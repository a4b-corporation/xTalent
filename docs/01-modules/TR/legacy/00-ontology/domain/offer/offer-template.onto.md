---
entity: OfferTemplate
domain: total-rewards
version: "1.0.0"
status: draft
owner: compensation-team
tags: [offer, template, recruiting]

classification:
  type: AGGREGATE_ROOT
  category: offer

attributes:
  - name: id
    type: string
    required: true
    unique: true
    description: System-generated UUID

  - name: code
    type: string
    required: true
    unique: true
    description: Template code
    constraints:
      max: 50

  - name: name
    type: string
    required: true
    description: Template name
    constraints:
      max: 200

  - name: description
    type: string
    required: false
    description: Template description

  - name: versionNo
    type: number
    required: true
    default: 1
    description: Version number

  - name: componentsJson
    type: object
    required: true
    description: Pay components, benefits, equity in offer

  - name: effectiveStartDate
    type: date
    required: true
    description: Start date

  - name: effectiveEndDate
    type: date
    required: false
    description: End date

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: includesComponents
    target: PayComponent
    cardinality: many-to-many
    required: false
    description: Pay components in template

  - name: includesBenefits
    target: BenefitPlan
    cardinality: many-to-many
    required: false
    description: Benefit plans in template

  - name: forGrade
    target: Grade
    cardinality: many-to-one
    required: false
    description: Target grade for template

lifecycle:
  states: [draft, active, deprecated]
  initial: draft
  transitions:
    - from: draft
      to: active
      trigger: activate
    - from: active
      to: deprecated
      trigger: deprecate

actions:
  - name: create
    description: Create offer template
    requiredFields: [code, name, componentsJson, effectiveStartDate]

  - name: createNewVersion
    description: Create new version
    affectsAttributes: [versionNo, componentsJson]

  - name: generateOffer
    description: Generate offer from template
    requiredFields: [candidateId, positionId]

policies:
  - name: uniqueCodeVersion
    type: validation
    rule: "Code + version must be unique"

  - name: hasComponents
    type: validation
    rule: "Template must have at least one component"
---

# OfferTemplate

## Overview

**OfferTemplate** định nghĩa khuôn mẫu cho offer letter - bao gồm salary components, benefits, equity. Dùng cho new hires, transfers, promotions, retention.

```mermaid
mindmap
  root((OfferTemplate))
    Compensation
      Base Salary
      Allowances
      Sign-on Bonus
    Benefits
      Medical
      Retirement
      Wellness
    Equity
      RSU
      Stock Options
    Use Cases
      New Hire
      Promotion
      Retention
```

## Business Context

### Key Stakeholders
- **Recruiting Team**: Create offers from templates
- **Compensation Team**: Define and maintain templates
- **Hiring Managers**: Customize offers within guidelines
- **Finance**: Budget approval

### Offer Template Use Cases

| Use Case | Description | Customizable Fields |
|----------|-------------|---------------------|
| **New Hire** | External candidates | Salary, sign-on, start date |
| **Internal Transfer** | Same level move | Salary adjustment, relocation |
| **Promotion** | Level increase | New salary, bonus target |
| **Retention** | Counter offer | Sign-on, equity grant |

### Business Value
OfferTemplate ensures consistency in offers, guides salary decisions within pay ranges, và speeds up offer generation process.

## Attributes Guide

### Core Identity
- **code**: Mã duy nhất. Format: SR_ENGINEER_VN, DIRECTOR_SG
- **name**: Tên hiển thị. VD: "Senior Engineer Offer - Vietnam"
- **description**: Mô tả khi nào dùng template này
- **versionNo**: Version number

### componentsJson Structure

```json
{
  "compensation": [
    {
      "componentCode": "BASIC_SALARY",
      "amount": null,
      "minAmount": 25000000,
      "maxAmount": 45000000,
      "required": true
    },
    {
      "componentCode": "TRANSPORT_ALLOWANCE",
      "amount": 2000000,
      "required": false
    },
    {
      "componentCode": "SIGN_ON_BONUS",
      "amount": null,
      "maxAmount": 50000000,
      "required": false
    }
  ],
  "benefits": [
    {
      "planCode": "MED_PREMIUM",
      "optionCode": "EMPLOYEE_FAMILY",
      "required": true
    },
    {
      "planCode": "WELLNESS_VNG",
      "required": false
    }
  ],
  "equity": {
    "grantType": "RSU",
    "units": null,
    "maxUnits": 1000,
    "vestingSchedule": "4Y_1Y_CLIFF"
  },
  "bonusTarget": {
    "targetPct": 15,
    "planCode": "ANNUAL_BONUS"
  }
}
```

