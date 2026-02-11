# Absence Management - Domain Glossary

> Comprehensive glossary of terms used in the Absence sub-module

---

## Configuration Entities

### Leave Class
**Định nghĩa**: Phân loại cấp cao của các loại phép (ví dụ: Phép có lương, Phép không lương, Phép theo luật định).

**Mục đích**: Nhóm các leave types tương tự nhau để áp dụng policies chung.

**Ví dụ**:
- **Paid Time Off (PTO)**: Bao gồm Annual Leave, Sick Leave
- **Unpaid Leave**: Bao gồm Unpaid Personal Leave
- **Statutory Leave**: Bao gồm Maternity Leave, Paternity Leave

---

### Leave Type
**Định nghĩa**: Loại phép cụ thể mà nhân viên có thể đăng ký.

**Thuộc tính quan trọng**:
- **isPaid**: Phép có được trả lương không
- **requiresApproval**: Cần phê duyệt không
- **allowsHalfDay**: Cho phép nghỉ nửa ngày không
- **unitOfMeasure**: Tính theo ngày hay giờ

**Ví dụ**:
- **Annual Leave**: Phép năm, có lương, cần phê duyệt
- **Sick Leave**: Phép ốm, có lương, có thể không cần phê duyệt trước
- **Maternity Leave**: Phép thai sản, theo luật định

---

## Policy & Rules Entities

### Policy Library
**Định nghĩa**: **UI module** (không phải entity) để quản lý tập trung các rules.

**Mục đích**: Cung cấp giao diện để:
- Tạo và quản lý các loại rules (Eligibility, Validation, Accrual, etc.)
- Bind rules vào LeaveType hoặc LeaveClass
- Xem tất cả rules đang áp dụng cho một leave type
- Reuse rules across multiple leave types

**Lưu ý quan trọng**: 
- Policy Library là **UI concept**, không phải database table
- Các rules là **independent entities** trong database
- Mỗi rule có thể bind trực tiếp vào LeaveType HOẶC LeaveClass
- Không có entity "Policy" làm container

**Ví dụ workflow**:
1. HR vào Policy Library UI
2. Tạo một EligibilityRule: "Tenure >= 6 months"
3. Bind rule này vào LeaveClass "PTO" → áp dụng cho tất cả leave types trong class
4. HOẶC bind vào LeaveType "Annual Leave" cụ thể → chỉ áp dụng cho Annual Leave

---

### Rules - General Concept

**Định nghĩa**: Các quy tắc độc lập có thể bind vào LeaveType hoặc LeaveClass.

**Thuộc tính chung**:
- **code**: Mã định danh duy nhất (để reuse)
- **name**: Tên rule
- **leaveTypeId** HOẶC **leaveClassId**: Bind vào type hoặc class
- **priority**: Độ ưu tiên (số cao hơn = ưu tiên cao hơn)
- **effectiveDate/endDate**: Thời gian hiệu lực

**Nguyên tắc binding**:
- Một rule chỉ có thể bind vào **HOẶC** LeaveType **HOẶC** LeaveClass, không được cả hai
- Rule bind vào LeaveClass → áp dụng cho tất cả LeaveTypes trong class đó
- Rule bind vào LeaveType → chỉ áp dụng cho type cụ thể đó
- Nếu có conflict, rule có priority cao hơn thắng

**Ví dụ**:
```
EligibilityRule #1:
  code: "TENURE_6M"
  name: "Tenure >= 6 months"
  leaveClassId: "PTO_CLASS"
  priority: 10
  → Áp dụng cho: Annual Leave, Sick Leave (cả class)

EligibilityRule #2:
  code: "TENURE_12M"  
  name: "Tenure >= 12 months"
  leaveTypeId: "ANNUAL_LEAVE"
  priority: 20
  → Áp dụng cho: Chỉ Annual Leave
  → Vì priority cao hơn, rule này override rule #1 cho Annual Leave
```

---

