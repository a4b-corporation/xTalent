# RMI Perspective Detection

## Problem Statement

FX option strategies can be viewed from two perspectives:

**LHS (Left Hand Side / Importer)**:
- Protecting against currency **appreciation**
- Selling foreign currency to buy local
- Example: US importer paying in EUR

**RHS (Right Hand Side / Exporter)**:
- Protecting against currency **depreciation**  
- Buying foreign currency with local
- Example: US exporter receiving EUR

**Critical Issue**: The aggregation logic differs completely based on perspective!

```
Wrong perspective → Wrong notional → Wrong risk calculation
```

---

## Why Perspective Matters

### Same Legs, Different Aggregation

**Strategy**: Sell Put @ 1.08 ($100K) + Buy Call @ 1.10 ($100K)

**If LHS (Importer)**:
```
original_notional = sum(Sell-Put amounts) = $100,000 ✅
strike_rate = Sell-Put rate = 1.08 ✅
upper_barrier = Buy-Call rate = 1.10 ✅
```

**If RHS (Exporter)** - WRONG!:
``

`
original_notional = sum(Sell-Call amounts) = $0 ❌ (no Sell-Call!)
strike_rate = undefined ❌
```

**Conclusion**: Must detect perspective BEFORE aggregating

---

## Core Concept: Leg-Based Inference

### Detection Rule

```
IF strategy contains Sell-Put leg:
    → perspective = LHS (Importer)
    → Notional from: Sell-Put legs
    → Leverage from: Buy-Call legs

ELIF strategy contains Sell-Call leg:
    → perspective = RHS (Exporter)
    → Notional from: Sell-Call legs
    → Leverage from: Buy-Put legs

ELSE:
    → perspective = LHS (default / conservative fallback)
```

### Rationale

**LHS (Importer) Economic Logic**:
```
Importer needs EUR to pay supplier

Sell Put @ 1.08:
  - Obliges to BUY EUR at 1.08 if spot drops below
  - Sets FLOOR protection (minimum rate)

Buy Call @ 1.10:
  - Right to BUY EUR at 1.10 if spot rises above
  - Sets CEILING protection (maximum rate)

→ Sell-Put is the PRIMARY obligation → Defines notional
```

**RHS (Exporter) Economic Logic**:
```
Exporter receives EUR, needs to sell for USD

Sell Call @ 1.10:
  - Obliges to SELL EUR at 1.10 if spot rises above
  - Sets FLOOR protection (minimum rate)

Buy Put @ 1.08:
  - Right to SELL EUR at 1.08 if spot drops below
  - Sets CEILING protection (maximum rate)

→ Sell-Call is the PRIMARY obligation → Defines notional
```

---

## Detection Algorithm

### Step 1: Analyze Leg Positions

```python
For each leg in strategy:
    Extract:
      - buy_sell: "Buy" or "Sell"
      - call_put: "Call" or "Put"

Positions found:
  sell_put_present = any(buy_sell == "Sell" AND call_put == "Put")
  sell_call_present = any(buy_sell == "Sell" AND call_put == "Call")
```

### Step 2: Apply Decision Tree

```
IF sell_put_present:
    rmi_type = "LHS"

ELIF sell_call_present:
    rmi_type = "RHS"

ELSE:
    # Edge case: Only bought options (no sold)
    rmi_type = "LHS"  # Conservative default
```

### Step 3: Validate Against Known Patterns

```python
# Cross-check with fingerprint match
IF rmi_type == "LHS":
    expected_positions = ["Sell-Put", "Buy-Call", ...]
ELSE:
    expected_positions = ["Sell-Call", "Buy-Put", ...]

IF strategy positions NOT consistent with rmi_type:
    Flag: rmi_detection_uncertain
```

---

## Product-Specific RMI Patterns

### Collar

**LHS Collar**:
```yaml
positions:
  - Sell Put   # Primary
  - Buy Call   # Cap

rmi_type: LHS
notional_source: Sell-Put
```

**RHS Collar**:
```yaml
positions:
  - Sell Call  # Primary
  - Buy Put    # Floor

rmi_type: RHS
notional_source: Sell-Call
```

### Ratio Forward (RF)

**LHS RF**:
```yaml
positions:
  - Sell Put × 1    # Notional
  - Buy Call × 2    # Leverage (ratio)

rmi_type: LHS
ratio: 1:2
```

**RHS RF**:
```yaml
positions:
  - Sell Call × 1   # Notional
  - Buy Put × 2     # Leverage

rmi_type: RHS
ratio: 1:2
```

### Seagull

**LHS Seagull** (also called "Call Seagull"):
```yaml
positions:
  - Sell Put @ lower     # Notional
  - Buy Call @ mid       # Protection
  - Sell Call @ higher   # Financing

rmi_type: LHS
```

**RHS Seagull** (also called "Put Seagull"):
```yaml
positions:
  - Sell Call @ higher   # Notional
  - Buy Put @ mid        # Protection
  - Sell Put @ lower     # Financing

rmi_type: RHS
```

---

## Validation Strategies

### Method 1: Explicit Field Check

```python
# Some vendors provide RMI type explicitly
IF 'fp_rmi_type' in data:
    explicit_rmi = data['fp_rmi_type']
    
    # Validate against inferred RMI
    IF explicit_rmi != inferred_rmi:
        Flag: rmi_mismatch_warning
```

### Method 2: Amount Coherence Check

```python
# Verify aggregation makes sense
IF rmi_type == "LHS":
    notional = sum(Sell-Put amounts)
    leverage = sum(Buy-Call amounts)
ELSE:
    notional = sum(Sell-Call amounts)
    leverage = sum(Buy-Put amounts)

IF notional == 0:
    Flag: rmi_detection_failed
    Retry with opposite RMI type
```

