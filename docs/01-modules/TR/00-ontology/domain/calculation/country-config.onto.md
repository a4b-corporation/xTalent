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

actions:
  - name: create
    description: Create country config
    requiredFields: [countryCode, countryName, currencyCode]

policies:
  - name: validCountryCode
    type: validation
    rule: "Country code must be valid ISO 3166-1 alpha-2"
---

# CountryConfig

## Overview

**CountryConfig** định nghĩa cấu hình quốc gia cho tính lương - giờ làm việc chuẩn, hệ thống thuế, bảo hiểm xã hội.

## Examples

### Vietnam
- **countryCode**: VN
- **countryName**: Vietnam
- **currencyCode**: VND
- **taxSystem**: PROGRESSIVE
- **siSystem**: MANDATORY
- **standardWorkingHoursPerDay**: 8
- **standardWorkingDaysPerMonth**: 26

### Singapore
- **countryCode**: SG
- **countryName**: Singapore
- **currencyCode**: SGD
- **taxSystem**: PROGRESSIVE
- **siSystem**: MANDATORY (CPF)
- **standardWorkingHoursPerDay**: 8
- **standardWorkingDaysPerMonth**: 22

## Related Entities

| Entity | Relationship | Description |
|--------|--------------|-------------|
| [[CalculationRule]] | hasRules | Country-specific rules |
| [[HolidayCalendar]] | hasHolidays | Holiday calendar |
