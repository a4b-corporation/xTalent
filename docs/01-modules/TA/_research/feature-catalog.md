# Feature Catalog: Time & Absence Module

## Document Information

| Field | Value |
|-------|-------|
| **Module** | Time & Absence (TA) |
| **Total Features** | 65 |
| **Categories** | 10 |
| **Last Updated** | 2026-01-30 |
| **Status** | Complete |

---

## Executive Summary

### Feature Distribution

| Category | Count | Priority Breakdown |
|----------|-------|-------------------|
| Time Tracking | 8 | P1: 6, P2: 2 |
| Absence Management | 12 | P0: 10, P2: 2 |
| Leave Balance & Accrual | 8 | P0: 7, P2: 1 |
| Leave Policy & Compliance | 6 | P0: 5, P1: 1 |
| Scheduling | 7 | P1: 6, P2: 1 |
| Calendar & Holiday | 4 | P1: 4 |
| Overtime & Compensatory | 4 | P1: 4 |
| Reporting & Analytics | 6 | P2: 6 |
| Self-Service & UX | 5 | P2: 5 |
| Integration | 5 | P1: 2, P2: 3 |
| **TOTAL** | **65** | P0: 22, P1: 24, P2: 19 |

### Differentiation Analysis

| Type | Count | % | Description |
|------|-------|---|-------------|
| **Parity** | 48 | 74% | Table stakes - match industry standard |
| **Innovation** | 11 | 17% | USP - competitive differentiator |
| **Compliance** | 6 | 9% | Mandatory - legal requirement |

### Gap Analysis Summary

| Gap Type | Count | Strategy |
|----------|-------|----------|
| Standard Fit | 51 | Configure only |
| Config Gap | 7 | Customize config |
| Extension Gap | 4 | Build extension |
| **Core Gap** | 3 | ARB approval needed |

---

## Category 1: Time Tracking (8 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| TT-01 | Clock In/Out | P1 | Parity | LOW | Standard |
| TT-02 | Mobile Time Clock | P1 | Parity | MEDIUM | Standard |
| TT-03 | Biometric Integration | P1 | Parity | HIGH | Standard |
| TT-04 | GPS/Geofencing | P1 | Innovation | MEDIUM | Config |
| TT-05 | Web Timesheet Entry | P1 | Parity | LOW | Standard |
| TT-06 | Project Time Tracking | P1 | Parity | MEDIUM | Standard |
| TT-07 | Offline Time Capture | P2 | Innovation | HIGH | Extension |
| TT-08 | Auto Clock-In Detection | P2 | Innovation | HIGH | Extension |

### Detailed Specifications

#### TT-01: Clock In/Out

```yaml
id: TT-01
name: Clock In/Out
category: Time Tracking
priority: P1
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**: 
Nhân viên có thể chấm công vào/ra thông qua hệ thống

**Functional Requirements**:
- [ ] Chấm công vào (Clock In)
- [ ] Chấm công ra (Clock Out)
- [ ] Chấm công nghỉ giữa ca (Break Start/End)
- [ ] Hiển thị thời gian chấm công gần nhất
- [ ] Validate không chấm công trùng

**Actors**:
- Employee (Primary)
- Manager (View)

**Related Entities**:
- TimeClock
- TimeEntry
- Employee

**Vendor Reference**:
| Vendor | Feature Name | Notes |
|--------|-------------|-------|
| Oracle | Time Clock | Web-based punch |
| SAP | Time Recording | Attendance recording |
| Workday | Web Time Clocks | Browser-based |
| Microsoft | Virtual time clock | Employee app |

---

#### TT-02: Mobile Time Clock

```yaml
id: TT-02
name: Mobile Time Clock
category: Time Tracking
priority: P1
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Chấm công qua ứng dụng di động với hỗ trợ GPS

**Functional Requirements**:
- [ ] Mobile app cho iOS/Android
- [ ] Clock in/out từ mobile
- [ ] Capture GPS location khi chấm công
- [ ] Offline mode với sync sau
- [ ] Push notification nhắc chấm công

**Actors**:
- Employee (Primary)
- Field Worker (Primary)

