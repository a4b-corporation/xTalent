# Handoff: Step 4 -> Step 5 (Product Experience Design)
*ECR Module | xTalent HCM Solution | 2026-03-26*

---

## Input Summary for Experience Designer

Step 4 (Solution Architecture) is complete. The following artifacts are available as input for experience design:

| Artifact | Path | Relevance to UX |
|----------|------|-----------------|
| Context Map L1 | `architecture/context-map-l1.md` | System boundary, actors, external systems, integration patterns |
| Context Map L2 | `architecture/context-map-l2.md` | Container topology, offline kiosk sync protocol, communication SLAs |
| Database Schema | `architecture/db.dbml` | Data shapes, field types, enum values, constraints for form design |
| Use-Case API | `architecture/api-usecase.openapi.yaml` | 27 business-intent endpoints — the primary API surface for all UX flows |
| Domain API | `architecture/api-domain.openapi.yaml` | CRUD endpoints for admin/data management screens |
| Event Repository | `architecture/events.yaml` | 54 domain events — use for real-time UX state transitions and notification triggers |

---

## Available API Capabilities

### TA Event Coordinator can:

From `api-usecase.openapi.yaml` — permission prefix `ecr.event.*` and `ecr.schedule.*`:

- **Create a recruitment event** (`createRecruitmentEvent`) — initiates event in DRAFT state with title, date range, location, capacity
- **Publish a recruitment event** (`publishEvent`) — makes event visible; guards: >= 1 track, valid date range, registration form defined
- **Clone an existing event** (`cloneEvent`) — copies structure without registrations; useful for recurring events
- **Open registration** (`openEventRegistration`) — transitions to REGISTRATION_OPEN; candidates can register
- **Start and close the event** (`startEvent`, `closeEvent`) — controls event day lifecycle
- **Build schedule matrix** (`buildScheduleMatrix`) — defines rooms, shifts, and slot capacity grid
- **Allocate candidates to slots** (`allocateCandidatesToSlots`) — batch allocation with optional rebalancing; exclusive lock prevents concurrent runs
- **Invite candidates to slot** (`inviteCandidatesToSlot`) — sends slot assignment notifications
- **Confirm waitlist slot** (`confirmWaitlistSlot`) — promotes waitlisted candidate when slot opens
- **Dispatch session digest** (`dispatchSessionDigest`) — sends per-session interview kit emails to Hiring Managers
- **Send bulk communication** (`sendBulkCommunication`) — triggers templated bulk email job (invitation, reminder, outcome)
- **Get communication job status** (`getCommunicationJobStatus`) — polls async email job progress
- **View event dashboard** (`getEventDashboard`) — real-time metrics snapshot (registration count, check-in rate, interview funnel)
- **Generate report** (`generateReport`) — runs a saved report definition; async output
- **View audit log** (`getAuditLog`) — paginated append-only audit trail

### Hiring Manager can:

- **Access interview kit via KitLink** (`accessInterviewKit`) — no ECR login required; token embedded in email link; 24-hour TTL; returns candidate queue, session schedule, scoring rubric
- **Submit interview score** (`submitInterviewScore`) — immutable after submission; PASS / FAIL / HOLD / SKIP verdicts; comment field; duplicate submission rejected with 409
- **Skip a candidate** (`skipCandidate`) — removes candidate from active queue without scoring; requires reason code

Note: HM access is entirely KitLink-based. There is no persistent HM login session in ECR. Every KitLink request is validated server-side for expiry (403 if expired) and session ownership. UX must communicate link expiry proactively and provide a re-request mechanism.

### Candidate can:

- **Register for an event** (`registerCandidate`) — online self-registration via portal; validates eligibility, capacity, duplicate detection; returns SBD on confirmation
- **Receive notifications** — invitation email, slot assignment email, reminder (triggered by domain events via BC-07, not direct API calls from candidate)

