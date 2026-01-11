# Configuration Guide: Standard Fields

## Overview

The `standard_fields.yaml` file defines the canonical field names used throughout the pipeline. Raw data columns from various vendors are mapped to these standard names during the **Standardize** stage.

**Location**: `configs/standard_fields.yaml`

---

## File Structure

```yaml
standard_fields:
  - name: <field_name>
    description: <human_readable_description>
    aliases:
      - <synonym_1>
      - <synonym_2>
      - ...
```

### Field Properties

| Property | Type | Required | Purpose |
|----------|------|----------|---------|
| `name` | String | ✅ Yes | Canonical field name (lowercase_with_underscores) |
| `description` | String | ✅ Yes | What this field represents |
| `aliases` | List[String] | ⚠️ Optional | Alternative names vendors use for this field |

---

## Field Categories

### 1. Identifiers
```yaml
- name: trade_id
  description: Unique identifier for the trade
  aliases:
    - "Ref #"
    - Reference
    - Deal ID
    - Transaction ID

- name: strategy_id
  description: Generated ID grouping related trades
  aliases:
    - Strategy
    - Group ID
```

### 2. Trade Attributes
```yaml
- name: counter_amt
  description: Notional amount in contract currency
  aliases:
    - Counter Amount
    - Notional
    - Amount
    - Trade Amount
    - Contract Amount

- name: rate
  description: Strike rate or forward rate
  aliases:
    - Strike
    - Strike Rate
    - Strike Price
    - Forward Rate
    - Exchange Rate
```

### 3. Dates
```yaml
- name: trade_date
  description: Date trade was executed
  aliases:
    - Trade Date
    - Execution Date
    - Deal Date

- name: expiry_date
  description: Option expiration date
  aliases:
    - Maturity
    - Maturity Date
    - Expiry
    - Expiration Date
    - Value Date
```

### 4. Option Characteristics
```yaml
- name: buy_sell
  description: Buy or Sell indicator
  aliases:
    - Direction
    - Position
    - Side
    - Transaction Type

- name: call_put
  description: Call or Put option type
  aliases:
    - Option Type
    - Type
    - Call/Put
    - CP
```

### 5. Barriers & Features
```yaml
- name: barrier_1
  description: Primary barrier level (usually knockout)
  aliases:
    - Barrier
    - KO Barrier
    - Barrier Level
    - Trigger Level

- name: window_start
  description: Date when barrier monitoring starts
  aliases:
    - Window Start
    - Observation Start
    - Barrier Start Date
```

---

## Adding a New Standard Field

### Step 1: Identify Need
```
Scenario: Vendor provides "Settlement Amount" field
Current mappings: No good match in standard_fields
Action: Add new standard field
```

### Step 2: Define Field
```yaml
- name: settlement_amount
  description: Final settlement amount after exercise
  aliases:
    - Settlement Amount
    - Settlement Amt
    - Final Amount
    - Exercise Amount
```

### Step 3: Consider Placement
```yaml
# Group with related fields
# Amounts section:
  - name: counter_amt
  - name: contract_amt
  - name: settlement_amount  # ← Add here
  - name: premium_amt
```

### Step 4: Test Mapping
```
1. Upload file with "Settlement Amount" column
2. Check Standardize stage
3. Verify auto-mapping to settlement_amount
4. Adjust aliases if needed
```

---

## Alias Best Practices

### ✅ Good Aliases
```yaml
aliases:
  - Counter Amount    # Exact vendor term
  - Notional          # Common synonym
  - Amount            # Short form
  - Trade Amount      # Qualified version
```

### ❌ Poor Aliases
```yaml
aliases:
  - amt              # Too vague (could be premium_amt, etc.)
  - value            # Too generic
  - field1           # Not semantic
```

### Alias Guidelines

1. **Include variations**:
   ```yaml
   - Strike Rate      # Full form
   - Strike           # Short form
   - Strike Price     # Alternative phrasing
   ```

