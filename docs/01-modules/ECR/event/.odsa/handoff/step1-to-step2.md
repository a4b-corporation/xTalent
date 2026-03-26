# Handoff: Step 1 → Step 2 (Reality / BRD)
*ECR Module | 2026-03-25*

---

## Input for BRD

The following artifacts from Step 1 are the authoritative inputs for the Business Requirements Document:

| Artifact | Location | Purpose |
|---|---|---|
| Requirements Document | `step1-prereality/requirements.md` | 44 functional requirements, 12 NFRs, 10 hypotheses, 8 open questions |
| Step 1 Summary | `.odsa/context/step1-summary.md` | Compressed context, key decisions, what Step 2 needs |
| This Handoff | `.odsa/handoff/step1-to-step2.md` | Formal contract between Step 1 and Step 2 |

The BRD author must read `requirements.md` in full before beginning. The requirements document is structured, unambiguous (score 0.15/1.0), and ready for formalization.

---

## Recommended Scope for Step 2

### In Scope (must be formalized in BRD)

All 44 functional requirements across:
- FR-01 to FR-06: Event Lifecycle Management
- FR-07 to FR-10: Candidate Capture & Registration
- FR-11 to FR-13: Candidate Identity & Deduplication
- FR-14 to FR-18: Assessment & Evaluation *(pending OQ-01 resolution)*
- FR-19 to FR-22: Scheduling & Capacity Management
- FR-23 to FR-26: Onsite Operations & Kiosk
- FR-27 to FR-31: Panel Interview Management
- FR-32 to FR-35: Communication & Notifications
- FR-36 to FR-39: Bulk Operations
- FR-40 to FR-44: Analytics & Reporting

All 12 non-functional requirements (NFR-01 to NFR-12).

### Deferred Pending Decision (do not finalize in BRD until resolved)

- FR-14 to FR-18 (Assessment) — blocked on OQ-01 (build vs. integrate decision)
- FR-25 (Face Capture) — blocked on OQ-06 (legal review of Decree 13/2023/ND-CP)
- FR-07 / FR-35 (SMS) — blocked on OQ-02 (SMS gateway confirmation)
- FR-26 (Badge Printing) — blocked on OQ-03 (hardware standardization)

### Out of Scope for ECR (document as explicit exclusions)

- Performance management / 360-degree feedback (separate xTalent module)
- Offer management and onboarding (separate xTalent module)
- Payroll integration (out of Talent Acquisition domain)
- Video interviewing (OQ-04 expansion; may be a future phase)

---

## Key Business Rules to Formalize

The following business rules from Step 1 are critical and must be stated explicitly in the BRD with stakeholder sign-off:

**BR-01: SBD Decoupling**
SBD assignment must be decoupled from email delivery. An SBD is valid for operational use (check-in, queue entry) regardless of whether the candidate has received or opened their confirmation email.

**BR-02: Duplicate Resolution Is Human**
The system must never automatically merge or reject a candidate record based on duplicate detection alone. Every potential duplicate must be surfaced to a TA Coordinator for an explicit Merge / Keep Both / Reject New decision. Automated action is prohibited.

**BR-03: Bulk Advancement Exclusions**
Candidates with unresolved duplicate flags must be excluded from all bulk advancement operations. They must appear in a Blocked Items report after every bulk operation run.

**BR-04: Score Finality**
Interview score submissions are final once submitted. Edits require TA Coordinator approval and must generate an audit log entry. This protects interview integrity and prevents score-washing after candidate outcome decisions.

**BR-05: Manager Link Expiry**
All Hiring Manager Session Digest links must expire no later than 24 hours after the event day they cover. This is a non-negotiable data governance control. The expiry must be enforced server-side, not only in the UI.

**BR-06: Event Structural Immutability In Progress**
Once an event transitions to In Progress state, structural changes (track additions, capacity reductions beyond configured threshold) are blocked. Only operational parameters (room assignment, shift capacity within override limit) may be changed.

**BR-07: Assessment Delivery Gate**
Assessments may only be delivered to candidates in Confirmed or Checked-In status within the relevant phase. Candidates in Pending (unresolved duplicate) or Withdrawn status must not receive assessment invitations.

