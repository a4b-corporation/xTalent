# Feature Catalog: ECR Module
## xTalent HCM Solution | 2026-03-26

---

## Feature Classification Key

- **M** = Masterdata: configuration and reference data (CRUD, light spec)
- **T** = Transaction: workflow with states, steps, and side effects (deep spec)
- **A** = Analytics: read-only dashboards, reports, and metrics (medium spec)

## Priority Key

- **P0** = MVP / Event Day Critical — system cannot function without these on event day
- **P1** = Pre-Event Setup — required to configure and prepare before P0 can run
- **P2** = Management, Compliance, Future Phase — important but not day-of blockers

---

## Feature List

| Feature ID | Feature Name | BC | Type | Priority | Description |
|-----------|-------------|-----|------|----------|-------------|
| ECR-M-001 | Event Configuration | BC-01 | M | P1 | Core event metadata: name, dates, location, description, tracks, capacity, registration window, event status defaults |
| ECR-T-001 | Event Lifecycle Management | BC-01 | T | P1 | Full state machine: Draft → Published → RegOpen → InProgress → Closed → Archived; publish, open registration, start, close, archive transitions with guard conditions |
| ECR-M-002 | Track Configuration | BC-01 | M | P1 | Track definition within an event: track name, linked job request, question set assignment, target headcount, screening criteria |
| ECR-T-002 | Registration Form Builder | BC-01 | T | P1 | Dynamic form designer: field types (text, select, file upload), required/optional toggle, track-specific question blocks, preview mode, version lock on publish |
| ECR-T-003 | Event Cloning | BC-01 | T | P2 | Clone an existing event or saved template: select source, choose which sections to carry over (tracks, form, schedule structure), set new dates, save as draft |
| ECR-T-004 | Candidate Self-Registration Portal | BC-02 | T | P1 | Public-facing, no-login portal: multi-step form, document upload, duplicate detection on submit, SBD issuance on success, waitlist placement when capacity full |
| ECR-T-005 | Duplicate Flag Resolution | BC-02 | T | P2 | TA reviews system-flagged duplicate candidates: compare side-by-side, merge records, reject duplicate, or override flag; action logged to audit |
| ECR-T-006 | Waitlist Management | BC-02 | T | P2 | Waitlist queue view, manual promote-to-registered, auto-promotion trigger when allocated slots open; notification sent on promotion |
| ECR-M-003 | SBD Management | BC-02 | M | P1 | View assigned SBDs per event, regenerate individual SBD, batch generate missing SBDs, export SBD list; SBD format config (prefix, zero-pad length) |
| ECR-T-007 | Assessment Delivery | BC-03 | T | P2 | DEFERRED — pending vendor activation. Placeholder state displayed in UI. Integration hooks reserved. Feature flag controlled. |
| ECR-M-004 | Schedule Matrix Builder | BC-04 | M | P1 | Define rooms, time slots (shifts), and capacity per slot; grid-based visual editor; assign tracks to rooms; export schedule grid |
| ECR-T-008 | Candidate Slot Allocation | BC-04 | T | P1 | Assign registered candidates to schedule slots: auto algorithms (Round-Robin, Fill-First), manual drag-and-drop override, conflict detection, allocation preview before commit |
| ECR-T-009 | Slot Invitation and Confirmation | BC-04 | T | P1 | Dispatch slot invitations to allocated candidates; candidate confirms, requests reschedule, or is moved to waitlist; TA views confirmation status dashboard |
| ECR-T-010 | Kiosk Check-In | BC-05 | T | P0 | Onsite check-in via QR scan or manual SBD entry; online mode writes to server immediately; offline mode writes to local SQLite (Provisional state); face capture placeholder; < 5s P95 |
| ECR-T-011 | Walk-In Registration | BC-05 | T | P2 | Onsite staff captures walk-in candidate data on kiosk; offline queue when no connectivity; assigns provisional SBD; flags as WalkIn type for later review |
| ECR-T-012 | Offline Sync and Manual Review | BC-05 | T | P2 | Sync offline kiosk queue to server on reconnect; conflict detection (duplicate SBD, already checked-in); TA manual review queue for unresolved conflicts |
| ECR-T-013 | Session Digest Dispatch | BC-06 | T | P1 | TA triggers session digest for HM panels: selects session, generates KitLink per interviewer, dispatches email with link and candidate list; link TTL = 24h |
| ECR-T-014 | HM Interview Kit | BC-06 | T | P0 | KitLink deep link (no login): interviewer lands on candidate queue for their session; views candidate profile + track info; submits score with confirmation; skip with reason; link expiry warning + re-request CTA |
| ECR-T-015 | Score Edit Request | BC-06 | T | P2 | HM requests correction of submitted score: reason text required; TA reviews request; approves unlock → HM re-submits; full audit chain maintained |
| ECR-M-005 | Panel and Interviewer Assignment | BC-06 | M | P1 | Assign HM panels to sessions: hard assignment (specific slot), soft assignment (available pool); multiple interviewers per session; generate KitLinks from assignment |
| ECR-T-016 | Bulk Email Dispatch | BC-07 | T | P1 | Select email template, define recipient filter (event, track, status), preview recipient count, confirm send; async job with 500/min ceiling; job ID returned for tracking |
| ECR-M-006 | Email Template Management | BC-07 | M | P1 | Create and manage email templates: name, subject, body (rich text + merge tags), version history, preview with sample data, activate/deactivate |
| ECR-A-001 | Communication Job Tracking | BC-07 | A | P1 | Monitor bulk email jobs: delivery status (sent, delivered, bounced, failed), retry queue, bounce rate per job, job progress bar; filter by date and event |
| ECR-A-002 | Live Event Dashboard | BC-08 | A | P0 | Real-time event day metrics: check-in count vs registered, check-in rate over time, queue depth by room, track funnel (registered → checked-in → interviewed → scored); Redis-backed < 5s P95 |
| ECR-A-003 | Custom Report Builder | BC-08 | A | P2 | Dynamic report designer: select dimensions (event, track, status, date range), metrics (count, rate, score avg), preview table, export CSV/Excel |
| ECR-A-004 | Audit Log Viewer | BC-08 | A | P2 | Paginated, filterable audit trail: actor, action, entity, before/after values, timestamp; read-only non-editable presentation; filter by actor, date, entity type |
| ECR-A-005 | Event Performance Analytics | BC-08 | A | P2 | Post-event KPI summary: registration conversion rate, show-up rate, interview completion rate, offer rate by track; trend comparison vs previous events |

