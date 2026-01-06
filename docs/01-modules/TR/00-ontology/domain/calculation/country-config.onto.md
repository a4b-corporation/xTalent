---
entity: CountryConfig
domain: total-rewards
version: "1.0.0"
status: draft
owner: compliance-team
tags: [calculation, country, reference]

classification:
  type: REFERENCE_DATA
  category: calculation

attributes:
  - name: countryCode
    type: string
    required: true
    unique: true
    description: ISO 3166-1 alpha-2 country code
    constraints:
      max: 2

  - name: countryName
    type: string
    required: true
    description: Country name
    constraints:
      max: 100

  - name: currencyCode
    type: string
    required: true
    description: ISO 4217 currency code
    constraints:
      max: 3

  - name: taxSystem
    type: enum
    required: false
    values: [PROGRESSIVE, FLAT, DUAL]
    description: Tax system type

  - name: siSystem
    type: enum
    required: false
    values: [MANDATORY, OPTIONAL, HYBRID]
    description: Social insurance system

  - name: standardWorkingHoursPerDay
    type: number
    required: true
    default: 8
    description: Standard working hours per day

  - name: standardWorkingDaysPerWeek
    type: number
    required: true
    default: 5
    description: Standard working days per week

  - name: standardWorkingDaysPerMonth
    type: number
    required: true
    default: 22
    description: Standard working days per month

  - name: configJson
    type: object
    required: false
    description: Country-specific configurations

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: hasRules
    target: CalculationRule
    cardinality: one-to-many
    required: false
    inverse: belongsToCountry
    description: Calculation rules for this country

  - name: hasHolidays
    target: HolidayCalendar
    cardinality: one-to-many
    required: false
    inverse: belongsToCountry
    description: Holiday calendar

lifecycle:
  states: [active, inactive]
  initial: active
  transitions:
    - from: active
      to: inactive
      trigger: deactivate

actions:
  - name: create
    description: Create country config
    requiredFields: [countryCode, countryName, currencyCode]

  - name: updateConfig
    description: Update country-specific settings
    affectsAttributes: [configJson]

policies:
  - name: validCountryCode
    type: validation
    rule: "Country code must be valid ISO 3166-1 alpha-2"
---

# CountryConfig

## Overview

**CountryConfig** định nghĩa cấu hình quốc gia cho tính lương - giờ làm việc chuẩn, hệ thống thuế, bảo hiểm xã hội. Là REFERENCE_DATA, shared giữa TR, TA, và Payroll modules.

```mermaid
mindmap
  root((CountryConfig))
    Tax
      PROGRESSIVE
      FLAT
      DUAL
    Social Insurance
      MANDATORY
      OPTIONAL
      HYBRID
    Working Standards
      Hours per Day
      Days per Week
      Days per Month
    Contains
      CalculationRules
      HolidayCalendars
```

## Business Context

### Key Stakeholders
- **Compliance Team**: Maintain country configurations
- **Payroll Team**: Use for calculations
- **HR Admin**: Reference for policies
- **Finance**: Multi-country reporting

### Supported Countries

| Country | Currency | Tax System | SI System |
|---------|----------|------------|-----------|
| **VN** | VND | PROGRESSIVE | MANDATORY |
| **SG** | SGD | PROGRESSIVE | MANDATORY (CPF) |
| **US** | USD | PROGRESSIVE | HYBRID |
| **TH** | THB | PROGRESSIVE | MANDATORY |

### Business Value
CountryConfig centralizes country-specific settings, ensures compliance với local regulations, và enables multi-country payroll.

## Attributes Guide

### Core Identity
- **countryCode**: ISO 3166-1 alpha-2. VD: VN, SG, US
- **countryName**: Tên quốc gia
- **currencyCode**: ISO 4217. VD: VND, SGD, USD

### Tax & SI System
- **taxSystem**: 
  - *PROGRESSIVE*: Tax brackets (VN, SG)
  - *FLAT*: Single rate
  - *DUAL*: Combination