## Eligibility & Hybrid Model

### Eligibility Architecture Overview

**Định nghĩa**: Hệ thống quản lý eligibility tập trung (centralized) cho phép xác định **WHO** is eligible (ai đủ điều kiện) tách biệt khỏi **WHAT** they're eligible for (đủ điều kiện cho cái gì).

**Key Innovation**: 
- **Organizational Scope** (WHO): Managed by `EligibilityProfile` in Core module
- **Object Scope** (WHAT): Managed by `leaveTypeId`, `leaveClassId` in TA module

**Tham khảo**: Xem [Eligibility Engine Guide](../../CO/01-concept/11-eligibility-engine-guide.md) và [Eligibility Glossary](../../CO/00-ontology/glossary-eligibility.md) để hiểu chi tiết về kiến trúc eligibility.

---

### Hybrid Eligibility Model

**Định nghĩa**: Mô hình kết hợp giữa **Default Eligibility** (ở cấp Class/Type) và **Override Eligibility** (ở cấp Rule).

**Hierarchy**:
```
LeaveClass (default_eligibility_profile_id)
  ↓
LeaveType (default_eligibility_profile_id) - can override class
  ↓
AccrualRule (eligibility_profile_id) - can override type
CarryoverRule (eligibility_profile_id) - can override type
LimitRule (eligibility_profile_id) - can override type
... (other rules)
```

**Resolution Logic**:
1. Check if rule has `eligibility_profile_id` → Use this (OVERRIDE) ✅
2. Else check if LeaveType has `default_eligibility_profile_id` → Use this
3. Else check if LeaveClass has `default_eligibility_profile_id` → Use this
4. Else no restriction (ALL ELIGIBLE) ✅

**Ví dụ - Simple Case (All Rules Use Default)**:
```yaml
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

LeaveType: ANNUAL_LEAVE
  leave_class_id: PTO
  default_eligibility_profile_id: null  # Inherit from class

AccrualRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Inherit from type → class
  accrual_amount: 1.67

CarryoverRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Inherit from type → class
  max_carryover: 5

→ Result: All rules use ELIG_ALL_FULLTIME (full-time employees only)
```

**Ví dụ - Complex Case (Different Rules, Different Eligibility)**:
```yaml
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_ALL_FULLTIME"

LeaveType: ANNUAL_LEAVE
  leave_class_id: PTO
  default_eligibility_profile_id: null

# Junior staff: 12 days/year
AccrualRule: JUNIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: "ELIG_JUNIOR"  # OVERRIDE
  accrual_amount: 1.0

# Senior staff: 15 days/year
AccrualRule: SENIOR_ACCRUAL
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: "ELIG_SENIOR"  # OVERRIDE
  accrual_amount: 1.25

# Everyone can carry over
CarryoverRule: STANDARD
  leave_type_id: ANNUAL_LEAVE
  eligibility_profile_id: null  # Use default (all full-time)
  max_carryover: 5

→ Result:
  - Employee G2: Gets JUNIOR_ACCRUAL (12 days), can carry over 5
  - Employee G5: Gets SENIOR_ACCRUAL (15 days), can carry over 5
  - Part-time: No accrual (not in ELIG_ALL_FULLTIME)
```

---

### EligibilityProfile (Core Module)

**Định nghĩa**: Dynamic eligibility rules định nghĩa **WHO** is eligible dựa trên organizational attributes.

**Key Attributes**:
- `code`: Unique identifier (e.g., `ELIG_SENIOR_STAFF`)
- `domain`: `ABSENCE`, `BENEFITS`, `COMPENSATION`, or `CORE`
- `rule_json`: Dynamic criteria (organizational scope)

**Rule JSON Structure**:
```json
{
  "business_units": ["BU_SALES", "BU_TECH"],
  "legal_entities": ["LE_VN", "LE_SG"],
  "countries": ["VN", "SG"],
  "grades": ["G4", "G5", "M3", "M4", "M5"],
  "employment_types": ["FULL_TIME"],
  "min_tenure_months": 6,
  "departments": ["SALES", "MARKETING"]
}
```

