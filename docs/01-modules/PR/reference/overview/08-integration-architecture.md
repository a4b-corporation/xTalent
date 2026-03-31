# Integration Architecture — Tích hợp Hệ thống

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Developer, Architect, IT Manager  
**Thời gian đọc**: ~15 phút

---

## Tổng quan

PR module không hoạt động độc lập — nó là **điểm hội tụ** của dữ liệu từ nhiều module và là **nguồn đầu ra** cho hệ thống kế toán, ngân hàng, và cơ quan thuế. **PayrollInterface** entity là nơi định nghĩa các integration points này.

```
                    ┌─────────────────┐
    CO Module ─────►│                 │◄─────── TA Module
    (Employee,      │   PR Module     │         (Attendance,
     Assignment,    │   Payroll       │          Overtime,
     LegalEntity)   │   Engine        │          Leave)
                    │                 │
    TR Module ─────►│                 │◄─────── Manual Input
    (Compensation,  │                 │         (Adjustments,
     Benefits,      └────────┬────────┘          Advances)
     TaxableBridge)          │
                             │
           ┌─────────────────┼────────────────┐
           ▼                 ▼                ▼
      Banking Systems    GL/Accounting    Tax Authorities
      (Payment files)   (Journal entries)  (PIT reports,
                                           BHXH filings)
```

---

## 1. PayrollInterface — Entity Cấu hình Tích hợp

**PayrollInterface** là AGGREGATE_ROOT định nghĩa từng kết nối tích hợp — cả inbound (nhận dữ liệu vào) và outbound (gửi dữ liệu ra).

```
PayrollInterface {
  interfaceCode: String           // CO_EMPLOYEE_SYNC, TA_ATTENDANCE_IMPORT...
  direction: Enum                 // INBOUND | OUTBOUND | BIDIRECTIONAL
  sourceSystem: String            // CO, TA, TR, BANK, TAX_AUTHORITY
  
  triggerType: Enum               // EVENT_DRIVEN | SCHEDULED | MANUAL
  schedule: String?               // Cron expression nếu SCHEDULED
  
  dataMapping: [FieldMapping]     // Field-to-field mapping rules
  transformations: [Transform]    // Data transformations (currency, date format...)
  
  errorHandling: {
    retryCount: Integer
    alertOnFailure: Boolean
    fallbackAction: Enum          // SKIP | HOLD | ALERT
  }
}
```

---

## 2. Inbound Integrations — Nhận Dữ liệu

### 2.1 CO Module — Core HR Data

CO (Core HR) là **nguồn sự thật** cho dữ liệu cơ bản. PR không tự quản lý employee hay org structure — mà consume từ CO.

| Data | CO Entity | Dùng trong PR | Trigger |
|------|----------|---------------|---------|
| Worker/Employee | `Employee` | PayGroup assignment | Employee created/updated |
| Salary | `Assignment.salary` | BASE_SALARY element | Salary change event |
| Contract type | `Contract.type` | BHXH eligibility logic | Contract change |
| Legal Entity | `LegalEntity` | PayCalendar, GL mapping | Org structure change |
| Cost Center | `Position.costCenter` | CostingRule allocation | Position change |
| Grade/Level | `Grade` | Formula conditions | Grade change |

```
Event flow example:
  HR tăng lương cho Employee A (CO module)
    → CO emits: SalaryChanged { employeeId, newSalary, effectiveDate }
    → PR receives:
        - Update BASE_SALARY element value
        - Flag for retroactive if effectiveDate is in past period
        - Trigger pre-validation check for next payroll run
```

**Data Sync cần thiết trước Payroll Run**:
- `PayGroup` membership (employee → PayGroup assignment)
- Employment status (ACTIVE / TERMINATED / ON_LEAVE)
- Contract type và effective dates
- Salary và allowance amounts (từ TR compensation data)
- Number of dependents (cho PIT giảm trừ)

### 2.2 TA Module — Time & Attendance

**TA (Time & Absence)** cung cấp dữ liệu thực tế về ngày làm việc, giờ làm thêm, nghỉ phép — là input quan trọng để tính lương chính xác.

