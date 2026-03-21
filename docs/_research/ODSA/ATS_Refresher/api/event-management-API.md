# Event Management API Documentation

> **Version:** 1.0.0
> **Last Updated:** 2026-03-20
> **Bounded Context:** Event Management (ATS)

---

## Overview

API cho **Event Management Bounded Context** — quản lý tạo và config Event Fresher, mapping Request, workflow setup, và publish lên Career Site.

### Responsibilities

- Tạo và quản lý Event Fresher
- Map Request tuyển dụng vào Event
- Cấu hình Tracks và QuestionSets
- Configure Workflow các vòng tuyển dụng
- Publish Event lên Career Site

### Source Documents

| Document | Path |
|----------|------|
| Glossary | `6.glossary/event-management.md` |
| Use Case Flows | `7.flows/event-management-flow.md` |
| Ontology (LinkML) | `5.ontology/event-management/*.yaml` |

---

## Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/ats/v1` |
| Staging | `https://staging-api.xtalent.io/ats/v1` |
| Local Development | `http://localhost:8080/ats/v1` |

---

## Authentication

> TODO: Add authentication scheme (OAuth 2.0 / JWT)

---

## Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/events/create` | Tạo Event Fresher mới |
| POST | `/events/{id}/map-request` | Map Request vào Event |
| POST | `/events/{id}/add-track` | Thêm Track vào Event |
| POST | `/events/{id}/configure-workflow` | Cấu hình Workflow |
| POST | `/events/{id}/publish` | Publish Event lên Career Site |
| GET | `/events/{id}` | Lấy thông tin Event chi tiết |

---

## Detailed API Reference

### 1. Create Event

**Endpoint:** `POST /events/create`

**Description:** Tạo Event Fresher mới từ dashboard.

**Flow Reference:** `7.flows/event-management-flow.md` — Phase 1: Create Event

#### Preconditions

- TA có quyền tạo Event (TA_ADMIN/TA_MANAGER role)
- Program type = "Fresher" (chỉ Fresher events được tạo trong system này)

#### Business Rules

- **BR-EM-001:** program_type phải là "FRESHER"

#### Request

```json
{
  "name": "Fresher Journey 2026 - Hanoi",
  "description": "Tuyển dụng Fresher cho các vị trí Game Development, Game Design, Game QC",
  "program_type": "FRESHER",
  "start_date": "2026-04-01",
  "end_date": "2026-04-30",
  "application_start_date": "2026-04-01T00:00:00Z",
  "application_end_date": "2026-04-30T23:59:59Z"
}
```

#### Response (201 Created)

```json
{
  "event_id": "EVT-20260001",
  "name": "Fresher Journey 2026 - Hanoi",
  "description": "Tuyển dụng Fresher cho các vị trí Game Development, Game Design, Game QC",
  "program_type": "FRESHER",
  "start_date": "2026-04-01",
  "end_date": "2026-04-30",
  "application_start_date": "2026-04-01T00:00:00Z",
  "application_end_date": "2026-04-30T23:59:59Z",
  "status": "DRAFT",
  "created_by": "ta_user_001",
  "created_at": "2026-03-20T10:30:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | INVALID_PROGRAM_TYPE | program_type != "FRESHER" |
| 400 | INVALID_DATE_RANGE | start_date >= end_date |
| 403 | FORBIDDEN | User không có quyền tạo Event |

#### Error Example (400)

```json
{
  "error_code": "INVALID_PROGRAM_TYPE",
  "message": "Chỉ Event thuộc Program 'Fresher' mới được tạo trong system này",
  "field": "program_type",
  "provided_value": "EXPERIENCED",
  "suggestion": "Vui lòng chọn Program type = Fresher"
}
```

---

### 2. Map Request to Event

**Endpoint:** `POST /events/{id}/map-request`

**Description:** Map Request tuyển dụng vào Event.

**Flow Reference:** `7.flows/event-management-flow.md` — Phase 2: Map Request

#### Preconditions

- Event status = DRAFT
- Request type = "FRESHER"
- Request status = "APPROVED"
- Request chưa được map Event khác

#### Business Rules

- **BR-EM-002:** Chỉ Request type "Fresher" và status "Approved" mới được map
- **BR-EM-004:** Một Request chỉ được map 1 Event duy nhất
- **BR-EM-006:** Không được add mapping Request sau khi Event đã publish

#### Request

```http
POST /events/EVT-20260001/map-request
Content-Type: application/json

