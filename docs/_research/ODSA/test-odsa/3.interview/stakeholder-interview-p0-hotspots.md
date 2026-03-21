# Stakeholder Interview — ATS Fresher Module

> **Session Purpose:** Resolve P0 Hot Spots from Event Storming session
> **Date:** 2026-03-20
> **Interviewer:** AI Assistant
> **Stakeholder:** BA Team / HR Director / Product Owner
> **Status:** IN PROGRESS

---

## Session Overview

| Attribute | Value |
|-----------|-------|
| **Domain** | ATS Fresher — Applicant Tracking System |
| **Session Type** | Hot Spot Resolution Interview |
| **P0 Hot Spots** | 4 hot spots (H01, H03, H08, H12) |
| **Output** | Resolved decisions for Bounded Context design |

---

## P0 Hot Spots được chọn

| ID | Hot Spot | Priority | Status |
|----|----------|----------|--------|
| H01 | Quy trình auto-allocate slot từ hàng chờ khi Student đổi lịch | P0 | ✅ RESOLVED |
| H03 | Khi OfferRejected, TA có được tạo Offer mới cho cùng 1 Candidate? | P0 | ✅ RESOLVED |
| H08 | EmailFailed — retry policy là gì? Retry bao nhiêu lần? | P0 | ✅ RESOLVED |
| H12 | Offer deadline — nếu Student không phản hồi, hệ thống auto gì? | P0 | ✅ RESOLVED |

---

## Interview Questions & Decisions

### Q01: Auto-allocate Slot từ Hàng chờ (H01)

**Câu hỏi:** Khi Student request đổi lịch thi/interview và ca mới đã hết slot, hệ thống đưa Student vào hàng chờ. Khi nào và như thế nào để auto-allocate slot từ hàng chờ?

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Manual Trigger bởi TA | TA kiểm soát hoàn toàn | Overhead cho TA, chậm response |
| B | Auto-allocate Ngay khi có Slot | Nhanh, không cần TA intervention | Không có sự ưu tiên đặc biệt |
| C | Auto-allocate với Batch Processing (2 tiếng/lần) | Cân bằng giữa tốc độ và control | Student phải chờ lâu hơn |
| D | First-Come-First-Served với Time Window | Công bằng, transparent | Có thể mất thời gian nếu nhiều Students không phản hồi |

**Decision:**

| Attribute | Value |
|-----------|-------|
| **Selected Option** | **Option D** — First-Come-First-Served với Time Window |
| **Rationale** | Đảm bảo công bằng cho ứng viên, có transparency trong allocation |

**Implementation Details:**

| Parameter | Value |
|-----------|-------|
| **Time Window để confirm** | **Configurable** — default: 24 giờ |
| **Số lần retry nếu không confirm** | **Configurable** — default: 2 lần |
| **Notify TA khi auto-allocate** | **Configurable** — email/in-app notification |
| **All parameters** | **Fully Configurable** via Settings |

**Related Events:**
- `ScheduleChanged`
- `SlotAllocated`
- `ScheduleConfirmed`
- `ScheduleExpired`

---

### Q02: OfferRejected — Tạo Offer mới? (H03)

**Câu hỏi:** Khi Student Reject Offer, TA có được tạo Offer mới cho cùng 1 Candidate không? Hay Candidate bị loại hoàn toàn khỏi quy trình?

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Không được tạo Offer mới (Hard Reject) | Rõ ràng, dứt khoát, tránh spam Offers | Mất ứng viên tiềm năng nếu họ change mind |
| B | Được tạo 1 Offer duy nhất (One Re-offer) | Giữ chân ứng viên tốt, flexibility cho TA | Phức tạp hơn, cần approval workflow |
| C | Được tạo Offer unlimited (Unlimited Re-offers) | Maximum flexibility | Risk spam Candidates, khó track |
| D | Auto-extend Offer Deadline (Pre-Reject Prevention) | Giảm Reject rate, có mechanism prevention | Phức tạp implement |

