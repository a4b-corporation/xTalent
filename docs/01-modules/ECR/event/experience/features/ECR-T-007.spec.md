# ECR-T-007: Assessment Delivery
**Type:** Transaction | **Priority:** P2 | **BC:** BC-03
**Permission:** ecr.assessment.manage

## Status: DEFERRED — Pending Vendor Activation

This feature is not active in the current release. The UI renders a placeholder state controlled by a feature flag (`feature.assessment_delivery`). No candidate data is sent to any external assessment system.

---

## Purpose

When active, Assessment Delivery will manage the dispatch of pre-screening or onsite assessment tests to registered candidates via an integrated third-party vendor (vendor TBD). Candidates complete the test externally; results are pulled back and attached to their registration profile.

---

## States (Future)

| State | Description |
|-------|-------------|
| NotConfigured | Feature flag OFF or vendor not activated |
| Configured | Vendor credentials set; assessment tests mapped to tracks |
| Dispatched | Assessment invitations sent to candidates |
| Completed | Results received from vendor |
| Expired | Deadline passed; no result received |

---

## Current UI Behavior (Deferred State)

**Screen:** /events/:id/assessments

**Actor sees:**
- Full-page placeholder card with:
  - Icon: test tube / assessment icon
  - Heading: "Assessment Delivery — Coming Soon"
  - Body: "Online assessment integration is pending vendor activation. This feature will be enabled in a future release. No candidate data has been shared with any external system."
  - Badge: "Feature Unavailable"
  - [Notify me when available] button → subscribes current user to feature activation notification
- No assessment configuration fields, no candidate data, no dispatch buttons

**Actor does:** Views placeholder; optionally subscribes to notification
**System does:** No external calls; no data transmission; feature_flag check logged
**Errors:** None (placeholder state has no error paths)

---

## Integration Hooks (Reserved)

The following API endpoints and events are reserved for future activation:

| Artifact | Reserved Identifier | Notes |
|----------|-------------------|-------|
| API endpoint | `POST /assessments/dispatch` | Will trigger vendor invitation send |
| API endpoint | `GET /assessments/:candidateId/result` | Will pull result from vendor webhook |
| Domain Event | `AssessmentDispatched` | Reserved in events.yaml |
| Domain Event | `AssessmentResultReceived` | Reserved in events.yaml |
| Feature flag | `feature.assessment_delivery` | Set to false in all environments |

---

## Business Rules (Current)

- **BR-ASS-001:** While `feature.assessment_delivery = false`, no assessment data is written or read.
- **BR-ASS-002:** The menu item for Assessments is visible in navigation (to signal future capability) but the screen shows only the placeholder.
- **BR-ASS-003:** No candidate PII is transmitted to any vendor system until this feature is explicitly activated by a system administrator.

---

## Activation Checklist (For Future Reference)

When vendor is confirmed and feature is ready for activation, the following gates must pass:

1. Vendor contract signed and data processing agreement (DPA) executed
2. Vendor API credentials stored in secrets manager
3. Privacy impact assessment completed
4. Feature flag `feature.assessment_delivery` set to true in staging; tested
5. QA sign-off on dispatch + result-receive cycle
6. Feature flag promoted to production

---

## Empty State

Not applicable — placeholder state is always shown while feature is deferred.
