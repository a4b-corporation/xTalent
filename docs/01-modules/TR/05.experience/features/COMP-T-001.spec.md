# COMP-T-001 — Merit Review Cycle Management

**Type**: Transaction | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]
**User Stories**: US-002, US-003, US-004

---

## Purpose

Merit Review Cycle is the structured annual (or periodic) process by which an organization reviews and adjusts base salaries for eligible workers. The cycle provides a governed, multi-level workflow: Compensation Admin defines parameters and opens the cycle; People Managers propose salary changes for their team within budget guardrails; approvers (Director / Finance) review and approve; Compensation Admin closes and publishes. The result is a set of new SalaryRecord versions (SCD Type 2) with a future effective date, and downstream events triggering payroll bridge updates.

**Business Goal**: Reduce merit review cycle duration from 6–8 weeks to ≤ 2 weeks (OBJ-01).

---

## Trigger

Compensation Administrator creates and opens a new CompensationCycle record.

---

## Actors

| Actor | Role in Flow |
|-------|-------------|
| Compensation Administrator | Creates cycle configuration; opens/closes cycle; publishes results |
| People Manager | Proposes salary changes for direct/indirect reports |
| Finance Approver / Director | Approves proposals (especially above threshold %) |
| Worker | Passive — notified of outcome |
| System | Validates min wage; calculates compa-ratio; routes approvals; creates SalaryRecords |

---

## State Machine

```
DRAFT → OPEN → UNDER_REVIEW → APPROVED → CLOSED → PUBLISHED
  ↑                               |
  └──── (reopen if needed) ───────┘

DRAFT:        Cycle configured, not yet visible to Managers
OPEN:         Managers can submit proposals; submission window active
UNDER_REVIEW: All proposals submitted; now in approval workflow
APPROVED:     All proposals approved by Finance/Director
CLOSED:       Cycle closed by Comp Admin; no more changes
PUBLISHED:    SalaryRecords created; workers notified; payroll events fired
```

CompensationProposal states (per individual):
```
DRAFT → SUBMITTED → APPROVED → REJECTED → REVISION_REQUESTED
```

---

## Step-by-Step Flow

### Phase 1 — Cycle Setup (Compensation Admin)

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | Comp Admin | Clicks "Create New Cycle" | Opens cycle wizard |
| 2 | Comp Admin | Step 1: Eligibility — selects org units, grades, employment types | System shows estimated eligible worker count |
| 3 | Comp Admin | Step 2: Budget — enters budget % of eligible payroll | System shows estimated budget amount in currency |
| 4 | Comp Admin | Step 3: Approval routing — sets approval threshold % (e.g., >10% requires VP) | System previews routing tree |
| 5 | Comp Admin | Step 4: Timeline — sets submission deadline and target effective date | System validates dates are in the future |
| 6 | Comp Admin | Clicks "Save as Draft" | Cycle created in DRAFT state |
| 7 | Comp Admin | Reviews; clicks "Open Cycle" | Cycle state → OPEN; Managers notified |

### Phase 2 — Proposal Submission (People Manager)

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 8 | People Manager | Receives notification; opens "Merit Proposals" | Shows team worker table: current salary, compa-ratio, status |
| 9 | People Manager | Clicks on a worker | Opens Proposal Form in side panel |
| 10 | People Manager | Views: worker card, current salary, pay range visualization | Band bar shows: min / current / mid / max; compa-ratio label |
| 11 | People Manager | Enters proposed salary | System live-calculates: new compa-ratio, % change, budget impact delta |
| 12 | People Manager | System checks min wage | If below → red error block. Cannot submit. |
| 13 | People Manager | System checks pay range | If outside range → amber warning. Justification required. |
| 14 | People Manager | Selects change type | MERIT / PROMOTION / EQUITY_ADJUSTMENT |
| 15 | People Manager | Enters justification text | Required if >threshold % or outside range |
| 16 | People Manager | Clicks "Submit Proposal" | Proposal status → SUBMITTED; budget gauge updates |
| 17 | People Manager | Repeats steps 9–16 for all team members | — |
| 18 | System | Detects all proposals submitted (or deadline reached) | Cycle state → UNDER_REVIEW; approvers notified |

### Phase 3 — Approval (Finance Approver / Director)

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 19 | Approver | Receives in-app notification + email | — |
| 20 | Approver | Opens "Pending Approvals" | List of proposals with budget impact summary |
| 21 | Approver | Reviews individual proposal | Sees: proposed amount, % change, compa-ratio, justification, pay range position |
| 22 | Approver | Clicks "Approve" | Proposal status → APPROVED; budget gauge updates real-time |
| 23 | Approver | Clicks "Reject" + adds comment | Proposal status → REJECTED; Manager notified |
| 24 | Approver | Clicks "Request Revision" | Proposal status → REVISION_REQUESTED; Manager can re-submit |