**Related Entities**:
- TimeClock
- TimeEntry
- Location

**Non-Functional Requirements**:
- Offline capability: 24 hours
- Location accuracy: ±50m
- Battery impact: < 5%

---

#### TT-03: Biometric Integration

```yaml
id: TT-03
name: Biometric Integration
category: Time Tracking
priority: P1
differentiation: Parity
complexity: HIGH
gap_type: Standard Fit
phase: 2
source: Industry Standard
decision_ref: null
```

**Description**:
Tích hợp với thiết bị chấm công sinh trắc học

**Functional Requirements**:
- [ ] Kết nối với fingerprint scanners
- [ ] Kết nối với face recognition devices
- [ ] Sync data từ devices
- [ ] Handle exceptions (failed scan, unknown employee)
- [ ] Support multiple device vendors

**Actors**:
- System Admin (Configure)
- HR Admin (Monitor)

**Related Entities**:
- TimeClock
- TimeEntry
- Device

**Integration Requirements**:
| Device Type | Protocol | Common Vendors |
|-------------|----------|----------------|
| Fingerprint | REST API, SDK | ZKTeco, Suprema, HID |
| Face Recognition | REST API | Hikvision, Dahua, ZKTeco |
| Card Reader | Wiegand | HID, Suprema |

---

#### TT-04: GPS/Geofencing

```yaml
id: TT-04
name: GPS/Geofencing
category: Time Tracking
priority: P1
differentiation: Innovation
complexity: MEDIUM
gap_type: Config Gap
phase: 2
source: Oracle/Workday
decision_ref: null
```

**Description**:
Xác thực vị trí chấm công bằng GPS và geofence

**Functional Requirements**:
- [ ] Define geofence zones (office, site, etc.)
- [ ] Validate punch location against geofence
- [ ] Alert/block punch outside geofence
- [ ] Track location history
- [ ] Configurable enforcement (strict/warn)

**Actors**:
- HR Admin (Configure zones)
- Employee (Punch)
- Manager (View alerts)

**Related Entities**:
- TimeClock
- Geofence
- WorkLocation

**Configuration Options**:
| Option | Values | Default |
|--------|--------|---------|
| Geofence radius | 50m - 5000m | 100m |
| Enforcement | STRICT, WARN, LOG | WARN |
| Accuracy requirement | 10m - 100m | 50m |

---

#### TT-05: Web Timesheet Entry

