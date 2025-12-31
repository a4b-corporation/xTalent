---
entity: Department
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
    description: System-generated unique identifier

  - name: code
    type: string
    required: true
    unique: true
    description: Department code (e.g., DEPT-ENG)
    constraints:
      pattern: "^DEPT-[A-Z]{2,10}$"

  - name: name
    type: string
    required: true
    description: Department name

  - name: description
    type: string
    required: false
    description: Department description and purpose

  - name: costCenter
    type: string
    required: false
    description: Associated cost center for budgeting

  - name: status
    type: enum
    required: true
    values: [active, inactive, archived]
    default: active

  - name: effectiveDate
    type: date
    required: true
    description: When department became/becomes active

relationships:
  - name: hasEmployees
    target: Employee
    cardinality: one-to-many
    required: false
    inverse: belongsToDepartment
    description: Employees assigned to this department

  - name: parentDepartment
    target: Department
    cardinality: many-to-one
    required: false
    inverse: childDepartments
    description: Parent in department hierarchy (null for top-level)

  - name: childDepartments
    target: Department
    cardinality: one-to-many
    required: false
    inverse: parentDepartment
    description: Sub-departments

  - name: managedBy
    target: Employee
    cardinality: many-to-one
    required: false
    inverse: managesDepartments
    description: Department head/manager

  - name: hasPositions
    target: Position
    cardinality: one-to-many
    required: false
    inverse: belongsToDepartment
    description: Positions within this department

lifecycle:
  states: [active, inactive, archived]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate
      guard: "No active employees"
    - from: inactive
      to: active
      trigger: reactivate
    - from: [active, inactive]
      to: archived
      trigger: archive
      guard: "No employees ever assigned OR all historical"

policies:
  - name: uniqueCode
    type: validation
    rule: "Department code must be unique"

  - name: noCircularHierarchy
    type: validation
    rule: "Department cannot be its own ancestor in hierarchy"
    expression: "NOT inAncestorChain(this, this)"

  - name: managerMustBelong
    type: business
    rule: "Department manager should be an employee of the department or parent"
---

# Department

## Overview
A **Department** represents an organizational unit within the company. Departments form a hierarchy and serve as the primary organizational structure for grouping employees.

## Business Context
Departments are used for:
- **Organizational structure**: Defining reporting lines and team boundaries
- **Budgeting**: Cost centers are often aligned with departments
- **Reporting**: Headcount, performance metrics, etc. aggregated by department
- **Access control**: Some permissions granted at department level

## Key Relationships
- Contains multiple [[Employee]]s as members
- Has a hierarchy with parent/child [[Department]]s
- Managed by an [[Employee]] (department head)
- Contains [[Position]]s that define available roles

## Lifecycle Notes
- **Active**: Normal operating state
- **Inactive**: Temporarily not accepting new employees, existing employees should be transferred
- **Archived**: Department closed permanently, retained for historical reporting

A department can only be deactivated if it has no active employees. Archived departments cannot be reactivated.

## Domain Rules
- Each department has exactly one parent (except root departments)
- The department hierarchy cannot contain cycles
- A department manager should ideally be a member of that department
- When a department is archived, all positions become inactive