{
  "request_id": "REQ-2026-001"
}
```

#### Response (201 Created)

```json
{
  "mapping_id": "MAP-000001",
  "event_id": "EVT-20260001",
  "request_id": "REQ-2026-001",
  "request_type": "FRESHER",
  "position_title": "Fresher Game Developer",
  "department": "Game Development",
  "hiring_manager": "hm_001",
  "headcount": 5,
  "status": "ACTIVE",
  "mapped_at": "2026-03-20T10:35:00Z",
  "created_by": "ta_user_001",
  "created_at": "2026-03-20T10:35:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | INVALID_REQUEST_TYPE | Request type != "FRESHER" |
| 400 | INVALID_REQUEST_STATUS | Request status != "APPROVED" |
| 400 | REQUEST_ALREADY_MAPPED | Request đã map Event khác |
| 403 | FORBIDDEN | Event đã publish (BR-EM-006) |
| 404 | EVENT_NOT_FOUND | Event không tồn tại |

#### Error Example (400)

```json
{
  "error_code": "REQUEST_ALREADY_MAPPED",
  "message": "Request đã được map vào Event [EVT-20250015]",
  "field": "request_id",
  "provided_value": "REQ-2026-001",
  "context": {
    "mapped_event_id": "EVT-20250015"
  }
}
```

---

### 3. Add Track to Event

**Endpoint:** `POST /events/{id}/add-track`

**Description:** Thêm Track chuyên ngành vào Event.

**Flow Reference:** `7.flows/event-management-flow.md` — Phase 3: Add Track & Configure QuestionSets

#### Preconditions

- Event status = DRAFT

#### Business Rules

- **BRS-EM-TRK-001:** Track phải thuộc về 1 Event
- **BRS-EM-TRK-002:** Không được xóa Track đã có applications

#### Configurable Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `min_tracks` | 1 | Số Track tối thiểu trước khi publish |

#### Request

```http
POST /events/EVT-20260001/add-track
Content-Type: application/json

{
  "track_name": "Game Development",
  "description": "Track dành cho ứng viên có kinh nghiệm lập trình C++/C#, portfolio game dự án",
  "question_set_id": "QST-000001"
}
```

#### Response (201 Created)

```json
{
  "track_id": "TRK-000001",
  "event_id": "EVT-20260001",
  "track_name": "Game Development",
  "description": "Track dành cho ứng viên có kinh nghiệm lập trình C++/C#, portfolio game dự án",
  "question_set_id": "QST-000001",
  "status": "ACTIVE",
  "created_by": "ta_user_001",
  "created_at": "2026-03-20T10:40:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | MISSING_REQUIRED_FIELDS | Thiếu track_name hoặc description |
| 400 | INVALID_QUESTION_SET | QuestionSet không tồn tại hoặc không có câu hỏi |
| 404 | EVENT_NOT_FOUND | Event không tồn tại |

---

### 4. Configure Workflow for Event

**Endpoint:** `POST /events/{id}/configure-workflow`

**Description:** Thiết lập workflow các vòng tuyển dụng cho Event.

**Flow Reference:** `7.flows/event-management-flow.md` — Phase 4: Configure Workflow

#### Preconditions

- Event status = DRAFT

#### Required Rounds

| Round | Required | Description |
|-------|----------|-------------|
| SCREENING | Yes | Vòng screening applications |
| ONLINE_TEST / ONSITE_TEST | At least 1 | Vòng kiểm tra năng lực |
| INTERVIEW | Yes | Vòng phỏng vấn |
| OFFER | Yes | Vòng offer |

#### Business Rules

- **BR-EM-007:** Workflow phải có ít nhất 1 vòng đánh giá (Test hoặc Interview)
- **BRS-EM-WFL-001:** Workflow phải có ít nhất 1 vòng đánh giá
- **BRS-EM-WFL-002:** Vòng skipped phải tồn tại trong rounds

#### Configurable Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `min_workflow_rounds` | 1 | Số vòng đánh giá tối thiểu |

#### Request (Full Workflow)

```http
POST /events/EVT-20260001/configure-workflow
Content-Type: application/json

{
  "workflow_name": "Fresher Standard Workflow",
  "rounds": [
    "SCREENING",
    "ONLINE_TEST",
    "INTERVIEW",
    "OFFER"
  ],
  "skipped_rounds": []
}
```

#### Request (Workflow with Skips)

```json
{
  "workflow_name": "Fresher Fast-Track Workflow",
  "rounds": [
    "SCREENING",
    "ONLINE_TEST",
    "ONSITE_TEST",
    "INTERVIEW",
    "OFFER"
  ],
  "skipped_rounds": [
    "ONLINE_TEST"
  ]
}
```

#### Response (201 Created)

```json
{
  "workflow_id": "WFL-000001",
  "event_id": "EVT-20260001",
  "workflow_name": "Fresher Standard Workflow",
  "rounds": [
    "SCREENING",
    "ONLINE_TEST",
    "INTERVIEW",
    "OFFER"
  ],
  "skipped_rounds": [],
  "status": "ACTIVE",
  "created_by": "ta_user_001",
  "created_at": "2026-03-20T10:45:00Z"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | NO_EVALUATION_ROUNDS | Workflow không có vòng Test/Interview |
| 400 | INVALID_SKIPPED_ROUND | Vòng skipped không tồn tại trong rounds |
| 400 | MISSING_REQUIRED_ROUND | Thiếu vòng bắt buộc (SCREENING) |
| 404 | EVENT_NOT_FOUND | Event không tồn tại |

#### Error Example (400)

```json
{
  "error_code": "NO_EVALUATION_ROUNDS",
  "message": "Workflow phải có ít nhất 1 vòng đánh giá (Test hoặc Interview)",
  "field": "rounds",
  "provided_value": ["SCREENING", "OFFER"],
  "suggestion": "Vui lòng configure workflow với Screening + Online Test/Onsite Test + Interview"
}
```

---

### 5. Publish Event

**Endpoint:** `POST /events/{id}/publish`

**Description:** Publish Event lên Career Site.

**Flow Reference:** `7.flows/event-management-flow.md` — Phase 5: Publish Event

#### Preconditions

- Event status = DRAFT
- Event có ít nhất 1 Track
- Event có ít nhất 1 Request mapped
- Workflow hợp lệ (≥1 vòng đánh giá)

#### Validation Before Publish

| Check | Requirement |
|-------|-------------|
| tracks count | ≥ 1 |
| request_mappings count | ≥ 1 |
| workflow evaluation rounds | ≥ 1 (Test hoặc Interview) |

#### Postconditions

- Event.status = PUBLISHED
- Event được hiển thị trên Career Site
- application_window mở (nếu start_date ≤ now)
- Event `EventPublished` được publish

#### Business Rules

- **BR-EM-006:** Không được add mapping Request sau khi Event đã publish

#### Configurable Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `min_tracks` | 1 | Số Track tối thiểu |
| `min_request_mappings` | 1 | Số Request mapping tối thiểu |
| `min_workflow_rounds` | 1 | Số vòng đánh giá tối thiểu |
| `career_site_timeout_seconds` | 5 | Timeout cho Career Site API |
| `career_site_retry_attempts` | 3 | Số lần retry |

#### Integration Points

| Context | Type | Sync/Async |
|---------|------|------------|
| Career Site (external) | PublishEvent | Sync REST API |
| Application Context | EventPublished | Async event bus |

#### Response (200 OK)

```json
{
  "event_id": "EVT-20260001",
  "status": "PUBLISHED",
  "published_at": "2026-03-20T11:00:00Z",
  "application_window": {
    "start": "2026-04-01T00:00:00Z",
    "end": "2026-04-30T23:59:59Z"
  },
  "career_site_url": "https://career.xtalent.io/events/EVT-20260001",
  "tracks_count": 3,
  "request_mappings_count": 2
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | NO_TRACKS | Event chưa có Track nào |
| 400 | NO_REQUEST_MAPPINGS | Event chưa map Request nào |
| 400 | INVALID_WORKFLOW | Workflow không hợp lệ |
| 404 | EVENT_NOT_FOUND | Event không tồn tại |
| 409 | EVENT_ALREADY_PUBLISHED | Event đã publish trước đó |
| 504 | CAREER_SITE_TIMEOUT | Career Site API timeout |

#### Error Example (400)

```json
{
  "error_code": "NO_TRACKS",
  "message": "Event phải có ít nhất 1 Track trước khi publish",
  "field": "tracks",
  "provided_value": 0,
  "suggestion": "Vui lòng add Track với thông tin chi tiết"
}
```

#### Retry Policy (Career Site Timeout)

| Attempt | Delay |
|---------|-------|
| 1 | 500ms |
| 2 | 2 seconds |
| 3 | 10 seconds |

Sau max retries vẫn failure:
- Event.status vẫn = DRAFT
- Notify TA để retry manual
- Log error cho Career Site API endpoint

---

### 6. Get Event Details

**Endpoint:** `GET /events/{id}`

**Description:** Lấy thông tin chi tiết Event bao gồm:
- Event cơ bản
- Tracks (với QuestionSets)
- RequestMappings
- Workflow configuration

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| include | array | Fields to include: `tracks`, `request_mappings`, `workflow`, `all` |

#### Request

```http
GET /events/EVT-20260001?include=tracks,request_mappings,workflow
```

#### Response (200 OK)

```json
{
  "event": {
    "event_id": "EVT-20260001",
    "name": "Fresher Journey 2026 - Hanoi",
    "description": "Tuyển dụng Fresher cho các vị trí Game Development, Game Design, Game QC",
    "program_type": "FRESHER",
    "start_date": "2026-04-01",
    "end_date": "2026-04-30",
    "application_start_date": "2026-04-01T00:00:00Z",
    "application_end_date": "2026-04-30T23:59:59Z",
    "status": "PUBLISHED",
    "published_at": "2026-03-20T11:00:00Z",
    "created_by": "ta_user_001",
    "created_at": "2026-03-20T10:30:00Z"
  },
  "tracks": [
    {
      "track_id": "TRK-000001",
      "track_name": "Game Development",
      "description": "Track dành cho ứng viên có kinh nghiệm lập trình C++/C#",
      "question_set_id": "QST-000001",
      "status": "ACTIVE"
    },
    {
      "track_id": "TRK-000002",
      "track_name": "Game Design",
      "description": "Track dành cho ứng viên có tư duy thẩm mỹ, creativity",
      "question_set_id": "QST-000002",
      "status": "ACTIVE"
    },
    {
      "track_id": "TRK-000003",
      "track_name": "Game QC",
      "description": "Track dành cho ứng viên có tư duy logic, attention to detail",
      "question_set_id": "QST-000003",
      "status": "ACTIVE"
    }
  ],
  "request_mappings": [
    {
      "mapping_id": "MAP-000001",
      "request_id": "REQ-2026-001",
      "request_type": "FRESHER",
      "position_title": "Fresher Game Developer",
      "department": "Game Development",
      "headcount": 5,
      "status": "ACTIVE"
    },
    {
      "mapping_id": "MAP-000002",
      "request_id": "REQ-2026-002",
      "request_type": "FRESHER",
      "position_title": "Fresher Game Designer",
      "department": "Game Design",
      "headcount": 3,
      "status": "ACTIVE"
    }
  ],
  "workflow": {
    "workflow_id": "WFL-000001",
    "workflow_name": "Fresher Standard Workflow",
    "rounds": [
      "SCREENING",
      "ONLINE_TEST",
      "INTERVIEW",
      "OFFER"
    ],
    "skipped_rounds": [],
    "status": "ACTIVE"
  }
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 404 | EVENT_NOT_FOUND | Event không tồn tại |

---

## Data Models

### Entity Schemas (from LinkML Ontology)

#### Event

Source: `5.ontology/event-management/event.yaml`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event_id | string (EVT-\\d{6}) | Yes | Unique identifier |
| name | string | Yes | Tên Event |
| description | string | No | Mô tả chi tiết |
| program_type | ProgramTypeEnum | Yes | Loại chương trình |
| start_date | date | Yes | Ngày bắt đầu |
| end_date | date | Yes | Ngày kết thúc |
| application_start_date | datetime | Yes | Start nhận applications |
| application_end_date | datetime | Yes | End nhận applications |
| status | EventStatusEnum | Yes | Lifecycle status |
| published_at | datetime | No | Thời điểm publish |
| created_by | string (user_id) | Yes | User tạo Event |
| created_at | datetime | Yes | Timestamp tạo |
| updated_at | datetime | No | Timestamp cập nhật |
| workflow_id | string (WFL-\\d{6}) | No | Workflow reference |

#### Track

Source: `5.ontology/event-management/track.yaml`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| track_id | string (TRK-\\d{6}) | Yes | Unique identifier |
| event_id | string (EVT-\\d{6}) | Yes | Event reference |
| track_name | string | Yes | Tên Track |
| description | string | No | Mô tả Track |
| question_set_id | string (QST-\\d{6}) | No | QuestionSet reference |
| status | TrackStatusEnum | Yes | Status |
| created_by | string (user_id) | Yes | User tạo Track |
| created_at | datetime | Yes | Timestamp tạo |
| updated_at | datetime | No | Timestamp cập nhật |

#### RequestMapping

Source: `5.ontology/event-management/request-mapping.yaml`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| mapping_id | string (MAP-\\d{6}) | Yes | Unique identifier |
| event_id | string (EVT-\\d{6}) | Yes | Event reference |
| request_id | string | Yes | External Request ID |
| request_type | RequestTypeEnum | Yes | Loại Request |
| position_title | string | Yes | Tên vị trí |
| department | string | No | Phòng ban |
| hiring_manager | string (user_id) | No | Hiring Manager |
| headcount | integer (≥1) | Yes | Số lượng tuyển |
| status | RequestMappingStatusEnum | Yes | Status |
| mapped_at | datetime | Yes | Thời điểm map |
| created_by | string (user_id) | Yes | User tạo mapping |
| created_at | datetime | Yes | Timestamp tạo |

#### Workflow

Source: `5.ontology/event-management/workflow.yaml`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| workflow_id | string (WFL-\\d{6}) | Yes | Unique identifier |
| event_id | string (EVT-\\d{6}) | Yes | Event reference |
| workflow_name | string | Yes | Tên Workflow |
| rounds | WorkflowRound[] | Yes | Danh sách vòng |
| skipped_rounds | WorkflowRound[] | No | Vòng skip |
| status | WorkflowStatusEnum | Yes | Status |
| created_by | string (user_id) | Yes | User tạo Workflow |
| created_at | datetime | Yes | Timestamp tạo |
| updated_at | datetime | No | Timestamp cập nhật |

---

## Enumerations

### ProgramTypeEnum

Source: `5.ontology/event-management/event.yaml`

| Value | Description |
|-------|-------------|
| FRESHER | Event tuyển dụng Fresher |
| JOB_FAIR | Ngày hội việc làm |
| UNIWEEK | Tuần lễ đại học |
| INTERN | Tuyển dụng thực tập sinh |

### EventStatusEnum

Source: `5.ontology/event-management/event.yaml`

| Value | Description |
|-------|-------------|
| DRAFT | Event đang nháp, chưa publish |
| PUBLISHED | Event đã publish, đang nhận applications |
| ACTIVE | Event đang diễn ra |
| COMPLETED | Event đã hoàn tất |
| CANCELLED | Event đã hủy |

### TrackStatusEnum

Source: `5.ontology/event-management/track.yaml`

| Value | Description |
|-------|-------------|
| ACTIVE | Track đang active |
| INACTIVE | Track không còn active |
| CANCELLED | Track đã hủy |

### RequestTypeEnum

Source: `5.ontology/event-management/request-mapping.yaml`

| Value | Description |
|-------|-------------|
| FRESHER | Tuyển dụng Fresher |
| INTERN | Tuyển dụng Intern |
| EMPLOYEE | Tuyển dụng nhân viên chính thức |
| CONTRACTOR | Tuyển dụng contractor |

### RequestMappingStatusEnum

Source: `5.ontology/event-management/request-mapping.yaml`

| Value | Description |
|-------|-------------|
| ACTIVE | Mapping đang active |
| INACTIVE | Mapping không còn active |
| CANCELLED | Mapping đã hủy |

### WorkflowStatusEnum

Source: `5.ontology/event-management/workflow.yaml`

| Value | Description |
|-------|-------------|
| DRAFT | Workflow đang nháp |
| ACTIVE | Workflow đang active |
| INACTIVE | Workflow không còn active |

### WorkflowRound

Source: `5.ontology/event-management/workflow.yaml`

| Value | Description |
|-------|-------------|
| SCREENING | Vòng screening applications |
| ONLINE_TEST | Vòng Online Test (Assignment) |
| ONSITE_TEST | Vòng Onsite Test |
| INTERVIEW | Vòng Phỏng vấn |
| OFFER | Vòng Offer |

---

## Business Rules Summary

| Rule ID | Description |
|---------|-------------|
| BR-EM-001 | Chỉ Event thuộc Program "Fresher" mới được map Request |
| BR-EM-002 | Chỉ Request type "Fresher" và status "Approved" mới được map |
| BR-EM-003 | Request đã map Event không được post lên Career Site |
| BR-EM-004 | Một Request chỉ được map 1 Event duy nhất |
| BR-EM-005 | Không được unmap Request nếu đã có Student apply |
| BR-EM-006 | Không được add mapping Request sau khi Event đã publish |
| BR-EM-007 | Workflow phải có ít nhất 1 vòng đánh giá (Test hoặc Interview) |
| BR-EM-008 | Số lần Re-offer tối đa cho 1 Candidate (configurable) |
| BR-EM-009 | Approval workflow cho Re-offer (configurable) |

---

## Event Lifecycle

```
DRAFT → PUBLISHED → ACTIVE → COMPLETED
              ↓
           CANCELLED
```

| Transition | Trigger | Conditions |
|------------|---------|------------|
| DRAFT → PUBLISHED | TA click "Publish" | tracks ≥ 1, request_mappings ≥ 1, workflow hợp lệ |
| PUBLISHED → ACTIVE | Application window bắt đầu | start_date ≤ now |
| ACTIVE → COMPLETED | Application window kết thúc | end_date passed, tất cả applications đã xử lý |
| PUBLISHED/ACTIVE → CANCELLED | TA hủy Event | Lý do business |

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Application Context | Published Language | — | EventPublished, EventConfigUpdated | Async (event bus) |
| Offer Context | Feedback | ReofferRequest | — | Async (command) |
| Request System (external) | ACL | — | GetRequestDetails | Sync (REST API) |
| Career Site (external) | Open Host Service | — | PublishEvent | Sync (REST API) |

---

## Domain Events

| Event | Trigger | Payload |
|-------|---------|---------|
| EventCreated | TA tạo Event mới | eventId, name, description, programType, startDate, endDate |
| EventPublished | TA publish Event | eventId, publishedAt, applicationWindow (start, end) |
| RequestMapped | TA map Request vào Event | mappingId, eventId, requestId, requestType, mappedAt |
| WorkflowConfigured | TA thiết lập workflow | workflowId, eventId, rounds[], skippedRounds[] |
| EventConfigUpdated | TA cập nhật cấu hình Event | eventId, updatedFields[], updatedTracks[] |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design |
|------------|-------------|-------------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Event không hiển thị thông tin PII khi publish |
| Vietnam Labor Law | Quy định về tuyển dụng fresher | Program type chỉ cho phép "Fresher" |

---

## Appendix: OpenAPI Specification

Full OpenAPI 3.0 specification: [`event-management-api.openapi.yaml`](./event-management-api.openapi.yaml)
