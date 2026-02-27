# Problem Statement: Payroll Scripting & Formula Engine

> **Tài liệu:** Problem Statement & Business Requirements  
> **Module:** Payroll Engine — xTalent HCM  
> **Phiên bản:** 1.0  
> **Ngày:** 2026-02-27  
> **Trạng thái:** Draft — Chờ Architecture Board Review

---

## 1. Business Context

### 1.1 Bối cảnh xTalent HCM

xTalent HCM là giải pháp quản lý nhân sự (Human Capital Management) được xây dựng cho thị trường Việt Nam với định hướng mở rộng toàn cầu (open-source roadmap). Hệ thống cần tính lương (Payroll) đủ mạnh để đáp ứng:

- **Phức tạp nghiệp vụ VN**: Thuế TNCN lũy tiến 7 bậc, BHXH/BHYT/BHTN với trần sàn thay đổi theo Nghị định, phụ cấp điều kiện theo từng loại hợp đồng
- **Đa dạng cấu trúc lương**: Gross-to-Net, Net-to-Gross, 3P (Pay for Position, Pay for Person, Pay for Performance)
- **Yêu cầu audit & compliance**: Lưu vết đầy đủ cho thanh tra lao động, kiểm toán nội bộ
- **Khả năng global**: Kiến trúc đủ linh hoạt để hỗ trợ multi-country trong tương lai

### 1.2 Bài toán lõi

Tính lương không đơn giản là **"áp dụng công thức"**. Đây là bài toán phức tạp đa chiều:

```
Payroll = f(Employee Data, Time & Attendance, Benefits, Tax Rules, Policy Rules, Period Config)
```

Trong đó mỗi thành phần lương (Payroll Element) phụ thuộc vào nhau theo đồ thị dependency phức tạp, thay đổi theo:

- Thời gian (Luật, Nghị định cập nhật hàng năm)  
- Tổ chức (Policy khác nhau theo công ty, bộ phận, vị trí)  
- Nhân viên cá nhân (Ký kết phụ lục, thỏa thuận đặc biệt)

---

## 2. Problem Statement

### 2.1 Vấn đề hiện tại

Các hệ thống payroll thường rơi vào một trong hai cực:

| Loại | Đặc điểm | Rủi ro |
|------|----------|--------|
| **Hardcode logic** | Logic tính lương viết cứng trong code | Mỗi thay đổi cần release mới, không thể tự phục vụ nghiệp vụ |
| **Spreadsheet** | HR dùng Excel để tính toán | Không audit được, không tích hợp được, error-prone |

xTalent cần một **con đường thứ ba**: Payroll Engine với scripting/formula layer cho phép:

1. Nghiệp vụ (HR/Finance) tự cấu hình công thức mà không cần lập trình
2. Kỹ thuật kiểm soát được security, performance, audit
3. Hỗ trợ đầy đủ vòng đời: test → simulate → deploy → run

### 2.2 Tại sao không dùng expression engine đơn thuần?

Expression engine đơn thuần (JEXL, SpEL, CEL) **chỉ giải quyết** bài toán "tính một công thức":

```
result = baseSalary * 0.08   ← Đây chỉ là formula evaluation
```

Nhưng Payroll **thực sự cần**:

```
1. Tính gross salary            ← phụ thuộc attendance + base + allowances
2. Tính BHXH (trần 29.8tr)     ← phụ thuộc gross salary
3. Tính BHYT, BHTN             ← phụ thuộc gross salary
4. Tính thu nhập chịu thuế     ← gross - (BHXH+BHYT+BHTN) - giảm trừ gia cảnh
5. Tính thuế TNCN lũy tiến     ← phụ thuộc thu nhập chịu thuế
6. Tính net salary             ← gross - tổng khấu trừ
7. Điều chỉnh hồi tố           ← nếu tháng trước tính sai hoặc có thay đổi retroactive
```

Đây là **dependency graph** phức tạp, không phải một công thức đơn lẻ. Expression engine không có:
- Working memory (lưu trạng thái trung gian)
- Rule chaining (A → B → C)
- Dependency resolution (resolve thứ tự tính toán)
- Conflict resolution (khi nhiều rule cùng ảnh hưởng 1 element)

---

## 3. Business Requirements