```yaml
id: TT-05
name: Web Timesheet Entry
category: Time Tracking
priority: P1
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Nhân viên nhập giờ làm việc qua giao diện web

**Functional Requirements**:
- [ ] Calendar-based time entry UI
- [ ] Daily/Weekly view toggle
- [ ] Copy from previous day/week
- [ ] Split time across cost centers
- [ ] Save draft & submit workflow

**Actors**:
- Employee (Primary)
- Manager (Approve)

**Related Entities**:
- TimeEntry
- TimeSheet
- CostCenter

---

#### TT-06: Project Time Tracking

```yaml
id: TT-06
name: Project Time Tracking
category: Time Tracking
priority: P1
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 2
source: Workday
decision_ref: null
```

**Description**:
Theo dõi thời gian theo dự án/task

**Functional Requirements**:
- [ ] Allocate time to projects
- [ ] Allocate time to tasks
- [ ] Project time validation rules
- [ ] Time vs budget tracking
- [ ] Multi-project per day

**Actors**:
- Employee (Primary)
- Project Manager (View)

**Related Entities**:
- TimeEntry
- Project
- Task
- CostCenter

---

#### TT-07: Offline Time Capture

```yaml
id: TT-07
name: Offline Time Capture
category: Time Tracking
priority: P2
differentiation: Innovation
complexity: HIGH
gap_type: Extension Gap
phase: 3
source: Oracle
decision_ref: null
```

**Description**:
Hỗ trợ chấm công khi không có kết nối internet

**Functional Requirements**:
- [ ] Store punches locally
- [ ] Queue sync when online
- [ ] Conflict resolution
- [ ] Offline duration limit
- [ ] Visual indicator offline mode

**Non-Functional Requirements**:
- Offline storage: 7 days
- Sync time: < 30 seconds
- Data integrity: 100%

---

#### TT-08: Auto Clock-In Detection

```yaml
id: TT-08
name: Auto Clock-In Detection
category: Time Tracking
priority: P2
differentiation: Innovation
complexity: HIGH
gap_type: Extension Gap
phase: 3
source: AI Trend 2025
decision_ref: null
```

**Description**:
Tự động phát hiện và gợi ý chấm công dựa trên AI

**Functional Requirements**:
- [ ] Detect arrival via WiFi/location
- [ ] Suggest clock-in notification
- [ ] Learn patterns per employee
- [ ] Manual override option
- [ ] Audit trail for auto punches

**AI/ML Requirements**:
- Pattern recognition accuracy: > 90%
- False positive rate: < 5%
- Learning period: 2 weeks

---

## Category 2: Absence Management (12 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| AM-01 | Leave Request Submission | P0 | Parity | LOW | Standard |
| AM-02 | Leave Approval Workflow | P0 | Parity | MEDIUM | Standard |
| AM-03 | Multi-Level Approval | P0 | Parity | MEDIUM | Standard |
| AM-04 | Delegate Approver | P0 | Parity | LOW | Standard |
| AM-05 | Bulk Leave Actions | P0 | Parity | MEDIUM | Standard |
| AM-06 | Concurrent Absences | P0 | Parity | MEDIUM | Config |
| AM-07 | Half-Day Leave | P0 | Parity | LOW | Standard |
| AM-08 | Hourly Leave | P0 | Parity | LOW | Standard |
| AM-09 | Leave Comments/Attachments | P0 | Parity | LOW | Standard |
| AM-10 | Cancel/Modify Request | P0 | Parity | LOW | Standard |
| AM-11 | AI Approval Recommendation | P2 | Innovation | HIGH | Extension |
| AM-12 | Vacation Bidding | P2 | Innovation | HIGH | Extension |

### Detailed Specifications

#### AM-01: Leave Request Submission

```yaml
id: AM-01
name: Leave Request Submission
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Nhân viên có thể tạo và gửi đơn xin nghỉ phép

**Functional Requirements**:
- [ ] Select leave type from catalog
- [ ] Choose date range (start/end)
- [ ] Select duration type (full/half/hours)
- [ ] View current balance before submit
- [ ] Validate against policy rules
- [ ] Submit for approval

**Actors**:
- Employee (Primary)
- HR Admin (On behalf)

**Related Entities**:
- LeaveRequest
- LeaveType
- LeaveBalance
- Employee

**Validation Rules**:
| Rule | Description | Severity |
|------|-------------|----------|
| Balance check | Available balance >= requested | Error |
| Advance notice | Min days before leave start | Warning |
| Max duration | Max consecutive days | Error |
| Blackout dates | Restricted periods | Error |

---

#### AM-02: Leave Approval Workflow

```yaml
id: AM-02
name: Leave Approval Workflow
category: Absence Management
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Quy trình phê duyệt đơn nghỉ phép

**Functional Requirements**:
- [ ] Route to direct manager
- [ ] Approve/Reject with comments
- [ ] Email/push notification to approver
- [ ] View team calendar before approve
- [ ] Auto-escalation after X days
- [ ] Audit trail of approvals

**Actors**:
- Manager (Approve/Reject)
- HR Admin (Override)
- System (Route/Escalate)

**Related Entities**:
- LeaveRequest
- ApprovalWorkflow
- Employee

**Workflow States**:
```
SUBMITTED → PENDING_APPROVAL → APPROVED/REJECTED
         ↘ ESCALATED ↗
```

---

#### AM-03: Multi-Level Approval

```yaml
id: AM-03
name: Multi-Level Approval
category: Absence Management
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Phê duyệt nhiều cấp cho các loại nghỉ dài hoặc đặc biệt

**Functional Requirements**:
- [ ] Configure approval chain per leave type
- [ ] Configure approval chain per duration threshold
- [ ] Sequential/Parallel approval modes
- [ ] Skip-level approval option
- [ ] View approval progress

**Actors**:
- Multiple Managers
- HR Director
- CEO (optional)

