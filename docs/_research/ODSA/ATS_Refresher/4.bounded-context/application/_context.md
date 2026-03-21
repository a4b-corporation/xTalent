# Context: Application

> **Context ID:** `ats.application`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm (Responsibilities)

- **Nhận Applications** — Tiếp nhận đơn apply từ Students qua Career Site
- **Validate Application** — Kiểm tra điều kiện apply (Event active, Student chưa apply)
- **Track Selection** — Student chọn Track khi apply
- **Form Fields Collection** — Thu thập thông tin từ form động theo Event config
- **Question Answers** — Thu thập câu trả lời cho bộ câu hỏi theo Track
- **Duplicate Detection** — Tự động phát hiện ứng viên trùng (SĐT + StudentID)
- **Attachment Collection** — Nhận CV và attachments từ Student

## Không Chịu Trách Nhiệm (Non-Responsibilities)

- **Screening decisions** — Thuộc Screening context
- **Tạo Event** — Thuộc Event Management context
- **Gửi confirmation emails** — Thuộc Email Service
- **Quản lý Student profile** — Student profile thuộc hệ thống khác

---

## Core Entities

| Entity | Định Nghĩa Trong Context Này | Attributes Chính |
|--------|-----------------------------|-----------------|
| **Application** | Đơn apply của Student vào Event/Track | applicationId, eventId, trackId, studentId, status, submittedAt |
| **Student** | Thông tin Student applicant | studentId, fullName, email, phone, dateOfBirth, university, major, gpa |
| **Duplicate** | Record phát hiện ứng viên trùng | duplicateId, applicationId1, applicationId2, matchType, status, resolvedAt |
| **FormFieldValue** | Giá trị các fields động | fieldId, applicationId, fieldName, fieldValue |
| **QuestionAnswer** | Câu trả lời cho questions | answerId, applicationId, questionId, answerText |
| **Attachment** | Files đính kèm | attachmentId, applicationId, fileName, fileType, fileSize, fileUrl |

---

## Business Rules (Key Policies)

| Rule ID | Rule Description | Severity | Configurable? |
|---------|-----------------|----------|---------------|
| **APP-001** | Chỉ được apply khi Event đang active (startDate ≤ now ≤ endDate) | Error | No |
| **APP-002** | Student chỉ được apply 1 Track/Event | Error | No |
| **APP-003** | Student không được apply cùng 1 Event nhiều lần | Error | No |
| **APP-004** | Duplicate detection dựa trên SĐT HOẶC StudentID match | Warning | No |
| **APP-005** | Application phải có đầy đủ form fields bắt buộc | Error | No |
| **APP-006** | Attachments phải đúng format cho phép (PDF, Word, Image) | Error | No |
| **APP-007** | File size tối đa cho attachments | Warning | **Yes** (default: 10MB) |
| **APP-008** | Time Window để confirm slot khi được auto-allocate | Warning | **Yes** (default: 24h) |
| **APP-009** | Số lần retry auto-allocate nếu Student không confirm | Warning | **Yes** (default: 2 lần) |

---

## Ubiquitous Language (Key Terms)

| Term | Definition | Synonyms | Anti-Synonyms |
|------|------------|----------|---------------|
| **Application** | Đơn xin việc của Student submit vào Event | Application Form, Submission | Resume, CV |
| **Track** | Chuyên ngành/vị trí mà Student apply trong Event | Stream, Specialization | Job Title, Position |
| **Duplicate** | Hai hoặc nhiều applications từ cùng 1 Student (dùng nhiều accounts) | Duplicate Application, Multi-application | Similar Application |
| **Student** | Ứng viên là sinh viên tham gia tuyển dụng Fresher | Applicant, Candidate, Fresher | Employee, Intern |
| **Active Event** | Event đang trong thời gian nhận applications | Running Event, Open Event | Draft Event, Published Event |

---

## Team Owner

| Role | Name/Team |
|------|-----------|
| **Team** | TA Operations (Talent Acquisition) |
| **Tech Lead** | TBD |
| **Product Owner** | TA Director |
| **Stakeholders** | BA Team, IT Integration Team, Career Site Team |

---

## Integration Points

| Direction | Context | Event/API | Data | Relationship Type |
|-----------|---------|-----------|------|-------------------|
| **Receives From** | Event Management | `EventPublished` | eventId, tracks[], applicationWindow | Published Language |
| **Receives From** | Event Management | `EventConfigUpdated` | eventId, fields[], questions[] | Published Language |
| **Sends To** | Screening | `ApplicationSubmitted` | applicationId, studentId, track, answers[] | Customer/Supplier |
| **Sends To** | Screening | `DuplicateDetected` | applicationId1, applicationId2, matchType | Customer/Supplier |
| **Calls API** | Career Site (external) | `GetApplicationData` | Career Site form data | ACL |
| **Sends To** | Email Service | `SendConfirmationEmail` | applicationId, studentEmail, templateId | Open Host Service |

---

## Context-Specific Flows

### Flow APP-F01: Student Apply vào Event

```
1. Student truy cập Career Site, mở Event page
2. Student chọn Track (bắt buộc)
3. Hệ thống hiển thị form fields + questions theo Track đã chọn
4. Student điền thông tin và upload attachments (CV, etc.)
5. Hệ thống validate:
   - Event đang active
   - Student chưa apply Event này
   - Form fields đầy đủ
   - Attachments đúng format/size
6. Student submit application
7. Hệ thống tạo Application record với status = "Submitted"
8. Hệ thống gửi confirmation email cho Student
9. Hệ thống gửi `ApplicationSubmitted` event cho Screening context
```

### Flow APP-F02: Duplicate Detection

```
1. Student submit application
2. Hệ thống auto check duplicate:
   - Search applications cùng Event
   - Match theo SĐT OR StudentID
3. Nếu match tìm thấy:
   - Tạo Duplicate record
   - Highlight applications trong danh sách
   - Notify TA (in-app/email)
4. TA review duplicate:
   - Option 1: Remove (xóa 1 application)
   - Option 2: Replace Data (merge thông tin)
   - Option 3: No Action (không phải duplicate)
5. Hệ thống cập nhật Duplicate status
```

### Flow APP-F03: Auto-allocate Slot (từ Interview/Event Storming)

```
1. Slot trống xuất hiện (do有人hủy)
2. Hệ thống check hàng chờ (First-Come-First-Served)
3. Lấy Student đầu tiên trong hàng chờ
4. Gửi email mời slot với time window confirm (configurable, default: 24h)
5. Nếu Student confirm → allocate slot
6. Nếu Student không confirm → retry (configurable, default: 2 lần)
7. Nếu hết retry → move sang Student tiếp theo
8. Notify TA khi auto-allocate thành công
```

---

## Out of Scope

- **Screening applications** — Thuộc Screening context
- **Gửi emails** — Thuộc Email Service
- **Quản lý Event** — Thuộc Event Management context
- **Student profile management** — Thuộc hệ thống khác

---

## Configurable Parameters

| Parameter | Default | Range | Notes |
|-----------|---------|-------|-------|
| **Max Attachment Size** | 10MB | 1-50MB | Per file |
| **Allowed File Types** | PDF, Word, Image | Configurable list | |
| **Time Window for Slot Confirm** | 24 hours | 1-72 hours | Auto-allocate flow |
| **Max Retry for Auto-allocate** | 2 | 0-5 | Số lần retry nếu Student không confirm |
| **Notify TA on Auto-allocate** | True | Boolean | Email/in-app notification |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial context definition |
