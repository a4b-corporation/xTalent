# Glossary — Test Session Context

> **Scope:** Test Session context — Quản lý ca thi Onsite, auto allocate slots, check-in, và chấm thi
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **TestSlot** | Ca thi Onsite với ngày giờ, địa điểm, phòng, và max capacity. Auto gen SBD khi Student được chia vào slot. | InterviewSlot (phỏng vấn, không phải thi), Assignment (bài tập online) | "TSLOT-000001: Event EVT-000001, slot_name = 'Ca sáng 08:00-12:00', test_date = 2026-04-27, location = 'Hà Nội', room = 'Phòng 301', max_capacity = 30, current_capacity = 25, status = ACTIVE" | DRAFT, ACTIVE, IN_PROGRESS, COMPLETED, CANCELLED |
| **Schedule** | Lịch thi của Student trong Test Session, auto gen SBD khi được chia vào slot, có confirm deadline và change_count. | TestSlot (ca thi), Assignment (bài tập online) | "TSCH-000001: Slot TSLOT-000001, Application APP-000001, Candidate CRR-000001, sbd = 'SBD-20260001', status = CONFIRMED, confirmed_at = 2026-04-20 10:30, change_count = 0" | PENDING, CONFIRMED, RESCHEDULED, COMPLETED, NO_SHOW, CANCELLED |
| **CheckIn** | Record check-in cho Student trong Test Session, với actual_time, is_late flag, và optional photo capture. | Attendance (cách gọi khác), Schedule (lịch thi) | "TCI-000001: Schedule TSCH-000001, actual_time = 2026-04-27 07:45, is_late = false, photo_id = ATT-001, checked_in_by = TA-001" | ON_TIME, LATE, VERY_LATE, ABSENT |
| **Grading** | Kết quả chấm Onsite Test của Manager, bao gồm score (0-100), comment, và pass_fail decision. | GradingTask (task phân công chấm), CheckIn (record check-in) | "TGRD-000001: Schedule TSCH-000001, grader_id = MGR-001, score = 78.5, comment = 'Làm bài tốt, code sạch', pass_fail = PASS, graded_at = 2026-04-27 14:00" | — |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **TestSlotCreated** | TA tạo TestSlot mới với thông tin ca thi | TA | slotId, eventId, slotName, testDate, startTime, endTime, location, room, maxCapacity |
| **TestSlotPublished** | TA publish TestSlot (mở đăng ký) | TA | slotId, publishedAt, notificationSent |
| **ScheduleAllocated** | Hệ thống auto allocate Student vào TestSlot theo FCFS + Time Window | System (automated) | scheduleId, slotId, applicationId, candidateRrId, sbd, confirmDeadline |
| **ScheduleConfirmed** | Student confirm tham gia Test Session | Student (Candidate) | scheduleId, confirmedAt, notificationSent |
| **ScheduleRescheduled** | Student đổi lịch thi (lần thứ 1) | Student/System | scheduleId, newSlotId, changeCount, rescheduledAt |
| **CheckInRecorded** | Student check-in tại địa điểm thi | TA/Student | checkInId, scheduleId, actualTime, isLate, lateReason, photoId |
| **GradingCompleted** | Manager hoàn thành chấm Onsite Test | Manager (Grader) | gradingId, scheduleId, graderId, score, comment, passFail, gradedAt |
| **TestSlotCompleted** | TestSlot hoàn tất (tất cả Candidates đã thi và chấm xong) | System | slotId, completedAt, totalCandidates, passedCount, failedCount |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CreateTestSlot** | Yêu cầu tạo TestSlot mới với thông tin ca thi | TA | Event đã publish, TA có quyền tạo TestSlot | TestSlot created ở status DRAFT |
| **PublishTestSlot** | Yêu cầu publish TestSlot (mở đăng ký) | TA | TestSlot có đủ thông tin (ngày giờ, địa điểm, room, capacity) | TestSlot status = ACTIVE, auto-allocate bắt đầu (nếu enabled) |
| **AllocateSchedule** | Yêu cầu hệ thống auto allocate Student vào TestSlot | System | TestSlot status = ACTIVE, còn chỗ (current_capacity < max_capacity) | Schedule created với SBD, confirm_deadline |
| **ConfirmSchedule** | Yêu cầu confirm tham gia Test Session | Student | Schedule status = PENDING, chưa qua confirm_deadline | Schedule status = CONFIRMED, notified TA |
| **RescheduleTest** | Yêu cầu đổi lịch thi | Student | Schedule status = CONFIRMED, change_count < 1 | Schedule status = RESCHEDULED, change_count += 1 |
| **RecordCheckIn** | Yêu cầu ghi nhận check-in | TA/Student | Schedule status = CONFIRMED, Student đến địa điểm thi | CheckIn created với actual_time, is_late flag |
| **CompleteGrading** | Yêu cầu hoàn thành chấm Onsite Test | Manager | CheckIn status = ON_TIME/LATE, Student đã thi xong | Grading created với score, comment, pass_fail |

---

## Business Rules

