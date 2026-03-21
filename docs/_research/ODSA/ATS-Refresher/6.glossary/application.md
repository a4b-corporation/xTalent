# Glossary — Application Context

> **Scope:** Application context — Nhận applications, validate, track selection, duplicate detection, form fields collection
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **Application** | Đơn xin việc của Student submit vào Event/Track, bao gồm thông tin cá nhân, câu trả lời questions, và attachments (CV, certificates). | Submission (bài nộp Online Test), CandidateRR (record sau khi Pass Screening) | "APP-000001: Student STU-000001 apply vào Event EVT-000001, Track TRK-000001, submitted at 2026-04-15 10:30, status SUBMITTED" | DRAFT, SUBMITTED, SCREENING, TEST, INTERVIEW, OFFER, ACCEPTED, REJECTED, WITHDRAWN |
| **Student** | Ứng viên là sinh viên tham gia tuyển dụng Fresher, có thông tin cá nhân (họ tên, email, phone, university, major, GPA). | Applicant (cách gọi khác), Candidate (sau khi Pass Screening), Employee (sau khi hire) | "STU-000001: NGUYEN VAN A, email: nguyenvana@gmail.com, phone: 0901234567, university: Đại học Bách Khoa Hà Nội, major: Computer Science, GPA: 3.5/4.0" | — |
| **Duplicate** | Record phát hiện hai hoặc nhiều applications từ cùng 1 Student (dùng nhiều accounts), match theo SĐT HOẶC StudentID. | Similar Application (không phải duplicate), Multiple Applications (cùng 1 Event) | "DUP-000001: APP-000001 và APP-000002 match theo phone number 0901234567, status PENDING review" | PENDING, REVIEWING, RESOLVED, IGNORED |
| **FormFieldValue** | Giá trị của các form fields động mà Student điền khi apply, tùy thuộc vào Event config. | QuestionAnswer (câu trả lời cho questions), Attachment (file upload) | "FV-000001: Application APP-000001, field 'expected_salary' = '10000000', field_type = NUMBER" | — |
| **QuestionAnswer** | Câu trả lời của Student cho questions trong bộ câu hỏi của Track. | FormFieldValue (giá trị form fields), Attachment (file upload) | "ANS-000001: Application APP-000001, question_id Q-001 'Describe your OOP knowledge', answer_text = 'I have 2 years experience...'" | — |
| **Attachment** | Files đính kèm mà Student upload khi submit application (CV, certificates, transcripts, portfolio). | File (cách gọi khác), Document (cách gọi khác) | "ATT-000001: Application APP-000001, file_name 'NguyenVanA_CV.pdf', file_type PDF, file_size 2048000 bytes (~2MB)" | PENDING, COMPLETED, FAILED, DELETED |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **ApplicationSubmitted** | Student submit application vào Event/Track | Student | applicationId, studentId, eventId, trackId, submittedAt |
| **DuplicateDetected** | Hệ thống auto phát hiện applications trùng theo SĐT hoặc StudentID | System (automated) | applicationId1, applicationId2, matchType (PHONE/STUDENT_ID/EMAIL/BOTH) |
| **ApplicationReviewed** | TA review application để screening | TA | applicationId, reviewedBy, reviewedAt, notes |
| **ApplicationWithdrawn** | Student rút đơn application | Student | applicationId, withdrawnAt, reason (optional) |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **SubmitApplication** | Yêu cầu submit đơn apply vào Event/Track | Student | Event đang active (startDate ≤ now ≤ endDate), Student chưa apply Event này, Form fields đầy đủ, Attachments đúng format/size | Application created ở status SUBMITTED, gửi confirmation email cho Student |
| **DetectDuplicate** | Yêu cầu hệ thống auto check duplicate applications | System | Application đã submitted | Duplicate record created nếu tìm thấy match, notify TA |
| **UpdateApplication** | Yêu cầu cập nhật thông tin application | Student | Application status = DRAFT hoặc SUBMITTED (nếu Event cho phép) | Application updated, updated_at timestamp mới |
| **WithdrawApplication** | Yêu cầu rút đơn application | Student | Application status = SUBMITTED hoặc SCREENING | Application status = WITHDRAWN, không thể submit lại |
| **ExportApplications** | Yêu cầu export danh sách applications với đầy đủ data | TA | Event có applications | Danh sách applications export ra file (Excel/CSV) |

