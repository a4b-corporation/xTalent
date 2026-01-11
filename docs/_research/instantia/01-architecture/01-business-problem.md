# The Business Problem: FX Option Data Consolidation

## Context

Financial institutions trade Foreign Exchange (FX) options to hedge currency risks. These trades are:
- **Complex**: Multi-leg strategies (2-4 legs combined)
- **Vendor-specific**: Each bank uses different terminology
- **Fragmented**: Same strategy split across multiple rows
- **Unclassified**: No standardized product naming

## The Challenge

### 1. **Data Standardization Problem**
Each vendor uses different column names for the same concept:
```
Bank A: "Counter Amt" | "Strike Price" | "Maturity"
Bank B: "Notional" | "Strike Rate" | "Expiry Date"
Bank C: "Amount" | "Rate" | "Value Date"
```

**Impact**: Manual mapping required for every new vendor → time-consuming, error-prone

### 2. **Multi-Leg Consolidation Problem**
A single strategy (e.g., Collar) is represented as separate rows:
```
Row 1: Sell Put  @ 1.08 | Notional: $100,000
Row 2: Buy Call  @ 1.10 | Notional: $100,000
```

**Desired output**: Single consolidated row with calculated fields
```
Strategy: Collar | Strike: 1.08 | Upper: 1.10 | Notional: $100,000
```

**Impact**: Cannot analyze strategy-level P&L or risk without manual consolidation

### 3. **Product Classification Problem**
Same product has multiple names:
- Internal code: "RF" (Ratio Forward)
- Academic name: "Reverse Collar"
- Vendor name: "Protected Forward"

**Impact**: No standardized taxonomy → difficult to aggregate across vendors

### 4. **Perspective Detection Problem**
FX trades have two sides:
- **Importer (LHS)**: Selling foreign currency, buying local
  - Notional from **Sell Put** legs
  - Leverage from **Buy Call** legs
- **Exporter (RHS)**: Buying foreign currency, selling local
  - Notional from **Sell Call** legs
  - Leverage from **Buy Put** legs

**Impact**: Wrong aggregation if perspective not detected → incorrect risk exposure

---

## Business Requirements

### Must-Have Capabilities
1. **Automatic Field Mapping**: Zero-configuration support for new vendors
2. **Multi-Leg Detection**: Identify which rows belong to the same strategy
3. **Product Recognition**: Classify products against internal taxonomy
4. **Perspective-Aware Aggregation**: Calculate notional/leverage based on Importer/Exporter role
5. **Dual Classification**: Map to both internal codes and academic names

### Success Criteria
- ✅ Process 1000+ trades from multiple vendors without manual mapping
- ✅ 95%+ accuracy in product classification
- ✅ Single-row output per strategy with all calculated fields
- ✅ Support new product types via configuration (no code changes)

---

## Current Manual Process Pain Points

### Time Consumption
| Step | Manual Time | With Automation |
|------|-------------|-----------------|
| Field mapping | 30 min/vendor | < 1 min |
| Strategy grouping | 1-2 hours | < 5 sec |
| Product classification | 2-3 hours | < 10 sec |
| Aggregation | 1-2 hours | < 5 sec |
| **Total** | **4-7 hours** | **< 1 min** |

### Error Rates
- Manual mapping: **10-15% field mismatch**
- Manual grouping: **5-10% incorrect legs**
- Manual classification: **20-30% unknown products**

---

## Expected Outcomes

### Operational Benefits
- **Reduce processing time**: 4-7 hours → < 1 minute
- **Increase accuracy**: Manual errors eliminated
- **Scale effortlessly**: Support new vendors without custom code
- **Enable analysis**: Strategy-level reporting and risk aggregation

### Strategic Benefits
- **Standardized taxonomy**: Consistent product naming across organization
- **Audit trail**: Full traceability of transformations
- **Flexibility**: Config-driven rules adapt to new market products
- **Knowledge capture**: Business logic externalized from code

---

## Scope & Constraints

### In Scope
- FX vanilla options and structured products
- Multi-leg strategies (up to 4 legs)
- Standard barrier types (European, American, Window)
- Common product families (Forwards, Collars, Seagulls, Ratio structures)

### Out of Scope
- Real-time streaming data
- Cross-asset products (FX + IR)
- Exotic barriers (Parisian, Lookback)
- Trade execution or booking

### Assumptions
- Input data is in Excel/PDF format
- Strategies are within same expiry date and currency pair
- Historical data (not real-time requirements)
