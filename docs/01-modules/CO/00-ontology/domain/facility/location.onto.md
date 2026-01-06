---
entity: Location
domain: core-hr
version: "1.0.0"
status: draft
owner: core-team
tags: [facility, location, entity]

classification:
  type: ENTITY
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
    description: Location code

  - name: name
    type: string
    required: true
    description: Location name

  - name: placeId
    type: string
    required: true
    description: FK to Place

  - name: locationTypeCode
    type: enum
    required: true
    values: [FLOOR, OFFICE, MEETING_ROOM, DESK, AREA]
    description: Location type

  - name: parentId
    type: string
    required: false
    description: Parent location

  - name: capacity
    type: number
    required: false
    description: Capacity

  - name: latitude
    type: number
    required: false
    description: Latitude

  - name: longitude
    type: number
    required: false
    description: Longitude

  - name: isActive
    type: boolean
    required: true
    default: true
    description: Active status

relationships:
  - name: atPlace
    target: Place
    cardinality: many-to-one
    required: true
    inverse: hasLocations
    description: Parent place

  - name: hasWorkLocations
    target: WorkLocation
    cardinality: one-to-many
    required: false
    inverse: locatedAt
    description: Work locations here

lifecycle:
  states: [active, inactive]
  initial: active

actions:
  - name: create
    description: Create location
    requiredFields: [code, name, placeId, locationTypeCode]

policies:
  - name: uniqueCode
    type: validation
    rule: "Location code must be unique"
---

# Location

## Overview

A **Location** represents a specific space within a [[Place]] - floor, office, meeting room, or desk area. Locations provide granular spatial reference for [[WorkLocation]]s and resource management.

```mermaid
mindmap
  root((Location))
    Types
      FLOOR
      OFFICE
      MEETING_ROOM
      DESK
      AREA
    Links
      Place
      WorkLocation
    Properties
      Capacity
      Coordinates
```

## Business Context

### Key Stakeholders
- **Facilities**: Space management
- **IT**: Asset placement
- **HR Admin**: Work location assignment

### Business Processes
- **Space Planning**: Floor/room allocation
- **Hot Desking**: Desk booking
- **Resource Management**: Meeting rooms

### Business Value
Granular location data enables space optimization and hybrid work management.

## Attributes Guide

### Identification
- **code**: Unique identifier. Format: LOC-VT-F10-A.
- **name**: e.g., "Floor 10 - Zone A".
- **locationTypeCode**: FLOOR, OFFICE, MEETING_ROOM, DESK, AREA.

### Spatial
- **capacity**: Max occupancy.
- **latitude/longitude**: For mapping.

## Relationships Explained

```mermaid
erDiagram
    LOCATION }o--|| PLACE : "atPlace"
    LOCATION ||--o{ WORK_LOCATION : "hasWorkLocations"
```

### Place
- **atPlace** → [[Place]]: Physical building/site.

### Work Locations
- **hasWorkLocations** → [[WorkLocation]]: HR work locations at this space.

## Lifecycle & Workflows

| State | Meaning |
|-------|---------|
| **active** | Space available |
| **inactive** | Space decommissioned |

## Actions & Operations

### create
**Who**: Facilities  
**Required**: code, name, placeId, locationTypeCode

## Examples

### Example: Office Floor
- **code**: LOC-VT-F10
- **name**: Floor 10
- **locationTypeCode**: FLOOR
- **placeId**: PLC-VN-HCM-VT

## Related Entities

| Entity | Relationship |
|--------|--------------|
| [[Place]] | atPlace |
| [[WorkLocation]] | hasWorkLocations |