### 3.1 Payroll Elements & Formula Authoring

**Mô tả:** Hệ thống phải cho phép định nghĩa Payroll Elements (các thành phần lương) và gán công thức tính toán cho từng element.

#### BR-001: Cấu trúc Payroll Element

Mỗi Payroll Element phải có:

```
PayrollElement {
  code: String              // Mã định danh (vd: BASE_SALARY, BHXH_EMPLOYEE)
  name: String              // Tên hiển thị
  type: Enum                // EARNING | DEDUCTION | INFORMATION | TAX
  formula: Formula          // Công thức tính
  dependencies: [Element]   // Các element cần tính trước
  ceiling: Decimal?         // Trần (nếu có)
  floor: Decimal?          // Sàn (nếu có)
  effectiveDate: Date       // Ngày có hiệu lực
  expiryDate: Date?         // Ngày hết hiệu lực
  countryCode: String       // VN | * (global)
}
```

#### BR-002: Formula DSL cho Business Users

Công thức phải **đọc được bởi người không phải lập trình viên**:

```
# Ví dụ công thức BHXH nhân viên đóng
min(baseSalary + allowances, bhxhCeiling) * 0.08

# Ví dụ công thức thuế TNCN
progressiveTax(taxableIncome, VN_TAX_BRACKETS_2024)

# Ví dụ phụ cấp có điều kiện
if (employeeType == "PROBATION") 0
else if (department == "SALES" && region == "HN") baseSalary * 0.15
else baseSalary * 0.10
```

**Yêu cầu DSL:**
- Syntax gần với ngôn ngữ tự nhiên / Excel formula
- Hỗ trợ: số học, so sánh, điều kiện (if/else), hàm built-in, tham chiếu element khác
- **Không cho phép**: truy cập file system, network calls, tạo object tùy ý, reflection

#### BR-003: Pre-built Formula Functions

Hệ thống cung cấp thư viện hàm built-in:

| Hàm | Mô tả |
|-----|-------|
| `min(a, b)`, `max(a, b)` | Lấy giá trị min/max |
| `round(value, digits)` | Làm tròn số |
| `progressiveTax(income, brackets)` | Tính thuế lũy tiến |
| `proRata(salary, workDays, totalDays)` | Tính theo ngày làm việc |
| `lookup(table, key)` | Tra bảng quy định |
| `sumElements([codes])` | Tổng nhiều elements |
| `ifNull(value, default)` | Xử lý giá trị null |

#### BR-004: Formula Versioning

- Mỗi formula phải có version theo thời gian hiệu lực
- Khi Nghị định mới ban hành, tạo version mới với ngày hiệu lực tương lai
- Hệ thống tự động áp dụng đúng version theo thời điểm tính lương

---

### 3.2 Rule Orchestration & Dependency Management

#### BR-005: Dependency Graph

- Hệ thống phải tự động phát hiện dependency giữa các Payroll Elements
- Tự động tính toán thứ tự thực thi (topological sort)
- Phát hiện và báo lỗi circular dependency

```
Ví dụ dependency chain Payroll VN:
ATTENDANCE_DAYS
  └─→ GROSS_SALARY
        ├─→ BHXH_BASE
        │     ├─→ BHXH_EMPLOYEE (8%)
        │     ├─→ BHYT_EMPLOYEE (1.5%)
        │     └─→ BHTN_EMPLOYEE (1%)
        └─→ TAXABLE_INCOME
              └─→ PIT_TAX (lũy tiến 7 bậc)
                    └─→ NET_SALARY
```

#### BR-006: Multi-Stage Recalculation

Hệ thống phải hỗ trợ tính lại theo từng giai đoạn:

1. **Stage 1 — Pre-payroll**: Tính các element cơ sở (attendance, base salary)
2. **Stage 2 — Gross Calculation**: Tính BHXH, phụ cấp, thưởng
3. **Stage 3 — Tax Calculation**: Tính thuế TNCN
4. **Stage 4 — Net Calculation**: Tính lương thực nhận
5. **Stage 5 — Post-processing**: Làm tròn, chia ra nhiều kỳ (nếu cần)

#### BR-007: Rule Conflict Resolution

Khi nhiều rule cùng ảnh hưởng một element (ví dụ: policy công ty vs chính sách cá nhân):

