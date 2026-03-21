# Glossary — Interview Context

> **Scope:** Interview context — Quản lý ca phỏng vấn, invitation Interviewers, check-in, và grading đề xuất Offer/Reject
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **InterviewSlot** | Ca phỏng vấn với ngày giờ, hình thức (Online/Offline/Hybrid), interviewers, và capacity. | TestSlot (ca thi, không phải phỏng vấn), Meeting (cuộc họp) | "ISLOT-000001: Event EVT-000001, slot_name = 'Ca sáng 09:00-12:00', interview_date = 2026-05-05, format = ONLINE, link = 'https://meet.google.com/abc-defg', interviewers = [MGR-001, MGR-002], max_capacity = 10, status = ACTIVE" | DRAFT, ACTIVE, IN_PROGRESS, COMPLETED, CANCELLED |
| **InterviewSchedule** | Lịch phỏng vấn của Candidate, được auto allocate vào InterviewSlot với confirm deadline. | InterviewSlot (ca phỏng vấn), TestSchedule (lịch thi) | "ISCH-000001: Slot ISLOT-000001, Application APP-000001, Candidate CRR-000001, status = CONFIRMED, confirmed_at = 2026-04-28 10:30, change_count = 0" | PENDING, CONFIRMED, RESCHEDULED, COMPLETED, NO_SHOW, CANCELLED |
| **InterviewerInvitation** | Invitation gửi cho Interviewer để tham gia phỏng vấn, với calendar integration (optional). | MeetingInvitation (cách gọi khác), Schedule (lịch của Candidate) | "IINV-000001: Slot ISLOT-000001, interviewer_id = MGR-001, status = ACCEPTED, calendar_event_id = 'CAL-ABC123', sent_at = 2026-04-25 09:00, responded_at = 2026-04-25 14:30, response = ACCEPT" | PENDING, ACCEPTED, DECLINED, CANCELLED |
| **CheckIn** | Record check-in cho Candidate trong Interview, với actual_time, is_late flag, và optional photo. | Attendance (cách gọi khác), InterviewSchedule (lịch phỏng vấn) | "ICI-000001: Schedule ISCH-000001, actual_time = 2026-05-05 08:55, is_late = false, photo_id = ATT-001, checked_in_by = TA-001" | ON_TIME, LATE, ABSENT |
| **Grading** | Kết quả phỏng vấn từ Interviewer, bao gồm score (0-100), comment, và proposal (Offer/Reject/NeedDiscussion). | GradingTask (task phân công chấm), CheckIn (record check-in) | "IGRD-000001: Schedule ISCH-000001, interviewer_id = MGR-001, score = 88.0, comment = 'Giao tiếp tốt, kỹ thuật vững', proposal = OFFER, graded_at = 2026-05-05 11:30" | — |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **InterviewSlotCreated** | TA tạo InterviewSlot mới với thông tin ca phỏng vấn | TA | slotId, eventId, slotName, interviewDate, startTime, endTime, format, interviewers[] |
| **InterviewSlotPublished** | TA publish InterviewSlot (mở đăng ký) | TA | slotId, publishedAt, notificationSent |
| **InterviewScheduleAllocated** | Hệ thống auto allocate Candidate vào InterviewSlot theo FCFS + Time Window | System (automated) | scheduleId, slotId, applicationId, candidateRrId, confirmDeadline |
| **InterviewScheduleConfirmed** | Candidate confirm tham gia phỏng vấn | Candidate | scheduleId, confirmedAt, notificationSent |
| **InterviewScheduleRescheduled** | Candidate đổi lịch phỏng vấn (lần thứ 1) | Candidate/System | scheduleId, newSlotId, changeCount, rescheduledAt |
| **InterviewerInvitationSent** | Invitation gửi cho Interviewer | TA/System | invitationId, slotId, interviewerId, sentAt, calendarEventId |
| **InterviewerResponded** | Interviewer phản hồi invitation (Accept/Decline) | Interviewer | invitationId, response, respondedAt |
| **CheckInRecorded** | Candidate check-in tại địa điểm/phòng phỏng vấn | TA/Candidate | checkInId, scheduleId, actualTime, isLate, lateReason, photoId |
| **GradingSubmitted** | Interviewer submit kết quả phỏng vấn với proposal | Interviewer | gradingId, scheduleId, interviewerId, score, comment, proposal, gradedAt |
| **InterviewCompleted** | Interview hoàn tất (tất cả Candidates đã phỏng vấn và submit grading) | System | slotId, completedAt, totalCandidates, offerCount, rejectCount |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CreateInterviewSlot** | Yêu cầu tạo InterviewSlot mới với thông tin ca phỏng vấn | TA | Event đã publish, TA có quyền tạo InterviewSlot | InterviewSlot created ở status DRAFT |
| **PublishInterviewSlot** | Yêu cầu publish InterviewSlot (mở đăng ký) | TA | InterviewSlot có đủ thông tin (ngày giờ, format, interviewers) | InterviewSlot status = ACTIVE, auto-allocate bắt đầu (nếu enabled) |
| **AllocateInterviewSchedule** | Yêu cầu hệ thống auto allocate Candidate vào InterviewSlot | System | InterviewSlot status = ACTIVE, còn chỗ (current_capacity < max_capacity) | InterviewSchedule created với confirm_deadline |
| **ConfirmInterviewSchedule** | Yêu cầu confirm tham gia phỏng vấn | Candidate | InterviewSchedule status = PENDING, chưa qua confirm_deadline | InterviewSchedule status = CONFIRMED, notified TA |
| **RescheduleInterview** | Yêu cầu đổi lịch phỏng vấn | Candidate | InterviewSchedule status = CONFIRMED, change_count < 1 | InterviewSchedule status = RESCHEDULED, change_count += 1 |
| **SendInterviewerInvitation** | Yêu cầu gửi invitation cho Interviewer | TA/System | InterviewSlot có interviewers được phân công | InterviewerInvitation created, calendar event tạo (nếu enabled) |
| **RecordInterviewCheckIn** | Yêu cầu ghi nhận check-in | TA/Candidate | InterviewSchedule status = CONFIRMED, Candidate đến phòng phỏng vấn | CheckIn created với actual_time, is_late flag |
| **SubmitGrading** | Yêu cầu submit kết quả phỏng vấn | Interviewer | CheckIn status = ON_TIME/LATE, Candidate đã phỏng vấn xong | Grading created với score, comment, proposal |