---

## Business Rules

- **BR-APP-001**: Chỉ được apply khi Event đang active (startDate ≤ now ≤ endDate)
- **BR-APP-002**: Student chỉ được apply 1 Track/Event
- **BR-APP-003**: Student không được apply cùng 1 Event nhiều lần
- **BR-APP-004**: Duplicate detection dựa trên SĐT HOẶC StudentID match
- **BR-APP-005**: Application phải có đầy đủ form fields bắt buộc
- **BR-APP-006**: Attachments phải đúng format cho phép (PDF, Word, Image)
- **BR-APP-007**: File size tối đa cho attachments (configurable, default: 10MB)
- **BR-APP-008**: Time Window để confirm slot khi được auto-allocate (configurable, default: 24h)
- **BR-APP-009**: Số lần retry auto-allocate nếu Student không confirm (configurable, default: 2 lần)

---

## Lifecycle States

### Application Lifecycle

```
DRAFT → SUBMITTED → SCREENING → TEST → INTERVIEW → OFFER → ACCEPTED
                                ↓          ↓           ↓
                             REJECTED  REJECTED   REJECTED
                                ↓
                           WITHDRAWN (từ SUBMITTED, SCREENING, TEST, INTERVIEW)

Legend:
→ : transition bình thường
↓ : rejection ở vòng tương ứng
Terminal states: ACCEPTED, REJECTED, WITHDRAWN

Transition conditions:
- DRAFT → SUBMITTED: Student submit application
- SUBMITTED → SCREENING: TA bắt đầu screening
- SCREENING → TEST: Pass Screening
- SCREENING → REJECTED: Fail Screening
- TEST → INTERVIEW: Pass Online Test/Onsite Test
- TEST → REJECTED: Fail Test
- INTERVIEW → OFFER: Pass Interview
- INTERVIEW → REJECTED: Fail Interview
- OFFER → ACCEPTED: Student accept offer
- OFFER → REJECTED: Student reject offer hoặc expire
- SUBMITTED/SCREENING/TEST/INTERVIEW → WITHDRAWN: Student withdraw
```

### Duplicate Lifecycle

```
PENDING → REVIEWING → RESOLVED
                    → IGNORED

Terminal states: RESOLVED, IGNORED

Transition conditions:
- PENDING → REVIEWING: TA bắt đầu review duplicate
- REVIEWING → RESOLVED: TA quyết định remove/merge
- REVIEWING → IGNORED: TA quyết định không phải duplicate
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Event Management Context | Published Language | EventPublished, EventConfigUpdated | — | Async (event bus) |
| Screening Context | Customer/Supplier | — | ApplicationSubmitted, DuplicateDetected | Async (event bus) |
| Career Site (external) | ACL (Anti-Corruption Layer) | GetApplicationData | — | Sync (REST API) |
| Email Service (external) | Open Host Service | SendConfirmationEmail | — | Async (command) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Student entity phải encrypt email, phone; consent checkbox khi submit | Data privacy review + encryption audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | Applications phải lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |

---

## Edge Cases Checklist

| Edge Case |如何处理 | Glossary Reference |
|-----------|---------|-------------------|
| Guest checkout (không đăng ký) | Student phải tạo account trước khi submit | Student entity yêu cầu student_id |
| Duplicate theo email | Match theo email thay vì SĐT/StudentID | Duplicate match_type = EMAIL |
| File attachment > 10MB | Reject upload với error message | BR-APP-007 validation |
| Student submit 2 applications cùng Event | Hệ thống reject application thứ 2 | BR-APP-003 validation |
| Event hết hạn trong khi Student đang điền form | Show error "Event đã đóng nhận applications" | BR-APP-001 validation |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép Student update application sau khi submit không? | BA | RESOLVED: Có, nếu Event cho phép (configurable), nhưng không được đổi Track |
| 2026-03-20 | ❓ Guest có thể apply không hay phải đăng ký account trước? | Tech Lead | RESOLVED: Phải đăng ký account để có student_id trước khi apply |
