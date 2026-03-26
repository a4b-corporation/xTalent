# Event Storming: ECR Module
## xTalent HCM Solution | 2026-03-25

---

## Overview

This document captures the full Event Storming output for the Event-Centric Recruitment (ECR) module. It maps the complete domain event timeline from event creation through post-event analytics, identifying all commands, actors, aggregates, policies, external systems, and hot spots.

**Color legend (described textually):**
- Domain Events (Orange) — things that happened, in past tense
- Commands (Blue) — user or system intent that triggers events
- Actors — who issues the command
- Policies (Lilac) — automated reactions to events
- External Systems (Pink) — outside the ECR bounded context
- Hot Spots (Red) — ambiguity, risk, or unresolved business rule

---

## 1. Domain Events (Orange)

| ID | Domain Event | Description | Trigger |
|----|--------------|-------------|---------|
| DE-01 | EventDraftCreated | A new event was created in Draft state via the wizard | TA Coordinator completes creation wizard |
| DE-02 | EventPublished | Event moved from Draft to Published; visible in event registry | TA Coordinator publishes event |
| DE-03 | RegistrationOpened | Event registration became open to candidates | TA Coordinator opens registration window |
| DE-04 | EventCloned | A new event was created by cloning an existing event; structural data copied, operational data excluded | TA Coordinator initiates clone |
| DE-05 | TrackAdded | A new candidate track was added to an event | TA Coordinator adds track in wizard or pre-event setup |
| DE-06 | FormFieldAdded | A custom registration form field was added to an event or track | TA Coordinator uses form builder |
| DE-07 | EventTransitionedToInProgress | Event state changed to In Progress; structural changes locked | TA Coordinator starts event day |
| DE-08 | EventClosed | Event state changed to Closed; no further candidates can register or check in | TA Coordinator closes event |
| DE-09 | EventArchived | Event moved to Archived state for long-term retention | System (scheduled) or TA Coordinator |
| DE-10 | CandidateRegisteredOnline | A candidate submitted the online registration form and received an SBD | Candidate submits online form |
| DE-11 | CandidateRegisteredAtKiosk | A walk-in candidate was captured at the kiosk and received an SBD | Onsite Staff captures walk-in |
| DE-12 | CandidateRegisteredOffline | A walk-in candidate was captured in kiosk offline mode; record is provisional | Kiosk offline capture |
| DE-13 | SBDAssigned | A unique Số Báo Danh was generated and assigned to a candidate for this event | System, on registration capture |
| DE-14 | DuplicateFlagged | A potential duplicate candidate record was detected; human review required | System (multi-factor matching) |
| DE-15 | DuplicateMerged | Two candidate records were merged by a human reviewer | TA Coordinator resolves duplicate as Merge |
| DE-16 | DuplicateKeptBoth | Two candidate records were confirmed as separate individuals | TA Coordinator resolves as Keep Both |
| DE-17 | DuplicateRejected | One candidate record was rejected as a true duplicate | TA Coordinator resolves as Reject |
| DE-18 | CandidateConfirmed | Candidate registration was confirmed into a scheduled slot | System after schedule allocation, or TA Coordinator manual action |
| DE-19 | CandidateWaitlisted | Candidate registered for a full slot and was placed on the waitlist | System when capacity exceeded |
| DE-20 | WaitlistBackfilled | A waitlisted candidate was moved to a confirmed slot after a cancellation | System reacts to cancellation |
| DE-21 | CandidateCancelled | A candidate cancelled their registration | Candidate or TA Coordinator |
| DE-22 | OfflineDataSynced | Offline-captured candidate records were synced to the server on reconnect | Kiosk on network reconnect |
| DE-23 | SyncFailedToManualReview | Offline records that failed server-side sync were routed to the manual review queue | System (sync failure handler) |
| DE-24 | ScheduleMatrixDefined | A Day x Shift x Room capacity matrix was saved for the event | TA Coordinator saves schedule |
| DE-25 | CapacityOverridden | A room's capacity was changed by a TA Coordinator with a logged reason | TA Coordinator override action |
| DE-26 | CandidatesAllocatedToSlots | Candidates were automatically assigned to schedule slots using a selected strategy | TA Coordinator runs allocation |
| DE-27 | CandidateCheckedIn | Candidate checked in at the event venue via QR scan or SBD entry | Onsite Staff or Candidate at kiosk |
| DE-28 | CheckInDuplicated | An attempt to check in an already-checked-in candidate was detected and blocked | Kiosk check-in system |
| DE-29 | CheckInCapturedOffline | Candidate checked in at kiosk while in offline mode; status is provisional | Kiosk offline check-in |
| DE-30 | AssessmentBlueprintDefined | An assessment blueprint was saved defining question structure and rules | TA Coordinator saves blueprint |
| DE-31 | AssessmentDispatched | Assessment links were sent to eligible (Confirmed/Checked-In) candidates | TA Coordinator triggers assessment dispatch |
| DE-32 | AssessmentCompleted | A candidate submitted their assessment responses | Candidate submits assessment |
| DE-33 | AssessmentAutoGraded | MCQ responses were automatically scored; composite score available | System (auto-grader) |
| DE-34 | ProctoringFlagRaised | A suspicious behavior event was logged during a candidate's assessment | System (proctoring monitor) |
| DE-35 | InterviewerAssigned | A Hiring Manager was assigned to an interview session (hard, soft, or queue mode) | TA Coordinator assigns interviewer |
| DE-36 | SessionDigestSent | A Session Digest email with interview schedule and kit link was sent to a Hiring Manager | TA Coordinator dispatches digests |
| DE-37 | InterviewKitAccessed | A Hiring Manager opened their digital interview kit via the secure link | HM clicks Session Digest link |
| DE-38 | CandidateInterviewed | An interview session was started for a candidate | HM begins interview in queue |
| DE-39 | InterviewScoreSubmitted | A Hiring Manager submitted interview scores for a candidate | HM submits score form |
| DE-40 | ScoreEditRequested | A Hiring Manager requested to edit a previously submitted score | HM clicks "Request Score Edit" |
| DE-41 | ScoreEditApproved | TA Coordinator approved a score edit request; audit entry created | TA Coordinator approves edit |
| DE-42 | ScoreEditRejected | TA Coordinator rejected a score edit request | TA Coordinator rejects edit |
| DE-43 | CandidateSkipped | An interviewer marked a candidate as No-Show and removed from queue | HM or Onsite Staff skips candidate |
| DE-44 | CandidateDeferred | An interviewer deferred a candidate to a later slot in the queue | HM or Onsite Staff defers candidate |
| DE-45 | BulkAdvancementRun | Multiple candidates were advanced to a target pipeline stage in one operation | TA Coordinator runs bulk advance |
| DE-46 | BulkInvitationDispatched | Invitations were sent to a cohort of candidates in a bulk email operation | TA Coordinator dispatches bulk invitations |
| DE-47 | BulkOutcomeRecorded | Pass/Fail/Hold/No-Show outcomes were recorded for multiple candidates simultaneously | TA Coordinator records bulk outcomes |
| DE-48 | RescheduleNotificationSent | A candidate was notified of a change to their scheduled slot | System reacts to schedule change |
| DE-49 | CandidatePassedEvent | A candidate's outcome for the event was recorded as Pass | TA Coordinator or bulk operation |
| DE-50 | CandidateFailedEvent | A candidate's outcome for the event was recorded as Fail | TA Coordinator or bulk operation |
| DE-51 | EventKitLinkExpired | A Session Digest link expired 24 hours after event day end | System (scheduled expiry) |
| DE-52 | AuditEntryCreated | An audit log entry was written for a consequential system action | System (on any audited action) |
| DE-53 | ReportGenerated | A custom report was generated by an HR Analytics Lead | HR Analytics Lead runs report builder |
| DE-54 | DashboardRefreshed | The real-time event dashboard metrics were refreshed | System (5-second refresh cycle) |