**Configuration**:
| Trigger | Level 1 | Level 2 | Level 3 |
|---------|---------|---------|---------|
| ≤ 3 days | Manager | - | - |
| 4-7 days | Manager | HR Manager | - |
| > 7 days | Manager | HR Manager | HR Director |
| Maternity | Manager | HR Director | CEO |

---

#### AM-04: Delegate Approver

```yaml
id: AM-04
name: Delegate Approver
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Ủy quyền phê duyệt khi manager vắng mặt

**Functional Requirements**:
- [ ] Set delegate for date range
- [ ] Auto-route to delegate
- [ ] Delegate receives notifications
- [ ] Original approver still visible
- [ ] Delegate can decline delegation

**Actors**:
- Manager (Delegate)
- Delegatee (Approve)
- HR Admin (Configure)

**Related Entities**:
- ApprovalDelegation
- Employee

---

#### AM-05: Bulk Leave Actions

```yaml
id: AM-05
name: Bulk Leave Actions
category: Absence Management
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Oracle
decision_ref: null
```

**Description**:
Xử lý hàng loạt đơn nghỉ phép

**Functional Requirements**:
- [ ] Bulk approve multiple requests
- [ ] Bulk reject with single comment
- [ ] Filter pending requests
- [ ] Select all/none toggle
- [ ] Undo within time window

**Actors**:
- Manager (Primary)
- HR Admin (Override)

**Use Cases**:
- Year-end approval backlog
- Holiday period requests
- Post-absence verification

---

#### AM-06: Concurrent Absences

```yaml
id: AM-06
name: Concurrent Absences
category: Absence Management
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Config Gap
phase: 1
source: Oracle
decision_ref: null
```

**Description**:
Hỗ trợ nhiều loại nghỉ cùng lúc

**Functional Requirements**:
- [ ] Allow overlapping leave types
- [ ] Configure allowed combinations
- [ ] Priority rules for payroll
- [ ] Balance deduction per type
- [ ] Clear visualization

**Examples**:
| Leave 1 | Leave 2 | Allowed |
|---------|---------|---------|
| Annual | Sick | No |
| Maternity | Bereavement | Yes |
| Training | Annual | No |

---

#### AM-07: Half-Day Leave

```yaml
id: AM-07
name: Half-Day Leave
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Cho phép nghỉ nửa ngày (sáng/chiều)

**Functional Requirements**:
- [ ] Select AM or PM
- [ ] Deduct 0.5 from balance
- [ ] Display in calendar
- [ ] Combine with attendance
- [ ] Configurable per leave type

**Actors**:
- Employee (Request)
- System (Calculate)

---

#### AM-08: Hourly Leave

```yaml
id: AM-08
name: Hourly Leave
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Workday
decision_ref: null
```

**Description**:
Cho phép nghỉ theo giờ

**Functional Requirements**:
- [ ] Select time range (from-to)
- [ ] Minimum duration (e.g., 1 hour)
- [ ] Balance in hours (converted)
- [ ] Configurable per leave type
- [ ] Integrate with time tracking

**Actors**:
- Employee (Request)

**Configuration**:
| Setting | Value |
|---------|-------|
| Minimum duration | 1 hour |
| Increment | 15 minutes |
| Max hourly requests/month | 8 |

---

#### AM-09: Leave Comments/Attachments

```yaml
id: AM-09
name: Leave Comments/Attachments
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Đính kèm ghi chú và tài liệu vào đơn nghỉ

**Functional Requirements**:
- [ ] Add reason/comments
- [ ] Upload attachments (PDF, image)
- [ ] View history of comments
- [ ] Approver can add comments
- [ ] Required documents per leave type

**Attachment Rules**:
| Leave Type | Required Document |
|------------|-------------------|
| Sick > 3 days | Medical certificate |
| Maternity | Birth certificate (later) |
| Bereavement | Death certificate |

---

#### AM-10: Cancel/Modify Request

```yaml
id: AM-10
name: Cancel/Modify Request
category: Absence Management
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Hủy hoặc sửa đổi đơn đã gửi

