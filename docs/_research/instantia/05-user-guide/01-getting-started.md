# Getting Started Guide

## Prerequisites

### System Requirements
- Python 3.9+
- 4GB RAM minimum (8GB recommended)
- 1GB free disk space
- Modern web browser (Chrome, Firefox, Safari)

### Installation
```bash
# Clone repository
git clone <repository_url>
cd optionETL

# Install dependencies
pip install -r requirements.txt

# Download embedding model (first run only)
python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"
```

---

## Quick Start (5 Minutes)

### Step 1: Launch Application
```bash
python main.py
```

Output:
```
NiceGUI ready to go on http://localhost:8080
```

### Step 2: Open Browser
Navigate to: `http://localhost:8080`

### Step 3: Upload Sample File
1. Click **Extract** tab
2. Upload `sample_data/trades_example.xlsx`
3. Click **Load File**
4. ✅ See: "Loaded 15 rows, 8 columns"

### Step 4: Run Through Pipeline
1. **Standardize**: Click "Auto-Map Fields" → Review → "Apply"
2. **Group**: Click "Group Strategies" → See: "4 strategies created"
3. **Match**: Click "Classify" → See: "4/4 classified"
4. **Calculate**: Click "Aggregate" → See: "4 output rows"

### Step 5: Export Results
1. Click **Download Results**
2. Open `output.xlsx` in Excel
3. ✅ See consolidated strategies with all 23 fields

---

## Basic Workflow

### Complete Pipeline Flow

```mermaid
graph LR
    A[Upload File] --> B[Extract]
    B --> C[Standardize]
    C --> D[Group]
    D --> E[Match]
    E --> F[Calculate]
    F --> G[Export]
    
    style A fill:#e3f2fd
    style G fill:#c8e6c9
```

### Stage-by-Stage Walkthrough

#### Stage 1: Extract
**Goal**: Load raw data

**Actions**:
1. Select file (Excel/CSV/PDF)
2. Click "Upload File"
3. Verify data table preview

**Success**: Rows and columns displayed

#### Stage 2: Standardize
**Goal**: Map vendor columns to standard names

**Actions**:
1. Review auto-mapped fields
2. Override if needed (dropdown)
3. Click "Apply Mapping"

**Success**: Green checkmarks on all mappings

**Tip**: Save mapping for future uploads from same vendor

#### Stage 3: Group
**Goal**: Link related legs into strategies

**Actions**:
1. Review grouping keys (trade_date, expiry, pair)
2. Enable/disable fuzzy matching
3. Click "Group Strategies"

**Success**: strategy_id column added, multi-leg count > 60%

**Troubleshooting**: If too many single-leg, relax grouping keys

#### Stage 4: Match
**Goal**: Identify product types

**Actions**:
1. Click "Classify Strategies"
2. Review product distribution

**Success**: Classification rate > 90%

**Troubleshooting**: "UNKNOWN" products → add new fingerprint

#### Stage 5: Calculate
**Goal**: Consolidate to single row per strategy

**Actions**:
1. Review field mappings
2. Click "Calculate"
3. Verify output table

**Success**: N input rows → M output strategies (M < N)

**Validation**: Check critical fields (notional, strike, ratio)

---

## Common Tasks

### Task 1: Add New Vendor
**Problem**: Vendor uses different column names

**Solution**:
1. Upload file → Standardize stage
2. Review auto-mappings
3. If low similarity, add aliases to `standard_fields.yaml`:
   ```yaml
   - name: counter_amt
     aliases:
       - "Vendor XYZ Amount"  # Add this
   ```
4. Reload app, re-standardize
5. Save mapping for future

**Time**: 5-10 minutes

### Task 2: Add New Product
**Problem**: Unknown product not recognized

**Solution**:
1. Analyze legs manually (Buy/Sell, Call/Put)
2. Add fingerprint to `strategy_fingerprints.yaml`:
   ```yaml
   - name: New Product (NP)
     product_code: NP
     leg_count: 3
     patterns:
       - legs: [{bs: S, cp: P}, {bs: B, cp: C}, {bs: S, cp: C}]
         rmi_type: LHS
   ```
3. Restart app
4. Re-run Match stage

