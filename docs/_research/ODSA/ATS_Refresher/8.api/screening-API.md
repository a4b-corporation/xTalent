# Screening API Documentation

> **Version:** 1.0.0
> **Bounded Context:** Screening
> **Owner:** TA Operations Team + Tech Lead
> **Last Updated:** 2026-03-20

---

## Overview

Screening API cung cấp các endpoints để thực hiện screening decisions (Pass/Fail) cho applications, quản lý Candidate Records (CandidateRR) trong pipeline tuyển dụng, và theo dõi failed applicants.

### Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/ats/v1` |
| Staging | `https://staging-api.xtalent.io/ats/v1` |

### Derived From

- **Glossary:** `6.glossary/screening.md`
- **Flow:** `7.flows/screening-flow.md`
- **Ontology:** `5.ontology/screening/*.yaml`

---

## Authentication

Tất cả requests yêu cầu Bearer Token (JWT):

```http
Authorization: Bearer <your-jwt-token>
```

---

## Use Cases Supported

| Use Case | Endpoint | Method |
|----------|----------|--------|
| Complete Screening | `/applications/{id}/screen` | POST |
| View Screening | `/screenings/{id}` | GET |
| Update Screening | `/screenings/{id}` | PUT |
| Shortlist Candidates | `/applications/shortlist` | POST |
| Rank Candidates | `/candidates/{id}/rank` | POST |
| View Failed Applicant | `/failed-applicants/{id}` | GET |
| Send Thank You Email | `/failed-applicants/{id}/thank-you-email` | POST |

---

## API Reference

### 1. Complete Screening

**Endpoint:** `POST /applications/{applicationId}/screen`

**Use Case:** CompleteScreening
**Actor:** TA (Talent Acquisition)

Thực hiện screening decision (Pass/Fail) cho một Application.

#### Preconditions
- Application tồn tại với status = SCREENING
- TA có quyền screening (được phân công hoặc có role TA_ADMIN/TA_MANAGER)
- Application đã qua Duplicate check
- CandidateRR chưa tồn tại cho application này

#### Request

