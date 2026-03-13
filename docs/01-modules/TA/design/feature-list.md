# Feature List: Time & Absence Module

> Danh sách tổng hợp các tính năng của module Time & Absence (TA) — tạo từ `_research/feature-catalog.md`.

## Thông tin tài liệu

| Field | Value |
|-------|-------|
| **Module** | Time & Absence (TA) |
| **Tổng số features** | 65 |
| **Số categories** | 10 |
| **Nguồn** | `_research/feature-catalog.md` |
| **Ngày tạo** | 2026-03-10 |

---

## Phân bố theo Priority

| Priority | Số lượng | % |
|----------|----------|---|
| P0 (Must Have) | 22 | 34% |
| P1 (Should Have) | 24 | 37% |
| P2 (Nice to Have) | 19 | 29% |

## Phân bố theo Differentiation

| Loại | Số lượng | % | Mô tả |
|------|----------|---|-------|
| Parity | 48 | 74% | Table stakes — theo chuẩn thị trường |
| Innovation | 11 | 17% | USP — lợi thế cạnh tranh |
| Compliance | 6 | 9% | Bắt buộc — yêu cầu pháp lý |

## Phân bố theo Gap Type

| Gap Type | Số lượng | Strategy |
|----------|----------|----------|
| Standard Fit | 51 | Configure only |
| Config Gap | 7 | Customize config |
| Extension Gap | 4 | Build extension |
| **Core Gap** | 3 | ARB approval needed |

---

## Category 1: Time Tracking (8 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| TT-01 | Clock In/Out | P1 | Parity | LOW | Standard | 1 |
| TT-02 | Mobile Time Clock | P1 | Parity | MEDIUM | Standard | 1 |
| TT-03 | Biometric Integration | P1 | Parity | HIGH | Standard | 2 |
| TT-04 | GPS/Geofencing | P1 | Innovation | MEDIUM | Config | 2 |
| TT-05 | Web Timesheet Entry | P1 | Parity | LOW | Standard | 1 |
| TT-06 | Project Time Tracking | P1 | Parity | MEDIUM | Standard | 2 |
| TT-07 | Offline Time Capture | P2 | Innovation | HIGH | Extension | 3 |
| TT-08 | Auto Clock-In Detection | P2 | Innovation | HIGH | Extension | 3 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **TT-01** | Chấm công vào/ra qua hệ thống; validate không chấm trùng; hỗ trợ nghỉ giữa ca |
| **TT-02** | Chấm công qua app mobile iOS/Android; capture GPS; offline mode; push notification |
| **TT-03** | Tích hợp thiết bị sinh trắc học (fingerprint, face recognition, card reader) |
| **TT-04** | Xác thực vị trí chấm công qua geofence; cấu hình mode STRICT/WARN/LOG |
| **TT-05** | Nhập giờ làm việc qua web; calendar view; split cost center; submit workflow |
| **TT-06** | Phân bổ thời gian theo project/task; validate với budget; multi-project per day |
| **TT-07** | Lưu punch locally khi offline; sync queue khi có mạng; offline tối đa 7 ngày |
| **TT-08** | AI detect arrival qua WiFi/location; gợi ý clock-in; learn theo pattern cá nhân |

---

