# Assessment API Documentation

> **Bounded Context:** Assessment
> **Version:** 1.0.0
> **Last Updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Overview

Assessment API cung cấp các endpoints để quản lý Assessment Bounded Context — Tạo Assignment, nhận Submissions, phân công GradingTasks, chấm bài và ghi nhận kết quả.

### Context Boundaries

| Direction | Context | Integration Type | Events |
|-----------|---------|-----------------|--------|
| **Upstream** | Event Management | Customer/Supplier | EventPublished |
| **Upstream** | Application | Published Language | ApplicationSubmitted |
| **Upstream** | Screening | Customer/Supplier | CandidateRRCreated |
| **Downstream** | Test Session | Feedback | GradingCompleted |
| **Side-by-Side** | File Storage | ACL | AttachmentUploaded |

### Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/ats/v1` |
| Staging | `https://staging-api.xtalent.io/ats/v1` |
| Development | `https://dev-api.xtalent.io/ats/v1` |

### Authentication

API hỗ trợ 2 phương thức authentication:

1. **Bearer Token (JWT)** — Cho user requests
   ```
   Authorization: Bearer <jwt_token>
   ```

2. **API Key** — Cho service-to-service communication
   ```
   X-API-Key: <api_key>
   ```

---

## Use Cases & Endpoints

### 1. Create Online Test

**Endpoint:** `POST /assessments/create`

**Use Case:** TA tạo Assignment (Online Test) mới để gửi cho Students làm bài kiểm tra.

**Pre-conditions:**
- Event đã publish (EventPublished event đã xảy ra)
- TA có quyền tạo Assignment

**Post-conditions:**
- Assignment created ở status DRAFT
- AssignmentPublished event được trigger khi publish

**Business Rules:**
- BR-ASM-002: Assignment phải có link làm bài hợp lệ (Google Form, TestGorilla, etc.)
- BR-ASM-003: allowed_file_types phải chứa ít nhất [PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX]
- BR-ASM-005: multiple_files_allowed = true (default)

#### Request

```json
{
  "event_id": "EVT-000001",
  "title": "OOP Knowledge Test",
  "description": "Kiểm tra kiến thức về OOP principles",
  "link": "https://testgorilla.com/abc123",
  "deadline": "2026-04-25T23:59:00Z",
  "allowed_file_types": ["PDF", "DOCX", "PPT"],
  "max_file_size": 10485760,
  "multiple_files_allowed": true,
  "graders": ["MGR-001", "MGR-002"]
}
```

#### Response (201 Created)

