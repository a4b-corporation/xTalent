# Integration Architecture

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: Developers, Solution Architects  
**Đọc ~15 phút**

---

## Tổng quan

TR module không hoạt động độc lập — nó nhận dữ liệu từ nhiều module khác và cung cấp dữ liệu cho downstream systems. Tài liệu này mô tả tất cả integration points, event model, và các yêu cầu security/data privacy.

```
                    ┌─────────────────────────┐
                    │        TR MODULE         │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼──────────────────┐
        ↑                       ↓                  ↓
   CO Module              PR (Payroll)       External Systems
   (Provider)             (Consumer)         (Provider/Consumer)
   
        ↑
   TA Module (partial)
```

---

## 1. CO Module Integration (Core HR → TR)

CO module là **provider** chính của TR — cung cấp dữ liệu nền tảng về organization, worker, và job.

### Data Dependencies

| CO Entity | TR sử dụng | Mục đích |
|-----------|------------|---------|
| **Worker** | CompensationAssignment.worker_id | Link compensation đến nhân viên |
| **Assignment** | CompensationAssignment.assignment_id | Xác định loại staffing (position-based/job-based) |
| **Job** | GradeVersion.grade_code | Grade code → Pay range lookup |
| **Position** | PayRange.scope_type = POSITION | Position-specific pay range |
| **LegalEntity** | Country-specific tax rules, SI rates | Tax/SI calculation context |
| **BusinessUnit** | PayRange.scope_type = BU, BudgetAllocation | Pay range + budget allocation |
| **WorkerType** | Eligibility rules | Full-time vs hourly eligibility |

### Critical Data Flow — Grade Resolution

```
CO.Job.grade_code  ──────────→  TR.GradeVersion (by grade_code)
                                         │
CO.Assignment.position_id ──→  TR.PayRange (scope: POSITION)
CO.Assignment.business_unit ─→ TR.PayRange (scope: BU)
CO.Assignment.legal_entity ──→ TR.PayRange (scope: LE)
                               TR.PayRange (scope: GLOBAL as fallback)
```

> **Quy tắc**: Scope cụ thể nhất thắng. TR.GradeVersion là nguồn dữ liệu chính — CO.JobGrade đã deprecated.

### Common Integration Workflows

**New Hire Setup:**
```
1. CO: Create Worker + Assignment (to Position or Job)
2. CO: Job đã có grade_code (ví dụ: G3)
3. TR: Lookup GradeVersion(G3) + PayRange (scope resolution)
4. TR: Validate offer amount ≤ max of applicable PayRange
5. TR: Create EmployeeCompensation record
6. TR: Assign Benefit plans (based on EligibilityProfile)
```

**Promotion:**
```
1. CO: End current Assignment, create new Assignment (higher Job/Grade)
2. CO: New Job has higher grade_code (G3 → G4)
3. TR: Detect Assignment change event
4. TR: Lookup new PayRange for G4
5. TR: Validate new salary within G4 range
6. TR: Create CompensationAdjustment (type: PROMOTION)
7. TR: Create new GradeVersion record (SCD Type 2)
```

---

## 2. Payroll Module Integration (TR → PR)

TR module là **provider** cho Payroll — gửi tất cả data cần thiết để tính lương và xử lý thuế.

### Data TR gửi sang Payroll

| TR Data | PR Nhận | Mục đích |
|---------|---------|---------|
| **TaxableItem** | Taxable events | RSU vest, perk redemption → withhold tax |
| **PayComponent** | Pay component values | Thành phần lương cho payslip |
| **DeductionTransaction** | Deductions | Loan/garnishment/advance khấu trừ |
| **TaxWithholdingElection** | Tax elections | W-4, VN tax declarations |
| **BenefitPremium** | Employee benefit costs | Khấu trừ premium từ lương |
| **CommissionTransaction** | Commission payments | Thưởng hoa hồng |
| **BonusAllocation** | Bonus payments | Thưởng hiệu suất |

### TaxableItem — Data Contract

```yaml
TaxableItem:
  id:               UUID
  employee_id:      FK → Worker
  amount:           Decimal (taxable income amount)
  source:           EQUITY_VESTING | EQUITY_EXERCISE | PERK_REDEMPTION | BENEFIT_PREMIUM
  item_type:        SUPPLEMENTAL_INCOME | REGULAR_INCOME | IMPUTED_INCOME
  tax_year:         YYYY
  withholding_method: SUPPLEMENTAL | AGGREGATE | ANNUALIZED
  pay_period:       FK → PayPeriod (kỳ lương để xử lý)
  status:           PENDING | PROCESSED | CANCELLED
  created_at:       Timestamp
```

---

## 3. TA Module Integration (Time & Absence ↔ TR)

### TA → TR (Dữ liệu thời gian vào Variable Pay & Proration)

```yaml
OvertimeHours → TR Variable Pay:
  TA ghi nhận OT approved hours (theo ngày)
  TR nhận và tính overtime pay:
    OT Daily (> 8h/ngày): ×1.5 rate
    OT Rest Day: ×2.0 rate
    OT Holiday: ×3.0 rate

AttendanceData → TR Proration:
  Ngày làm việc thực tế → proration factor cho working days method
  Unpaid leave days → proration deduction

LeaveBalance → Benefits Coordination:
  FMLA/parental leave tracking
  Benefits continuation during leave
```

