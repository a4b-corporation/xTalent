# RequestMapping Entity LinkML Ontology - Documentation

## Overview

Comprehensive LinkML ontology for the **RequestMapping** entity in the ECR (Event-Centric Recruitment) module. RequestMapping serves as an Anti-Corruption Layer (ACL) between Event Context and ATS Core, managing many-to-many relationships between Tracks and Job Requisitions.

## File Information

- **File**: `request_mapping.yaml`
- **Format**: LinkML YAML
- **Version**: 1.0.0
- **Module**: ECR (Event-Centric Recruitment)
- **Bounded Context**: Event Management Context
- **DDD Pattern**: Entity (Anti-Corruption Layer)

## Entity Definition: RequestMapping

RequestMapping is an **Entity** that manages the many-to-many relationship between Track (Event Context) and Request (ATS Core).

### Key Characteristics

- **Anti-Corruption Layer**: Protects Event Context from changes in ATS Core
- **Many-to-Many with Metadata**: Not just a junction table, but a full entity with business logic
- **Independent Lifecycle**: Can be created/removed without affecting Track or Request
- **Business Constraints**: Only 'Fresher' type Requests that are 'Approved' but not 'Posted'

## Core Attributes

### Identification
- `mapping_id`: Unique identifier with pattern `^MAP-\\d{6}$` (e.g., MAP-000001)

### Relationship Keys
- `track_id`: Foreign key to Track (required)
- `request_id`: Foreign key to Request in ATS Core (required)
- `event_id`: Denormalized Event ID for faster filtering

### Mapping Configuration
- `mapping_type`: Range of MappingTypeEnum (PRIMARY, SECONDARY, BACKUP)
- `is_primary`: Boolean flag (only one PRIMARY per Track allowed)
- `mapping_status`: Range of MappingStatusEnum (ACTIVE, INACTIVE, SUSPENDED, EXPIRED)
- `priority_order`: Integer (1 = highest priority) for fallback ordering

### External System Sync (Read-only)
- `request_type`: Synced from ATS Core (must be 'FRESHER')
- `request_status`: Synced from ATS Core (must be 'APPROVED' and NOT 'POSTED')

### Metadata
- `notes`: Optional notes about the mapping
- `created_by`, `created_at`, `updated_at`: Standard audit fields
- `deactivated_at`, `deactivated_by`: Deactivation audit trail

## Enumerations

### MappingTypeEnum (3 values)

| Value | Priority | is_primary | Usage |
|-------|---------|-----------|-------|
| `PRIMARY` | 1 | true | Main job requisition for this Track |
| `SECONDARY` | 2 | false | Additional job requisitions sharing same candidate pool |
| `BACKUP` | 3 | false | Fallback job requisition if primary is cancelled |

### MappingStatusEnum (4 values)

| Value | Allow Candidate Assignment | Description |
|-------|---------------------------|-------------|
| `ACTIVE` | ✅ Yes | Mapping is currently active |
| `INACTIVE` | ❌ No | Mapping deactivated (requires deactivation metadata) |
| `SUSPENDED` | ❌ No | Mapping temporarily suspended (can reactivate) |
| `EXPIRED` | ❌ No | Mapping expired (Request already closed, read-only) |

## Business Rules

### BRS-MAP-001: Request Type Validation
Request phải là type 'FRESHER'

**Rationale**: Prevents mapping with other Request types (Regular Job, Internship, etc.)  
**Reference**: BRS-EVT-001

### BRS-MAP-002: Request Status Validation
Request phải Approved nhưng chưa Posted

**Rationale**: Avoids conflict between Event recruitment and Job Board recruitment  
**Validation**: Request.status must be 'APPROVED' AND NOT 'POSTED'  
**Reference**: BRS-EVT-001

### BRS-MAP-003: Single PRIMARY Mapping per Track
Chỉ một PRIMARY mapping per Track

**Rationale**: Each Track can only have one main Request  
**Validation**: Unique constraint on (track_id, is_primary=true)

### BRS-MAP-004: Consistency Check
Nếu mapping_type = PRIMARY thì is_primary = true

**Rationale**: Ensures consistency between mapping_type and is_primary flag

### BRS-MAP-005: Referential Integrity
Track và Request phải tồn tại trong hệ thống

**Validation**:
- Track must exist in Event Context
- Request must exist in ATS Core

