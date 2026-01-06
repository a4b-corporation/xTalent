# Deductions - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Deductions

---

## Overview

Deductions manages employee deductions including loans, garnishments, and salary advances with automated payment schedules.

---

## Entities

### 1. DeductionType
**Definition**: Types of deductions (LOAN, GARNISHMENT, ADVANCE, UNION_DUES, CHARITABLE, OTHER).
**Purpose**: Categorizes deductions with default rules.
**Attributes**: `code`, `name`, `category`, `max_percentage_of_salary`, `priority_order`

### 2. EmployeeDeduction
**Definition**: Employee deduction record with total amount and payment terms.
**Purpose**: Tracks individual deduction agreements.
**Attributes**: `employee_id`, `deduction_type_code`, `total_amount`, `remaining_balance`, `installment_amount`, `start_date`, `end_date`, `status` (ACTIVE, COMPLETED, SUSPENDED, CANCELLED)

### 3. DeductionSchedule
**Definition**: Payment schedule for deductions (monthly, biweekly, etc.).
**Purpose**: Defines when deductions are taken from payroll.
**Attributes**: `deduction_id`, `scheduled_date`, `amount`, `status` (SCHEDULED, PROCESSED, SKIPPED)

### 4. DeductionTransaction
**Definition**: Individual deduction transaction record.
**Purpose**: Tracks each deduction taken from payroll.
**Attributes**: `deduction_id`, `payroll_batch_id`, `amount_deducted`, `balance_after`, `transaction_date`

---

## Summary
**4 entities** for employee deduction management with automated scheduling.

**Document Status**: ✅ Complete | **Coverage**: 4/4 entities