---

## Business Rules

- **BR-ISLOT-001**: Interviewer chỉ thấy Candidates được phân công (không thấy tất cả)
- **BR-ISLOT-002**: Interviewer không được request đổi lịch (chỉ TA mới được)
- **BR-ISLOT-003**: Auto-allocate với FCFS + Time Window (configurable)
- **BR-ISLOT-004**: Time Window để confirm slot (default: 24h, configurable 1-72h)
- **BR-ISLOT-005**: Notify TA khi auto-allocate thành công (configurable)
- **BR-ISCH-001**: Candidate chỉ được đổi lịch 1 lần (lần thứ 2 chỉ còn Yes/No options)
- **BR-IINV-001**: Calendar event tự động tạo cho Interviewers (optional integration)
- **BR-ICI-001**: Check-in muộn vẫn cho phép với lý do
- **BR-IGRD-001**: Interviewer chỉ submit grading cho Candidates được phân công
- **BR-IGRD-002**: Grading có thể update trước khi TA review (configurable deadline)

---

## Lifecycle States

### InterviewSlot Lifecycle

```
DRAFT → ACTIVE → IN_PROGRESS → COMPLETED
              ↓
           CANCELLED

Legend:
→ : transition bình thường
↓ : transition đặc biệt
Terminal states: COMPLETED, CANCELLED

Transition conditions:
- DRAFT → ACTIVE: TA publish InterviewSlot
- ACTIVE → IN_PROGRESS: Đến ngày giờ phỏng vấn (interview_date + start_time)
- IN_PROGRESS → COMPLETED: Tất cả Candidates đã phỏng vấn và submit grading
- ACTIVE/IN_PROGRESS → CANCELLED: TA hủy InterviewSlot (lý do đặc biệt)
```

### InterviewSchedule Lifecycle