---

## 2. Commands (Blue)

| ID | Command | Actor | Triggered Domain Event(s) |
|----|---------|-------|--------------------------|
| CMD-01 | CreateEvent | TA Event Coordinator | DE-01 (EventDraftCreated) |
| CMD-02 | PublishEvent | TA Event Coordinator | DE-02 (EventPublished) |
| CMD-03 | OpenRegistration | TA Event Coordinator | DE-03 (RegistrationOpened) |
| CMD-04 | CloneEvent | TA Event Coordinator | DE-04 (EventCloned), DE-01 |
| CMD-05 | AddTrack | TA Event Coordinator | DE-05 (TrackAdded) |
| CMD-06 | AddFormField | TA Event Coordinator | DE-06 (FormFieldAdded) |
| CMD-07 | StartEvent | TA Event Coordinator | DE-07 (EventTransitionedToInProgress) |
| CMD-08 | CloseEvent | TA Event Coordinator | DE-08 (EventClosed) |
| CMD-09 | RegisterCandidateOnline | Candidate | DE-10 (CandidateRegisteredOnline), DE-13 (SBDAssigned), DE-14 if duplicate |
| CMD-10 | RegisterCandidateAtKiosk | Onsite Operations Staff | DE-11 (CandidateRegisteredAtKiosk), DE-13 (SBDAssigned), DE-14 if duplicate |
| CMD-11 | CaptureOfflineRegistration | Kiosk System | DE-12 (CandidateRegisteredOffline), DE-13 (SBDAssigned) |
| CMD-12 | ResolveDuplicateMerge | TA Event Coordinator | DE-15 (DuplicateMerged), DE-52 (AuditEntryCreated) |
| CMD-13 | ResolveDuplicateKeepBoth | TA Event Coordinator | DE-16 (DuplicateKeptBoth), DE-52 |
| CMD-14 | ResolveDuplicateReject | TA Event Coordinator | DE-17 (DuplicateRejected), DE-52 |
| CMD-15 | DefineScheduleMatrix | TA Event Coordinator | DE-24 (ScheduleMatrixDefined) |
| CMD-16 | OverrideCapacity | TA Event Coordinator | DE-25 (CapacityOverridden), DE-52 |
| CMD-17 | RunCandidateAllocation | TA Event Coordinator | DE-26 (CandidatesAllocatedToSlots), DE-18 (CandidateConfirmed) × N |
| CMD-18 | CheckInCandidate | Onsite Operations Staff / Candidate | DE-27 (CandidateCheckedIn) or DE-28 (CheckInDuplicated) |
| CMD-19 | CheckInCandidateOffline | Kiosk System | DE-29 (CheckInCapturedOffline) |
| CMD-20 | SyncOfflineData | Kiosk System | DE-22 (OfflineDataSynced) or DE-23 (SyncFailedToManualReview) |
| CMD-21 | DefineAssessmentBlueprint | TA Event Coordinator | DE-30 (AssessmentBlueprintDefined) |
| CMD-22 | DispatchAssessment | TA Event Coordinator | DE-31 (AssessmentDispatched) |
| CMD-23 | SubmitAssessment | Candidate | DE-32 (AssessmentCompleted), DE-33 (AssessmentAutoGraded) |
| CMD-24 | AssignInterviewer | TA Event Coordinator | DE-35 (InterviewerAssigned) |
| CMD-25 | SendSessionDigests | TA Event Coordinator | DE-36 (SessionDigestSent) × N HMs |
| CMD-26 | AccessInterviewKit | Hiring Manager | DE-37 (InterviewKitAccessed) |
| CMD-27 | SubmitInterviewScore | Hiring Manager | DE-39 (InterviewScoreSubmitted), DE-52 |
| CMD-28 | RequestScoreEdit | Hiring Manager | DE-40 (ScoreEditRequested) |
| CMD-29 | ApproveScoreEdit | TA Event Coordinator | DE-41 (ScoreEditApproved), DE-52 |
| CMD-30 | RejectScoreEdit | TA Event Coordinator | DE-42 (ScoreEditRejected), DE-52 |
| CMD-31 | SkipCandidate | Hiring Manager / Onsite Staff | DE-43 (CandidateSkipped), DE-52 |
| CMD-32 | DeferCandidate | Hiring Manager / Onsite Staff | DE-44 (CandidateDeferred) |
| CMD-33 | RunBulkAdvancement | TA Event Coordinator | DE-45 (BulkAdvancementRun), DE-52 |
| CMD-34 | DispatchBulkInvitations | TA Event Coordinator | DE-46 (BulkInvitationDispatched) |
| CMD-35 | RecordBulkOutcomes | TA Event Coordinator | DE-47 (BulkOutcomeRecorded), DE-52 |
| CMD-36 | GenerateReport | HR Analytics Lead | DE-53 (ReportGenerated) |

