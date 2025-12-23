# Payroll (PR) - Ontology

**Module**: Payroll (PR)  
**Version**: 2.0  
**Last Updated**: 2025-12-23

---

## Overview

The Payroll ontology defines the foundational data model for comprehensive payroll processing and management. This ontology covers payroll configuration, execution, integration, banking, and audit capabilities across 6 integrated sub-modules.

**Purpose**: Establish a clear, consistent data model that supports:
- Multi-country payroll processing with localized rules
- Flexible payroll element configuration (earnings, deductions, taxes)
- Retroactive adjustments and corrections
- Bank payment file generation and transmission
- Complete audit trail for compliance
- Gateway integration for data exchange

---

## Sub-modules

| Code | Name | Entities | Purpose |
|------|------|----------|---------|
| **CONFIG** | Payroll Configuration | 13 | Master data for calendars, groups, elements, balances, rules, templates |
| **PROCESSING** | Payroll Processing | 9 | Payroll run execution, calculations, results, costing |
| **GATEWAY** | Gateway Integration | 4 | Interface definitions and file processing for data exchange |
| **BANKING** | Banking & Payments | 4 | Bank accounts, payment batch generation and processing |
| **AUDIT** | Audit & Compliance | 1 | Comprehensive audit logging for all payroll activities |
| **UTILITY** | Utility Tables | 8 | Import jobs, generated files, bank/tax templates, policies |

**Total Entities**: 39

---

## Domain Entity Documentation

### Configuration (CONFIG)

**File**: [domain/config-entities.md](./domain/config-entities.md)

**Entities** (13):
- `PayFrequency` - Payroll frequency definitions (monthly, bi-weekly, etc.)
- `PayCalendar` - Payroll calendar with cut-off and pay dates
- `PayGroup` - Payroll processing groups
- `PayElement` - Earnings, deductions, and tax elements
- `BalanceDefinition` - Balance definitions (gross, net, YTD, etc.)
- `CostingRule` - GL costing and distribution rules
- `StatutoryRule` - Country-specific statutory rules
- `GLMapping` - Element to GL account mapping
- `ValidationRule` - Data validation rules
- `PayslipTemplate` - Payslip template definitions
- `PayFormula` - Reusable calculation formulas
- `PayProfile` - Payroll policy profiles
- `PayProfileMap` - Profile to group/employee mapping

### Processing (PROCESSING)

**File**: [domain/processing-entities.md](./domain/processing-entities.md)

**Entities** (9):
- `PayrollBatch` - Payroll run batch header
- `PayrollEmployee` - Employee payroll run results
- `InputValue` - Payroll input values from various sources
- `PayrollResult` - Calculated payroll element results
- `PayrollBalance` - Payroll balance values
- `RetroDelta` - Retroactive adjustment deltas
- `CalculationLog` - Calculation trace and debugging
- `Costing` - GL costing distribution
- `ManualAdjustment` - Manual payroll adjustments

### Gateway Integration (GATEWAY)

**File**: [domain/gateway-entities.md](./domain/gateway-entities.md)

**Entities** (4):
- `InterfaceDefinition` - Interface configuration
- `InterfaceJob` - Interface execution job
- `InterfaceFile` - Interface file tracking
- `InterfaceLine` - Interface file line details

### Banking & Payments (BANKING)

**File**: [domain/banking-entities.md](./domain/banking-entities.md)

**Entities** (4):
- `BankAccount` - Company bank accounts
- `PaymentBatch` - Payment batch for bank file generation
- `PaymentLine` - Individual payment lines

### Audit & Compliance (AUDIT)

**File**: [domain/audit-entities.md](./domain/audit-entities.md)

**Entities** (1):
- `AuditLog` - Comprehensive audit logging

### Utility (UTILITY)

**File**: [domain/utility-entities.md](./domain/utility-entities.md)

**Entities** (8):
- `ImportJob` - CSV/file import job tracking
- `GeneratedFile` - Generated file tracking (payslips, reports)
- `BankTemplate` - Bank file format templates
- `TaxReportTemplate` - Tax report templates
- `PayAdjustReason` - Adjustment reason codes
- `PayDeductionPolicy` - Deduction policy definitions
- `PayBenefitLink` - Element to benefit policy mapping

---

## Workflow Catalogs

### Configuration Workflows

**File**: [workflows/config-workflows.md](./workflows/config-workflows.md)

