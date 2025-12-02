# xTalent Naming Conventions

## General Principles

1. **Consistency**: Use the same naming pattern across the entire system
2. **Clarity**: Names should be self-explanatory
3. **Brevity**: Keep names concise but meaningful
4. **Case Sensitivity**: Follow language/framework conventions

---

## Database Naming

### Tables
- **Format**: `snake_case`, plural
- **Examples**: `workers`, `leave_requests`, `compensation_assignments`

### Columns
- **Format**: `snake_case`, singular
- **Examples**: `worker_id`, `start_date`, `total_amount`

### Primary Keys
- **Format**: `id` (UUID)
- **Type**: UUID v4

### Foreign Keys
- **Format**: `{referenced_table_singular}_id`
- **Examples**: `worker_id`, `position_id`, `legal_entity_id`

### Indexes
- **Format**: `idx_{table}_{column(s)}`
- **Examples**: `idx_workers_email`, `idx_leave_requests_worker_status`

### Constraints
- **Unique**: `uq_{table}_{column(s)}`
- **Check**: `chk_{table}_{description}`
- **Foreign Key**: `fk_{table}_{referenced_table}`

---

## API Naming

### Endpoints
- **Format**: `kebab-case`, plural for collections
- **Examples**: 
  - `/api/workers`
  - `/api/leave-requests`
  - `/api/compensation-plans`

### Resource Hierarchy
```
/api/{module}/{resource}
/api/{module}/{resource}/{id}
/api/{module}/{resource}/{id}/{sub-resource}
```

**Examples**:
```
GET    /api/ta/leave-requests
GET    /api/ta/leave-requests/{id}
POST   /api/ta/leave-requests
PUT    /api/ta/leave-requests/{id}
DELETE /api/ta/leave-requests/{id}
GET    /api/ta/leave-requests/{id}/approvals
```

### Query Parameters
- **Format**: `camelCase`
- **Examples**: `?status=PENDING&startDate=2025-01-01&pageSize=20`

### Request/Response Fields
- **Format**: `camelCase`
- **Examples**: `workerId`, `startDate`, `totalAmount`

---

## Code Naming

### TypeScript/JavaScript

#### Variables & Functions
- **Format**: `camelCase`
- **Examples**: `workerId`, `calculateLeaveBalance()`, `isApproved`

#### Classes & Interfaces
- **Format**: `PascalCase`
- **Examples**: `Worker`, `LeaveRequest`, `ICompensationService`

#### Constants
- **Format**: `UPPER_SNAKE_CASE`
- **Examples**: `MAX_LEAVE_DAYS`, `DEFAULT_CURRENCY`, `API_BASE_URL`

#### Enums
- **Format**: `PascalCase` for enum name, `UPPER_SNAKE_CASE` for values
```typescript
enum LeaveStatus {
  DRAFT = 'DRAFT',
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED'
}
```

#### Private Members
- **Format**: prefix with `_`
- **Examples**: `_internalCache`, `_validateInput()`

### File Names

#### TypeScript/JavaScript
- **Components**: `PascalCase.tsx` - `LeaveRequestForm.tsx`
- **Services**: `camelCase.service.ts` - `leaveRequest.service.ts`
- **Models**: `camelCase.model.ts` - `worker.model.ts`
- **Utils**: `camelCase.util.ts` - `dateFormat.util.ts`

#### HTML/CSS
- **Format**: `kebab-case`
- **Examples**: `leave-request-form.html`, `worker-profile.css`

---

## Module Abbreviations

Use these standard abbreviations for modules:

- **CO**: Core (Core HR)
- **TA**: Time & Absence
- **TR**: Total Rewards
- **PR**: Payroll

**Usage in code**:
```typescript
// Namespace
namespace CO.Worker { }
namespace TA.LeaveRequest { }

// File paths
/src/modules/CO/services/
/src/modules/TA/controllers/

// API paths
/api/co/workers
/api/ta/leave-requests
```

---

## Entity Naming Patterns

### Core Entities
- Person, Worker, LegalEntity, OrgUnit, Job, Position, Assignment

### Time & Absence
- TimeType, TimeBalance, TimeEvent, TimeMovement
- LeaveType, LeaveRequest, LeaveBalance
- AttendanceRecord, Schedule, Shift

### Total Rewards
- CompensationPlan, CompensationComponent, CompensationAssignment
- Grade, GradeStep
- Benefit, BenefitPlan, BenefitEnrollment

### Payroll
- PayrollPeriod, PayrollRun, PayrollElement, PayrollResult
- TaxRule, DeductionRule

---

## Event Naming

### Format
`{Entity}{Action}` in PascalCase

### Examples
- `WorkerCreated`
- `LeaveRequestSubmitted`
- `LeaveRequestApproved`
- `CompensationAssigned`
- `PayrollCalculated`

---

## Status/State Values

