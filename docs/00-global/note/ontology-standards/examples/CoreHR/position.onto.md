---
entity: Position
domain: core-hr
version: "1.0.0"
status: approved
owner: hr-team
tags: [core, organization]

attributes:
  - name: id
    type: string
    required: true
    unique: true

  - name: code
    type: string
    required: true
    unique: true
    description: Position code (e.g., POS-ENG-001)

  - name: title
    type: string
    required: true
    description: Position title (e.g., "Senior Software Engineer")

  - name: jobLevel
    type: enum
    required: true
    values: [entry, mid, senior, lead, manager, director, vp, cLevel]
    description: Level in job hierarchy

  - name: status
    type: enum
    required: true
    values: [open, filled, frozen, closed]
    default: open

  - name: headcount
    type: number
    required: true
    default: 1
    description: Number of employees that can hold this position

  - name: effectiveDate
    type: date
    required: true

  - name: endDate
    type: date
    required: false

relationships:
  - name: belongsToDepartment
    target: Department
    cardinality: many-to-one
    required: true
    inverse: hasPositions
    description: Department this position belongs to

  - name: heldByEmployee
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: holdsPosition
    description: Employee(s) currently in this position

  - name: reportsToPosition
    target: Position
    cardinality: many-to-one
    required: false
    inverse: hasReportingPositions
    description: Supervisor position in org hierarchy

  - name: hasReportingPositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: reportsToPosition
    description: Positions that report to this one

lifecycle:
  states: [open, filled, frozen, closed]
  initial: open
  transitions:
    - from: open
      to: filled
      trigger: assignEmployee
    - from: filled
      to: open
      trigger: vacate
    - from: [open, filled]
      to: frozen
      trigger: freeze
    - from: frozen
      to: open
      trigger: unfreeze
    - from: [open, frozen]
      to: closed
      trigger: close

policies:
  - name: headcountLimit
    type: validation
    rule: "Number of assigned employees cannot exceed headcount"
    expression: "COUNT(heldByEmployee) <= headcount"

  - name: departmentRequired
    type: validation
    rule: "Position must belong to a department"
---

# Position

## Overview
A **Position** represents a specific job slot within the organizational structure. Unlike a Job (generic role template), a Position is a concrete seat that can be filled by an employee.

## Business Context
Positions are used for:
- **Headcount planning**: Each position represents a budgeted slot
- **Org chart**: Positions define the structure, not just employee relationships
- **Succession planning**: Identify critical positions and potential successors

## Key Relationships
- Belongs to a [[Department]]
- Can be held by one or more [[Employee]]s (based on headcount)
- Reports to another [[Position]] (org structure)

## Lifecycle Notes
- **Open**: Available for assignment
- **Filled**: All headcount slots occupied
- **Frozen**: Temporarily unavailable (hiring freeze)
- **Closed**: Position eliminated

## Domain Rules
- A position can only be filled up to its headcount limit
- When a position is closed, any assigned employees must be reassigned
- The position hierarchy (reportsTo) should align with department hierarchy