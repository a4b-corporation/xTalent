# Test Session API Documentation

> **Version:** 1.0.0
> **Base URL:** `https://api.xtalent.io/ats/v1`
> **Staging URL:** `https://staging-api.xtalent.io/ats/v1`

## Overview

API cho **Test Session Bounded Context** — Quản lý ca thi Onsite, auto allocate slots, check-in, và chấm thi.

### Derived From

| Document | Path |
|----------|------|
| **Glossary** | `6.glossary/test-session.md` |
| **Flow** | `7.flows/test-session-flow.md` |
| **Ontology** | `5.ontology/test-session/*.yaml` |

### Use Cases Supported

| Use Case | Endpoint | Description |
|----------|----------|-------------|
| Create TestSlot | `POST /test-slots/create` | Tạo TestSlot mới với thông tin ca thi |
| Auto-allocate Candidates | `POST /test-slots/{id}/allocate` | Hệ thống auto allocate Student vào TestSlot |
| Confirm Schedule | `POST /schedules/{id}/confirm` | Student confirm tham gia Test Session |
| Reschedule Test | `POST /schedules/{id}/reschedule` | Student đổi lịch thi (lần 1) |
| Get Test Schedule | `GET /schedules/{id}` | Lấy thông tin Schedule của Student |

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| **BR-TSLOT-001** | Auto gen SBD khi Student được chia vào slot |
| **BR-TSLOT-002** | Student chỉ được đổi lịch 1 lần (lần thứ 2 chỉ còn Yes/No options) |
| **BR-TSLOT-003** | Auto allocate slots theo FCFS với Time Window (configurable) |
| **BR-TSLOT-004** | Time Window để confirm slot (default: 24h, configurable 1-72h) |
| **BR-TSLOT-005** | Notify TA khi auto-allocate thành công (configurable) |
| **BR-TSLOT-006** | Photo capture khi check-in không bắt buộc (configurable) |
| **BR-TSLOT-007** | Grace period cho check-in muộn (default: 15 phút) |
| **BR-TSCH-001** | Chỉ Managers được phân công mới chấm được Onsite Test |
| **BR-TCI-001** | Check-in muộn vẫn cho phép với lý do (trong grace period) |

---

## Ubiquitous Language

### Entities

| Term | Definition |
|------|------------|
| **TestSlot** | Ca thi Onsite với ngày giờ, địa điểm, phòng, và max capacity |
| **Schedule** | Lịch thi của Student trong Test Session, auto gen SBD khi được chia vào slot |
| **SBD** | Số Báo Danh (pattern: `SBD-YYYYNNNN`), auto-gen khi allocate |
| **CheckIn** | Record check-in cho Student trong Test Session |
| **Grading** | Kết quả chấm Onsite Test của Manager |

### Lifecycle States

#### TestSlot Lifecycle
```
DRAFT → ACTIVE → IN_PROGRESS → COMPLETED
              ↓
           CANCELLED
```

#### Schedule Lifecycle
```
PENDING → CONFIRMED → COMPLETED
    ↓           ↓
RESCHEDULED  NO_SHOW
    ↓
 CANCELLED
```

---

## Authentication

All API endpoints require authentication via Bearer token:

```http
Authorization: Bearer <access_token>
```

---

## API Endpoints

### 1. Create TestSlot

**Endpoint:** `POST /test-slots/create`

**Description:** Tạo TestSlot mới với thông tin ca thi.

**Preconditions:**
- Event đã publish
- TA có quyền tạo TestSlot

**Postconditions:**
- TestSlot created ở status `DRAFT`

**Request Body:**

```json
{
  "event_id": "EVT-000001",
  "slot_name": "Ca sáng 08:00-12:00",
  "description": "Ca thi sáng tại Hà Nội",
  "test_date": "2026-04-27",
  "start_time": "08:00",
  "end_time": "12:00",
  "location": "Hà Nội",
  "room": "Phòng 301",
  "max_capacity": 30,
  "graders": ["MGR-001", "MGR-002"],
  "auto_allocate_enabled": true,
  "time_window_hours": 24,
  "max_retry": 2,
  "notify_ta_on_allocate": true,
  "photo_capture_required": false,
  "grace_period_minutes": 15
}
```

**Response (201 Created):**