**Ví dụ**:
```yaml
# Eligibility Profile (Core Module)
EligibilityProfile: ELIG_VN_SENIOR
  code: "ELIG_VN_SENIOR"
  domain: "CORE"  # Can be used by any module
  rule_json:
    countries: ["VN"]
    grades: ["G4", "G5", "M3", "M4", "M5"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 12

# Used in TA Module
LeaveClass: PTO
  default_eligibility_profile_id: "ELIG_VN_SENIOR"

AccrualRule: SENIOR_ACCRUAL
  leave_type_id: "ANNUAL_LEAVE"
  eligibility_profile_id: "ELIG_VN_SENIOR"
  accrual_amount: 1.67
```

**Benefits**:
- ✅ **Reusability**: Define once, use across TA, TR, and other modules
- ✅ **Performance**: O(1) lookups via cached membership (`EligibilityMember`)
- ✅ **Consistency**: Unified eligibility logic across system
- ✅ **Flexibility**: Hybrid model supports simple and complex scenarios

---

### When to Use Default vs Override

**Use Default** (at Class/Type level):
- ✅ Most rules share same eligibility
- ✅ Simple, consistent eligibility
- ✅ Easier maintenance

**Use Override** (at Rule level):
- ✅ Different rules need different eligibility
- ✅ Tiered benefits/policies (junior vs senior)
- ✅ Special cases or exceptions

---

### Migration from Old Eligibility Model

**Before** (Old Model - Embedded Eligibility):
```yaml
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"
  minTenureMonths: 6
  employmentTypes: ["FULL_TIME"]
  applicableCountries: ["VN"]
  accrualAmount: 1.67
```

**After** (New Model - Centralized Eligibility):
```yaml
# Step 1: Create EligibilityProfile (Core Module)
EligibilityProfile:
  code: "ELIG_VN_FULLTIME"
  domain: "CORE"
  rule_json:
    countries: ["VN"]
    employment_types: ["FULL_TIME"]
    min_tenure_months: 6

# Step 2: Reference in AccrualRule (TA Module)
AccrualRule:
  leaveTypeId: "ANNUAL_LEAVE"
  eligibility_profile_id: "ELIG_VN_FULLTIME"  # Reference
  accrualAmount: 1.67
```

**Key Changes**:
- ❌ Removed: `minTenureMonths`, `employmentTypes`, `applicableCountries` from rules
- ✅ Added: `default_eligibility_profile_id` to LeaveClass and LeaveType
- ✅ Added: `eligibility_profile_id` to all absence rules

---

### Eligibility Rule
**Định nghĩa**: Quy tắc xác định nhân viên nào đủ điều kiện sử dụng leave type.

**Các loại**:
- **TENURE**: Dựa trên thâm niên (ví dụ: phải làm việc >= 6 tháng)
- **EMPLOYMENT_TYPE**: Dựa trên loại hợp đồng (Full-time, Part-time)
- **LOCATION**: Dựa trên địa điểm làm việc
- **DEPARTMENT**: Dựa trên phòng ban
- **JOB_LEVEL**: Dựa trên cấp bậc công việc

**Ví dụ**:
- "Annual Leave chỉ dành cho nhân viên Full-time đã làm việc >= 6 tháng"
- "Sick Leave dành cho tất cả nhân viên"

---

### Validation Rule
**Định nghĩa**: Quy tắc kiểm tra tính hợp lệ của leave request.

**Các loại**:
- **ADVANCE_NOTICE**: Phải đăng ký trước X ngày
- **MAX_CONSECUTIVE_DAYS**: Không được nghỉ quá X ngày liên tục
- **MIN_CONSECUTIVE_DAYS**: Phải nghỉ ít nhất X ngày
- **BLACKOUT_PERIOD**: Không được nghỉ trong khoảng thời gian cấm
- **MAX_REQUESTS_PER_PERIOD**: Tối đa X đơn trong một kỳ
- **DOCUMENTATION_REQUIRED**: Yêu cầu giấy tờ chứng minh

