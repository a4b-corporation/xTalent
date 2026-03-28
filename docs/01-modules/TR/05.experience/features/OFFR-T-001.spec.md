# OFFR-T-001 — Offer Creation & Approval

**Type**: Transaction | **Priority**: P0 | **BC**: BC-06 Offer Management
**Country**: [All countries]

---

## Purpose

Enables Hiring Managers to create compensation offers for candidates — selecting a template, entering salary (with real-time min wage validation and pay range guidance), routing through an approval workflow, and delivering a digital offer letter for candidate e-signature. Integrates with multi-provider e-signature (DocuSign, HelloSign) via an abstraction layer. Accepted offers feed into the onboarding flow.

---

## Trigger

Hiring Manager clicks "Create Offer" for a candidate who has passed final interview stage.

---

## Actors

| Actor | Role |
|-------|------|
| Hiring Manager | Creates offer; selects template; enters salary |
| Compensation Admin / HR Admin | Reviews salary vs pay range; optional co-approver |
| Director / VP | Approves offer above threshold |
| Candidate (external) | Receives, reviews, and e-signs offer letter |
| System | Min wage validation; approval routing; e-signature delivery; expiry management |

---

## State Machine

```
OfferRecord:
DRAFT → PENDING_APPROVAL → APPROVED → SENT → SIGNED → ACCEPTED → CONVERTED_TO_HIRE
                        └→ REJECTED (back to Hiring Manager)
                                                    └→ DECLINED (by Candidate)
                                                    └→ COUNTER_REQUESTED (by Candidate)
                                                    └→ EXPIRED (time out)
```

---

## Step-by-Step Flow

### Step 1 — Create Offer (Hiring Manager)
1. Navigate to: Offer Management → New Offer
2. Search and select Candidate (from ATS / CO pre-hire record)
3. Select template from `OfferTemplate` library
4. Fill in offer details:
   - **Position** (FK to Job/Position from CO module)
   - **Start Date**
   - **LegalEntity** + **BusinessUnit** + **WorkplaceLocation**
   - **Grade** (auto-suggest from Position; editable)
   - **Salary**: gross monthly amount + currency
5. System shows:
   - Pay Range for Grade + Location (min / mid / max)
   - CompaRatio preview (proposed / midpoint)
   - Min Wage for workplace zone (real-time validation via BC-02)
   - ⚠️ Warning if salary < min wage (hard block)
   - ℹ️ Advisory if salary outside pay range (soft warning)
6. Additional components: allowances, sign-on bonus, benefits package selection
7. Generate preview PDF (from template + entered values)
8. Submit for approval

### Step 2 — Approval Routing
System routes based on offer_amount vs pay_range + configurable thresholds:

| Scenario | Approver |
|----------|---------|
| Within pay range | Compensation Admin (or auto-approve) |
| Above midpoint | HR Admin |
| Above max of pay range | Director |
| Sign-on bonus included | Finance Approver (additional) |

### Step 3 — Approval (Approver)
- Approver sees: candidate info, offer summary, pay range visualization, CompaRatio
- Actions: Approve / Reject with comment / Request revision
- On Approve: OfferRecord → APPROVED
- System generates final offer letter PDF (merged from template + data)

### Step 4 — Candidate Delivery
1. System selects e-signature provider (DocuSign / HelloSign / configured provider)
2. Sends offer letter to candidate email with e-sign link
3. `OfferSent` event emitted
4. Expiry timer starts (configurable, default 7 days)

### Step 5 — Candidate Response
- **Signs**: OfferRecord → SIGNED → ACCEPTED; `OfferAccepted` event emitted
- **Declines**: OfferRecord → DECLINED; HR Admin notified
- **Counter-offer**: Candidate submits counter → HR Admin reviews → revised offer flow
- **No response by expiry**: OfferRecord → EXPIRED; HR Admin notified

### Step 6 — Conversion to Hire
On ACCEPTED:
- `OfferAccepted` event → HR Admin/CO module creates WorkingRelationship
- Salary from offer → first SalaryRecord in BC-01
- Benefits election window opened (linked to selected benefits package)

---

## Offer Template Management

HR Admin creates templates with merge fields:
- `{{candidate_name}}`, `{{position_title}}`, `{{start_date}}`, `{{salary_amount}}`, `{{legal_entity_name}}`, etc.
- Templates scoped per country (letter format varies)
- Preview with sample data

---

## E-Signature Provider Abstraction

- Admin configures preferred provider per LegalEntity
- Provider config: API credentials, webhook endpoint
- System normalizes callbacks: `SignatureCompleted` → internal `OfferSigned` event
- Dual confirm: webhook primary + 15-min polling fallback
- If provider unavailable: fallback to next configured provider

---

## Validation Rules

| Rule | When | Error |
|------|------|-------|
| `salary >= MinWage(workplace_zone)` | On submit/approve | "Salary below minimum wage for Zone [X]: [amount]" |
| Position must be active | On create | "Position is not active" |
| Candidate must exist in system | On create | "Candidate not found" |
| Expiry date must be future | On create | "Offer expiry must be in the future" |
| Cannot create duplicate open offers for same candidate | On create | "Candidate already has open offer [ID]" |

---

## Notifications

| Event | Recipients | Channel |
|-------|-----------|---------|
| Offer submitted for approval | Approver(s) | Email + In-app |
| Offer rejected | Hiring Manager | In-app |
| Offer sent to candidate | Hiring Manager, HR Admin | In-app |
| Offer signed | Hiring Manager, HR Admin | Email + In-app |
| Offer declined | Hiring Manager, HR Admin | Email + In-app |
| Counter-offer requested | Hiring Manager, HR Admin | Email + In-app |
| Offer expiring in 24h | Hiring Manager | Push + Email |
| Offer expired | Hiring Manager, HR Admin | In-app |

---

*OFFR-T-001 — Offer Creation & Approval*
*2026-03-27*
