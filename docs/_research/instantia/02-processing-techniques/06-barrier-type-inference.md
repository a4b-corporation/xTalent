# Barrier Type Inference

## Problem Statement

FX option barriers control when the option is activated or deactivated:

**European**: Barrier checked only at expiry
**American**: Barrier checked continuously from trade date to expiry
**Window**: Barrier checked from a specific window_start date to expiry

```
Problem: Source data often lacks explicit barrier_type field
Solution: Infer barrier type from dates and barrier values
```

---

## Core Concept: Date-Based Inference

### Detection Logic

```
Step 1: Check if barriers exist
  IF no barrier_1 AND no barrier_2:
    → barrier_type = "European" (default for vanilla)

Step 2: Check window_start validity
  IF barrier exists AND window_start is valid date:
    → Proceed to Step 3
  ELSE:
    → barrier_type = "European"

Step 3: Compare dates
  IF trade_date >= window_start AND expiry_date != window_start:
    → barrier_type = "American"
  
  ELIF trade_date < window_start AND expiry_date != window_start:
    → barrier_type = "Window"
  
  ELSE:
    → barrier_type = "European"
```

### Valid Date Definition

```python
window_start is valid IF:
  - Not null
  - Not "0001-01-01" (default empty date)
  - >= "1990-01-01" (reasonable historical cutoff)
  - <= expiry_date (logically consistent)
```

---

## Barrier Detection

### Identifying Barrier Presence

**Method 1**: Explicit barrier fields
```python
has_barrier = (
    (barrier_1 is not null AND float(barrier_1) > 0) OR
    (barrier_2 is not null AND float(barrier_2) > 0)
)
```

**Method 2**: Product fingerprint
```python
# Some products ALWAYS have barriers
IF product_code in ['KOF', 'KORF', 'DKORF']:
    has_barrier = True
```

### Barrier Type Classification

**Knock-Out (KO)**: Deactivates if barrier hit
```python
# Usually in barrier_1 field
ko_barrier = barrier_1 if barrier_1 else None
```

**Knock-In (KI)**: Activates if barrier hit
```python
# Usually in barrier_2 field for double barrier products
ki_barrier = barrier_2 if barrier_2 else None
```

**Double Barrier**: Both KI and KO
```python
# Dynamic products like DKORF
IF barrier_1 AND barrier_2:
    barrier_structure = "Double"
```

---

## Date Relationship Analysis

### Scenario 1: American Barrier

```
trade_date:    2024-02-15
window_start:  2024-02-01  (before trade date)
expiry_date:   2024-06-15

Logic:
  trade_date >= window_start → TRUE
  expiry_date != window_start → TRUE
  
Result: barrier_type = "American"

Interpretation:
  Barrier active from Feb 15 (trade) to Jun 15 (expiry)
```

### Scenario 2: Window Barrier

```
trade_date:    2024-02-15
window_start:  2024-03-01  (after trade date)
expiry_date:   2024-06-15

Logic:
  trade_date < window_start → TRUE
  expiry_date != window_start → TRUE
  
Result: barrier_type = "Window"

Interpretation:
  Barrier active from Mar 1 (window) to Jun 15 (expiry)
  Not active during Feb 15 - Feb 29
```

### Scenario 3: European (No Window)

```
trade_date:    2024-02-15
window_start:  null (or invalid)
expiry_date:   2024-06-15

Logic:
  window_start invalid → Skip date comparison
  
Result: barrier_type = "European"

Interpretation:
  Barrier checked only at Jun 15 (expiry)
```

### Scenario 4: Degenerate Case

```
trade_date:    2024-02-15
window_start:  2024-06-15  (same as expiry)
expiry_date:   2024-06-15

Logic:
  expiry_date == window_start → TRUE
  
Result: barrier_type = "European"

Interpretation:
  Window starts at expiry → effectively European
```

---

## Edge Cases & Handling

### Case 1: Missing window_start

```
Data:
  barrier_1 = 1.12 (exists)
  window_start = null

Handling:
  Default to "European"
  
Rationale:
  Cannot determine American vs Window without window_start
  European is conservative assumption
```

### Case 2: Invalid window_start Dates

```
Invalid values:
  - "0001-01-01" (default empty)
  - "1900-01-01" (obviously wrong)
  - "2099-12-31" (future date beyond expiry)

Handling:
  Treat as missing → "European"
```

### Case 3: Future-Dated Trades

```
Data:
  trade_date = 2024-06-01
  window_start = 2024-05-15  (in the past)
  expiry_date = 2024-07-15

Logic:
  trade_date >= window_start → TRUE
  
Result: "American"

Note: window_start can be before trade_date
```

### Case 4: Zero or Negative Barriers

```
Data:
  barrier_1 = 0
  
Handling:
  Treat as no barrier
  barrier_type = "European"
```

---

## Product-Specific Rules

### Vanilla Options (VO)

```
Product: VO (single leg, no barriers)

Default: barrier_type = "European"

Override: Never has American/Window
```

### Knockout Products (KOF, KORF)

```
Product: KOF, KORF

Must have: barrier_1 (knockout level)

Inference:
  IF window_start valid:
    Apply date logic
  ELSE:
    Default "European" (rare for KO products)
```

### Dynamic Products (DKORF)