- Ưu tiên rule cụ thể hơn (employee-level > department-level > company-level)
- Ghi log xung đột để audit
- Cho phép cấu hình chiến lược xung đột (override vs merge)

---

### 3.3 Payroll Execution Modes

#### BR-008: Dry Run Mode

**Mục đích**: Kiểm tra công thức mà không tạo ra bất kỳ side effect nào.

**Use cases:**
- HR muốn kiểm tra công thức mới vừa tạo
- Phát hiện lỗi syntax, reference không tồn tại, circular dependency
- Kiểm tra kết quả trên một tập nhân viên mẫu nhỏ

**Yêu cầu kỹ thuật:**
- **Không persist** bất kỳ kết quả nào vào database
- Trả về kết quả tính toán kèm **intermediate values** (các giá trị trung gian)
- Trả về **rule firing log** (rule nào được kích hoạt, theo thứ tự nào)
- Trả về **error/warning** rõ ràng nếu có vấn đề
- Execution timeout: tối đa 30 giây

```
DryRunResult {
  employeeId: String
  period: YearMonth
  formulaVersion: String
  elements: [{
    code: String
    value: Decimal
    formula: String          // Công thức đã dùng
    inputs: Map<String, Any> // Các input đã dùng
    executionOrder: Int      // Thứ tự trong dependency chain
  }]
  ruleLog: [RuleExecution]
  errors: [Error]
  warnings: [Warning]
  executionTime: Long        // milliseconds
}
```

#### BR-009: Simulation Mode (Historical Data)

**Mục đích**: Chạy tính lương trên dữ liệu lịch sử với một version công thức mới, để so sánh kết quả.

**Use cases:**
- So sánh ảnh hưởng khi thay đổi policy: "Nếu dùng công thức mới, lương tháng 1/2025 sẽ khác bao nhiêu?"
- Kiểm tra tác động của Nghị định mới trước khi áp dụng
- Phân tích impact trên toàn bộ tập nhân viên

**Yêu cầu kỹ thuật:**
- Sử dụng **dữ liệu lịch sử** (historical employee data, attendance, benefits tại thời điểm đó)
- So sánh **side-by-side**: kết quả formula cũ vs formula mới
- Tạo **impact report**: tổng chênh lệch, nhân viên bị ảnh hưởng, phân phối chênh lệch
- **Không modify** dữ liệu historical
- Hỗ trợ chạy song song nhiều nhân viên (batch simulation)
- Lưu kết quả simulation vào bảng riêng (có thể xóa sau khi review)

```
SimulationResult {
  simulationId: UUID
  period: YearMonth
  formulaVersion: String       // Version mới đang test
  baselineVersion: String      // Version cũ để compare
  employees: [{
    employeeId: String
    baseline: PayrollResult    // Kết quả version cũ
    simulated: PayrollResult   // Kết quả version mới
    delta: Map<ElementCode, Decimal>  // Chênh lệch từng element
  }]
  summary: {
    totalEmployees: Int
    totalDeltaGross: Decimal
    totalDeltaNet: Decimal
    affectedCount: Int
  }
}
```

#### BR-010: Production Run Mode

**Mục đích**: Chạy tính lương chính thức, tạo ra kết quả được lưu và phê duyệt.

**Giai đoạn thực hiện:**
```
1. Pre-payroll Validation
   ├── Kiểm tra missing data (time & attendance chưa đủ)
   ├── Kiểm tra formula errors
   └── Kiểm tra thay đổi master data bất thường

2. Calculation Run
   ├── Batch process tất cả nhân viên trong payroll group
   ├── Execute theo dependency order
   └── Ghi chi tiết từng element, từng rule

3. Post-Calculation Review
   ├── Variance report (so sánh với kỳ trước)
   ├── Exception report (nhân viên có kết quả bất thường)
   └── Checklist nghiệp vụ

4. Approval & Close
   ├── Phê duyệt từng cấp (HR Manager → Finance → CFO)
   └── Lock payroll period
```

**Yêu cầu kỹ thuật:**
- **Transactional**: Toàn bộ batch là một transaction — all-or-nothing
- **Idempotent**: Chạy lại nhiều lần với cùng input phải cho cùng output (deterministic)
- **Audit trail**: Ghi log toàn bộ: ai chạy, lúc nào, formula version nào, từng bước
- **Performance**: Tính lương cho 10,000 nhân viên trong vòng 5 phút
- **Lock mechanism**: Không cho phép sửa dữ liệu đang trong quá trình chạy