**Decision:**

| Attribute | Value |
|-----------|-------|
| **Selected Option** | **Hybrid Option B + D** — Re-offer configurable + Auto-remind prevention |
| **Rationale** | Kết hợp lợi điểm của cả 2 options: (1) Prevention qua auto-remind để giảm expire/reject, (2) Re-offer configurable để giữ chân ứng viên tiềm năng |

**Implementation Details:**

| Parameter | Value |
|-----------|-------|
| **Re-offer allowed** | **Configurable** — số lần tối đa không fixed |
| **Approval required** | **Configurable Workflow** — Manager/HR Director tùy rule |
| **Expire vs Reject** | Separate handling — Expire không phải Reject |
| **Auto-remind trước deadline** | **Configurable** — thời gian + rule |
| **Re-offer cooldown period** | **Configurable** — không fixed |
| **All parameters** | **Fully Configurable** via Settings + Workflow Engine |

**Related Events:**
- `OfferCreated`
- `OfferSent`
- `OfferRejected`
- `OfferExpired`
- `OfferReminderSent`

---

### Q03: EmailFailed — Retry Policy (H08)

**Câu hỏi:** Khi email gửi thất bại (EmailFailed), retry policy là gì? Retry bao nhiêu lần, khoảng cách bao lâu? Có notify TA không?

**Context:**
- Email quan trọng: Assignment, Test Invitation, Interview Invitation, Offer Letter
- Email không quan trọng: Confirmation, Reminder, Thank You

**Options:**

#### Option A: Simple Retry (3 lần, 5 phút/lần)
- Retry tối đa 3 lần
- Khoảng cách: 5 phút giữa mỗi lần retry
- Nếu vẫn fail: Notify TA qua in-app notification
- **Pros:** Đơn giản, dễ implement
- **Cons:** Có thể miss emails quan trọng nếu SMTP issue kéo dài

#### Option B: Priority-based Retry
- **Priority 1 (Critical):** Offer, Interview Invitation — Retry 5 lần, 2 phút/lần, notify TA ngay lần fail thứ 3
- **Priority 2 (Important):** Assignment, Test Invitation — Retry 3 lần, 5 phút/lần, notify TA lần fail cuối
- **Priority 3 (Normal):** Reminder, Thank You — Retry 2 lần, 15 phút/lần, không notify TA
- **Pros:** Optimize cho emails quan trọng
- **Cons:** Phức tạp hơn, cần classify emails

#### Option C: Escalation-based
- Lần 1-2: Auto retry (5 phút)
- Lần 3: Notify TA, TA có thể manual resend
- Lần 4-5: Auto retry nếu TA không action
- Final: Escalate đến IT/Email Admin
- **Pros:** Có human intervention
- **Cons:** Yêu cầu TA monitor notifications

#### Option D: External Service Fallback
- retry qua secondary email provider (e.g., SendGrid fallback nếu SMTP primary fail)
- Retry 3 lần ở primary, fail thì switch sang secondary
- **Pros:** Tăng reliability
- **Cons:** Tốn kém (2 providers), phức tạp integration |

**Decision:**

| Attribute | Value |
|-----------|-------|
| **Selected Option** | **Hybrid All Options (A+B+C+D)** — Configurable via Rules Engine |
| **Rationale** | Hệ thống cho phép user cấu hình linh hoạt: (1) Chọn 1 trong 4 options, (2) Mix multiple options via rules, (3) Cấu hình theo email type/priority |

**Implementation Details:**

| Parameter | Value |
|-----------|-------|
| **Configurable Options** | Tất cả 4 options (A/B/C/D) có thể enable/disable |
| **Rule Engine** | Cho phép cấu hình rules theo: Email Type, Priority, Time of Day, Recipient |
| **Example Rule** | IF Email Type = "Offer Letter" THEN use Option B (Priority-based) + Option D (Fallback) |
| **Default Policy** | Simple Retry (3 lần, 5 phút) + Notify TA sau 3 fails |
| **Fallback Provider** | Optional — cấu hình khi enable Option D |
| **Notify TA** | Configurable — Email/In-app/SMS |
| **Email Classification** | Critical (Offer, Interview), Important (Assignment, Test), Normal (Reminder, Thank You) |

