# Leave Balance Dashboard — ABS-A-001

**Classification:** Analytics (A)
**Priority:** P0 (MVP)
**Primary Actor:** Employee (self-service), Manager (team view), HR Admin (org-wide)
**API:** `GET /leaves/balances`, `GET /leaves/balances/{balanceId}/movements`
**User Story:** US-ABS-002, US-ABS-BALANCE-MGR
**BRD Reference:** FR-ABS-004
**Hypothesis:** H1 (Event-Driven Ledger — balances derived from movements), H5 (Calendar-first UX — balance visible from calendar)
**Date:** 2026-03-25

---

## Purpose

The Leave Balance Dashboard provides real-time, authoritative visibility into each employee's leave entitlements across all active leave types. Unlike a simple balance field, the dashboard exposes the full movement ledger (accruals, deductions, reservations, lot expirations) that underpins the balance — reflecting the Event-Driven Ledger architecture (H1). This replaces manual balance lookups via HR, Excel spreadsheets, and verbal inquiry.

**Three roles, three views:**
1. **Employee** — personal balance widget + detail + movement history
2. **Manager** — team balance overview with low-balance alerts
3. **HR Admin** — org-wide balance query with export capability

---

## State Derivation

Leave balance is **never stored directly**. It is derived by aggregating `LeaveMovement` records on the ledger:

```
available_days  = Σ(ACCRUAL) + Σ(CARRYOVER) - Σ(DEDUCTION) - Σ(RESERVATION) - Σ(EXPIRY)
pending_days    = Σ(RESERVATION) — for requests still in SUBMITTED/UNDER_REVIEW
used_days       = Σ(DEDUCTION) — for APPROVED requests whose leave date has passed
total_entitled  = Σ(ACCRUAL) + Σ(CARRYOVER) for the current policy year
```

A `LeaveMovement` record is **immutable and append-only** — corrections are new records (`CORRECTION_CREDIT` / `CORRECTION_DEBIT`), never edits.

---

## Screens and Steps

### Screen 1: Balance Widget (Home Dashboard / Employee Home)

**Entry points:**
- Employee Home — "My Leave Balances" widget (always visible)
- Manager Home — "Team Leave Summary" panel
- Quick access from Leave request form ("Check Balance" CTA)

**Layout — Employee Widget:**

```
+--------------------------------------------------+
|  My Leave Balances                     [View All] |
+--------------------------------------------------+
|                                                  |
|  Annual Leave                                    |
|  ┌──────────────────────────────────────────┐   |
|  │ Available: 10.0 days                      │   |
|  │ Pending: 2.0 days │ Used: 5.0 days        │   |
|  │ [████████████████████░░░░░░] 66%          │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  Sick Leave                                      |
|  ┌──────────────────────────────────────────┐   |
|  │ Available: 14.0 days                      │   |
|  │ Pending: 0.0 days │ Used: 1.0 day         │   |
|  │ [███████████████████████░░░] 93%          │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  ⚠ Carryover lot expires Mar 31 — 2.0 days      |
+--------------------------------------------------+
```

**Color logic:**
- 🟢 Green bar: available > 70% of total entitled
- 🟡 Yellow bar: available 30–70%
- 🔴 Red bar: available < 30%
- ⚠ Orange expiry warning: lot expires within 30 days

### Screen 2: Balance Detail View

**Route:** `/leave/balances/{leaveTypeId}`

**Layout:**

```
+--------------------------------------------------+
|  < Back     Annual Leave Balance          [2026] |
+--------------------------------------------------+
|                                                  |
|  Balance Summary                                 |
|  ┌──────────────────────────────────────────┐   |
|  │ Total Entitled:    15.0 days              │   |
|  │ Carried Over:       2.0 days (→ Mar 31)   │   |
|  │ Accrued YTD:        8.0 days              │   |
|  │ ──────────────────────────────────────── │   |
|  │ Used:              -5.0 days              │   |
|  │ Pending:           -2.0 days (reserved)   │   |
|  │ ──────────────────────────────────────── │   |
|  │ Available:         10.0 days              │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  Lots (FEFO order)                               |
|  ┌──────────────────────────────────────────┐   |
|  │ Source     │ Amount │ Expires             │   |
|  │ Carryover  │  2.0   │ Mar 31, 2026 ⚠     │   |
|  │ Accrual    │  8.0   │ Dec 31, 2026 ✅    │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  Movement History           [Filter ▼]  [Export] |
|  ┌──────────────────────────────────────────┐   |
|  │ Date     │ Type       │ Amount │ Balance  │   |
|  │ Mar 01   │ Accrual    │  +1.25 │ 10.00    │   |
|  │ Feb 20   │ Deduction  │  -3.00 │  8.75    │   |
|  │ Feb 15   │ Reservation│  -2.00 │ 11.75    │   |
|  │ Feb 01   │ Accrual    │  +1.25 │ 13.75    │   |
|  │ Jan 15   │ Carryover  │  +2.00 │ 12.50    │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  [Request Leave from this balance →]             |
+--------------------------------------------------+
```

