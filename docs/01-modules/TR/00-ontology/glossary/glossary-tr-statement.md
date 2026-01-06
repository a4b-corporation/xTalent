# Total Rewards Statement - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Total Rewards Statement

---

## Overview

Total Rewards Statement generates comprehensive compensation statements showing employees their total rewards value including fixed pay, variable pay, benefits, and perks.

---

## Entities

### 1. StatementConfiguration
**Definition**: Configuration for statement layout, sections, and generation schedule.
**Purpose**: Defines how statements are structured and when they're generated.
**Key Attributes**: `code`, `layout_json`, `schedule_json`, `version_no`

### 2. StatementSection
**Definition**: Predefined sections (FIXED_COMP, VARIABLE_COMP, BENEFITS, PERKS, TOTAL).
**Purpose**: Defines data sources for each statement section.

### 3. StatementJob
**Definition**: Batch job for generating statements for a population.
**Purpose**: Manages mass statement generation process.
**Attributes**: `config_id`, `generation_date`, `status` (QUEUED, RUNNING, COMPLETED, FAILED), `total_employees`, `completed_count`

### 4. StatementLine
**Definition**: Individual employee statement with calculated total rewards value.
**Purpose**: Stores generated statement data per employee.
**Attributes**: `employee_id`, `job_id`, `statement_data_json`, `total_value`, `pdf_url`, `status` (GENERATED, SENT, VIEWED)

---

## Summary
**4 entities** for total rewards statement generation and distribution.

**Document Status**: ✅ Complete | **Coverage**: 4/4 entities