```
PENDING → CONFIRMED → COMPLETED
    ↓           ↓
RESCHEDULED  NO_SHOW
    ↓
 CANCELLED

Terminal states: COMPLETED, NO_SHOW, CANCELLED

Transition conditions:
- PENDING → CONFIRMED: Candidate confirm tham gia
- PENDING → RESCHEDULED: Candidate đổi lịch (change_count = 1)
- CONFIRMED → COMPLETED: Candidate hoàn thành phỏng vấn
- CONFIRMED → NO_SHOW: Candidate không đến (không check-in)
- RESCHEDULED → CONFIRMED: Candidate confirm lịch mới
- PENDING → CANCELLED: TA hủy schedule
```

### InterviewerInvitation Lifecycle

```
PENDING → ACCEPTED → INTERVIEW_COMPLETED
        → DECLINED → REPLACEMENT_SENT
        → CANCELLED

Terminal states: INTERVIEW_COMPLETED, CANCELLED

Transition conditions:
- PENDING → ACCEPTED: Interviewer accept invitation
- PENDING → DECLINED: Interviewer decline invitation
- ACCEPTED → INTERVIEW_COMPLETED: Phỏng vấn hoàn tất
- DECLINED → REPLACEMENT_SENT: TA mời Interviewer thay thế
- PENDING/ACCEPTED → CANCELLED: TA hủy invitation
```

### Grading Proposal Flow

```
SUBMITTED → TA REVIEW → OFFER → Offer Context
                      → REJECT → Failed
                      → NEED_DISCUSSION → Discussion → OFFER/REJECT
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Event Management Context | Customer/Supplier | EventPublished | InterviewSlotCreated | Async (event bus) |
| Application Context | Published Language | ApplicationSubmitted | — | Async (event bus) |
| Screening Context | Customer/Supplier | CandidateRRCreated | — | Async (event bus) |
| Test Session Context | Feedback | GradingCompleted (Onsite Test Pass) | — | Async (event bus) |
| Interview Context | Internal | InterviewScheduleAllocated, CheckInRecorded | GradingSubmitted | Async (event bus) |
| Offer Context | Customer/Supplier | GradingSubmitted (proposal = OFFER) | — | Async (event bus) |
| Calendar Service (external) | Open Host Service | CreateCalendarEvent | InterviewerInvitationSent | Sync (REST API) |
| Email Service (external) | Open Host Service | SendNotification | InterviewScheduleConfirmed, InterviewerResponded | Async (command) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | PII không hiển thị với Interviewers (blind interview nếu configurable) | Data privacy review + anonymization audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | InterviewSlots, Schedules, Gradings lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |
| Fair Hiring | Đánh giá công bằng, không bias | Structured interview questions, scoring rubric (configurable) | Interview guidelines + bias audit |

---

## Edge Cases Checklist

| Edge Case | Xử lý | Glossary Reference |
|-----------|-------|-------------------|
| Candidate không confirm trong Time Window | Auto-allocate retry (max 2 lần), notify TA | BR-ISLOT-004 |
| Candidate đổi lịch lần 2 | Chỉ còn Yes/No options (không tự chọn slot) | BR-ISCH-001 |
| Interviewer decline invitation | Auto-send invitation cho interviewer thay thế | BR-IINV-001 |
| Check-in muộn | Vẫn cho phép phỏng vấn với lý do | BR-ICI-001 |
| Interviewer không submit grading | Notify reminder, TA có thể manually update | BR-IGRD-001 |
| Grading proposal = NEED_DISCUSSION | TA tổ chức discussion meeting trước khi quyết định | Grading proposal flow |
| InterviewSlot hết chỗ | Auto-allocate failed, notify TA manual assign | BR-ISLOT-003 |
| Candidate NO_SHOW | Status = NO_SHOW, có thể cho phỏng vấn lại (configurable) | InterviewSchedule lifecycle |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép Candidate đổi lịch lần 2 không? | BA | RESOLVED: Có, nhưng chỉ còn Yes/No options (không tự chọn slot) |
| 2026-03-20 | ❓ Calendar integration có bắt buộc không? | Tech Lead | RESOLVED: Không, optional per Event/InterviewSlot |
| 2026-03-20 | ❓ Grading có thể update sau khi submit không? | BA | RESOLVED: Có, trước khi TA review (configurable deadline) |
| 2026-03-20 | ❓ Interviewer có thể xem resume của Candidate không? | BA | RESOLVED: Có, nhưng chỉ khi được phân công (BR-ISLOT-001) |