**Time**: 15-30 minutes

### Task 3: Adjust Grouping
**Problem**: Legs not grouping correctly

**Solution A** (Too strict):
```yaml
# Remove optional key
- field: company_code
  required: false  # Was: true
```

**Solution B** (Too loose):
```yaml
# Add more keys
- field: portfolio
  required: true
```

**Solution C** (Data errors):
```yaml
# Enable fuzzy matching
- field: expiry_date
  fuzzy: true
  tolerance: ±1 day
```

**Time**: 5 minutes

---

## Data Preparation Tips

### Excel Files
✅ **Good**:
- Header row in first row
- One row per leg
- Consistent date formats
- No merged cells

❌ **Avoid**:
- Multiple header rows
- Grouped/merged cells
- Mixed date formats (within same column)
- Empty rows between data

### Column Names
✅ **Good**:
- "Counter Amount", "Notional", "Trade Amount"
- Descriptive, semantic

❌ **Avoid**:
- "Col1", "Field_A", "Amount" (too generic)
- Asian characters without UTF-8 encoding

### Required Fields
**Minimum**:
- Amount/Notional
- Rate/Strike
- Expiry/Maturity
- Buy/Sell
- Call/Put
- Currency Pair

**Recommended**:
- Trade Date
- Trade ID
- Premium
- Barriers (if applicable)

---

## Performance Tips

### Large Files (> 1000 rows)
- Use CSV instead of Excel (faster parsing)
- Disable UI preview during processing
- Increase batch size in settings

### Multiple Vendors
- Save vendor mappings (`configs/mappings/<vendor>.yaml`)
- Load mapping before upload (auto-apply)

### Frequent Classifications
- Cache fingerprint matches
- Pre-load commonly used products

---

## Troubleshooting

### Issue: "No matches found" (Standardize)
**Cause**: Vendor column names very different

**Fix**:
1. Check similarity scores (should be > 0.5)
2. Add aliases to `standard_fields.yaml`
3. Manual override via dropdown

### Issue: Too many orphans (Group)
**Cause**: Grouping keys too strict

**Fix**:
1. Check grouping rate (target > 60%)
2. Remove optional keys (e.g., company_code)
3. Enable fuzzy matching for dates

### Issue: High "UNKNOWN" rate (Match)
**Cause**: New products not in fingerprint library

**Fix**:
1. Analyze unknown strategies manually
2. Add fingerprints to `strategy_fingerprints.yaml`
3. Restart and re-match

### Issue: Wrong calculations (Calculate)
**Cause**: Incorrect RMI detection

**Fix**:
1. Check fp_rmi_type column (should be LHS or RHS)
2. Verify leg positions (LHS: Sell-Put, RHS: Sell-Call)
3. If wrong, adjust fingerprint RMI rules

---

## Best Practices

### 1. Start Small
Test with 10-20 rows before processing thousands

### 2. Validate Each Stage
Don't proceed if current stage has errors

### 3. Save Configurations
Reuse mappings, fingerprints, grouping configs

### 4. Version Control Configs
Track changes to YAML files in Git

### 5. Review Unknown Products
Manually classify before adding fingerprints

### 6. Monitor Metrics
- Mapping coverage: > 80%
- Grouping rate: > 60%
- Classification rate: > 90%
- Average legs/strategy: 2-3

---

## Next Steps

- **Learn More**: Read [Architecture Overview](../01-architecture/README.md)
- **Deep Dive**: Study [Pipeline Stages](../03-pipeline-stages/README.md)
- **Customize**: Configure [Aggregation Rules](../04-configuration/03-aggregation-rules-guide.md)
- **Examples**: Review [Case Studies](../07-case-studies/README.md)

---

## Support

### Documentation
- Architecture: `docs/01-architecture/`
- Techniques: `docs/02-processing-techniques/`
- Pipeline: `docs/03-pipeline-stages/`
- Configuration: `docs/04-configuration/`

### Sample Data
- `sample_data/trades_example.xlsx` - Basic example
- `sample_data/complex_strategies.csv` - Advanced cases

### Common Issues
Check `docs/05-user-guide/troubleshooting.md` (if exists)
