# Location & Geography API Catalog

> **Module**: Core HR - Location & Geography Management  
> **Version**: 1.0.0  
> **Status**: Draft  
> **Last Updated**: 2026-01-29  
> **Reference**: Oracle HCM, SAP SuccessFactors, Workday patterns

---

## Overview

This document catalogs all necessary APIs for the **Location & Geography** entities. It follows **RESTful** conventions with 3-tier location architecture.

### 3-Tier Location Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 1: Geographic Reference (Read-mostly, Master Data)           │
│  ┌──────────────┐    ┌──────────────────┐                          │
│  │   Country    │───►│    AdminArea     │ (Province→District→Ward) │
│  └──────────────┘    └──────────────────┘                          │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 2: Physical Infrastructure (Big Map + Internal Map)          │
│  ┌──────────────┐    ┌──────────────────┐                          │
│  │    Place     │───►│    Location      │ (Floor→Room→Desk)       │
│  │  (Building)  │    │  (Internal Map)  │                          │
│  └──────────────┘    └──────────────────┘                          │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 3: HR Assignment (Organizational Layer)                      │
│  ┌──────────────────┐    ┌──────────────────┐                      │
│  │  WorkLocation    │───►│   Assignment     │                      │
│  │  (Office/Remote) │    │   (Employee)     │                      │
│  └──────────────────┘    └──────────────────┘                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Entities Covered

| Entity | Description | File |
|--------|-------------|------|
| **Address** | Polymorphic address for any owner | Address.onto.md |
| **AdminArea** | Geographic hierarchy (N-level) | admin-area.onto.md |
| **Place** | Physical site on map | place.onto.md |
| **Location** | Internal space hierarchy | location.onto.md |
| **WorkLocation** | HR assignment point | work-location.onto.md |

---

## 1. Address APIs

> **Entity**: `Address`  
> **Domain**: Common (Polymorphic)  
> **Base Path**: `/api/v1/addresses`

### 1.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/addresses` | Create address | HR Admin |
| `GET` | `/addresses/{id}` | Get by ID | Read |
| `GET` | `/addresses` | List (paginated) | Read |
| `PATCH` | `/addresses/{id}` | Update | HR Admin |
| `DELETE` | `/addresses/{id}` | Soft delete | HR Admin |

### 1.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/addresses/{id}/actions/verify` | Verify via address validation service | Admin |
| `POST` | `/addresses/{id}/actions/setPrimary` | Set as primary address for owner | Admin |
| `POST` | `/addresses/{id}/actions/geocode` | Get lat/lng from address text | Integration |
| `POST` | `/addresses/{id}/actions/deactivate` | Deactivate (moved, invalid) | Admin |
| `POST` | `/addresses/{id}/actions/reactivate` | Reactivate address | Admin |

### 1.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/addresses/query/by-owner` | Get addresses for owner | `ownerType`, `ownerId` |
| `GET` | `/addresses/query/primary` | Get primary address | `ownerType`, `ownerId`, `addressType` |
| `GET` | `/addresses/query/by-type/{type}` | Get by address type | `ownerType`, `ownerId` |
| `GET` | `/addresses/query/by-admin-area/{areaId}` | Get addresses in admin area | `includeChildren` |
| `GET` | `/addresses/query/unverified` | Get unverified addresses | - |

### 1.4 VN Compliance

| Path | Description |
|------|-------------|
| `GET /addresses/query/permanent/{ownerId}` | Get permanent address (hộ khẩu) for Worker |
| `GET /addresses/query/temporary/{ownerId}` | Get temporary address (tạm trú) for Worker |

---

## 2. AdminArea APIs

> **Entity**: `AdminArea`  
> **Domain**: Geography (Master Data)  
> **Base Path**: `/api/v1/admin-areas`

### 2.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/admin-areas` | Create admin area | Admin |
| `GET` | `/admin-areas/{id}` | Get by ID | Read |
| `GET` | `/admin-areas` | List (paginated) | Read |
| `PATCH` | `/admin-areas/{id}` | Update | Admin |
| `DELETE` | `/admin-areas/{id}` | Soft delete | Admin |

### 2.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/admin-areas/{id}/actions/activate` | Activate admin area | Admin |
| `POST` | `/admin-areas/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/admin-areas/{id}/actions/deprecate` | Deprecate (boundary change) | Redistricting |
| `POST` | `/admin-areas/{id}/actions/merge` | Merge with another area | Redistricting |
| `POST` | `/admin-areas/{id}/actions/split` | Split into new areas | Redistricting |
| `POST` | `/admin-areas/{id}/actions/createVersion` | Create SCD Type-2 version | Boundary change |

