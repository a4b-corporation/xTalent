# Application API Documentation

> **Version:** 1.0.0
> **Last Updated:** 2026-03-20
> **Bounded Context:** Application
> **Owner:** TA Operations Team + Tech Lead

---

## Overview

Application API cung cấp các endpoints để quản lý đơn ứng tuyển (Application) của Student vào Event/Track trong hệ thống ATS xTalent.

### Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/ats/v1` |
| Staging | `https://staging-api.xtalent.io/ats/v1` |
| Development | `https://dev-api.xtalent.io/ats/v1` |

### References

| Document | Link |
|----------|------|
| OpenAPI Specification | [`application-api.openapi.yaml`](./application-api.openapi.yaml) |
| Flow Document | [`7.flows/application-flow.md`](../7.flows/application-flow.md) |
| Glossary | [`6.glossary/application.md`](../6.glossary/application.md) |
| Ontology | [`5.ontology/application/`](../5.ontology/application/) |

---

## Authentication

### Bearer Token (User Requests)

```http
Authorization: Bearer <JWT_TOKEN>
```

### Internal API Key (Service-to-Service)

```http
X-Internal-API-Key: <API_KEY>
```

---

## Endpoints Summary

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/applications/submit` | Submit application | Bearer |
| `GET` | `/applications/{id}` | Get application status | Bearer |
| `PUT` | `/applications/{id}/form` | Update application form | Bearer |
| `POST` | `/applications/{id}/withdraw` | Withdraw application | Bearer |
| `POST` | `/applications/{id}/attachments` | Upload attachment | Bearer |
| `POST` | `/internal/duplicates/detect` | Trigger duplicate detection | Internal |
| `POST` | `/internal/duplicates/{id}/resolve` | Resolve duplicate | Internal |

---

## Use Cases

### 1. Submit Application

**Actor:** Student (Candidate)

**Endpoint:** `POST /applications/submit`

**Description:** Student submit đơn apply vào Event/Track.

**Business Rules:**
- **BR-APP-001:** Chỉ được apply khi Event đang active (startDate ≤ now ≤ endDate)
- **BR-APP-002:** Student chỉ được apply 1 Track/Event
- **BR-APP-003:** Student không được apply cùng 1 Event nhiều lần
- **BR-APP-005:** Application phải có đầy đủ form fields bắt buộc
- **BR-APP-006:** Attachments phải đúng format cho phép (PDF, Word, Image)
- **BR-APP-007:** File size tối đa cho attachments (default: 10MB)

**Request Example:**

```json
{
  "student_id": "STU-000001",
  "event_id": "EVT-000001",
  "track_id": "TRK-000001",
  "form_fields": [
    {
      "field_name": "expected_salary",
      "field_value": "10000000",
      "field_type": "NUMBER"
    },
    {
      "field_name": "availability",
      "field_value": "2026-06-01",
      "field_type": "DATE"
    }
  ],
  "question_answers": [
    {
      "question_id": "Q-001",
      "question_text": "Describe your OOP knowledge",
      "question_type": "LONG_TEXT",
      "answer_text": "I have 2 years of experience with OOP principles..."
    },
    {
      "question_id": "Q-002",
      "question_text": "Are you willing to relocate?",
      "question_type": "YES_NO",
      "answer_text": "YES"
    }
  ],
  "attachments": [
    {
      "file_name": "NguyenVanA_CV.pdf",
      "file_type": "PDF",
      "file_size": 2048000,
      "attachment_type": "CV",
      "file_url": "s3://xtalent-attachments/cv/APP-000001_CV.pdf"
    },
    {
      "file_name": "NguyenVanA_Transcript.pdf",
      "file_type": "PDF",
      "file_size": 1024000,
      "attachment_type": "TRANSCRIPT",
      "file_url": "s3://xtalent-attachments/transcript/APP-000001_Transcript.pdf"
    }
  ]
}
```

**Response Example (201 Created):**

```json
{
  "application_id": "APP-20260001",
  "event_id": "EVT-000001",
  "track_id": "TRK-000001",
  "student_id": "STU-000001",
  "status": "SUBMITTED",
  "submitted_at": "2026-04-15T10:30:00Z",
  "created_by": "STU-000001",
  "created_at": "2026-04-15T10:30:00Z",
  "updated_at": "2026-04-15T10:30:00Z"
}
```

**Error Responses:**

| Code | Error | Description |
|------|-------|-------------|
| 400 | `EVENT_NOT_ACTIVE` | Event đã hết hạn nhận applications |
| 409 | `ALREADY_APPLIED_TO_EVENT` | Student đã apply Event này trước đó |
| 409 | `ALREADY_APPLIED_TO_OTHER_TRACK` | Student đã apply Track khác trong Event này |
| 422 | `VALIDATION_FAILED` | Form fields thiếu hoặc attachments sai format |

**Flow Reference:** [7.flows/application-flow.md#phase-2-student-submit-application](../7.flows/application-flow.md#phase-2-student-submit-application)

---

### 2. Get Application Status

**Actor:** Student, TA

**Endpoint:** `GET /applications/{application_id}`

**Description:** Retrieve application details and current status.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `include` | array[string] | No | Additional details: `form_fields`, `question_answers`, `attachments`, `student` |

**Request Example:**

```http
GET /applications/APP-20260001?include=form_fields,question_answers,attachments,student
Authorization: Bearer <JWT_TOKEN>
```

**Response Example (200 OK):**

```json
{
  "application_id": "APP-20260001",
  "event_id": "EVT-000001",
  "track_id": "TRK-000001",
  "student_id": "STU-000001",
  "status": "SCREENING",
  "submitted_at": "2026-04-15T10:30:00Z",
  "created_by": "STU-000001",
  "created_at": "2026-04-15T10:30:00Z",
  "updated_at": "2026-04-15T11:00:00Z",
  "student": {
    "full_name": "NGUYEN VAN A",
    "email": "nguyenvana@gmail.com",
    "phone": "0901234567",
    "university": "Đại học Bách Khoa Hà Nội",
    "major": "Computer Science",
    "gpa": 3.5
  },
  "form_fields": [
    {
      "field_name": "expected_salary",
      "field_label": "Expected Salary",
      "field_type": "NUMBER",
      "field_value": "10000000",
      "is_required": true
    },
    {
      "field_name": "availability",
      "field_label": "Availability Date",
      "field_type": "DATE",
      "field_value": "2026-06-01",
      "is_required": true
    }
  ],
  "question_answers": [
    {
      "answer_id": "ANS-000001",
      "question_id": "Q-001",
      "question_text": "Describe your OOP knowledge",
      "question_type": "LONG_TEXT",
      "answer_text": "I have 2 years of experience with OOP principles..."
    }
  ],
  "attachments": [
    {
      "attachment_id": "ATT-000001",
      "file_name": "NguyenVanA_CV.pdf",
      "file_type": "PDF",
      "file_size": 2048000,
      "attachment_type": "CV",
      "upload_status": "COMPLETED",
      "file_url": "s3://xtalent-attachments/cv/APP-000001_CV.pdf"
    }
  ]
}
```

**Application Lifecycle States:**

| Status | Description |
|--------|-------------|
| `DRAFT` | Đang nháp, chưa submit |
| `SUBMITTED` | Đã submit |
| `SCREENING` | Đang screening |
| `TEST` | Đã qua vòng screening, chờ test |
| `INTERVIEW` | Đã qua vòng test, chờ interview |
| `OFFER` | Đã qua vòng interview, chờ offer |
| `ACCEPTED` | Đã accept offer |
| `REJECTED` | Bị reject |
| `WITHDRAWN` | Rút đơn (terminal state) |

**Flow Reference:** [7.flows/application-flow.md#postconditions-happy-path](../7.flows/application-flow.md#postconditions-happy-path)

---

### 3. Update Application Form

**Actor:** Student

**Endpoint:** `PUT /applications/{application_id}/form`

**Description:** Update form fields for a DRAFT application.

**Preconditions:**
- Application must be in `DRAFT` status
- Event must allow application updates (configurable per Event)

**Request Example:**

```json
{
  "form_fields": [
    {
      "field_name": "expected_salary",
      "field_value": "12000000",
      "field_type": "NUMBER"
    },
    {
      "field_name": "availability",
      "field_value": "2026-07-01",
      "field_type": "DATE"
    }
  ]
}
```

**Business Rules:**
- **BR-APP-005:** Required form fields must be filled

**Flow Reference:** [7.flows/application-flow.md#phase-1-student-dien-application-form](../7.flows/application-flow.md#phase-1-student-dien-application-form)

---

### 4. Withdraw Application

**Actor:** Student

**Endpoint:** `POST /applications/{application_id}/withdraw`

**Description:** Withdraw a submitted application.

**Preconditions:**
- Application must be in `SUBMITTED` or `SCREENING` status
- Student can only withdraw before Screening begins (configurable)

**Request Example:**

```json
{
  "reason": "Accepted another offer"
}
```

**Response Example (200 OK):**

```json
{
  "application_id": "APP-20260001",
  "event_id": "EVT-000001",
  "track_id": "TRK-000001",
  "student_id": "STU-000001",
  "status": "WITHDRAWN",
  "submitted_at": "2026-04-15T10:30:00Z",
  "updated_at": "2026-04-15T14:00:00Z"
}
```

**Postconditions:**
- Application status changed to `WITHDRAWN`
- `ApplicationWithdrawn` event published
- Application cannot be resubmitted

**Flow Reference:** [7.flows/application-flow.md#notes](../7.flows/application-flow.md#notes)

---

### 5. Upload Attachment

**Actor:** Student

**Endpoint:** `POST /applications/{application_id}/attachments`

**Description:** Upload a file attachment to an application.

**Allowed File Types:**
- PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, JPG, PNG

**File Size Limit:**
- Default: 10MB (configurable per Event)

**Request Example:**

```json
{
  "file_name": "NguyenVanA_CV.pdf",
  "file_type": "PDF",
  "file_size": 2048000,
  "attachment_type": "CV",
  "file_url": "s3://xtalent-attachments/cv/APP-000001_CV.pdf"
}
```

**Retry Policy (File Storage Upload Failure):**

| Attempt | Delay |
|---------|-------|
| 1 | 500ms |
| 2 | 2 seconds |
| 3 | 10 seconds |

**Business Rules:**
- **BR-APP-006:** Attachments phải đúng format cho phép
- **BR-APP-007:** File size tối đa cho attachments

**Flow Reference:** [7.flows/application-flow.md#phase-1-student-dien-application-form](../7.flows/application-flow.md#phase-1-student-dien-application-form)

---

### 6. Trigger Duplicate Detection (Internal)

**Actor:** System (automated)

**Endpoint:** `POST /internal/duplicates/detect`

**Description:** Internal endpoint to trigger duplicate detection after application submission.

**Authentication:** Internal API Key required

**Request Example:**

```json
{
  "application_id": "APP-20260001",
  "student_id": "STU-000001"
}
```

**Response Example - Duplicate Found:**

```json
{
  "duplicate_found": true,
  "duplicate_id": "DUP-000001",
  "match_type": "PHONE",
  "matched_applications": ["APP-20260001", "APP-20260002"]
}
```

**Response Example - No Duplicate:**

```json
{
  "duplicate_found": false,
  "duplicate_id": null,
  "match_type": null,
  "matched_applications": []
}
```

**Match Types:**

| Type | Description |
|------|-------------|
| `PHONE` | Match theo số điện thoại |
| `STUDENT_ID` | Match theo Student ID |
| `EMAIL` | Match theo email (optional, configurable) |
| `BOTH` | Match cả SĐT và Student ID |

**Business Rules:**
- **BR-APP-004:** Duplicate detection dựa trên SĐT HOẶC StudentID match

**Flow Reference:** [7.flows/application-flow.md#phase-3-duplicate-detection-auto](../7.flows/application-flow.md#phase-3-duplicate-detection-auto)

---

### 7. Resolve Duplicate (Internal)

**Actor:** TA (Talent Acquisition)

**Endpoint:** `POST /internal/duplicates/{duplicate_id}/resolve`

**Description:** Internal endpoint for TA to resolve a duplicate record.

**Authentication:** Internal API Key required

**Resolution Methods:**

| Method | Description |
|--------|-------------|
| `REMOVE` | Xóa 1 application |
| `MERGE` | Merge thông tin 2 applications |
| `NO_ACTION` | Không phải duplicate |

**Request Example:**

```json
{
  "resolution_method": "REMOVE",
  "notes": "Keep first application, remove duplicate"
}
```

**Duplicate Lifecycle:**

```
PENDING → REVIEWING → RESOLVED
                    → IGNORED
