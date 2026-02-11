# Track Entity LinkML Ontology - Documentation

## Overview

Comprehensive LinkML ontology for the **Track** entity in the ECR (Event-Centric Recruitment) module. Track represents a recruitment stream within an Event with its own question set, stages, and request mappings.

## File Information

- **File**: `track.yaml`
- **Format**: LinkML YAML
- **Version**: 1.0.0
- **Module**: ECR (Event-Centric Recruitment)
- **Bounded Context**: Event Management Context
- **Parent Aggregate**: Event (Track is NOT an aggregate root)

## Entity Definition: Track

Track is a **recruitment stream** within an Event that represents a specific professional track (e.g., "Game Development", "QC", "Design").

### Key Characteristics

- **Dynamic Question Sets**: Each Track has its own question blueprint that renders dynamically
- **Multi-stage workflow**: Supports custom stages (Check-in → Test → Interview)
- **Request Mapping**: Flexible many-to-many mapping with Job Requisitions via RequestMapping
- **SBD Integration**: Track code is used in candidate SBD generation: `{EventCode}-{TrackCode}-{Random}`

## Core Attributes

### Identification
- `track_id`: Unique identifier with pattern `^TRK-\\d{6}$` (e.g., TRK-000001)
- `track_code`: Short code for SBD generation with pattern `^[A-Z]{2,5}$` (e.g., "GAME", "QC", "DESIGN")
- `track_name`: Full track name (e.g., "Game Development")
- `track_description`: Detailed description

### Configuration
- `track_type`: Range of TrackTypeEnum (TECHNICAL, BUSINESS, CREATIVE, OPERATIONAL)
- `track_status`: Range of TrackStatusEnum (DRAFT, ACTIVE, FULL, CLOSED, ARCHIVED)
- `event_id`: Foreign key to parent Event (required)

### Question Set Management
- `question_set_id`: Reference to FieldBlueprint
- `question_set_locked`: Boolean flag (must lock before Fixed Reports)
- `question_set_locked_at`: Timestamp when locked
- `question_set_locked_by`: User who locked the question set

### Planning & UI
- `target_headcount`: Target number of candidates for this Track
- `display_order`: UI rendering order for candidate selection
- `is_active`: Whether Track is active for candidate registration

### Audit
- `created_by`, `created_at`, `updated_at`: Standard audit fields

### Relationships
- `stages`: Multi-valued reference to Stage value objects (Check-in → Test → Interview)
- `request_mappings`: Multi-valued reference to RequestMapping entities

## Related Components

### Stage (Value Object)
**Embedded in Track** - Workflow phases within a Track (e.g., "Check-in", "Online Test", "Interview")

**DDD Pattern**: Value Object (no independent lifecycle, fully dependent on Track)

**Complete Attributes** (17 slots):
- `stage_id`: Unique identifier with pattern `^STG-\\d{6}$`
- `stage_name`, `stage_description`: Stage identification
- `stage_type`: Range of StageTypeEnum (REGISTRATION, SCREENING, CHECK_IN, TEST, INTERVIEW, ASSESSMENT, OFFER)
- `stage_status`: Range of StageStatusEnum (DRAFT, ACTIVE, PAUSED, COMPLETED, CLOSED, ARCHIVED)
- `stage_order`: Sequential order (1, 2, 3, ...) - defines workflow sequence
- `track_id`: Foreign key to parent Track
- `is_required`, `is_active`: Boolean flags
- `passing_criteria`: JSON format criteria for passing (e.g., `{"min_score": 70}`)
- `auto_advance`: Auto-move candidate to next stage upon passing
- `time_limit_minutes`: Time limit for TEST/ASSESSMENT stages (required for these types)
- `cutoff_score`: Score threshold to pass (0-100)
- `weight`: Stage weight in total score (0-1, sum must equal 1.0 per Track)
- `requires_sbd`: Whether SBD is required for this stage
- `notification_template_id`: Email template reference
- `created_by`, `created_at`, `updated_at`: Audit fields

**Business Rules** (8 rules): BRS-STG-001 to BRS-STG-008
- Stage must belong to existing Track
- Stage order must be unique within Track
- If cutoff_score is set, passing_criteria is required
- TEST/ASSESSMENT types must have time_limit_minutes
- Total weight of all Stages in Track must equal 1.0
- INTERVIEW stage must have is_required = true
- If requires_sbd = true, stage_order must be >= 2
- Auto-advance only works for ACTIVE stages

**Note**: Stage was initially designed as a separate entity, but following DDD principles, it is now correctly modeled as a **Value Object** embedded within Track. Stage has no independent lifecycle and only exists within the context of a Track.

### RequestMapping Entity
Many-to-many mapping between Track and Job Requisitions (Anti-Corruption Layer)

