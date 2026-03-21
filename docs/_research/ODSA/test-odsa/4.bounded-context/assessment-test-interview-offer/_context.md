# Context: Assessment

> **Context ID:** `ats.assessment`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm (Responsibilities)

- **Tạo Assignment** — TA tạo bài kiểm tra Online với thông tin, deadline, người chấm
- **Gửi Assignment** — Gửi bài test cho Students qua email
- **Nhận Submissions** — Student nộp bài làm qua link
- **Grading Management** --Manager chấm bài Assignment
- **Import Results** — TA import kết quả chấm hàng loạt
- **Task Management** — Tạo task cho Managers, auto-complete khi import

## Không Chịu Trách Nhiệm (Non-Responsibilities)

- **Tạo Event/Workflow** — Thuộc Event Management
- **Screening decisions** — Thuộc Screening context
- **Onsite Test grading** — Thuộc Test Session context
- **Gửi emails** — Thuộc Email Service

---

## Core Entities

| Entity | Definition | Key Attributes |
|--------|------------|----------------|
| **Assignment** | Bài kiểm tra Online | assignmentId, eventId, title, description, link, attachmentId, deadline, graders[], status |
| **Submission** | Bài nộp của Student | submissionId, assignmentId, applicationId, attachments[], submittedAt, status |
| **Grading** | Kết quả chấm điểm | gradingId, submissionId, graderId, score, comment, passFail, gradedAt |
| **GradingTask** | Task chấm bài cho Manager | taskId, assignmentId, graderId, submissions[], status, completedAt |

---

## Business Rules

| Rule ID | Description | Severity | Configurable? |
|---------|-------------|----------|---------------|
| **ASM-001** | Chỉ Managers được TA phân công mới chấm được Assignment | Error | No |
| **ASM-002** | Submission chỉ được nộp trước deadline | Error | No |
| **ASM-003** | File submission phải đúng format (Word/PDF/Excel/PPT) | Error | **Yes** |
| **ASM-004** | File size ≤ 10MB (default) | Warning | **Yes** |
| **ASM-005** | Student được nộp nhiều file (không cần zip) | Warning | No |
| **ASM-006** | Task auto-complete khi TA import kết quả | Warning | No |
| **ASM-007** | Email retry policy: Hybrid A+B+C+D via rules | Warning | **Yes** (rules engine) |

---

## Integration Points

| Direction | Context | Event/API | Relationship |
|-----------|---------|-----------|--------------|
| **Receives From** | Screening | `ScreeningCompleted (Pass)` | Customer/Supplier |
| **Sends To** | Test Session | `OnlineTestCompleted` | Customer/Supplier |
| **Sends To** | Email Service | `SendAssignment`, `SendReminder` | Open Host Service |

---

## Configurable Parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| **Allowed File Types** | PDF, Word, Excel, PPT | Configurable list |
| **Max File Size** | 10MB | Per file |
| **Multiple Files Allowed** | True | Không cần zip |
| **Email Retry Policy** | Hybrid (rules-based) | Xem interview P0 Hot Spots |

---

# Context: Test Session

> **Context ID:** `ats.test-session`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm

- **Tạo ca thi Onsite** — Setup slots với ngày giờ, địa điểm, phòng, capacity
- **Gửi Invitation** — Mời Students tham gia thi
- **Auto Allocate Slots** — Tự động chia Students vào ca theo rule
- **Schedule Change Management** — Xử lý đổi lịch với FCFS + Time Window
- **Check-in Management** — Ghi nhận check-in, chụp hình
- **Grading** — Manager chấm bài Onsite Test

## Không Chịu Trách Nhiệm

- **Tạo Assignment** — Thuộc Assessment context
- **Interview scheduling** — Thuộc Interview context
- **Gửi emails** — Thuộc Email Service

---

## Core Entities

| Entity | Definition | Key Attributes |
|--------|------------|----------------|
| **TestSlot** | Ca thi Onsite | slotId, eventId, description, date, startTime, endTime, location, room, maxCapacity, graders[], status |
| **Schedule** | Lịch thi của Student | scheduleId, slotId, applicationId, sbd, status, confirmedAt, confirmDeadline |
| **CheckIn** | Check-in record | checkInId, scheduleId, actualTime, photoId, checkedInBy |
| **Grading** | Kết quả chấm Onsite | gradingId, scheduleId, graderId, score, comment, passFail |

---

## Business Rules

