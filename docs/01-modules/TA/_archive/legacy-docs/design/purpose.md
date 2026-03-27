# Absence Module Purpose

## Module Overview

The **Absence Module** (Leave Management) is a core component of the xTalent HR system, designed to manage the complete lifecycle of employee time-off requests, from policy definition and balance accrual to request approval, usage tracking, and period-end processing.

## Business Purpose

### Primary Objectives

1. **Centralized Leave Management**: Provide a unified system for managing all types of employee absences (annual leave, sick leave, maternity leave, unpaid leave, etc.)

2. **Accurate Balance Tracking**: Maintain precise, real-time tracking of leave balances for each employee across multiple leave types and classes

3. **Policy-Driven Automation**: Enable configurable policies that automatically handle accrual, carry-forward, expiry, and limit calculations

4. **Compliance & Audit**: Ensure full auditability of all leave transactions with immutable ledger tracking and daily snapshots

5. **Multi-National Support**: Support diverse leave policies across different countries, business units, and legal entities

### Key Capabilities

| Capability | Description |
|------------|-------------|
| **Leave Type Definition** | Define unlimited leave types with custom units, holiday handling, and overlap policies |
| **Leave Class Configuration** | Create operational variants (ACCOUNT/LIMIT mode) with period profiles and event mappings |
| **Policy Management** | Configure accrual, carry-forward, limit, overdraft, and validation rules as reusable policies |
| **Instant Account Management** | Auto-create and manage employee leave accounts (LeaveInstants) with multi-period continuity |
| **Grant Lot Management** | Track individual grant lots with expiry dates and FEFO (First Expire First Out) consumption |
| **Request & Reservation** | Handle leave requests with quota reservation and approval workflows |
| **Event-Driven Automation** | Automated accrual, carry-forward, expiry, and posting via scheduled events |
| **Movement Ledger** | Immutable single-entry ledger (±qty) for all balance changes |
| **Team Staffing Control** | Enforce concurrent leave limits at team/organizational level |
| **Reporting & Analytics** | Daily balance snapshots, movement history, and carry-forward analysis |

## Design Philosophy

### Movement-Based Ledger

The Absence module uses a **single-entry movement ledger** instead of traditional Dr/Cr accounting. Each movement records a ±quantity change, making the system simpler and more performant for balance calculations.

**Key Principles:**
- All balance changes flow through LeaveMovement
- Movements are immutable (corrections use reversal movements)
- Every movement is linked to an event code for traceability

### Event-Driven Architecture

All leave operations are triggered by **events**:
- **Scheduled Events**: Accrual, carry-forward, expiry (time-based triggers)
- **Request-Based Events**: Hold quota, start posting (user action triggers)
- **Manual Events**: Adjustments, reversals (admin intervention)

### Policy-Driven Logic

Business rules are externalized into **LeavePolicy** entities:
- Accrual rules (frequency, amount, proration)
- Carry-forward rules (max carry, expiry)
- Limit rules (yearly caps, monthly limits)
- Overdraft rules (advance allowance)
- Validation rules (evidence requirements, blackout dates)

### Multi-Period Continuity

LeaveInstants persist across periods:
- No account recreation at period boundaries
- Carry-forward handled via movements, not balance transfers
- Period close only affects period status, not account existence

## Module Boundaries

### In Scope (Absence Module)

- Leave type and class configuration
- Leave policy definition and assignment
- Leave instant (account) creation and management
- Grant lot tracking and FEFO consumption
- Leave request submission and approval
- Reservation and quota holding
- Movement posting and ledger management
- Event scheduling and execution
- Period close and carry-forward
- Balance snapshots and reporting

### Out of Scope (Other Modules)

| Function | Owned By |
|----------|----------|
| Employee master data | Employment Module |
| Approval workflow engine | Workflow Module |
| Holiday calendar definition | Common/Localization |
| Organization structure | Organization Module |
| Timesheet entry and approval | Time & Attendance Module |
| Payroll deduction for unpaid leave | Payroll Module |
| Overtime calculation and request | Time & Attendance Module |
| Shift scheduling | Workforce Management Module |

## Integration Points

### Upstream Dependencies

- **Employment Module**: Employee data, assignment to BU/LE
- **Organization Module**: Org unit hierarchy for team limits
- **Common/Holiday**: Holiday calendar for date calculations

### Downstream Consumers

- **Payroll Module**: Unpaid leave deductions, leave encashment
- **Time & Attendance Module**: Timesheet integration, actuals vs. planned
- **Analytics/BI**: Leave trends, absence rates, compliance reporting

## Success Metrics

| Metric | Target |
|--------|--------|
| Balance accuracy | 100% (all movements traceable) |
| Accrual timeliness | On-time monthly/yearly accruals |
| Request processing | < 2 seconds for validation |
| Audit compliance | Full movement history for 7+ years |
| Multi-country support | Configurable per country code |

## Glossary

| Term | Definition |
|------|------------|
| **LeaveType** | Conceptual definition of a leave category (e.g., Annual Leave) |
| **LeaveClass** | Operational variant of a LeaveType (mode, period, rules) |
| **LeaveInstant** | Employee's leave account for a specific LeaveClass |
| **LeaveInstantDetail** | Individual grant lot with expiry date |
| **LeaveMovement** | Immutable ledger entry recording ±balance change |
| **LeaveReservation** | Temporary quota hold for approved requests |
| **FEFO** | First Expire First Out (lot consumption priority) |
| **ACCRUAL** | Periodic grant of leave balance |
| **CARRY** | Transfer of unused balance to next period |
| **EXPIRE** | Loss of unused balance after expiry date |

---

*This document is part of the ODDS v1 documentation standard for the xTalent Absence Module.*
