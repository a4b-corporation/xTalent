# Core Module - Functional Requirements Specification

> **Module**: Core (CO)  
> **Version**: 2.0  
> **Last Updated**: 2026-01-08  
> **Status**: In Development

## Overview

Tài liệu này mô tả cấu trúc Functional Requirements Specification (FRS) cho Core Module của xTalent HCM. Core module là nền tảng quản lý nhân sự cốt lõi, bao gồm quản lý worker, employment relationships, tổ chức công ty, job & position, skills, và career paths.

## FRS Structure

Mỗi sub-module sẽ có file `*.frs.md` riêng theo chuẩn `frs-builder` skill:

```
02-spec/01-functional-requirements/
├── README.md              # Tài liệu này
├── _index.md              # Index tất cả FRs theo sub-module
├── 00-configuration.frs.md
├── 01-person.frs.md
├── 02-work-relationship.frs.md
├── 03-employment.frs.md
├── 04-assignment.frs.md
├── 05-organization.frs.md
├── 06-job-position.frs.md
├── 07-skill.frs.md
├── 08-career.frs.md
├── 09-eligibility.frs.md
└── 10-privacy.frs.md
```

## Sub-Modules

| # | Sub-Module | FR Prefix | Priority | Description |
|---|------------|-----------|----------|-------------|
| 00 | Configuration | FR-CFG | CRITICAL | Code Lists, Currencies, Timezones, Countries |
| 01 | Person | FR-WRK | HIGH | Worker profiles, contacts, addresses, documents |
| 02 | Work Relationship | FR-WR, FR-CONTRACT | HIGH | Employment contracts, relationship types |
| 03 | Employment | FR-EMP | HIGH | Employee records, probation, termination |
| 04 | Assignment | FR-ASG, FR-MTX | HIGH | Job assignments, managers, matrix reporting |
| 05 | Organization | FR-BU | MEDIUM | Legal entities, business units, hierarchy |
| 06 | Job & Position | FR-TAX, FR-PRF, FR-POS | MEDIUM | Job catalog, profiles, positions |
| 07 | Skill | FR-SKL, FR-ASS | LOW | Skill catalog, assessments, certifications |
| 08 | Career | FR-CAR | LOW | Career paths, ladders, progression |
| 09 | Eligibility | FR-ELG | MEDIUM | Cross-module eligibility profiles |
| 10 | Privacy | FR-PRI | HIGH | GDPR, data classification, consent |

## FRS File Format

Mỗi file `*.frs.md` tuân theo chuẩn `frs-builder`:

1. **YAML Frontmatter** - Metadata + requirements array
2. **Functional Scope** - Mindmap overview
3. **Requirement Catalog** - Summary table
4. **Detailed Specifications** - Full FR details
5. **Requirement Hierarchy** - requirementDiagram

## Priority Definitions

| Priority | Meaning |
|----------|---------|
| **MUST** | Required for MVP, system cannot function without |
| **SHOULD** | Important, needed for production release |
| **COULD** | Nice-to-have, can be deferred |

## Requirement Types

| Type | Description |
|------|-------------|
| `Functional` | Core functionality |
| `Validation` | Business rule enforcement |
| `Workflow` | Process automation |
| `Calculation` | Computed values |
| `UI/UX` | User interface requirements |
| `Integration` | External system connections |
| `Configuration` | Setup and configuration |

## Related Documents

- **Ontology**: `00-ontology/domain/` - Entity definitions
- **Business Rules**: `02-spec/04-business-rules/` - BRS files
- **BDD Scenarios**: `02-spec/05-BDD/` - Feature files
- **Research**: `_research/` - Feature and entity catalogs

## Statistics Summary

| Metric | Value |
|--------|-------|
| Total Sub-Modules | 11 |
| Total Requirements | ~450 FRs |
| MUST | ~200 |
| SHOULD | ~175 |
| COULD | ~75 |
