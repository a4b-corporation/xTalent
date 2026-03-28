# AUDT-A-001 — Audit Trail Viewer

**Type**: Analytics | **Priority**: P0 | **BC**: BC-10 Audit & Observability
**Country**: [All countries]

---

## Purpose

Provides compliance officers, HR admins, and external auditors with an immutable, searchable audit trail of all changes across the Total Rewards module. No records can be deleted or modified — append-only. Access is scoped per role and legal entity. Used for regulatory compliance (Vietnam Labor Code, PDPA, GDPR), internal audits, and dispute resolution.

---

## Data Sources

| Source | Data Used |
|--------|---------|
| `tr.audit_record` | All entity changes across all BCs |
| `co.worker` | Actor name resolution |
| `co.legal_entity` | Scope filtering |

All changes to salary, benefits, contributions, offers, and tax data create an `AuditRecord` automatically. No manual audit entry.

---

## Key Metrics / Dimensions

| Dimension | Options |
|-----------|---------|
| Entity Type | SalaryRecord / CompensationProposal / ContributionConfig / OfferRecord / TaxBracket / BenefitEnrollment / DeductionRecord / CalculationRule / FxRateRecord / All |
| Action | CREATE / UPDATE / DELETE_ATTEMPT / APPROVE / REJECT |
| Actor | Worker ID / name / role |
| Legal Entity | Scoped per user's access |
| Date Range | Custom date picker; default last 30 days |
| Business Unit | Department filter |
| Search | Free-text search on entity_id, reason, actor name |

---

## Visualizations & Views

### 1. Audit Log Table (primary view)

| Column | Description |
|--------|-------------|
| Timestamp | UTC + local timezone |
| Entity Type | Color-coded badge |
| Entity ID | Clickable → entity detail |
| Action | CREATE / UPDATE / APPROVE etc. |
| Actor | Name + role |
| Before | Collapsed JSON diff (click to expand) |
| After | Collapsed JSON diff (click to expand) |
| Reason | Justification if provided |
| Legal Entity | Scope |

**Features**:
- Virtual scroll (handles 100K+ records)
- Real-time streaming: new audit records appear automatically
- Diff view: side-by-side before/after for UPDATE records
- "Export Page" / "Export All Matching" to Excel / PDF

### 2. Anomaly Detection Panel

System flags suspicious patterns:
- Salary change > 50% in single record
- FX rate override without approver
- Same Worker's salary changed > 3 times in 30 days
- DeductionRecord created with GARNISHMENT type (high priority)
- Calculation rule changed within 7 days of payroll run
- Access outside business hours (configurable)

Flagged records shown with 🚨 badge. Compliance Officer can mark as "reviewed" or "escalate".

### 3. Compliance Summary Dashboard

| Metric | Description |
|--------|-------------|
| Records this period | Count of audit entries |
| Anomalies detected | Count with severity |
| Salary changes | Count by type (merit / correction / regulatory) |
| Config changes | Changes to SI rates, tax brackets, min wage |
| FX overrides | Count + approver name |
| Failed deletion attempts | Count (blocked by immutability) |

---

## Access Control (Strict)

| Role | Access Scope |
|------|-------------|
| Compliance Officer | All records within their LE mandate |
| HR Admin | All TR records for their LE |
| Compensation Admin | SalaryRecord, CompensationProposal audit only |
| Tax Admin | Tax, SI Contribution, FX rate records only |
| Finance Approver | Budget, FX override, bonus approval records |
| External Auditor | Read-only; scoped to specific LE + time range granted by HR Admin |
| Worker | Own records only (salary changes, benefit changes affecting them) |
| People Manager | Not accessible |

External Auditor access: granted by HR Admin via "Grant Audit Access" wizard:
- Select auditor (external email)
- Select scope: Legal Entity(s), date range
- Access expires automatically on grant end date

---

## Data Retention

| Record Type | Retention |
|-------------|-----------|
| Salary changes | 7 years (Vietnam labor law requirement) |
| Tax records | 10 years |
| Benefits | 7 years |
| FX overrides | 5 years |
| All others | 5 years minimum |

Records are NEVER deleted — archive to cold storage after retention period, but still queryable.

---

## Export for Compliance Reporting

| Report Type | Description |
|------------|-------------|
| Salary Change Report | All salary changes in period with before/after values |
| SI Contribution Audit | All SI calculations for Vietnam labor inspection |
| FX Override Report | All manual FX overrides with justifications |
| Config Change Report | All changes to tax brackets, SI rates, min wage |
| Access Log | Who accessed what audit records and when |

All exports: Excel + PDF. Include digital hash for integrity verification.

---

## Immutability Guarantee

- `AuditRecord` table: `INSERT` only — no `UPDATE`, no `DELETE`
- Database-level trigger enforces this (not just application-level)
- Any `DELETE_ATTEMPT` is itself logged as an `AuditRecord`
- Monthly integrity check: row count + hash comparison vs previous month

---

*AUDT-A-001 — Audit Trail Viewer*
*2026-03-27*
