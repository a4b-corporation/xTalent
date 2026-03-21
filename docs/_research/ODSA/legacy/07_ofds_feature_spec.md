# OFDS Feature Specification — 9 Thành Phần Chi Tiết

> **Mục tiêu:** Hướng dẫn chi tiết từng trong 9 thành phần bắt buộc của một Feature Specification Document (`*.fsd.md`), bao gồm lý do tồn tại, cách viết đúng, ví dụ minh họa thực tế (từ TA module), và mức độ bắt buộc.

---

## Tổng quan 9 thành phần

| # | Thành phần | Mức bắt buộc | Audience chính | Ontology link |
|---|-----------|-------------|---------------|--------------|
| 1 | Business Context & Job Stories | **Required** | BA, PO | `design/purpose.md` |
| 2 | UI Workflow & Mockup | **Required** | Dev, Designer | Feature-specific |
| 3 | System Events | **Required** | Dev, Architect | `system/events.yaml` |
| 4 | Business Rules | **Required** | Dev, QA | `ontology/rules.yaml` |
| 5 | NFRs & Constraints | **Required** | Dev, Architect | Feature-specific |
| 6 | Dependency Map | **Required** | BA, Dev Lead | Cross-feature |
| 7 | Edge & Corner Cases | **Required** | QA, Dev | Feature-specific |
| 8 | Acceptance Criteria (Gherkin) | **Required** | QA, Dev | Feature-specific |
| 9 | Release Planning | Recommended | PM, Dev Lead | Feature-specific |

---

## Thành phần 1: Business Context & Job Stories

### Mục đích

Neo feature vào bài toán kinh doanh thực tế. Ngăn chặn việc build feature không ai cần hoặc build sai vấn đề. Cung cấp context để developer hiểu **tại sao** feature tồn tại — không chỉ **làm gì**.

### Cấu trúc

**Problem Statement** — Ngắn gọn, súc tích. Trả lời: Người dùng đang gặp vấn đề gì? Tại sao cần tính năng này?

**Job Story** — Dùng định dạng "Jobs-to-be-Done" thay vì User Story truyền thống, vì nó chú trọng ngữ cảnh và động lực thay vì chỉ khai báo vai trò:

```text
❌ User Story (thiếu context):
"Là nhân viên, tôi muốn tạo đơn xin nghỉ để nghỉ phép."

✅ Job Story (có context + motivation):
"Khi tôi cần lên kế hoạch nghỉ phép sắp tới và muốn chắc chắn 
 số dư của mình đủ, tôi muốn tạo đơn nghỉ và thấy ngay số dư 
 hiện tại, để tôi không bị từ chối vì thiếu ngày."
```

**Success Metrics** — Chỉ định rõ chỉ số nào sẽ được đo sau khi ra mắt, dùng HEART hoặc AARRR framework:

| Framework | Khi nào dùng |
|----------|-------------|
| **HEART** | Feature tập trung vào UX, tương tác người dùng |
| **AARRR** | Feature liên quan tăng trưởng, conversion, revenue |

### Ví dụ thực tế: ABS-LR-001

```markdown
## 1. Business Context

### Problem Statement
Nhân viên hiện tại phải email hoặc nhắn Slack để xin nghỉ, gây mất thời gian
cho cả nhân viên lẫn quản lý, không có audit trail, và dễ xảy ra lỗi tính toán
số dư. Feature này số hóa quy trình xin nghỉ với validation tự động.

### Job Story
> Khi tôi cần nghỉ phép và muốn kiểm tra số dư trước khi gửi đơn,
> tôi muốn tạo đơn nghỉ trực tiếp trên hệ thống với đầy đủ thông tin,
> để tôi không cần gửi email qua lại và biết ngay đơn có hợp lệ không.

### Success Metrics
| Metric | Framework | Target |
|--------|----------|--------|
| Task Success Rate (tạo đơn thành công / tổng lần thử) | HEART | ≥ 95% |
| Error Rate (validation fail / tổng đơn) | HEART | ≤ 5% |
| Time to Submit (thời gian trung bình từ mở đến submit) | HEART | ≤ 3 phút |
```

