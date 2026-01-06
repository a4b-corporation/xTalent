---
entity: Contract
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [work-relationship, contract, core]

classification:
  type: AGGREGATE_ROOT
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

  - name: contractTypeCode
    type: enum
    required: true
    values: [INDEFINITE, FIXED_TERM, SEASONAL, PROBATION]
    description: Contract type

  - name: templateId
    type: string
    required: false
    description: FK to ContractTemplate

  - name: contractNumber
    type: string
    required: true
    description: Contract number
    constraints:
      max: 100

  - name: startDate
    type: date
    required: true
    description: Contract start date

  - name: endDate
    type: date
    required: false
    description: Contract end date

  - name: primaryFlag
    type: boolean
    required: true
    default: false
    description: Is primary contract

  - name: parentContractId
    type: string
    required: false
    description: Parent contract (for amendments)

  - name: parentRelationshipType
    type: enum
    required: false
    values: [AMENDMENT, ADDENDUM, RENEWAL, SUPERSESSION]
    description: Relationship to parent contract

  - name: amendmentTypeCode
    type: string
    required: false
    description: Amendment type if applicable

  - name: workScheduleTypeCode
    type: string
    required: false
    description: Work schedule type

relationships:
  - name: belongsToEmployee
    target: Employee
    cardinality: many-to-one
    required: true
    inverse: hasContracts
    description: Employee of contract

  - name: usesTemplate
    target: ContractTemplate
    cardinality: many-to-one
    required: false
    inverse: usedByContracts
    description: Template used

  - name: parentContract
    target: Contract
    cardinality: many-to-one
    required: false
    description: Parent contract

lifecycle:
  states: [draft, active, expired, terminated]
  initial: draft
  terminal: [expired, terminated]
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: expired
      trigger: expire
      guard: "endDate reached"
    - from: active
      to: terminated
      trigger: terminate

actions:
  - name: create
    description: Create contract
    requiredFields: [employeeId, contractTypeCode, contractNumber, startDate]

  - name: activate
    description: Activate contract
    triggersTransition: activate

  - name: amend
    description: Create amendment
    affectsRelationships: [parentContract]

  - name: renew
    description: Renew contract
    affectsRelationships: [parentContract]

  - name: terminate
    description: Early termination
    triggersTransition: terminate

policies:
  - name: uniqueNumber
    type: validation
    rule: "Contract number must be unique"

  - name: validDates
    type: validation
    rule: "endDate >= startDate if specified"

  - name: fixedTermLimit
    type: business
    rule: "FIXED_TERM contracts max 36 months per Vietnam Labor Code"

  - name: renewalLimit
    type: business
    rule: "Maximum 2 consecutive FIXED_TERM contracts before conversion to INDEFINITE"
---

# Contract

## Overview

A **Contract** represents the employment agreement between an [[Employee]] and the organization. Contracts define legal terms, duration, and working conditions. They follow Vietnam Labor Code requirements including contract types, renewal limits, and mandatory conversions.

```mermaid
mindmap
  root((Contract))
    Types
      INDEFINITE["Không xác định thời hạn"]
      FIXED_TERM["Có thời hạn"]
      SEASONAL["Thời vụ"]
      PROBATION["Thử việc"]
    Relationships
      Parent Contract
      Amendment
      Addendum
      Renewal
    Document
      contractNumber
      startDate
      endDate
```

## Business Context

### Key Stakeholders
- **HR Admin**: Creates, manages, renews contracts
- **Legal**: Reviews terms, ensures compliance
- **Employee**: Signs, receives copy
- **Payroll**: Uses contract type for tax/SI calculation

### Business Processes
This entity is central to:
- **Onboarding**: Contract creation part of hire process
- **Contract Renewal**: Tracking expiry, renewal workflow
- **Compliance**: Labor law adherence (contract types, limits)
- **Termination**: Contract termination triggers exit process

### Business Value
Contract is the legal basis for employment. Proper management ensures compliance with Vietnam Labor Code and protects both organization and employee.

## Attributes Guide

### Identification
- **contractNumber**: Official contract reference. Format: HD-YYYY-XXXX. Printed on physical contract.
- **employeeId**: Links to [[Employee]]. Each contract belongs to exactly one employee.

### Contract Terms
- **contractTypeCode**: Type per Vietnam Labor Code 2019:
  - *INDEFINITE*: Không xác định thời hạn - preferred for long-term
  - *FIXED_TERM*: Có thời hạn - 12-36 months
  - *SEASONAL*: Thời vụ - < 12 months for seasonal work
  - *PROBATION*: Thử việc - max 60 days for senior roles
- **startDate / endDate**: Contract validity period. INDEFINITE has no endDate.
- **workScheduleTypeCode**: Full-time, Part-time, Shift work.

