# Glossary — BC-04: Payment Output

**Bounded Context**: Payment Output
**Module**: Payroll (PR)
**Step**: 3 — Domain Architecture
**Date**: 2026-03-31

---

## Purpose

This glossary defines the ubiquitous language for the Payment Output bounded context. BC-04 is responsible for generating all output artifacts from approved payroll results: bank payment files for disbursement, GL journal entries for accounting, and payslip documents for workers.

---

## Aggregate Roots

### BankPaymentFile

| Field | Value |
|-------|-------|
| **Name** | BankPaymentFile |
| **xTalent Term** | `bank_payment_file` |
| **Type** | Aggregate Root |
| **Definition** | A structured output file containing payment instructions for one bank (VCB, BIDV, or TCB) for a given PayPeriod. Contains: `file_id`, `period_id`, `pay_group_id`, `legal_entity_id`, `bank_code`, `file_name`, `file_url`, `payment_channel` (FILE_MANUAL in V1), `record_count`, `total_amount_vnd`, `generated_at`, `generated_by`, `status` (GENERATED, DOWNLOADED, SUBMITTED). Each record in the file corresponds to one worker's net payment to their bank account. |
| **Khac voi** | The `BankPaymentFile` is a bank-specific rendering of the bank-agnostic `BankPaymentRequest` domain concept. The file format varies by bank (VCB, BIDV, TCB have different column layouts and encoding requirements) but the domain data is the same. |
| **States** | GENERATED, DOWNLOADED, SUBMITTED |
| **Lifecycle Events** | BankPaymentFileGenerated |

---

### GlJournal

| Field | Value |
|-------|-------|
| **Name** | GlJournal |
| **xTalent Term** | `gl_journal` |
| **Type** | Aggregate Root |
| **Definition** | A VAS-compliant General Ledger journal entry batch generated after a PayPeriod is approved. Contains: `journal_id`, `period_id`, `legal_entity_id`, `journal_line_count`, `total_debit`, `total_credit`, `generated_at`, `status`. Each journal line has: `account_code` (Vietnamese accounting TK codes: 334 salary payable, 338 SI payable, 3383 employer SI, 3335 PIT payable, 642 labor cost), `debit_amount`, `credit_amount`, `cost_center_id`, `description`. |
| **Khac voi** | Not the same as a bank payment file. The GlJournal is for internal accounting (cost recognition and liability recording); the BankPaymentFile is for external disbursement (payment to workers). Both are generated from the same approved PayrollResult data, but serve different audiences. |
| **States** | GENERATED, POSTED |
| **Lifecycle Events** | GlJournalGenerated |

---

### PayslipDocument

| Field | Value |
|-------|-------|
| **Name** | PayslipDocument |
| **xTalent Term** | `payslip_document` |
| **Type** | Aggregate Root |
| **Definition** | A generated PDF payslip document for a specific worker for a specific PayPeriod. Contains: `payslip_id`, `working_relationship_id`, `period_id`, `legal_entity_id`, `template_code`, `file_url`, `generated_at`, `status` (GENERATED, AVAILABLE, VIEWED, DOWNLOADED). Generated from the locked PayrollResult. Immutable once generated (regeneration creates a new record). |
| **Khac voi** | Not the same as a PayslipView (BC-06). PayslipDocument is the stored file artifact. PayslipView is the worker's read session in the self-service portal. BC-06 accesses PayslipDocument records from BC-04 as a read-only consumer. |
| **States** | GENERATED, AVAILABLE, VIEWED, DOWNLOADED |
| **Lifecycle Events** | PayslipsGenerated |

---

## Value Objects

### BankPaymentRecord

| Field | Value |
|-------|-------|
| **Name** | BankPaymentRecord |
| **Type** | Value Object (line item within BankPaymentFile) |
| **Definition** | A single payment instruction for one worker: `working_relationship_id`, `worker_name`, `bank_account_number`, `bank_branch_code`, `amount_vnd`, `description` (period reference). Format is adapted per bank adapter. |

---

### GlJournalLine

| Field | Value |
|-------|-------|
| **Name** | GlJournalLine |
| **Type** | Value Object (line item within GlJournal) |
| **Definition** | A single debit or credit entry: `line_number`, `account_code`, `debit_amount`, `credit_amount`, `cost_center_id`, `description`, `reference` (period_id + run_id). Vietnamese TK codes used: 334 (salary payable to workers), 338 (SI contributions payable), 3383 (employer SI cost), 3335 (PIT payable to tax authority), 642 (labor cost expense). |

---

## Domain Events

| Event Name | Aggregate | Description |
|------------|-----------|-------------|
| BankPaymentFileGenerated | BankPaymentFile | Bank payment file created for a given bank and period |
| GlJournalGenerated | GlJournal | GL journal entries generated after period approval |
| PayslipsGenerated | PayslipDocument | Payslip PDFs generated for all workers in a period |

---

## Commands

| Command Name | Actor | Description |
|--------------|-------|-------------|
| GenerateBankPaymentFile | Finance Manager | Trigger bank file generation for a specific bank after PayrollRunApproved |
| GenerateGlJournal | Finance Manager / System | Trigger GL journal generation after PayPeriodLocked |
| GeneratePayslips | Payroll Admin / System | Trigger payslip PDF generation after PayPeriodLocked |

---

## Bank Adapters (V1 Scope)

| Bank Code | File Format | Character Set | Encoding |
|-----------|-------------|---------------|---------|
| VCB | VCB standard salary file | UTF-8 | CSV/TXT |
| BIDV | BIDV payroll format | UTF-8 | Excel/CSV |
| TCB | TCB mass payment | UTF-8 | CSV |

All adapters read from the bank-agnostic `BankPaymentRequest` domain concept and transform to bank-specific format. API push (V2) is deferred — see AQ-05 Decision D.

---

## GL Account Codes (VAS Reference)

| TK Code | Meaning | Journal Role |
|---------|---------|-------------|
| 334 | Phải trả người lao động (Salary payable to workers) | Credit (liability created) |
| 338 | Phải trả, phải nộp khác — SI (BHXH/BHYT/BHTN payable) | Credit (liability) |
| 3383 | BHXH, BHYT employer contributions | Credit (liability) |
| 3335 | Thuế TNCN phải nộp (PIT payable to GDT) | Credit (liability) |
| 642 | Chi phí quản lý doanh nghiệp — labor cost | Debit (expense) |

---

## Terms Used from External Bounded Contexts

| Term | Source BC | How Used in BC-04 |
|------|-----------|------------------|
| `PayrollResult` | BC-03 | Primary data source for generating all output artifacts |
| `PayPeriod` | BC-03 | Triggers output generation after PayPeriodLocked event |
| `CompensationSnapshot` | BC-03 | Source of bank_account_id for bank payment records |
| `legal_entity_id` | CO (EXT-01) | Multi-tenancy isolation on all output artifacts |
| `working_relationship_id` | CO (EXT-01) | Links each payment record to a specific worker's employment context |
| `bank_account` | CO (EXT-01) | Bank account details (number, branch) for payment file population |