**Functional Requirements**:
- [ ] Cancel pending request
- [ ] Cancel approved request (with workflow)
- [ ] Modify dates before approval
- [ ] Restore balance after cancel
- [ ] Notification to approver

**Cancel Rules**:
| Status | Can Cancel | Approval Required |
|--------|------------|-------------------|
| DRAFT | Yes | No |
| SUBMITTED | Yes | No |
| PENDING | Yes | No |
| APPROVED (future) | Yes | Yes |
| APPROVED (past) | Yes | HR Only |

---

#### AM-11: AI Approval Recommendation

```yaml
id: AM-11
name: AI Approval Recommendation
category: Absence Management
priority: P2
differentiation: Innovation
complexity: HIGH
gap_type: Extension Gap
phase: 3
source: Oracle 25D Release
decision_ref: null
```

**Description**:
AI gợi ý quyết định phê duyệt dựa trên patterns

**Functional Requirements**:
- [ ] Analyze historical approval patterns
- [ ] Check policy compliance
- [ ] Assess team coverage impact
- [ ] Generate recommendation (Approve/Review/Reject)
- [ ] Explain reasoning
- [ ] Learn from overrides

**AI Factors Considered**:
| Factor | Weight |
|--------|--------|
| Employee eligibility | 25% |
| Team coverage | 25% |
| Historical patterns | 20% |
| Policy compliance | 20% |
| Manager preferences | 10% |

**Accuracy Target**: > 85%

---

#### AM-12: Vacation Bidding

```yaml
id: AM-12
name: Vacation Bidding
category: Absence Management
priority: P2
differentiation: Innovation
complexity: HIGH
gap_type: Extension Gap
phase: 3
source: Oracle
decision_ref: null
```

**Description**:
Quy trình đấu giá lịch nghỉ phép cho các dịp cao điểm

**Functional Requirements**:
- [ ] HR opens bidding period
- [ ] Employees submit preferred dates
- [ ] System ranks by seniority/points
- [ ] Allocation algorithm
- [ ] Notify results
- [ ] Appeal process

**Use Cases**:
- Lunar New Year (Tết)
- Summer vacation season
- Year-end holidays

---

## Category 3: Leave Balance & Accrual (8 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| LA-01 | Balance Inquiry | P0 | Parity | LOW | Standard |
| LA-02 | Automated Accrual | P0 | Parity | MEDIUM | Standard |
| LA-03 | Proration Calculation | P0 | Parity | MEDIUM | Standard |
| LA-04 | Carryover Rules | P0 | Parity | MEDIUM | Standard |
| LA-05 | Expiration Rules | P0 | Parity | MEDIUM | Standard |
| LA-06 | Negative Balance Control | P0 | Parity | MEDIUM | Config |
| LA-07 | Sell/Buy Leave | P2 | Innovation | HIGH | Extension |
| LA-08 | Compensatory Time | P0 | Parity | MEDIUM | Standard |

### Detailed Specifications

#### LA-01: Balance Inquiry

```yaml
id: LA-01
name: Balance Inquiry
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: LOW
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: ADR-002
```

**Description**:
Nhân viên xem số dư nghỉ phép theo từng loại

**Functional Requirements**:
- [ ] View all leave type balances
- [ ] Breakdown: Opening + Earned - Used - Pending = Available
- [ ] Historical balance view
- [ ] Balance as of future date
- [ ] Export/print balance statement

**Display Format**:
| Leave Type | Opening | Accrued | Used | Pending | Available |
|------------|---------|---------|------|---------|-----------|
| Annual | 3 | 12 | 5 | 2 | 8 |
| Sick | 0 | 30 | 2 | 0 | 28 |

---

#### LA-02: Automated Accrual

```yaml
id: LA-02
name: Automated Accrual
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: ADR-001
```

**Description**:
Tự động tính và cộng số ngày nghỉ phép theo kỳ

**Functional Requirements**:
- [ ] Configure accrual frequency (Monthly/Quarterly/Annual)
- [ ] Configure accrual timing (Start/End of period)
- [ ] Batch job to process accruals
- [ ] Individual recalculation
- [ ] Accrual history log