### 2.3 Business Actions - Import/Export

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/admin-areas/actions/import` | Bulk import from government data | Integration |
| `POST` | `/admin-areas/actions/export` | Export hierarchy to JSON/CSV | Integration |

### 2.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/admin-areas/{id}/children` | Get child areas | `recursive` |
| `GET` | `/admin-areas/{id}/ancestors` | Get path to country | - |
| `GET` | `/admin-areas/{id}/descendants` | Get all descendants | `maxDepth` |
| `GET` | `/admin-areas/query/by-country/{countryCode}` | Get by country | `levelCode` |
| `GET` | `/admin-areas/query/by-level/{level}` | Get by level | `countryCode` |
| `GET` | `/admin-areas/tree/{countryCode}` | Get full hierarchy tree | `depth` |
| `GET` | `/admin-areas/search` | Search by name/code | `q`, `countryCode` |

### 2.5 VN-Specific Queries

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/admin-areas/vn/provinces` | Get all VN provinces (Tỉnh/TP) | - |
| `GET` | `/admin-areas/vn/districts/{provinceId}` | Get districts in province (Quận/Huyện) | - |
| `GET` | `/admin-areas/vn/wards/{districtId}` | Get wards in district (Phường/Xã) | - |

---

## 3. Place APIs

> **Entity**: `Place`  
> **Domain**: Facility (Geographic Point)  
> **Base Path**: `/api/v1/places`

### 3.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/places` | Create place | Facility Admin |
| `GET` | `/places/{id}` | Get by ID | Read |
| `GET` | `/places` | List (paginated) | Read |
| `PATCH` | `/places/{id}` | Update | Facility Admin |
| `DELETE` | `/places/{id}` | Soft delete | Facility Admin |

### 3.2 Business Actions

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/places/{id}/actions/activate` | Activate place | Admin |
| `POST` | `/places/{id}/actions/deactivate` | Deactivate (temp close) | Admin |
| `POST` | `/places/{id}/actions/close` | Permanently close | Admin |
| `POST` | `/places/{id}/actions/reactivate` | Reactivate | Admin |
| `POST` | `/places/{id}/actions/updateContact` | Update primary contact | Admin |
| `POST` | `/places/{id}/actions/geocode` | Get/update lat/lng from address | Integration |
| `POST` | `/places/{id}/actions/move` | Reparent to different parent place | Reorganization |

### 3.3 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/places/{id}/children` | Get child places | `recursive` |
| `GET` | `/places/{id}/locations` | Get internal locations | `type` |
| `GET` | `/places/{id}/work-locations` | Get associated work locations | - |
| `GET` | `/places/query/by-type/{type}` | Get by place type | `isActive` |
| `GET` | `/places/query/by-admin-area/{areaId}` | Get by admin area | `includeChildren` |
| `GET` | `/places/query/nearby` | Get nearby places | `lat`, `lng`, `radiusKm` |
| `GET` | `/places/search` | Search by name/code | `q` |

---

## 4. Location APIs

> **Entity**: `Location`  
> **Domain**: Facility (Internal Space)  
> **Base Path**: `/api/v1/locations`

### 4.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/locations` | Create location | Facility Admin |
| `GET` | `/locations/{id}` | Get by ID | Read |
| `GET` | `/locations` | List (paginated) | Read |
| `PATCH` | `/locations/{id}` | Update | Facility Admin |
| `DELETE` | `/locations/{id}` | Soft delete | Facility Admin |

### 4.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/locations/{id}/actions/activate` | Activate location | Admin |
| `POST` | `/locations/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/locations/{id}/actions/startRenovation` | Mark under renovation | Maintenance |
| `POST` | `/locations/{id}/actions/completeRenovation` | Renovation complete | Maintenance |
| `POST` | `/locations/{id}/actions/decommission` | Permanently decommission | Admin |
| `POST` | `/locations/{id}/actions/reactivate` | Reactivate | Admin |

### 4.3 Business Actions - Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/locations/{id}/actions/move` | Reparent to new parent location | Reorganization |
| `POST` | `/locations/{id}/actions/updateCapacity` | Update maximum capacity | Admin |
| `POST` | `/locations/{id}/actions/updateFeatures` | Update room features | Admin |

### 4.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/locations/{id}/children` | Get child locations | `recursive` |
| `GET` | `/locations/{id}/ancestors` | Get path to Place | - |
| `GET` | `/locations/query/by-place/{placeId}` | Get by place | `type`, `isActive` |
| `GET` | `/locations/query/by-type/{type}` | Get by type (FLOOR, ROOM) | `placeId` |
| `GET` | `/locations/query/bookable` | Get bookable locations | `placeId`, `capacity` |
| `GET` | `/locations/query/available` | Get available locations | `placeId`, `features[]` |
| `GET` | `/locations/tree/{placeId}` | Get location tree for place | `depth` |
| `GET` | `/locations/search` | Search by name/code | `q`, `placeId` |

