# Glossary — BC-05: Statutory Reporting

**Bounded Context**: Statutory Reporting
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Statutory Reporting bounded context. BC-05 is responsible for generating all compliance filing documents submitted to government agencies: BHXH monthly contribution list, PIT quarterly declaration, and PIT annual withholding certificates.

---

## Aggregate Roots

### BhxhReport

| Field | Value |
|-------|-------|
| **Name** | BhxhReport |
| **xTalent Term** | `bhxh_report` |
| **Type** | Aggregate Root |
| **Definition** | The BHXH D02-LT monthly contribution list submitted to the Social Insurance agency (VssID portal). Contains: `report_id`, `period_id`, `legal_entity_id`, `report_type` (D02_LT), `file_name`, `file_url`, `eligible_worker_count`, `total_bhxh_employee`, `total_bhxh_employer`, `total_bhyt_employee`, `total_bhyt_employer`, `total_bhtn_employee`, `total_bhtn_employer`, `generated_at`, `generated_by`, `status` (GENERATED, SUBMITTED, ACCEPTED, REJECTED). The file format follows BHXH's VssID XML schema. |
| **Khac voi** | Not the same as the PIT declaration. BHXH reports go to the Social Insurance agency (BHXH); PIT declarations go to the General Department of Taxation (GDT). Each has its own format, submission portal, and regulatory deadline. |
| **States** | GENERATED, SUBMITTED, ACCEPTED, REJECTED |
| **Lifecycle Events** | BhxhReportGenerated |

---

### PitDeclaration

| Field | Value |
|-------|-------|
| **Name** | PitDeclaration |
| **xTalent Term** | `pit_declaration` |
| **Type** | Aggregate Root |
| **Definition** | A PIT quarterly declaration or annual settlement filing submitted to the General Department of Taxation (GDT). For quarterly filing: Form 05/KK-TNCN XML per Circular 08/2013/TT-BTC. For annual settlement: Form 05/QTT-TNCN. Contains: `declaration_id`, `period_type` (QUARTERLY, ANNUAL), `quarter` (1–4, or null for annual), `year`, `pay_group_id`, `legal_entity_id`, `xml_file_name`, `file_url`, `worker_count`, `total_pit_withheld`, `generated_at`, `status`. |
| **Khac voi** | The quarterly declaration (05/KK-TNCN) reports monthly PIT withheld per quarter. The annual settlement declaration (05/QTT-TNCN) is the year-end reconciliation. These are separate forms submitted on different schedules. |
| **States** | GENERATED, SUBMITTED, ACCEPTED, REJECTED |
| **Lifecycle Events** | PitDeclarationGenerated |

---

### PitCertificate

| Field | Value |
|-------|-------|
| **Name** | PitCertificate |
| **xTalent Term** | `pit_certificate` / `pit_withholding_certificate` |
| **Type** | Aggregate Root |
| **Definition** | A PIT withholding certificate issued per worker for a calendar year. Documents the total income earned and PIT withheld from a specific working_relationship during the year. Used by workers to file their individual PIT self-assessment or reclaim overpaid tax. Contains: `certificate_id`, `working_relationship_id`, `year`, `legal_entity_id`, `ytd_gross`, `ytd_pit_withheld`, `tax_code`, `worker_name`, `generated_at`, `status`. |
| **Khac voi** | Not the same as PitDeclaration. PitCertificate is an individual worker document (one per worker per year); PitDeclaration is an employer-level filing covering all workers. PitCertificate is accessible via BC-06 Worker Self-Service; PitDeclaration is for Payroll Admin submission to GDT. |
| **States** | GENERATED, AVAILABLE, DOWNLOADED |
| **Lifecycle Events** | PitWithholdingCertificateGenerated |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| BhxhReportGenerated | BhxhReport | D02-LT report generated for a period |
| PitDeclarationGenerated | PitDeclaration | PIT quarterly or annual declaration generated |
| PitWithholdingCertificateGenerated | PitCertificate | PIT withholding certificate generated for a worker for a year |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| GenerateBhxhReport | Payroll Admin | Generate D02-LT for a period after PayPeriodLocked |
| GeneratePitDeclaration | Payroll Admin | Generate quarterly or annual PIT declaration |
| GeneratePitCertificate | Payroll Admin / Worker | Generate PIT withholding certificate for a worker for a year |

---

## Regulatory Forms Reference

| Form | Regulation | Frequency | Submitted To | Description |
|------|-----------|-----------|-------------|-------------|
| D02-LT | BHXH circulars | Monthly | BHXH Agency (VssID) | Social insurance contribution list |
| 05/KK-TNCN | Circular 08/2013/TT-BTC | Quarterly | GDT (eTax) | PIT withholding declaration |
| 05/QTT-TNCN | Circular 08/2013/TT-BTC | Annual | GDT (eTax) | Annual PIT settlement declaration |
| PIT Certificate | PIT Law 04/2007/QH12 | Annual (per worker) | Worker | Individual PIT withholding certificate |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-05 |
|------|-----------|------------------|
| `PayrollResult` | BC-03 | Source of SI contribution amounts and PIT amounts for report population |
| `PayPeriod` | BC-03 | Scope of BHXH report and PIT declaration |
| `CompensationSnapshot` | BC-03 | Source of worker identity and tax code for certificates |
| `working_relationship_id` | CO (EXT-01) | Worker identifier in certificates and declarations |
| `legal_entity_id` | CO (EXT-01) | Employer identifier in all statutory filings |