**Workflows** (5):
- WF-PR-CONFIG-001: Pay Calendar Setup
- WF-PR-CONFIG-002: Pay Group Configuration
- WF-PR-CONFIG-003: Pay Element Management
- WF-PR-CONFIG-004: Formula & Rule Configuration
- WF-PR-CONFIG-005: Payslip Template Design

### Processing Workflows

**File**: [workflows/processing-workflows.md](./workflows/processing-workflows.md)

**Workflows** (6):
- WF-PR-PROC-001: Standard Payroll Run
- WF-PR-PROC-002: Supplemental Payroll Run
- WF-PR-PROC-003: Retroactive Adjustment Processing
- WF-PR-PROC-004: Manual Adjustment Entry
- WF-PR-PROC-005: Payroll Validation & Review
- WF-PR-PROC-006: Payroll Finalization

### Gateway Workflows

**File**: [workflows/gateway-workflows.md](./workflows/gateway-workflows.md)

**Workflows** (3):
- WF-PR-GW-001: Interface Definition Setup
- WF-PR-GW-002: Inbound Data Processing
- WF-PR-GW-003: Outbound File Generation

### Banking Workflows

**File**: [workflows/banking-workflows.md](./workflows/banking-workflows.md)

**Workflows** (3):
- WF-PR-BANK-001: Payment File Generation
- WF-PR-BANK-002: Bank File Transmission
- WF-PR-BANK-003: Payment Confirmation Processing

---

## Glossaries

Quick reference glossaries for each sub-module:

- [glossary-config.md](./glossary-config.md) - Configuration terminology
- [glossary-processing.md](./glossary-processing.md) - Processing terminology
- [glossary-gateway.md](./glossary-gateway.md) - Gateway terminology
- [glossary-banking.md](./glossary-banking.md) - Banking terminology
- [glossary-audit.md](./glossary-audit.md) - Audit terminology
- [glossary-utility.md](./glossary-utility.md) - Utility terminology
- [glossary-index.md](./glossary-index.md) - Master glossary index

---

## Design Principles

### 1. Multi-Currency Support

The payroll system supports multi-currency processing:
- `PayCalendar` has `default_currency` field
- `PayGroup` specifies `currency_code`
- All monetary amounts include `currency_code`

### 2. SCD Type 2 for Master Data

Master configuration entities use SCD Type 2 for historical tracking:
- `PayCalendar`, `PayElement`, `BalanceDefinition`, `CostingRule`
- `StatutoryRule`, `ValidationRule`, `PayslipTemplate`, `PayProfile`

This ensures accurate historical payroll calculations and audit compliance.

### 3. Thin Persistence Pattern

Payroll processing uses a "thin persistence" pattern:
- Minimal data stored during run (inputs, results, balances)
- Detailed calculations logged for debugging
- Results can be recalculated from inputs if needed

### 4. Retroactive Processing

Comprehensive retroactive adjustment support:
- `RetroDelta` tracks differences from original runs
- `original_run_id` and `reversed_by_run_id` for audit trail
- Delta amounts applied in subsequent runs

### 5. Flexible Integration

Gateway pattern for data exchange:
- Configurable interface definitions (CSV, JSON, API)
- Mapping configuration for field transformations
- Job and file tracking for monitoring

---

## Integration Points

### Core Module (CO)

- **Employee** → `PayrollEmployee.employee_id`
- **LegalEntity** → `PayCalendar.legal_entity_id`, `PayGroup.legal_entity_id`
- **TalentMarket** → `PayCalendar.market_id`, `PayGroup.market_id`

### Time & Attendance (TA)

- Time entries → `InputValue` (source_type = 'TimeAttendance')
- Absence data → `InputValue` (source_type = 'Absence')

### Total Rewards (TR)

- Compensation elements → `PayElement` configuration
- Benefits → `PayBenefitLink` mapping

### External Systems

- **Banking Systems**: Payment file generation and transmission
- **Tax Authorities**: Tax reporting and compliance
- **Accounting/GL**: Costing distribution and journal entries

---

## References

- **Database Schema**: [../03-design/5.Payroll.V3.dbml](../03-design/5.Payroll.V3.dbml)
- **Concept Guides**: [../01-concept/](../01-concept/)
- **Specifications**: [../02-spec/](../02-spec/)
- **Module Standards**: [../../MODULE-DOCUMENTATION-STANDARDS.md](../../MODULE-DOCUMENTATION-STANDARDS.md)

---

**Document Version**: 1.0  
**Created**: 2025-12-23  
**Last Review**: 2025-12-23  
**Reviewed By**: xTalent Documentation Team