| Data từ TA | Element trong PR | Công thức |
|-----------|-----------------|-----------|
| `actualWorkDays` | `ACTUAL_WORK_DAYS` | Input cho proRata() |
| `overtimeHours` | `OVERTIME_HOURS` | Multiplier tính OT pay |
| `nightShiftDays` | `NIGHT_SHIFT_DAYS` | Night shift bonus |
| `leaveWithoutPay` | `UNPAID_LEAVE_DAYS` | Trừ khỏi actualWorkDays |
| `approvedLeave` | `ANNUAL_LEAVE_TAKEN` | Informational |

```
Cutoff Date rule:
  T&A data phải COMPLETE trước PayPeriod.cutoffDate
  → Sau cutoff: không thể thêm/sửa T&A cho kỳ đó
  → PayrollRun sẽ fetch T&A snapshot tại thời điểm cutoff
  → Nếu T&A chưa đủ → Stage 1 validation sẽ ERROR
```

### 2.3 TR Module — Total Rewards Data

**TR (Total Rewards)** cung cấp dữ liệu về bonus, equity, benefits premiums và **TaxableBridge** (điểm quan trọng nhất):

| Data từ TR | Mô tả |
|-----------|-------|
| **CompensationComponent** | Danh sách pay components áp dụng cho employee (salary basis, allowances) |
| **BonusPlan result** | Kết quả tính bonus period → thêm vào payroll element BONUS |
| **TaxableBridge items** | RSU vest / Option exercise → taxable income phải tính vào PR |
| **BenefitPremium** | Employee share của benefits premium → deduction từ net |
| **TaxWithholdingElection** | Khai báo giảm trừ (số người phụ thuộc, phụ lục) |

```
TaxableBridge flow (quan trọng):
  TR: RSU Vest event for Employee A
    → TR creates: TaxableItem { employeeId, amount: 50,000,000, type: RSU_VEST, period: 2025-03 }
    → PR receives TaxableItem → add to TAXABLE_INCOME for period 3/2025
    → PIT_TAX tính bao gồm cả 50M từ RSU
    → Không bị bỏ sót thuế từ equity events
```

---

## 3. Outbound Integrations — Gửi Dữ liệu Ra

### 3.1 Banking Systems — Thanh toán

```
Flow chuẩn:
  Production Run LOCKED
    → Generate bank file (theo BankTemplate)
    → Admin download → upload lên banking portal
    → Bank confirms payment
    → Post payment: update NetPayment record với bankRef, paymentDate
    
Future (API integration):
  → Direct API submission to bank
  → Real-time payment status webhook
  → Auto-reconciliation
```

Xem chi tiết format: [07 Accounting & Reporting · BankTemplate](./07-accounting-reporting.md)

### 3.2 GL / Accounting System

```
Post-approval flow:
  Approval: Finance approved → Period LOCKED
    → Auto-generate GL Journal Entries (theo GLMappingPolicy)
    → Post to Accounting System (ERP / Accounting software)
    
Integration format:
  - Native: Journal Entry API (REST/SOAP)
  - File-based: CSV/XML export cho manual import
  - SAP CO-PA: Cost accounting entry format
  - Standard: IFRS/VAS compliant journal structure
```

### 3.3 Tax Authorities — Cơ quan Thuế

```
Vietnam:
  PIT Quarterly filing: XML theo mẫu TT8/2013
    → Gửi cổng dịch vụ thuế điện tử (eTax.gdt.gov.vn)
  Annual settlement: Quyết toán năm (tháng 3 năm sau)
  
  BHXH monthly filing: VssID format
    → Cổng giao tiếp điện tử BHXH (vssid.bhxh.gov.vn)

Future countries:
  Singapore: CPF monthly submission → CPF Board
  USA: IRS Form 941 quarterly, W-2 annual
```

---

## 4. Event Model

PR module publish và consume events theo Event-Driven Architecture:

### Events PR publishes (output)