### Format
`UPPER_SNAKE_CASE`

### Common Statuses
- **Generic**: `ACTIVE`, `INACTIVE`, `DELETED`
- **Workflow**: `DRAFT`, `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`
- **Worker**: `ACTIVE`, `TERMINATED`, `SUSPENDED`, `ON_LEAVE`
- **Position**: `ACTIVE`, `INACTIVE`, `FROZEN`, `ELIMINATED`

---

## Boolean Fields

### Prefix Conventions
- **is**: State - `isActive`, `isPrimary`, `isApproved`
- **has**: Possession - `hasChildren`, `hasApprovals`
- **can**: Permission - `canApprove`, `canEdit`
- **should**: Recommendation - `shouldNotify`, `shouldEscalate`

### Examples
```typescript
interface Worker {
  isActive: boolean;
  hasTerminationDate: boolean;
  canRequestLeave: boolean;
}
```

---

## Date/Time Fields

### Naming
- **Date only**: `{purpose}Date` - `startDate`, `endDate`, `hireDate`
- **DateTime**: `{purpose}DateTime` - `createdDateTime`, `approvedDateTime`
- **Time only**: `{purpose}Time` - `startTime`, `endTime`

### Audit Fields
Standard audit fields for all entities:
- `createdAt`: datetime
- `createdBy`: string (user ID)
- `updatedAt`: datetime
- `updatedBy`: string (user ID)
- `deletedAt`: datetime (nullable, for soft delete)

---

## Amount/Quantity Fields

### Format
`{purpose}{Unit}`

### Examples
- `totalAmount`, `netAmount`, `taxAmount`
- `totalDays`, `usedDays`, `availableDays`
- `totalHours`, `workedHours`, `overtimeHours`

---

## ID Fields

### Primary Key
- Always `id` (UUID)

### Foreign Keys
- `{entity}Id` - `workerId`, `positionId`, `leaveTypeId`

### Composite Keys (if needed)
- Combine with underscore: `worker_id_year_leave_type_id`

---

## Documentation Files

### Ontology
- `{module}-ontology.yaml`
- `{module}-glossary.md`
- `{module}-state-machines.md`

### Concept
- `01-concept-overview.md`
- `02-conceptual-guide.md`
- `{entity}-concept.md` (in entity-guides folder)

### Specification
- `01-behaviour-spec.md`
- `02-use-cases.md`
- `{scenario}-scenario.md` (in scenarios folder)

### Design
- `01-data-model.dbml`
- `02-data-model-notes.md`
- `03-event-model.md`

### API
- `{module}-openapi.yaml`
- `api-guidelines.md`

### UI
- `{screen}-spec.md` (in screens folder)
- `{screen}.html` (in mockups folder)

---

## Version Naming

### API Versions
- **Format**: `v{major}`
- **Examples**: `v1`, `v2`
- **URL**: `/api/v1/workers`

### Document Versions
- **Format**: `{major}.{minor}.{patch}`
- **Examples**: `1.0.0`, `1.2.3`, `2.0.0`

---

## Test Naming

### Test Files
- `{module}.test.ts` - unit tests
- `{module}.integration.test.ts` - integration tests
- `{feature}.e2e.ts` - E2E tests

### Test Cases
```typescript
describe('LeaveRequestService', () => {
  describe('createLeaveRequest', () => {
    it('should create leave request when worker has sufficient balance', () => {
      // test
    });
    
    it('should throw error when balance is insufficient', () => {
      // test
    });
  });
});
```

---

## Environment Variables

### Format
`UPPER_SNAKE_CASE` with prefix

### Examples
```
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=xtalent

# API
API_BASE_URL=https://api.xtalent.com
API_VERSION=v1

# Module specific
TA_MAX_LEAVE_DAYS=30
TR_DEFAULT_CURRENCY=USD
```

---

## Error Codes

### Format
`{MODULE}_{CATEGORY}_{SPECIFIC}`

### Examples
```
TA_LEAVE_INSUFFICIENT_BALANCE
TA_LEAVE_OVERLAPPING_DATES
TR_COMP_INVALID_AMOUNT
CO_WORKER_NOT_FOUND
```

---

## Best Practices

### DO ✅
- Use meaningful, descriptive names
- Follow language/framework conventions
- Be consistent across the codebase
- Use abbreviations sparingly and document them
- Use plural for collections, singular for items

### DON'T ❌
- Use single letter variables (except in loops: i, j, k)
- Use abbreviations that aren't widely known
- Mix naming conventions (camelCase vs snake_case)
- Use generic names like `data`, `temp`, `value`
- Use Hungarian notation (strName, intCount)

---

## Checklist

When naming something new, ask:

- [ ] Is it consistent with existing names?
- [ ] Is it self-explanatory?
- [ ] Does it follow the convention for its type?
- [ ] Would a new team member understand it?
- [ ] Is it searchable in the codebase?