**Accrual Example** (Vietnam Annual):
| Employee | Tenure | Entitlement | Monthly Accrual |
|----------|--------|-------------|-----------------|
| Nguyễn A | 2 years | 12 days | 1 day |
| Trần B | 7 years | 13 days | 1.083 days |

---

#### LA-03: Proration Calculation

```yaml
id: LA-03
name: Proration Calculation
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: SAP
decision_ref: null
```

**Description**:
Tính toán pro-rata cho nhân viên mới hoặc nghỉ việc

**Functional Requirements**:
- [ ] Prorate on hire date
- [ ] Prorate on termination
- [ ] Prorate on status change
- [ ] Configurable proration method
- [ ] Handle mid-period changes

**Proration Methods**:
| Method | Formula | Use Case |
|--------|---------|----------|
| Calendar Days | Entitlement × (Days/365) | Standard |
| Working Days | Entitlement × (Work Days/260) | Accurate |
| Monthly | Entitlement × (Months/12) | Simple |

---

#### LA-04: Carryover Rules

```yaml
id: LA-04
name: Carryover Rules
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Quy tắc chuyển số dư sang năm mới

**Functional Requirements**:
- [ ] Configure max carryover days
- [ ] Configure carryover expiry
- [ ] Auto-process at year end
- [ ] Preview before processing
- [ ] Exception handling

**Configuration Options**:
| Option | Values |
|--------|--------|
| Allow carryover | Yes/No |
| Max carryover days | 0-365 |
| Expiry months | 0-12 (0 = never) |
| Carryover type | FIFO / LIFO |

---

#### LA-05: Expiration Rules

```yaml
id: LA-05
name: Expiration Rules
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Quy tắc hết hạn số ngày nghỉ không sử dụng

**Functional Requirements**:
- [ ] Configure expiry period
- [ ] Notification before expiry
- [ ] Auto-expire old balance
- [ ] Expiry history log
- [ ] Forfeiture report

**Expiry Scenarios**:
| Balance Type | Expiry Rule |
|--------------|-------------|
| Current year | Dec 31 |
| Carryover | March 31 next year |
| Comp time | 90 days from earn |

---

#### LA-06: Negative Balance Control

```yaml
id: LA-06
name: Negative Balance Control
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Config Gap
phase: 1
source: Industry Standard
decision_ref: null
```

**Description**:
Kiểm soát việc cho phép số dư âm

**Functional Requirements**:
- [ ] Configure allow/block negative
- [ ] Set maximum negative days
- [ ] Approval workflow for negative
- [ ] Payback rules
- [ ] Report on negative balances

**Configuration**:
| Leave Type | Allow Negative | Max Negative |
|------------|----------------|--------------|
| Annual | Yes | -5 days |
| Sick | No | 0 |
| Comp Time | No | 0 |

---

#### LA-07: Sell/Buy Leave

```yaml
id: LA-07
name: Sell/Buy Leave
category: Leave Balance & Accrual
priority: P2
differentiation: Innovation
complexity: HIGH
gap_type: Extension Gap
phase: 2
source: Microsoft
decision_ref: null
```

**Description**:
Cho phép nhân viên bán hoặc mua thêm ngày nghỉ

**Functional Requirements**:
- [ ] Sell unused leave back to company
- [ ] Buy additional leave days
- [ ] Configure eligibility per leave type
- [ ] Integrate with payroll
- [ ] Approval workflow
- [ ] Annual limits

**Configuration**:
| Option | Sell | Buy |
|--------|------|-----|
| Eligible leave types | Annual | Annual |
| Max days | 5 | 10 |
| Rate | 1 day salary | 1 day salary |
| Approval | Auto | Manager |

---

#### LA-08: Compensatory Time

```yaml
id: LA-08
name: Compensatory Time
category: Leave Balance & Accrual
priority: P0
differentiation: Parity
complexity: MEDIUM
gap_type: Standard Fit
phase: 1
source: Oracle
decision_ref: null
```

**Description**:
Tích lũy và sử dụng giờ nghỉ bù từ overtime

**Functional Requirements**:
- [ ] Convert OT hours to comp time
- [ ] Configure conversion rate
- [ ] Track comp time balance
- [ ] Use comp time for leave
- [ ] Cash out option
- [ ] Expiry rules