**Movement type labels:**
| `LeaveMovement.type` | Display label |
|---------------------|---------------|
| `ACCRUAL` | Accrual |
| `CARRYOVER` | Carried Over |
| `DEDUCTION` | Leave Taken |
| `RESERVATION` | Reserved (pending request) |
| `RESERVATION_RELEASE` | Released (request cancelled/rejected) |
| `EXPIRY` | Expired |
| `CORRECTION_CREDIT` | Balance Correction (Credit) |
| `CORRECTION_DEBIT` | Balance Correction (Debit) |

### Screen 3: Team Balance View (Manager)

**Route:** `/leave/team-balances`

**Layout:**
```
+--------------------------------------------------+
|  Team Leave Balances              [Filter ▼] [Export] |
+--------------------------------------------------+
|                                                  |
|  [Search employee...]     [Department: All ▼]    |
|  [Leave Type: All ▼]      [Balance: All ▼]       |
|                                                  |
|  ┌──────────────────────────────────────────┐   |
|  │ 🔴 Jane Doe                              │   |
|  │    Developer  │  Annual: 2.0 days        │   |
|  │               │  Sick: 14.0 days         │   |
|  │               │       [View Details]     │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  ┌──────────────────────────────────────────┐   |
|  │ 🟢 John Smith                            │   |
|  │    Designer   │  Annual: 12.0 days       │   |
|  │               │  Sick: 13.0 days         │   |
|  │               │       [View Details]     │   |
|  └──────────────────────────────────────────┘   |
|                                                  |
|  ⚠ 1 employee has Annual leave < 5 days         |
+--------------------------------------------------+
```

**Balance Range filter:**
- 🔴 Low: available < 5 days
- 🟡 Medium: 5–10 days
- 🟢 High: > 10 days

---

## Notification Triggers

| Event | Recipient | Channel | Template |
|-------|-----------|---------|----------|
| Lot expiring in 30 days | Employee | Push + In-app | "Your [N] days of [leave type] (carryover) will expire on [date]. Plan your leave or contact HR." |
| Lot expiring in 7 days | Employee | Push + Email | "URGENT: [N] days of [leave type] expire in 7 days. Submit your leave request now." |
| Low balance alert (< 5 days Annual) | Manager | In-app dashboard badge | "[Employee] has [N] days Annual leave remaining." |

---

## API Contracts

### GET /leaves/balances

**Response 200:**
```json
{
  "employee_id": "uuid",
  "as_of": "2026-03-25T04:00:00Z",
  "balances": [
    {
      "balance_id": "uuid",
      "leave_type": {
        "id": "uuid",
        "name": "Annual Leave",
        "code": "ANNUAL"
      },
      "accrued_days": 15.0,
      "used_days": 5.0,
      "pending_days": 2.0,
      "available_days": 10.0,
      "carryover_days": 2.0,
      "total_entitled_days": 17.0,
      "lots": [
        {
          "lot_id": "uuid",
          "source": "CARRYOVER",
          "amount_days": 2.0,
          "expires_at": "2026-03-31"
        },
        {
          "lot_id": "uuid",
          "source": "ACCRUAL",
          "amount_days": 8.0,
          "expires_at": "2026-12-31"
        }
      ]
    }
  ]
}
```

### GET /leaves/balances/{balanceId}/movements

**Query params:** `?from=2026-01-01&to=2026-03-25&type=ACCRUAL,DEDUCTION&page=1&limit=20`

**Response 200:**
```json
{
  "balance_id": "uuid",
  "total": 42,
  "movements": [
    {
      "movement_id": "uuid",
      "date": "2026-03-01",
      "type": "ACCRUAL",
      "amount_days": 1.25,
      "balance_after_days": 10.00,
      "reference": "Monthly accrual — batch run 2026-03-01",
      "created_at": "2026-03-01T02:00:00Z"
    },
    {
      "movement_id": "uuid",
      "date": "2026-02-20",
      "type": "DEDUCTION",
      "amount_days": -3.00,
      "balance_after_days": 8.75,
      "reference": "Leave request LR-2026-02-042",
      "created_at": "2026-02-20T08:15:12Z"
    }
  ]
}
```

