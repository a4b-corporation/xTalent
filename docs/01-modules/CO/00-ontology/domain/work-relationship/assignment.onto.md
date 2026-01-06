---
entity: Assignment
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [work-relationship, assignment, core]

classification:
  type: ENTITY
  category: work-relationship

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: employeeId
    type: string
    required: true
    description: FK to Employee

  - name: positionId
    type: string
    required: false
    description: FK to Position

  - name: businessUnitId
    type: string
    required: true
    description: FK to BusinessUnit

  - name: primaryLocationId
    type: string
    required: false
    description: FK to WorkLocation

  - name: statusCode
    type: enum
    required: true
    values: [ACTIVE, SUSPENDED, ENDED]
    description: Assignment status

  - name: fte
    type: number
    required: false
    description: FTE allocation
    constraints:
      min: 0.1
      max: 1.0

  - name: supervisorAssignmentId
    type: string
    required: false
    description: Supervisor's assignment (reporting line)

  - name: isPrimary
    type: boolean
    required: true
    default: true
    description: Primary assignment

  - name: startDate
    type: date
    required: true
    description: Assignment start

  - name: endDate
    type: date
    required: false
    description: Assignment end

  - name: reasonCode
    type: string
    required: false
    description: Reason for assignment/change

relationships:
  - name: assignedToEmployee
    target: Employee
    cardinality: many-to-one
    required: true
    inverse: hasAssignments
    description: Employee

  - name: assignedToPosition
    target: Position
    cardinality: many-to-one
    required: false
    inverse: hasAssignments
    description: Position

  - name: inBusinessUnit
    target: BusinessUnit
    cardinality: many-to-one
    required: true
    description: BU

  - name: atLocation
    target: WorkLocation
    cardinality: many-to-one
    required: false
    description: Work location

  - name: supervisedBy
    target: Assignment
    cardinality: many-to-one
    required: false
    description: Supervisor assignment

lifecycle:
  states: [active, suspended, ended]
  initial: active
  terminal: [ended]
  transitions:
    - from: active
      to: suspended
      trigger: suspend
    - from: suspended
      to: active
      trigger: resume
    - from: [active, suspended]
      to: ended
      trigger: end

actions:
  - name: create
    description: Create assignment
    requiredFields: [employeeId, businessUnitId, startDate]

  - name: transfer
    description: Transfer to new position/BU
    affectsAttributes: [positionId, businessUnitId]

  - name: changeSupervisor
    description: Change reporting line
    affectsAttributes: [supervisorAssignmentId]

  - name: end
    description: End assignment
    triggersTransition: end

policies:
  - name: onePrimary
    type: business
    rule: "Employee has exactly one primary assignment at any time"

  - name: validPosition
    type: validation
    rule: "Position must have available slot"

  - name: supervisorHierarchy
    type: validation
    rule: "Supervisor cannot report to subordinate (no cycles)"
---

# Assignment

## Overview

An **Assignment** links an [[Employee]] to a [[Position]] and [[BusinessUnit]], defining where they work and who they report to. Assignments are the core of the organizational structure - they create the org chart, determine cost allocation, and establish reporting relationships.

```mermaid
mindmap
  root((Assignment))
    Links
      Employee
      Position
      BusinessUnit
      WorkLocation
    Reporting
      Supervisor["Supervisor Assignment"]
    Allocation
      FTE
      isPrimary
```

## Business Context

### Key Stakeholders
- **Manager**: Owns the assignment, approves changes
- **HR Admin**: Creates assignments, processes transfers
- **Finance**: Uses for cost allocation (BU cost center)
- **Org Design**: Analyzes org structure via assignments

### Business Processes
This entity is central to:
- **Onboarding**: Assignment created as part of hire process
- **Transfers**: Moving employees between positions/BUs
- **Org Chart**: Supervisor chain = org hierarchy
- **Headcount**: Assignment count = actual headcount per BU

### Business Value
Assignment is the operational placement of people. It answers: "Where do you work?" "Who do you report to?" "What do you do?"

## Attributes Guide

### Core Links
- **employeeId**: The employee being assigned. Required.
- **positionId**: The position slot. Optional for matrix/project assignments.
- **businessUnitId**: The organizational unit. Required - for cost allocation.