Note: Candidates do not have an authenticated ECR session beyond registration submission. All subsequent candidate-facing interactions are email-link driven (slot confirmation, reminders). UX for candidates is primarily the registration form and email content.

### Onsite Staff (Kiosk) can:

- **Start a kiosk session** (`startKioskSession`) — authenticates device, pre-allocates SBD block (100 numbers); must be online at session start
- **Check in a candidate via QR scan or SBD lookup** (`scanCheckIn`) — works online; in offline mode, kiosk writes locally to SQLite without calling this endpoint; sync reconciles on reconnect
- **Register a walk-in** (`registerKioskWalkIn`) — captures walk-in candidate onsite; works online only (duplicate check requires server); can fall back to manual queue offline
- **Generate SBD offline** — not a server API call; kiosk derives SBD from pre-allocated block in local SQLite; no server round-trip
- **Sync offline data** (`syncKioskData`) — ordered batch upload on reconnect; server returns `accepted` and `conflicts`; conflicts route to ManualReviewQueue (never silently discarded)
- **Request new SBD block** — triggered automatically when < 10 SBDs remain in current block; requires network connectivity

---

## Performance SLAs for UX Design

| SLA | Value | UX Design Implication |
|-----|-------|----------------------|
| Kiosk local operations | < 5s P95 | All check-in interactions must complete within 5s locally; loading indicators are permitted only for server sync actions |
| HM dashboard refresh | < 5s P95 | Dashboard can auto-refresh; real-time feel achievable; Redis-backed projection means no spinner needed for counter updates |
| API Gateway → Core API | < 200ms P95 | Forms and command submissions feel near-instant; no skeleton loaders needed for simple commands |
| User → API Gateway | < 500ms P95 | Total online response budget including network; aggressive loading states are unnecessary for typical operations |
| Bulk email dispatch | 500 msg/min ceiling | Bulk communication jobs are async; UX must show a job-queued confirmation, not instant delivery; `getCommunicationJobStatus` is the polling endpoint |
| Event dashboard data age | < 1s (Redis) | Check-in counts visible on HM dashboard within ~1s of check-in event; suitable for live event monitoring |
| Audit log availability | Eventual (Kafka consumer) | Audit entries appear seconds after the action; not suitable for immediate confirmation UX; use domain event response for immediate feedback |

---

## Offline Constraints (Kiosk UX)

### What works fully offline (after session start):

- QR code scan and SBD lookup against local SQLite database
- SBD generation from pre-allocated block (no server call)
- Walk-in capture to local queue (no duplicate check — flagged for review on sync)
- All previously synced candidate records are available for lookup

### What requires network connectivity:

- Starting a new kiosk session (SBD block allocation requires server)
- Online walk-in registration with real-time duplicate detection
- Syncing offline records to server
- Requesting a new SBD block when current block is near exhausted (< 10 remaining)

### Sync UX requirements:

- Display sync queue depth (number of pending records) at all times
- Alert onsite staff when SBD block has < 10 numbers remaining and network is unavailable
- Show sync status after reconnect: accepted count vs. conflict count
- Conflicts in ManualReviewQueue must be surfaced clearly — they are not lost but require staff action
- Provisional check-in state (offline, not yet synced) must be visually distinct from confirmed state
- Power-loss recovery: SQLite WAL mode ensures queued records survive crash; UX must handle "resuming after device restart" gracefully

---

## Key User Workflows to Design

Listed by frequency and criticality on event day:

