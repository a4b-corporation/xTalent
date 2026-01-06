# Variable Pay - Glossary

**Version**: 2.1  
**Last Updated**: 2025-12-11  
**Module**: Total Rewards (TR)  
**Sub-module**: Variable Pay

---

## Overview

Variable Pay manages performance-based compensation including bonuses, equity grants, and sales commissions. This sub-module provides:

- **Bonus Management**: STI (short-term incentive), LTI (long-term incentive), spot bonuses
- **Equity Compensation**: RSU, stock options, SAR, phantom stock with vesting schedules
- **Commission Plans**: Revenue-based, tiered, accelerator commission structures
- **Budget Pools**: Distributed bonus allocation across legal entities
- **Approval Workflows**: Multi-level approval for bonus and commission payouts

This sub-module is critical for **performance-driven compensation** and talent retention.

---

## Entities

### 1. BonusPlan

**Definition**: Template defining bonus plan structure, eligibility rules, and calculation formulas.

**Purpose**: Standardizes bonus programs across the organization (STI, LTI, retention, sign-on).

**Key Characteristics**:
- Multiple bonus types (STI, LTI, COMMISSION, SPOT_BONUS, RETENTION, SIGN_ON)
- Flexible formula-based calculations
- Configurable eligibility criteria
- Optional equity component
- Performance and company multipliers

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique plan code (e.g., STI_2025, LTI_2025_2027) |
| `name` | string(200) | Yes | Plan name |
| `description` | text | No | Detailed description |
| `bonus_type` | enum | Yes | STI, LTI, COMMISSION, SPOT_BONUS, RETENTION, SIGN_ON |
| `equity_flag` | boolean | No | Whether bonus includes equity (default: false) |
| `formula_json` | jsonb | No | Bonus calculation formula |
| `eligibility_rule` | jsonb | No | Eligibility criteria |
| `effective_start_date` | date | Yes | When plan becomes active |
| `effective_end_date` | date | No | When plan expires |
| `is_active` | boolean | No | Active status |

**Formula JSON Structure**:

```yaml
formula_json:
  base: "ANNUAL_SALARY"  # or MONTHLY_SALARY, FIXED_AMOUNT
  target_pct: 0.15       # 15% target bonus
  performance_multiplier:
    EXCEEDS: 1.5
    MEETS: 1.0
    BELOW: 0.5
    UNSATISFACTORY: 0.0
  company_multiplier_range: [0.8, 1.2]  # 80-120% based on company performance
```

**Eligibility Rule Structure**:

```yaml
eligibility_rule:
  min_tenure_months: 6
  employment_types: ["FULL_TIME"]
  grades: ["G5", "G6", "M1", "M2"]
  performance_rating_min: "MEETS"
  exclude_probation: true
```

**Business Rules**:
1. STI typically annual, LTI multi-year (2-4 years)
2. Commission plans have different calculation logic (see CommissionPlan)
3. Eligibility rules evaluated at cycle start
4. equity_flag = true links to EquityGrant entity

**Examples**:

```yaml
Example 1: Annual STI Plan
  BonusPlan:
    code: "STI_2025"
    name: "2025 Short-Term Incentive"
    bonus_type: STI
    equity_flag: false
    formula_json:
      base: "ANNUAL_SALARY"
      target_pct: 0.15
      performance_multiplier:
        EXCEEDS: 1.5
        MEETS: 1.0
        BELOW: 0.5
      company_multiplier_range: [0.8, 1.2]
    eligibility_rule:
      min_tenure_months: 6
      grades: ["G5", "G6", "M1", "M2", "M3"]

Example 2: Long-Term Incentive (with equity)
  BonusPlan:
    code: "LTI_2025_2027"
    name: "2025-2027 Long-Term Incentive"
    bonus_type: LTI
    equity_flag: true
    formula_json:
      base: "ANNUAL_SALARY"
      target_pct: 0.30
      vesting_years: 3
    eligibility_rule:
      min_grade: "M2"
      performance_rating_min: "MEETS"
```

