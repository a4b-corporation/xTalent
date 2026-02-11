# Event Entity LinkML Ontology - Documentation

## Overview

This document describes the comprehensive LinkML ontology for the **Event** entity in the ECR (Event-Centric Recruitment) module of the xTalent solution.

## File Information

- **File**: `event.yaml`
- **Format**: LinkML YAML
- **Version**: 1.0.0
- **Module**: ECR (Event-Centric Recruitment)
- **Bounded Context**: Event Management Context

## Entity Definition: Event

The Event entity is defined as an **Aggregate Root** in the Event Management Context, serving as the central container for managing mass hiring events.

### Key Characteristics

- **Event-Centric paradigm**: Event is a container for multiple Tracks (recruitment streams)
- **Master Event lifecycle**: Extends from pre-event → physical event → post-event
- **Hybrid model**: Supports both online (remote testing) and onsite (kiosk check-in) operations

## Core Attributes

### Identification & Basic Info
- `event_id`: Unique identifier with pattern `^EVT-\\d{6}$` (e.g., EVT-000001)
- `event_code`: Short code for SBD generation (e.g., "FRESHER2026")
- `event_name`: Full event name
- `event_description`: Detailed description

### Type & Status
- `event_type`: Range of EventTypeEnum (FRESHER, JOB_FAIR, etc.)
- `event_status`: Range of EventStatusEnum (DRAFT, PUBLISHED, ONGOING, etc.)

### Temporal Attributes
- `start_date`: Master event lifecycle start
- `end_date`: Master event lifecycle end
- `physical_event_date`: Actual onsite event date
- `created_at`, `published_at`, `archived_at`: Audit timestamps

### Capacity & Location
- `max_capacity`: Total candidate capacity
- `venue_location`: Physical event location

### Relationships
- `tracks`: Multi-valued reference to Track entities
- `request_mappings`: Multi-valued reference to RequestMapping entities

## Related Entities

### Track Entity
Represents recruitment streams within an event (e.g., "Game Dev", "QC", "Design")

**Attributes**:
- `track_id`, `track_name`, `track_code`
- `track_type`: Range of TrackTypeEnum
- `event_id`: Foreign key to Event
- `question_set_id`: Reference to dynamic question blueprint
- `question_set_locked`: Boolean flag for report consistency

### RequestMapping Entity
Many-to-many mapping between Tracks and Job Requisitions

**Purpose**: Anti-Corruption Layer between Event Context and ATS Core

## Enumerations

### EventStatusEnum (6 values)

| Value | Description | Annotations |
|-------|-------------|-------------|
| `DRAFT` | Event being created/edited | `allow_edits: true`, `visible_to_candidates: false` |
| `PUBLISHED` | Event live for candidate registration | `allow_edits: false`, `visible_to_candidates: true` |
| `ONGOING` | Event in progress | `allow_registration: true`, `allow_checkin: true` |
| `COMPLETED` | Event finished but not archived | `allow_registration: false`, `allow_reporting: true` |
| `ARCHIVED` | Read-only archived state | `allow_edits: false`, `read_only: true` |
| `CANCELLED` | Event cancelled | `allow_edits: false`, `visible_to_candidates: false` |

### EventTypeEnum (7 values)

| Value | Description | Target Audience | Typical Scale |
|-------|-------------|-----------------|---------------|
| `FRESHER` | New graduate mass hiring | University graduates | 100-1000 candidates |
| `JOB_FAIR` | General job fair | General job seekers | 500-5000 candidates |
| `MANAGEMENT_TRAINEE` | MT programs | High-potential graduates | 50-200 candidates |
| `INTERNSHIP` | Internship recruitment | Students | 20-500 candidates |
| `CAMPUS_RECRUITMENT` | On-campus hiring | University students | 50-300 candidates |
| `WALK_IN` | Walk-in recruitment | Walk-in applicants | 100-500 candidates |
| `ONLINE_ASSESSMENT` | Pure online assessment | Any | Variable |

### TrackTypeEnum (4 values)

| Value | Description | Examples |
|-------|-------------|----------|
| `TECHNICAL` | Technical/Engineering positions | Software Developer, QA Engineer, DevOps |
| `BUSINESS` | Business/Management positions | Business Analyst, Product Manager, Sales |
| `CREATIVE` | Creative/Design positions | Game Designer, UI/UX Designer, Content Creator |
| `OPERATIONAL` | Operations/Support positions | Customer Service, HR, Admin |

## Business Rules

### BRS-EVT-001: Request Mapping Constraints
Event chỉ map với Request loại 'Fresher' đã Approved nhưng chưa Posted

**Rationale**: Ngăn chặn xung đột khi một vị trí vừa tuyển qua Job Board vừa tuyển qua Event

**Validation**: At application level khi tạo RequestMapping

### BRS-EVT-002: Track Minimum Requirement
Event phải có ≥1 Track để chuyển sang Published