| Rule ID | Description | Severity | Configurable? |
|---------|-------------|----------|---------------|
| **TEST-001** | Auto gen SBD khi Student được chia vào slot | Error | No |
| **TEST-002** | Auto allocate slots theo FCFS với Time Window | Warning | **Yes** (time window, retries) |
| **TEST-003** | Student chỉ được đổi lịch 1 lần | Error | No |
| **TEST-004** | Lần đổi thứ 2 chỉ còn Yes/No options | Error | No |
| **TEST-005** | Notify TA khi auto-allocate thành công | Warning | **Yes** (method) |
| **TEST-006** | Check-in muộn vẫn cho phép với lý do | Warning | No |
| **TEST-007** | Photo capture không bắt buộc | Warning | **Yes** |

---

## Integration Points

| Direction | Context | Event/API | Relationship |
|-----------|---------|-----------|--------------|
| **Receives From** | Assessment | `OnlineTestCompleted` | Customer/Supplier |
| **Sends To** | Interview | `OnsiteTestCompleted` | Customer/Supplier |
| **Sends To** | Email Service | `SendTestInvitation`, `SendScheduleReminder` | Open Host Service |

---

## Configurable Parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| **Time Window for Confirm** | 24 hours | Auto-allocate flow |
| **Max Retry for Auto-allocate** | 2 | Số lần retry |
| **Notify TA on Auto-allocate** | True | Email/in-app |
| **Photo Capture Required** | False | Optional |
| **Grace Period for Check-in Late** | 15 minutes | Allow late check-in |

---

# Context: Interview

> **Context ID:** `ats.interview`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm

- **Tạo ca Phỏng vấn** — Setup interview slots với ngày giờ, hình thức (Online/Offline),Interviewers
- **Gửi Invitation** — Mời Students và Interviewers
- **Gửi Calendar Invite** — Auto tạo Google Calendar/Outlook event cho Interviewers
- **Schedule Management** — Xử lý confirm/đổi lịch
- **Check-in Management** — Ghi nhận check-in, chụp hình
- **Grading Management** — Interviewer chấm điểm, đề xuất Offer/Reject
- **Import Results** — TA import kết quả hàng loạt

## Không Chịu Trách Nhiệm

- **Onsite Test scheduling** — Thuộc Test Session context
- **Offer creation** — Thuộc Offer context
- **Gửi emails** — Thuộc Email Service
- **Booking phòng tự động** — Manual hoặc optional integration

---

## Core Entities

| Entity | Definition | Key Attributes |
|--------|------------|----------------|
| **InterviewSlot** | Ca phỏng vấn | slotId, eventId, description, date, startTime, endTime, format (Online/Offline), location, room, link, maxCapacity, interviewers[], status |
| **InterviewSchedule** | Lịch phỏng vấn của Candidate | scheduleId, slotId, applicationId, sbd, status, confirmedAt, confirmDeadline |
| **InterviewerInvitation** | Invitation cho Interviewer | invitationId, slotId, interviewerId, calendarEventId, status |
| **CheckIn** | Check-in record | checkInId, scheduleId, actualTime, photoId, checkedInBy |
| **Grading** | Kết quả phỏng vấn | gradingId, scheduleId, interviewerId, score, comment, proposal (Offer/Reject/NeedDiscussion) |

---

## Business Rules

| Rule ID | Description | Severity | Configurable? |
|---------|-------------|----------|---------------|
| **INT-001** | Interviewer chỉ thấy Candidates được phân công | Error | No |
| **INT-002** | Interviewer không được request đổi lịch | Warning | No |
| **INT-003** | Student chỉ được đổi lịch 1 lần | Error | No |
| **INT-004** | Lần đổi thứ 2 chỉ còn Yes/No options | Error | No |
| **INT-005** | Auto-allocate với FCFS + Time Window | Warning | **Yes** |
| **INT-006** | Calendar event tự động tạo cho Interviewers | Warning | No |
| **INT-007** | Grading có thể update trước khi final review | Warning | **Yes** (deadline) |

---

## Integration Points

| Direction | Context | Event/API | Relationship |
|-----------|---------|-----------|--------------|
| **Receives From** | Test Session | `OnsiteTestCompleted` | Customer/Supplier |
| **Sends To** | Offer | `InterviewCompleted` | Customer/Supplier |
| **Sends To** | Email Service | `SendInterviewInvitation`, `InviteInterviewer` | Open Host Service |
| **Calls API** | Google Calendar/Outlook | `CreateCalendarEvent` | ACL (optional) |