**Attributes**:
- `mapping_id`: Unique identifier with pattern `^MAP-\\d{6}$`
- `track_id`: Foreign key to Track
- `request_id`: Foreign key to Request (from ATS Core)
- `mapping_type`: Range of MappingTypeEnum (PRIMARY, SECONDARY, BACKUP)
- `is_primary`: Boolean flag for primary mapping

## Enumerations

### TrackTypeEnum (4 values)

| Value | Description | Examples |
|-------|-------------|----------|
| `TECHNICAL` | Technical/Engineering positions | Software Developer, QA Engineer, DevOps, Data Engineer |
| `BUSINESS` | Business/Management positions | Business Analyst, Product Manager, Sales, Marketing |
| `CREATIVE` | Creative/Design positions | Game Designer, UI/UX Designer, Content Creator |
| `OPERATIONAL` | Operations/Support positions | Customer Service, HR, Admin, Finance |

### TrackStatusEnum (5 values)

| Value | Description | Visible to Candidates | Allow Registration |
|-------|-------------|----------------------|-------------------|
| `DRAFT` | Track being configured | ❌ No | ❌ No |
| `ACTIVE` | Track active for registration | ✅ Yes | ✅ Yes |
| `FULL` | Target headcount reached | ✅ Yes | ❌ No (show waitlist) |
| `CLOSED` | Registration closed | ❌ No | ❌ No |
| `ARCHIVED` | Archived (read-only) | ❌ No | ❌ No |

### StageTypeEnum (7 values)

| Value | Typical Order | Requires SBD | Requires Time Limit | Description |
|-------|--------------|--------------|-------------------|-------------|
| `REGISTRATION` | 1 | ❌ No | ❌ No | Registration/Profile collection |
| `SCREENING` | 2 | ❌ No | ❌ No | Resume screening |
| `CHECK_IN` | 3 | ✅ Yes | ❌ No | Onsite check-in (kiosk QR scan) |
| `TEST` | 4 | ✅ Yes | ✅ Yes | Assessment (MCQ, Coding, Technical) |
| `INTERVIEW` | 5 | ✅ Yes | ❌ No | Interview (HR, Technical, Panel) - **Always required** |
| `ASSESSMENT` | 6 | ❌ No | ❌ No | Overall assessment/Portfolio review |
| `OFFER` | 7 | ❌ No | ❌ No | Offer stage |

### StageStatusEnum (6 values)

| Value | Allow Candidates | Description |
|-------|-----------------|-------------|
| `DRAFT` | ❌ No | Stage being configured, not active yet |
| `ACTIVE` | ✅ Yes | Stage active, candidates can participate |
| `PAUSED` | ❌ No | Stage temporarily paused (can resume) |
| `COMPLETED` | ❌ No | Stage completed for all candidates |
| `CLOSED` | ❌ No | Stage closed, no new candidates accepted |
| `ARCHIVED` | ❌ No | Stage archived (read-only) |

### PassingStatusEnum (7 values)

Used to track candidate's status at each stage.

| Value | Advance to Next | Description |
|-------|----------------|-------------|
| `PENDING` | ❌ | Not started this stage yet |
| `IN_PROGRESS` | ❌ | Currently performing stage |
| `PASSED` | ✅ | Successfully passed stage |
| `FAILED` | ❌ | Did not pass stage (send rejection email) |
| `SKIPPED` | ✅ | Skipped stage (is_required=false) |
| `NO_SHOW` | ❌ | Did not attend (for CHECK_IN, INTERVIEW) |
| `UNDER_REVIEW` | ❌ | Awaiting review (for ASSESSMENT, INTERVIEW) |

### MappingTypeEnum (3 values)

| Value | Description | is_primary |
|-------|-------------|------------|
| `PRIMARY` | Primary mapping (1 Track → 1 main Request) | true |
| `SECONDARY` | Secondary mapping (Track → multiple secondary Requests) | false |
| `BACKUP` | Backup Request if primary is cancelled | false |

## Business Rules

### BRS-TRK-001: Parent Event Validation
Track phải thuộc về một Event đã tồn tại

**Validation**: Precondition check that event_id exists in system

### BRS-TRK-002: Question Set Lock for Fixed Reports
Question Set phải locked trước khi tạo Fixed Report Template

**References**: BRS-EVT-003, BRS-FORM-001  
**Validation**: Check question_set_locked = true when requesting Fixed Report

### BRS-TRK-003: Lock Metadata Required
Khi lock Question Set, phải set locked_at và locked_by

**Validation**: When question_set_locked = true, both locked_at and locked_by must be set

### BRS-TRK-004: Track Code Uniqueness
Track code phải unique trong cùng một Event

**Rationale**: Tránh conflict khi generate SBD  
**Validation**: Application-level unique constraint on (event_id, track_code)

