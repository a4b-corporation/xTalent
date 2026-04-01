# Glossary — BC-06: Worker Self-Service

**Bounded Context**: Worker Self-Service
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Worker Self-Service bounded context. BC-06 is the read-only worker-facing portal for payroll information. It provides workers access to their payslips, year-to-date summaries, and the ability to request PIT withholding certificates. BC-06 never writes payroll data — it consumes output from BC-03, BC-04, and BC-05 as read-only.

---

## Aggregate Roots

### PayslipView

| Field | Value |
|-------|-------|
| **Name** | PayslipView |
| **xTalent Term** | `payslip_view` |
| **Type** | Aggregate Root |
| **Definition** | A worker's read session record for accessing a specific payslip document. Contains: `view_id`, `working_relationship_id`, `legal_entity_id`, `period_id`, `payslip_document_id` (reference to BC-04), `accessed_at`, `ip_address`, `channel` (WEB, MOBILE), `status` (AVAILABLE, VIEWED, DOWNLOADED). BC-06 resolves which PayslipDocument (BC-04) the worker is entitled to view based on their `working_relationship_id` and the requested period. Access is authenticated and logged for audit purposes. |
| **Khac voi** | Not the same as PayslipDocument (BC-04). PayslipDocument is the stored PDF artifact; PayslipView is the worker's access session record. A single PayslipDocument may have multiple PayslipView records if the worker accesses it multiple times. |
| **States** | AVAILABLE, VIEWED, DOWNLOADED |
| **Lifecycle Events** | PayslipAccessed, PayslipDownloaded |

---

### YtdSummary

| Field | Value |
|-------|-------|
| **Name** | YtdSummary |
| **xTalent Term** | `ytd_summary` |
| **Type** | Aggregate Root |
| **Definition** | A worker's year-to-date salary and deduction summary, computed on demand from locked PayrollResult records. Contains: `summary_id`, `working_relationship_id`, `legal_entity_id`, `year`, `ytd_gross`, `ytd_si_employee_bhxh`, `ytd_si_employee_bhyt`, `ytd_si_employee_bhtn`, `ytd_pit`, `ytd_net`, `period_count` (number of periods included), `last_computed_at`. YtdSummary is a computed read-model, not a source-of-truth record. It is recalculated each time the worker requests it, aggregating from all FINAL PayrollResult records for the working_relationship in the year. |
| **Khac voi** | Not a stored balance record. YtdSummary is a projection computed from immutable PayrollResult records (BC-03). It cannot be edited. If a PayrollResult is corrected (via retro adjustment in BC-03), the next YtdSummary computation will reflect the correction automatically. |
| **States** | No state transitions — computed on-demand |
| **Lifecycle Events** | YtdSummaryViewed |

---

### PitCertificateRequest

| Field | Value |
|-------|-------|
| **Name** | PitCertificateRequest |
| **xTalent Term** | `pit_certificate_request` |
| **Type** | Aggregate Root |
| **Definition** | A worker-initiated request for a PIT withholding certificate for a specific year. Contains: `request_id`, `working_relationship_id`, `legal_entity_id`, `year`, `requested_at`, `fulfilled_at`, `pit_certificate_id` (reference to BC-05 PitCertificate once generated), `status` (PENDING, FULFILLED, UNAVAILABLE). On receipt of a PitCertificateRequest, BC-06 checks if a PitCertificate (BC-05) already exists for this worker-year combination. If it exists, the request is immediately fulfilled. If not, BC-06 notifies Payroll Admin to generate the certificate via BC-05. |
| **Khac voi** | Not the same as PitCertificate (BC-05). PitCertificate is the generated document artifact (owned by BC-05); PitCertificateRequest is the worker's demand workflow record (owned by BC-06). The request triggers generation but does not contain the certificate itself. |
| **States** | PENDING, FULFILLED, UNAVAILABLE |
| **Lifecycle Events** | PitCertificateRequested, PitCertificateRequestFulfilled, PitCertificateRequestDenied |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| PayslipAccessed | PayslipView | Worker viewed a payslip in the portal |
| PayslipDownloaded | PayslipView | Worker downloaded a payslip PDF |
| YtdSummaryViewed | YtdSummary | Worker viewed their YTD summary |
| PitCertificateRequested | PitCertificateRequest | Worker submitted a PIT certificate request |
| PitCertificateRequestFulfilled | PitCertificateRequest | Certificate available; request fulfilled |
| PitCertificateRequestDenied | PitCertificateRequest | Certificate unavailable (no payroll data for year) |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| ViewPayslip | Worker | Access a payslip for a specific period |
| DownloadPayslip | Worker | Download a payslip PDF |
| ViewYtdSummary | Worker | Request YTD salary and deduction summary for a year |
| RequestPitCertificate | Worker | Submit a PIT withholding certificate request for a year |

---

## Business Rules (in scope for BC-06)

| Rule ID | Summary |
|---------|---------|
| BR-WSS-01 | A worker may only access payslips for their own `working_relationship_id` — cross-relationship access is forbidden |
| BR-WSS-02 | PayslipView is only available after the PayPeriod has reached LOCKED state in BC-03 |
| BR-WSS-03 | YtdSummary aggregates all FINAL PayrollResult records for the year; DRAFT results are excluded |
| BR-WSS-04 | PitCertificateRequest for the current year is only fulfillable after year-end settlement (AnnualPitSettlementCompleted event from BC-03) |
| BR-WSS-05 | All payslip access events are logged to BC-07 Audit Trail with worker_id, timestamp, and channel |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-06 |
|------|-----------|------------------|
| `working_relationship_id` | CO (EXT-01) | Primary key identifying which worker's data to display; enforces self-service access boundary |
| `legal_entity_id` | CO (EXT-01) | Multi-tenancy scope on all self-service aggregates |
| `PayrollResult` | BC-03 | Source data for YtdSummary computation |
| `PayslipDocument` | BC-04 | Referenced by PayslipView; actual PDF artifact stored in BC-04 |
| `PitCertificate` | BC-05 | Referenced by PitCertificateRequest once generated |
| `PayPeriod` | BC-03 | Used to determine if a payslip is available (must be in LOCKED state) |
