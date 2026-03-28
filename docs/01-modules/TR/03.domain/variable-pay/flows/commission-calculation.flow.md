# Use Case Flow: Real-Time Commission Calculation

> **Bounded Context**: BC-03 — Variable Pay
> **Use Case**: Commission Recalculation After CRM Sales Transaction Import
> **Primary Actor**: System (CRM Sync), Sales Rep (views dashboard)
> **Trigger**: New SalesTransaction imported from CRM via daily sync or webhook

---

## Flow Diagram

```
CRM System         Import Job            BC-03 Variable Pay          Dashboard (Sales Rep)
     |                  |                        |                           |
     |  [1] Daily sync  |                        |                           |
     |  or webhook      |                        |                           |
     |─────────────────>|                        |                           |
     |                  |  [2] ImportSalesTransactions                       |
     |                  |───────────────────────>|                           |
     |                  |              [3] Dedup check:                      |
     |                  |              crm_transaction_id exists?            |
     |                  |              → SKIP (idempotent)                  |
     |                  |                        |                           |
     |                  |              [4] Insert SalesTransaction           |
     |                  |              status = SYNCED                       |
     |                  |                        |                           |
     |                  |              [5] SalesTransactionSynced published  |
     |                  |                        |──── Kafka ───────────────>|
     |                  |                        |                           |
     |                  |         [6] RecalculateCommission                  |
     |                  |         (per affected Worker per period)           |
     |                  |                        |                           |
     |                  |              [7] Aggregate all SalesTransactions   |
     |                  |              for Worker in current period          |
     |                  |                        |                           |
     |                  |              [8] Compute QuotaAttainment:          |
     |                  |              actual / quota × 100                  |
     |                  |                        |                           |
     |                  |              [9] Determine CommissionTier          |
     |                  |              based on attainment %                 |
     |                  |                        |                           |
     |                  |              [10] Apply FX conversion              |
     |                  |              (via BC-02 if multi-currency)         |
     |                  |                        |                           |
     |                  |              [11] Apply cap if configured          |
     |                  |                        |                           |
     |                  |              [12] Update CommissionStatement       |
     |                  |              last_recalculated_at = now()          |
     |                  |                        |                           |
     |                  |         [13] QuotaAttainmentUpdated event          |
     |                  |                        |──── Kafka (< 5s) ────────>|
     |                  |                        |                [14] UI    |
     |                  |                        |                renders    |
     |                  |                        |                real-time  |
```

---

## Steps Detail

### [2–3] Idempotent Import

**Command**: `ImportSalesTransactions`
**Idempotency key**: `crm_transaction_id`

```sql
INSERT INTO sales_transaction (
  id, crm_transaction_id, worker_id, deal_amount, currency,
  close_date, period, territory_id, status, synced_at
)
ON CONFLICT (crm_transaction_id) DO NOTHING   -- idempotent
```

If `crm_transaction_id` already exists → skip silently (BR-V03).

---

### [7] Sales Aggregation

```sql
SELECT
  SUM(deal_amount) AS actual_sales,
  currency
FROM sales_transaction
WHERE worker_id = ?
  AND period = '2026-03'
  AND status = 'SYNCED'
  AND territory_id = ?     -- if territory-scoped plan
GROUP BY currency
```

Multi-currency sales → convert to plan currency via BC-02 FxRateRecord.

---

### [8] QuotaAttainment Computation

```
attainment_pct = (actual_sales / quota_amount) × 100

Example:
  actual_sales = 850,000,000 VND
  quota_target = 1,000,000,000 VND
  attainment_pct = 85.0%
```

---

### [9] Tier Determination

**CommissionPlan tiers example**:
| from_pct | to_pct | rate | accelerator |
|----------|--------|------|-------------|
| 0 | 80 | 5% | — |
| 80 | 100 | 8% | — |
| 100 | null | 10% | 1.5× |

**TIERED calculation** (most common — apply each tier to the range it covers):
```
For attainment 85%:
  0–80% range: 800,000,000 × 5% = 40,000,000 VND
  80–85% range: 50,000,000 × 8% = 4,000,000 VND
  Total = 44,000,000 VND
```

**SLAB calculation** (all-or-nothing):
```
At 85% attainment → falls in 80–100% slab → 8% on entire amount
  850,000,000 × 8% = 68,000,000 VND
```

Tier type (TIERED/SLAB/FLAT) is defined per `CommissionPlan.tier_type`.

---

### [10] FX Conversion (if multi-currency)

```
If sales in USD and plan in VND:
  deal_amount_vnd = deal_amount_usd × FxRateRecord(USD→VND, close_date)
```

FX rate lookup via BC-02 `CalculationEnginePort`.

---

### [11] Cap Application

```
If commission_plan.max_commission_amount IS NOT NULL:
  final_commission = min(calculated_amount, max_commission_amount)
  is_capped = (calculated_amount > max_commission_amount)
  IF is_capped → emit CommissionCapApplied
```

---

### [12] CommissionStatement Update

```sql
UPDATE commission_statement
SET
  quota_attainment = {...},
  applied_tier = {...},
  commission_amount = 44000000,
  currency = 'VND',
  is_capped = false,
  last_recalculated_at = NOW(),
  status = 'OPEN'
WHERE worker_id = ? AND period = '2026-03'
```

---

### [13] Real-Time Event Publishing

**`QuotaAttainmentUpdated`** published to Kafka:
```json
{
  "worker_id": "uuid",
  "period": "2026-03",
  "attainment_pct": 85.0,
  "commission_amount": 44000000,
  "currency": "VND",
  "plan_id": "uuid",
  "computed_at": "2026-03-26T14:32:10Z"
}
```

**Latency SLA**: Dashboard receives event **< 5 seconds** after SalesTransaction imported.
This requires Kafka streaming — **batch processing is insufficient** for this requirement.

---

## Period End Flow

### Month Close
**Trigger**: Last day of month (or manual close by Sales Compensation Admin)
**Command**: `FinalizeCommissionStatement`

```
CommissionStatement.status: OPEN → PENDING_REVIEW
  → Manager reviews
  → Approved: FINALIZED
  → Disputes resolved
  → Payout scheduled: PAID
```

---

## Alternative Flows

### A1: Void Transaction
- Finance Approver calls `VoidSalesTransaction` with reason
- `SalesTransaction.status` → VOIDED
- `RecalculateCommission` triggered for affected Worker
- Audit trail preserved (transaction not deleted)

### A2: Territory Change Mid-Period
- Worker changes territory
- Commission splits proportionally by days in each territory (BR-V08)
- Configurable: can be disabled per enterprise

### A3: CRM Sync Error
- `CRMSyncStatus.status` → ERROR
- Alert to Sales Compensation Admin
- Manual import available as fallback
- No automatic retry loop (prevents double-import)

---

## Business Rules Applied

| Rule | Application |
|------|-------------|
| BR-V01 | < 5 seconds dashboard latency — Kafka required at step [13] |
| BR-V02 | SalesTransaction immutable after synced at step [4] |
| BR-V03 | Idempotent import via crm_transaction_id at step [3] |
| BR-V07 | Tier non-overlap validation at CommissionPlan creation |
| BR-V08 | Territory split on mid-period change at step [7] |

---

*Flow: Real-Time Commission Calculation — BC-03 Variable Pay*
*2026-03-26*
