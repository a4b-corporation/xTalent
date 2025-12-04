# Taxable Bridge - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Taxable Bridge

---

## Overview

Taxable Bridge provides integration between Total Rewards and Payroll modules for taxable benefits and non-cash compensation that must be reported for tax purposes.

---

## Entity

### TaxableItem

**Definition**: Bridge table to payroll for taxable benefits capturing non-cash compensation that must be taxed.

**Purpose**: Ensures all taxable benefits are properly reported and taxed through payroll.

**Key Characteristics**:
- Links TR events to payroll for tax withholding
- Supports multiple source modules (BENEFIT, EQUITY, PERK, RECOGNITION, REIMBURSEMENT)
- Tracks processing status
- Annual tax reporting (W-2, 1099, etc.)

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `source_module` | enum | Yes | BENEFIT, EQUITY, PERK, RECOGNITION, REIMBURSEMENT, OTHER |
| `source_table` | string(50) | Yes | Source table name |
| `source_id` | UUID | Yes | Source record ID |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `taxable_amount` | decimal(18,4) | Yes | Amount subject to tax |
| `currency` | string(3) | Yes | Currency code |
| `tax_year` | integer | Yes | Tax year (e.g., 2025) |
| `tax_period` | integer | No | Tax period within year (1-12 for monthly) |
| `item_type` | enum | Yes | EQUITY_VEST, PERK_REDEMPTION, BENEFIT_PREMIUM, RECOGNITION_AWARD, REIMBURSEMENT |
| `description` | string(500) | No | Item description |
| `payroll_batch_id` | UUID | No | FK to Payroll.Batch (when processed) |
| `processed_flag` | boolean | No | Whether processed in payroll (default: false) |
| `processed_at` | timestamp | No | When item was processed |
| `tax_withheld` | decimal(18,4) | No | Tax amount withheld |

**Business Rules**:
1. Created when taxable event occurs (equity vest, perk redemption, etc.)
2. Processed by payroll module for tax withholding
3. Reported on annual tax forms (W-2, 1099, etc.)
4. One item per taxable event
5. Must be processed before year-end tax reporting

**Examples**:

```yaml
Example 1: RSU Vesting (Taxable Event)
  TaxableItem:
    source_module: EQUITY
    source_table: "equity_vesting_event"
    source_id: "VEST_EVENT_UUID"
    employee_id: "EMP_001_UUID"
    taxable_amount: 10000000  # VND (1000 units * 10,000 FMV)
    currency: "VND"
    tax_year: 2025
    tax_period: 3  # March
    item_type: EQUITY_VEST
    description: "RSU vesting - 1000 units @ 10,000 VND"
    processed_flag: true
    tax_withheld: 2000000  # 20% withholding

Example 2: High-Value Perk Redemption
  TaxableItem:
    source_module: PERK
    source_table: "perk_redemption"
    source_id: "REDEMPTION_UUID"
    employee_id: "EMP_002_UUID"
    taxable_amount: 5000000  # VND
    currency: "VND"
    tax_year: 2025
    tax_period: 6  # June
    item_type: PERK_REDEMPTION
    description: "Laptop redemption - taxable fringe benefit"
    processed_flag: false

Example 3: Recognition Award
  TaxableItem:
    source_module: RECOGNITION
    source_table: "recognition_event"
    source_id: "RECOGNITION_UUID"
    employee_id: "EMP_003_UUID"
    taxable_amount: 1000000  # VND cash award
    currency: "VND"
    tax_year: 2025
    tax_period: 12  # December
    item_type: RECOGNITION_AWARD
    description: "Year-end excellence award"
```

**Integration Flow**:

1. **Taxable Event Occurs** (e.g., RSU vests)
2. **TaxableItem Created** → Source module creates record
3. **Payroll Processing** → Payroll module queries unprocessed items
4. **Tax Withholding** → Tax calculated and withheld
5. **Mark Processed** → `processed_flag = true`, `payroll_batch_id` set
6. **Year-End Reporting** → All items aggregated for W-2/1099

**Tax Reporting**:
- All items for tax_year aggregated
- Reported on appropriate tax forms
- Supports multi-country tax compliance
- Audit trail for tax authorities

---

## Summary

**1 entity** bridging Total Rewards to Payroll for tax compliance.

**Key Features**:
- ✅ Multi-source support (equity, benefits, perks, recognition)
- ✅ Automatic tax withholding integration
- ✅ Year-end tax reporting
- ✅ Processing status tracking
- ✅ Complete audit trail

**Critical for**:
- Tax compliance
- Payroll integration
- Year-end reporting
- IRS/tax authority audits

---

**Document Status**: ✅ Complete  
**Coverage**: 1 of 1 entity documented  
**Last Updated**: 2025-12-04