2. **Include abbreviations**:
   ```yaml
   - Counter Amount
   - Counter Amt      # Common abbreviation
   - Ctr Amount       # Shorter abbreviation
   ```

3. **Include vendor-specific terms**:
   ```yaml
   - Maturity         # Standard
   - Expiry Date      # Vendor A
   - Value Date       # Vendor B
   ```

4. **Don't duplicate** across fields:
   ```yaml
   # BAD: "Amount" alias in multiple fields
   counter_amt:
     aliases: [Amount]  # Confusing!
   
   premium_amt:
     aliases: [Amount]  # Which one to map?
   
   # GOOD: Qualified aliases
   counter_amt:
     aliases: [Notional Amount, Contract Amount]
   
   premium_amt:
     aliases: [Premium Amount, Option Premium]
   ```

---

## Common Standard Fields Reference

### Essential Fields (Required for pipeline)
```yaml
counter_amt        # Notional amount
rate               # Strike rate
expiry_date        # Option expiry
buy_sell           # Buy/Sell direction
call_put           # Call/Put type
currency_pair      # e.g., EUR/USD
trade_date         # Execution date
```

### Optional Fields (Enhance output)
```yaml
premium_amt        # Option premium paid
barrier_1          # Knockout barrier
barrier_2          # Knock-in barrier (DKO products)
window_start       # Barrier observation start
window_end         # Barrier observation end
cutoff             # Cutoff time
spot               # Spot rate at trade
delivery_date      # Settlement date
```

---

## Validation Rules

### Naming Convention
```
✅ GOOD:
  - counter_amt       (lowercase, underscore)
  - trade_date        (descriptive, clear)
  - barrier_1         (numbered suffix)

❌ BAD:
  - CounterAmt        (CamelCase)
  - trade-date        (hyphens)
  - b1                (too cryptic)
```

### Description Requirements
```
✅ GOOD:
  "Notional amount in contract currency"
  - Clear
  - Specific
  - Explains units

❌ BAD:
  "Amount"
  - Too vague
  - Unclear which amount
```

---

## Testing Your Changes

### Test 1: Semantic Mapping
```python
# Upload file with new vendor term
Source column: "Net Amount"

Expected: Maps to settlement_amount (if aliases include it)
Verify: Similarity score > 0.5
```

### Test 2: No Conflicts
```python
# Ensure unique mapping
Source column: "Amount"

Problem: Maps to multiple fields (counter_amt, premium_amt)
Solution: Remove generic "Amount" alias, use qualified versions
```

### Test 3: Coverage
```python
# Check all vendor columns mapped
Total columns: 10
Mapped: 9
Unmapped: 1 ("XYZ_Field")

Action: Add XYZ_Field as new standard field or alias
```

---

## Example: Full Field Definition

```yaml
- name: counter_amt
  description: >
    Notional amount in the contract currency. 
    This is the face value of the option, not the premium.
    For multi-leg strategies, individual leg amounts are summed 
    during aggregation to get total original_notional_amount.
  
  aliases:
    # Full forms
    - Counter Amount
    - Notional Amount
    - Contract Notional
    
    # Short forms
    - Counter Amt
    - Notional
    - Amount
    
    # Vendor-specific
    - Trade Amount        # Vendor A
    - Original Amount     # Vendor B
    - Face Value          # Vendor C
```

---

## Integration with Pipeline

### Stage 2 (Standardize) Usage
```
1. Load standard_fields.yaml
2. Encode each field name + aliases as embeddings
3. Compare source columns to standard embeddings
4. Map highest similarity (if > threshold)
```

### Stage 5 (Calculate) Usage
```
Aggregation rules reference standard field names:

rule:
  source_field: counter_amt  # Must match standard_fields
  aggregation: sum
```

---

## Summary

**Purpose**: Define canonical field names for the pipeline  
**Format**: YAML with name, description, aliases  
**Usage**: Semantic mapping in Standardize stage  
**Best Practice**: Add aliases for all known vendor variations  
**Validation**: Test with real vendor files  

**Key Benefit**: Adding aliases doesn't require code changes—just update YAML and reload!
