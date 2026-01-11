# Case Study: Multi-Leg Ratio Forward Consolidation

## Overview

This case study demonstrates how a **4-leg Ratio Forward** strategy is correctly identified, classified, and aggregated from individual trade legs.

---

## Business Context

**Company**: US Importer (LHS perspective)  
**Exposure**: Weekly EUR payments to suppliers  
**Hedge**: Ratio Forward Extra (leveraged protection)

**Strategy Structure**:
- **Sell 1× Put** @ lower strike (primary obligation, 60% notional)
- **Sell 1× Put** @ even lower strike (additional premium funding, 40% notional)
- **Buy 2× Call** @ mid strike (leveraged upside participation)

**Economic profile**:
- Floor protection at lower strikes
- 2:1 participation above mid strike
- Zero/low premium cost (extra sold put finances leverage)

---

## Input Data (4 Legs)

```csv
trade_id,trade_date,expiry_date,currency_pair,buy_sell,call_put,counter_amt,rate,premium_amt,barrier_1
T001,2024-02-15,2024-08-15,EUR/USD,Sell,Put,60000,1.08,1200,
T002,2024-02-15,2024-08-15,EUR/USD,Sell,Put,40000,1.06,800,
T003,2024-02-15,2024-08-15,EUR/USD,Buy,Call,100000,1.12,-1500,
T004,2024-02-15,2024-08-15,EUR/USD,Buy,Call,100000,1.12,-500,
```

**Total**: 4 individual rows → Need to consolidate to 1 strategy

---

## Pipeline Processing

### Stage 1: Extract
```
Input: trades_rf.csv
✅ Loaded 4 rows, 10 columns
```

### Stage 2: Standardize
```
Mapping results:
  Counter Amt → counter_amt (0.95)
  Rate → rate (0.91)
  Expiry Date → expiry_date (0.96)
  Buy/Sell → buy_sell (1.00)
  Call/Put → call_put (1.00)
  Premium Amt → premium_amt (0.89)
  
✅ 10/10 columns mapped (100%)
```

### Stage 3: Group
```
Grouping keys: [trade_date, expiry_date, currency_pair]

Composite key: "2024-02-15|2024-08-15|EURUSD"

All 4 legs have same key:
  T001: "2024-02-15|2024-08-15|EURUSD"
  T002: "2024-02-15|2024-08-15|EURUSD"
  T003: "2024-02-15|2024-08-15|EURUSD"
  T004: "2024-02-15|2024-08-15|EURUSD"

Result:
  strategy_id = STR001 (all 4 legs)

✅ 4 legs → 1 strategy (100% grouping rate)
```

### Stage 4: Match

**Pattern Analysis**:
```
Leg count: 4
Positions:
  - Sell-Put (T001)
  - Sell-Put (T002)  ← Two Sell-Puts!
  - Buy-Call (T003)
  - Buy-Call (T004)   ← Two Buy-Calls!

Amounts:
  Sell-Put total: 60K + 40K = 100K
  Buy-Call total: 100K + 100K = 200K
  Ratio: 200K / 100K = 2:1 ✓

RMI detection:
  Has Sell-Put → LHS
```

**Fingerprint Matching**:
```yaml
# Against: Ratio Forward (RF)
- leg_count: 2-4 ✓ (4 is in range)
- positions: Sell-Put + Buy-Call ✓
- has_ratio: true ✓
- amount_relationship: "Call > Put" ✓ (200K > 100K)

Match score: 95/100 ✅
```

**Classification Result**:
```
fp_product_code = RF
option_strategy = Ratio Forward
fp_rmi_type = LHS
```

✅ 1/1 classified (100%)

### Stage 5: Calculate

**Step 1: Detect RMI Type**
```python
rmi_type = "LHS"  # From Match stage
```

**Step 2: Aggregate Notional (RMI-aware)**
```python
# Use lhs_notional filter (Sell-Put legs)
notional_legs = [T001, T002]

original_notional_amount = sum([60K, 40K]) = 100,000
```

**Step 3: Aggregate Leverage (RMI-aware)**
```python
# Use lhs_leverage filter (Buy-Call legs)
leverage_legs = [T003, T004]

original_leverage_amount = sum([100K, 100K]) = 200,000
```

**Step 4: Extract Strike Rate**
```python
# From first Sell-Put leg
strike_rate = notional_legs[0].rate = 1.08
```

**Step 5: Extract Upper Barrier**
```python
# Max of Buy-Call rates
upper_barrier_rate = max([1.12, 1.12]) = 1.12
```

**Step 6: Calculate Ratio**
```python
ratio = leverage / notional
     = 200,000 / 100,000
     = 2.0

formatted = "1:2.0"
```

**Step 7: Other Fields**
```python
expiry_date = first(expiry_date_values) = "2024-08-15"
currency_pair = "EURUSD"
leg_sequence = count(legs) = 4
premium_amt = sum([1200, 800, -1500, -500]) = 0  # Zero cost!
```

**Step 8: Barrier Type Inference**
```python
has_barrier = (barrier_1 is not null and barrier_1 > 0)
            = False  # All barrier_1 are empty

barrier_type = "European"
```

---

## Final Output (1 Row)