### Work Details
- **primaryLocationId**: Where employee physically works. For remote workers, may be home office.
- **fte**: Full-time equivalent. 1.0 = full-time, 0.5 = half-time. Used for headcount calculations.
- **isPrimary**: Employee's main assignment. Determines primary manager, cost center.

### Reporting Line
- **supervisorAssignmentId**: Points to supervisor's assignment (not person). This creates the reporting chain.
  - When supervisor changes position, their subordinates' reporting unchanged
  - When employee transferred, reporting line ends with this assignment

## Relationships Explained

```mermaid
erDiagram
    ASSIGNMENT }o--|| EMPLOYEE : "assignedToEmployee"
    ASSIGNMENT }o--o| POSITION : "assignedToPosition"
    ASSIGNMENT }o--|| BUSINESS_UNIT : "inBusinessUnit"
    ASSIGNMENT }o--o| WORK_LOCATION : "atLocation"
    ASSIGNMENT }o--o| ASSIGNMENT : "supervisedBy"
```

### Employee Link
- **assignedToEmployee** → [[Employee]]: The person. Employee can have multiple assignments (primary + secondary/project).

### Position Link
- **assignedToPosition** → [[Position]]: The role slot. Position may have multiple assignments if maxIncumbents > 1.

### Organization
- **inBusinessUnit** → [[BusinessUnit]]: Cost center and organizational home.
- **atLocation** → [[WorkLocation]]: Physical work location.

### Hierarchy
- **supervisedBy** → [[Assignment]]: Links to supervisor's assignment. Creates reporting tree without person dependency.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **active** | Currently working | Included in headcount, org chart |
| **suspended** | Temporary hold | May exclude from active headcount |
| **ended** | Assignment complete | Historical only |

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> active: create
    
    active --> suspended: suspend
    suspended --> active: resume
    
    active --> ended: end
    suspended --> ended: end
    
    ended --> [*]
```

### Transfer Workflow

```mermaid
flowchart TD
    A[Transfer Request] --> B[Create New Assignment]
    B --> C[Set Start Date = Transfer Date]
    C --> D[End Current Assignment]
    D --> E[Update Position Counts]
```

## Actions & Operations

### create
**Who**: HR Admin  
**When**: Hire, transfer, additional assignment  
**Required**: employeeId, businessUnitId, startDate  
**Process**:
1. Verify position has available slot (if applicable)
2. Verify employee has active status
3. Create assignment in active state
4. Update position incumbent count

### transfer
**Who**: HR Admin with manager approval  
**When**: Moving to new position or BU  
**Process**:
1. End current assignment
2. Create new assignment with new position/BU
3. Reporting line may change

### changeSupervisor
**Who**: HR Admin  
**When**: Reorg, manager change  
**Process**:
1. Verify no circular reporting
2. Update supervisorAssignmentId

### end
**Who**: HR Admin  
**When**: Transfer, termination, project end  
**Process**:
1. Set endDate
2. Update position incumbent count
3. Status → ended

## Business Rules

### Data Integrity

#### One Primary (onePrimary)
**Rule**: Exactly one primary assignment per employee at any time.  
**Reason**: Determines main manager, cost allocation.  
**Violation**: System enforces; new primary demotes old.

#### Valid Position (validPosition)
**Rule**: Position must have available slot.  
**Reason**: Prevents overstaffing.  
**Violation**: System blocks if maxIncumbents reached.

### Hierarchy

#### No Cycles (supervisorHierarchy)
**Rule**: Supervisor chain cannot form cycles.  
**Reason**: Org hierarchy must be a tree.  
**Violation**: System prevents save.

## Examples

### Example 1: Standard Assignment
- **employeeId**: EMP-00042
- **positionId**: POS-00123
- **businessUnitId**: ENGINEERING
- **fte**: 1.0
- **isPrimary**: true
- **supervisorAssignmentId**: ASN-00010

### Example 2: Secondary Assignment (Project)
- **employeeId**: EMP-00042
- **positionId**: null (project-based)
- **businessUnitId**: INNOVATION_LAB
- **fte**: 0.2
- **isPrimary**: false

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Employee]] | assignedToEmployee | The employee |
| [[Position]] | assignedToPosition | The position |
| [[BusinessUnit]] | inBusinessUnit | Cost center |
| [[WorkLocation]] | atLocation | Work site |