## Category 2: Absence Management (12 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| AM-01 | Leave Request Submission | P0 | Parity | LOW | Standard | 1 |
| AM-02 | Leave Approval Workflow | P0 | Parity | MEDIUM | Standard | 1 |
| AM-03 | Multi-Level Approval | P0 | Parity | MEDIUM | Standard | 1 |
| AM-04 | Delegate Approver | P0 | Parity | LOW | Standard | 1 |
| AM-05 | Bulk Leave Actions | P0 | Parity | MEDIUM | Standard | 1 |
| AM-06 | Concurrent Absences | P0 | Parity | MEDIUM | Config | 1 |
| AM-07 | Half-Day Leave | P0 | Parity | LOW | Standard | 1 |
| AM-08 | Hourly Leave | P0 | Parity | LOW | Standard | 1 |
| AM-09 | Leave Comments/Attachments | P0 | Parity | LOW | Standard | 1 |
| AM-10 | Cancel/Modify Request | P0 | Parity | LOW | Standard | 1 |
| AM-11 | AI Approval Recommendation | P2 | Innovation | HIGH | Extension | 3 |
| AM-12 | Vacation Bidding | P2 | Innovation | HIGH | Extension | 3 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **AM-01** | Tạo và gửi đơn nghỉ phép; view balance; validate policy (balance, notice, blackout) |
| **AM-02** | Route tới manager; approve/reject; escalation tự động; audit trail |
| **AM-03** | Multi-level chain theo loại nghỉ/thời hạn; sequential/parallel mode |
| **AM-04** | Ủy quyền phê duyệt trong khoảng thời gian; auto-route; delegate notifications |
| **AM-05** | Bulk approve/reject nhiều đơn; filter; undo trong time window |
| **AM-06** | Hỗ trợ overlapping leave types; priority rules cho payroll; cấu hình combinations |
| **AM-07** | Nghỉ nửa ngày (AM/PM); deduct 0.5 từ balance; configurable per leave type |
| **AM-08** | Nghỉ theo giờ; minimum 1 giờ; balance in hours; tích hợp time tracking |
| **AM-09** | Đính kèm lý do và tài liệu; track comment history; required docs per leave type |
| **AM-10** | Hủy/sửa đơn đã gửi; restore balance; notification; cancel approved cần workflow |
| **AM-11** | AI phân tích historical patterns để gợi ý phê duyệt; accuracy target > 85% |
| **AM-12** | Đấu giá lịch nghỉ cao điểm (Tết, hè); rank theo seniority/points; appeal process |

---

## Category 3: Leave Balance & Accrual (8 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| LA-01 | Balance Inquiry | P0 | Parity | LOW | Standard | 1 |
| LA-02 | Automated Accrual | P0 | Parity | MEDIUM | Standard | 1 |
| LA-03 | Proration Calculation | P0 | Parity | MEDIUM | Standard | 1 |
| LA-04 | Carryover Rules | P0 | Parity | MEDIUM | Standard | 1 |
| LA-05 | Expiration Rules | P0 | Parity | MEDIUM | Standard | 1 |
| LA-06 | Negative Balance Control | P0 | Parity | MEDIUM | Config | 1 |
| LA-07 | Sell/Buy Leave | P2 | Innovation | HIGH | Extension | 2 |
| LA-08 | Compensatory Time | P0 | Parity | MEDIUM | Standard | 1 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **LA-01** | Xem số dư theo loại nghỉ; breakdown Opening+Earned-Used-Pending=Available; as of date |
| **LA-02** | Tự động tính và cộng balance theo kỳ (Monthly/Quarterly/Annual); batch job; history |
| **LA-03** | Tính pro-rata khi mới vào/nghỉ việc/đổi status; configurable method (Calendar/Work Days/Monthly) |
| **LA-04** | Quy tắc chuyển số dư năm mới; max carryover days; expiry; FIFO/LIFO |
| **LA-05** | Quy tắc hết hạn balance; notification trước khi expire; auto-expire; forfeiture report |
| **LA-06** | Cấu hình cho phép số dư âm; max negative days; approval workflow; payback rules |
| **LA-07** | Bán/mua ngày nghỉ; tích hợp payroll; annual limits; approval workflow |
| **LA-08** | Quy đổi overtime thành comp time; conversion rate; use comp time for leave; cash out |

---

