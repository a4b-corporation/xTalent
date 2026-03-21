# Context: Event Management

> **Context ID:** `ats.event-management`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm (Responsibilities)

- **Tạo Event Fresher** — Thiết lập Event với thông tin cơ bản (tên, mô tả, thời gian, program type)
- **Mapping Request tuyển dụng** — Connect Event với 1 hoặc nhiều Request tuyển dụng đã được approve
- **Quản lý Track** — Thiết lập các Tracks trong Event (VD: Game Development, Game Design, Game QC)
- **Bộ câu hỏi theo Track** — Add questionnaire templates cho từng Track
- **Workflow Configuration** — Thiết lập workflow vòng tuyển dụng (skip rounds nếu cần)
- **Publish Event** — Post Event lên Career Site

## Không Chịu Trách Nhiệm (Non-Responsibilities)

- **NHẬN applications** — Thuộc Application context
- **Screening applications** — Thuộc Screening context
- **Gửi emails** — Thuộc Email Service (external)
- **Quản lý Request tuyển dụng** — Request thuộc hệ thống khác, chỉ mapping vào Event

---

## Core Entities

| Entity | Định Nghĩa Trong Context Này | Attributes Chính |
|--------|-----------------------------|-----------------|
| **Event** | Sự kiện tuyển dụng Fresher với cấu hình workflow | eventId, name, description, programType, startDate, endDate, status, tracks |
| **RequestMapping** | Mapping giữa Event và Request tuyển dụng | mappingId, eventId, requestId, requestType, status, mappedAt |
| **Track** | Phân nhánh trong Event cho các vị trí khác nhau | trackId, eventId, trackName, questionSetId, status |
| **Workflow** | Cấu hình các vòng tuyển dụng cho Event | workflowId, eventId, rounds[], skippedRounds[], status |
| **QuestionSet** | Bộ câu hỏi áp dụng cho Track | questionSetId, trackId, questions[], status |

---

## Business Rules (Key Policies)

| Rule ID | Rule Description | Severity | Configurable? |
|---------|-----------------|----------|---------------|
| **EM-001** | Chỉ Event thuộc Program "Fresher" mới được map Request tuyển dụng | Error | No |
| **EM-002** | Chỉ Request type "Fresher" và status "Approved" mới được map | Error | No |
| **EM-003** | Request đã map Event không được post lên Career Site | Error | No |
| **EM-004** | Một Request chỉ được map 1 Event duy nhất | Error | No |
| **EM-005** | Không được unmap Request nếu đã có Student apply | Error | No |
| **EM-006** | Không được add mapping Request sau khi Event đã publish | Warning | No |
| **EM-007** | Workflow phải có ít nhất 1 vòng đánh giá (Test hoặc Interview) | Error | No |
| **EM-008** | Số lần Re-offer tối đa cho 1 Candidate | Warning | **Yes** (default: 1-2) |
| **EM-009** | Approval workflow cho Re-offer | Warning | **Yes** (workflow-based) |

---

## Ubiquitous Language (Key Terms)

| Term | Definition | Synonyms | Anti-Synonyms |
|------|------------|----------|---------------|
| **Event** | Sự kiện tuyển dụng Fresher được tạo và quản lý trong hệ thống | Fresher Event, Recruitment Event | Job Post, Career Fair |
| **Program** | Phân loại cao cấp của Event (Fresher, Job Fair, Uniweek) | Event Type, Category | — |
| **Track** | Phân nhánh trong Event cho các vị trí/vai trò khác nhau | Stream, Specialization | Job Title, Position |
| **Request Mapping** | Liên kết giữa Event và Request tuyển dụng | Job Mapping, Request Link | Job Post |
| **Workflow** | Cấu hình trình tự các vòng tuyển dụng cho Event | Process Flow, Pipeline | Application Flow |
| **Publish** | Action post Event lên Career Site | Go Live, Launch | Create, Save |

---

## Team Owner

| Role | Name/Team |
|------|-----------|
| **Team** | TA Operations (Talent Acquisition) |
| **Tech Lead** | TBD |
| **Product Owner** | TA Director / HR Director |
| **Stakeholders** | BA Team, IT Integration Team |

---

## Integration Points

| Direction | Context | Event/API | Data | Relationship Type |
|-----------|---------|-----------|------|-------------------|
| **Sends To** | Application | `EventPublished` | eventId, tracks[], applicationWindow | Published Language |
| **Sends To** | Application | `EventConfigUpdated` | eventId, tracks[], fields[] | Published Language |
| **Receives From** | Offer | `ReofferRequest` | eventId, candidateId, reason | Feedback |
| **Calls API** | Request System (external) | `GetRequestDetails` | requestId | ACL |
| **Calls API** | Career Site (external) | `PublishEvent` | eventId, eventDetails | Open Host Service |

---

## Context-Specific Flows

### Flow EM-F01: Tạo Event với Mapping Request

```
1. TA tạo Event với thông tin cơ bản
2. TA chọn Program = "Fresher"
3. Hệ thống validate Program type
4. TA add Tracks (Game Development, Game Design, etc.)
5. TA add bộ câu hỏi cho từng Track từ Questionnaire library
6. TA mapping Request tuyển dụng:
   - Chọn Requests type = "Fresher"
   - Filter Requests status = "Approved"
   - Filter Requests NOT posted lên Career Site
7. Hệ thống validate mappings
8. TA thiết lập workflow (chọn rounds, skip rounds nếu cần)
9. TA save Event ở status = "Draft"
```

### Flow EM-F02: Publish Event lên Career Site

```
1. TA mở Event ở status = "Draft"
2. TA review toàn bộ config (tracks, questions, workflow, mappings)
3. TA click "Publish"
4. Hệ thống validate:
   - Có ít nhất 1 Track
   - Có ít nhất 1 Request mapped
   - Workflow hợp lệ (có ≥1 vòng đánh giá)
5. Hệ thống push Event lên Career Site
6. Event status = "Published"
7. Không được add/remove Requests sau khi publish
```

### Flow EM-F03: Re-offer Request (từ Offer Context)

```
1. Offer context gửi ReofferRequest (candidate đã Reject Offer)
2. Event Management nhận request
3. Validate Event còn active
4. Validate Re-offer count < max (configurable)
5. Trigger approval workflow (nếu required)
6. Nếu approved, re-open Event cho Candidate
7. Notify Offer context kết quả
```

---

## Out of Scope

- **Application processing** — Thuộc Application context
- **Screening decisions** — Thuộc Screening context
- **Assignment/Test creation** — Thuộc Assessment context
- **Schedule management** — Thuộc Test Session/Interview contexts
- **Offer Letter creation** — Thuộc Offer context
- **Email sending** — Thuộc Email Service (external)
- **Request tuyển dụng CRUD** — Thuộc hệ thống khác

---

## Configurable Parameters

| Parameter | Default | Range | Notes |
|-----------|---------|-------|-------|
| **Max Re-offers per Candidate** | 1 | 0-3 | 0 = không cho re-offer |
| **Re-offer Approval Required** | True | Boolean | Workflow-based |
| **Re-offer Cooldown Period** | 3 days | 1-7 days | Thời gian giữa 2 offers |
| **Auto-remind Before Deadline** | 24h + 2h | Configurable | Time before offer expire |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial context definition |
