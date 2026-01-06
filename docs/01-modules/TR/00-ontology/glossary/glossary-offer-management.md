# Offer Management - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Offer Management

---

## Overview

Offer Management handles total rewards offer packages for new hires, promotions, and retention. This sub-module provides:

- **Offer Templates**: Reusable offer structures with approval workflows
- **Offer Packages**: Specific offers for candidates with total value calculation
- **Offer Tracking**: Complete lifecycle from creation to acceptance/rejection
- **E-signature**: Digital signature capture for offer letters
- **Counter-offers**: Negotiation workflow support

---

## Entities

### 1. OfferTemplate

**Definition**: Reusable template defining standard offer structure for different scenarios.

**Purpose**: Standardizes offers across organization with version control.

**Attributes**: `code`, `name`, `version_no`, `offer_type` (NEW_HIRE, PROMOTION, RETENTION, COUNTER_OFFER, INTERNAL_TRANSFER), `components_json`, `approval_workflow_json`

**Components JSON Structure**:
```yaml
components_json:
  fixed_compensation:
    base_salary: {amount: null, currency: "VND", frequency: "MONTHLY"}
    allowances: [{component: "LUNCH", amount: 730000}]
  variable_compensation:
    sti_target_pct: 0.15
    lti_eligible: true
  benefits:
    medical: "PREMIUM_PLAN"
  perks:
    signing_bonus: null
```

---

### 2. OfferTemplateEvent

**Definition**: Audit trail for template changes (CREATED, UPDATED, ACTIVATED, DEACTIVATED, CLONED).

**Purpose**: Tracks all modifications to offer templates for compliance.

---

### 3. OfferPackage

**Definition**: Specific offer package for a candidate instantiating template with actual values.

**Purpose**: Creates personalized offers with total compensation calculation.

**Key Attributes**:
- `worker_id`: FK to Core.Worker (candidate)
- `total_fixed_cash`: Base + allowances
- `total_variable`: STI + LTI targets
- `total_benefits`: Estimated annual benefits value
- `total_value`: Total compensation package
- `status`: DRAFT, PENDING, APPROVED, SENT, VIEWED, ACCEPTED, REJECTED, EXPIRED, WITHDRAWN

**Business Rules**:
1. total_cash = total_fixed_cash + total_variable
2. total_value = total_cash + total_benefits
3. Cannot modify ACCEPTED or REJECTED offer
4. Expires if no response by expires_at
5. VIEWED status set when candidate opens offer letter

**Example**:
```yaml
OfferPackage:
  worker_id: "CANDIDATE_UUID"
  offer_type: NEW_HIRE
  position_title: "Senior Software Engineer"
  total_fixed_cash: 65000000  # VND/month
  total_variable: 15000000    # Annual target
  total_benefits: 7800000     # Annual
  total_value: 87800000       # Annual total
  status: SENT
  response_deadline: "2025-04-15"
```

---

### 4. OfferEvent

**Definition**: Offer package event tracking for complete audit trail.

**Purpose**: Records all offer lifecycle events (CREATED, SENT, VIEWED, REMINDER, ACCEPTED, REJECTED, EXPIRED, WITHDRAWN, MODIFIED, APPROVED).

**Event Details JSON**:
```yaml
event_details_json:
  ip_address: "192.168.1.1"
  user_agent: "Mozilla/5.0..."
  location: "Ho Chi Minh City, VN"
  device: "Desktop"
  notes: "Candidate requested higher base salary"
```

---

### 5. OfferAcceptance

**Definition**: Offer acceptance/rejection record with e-signature capture.

**Purpose**: Captures candidate decision and signature for legal compliance.

**Attributes**:
- `accepted`: boolean (true = accepted, false = rejected)
- `rejection_reason`: Why candidate rejected
- `rejection_category`: COMPENSATION, LOCATION, ROLE, COMPANY_FIT, COMPETING_OFFER, PERSONAL_REASONS, OTHER
- `signed_doc_url`: URL to signed offer letter
- `signature_ip`, `signature_timestamp`: E-signature metadata
- `counter_offer_json`: Candidate counter-offer details

**Business Rules**:
1. accepted and rejected_at are mutually exclusive
2. signed_doc_url required if accepted = true
3. rejection_reason required if accepted = false
4. Counter-offer triggers negotiation workflow

---

## Summary

**5 entities** managing offer lifecycle:
1. OfferTemplate - Reusable templates
2. OfferTemplateEvent - Template audit trail
3. OfferPackage - Specific offers
4. OfferEvent - Offer lifecycle tracking
5. OfferAcceptance - Acceptance/rejection capture

**Key Features**:
- ✅ Template versioning
- ✅ Total compensation calculation
- ✅ Approval workflows
- ✅ E-signature support
- ✅ Counter-offer negotiation
- ✅ Complete audit trail

---

**Document Status**: ✅ Complete  
**Coverage**: 5 of 5 entities  
**Last Updated**: 2025-12-04