---

### 3.4 Retroactive Adjustment

#### BR-011: Xử lý hồi tố (Retroactive)

Retroactive xảy ra khi có thay đổi có hiệu lực hồi tố:
- Nâng lương từ tháng trước (approved muộn)
- Phát hiện tính sai kỳ trước
- Thay đổi chính sách có hiệu lực hồi tố

**Cơ chế:**

```
Kỳ tháng 2 (hiện tại):
  - Phát hiện tháng 1 tính sai BHXH do nhân viên X tăng lương
  - Recalculate kỳ tháng 1 với lương mới
  - Delta_BHXH = BHXH_tháng1_mới - BHXH_tháng1_cũ
  - Đưa delta vào kỳ tháng 2 (forwarding difference)
```

**Yêu cầu:**
- Không overwrite kết quả kỳ cũ — tạo retroactive adjustment record
- Cascading effects: thay đổi một element phải trigger recalculation chain
- Giới hạn độ sâu hồi tố: tối đa N kỳ về trước (cấu hình được)
- Bắt buộc có approval trước khi áp dụng retroactive

---

### 3.5 Audit & Compliance

#### BR-012: Audit Trail

Mọi hoạt động của Payroll Engine phải được ghi lại:

```
AuditEntry {
  timestamp: DateTime
  userId: String
  action: Enum              // RUN | DRY_RUN | SIMULATE | APPROVE | MODIFY_FORMULA
  entityType: String        // PAYROLL_RUN | FORMULA | ELEMENT
  entityId: String
  details: {
    inputSnapshot: Any      // Snapshot input tại thời điểm chạy
    formulaVersion: String
    resultHash: String      // Hash kết quả để verify
  }
}
```

#### BR-013: Formula Governance

- Mỗi công thức phải qua quy trình duyệt trước khi active
- Không cho phép edit công thức đang active — phải tạo version mới
- Lịch sử toàn bộ change có thể xem và revert
- Phân quyền: HR có thể xem, HR Manager có thể draft, Finance Lead có thể approve

---

### 3.6 Vietnam-Specific Requirements

#### BR-014: Thuế TNCN Lũy Tiến

Support biểu thuế VN 2025 (7 bậc):

| Bậc | Thu nhập tính thuế/tháng | Thuế suất |
|-----|--------------------------|-----------|
| 1 | Đến 5 triệu | 5% |
| 2 | 5 – 10 triệu | 10% |
| 3 | 10 – 18 triệu | 15% |
| 4 | 18 – 32 triệu | 20% |
| 5 | 32 – 52 triệu | 25% |
| 6 | 52 – 80 triệu | 30% |
| 7 | Trên 80 triệu | 35% |

- Giảm trừ gia cảnh: Bản thân 11 tr/tháng, phụ thuộc 4.4 tr/người/tháng
- Hỗ trợ tính năm (quyết toán) và cấn trừ tháng

#### BR-015: BHXH / BHYT / BHTN

| Loại | Nhân viên | Công ty | Trần |
|------|-----------|---------|------|
| BHXH | 8% | 17.5% | 20 × lương cơ sở |
| BHYT | 1.5% | 3% | 20 × lương cơ sở |
| BHTN | 1% | 1% | 20 × lương cơ sở |
| TNLĐ | 0% | 0.5% | 20 × lương cơ sở |

- Lương cơ sở cập nhật theo Nghị định (hiện tại: 2,340,000 VND/tháng từ 7/2024)
- Trần BHXH = 20 × lương cơ sở = 46,800,000 VND/tháng
- Hỗ trợ thay đổi trần/sàn theo hiệu lực ngày

#### BR-016: Hợp đồng & Loại nhân viên

Phân biệt xử lý theo:
- Hợp đồng lao động không xác định thời hạn
- Hợp đồng lao động xác định thời hạn (12-36 tháng)
- Thử việc (2 tháng — không đóng BHXH)
- Cộng tác viên / Freelancer (thuế khoán 10%)
- Người nước ngoài (tax residency check, expat tax treaty)

---