1. **Candidate QR / SBD Check-In** (Onsite Staff) — highest volume, time-critical; must handle online and offline modes; target < 5s end-to-end including UX interaction
2. **Hiring Manager Interview Kit** (HM via KitLink) — time-sensitive; no login flow; deep link from email; must handle expired link gracefully; score submission is irreversible
3. **Live Event Dashboard** (TA Coordinator) — real-time monitoring during event day; registration funnel, check-in rate, interview throughput
4. **Bulk Communication Dispatch** (TA Coordinator) — pre-event invitations, slot assignments, reminders; async job with status tracking
5. **Schedule Matrix Building** (TA Coordinator) — pre-event setup; room-shift-slot grid; allocation run with progress indicator (may take seconds for large events)
6. **Candidate Registration Portal** (Candidate) — self-service online form; duplicate detection feedback; SBD confirmation on success; waitlist notification if capacity full
7. **Walk-In Registration + Manual Review** (Onsite Staff) — captures unregistered candidates; offline-safe; conflict resolution post-sync
8. **Waitlist Management** (TA Coordinator) — promote candidates when slots open; system can automate or require manual confirmation (configurable)
9. **Event Creation Wizard** (TA Coordinator) — multi-step: event details, tracks, registration form, capacity; guard validations before publish
10. **Audit Log Review** (TA Coordinator / Compliance) — paginated timeline of all actions; filter by actor, entity, date range

---

## Data Sensitivity Constraints

| Constraint | Detail |
|------------|--------|
| Candidate PII — Vietnam residency | All candidate name, contact, and registration data is stored in Vietnam DC only. No PII may be rendered in any client-side cache outside Vietnam infrastructure. |
| KitLink access | A KitLink grants temporary access to a specific interview session's candidate queue. Links expire after 24 hours. After expiry, ECR returns 403; UX must offer a "request new link" action directed to the TA Coordinator. |
| KitLink scope | Each KitLink is scoped to a single `interview_session_id`. A HM with multiple sessions receives one link per session. UX must not allow cross-session data leakage via link parameter manipulation. |
| Interview score immutability | Once submitted, a score cannot be changed. UX must include a confirmation step before submission. Show a clear "this is final" warning. Score edit requests exist as a separate admin workflow with audit trail. |
| Candidate duplicate flags | Duplicate flags contain PII across two candidate records. Access restricted to TA Coordinator (`ecr.registration.manage`). Not visible in candidate-facing or HM-facing views. |
| Assessment data (deferred) | No candidate data may be sent to the Assessment Engine until the vendor confirms Vietnam data residency compliance. UX for assessment should show a "pending vendor activation" placeholder state. |
| Audit log | Append-only, hash-chained. Must never be presented as editable. Deletions are architecturally impossible (separate instance, no DELETE trigger). |

---

## Recommended Experience Design Priorities

### P0 — Event Day Operations (Cannot fail)

- Kiosk check-in (online + offline modes with sync UX)
- HM Interview Kit access (KitLink deep link + score submission)
- Live Event Dashboard (real-time check-in and interview funnel)

### P1 — Pre-Event Setup (Blocking to event day)

- Event creation wizard (Draft → Published → Registration Open → In Progress)
- Schedule matrix builder (rooms, shifts, slot grid)
- Candidate slot allocation run with progress and conflict review
- Bulk email dispatch with job status tracking
- Candidate registration portal (self-service, SBD confirmation, waitlist notice)

### P2 — Event Management and Compliance

- Walk-in registration and ManualReviewQueue resolution
- Waitlist management (manual promotion or auto-promote toggle)
- Communication template management
- Audit log viewer (filter, export)
- Custom report generation

---

## Gate G4 Status

All quality gates passed:

- Context Map L1: all 4 actors and 3 external systems included
- Context Map L2: all 8 BCs present with DDD relationship types; all 10 containers described
- DBML: all LinkML classes mapped to tables; relationships match; enums defined
- Use-Case API: 27 endpoints, all derived from flow intent; business-verb naming throughout
- Domain API: CRUD coverage for all aggregate roots; no path overlap with use-case API
- Event Repository: 54 events across 8 BCs; all events have consumers; no orphan events; all sourced from Event Storming or flows
- All OpenAPI specs are OpenAPI 3.0 compliant
- DBML syntax is dbdiagram.io compatible

Step 4 is complete. Step 5 (Product Experience) may begin.
