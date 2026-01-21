# Architecture Decision Records

> **Core HR (CO) Module** | Key Design Decisions
> Date: 2026-01-19

---

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| ADR-001 | Worker vs Employee Separation | Accepted | 2026-01-19 |
| ADR-002 | WorkRelationship Type Model | Accepted | 2026-01-19 |
| ADR-003 | Contract Type Alignment with Labor Code 2019 | Proposed | 2026-01-19 |
| ADR-004 | Supervisor by Assignment (not Person) | Accepted | 2026-01-19 |
| ADR-005 | Facility Three-Tier Hierarchy | Accepted | 2026-01-19 |
| ADR-006 | Event-Driven Cross-Module Integration | Proposed | 2026-01-19 |

---

## ADR-001: Worker vs Employee Separation

**Status**: Accepted

### Context

Enterprise HCM systems need to track people who may have different types of relationships with the organization over time. The question is: should there be one "Employee" record or separate entities for identity vs employment?

### Decision

Implement three-tier model:
1. **Worker**: Lifetime person identity (name, DOB, nationality)
2. **WorkRelationship**: Type of engagement (EMPLOYEE, CONTINGENT, etc.)
3. **Employee**: Employment-specific data (employeeCode, hireDate, BHXH)

```
Worker (1) → WorkRelationship (N) → Employee (0..1 per relationship)
```

### Alternatives Considered

1. **Single Employee entity** (SAP SF style)
   - Rejected: Cannot track alumni, cannot handle re-hire cleanly

2. **Worker + Employment** (Workday style)
   - Considered: Good model but Vietnam needs additional BHXH/contract data
   - Modified: Added Employee entity between WorkRelationship and Assignment

### Consequences

**Positive**:
- Clean separation of concerns
- Supports multi-entity employment
- Alumni tracking possible
- Re-hire creates new WorkRelationship, same Worker

**Negative**:
- More complex than single-entity models
- Requires understanding of hierarchy

**Risks**:
- Developers may confuse entities initially

---

## ADR-002: WorkRelationship Type Model

**Status**: Accepted

### Context

Different types of workers have different legal, payroll, and benefit implications. How should we categorize them?

### Decision

Implement 4-type model:

| Type | Definition | Creates Employee | SI/Payroll |
|------|------------|-----------------|------------|
| **EMPLOYEE** | HĐLĐ/HĐTT with company | Yes | Internal |
| **CONTINGENT** | HĐLĐ with agency | No | External |
| **CONTRACTOR** | HĐDV, self-employed | No | Invoice |
| **NON_WORKER** | No labor relationship | No | None |

### Alternatives Considered

1. **2 types (Employee, Contingent Worker)** - Workday style
   - Rejected: Cannot distinguish Contractor from Contingent in Vietnam context

2. **3 types (add Non-Worker)** - Oracle style
   - Considered: Good but Contractor needs separate category for HĐDV tracking

3. **Enum with subtypes**
   - Rejected: Increases complexity without benefit

### Consequences

**Positive**:
- Covers 100% of Vietnam employment scenarios
- Clear SI/payroll implications per type
- Business rules can be type-specific

**Negative**:
- More types than competitors (complexity)

---

## ADR-003: Contract Type Alignment with Labor Code 2019

**Status**: Proposed

### Context

Vietnam Labor Code 2019 simplified contract types from 3 to 2 categories. Current ontology has 4 contract types (INDEFINITE, FIXED_TERM, SEASONAL, PROBATION). This may cause confusion.

### Decision

Align contract types with Labor Code 2019:

| From (Current) | To (Proposed) | Rationale |
|----------------|---------------|-----------|
| INDEFINITE | INDEFINITE | Keep - valid type |
| FIXED_TERM | FIXED_TERM | Keep - valid type |
| SEASONAL | Remove | Deprecated in 2019 Code |
| PROBATION | Attribute | Probation is a period, not contract type |

### Updated Model

```yaml
Contract:
  contractTypeCode: [INDEFINITE, FIXED_TERM]
  probationDays: number?  # instead of separate type
  probationSalaryPercent: number?
```

### Alternatives Considered