**Related Events:**
- `EmailSent`
- `EmailFailed`
- `EmailRetryExhausted`
- `TA Notified`

---

### Q04: Offer Deadline — Auto Action (H12)

**Câu hỏi:** Offer deadline — nếu Student không phản hồi trước deadline, hệ thống auto gì?

**Options:**

#### Option A: Auto-Expire với Status "Expired"
- Khi deadline qua, Offer tự động chuyển status = "Expired"
- Candidate không bị Reject, có thể được re-offer (tùy Q02 decision)
- TA nhận được notification
- **Pros:** Phân biệt rõ Expire vs Reject, fair cho Candidate
- **Cons:** Candidate có thể miss opportunity nếu không check email

#### Option B: Auto-Expire + Auto-Remind (Trước deadline)
- 24h trước deadline: Auto gửi remind email
- 2h trước deadline: Auto gửi remind lần 2 (SMS nếu có)
- Khi deadline qua: Status = "Expired"
- **Pros:** Giảm missed deadline, candidate-friendly
- **Cons:** Phức tạp hơn, cần SMS integration (optional)

#### Option C: Auto-Extend Deadline (Exception-based)
- Khi deadline qua, nếu Candidate không phản hồi → Auto-extend 24h
- TA nhận được notification để follow-up
- Chỉ extend 1 lần duy nhất
- **Pros:** Thêm cơ hội cho Candidate
- **Cons:** Kéo dài quy trình, có thể delay hiring

#### Option D: Auto-Reject sau Deadline
- Khi deadline qua, Offer tự động = "Rejected"
- Candidate bị loại khỏi pipeline
- TA có thể ReOpen nếu muốn
- **Pros:** Dứt khoát, rõ ràng status
- **Cons:** Có thể mất ứng viên tốt chỉ vì miss deadline |

**Decision:**

| Attribute | Value |
|-----------|-------|
| **Selected Option** | **Option B + Auto-Reject** — Auto-Expire + Remind + Auto-Reject sau configurable period |
| **Rationale** | (1) Auto-remind trước deadline để giảm missed deadline, (2) Sau khi expire, TA có configurable period để gia hạn/reactivate, (3) Nếu TA không action, auto-reject để dứt khoát status |

**Implementation Details:**

| Parameter | Value |
|-----------|-------|
| **Pre-deadline remind** | Configurable — đề xuất: 24h + 2h trước expiry |
| **Auto-action tại deadline** | Auto-Expire (status = "Expired") |
| **Post-expire grace period** | Configurable — đề xuất: 24-48 giờ để TA gia hạn/reactivate |
| **Auto-action sau grace period** | Auto-Reject (status = "Rejected") |
| **Notify TA** | Có — tại deadline expire và trước khi auto-reject |
| **Re-offer eligible sau Expire** | Có — linked to Q02 decision (re-offer configurable) |
| **Reactivate workflow** | Configurable workflow — TA có thể reactivate trước khi auto-reject |

**Related Events:**
- `OfferSent`
- `OfferReminderSent`
- `OfferExpired`
- `OfferRejected`

---

## Decision Log

| Timestamp | Question | Decision | Notes |
|-----------|----------|----------|-------|
| 2026-03-20 | Q01 — Auto-allocate Slot | Option D — FCFS với Time Window | **All parameters configurable** |
| 2026-03-20 | Q02 — Offer Rejected | Hybrid B+D — Re-offer + Auto-remind | **Configurable + Workflow-based** |
| 2026-03-20 | Q03 — Email Retry | Hybrid A+B+C+D — Configurable Rules | **Rule engine cho phép mix options** |
| 2026-03-20 | Q04 — Offer Deadline | Option B + Auto-Reject | **Configurable grace period** |