---

## 3. Actors

### TA Event Coordinator
Primary actor. Responsible for the full event lifecycle.

**Primary commands:** CMD-01, CMD-02, CMD-03, CMD-04, CMD-05, CMD-06, CMD-07, CMD-08, CMD-12, CMD-13, CMD-14, CMD-15, CMD-16, CMD-17, CMD-21, CMD-22, CMD-24, CMD-25, CMD-29, CMD-30, CMD-33, CMD-34, CMD-35

### Hiring Manager (HM)
Conducts interviews via digital kit. No xTalent login required for interview operations.

**Primary commands:** CMD-26, CMD-27, CMD-28, CMD-31, CMD-32

### Candidate — Fresher / Experienced
Self-registers online; receives SBD, assessment links, schedule notifications.

**Primary commands:** CMD-09, CMD-23

### Candidate — Walk-In
Arrives at venue without prior registration; captured at kiosk by Onsite Staff.

**Primary commands:** (Captured via CMD-10 by Onsite Staff on their behalf)

### Onsite Operations Staff
Manages kiosk stations, captures walk-in registrations, executes check-ins.

**Primary commands:** CMD-10, CMD-18, CMD-31, CMD-32

### HR Analytics Lead
Consumes reports and audit data. Read-only access to event data.

**Primary commands:** CMD-36