---

## Feature Count by Classification

| Type | Count | Feature IDs |
|------|-------|-------------|
| Masterdata (M) | 6 | ECR-M-001 through ECR-M-006 |
| Transaction (T) | 16 | ECR-T-001 through ECR-T-016 |
| Analytics (A) | 5 | ECR-A-001 through ECR-A-005 |
| **Total** | **27** | |

## Feature Count by Priority

| Priority | Count | Rationale |
|----------|-------|-----------|
| P0 | 3 | Event day blockers: Kiosk Check-In, HM Interview Kit, Live Event Dashboard |
| P1 | 13 | Pre-event setup required before P0 can operate |
| P2 | 11 | Management, compliance, deferred, or enhancement features |
| **Total** | **27** | |

---

## Traceability

| Feature ID | API Endpoint(s) | Domain Events |
|-----------|----------------|---------------|
| ECR-M-001 | createRecruitmentEvent | RecruitmentEventCreated |
| ECR-T-001 | publishEvent, openEventRegistration, startEvent, closeEvent | EventPublished, RegistrationOpened, EventStarted, EventClosed |
| ECR-M-002 | createRecruitmentEvent (track sub-resource) | TrackConfigured |
| ECR-T-002 | createRecruitmentEvent (form sub-resource) | RegistrationFormPublished |
| ECR-T-003 | cloneEvent | EventCloned |
| ECR-T-004 | registerCandidate | CandidateRegistered, CandidateWaitlisted, SBDIssued |
| ECR-T-005 | (domain API: duplicates) | DuplicateResolved |
| ECR-T-006 | confirmWaitlistSlot | WaitlistPromoted |
| ECR-M-003 | (domain API: SBD management) | SBDGenerated |
| ECR-T-007 | (deferred) | (deferred) |
| ECR-M-004 | buildScheduleMatrix | ScheduleMatrixBuilt |
| ECR-T-008 | allocateCandidatesToSlots | CandidatesAllocated |
| ECR-T-009 | inviteCandidatesToSlot, confirmWaitlistSlot | SlotInvitationSent, SlotConfirmed |
| ECR-T-010 | scanCheckIn, startKioskSession | CandidateCheckedIn (online) / KioskCheckInQueued (offline) |
| ECR-T-011 | registerKioskWalkIn | WalkInRegistered |
| ECR-T-012 | syncKioskData | KioskSyncCompleted, ConflictFlagged |
| ECR-T-013 | dispatchSessionDigest | SessionDigestDispatched, KitLinkGenerated |
| ECR-T-014 | accessInterviewKit, submitInterviewScore, skipCandidate | InterviewScoreSubmitted, CandidateSkipped |
| ECR-T-015 | (domain API: score edit request) | ScoreEditRequested, ScoreEditApproved |
| ECR-M-005 | (domain API: panel assignment) | PanelAssigned |
| ECR-T-016 | sendBulkCommunication | BulkEmailJobCreated, BulkEmailJobCompleted |
| ECR-M-006 | (domain API: templates) | EmailTemplateCreated, EmailTemplateUpdated |
| ECR-A-001 | getCommunicationJobStatus | — |
| ECR-A-002 | getEventDashboard | — |
| ECR-A-003 | generateReport | — |
| ECR-A-004 | getAuditLog | — |
| ECR-A-005 | generateReport (post-event variant) | — |