### TR → TA (ít phổ biến hơn)

```yaml
Shift Differential Pay:
  TR có thể define premium pay cho specific shift types
  TA cung cấp shift data → TR tính shift differential → Payroll
```

---

## 4. External System Integrations

### Benefits Carriers — EDI 834

```yaml
Trigger: Sau khi enrollment period đóng hoặc life event processed

EDI 834 File Content:
  - Employee demographics (name, DOB, SSN)
  - Plan elections (plan code, coverage tier)
  - Dependent information (relationship, DOB, SSN)
  - Enrollment dates (effective start/end)
  - Premium amounts

Flow:
  TR generates EDI 834 → SFTP/API → Carrier processes → ACK
  
Error handling:
  Carrier rejects → HR gets notification → Manual resolution
  Carrier sends 999 ACK → TR marks as confirmed
```

### Stock Plan Administrator (Equity)

```yaml
Bidirectional sync:

TR → Stock Admin:
  New equity grants (grant details, employee info)
  Grant modifications (accelerated vesting, forfeiture)

Stock Admin → TR:
  Vesting confirmation (for RSU)
  Exercise transactions (for options)
  FMV data (daily for vest/exercise calculations)
  
API pattern: REST API với OAuth 2.0
Sync frequency: Daily batch + real-time for exercises
```

### Tax Authorities

```yaml
US — IRS:
  W-2 (Wage and Tax Statement):
    - Annual, generated Jan 31
    - Submitted electronically (SSA format)
    - Employee copy mailed or self-service download
  
  1099-B (Broker transactions):
    - For stock sales (forwarded to brokerage)
  
  1099-NEC:
    - For contractor payments (if applicable)

Vietnam — Thuế cục:
  Quyết toán thuế TNCN:
    - Hàng năm (deadline 31/3 năm sau)
    - Báo cáo theo mẫu quy định
    - Kèm danh sách người phụ thuộc

  Báo cáo SI (BHXH online):
    - Hàng tháng
    - Tăng/giảm lao động
    - Điều chỉnh mức đóng
```

---

## 5. Event Architecture

TR emit events cho các hành động quan trọng. Các module khác subscribe và phản ứng tự động.

### Key Events & Consumers

| Event | Producer | Consumer | Mục đích |
|-------|---------|---------|---------|
| `comp.adjustment.approved` | TR | Payroll, Notification | Thông báo thay đổi lương |
| `equity.vested` | TR | Payroll, Notification | RSU vest → TaxableItem created |
| `benefit.enrolled` | TR | Benefits Carrier | Trigger EDI 834 |
| `benefit.life_event.verified` | TR | TR (open window) | Mở enrollment window |
| `offer.accepted` | TR | CO, Onboarding | Chuyển sang onboarding workflow |
| `recognition.point.awarded` | TR | Notification | Gửi notification đến recipient |
| `deduction.created` | TR | Payroll | Inform next payroll cycle |

---

## 6. Role-Based Access Control

| Role | Quyền truy cập |
|------|---------------|
| **HR Administrator** | Full access: configure plans, run cycles, generate statements, audit |
| **Compensation Manager** | Configure comp plans/grades, run merit cycles, view analytics |
| **Benefits Administrator** | Configure benefit plans, manage enrollment, process claims |
| **Manager** | View team compensation, propose adjustments, approve bonuses, give recognition |
| **Employee (Self-service)** | View own compensation, enroll benefits, view statement, redeem points |
| **Recruiter** | Create/send offer packages, view offer status |
| **Finance/Payroll** | View TaxableItems, audit reports, budget analytics |

---

## 7. Data Privacy & Security

### Sensitive Data Classification

```yaml
Highly Sensitive (encryption at rest + in transit):
  - National ID / SSN / Tax ID
  - Health information (claims, diagnoses, dependents)
  - Salary and compensation data
  - Equity grant details
  - Bank account information

Moderately Sensitive (access-controlled):
  - Performance ratings
  - Benefit enrollment elections
  - Tax withholding elections

Data Masking:
  - Salary data: Masked from non-authorized roles
  - SSN: Last 4 digits only in UI
  - Health info: Need-to-know basis
```

### Compliance Requirements

```yaml
GDPR (EU employees):
  ✅ Consent for data collection
  ✅ Right to access (employee can download own data)
  ✅ Right to correction
  ✅ Data retention limits (7 years max then purge)
  ✅ Breach notification (72 hours)
  ✅ Vendor DPA (benefits carriers, stock admin)

Vietnamese Law (Nghị định 13/2023):
  ✅ Consent for processing personal data
  ✅ Purpose limitation
  ✅ Security measures
  ✅ Cross-border transfer controls

SOX Compliance:
  ✅ Segregation of duties (maker-checker)
  ✅ Audit trail for all financial data changes
  ✅ Access reviews (quarterly)
  ✅ Evidence for external auditor
```

---

*Nguồn: `01-concept-overview.md` (Integration Points) · `02-spec/05-integration-spec.md` · `02-spec/06-security-spec.md` · `03-compensation-management-guide.md` (CO Integration section)*  
*← [06 Calculation & Compliance](./06-calculation-compliance.md) · [README →](./README.md)*