**BR-08: Offline Data Integrity**
All offline-captured kiosk data (registrations, check-ins, face images) must be treated as provisional until sync is confirmed. Sync is atomic per record. A record that fails sync validation must be placed in a manual review queue, never silently discarded.

---

## Stakeholders to Involve

### Required for BRD Sign-Off

| Stakeholder | Role | Input Required |
|---|---|---|
| TA Lead / Talent Acquisition Director | Business owner | Validate event creation workflow, track structure, SBD format rules |
| Hiring Manager Representative (2–3 HMs) | End user | Validate Session Digest, digital interview kit, queue management UX |
| IT / Infrastructure Lead | Technical authority | Confirm hosting options, data residency, SMS gateway, offline architecture |
| Legal / Compliance Officer | Regulatory | Resolve OQ-06 (face capture, Decree 13/2023/ND-CP), manager link expiry policy |
| xTalent Platform Architect | Integration authority | Confirm Job Request integration contract, candidate profile linkage, API design |

### Recommended for Workshops

| Stakeholder | Workshop Topic |
|---|---|
| Onsite Operations Staff (2–3 staff) | Kiosk UX, offline mode, badge printing workflow |
| HR Analytics Lead | Dynamic report builder requirements, audit log retention |
| Representative Enterprise Customer (VNG or MWG) | Validate Event → Track → Request model against real event structure |

---

## Risks & Assumptions

### Risks

**Risk-01: Assessment Scope Creep (High)**
If OQ-01 resolves as "build internally," the assessment subsystem (FR-14 to FR-18) represents a substantial engineering workload that could compress delivery timeline for core event management features. Mitigation: resolve OQ-01 early in Step 2 and, if building, scope assessment as a separate delivery increment.

**Risk-02: Offline Architecture Complexity (Medium-High)**
Offline-first kiosk with conflict-safe sync is architecturally non-trivial. Underestimating this risk is the single most common cause of kiosk system failures in field deployments. Mitigation: prototype offline sync against a realistic venue scenario (500 candidates, intermittent connectivity) during technical design.

**Risk-03: Legal Blocking of Face Capture (Medium)**
If Decree 13/2023/ND-CP review concludes that face capture requires additional consent infrastructure or data processing agreements beyond ECR's planned scope, FR-25 may be deferred or redesigned. Mitigation: initiate legal review in parallel with BRD authoring; do not build face capture until legal sign-off is received.

**Risk-04: SBD Format Governance (Low-Medium)**
Without agreed format rules for SBD (prefix logic, numeric range, collision handling), different enterprise customers will implement SBDs inconsistently, creating support problems. Mitigation: define SBD format as a configurable template within event settings, with sensible defaults, and document the configuration options in the BRD.

**Risk-05: Integration Dependency on xTalent Job Request Module (Medium)**
The Track → Job Request linkage (FR-02) creates a hard dependency on the xTalent Job Request module API. If that module's API is not stable or does not expose the required fields, Track configuration will be blocked. Mitigation: confirm integration contract and field availability with xTalent platform architect before BRD is finalized.

### Assumptions

**A-01:** The xTalent Job Request module is in production and exposes a stable API that allows ECR to read and link job requests by requisition ID.

**A-02:** xTalent's existing email integration layer can handle bulk sends of up to 500 emails per minute as specified in FR-32.

**A-03:** Enterprise customers deploying ECR onsite will provision dedicated tablets or fixed-kiosk devices for check-in, not shared personal devices. This assumption affects badge printer pairing and offline storage sizing.

**A-04:** The candidate-facing registration portal will be accessible via the public internet (not behind enterprise VPN). Walk-in candidates must be able to register on their own mobile devices at the venue.

**A-05:** xTalent's RBAC system is extensible to support per-event role assignments as specified in NFR-11. This has not been confirmed at the platform level and must be validated in Step 2.

**A-06:** Vietnamese language is the primary UI language for all candidate-facing interfaces. English is a secondary language for multinational customers. Bidirectional text support is not required.