```http
POST /applications/APP-000001/screen
Content-Type: application/json
Authorization: Bearer <token>

{
  "result": "PASS",
  "notes": "CV tốt, phù hợp yêu cầu. Ứng viên có kinh nghiệm React và Node.js",
  "decidedBy": "TA-001"
}
```

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| result | string | Yes | `PASS` hoặc `FAIL` |
| failReason | string | Conditional | Bắt buộc khi result = FAIL. Xem [Fail Reasons](#fail-reasons) |
| notes | string | No | Ghi chú của TA |
| decidedBy | string | Yes | User ID của TA thực hiện screening |

#### Fail Reasons

| Value | Description |
|-------|-------------|
| `INSUFFICIENT_SKILLS` | Kỹ năng không đạt |
| `CULTURE_MISMATCH` | Không phù hợp văn hóa |
| `EXPERIENCE_GAP` | Khoảng cách kinh nghiệm |
| `NOT_QUALIFIED` | Không đủ qualifications |
| `POOR_FIT` | Không phù hợp |
| `OTHER` | Lý do khác |

#### Response (200 OK) - Pass Case

```json
{
  "screening": {
    "screeningId": "SCR-000001",
    "applicationId": "APP-000001",
    "result": "PASS",
    "decidedBy": "TA-001",
    "decidedAt": "2026-04-20T14:30:00Z",
    "notes": "CV tốt, phù hợp yêu cầu",
    "createdAt": "2026-04-20T14:30:00Z"
  },
  "candidateRr": {
    "candidateRrId": "CRR-000001",
    "applicationId": "APP-000001",
    "studentId": "STU-000001",
    "status": "ACTIVE",
    "currentStage": "ONLINE_TEST",
    "sourceEvent": "EVT-000001",
    "screeningId": "SCR-000001",
    "createdAt": "2026-04-20T14:30:05Z"
  },
  "events": [
    {
      "eventName": "ScreeningCompleted",
      "eventId": "EVT-SCR-000001"
    },
    {
      "eventName": "CandidateRRCreated",
      "eventId": "EVT-CRR-000001"
    }
  ]
}
```

#### Response (200 OK) - Fail Case

```json
{
  "screening": {
    "screeningId": "SCR-000002",
    "applicationId": "APP-000002",
    "result": "FAIL",
    "decidedBy": "TA-001",
    "decidedAt": "2026-04-20T15:00:00Z",
    "notes": "Kỹ năng không đạt",
    "createdAt": "2026-04-20T15:00:00Z"
  },
  "failedApplicant": {
    "failedId": "FAIL-000001",
    "applicationId": "APP-000002",
    "screeningId": "SCR-000002",
    "failReason": "INSUFFICIENT_SKILLS",
    "thankYouSent": true,
    "endedAt": "2026-04-20T15:00:00Z",
    "createdAt": "2026-04-20T15:00:05Z"
  },
  "events": [
    {
      "eventName": "ScreeningCompleted",
      "eventId": "EVT-SCR-000002"
    },
    {
      "eventName": "FailedApplicantRecorded",
      "eventId": "EVT-FAIL-000001"
    }
  ]
}
```

#### Error Responses

| Status | Error Code | Description |
|--------|------------|-------------|
| 400 | `INVALID_SCREENING_RESULT` | result không phải PASS hoặc FAIL |
| 400 | `MISSING_FAIL_REASON` | Thiếu failReason khi result = FAIL |
| 403 | `SCREENING_FORBIDDEN` | TA không có quyền screening |
| 404 | `APPLICATION_NOT_FOUND` | Application không tồn tại |
| 409 | `APPLICATION_ALREADY_SCREENED` | Application đã qua vòng Screening |
| 422 | `CANDIDATE_RR_ALREADY_EXISTS` | CandidateRR đã tồn tại (duplicate) |

**403 Example:**
```json
{
  "errorCode": "SCREENING_FORBIDDEN",
  "message": "Bạn không có quyền thực hiện screening cho application này",
  "details": {
    "reason": "TA không được phân công hoặc không có role required",
    "requiredRoles": ["TA_ADMIN", "TA_MANAGER"],
    "assignedTaOnly": true
  }
}
```

**409 Example:**
```json
{
  "errorCode": "APPLICATION_ALREADY_SCREENED",
  "message": "Application đã qua vòng Screening, không thể cập nhật",
  "details": {
    "applicationId": "APP-000001",
    "currentStatus": "TEST",
    "requiredStatus": "SCREENING",
    "resolution": "Liên hệ Admin để xử lý ngoại lệ"
  }
}
```

#### Business Rules Applied

- **BR-SCR-001:** Auto tạo Candidate RR khi Screening = Pass
- **BR-SCR-002:** KHÔNG tạo Candidate RR khi Screening = Fail
- **BR-SCR-004:** Chỉ TA được phân quyền mới được thực hiện Screening

**Flow Reference:** `7.flows/screening-flow.md`

---

### 2. Get Screening Details

**Endpoint:** `GET /screenings/{screeningId}`

**Use Case:** ViewScreening
**Actor:** TA, Admin

Lấy thông tin chi tiết của một Screening record.

#### Request

```http
GET /screenings/SCR-000001
Authorization: Bearer <token>
```

#### Response (200 OK)

```json
{
  "screening": {
    "screeningId": "SCR-000001",
    "applicationId": "APP-000001",
    "result": "PASS",
    "decidedBy": "TA-001",
    "decidedAt": "2026-04-20T14:30:00Z",
    "notes": "CV tốt, phù hợp yêu cầu",
    "createdAt": "2026-04-20T14:30:00Z",
    "updatedAt": null
  },
  "candidateRr": {
    "candidateRrId": "CRR-000001",
    "applicationId": "APP-000001",
    "studentId": "STU-000001",
    "status": "ACTIVE",
    "currentStage": "ONLINE_TEST",
    "sourceEvent": "EVT-000001",
    "screeningId": "SCR-000001",
    "createdAt": "2026-04-20T14:30:05Z"
  }
}
```

---

### 3. Update Screening Result

**Endpoint:** `PUT /screenings/{screeningId}`

**Use Case:** UpdateScreening
**Actor:** TA

Cập nhật Screening result trước khi Application qua vòng sau.

#### Preconditions
- Screening tồn tại
- Application status = SCREENING (chưa qua vòng sau)
- TA có quyền update (người tạo hoặc TA_ADMIN)

#### Request

```http
PUT /screenings/SCR-000001
Content-Type: application/json
Authorization: Bearer <token>

{
  "result": "FAIL",
  "failReason": "CULTURE_MISMATCH",
  "notes": "Cập nhật: Ứng viên không phù hợp văn hóa công ty"
}
```

#### Response (200 OK)

```json
{
  "screening": {
    "screeningId": "SCR-000001",
    "applicationId": "APP-000001",
    "result": "FAIL",
    "decidedBy": "TA-001",
    "decidedAt": "2026-04-20T14:30:00Z",
    "notes": "Cập nhật: Ứng viên không phù hợp văn hóa công ty",
    "createdAt": "2026-04-20T14:30:00Z",
    "updatedAt": "2026-04-20T16:00:00Z"
  },
  "events": [
    {
      "eventName": "ScreeningUpdated",
      "eventId": "EVT-SCR-UPD-000001"
    }
  ]
}
```

#### Error Responses

| Status | Error Code | Description |
|--------|------------|-------------|
| 400 | `INVALID_SCREENING_UPDATE` | Update request không hợp lệ |
| 403 | `UPDATE_FORBIDDEN` | TA không có quyền update |
| 409 | `APPLICATION_PASSED_SCREENING` | Application đã qua vòng Screening |

#### Business Rules Applied

- **BR-SCR-003:** Screening result có thể update trước khi Application qua vòng sau

**Flow Reference:** `7.flows/screening-flow.md` - Edge Cases

---

### 4. Shortlist Multiple Applications

**Endpoint:** `POST /applications/shortlist`

**Use Case:** ShortlistCandidates
**Actor:** TA

Shortlist nhiều applications để review screening hàng loạt.

#### Request

```http
POST /applications/shortlist
Content-Type: application/json
Authorization: Bearer <token>

{
  "applicationIds": ["APP-000001", "APP-000002", "APP-000003"],
  "notes": "Shortlist cho buổi screening ngày 20/04/2026"
}
```

#### Response (200 OK)

```json
{
  "shortlistId": "SL-000001",
  "applicationIds": ["APP-000001", "APP-000002", "APP-000003"],
  "createdAt": "2026-04-20T10:00:00Z",
  "createdBy": "TA-001"
}
```

#### Error Responses

| Status | Error Code | Description |
|--------|------------|-------------|
| 400 | `INVALID_SHORTLIST` | Danh sách applications không hợp lệ |

---

### 5. Rank Candidates

**Endpoint:** `POST /candidates/{candidateRrId}/rank`

**Use Case:** RankCandidates
**Actor:** TA, Hiring Manager

Xếp hạng candidate trong pipeline tuyển dụng.

#### Request

```http
POST /candidates/CRR-000001/rank
Content-Type: application/json
Authorization: Bearer <token>

{
  "rank": 1,
  "score": 85,
  "notes": "Ứng viên xuất sắc, ưu tiên cho vòng Online Test"
}
```

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| rank | integer | Yes | Xếp hạng (1 = cao nhất) |
| score | integer | No | Score đánh giá (0-100) |
| notes | string | No | Ghi chú đánh giá |

#### Response (200 OK)

```json
{
  "candidateRrId": "CRR-000001",
  "rank": 1,
  "score": 85,
  "rankedBy": "TA-001",
  "rankedAt": "2026-04-20T15:00:00Z"
}
```

#### Error Responses

| Status | Error Code | Description |
|--------|------------|-------------|
| 404 | `CANDIDATE_RR_NOT_FOUND` | Candidate RR không tồn tại |

---

### 6. Get Failed Applicant Details

**Endpoint:** `GET /failed-applicants/{failedId}`

**Use Case:** ViewFailedApplicant
**Actor:** TA, Admin

Lấy thông tin chi tiết của một Failed Applicant record.

#### Request

```http
GET /failed-applicants/FAIL-000001
Authorization: Bearer <token>
```

#### Response (200 OK)

```json
{
  "failedApplicant": {
    "failedId": "FAIL-000001",
    "applicationId": "APP-000002",
    "screeningId": "SCR-000002",
    "failReason": "INSUFFICIENT_SKILLS",
    "thankYouSent": true,
    "endedAt": "2026-04-20T15:00:00Z",
    "createdAt": "2026-04-20T15:00:05Z"
  }
}
```

---

### 7. Send Thank You Email

**Endpoint:** `POST /failed-applicants/{failedId}/thank-you-email`

**Use Case:** SendThankYouEmail
**Actor:** System (automated) hoặc TA (manual)

Gửi Thank You email cho Failed Applicant.

#### Preconditions
- FailedApplicant tồn tại
- thank_you_sent = false

#### Request

```http
POST /failed-applicants/FAIL-000001/thank-you-email
Authorization: Bearer <token>
```

#### Response (200 OK)

```json
{
  "failedId": "FAIL-000001",
  "emailSent": true,
  "sentAt": "2026-04-20T15:05:00Z",
  "emailTemplate": "REJECTION",
  "eventId": "EVT-EMAIL-000001"
}
```

#### Error Responses

| Status | Error Code | Description |
|--------|------------|-------------|
| 409 | `EMAIL_ALREADY_SENT` | Email đã gửi trước đó |

**409 Example:**
```json
{
  "errorCode": "EMAIL_ALREADY_SENT",
  "message": "Thank You email đã được gửi cho Failed Applicant này",
  "details": {
    "failedId": "FAIL-000001",
    "previousSentAt": "2026-04-20T15:00:00Z"
  }
}
```

#### Business Rules Applied

- **BRS-FAIL-003:** Thank You Letter chỉ được gửi 1 lần per stage

---

## Data Models

### Screening

Kết quả screening decision cho Application.

| Field | Type | Description |
|-------|------|-------------|
| screeningId | string | Unique ID (Format: SCR-XXXXXX) |
| applicationId | string | Application ID được screening |
| result | enum | PASS, FAIL, PENDING |
| notes | string | Ghi chú của TA |
| decidedBy | string | User ID quyết định (TA) |
| decidedAt | datetime | Thời điểm quyết định |
| createdAt | datetime | Timestamp tạo record |
| updatedAt | datetime | Timestamp cập nhật record |

### CandidateRR

Candidate record trong ATS được tạo khi Pass Screening.

| Field | Type | Description |
|-------|------|-------------|
| candidateRrId | string | Unique ID (Format: CRR-XXXXXX) |
| applicationId | string | Application ID nguồn |
| studentId | string | Student ID của candidate |
| status | enum | ACTIVE, HIRED, REJECTED, WITHDRAWN |
| currentStage | enum | SCREENING, ONLINE_TEST, ONSITE_TEST, INTERVIEW, OFFER, HIRE |
| sourceEvent | string | Event ID mà candidate apply vào |
| screeningId | string | Screening ID nguồn |
| createdAt | datetime | Timestamp tạo record |
| updatedAt | datetime | Timestamp cập nhật record |

### FailedApplicant

Record theo dõi applications Failed.

| Field | Type | Description |
|-------|------|-------------|
| failedId | string | Unique ID (Format: FAIL-XXXXXX) |
| applicationId | string | Application ID bị fail |
| screeningId | string | Screening ID quyết định fail |
| failReason | enum | Xem [Fail Reasons](#fail-reasons) |
| thankYouSent | boolean | Đã gửi Thank You email |
| endedAt | datetime | Thời điểm kết thúc |
| createdAt | datetime | Timestamp tạo record |

---

## Events Published

Screening Context publishes các events sau:

| Event | Description | When Published |
|-------|-------------|----------------|
| ScreeningCompleted | TA hoàn thành review | Sau khi tạo Screening record |
| CandidateRRCreated | Candidate RR được tạo | Khi Screening = PASS |
| FailedApplicantRecorded | Failed Applicant được ghi nhận | Khi Screening = FAIL |
| ScreeningUpdated | Screening result được cập nhật | Sau khi update Screening |
| ThankYouEmailSent | Thank You email được gửi | Sau khi gửi email thành công |

### Event Payload Examples

**ScreeningCompleted:**
```json
{
  "eventName": "ScreeningCompleted",
  "eventId": "EVT-SCR-000001",
  "payload": {
    "screeningId": "SCR-000001",
    "applicationId": "APP-000001",
    "result": "PASS",
    "decidedBy": "TA-001",
    "decidedAt": "2026-04-20T14:30:00Z",
    "notes": "CV tốt, phù hợp yêu cầu"
  }
}
```

**CandidateRRCreated:**
```json
{
  "eventName": "CandidateRRCreated",
  "eventId": "EVT-CRR-000001",
  "payload": {
    "candidateRrId": "CRR-000001",
    "applicationId": "APP-000001",
    "studentId": "STU-000001",
    "status": "ACTIVE",
    "currentStage": "ONLINE_TEST",
    "sourceEvent": "EVT-000001",
    "screeningId": "SCR-000001"
  }
}
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published |
|---------|-----------------|-----------------|------------------|
| Application Context | Customer/Supplier | ApplicationSubmitted | ScreeningCompleted, CandidateRRCreated, FailedApplicantRecorded |
| Assessment Context | Published Language | — | CandidateRRCreated |
| Email Service | Open Host Service | SendThankYouEmail | ThankYouEmailSent |

---

## Compliance Notes

| Regulation | Requirement | Implementation |
|------------|-------------|----------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân | CandidateRR encrypt email, phone |
| Vietnam Labor Law | Lưu trữ hồ sơ | FailedApplicant lưu trữ tối thiểu 1 năm |
| Labor Law | Thông báo kết quả | Thank You email bắt buộc cho Failed Applicants |

---

## Error Handling

### Standard Error Response Format

```json
{
  "errorCode": "ERROR_CODE",
  "message": "Mô tả lỗi bằng tiếng Việt",
  "details": {
    "field": "fieldName",
    "providedValue": "invalid-value",
    "allowedValues": ["value1", "value2"]
  }
}
```

### Common Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `INVALID_SCREENING_RESULT` | 400 | result không hợp lệ |
| `MISSING_FAIL_REASON` | 400 | Thiếu failReason |
| `SCREENING_FORBIDDEN` | 403 | Không có quyền |
| `APPLICATION_NOT_FOUND` | 404 | Application không tồn tại |
| `APPLICATION_ALREADY_SCREENED` | 409 | Application đã qua vòng |
| `CANDIDATE_RR_ALREADY_EXISTS` | 422 | CandidateRR đã tồn tại |
| `EMAIL_ALREADY_SENT` | 409 | Email đã gửi |

---

## Retry Policy

### Email Service Failure

| Attempt | Delay | Action |
|---------|-------|--------|
| 1 | Immediate | Send email |
| 2 | 2 seconds | Retry |
| 3 | 2 seconds | Retry |
| Max Retries Exceeded | — | Log error, notify TA_ADMIN, continue flow |

**Note:** Email là side effect, không block flow chính.

---

## Related Documents

- **Flow:** `7.flows/screening-flow.md`
- **Glossary:** `6.glossary/screening.md`
- **Ontology:**
  - `5.ontology/screening/screening.yaml`
  - `5.ontology/screening/candidate-rr.yaml`
  - `5.ontology/screening/failed-applicant.yaml`

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-20 | Initial release |