- **siSystem**:
  - *MANDATORY*: Required contributions (VN, SG)
  - *OPTIONAL*: Employee choice
  - *HYBRID*: Some mandatory, some optional

### Working Standards
- **standardWorkingHoursPerDay**: Giờ làm/ngày (thường 8)
- **standardWorkingDaysPerWeek**: Ngày làm/tuần (thường 5)
- **standardWorkingDaysPerMonth**: Ngày làm/tháng (VN: 26 theo luật, thực tế ~22)

### Extended Configuration (configJson)
```json
{
  "minimumWage": {
    "region1": 4960000,
    "region2": 4410000,
    "region3": 3860000,
    "region4": 3250000
  },
  "publicHolidaysPerYear": 11,
  "annualLeaveMinDays": 12,
  "probationMaxMonths": 2,
  "noticePeriodDefault": 30
}
```

## Relationships Explained

```mermaid
erDiagram
    COUNTRY_CONFIG ||--o{ CALCULATION_RULE : "hasRules"
    COUNTRY_CONFIG ||--o{ HOLIDAY_CALENDAR : "hasHolidays"
    LEGAL_ENTITY }o--|| COUNTRY_CONFIG : "locatedIn"
```

### CalculationRule
- **hasRules** → [[CalculationRule]]: Country-specific calculation rules (tax, SI)

### HolidayCalendar
- **hasHolidays** → [[HolidayCalendar]]: Holiday calendars for this country

## Lifecycle & Workflows

```mermaid
stateDiagram-v2
    [*] --> active: create
    active --> inactive: deactivate
```

| State | Meaning |
|-------|---------|
| **active** | Country supported |
| **inactive** | Country no longer supported |

## Actions & Operations

### create
**Who**: Compliance Team  
**Required**: countryCode, countryName, currencyCode

### updateConfig
**Who**: Compliance Team  
**When**: Law changes, minimum wage update

## Business Rules

#### Valid Country Code (validCountryCode)
**Rule**: Must be valid ISO 3166-1 alpha-2 code.

## Examples

### Example 1: Vietnam
```yaml
countryCode: VN
countryName: "Vietnam"
currencyCode: VND
taxSystem: PROGRESSIVE
siSystem: MANDATORY
standardWorkingHoursPerDay: 8
standardWorkingDaysPerWeek: 5
standardWorkingDaysPerMonth: 26  # Theo luật
configJson:
  minimumWage:
    region1: 4960000
    region2: 4410000
    region3: 3860000
    region4: 3250000
  publicHolidaysPerYear: 11
  annualLeaveMinDays: 12
  probationMaxMonths: 2
  noticePeriodDefault: 30
```

### Example 2: Singapore
```yaml
countryCode: SG
countryName: "Singapore"
currencyCode: SGD
taxSystem: PROGRESSIVE
siSystem: MANDATORY
standardWorkingHoursPerDay: 8
standardWorkingDaysPerWeek: 5
standardWorkingDaysPerMonth: 22
configJson:
  cpfCeilingMonthly: 6800
  cpfCeilingAnnual: 102000
  awsMonths: 1
  annualLeaveMinDays: 7
```

### Example 3: United States
```yaml
countryCode: US
countryName: "United States"
currencyCode: USD
taxSystem: PROGRESSIVE
siSystem: HYBRID
standardWorkingHoursPerDay: 8
standardWorkingDaysPerWeek: 5
standardWorkingDaysPerMonth: 22
configJson:
  federalMinimumWage: 7.25
  overtimeThresholdWeekly: 40
  fica:
    socialSecurity: 0.062
    medicare: 0.0145
```

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[CalculationRule]] | hasRules | Country-specific rules |
| [[HolidayCalendar]] | hasHolidays | Holiday calendar |
| [[LegalEntity]] | indirect | Entities in country |