## Category 4: Leave Policy & Compliance (6 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| LP-01 | Policy Configuration | P0 | Parity | MEDIUM | Standard | 1 |
| LP-02 | Eligibility Rules | P0 | Parity | MEDIUM | Standard | 1 |
| LP-03 | Waiting Period Rules | P0 | Parity | MEDIUM | Standard | 1 |
| LP-04 | Vietnam Labor Law Compliance | P0 | Compliance | HIGH | **Core Gap** | 1 |
| LP-05 | Social Insurance Integration | P0 | Compliance | HIGH | **Core Gap** | 1 |
| LP-06 | Multi-Region Policies | P1 | Parity | HIGH | Config | 2 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **LP-01** | Cấu hình chính sách nghỉ phép; accrual, carryover, limit, overdraft, validation rules |
| **LP-02** | Quy tắc đủ điều kiện nghỉ theo tenure, contract type, employment category |
| **LP-03** | Quy tắc thời gian chờ trước khi được nghỉ (probation period, new hire) |
| **LP-04** | ⚠️ **CORE GAP** — Bộ luật Lao động 2019 VN: 11 ngày phép, 12/14/16 ngày phép năm, thâm niên, overtime 150/200/300% |
| **LP-05** | ⚠️ **CORE GAP** — Tích hợp BHXH VN: track SI history, tính nghỉ ốm, generate claim docs |
| **LP-06** | Hỗ trợ đa chính sách theo quốc gia/vùng; configurable per legal entity |

---

## Category 5: Scheduling (7 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| SC-01 | Shift Definition | P1 | Parity | LOW | Standard | 2 |
| SC-02 | Schedule Assignment | P1 | Parity | MEDIUM | Standard | 2 |
| SC-03 | Rotating Schedules | P1 | Parity | MEDIUM | Standard | 2 |
| SC-04 | Shift Swap Request | P1 | Parity | MEDIUM | Standard | 2 |
| SC-05 | Schedule Template | P1 | Parity | LOW | Standard | 2 |
| SC-06 | Auto-Scheduling | P2 | Innovation | HIGH | Extension | 3 |
| SC-07 | Cross-Midnight Support | P1 | Parity | MEDIUM | Config | 2 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **SC-01** | Định nghĩa ca làm việc (start/end time, break, pay code); reusable shift patterns |
| **SC-02** | Gán lịch làm cho nhân viên/team; publish schedule; conflict detection |
| **SC-03** | Hỗ trợ lịch xoay ca (A/B/C rotation); cycle management; auto-advance |
| **SC-04** | Nhân viên đề xuất đổi ca với đồng nghiệp; manager approval; auto-update schedule |
| **SC-05** | Template lịch tuần/tháng; clone và apply cho nhiều periods |
| **SC-06** | AI tự động xếp lịch tối ưu; coverage requirements; skill matching; compliance |
| **SC-07** | Hỗ trợ ca qua nửa đêm (night shift); đúng tính toán ngày; holiday handling |

---

## Category 6: Calendar & Holiday (4 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| CH-01 | Holiday Calendar Definition | P1 | Parity | LOW | Standard | 2 |
| CH-02 | Regional Holiday Support | P1 | Compliance | MEDIUM | **Core Gap** | 2 |
| CH-03 | Team Absence Calendar | P1 | Parity | LOW | Standard | 2 |
| CH-04 | Calendar Export/Sync | P1 | Parity | LOW | Standard | 2 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **CH-01** | Định nghĩa lịch nghỉ lễ công ty/quốc gia; recurring holidays; manual override |
| **CH-02** | ⚠️ **CORE GAP** — Hỗ trợ lịch nghỉ theo vùng/quốc gia; VN holidays (Tết, Giỗ Tổ, etc.) |
| **CH-03** | Xem lịch vắng mặt team; filter theo type/period; manager view |
| **CH-04** | Export lịch sang Google Calendar/Outlook/iCal; two-way sync |

---