---

## Pending Questions for Stakeholder

### ✅ Q01 Follow-up Details — RESOLVED

| Question | Your Answer |
|----------|-------------|
| Time Window để confirm = ? | **Configurable** (default: 24 giờ) |
| Số lần retry nếu không confirm = ? | **Configurable** (default: 2 lần) |
| Notify TA khi auto-allocate = ? | **Configurable** (default: Có) |

### ✅ Q02 Follow-up Details — RESOLVED

| Question | Your Answer |
|----------|-------------|
| Số lần Re-offer tối đa = ? | **Configurable** (không fixed) |
| Approval required = ? | **Configurable Workflow** |
| Auto-remind trước deadline = ? | **Configurable** (thời gian + rule) |
| Re-offer cooldown period = ? | **Configurable** (không fixed) |

### ✅ Q03 Decision — RESOLVED

| Question | Your Answer |
|----------|-------------|
| Selected Option (A/B/C/D) | **Hybrid All Options** — Configurable via Rules |
| Max retries | **Configurable** per email type |
| Retry interval | **Configurable** per email type |
| Notify TA? | **Configurable** |
| Notify method | **Configurable** (email/in-app/SMS) |

### ✅ Q04 Decision — RESOLVED

| Question | Your Answer |
|----------|-------------|
| Selected Option (A/B/C/D) | **Option B + Auto-Reject** |
| Pre-deadline remind | **Configurable** (24h + 2h default) |
| Auto-action tại deadline | **Auto-Expire** → Grace Period → **Auto-Reject** |
| Notify TA? | **Có** (tại expire và trước reject) |

---

## Next Steps

- [x] Resolve Q01 — Auto-allocate Slot (Configurable)
- [x] Resolve Q02 — Offer Re-offer + Auto-remind (Configurable + Workflow)
- [x] Resolve Q03 — Email Retry Policy (Configurable Rules Engine)
- [x] Resolve Q04 — Offer Deadline (Auto-Expire + Grace Period + Auto-Reject)
- [ ] Update BRD với các decisions
- [ ] Update Event Storming summary với resolved Hot Spots
- [ ] Proceed to Bounded Context identification
- [ ] Design Configuration Schema cho các configurable parameters

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | 2026-03-20 | AI Assistant | Initial interview session created |
| 0.2 | 2026-03-20 | AI Assistant | Added Q01 (Option D) và Q02 (Hybrid B+D) decisions |
| 0.3 | 2026-03-20 | AI Assistant | **All P0 Hot Spots RESOLVED** — Updated Q03 (Hybrid Rules), Q04 (B+Auto-Reject), finalized Q01/Q02 as Configurable |

---

## Summary: All P0 Hot Spots RESOLVED ✅

### Design Principles từ Interview

| Principle | Description |
|-----------|-------------|
| **Configurability First** | Tất cả parameters đều configurable, không hardcode |
| **Rule-based Engine** | Hỗ trợ rules để mix options (đặc biệt Q03 Email Retry) |
| **Workflow-based Approval** | Approval workflows configurable theo org structure |
| **Grace Periods** | Luôn có grace period trước khi auto-action tiêu cực |
| **Notify TA** | TA luôn được notify trước và sau khi auto-action |

### Configuration Categories

| Category | Configurable Items |
|----------|-------------------|
| **Time Windows** | Confirm window, Retry intervals, Grace periods, Remind times |
| **Retry Policies** | Max retries, Retry intervals, Notify thresholds, Fallback providers |
| **Workflows** | Approval chains, Re-offer limits, Reactivate workflows |
| **Notifications** | Notify methods (email/in-app/SMS), Notify timing, Notify recipients |
| **Auto-actions** | Expire → Grace → Reject flow, Auto-allocate rules, Re-offer eligibility |
