# Tax Withholding - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Tax Withholding

---

## Overview

Tax Withholding manages employee tax withholding elections, declarations, and adjustments for accurate payroll tax calculation.

---

## Entities

### 1. TaxWithholding
**Definition**: Employee tax withholding election (W-4 in US, tax declaration in Vietnam).
**Purpose**: Captures employee tax preferences for withholding calculation.
**Attributes**: `employee_id`, `country_code`, `filing_status` (SINGLE, MARRIED, HEAD_OF_HOUSEHOLD), `allowances`, `additional_withholding`, `exempt`, `effective_date`

**Example**:
```yaml
TaxWithholding:
  employee_id: "EMP_001_UUID"
  country_code: "VN"
  filing_status: MARRIED
  allowances: 2  # Self + 1 dependent
  additional_withholding: 0
  exempt: false
```

### 2. TaxDeclaration
**Definition**: Annual tax declaration with deductions and dependents.
**Purpose**: Stores employee tax declaration for annual tax calculation.
**Attributes**: `employee_id`, `tax_year`, `personal_deduction`, `dependent_count`, `dependent_deduction`, `insurance_deduction`, `charity_deduction`, `status` (DRAFT, SUBMITTED, APPROVED)

### 3. TaxAdjustment
**Definition**: Mid-year tax withholding adjustments.
**Purpose**: Allows corrections to tax withholding during the year.
**Attributes**: `employee_id`, `adjustment_date`, `adjustment_type` (INCREASE, DECREASE, CORRECTION), `amount`, `reason`, `approved_by`

---

## Summary
**3 entities** for tax withholding management and compliance.

**Key Features**:
- ✅ Multi-country tax support
- ✅ Dependent tracking
- ✅ Mid-year adjustments
- ✅ Approval workflows

**Document Status**: ✅ Complete | **Coverage**: 3/3 entities