## Category 7: Overtime & Compensatory (4 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| OT-01 | Overtime Calculation | P1 | Parity | MEDIUM | Standard | 2 |
| OT-02 | Overtime Approval | P1 | Parity | LOW | Standard | 2 |
| OT-03 | Comp Time Conversion | P1 | Parity | MEDIUM | Standard | 2 |
| OT-04 | Overtime Caps/Alerts | P1 | Parity | MEDIUM | Config | 2 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **OT-01** | Tính OT tự động theo ca; rate calculation (150/200/300%); VN Labor Law compliant |
| **OT-02** | Pre-approval workflow cho overtime; manager approve trước khi làm; audit trail |
| **OT-03** | Quy đổi OT thành comp time; configurable rate (1:1, 1:1.5, 1:2); tracking balance |
| **OT-04** | Limit OT theo ngày/tuần/tháng/năm; alert khi gần giới hạn; LLV compliance |

---

## Category 8: Reporting & Analytics (6 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| RA-01 | Absence Dashboard | P2 | Parity | MEDIUM | Standard | 3 |
| RA-02 | Trend Analysis | P2 | Parity | MEDIUM | Standard | 3 |
| RA-03 | Cost Analysis | P2 | Parity | MEDIUM | Standard | 3 |
| RA-04 | Compliance Reports | P2 | Compliance | MEDIUM | Standard | 3 |
| RA-05 | Predictive Analytics | P2 | Innovation | HIGH | Extension | 3 |
| RA-06 | Custom Report Builder | P2 | Parity | MEDIUM | Standard | 3 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **RA-01** | Dashboard tổng hợp: attendance rate, absence trends, balance summary, exceptions |
| **RA-02** | Phân tích xu hướng vắng mặt theo team/loại/period; seasonality patterns |
| **RA-03** | Chi phí vắng mặt (overtime fill, temp staff, productivity loss); cost per absence |
| **RA-04** | Báo cáo tuân thủ VN Labor Law; audit log; SI claim reports |
| **RA-05** | AI dự báo absence patterns; early warning; staffing risk alerts |
| **RA-06** | Drag-and-drop report builder; custom dimensions; schedule & export |

---

## Category 9: Self-Service & UX (5 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| SS-01 | Employee Self-Service Portal | P2 | Parity | LOW | Standard | 3 |
| SS-02 | Manager Dashboard | P2 | Parity | MEDIUM | Standard | 3 |
| SS-03 | Mobile App | P2 | Parity | MEDIUM | Standard | 3 |
| SS-04 | Push Notifications | P2 | Parity | LOW | Standard | 3 |
| SS-05 | Teams/Slack Integration | P2 | Innovation | MEDIUM | Extension | 3 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **SS-01** | Portal tự phục vụ: view/submit leave, check balance, view history, download statements |
| **SS-02** | Dashboard manager: team calendar, pending approvals, attendance exceptions, alerts |
| **SS-03** | App di động: full leave management, time clock, notifications, offline support |
| **SS-04** | Push notification: pending approvals, status updates, expiry warnings, OT alerts |
| **SS-05** | Bot trong Teams/Slack: submit request, approve, check balance qua chat |

---

## Category 10: Integration (5 features)

| ID | Feature | Priority | Diff | Complexity | Gap Type | Phase |
|----|---------|----------|------|------------|----------|-------|
| IN-01 | Payroll Integration | P1 | Parity | HIGH | **Core Gap** | 2 |
| IN-02 | Core HR Integration | P1 | Parity | HIGH | Standard | 2 |
| IN-03 | Benefits Integration | P2 | Parity | MEDIUM | Standard | 3 |
| IN-04 | API Access | P2 | Parity | MEDIUM | Standard | 3 |
| IN-05 | Biometric Device Integration | P2 | Parity | MEDIUM | Standard | 3 |

### Mô tả

