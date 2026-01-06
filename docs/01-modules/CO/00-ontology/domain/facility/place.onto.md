---
entity: Place
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [facility, place, core]

classification:
  type: AGGREGATE_ROOT
  category: facility

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
    description: Place code

  - name: name
    type: string
    required: true
    description: Place name

  - name: placeTypeCode
    type: enum
    required: true
    values: [BUILDING, CAMPUS, SITE, WAREHOUSE]
    description: Place type

  - name: parentId
    type: string
    required: false
    description: Parent place

  - name: adminAreaId
    type: string
    required: false
    description: Administrative area

  - name: countryCode
    type: string
    required: true
    description: Country code

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: hasLocations
    target: Location
    cardinality: one-to-many
    required: false
    inverse: atPlace
    description: Locations in place

  - name: hasChildren
    target: Place
    cardinality: one-to-many
    required: false
    description: Child places

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create place
    requiredFields: [code, name, placeTypeCode, countryCode]

policies:
  - name: uniqueCode
    type: validation
    rule: "Place code must be unique"
---

# Place

## Overview

A **Place** represents a physical site - building, campus, or warehouse. Places provide the top-level physical hierarchy, containing [[Location]]s which in turn host [[WorkLocation]]s. This three-tier model enables granular facility management.

```mermaid
mindmap
  root((Place))
    Types
      BUILDING
      CAMPUS
      SITE
      WAREHOUSE
    Contains
      Location
    Geography
      Country
      AdminArea
```

## Business Context

### Key Stakeholders
- **Facilities**: Manages physical sites
- **Real Estate**: Lease/property management
- **HR**: Links to work assignments

### Business Processes
- **Facility Management**: Site inventory
- **Space Planning**: Floor/room allocation
- **Address Management**: Physical addresses

### Business Value
Centralized site management enables facility planning and location-based policies.

## Attributes Guide

### Identification
- **code**: Unique identifier. Format: PLC-VN-HCM-VT.
- **name**: e.g., "VNG Tower".
- **placeTypeCode**: BUILDING, CAMPUS, SITE, WAREHOUSE.

### Geography
- **countryCode**: ISO country code.
- **adminAreaId**: Province/city reference.

## Relationships Explained

```mermaid
erDiagram
    PLACE ||--o{ LOCATION : "hasLocations"
    PLACE ||--o{ PLACE : "hasChildren"
```

### Locations
- **hasLocations** → [[Location]]: Specific spaces within place.

### Hierarchy
- **hasChildren** → [[Place]]: Sub-places (building within campus).

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Site operational |
| **inactive** | Site closed |

## Actions & Operations

### create
**Who**: Facilities  
**Required**: code, name, placeTypeCode, countryCode

## Examples

### Example: Office Building
- **code**: PLC-VN-HCM-VT
- **name**: VNG Tower
- **placeTypeCode**: BUILDING
- **countryCode**: VN

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Location]] | hasLocations |