## 4. Non-Functional Requirements

### 4.1 Security

| Yêu cầu | Chi tiết |
|---------|---------|
| **Injection Prevention** | Formula DSL không cho phép truy cập arbitrary API, file system, network |
| **Sandboxing** | Mỗi formula execution trong isolated context |
| **Class Whitelist** | Chỉ các class được phê duyệt mới accessible trong formula |
| **Pre-compile Validation** | Formula phải compile & validate trước khi active |
| **No Reflection** | Không cho phép reflection trong formula |

### 4.2 Performance

| Scenario | Target |
|---------|--------|
| Dry Run - 1 nhân viên | < 100ms |
| Dry Run - 100 nhân viên | < 5s |
| Simulation - 1,000 nhân viên/kỳ | < 2 phút |
| Production Run - 10,000 nhân viên | < 5 phút |
| Formula compile (one-time) | < 1s |

### 4.3 Determinism

- Cùng input + cùng formula version → cùng output (mọi lúc, mọi nơi)
- Không phụ thuộc vào thứ tự xử lý thread
- Không sử dụng random, timestamp không xác định trong formula

### 4.4 Extensibility (Global Payroll)

- Kiến trúc phải cho phép thêm country-specific element mà không sửa engine core
- Country override: formula VN được kế thừa và override bởi formula cùng code cho quốc gia khác
- Plugin architecture cho country-specific built-in functions

---

## 5. Constraints & Non-Goals

### 5.1 Trong phạm vi (In Scope)

- ✅ Formula authoring & versioning
- ✅ Dry Run, Simulation, Production Run
- ✅ Rule dependency management
- ✅ Retroactive adjustment
- ✅ Audit trail
- ✅ Vietnam payroll (TNCN, BHXH/BHYT/BHTN)
- ✅ Security sandboxing

### 5.2 Ngoài phạm vi (Out of Scope — v1)

- ❌ AI-assisted formula authoring (future)
- ❌ Real-time streaming payroll calculation (future)
- ❌ BI/Analytics dashboard (separate module)
- ❌ Bank payment integration (separate module)
- ❌ Non-VN country support (v2+)

---

## 6. Success Criteria & Acceptance Criteria

### 6.1 MỤC TIÊU

| Mục tiêu | Đo lường |
|---------|---------|
| Business user tự cấu hình được công thức đơn giản | Không cần lập trình viên hỗ trợ |
| Phát hiện lỗi formula trước khi go-live | Dry run phát hiện 100% lỗi syntax & reference |
| Impact analysis trước khi đổi policy | Simulation chạy được trên full historical dataset |
| Full audit trail | 100% operation được log với đủ context |
| Performance benchmark đạt | Theo bảng Non-Functional Requirements |

### 6.2 ACCEPTANCE CRITERIA

- [ ] **AC-001**: HR có thể tạo công thức cho element mới trong < 30 phút (không cần lập trình viên)
- [ ] **AC-002**: Dry Run phát hiện circular dependency và báo lỗi rõ ràng
- [ ] **AC-003**: Simulation tạo được báo cáo impact (so sánh cũ vs mới) cho 1,000 nhân viên
- [ ] **AC-004**: Production Run cho 5,000 nhân viên trong < 3 phút
- [ ] **AC-005**: Formula injection (vd: `Runtime.exec()`) bị từ chối ở compile stage
- [ ] **AC-006**: Toàn bộ lịch sử công thức có thể xem và revert
- [ ] **AC-007**: Kết quả Production Run khớp 100% với manual calculation (TNCN, BHXH)

---

## 7. References

- Luật Thuế TNCN sửa đổi 2024
- Nghị định 73/2024/NĐ-CP (Lương cơ sở)
- Bộ Luật Lao động 2019 (BHXH/BHYT/BHTN)
- Oracle HCM Fast Formula Documentation
- SAP SuccessFactors Employee Central Payroll Guide
- ADR-001: Payroll Rule & Formula Engine Architecture (xem: `adr.md`)
- Technical Proposal: Payroll Rule & Formula Engine Architecture (xem: `tech-proposal.md`)

---

*Tài liệu này dùng làm input cho: `02-detailed-analysis.md` (Phân tích & So sánh chi tiết) và `03-proposal.md` (Đề xuất kiến trúc)*