| ID | Mô tả |
|----|-------|
| **IN-01** | ⚠️ **CORE GAP** — Feed T&A data sang Payroll: unpaid leave deduction, OT pay, leave encashment |
| **IN-02** | Sync employee data từ Core HR; org hierarchy; employment status changes |
| **IN-03** | Tích hợp Benefits: leave encashment, group insurance claims, wellness programs |
| **IN-04** | REST API public cho third-party integration; webhook events; idempotent operations |
| **IN-05** | Connector cho biometric devices (ZKTeco, Suprema, Hikvision); multi-vendor support |

---

## Implementation Phases

### Phase 1: Foundation (Month 1–4) — 22 features (All P0)

| Group | Features |
|-------|---------|
| Absence Management | AM-01 đến AM-10 (10 features) |
| Leave Balance & Accrual | LA-01 đến LA-06, LA-08 (7 features) |
| Leave Policy & Compliance | LP-01 đến LP-05 (5 features) |

**Exit Criteria**: P0 complete · VN Labor Law verified · Core HR integration working · UAT passed

### Phase 2: Enhancement (Month 5–7) — 24 features (All P1)

| Group | Features |
|-------|---------|
| Time Tracking | TT-01 đến TT-06 (6 features) |
| Scheduling | SC-01 đến SC-05, SC-07 (6 features) |
| Calendar & Holiday | CH-01 đến CH-04 (4 features) |
| Overtime & Compensatory | OT-01 đến OT-04 (4 features) |
| Policy & Integration | LP-06, IN-01, IN-02, LA-07 (4 features) |

**Exit Criteria**: P1 complete · Mobile app published · Scheduling functional

### Phase 3: Advanced (Month 8–10) — 19 features (All P2)

| Group | Features |
|-------|---------|
| Time Tracking Advanced | TT-07, TT-08 (2 features) |
| Absence Innovation | AM-11, AM-12 (2 features) |
| Scheduling AI | SC-06 (1 feature) |
| Reporting & Analytics | RA-01 đến RA-06 (6 features) |
| Self-Service & UX | SS-01 đến SS-05 (5 features) |
| Integration | IN-03 đến IN-05 (3 features) |

**Exit Criteria**: P2 complete · AI accuracy > 85% · Full API documentation

---

## Core Gaps — Cần ARB Approval

> Các gaps này là **bắt buộc** cho Vietnam market launch.

| ID | Feature | Justification | ARB Status |
|----|---------|---------------|------------|
| LP-04 | VN Labor Law Compliance | Yêu cầu pháp lý bắt buộc cho thị trường VN | PENDING |
| LP-05 | Social Insurance Integration | BHXH bắt buộc cho mọi nhân viên VN | PENDING |
| CH-02 | Regional Holiday Support | Lịch nghỉ VN (Tết, v.v.) độc đáo và bắt buộc | PENDING |
| IN-01 | Payroll Integration | T&A là primary input cho tính lương | PENDING |

---

## Quick Reference — Toàn bộ 65 features