**Rationale**: Đảm bảo Event có ít nhất một luồng tuyển dụng trước khi public

**Validation**: Precondition check when status changes to PUBLISHED

### BRS-EVT-003: Question Set Lock
Track.QuestionSet phải locked trước khi tạo Report cố định

**Rationale**: Đảm bảo tính nhất quán của báo cáo với cấu trúc câu hỏi

**Validation**: When generating Fixed Report Template

### BRS-EVT-004: Date Range Validation
End date phải sau Start date

**Validation**: Postcondition with `minimum_value` constraint

### BRS-EVT-005: Physical Event Date Range
Physical event date phải nằm giữa Start date và End date

**Rationale**: Physical event là một phần của Master Event lifecycle

**Validation**: Precondition + Postcondition with date range constraints

### BRS-EVT-006: Published Timestamp
Published_at phải được set khi status chuyển sang PUBLISHED

**Validation**: Precondition check when status = PUBLISHED

### BRS-EVT-007: Archived Timestamp
Archived_at phải được set khi status chuyển sang ARCHIVED

**Validation**: Precondition check when status = ARCHIVED

## Vendor Terminology Mapping

| xTalent ECR | Oracle HCM | SAP SuccessFactors | Workday |
|-------------|------------|-------------------|---------|
| Event | Recruiting Event | Recruiting Campaign | Recruiting Event |
| Track | Job Family | Job Category | Job Family |

### Disambiguation Note

Trong Oracle HCM và Workday, "Recruiting Event" thường chỉ là một hoạt động marketing/sourcing đơn giản. Trong xTalent ECR, Event là một Aggregate Root phức tạp quản lý toàn bộ vòng đời tuyển dụng số lượng lớn, từ đăng ký, check-in, test, đến phỏng vấn và offer.

## Architecture Alignment

The ontology aligns with ECR module architecture principles:

1. **Event-Centric vs Job-Centric**: Event is the aggregate root, not Job Requisition
2. **Multi-dimensional**: Supports multiple Tracks within single Event
3. **Dynamic mapping**: Flexible Track ↔ Request relationships via RequestMapping
4. **Extended lifecycle**: Master Event covers pre/during/post physical event phases
5. **Hybrid operations**: Accommodates both online and onsite recruitment flows

## Usage Example

```yaml
Event:
  event_id: "EVT-000001"
  event_code: "FRESHER2026"
  event_name: "Chương trình Tuyển dụng Fresher 2026"
  event_type: FRESHER
  event_status: PUBLISHED
  start_date: "2026-01-01"
  end_date: "2026-03-31"
  physical_event_date: "2026-02-15"
  venue_location: "Trường ĐH Bách Khoa, Hội trường A"
  max_capacity: 1000
  created_by: "TA-00123"
  created_at: "2026-01-01T09:00:00Z"
  published_at: "2026-01-05T14:30:00Z"
  tracks:
    - track_id: "TRK-001"
    - track_id: "TRK-002"
  request_mappings:
    - mapping_id: "MAP-001"
    - mapping_id: "MAP-002"
```

## LinkML Standards Compliance

This ontology follows all standards from `linkml-ontology-guide.md`:

- ✅ Entity has clear description
- ✅ Complete annotations (terminology mapping, module, bounded context)
- ✅ All slots have range and required defined
- ✅ Business rules have IDs (BRS-EVT-xxx)
- ✅ Enum values have descriptions and annotations
- ✅ Naming conventions:
  - Entity: PascalCase
  - Slots: snake_case
  - Enums: PascalCase + "Enum"
  - Enum values: UPPER_SNAKE_CASE
  - Rule IDs: BRS-{MODULE}-{NUMBER}

## Related Entities (To Be Developed)

To complete the ECR module ontology:

### Form & Data Context
- QuestionBank
- QuestionItem
- FieldBlueprint
- RenderingSchema

### Scheduling Context
- Capacity
- Shift
- Slot
- Reservation

### Identity Context
- Candidate
- Profile

## References

1. [linkml-ontology-guide.md](../standards/linkml-ontology-guide.md) - LinkML standards
2. [ecr-ontology-analysis.md](../Reference/ecr-ontology-analysis.md) - ECR entity analysis
3. [Product Specs: Event-Centric Recruitment (ECR) Module.md](../Reference/Product%20Specs_%20Event-Centric%20Recruitment%20%28ECR%29%20Module.md) - Product requirements
4. [Bổ sung tính năng tuyển dụng tập trung sự kiện.md](../Reference/B%E1%BB%95%20sung%20t%C3%ADnh%20n%C4%83ng%20tuy%E1%BB%83n%20d%E1%BB%A5ng%20t%E1%BA%ADp%20trung%20s%E1%BB%B1%20ki%E1%BB%87n.md) - Strategic research

---

**Document Version**: 1.0.0  
**Created**: 2026-02-10  
**Module**: Event-Centric Recruitment (ECR)  
**Ontology Standard**: LinkML YAML
