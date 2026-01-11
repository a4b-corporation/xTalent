# Phase 3 Complete: Pipeline Stages Deep Dive ✅

## Completed Documents

### 1. [Stage 1: Extract](stage-1-extract.md)
**Purpose**: Data ingestion from Excel/CSV/PDF  
**Input**: Raw files (various formats)  
**Output**: DataFrame with vendor-specific columns  
**Key Features**:
- Multi-format support (Excel, CSV, PDF OCR)
- Auto-detect headers and data types
- Example: 15 rows extracted from bank_trades.xlsx

### 2. [Stage 2: Standardize](stage-2-standardize.md)
**Purpose**: Field mapping & normalization  
**Input**: DataFrame with vendor columns  
**Output**: DataFrame with standard field names  
**Key Features**:
- AI semantic mapping (embeddings + similarity)
- Manual override UI
- Mapping persistence (save for future uploads)
- Example: "Counter Amt" → "counter_amt" (0.92 similarity)

### 3. [Stage 3: Group](stage-3-group.md)
**Purpose**: Multi-leg strategy identification  
**Input**: Standardized individual legs  
**Output**: DataFrame with strategy_id column  
**Key Features**:
- Composite key grouping (trade_date + expiry + pair)
- Multi-level: Exact + Fuzzy matching
- Hash-based performance (O(N))
- Example: 15 legs → 4 strategies (avg 3.75 legs/strategy)

### 4. [Stage 4: Match](stage-4-match.md)
**Purpose**: Product classification  
**Input**: Grouped strategies  
**Output**: DataFrame with fp_product_code, option_strategy, fp_rmi_type  
**Key Features**:
- Fingerprint pattern matching (score-based)
- Academic classification rules
- RMI perspective detection (LHS/RHS)
- Example: [Sell Put, 2× Buy Call] → RF (Ratio Forward, LHS)

### 5. [Stage 5: Calculate](stage-5-calculate.md)
**Purpose**: Multi-leg aggregation  
**Input**: Classified multi-leg strategies  
**Output**: Single-row DataFrame per strategy (23 fields)  
**Key Features**:
- RMI-aware leg filtering
- Rule-driven aggregation (YAML config)
- Calculated fields (ratio, barrier_type)
- Example: 4 legs → 1 row with all output fields

---

## Complete Pipeline Flow

```
Raw File (15 rows)
    ↓ Stage 1: Extract
[Counter Amt, Strike Price, Maturity, ...]
    ↓ Stage 2: Standardize  
[counter_amt, rate, expiry_date, ...]
    ↓ Stage 3: Group
[strategy_id=STR001, STR001, STR001, STR001, ...]
    ↓ Stage 4: Match
[fp_product_code=RF, option_strategy=Ratio Forward, fp_rmi_type=LHS]
    ↓ Stage 5: Calculate
[original_notional=300K, strike_rate=1.08, ratio=1:1, ...]

Output: 4 consolidated strategies (23 output fields each)
```

---

## Key Metrics Across Stages

| Stage | Input | Output | Time | Compression |
|-------|-------|--------|------|-------------|
| 1. Extract | File | 15 rows | < 5s | - |
| 2. Standardize | 15 rows | 15 rows | ~200ms | - |
| 3. Group | 15 rows | 15 rows + strategy_id | < 1s | - |
| 4. Match | 15 rows | 15 rows + classifications | < 1s | - |
| 5. Calculate | 15 rows | 4 rows (aggregated) | < 1s | 3.75:1 |
| **Total** | **Raw file** | **4 strategies** | **< 10s** | **N/A** |

---

## Data Transformation Example

### Initial State (After Extract)
```csv
Counter Amt,Strike Price,Maturity,Buy/Sell,Call/Put,Terms
100000,1.08,2024-06-15,Sell,Put,EUR/USD
100000,1.10,2024-06-15,Buy,Call,EUR/USD
200000,1.06,2024-06-15,Sell,Put,EUR/USD
200000,1.12,2024-06-15,Buy,Call,EUR/USD
```

### After Standardize
```
counter_amt  rate  expiry_date  buy_sell  call_put  currency_pair
100000       1.08  2024-06-15   Sell      Put       EURUSD
100000       1.10  2024-06-15   Buy       Call      EURUSD
200000       1.06  2024-06-15   Sell      Put       EURUSD
200000       1.12  2024-06-15   Buy       Call      EURUSD
```

### After Group
```
strategy_id  counter_amt  rate  buy_sell  call_put  ...
STR001       100000       1.08  Sell      Put
STR001       100000       1.10  Buy       Call
STR001       200000       1.06  Sell      Put
STR001       200000       1.12  Buy       Call
```

### After Match
```
strategy_id  fp_product_code  option_strategy  fp_rmi_type  counter_amt  rate  ...
STR001       RF               Ratio Forward    LHS          100000       1.08
STR001       RF               Ratio Forward    LHS          100000       1.10
STR001       RF               Ratio Forward    LHS          200000       1.06
STR001       RF               Ratio Forward    LHS          200000       1.12
```

### Final Output (After Calculate)
```
strategy_id  fp_product_code  original_notional  strike_rate  upper_barrier  ratio  leg_sequence
STR001       RF               300000.00          1.08         1.12           1:1.0  4
```

---

## What's Next

### Phase 4: Configuration
Deep dive into:
- `standard_fields.yaml`
- `strategy_fingerprints.yaml`
- `aggregation_rules.yaml`
- `grouping_config.yaml`

### Phase 5: User Guide & Case Studies
Practical examples:
- Complete workflow walkthrough
- LHS/RHS analysis case study
- Multi-leg consolidation examples
- Troubleshooting common issues