| Event | Trigger | Consumers |
|-------|---------|-----------|
| `PayrollRunCompleted` | Production run finished | TR (update YTD), Accounting, HR Dashboard |
| `PeriodLocked` | Payroll approved | Accounting (post GL), Payroll history |
| `PayslipGenerated` | After period locked | Notification service → Employee email |
| `AdjustmentApplied` | Retroactive processed | Audit system, Finance alert |
| `FormulaActivated` | New formula version active | Monitoring, audit log |

### Events PR consumes (input)

| Event | Source | Action |
|-------|--------|--------|
| `EmployeeSalaryChanged` | CO | Update BASE_SALARY, flag retro if past |
| `EmployeeTransferred` | CO | Update PayGroup assignment |
| `AttendanceLocked` | TA | Signal T&A data ready for cutoff |
| `TaxableItemCreated` | TR | Add to taxable income for period |
| `BenefitEnrollmentChanged` | TR | Update benefit premium deduction |

---

## 5. Security & Access Control

### Role-Based Access

| Role | Quyền |
|------|-------|
| **Payroll Admin** | Tạo/chạy payroll run, manage PayGroups, import T&A, view all payroll data |
| **HR Manager** | Approve payroll (bước 1), view summary reports, không xem chi tiết từng người |
| **Finance Manager/CFO** | Final approve, view budget reports, GL reconciliation |
| **HR Staff** | Manage employee assignments, không xem payroll results |
| **Employee** | Xem payslip của bản thân, download PDF |
| **Auditor** | Read-only toàn bộ — payroll results, audit logs, formula history |
| **IT/Developer** | Formula Studio (không production data), system configuration |

### Data Privacy

```
Payroll data là HIGHLY SENSITIVE (PII + financial):

  Masking rules:
    → Employee xem payslip: chỉ thấy của mình
    → HR Manager xem report: salary masked (hiện range, không hiện số tuyệt đối)
    → Export to CSV: số tài khoản ngân hàng masked (last 4 digits only)
    
  Encryption:
    → At rest: AES-256 cho payroll_result table
    → In transit: TLS 1.3
    → Bank file: encrypted khi gửi (theo yêu cầu từng ngân hàng)
    
  Retention:
    → Payroll results: 7 năm (theo Luật Kế toán VN)
    → Audit logs: 7 năm, immutable
    → Simulation results: xóa sau 90 ngày hoặc khi admin delete
```

---

## 6. API Patterns

### Payroll Run API

```
POST /api/payroll/runs
  body: { groupId, period, mode: "DRY_RUN" | "SIMULATION" | "PRODUCTION" }
  response: { runId, status: "INITIATED" }

GET /api/payroll/runs/{runId}
  response: { runId, status, progress, elementsProcessed, errors }

GET /api/payroll/runs/{runId}/results
  response: { employees: [...], summary: {...} }

POST /api/payroll/runs/{runId}/approve
  body: { approverNote }
  response: { status: "APPROVED", lockedAt }
```

### Employee Payslip API

```
GET /api/payslips?employeeId=EMP-001&period=2025-03
  response: { payslipId, period, gross, net, elements: [...] }

GET /api/payslips/{payslipId}/pdf
  response: Binary PDF stream

GET /api/payslips/ytd?employeeId=EMP-001&year=2025
  response: { ytdGross, ytdPIT, ytdBHXH, periods: [...] }
```

---

## 7. Môi trường và Deployment

```
Architecture note:
  Drools 8 chạy IN-PROCESS với application server
  → Không cần external rule server riêng (không giống KieServer standalone)
  → Giảm latency, đơn giản hóa deployment, không có network overhead

Dependencies (toàn bộ JVM):
  drools-core 8.x         → Rule engine
  drools-mvel             → MVEL dialect (native)
  antlr4-runtime          → DSL parser
  mvel2                   → Formula evaluation
  spring-batch            → Batch processing framework
  quartz                  → Job scheduling

Horizontal scaling:
  → Stateless application tier (KieSession không share giữa requests)
  → Partition batch bằng PayGroup → mỗi instance xử lý subset
  → Database: Postgres với read replicas cho reporting queries
```

---

*← [07 Accounting & Reporting](./07-accounting-reporting.md) · [README →](./README.md)*