1. **Keep 4 types for flexibility**
   - Rejected: Causes confusion with legal definitions

2. **Use FIXED_TERM with subtype for seasonal**
   - Considered: More complex, no legal basis in 2019 Code

### Consequences

**Positive**:
- Aligns with legal definitions
- Reduces confusion
- Probation rules become attribute-based

**Negative**:
- Requires ontology update
- Migration for existing data

---

## ADR-004: Supervisor by Assignment (not Person)

**Status**: Accepted

### Context

Reporting relationships (org chart) need to be tracked. The question is: should supervisor be linked by Person/Worker or by Assignment?

### Decision

Link supervisor via **Assignment**, not Person:

```yaml
Assignment:
  supervisorAssignmentId: string  # Points to supervisor's Assignment
```

### Rationale

| Approach | Pros | Cons |
|----------|------|------|
| By Person | Simple | Breaks if supervisor changes position |
| By Assignment | Stable | Slightly complex |

When supervisor transfers positions, if linked by Person, the subordinate's reporting line would incorrectly follow the person to new position.

### Alternatives Considered

1. **Supervisor by workerId**
   - Rejected: Reports follow person to wrong position

2. **Supervisor by positionId**
   - Considered: Works for position-centric but fails for Job Management model

### Consequences

**Positive**:
- Org chart stable during supervisor movements
- Works for both Position and Job Management models

**Negative**:
- Must update when subordinate transfers

---

## ADR-005: Facility Three-Tier Hierarchy

**Status**: Accepted

### Context

Work locations need to be tracked for attendance, policies, and asset management. What level of granularity?

### Decision

Implement three-tier facility model:

```
Place (building, campus) → Location (floor, room) → WorkLocation (work site)
```

| Tier | Purpose | Examples |
|------|---------|----------|
| Place | Physical site | VNG Tower, Factory A |
| Location | Space within place | Floor 12, Room 1201 |
| WorkLocation | Where people work | Office HQ, Production Line |

### Rationale

- **Place**: Facilities management, lease tracking
- **Location**: Space planning, asset assignment
- **WorkLocation**: HR assignment, time policies

### Alternatives Considered

1. **Two-tier (Place → WorkLocation)**
   - Rejected: Loses floor/room granularity for space planning

2. **Four-tier (add Building within Campus)**
   - Rejected: Over-engineered, rarely needed

### Consequences

**Positive**:
- Sufficient granularity for most use cases
- Aligns with Oracle/SAP models

**Negative**:
- May need additional tiers for very large campuses

---

## ADR-006: Event-Driven Cross-Module Integration

**Status**: Proposed

### Context

Core HR data changes need to flow to TA, TR, PR modules. How should this integration work?

### Decision

Use **event-driven architecture** with API fallback:

| Pattern | Use Case | Examples |
|---------|----------|----------|
| **Event-Driven** | State changes | employee.hired, contract.signed |
| **API Sync** | Real-time lookups | Get employee by ID |
| **Batch** | Bulk operations | Statutory reports |

### Event Contract

```yaml
event: employee.hired
version: "1.0"
producer: CO
consumers: [TA, TR, PR]
payload:
  employeeId: string
  hireDate: date
  assignmentId: string
  # ... full context for consumers
```

### Alternatives Considered

1. **API-only (no events)**
   - Rejected: Consumers must poll, high latency

2. **Shared database**
   - Rejected: Tight coupling, schema changes break consumers

3. **Message queue only**
   - Considered: Good but need API for queries

### Consequences

**Positive**:
- Loose coupling between modules
- Consumers react in real-time
- API available for queries

**Negative**:
- Event schema must be carefully versioned
- Need event broker infrastructure

---

## Summary

| ADR | Decision | Impact |
|-----|----------|--------|
| ADR-001 | Worker/WorkRelationship/Employee hierarchy | Foundation |
| ADR-002 | 4 WorkRelationship types | Comprehensive coverage |
| ADR-003 | 2 contract types + probation attribute | Labor Code alignment |
| ADR-004 | Supervisor by Assignment | Stable org chart |
| ADR-005 | 3-tier facility hierarchy | Standard granularity |
| ADR-006 | Event-driven integration | Module decoupling |
