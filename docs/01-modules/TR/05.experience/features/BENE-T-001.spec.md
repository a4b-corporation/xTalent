# BENE-T-001 — Benefits Open Enrollment

**Type**: Transaction | **Priority**: P0 | **BC**: BC-04 Benefits Administration
**Country**: [All countries]

---

## Purpose

Open Enrollment allows Workers to select, change, or waive benefit coverage during a defined annual window. Workers compare plan options, select coverage tiers, add dependents, and confirm elections. HR Admin monitors enrollment progress and finalizes when the window closes. Finalized enrollments create recurring DeductionRecords and sync to carriers via EDI 834.

---

## Trigger

HR Admin opens an enrollment window on a BenefitPlan (sets enrollment_window_start/end).

---

## Actors

| Actor | Role |
|-------|------|
| Worker | Selects/changes/waives benefit elections; adds dependents |
| HR Admin | Monitors enrollment progress; finalizes enrollment |
| System | Validates eligibility; creates DeductionRecords; syncs to carrier |
| Benefits Carrier | Receives EDI 834 file (external) |

---

## State Machine

```
BenefitEnrollment:
PENDING → ACTIVE → TERMINATED
        └→ CANCELLED (window closed without finalizing)
        └→ DECLINED (failed eligibility on finalize)

DependentVerification:
PENDING_VERIFICATION → VERIFIED
                    └→ REJECTED → (dependent removed from coverage)
```

---

## Worker Flow: Enrollment Portal

### Step 1 — View Available Plans
- Worker sees cards for each plan they are eligible for
- Each card shows:
  - Plan name, carrier logo
  - Coverage type (Health / Dental / Life)
  - Coverage tiers available + monthly employee cost per tier
  - "What's covered" expandable section
  - Current enrollment status (if renewing)
- Filter: by plan type

### Step 2 — Select Coverage
- Click "Enroll" on plan card
- Select coverage tier: Employee Only / + Spouse / + Children / Family
- System shows:
  - Employee monthly cost: ₫XXX,XXX
  - Employer contribution: ₫XXX,XXX (for transparency)
  - Annual total cost
- "Compare Plans" side-by-side view available

### Step 3 — Add Dependents (if FAMILY / PLUS_SPOUSE / PLUS_CHILDREN)
- Form: Dependent Name, Relationship, Date of Birth, Document type
- Upload: birth certificate / marriage certificate
- Multiple dependents supported
- Verification note: "Document will be verified within 5 business days"

### Step 4 — Enrollment Summary
- Shows all elections (current + new)
- Payroll impact: monthly deduction increase/decrease
- Confirm & Submit button

---

## HR Admin: Enrollment Monitoring Dashboard

| Metric | Display |
|--------|---------|
| Total eligible Workers | Count |
| Enrolled | Count + % progress bar |
| Pending (not yet acted) | Count + reminder action |
| Waived | Count |
| Enrollment window | Open/Closed status + days remaining |

**Actions**:
- Send reminder to pending Workers
- View enrollment list with filter/export
- Finalize enrollment (close window)

---

## Finalization (HR Admin)

1. HR Admin clicks "Finalize Enrollment" after window close date
2. System runs final eligibility check on all PENDING enrollments
3. Failed eligibility → DECLINED (with reason)
4. For each ACTIVE enrollment:
   - Calculate `employee_monthly_deduction = monthly_premium[tier] × employee_pct`
   - Create `DeductionRecord` (type=BENEFIT_PREMIUM, frequency=MONTHLY, priority=4)
   - Emit `BenefitEnrolled` event
5. If `is_taxable_benefit_in_kind = true`:
   - Create `TaxableItem` in BC-08 for employer contribution above threshold
6. Generate EDI 834 transaction → submit to carrier
7. Confirmation screen: "Enrollment finalized for 143 workers"

---

## Life Event Changes (Outside Open Enrollment)

Worker can change benefits within 30 days of:
- Marriage (upload marriage certificate)
- Birth/adoption (upload birth certificate)
- Loss of other coverage (upload proof)
- Divorce

Flow: Worker submits LifeEvent request → HR Admin approves event → enrollment change window opens for 30 days → same enrollment flow as above.

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| Enrollment window must be OPEN | On Worker submit | "Enrollment window is closed" |
| Worker must be eligible for plan | On Worker submit | "You are not eligible for this plan (requires [X] months of service)" |
| FAMILY tier requires dependent added | On finalize | "Family coverage requires at least 1 dependent. Add dependents or change tier." |
| Dependent verification within 30 days | On finalize | Warning — coverage downgraded if not verified |
| One enrollment per plan type per Worker | On Worker submit | "You already have active [HEALTH] coverage. This will replace it." |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| Enrollment window opens | Eligible Workers | In-app + Email |
| Enrollment window closing soon (3 days) | Pending Workers | Push notification + Email |
| Enrollment confirmed | Worker | In-app + Email |
| Dependent verification required | Worker | Email with deadline |
| Dependent verification rejected | Worker | In-app + Email |
| Carrier sync successful | HR Admin | In-app |
| Carrier sync failed | HR Admin | In-app alert + Email |

---

*BENE-T-001 — Benefits Open Enrollment*
*2026-03-27*
