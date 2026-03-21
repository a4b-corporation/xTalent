# Glossary — Assessment Context

> **Scope:** Assessment context — Tạo Assignment, nhận Submissions, phân công GradingTasks, chấm bài và ghi nhận kết quả
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **Assignment** | Bài kiểm tra Online được TA tạo và gửi cho Students, bao gồm link làm bài, deadline, và configurable parameters (file types, max size). | OnlineTest (cách gọi khác), Exam (trang trọng hơn), Submission (bài nộp của Student) | "ASMNT-000001: Event EVT-000001, title = 'OOP Knowledge Test', link = 'https://testgorilla.com/abc123', deadline = 2026-04-25 23:59, status = ACTIVE, allowed_file_types = [PDF, DOCX]" | DRAFT, ACTIVE, CLOSED, GRADING, COMPLETED, CANCELLED |
| **Submission** | Bài nộp của Student cho Assignment, bao gồm attachments, submitted_at timestamp, và is_late flag. | Assignment (bài tập), Grading (kết quả chấm) | "SUB-000001: Assignment ASMNT-000001, Application APP-000001, Candidate CRR-000001, attachments = [ATT-001, ATT-002], submitted_at = 2026-04-24 10:30, is_late = false, status = SUBMITTED" | SUBMITTED, GRADING, GRADED, LATE, RESUBMITTED |
| **Grading** | Kết quả chấm bài Submission, bao gồm score (0-100), comment, và pass_fail decision từ Manager. | GradingTask (task phân công chấm), Submission (bài nộp) | "GRD-000001: Submission SUB-000001, grader_id = MGR-001, score = 85.5, comment = 'Good understanding of OOP principles', pass_fail = PASS, graded_at = 2026-04-26 14:00" | — |
| **GradingTask** | Task chấm bài được TA tạo và phân công cho Manager, bao gồm danh sách submissions cần chấm, deadline hoàn thành. | Grading (kết quả chấm), Assignment (bài tập) | "GTK-000001: Assignment ASMNT-000001, grader_id = MGR-001, submissions = [SUB-000001, SUB-000002, SUB-000003], status = IN_PROGRESS, deadline = 2026-04-28 17:00" | PENDING, IN_PROGRESS, COMPLETED, CANCELLED |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **AssignmentCreated** | TA tạo Assignment mới với thông tin cơ bản | TA | assignmentId, eventId, title, link, deadline, status |
| **AssignmentPublished** | TA publish Assignment (mở nộp bài) cho Students | TA | assignmentId, publishedAt, notificationSent |
| **SubmissionReceived** | Student nộp bài Assignment qua link | Student (Candidate) | submissionId, assignmentId, applicationId, candidateRrId, attachments, submittedAt, isLate |
| **GradingTaskCreated** | TA tạo GradingTask và phân công cho Manager | TA | taskId, assignmentId, graderId, submissions[], deadline |
| **GradingCompleted** | Manager hoàn thành chấm một Submission | Manager (Grader) | gradingId, submissionId, graderId, score, comment, passFail, gradedAt |
| **AssignmentClosed** | Assignment đóng (qua deadline hoặc TA manually close) | System/TA | assignmentId, closedAt, totalSubmissions, pendingGrading |
| **ResultsImported** | TA import kết quả chấm hàng loạt từ file Excel | TA | assignmentId, importedBy, importedAt, resultsCount |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CreateAssignment** | Yêu cầu tạo Assignment mới với thông tin cơ bản | TA | Event đã publish, TA có quyền tạo Assignment | Assignment created ở status DRAFT |
| **PublishAssignment** | Yêu cầu publish Assignment (mở nộp bài) | TA | Assignment có đủ thông tin (title, link, deadline) | Assignment status = ACTIVE, notification gửi Candidates |
| **SubmitAssignment** | Yêu cầu nộp bài Assignment | Student (Candidate) | Assignment status = ACTIVE, chưa qua deadline (hoặc trong grace period) | Submission created ở status SUBMITTED, is_late flag nếu qua deadline |
| **CreateGradingTask** | Yêu cầu tạo GradingTask phân công cho Manager | TA | Assignment có submissions cần chấm, Manager được chỉ định | GradingTask created ở status PENDING |
| **CompleteGrading** | Yêu cầu hoàn thành chấm một Submission | Manager | GradingTask status = IN_PROGRESS, Submission chưa được chấm | Grading created với score, comment, pass_fail |
| **ImportResults** | Yêu cầu import kết quả chấm hàng loạt từ Excel | TA | Assignment có submissions, file Excel hợp lệ | Grading records created/bulk updated, Assignment status = COMPLETED |
| **CloseAssignment** | Yêu cầu đóng Assignment | TA/System | Assignment qua deadline hoặc tất cả submissions đã chấm | Assignment status = CLOSED/COMPLETED, không nhận thêm submissions |