**Conversion Rates**:
| OT Type | Hours → Comp Time |
|---------|-------------------|
| Weekday OT | 1:1 |
| Weekend OT | 1:1.5 |
| Holiday OT | 1:2 |

---

## Category 4: Leave Policy & Compliance (6 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| LP-01 | Policy Configuration | P0 | Parity | MEDIUM | Standard |
| LP-02 | Eligibility Rules | P0 | Parity | MEDIUM | Standard |
| LP-03 | Waiting Period Rules | P0 | Parity | MEDIUM | Standard |
| LP-04 | Vietnam Labor Law Compliance | P0 | Compliance | HIGH | **Core Gap** |
| LP-05 | Social Insurance Integration | P0 | Compliance | HIGH | **Core Gap** |
| LP-06 | Multi-Region Policies | P1 | Parity | HIGH | Config |

### Detailed Specifications

#### LP-04: Vietnam Labor Law Compliance

```yaml
id: LP-04
name: Vietnam Labor Law Compliance
category: Leave Policy & Compliance
priority: P0
differentiation: Compliance
complexity: HIGH
gap_type: CORE GAP
phase: 1
source: Legal Requirement
decision_ref: ADR-003
authority: PENDING ARB APPROVAL
```

**⚠️ CORE GAP - Requires ARB Approval**

**Description**:
Tuân thủ đầy đủ Bộ luật Lao động 2019 Việt Nam

**Legal Requirements**:
| Article | Requirement | Implementation |
|---------|-------------|----------------|
| Điều 112 | Public holidays 11 days | Holiday calendar |
| Điều 113 | Annual leave 12/14/16 days | Leave policy rules |
| Điều 114 | +1 day per 5 years | Seniority bonus |
| Điều 115 | Personal leave (marriage, bereavement) | Leave types |
| Điều 98 | Overtime rates 150/200/300% | Overtime rules |

**Functional Requirements**:
- [ ] Pre-built VN leave types
- [ ] Pre-built VN policies
- [ ] Seniority calculation
- [ ] Holiday calendar (Tết, etc.)
- [ ] Overtime rate calculation
- [ ] Compliance reporting

---

#### LP-05: Social Insurance Integration

```yaml
id: LP-05
name: Social Insurance Integration
category: Leave Policy & Compliance
priority: P0
differentiation: Compliance
complexity: HIGH
gap_type: CORE GAP
phase: 1
source: Legal Requirement
decision_ref: ADR-003
authority: PENDING ARB APPROVAL
```

**⚠️ CORE GAP - Requires ARB Approval**

**Description**:
Tích hợp với hệ thống BHXH Việt Nam

**Functional Requirements**:
- [ ] Track SI contribution history
- [ ] Calculate sick leave entitlement based on SI years
- [ ] Generate SI claim documents
- [ ] Export data for SI submission
- [ ] Import SI payment status

**SI Leave Entitlement**:
| SI Years | Normal Jobs | Hazardous |
|----------|-------------|-----------|
| < 15 | 30 days | 40 days |
| 15-30 | 40 days | 50 days |
| ≥ 30 | 60 days | 70 days |

---

## Category 5: Scheduling (7 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| SC-01 | Shift Definition | P1 | Parity | LOW | Standard |
| SC-02 | Schedule Assignment | P1 | Parity | MEDIUM | Standard |
| SC-03 | Rotating Schedules | P1 | Parity | MEDIUM | Standard |
| SC-04 | Shift Swap Request | P1 | Parity | MEDIUM | Standard |
| SC-05 | Schedule Template | P1 | Parity | LOW | Standard |
| SC-06 | Auto-Scheduling | P2 | Innovation | HIGH | Extension |
| SC-07 | Cross-Midnight Support | P1 | Parity | MEDIUM | Config |

---

## Category 6: Calendar & Holiday (4 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| CH-01 | Holiday Calendar Definition | P1 | Parity | LOW | Standard |
| CH-02 | Regional Holiday Support | P1 | Compliance | MEDIUM | **Core Gap** |
| CH-03 | Team Absence Calendar | P1 | Parity | LOW | Standard |
| CH-04 | Calendar Export/Sync | P1 | Parity | LOW | Standard |