**Ví dụ**:
- "Annual Leave: Phải đăng ký trước ít nhất 7 ngày"
- "Sick Leave > 3 ngày: Phải có giấy bác sĩ"
- "Blackout period: Không được nghỉ từ 20-31/12 (đóng sổ cuối năm)"

---

### Accrual Rule
**Định nghĩa**: Quy tắc xác định cách nhân viên tích lũy (earn) leave balance.

**Phương thức tích lũy**:
- **UPFRONT**: Cấp toàn bộ số ngày vào đầu kỳ
- **MONTHLY**: Tích lũy theo tháng
- **BIWEEKLY**: Tích lũy mỗi 2 tuần
- **DAILY**: Tích lũy theo ngày
- **HOURLY**: Tích lũy theo giờ

**Ví dụ**:
- "Upfront: 20 ngày được cấp vào ngày 1/1 hàng năm"
- "Monthly: 1.67 ngày/tháng (20 ngày / 12 tháng)"
- "Tenure-based: 0-5 năm = 15 ngày, 5+ năm = 20 ngày"

---

### Carryover Rule
**Định nghĩa**: Quy tắc xử lý số ngày phép chưa sử dụng khi hết kỳ.

**Các loại**:
- **NONE**: Không cho phép chuyển
- **UNLIMITED**: Chuyển toàn bộ
- **LIMITED**: Chuyển tối đa X ngày
- **EXPIRE_ALL**: Tất cả hết hạn
- **PAYOUT**: Chi trả thành tiền

**Ví dụ**:
- "Unlimited: Tất cả ngày chưa dùng chuyển sang năm sau"
- "Limited: Tối đa 5 ngày, phần còn lại hết hạn"
- "Payout: Chi trả 100% lương ngày cho ngày chưa dùng"

---

### Limit Rule
**Định nghĩa**: Quy tắc giới hạn số lượng phép có thể sử dụng.

**Các loại**:
- **MAX_PER_YEAR**: Tối đa X ngày/năm
- **MAX_PER_REQUEST**: Tối đa X ngày/đơn
- **MAX_PER_MONTH**: Tối đa X ngày/tháng
- **MIN_PER_REQUEST**: Tối thiểu X ngày/đơn

**Ví dụ**:
- "Max per year: Không quá 20 ngày/năm"
- "Max per request: Không quá 10 ngày liên tục"
- "Min per request: Ít nhất 0.5 ngày (nửa ngày)"

---

### Overdraft Rule
**Định nghĩa**: Quy tắc cho phép nhân viên nghỉ phép khi số dư = 0 (âm số dư).

**Thuộc tính**:
- **allowOverdraft**: Có cho phép không
- **maxOverdraftAmount**: Tối đa bao nhiêu ngày âm
- **repaymentRequired**: Có yêu cầu hoàn trả không
- **requiresApproval**: Cần phê duyệt đặc biệt không

**Ví dụ**:
- "Cho phép âm tối đa 5 ngày, tự động trừ từ accrual tháng sau"
- "Không cho phép overdraft, phải có số dư đủ mới được nghỉ"

---

### Proration Rule
**Định nghĩa**: Quy tắc tính tỷ lệ phép cho nhân viên vào giữa kỳ hoặc part-time.

**Các loại**:
- **START_DATE**: Tính tỷ lệ theo ngày bắt đầu làm việc
- **END_DATE**: Tính tỷ lệ theo ngày kết thúc
- **SCHEDULE**: Tính tỷ lệ theo lịch làm việc (part-time)

**Ví dụ**:
- "Nhân viên vào ngày 1/7: Được 10 ngày (50% của 20 ngày)"
- "Part-time 50%: Được 10 ngày (50% của 20 ngày)"