---

## Thành phần 2: UI Workflow & Mockup

### Mục đích

Mô tả chính xác cách người dùng tương tác với hệ thống qua giao diện. Cung cấp mockup machine-readable để designer và dev có cùng reference point.

### Cấu trúc

**Screen Flow** — Sơ đồ text đơn giản mô tả các màn hình và chuyển tiếp:

```text
[Entry Point] → [Màn hình chính] → [Xác nhận] → [Kết quả thành công]
                      ↓                  ↓
               [Validation Error]  [Server Error]
```

**Mockup — A2UI JSON DSL** — Dùng AI Mockup Builder format với 30 components. Đây là format chuẩn, machine-readable, có thể render thành UI trực tiếp:

> Xem DSL reference đầy đủ tại skill `mockup-creator`.
> Key constraint: 1 feature spec nên có mockup cho **happy path screen** chính. Các error/empty states mô tả bằng text.

**Micro UI States** — 3 trạng thái bắt buộc phải specify:

| State | Mô tả | Phải define |
|-------|-------|------------|
| **Empty State** | Khi chưa có dữ liệu | Primary message + CTA |
| **Error State** | Khi có lỗi server hoặc validation | Error message + recovery path |
| **Loading State** | Khi đang chờ API | Spinner/skeleton + button disable |

### Ví dụ thực tế: ABS-LR-001

```markdown
## 2. UI Workflow & Mockup

### Screen Flow
```text
[Leave Request List] → [+ New Request Form] → [Review & Submit] → [Confirmation]
        ↑                      ↓                      ↓
  (back navigation)    [Validation Error]       [Server Error]
                    (inline, không navigate)  (toast notification)