### BRS-MAP-006: No Duplicate Mappings
Không duplicate mapping cho cùng (track_id, request_id)

**Validation**: Unique constraint on (track_id, request_id) WHERE mapping_status = ACTIVE

### BRS-MAP-007: Deactivation Audit Trail
Khi deactivate mapping, phải set deactivated_at và deactivated_by

**Validation**: When mapping_status = INACTIVE, both deactivated_at and deactivated_by must be set

## Vendor Terminology Mapping

| xTalent ECR | Oracle HCM | SAP SuccessFactors | Workday |
|-------------|------------|-------------------|---------|
| RequestMapping | Job Opening Allocation | Requisition Assignment | Job Posting Link |

### Disambiguation Note

Trong Oracle/SAP, "Job Opening" thường direct link với Job Posting. Trong xTalent ECR, RequestMapping là một ACL layer cho phép:
- 1 Track map với nhiều Requests (PRIMARY + SECONDARY + BACKUP)
- 1 Request được chia sẻ bởi nhiều Tracks
- Metadata về priority và type

## Integration Pattern: Anti-Corruption Layer

RequestMapping implements the **Anti-Corruption Layer** pattern from DDD:

```
┌─────────────────┐         ┌──────────────────┐         ┌──────────────┐
│  Event Context  │ ──────> │ RequestMapping   │ ──────> │  ATS Core    │
│  (Track)        │         │  (ACL Entity)    │         │  (Request)   │
└─────────────────┘         └──────────────────┘         └──────────────┘
```

**Benefits**:
1. Event Context không phụ thuộc vào ATS Core data model
2. Có thể change ATS system mà không impact Event Context
3. Filter và validate data từ ATS Core trước khi vào Event Context
4. Add metadata (mapping_type, priority_order) không có sẵn trong ATS Core

## Usage Example

```yaml
RequestMapping:
  mapping_id: "MAP-000001"
  track_id: "TRK-000001"
  request_id: "REQ-F26-GAME-001"
  mapping_type: PRIMARY
  is_primary: true
  mapping_status: ACTIVE
  request_type: "FRESHER"
  request_status: "APPROVED"
  event_id: "EVT-000001"
  priority_order: 1
  notes: "Main requisition for Game Dev Track"
  created_by: "TA-00123"
  created_at: "2026-01-10T10:00:00Z"
```

## Lifecycle Management

### Creating a Mapping

1. TA selects a Track in Event
2. TA searches for available Requests from ATS Core
3. System validates:
   - Request type = 'FRESHER' (BRS-MAP-001)
   - Request status = 'APPROVED' and NOT 'POSTED' (BRS-MAP-002)
   - No existing ACTIVE mapping for same (track_id, request_id) (BRS-MAP-006)
4. If mapping_type = PRIMARY, check only one PRIMARY per Track (BRS-MAP-003)
5. Create RequestMapping with mapping_status = ACTIVE

### Deactivating a Mapping

1. TA clicks "Deactivate" on a mapping
2. System sets:
   - mapping_status = INACTIVE
   - deactivated_at = current timestamp
   - deactivated_by = current user ID
3. System validates BRS-MAP-007
4. Candidates already assigned to Request remain unchanged
5. New candidates cannot be assigned to this mapping

## LinkML Standards Compliance

- ✅ Entity has clear description with DDD pattern annotation
- ✅ Complete annotations (terminology mapping, module, bounded_context, integration_pattern)
- ✅ All slots have range and required defined
- ✅ Business rules have IDs (BRS-MAP-xxx)
- ✅ Enum values have descriptions and annotations
- ✅ Proper use of imports for Track reference
- ✅ Naming conventions followed (PascalCase, snake_case, UPPER_SNAKE_CASE)
- ✅ Anti-Corruption Layer pattern documented

## Related Ontologies

1. **track.yaml**: Parent Track entity (imported)
2. **event.yaml**: Grandparent Event entity (via Track)
3. **To be created**:
   - request.yaml (Job Requisition from ATS Core)
   - candidate_request_assignment.yaml (tracking candidate assignments to Requests)

---

**Document Version**: 1.0.0  
**Created**: 2026-02-11  
**Module**: Event-Centric Recruitment (ECR)  
**Ontology Standard**: LinkML YAML  
**DDD Pattern**: Entity (Anti-Corruption Layer)