---

### Rounding Rule
**Định nghĩa**: Quy tắc làm tròn số phép khi có số lẻ.

**Phương thức**:
- **UP**: Làm tròn lên
- **DOWN**: Làm tròn xuống
- **NEAREST**: Làm tròn gần nhất
- **NEAREST_HALF**: Làm tròn đến 0.5 gần nhất
- **NEAREST_QUARTER**: Làm tròn đến 0.25 gần nhất

**Ví dụ**:
- "Round up: 1.67 → 2.0"
- "Round to nearest half: 1.67 → 1.5"
- "Round down: 1.67 → 1.0"

---

## Period & Schedule Entities

### Period Profile
**Định nghĩa**: Cấu trúc kỳ phép (leave year).

**Các loại**:
- **CALENDAR_YEAR**: Năm dương lịch (1/1 - 31/12)
- **FISCAL_YEAR**: Năm tài chính (ví dụ: 1/4 - 31/3)
- **HIRE_ANNIVERSARY**: Theo ngày vào làm của nhân viên
- **CUSTOM**: Tùy chỉnh

**Ví dụ**:
- "Calendar year: 1/1/2025 - 31/12/2025"
- "Fiscal year: 1/4/2025 - 31/3/2026"
- "Hire anniversary: Nếu vào ngày 15/6, kỳ phép là 15/6 - 14/6 năm sau"

---

### Schedule
**Định nghĩa**: Lịch làm việc, xác định ngày nào là ngày làm việc.

**Mục đích**: Tính toán số ngày làm việc trong leave request (loại trừ cuối tuần và ngày lễ).

**Ví dụ**:
- "Standard 5-day: Thứ 2-6, 8 giờ/ngày"
- "4-day week: Thứ 2-5, 10 giờ/ngày"
- "6-day week: Thứ 2-7, 8 giờ/ngày"

---

### Holiday
**Định nghĩa**: Ngày lễ/ngày nghỉ công ty, không tính vào leave request.

**Thuộc tính**:
- **isRecurring**: Có lặp lại hàng năm không
- **date**: Ngày cụ thể

**Ví dụ**:
- "Tết Nguyên Đán: 1/1, recurring"
- "Quốc Khánh: 2/9, recurring"
- "Company Anniversary: 15/3, non-recurring"

---

## Transaction Entities

### Leave Request
**Định nghĩa**: Đơn xin nghỉ phép của nhân viên.

**Lifecycle**:
```
DRAFT → PENDING → APPROVED/REJECTED/WITHDRAWN
APPROVED → CANCELLED (exceptional)
```

**Trạng thái**:
- **DRAFT**: Đang soạn thảo, chưa submit
- **PENDING**: Đã submit, chờ phê duyệt
- **APPROVED**: Đã được phê duyệt
- **REJECTED**: Bị từ chối
- **CANCELLED**: Đã hủy
- **WITHDRAWN**: Nhân viên rút lại

**Thuộc tính quan trọng**:
- **totalDays**: Tổng số ngày làm việc (tự động tính, loại trừ cuối tuần và ngày lễ)
- **isHalfDay**: Có phải nghỉ nửa ngày không
- **reason**: Lý do nghỉ phép

---

### Leave Reservation
**Định nghĩa**: Giữ chỗ tạm thời trên leave balance khi request đang pending.

**Mục đích**: Ngăn chặn double-booking - nhân viên không thể tạo 2 requests trùng ngày.

**Lifecycle**:
```
ACTIVE → RELEASED (khi approved/rejected)
ACTIVE → EXPIRED (nếu không xử lý trong thời gian quy định)
```

**Ví dụ**:
- Nhân viên có 10 ngày available
- Tạo request 5 ngày → Reservation 5 ngày
- Available còn 5 ngày (10 - 5 pending)
- Nếu approved: Reservation released, used +5
- Nếu rejected: Reservation released, available trở lại 10