```
Product: DKORF (double barrier)

Has: barrier_1 (KO) AND barrier_2 (KI)

Inference:
  Both barriers use SAME barrier_type
  Apply date logic to determine type
```

---

## Validation Checks

### Post-Inference Validation

**Check 1**: Barrier presence consistency
```python
IF barrier_type in ['American', 'Window']:
    assert has_barrier == True
    # Can't be American/Window without a barrier
```

**Check 2**: Date ordering
```python
assert trade_date <= expiry_date
assert window_start <= expiry_date
```

**Check 3**: Product coherence
```python
IF product_code == 'VO':  # Vanilla
    assert barrier_type == 'European'
    # Vanilla never has barriers
```

### Quality Metrics

```
Inference Confidence:
- High: window_start valid, dates logical
- Medium: window_start missing, defaulted to European
- Low: window_start suspicious (e.g., far future)
```

---

## Implementation Patterns

### Decision Tree Approach

```python
def infer_barrier_type(leg_data):
    # Extract relevant fields
    barrier_1 = leg_data.get('barrier_1')
    barrier_2 = leg_data.get('barrier_2')
    window_start = leg_data.get('window_start')
    trade_date = leg_data.get('trade_date')
    expiry_date = leg_data.get('expiry_date')
    
    # Step 1: Check barrier existence
    has_barrier = (
        (barrier_1 and float(barrier_1) > 0) or
        (barrier_2 and float(barrier_2) > 0)
    )
    
    if not has_barrier:
        return "European"
    
    # Step 2: Check window_start validity
    if not is_valid_date(window_start):
        return "European"
    
    # Step 3: Date comparison
    if trade_date >= window_start and expiry_date != window_start:
        return "American"
    elif trade_date < window_start and expiry_date != window_start:
        return "Window"
    else:
        return "European"
```

### Rule-Based Approach

```yaml
barrier_type_rules:
  # Rule 1: No barriers
  - condition: "barrier_1 is null AND barrier_2 is null"
    result: "European"
  
  # Rule 2: Invalid window
  - condition: "window_start < '1990-01-01'"
    result: "European"
  
  # Rule 3: American
  - condition: "trade_date >= window_start AND expiry_date != window_start"
    result: "American"
  
  # Rule 4: Window
  - condition: "trade_date < window_start AND expiry_date != window_start"
    result: "Window"
  
  # Default
  - condition: "true"
    result: "European"
```

---

## Aggregation Integration

### Strategy-Level Determination

```python
# For multi-leg strategies, use first leg's barrier type
# (all legs in same strategy should have same barrier type)

strategy_barrier_type = legs[0].barrier_type

# Validate consistency
for leg in legs[1:]:
    if leg.barrier_type != strategy_barrier_type:
        Flag: inconsistent_barrier_types
```

### Output Field Population

```yaml
output_fields:
  - name: barrier_type
    source: calculated
    aggregation: first
    validation:
      - "value in ['European', 'American', 'Window']"
```

---

## Testing Strategy

### Test Cases

**Test 1**: European (no barrier)
```python
assert infer({}) == "European"
assert infer({"barrier_1": None}) == "European"
assert infer({"barrier_1": 0}) == "European"
```

**Test 2**: European (barrier but no window)
```python
data = {
    "barrier_1": 1.12,
    "window_start": None
}
assert infer(data) == "European"
```

**Test 3**: American
```python
data = {
    "barrier_1": 1.12,
    "window_start": "2024-02-01",
    "trade_date": "2024-02-15",
    "expiry_date": "2024-06-15"
}
assert infer(data) == "American"
```

**Test 4**: Window
```python
data = {
    "barrier_1": 1.12,
    "window_start": "2024-03-01",  # After trade
    "trade_date": "2024-02-15",
    "expiry_date": "2024-06-15"
}
assert infer(data) == "Window"
```

**Test 5**: Edge - window same as expiry
```python
data = {
    "barrier_1": 1.12,
    "window_start": "2024-06-15",
    "trade_date": "2024-02-15",
    "expiry_date": "2024-06-15"
}
assert infer(data) == "European"
```

---

## Performance Considerations

### Vectorized Inference

```python
# Instead of row-by-row
for row in df.iterrows():
    barrier_type = infer(row)

# Use vectorized pandas
df['has_barrier'] = (df['barrier_1'] > 0) | (df['barrier_2'] > 0)
df['valid_window'] = df['window_start'] >= '1990-01-01'
df['is_american'] = (
    df['has_barrier'] & 
    df['valid_window'] & 
    (df['trade_date'] >= df['window_start']) &
    (df['expiry_date'] != df['window_start'])
)
df['barrier_type'] = np.where(
    ~df['has_barrier'], 'European',
    np.where(df['is_american'], 'American', 'Window')
)
```

---

## Summary

**Technique**: Date-relationship analysis for barrier classification  
**Key Fields**: barrier_1/barrier_2, window_start, trade_date, expiry_date  
**Logic**: Compare window_start vs trade_date to determine activation window  
**Fallback**: Default to "European" if dates invalid or barriers absent  

**Best For**: Inferring barrier behavior from date metadata  
**Trade-off**: Assumes window_start field exists and is reliable  
**When to Use**: Source data has dates but not explicit barrier_type field