```json
{
  "assignment_id": "ASMNT-000001",
  "event_id": "EVT-000001",
  "title": "OOP Knowledge Test",
  "description": "Kiểm tra kiến thức về OOP principles",
  "link": "https://testgorilla.com/abc123",
  "deadline": "2026-04-25T23:59:00Z",
  "status": "DRAFT",
  "allowed_file_types": ["PDF", "DOCX", "PPT"],
  "max_file_size": 10485760,
  "multiple_files_allowed": true,
  "graders": ["MGR-001", "MGR-002"],
  "created_by": "TA-001",
  "created_at": "2026-03-20T10:00:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | VALIDATION_ERROR | Missing link, invalid file types |
| 401 | UNAUTHORIZED | User không có quyền tạo Assignment |
| 404 | EVENT_NOT_FOUND | Event không tồn tại |
| 409 | CONFLICT | Assignment đã tồn tại cho Event này |

**Source Documents:**
- Flow: [7.flows/assessment-flow.md](../7.flows/assessment-flow.md)
- Glossary: [6.glossary/assessment.md](../6.glossary/assessment.md#commands)
- Ontology: [5.ontology/assessment/assignment.yaml](../5.ontology/assessment/assignment.yaml)

---

### 2. Submit Assignment

**Endpoint:** `POST /assessments/{assignment_id}/submit`

**Use Case:** Student nộp bài Assignment qua link (TestGorilla, Google Form, etc.) với attachments.

**Pre-conditions:**
- Assignment tồn tại với status = ACTIVE
- CandidateRR tồn tại với current_stage = ONLINE_TEST
- Assignment.deadline chưa qua (hoặc trong grace period)
- Student đã nhận được Assignment link qua email

**Post-conditions:**
- Submission tồn tại với status = SUBMITTED, is_late = false
- Attachments được lưu trong FileStorage với IDs
- GradingTask được tạo (hoặc update) với submissions[] includes mới submission
- SubmissionReceived event được publish

**Business Rules:**
- BR-ASM-003: File submission phải đúng format
- BR-ASM-004: Submission chỉ được nộp trước deadline (configurable grace period)
- BR-ASM-005: Student được nộp nhiều file (không cần zip)

#### Request

```
POST /assessments/ASMNT-000001/submit
```

```json
{
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "attachments": ["ATT-001", "ATT-002"]
}
```

#### Response (201 Created)

```json
{
  "submission_id": "SUB-000001",
  "assignment_id": "ASMNT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "attachments": ["ATT-001", "ATT-002"],
  "submitted_at": "2026-04-24T10:30:00Z",
  "is_late": false,
  "status": "SUBMITTED",
  "created_by": "STU-001",
  "created_at": "2026-04-24T10:30:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | INVALID_FILE_TYPE | File type không đúng format |
| 400 | FILE_SIZE_EXCEEDED | File size vượt quá limit (default 10MB) |
| 401 | UNAUTHORIZED | Student chưa đăng nhập |
| 403 | FORBIDDEN | Student không có quyền nộp bài này |
| 404 | ASSIGNMENT_NOT_FOUND | Assignment không tồn tại |
| 404 | CANDIDATE_RR_NOT_FOUND | Candidate RR không tồn tại |
| 409 | ASSIGNMENT_CLOSED | Assignment đã đóng |
| 409 | ALREADY_SUBMITTED | Đã submit rồi (resubmit không enabled) |
| 410 | DEADLINE_PASSED | Deadline đã qua (không trong grace period) |

#### Error Handling Scenarios

**Late Submission (trong grace period):**
- System vẫn accept submission
- Set `is_late = true`
- Status = LATE
- Hiển thị warning: "Bài nộp muộn — có thể bị penalty"

**Invalid File Type:**
- System reject upload ngay ở client-side
- Error: "File type không được chấp nhận. Chỉ chấp nhận: PDF, DOCX, PPT"
- Submission KHÔNG được tạo

**File Size Exceeded:**
- System reject upload
- Error: "File size vượt quá 10MB. Vui lòng giảm kích thước file"
- Gợi ý: Compress PDF, chia nhỏ file

**Source Documents:**
- Flow: [7.flows/assessment-flow.md](../7.flows/assessment-flow.md)
- Glossary: [6.glossary/assessment.md](../6.glossary/assessment.md#commands)
- Ontology: [5.ontology/assessment/submission.yaml](../5.ontology/assessment/submission.yaml)

---

### 3. Create Grading Task

**Endpoint:** `POST /assessments/{assignment_id}/grading-tasks/create`

**Use Case:** TA tạo GradingTask và phân công cho Manager chấm bài.

**Pre-conditions:**
- Assignment có submissions cần chấm
- Manager được chỉ định tồn tại và có quyền chấm

**Post-conditions:**
- GradingTask created ở status PENDING
- GradingTaskCreated event được publish

**Business Rules:**
- BR-ASM-001: Chỉ Managers được TA phân công mới chấm được Assignment
- BR-GTK-001: GradingTask auto-complete khi TA import kết quả chấm hàng loạt

#### Request

```
POST /assessments/ASMNT-000001/grading-tasks/create
```

```json
{
  "grader_id": "MGR-001",
  "submission_ids": ["SUB-000001", "SUB-000002", "SUB-000003"],
  "deadline": "2026-04-28T17:00:00Z"
}
```

#### Response (201 Created)

```json
{
  "task_id": "GTK-000001",
  "assignment_id": "ASMNT-000001",
  "grader_id": "MGR-001",
  "submissions": ["SUB-000001", "SUB-000002", "SUB-000003"],
  "status": "PENDING",
  "deadline": "2026-04-28T17:00:00Z",
  "created_by": "TA-001",
  "created_at": "2026-04-26T10:00:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | VALIDATION_ERROR | Không có submissions nào được chọn |
| 400 | INVALID_GRADER | Grader không phải Manager |
| 401 | UNAUTHORIZED | User không có quyền tạo GradingTask |
| 404 | ASSIGNMENT_NOT_FOUND | Assignment không tồn tại |
| 404 | GRADER_NOT_FOUND | Grader không tồn tại |
| 404 | SUBMISSION_NOT_FOUND | Submission không tồn tại |
| 409 | GRADING_TASK_EXISTS | GradingTask đã tồn tại cho grader này |

**Source Documents:**
- Flow: [7.flows/assessment-flow.md](../7.flows/assessment-flow.md)
- Glossary: [6.glossary/assessment.md](../6.glossary/assessment.md#commands)
- Ontology: [5.ontology/assessment/grading-task.yaml](../5.ontology/assessment/grading-task.yaml)

---

### 4. Score Submission

**Endpoint:** `POST /assessments/{submission_id}/grade`

**Use Case:** Manager hoàn thành chấm một Submission với score, comment và pass_fail decision.

**Pre-conditions:**
- GradingTask status = IN_PROGRESS
- Submission chưa được chấm
- Grader là Manager được phân công (BRS-GRD-001)

**Post-conditions:**
- Grading created với score, comment, pass_fail
- GradingCompleted event được publish
- Submission status = GRADED

**Business Rules:**
- BR-GRD-001: Score phải trong khoảng 0-100
- BR-GRD-002: PassFail = PASS khi score >= threshold (configurable per Event)
- BR-ASM-001: Chỉ Managers được TA phân công mới chấm được Assignment

#### Request

```
POST /assessments/SUB-000001/grade
```

```json
{
  "score": 85.5,
  "comment": "Good understanding of OOP principles",
  "pass_fail": "PASS"
}
```

#### Response (201 Created)

```json
{
  "grading_id": "GRD-000001",
  "submission_id": "SUB-000001",
  "grader_id": "MGR-001",
  "score": 85.5,
  "comment": "Good understanding of OOP principles",
  "pass_fail": "PASS",
  "graded_at": "2026-04-26T14:00:00Z",
  "created_by": "MGR-001",
  "created_at": "2026-04-26T14:00:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | VALIDATION_ERROR | Score ngoài khoảng 0-100, thiếu comment |
| 401 | UNAUTHORIZED | Grader chưa đăng nhập |
| 403 | UNAUTHORIZED_GRADER | Grader không được phân công chấm submission này |
| 404 | SUBMISSION_NOT_FOUND | Submission không tồn tại |
| 409 | ALREADY_GRADED | Submission đã được chấm rồi |
| 422 | INVALID_TASK_STATUS | GradingTask chưa ở status IN_PROGRESS |

#### Error Handling: Unauthorized Grader

**Condition:** Grader attempt complete grading nhưng không nằm trong grader_id của GradingTask

**Handling:**
- System reject grading attempt
- Hiển thị: "Bạn không được phân công chấm submission này"
- Log security event
- Notify TA nếu có attempt không authorized

**Source Documents:**
- Flow: [7.flows/assessment-flow.md](../7.flows/assessment-flow.md)
- Glossary: [6.glossary/assessment.md](../6.glossary/assessment.md#commands)
- Ontology: [5.ontology/assessment/grading.yaml](../5.ontology/assessment/grading.yaml)

---

### 5. Get Assessment Result

**Endpoint:** `GET /assessments/{submission_id}/result`

**Use Case:** Student hoặc TA xem kết quả bài nộp với score, comment, pass_fail decision.

**Pre-conditions:**
- Submission tồn tại
- Submission status = GRADED (hoặc GRADING nếu chưa chấm xong)

**Post-conditions:**
- Trả về Submission + Grading information

**Business Rules:**
- Blind grading: Khi enabled, Grading.comment không hiển thị PII
- Score visibility: Student chỉ thấy kết quả khi Assignment status = COMPLETED

#### Request

```
GET /assessments/SUB-000001/result
```

#### Response (200 OK)

**Case: Graded (PASS)**

```json
{
  "submission_id": "SUB-000001",
  "assignment_id": "ASMNT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "submitted_at": "2026-04-24T10:30:00Z",
  "is_late": false,
  "status": "GRADED",
  "grading": {
    "grading_id": "GRD-000001",
    "grader_id": "MGR-001",
    "score": 85.5,
    "comment": "Good understanding of OOP principles",
    "pass_fail": "PASS",
    "graded_at": "2026-04-26T14:00:00Z"
  }
}
```

**Case: Pending Grading**

```json
{
  "submission_id": "SUB-000003",
  "assignment_id": "ASMNT-000001",
  "application_id": "APP-000003",
  "candidate_rr_id": "CRR-000003",
  "submitted_at": "2026-04-24T12:00:00Z",
  "is_late": false,
  "status": "GRADING",
  "grading": null
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 401 | UNAUTHORIZED | User chưa đăng nhập |
| 403 | FORBIDDEN | User không có quyền xem kết quả |
| 403 | RESULT_NOT_READY | Kết quả chưa sẵn sàng |
| 404 | SUBMISSION_NOT_FOUND | Submission không tồn tại |
| 410 | ASSIGNMENT_CANCELLED | Assignment đã bị hủy |

**Source Documents:**
- Flow: [7.flows/assessment-flow.md](../7.flows/assessment-flow.md)
- Glossary: [6.glossary/assessment.md](../6.glossary/assessment.md#entities)
- Ontology: [5.ontology/assessment/submission.yaml](../5.ontology/assessment/submission.yaml), [grading.yaml](../5.ontology/assessment/grading.yaml)

---

## Data Models

### Assignment

**Ontology Source:** [5.ontology/assessment/assignment.yaml](../5.ontology/assessment/assignment.yaml)

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| assignment_id | string (ASMNT-XXXXXX) | Unique identifier | Yes |
| event_id | string (EVT-XXXXXX) | Event ID mà Assignment thuộc về | Yes |
| title | string (max 255) | Tiêu đề Assignment | Yes |
| description | string (max 2000) | Mô tả chi tiết | No |
| link | string (URI) | Link làm bài (Google Form, TestGorilla) | Yes |
| attachment_id | string (ATT-XXXXXX) | Attachment ID (nếu có) | No |
| deadline | datetime | Deadline nộp bài | Yes |
| status | enum | DRAFT, ACTIVE, CLOSED, GRADING, COMPLETED, CANCELLED | Yes |
| graders | string[] (MGR-XXX) | Danh sách Grader IDs | No |
| allowed_file_types | string[] | File types được phép (PDF, DOCX, etc.) | No |
| max_file_size | integer (bytes) | File size tối đa | No |
| multiple_files_allowed | boolean | Cho phép nộp nhiều file | No |
| created_by | string (TA-XXX) | User ID tạo Assignment | Yes |
| created_at | datetime | Timestamp tạo | Yes |
| updated_at | datetime | Timestamp cập nhật | No |

### Submission

**Ontology Source:** [5.ontology/assessment/submission.yaml](../5.ontology/assessment/submission.yaml)

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| submission_id | string (SUB-XXXXXX) | Unique identifier | Yes |
| assignment_id | string (ASMNT-XXXXXX) | Assignment ID | Yes |
| application_id | string (APP-XXXXXX) | Application ID | Yes |
| candidate_rr_id | string (CRR-XXXXXX) | Candidate RR ID | Yes |
| attachments | string[] (ATT-XXXXXX) | Danh sách attachment IDs | Yes |
| submitted_at | datetime | Thời điểm nộp | Yes |
| is_late | boolean | Nộp muộn | No |
| status | enum | SUBMITTED, GRADING, GRADED, LATE, RESUBMITTED | Yes |
| created_by | string (STU-XXX) | Student ID | Yes |
| created_at | datetime | Timestamp tạo | Yes |

### GradingTask

**Ontology Source:** [5.ontology/assessment/grading-task.yaml](../5.ontology/assessment/grading-task.yaml)

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| task_id | string (GTK-XXXXXX) | Unique identifier | Yes |
| assignment_id | string (ASMNT-XXXXXX) | Assignment ID | Yes |
| grader_id | string (MGR-XXX) | Manager ID | Yes |
| submissions | string[] (SUB-XXXXXX) | Danh sách submission IDs | Yes |
| status | enum | PENDING, IN_PROGRESS, COMPLETED, CANCELLED | Yes |
| completed_at | datetime | Thời điểm hoàn thành | No |
| deadline | datetime | Deadline chấm | No |
| created_by | string (TA-XXX) | User ID tạo task | Yes |
| created_at | datetime | Timestamp tạo | Yes |

### Grading

**Ontology Source:** [5.ontology/assessment/grading.yaml](../5.ontology/assessment/grading.yaml)

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| grading_id | string (GRD-XXXXXX) | Unique identifier | Yes |
| submission_id | string (SUB-XXXXXX) | Submission ID | Yes |
| grader_id | string (MGR-XXX) | User ID người chấm | Yes |
| score | float (0-100) | Điểm số | Yes |
| comment | string (max 2000) | Nhận xét | No |
| pass_fail | enum | PASS, FAIL, NEEDS_DISCUSSION | Yes |
| graded_at | datetime | Thời điểm chấm xong | Yes |
| created_by | string (MGR-XXX) | Grader ID | Yes |
| created_at | datetime | Timestamp tạo | Yes |

---

## Business Rules

| Rule ID | Description | Applied To |
|---------|-------------|------------|
| BR-ASM-001 | Chỉ Managers được TA phân công mới chấm được Assignment | Grading |
| BR-ASM-002 | Assignment phải có link làm bài hợp lệ (Google Form, TestGorilla, etc.) | Assignment |
| BR-ASM-003 | File submission phải đúng format (Word/PDF/Excel/PPT) | Submission |
| BR-ASM-004 | Submission chỉ được nộp trước deadline (configurable grace period) | Submission |
| BR-ASM-005 | Student được nộp nhiều file (không cần zip) | Submission |
| BR-GRD-001 | Score phải trong khoảng 0-100 | Grading |
| BR-GRD-002 | PassFail = PASS khi score >= threshold (configurable per Event) | Grading |
| BR-GTK-001 | GradingTask auto-complete khi TA import kết quả chấm hàng loạt | GradingTask |

---

## Lifecycle States

### Assignment Lifecycle

```
DRAFT → ACTIVE → CLOSED → GRADING → COMPLETED
              ↓
           CANCELLED

Terminal states: COMPLETED, CANCELLED
```

| Transition | Trigger |
|------------|---------|
| DRAFT → ACTIVE | TA publish Assignment |
| ACTIVE → CLOSED | Qua deadline hoặc TA manually close |
| CLOSED → GRADING | Bắt đầu chấm bài |
| GRADING → COMPLETED | Tất cả submissions đã chấm xong |
| ACTIVE/CLOSED → CANCELLED | TA hủy Assignment |

### Submission Lifecycle

```
SUBMITTED → GRADING → GRADED
     ↓
    LATE (nếu qua deadline)

Terminal states: GRADED
```

| Transition | Trigger |
|------------|---------|
| SUBMITTED → GRADING | Bắt đầu chấm |
| GRADING → GRADED | Chấm xong |
| SUBMITTED → LATE | Nộp qua deadline (is_late = true) |

### GradingTask Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                  ↓
               CANCELLED

Terminal states: COMPLETED, CANCELLED
```

| Transition | Trigger |
|------------|---------|
| PENDING → IN_PROGRESS | Grader bắt đầu chấm |
| IN_PROGRESS → COMPLETED | Tất cả submissions đã chấm xong |
| IN_PROGRESS → COMPLETED (auto) | TA import kết quả hàng loạt (BR-GTK-001) |
| PENDING/IN_PROGRESS → CANCELLED | TA hủy task |

---

## Compliance Notes

| Regulation | Requirement | Impact |
|------------|-------------|--------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Blind grading — Submissions không hiển thị PII với Graders |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | Assignments, Submissions, Gradings lưu trữ tối thiểu 1 năm |
| Fair Hiring | Đánh giá công bằng, không bias | Graders không thấy thông tin cá nhân (tên, gender, university) |

---

## Configurable Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| allowed_file_types | [PDF, DOCX, PPT, XLSX] | Array | File types được chấp nhận |
| max_file_size | 10MB (10485760 bytes) | 1-50MB | Maximum file size |
| multiple_files_allowed | true | boolean | Cho phép nộp nhiều files |
| grace_period_minutes | 0 | 0-1440 | Grace period sau deadline (phút) |
| max_resubmissions | 1 | 0-3 | Số lần nộp lại tối đa |
| blind_grading_enabled | true | boolean | Ẩn PII với Graders |

---

## Events Published

| Event | Trigger | Payload |
|-------|---------|---------|
| AssignmentCreated | TA tạo Assignment mới | assignmentId, eventId, title, link, deadline, status |
| AssignmentPublished | TA publish Assignment | assignmentId, publishedAt, notificationSent |
| SubmissionReceived | Student nộp bài | submissionId, assignmentId, applicationId, attachments, isLate |
| GradingTaskCreated | TA tạo GradingTask | taskId, assignmentId, graderId, submissions[], deadline |
| GradingCompleted | Manager hoàn thành chấm | gradingId, submissionId, score, passFail, gradedAt |
| AssignmentClosed | Assignment đóng | assignmentId, closedAt, totalSubmissions, pendingGrading |
| ResultsImported | TA import kết quả | assignmentId, importedBy, importedAt, resultsCount |

---

## OpenAPI Specification

Full OpenAPI 3.0 specification available at:
- [assessment-api.openapi.yaml](./assessment-api.openapi.yaml)

---

## Appendix: ID Patterns

| Entity | Pattern | Example |
|--------|---------|---------|
| Assignment | `^ASMNT-\d{6}$` | ASMNT-000001 |
| Submission | `^SUB-\d{6}$` | SUB-000001 |
| GradingTask | `^GTK-\d{6}$` | GTK-000001 |
| Grading | `^GRD-\d{6}$` | GRD-000001 |
| Event | `^EVT-\d{6}$` | EVT-000001 |
| Application | `^APP-\d{6}$` | APP-000001 |
| CandidateRR | `^CRR-\d{6}$` | CRR-000001 |
| Attachment | `^ATT-\d{6}$` | ATT-001 |
| Grader (Manager) | `^MGR-\d{3}$` | MGR-001 |
| TA | `^TA-\d{3}$` | TA-001 |
| Student | `^STU-\d{3}$` | STU-001 |