```

**Flow Reference:** [7.flows/application-flow.md#case-duplicate-detected](../7.flows/application-flow.md#case-duplicate-detected)

---

## Error Handling

### Standard Error Response

```json
{
  "error_code": "VALIDATION_FAILED",
  "message": "Vui lòng điền đầy đủ thông tin bắt buộc (marked with *)",
  "details": {
    "field_errors": [
      {
        "field": "expected_salary",
        "message": "This field is required",
        "code": "REQUIRED"
      }
    ]
  }
}
```

### Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `EVENT_NOT_ACTIVE` | 400 | Event đã hết hạn nhận applications |
| `ALREADY_APPLIED_TO_EVENT` | 409 | Student đã apply Event này trước đó |
| `ALREADY_APPLIED_TO_OTHER_TRACK` | 409 | Student đã apply Track khác trong Event này |
| `VALIDATION_FAILED` | 422 | Missing required fields or invalid format |
| `APPLICATION_NOT_FOUND` | 404 | Application not found |
| `DUPLICATE_DETECTED` | 409 | Phát hiện application trùng |
| `FILE_SIZE_EXCEEDED` | 413 | File size vượt quá giới hạn |
| `UNSUPPORTED_FILE_FORMAT` | 415 | File format không được chấp nhận |
| `ACCESS_DENIED` | 403 | Access denied |

---

## Configurable Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `allowed_attachment_types` | [PDF, DOCX, DOC, PNG, JPG, JPEG] | Array | File types được chấp nhận |
| `max_file_size_mb` | 10 | 1-50 MB | File size tối đa cho attachments |
| `max_attachments_per_application` | 5 | 1-10 | Số attachments tối đa |
| `required_form_fields` | [expected_salary, availability] | Array | Form fields bắt buộc (configurable per Event) |
| `duplicate_match_email` | false | boolean | Match duplicate theo email (default: false) |
| `allow_application_update_after_submit` | false | boolean | Cho phép update application sau khi submit |
| `confirmation_email_enabled` | true | boolean | Enable confirmation email sau khi submit |

---

## Events Published

| Event | Trigger | Payload |
|-------|---------|---------|
| `ApplicationSubmitted` | Student submit application | applicationId, studentId, eventId, trackId, submittedAt |
| `ApplicationWithdrawn` | Student withdraw application | applicationId, withdrawnAt, reason (optional) |
| `DuplicateDetected` | System auto phát hiện duplicate | applicationId1, applicationId2, matchType |

---

## Compliance Notes

| Regulation | Requirement | Implementation |
|------------|-------------|----------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân | Student entity encrypt email, phone; consent checkbox khi submit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | Applications lưu trữ tối thiểu 1 năm |

---

## Appendix: Entity Relationships

```
┌─────────────────┐
│    Student      │
│  (student_id)   │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐       1:N       ┌───────────────────┐
│   Application   │◄────────────────│   FormFieldValue  │
│ (application_id)│                 │  (field_value_id) │
└────────┬────────┘                 └───────────────────┘
         │ 1:N
         ├─────────────────┐
         ▼                 ▼
┌───────────────────┐ ┌─────────────────┐
│  QuestionAnswer   │ │    Attachment   │
│   (answer_id)     │ │ (attachment_id) │
└───────────────────┘ └─────────────────┘

┌─────────────────┐
│    Duplicate    │
│ (duplicate_id)  │
└────────┬────────┘
         │ N:N (via application_id_1, application_id_2)
         ▼
┌─────────────────┐
│   Application   │
└─────────────────┘
```

---

**Document Version:** 1.0.0
**Last Updated:** 2026-03-20
**Maintained By:** xTalent ATS Team
