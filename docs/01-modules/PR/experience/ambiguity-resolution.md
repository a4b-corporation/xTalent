# Ambiguity Resolution - Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Experience (Step 5)
> **Date**: 2026-03-31
> **Version**: 1.0

---

## Overview

This document captures ambiguities encountered during Step 5 (Product Experience) and their resolutions or open questions requiring stakeholder input.

---

## Resolved Ambiguities

### RA-001: Formula Builder UX Approach

| Aspect | Decision |
|--------|----------|
| **Question** | How should the formula builder be designed for non-technical users? |
| **Options Considered** | A) Text-based expression editor only, B) Visual drag-and-drop builder, C) Template library + text editor |
| **Resolution** | Option C for MVP: Template library with pre-built formulas + text editor with syntax highlighting and validation. Visual builder deferred to V2. |
| **Rationale** | Non-technical users need templates for common scenarios. Power users need flexibility of text editor. Visual builder adds significant development cost. |
| **Impact** | Formula Builder screen includes template picker and expression editor. No visual drag-drop components. |

---

### RA-002: PIT Bracket UI Approach

| Aspect | Decision |
|--------|----------|
| **Question** | How should PIT progressive brackets be configured? |
| **Options Considered** | A) Simple table editor, B) Table + visual chart, C) Guided wizard |
| **Resolution** | Option B: Table editor with inline validation + visual chart showing rate progression. |
| **Rationale** | Table provides precise control. Chart provides intuitive visualization of progressive rates. Vietnam-specific brackets are standard, no wizard needed. |
| **Impact** | PIT Configuration screen includes both table and chart visualization. |

---

### RA-003: SCD-2 Version Comparison Granularity

| Aspect | Decision |
|--------|----------|
| **Question** | What level of detail should version comparison show? |
| **Options Considered** | A) Full JSON diff, B) Field-by-field comparison, C) Summary only |
| **Resolution** | Option B: Field-by-field comparison with highlighted changes. JSON diff available on hover. |
| **Rationale** | Users need to see what changed at field level. Full JSON diff is too technical. Summary misses important details. |
| **Impact** | Version Comparison Modal shows aligned field pairs with change highlighting. |

---

### RA-004: Employee Picker Integration Timing

| Aspect | Decision |
|--------|----------|
| **Question** | When should employee picker call CO module API? |
| **Options Considered** | A) On-demand per search, B) Pre-load and cache, C) Hybrid with debounce |
| **Resolution** | Option C: Hybrid with debounce. Search triggers API call after 300ms delay. Results cached for session. |
| **Rationale** | Pure on-demand causes latency. Pre-loading all employees is expensive for large organizations. Hybrid provides responsive UX. |
| **Impact** | Employee Picker Modal includes debounce on search input. Cache invalidates on session end. |

---

### RA-005: Validation Error Display Strategy

| Aspect | Decision |
|--------|----------|
| **Question** | How should validation errors be displayed to users? |
| **Options Considered** | A) Modal blocking save, B) Inline field errors only, C) Hybrid with severity-based display |
| **Resolution** | Option C: Hybrid approach based on severity:
- ERROR: Modal blocking save
- WARNING: Banner with acknowledge option
- INFO: Inline text below field |
| **Rationale** | Critical errors must be fixed. Warnings should allow override with acknowledgment. Information should be visible but non-blocking. |
| **Impact** | Validation UI includes multiple components: modal, banner, inline text based on error severity. |

---

## Open Questions

### OQ-001: CalcEngine Snapshot Timing

| Aspect | Details |
|--------|---------|
| **Question** | When does Calculation Engine request configuration snapshot? |
| **Context** | From Step 4 handoff: OQ-001 - CalcEngine may request snapshot on-demand or subscribe to events. |
| **Options** | A) On-demand when calculation starts, B) Pre-generated on configuration change, C) Hybrid with cache |
| **Impact on UX** | If on-demand: May need "Generate Snapshot" button in UI. If pre-generated: Show last snapshot timestamp. |
| **Recommendation** | Hybrid: Cache snapshot on configuration change, show timestamp in UI, allow manual refresh. |
| **Decision Needed By** | Implementation Team (Step 6) |
| **Status** | PENDING |

