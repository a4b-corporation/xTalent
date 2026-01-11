# Stage 2: Standardize - Field Mapping & Normalization

## Purpose
Transform vendor-specific column names into standardized field names using AI-powered semantic mapping.

---

## Input

### From Stage 1 (Extract)
```python
df.columns = [
    'Counter Amt',      # Vendor-specific
    'Strike Price',     # Vendor-specific
    'Maturity',         # Vendor-specific
    'Buy/Sell',
    'Call/Put',
    'Terms'
]
```

**Problem**: Different vendors use different names for the same concept

---

## Process Flow

### Step 1: Load Standard Field Definitions

```yaml
# From: configs/standard_fields.yaml
standard_fields:
  - name: counter_amt
    description: "Notional amount in contract currency"
    aliases: [amount, notional, trade_amount]
  
  - name: rate
    description: "Strike or forward rate"
    aliases: [strike, strike_rate, strike_price]
  
  - name: expiry_date
    description: "Option expiry date"
    aliases: [maturity, expiry, maturity_date, value_date]
```

### Step 2: Encode Embeddings

```
Standard fields → Embeddings:
  "counter_amt" → [0.21, 0.45, 0.12, ..., 0.67]
  "rate" → [0.05, 0.78, 0.31, ..., 0.22]
  "expiry_date" → [0.11, 0.09, 0.87, ..., 0.34]

Source columns → Embeddings:
  "Counter Amt" → [0.19, 0.47, 0.11, ..., 0.69]
  "Strike Price" → [0.07, 0.76, 0.33, ..., 0.21]
  "Maturity" → [0.12, 0.08, 0.85, ..., 0.36]
```

### Step 3: Calculate Similarity Matrix

```
                counter_amt  rate  expiry_date
Counter Amt     0.92        0.15  0.22
Strike Price    0.18        0.91  0.11
Maturity        0.21        0.12  0.94
```

### Step 4: Auto-Map (Greedy Matching)

```
For each source column:
  best_match = max(similarities)
  
  IF best_match > threshold (0.5):
    mapping[source] = standard_field
```

**Result**:
```python
auto_mappings = {
    'Counter Amt': 'counter_amt',      # similarity: 0.92
    'Strike Price': 'rate',            # similarity: 0.91
    'Maturity': 'expiry_date',         # similarity: 0.94
    'Buy/Sell': 'buy_sell',            # exact match
    'Call/Put': 'call_put',            # exact match
    'Terms': 'currency_pair'           # similarity: 0.78
}
```

### Step 5: Manual Review & Override

```
UI displays:
┌────────────────┬──────────────────┬────────────┐
│ Source Column  │ Auto-Mapped To   │ Similarity │
├────────────────┼──────────────────┼────────────┤
│ Counter Amt    │ counter_amt  ✅  │ 0.92       │
│ Strike Price   │ rate  ✅         │ 0.91       │
│ Maturity       │ expiry_date  ✅  │ 0.94       │
│ Buy/Sell       │ buy_sell  ✅     │ 1.00       │
│ Call/Put       │ call_put  ✅     │ 1.00       │
│ Terms          │ currency_pair ✅ │ 0.78       │
└────────────────┴──────────────────┴────────────┘

User can:
  - Accept all mappings
  - Override individual mappings (dropdown)
  - Leave unmapped (will be excluded)
```

### Step 6: Apply Mapping

```python
# Rename columns
df_standardized = df.rename(columns=auto_mappings)

print(df_standardized.columns)
# ['counter_amt', 'rate', 'expiry_date', 'buy_sell', 
#  'call_put', 'currency_pair']
```

### Step 7: Apply Format Rules (Optional)

```yaml
# From: configs/computed_rules.yaml
format_rules:
  - field: expiry_date
    type: date
    format: "%Y-%m-%d"
  
  - field: currency_pair
    type: normalize
    transform: "str.upper().replace('/', '')"
```

**Execution**:
```python
# Date normalization
df['expiry_date'] = pd.to_datetime(df['expiry_date'])

# Currency pair normalization
df['currency_pair'] = df['currency_pair'].str.replace('/', '').str.upper()
# "EUR/USD" → "EURUSD"
```

### Step 8: Apply Computed Fields

```yaml
# Add calculated columns
computed_fields:
  - field: normalized_pair
    formula: "currency_pair.replace('/', '')"
  
  - field: days_to_expiry
    formula: "(expiry_date - trade_date).days"
```

**Result**:
```python
df['normalized_pair'] = df['currency_pair'].str.replace('/', '')
df['days_to_expiry'] = (df['expiry_date'] - df['trade_date']).dt.days
```

---

## Output Format

### Standardized DataFrame

**Before** (Extract output):
```
   Counter Amt  Strike Price  Maturity    Buy/Sell  Call/Put  Terms
0  100000       1.08          2024-06-15  Sell      Put       EUR/USD
1  100000       1.10          2024-06-15  Buy       Call      EUR/USD
```

**After** (Standardize output):
```
   counter_amt  rate  expiry_date  buy_sell  call_put  currency_pair  normalized_pair
0  100000.0     1.08  2024-06-15   Sell      Put       EURUSD         EURUSD
1  100000.0     1.10  2024-06-15   Buy       Call      EURUSD         EURUSD
```

---

## Edge Cases

### Case 1: Low Similarity (< threshold)

```
Source: "XYZ_Field"
Similarities: all < 0.5

Handling:
  - Leave unmapped
  - Flag: "Unknown field"
  - User can manually map via dropdown
```

### Case 2: Ambiguous Match