### System (Automated)
Executes automated reactions to domain events (policies, scheduled jobs, sync).

**Primary commands:** CMD-11, CMD-19, CMD-20, CMD-23 (auto-grading), scheduling expiry jobs

---

## 4. Aggregates / Bounded Contexts

### 4.1 Event Management Aggregate
Root Entity: Event

**Domain Events grouped here:**
DE-01, DE-02, DE-03, DE-04, DE-05, DE-06, DE-07, DE-08, DE-09

**Invariants enforced:**
- Event state machine transitions are unidirectional and validated
- Structural changes (tracks, form fields) prohibited once EventTransitionedToInProgress
- Event must have at least 1 track before transitioning to Published

**Key entities:** Event, Track, EventPhase, RegistrationForm, FormField

---

### 4.2 Candidate Aggregate
Root Entity: CandidateEventRegistration (candidate in the context of a specific event)

**Domain Events grouped here:**
DE-10, DE-11, DE-12, DE-13, DE-14, DE-15, DE-16, DE-17, DE-18, DE-19, DE-20, DE-21, DE-22, DE-23

**Invariants enforced:**
- SBD is unique within an event
- SBD is generated at capture, not at email delivery
- Duplicate records cannot be auto-merged or auto-rejected (human decision required)
- Waitlist ordering is strictly by registration timestamp

**Key entities:** CandidateEventRegistration, SBD, DuplicateFlag, WaitlistEntry

---

### 4.3 Assessment Aggregate
Root Entity: CandidateAssessment

**Domain Events grouped here:**
DE-30, DE-31, DE-32, DE-33, DE-34

**Invariants enforced:**
- Assessment dispatched only to Confirmed or Checked-In candidates (BR-07)
- Assessment link is time-limited
- Auto-grading is applied to MCQ; essays routed for manual review

**Key entities:** AssessmentBlueprint, QuestionBank, Question, CandidateAssessment, AssessmentResult, ProctoringLog