**Best Practices**:
- ✅ DO: Define clear eligibility criteria
- ✅ DO: Use performance multipliers for differentiation
- ✅ DO: Set company multiplier range for business performance alignment
- ❌ DON'T: Make formulas too complex (hard to communicate)
- ❌ DON'T: Change eligibility mid-cycle

---

### 2. BonusCycle

**Definition**: Specific instance of a bonus plan for a defined performance period with budget and workflow management.

**Purpose**: Manages execution of bonus plan including budget tracking, approval workflow, and payout timing.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `plan_id` | UUID | Yes | FK to BonusPlan |
| `code` | string(50) | Yes | Cycle identifier (e.g., STI_2025_Q1, LTI_2025) |
| `name` | string(200) | Yes | Cycle name |
| `period_start` | date | Yes | Performance period start |
| `period_end` | date | Yes | Performance period end |
| `payout_date` | date | No | Planned payout date |
| `budget_amount` | decimal(18,4) | No | Total budget |
| `currency` | string(3) | Yes | Currency code |
| `workflow_state` | jsonb | No | Current workflow state |
| `status` | enum | No | DRAFT, OPEN, IN_REVIEW, APPROVED, PAID, CLOSED, CANCELLED |

**Business Rules**:
1. period_end must be after period_start
2. payout_date typically after period_end (e.g., 30-60 days)
3. Cannot modify PAID or CLOSED cycle
4. Budget tracked in real-time via BonusPool

**Examples**:

```yaml
Example: 2025 Annual STI Cycle
  BonusCycle:
    plan_id: "STI_2025_UUID"
    code: "STI_2025_ANNUAL"
    name: "2025 Annual STI Cycle"
    period_start: "2025-01-01"
    period_end: "2025-12-31"
    payout_date: "2026-03-15"
    budget_amount: 10000000000  # 10B VND
    currency: "VND"
    status: OPEN
```

---

### 3. BonusPool

**Definition**: Budget pool for bonus allocation by legal entity or business unit.

**Purpose**: Enables distributed bonus budget management across organizational units.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `cycle_id` | UUID | Yes | FK to BonusCycle |
| `legal_entity_id` | UUID | Yes | FK to Core.LegalEntity |
| `name` | string(200) | Yes | Pool name |
| `budget_amount` | decimal(18,4) | Yes | Allocated budget |
| `utilized_amount` | decimal(18,4) | No | Sum of approved allocations (default: 0) |
| `currency` | string(3) | Yes | Currency code |

**Business Rules**:
1. utilized_amount = SUM(approved_amount) from BonusAllocation
2. utilized_amount should not exceed budget_amount (warning, not hard block)
3. Real-time budget tracking as allocations are approved

**Examples**:

```yaml
Example: Vietnam STI Pool
  BonusPool:
    cycle_id: "STI_2025_UUID"
    legal_entity_id: "VNG_CORP_UUID"
    name: "Vietnam STI Pool 2025"
    budget_amount: 5000000000  # 5B VND
    utilized_amount: 3200000000  # 3.2B VND used
    currency: "VND"
```

---

### 4. BonusAllocation

**Definition**: Individual bonus allocation to employee with approval workflow.

**Purpose**: Tracks proposed and approved bonus amounts with full calculation breakdown.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `pool_id` | UUID | Yes | FK to BonusPool |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `proposed_amount` | decimal(18,4) | Yes | Proposed bonus |
| `approved_amount` | decimal(18,4) | No | Final approved amount |
| `currency` | string(3) | Yes | Currency code |
| `performance_rating` | string(50) | No | Performance rating |
| `performance_multiplier` | decimal(5,4) | No | Performance multiplier applied |
| `company_multiplier` | decimal(5,4) | No | Company multiplier applied |
| `calculation_details` | jsonb | No | Full calculation breakdown |
| `status` | enum | No | DRAFT, PENDING, APPROVED, REJECTED, PAID |
| `approver_emp_id` | UUID | No | FK to Core.Employee (approver) |
| `decision_date` | timestamp | No | When decision was made |