### Template & Amendments
- **templateId**: Links to [[ContractTemplate]] for standardized terms.
- **parentContractId**: For amendments/renewals, links to original contract.
- **parentRelationshipType**: How this contract relates to parent:
  - *AMENDMENT*: Modifies existing terms (salary, position)
  - *ADDENDUM*: Adds new terms (bonus agreement)
  - *RENEWAL*: Extends duration
  - *SUPERSESSION*: Replaces parent entirely

## Relationships Explained

```mermaid
erDiagram
    CONTRACT }o--|| EMPLOYEE : "belongsToEmployee"
    CONTRACT }o--o| CONTRACT_TEMPLATE : "usesTemplate"
    CONTRACT }o--o| CONTRACT : "parentContract"
```

### Employee Link
- **belongsToEmployee** → [[Employee]]: The employee party to this contract. Employee may have multiple contracts (e.g., initial + amendments).

### Template
- **usesTemplate** → [[ContractTemplate]]: Standardized template providing default terms, clauses, probation rules.

### Contract Chain
- **parentContract** → [[Contract]]: Links amendments/renewals to original. Enables full contract history tracking.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Being prepared, not yet signed | Not legally binding |
| **active** | Currently in force | Employee actively working |
| **expired** | End date reached normally | Auto-transition, no action needed |
| **terminated** | Early termination | May trigger consequences |

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> draft: create
    
    draft --> active: activate (sign)
    
    active --> expired: expire (auto on endDate)
    active --> terminated: terminate (early)
    
    expired --> [*]
    terminated --> [*]
```

### Vietnam Labor Code Compliance Flow

```mermaid
flowchart TD
    A[PROBATION] -->|Max 60 days| B[FIXED_TERM 1]
    B -->|Max 36 months| C{Renew?}
    C -->|Yes| D[FIXED_TERM 2]
    C -->|No| E[Terminate]
    D -->|Max 36 months| F{Renew again?}
    F -->|Yes| G[MUST: INDEFINITE]
    F -->|No| H[Terminate]
```

## Actions & Operations

### create
**Who**: HR Admin  
**When**: New employee or contract renewal  
**Required**: employeeId, contractTypeCode, contractNumber, startDate  
**Process**:
1. Select or create from template
2. Populate contract details
3. Create in draft state

### activate
**Who**: HR Admin  
**When**: Contract signed by both parties  
**Process**:
1. Verify all required fields
2. Transition to active
3. Notify payroll, IT

### amend
**Who**: HR Admin  
**When**: Changing terms (salary, position)  
**Process**:
1. Create new contract with parentRelationshipType = AMENDMENT
2. Link to parent contract
3. Set amendmentTypeCode (SALARY_CHANGE, POSITION_CHANGE)

### renew
**Who**: HR Admin  
**When**: Extending expiring contract  
**Process**:
1. Check renewal limits (max 2 FIXED_TERM)
2. Create new contract with parentRelationshipType = RENEWAL
3. If 3rd renewal, force INDEFINITE type

## Business Rules

### Data Integrity

#### Unique Number (uniqueNumber)
**Rule**: Contract number globally unique.  
**Reason**: Legal document reference.  
**Violation**: System prevents save.

#### Date Validation (validDates)
**Rule**: endDate >= startDate.  
**Reason**: Logical consistency.  
**Violation**: System prevents save.

### Vietnam Labor Code Compliance

#### Fixed-Term Limit (fixedTermLimit)
**Rule**: FIXED_TERM max 36 months.  
**Reason**: Article 22, Labor Code 2019.  
**Violation**: Warning shown, recommend INDEFINITE.

#### Renewal Limit (renewalLimit)
**Rule**: Max 2 consecutive FIXED_TERM contracts.  
**Reason**: Article 20, Labor Code 2019. Third renewal must be INDEFINITE.  
**Implementation**: System warns at 2nd renewal, blocks 3rd unless INDEFINITE.

## Examples

### Example 1: Standard INDEFINITE Contract
- **contractNumber**: HD-2023-00042
- **contractTypeCode**: INDEFINITE
- **startDate**: 2023-01-15
- **endDate**: null
- **primaryFlag**: true

### Example 2: Amendment for Salary Change
- **contractNumber**: HD-2023-00042-A1
- **parentContractId**: HD-2023-00042
- **parentRelationshipType**: AMENDMENT
- **amendmentTypeCode**: SALARY_CHANGE
- **startDate**: 2024-01-01

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[Employee]] | belongsToEmployee | Contract holder |
| [[ContractTemplate]] | usesTemplate | Standard template |
| [[Contract]] | parentContract | Parent (for amendments) |