### BRS-TRK-005: Active Status for Registration
Track status phải ACTIVE để ứng viên có thể đăng ký

**Validation**: UI only shows Tracks where track_status = ACTIVE and is_active = true

### BRS-TRK-006: Dynamic Question Rendering
Track 'Game Dev' hiển thị câu hỏi về ngôn ngữ lập trình, Track 'Game Design' hiển thị Portfolio

**References**: BRS-FORM-002  
**Implementation**: GET /api/forms/schema?track_id={id} returns dynamic schema

### BRS-TRK-007: Display Order Uniqueness
Display order phải unique trong cùng Event

**Validation**: Application-level unique constraint on (event_id, display_order)

## Vendor Terminology Mapping

| xTalent ECR | Oracle HCM | SAP SuccessFactors | Workday |
|-------------|------------|-------------------|---------|
| Track | Job Family | Job Category | Job Family |

### Disambiguation Note

Trong Workday, "Job Family" là phân loại nghề nghiệp cố định (IT, HR, Finance). Trong xTalent ECR, Track là một luồng tuyển dụng động trong 1 Event cụ thể, có thể map với nhiều Job Family khác nhau tùy theo cấu hình Event.

## Key Design Patterns

### 1. Dynamic Question Sets by Track

When a candidate selects a Track, the system renders the corresponding question set:

- **Track "Game Dev"**: Shows questions about programming languages (C++, C#)
- **Track "Game Design"**: Shows Portfolio upload and design skills
- **Implementation**: GET /api/forms/schema?track_id={id}

### 2. Contextual Visibility in Recruiter View

- Default view: Track-specific questions are hidden
- When filtering by Track: Automatically shows corresponding question columns
- Prevents UI clutter while maintaining data integrity

### 3. SBD Generation with Track Code

Candidate SBD format: `{EventCode}-{TrackCode}-{Random}`

**Example**: `F26-GAME-0159`
- EventCode: F26 (Fresher 2026)
- TrackCode: GAME (Game Dev Track)
- Random: 0159

**Benefit**: Easy candidate categorization at physical event venues

## Usage Example

```yaml
Track:
  track_id: "TRK-000001"
  track_code: "GAME"
  track_name: "Game Development"
  track_description: "Software development for game industry"
  track_type: TECHNICAL
  track_status: ACTIVE
  event_id: "EVT-000001"
  question_set_id: "BP-000123"
  question_set_locked: true
  question_set_locked_at: "2026-01-10T14:00:00Z"
  question_set_locked_by: "TA-00123"
  target_headcount: 50
  display_order: 1
  is_active: true
  created_by: "TA-00123"
  created_at: "2026-01-05T10:00:00Z"
  stages:
    - stage_id: "STG-000001"
    - stage_id: "STG-000002"
  request_mappings:
    - mapping_id: "MAP-000001"
```

## Integration with Event

Track is a child entity of Event:
- Each Event can have multiple Tracks
- Track cannot exist without Event (orphan prevention via BRS-TRK-001)
- Track inherits some Event lifecycle constraints

**Import**: track.yaml imports event.yaml to reference Event entity

## LinkML Standards Compliance

- ✅ Entity has clear description
- ✅ Complete annotations (terminology mapping, module, bounded context)
- ✅ All slots have range and required defined
- ✅ Business rules have IDs (BRS-TRK-xxx)
- ✅ Enum values have descriptions and annotations
- ✅ Proper use of imports for Event reference
- ✅ Naming conventions followed (PascalCase, snake_case, UPPER_SNAKE_CASE)

## Stage Workflow Patterns

### Linear Workflow (Most Common)

```
Stage 1 (REGISTRATION) → Stage 2 (SCREENING) → Stage 3 (TEST) → Stage 4 (INTERVIEW) → Stage 5 (OFFER)
```

Defined by `stage_order` field, with total `weight` summing to 1.0.

### Weighted Scoring Example

When calculating overall candidate score across stages:

```
Total Score = (Stage1_Score × Weight1) + (Stage2_Score × Weight2) + ... + (StageN_Score × WeightN)
```

Example:
- CHECK_IN: weight = 0 (attendance only)
- TEST: weight = 0.4, score = 85
- INTERVIEW: weight = 0.6, score = 90

```
Total = (85 × 0.4) + (90 × 0.6) = 34 + 54 = 88
```

## Related Ontologies

1. **event.yaml**: Parent Event entity (imported)
2. **Stage**: Embedded as Value Object within Track (not a separate file)
3. **To be created**:
   - field_blueprint.yaml (question set management)
   - request.yaml (Job Requisition from ATS Core)
   - candidate_stage_progress.yaml (tracking candidate progress through stages)

---

**Document Version**: 1.0.0  
**Created**: 2026-02-10  
**Module**: Event-Centric Recruitment (ECR)  
**Ontology Standard**: LinkML YAML
