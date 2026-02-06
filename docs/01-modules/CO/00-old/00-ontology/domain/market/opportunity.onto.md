---
entity: Opportunity
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [market, opportunity, core]

classification:
  type: AGGREGATE_ROOT
  category: market

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: oppCode
    type: string
    required: true
    unique: true
    description: Opportunity code

  - name: oppTitle
    type: string
    required: true
    description: Opportunity title

  - name: oppTypeCode
    type: enum
    required: true
    values: [ROLE, PROJECT, GIG, MENTORING, SHADOW]
    description: Opportunity type

  - name: description
    type: string
    required: false
    description: Full description

  - name: ownerUnitId
    type: string
    required: false
    description: Owning BU

  - name: hostEmployeeId
    type: string
    required: false
    description: Opportunity host/owner

  - name: targetJobId
    type: string
    required: false
    description: Target job (if role)

  - name: targetPositionId
    type: string
    required: false
    description: Target position (if slot)

  - name: requiredSkills
    type: array
    required: false
    description: List of required skill codes

  - name: estimatedHoursPerWeek
    type: number
    required: false
    description: Time commitment

  - name: openDate
    type: date
    required: true
    description: Open date

  - name: closeDate
    type: date
    required: false
    description: Close date

  - name: statusCode
    type: enum
    required: true
    values: [DRAFT, OPEN, CLOSED, FILLED, CANCELLED]
    description: Opportunity status

relationships:
  - name: inMarket
    target: TalentMarket
    cardinality: many-to-one
    required: false
    inverse: hasOpportunities
    description: Market

  - name: targetJob
    target: Job
    cardinality: many-to-one
    required: false
    description: Target job

  - name: hasApplications
    target: OpportunityApplication
    cardinality: one-to-many
    required: false
    description: Applications received

lifecycle:
  states: [draft, open, closed, filled, cancelled]
  initial: draft
  terminal: [closed, filled, cancelled]
  transitions:
    - from: draft
      to: open
      trigger: publish
    - from: open
      to: filled
      trigger: fill
    - from: open
      to: closed
      trigger: close
    - from: [draft, open]
      to: cancelled
      trigger: cancel

actions:
  - name: create
    description: Create opportunity
    requiredFields: [oppCode, oppTitle, oppTypeCode, openDate]

  - name: publish
    description: Make opportunity visible
    triggersTransition: publish

  - name: apply
    description: Employee applies
    producesArtifacts: [OpportunityApplication]

  - name: fill
    description: Select candidate
    triggersTransition: fill

policies:
  - name: uniqueCode
    type: validation
    rule: "Opportunity code must be unique"

  - name: closeDateAfterOpen
    type: validation
    rule: "Close date must be after open date"
---

# Opportunity

## Overview

An **Opportunity** represents an internal mobility chance - a job opening, project assignment, gig, mentoring slot, or job shadowing experience. Part of the [[TalentMarket]] ecosystem, opportunities enable employees to discover and apply for growth experiences within the organization.

```mermaid
mindmap
  root((Opportunity))
    Types
      ROLE["Role/Job Opening"]
      PROJECT
      GIG["Short-term Gig"]
      MENTORING
      SHADOW["Job Shadowing"]
    Properties
      Skills Required
      Time Commitment
      Duration
    Status
      OPEN
      FILLED
      CLOSED
```

## Business Context

### Key Stakeholders
- **Hiring Manager**: Posts role opportunities
- **Project Lead**: Posts project opportunities
- **Employee**: Browses and applies
- **HR/Talent**: Administers marketplace

### Business Processes
This entity is central to:
- **Internal Hiring**: Internal job postings
- **Project Staffing**: Cross-functional projects
- **Gig Economy**: Short-term assignments
- **Development**: Mentoring, shadowing

### Business Value
Internal opportunity marketplace improves retention by showing growth paths, enables skill utilization across organization, and reduces external hiring costs.

## Attributes Guide

### Identification
- **oppCode**: Unique identifier. Format: OPP-2024-0001.
- **oppTitle**: Display title. e.g., "Senior Developer - Payments Team".
- **description**: Full opportunity details.

