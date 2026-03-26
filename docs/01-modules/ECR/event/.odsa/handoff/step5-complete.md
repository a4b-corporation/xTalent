# ODSA Pipeline Complete: ECR Module
*xTalent HCM Solution | 2026-03-26*

## Pipeline Summary

| Step | Status | Key Output |
|------|--------|-----------|
| Step 1: Pre-Reality | Complete | requirements.md (44 FRs) |
| Step 2: Reality | Complete | BRD, 39 user stories, event storming |
| Step 3: Domain Architecture | Complete | 8 BCs, 31 artifacts |
| Step 4: Solution Architecture | Complete | 6 architecture files (context maps, DB, APIs, events) |
| Step 5: Product Experience | Complete | feature-catalog, 4 IA files, 27 feature specs |

## All Artifacts Index

### Step 1: Pre-Reality
- `step1-prereality/requirements.md`

### Step 2: Reality
- `reality/brd.md`
- `reality/user-stories.md`
- `reality/event-storming.md`

### Step 3: Domain Architecture
- `domain/bounded-contexts.md`
- `domain/{context}/glossary.md` (per BC)
- `domain/{context}/model.linkml.yaml` (per BC)
- `domain/{context}/flows/{usecase}.flow.md` (per use case)

### Step 4: Solution Architecture
- `architecture/context-map-l1.md`
- `architecture/context-map-l2.md`
- `architecture/db.dbml`
- `architecture/api-usecase.openapi.yaml`
- `architecture/api-domain.openapi.yaml`
- `architecture/events.yaml`

### Step 5: Product Experience
- `experience/feature-catalog.md`
- `experience/ia/menu-map.md`
- `experience/ia/interaction-map.md`
- `experience/ia/nav-flows.md`
- `experience/ia/permission-matrix.md`
- `experience/features/ECR-M-001.spec.md` — Event Configuration (Masterdata, P1)
- `experience/features/ECR-M-002.spec.md` — Track Configuration (Masterdata, P1)
- `experience/features/ECR-M-003.spec.md` — SBD Management (Masterdata, P1)
- `experience/features/ECR-M-004.spec.md` — Schedule Matrix Builder (Masterdata, P1)
- `experience/features/ECR-M-005.spec.md` — Panel and Interviewer Assignment (Masterdata, P1)
- `experience/features/ECR-M-006.spec.md` — Email Template Management (Masterdata, P1)
- `experience/features/ECR-T-001.spec.md` — Event Lifecycle Management (Transaction, P1)
- `experience/features/ECR-T-002.spec.md` — Registration Form Builder (Transaction, P1)
- `experience/features/ECR-T-003.spec.md` — Event Cloning (Transaction, P2)
- `experience/features/ECR-T-004.spec.md` — Candidate Self-Registration Portal (Transaction, P1)
- `experience/features/ECR-T-005.spec.md` — Duplicate Flag Resolution (Transaction, P2)
- `experience/features/ECR-T-006.spec.md` — Waitlist Management (Transaction, P2)
- `experience/features/ECR-T-007.spec.md` — Assessment Delivery (Transaction, P2, DEFERRED)
- `experience/features/ECR-T-008.spec.md` — Candidate Slot Allocation (Transaction, P1)
- `experience/features/ECR-T-009.spec.md` — Slot Invitation and Confirmation (Transaction, P1)
- `experience/features/ECR-T-010.spec.md` — Kiosk Check-In (Transaction, P0)
- `experience/features/ECR-T-011.spec.md` — Walk-In Registration (Transaction, P2)
- `experience/features/ECR-T-012.spec.md` — Offline Sync and Manual Review (Transaction, P2)
- `experience/features/ECR-T-013.spec.md` — Session Digest Dispatch (Transaction, P1)
- `experience/features/ECR-T-014.spec.md` — HM Interview Kit (Transaction, P0)
- `experience/features/ECR-T-015.spec.md` — Score Edit Request (Transaction, P2)
- `experience/features/ECR-T-016.spec.md` — Bulk Email Dispatch (Transaction, P1)
- `experience/features/ECR-A-001.spec.md` — Communication Job Tracking (Analytics, P1)
- `experience/features/ECR-A-002.spec.md` — Live Event Dashboard (Analytics, P0)
- `experience/features/ECR-A-003.spec.md` — Custom Report Builder (Analytics, P2)
- `experience/features/ECR-A-004.spec.md` — Audit Log Viewer (Analytics, P2)
- `experience/features/ECR-A-005.spec.md` — Event Performance Analytics (Analytics, P2)

## Gate G5 Status

| Criteria | Status | Notes |
|----------|--------|-------|
| Feature catalog — all capabilities from Steps 1-4 covered | Pass | 27 features spanning all 8 BCs |
| Classification — every feature has M/T/A | Pass | 6M, 16T, 5A |
| P0 specs complete | Pass | ECR-T-010, ECR-T-014, ECR-A-002 all fully specced |
| Interaction map — every feature has >= 1 interaction point | Pass | See experience/ia/interaction-map.md |
| Permission matrix — all roles x all features covered | Pass | See experience/ia/permission-matrix.md |
| Consistency — feature IDs match across catalog, IA, specs | Pass | IDs consistent across all 32 artifacts |

## Development Handoff Checklist

- [ ] Feature specs reviewed by Product Owner (P0 specs priority)
- [ ] API contracts reviewed by Engineering Lead (api-usecase.openapi.yaml + api-domain.openapi.yaml)
- [ ] Permission matrix reviewed by Security team
- [ ] Assessment build/integrate decision made (blocks ECR-T-007 activation)
- [ ] Face capture legal review complete (blocks ECR-T-010 face capture sub-feature)
- [ ] SMS gateway vendor selected (blocks SMS notification channel in ECR-T-006, ECR-T-009)
- [ ] Badge printing hardware standardized (blocks badge print in ECR-T-010)
- [ ] HR system integration scoped (enables Offer Rate in ECR-A-005)

## Open Decisions Before Development Starts

| Decision | Blocks | Owner | Target Date |
|----------|--------|-------|-------------|
| Assessment vendor activation | ECR-T-007 | Product Lead | TBD |
| Face capture biometric legal review | ECR-T-010 face capture | Legal / DPO | TBD |
| SMS gateway vendor selection | ECR-T-006, ECR-T-009 SMS notifications | Infrastructure Lead | TBD |
| Badge printer hardware standard | ECR-T-010 badge print | IT / Ops | TBD |

## Recommended Sprint 0 Scope

Build the minimum viable event day stack first:

1. **ECR-T-010 Kiosk Check-In** (P0) — with QR scan, manual SBD entry, online + offline mode
2. **ECR-T-014 HM Interview Kit** (P0) — KitLink flow, candidate queue, score submission
3. **ECR-A-002 Live Event Dashboard** (P0) — Redis-backed real-time metrics
4. **ECR-T-013 Session Digest Dispatch** (P1) — required to generate KitLinks for ECR-T-014
5. **ECR-M-001 Event Configuration** (P1) — required to create an event for the above to run

This stack delivers a working event day experience: candidates check in, HMs interview and score, TA monitors in real-time. All P1 setup features and P2 features follow in subsequent sprints.