```

### Mockup — Create Leave Request Form

```json
{
  "type": "page",
  "theme": "light",
  "children": [
    {
      "type": "navbar",
      "brand": "xTalent",
      "title": "Absence Management"
    },
    {
      "type": "section",
      "padding": "lg",
      "children": [
        {
          "type": "breadcrumb",
          "items": [
            {"label": "Home", "href": "/"},
            {"label": "My Absences", "href": "/absences"},
            {"label": "New Request", "href": "#"}
          ]
        },
        {
          "type": "heading",
          "level": 1,
          "text": "Create Leave Request"
        },
        {
          "type": "row",
          "gap": "xl",
          "children": [
            {
              "type": "column",
              "gap": "lg",
              "children": [
                {
                  "type": "card",
                  "title": "Request Details",
                  "padding": "lg",
                  "children": [
                    {
                      "type": "form",
                      "children": [
                        {
                          "type": "select",
                          "label": "Leave Type",
                          "options": ["Annual Leave", "Sick Leave", "Maternity Leave", "Bereavement"],
                          "placeholder": "Select leave type"
                        },
                        {
                          "type": "row",
                          "gap": "md",
                          "children": [
                            {
                              "type": "input",
                              "label": "Start Date",
                              "inputType": "date"
                            },
                            {
                              "type": "input",
                              "label": "End Date",
                              "inputType": "date"
                            }
                          ]
                        },
                        {
                          "type": "select",
                          "label": "Duration Type",
                          "options": ["Full Day", "Half Day (AM)", "Half Day (PM)", "Hourly"],
                          "placeholder": "Select duration"
                        },
                        {
                          "type": "textarea",
                          "label": "Reason (Optional)",
                          "placeholder": "Add reason or notes...",
                          "rows": 3
                        },
                        {
                          "type": "button-group",
                          "children": [
                            {
                              "type": "button",
                              "text": "Submit for Approval",
                              "variant": "primary"
                            },
                            {
                              "type": "button",
                              "text": "Save as Draft",
                              "variant": "outline"
                            },
                            {
                              "type": "button",
                              "text": "Cancel",
                              "variant": "ghost"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "type": "column",
              "gap": "md",
              "children": [
                {
                  "type": "card",
                  "title": "Balance Summary",
                  "padding": "md",
                  "children": [
                    {
                      "type": "stat-list",
                      "stats": [
                        {"label": "Annual Leave Available", "value": "12 days"},
                        {"label": "Sick Leave Available", "value": "5 days"},
                        {"label": "Requested (This Request)", "value": "3 days"},
                        {"label": "Remaining After Submit", "value": "9 days"}
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

### Micro UI States

**Empty State** (khi balance = 0):
- Message: "Bạn đã sử dụng hết số ngày nghỉ phép năm nay"
- Description: "Liên hệ HR để được hỗ trợ điều chỉnh số dư"
- CTA: Button "Liên hệ HR" → /hr/contact

**Error State** (validate thất bại):
- Balance không đủ: Inline warning màu đỏ ngay dưới field "Duration" — "Số dư không đủ. Available: {N} ngày, Requested: {M} ngày"
- Ngày trùng: Inline warning — "Bạn đã có đơn nghỉ vào ngày {date}. Vui lòng chọn ngày khác"

**Loading State** (sau khi nhấn Submit):
- Button "Submit for Approval" chuyển sang disabled + spinner icon
- Ngăn double-submit: disabled tất cả form fields
- Timeout sau 30s: hiển thị toast "Đã xảy ra lỗi kết nối. Vui lòng thử lại."
```

---

## Thành phần 3: System Events

### Mục đích

Xác định rõ chuỗi sự kiện (Domain Events) và lệnh (Commands) do feature này phát sinh. Giúp developer biết chính xác cần emit event nào, payload là gì, và các service nào sẽ lắng nghe.

### Nguyên tắc Event Storming trong Feature Spec

```text
Màu coding (memetaphor từ Event Storming):
  🟠 Domain Event   — Đã xảy ra (past tense), bất biến
  🔵 Command        — Kích hoạt Event
  🟡 Actor          — Ai phát ra Command
  🟣 Policy         — Phản ứng sau Event
  🟢 External System — Hệ thống ngoài
```

### Template

```markdown
## 3. System Events

| Event | Trigger Command | Actor | Payload Fields |
|-------|----------------|-------|----------------|
| `LeaveRequestCreated` | `CreateLeaveRequest` | Employee | request_id, employee_id, leave_type, start_date, end_date, duration_days |
| `LeaveBalanceReserved` | (triggered by policy) | System | employee_id, leave_type, reserved_days, request_id |

**Event Flow:**
```text
[Employee] 
  → Command: CreateLeaveRequest
    → Validate: balance check, overlap check (ontology/rules.yaml)
    → Event: LeaveRequestCreated
      → Policy: "Khi LeaveRequestCreated" → Command: ReserveLeaveBalance
        → Event: LeaveBalanceReserved
      → Policy: "Khi LeaveRequestCreated" → Command: NotifyManager
        → Event: ManagerNotified
```

*Reference Events: [`../system/events.yaml`](../system/events.yaml)*
```

---

## Thành phần 4: Business Rules

### Mục đích

Liên kết feature với business rules trong ontology, và bổ sung các rules đặc thù của feature nếu chưa có trong ontology.

### Nguyên tắc quan trọng

> **KHÔNG** viết lại rules đã tồn tại trong `ontology/rules.yaml`. Chỉ **reference** chúng. Chỉ viết mới khi rule đặc thù cho feature này và chưa có trong ontology.

### 4 loại Business Rules

| Loại | Định nghĩa | Ví dụ |
|------|-----------|-------|
| **Process Rules** | Định nghĩa trình tự bắt buộc | Phải chọn leave type trước khi chọn ngày |
| **Constraint Rules** | Giới hạn, điều kiện, ràng buộc | Số ngày requested ≤ available balance |
| **Data Rules** | Validation định dạng, data integrity | Start date không được sau End date |
| **Computation Rules** | Công thức tính toán | working_days = calendar_days - weekends - holidays |

### Decision Tables — Format chuẩn

Dùng cho các logic phân nhánh phức tạp:

```markdown
### Decision Table: Số ngày tính từ khoảng ngày

| Duration Type | Start = End | Tính toán |
|--------------|-------------|-----------|
| Full Day | Yes | 1 ngày |
| Full Day | No | working_days(start, end) |
| Half Day AM | — | 0.5 ngày |
| Half Day PM | — | 0.5 ngày |
| Hourly | — | hours / 8 (rounded to 0.25) |
```

---

## Thành phần 5: NFRs & Constraints

### Mục đích

Định nghĩa rõ ràng các yêu cầu phi chức năng đặc thù của feature này, dùng chuẩn ISO/IEC 25010.

### Cấu trúc chuẩn

```markdown
## 5. NFRs & Constraints

### Performance (ISO 25010: Performance Efficiency)
- API `/leave-requests` POST: response time ≤ 500ms at P95, 100 concurrent users
- Balance calculation: ≤ 100ms  
- Calendar API (để check working days): ≤ 200ms

### Security (ISO 25010: Security)
- Employee chỉ xem được balance của chính mình (không xem người khác)
- HR Admin có thể xem balance của mọi người
- Audit log bắt buộc: ai tạo, khi nào, từ IP nào

### Usability (ISO 25010: Usability)
- Mobile-responsive (min 375px width)
- Keyboard navigation đầy đủ (Tab, Enter)
- Error message tiếng Việt, rõ nghĩa

### Constraints
| Loại | Constraint |
|------|-----------|
| Technical | UI dùng xTalent Design System components (không custom) |
| Business | Chỉ apply cho employees có active employment |
| Regulatory | Audit trail phải giữ tối thiểu 5 năm |
```

---

## Thành phần 6: Dependency Map

### Mục đích

Lập bản đồ phụ thuộc giữa các features để tránh bottleneck và lên kế hoạch sprint hợp lý.

### 4 mô hình quan hệ Agile

```text
FS (Finish-to-Start): B chỉ bắt đầu khi A hoàn tất — phổ biến nhất
SS (Start-to-Start): B bắt đầu sau khi A bắt đầu
FF (Finish-to-Finish): B kết thúc cùng lúc A kết thúc
SF (Start-to-Finish): B kết thúc sau khi A bắt đầu — hiếm gặp
```

### Template

```markdown
## 6. Dependency Map

### This Feature Requires

| Feature ID | Feature Name | Relationship | Reason |
|-----------|-------------|-------------|--------|
| [ABS-BAL-001](./ABS-BAL-001.fsd.md) | View Leave Balance | FS | Phải hiển thị balance trước khi user tạo đơn |

### Features Requiring This Feature

| Feature ID | Feature Name | Relationship |
|-----------|-------------|-------------|
| [ABS-LR-002](./ABS-LR-002.fsd.md) | Submit for Approval | FS |

### External Dependencies

| System | Dependency | Risk Level |
|--------|-----------|-----------|
| Holiday Calendar Service | Tính working days | MEDIUM — nếu service down, không tính được ngày |
```

---

## Thành phần 7: Edge & Corner Cases

### Mục đích

Xác định trước các tình huống ngoại lệ để dev implement defensive programming và QA tạo đủ test cases.

### Phân biệt Edge vs Corner Case

| | Edge Case | Corner Case |
|-|-----------|------------|
| Số biến cực đoan | 1 biến | ≥ 2 biến đồng thời |
| Tần suất | Thường xảy ra có chu kỳ | Hiếm, khó dự đoán |
| Xử lý UI | Cần thiết kế UI state rõ | Exception handler đủ |

### Template

```markdown
## 7. Edge & Corner Cases

### Edge Cases

| # | Case | Điều kiện | Hành vi mong đợi |
|---|------|-----------|-----------------|
| E1 | Balance = 0 | Nhân viên hết số ngày nghỉ | Block submit, show Empty State với message rõ |
| E2 | Balance = 0.5 (nửa ngày) | User chọn Full Day | Warning: "Chỉ còn 0.5 ngày — không đủ cho full day request" |
| E3 | Start date hôm nay | Leave type không cho phép xin gấp | Validate: "Loại nghỉ này yêu cầu báo trước {N} ngày làm việc" |
| E4 | Date range vượt giới hạn | User chọn range > 30 ngày | Error: "Tối đa 30 ngày per request" |

### Corner Cases

| # | Case | Điều kiện kết hợp | Handling Strategy |
|---|------|------------------|------------------|
| C1 | Session hết hạn giữa chừng | User điền form → session expire → nhấn Submit | Redirect login, preserve form data trong localStorage 1 giờ |
| C2 | Concurrent submit | User mở 2 tab, submit cùng lúc | Backend idempotency key; thứ hai return 409 Conflict |
| C3 | Holiday update khi đang điền form | Admin thêm holiday vào calendar | Recalculate working days khi user focus lại tab |

### Edge Case Checklist

- [ ] Input boundary: start_date > end_date handled
- [ ] Empty: balance = 0, balance < requested
- [ ] Special: leave type thay đổi sau khi đã chọn ngày (recalculate)
- [ ] Concurrent: double-submit prevention
- [ ] Session: form data preserved on session expiry
- [ ] Permission: employee không tạo được đơn cho người khác (URL manipulation)
```

---

## Thành phần 8: Acceptance Criteria (Gherkin)

### Mục đích

Định nghĩa chính xác "Definition of Done" dưới dạng testable scenarios — đủ để QA viết automated tests, và đủ để dev biết implementation nào là đúng.

### Nguyên tắc viết Gherkin tốt

**Declarative (Good):** Mô tả *kết quả*, không mô tả *cơ chế UI*:
```gherkin
✅ When người dùng cung cấp thông tin nghỉ hợp lệ và submit
```

**Imperative (Bad):** Mô tả từng bước click/type vào UI:
```gherkin
❌ When người dùng nhấn vào dropdown có id "leave-type-select" và chọn item thứ 2
```

Lý do: Imperative tests bị invalidate ngay khi UI thay đổi.

### Template

```markdown
## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-001 - Create Leave Request

  Background:
    Given nhân viên đã đăng nhập vào hệ thống
    And nhân viên có employment status là Active

  # Happy Path
  Scenario: Tạo đơn nghỉ hợp lệ với đủ số dư
    Given nhân viên có 10 ngày Annual Leave available
    When nhân viên tạo đơn Annual Leave từ 2026-04-01 đến 2026-04-03 (3 ngày làm việc)
    Then hệ thống tạo LeaveRequest với status DRAFT
    And balance hiển thị: Available = 7 ngày (10 - 3)
    And LeaveRequestCreated event được emit với đúng payload

  # Validation
  Scenario: Không thể tạo đơn khi số dư không đủ
    Given nhân viên có 2 ngày Annual Leave available
    When nhân viên tạo đơn Annual Leave 5 ngày
    Then hệ thống không tạo request
    And hiển thị thông báo lỗi "Số dư không đủ. Available: 2 ngày, Requested: 5 ngày"
    And không emit event nào

  # Edge Case: Half day khi balance = 0.5
  Scenario: Tạo đơn half day với balance vừa đủ
    Given nhân viên có 0.5 ngày Annual Leave available
    When nhân viên tạo đơn Half Day AM cho ngày 2026-04-01
    Then hệ thống tạo LeaveRequest thành công
    And balance sau khi tạo = 0.0

  # Overlap check
  Scenario: Không thể tạo đơn trùng với đơn đã approve
    Given nhân viên có đơn APPROVED cho ngày 2026-04-01
    When nhân viên tạo đơn mới bao gồm ngày 2026-04-01
    Then hệ thống từ chối với thông báo "Đã có đơn nghỉ vào ngày 2026-04-01"
```
```

---

## Thành phần 9: Release Planning

### Mục đích

Lên kế hoạch phát hành theo 3 giai đoạn (Alpha → Beta → GA) để kiểm soát rủi ro và manage kỳ vọng.

### 3 Giai đoạn chuẩn

| Phase | Tên | Scope | Feature Completeness |
|-------|-----|-------|---------------------|
| **Alpha** | Private Preview | Internal team + invited users | Happy path only, edge cases optional |
| **Beta** | Public Preview | Opt-in users | Full feature, NFRs phải đạt |
| **GA** | General Availability | Tất cả users | 100% AC passed, frozen API |

### Template

```markdown
## 9. Release Planning

### Phase 1: Alpha (Private Preview)
- **Target:** Internal QA team + 2-3 pilot HR users
- **Scope:**
  - [x] Happy path: Create + Submit leave request
  - [x] Balance validation
  - [ ] Edge cases (optional at this phase)
- **Criteria to exit:** Không có P0 bugs trên happy path

### Phase 2: Beta (Public Preview)
- **Target:** Tất cả nhân viên trong 1 phòng ban pilot
- **Scope:**
  - [x] All AC scenarios passed
  - [x] NFRs đạt (response time ≤ 500ms)
  - [x] Edge cases handled
- **Criteria to exit:** HEART Task Success Rate ≥ 95% trong 2 tuần

### Phase 3: GA (General Availability)
- **Target:** Toàn bộ tổ chức
- **Scope:** Feature-complete, backward-compatible API frozen
- **Criteria:** 100% Acceptance Criteria passed + 0 P0 bugs

### Out of Scope (v1)
- Hourly leave request (sẽ add ở v1.1)
- Attachment upload (separate feature ABS-LR-007)
```

---

## Quick Reference: Feature Spec Quality Checklist

Trước khi chuyển Feature Spec sang status `Reviewed`, kiểm tra:

```markdown
## Business Context
- [ ] Problem Statement rõ ràng (≤ 3 câu)
- [ ] Job Story đúng format, có đủ 3 phần (context, action, outcome)
- [ ] Success Metrics có thể đo lường được

## UI Workflow & Mockup
- [ ] Screen flow đủ nhánh (happy + error + edge)
- [ ] Mockup A2UI JSON hợp lệ (valid 30-component DSL)
- [ ] 3 Micro UI States đã define (Empty, Error, Loading)

## System Events
- [ ] Tất cả events có payload đầy đủ
- [ ] Policies (phản ứng sau event) đã định nghĩa
- [ ] Reference đến `system/events.yaml` đúng

## Business Rules
- [ ] Rules từ ontology đã reference (không viết lại)
- [ ] Feature-specific rules (nếu có) rõ ràng
- [ ] Decision Tables cover tất cả combinations

## NFRs & Constraints
- [ ] Performance có số cụ thể (ms, users, percentile)
- [ ] Security requirements đặc thù feature
- [ ] Constraints hợp lý và có thể thực thi

## Dependency Map
- [ ] Tất cả required features đã list với relationship type
- [ ] External dependencies và risk level

## Edge & Corner Cases
- [ ] Edge Case Checklist đã check
- [ ] Corner Cases quan trọng nhất đã identified

## Acceptance Criteria
- [ ] Cover happy path
- [ ] Cover validation failures
- [ ] Cover ít nhất 2 edge cases
- [ ] Gherkin viết declarative (không imperative)

## Release Planning
- [ ] 3 phases defined
- [ ] Out of scope v1 explicit
```