## Relationships Explained

```mermaid
erDiagram
    OFFER_TEMPLATE }o--o{ PAY_COMPONENT : "includesComponents"
    OFFER_TEMPLATE }o--o{ BENEFIT_PLAN : "includesBenefits"
    OFFER_TEMPLATE }o--o| GRADE : "forGrade"
    OFFER_TEMPLATE ||--o{ OFFER : "generates"
```

### PayComponent
- **includesComponents** → [[PayComponent]]: Compensation elements in template

### BenefitPlan
- **includesBenefits** → [[BenefitPlan]]: Benefit packages

### Grade
- **forGrade** → [[Grade]]: Target grade (for pay range validation)

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> draft: create
    draft --> active: activate
    active --> deprecated: deprecate
    active --> active: createNewVersion
```

| State | Meaning |
|-------|---------|
| **draft** | Đang design |
| **active** | Có thể generate offers |
| **deprecated** | Không dùng cho new offers |

### Offer Generation Flow

```mermaid
flowchart LR
    A[Select Template] --> B[Load Candidate/Position]
    B --> C[Auto-fill from Grade/PayRange]
    C --> D[Recruiter Customizes]
    D --> E[Manager Review]
    E --> F[Generate Offer Letter]
```

## Actions & Operations

### create
**Who**: Compensation Team  
**Required**: code, name, componentsJson, effectiveStartDate

### createNewVersion
**Who**: Compensation Team  
**When**: Policy changes, new components  
**Affects**: versionNo, componentsJson

### generateOffer
**Who**: Recruiter  
**Required**: candidateId, positionId  
**Output**: Draft Offer record

## Business Rules

#### Unique Code Version (uniqueCodeVersion)
**Rule**: Code + version unique.

#### Has Components (hasComponents)
**Rule**: Template phải có ít nhất 1 component.

## Examples

### Example 1: Senior Engineer - Vietnam
```yaml
code: SR_ENGINEER_VN
name: "Senior Engineer Offer - Vietnam"
forGrade: G3
componentsJson:
  compensation:
    - componentCode: BASIC_SALARY
      minAmount: 25000000
      maxAmount: 45000000
      required: true
    - componentCode: TRANSPORT_ALLOWANCE
      amount: 2000000
      required: false
    - componentCode: SIGN_ON_BONUS
      maxAmount: 30000000
      required: false
  benefits:
    - planCode: MED_PREMIUM
      optionCode: EMPLOYEE_PLUS_ONE
      required: true
  bonusTarget:
    targetPct: 15
```

### Example 2: Director - Vietnam
```yaml
code: DIRECTOR_VN
name: "Director Offer - Vietnam"
forGrade: M4
componentsJson:
  compensation:
    - componentCode: BASIC_SALARY
      minAmount: 80000000
      maxAmount: 120000000
      required: true
    - componentCode: CAR_ALLOWANCE
      amount: 15000000
      required: true
    - componentCode: SIGN_ON_BONUS
      maxAmount: 100000000
      required: false
  benefits:
    - planCode: MED_PREMIUM
      optionCode: FAMILY
      required: true
  equity:
    grantType: RSU
    maxUnits: 5000
    vestingSchedule: 4Y_1Y_CLIFF
  bonusTarget:
    targetPct: 30
```

### Example 3: Senior Engineer - Singapore
```yaml
code: SR_ENGINEER_SG
name: "Senior Engineer Offer - Singapore"
forGrade: G3
componentsJson:
  compensation:
    - componentCode: BASIC_SALARY
      minAmount: 6000
      maxAmount: 10000
      currency: SGD
      required: true
    - componentCode: AWS  # Annual Wage Supplement
      amount: 1  # 1 month
      required: true
  benefits:
    - planCode: MED_SG
      required: true
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[PayComponent]] | includesComponents | Pay elements |
| [[BenefitPlan]] | includesBenefits | Benefit packages |
| [[Grade]] | forGrade | Target grade |
| Offer | generates | Generated offers |