- **BR-TSLOT-001**: Auto gen SBD khi Student được chia vào slot
- **BR-TSLOT-002**: Student chỉ được đổi lịch 1 lần (lần thứ 2 chỉ còn Yes/No options)
- **BR-TSLOT-003**: Auto allocate slots theo FCFS với Time Window (configurable)
- **BR-TSLOT-004**: Time Window để confirm slot (default: 24h, configurable 1-72h)
- **BR-TSLOT-005**: Notify TA khi auto-allocate thành công (configurable)
- **BR-TSLOT-006**: Photo capture khi check-in không bắt buộc (configurable)
- **BR-TSLOT-007**: Grace period cho check-in muộn (default: 15 phút)
- **BR-TSCH-001**: Chỉ Managers được phân công mới chấm được Onsite Test
- **BR-TCI-001**: Check-in muộn vẫn cho phép với lý do (trong grace period)

---

## Lifecycle States

### TestSlot Lifecycle

```
DRAFT → ACTIVE → IN_PROGRESS → COMPLETED
              ↓
           CANCELLED

Legend:
→ : transition bình thường
↓ : transition đặc biệt
Terminal states: COMPLETED, CANCELLED

Transition conditions:
- DRAFT → ACTIVE: TA publish TestSlot
- ACTIVE → IN_PROGRESS: Đến ngày giờ thi (test_date + start_time)
- IN_PROGRESS → COMPLETED: Tất cả Candidates đã thi và chấm xong
- ACTIVE/IN_PROGRESS → CANCELLED: TA hủy TestSlot (lý do đặc biệt)
```

### Schedule Lifecycle

```
PENDING → CONFIRMED → COMPLETED
    ↓           ↓
RESCHEDULED  NO_SHOW
    ↓
 CANCELLED

Terminal states: COMPLETED, NO_SHOW, CANCELLED

Transition conditions:
- PENDING → CONFIRMED: Student confirm tham gia
- PENDING → RESCHEDULED: Student đổi lịch (change_count = 1)
- CONFIRMED → COMPLETED: Student hoàn thành thi
- CONFIRMED → NO_SHOW: Student không đến (không check-in)
- RESCHEDULED → CONFIRMED: Student confirm lịch mới
- PENDING → CANCELLED: TA hủy schedule
```

### CheckIn Lifecycle

```
ON_TIME → COMPLETED
   ↓
  LATE → COMPLETED
   ↓
VERY_LATE (qua grace period, không cho thi)

Terminal states: COMPLETED, VERY_LATE
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Event Management Context | Customer/Supplier | EventPublished | TestSlotCreated | Async (event bus) |
| Application Context | Published Language | ApplicationSubmitted | — | Async (event bus) |
| Screening Context | Customer/Supplier | CandidateRRCreated | — | Async (event bus) |
| Assessment Context | Feedback | GradingCompleted (Online Test) | — | Async (event bus) |
| Test Session Context | Internal | ScheduleAllocated, CheckInRecorded | GradingCompleted | Async (event bus) |
| Interview Context | Customer/Supplier | GradingCompleted (Onsite Test Pass) | — | Async (event bus) |
| Calendar Service (external) | Open Host Service | CreateCalendarEvent | — | Sync (REST API) |
| Email Service (external) | Open Host Service | SendNotification | ScheduleConfirmed, ScheduleRescheduled | Async (command) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | SBD gen tự động để ẩn danh tính, PII không hiển thị với Graders | Data privacy review + anonymization audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | TestSlots, Schedules, Gradings lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |
| Fair Hiring | Đánh giá công bằng, không bias | Blind grading (Graders không thấy thông tin cá nhân) | Blind grading feature + bias audit |

---

## Edge Cases Checklist

| Edge Case | Xử lý | Glossary Reference |
|-----------|-------|-------------------|
| Student không confirm trong Time Window | Auto-allocate retry (max 2 lần), notify TA | BR-TSLOT-004 |
| Student đổi lịch lần 2 | Chỉ còn Yes/No options (không tự chọn slot) | BR-TSLOT-002 |
| Check-in muộn quá grace period | VERY_LATE status, không cho thi | BR-TCI-001 |
| Photo capture required nhưng Student từ chối | Configurable: cho phép thi hay reject | BR-TSLOT-006 |
| TestSlot hết chỗ | auto-allocate failed, notify TA manual assign | BR-TSLOT-003 |
| Grader không phải Manager được phân công | Reject grading attempt | BR-TSCH-001 |
| Student NO_SHOW | Status = NO_SHOW, không cho thi lại | Schedule lifecycle |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép Student đổi lịch lần 2 không? | BA | RESOLVED: Có, nhưng chỉ còn Yes/No options (không tự chọn slot) |
| 2026-03-20 | ❓ Photo capture có bắt buộc không? | Tech Lead | RESOLVED: Không, configurable per Event/TestSlot |
| 2026-03-20 | ❓ Thời gian retry auto-allocate là bao lâu? | BA | RESOLVED: Configurable, default = 24h (same as Time Window) |