---

## Category 7: Overtime & Compensatory (4 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| OT-01 | Overtime Calculation | P1 | Parity | MEDIUM | Standard |
| OT-02 | Overtime Approval | P1 | Parity | LOW | Standard |
| OT-03 | Comp Time Conversion | P1 | Parity | MEDIUM | Standard |
| OT-04 | Overtime Caps/Alerts | P1 | Parity | MEDIUM | Config |

---

## Category 8: Reporting & Analytics (6 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| RA-01 | Absence Dashboard | P2 | Parity | MEDIUM | Standard |
| RA-02 | Trend Analysis | P2 | Parity | MEDIUM | Standard |
| RA-03 | Cost Analysis | P2 | Parity | MEDIUM | Standard |
| RA-04 | Compliance Reports | P2 | Compliance | MEDIUM | Standard |
| RA-05 | Predictive Analytics | P2 | Innovation | HIGH | Extension |
| RA-06 | Custom Report Builder | P2 | Parity | MEDIUM | Standard |

---

## Category 9: Self-Service & UX (5 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| SS-01 | Employee Self-Service Portal | P2 | Parity | LOW | Standard |
| SS-02 | Manager Dashboard | P2 | Parity | MEDIUM | Standard |
| SS-03 | Mobile App | P2 | Parity | MEDIUM | Standard |
| SS-04 | Push Notifications | P2 | Parity | LOW | Standard |
| SS-05 | Teams/Slack Integration | P2 | Innovation | MEDIUM | Extension |

---

## Category 10: Integration (5 features)

### Summary

| ID | Feature | Priority | Diff | Complexity | Gap Type |
|----|---------|----------|------|------------|----------|
| IN-01 | Payroll Integration | P1 | Parity | HIGH | **Core Gap** |
| IN-02 | Core HR Integration | P1 | Parity | HIGH | Standard |
| IN-03 | Benefits Integration | P2 | Parity | MEDIUM | Standard |
| IN-04 | API Access | P2 | Parity | MEDIUM | Standard |
| IN-05 | Biometric Device Integration | P2 | Parity | MEDIUM | Standard |

---

## Implementation Phases

### Phase 1: Foundation (Month 1-4)

**Features**: 22 (All P0)
- AM-01 to AM-10 (10)
- LA-01 to LA-06, LA-08 (7)
- LP-01 to LP-05 (5)

**Exit Criteria**:
- [ ] All P0 features complete
- [ ] VN Labor Law compliance verified
- [ ] Core HR integration working
- [ ] UAT passed

### Phase 2: Enhancement (Month 5-7)

**Features**: 24 (All P1)
- TT-01 to TT-06 (6)
- SC-01 to SC-05, SC-07 (6)
- CH-01 to CH-04 (4)
- OT-01 to OT-04 (4)
- LP-06 (1)
- IN-01, IN-02 (2)
- LA-07 (1)

**Exit Criteria**:
- [ ] All P1 features complete
- [ ] Mobile app published
- [ ] Scheduling functional

### Phase 3: Advanced (Month 8-10)

**Features**: 19 (All P2)
- TT-07, TT-08 (2)
- AM-11, AM-12 (2)
- SC-06 (1)
- RA-01 to RA-06 (6)
- SS-01 to SS-05 (5)
- IN-03 to IN-05 (3)

**Exit Criteria**:
- [ ] All P2 features complete
- [ ] AI accuracy > 85%
- [ ] Full API documentation

---

## Core Gaps Summary

| ID | Feature | Justification | ARB Status |
|----|---------|---------------|------------|
| LP-04 | VN Labor Law Compliance | Legal requirement for VN market | PENDING |
| LP-05 | Social Insurance Integration | SI is mandatory for VN employees | PENDING |
| CH-02 | Regional Holiday Support | VN holidays are unique | PENDING |
| IN-01 | Payroll Integration | T&A is primary payroll input | PENDING |

**Note**: All Core Gaps are mandatory for Vietnam market launch. ARB approval is a formality.

---

*Generated by domain-research skill as part of Research-Driven Workflow.*