---

### 4.4 Schedule Aggregate
Root Entity: EventSchedule

**Domain Events grouped here:**
DE-24, DE-25, DE-26, DE-48

**Invariants enforced:**
- Room double-booking is prevented
- Capacity override requires reason and is logged
- Structural capacity changes blocked when event is In Progress (BR-06)
- Waitlist backfill is first-come-first-served (BR-10)

**Key entities:** EventSchedule, ScheduleSlot, Room, Shift, AllocationStrategy, WaitlistQueue

---

### 4.5 Onsite Operations Aggregate
Root Entity: CheckInRecord

**Domain Events grouped here:**
DE-27, DE-28, DE-29, DE-22, DE-23

**Invariants enforced:**
- Check-in must complete end-to-end in <5 seconds (NFR-02)
- Duplicate check-in detected and rejected
- Offline data is provisional until sync confirmed; sync is atomic per record (BR-08)
- No data loss on sync failure — failed records to manual review queue

**Key entities:** CheckInRecord, KioskSession, OfflineSyncQueue, ManualReviewQueue

---

### 4.6 Interview Management Aggregate
Root Entity: InterviewSession

**Domain Events grouped here:**
DE-35, DE-36, DE-37, DE-38, DE-39, DE-40, DE-41, DE-42, DE-43, DE-44, DE-51

**Invariants enforced:**
- Session Digest links expire 24h after event day (server-side, BR-05)
- Submitted scores are locked; edit requires TA Coordinator approval (BR-04)
- All score changes are audit-logged (original value, new value, actors, timestamp)

**Key entities:** InterviewSession, InterviewerAssignment, SessionDigest, KitLink, InterviewScore, ScoreEditRequest

---

### 4.7 Communication Aggregate
Root Entity: CommunicationJob

**Domain Events grouped here:**
DE-36, DE-46, DE-48

**Invariants enforced:**
- Bulk email throughput >= 500 emails/minute (NFR-01)
- Failed deliveries are retried with backoff; never silently discarded
- Delivery status tracked per candidate

**Key entities:** CommunicationJob, EmailTemplate, DeliveryRecord

---

### 4.8 Analytics & Audit Aggregate
Root Entity: AuditLog / EventMetrics

**Domain Events grouped here:**
DE-52, DE-53, DE-54

**Invariants enforced:**
- Audit log is append-only (tamper-evident)
- Minimum retention 3 years
- All consequential actions generate an audit entry

**Key entities:** AuditEntry, EventMetricsSnapshot, ReportDefinition, ReportResult

---

## 5. Policies / Reactions (Lilac)

| ID | Trigger Event | Policy Name | Reaction |
|----|---------------|-------------|----------|
| POL-01 | CandidateRegisteredOnline | AutoSBDAssignment | When a candidate registers, the system immediately generates and assigns an SBD regardless of email delivery status (BR-01) |
| POL-02 | CandidateRegisteredAtKiosk | AutoSBDAssignment | Same as POL-01 for kiosk registrations |
| POL-03 | CandidateRegisteredOnline OR CandidateRegisteredAtKiosk | DuplicateDetectionCheck | On every new registration, system runs multi-factor matching (phone+studentID, phone+name+DOB, email+phone); if match found above threshold, raises DuplicateFlagged |
| POL-04 | DuplicateFlagged | DuplicateNotificationToCoordinator | Notify TA Coordinator: "New duplicate flagged for event [X] — requires review" |
| POL-05 | CandidateCancelled | WaitlistBackfillTrigger | When a confirmed candidate cancels, system identifies next candidate on waitlist by registration timestamp and assigns the freed slot; sends WaitlistBackfilled notification |
| POL-06 | CandidateCheckedIn | QueueDisplayUpdate | Within 5 seconds of check-in, update the HM queue display for the candidate's assigned room to show "Waiting" status (NFR-03) |
| POL-07 | CandidateCheckedIn | AssessmentEligibilityGrant | If assessment has been configured and event is in Assessment phase, candidate becomes eligible to receive assessment link (BR-07) |
| POL-08 | AssessmentCompleted | AutoGradingTrigger | System immediately scores MCQ questions; essay/coding responses flagged for manual review queue |
| POL-09 | InterviewScoreSubmitted | ScoreLock | Score record is marked immutable; future edits require an explicit ScoreEditRequest workflow |
| POL-10 | EventTransitionedToInProgress | StructuralChangeLock | System sets structural-change-locked flag on event; any attempt to modify tracks, rooms, or form fields returns an error (BR-06) |
| POL-11 | EventClosed + 24h | SessionDigestLinkExpiry | System marks all Session Digest links for the event as expired; server returns 403 on any access attempt (BR-05) |
| POL-12 | OfflineDataSynced | ProvisionalStatusClear | Successfully synced records transition from "Provisional" to "Confirmed" status |
| POL-13 | SyncFailedToManualReview | ManualReviewNotification | Notify TA Coordinator: "X records from kiosk sync failed — manual review required" |
| POL-14 | BulkAdvancementRun | AuditEntryCreated | System writes an audit entry with: actor, timestamp, event ID, stage from, stage to, candidate IDs included and excluded |
| POL-15 | ScoreEditApproved OR ScoreEditRejected | AuditEntryCreated | System writes audit entry with: original score, new score (if approved), requestor, approver, timestamp |