**Calculation Details JSON**:

```yaml
calculation_details:
  base_salary: 50000000
  target_pct: 0.15
  target_bonus: 7500000
  performance_multiplier: 1.2
  company_multiplier: 1.1
  calculated_bonus: 9900000
  proposed_bonus: 9900000
  approved_bonus: 10000000
```

**Business Rules**:
1. approved_amount may differ from proposed_amount (manager discretion)
2. Cannot modify APPROVED or PAID allocation
3. Approval required based on amount thresholds

---

## Summary (Part 1 of 2)

**Entities Covered**: 4 of 9
- BonusPlan
- BonusCycle
- BonusPool
- BonusAllocation

**Next**: EquityGrant, EquityVestingEvent, EquityTransaction, CommissionPlan, CommissionTier, CommissionTransaction

---

**Document Status**: 🔄 In Progress (Part 1)  
**Coverage**: 4 of 9 entities documented  
**Last Updated**: 2025-12-04

### 5. EquityGrant

**Definition**: Equity grant lifecycle management for RSU, stock options, SAR, and phantom stock.

**Purpose**: Tracks total, vested, exercised, and forfeited equity units with vesting schedules.

**Key Characteristics**:
- Multiple equity types (RSU, OPTION, SAR, PHANTOM_STOCK)
- Flexible vesting schedules (time-based, performance-based)
- Cliff and gradual vesting support
- Automatic vesting event generation
- Termination and forfeiture handling

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `plan_id` | UUID | Yes | FK to BonusPlan (equity plans) |
| `grant_number` | string(50) | Yes | Unique grant ID (e.g., RSU-2025-001234) |
| `grant_date` | date | Yes | Date grant was awarded |
| `unit_type` | enum | Yes | RSU, OPTION, SAR, PHANTOM_STOCK |
| `total_units` | integer | Yes | Total units granted |
| `vested_units` | integer | No | Units vested to date (default: 0) |
| `exercised_units` | integer | No | Units exercised (for options/SAR) |
| `forfeited_units` | integer | No | Units forfeited (termination, etc.) |
| `unvested_units` | integer | No | Computed: total - vested - forfeited |
| `strike_price` | decimal(18,6) | No | Exercise price (NULL for RSU) |
| `fair_market_value` | decimal(18,6) | No | FMV at grant date |
| `expiry_date` | date | No | Expiration date (for options) |
| `vesting_schedule_json` | jsonb | Yes | Vesting schedule definition |
| `status` | enum | No | ACTIVE, FULLY_VESTED, FORFEITED, EXPIRED, EXERCISED |
| `termination_date` | date | No | Employee termination date |

**Vesting Schedule JSON Structure**:

```yaml
vesting_schedule_json:
  type: "TIME_BASED"  # or PERFORMANCE_BASED, HYBRID
  cliff_months: 12    # 1-year cliff
  vesting_period_months: 48  # 4-year total vesting
  vesting_frequency: "QUARTERLY"  # MONTHLY, QUARTERLY, ANNUAL
  schedule:
    - vest_date: "2026-01-01"
      units: 250
      cumulative: 250
    - vest_date: "2026-04-01"
      units: 250
      cumulative: 500
    - vest_date: "2026-07-01"
      units: 250
      cumulative: 750
    - vest_date: "2026-10-01"
      units: 250
      cumulative: 1000
```

**Business Rules**:
1. unvested_units = total_units - vested_units - forfeited_units
2. vested_units + exercised_units + forfeited_units <= total_units
3. RSU has NULL strike_price, Options have strike_price
4. Vesting may accelerate on termination (good leaver provisions)
5. Cliff vesting: no vesting until cliff date, then lump sum

**Examples**:

```yaml
Example 1: RSU Grant (4-year vesting, 1-year cliff)
  EquityGrant:
    employee_id: "EMP_001_UUID"
    plan_id: "LTI_2025_UUID"
    grant_number: "RSU-2025-001234"
    grant_date: "2025-01-01"
    unit_type: RSU
    total_units: 1000
    vested_units: 0
    strike_price: null  # RSU has no strike price
    fair_market_value: 100000  # VND per unit
    vesting_schedule_json:
      type: "TIME_BASED"
      cliff_months: 12
      vesting_period_months: 48
      vesting_frequency: "QUARTERLY"
    status: ACTIVE

Example 2: Stock Option Grant
  EquityGrant:
    grant_number: "OPT-2025-005678"
    unit_type: OPTION
    total_units: 5000
    strike_price: 80000  # VND per unit
    fair_market_value: 100000
    expiry_date: "2035-01-01"  # 10-year expiry
    vesting_schedule_json:
      type: "TIME_BASED"
      cliff_months: 12
      vesting_period_months: 48
      vesting_frequency: "MONTHLY"
```

**Best Practices**:
- ✅ DO: Use standard vesting schedules (4-year, 1-year cliff)
- ✅ DO: Set FMV at grant date for tax compliance
- ✅ DO: Handle termination scenarios (good leaver vs bad leaver)
- ❌ DON'T: Modify vesting schedule after grant (create new grant instead)
- ❌ DON'T: Forget to set expiry_date for options

---

### 6. EquityVestingEvent

**Definition**: Records each vesting event (scheduled, accelerated, or forfeit).

**Purpose**: Tracks when equity units vest, creating taxable events and exercise opportunities.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `grant_id` | UUID | Yes | FK to EquityGrant |
| `vest_date` | date | Yes | Date units vested |
| `vested_units` | integer | Yes | Number of units vested |
| `event_type` | enum | Yes | SCHEDULED, ACCELERATED, FORFEIT, CLIFF |
| `acceleration_reason` | string(100) | No | Reason for acceleration |
| `payroll_batch_id` | UUID | No | FK to Payroll.Batch (if taxable event) |

**Business Rules**:
1. SCHEDULED events created automatically from vesting_schedule_json
2. ACCELERATED events require acceleration_reason (TERMINATION, ACQUISITION, IPO)
3. FORFEIT events have negative vested_units
4. RSU vesting creates immediate taxable event
5. Option vesting creates exercise opportunity (not taxable until exercise)

**Examples**:

```yaml
Example 1: Scheduled Quarterly Vesting
  EquityVestingEvent:
    grant_id: "RSU_GRANT_UUID"
    vest_date: "2026-01-01"
    vested_units: 250
    event_type: SCHEDULED

Example 2: Accelerated Vesting (Acquisition)
  EquityVestingEvent:
    grant_id: "RSU_GRANT_UUID"
    vest_date: "2025-06-15"
    vested_units: 750  # Remaining unvested units
    event_type: ACCELERATED
    acceleration_reason: "ACQUISITION"
```

---

### 7. EquityTransaction

**Definition**: Records equity transactions (exercise, cancel, forfeit, vest, sell).

**Purpose**: Tracks cash value and gain/loss for tax purposes.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `grant_id` | UUID | Yes | FK to EquityGrant |
| `txn_date` | date | Yes | Transaction date |
| `txn_type` | enum | Yes | EXERCISE, CANCEL, FORFEIT, VEST, SELL |
| `units` | integer | Yes | Number of units |
| `price_per_unit` | decimal(18,6) | No | Price per unit at transaction |
| `cash_value` | decimal(18,4) | No | Total cash value |
| `gain_loss` | decimal(18,4) | No | Gain/loss for tax |
| `payroll_batch_id` | UUID | No | FK to Payroll.Batch (tax withholding) |

**Business Rules**:
1. EXERCISE: cash_value = units * strike_price, gain = units * (FMV - strike)
2. VEST (RSU): cash_value = units * FMV, taxable as ordinary income
3. FORFEIT: negative units, no cash value
4. SELL: cash_value = units * sale_price, capital gains tax

**Examples**:

