# Interview API Documentation

> **Version**: 1.0.0
> **Last Updated**: 2026-03-20
> **Owner**: xTalent ATS Team

## Overview

Interview API cung cấp các endpoints để quản lý:
- **InterviewSlot**: Ca phỏng vấn với ngày giờ, hình thức (Online/Offline/Hybrid), interviewers
- **InterviewSchedule**: Lịch phỏng vấn của Candidate
- **InterviewerInvitation**: Invitation cho Interviewer
- **CheckIn**: Record check-in cho Interview
- **Grading**: Kết quả phỏng vấn, đề xuất Offer/Reject

## Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/v1` |
| Staging | `https://staging-api.xtalent.io/v1` |
| Development | `http://localhost:8080/v1` |

---

## Table of Contents

1. [Interview Slots](#interview-slots)
   - [Create InterviewSlot](#post-interview-slotscreate)
   - [Publish InterviewSlot](#post-interview-slotsidpublish)
   - [Schedule Candidates](#post-interview-slotsidschedule)
2. [Interview Schedules](#interview-schedules)
   - [Confirm Interview Schedule](#post-interview-schedulesidconfirm)
   - [Reschedule Interview](#post-interview-schedulesidreschedule)
   - [Get Interview Schedule](#get-interview-schedulesid)
3. [Interviewer Invitations](#interviewer-invitations)
   - [Respond to Invitation](#post-interviewer-invitationsidrespond)
4. [Grading](#grading)
   - [Submit Grading](#post-interviewsidsubmit-grading)
5. [Check-in](#check-in)
   - [Record Check-in](#post-checkinrecord)

---

## Interview Slots

### POST `/interview-slots/create`

**Tạo InterviewSlot mới**

#### Description

Tạo InterviewSlot mới với thông tin ca phỏng vấn. InterviewSlot được tạo ở trạng thái `DRAFT`.

#### Flow Reference

[`7.flows/interview-flow.md#phase-1-create--publish-interviewslot`](../7.flows/interview-flow.md)

#### Preconditions

- Event đã publish
- TA có quyền tạo InterviewSlot

#### Postconditions

- InterviewSlot created với status = `DRAFT`

#### Request Body

```json
{
  "event_id": "EVT-000001",
  "slot_name": "Ca sáng 09:00-12:00",
  "description": "Phỏng vấn Fresher Developer - Backend",
  "interview_date": "2026-05-05",
  "start_time": "09:00",
  "end_time": "12:00",
  "format": "ONLINE",
  "link": "https://meet.google.com/abc-defg",
  "interviewers": ["MGR-001", "MGR-002"],
  "max_capacity": 10,
  "auto_allocate_enabled": true,
  "time_window_hours": 24,
  "max_retry": 2,
  "notify_ta_on_allocate": true
}
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| event_id | string | Event ID (`EVT-xxxxxx`) |
| slot_name | string | Tên ca phỏng vấn |
| interview_date | date | Ngày phỏng vấn (YYYY-MM-DD) |
| start_time | time | Giờ bắt đầu (HH:mm) |
| end_time | time | Giờ kết thúc (HH:mm) |
| format | enum | `ONLINE`, `OFFLINE`, `HYBRID` |
| interviewers | string[] | Danh sách Manager IDs (min: 1) |
| max_capacity | integer | Số lượng tối đa (≥ 1) |

#### Conditional Fields

| Field | When Required | Description |
|-------|---------------|-------------|
| link | format = ONLINE | Link phỏng vấn (Google Meet, Zoom, etc.) |
| location | format = OFFLINE | Địa điểm phỏng vấn |
| room | format = OFFLINE | Phòng phỏng vấn |

#### Configurable Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| auto_allocate_enabled | true | boolean | Bật auto allocate |
| time_window_hours | 24 | 1-72 | Thời gian confirm slot (giờ) |
| max_retry | 2 | 0-5 | Số lần retry auto-allocate |
| notify_ta_on_allocate | true | boolean | Notify TA khi allocate thành công |

#### Responses

**201 Created**

```json
{
  "slot_id": "ISLOT-000001",
  "event_id": "EVT-000001",
  "slot_name": "Ca sáng 09:00-12:00",
  "interview_date": "2026-05-05",
  "start_time": "09:00",
  "end_time": "12:00",
  "format": "ONLINE",
  "link": "https://meet.google.com/abc-defg",
  "max_capacity": 10,
  "current_capacity": 0,
  "interviewers": ["MGR-001", "MGR-002"],
  "status": "DRAFT",
  "created_by": "TA-001",
  "created_at": "2026-04-25T08:30:00Z"
}
```

**400 Bad Request**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "interviewers is required and must have at least 1 interviewer",
    "details": {
      "field": "interviewers",
      "constraint": "min_length: 1"
    }
  }
}
```

**403 Forbidden**

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Only TA role can create InterviewSlots"
  }
}
```

**404 Not Found**

```json
{
  "error": {
    "code": "EVENT_NOT_FOUND",
    "message": "Event EVT-000001 does not exist"
  }
}
```

---

### POST `/interview-slots/{id}/publish`

**Publish InterviewSlot**

#### Description

Publish InterviewSlot (mở đăng ký, status = ACTIVE). Trigger auto-allocate Candidates nếu enabled.

#### Flow Reference

[`7.flows/interview-flow.md#phase-1-create--publish-interviewslot`](../7.flows/interview-flow.md)

#### Preconditions

- InterviewSlot.status = `DRAFT`
- InterviewSlot có đủ thông tin (ngày giờ, format, interviewers)

#### Postconditions

- InterviewSlot.status = `ACTIVE`
- Auto-allocate bắt đầu (nếu enabled)
- InterviewSchedule created cho mỗi Candidate
- InterviewerInvitation created cho mỗi interviewer

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSlot ID (`ISLOT-xxxxxx`) |

#### Responses

**200 OK**

```json
{
  "slot_id": "ISLOT-000001",
  "status": "ACTIVE",
  "updated_at": "2026-04-25T09:00:00Z"
}
```

**400 Bad Request**

```json
{
  "error": {
    "code": "INVALID_STATE",
    "message": "InterviewSlot thiếu thông tin: interviewers required"
  }
}
```

**409 Conflict**

```json
{
  "error": {
    "code": "INVALID_STATE_TRANSITION",
    "message": "InterviewSlot ISLOT-000001 đã ở trạng thái ACTIVE"
  }
}
```

---

### POST `/interview-slots/{id}/schedule`

**Schedule Candidates vào InterviewSlot**

#### Description

Auto-allocate hoặc Manual assign Candidates vào InterviewSlot.

#### Business Rules

| Rule | Description |
|------|-------------|
| **BR-ISLOT-003** | Auto-allocate với FCFS + Time Window (configurable) |
| **BR-ISLOT-004** | Time Window để confirm slot (default: 24h) |
| **BR-ISLOT-005** | Notify TA khi auto-allocate thành công |

#### Error Handling (từ Flow)

- **Candidate không confirm trong Time Window**: Auto retry allocate (max 2 lần)
- **Sau 2 lần vẫn không confirm**: Notify TA manual assign

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSlot ID (`ISLOT-xxxxxx`) |

#### Request Body

**Auto-allocate (FCFS)**

```json
{
  "method": "AUTO",
  "allocation_rules": {
    "fcfs": true,
    "time_window_hours": 24
  }
}
```

**Manual Assign**

```json
{
  "method": "MANUAL",
  "candidate_rr_ids": ["CRR-000001", "CRR-000002"]
}
```

#### Responses

**200 OK**

```json
{
  "allocated_schedules": [
    {
      "schedule_id": "ISCH-000001",
      "candidate_rr_id": "CRR-000001",
      "slot_id": "ISLOT-000001",
      "status": "PENDING",
      "confirm_deadline": "2026-04-26T09:00:00Z"
    }
  ],
  "notification_sent": true
}
```

**409 Conflict (Slot Full)**

```json
{
  "error": {
    "code": "SLOT_FULL",
    "message": "InterviewSlot ISLOT-000001 đã hết chỗ (10/10)"
  }
}
```

---

## Interview Schedules

### POST `/interview-schedules/{id}/confirm`

**Confirm Interview Schedule**

#### Description

Candidate confirm tham gia phỏng vấn.

#### Flow Reference

[`7.flows/interview-flow.md#phase-2-candidate-confirm--interviewer-accept`](../7.flows/interview-flow.md)

#### Preconditions

- InterviewSchedule.status = `PENDING`
- Chưa qua confirm_deadline

#### Postconditions

- InterviewSchedule.status = `CONFIRMED`
- Notify TA

#### Business Rules

| Rule | Description |
|------|-------------|
| **BR-ISCH-001** | Candidate chỉ được đổi lịch 1 lần |

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSchedule ID (`ISCH-xxxxxx`) |

#### Responses

**200 OK**

```json
{
  "schedule_id": "ISCH-000001",
  "slot_id": "ISLOT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "status": "CONFIRMED",
  "confirmed_at": "2026-04-25T10:30:00Z",
  "confirm_deadline": "2026-04-26T09:00:00Z",
  "change_count": 0
}
```

**409 Conflict (Deadline Exceeded)**

```json
{
  "error": {
    "code": "DEADLINE_EXCEEDED",
    "message": "Confirm deadline đã qua. Vui lòng liên hệ TA để được hỗ trợ."
  }
}
```

---

### POST `/interview-schedules/{id}/reschedule`

**Reschedule Interview**

#### Description

Candidate yêu cầu đổi lịch phỏng vấn.

#### Flow Reference

[`7.flows/interview-flow.md#case-candidate-đổi-lịch-lần-2`](../7.flows/interview-flow.md)

#### Business Rules

| Rule | Description |
|------|-------------|
| **BR-ISCH-001** | Lần 1: Tự chọn slot. Lần 2: Chỉ còn Yes/No options |

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSchedule ID (`ISCH-xxxxxx`) |

#### Request Body

**Lần đổi thứ 1 (Tự chọn slot)**

```json
{
  "reason": "Trùng lịch thi",
  "preferred_slot_id": "ISLOT-000002"
}
```

**Lần đổi thứ 2 (Yes/No only)**

```json
{
  "reason": "Việc gia đình đột xuất",
  "accept_reassignment": true
}
```

#### Responses

**200 OK**

```json
{
  "schedule_id": "ISCH-000001",
  "status": "RESCHEDULED",
  "change_count": 1,
  "updated_at": "2026-04-25T11:00:00Z"
}
```

**400 Bad Request (Max Changes Exceeded)**

```json
{
  "error": {
    "code": "MAX_CHANGES_EXCEEDED",
    "message": "Bạn đã đổi lịch 1 lần. Lần này chỉ còn Yes/No options"
  }
}
```

---

### GET `/interview-schedules/{id}`

**Get Interview Schedule**

#### Description

Lấy thông tin InterviewSchedule của Candidate.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSchedule ID (`ISCH-xxxxxx`) |

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| include | string[] | `slot_details`, `candidate_info`, `grading` |

#### Responses

**200 OK**

```json
{
  "schedule_id": "ISCH-000001",
  "slot_id": "ISLOT-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "status": "CONFIRMED",
  "confirmed_at": "2026-04-25T10:30:00Z",
  "confirm_deadline": "2026-04-26T09:00:00Z",
  "change_count": 0,
  "created_at": "2026-04-25T09:00:00Z"
}
```

---

## Interviewer Invitations

### POST `/interviewer-invitations/{id}/respond`

**Respond to Interviewer Invitation**

#### Description

Interviewer phản hồi invitation (Accept/Decline).

#### Flow Reference

[`7.flows/interview-flow.md#phase-2-candidate-confirm--interviewer-accept`](../7.flows/interview-flow.md)

#### Postconditions

- InterviewerInvitation.status = `ACCEPTED`/`DECLINED`

#### Error Handling (từ Flow)

- **Nếu DECLINED**: Notify TA, auto-send invitation cho interviewer thay thế

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewerInvitation ID (`IINV-xxxxxx`) |

#### Request Body

**Accept**

```json
{
  "response": "ACCEPT"
}
```

**Decline**

```json
{
  "response": "DECLINE",
  "reason": "Trùng lịch họp"
}
```

#### Responses

**200 OK**

```json
{
  "invitation_id": "IINV-000001",
  "slot_id": "ISLOT-000001",
  "interviewer_id": "MGR-001",
  "status": "ACCEPTED",
  "response": "ACCEPT",
  "responded_at": "2026-04-25T14:30:00Z"
}
```

---

## Grading

### POST `/interviews/{id}/submit-grading`

**Submit Grading**

#### Description

Interviewer submit kết quả phỏng vấn cho Candidate.

#### Flow Reference

[`7.flows/interview-flow.md#phase-4-submit-grading`](../7.flows/interview-flow.md)

#### Preconditions

- Interviewer được phân công cho Candidate này (BR-IGRD-001)
- Score trong khoảng 0-100

#### Postconditions

- Grading created với score, comment, proposal
- Notify TA grading đã submit
- Publish event `GradingSubmitted`

#### Business Rules

| Rule | Description |
|------|-------------|
| **BR-IGRD-001** | Interviewer chỉ submit grading cho Candidates được phân công |
| **BR-IGRD-002** | Grading có thể update trước khi TA review (configurable deadline) |

#### Error Handling (từ Flow)

- **Interviewer không submit grading**: Auto-send reminder sau 24h
- **Grading proposal = NEED_DISCUSSION**: TA tổ chức discussion meeting

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | InterviewSchedule ID (`ISCH-xxxxxx`) |

#### Request Body

**Proposal: OFFER**

```json
{
  "score": 88.0,
  "comment": "Giao tiếp tốt, kỹ thuật vững. Ứng viên nắm chắc kiến thức cơ bản.",
  "proposal": "OFFER"
}
```

**Proposal: REJECT**

```json
{
  "score": 45.0,
  "comment": "Kỹ thuật chưa đạt, cần cải thiện thêm.",
  "proposal": "REJECT"
}
```

**Proposal: NEED_DISCUSSION**

```json
{
  "score": 70.0,
  "comment": "Ứng viên có tiềm năng nhưng cần đánh giá thêm về văn hóa phù hợp.",
  "proposal": "NEED_DISCUSSION"
}
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| score | number | Điểm số (0-100) |
| proposal | enum | `OFFER`, `REJECT`, `NEED_DISCUSSION` |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| comment | string | Nhận xét của interviewer |

#### Responses

**201 Created**

```json
{
  "grading_id": "IGRD-000001",
  "schedule_id": "ISCH-000001",
  "interviewer_id": "MGR-001",
  "score": 88.0,
  "comment": "Giao tiếp tốt, kỹ thuật vững. Ứng viên nắm chắc kiến thức cơ bản.",
  "proposal": "OFFER",
  "graded_at": "2026-05-05T11:30:00Z",
  "can_update_before_review": true,
  "update_deadline": "2026-05-06T11:30:00Z",
  "created_by": "MGR-001",
  "created_at": "2026-05-05T11:30:00Z"
}
```

**400 Bad Request**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "score phải trong khoảng 0-100",
    "details": {
      "field": "score",
      "constraint": "minimum: 0, maximum: 100"
    }
  }
}
```

**403 Forbidden**

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "Bạn không được phân công phỏng vấn Candidate này"
  }
}
```

---

## Check-in

### POST `/checkin/record`

**Record Check-in**

#### Description

Ghi nhận check-in cho Candidate trong Interview.

#### Flow Reference

[`7.flows/interview-flow.md#phase-3-conduct-interview--check-in`](../7.flows/interview-flow.md)

#### Preconditions

- InterviewSchedule.status = `CONFIRMED`
- Candidate đến phòng phỏng vấn

#### Postconditions

- CheckIn created với:
  - `actual_time`: Thời gian check-in thực tế
  - `is_late`: Flag (so với start_time + grace_period)
  - `late_reason`: Lý do (nếu is_late = true)
  - `optional photo_id`: Photo ID (chụp hình)

#### Business Rules

| Rule | Description |
|------|-------------|
| **BR-ICI-001** | Check-in muộn vẫn cho phép với lý do |

#### Request Body

**On Time**

```json
{
  "schedule_id": "ISCH-000001",
  "actual_time": "2026-05-05T08:55:00Z",
  "photo_id": "ATT-001"
}
```

**Late**

```json
{
  "schedule_id": "ISCH-000001",
  "actual_time": "2026-05-05T09:20:00Z",
  "late_reason": "Kẹt xe",
  "photo_id": "ATT-002"
}
```

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| schedule_id | string | InterviewSchedule ID |
| actual_time | datetime | Thời gian check-in thực tế |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| is_late | boolean | Auto-calculated nếu không cung cấp |
| late_reason | string | Lý do check-in muộn |
| photo_id | string | Photo ID (chụp hình) |

#### Responses

**201 Created**

```json
{
  "check_in_id": "ICI-000001",
  "schedule_id": "ISCH-000001",
  "actual_time": "2026-05-05T08:55:00Z",
  "is_late": false,
  "status": "ON_TIME",
  "photo_id": "ATT-001",
  "checked_in_by": "TA-001",
  "created_at": "2026-05-05T08:55:00Z"
}
```

---

## Error Handling

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | User not authenticated |
| `FORBIDDEN` | 403 | User not authorized |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `INVALID_STATE` | 409 | Invalid resource state |
| `INVALID_STATE_TRANSITION` | 409 | Invalid state transition |
| `DEADLINE_EXCEEDED` | 409 | Deadline đã qua |
| `MAX_CHANGES_EXCEEDED` | 400 | Đã đạt max changes |
| `SLOT_FULL` | 409 | Slot đã hết chỗ |
| `GRADING_ALREADY_SUBMITTED` | 409 | Grading đã được submit |

---

## Lifecycle States

### InterviewSlot Lifecycle

```
DRAFT → ACTIVE → IN_PROGRESS → COMPLETED
              ↓
           CANCELLED
```

| Transition | Trigger |
|------------|---------|
| DRAFT → ACTIVE | TA publish InterviewSlot |
| ACTIVE → IN_PROGRESS | Đến interview_date + start_time |
| IN_PROGRESS → COMPLETED | Tất cả Candidates đã phỏng vấn + submit grading |
| ACTIVE/IN_PROGRESS → CANCELLED | TA hủy InterviewSlot |

### InterviewSchedule Lifecycle

```
PENDING → CONFIRMED → COMPLETED
    ↓           ↓
RESCHEDULED  NO_SHOW
    ↓
 CANCELLED
```

| Transition | Trigger |
|------------|---------|
| PENDING → CONFIRMED | Candidate confirm |
| PENDING → RESCHEDULED | Candidate đổi lịch (change_count = 1) |
| CONFIRMED → COMPLETED | Candidate hoàn thành phỏng vấn |
| CONFIRMED → NO_SHOW | Candidate không check-in |
| RESCHEDULED → CONFIRMED | Candidate confirm lịch mới |

---

## Appendix

### Source Documents

| Document | Path |
|----------|------|
| **Glossary** | [`6.glossary/interview.md`](../6.glossary/interview.md) |
| **Flow** | [`7.flows/interview-flow.md`](../7.flows/interview-flow.md) |
| **Ontology** | [`5.ontology/interview/`](../5.ontology/interview/) |

### Ontology Files

- `interview-slot.yaml` - InterviewSlot schema
- `interview-schedule.yaml` - InterviewSchedule schema
- `interviewer-invitation.yaml` - InterviewerInvitation schema
- `checkin.yaml` - CheckIn schema
- `grading.yaml` - Grading schema