---

## 6. External Systems (Pink)

| System | Integration Type | Data Exchanged | Dependency Level |
|--------|-----------------|----------------|-----------------|
| xTalent RBAC Service | Internal API (synchronous) | User identity, role assignments, permission checks | P0 — all authenticated actions depend on this |
| xTalent Job Request API | Internal API (synchronous) | Job Request IDs and details for track-to-requisition linkage | P1 — fallback (freeform) allowed if unavailable |
| Email Delivery Service (e.g., SendGrid, SES) | External API (async) | Bulk emails, delivery status webhooks | P0 — primary notification channel |
| SMS Gateway (pending) | External API (async) | SMS notifications to candidates | P2 — deferred; not required at launch |
| Assessment Engine (build vs. integrate TBD) | Internal or External API | Candidate assessment context (in), scores (out) | P1 — deferred; interface contract defined in domain design |
| Badge Printer Hardware | Hardware integration (local API) | Print job: SBD, candidate name, track, photo (deferred) | P2 — deferred; hardware not standardized |
| Biometric Identity Provider (face capture) | External SDK (pending legal clearance) | Candidate face image capture and matching | P2 — deferred; blocked by legal |
| Vietnam Data Center / Cloud Infrastructure | Infrastructure | All data storage, processing, and backup | P0 — data residency compliance (NFR-09) |

---

## 7. Hot Spots (Red)