---

## Business Rules

- **BR-ASM-001**: Chỉ Managers được TA phân công mới chấm được Assignment
- **BR-ASM-002**: Assignment phải có link làm bài hợp lệ (Google Form, TestGorilla, etc.)
- **BR-ASM-003**: File submission phải đúng format (Word/PDF/Excel/PPT)
- **BR-ASM-004**: Submission chỉ được nộp trước deadline (configurable grace period)
- **BR-ASM-005**: Student được nộp nhiều file (không cần zip)
- **BR-GRD-001**: Score phải trong khoảng 0-100
- **BR-GRD-002**: PassFail = PASS khi score >= threshold (configurable per Event)
- **BR-GTK-001**: GradingTask auto-complete khi TA import kết quả chấm hàng loạt

---

## Lifecycle States

### Assignment Lifecycle

```
DRAFT → ACTIVE → CLOSED → GRADING → COMPLETED
              ↓
           CANCELLED

Legend:
→ : transition bình thường
↓ : transition đặc biệt
Terminal states: COMPLETED, CANCELLED

Transition conditions:
- DRAFT → ACTIVE: TA publish Assignment
- ACTIVE → CLOSED: Qua deadline hoặc TA manually close
- CLOSED → GRADING: Bắt đầu chấm bài
- GRADING → COMPLETED: Tất cả submissions đã chấm xong
- ACTIVE/CLOSED → CANCELLED: TA hủy Assignment
```

### Submission Lifecycle

```
SUBMITTED → GRADING → GRADED
     ↓
    LATE (nếu qua deadline)

Terminal states: GRADED

Transition conditions:
- SUBMITTED → GRADING: Bắt đầu chấm
- GRADING → GRADED: Chấm xong
- SUBMITTED → LATE: Nộp qua deadline (is_late = true)
```

### GradingTask Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                  ↓
               CANCELLED

Terminal states: COMPLETED, CANCELLED

Transition conditions:
- PENDING → IN_PROGRESS: Grader bắt đầu chấm
- IN_PROGRESS → COMPLETED: Tất cả submissions đã chấm xong
- IN_PROGRESS → COMPLETED (auto): TA import kết quả hàng loạt (BRS-GTK-001)
- PENDING/IN_PROGRESS → CANCELLED: TA hủy task
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Event Management Context | Customer/Supplier | EventPublished | — | Async (event bus) |
| Application Context | Published Language | ApplicationSubmitted | — | Async (event bus) |
| Screening Context | Customer/Supplier | CandidateRRCreated | — | Async (event bus) |
| Assessment Context | Internal | AssignmentCreated, SubmissionReceived | GradingCompleted | Async (event bus) |
| Test Session Context | Feedback | — | GradingCompleted (để qua vòng Onsite Test) | Async (event bus) |
| File Storage (external) | ACL | — | AttachmentUploaded | Sync (REST API) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Submissions không hiển thị PII với Graders (blind grading) | Data privacy review + anonymization audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | Assignments, Submissions, Gradings lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |
| Fair Hiring | Đánh giá công bằng, không bias | Graders không thấy thông tin cá nhân (tên, gender, university) | Blind grading feature + bias audit |

---

## Edge Cases Checklist

| Edge Case | Xử lý | Glossary Reference |
|-----------|-------|-------------------|
| Student nộp bài qua deadline | Flag is_late = true, vẫn chấp nhận nếu trong grace period | BR-ASM-004 |
| File submission sai format | Reject với error message chi tiết | BR-ASM-003 |
| Grader không phải Manager được phân công | Reject grading attempt | BR-ASM-001 |
| Score ngoài khoảng 0-100 | Validation error | BR-GRD-001 |
| Student nộp nhiều lần | Chỉ nhận submission cuối cùng (hoặc configurable) | SubmissionStatus = RESUBMITTED |
| TA import kết quả khi GradingTask đang chấm | Auto-complete task, override kết quả | BRS-GTK-001 |
| Assignment bị hủy khi đang chấm | Chuyển tất cả submissions sang CANCELLED | AssignmentStatus = CANCELLED |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép Student nộp lại bài (resubmit) không? | BA | RESOLVED: Có, nhưng chỉ 1 lần và trước deadline |
| 2026-03-20 | ❓ Grading task auto-complete khi import kết quả có override kết quả cũ không? | Tech Lead | RESOLVED: Có, kết quả import từ Excel override kết quả cũ |
| 2026-03-20 | ❓ Blind grading có bắt buộc không? | BA | RESOLVED: Configurable per Event, default = ON |