```yaml
Example: Option Exercise
  EquityTransaction:
    grant_id: "OPT_GRANT_UUID"
    txn_date: "2027-01-15"
    txn_type: EXERCISE
    units: 1000
    price_per_unit: 80000  # Strike price
    cash_value: 80000000   # 1000 * 80,000
    gain_loss: 20000000    # 1000 * (100,000 FMV - 80,000 strike)
```

---

### 8. CommissionPlan

**Definition**: Commission plan structure for sales compensation with quota and tier definitions.

**Purpose**: Defines how sales commissions are calculated (flat rate, tiered, accelerator).

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Unique plan code |
| `name` | string(200) | Yes | Plan name |
| `plan_type` | enum | Yes | REVENUE_BASED, PROFIT_BASED, UNIT_BASED, HYBRID |
| `quota_type` | enum | Yes | INDIVIDUAL, TEAM, TERRITORY, PRODUCT |
| `payment_frequency` | enum | Yes | MONTHLY, QUARTERLY, ANNUAL |
| `calculation_method` | enum | Yes | FLAT_RATE, TIERED, ACCELERATOR, DECELERATOR |
| `formula_json` | jsonb | No | Commission calculation formula |
| `eligibility_rule` | jsonb | No | Eligibility criteria |

**Formula JSON Examples**:

```yaml
FLAT_RATE:
  base_rate: 0.05  # 5% of revenue
  cap: 500000      # Max commission per period

ACCELERATOR:
  base_rate: 0.05
  quota_threshold: 1000000
  accelerator:
    above_100_pct: 0.08
    above_120_pct: 0.10
  cap: 1000000
```

**Business Rules**:
1. TIERED plans have multiple CommissionTier records
2. ACCELERATOR increases rate above quota
3. DECELERATOR decreases rate below quota
4. Cap limits maximum commission payout

---

### 9. CommissionTier & CommissionTransaction

**CommissionTier**: Defines commission rate per achievement level.

**Attributes**:
- `tier_number`: Sequence (1, 2, 3...)
- `min_achievement_pct`: Minimum quota % (0, 80, 100, 120)
- `max_achievement_pct`: Maximum quota % (NULL = unlimited)
- `commission_rate`: Rate for this tier (e.g., 0.05 = 5%)

**Example Tiers**:

```yaml
Tier 1 (Base): 0-100% achievement → 5% rate
Tier 2 (Accelerator): 100-120% → 8% rate
Tier 3 (Super): 120%+ → 10% rate
```

**CommissionTransaction**: Individual commission record linking to sales data.

**Attributes**:
- `revenue_amount`: Sales/revenue amount
- `quota_amount`: Quota for period
- `achievement_pct`: (revenue / quota) * 100
- `commission_rate`: Rate applied
- `commission_amount`: Commission earned
- `status`: PENDING, APPROVED, PAID, DISPUTED, CANCELLED

**Business Rules**:
1. achievement_pct = (revenue_amount / quota_amount) * 100
2. Tier determined by achievement_pct
3. commission_amount = revenue_amount * commission_rate
4. Cannot modify APPROVED or PAID transactions

---

## Summary

The Variable Pay sub-module provides **9 entities** that work together to manage:

1. **Bonus Programs**: BonusPlan, BonusCycle, BonusPool, BonusAllocation
2. **Equity Compensation**: EquityGrant, EquityVestingEvent, EquityTransaction
3. **Sales Commissions**: CommissionPlan, CommissionTier, CommissionTransaction

**Key Design Patterns**:
- ✅ Flexible formula-based calculations
- ✅ Multi-level approval workflows
- ✅ Budget pool management
- ✅ Vesting schedule automation
- ✅ Tax event tracking
- ✅ Performance and company multipliers

**Integration Points**:
- **Payroll Module**: Tax withholding for bonuses, RSU vesting, option exercises
- **Performance Management**: Performance ratings drive bonus multipliers
- **Core Module**: Employee, Assignment, LegalEntity linkages

---

**Document Status**: ✅ Complete  
**Coverage**: 9 of 9 entities documented  
**Last Updated**: 2025-12-04  
**Next Steps**: Create glossary-benefits.md
