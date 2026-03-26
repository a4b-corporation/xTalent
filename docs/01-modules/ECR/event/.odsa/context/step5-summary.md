# Step 5 Summary: Product Experience Design
*ECR Module | xTalent HCM Solution | Completed: 2026-03-26*

## What Was Produced

- `experience/feature-catalog.md` — 27 features classified and prioritized with full traceability
- `experience/ia/menu-map.md` — Role-based menu hierarchy for all ECR actors
- `experience/ia/interaction-map.md` — Feature to interaction point mapping (screens, deep links, kiosk)
- `experience/ia/nav-flows.md` — Cross-feature navigation flows for P0 user stories
- `experience/ia/permission-matrix.md` — Role x Feature x Action coverage for all 27 features
- `experience/features/ECR-M-001.spec.md` through `ECR-M-006.spec.md` — 6 masterdata specs
- `experience/features/ECR-T-001.spec.md` through `ECR-T-016.spec.md` — 16 transaction specs
- `experience/features/ECR-A-001.spec.md` through `ECR-A-005.spec.md` — 5 analytics specs

Total: 1 catalog + 4 IA files + 27 feature specs = 32 artifacts

## Feature Catalog Summary

| Type | P0 | P1 | P2 | Total |
|------|----|----|----|-------|
| Masterdata (M) | 0 | 6 | 0 | 6 |
| Transaction (T) | 2 | 8 | 6 | 16 |
| Analytics (A) | 1 | 1 | 3 | 5 |
| **Total** | **3** | **15** | **9** | **27** |

P0: ECR-T-010 (Kiosk Check-In), ECR-T-014 (HM Interview Kit), ECR-A-002 (Live Event Dashboard)

## Key UX Decisions Made

1. **KitLink is token-gated, no login required for HMs** — reduces friction on event day; HM identity is asserted by the signed token, not an SSO session
2. **Kiosk check-in uses dual-mode (online + offline SQLite)** — ensures no single point of failure on event day; Provisional state bridges the gap until sync
3. **Score submission is irreversible by default; edit requires governed unlock** — prevents casual edits while providing a controlled escape hatch (ECR-T-015) with full audit trail
4. **Assessment delivery (ECR-T-007) deferred with placeholder UI** — vendor activation required; feature-flag controlled so the slot is reserved in the menu without blocking release
5. **Interaction points span 3 modes** — browser (TA/Admin), KitLink deep link (HM, no login), Kiosk PWA (onsite staff); each has distinct auth and UX constraints
6. **Bulk email has a 500/msg-per-minute ceiling enforced at dispatch** — protects email gateway reputation; progress tracked async via ECR-A-001 job tracker
7. **Live dashboard uses Redis-backed cache with 30s TTL** — decouples event-day read load from write path; alert states use ambient indicators not modal interrupts to avoid disrupting coordinator flow

## Deferred Items

- **ECR-T-007 (Assessment Delivery)** — Pending vendor activation decision. Placeholder UI rendered; feature-flag off by default. Decision owner: Product Lead.
- **ECR-T-010 face capture sub-feature** — Legal review required for biometric data capture. Placeholder rendered in kiosk UI; not activated until legal approval.
- **ECR-A-005 Offer Rate metric** — Requires downstream HR system integration (offer status feed). Shows "N/A" until integration is configured.
- **ECR-A-003 report scheduling** — Save / schedule reports deferred to a future phase. Only ad-hoc on-demand runs supported in P2 scope.

## Open Questions

- SMS gateway vendor: SMS notification channel referenced in several transaction specs (slot invitations, waitlist promotion); vendor selection needed before implementation
- Badge printing hardware: ECR-T-010 badge print sub-feature assumes a compatible label printer at kiosk; hardware standard not yet defined
- Face capture legal jurisdiction: requirements may differ by country; legal review scope needs to be defined

## Artifact Paths

| Artifact | Path |
|----------|------|
| Feature Catalog | experience/feature-catalog.md |
| Menu Map | experience/ia/menu-map.md |
| Interaction Map | experience/ia/interaction-map.md |
| Nav Flows | experience/ia/nav-flows.md |
| Permission Matrix | experience/ia/permission-matrix.md |
| Feature Specs | experience/features/ECR-{M,T,A}-*.spec.md |