```
strategy_id                     | STR001
fp_product_code                 | RF
option_strategy                 | Ratio Forward
fp_rmi_type                     | LHS
original_notional_amount        | 100,000.00
original_leverage_amount        | 200,000.00
strike_rate                     | 1.08
upper_barrier_rate              | 1.12
lower_barrier_rate              | null
ratio                           | 1:2.0
expiry_date                     | 2024-08-15
currency_pair                   | EURUSD
premium_amt                     | 0.00
leg_sequence                    | 4
barrier_type                    | European
current_residual_amount         | 100,000.00
current_leverage_amount         | 200,000.00
```

---

## Key Calculations Explained

### 1. Notional Consolidation
```
Input:
  T001: Sell Put $60K @ 1.08
  T002: Sell Put $40K @ 1.06

Output:
  original_notional = $60K + $40K = $100K

Financial Meaning:
  Company is obligated to buy $100K EUR
  Split across two strike levels (1.08 and 1.06)
```

### 2. Leverage Calculation
```
Input:
  T003: Buy Call $100K @ 1.12
  T004: Buy Call $100K @ 1.12

Output:
  original_leverage = $100K + $100K = $200K

Financial Meaning:
  Company can participate in $200K upside
  2× the notional → Ratio structure
```

### 3. Ratio Derivation
```
Formula:
  ratio = original_leverage / original_notional
        = $200K / $100K
        = 2.0

Formatted: "1:2.0"

Interpretation:
  For every $1 of notional protected,
  company gets $2 of upside participation
```

### 4. Strike Selection
```
Multiple strikes available:
  Sell-Put @ 1.08
  Sell-Put @ 1.06
  Buy-Call @ 1.12

Selected strike: 1.08 (first Sell-Put)

Why: Primary obligation strike is the floor protection
```

---

## Validation

### Check 1: Leg Count Distribution
```
Expected for Ratio Forwards: 2-4 legs
Actual: 4 legs ✓

Typical:
  2 legs: Simple 1:2 ratio (1 Sell-Put, 2 Buy-Call)
  3 legs: With extra financing leg
  4 legs: Dual sell-puts + dual buy-calls (this case)
```

### Check 2: Amount Coherence
```
Sell-Put amounts: [60K, 40K]
Buy-Call amounts: [100K, 100K]

Total Sell: 100K
Total Buy: 200K

Ratio: 2:1 ✓ (valid ratio product)
```

### Check 3: Premium Net Cost
```
Premiums:
  T001 (Sell Put): +1,200 (received)
  T002 (Sell Put): +800 (received)
  T003 (Buy Call): -1,500 (paid)
  T004 (Buy Call): -500 (paid)

Net: 1,200 + 800 - 1,500 - 500 = 0

Zero cost structure ✓ (common for ratio forwards)
```

### Check 4: RMI Consistency
```
Product: RF
RMI: LHS
Positions: Sell-Put + Buy-Call

Expected for LHS: ✓
  - Sell-Put (floor protection)
  - Buy-Call (upside participation)

If this were RHS:
  - Would have Sell-Call + Buy-Put
  - Different aggregation filters needed
```

---

## Business Impact

### Risk Exposure Summary
```
Downside Protection:
  Floor @ 1.08 (primary)
  Secondary floor @ 1.06

Upside Participation:
  Cap @ 1.12
  Ratio: 2:1 (leveraged)

Net Premium: $0 (zero cost)
```

### P&L Scenarios

**Scenario A**: Spot @ expiry = 1.05 (below floor)
```
Sell-Put @ 1.08 exercised:
  Loss on T001: (1.08 - 1.05) × $60K = $1,800

Sell-Put @ 1.06 exercised:
  Loss on T002: (1.06 - 1.05) × $40K = $400

Total exposure: $2,200 (limited downside)
```

**Scenario B**: Spot @ expiry = 1.15 (above cap)
```
Buy-Call @ 1.12 exercised:
  Gain on T003: (1.15 - 1.12) × $100K = $3,000
  Gain on T004: (1.15 - 1.12) × $100K = $3,000

Total gain: $6,000 (leveraged upside!)
```

**Scenario C**: Spot @ expiry = 1.10 (between strikes)
```
No options exercised
Company buys at spot: 1.10
Outcome: Neutral (within protection range)
```

---

## Why Multi-Leg Consolidation Matters

### Before Consolidation (4 Rows)
```
Problem:
  - Cannot see total exposure ($100K notional)
  - Cannot calculate ratio (2:1)
  - Barriers scattered across rows
  - P&L requires manual calculation

Risk Report: Incomplete/Incorrect
```

### After Consolidation (1 Row)
```
Solution:
  - Clear total exposure: $100K
  - Explicit ratio: 1:2.0
  - Single upper barrier: 1.12
  - All data for P&L in one place

Risk Report: Accurate & Complete ✓
```

---

## Conclusion

This case study demonstrates the pipeline's ability to:
1. **Group** complex multi-leg structures (4 legs with repeated positions)
2. **Classify** advanced products (Ratio Forward with dual strikes)
3. **Aggregate** correctly using RMI-aware filters (LHS logic)
4. **Calculate** derived metrics (ratio, barriers, net premium)

**Result**: 4 fragmented rows → 1 comprehensive strategy record, ready for risk analysis