---

## Configurable Parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| **Time Window for Confirm** | 24 hours | Auto-allocate flow |
| **Max Retry for Auto-allocate** | 2 | |
| **Notify TA on Auto-allocate** | True | |
| **Grading Update Deadline** | Before TA review | Configurable |
| **Calendar Integration Enabled** | False | Optional integration |

---

# Context: Offer

> **Context ID:** `ats.offer`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm

- **Tạo Offer Letter** — TA tạo thư mời với lương, phúc lợi, deadline
- **Gửi Offer** — Gửi Offer Letter cho Student qua email
- **Offer Response Handling** — Nhận Accept/Reject từ Student
- **Auto-Remind trước deadline** — Gửi remind 24h + 2h trước expiry
- **Expire Handling** — Auto-Expire sau deadline, grace period cho TA reactivate
- **Auto-Reject** — Auto Reject sau grace period nếu TA không action
- **Re-offer Management** — Tạo lại Offer (configurable次数, workflow approval)
- **Scan Candidate** — Scan documents sau khi Accept
- **Transfer to CnB** — Transfer Candidate sang hệ thống CnB

## Không Chịu Trách Nhiệm

- **Interview grading** — Thuộc Interview context
- **Gửi emails** — Thuộc Email Service
- **Quản lý Request tuyển dụng** — Thuộc hệ thống khác

---

## Core Entities

| Entity | Definition | Key Attributes |
|--------|------------|----------------|
| **Offer** | Thư mời nhận việc | offerId, applicationId, candidateRRId, requestId, salary, benefits, deadline, status, templateId |
| **OfferResponse** | Phản hồi của Student | responseId, offerId, response (Accept/Reject), responseAt, reason (if Reject) |
| **OfferReminder** | Reminder record | reminderId, offerId, reminderType (24h/2h), sentAt |
| **CandidateScan** | Scan result | scanId, candidateRRId, documents[], scannedAt, status |
| **CandidateTransfer** | Transfer record | transferId, candidateRRId, transferredAt, status, cnbReferenceId |

---

## Business Rules

| Rule ID | Description | Severity | Configurable? |
|---------|-------------|----------|---------------|
| **OFR-001** | Offer chỉ được tạo cho Candidates Pass Interview | Error | No |
| **OFR-002** | Offer phải matching với Request đã map trong Event | Error | No |
| **OFR-003** | Auto-remind 24h + 2h trước deadline | Warning | **Yes** (timing) |
| **OFR-004** | Auto-Expire khi deadline qua (không phải Reject) | Warning | No |
| **OFR-005** | Grace period cho TA reactivate/gia hạn | Warning | **Yes** (default: 24-48h) |
| **OFR-006** | Auto-Reject sau grace period nếu TA không action | Warning | **Yes** (trigger) |
| **OFR-007** | Re-offer allowed với configurable次数 | Warning | **Yes** (default: 1-2 lần) |
| **OFR-008** | Approval workflow cho Re-offer | Warning | **Yes** (workflow-based) |
| **OFR-009** | Thank You Letter chỉ gửi 1 lần per stage | Error | No |
| **OFR-010** | Offer template selectable từ library | Warning | **Yes** (customizable) |
| **OFR-011** | Student chỉ có Accept/Reject options (không Negotiate) | Error | No |

---

## Integration Points

| Direction | Context | Event/API | Relationship |
|-----------|---------|-----------|--------------|
| **Receives From** | Interview | `InterviewCompleted` | Customer/Supplier |
| **Sends To** | Event Management | `ReofferRequest` | Feedback |
| **Sends To** | Email Service | `SendOffer`, `SendOfferReminder` | Open Host Service |
| **Calls API** | CnB System | `TransferCandidate` | Anti-Corruption Layer |

---

## Configurable Parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| **Auto-remind Timing** | 24h + 2h | Before deadline |
| **Grace Period** | 24-48 hours | Before auto-reject |
| **Max Re-offers per Candidate** | 1-2 | Configurable |
| **Re-offer Approval Required** | True | Workflow-based |
| **Re-offer Cooldown Period** | 3 days | Between offers |
| **Offer Template Library** | Enabled | Customizable |
| **Notify TA on Expire** | True | Email/in-app |
| **Notify TA before Auto-Reject** | True | Email/in-app |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial context definitions for Assessment, Test Session, Interview, Offer |
