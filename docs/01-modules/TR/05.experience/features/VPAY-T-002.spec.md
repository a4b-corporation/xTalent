# VPAY-T-002 — Commission Real-Time Dashboard

**Type**: Transaction (Analytics-heavy) | **Priority**: P0 | **BC**: BC-03 Variable Pay
**Country**: [All countries]
**USP**: Real-time < 5 seconds after CRM sync

---

## Purpose

The Commission Dashboard gives sales reps and Sales Ops instant visibility into quota attainment, running commission, and transaction details — updated in real-time (< 5 seconds) as sales close in CRM. This is a key USP differentiating xTalent from competitors. Powered by Kafka streaming + WebSocket push, not polling.

---

## Actors

| Actor | Primary Need |
|-------|-------------|
| Worker (Sales Rep) | View own running commission, quota progress |
| Sales Operations | Monitor team attainment, resolve disputes, import transactions |
| Finance Approver | Review period-end commission totals before payout |
| Compensation Admin | Monitor commission plan effectiveness |

---

## Worker View: My Commission Dashboard

### Layout
```
┌──────────────────────────────────────────────────────────────────┐
│  My Commission — March 2026                    [Period selector▼] │
├─────────────────────┬────────────────────────────────────────────┤
│  QUOTA ATTAINMENT   │  RUNNING COMMISSION                        │
│  ████████░░  85%    │  ₫ 44,000,000                             │
│  850M / 1B VND      │  Target: ₫ 51,800,000                     │
│                     │  Gap to next tier: ₫ 7,800,000 more       │
├─────────────────────┴────────────────────────────────────────────┤
│  TIER PROGRESS                                                    │
│  [0–80%: 5%] ████ [80–100%: 8%] ██ [100%+: 10%] ░░             │
│  Currently in: Tier 2 (8%)                                       │
├──────────────────────────────────────────────────────────────────┤
│  TRANSACTIONS (23 deals)              [Search] [Filter] [Export] │
│  Date     │ Deal Name        │ Amount      │ Status              │
│  Mar 25   │ VNG Corp Renewal │ 120,000,000 │ Synced              │
│  Mar 22   │ TechCo New       │  85,000,000 │ Synced              │
│  ...                                                              │
└──────────────────────────────────────────────────────────────────┘
```

### Key Elements
- **Quota Gauge**: Radial or horizontal progress bar; color: red < 80%, orange 80–99%, green ≥ 100%
- **Tier Progress**: Shows current tier + how much more to reach next tier (motivational nudge)
- **Running Commission**: Bold current amount + target comparison
- **Transaction Table**: Sortable by date/amount; filter by period/status

---

## Real-Time Update Mechanism

```
CRM (close deal) → CRM Sync Job (ImportSalesTransactions)
  → SalesTransaction saved → SalesTransactionSynced event (Kafka)
  → RecalculateCommission (< 5s) → CommissionStatement updated
  → QuotaAttainmentUpdated event (Kafka: tr.commission-recalculated.v1)
  → WebSocket server pushes to active browser sessions
  → Dashboard updates without page refresh
```

**Latency SLA**: < 5 seconds end-to-end (CRM save → dashboard update).

Implementation note: Requires Kafka consumer + WebSocket bridge service. Browser connects via `ws://` on page load; reconnects automatically on disconnect.

---

## Sales Ops View: Team Dashboard

| Column | Description |
|--------|-------------|
| Worker | Name + photo |
| Territory | Assigned territory |
| Quota | Period target |
| Actual | Running total |
| Attainment % | Gauge |
| Commission | Running amount |
| Tier | Current tier label |
| Last Activity | Most recent synced transaction |

**Actions**:
- Click Worker → drill into their individual dashboard
- Flag transaction as disputed → creates dispute record
- Import transactions manually (CSV upload fallback)

---

## Period End: Finalization Flow

1. Last day of period: CommissionStatement.status → PENDING_REVIEW
2. Sales Ops reviews team dashboard
3. Dispute resolution (if any):
   - Flag disputed transaction → `SalesTransaction.status = DISPUTED`
   - Finance Approver resolves: VOIDED or CONFIRMED
   - System recalculates after resolution
4. Sales Ops clicks "Finalize Period" → all statements → FINALIZED
5. Finance Approver approves → APPROVED → PAID (via Payroll Bridge)

---

## CRM Sync Status Panel (Sales Ops)

| Metric | Description |
|--------|-------------|
| Last sync | Timestamp of most recent import |
| Records imported | Count this period |
| Errors | Failed imports (with detail) |
| Duplicates skipped | Idempotency rejections |
| Status | OK / ERROR / PARTIAL |

Manual import: "Upload CSV" → validates headers → preview → confirm import

---

## Edge Cases

| Scenario | Handling |
|----------|---------|
| CRM transaction voided | Immediate recalculation; commission reduced |
| Worker changes territory mid-period | Split by days in each territory (configurable BR-V08) |
| Commission exceeds cap | Cap applied; `is_capped = true`; badge shown; `CommissionCapApplied` event |
| WebSocket disconnected | Client reconnects and gets latest state; no missed updates |
| No CRM sync for > 24h | Alert to Sales Ops; banner on dashboard |

---

*VPAY-T-002 — Commission Real-Time Dashboard*
*2026-03-27*