---

## Data Sources

| Balance Component | Source |
|------------------|--------|
| `accrued_days` | Σ `LeaveMovement.type IN (ACCRUAL)` |
| `carryover_days` | Σ `LeaveMovement.type = CARRYOVER` |
| `used_days` | Σ `LeaveMovement.type = DEDUCTION` |
| `pending_days` | Σ `LeaveMovement.type = RESERVATION` (not yet released) |
| `available_days` | Derived: `(accrued + carryover) - used - pending - expired` |
| Lot FEFO ordering | `LeaveLot.expires_at ASC NULLS LAST` |

---

## Validation Rules

| Rule | Logic |
|------|-------|
| Available balance non-negative | When a `RESERVATION` would push `available_days` below 0, block with `INSUFFICIENT_BALANCE` |
| Lot expiry display | Show ⚠ if any lot expires within 30 days; show 🔴 if within 7 days |
| Balance consistency | `available_days` + `pending_days` + `used_days` = `accrued_days` + `carryover_days` - `expired_days` |
| Period filter | Only show movements for the selected policy year (Jan 1 – Dec 31) |

---

## Non-Functional Requirements

### Performance

| Metric | Target |
|--------|--------|
| Balance widget load (personal) | <500ms p95 |
| Balance detail page | <1s p95 |
| Team balance view (50 employees) | <2s p95 |
| Movement history pagination | <500ms per page |

### Accessibility (WCAG 2.1 AA)

| Standard | Requirement |
|----------|-------------|
| Color contrast | Progress bar fill ≥ 4.5:1 against background — supplemented by % text label (not color alone) |
| Keyboard navigation | Tab through all balance cards; enter to expand; keyboard accessible filters |
| Screen reader | ARIA labels on progress bars: `aria-label="Annual leave: 10 days available out of 17 total"` |
| Expiry warnings | Alert icon + descriptive text — not color-only indicator |

### Availability

| Metric | Target |
|--------|--------|
| Uptime | 99.9% |
| Real-time balance | SSE push on approval events — no full page reload required |
| Offline | Balance widget shows last-fetched value with "last updated X ago" timestamp |

---

## Mobile Considerations (H6)

- Balance widget renders as vertically stacked cards on mobile; progress bar full-width
- Lot expiry warning shown as inline badge below balance card (not tooltip)
- "Request Leave" CTA visible below each balance type — no navigation required
- Movement history is paginated (20 per page) with infinite scroll on mobile
- Export disabled on mobile; redirects to desktop notification

---

## Business Rules Applied

| Rule | Description |
|------|-------------|
| BR-ABS-040 | Balance is always derived from the `LeaveMovement` ledger; snapshot caching allowed for read performance but must be invalidated on any new movement event |
| BR-ABS-041 | FEFO (First-Expired-First-Out) — carryover lots are consumed before accrual lots; displayed in expiry ASC order |
| BR-ABS-042 | `available_days` displayed to the employee must reflect the current `RESERVATION` (pending balance hold) — not the raw accrued amount |
| BR-ABS-043 | Movement history is immutable; "corrections" appear as explicit `CORRECTION_CREDIT`/`CORRECTION_DEBIT` entries, never edits |
| BR-ABS-044 | Balance projection (accrual to year-end) is an informational estimate — not a reservation; shown as greyed-out "Projected by Dec 31: [N] days" |

---

## Traceability

| Source | Reference |
|--------|-----------|
| BRD Requirement | `FR-ABS-004` — Leave Balance Inquiry |
| User Stories | `US-ABS-002`, `US-ABS-BALANCE-MGR` |
| Domain Events | `LeaveAccrualProcessed`, `LeaveBalanceReserved`, `LeaveBalanceDeducted`, `LeaveExpired` |
| Feature Catalog | `ABS-T-004` (Balance Inquiry — P0); `ABS-T-009` (Reservation Status View — P1) |
| Flow | No standalone flow; balance widget is an embedded read surface in `submit-leave-request.flow.md` |

---

**Document Control:**
- **Version:** 1.1 (created in Source 1 style; merged from 99.odsa ABS-A-001.spec.md + enhanced with ledger derivation formula, FEFO lot logic, mobile considerations, team view, notification triggers, full API contracts, WCAG accessibility, business rules BR-ABS-040–044)
- **Created:** 2026-03-25
- **Status:** READY FOR IMPLEMENTATION
