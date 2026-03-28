# COMP-T-002 — Salary Change Activation

**Type**: Transaction | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]
**User Stories**: US-022

---

## Purpose

Salary Change Activation handles individual, off-cycle salary changes — promotions, market adjustments, corrections, or structural changes outside the merit review cycle. Each activation creates a new SalaryRecord version (SCD Type 2), preserving complete historical audit trail. The change triggers downstream events: payroll bridge notification and audit log capture. This feature is distinct from merit cycle proposals (COMP-T-001) in that it applies to a single worker at a time and does not require a cycle to be open.

---

## Trigger

Compensation Administrator or HR Administrator initiates a salary change for a specific worker via the worker's salary record detail page.

---

## Actors

| Actor | Role |
|-------|------|
| Compensation Administrator | Initiates the change |
| HR Administrator | Can initiate; can also approve |
| Finance Approver | Approves high-value changes (above threshold) |
| Worker | Notified of outcome (read-only) |
| System | Validates, creates SalaryRecord, fires events |

---

## State Machine

```
INITIATED → PENDING_APPROVAL → APPROVED → EFFECTIVE
               ↓
            REJECTED (→ initiator notified; can re-submit)
```

For changes within self-approval threshold: INITIATED → APPROVED → EFFECTIVE (no separate approval step).

---

## Step-by-Step Flow

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | Comp Admin | Navigates to worker's salary record detail | Shows current salary breakdown by component |
| 2 | Comp Admin | Clicks "Add Salary Change" | Opens change form in side drawer |
| 3 | Comp Admin | Selects `change_type` | PROMOTION / MARKET_ADJUSTMENT / CORRECTION / STRUCTURAL |
| 4 | Comp Admin | Enters `proposed_amount` | System calculates: new compa-ratio, % change from current |
| 5 | System | Shows pay range visualization | Bar: min / current / proposed / mid / max for worker's grade |
| 6 | System | Validates min wage in real-time | If proposed < min wage: red block with zone min wage amount |
| 7 | System | Checks pay range | If outside range: amber warning; justification field appears |
| 8 | Comp Admin | Sets `effective_date` | Must be today or future |
| 9 | Comp Admin | Enters `justification` | Required for outside-range or above-threshold changes |
| 10 | Comp Admin | Selects components to change (if not changing total only) | Optional: adjust individual component amounts |
| 11 | Comp Admin | Clicks "Submit" | System checks approval routing |
| 12 | System | If within self-approval threshold | Auto-approves; status → APPROVED → EFFECTIVE |
| 12b | System | If above threshold | Routes to Finance Approver; status → PENDING_APPROVAL |
| 13 | Finance Approver | Reviews + approves/rejects | Status → APPROVED or REJECTED |
| 14 | System (on APPROVED) | Creates new SalaryRecord version (SCD Type 2) | Previous record: `is_current = false`; New record: `is_current = true`, `effective_from = effective_date` |
| 15 | System | Publishes Kafka event | `tr.salary-changed.v1` → BC-08 Taxable Bridge, Payroll module |
| 16 | System | Publishes audit event | `tr.audit-records.v1` → BC-10 |
| 17 | System | Notifies worker | In-app + email: "Lương của bạn đã được cập nhật từ ngày [effective_date]." |

---

## Validations

| Rule | When | Error Message |
|------|------|--------------|
| Min wage hard block | On amount entry (real-time) | "Lương đề xuất VND [X] thấp hơn lương tối thiểu vùng [Zone]: VND [Y]." |
| Outside range warning | On amount entry | "Lương nằm ngoài khung [Grade]: [min]–[max]. Vui lòng nhập lý do." |
| Effective date | On submit | "Ngày hiệu lực phải là hôm nay hoặc trong tương lai." |
| No concurrent pending change | On submit | "Đã có thay đổi lương đang chờ phê duyệt cho Worker này." |
| Active salary record required | On open form | "Không tìm thấy bản ghi lương hiện hành. Vui lòng tạo bản ghi lương trước." |

---

## Error Scenarios

**E1 — SalaryRecord creation fails**
- System does not create partial record
- Comp Admin notified; change remains in APPROVED state; retry button available

**E2 — Payroll event publish fails**
- SalaryRecord is created (source of truth)
- Event is retried via Kafka retry mechanism (at-least-once delivery)
- HR Admin can view pending events in Taxable Bridge Dashboard

**E3 — Worker's grade changed between submit and approve**
- System re-validates pay range at approval time
- If now outside new grade's range: Approver sees amber warning; can still approve with note

---

## Notifications

| Event | Recipients | Channel | Template |
|-------|-----------|---------|---------|
| Approval requested | Finance Approver | In-app push + Email | "Thay đổi lương cho [Worker] cần phê duyệt: [change_type], VND [amount]." |
| Approved (auto) | Comp Admin + Worker | In-app | "Thay đổi lương đã được duyệt tự động." |
| Approved | Comp Admin + Worker | In-app + Email | "Lương của [Worker] đã được cập nhật." |
| Rejected | Comp Admin | In-app + Email | "Đề xuất thay đổi lương đã bị từ chối: [comment]." |
| Effective today | Worker | In-app | "Lương mới của bạn có hiệu lực từ hôm nay." |

---

## Edge Cases

1. Retroactive effective date — system blocks by default; HAD can override with justification (creates audit flag).
2. Multiple components changed — each component delta is tracked in SalaryRecord detail.
3. Worker on probation — system shows "Worker is in probation period" advisory; change is not blocked.
4. Currency mismatch — change amount must be in same currency as current SalaryRecord (no FX conversion at this layer).
5. Change during open merit cycle — allowed but system shows: "A merit cycle is currently open. This change will co-exist with cycle results."

---

*COMP-T-002 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