### Classification
- **oppTypeCode**: Type of opportunity:
  - *ROLE*: Open position (links to Job/Position)
  - *PROJECT*: Project assignment
  - *GIG*: Short task (< 1 month)
  - *MENTORING*: Mentor/mentee slot
  - *SHADOW*: Job shadowing experience

### Requirements
- **requiredSkills**: Skills needed (array of skill codes).
- **estimatedHoursPerWeek**: Time commitment expected.
- **targetJobId**: For ROLE type, links to [[Job]].

### Timing
- **openDate / closeDate**: Application window.

### Ownership
- **ownerUnitId**: [[BusinessUnit]] posting this.
- **hostEmployeeId**: Person hosting/managing.

## Relationships Explained

```mermaid
erDiagram
    OPPORTUNITY }o--o| TALENT_MARKET : "inMarket"
    OPPORTUNITY }o--o| JOB : "targetJob"
    OPPORTUNITY ||--o{ OPP_APPLICATION : "hasApplications"
```

### Market
- **inMarket** → [[TalentMarket]]: Which talent market/region.

### Role Link
- **targetJob** → [[Job]]: For ROLE type, the job being filled.

### Applications
- **hasApplications** → OpportunityApplication: All employee applications.

## Lifecycle & Workflows

### State Definitions

| State | Business Meaning | System Impact |
|-------|------------------|---------------|
| **draft** | Being prepared | Not visible |
| **open** | Accepting applications | Listed in marketplace |
| **closed** | Manually closed | No new applications |
| **filled** | Candidate selected | Success state |
| **cancelled** | Opportunity withdrawn | Removed |

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> draft: create
    
    draft --> open: publish
    draft --> cancelled: cancel
    
    open --> filled: fill (select candidate)
    open --> closed: close (no selection)
    open --> cancelled: cancel
    
    filled --> [*]
    closed --> [*]
    cancelled --> [*]
```

### Application Flow

```mermaid
flowchart TD
    A[Employee Browses Marketplace] --> B[Views Opportunity]
    B --> C{Interested?}
    C -->|Yes| D[Submit Application]
    D --> E[Manager Reviews]
    E --> F{Decision}
    F -->|Accept| G[Fill Opportunity]
    F -->|Reject| H[Continue Searching]
```

## Actions & Operations

### create
**Who**: Hiring Manager, Project Lead  
**When**: New opportunity arises  
**Required**: oppCode, oppTitle, oppTypeCode, openDate  
**Process**:
1. Define opportunity details
2. Set requirements
3. Save as draft

### publish
**Who**: Opportunity owner  
**When**: Ready for applications  
**Process**:
1. Verify details complete
2. Transition to open
3. Visible in marketplace

### apply
**Who**: Employee  
**When**: Interested in opportunity  
**Process**:
1. Create OpportunityApplication
2. Include statement of interest
3. Manager notified

### fill
**Who**: Opportunity owner  
**When**: Selecting candidate  
**Process**:
1. Choose from applicants
2. Transition to filled
3. Notify all applicants

## Business Rules

### Data Integrity

#### Unique Code (uniqueCode)
**Rule**: Opportunity code unique.  
**Reason**: Tracking reference.  
**Violation**: System prevents save.

#### Valid Dates (closeDateAfterOpen)
**Rule**: Close date after open date.  
**Reason**: Logical sequence.  
**Violation**: System prevents save.

## Examples

### Example 1: Internal Job Opening
- **oppCode**: OPP-2024-0042
- **oppTitle**: Senior Backend Developer
- **oppTypeCode**: ROLE
- **targetJobId**: JOB-SWE-SR
- **statusCode**: OPEN

### Example 2: Project Gig
- **oppCode**: OPP-2024-0050
- **oppTitle**: AI Hackathon Support
- **oppTypeCode**: GIG
- **estimatedHoursPerWeek**: 10
- **Duration**: 2 weeks

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[TalentMarket]] | inMarket | Market context |
| [[Job]] | targetJob | Position being filled |
| [[OpportunityApplication]] | hasApplications | Applications |