### Method 3: Fingerprint Cross-Check

```python
# After fingerprint matching
matched_product = fingerprint_match(strategy)

IF matched_product has expected_rmi:
    IF inferred_rmi != expected_rmi:
        Flag: rmi_conflict
        Use: matched_product.expected_rmi
```

---

## Edge Cases & Handling

### Case 1: Both Sell-Put AND Sell-Call Present

```
Example: Seagull structure
  - Sell Put @ 1.06
  - Buy Call @ 1.10
  - Sell Call @ 1.12

Both indicators present!
```

**Resolution**:
```python
# Primary sold leg (larger notional) determines RMI
sell_put_amount = sum(Sell-Put amounts)
sell_call_amount = sum(Sell-Call amounts)

IF sell_put_amount > sell_call_amount:
    rmi_type = "LHS"
ELSE:
    rmi_type = "RHS"
```

### Case 2: No Sold Legs (All Bought)

```
Example: Long Straddle
  - Buy Put @ 1.08
  - Buy Call @ 1.08

No sold obligations → ambiguous
```

**Handling**:
```python
# Default to LHS (conservative)
rmi_type = "LHS"

# Or infer from client type
IF client_type == "Exporter":
    rmi_type = "RHS"
```

### Case 3: Single Leg

```
Example: Vanilla option
  - Sell Put @ 1.08 (single leg)

Clear RMI → LHS
```

**Detection**:
```python
IF leg_count == 1:
    IF buy_sell == "Sell" AND call_put == "Put":
        rmi_type = "LHS"
    ELIF buy_sell == "Sell" AND call_put == "Call":
        rmi_type = "RHS"
```

---

## RMI-Aware Aggregation Rules

### Notional Amount

```yaml
LHS aggregation:
  source_legs: filter(buy_sell == "Sell" AND call_put == "Put")
  aggregation: sum(counter_amt)

RHS aggregation:
  source_legs: filter(buy_sell == "Sell" AND call_put == "Call")
  aggregation: sum(counter_amt)
```

### Strike Rate

```yaml
LHS:
  source_legs: filter(buy_sell == "Sell" AND call_put == "Put")
  aggregation: first(rate)  # Primary obligation strike

RHS:
  source_legs: filter(buy_sell == "Sell" AND call_put == "Call")
  aggregation: first(rate)
```

### Leverage Amount

```yaml
LHS:
  source_legs: filter(buy_sell == "Buy" AND call_put == "Call")
  aggregation: sum(counter_amt)

RHS:
  source_legs: filter(buy_sell == "Buy" AND call_put == "Put")
  aggregation: sum(counter_amt)
```

### Barriers

```yaml
LHS:
  upper_barrier:
    source_legs: filter(buy_sell == "Buy" AND call_put == "Call")
    aggregation: max(rate)
  
  lower_barrier:
    source: barrier_1 field

RHS:
  lower_barrier:
    source_legs: filter(buy_sell == "Buy" AND call_put == "Put")
    aggregation: min(rate)
  
  upper_barrier:
    source: barrier_1 field
```

---

## Performance Considerations

### Lazy Detection

```python
# Don't detect RMI until needed
class Strategy:
    _rmi_type = None  # Cached
    
    def get_rmi_type(self):
        if self._rmi_type is None:
            self._rmi_type = self._detect_rmi()
        return self._rmi_type
```

### Batch Detection

```python
# Vectorized RMI detection for DataFrame
df['has_sell_put'] = (
    (df['buy_sell'] == 'Sell') & 
    (df['call_put'] == 'Put')
).groupby(df['strategy_id']).transform('any')

df['has_sell_call'] = (
    (df['buy_sell'] == 'Sell') & 
    (df['call_put'] == 'Call')
).groupby(df['strategy_id']).transform('any')

df['rmi_type'] = np.where(
    df['has_sell_put'], 'LHS',
    np.where(df['has_sell_call'], 'RHS', 'LHS')
)
```

---

## Testing & Validation

### Test Coverage

**LHS Products**:
```python
test_cases = [
    {
        "product": "Collar",
        "legs": [
            {"buy_sell": "Sell", "call_put": "Put"},
            {"buy_sell": "Buy", "call_put": "Call"}
        ],
        "expected_rmi": "LHS"
    },
    {
        "product": "Ratio Forward",
        "legs": [
            {"buy_sell": "Sell", "call_put": "Put"},
            {"buy_sell": "Buy", "call_put": "Call"},
            {"buy_sell": "Buy", "call_put": "Call"}
        ],
        "expected_rmi": "LHS"
    },
]
```

**RHS Products**:
```python
test_cases = [
    {
        "product": "RHS Collar",
        "legs": [
            {"buy_sell": "Sell", "call_put": "Call"},
            {"buy_sell": "Buy", "call_put": "Put"}
        ],
        "expected_rmi": "RHS"
    },
]
```

### Validation Metrics

```
RMI Detection Accuracy = Correct Detections / Total Strategies

Target: > 99% (critical for correct aggregation)
```

---

## Summary

**Technique**: Leg position analysis for perspective detection  
**Key Signal**: Presence of Sell-Put (LHS) or Sell-Call (RHS)  
**Criticality**: HIGH (wrong RMI → wrong calculations)  
**Fallback**: Default to LHS if ambiguous  
**Validation**: Cross-check with fingerprint and amount coherence  

**Best For**: Automatic perspective inference from trade structure  
**Trade-off**: Edge cases (Seagulls) require additional logic  
**When to Use**: Source data doesn't explicitly state Importer/Exporter role