---

## 5. WorkLocation APIs

> **Entity**: `WorkLocation`  
> **Domain**: HR Operations  
> **Base Path**: `/api/v1/work-locations`

### 5.1 CRUD Operations

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/work-locations` | Create work location | HR Admin |
| `GET` | `/work-locations/{id}` | Get by ID | Read |
| `GET` | `/work-locations` | List (paginated) | Read |
| `PATCH` | `/work-locations/{id}` | Update | HR Admin |
| `DELETE` | `/work-locations/{id}` | Soft delete | HR Admin |

### 5.2 Business Actions - Lifecycle

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/work-locations/{id}/actions/activate` | Activate work location | Admin |
| `POST` | `/work-locations/{id}/actions/deactivate` | Deactivate | Admin |
| `POST` | `/work-locations/{id}/actions/close` | Permanently close | Office closure |
| `POST` | `/work-locations/{id}/actions/reactivate` | Reactivate | Admin |

### 5.3 Business Actions - Management

| Method | Path | Description | Trigger |
|--------|------|-------------|---------|
| `POST` | `/work-locations/{id}/actions/setPrimary` | Set as primary for BU | Admin |
| `POST` | `/work-locations/{id}/actions/updateCapacity` | Update headcount capacity | Admin |
| `POST` | `/work-locations/{id}/actions/transferAssignments` | Transfer all assignments to another | Office closure |
| `POST` | `/work-locations/{id}/actions/linkToLocation` | Link to physical Location | Admin |
| `POST` | `/work-locations/{id}/actions/unlinkFromLocation` | Unlink from Location (→ REMOTE) | Admin |

### 5.4 Query Operations

| Method | Path | Description | Params |
|--------|------|-------------|--------|
| `GET` | `/work-locations/query/by-legal-entity/{leId}` | Get by legal entity | `type`, `isActive` |
| `GET` | `/work-locations/query/by-business-unit/{buId}` | Get by business unit | `type` |
| `GET` | `/work-locations/query/by-type/{type}` | Get by type (OFFICE, REMOTE) | `leId` |
| `GET` | `/work-locations/query/primary/{buId}` | Get primary for BU | - |
| `GET` | `/work-locations/{id}/assignments` | Get current assignments | `asOfDate` |
| `GET` | `/work-locations/{id}/headcount` | Get current headcount | - |
| `GET` | `/work-locations/{id}/capacity-utilization` | Get capacity vs actual | - |
| `GET` | `/work-locations/search` | Search by name/code | `q` |

---

## Summary

### API Count by Entity

| Entity | CRUD | Actions | Query | Total |
|--------|------|---------|-------|-------|
| Address | 5 | 5 | 6 | **16** |
| AdminArea | 5 | 8 | 10 | **23** |
| Place | 5 | 7 | 7 | **19** |
| Location | 5 | 9 | 8 | **22** |
| WorkLocation | 5 | 9 | 8 | **22** |
| **Total** | **25** | **38** | **39** | **102** |

### Priority Matrix

| Priority | APIs | Description |
|----------|------|-------------|
| **P0** | 25 | CRUD - MVP |
| **P1** | 15 | Core Lifecycle (activate, deactivate, close) |
| **P2** | 10 | Address & Geo Operations (verify, geocode) |
| **P3** | 10 | Hierarchy Operations (tree, children, ancestors) |
| **P4** | 39 | Query & Navigation |
| **P5** | 3 | Import/Export |

### Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Add Worker Address** | POST /addresses → verify → setPrimary |
| **Setup Office** | POST /places → POST /locations → POST /work-locations |
| **Close Office** | POST /work-locations/transferAssignments → close |
| **VN Admin Hierarchy** | GET /admin-areas/vn/provinces → districts → wards |
| **Find Nearby Offices** | GET /places/query/nearby |

---

## Appendix: VN Administrative Structure

| Level | levelCode | Vietnamese | Count (2024) |
|-------|-----------|------------|--------------|
| 1 | PROVINCE | Tỉnh/Thành phố trực thuộc TW | 63 |
| 2 | DISTRICT | Quận/Huyện/Thị xã/TP thuộc Tỉnh | ~700 |
| 3 | WARD | Phường/Xã/Thị trấn | ~11,000 |

---

*Document Status: DRAFT*  
*References: [[Address]], [[AdminArea]], [[Place]], [[Location]], [[WorkLocation]]*