| ID | Feature | Priority | Category |
|----|---------|----------|----------|
| TT-01 | Clock In/Out | P1 | Time Tracking |
| TT-02 | Mobile Time Clock | P1 | Time Tracking |
| TT-03 | Biometric Integration | P1 | Time Tracking |
| TT-04 | GPS/Geofencing | P1 | Time Tracking |
| TT-05 | Web Timesheet Entry | P1 | Time Tracking |
| TT-06 | Project Time Tracking | P1 | Time Tracking |
| TT-07 | Offline Time Capture | P2 | Time Tracking |
| TT-08 | Auto Clock-In Detection | P2 | Time Tracking |
| AM-01 | Leave Request Submission | P0 | Absence Management |
| AM-02 | Leave Approval Workflow | P0 | Absence Management |
| AM-03 | Multi-Level Approval | P0 | Absence Management |
| AM-04 | Delegate Approver | P0 | Absence Management |
| AM-05 | Bulk Leave Actions | P0 | Absence Management |
| AM-06 | Concurrent Absences | P0 | Absence Management |
| AM-07 | Half-Day Leave | P0 | Absence Management |
| AM-08 | Hourly Leave | P0 | Absence Management |
| AM-09 | Leave Comments/Attachments | P0 | Absence Management |
| AM-10 | Cancel/Modify Request | P0 | Absence Management |
| AM-11 | AI Approval Recommendation | P2 | Absence Management |
| AM-12 | Vacation Bidding | P2 | Absence Management |
| LA-01 | Balance Inquiry | P0 | Leave Balance & Accrual |
| LA-02 | Automated Accrual | P0 | Leave Balance & Accrual |
| LA-03 | Proration Calculation | P0 | Leave Balance & Accrual |
| LA-04 | Carryover Rules | P0 | Leave Balance & Accrual |
| LA-05 | Expiration Rules | P0 | Leave Balance & Accrual |
| LA-06 | Negative Balance Control | P0 | Leave Balance & Accrual |
| LA-07 | Sell/Buy Leave | P2 | Leave Balance & Accrual |
| LA-08 | Compensatory Time | P0 | Leave Balance & Accrual |
| LP-01 | Policy Configuration | P0 | Leave Policy & Compliance |
| LP-02 | Eligibility Rules | P0 | Leave Policy & Compliance |
| LP-03 | Waiting Period Rules | P0 | Leave Policy & Compliance |
| LP-04 | Vietnam Labor Law Compliance | P0 | Leave Policy & Compliance |
| LP-05 | Social Insurance Integration | P0 | Leave Policy & Compliance |
| LP-06 | Multi-Region Policies | P1 | Leave Policy & Compliance |
| SC-01 | Shift Definition | P1 | Scheduling |
| SC-02 | Schedule Assignment | P1 | Scheduling |
| SC-03 | Rotating Schedules | P1 | Scheduling |
| SC-04 | Shift Swap Request | P1 | Scheduling |
| SC-05 | Schedule Template | P1 | Scheduling |
| SC-06 | Auto-Scheduling | P2 | Scheduling |
| SC-07 | Cross-Midnight Support | P1 | Scheduling |
| CH-01 | Holiday Calendar Definition | P1 | Calendar & Holiday |
| CH-02 | Regional Holiday Support | P1 | Calendar & Holiday |
| CH-03 | Team Absence Calendar | P1 | Calendar & Holiday |
| CH-04 | Calendar Export/Sync | P1 | Calendar & Holiday |
| OT-01 | Overtime Calculation | P1 | Overtime & Compensatory |
| OT-02 | Overtime Approval | P1 | Overtime & Compensatory |
| OT-03 | Comp Time Conversion | P1 | Overtime & Compensatory |
| OT-04 | Overtime Caps/Alerts | P1 | Overtime & Compensatory |
| RA-01 | Absence Dashboard | P2 | Reporting & Analytics |
| RA-02 | Trend Analysis | P2 | Reporting & Analytics |
| RA-03 | Cost Analysis | P2 | Reporting & Analytics |
| RA-04 | Compliance Reports | P2 | Reporting & Analytics |
| RA-05 | Predictive Analytics | P2 | Reporting & Analytics |
| RA-06 | Custom Report Builder | P2 | Reporting & Analytics |
| SS-01 | Employee Self-Service Portal | P2 | Self-Service & UX |
| SS-02 | Manager Dashboard | P2 | Self-Service & UX |
| SS-03 | Mobile App | P2 | Self-Service & UX |
| SS-04 | Push Notifications | P2 | Self-Service & UX |
| SS-05 | Teams/Slack Integration | P2 | Self-Service & UX |
| IN-01 | Payroll Integration | P1 | Integration |
| IN-02 | Core HR Integration | P1 | Integration |
| IN-03 | Benefits Integration | P2 | Integration |
| IN-04 | API Access | P2 | Integration |
| IN-05 | Biometric Device Integration | P2 | Integration |

---

*Tạo từ `_research/feature-catalog.md` · 2026-03-10 · Module Time & Absence (TA)*