---

### OQ-002: Multi-Language Support

| Aspect | Details |
|--------|---------|
| **Question** | Should the UI support Vietnamese language? |
| **Context** | Payroll is Vietnam-focused. Users may prefer Vietnamese interface. |
| **Options** | A) English only, B) Vietnamese only, C) Bilingual with user preference |
| **Impact on UX** | Requires translation of all labels, messages, and validation errors. Affects screen layout. |
| **Recommendation** | Bilingual with user preference toggle. Vietnam statutory terms (BHXH, BHYT, BHTN, PIT) should use Vietnamese abbreviations. |
| **Decision Needed By** | Product Owner |
| **Status** | PENDING |

---

### OQ-003: Audit Trail Retention Period

| Aspect | Details |
|--------|---------|
| **Question** | How long should audit entries be retained? |
| **Context** | Compliance requirements may mandate retention period. Database storage considerations. |
| **Options** | A) Indefinite, B) 7 years, C) Configurable per tenant |
| **Impact on UX** | Affects date range filter limits, export options, and query performance. |
| **Recommendation** | Configurable per tenant with minimum 7 years default. Archive old entries to cold storage. |
| **Decision Needed By** | Compliance Officer, IT Admin |
| **Status** | PENDING |

---

### OQ-004: Conflict Resolution Workflow

| Aspect | Details |
|--------|---------|
| **Question** | What is the workflow for resolving configuration conflicts? |
| **Context** | Conflicts detected by Validation BC. Users need to review and resolve. |
| **Options** | A) Immediate resolution required, B) Queue for batch review, C) Auto-resolve when possible |
| **Impact on UX** | Affects Conflict Queue Screen design, notification behavior, and save-blocking. |
| **Recommendation** | Queue for batch review for non-critical conflicts. Immediate resolution required for critical conflicts (version overlap, circular reference). |
| **Decision Needed By** | Product Owner |
| **Status** | PENDING |

---

### OQ-005: Mobile Responsiveness Priority

| Aspect | Details |
|--------|---------|
| **Question** | Which screens must be mobile-responsive? |
| **Context** | Payroll Admins may need to review configurations on mobile. Full CRUD on mobile may be impractical. |
| **Options** | A) All screens responsive, B) Read-only screens responsive, C) Desktop only |
| **Impact on UX** | Affects screen layout, table design, and interaction patterns. |
| **Recommendation** | Read-only screens (List, Detail, Audit Trail) responsive. CRUD screens desktop-focused with responsive fallback. |
| **Decision Needed By** | Product Owner |
| **Status** | PENDING |

---

## Design Decisions Summary

| ID | Topic | Resolution | Status |
|----|-------|------------|--------|
| RA-001 | Formula Builder UX | Template library + text editor | RESOLVED |
| RA-002 | PIT Bracket UI | Table + visual chart | RESOLVED |
| RA-003 | Version Comparison | Field-by-field with highlight | RESOLVED |
| RA-004 | Employee Picker Timing | Hybrid with debounce | RESOLVED |
| RA-005 | Validation Error Display | Severity-based hybrid | RESOLVED |
| OQ-001 | CalcEngine Snapshot | Hybrid with cache | PENDING |
| OQ-002 | Multi-Language | Bilingual preferred | PENDING |
| OQ-003 | Audit Retention | Configurable, 7-year default | PENDING |
| OQ-004 | Conflict Workflow | Queue for batch review | PENDING |
| OQ-005 | Mobile Responsiveness | Read-only responsive | PENDING |

---

## Assumptions

| ID | Assumption | Impact |
|----|------------|--------|
| A-001 | CO module provides Legal Entity and Worker APIs | Employee Picker and Legal Entity dropdown depend on CO |
| A-002 | User authentication via JWT with role claims | Permission checks assume JWT roles |
| A-003 | Vietnam statutory rates will not change during MVP phase | Rate change workflow deferred to P1 |
| A-004 | Single tenant deployment initially | Multi-tenant UI considerations deferred |
| A-005 | Desktop is primary device for Payroll Admins | Mobile-first not required for MVP |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Experience Architect Agent