### Phase 4 — Close & Publish (Compensation Admin)

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 25 | Comp Admin | Sees "100% proposals approved" | Cycle ready to publish |
| 26 | Comp Admin | Clicks "Close Cycle" | Confirmation modal: summary stats (N workers, total budget used, avg % change) |
| 27 | Comp Admin | Confirms | Cycle state → CLOSED |
| 28 | Comp Admin | Clicks "Publish Results" | System creates SalaryRecord (SCD Type 2) for each APPROVED proposal |
| 29 | System | Creates SalaryRecord | `tr.salary-changed.v1` Kafka event published |
| 30 | System | Notifies workers | In-app + email: "Your salary has been updated. Effective [date]." |
| 31 | Comp Admin | Downloads cycle export | CSV: worker, old salary, new salary, % change, effective date |

---

## Validations

| Rule | When | Error Message |
|------|------|--------------|
| Min wage hard block | On proposal submit | "Đề xuất lương VND X thấp hơn lương tối thiểu vùng [Zone]: VND Y. Không thể nộp đề xuất." |
| Budget soft warning | On each proposal entry | "Đề xuất này đang dùng X% ngân sách. Vượt quá ngân sách chung Y%." (warning, not block) |
| Outside pay range | On proposal entry | "Lương đề xuất nằm ngoài khung lương cấp bậc. Cần nhập lý do." (warning, justification required) |
| Threshold approval routing | On proposal submit | System routes to VP approver if % > threshold configured in cycle |
| Effective date in future | On cycle publish | Salary effective date must be today or future; system prevents backdating without override |
| Duplicate proposal | On proposal submit | "Worker này đã có đề xuất đang chờ xử lý trong chu kỳ này." |

---

## Error Scenarios

**E1 — Worker missing salary record**
- System shows "Không có bản ghi lương" in worker table row
- Manager cannot submit proposal; must notify Comp Admin to create salary record first

**E2 — Budget exceeded at cycle close**
- Comp Admin receives warning: "Tổng đề xuất đã được phê duyệt vượt X% so với ngân sách. Tiếp tục xuất bản?"
- Admin must confirm or go back and reject some proposals

**E3 — SalaryRecord creation failure at publish**
- System rolls back publish; no partial SalaryRecords created
- Comp Admin notified with error details; retry button available

**E4 — Manager misses deadline**
- After deadline, manager proposals are auto-submitted as DRAFT (not counted as submitted)
- Comp Admin can: extend deadline, manually submit remaining drafts, or proceed without them

**E5 — Proposal approved but min wage changed before effective date**
- System checks min wage again at publish time
- If violation detected: blocks publish; alerts Comp Admin with list of affected proposals

---

## Notifications

| Event | Recipients | Channel | Template |
|-------|-----------|---------|---------|
| Cycle opened | All People Managers in scope | Email + In-app | "Chu kỳ điều chỉnh lương [name] đã mở. Hạn nộp: [date]." |
| 3 days before deadline | Managers with incomplete proposals | In-app push | "Còn 3 ngày: [N] đề xuất chưa hoàn thành." |
| Proposal needs revision | People Manager | In-app + Email | "Đề xuất cho [Worker name] cần được điều chỉnh: [comment]." |
| All proposals submitted | Comp Admin + Approvers | In-app | "Tất cả đề xuất đã được nộp. Sẵn sàng phê duyệt." |
| Approval required | Finance Approver | In-app push + Email | "[N] đề xuất lương cần phê duyệt." |
| Salary updated | Worker | In-app + Email | "Lương của bạn đã được cập nhật từ ngày [effective_date]." |
| Cycle published | Comp Admin | In-app | "Chu kỳ đã xuất bản. [N] bản ghi lương được tạo." |

---

## Edge Cases

1. Manager has zero eligible workers in scope → Cycle shows "No eligible workers" for that manager; no action required.
2. Worker transferred between teams mid-cycle → Proposal ownership follows the new manager's team (configurable: original manager or new manager).
3. Cycle overlapping with another active cycle for same LegalEntity → System blocks creation; only one active cycle per LE at a time.
4. Comp Admin manually overrides a rejected proposal → Requires HAD role + audit justification.
5. Worker is on leave when salary effective date arrives → Salary record is created regardless; leave is managed in CO module separately.
6. Promoted worker (grade change) mid-cycle → Requires a separate Salary Change (COMP-T-002), not via merit cycle.

---

*COMP-T-001 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