| ID | Description | Risk Level | Resolution Path |
|----|-------------|------------|----------------|
| HS-01 | SBD Generation in Offline Mode — Who holds the SBD sequence counter when the kiosk is offline? If two kiosks are offline simultaneously, they could generate conflicting SBDs on the same sequence. | High | Design: each kiosk is assigned a unique prefix or SBD block at sync. SBDs from different kiosks within the same block cannot conflict. Requires architecture decision in Step 3. |
| HS-02 | Assessment Build vs. Integrate Ambiguity — FR-14 to FR-18 are blocked pending a product decision. The domain boundary between ECR and Assessment is unresolved: if integrated, data flows across system boundaries; if built, Assessment is an ECR subdomain. | High | Decision must be made within 4 weeks of BRD sign-off (Risk-01). Domain model must define the interface contract either way before development begins. |
| HS-03 | Offline Sync Conflict Resolution — When a candidate captured offline is later found to conflict with an existing online record (same phone), who resolves the conflict and what is the SBD assigned? | High | Policy: offline captures always generate a local SBD for operational continuity. Conflicts surfaced in Manual Review Queue. Human resolution determines which SBD is canonical. |
| HS-04 | Score Finality Scope — BR-04 says submitted scores require TA Coordinator approval to edit. But what if the HM makes an obvious data entry error (entered 0 instead of 5 on a scale of 5)? Is a full approval workflow required for clear errors? | Medium | Business rule decision: approval workflow applies to all score edits regardless of magnitude. "Obvious error" exception is a slippery slope. Confirm with compliance stakeholders before domain modeling. |
| HS-05 | Manager Kit Link Expiry Enforcement — If a Hiring Manager has a browser tab with the interview kit open when the link expires, what happens? Does the page go blank immediately? On next action? | Medium | Technical decision: server-side enforcement means next API call returns 403. Client should poll expiry status and gracefully warn HM before expiry. UX decision needed in Step 4. |
| HS-06 | Waitlist Fairness vs. Operational Flexibility — BR-10 says waitlist order cannot be manually overridden. But what if a VIP candidate (CEO's hire) is waitlisted and the business demands priority? | Medium | This is a governance risk. BRD documents the rule as non-overridable. If exceptions must be supported, a formal exception mechanism (with approval and full audit log) must be designed — not an informal override. Escalate to Product Leadership for explicit sign-off. |
| HS-07 | Bulk Advancement and Duplicate Resolution Race Condition — A TA Coordinator could resolve a duplicate in one browser tab while another runs bulk advancement in a second tab. The resolved candidate may or may not be caught by the eligibility check. | Medium | Architecture decision: eligibility check must be evaluated at command execution time (not at selection time). Check must be atomic with the bulk write. |
| HS-08 | Face Capture Legal Risk — Decree 13/2023/ND-CP requires explicit consent for biometric data collection. Even optional face capture at kiosk introduces compliance risk if consent mechanisms are not reviewed by DPO. | Medium | Deferred entirely until DPO legal clearance (FR-25 = P2 deferred). No design work proceeds until legal clears it. |
| HS-09 | Data Residency for Assessment Integration — If the assessment engine decision is "integrate with a foreign SaaS provider," candidate assessment data would leave Vietnamese data center boundaries, violating NFR-09. | High | Must be a blocking gate in vendor evaluation: data residency compliance is non-negotiable per legal (NFR-09). Any assessment SaaS must support Vietnam data residency, or the build decision is forced. |
| HS-10 | Event Cloning and Question Bank Linking — When an event is cloned, are the question bank references copied by value (snapshots) or by reference (live link)? If by reference and the original question bank is modified, the cloned event blueprint changes silently. | Medium | Design decision: question bank links should be copied by reference with a version snapshot at clone time. Changes to the source bank after cloning should not affect already-cloned events without explicit re-link. Discuss in Step 3 domain design. |
| HS-11 | Concurrent Bulk Operations on Same Event — Can two TA Coordinators run bulk advancement simultaneously on the same event? If so, the same candidates could be advanced twice or conflicts could occur. | Medium | Architecture decision: bulk advancement commands on the same event should be serialized. Optimistic locking or a distributed lock per event during bulk operations. Step 3 to address. |
| HS-12 | SMS Dependency Before Gateway Contracted — Some user stories reference SMS as part of the notification flow. If stakeholders assume SMS is available at launch, expectations need to be managed. Email is the sole guaranteed channel. | Low | Communication risk. Product team must clearly communicate SMS deferred status to stakeholders. Email templates must stand alone (not assume SMS supplementation). |

---

## 8. Complete Domain Event Timeline

### Pre-Event Phase

The lifecycle begins when a TA Event Coordinator decides to run a recruitment event. They either create a new event using the creation wizard (DE-01: EventDraftCreated) or clone an existing event (DE-04: EventCloned). During setup, they configure tracks (DE-05: TrackAdded), customize the registration form with event-specific fields (DE-06: FormFieldAdded), and define the schedule matrix of rooms, shifts, and days (DE-24: ScheduleMatrixDefined). Once satisfied, the coordinator publishes the event (DE-02: EventPublished), making it visible in the event registry.

### Registration Phase

The coordinator opens registration (DE-03: RegistrationOpened). Candidates begin submitting the online form (DE-10: CandidateRegisteredOnline). For each registration, the system immediately generates and assigns an SBD (DE-13: SBDAssigned) regardless of email delivery status (BR-01). Simultaneously, multi-factor duplicate detection runs (POL-03); if a potential match is found, a duplicate flag is raised (DE-14: DuplicateFlagged) and the TA Coordinator is notified.

When registered slots fill, incoming candidates are waitlisted (DE-19: CandidateWaitlisted). If a confirmed candidate cancels (DE-21: CandidateCancelled), the first waitlisted candidate is backfilled automatically (DE-20: WaitlistBackfilled, POL-05).

The TA Coordinator works through the Duplicate Tab to resolve all flagged records (DE-15, DE-16, or DE-17) before running bulk operations.

### Assessment Phase

If assessments are configured (and the build/integrate decision has been made), the coordinator dispatches assessments (CMD-22: DispatchAssessment, DE-31: AssessmentDispatched) only to Confirmed candidates (POL-07, BR-07). Candidates complete their assessments (DE-32: AssessmentCompleted). The system auto-grades MCQ items (DE-33: AssessmentAutoGraded, POL-08). Proctoring anomalies are logged as flags (DE-34: ProctoringFlagRaised) but do not auto-disqualify. Essay responses surface in a manual review queue.

### Scheduling Phase

With assessment results available, the coordinator finalizes slot allocations. They review the schedule matrix, adjust capacity if needed (DE-25: CapacityOverridden, before In Progress), and run candidate allocation (CMD-17: RunCandidateAllocation, DE-26: CandidatesAllocatedToSlots). Candidates are confirmed into slots (DE-18: CandidateConfirmed) and reschedule notifications are sent if slots are adjusted (DE-48: RescheduleNotificationSent).

### Event Day Phase

The coordinator starts the event (CMD-07: StartEvent, DE-07: EventTransitionedToInProgress). At this point, structural changes are locked (POL-10, BR-06).

Walk-in candidates arrive at kiosks and are captured (DE-11: CandidateRegisteredAtKiosk). If the venue network drops, the kiosk switches to offline mode automatically (DE-12/DE-29 for offline captures and check-ins). All candidates check in via QR scan or SBD entry (DE-27: CandidateCheckedIn). Each check-in triggers real-time queue display updates (POL-06) within 5 seconds (NFR-03).

Interviewers access their digital interview kits via Session Digest links (DE-37: InterviewKitAccessed). The kit shows their candidate queue in real time. Interviewers conduct interviews (DE-38: CandidateInterviewed) and submit scores (DE-39: InterviewScoreSubmitted), which are immediately locked (POL-09, BR-04). No-show candidates are skipped (DE-43: CandidateSkipped); late arrivals are deferred (DE-44: CandidateDeferred).

When the venue network reconnects after an outage, the kiosk syncs offline records (DE-22: OfflineDataSynced). Sync failures route to the manual review queue (DE-23: SyncFailedToManualReview, POL-13).

Throughout the event, the real-time dashboard refreshes (DE-54: DashboardRefreshed) every 5 seconds showing live pipeline metrics.

### Post-Event Phase

After interviews complete, the coordinator runs bulk outcome recording (CMD-35: RecordBulkOutcomes, DE-47: BulkOutcomeRecorded) to record Pass/Fail/Hold outcomes for all interviewed candidates. Bulk advancement moves candidates to their next stage (DE-45: BulkAdvancementRun) after skip-logic eligibility checks.

The coordinator closes the event (CMD-08: CloseEvent, DE-08: EventClosed). Twenty-four hours after event day, all Session Digest links expire server-side (DE-51: EventKitLinkExpired, POL-11).

Score edit requests (DE-40, DE-41, DE-42) may continue post-event until the final pipeline is closed. Every consequential action throughout generates an audit entry (DE-52: AuditEntryCreated). HR Analytics Lead generates custom reports (DE-53: ReportGenerated) covering pipeline conversion, source attribution, and event ROI.

Eventually, the event is archived (DE-09: EventArchived) for long-term retention with the audit log preserved for minimum 3 years (NFR-06).
