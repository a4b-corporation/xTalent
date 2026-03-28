# COMP-T-003 — Deduction Management

**Type**: Transaction | **Priority**: P0 | **BC**: BC-01 Compensation Management
**Country**: [All countries]
**User Stories**: US-010

---

## Purpose

Deduction Management governs the creation, tracking, and lifecycle of non-statutory recurring deductions from a worker's paycheck — salary advances, internal loans, court-ordered garnishments, and miscellaneous recurring deductions. Each deduction has a defined schedule (amount per period, start and end date), and the system tracks outstanding balance against installments. Statutory deductions (SI/tax) are handled by BC-02 Calculation Engine and BC-09 Tax; this feature covers non-statutory deductions only.

---

## Trigger

Compensation Administrator creates a deduction for a worker, or the system auto-detects a salary advance issued (future integration with finance system).

---

## Actors

| Actor | Role |
|-------|------|
| Compensation Administrator | Creates, updates, archives deductions |
| HR Administrator | Same as Comp Admin |
| Finance Approver | Approves garnishments (mandatory for GARNISHMENT type) |
| Worker | Views own deductions (read-only) |
| System | Tracks installment balance; sends deduction amounts to Taxable Bridge for Payroll |

---

## State Machine

```
DRAFT → ACTIVE → PAUSED → ACTIVE (resume)
                    ↓
                 COMPLETED (balance = 0 or end date reached)
                    ↓
                 ARCHIVED
```

Garnishment type requires additional state:
```
DRAFT → PENDING_APPROVAL → ACTIVE → COMPLETED
                ↓
           REJECTED (Finance Approver rejects)
```

---

## Step-by-Step Flow

### Create Standard Deduction

| Step | Actor | Action | System Response |
|------|-------|--------|----------------|
| 1 | Comp Admin | Opens worker record → Deductions tab | Shows existing deductions list |
| 2 | Comp Admin | Clicks "Add Deduction" | Opens deduction form |
| 3 | Comp Admin | Selects `deduction_type` | LOAN / SALARY_ADVANCE / GARNISHMENT / MISCELLANEOUS |
| 4 | Comp Admin | Enters: total amount, installment amount per period, start date, end date | System calculates: number of installments = total / installment; end date auto-calculated if not entered |
| 5 | System | Validates net pay impact | Shows advisory: "Net pay after this deduction: VND [X]" |
| 6 | System | Warns if net pay < min wage | "Cảnh báo: Lương net sau khấu trừ thấp hơn lương tối thiểu vùng." (Advisory, not block for standard types) |
| 7 | Comp Admin | Attaches document (optional) | PDF/image upload |
| 8 | Comp Admin | Clicks "Save" | For LOAN/ADVANCE/MISC: status → ACTIVE immediately |
| 8b | (GARNISHMENT) | Clicks "Submit for Approval" | Status → PENDING_APPROVAL; Finance Approver notified |
| 9 | System | Creates DeductionRecord | Installment schedule generated |
| 10 | Each payroll period | System | Deduction amount sent to Taxable Bridge → Payroll | Installment marked as PAID; outstanding balance decremented |
| 11 | System | When balance = 0 | Status → COMPLETED; Worker notified |

---

## Fields

| Field | Type | Required | Validation | Label (VI) |
|-------|------|----------|------------|-----------|
| `id` | UUID | Auto | Generated | - |
| `worker_id` | FK | Yes | Active worker with active WorkingRelationship | Nhân viên |
| `deduction_type` | Enum | Yes | LOAN / SALARY_ADVANCE / GARNISHMENT / MISCELLANEOUS | Loại khấu trừ |
| `total_amount` | Decimal | Yes | > 0 | Tổng số tiền |
| `installment_amount` | Decimal | Yes | > 0; <= total_amount | Số tiền mỗi kỳ |
| `currency_code` | String(3) | Auto | From worker's LegalEntity | Tiền tệ |
| `start_date` | Date | Yes | Today or future | Ngày bắt đầu |
| `end_date` | Date | Calculated | = start_date + (total/installment) periods | Ngày kết thúc (dự kiến) |
| `outstanding_balance` | Decimal | Auto | Decremented each period | Số dư còn lại |
| `status` | Enum | Auto | DRAFT / ACTIVE / PAUSED / PENDING_APPROVAL / COMPLETED / ARCHIVED | Trạng thái |
| `reason` | Text | Yes | Max 500 chars | Lý do |
| `reference_number` | String(50) | No | Court order number (GARNISHMENT) | Số tham chiếu |
| `document_attachment` | File | Conditional | Required for GARNISHMENT | Tài liệu đính kèm |
| `approved_by` | FK | Conditional | Required for GARNISHMENT | Người phê duyệt |
| `created_by` | FK | Auto | Current user | - |
| `created_at` | Timestamp | Auto | System | - |

---

## Validations

| Rule | When | Error Message |
|------|------|--------------|
| Installment <= total | On entry | "Số tiền mỗi kỳ không thể lớn hơn tổng số tiền." |
| Net pay advisory | On save | Advisory: "Lương net sau khấu trừ: VND [X]." |
| Min wage net pay | On save | Warning (not block): "Lương net dưới mức tối thiểu vùng sau khấu trừ." |
| Garnishment requires approval | On type select | System routes to Finance Approver automatically |
| Worker active | On create | Must have active WorkingRelationship | "Không thể tạo khấu trừ cho nhân viên không còn làm việc." |

---

## Error Scenarios

**E1 — Worker leaves before deduction completes**
- System auto-pauses deduction on Working Relationship termination
- HR Admin notified: "Deduction for [Worker] paused due to employment end."
- Final settlement handled in CO module's offboarding process

**E2 — Payroll rejects deduction amount**
- System logs error; marks installment as FAILED
- HR Admin alerted; manual override option available

**E3 — Garnishment rejected by Finance Approver**
- Status → REJECTED; Comp Admin notified with comment
- Can re-submit with revised amount or documentation

---

## Notifications

| Event | Recipients | Channel | Template |
|-------|-----------|---------|---------|
| Garnishment pending approval | Finance Approver | In-app + Email | "Yêu cầu phê duyệt khấu trừ cho [Worker]." |
| Deduction approved | Comp Admin + Worker | In-app | "Khấu trừ đã được duyệt. Bắt đầu từ [start_date]." |
| Deduction activated | Worker | In-app | "Một khoản khấu trừ đã được ghi nhận cho bạn. Xem chi tiết tại Thông tin Lương." |
| Deduction completed | Worker + Comp Admin | In-app | "Khấu trừ [type] đã hoàn tất." |
| Worker leaving with balance | HR Admin | In-app | "[Worker] có khấu trừ chưa hoàn tất: VND [balance]." |

---

## Edge Cases

1. Multiple concurrent deductions — allowed; system stacks deductions; net pay advisory shows total impact.
2. Deduction amount changed mid-schedule — creates a new installment schedule from the change date; history preserved.
3. Deduction paused (e.g., parental leave) — Comp Admin can manually pause; end date extended proportionally.
4. Overpayment correction — uses MISCELLANEOUS type with single installment.

---

*COMP-T-003 Spec — Total Rewards / xTalent HCM*
*2026-03-26*