---

### Leave Movement
**Định nghĩa**: Bút toán ghi sổ cho mọi thay đổi của leave balance. **Immutable ledger**.

**Các loại movement**:
- **ALLOCATION**: Cấp phép (ví dụ: cấp 20 ngày đầu năm)
- **ACCRUAL**: Tích lũy (ví dụ: +1.67 ngày mỗi tháng)
- **USAGE**: Sử dụng (ví dụ: -5 ngày khi request được approve)
- **ADJUSTMENT**: Điều chỉnh thủ công (ví dụ: HR sửa lỗi)
- **CARRYOVER**: Chuyển từ năm trước
- **EXPIRY**: Hết hạn
- **PAYOUT**: Chi trả thành tiền
- **REVERSAL**: Đảo ngược movement trước đó

**Nguyên tắc**:
- **Immutable**: Không được sửa hoặc xóa
- **Complete audit trail**: Mọi thay đổi đều có movement
- **balanceAfter = balanceBefore + amount**

**Ví dụ**:
```
Movement 1: ALLOCATION, +20 days, balance: 0 → 20
Movement 2: USAGE, -5 days, balance: 20 → 15
Movement 3: ACCRUAL, +1.67 days, balance: 15 → 16.67
Movement 4: ADJUSTMENT, +2 days, balance: 16.67 → 18.67
```

---

### Leave Balance
**Định nghĩa**: Số dư phép hiện tại của nhân viên cho một leave type trong một kỳ.

**Các thành phần**:
- **totalAllocated**: Tổng số được cấp trong kỳ
- **accrued**: Số đã tích lũy (nếu dùng accrual)
- **used**: Số đã sử dụng (requests đã approved)
- **pending**: Số đang chờ duyệt (requests pending)
- **reserved**: Số đang được giữ chỗ (reservations)
- **carriedOver**: Số chuyển từ kỳ trước
- **adjusted**: Điều chỉnh thủ công
- **expired**: Số đã hết hạn
- **available**: Số có thể sử dụng ngay

**Công thức**:
```
available = totalAllocated + carriedOver + adjusted - used - pending - expired
```

**Ví dụ**:
```
Total Allocated: 20 days
Carried Over: 5 days
Used: 8 days
Pending: 3 days
Expired: 0 days
Adjusted: 0 days

Available = 20 + 5 + 0 - 8 - 3 - 0 = 14 days
```

---

### Approval
**Định nghĩa**: Bản ghi phê duyệt cho leave request. Hỗ trợ multi-level approval.

**Approval Levels**:
- **Level 1**: Direct Manager
- **Level 2**: Department Head (cho requests > 5 ngày)
- **Level 3**: HR (cho special leave types)

**Quy tắc**:
- Phải approve theo thứ tự (level 1 trước level 2)
- Nếu bất kỳ level nào reject → toàn bộ request bị reject
- Không thể approve request của chính mình

---

## Event & Trigger Entities

### Event
**Định nghĩa**: Sự kiện hệ thống được trigger bởi các hành động liên quan đến leave.

**Các loại event**:
- **LEAVE_REQUEST_SUBMITTED**: Đơn được submit
- **LEAVE_REQUEST_APPROVED**: Đơn được duyệt
- **LEAVE_REQUEST_REJECTED**: Đơn bị từ chối
- **LEAVE_REQUEST_CANCELLED**: Đơn bị hủy
- **BALANCE_ALLOCATED**: Balance được cấp
- **BALANCE_ACCRUED**: Balance được tích lũy
- **BALANCE_EXPIRED**: Balance hết hạn
- **APPROVAL_REQUIRED**: Cần phê duyệt
- **REMINDER_SENT**: Nhắc nhở được gửi

**Mục đích**: 
- Gửi notifications
- Trigger integrations
- Audit logging

---

### Trigger
**Định nghĩa**: Tự động hóa các actions dựa trên events hoặc schedules.