```json
{
  "slot_id": "TSLOT-000001",
  "event_id": "EVT-000001",
  "slot_name": "Ca sáng 08:00-12:00",
  "description": "Ca thi sáng tại Hà Nội",
  "test_date": "2026-04-27",
  "start_time": "08:00",
  "end_time": "12:00",
  "location": "Hà Nội",
  "room": "Phòng 301",
  "max_capacity": 30,
  "current_capacity": 0,
  "graders": ["MGR-001", "MGR-002"],
  "status": "DRAFT",
  "auto_allocate_enabled": true,
  "time_window_hours": 24,
  "max_retry": 2,
  "notify_ta_on_allocate": true,
  "photo_capture_required": false,
  "grace_period_minutes": 15,
  "created_by": "TA-001",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-20T10:30:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request format or missing required fields |
| `401 UNAUTHORIZED` | Authentication required |
| `403 FORBIDDEN` | User does not have permission to create TestSlots |

---

### 2. Publish TestSlot

**Endpoint:** `POST /test-slots/{id}/publish`

**Description:** Publish TestSlot (mở đăng ký) để bắt đầu auto-allocate.

**Preconditions:**
- TestSlot có đủ thông tin (ngày giờ, địa điểm, room, capacity)
- TestSlot status = `DRAFT`

**Postconditions:**
- TestSlot status = `ACTIVE`
- Auto-allocate bắt đầu (nếu enabled)

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | TestSlot ID (pattern: `TSLOT-\\d{6}`) |

**Response (200 OK):**

```json
{
  "slot_id": "TSLOT-000001",
  "event_id": "EVT-000001",
  "slot_name": "Ca sáng 08:00-12:00",
  "test_date": "2026-04-27",
  "start_time": "08:00",
  "end_time": "12:00",
  "location": "Hà Nội",
  "room": "Phòng 301",
  "max_capacity": 30,
  "current_capacity": 0,
  "status": "ACTIVE",
  "auto_allocate_enabled": true,
  "time_window_hours": 24,
  "created_by": "TA-001",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-20T10:35:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | TestSlot missing required information |
| `404 NOT FOUND` | TestSlot not found |
| `409 CONFLICT` | TestSlot cannot be published in current status |

---

### 3. Auto-allocate Candidate to TestSlot

**Endpoint:** `POST /test-slots/{id}/allocate`

**Description:** Hệ thống auto allocate Student vào TestSlot theo FCFS + Time Window.

**Preconditions:**
- TestSlot status = `ACTIVE`
- Còn chỗ (`current_capacity < max_capacity`)

**Postconditions:**
- Schedule created với SBD (pattern: `SBD-YYYYNNNN`)
- `confirm_deadline` set (default: 24h từ khi allocate)
- Event `ScheduleAllocated` published

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | TestSlot ID (pattern: `TSLOT-\\d{6}`) |

**Request Body:**

```json
{
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001"
}
```

**Response (201 Created):**

```json
{
  "schedule_id": "TSCH-000001",
  "slot_id": "TSLOT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "sbd": "SBD-20260001",
  "status": "PENDING",
  "confirm_deadline": "2026-03-21T10:30:00Z",
  "change_count": 0,
  "created_by": "SYSTEM",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-20T10:30:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request format |
| `404 NOT FOUND` | TestSlot not found |
| `409 CONFLICT` | TestSlot full or candidate already allocated |

**Error Details:**

```json
{
  "code": "SLOT_FULL",
  "message": "TestSlot TSLOT-000001 has reached max capacity (30/30)",
  "details": {
    "slot_id": "TSLOT-000001",
    "current_capacity": 30,
    "max_capacity": 30
  }
}
```

---

### 4. Confirm Schedule

**Endpoint:** `POST /schedules/{id}/confirm`

**Description:** Student confirm tham gia Test Session sau khi được auto-allocate.

**Preconditions:**
- Schedule.status = `PENDING`
- Confirm deadline chưa qua (default: 24h từ khi allocate)
- `change_count < max_changes` (default: 1)

**Postconditions:**
- Schedule.status = `CONFIRMED`
- `confirmed_at` = now
- TestSlot.current_capacity += 1
- Event `ScheduleConfirmed` published

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Schedule ID (pattern: `TSCH-\\d{6}`) |

**Response (200 OK):**

```json
{
  "schedule_id": "TSCH-000001",
  "slot_id": "TSLOT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "sbd": "SBD-20260001",
  "status": "CONFIRMED",
  "confirmed_at": "2026-03-20T11:00:00Z",
  "confirm_deadline": "2026-03-21T10:30:00Z",
  "change_count": 0,
  "created_by": "SYSTEM",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-20T11:00:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request |
| `404 NOT FOUND` | Schedule not found |
| `409 CONFLICT` | Schedule cannot be confirmed (deadline expired, invalid status) |

**Error Details:**

```json
{
  "code": "DEADLINE_EXPIRED",
  "message": "Cannot confirm Schedule TSCH-000001: confirm deadline has passed",
  "details": {
    "schedule_id": "TSCH-000001",
    "confirm_deadline": "2026-03-19T10:30:00Z",
    "current_time": "2026-03-21T10:30:00Z"
  }
}
```

---

### 5. Reschedule Test

**Endpoint:** `POST /schedules/{id}/reschedule`

**Description:** Student đổi lịch thi (lần 1).

**Preconditions:**
- Schedule.status = `CONFIRMED`
- `change_count < 1` (Student chỉ được đổi lịch 1 lần)

**Postconditions:**
- Schedule.slot_id = new slot
- `change_count += 1`
- status = `RESCHEDULED`
- confirmDeadline mới (24h)
- Event `ScheduleRescheduled` published

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Schedule ID (pattern: `TSCH-\\d{6}`) |

**Request Body:**

```json
{
  "new_slot_id": "TSLOT-000002"
}
```

**Response (200 OK):**

```json
{
  "schedule_id": "TSCH-000001",
  "slot_id": "TSLOT-000002",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "sbd": "SBD-20260001",
  "status": "RESCHEDULED",
  "confirmed_at": null,
  "confirm_deadline": "2026-03-22T10:30:00Z",
  "change_count": 1,
  "created_by": "SYSTEM",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-21T10:30:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request |
| `404 NOT FOUND` | Schedule not found |
| `409 CONFLICT` | Reschedule not allowed (max changes reached, slot full) |

**Error Details:**

```json
{
  "code": "MAX_CHANGES_REACHED",
  "message": "Cannot reschedule TSCH-000001: Student đã đổi lịch 1 lần. Lần này chỉ còn Yes/No options — liên hệ TA để manual assign",
  "details": {
    "schedule_id": "TSCH-000001",
    "change_count": 1,
    "max_changes": 1,
    "action_required": "TA_MANUAL_ASSIGN"
  }
}
```

---

### 6. Get Test Schedule

**Endpoint:** `GET /schedules/{id}`

**Description:** Lấy thông tin Schedule của Student.

**Path Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | string | Schedule ID (pattern: `TSCH-\\d{6}`) |

**Response (200 OK):**

```json
{
  "schedule_id": "TSCH-000001",
  "slot_id": "TSLOT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "sbd": "SBD-20260001",
  "status": "PENDING",
  "confirmed_at": null,
  "confirm_deadline": "2026-03-21T10:30:00Z",
  "change_count": 0,
  "created_by": "SYSTEM",
  "created_at": "2026-03-20T10:30:00Z",
  "updated_at": "2026-03-20T10:30:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `404 NOT FOUND` | Schedule not found |

---

### 7. Record Check-in

**Endpoint:** `POST /checkins`

**Description:** Ghi nhận check-in cho Student trong Test Session.

**Preconditions:**
- Schedule.status = `CONFIRMED`
- Student đến địa điểm thi

**Postconditions:**
- CheckIn created với `actual_time`, `is_late` flag
- Event `CheckInRecorded` published

**Request Body:**

```json
{
  "schedule_id": "TSCH-000001",
  "actual_time": "2026-04-27T07:45:00Z",
  "photo_id": "ATT-001",
  "checked_in_by": "TA-001"
}
```

**Response (201 Created):**

```json
{
  "check_in_id": "TCI-000001",
  "schedule_id": "TSCH-000001",
  "actual_time": "2026-04-27T07:45:00Z",
  "is_late": false,
  "late_reason": null,
  "photo_id": "ATT-001",
  "checked_in_by": "TA-001",
  "created_at": "2026-04-27T07:45:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request |
| `404 NOT FOUND` | Schedule not found |
| `409 CONFLICT` | Check-in not allowed (very late, past grace period) |

**Error Details:**

```json
{
  "code": "VERY_LATE",
  "message": "Check-in rejected: Student đến muộn quá grace period (15 phút)",
  "details": {
    "schedule_id": "TSCH-000001",
    "scheduled_time": "2026-04-27T08:00:00Z",
    "actual_time": "2026-04-27T08:30:00Z",
    "grace_period_minutes": 15,
    "minutes_late": 30
  }
}
```

---

### 8. Complete Grading

**Endpoint:** `POST /gradings`

**Description:** Manager hoàn thành chấm Onsite Test.

**Preconditions:**
- CheckIn.status = `ON_TIME`/`LATE` (Student đã thi xong)
- Grader là Manager được phân công (BR-TSCH-001)

**Postconditions:**
- Grading created với score, comment, pass_fail
- Event `GradingCompleted` published

**Request Body:**

```json
{
  "schedule_id": "TSCH-000001",
  "grader_id": "MGR-001",
  "score": 78.5,
  "comment": "Làm bài tốt, code sạch",
  "pass_fail": "PASS"
}
```

**Response (201 Created):**

```json
{
  "grading_id": "TGRD-000001",
  "schedule_id": "TSCH-000001",
  "grader_id": "MGR-001",
  "score": 78.5,
  "comment": "Làm bài tốt, code sạch",
  "pass_fail": "PASS",
  "graded_at": "2026-04-27T14:00:00Z",
  "created_by": "MGR-001",
  "created_at": "2026-04-27T14:00:00Z"
}
```

**Error Responses:**

| Code | Condition |
|------|-----------|
| `400 BAD REQUEST` | Invalid request |
| `403 FORBIDDEN` | Grader not authorized (not in assigned graders list) |
| `404 NOT FOUND` | Schedule not found |

**Error Details:**

```json
{
  "code": "NOT_AUTHORIZED",
  "message": "Grader MGR-002 không được phân công chấm TestSlot TSLOT-000001",
  "details": {
    "grader_id": "MGR-002",
    "slot_id": "TSLOT-000001",
    "assigned_graders": ["MGR-001", "MGR-003"]
  }
}
```

---

## Data Models

### TestSlotStatusEnum

| Value | Description |
|-------|-------------|
| `DRAFT` | Đang nháp |
| `ACTIVE` | Đang mở đăng ký |
| `IN_PROGRESS` | Đang diễn ra |
| `COMPLETED` | Hoàn tất |
| `CANCELLED` | Đã hủy |

### ScheduleStatusEnum

| Value | Description |
|-------|-------------|
| `PENDING` | Chưa confirm |
| `CONFIRMED` | Đã confirm |
| `RESCHEDULED` | Đã đổi lịch |
| `COMPLETED` | Hoàn tất |
| `NO_SHOW` | Không đến |
| `CANCELLED` | Đã hủy |

### PassFailEnum

| Value | Description |
|-------|-------------|
| `PASS` | Đạt |
| `FAIL` | Không đạt |
| `NEEDS_DISCUSSION` | Cần thảo luận thêm |

---

## Configurable Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `time_window_hours` | 24 | 1-72 | Thời gian confirm slot (giờ) |
| `max_retry` | 2 | 0-5 | Số lần retry auto-allocate |
| `grace_period_minutes` | 15 | 0-60 | Grace period cho check-in muộn |
| `photo_capture_required` | false | boolean | Bắt buộc chụp ảnh khi check-in |
| `blind_grading_enabled` | true | boolean | Ẩn PII với Graders |
| `max_schedule_changes` | 1 | 0-3 | Số lần đổi lịch tối đa |

---

## Events Published

| Event | Description | Trigger |
|-------|-------------|---------|
| `TestSlotCreated` | TA tạo TestSlot mới | `POST /test-slots/create` |
| `TestSlotPublished` | TA publish TestSlot | `POST /test-slots/{id}/publish` |
| `ScheduleAllocated` | System auto allocate Student | `POST /test-slots/{id}/allocate` |
| `ScheduleConfirmed` | Student confirm tham gia | `POST /schedules/{id}/confirm` |
| `ScheduleRescheduled` | Student đổi lịch thi | `POST /schedules/{id}/reschedule` |
| `CheckInRecorded` | Student check-in | `POST /checkins` |
| `GradingCompleted` | Manager hoàn thành chấm thi | `POST /gradings` |

---

## Compliance Notes

| Regulation | Requirement | Impact |
|------------|-------------|--------|
| **Vietnam PDPL** | Bảo vệ thông tin cá nhân ứng viên | SBD gen tự động để ẩn danh tính, PII không hiển thị với Graders |
| **Vietnam Labor Law** | Lưu trữ hồ sơ tuyển dụng | TestSlots, Schedules, Gradings lưu trữ tối thiểu 1 năm |
| **Fair Hiring** | Đánh giá công bằng, không bias | Blind grading (Graders không thấy thông tin cá nhân) |

---

## Related Documents

- **Glossary:** [6.glossary/test-session.md](../../6.glossary/test-session.md)
- **Flow:** [7.flows/test-session-flow.md](../../7.flows/test-session-flow.md)
- **Ontology:** [5.ontology/test-session/](../../5.ontology/test-session/)

---

*Generated from ODSA API Designer workflow. Last updated: 2026-03-20*