```
Source: "Amount"
Matches:
  - counter_amt: 0.85
  - premium_amt: 0.82  (difference < 0.1)

Handling:
  - Auto-select highest (counter_amt)
  - Highlight in UI as "Low confidence"
  - Suggest manual review
```

### Case 3: Missing Required Fields

```
After mapping, check:
  required_fields = ['counter_amt', 'rate', 'expiry_date']

IF any missing:
    Warning: "Missing required field: expiry_date"
    Allow proceed with degraded functionality
```

### Case 4: Data Type Mismatch

```
Field: expiry_date
Expected type: datetime
Actual values: ["2024-06-15", "15/06/2024", "Jun 15, 2024"]

Handling:
  - Try pd.to_datetime() with multiple formats
  - Flag unparseable values
  - Allow manual correction
```

---

## Validation Checks

### Post-Standardization Validation

**Check 1**: Column coverage
```
mapped_count = len(auto_mappings)
total_count = len(source_columns)

coverage = mapped_count / total_count
Target: > 80%
```

**Check 2**: Required fields present
```
required = ['counter_amt', 'rate', 'expiry_date', 'buy_sell', 'call_put']

IF not all(field in df.columns for field in required):
    Warning: Critical field missing
```

**Check 3**: Data quality
```
# Check for null values
null_pct = df.isnull().sum() / len(df)

IF null_pct['counter_amt'] > 0.1:
    Warning: "10% missing amounts"
```

---

## Mapping Persistence

### Save Mapping Configuration

```yaml
# Save to: configs/mappings/{vendor_name}.yaml
vendor: Bank_ABC
created: 2024-01-15
mappings:
  Counter Amt: counter_amt
  Strike Price: rate
  Maturity: expiry_date
  Buy/Sell: buy_sell
  Call/Put: call_put
  Terms: currency_pair
```

**Benefit**: Next upload from same vendor auto-applies saved mapping

### Load Saved Mapping

```python
# Check if vendor mapping exists
IF vendor_mapping_file exists:
    Load mappings from file
    Apply to current data
    Skip AI inference (faster!)
ELSE:
    Run semantic mapping
    Offer to save for future
```

---

## Example: Complete Standardization

### Input (from Extract)
```
15 rows × 8 columns
Columns: ['Counter Amt', 'Strike Price', 'Maturity', 
          'Buy/Sell', 'Call/Put', 'Terms', 'Premium', 'Trade Date']
```

### Process
```
1. Load 23 standard fields from config

2. Encode embeddings:
   - 23 standard × 384 dim = 8,832 values
   - 8 source × 384 dim = 3,072 values

3. Calculate 8 × 23 = 184 similarity scores

4. Auto-map (greedy, threshold=0.5):
   - Counter Amt → counter_amt (0.92)
   - Strike Price → rate (0.91)
   - Maturity → expiry_date (0.94)
   - Buy/Sell → buy_sell (1.00)
   - Call/Put → call_put (1.00)
   - Terms → currency_pair (0.78)
   - Premium → premium_amt (0.88)
   - Trade Date → trade_date (0.96)

5. User reviews: Accepts all

6. Apply mapping: Rename columns

7. Format rules:
   - Normalize dates
   - Uppercase currency pairs

8. Computed fields:
   - Add normalized_pair
```

### Output
```
15 rows × 9 columns (8 mapped + 1 computed)
Columns: ['counter_amt', 'rate', 'expiry_date', 
          'buy_sell', 'call_put', 'currency_pair', 
          'premium_amt', 'trade_date', 'normalized_pair']

All values normalized and typed correctly
```

---

## UI/UX Flow

### User Actions
```
1. Navigate to "Standardize" page
2. View auto-mapped fields in table
3. Review mappings:
   - Green checkmarks (high confidence)
   - Yellow warnings (low confidence)
   - Red errors (unmapped)
4. Override if needed (dropdown selection)
5. Click "Apply Mapping"
6. View standardized data preview
```

### User Feedback
```
During mapping:
  - "Analyzing 8 columns..."
  - "Found 8 matches"

Success:
  - ✅ "8/8 columns mapped (100%)"
  - Show standardized table

Warnings:
  - ⚠️ "Low confidence: Terms → currency_pair (0.78)"
  - Suggest review
```

---

## Performance Optimization

### Caching Embeddings

```python
# Cache standard field embeddings (reusable)
standard_embeddings = load_cache('standard_embeddings.pkl')

IF not standard_embeddings:
    standard_embeddings = encode(standard_fields)
    save_cache('standard_embeddings.pkl', standard_embeddings)

# Only encode source columns (changes per vendor)
source_embeddings = encode(source_columns)  # Fast: ~100ms
```

### Batch Processing

```python
# Encode all columns at once (vectorized)
embeddings = model.encode(source_columns, batch_size=8)
# vs encoding one-by-one: 8× slower
```

---

## Data Persistence

### State Storage
```python
state['standardize_data'] = df_standardized
state['standardize_metadata'] = {
    'mapping': auto_mappings,
    'coverage': 8/8,
    'timestamp': datetime.now()
}
```

---

## Summary

**Stage**: Standardize (Stage 2 of 5)  
**Input**: DataFrame with vendor-specific columns  
**Output**: DataFrame with standardized column names  
**Key Technique**: Semantic similarity via embeddings  
**Performance**: ~200ms for typical datasets  
**Next Stage**: Group (identify multi-leg strategies)

---

## Transition to Stage 3

```
Standardize Output → Group Input

DataFrame: Standardized columns but individual legs
Next step: Group legs into strategies (add strategy_id)
```