**Các loại trigger**:
- **EVENT_BASED**: Kích hoạt khi có event (ví dụ: request submitted → send email)
- **SCHEDULE_BASED**: Kích hoạt theo lịch (ví dụ: mỗi tháng ngày 1 → accrue leave)
- **CONDITION_BASED**: Kích hoạt khi điều kiện thỏa mãn (ví dụ: balance < 5 → send alert)

**Ví dụ**:
- "Khi LEAVE_REQUEST_SUBMITTED → Gửi email cho manager"
- "Mỗi tháng ngày 1 → Tích lũy monthly leave"
- "Mỗi năm ngày 31/12 → Expire unused balances"
- "Khi available balance < 5 → Gửi low balance warning"

---

## Key Concepts

### Working Days vs Calendar Days
- **Calendar Days**: Tất cả các ngày (bao gồm cuối tuần, ngày lễ)
- **Working Days**: Chỉ các ngày làm việc (loại trừ cuối tuần và ngày lễ)

**Leave requests luôn tính theo Working Days.**

**Ví dụ**:
```
Request: Friday (Feb 7) to Monday (Feb 10)
Calendar Days: 4 days
Working Days: 2 days (Friday and Monday, excluding Sat-Sun)
```

---

### Half Day Leave
**Định nghĩa**: Nghỉ nửa ngày (sáng hoặc chiều).

**Quy tắc**:
- Chỉ áp dụng cho leave types có `allowsHalfDay = true`
- `startDate` phải bằng `endDate`
- Phải chọn `halfDayPeriod` (MORNING hoặc AFTERNOON)
- Tính là 0.5 days

---

### Hourly Leave
**Định nghĩa**: Nghỉ theo giờ thay vì theo ngày.

**Áp dụng cho**: Sick leave ngắn, personal appointments

**Ví dụ**:
- Nghỉ 2 giờ đi khám bác sĩ
- Nghỉ 4 giờ để đón con

---

### Overdraft (Negative Balance)
**Định nghĩa**: Cho phép nhân viên nghỉ phép khi balance = 0 (âm số dư).

**Use case**: 
- Nhân viên mới chưa tích lũy đủ nhưng cần nghỉ gấp
- Nhân viên đã dùng hết phép năm nhưng có việc khẩn cấp

**Quy tắc**:
- Phải được policy cho phép
- Có giới hạn số âm tối đa
- Thường yêu cầu approval đặc biệt
- Phải hoàn trả từ accrual tương lai

---

### Blackout Period
**Định nghĩa**: Khoảng thời gian cấm nghỉ phép.

**Use case**:
- Cuối năm tài chính (đóng sổ)
- Peak season (bận rộn nhất)
- Critical project deadlines

**Ví dụ**:
- "Không được nghỉ từ 20-31/12 (year-end close)"
- "Không được nghỉ trong tháng 6 (audit period)"

---

## Abbreviations

| Abbreviation | Full Term | Meaning |
|--------------|-----------|---------|
| **PTO** | Paid Time Off | Phép có lương |
| **AL** | Annual Leave | Phép năm |
| **SL** | Sick Leave | Phép ốm |
| **ML** | Maternity Leave | Phép thai sản |
| **PL** | Paternity Leave | Phép chăm con |
| **UL** | Unpaid Leave | Phép không lương |
| **YTD** | Year-to-Date | Từ đầu năm đến nay |
| **MTD** | Month-to-Date | Từ đầu tháng đến nay |

---

## Related Documents

- [Absence Ontology Index](./absence-ontology-index.yaml) - Complete entity definitions and relationships
- [Time & Absence Core Ontology](../../../00-global/ontology/time-absence-core.yaml) - Shared entities
- [Global Glossary](../../../00-global/glossary/domain-glossary.md) - System-wide terms

---

**Version**: 2.1  
**Last Updated**: 2025-12-11  
**Maintained By**: xTalent Documentation Team

