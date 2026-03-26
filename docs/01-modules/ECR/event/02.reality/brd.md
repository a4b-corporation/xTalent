# Business Requirements Document (BRD)
# Event-Centric Recruitment (ECR) — xTalent HCM Solution

---

## 1. Document Control

| Field | Value |
|-------|-------|
| Document Title | Business Requirements Document — Event-Centric Recruitment (ECR) |
| Module | Talent Acquisition > Event Sub-module |
| Solution | xTalent HCM Solution |
| Version | 1.0 |
| Status | Draft |
| Date | 2026-03-25 |
| Author | Business Analysis Team |
| Reviewed By | (pending Gate G2 review) |
| Approved By | (pending) |

### Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-25 | BA Team | Initial draft from Step 1 requirements |

---

## 2. Business Context

### 2.1 Background

Vietnamese enterprises in technology and retail sectors conduct large-scale mass hiring events — Job Fairs, Fresher Programs, Graduate Recruitment Days, and walk-in retail hiring campaigns. These events require processing 500–1,000+ candidates over a 1–2 day window across multiple concurrent assessment and interview tracks.

Traditional Applicant Tracking Systems (ATS) are designed around job-requisition-centric workflows: one job opening generates one pipeline of candidates processed sequentially. This model fundamentally breaks at event scale:

- Sequential workflows cannot accommodate 1,000 simultaneous candidates across multiple parallel tracks
- No native concept of "tracks" (different role types assessed concurrently within one event)
- Candidate identity assumed via email — mass events include walk-in candidates with no prior digital presence
- Onsite logistics require real-time check-in, badge generation, queue management, and scheduling — none of which exist in standard ATS
- Offline operations are necessary at venues with poor or unstable connectivity
- Duplicate detection based solely on email misses candidates who register via phone + student ID

The Event-Centric Recruitment (ECR) module solves these gaps by introducing a first-class "Event" entity as the primary organizing construct, with all ATS functions — candidate capture, assessment, scheduling, interviews, communications, and analytics — subordinate to the event context.

### 2.2 Business Objectives (SMART)

| ID | Objective | Baseline | Target | Deadline |
|----|-----------|----------|--------|----------|
| OBJ-01 | Reduce candidate check-in processing time from paper-based manual lookup | ~30 seconds/candidate | <5 seconds end-to-end via QR/SBD kiosk | Go-live |
| OBJ-02 | Enable TA team to independently create a multi-track event without IT support | Requires IT configuration (days) | TA Coordinator creates event in <15 minutes via self-service wizard | Go-live |
| OBJ-03 | Achieve data accuracy for SBD-to-profile linkage across all event touchpoints | Unknown (paper-based, error-prone) | 99.5% accuracy measured via audit log reconciliation | Go-live |
| OBJ-04 | Process bulk candidate invitations at enterprise scale | Manual email, ~50/hour | 1,000 invitations dispatched within 5 minutes via bulk operations | Go-live |
| OBJ-05 | Enable offline event operations at venues with poor connectivity | Not supported; event stops if network fails | Kiosk operates offline; syncs atomically on reconnect | Go-live |
| OBJ-06 | Reduce duplicate candidate data entry requiring post-event cleanup | High (estimated 5–15% duplicate rate at walk-in events) | <1% unresolved duplicates reaching bulk advancement stage | Go-live |

### 2.3 Key Performance Indicators

| KPI | Measurement Method | Target |
|-----|--------------------|--------|
| KPI-01: Check-in throughput | Audit log: kiosk scan timestamp to status-updated timestamp | <5 seconds P95 |
| KPI-02: Event creation time | Usage analytics: wizard start to event Published state | <15 minutes median |
| KPI-03: SBD linkage accuracy | Reconciliation audit: SBD records vs. candidate profiles post-event | >=99.5% |
| KPI-04: Bulk invitation throughput | Email dispatch log: batch start to last delivery acknowledgment | 1,000 in <5 minutes |
| KPI-05: Concurrent user capacity | Load test during event window | 1,000 concurrent users without degradation |
| KPI-06: Offline sync integrity | Sync log: offline records synced vs. records captured offline | 100% (failures to manual review queue, not lost) |
| KPI-07: Duplicate resolution rate | Dedup audit: duplicates flagged vs. resolved before bulk ops | 100% resolved before bulk advancement |
| KPI-08: System uptime during event windows | Uptime monitoring | >=99.5% |

### 2.4 Scope

#### In Scope

| Capability Group | Functional Requirements |
|-----------------|------------------------|
| Event Lifecycle Management | FR-01 to FR-06 |
| Candidate Capture | FR-07 to FR-10 |
| Candidate Identity & Deduplication | FR-11 to FR-13 |
| Assessment (deferred — see Deferred Items) | FR-14 to FR-18 |
| Scheduling & Capacity Management | FR-19 to FR-22 |
| Onsite Operations | FR-23 to FR-26 (FR-25 deferred) |
| Panel Interview Management | FR-27 to FR-31 |
| Communication & Notifications | FR-32 to FR-35 (FR-35 deferred) |
| Bulk Operations | FR-36 to FR-39 |
| Analytics & Reporting | FR-40 to FR-44 |

#### Out of Scope

| Item | Rationale |
|------|-----------|
| Offer Management | Separate xTalent module |
| Onboarding | Separate xTalent module |
| Payroll | Separate xTalent module |
| Performance Management | Separate xTalent module |
| Video Interviewing | Future phase |

#### Deferred Items (In Scope — Blocked Pending Resolution)

| FR | Description | Blocking Reason | Resolution Owner |
|----|-------------|-----------------|-----------------|
| FR-14 to FR-18 | Assessment Engine (question bank, blueprint, delivery, auto-grading, proctoring) | Build vs. integrate decision pending | Product Leadership |
| FR-25 | Biometric Face Capture at kiosk | Pending legal review of Decree 13/2023/ND-CP (Vietnam biometric data regulations) | Legal / DPO |
| FR-07 / FR-35 | SMS Gateway integration for candidate notifications | Pending SMS vendor selection and contract | Procurement |
| FR-26 | Badge Printing from kiosk | Pending hardware standardization across venues | IT Infrastructure |

---

## 3. Stakeholder Analysis

| Stakeholder | Role | Interest | Influence | Needs |
|-------------|------|----------|-----------|-------|
| TA Event Coordinator | Primary system user; creates and manages events end-to-end | High | High | Self-service event creation, bulk ops, real-time visibility, communication tools |
| Hiring Manager / Panel Interviewer | Conducts panel interviews at events | High | Medium | Digital interview kit, score submission, queue visibility, mobile access |
| Candidate — Fresher | Job seeker applying via online registration or campus fair | High | Low | Simple registration, clear confirmation, SMS/email updates, accessible portal |
| Candidate — Experienced | Professional applying to a targeted event | High | Low | Online pre-registration, assessment access, scheduling transparency |
| Candidate — Walk-In | Unregistered candidate arriving on event day | High | Low | Fast walk-in capture via kiosk, immediate SBD assignment, clear queue instructions |
| Onsite Operations Staff | Manages kiosk stations and physical candidate flow at venue | Medium | Medium | Reliable kiosk (offline capable), fast SBD lookup, badge printing |
| HR Analytics Lead | Consumes post-event reports, pipeline metrics, source data | Medium | Medium | Real-time dashboard, dynamic reports, audit trail access |
| xTalent Platform Team | Owns RBAC, Job Request API, shared infrastructure | Low | High | Clean API contracts, no RBAC bypass, data residency compliance |
| IT / Infrastructure | Manages venue connectivity and hardware | Low | High | Offline-first architecture, hardware-agnostic kiosk design |
| Legal / DPO | Reviews biometric data usage and data residency compliance | Low | High | Compliance with Decree 13/2023, PDPD, data residency in Vietnam |
| Procurement | Manages vendor contracts (SMS gateway, hardware) | Low | Medium | Vendor evaluation support, clear technical requirements |

---

## 4. Business Requirements

Business requirements are organized by capability group. Priority levels: P0 = Must Have (launch blocker), P1 = Should Have (high value, non-blocking), P2 = Nice to Have (future phase candidate).

---

### 4.1 Event Lifecycle Management

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-ELM-01 | Event Creation Wizard | TA Coordinator must be able to create a complete event (name, dates, venue, tracks, capacity, forms) via a self-service wizard without IT support | P0 | FR-01 | Wizard completes in <15 minutes; all required fields validated; event saved as Draft on completion |
| BR-ELM-02 | Event Cloning | TA Coordinator must be able to clone a previous event, inheriting structure (tracks, capacity, forms, question bank) while resetting operational data (candidate records, SBDs, scores) | P0 | FR-02 | Cloned event created in Draft state; original event unchanged; candidate data not copied; clone completes in <30 seconds |
| BR-ELM-03 | Event State Machine | Event must progress through defined states with controlled transitions; structural changes prohibited once In Progress | P0 | FR-03, BR-06 | States: Draft → Published → Registration Open → In Progress → Closed → Archived; invalid transitions rejected with descriptive error; transition log maintained |
| BR-ELM-04 | Multi-Track Support | TA Coordinator must be able to define multiple concurrent tracks within a single event | P0 | FR-04 | Minimum 1 track required; maximum 20 tracks per event; each track has independent capacity, schedule, and assessment configuration |
| BR-ELM-05 | Dynamic Form Builder | TA Coordinator must be able to configure custom registration form fields per event or per track | P1 | FR-05 | Standard fields pre-populated; custom fields addable (text, dropdown, file upload, date); form preview before publish; field order adjustable |
| BR-ELM-06 | Event Lifecycle Phases | System must support distinct operational phases with phase-appropriate UI controls | P0 | FR-06 | Phases: Pre-Event, Registration, Assessment, Scheduling, Event Day, Post-Event; phase transitions logged; phase-specific dashboards active; unauthorized transitions blocked |

### 4.2 Candidate Capture

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-CC-01 | Online Registration Form | Candidates must be able to register for an event via a public, mobile-responsive web form | P0 | FR-07 | Form accessible without login; mobile-responsive (375px+); CV file upload supported; confirmation email sent on submission; SBD generated immediately |
| BR-CC-02 | QR Walk-In Kiosk Capture | Walk-in candidates must be captured via a QR-enabled kiosk that creates a candidate record and generates SBD in real time | P0 | FR-08 | Kiosk form completion in <2 minutes; SBD generated immediately; SBD printed or displayed to candidate; duplicate check triggered |
| BR-CC-03 | Offline Candidate Capture | Kiosk must capture candidate data offline and sync when connectivity is restored | P0 | FR-09, BR-08 | Data captured offline stored locally with provisional status; sync triggered on reconnect; sync atomic per record; failed records routed to manual review queue, not lost |
| BR-CC-04 | SBD Generation | System must auto-generate a unique Số Báo Danh (SBD) for each registered candidate per event | P0 | FR-10, BR-01 | SBD unique within event; format configurable by event (prefix + sequence number); generated regardless of email delivery success; printed/displayed immediately at point of capture |

### 4.3 Candidate Identity & Deduplication

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-IDM-01 | Multi-Factor Duplicate Detection | System must detect potential duplicate candidate records using multiple identity signals | P0 | FR-11 | Detection runs on every new registration; matching rules: phone + student ID, phone + name + DOB, email + phone; confidence score displayed to reviewer; configurable thresholds per event |
| BR-IDM-02 | Human Duplicate Resolution | All detected duplicates must be routed to human review; system must never auto-merge or auto-reject | P0 | FR-12, BR-02 | Duplicate flagged and queued for review; reviewer sees both records side-by-side with confidence score; actions: Merge, Keep Both, Reject Duplicate; all resolutions logged with actor and timestamp |
| BR-IDM-03 | Duplicate Tab in Event Dashboard | TA Coordinator must have a dedicated duplicate management view per event | P1 | FR-13 | Duplicate tab shows count of unresolved; list sortable/filterable; resolution actions accessible inline; candidates with unresolved duplicates blocked from bulk advancement (BR-03) |

### 4.4 Assessment (Deferred — Pending Build vs. Integrate Decision)

Note: FR-14 to FR-18 are in scope but delivery is blocked pending the build vs. integrate decision. Requirements are documented for planning and interface design purposes. No implementation begins until the decision is made.

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-ASS-01 | Question Bank | System must support a structured question bank with tags, difficulty levels, and question types | P1 | FR-14 | Questions tagged by topic, difficulty, type (MCQ, essay, coding); bank searchable and filterable; questions reusable across events |
| BR-ASS-02 | Assessment Blueprint & Randomization | TA Coordinator must define an assessment blueprint and generate randomized question sets from the bank | P1 | FR-15 | Blueprint defines section counts and difficulty distribution; randomization produces unique sets per candidate within blueprint constraints; blueprint saveable as template |
| BR-ASS-03 | Assessment Delivery Gate | System must deliver assessments only to candidates in Confirmed or Checked-In status | P0 | FR-16, BR-07 | Assessment link sent only when candidate status = Confirmed or Checked-In; link is time-limited; access events logged; no delivery to Registered, Waitlisted, or No-Show candidates |
| BR-ASS-04 | Auto-Grading | System must auto-grade objective question types and flag subjective types for manual review | P1 | FR-17 | MCQ auto-graded with score visible to TA; essay/coding flagged for manual reviewer; partial scoring configurable per question |
| BR-ASS-05 | Proctoring Flags | System must log suspicious behaviors during online assessment for reviewer inspection | P2 | FR-18 | Tab-switch count, copy-paste events, and time-outside-window logged; flags visible to reviewer; no auto-disqualification on flags alone |

### 4.5 Scheduling & Capacity

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-SCH-01 | Schedule Builder | TA Coordinator must define a Day x Shift x Room capacity matrix for the event | P0 | FR-19 | Matrix UI supports multi-day events; each cell defines room capacity per shift; double-booking conflicts detected and rejected; schedule saveable as template |
| BR-SCH-02 | Smart Allocation | System must allocate candidates to schedule slots using configurable strategies | P0 | FR-20 | Strategies available: Round-Robin (distribute evenly), Fill-First (maximize room utilization); strategy selectable per track; allocation preview shown before confirmation |
| BR-SCH-03 | Waitlist & Backfill | Candidates beyond capacity enter a waitlist; cancellations trigger automated backfill | P0 | FR-21, BR-10 | Waitlist position assigned by registration timestamp (first-come-first-served); cancellation triggers backfill notification to next waitlisted candidate; backfill ordering cannot be manually overridden |
| BR-SCH-04 | Capacity Override | TA Coordinator may override room capacity with mandatory reason logging | P1 | FR-22 | Override requires confirmation dialog; reason field mandatory; override logged with actor, timestamp, old capacity, new capacity; override blocked during In Progress state (BR-06) |

### 4.6 Onsite Operations

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-ONS-01 | Kiosk Check-In via QR and SBD | Onsite staff and candidates must check in via QR code scan or manual SBD entry in under 5 seconds | P0 | FR-23 | Check-in end-to-end (scan/entry to status updated) completes in <5 seconds P95; both QR scan and SBD manual entry supported; duplicate check-in detected and rejected with clear message |
| BR-ONS-02 | Offline Kiosk Mode | Kiosk must fully function without network connectivity | P0 | FR-24, BR-08 | Kiosk enters offline mode automatically on network loss; all check-in and capture operations continue; data queued locally with provisional status; sync triggered on reconnect; sync status visible to operator |
| BR-ONS-03 | Biometric Face Capture | Kiosk may capture candidate photo for identity verification | P2 | FR-25 | DEFERRED — no implementation until legal clearance from DPO for Decree 13/2023/ND-CP compliance |
| BR-ONS-04 | Badge Printing | Kiosk triggers badge print on successful check-in | P1 | FR-26 | DEFERRED — pending hardware standardization; badge template configurable per event; integration via standard printer protocol |

### 4.7 Panel Interview Management

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-PNL-01 | Interviewer Assignment | TA Coordinator must assign interviewers to sessions as hard (mandatory) or soft (preferred) assignments, or in queue mode | P0 | FR-27 | Hard assignments lock interviewer to session; soft assignments shown as preferred; queue mode allows any available assigned interviewer to take next candidate; assignment type logged |
| BR-PNL-02 | Digital Interview Kit | Hiring Manager must receive a secure, time-limited link to a digital interview kit (candidate profile, scoring rubric, note area) | P0 | FR-28, BR-05 | Kit link generated per session per HM; accessible without xTalent login; link expires 24h after event day (server-side enforced); kit is read-only for candidate profile data |
| BR-PNL-03 | Real-Time Queue Display | Onsite staff and Hiring Manager must see real-time candidate queue status per interview room | P0 | FR-29 | Queue updates within 5 seconds of check-in event; statuses shown: Waiting, In Interview, Completed, Skipped, Deferred; display auto-refreshes without manual reload |
| BR-PNL-04 | Skip and Defer | Interviewer must be able to skip (mark absent) or defer (reschedule within event) a candidate from the queue | P1 | FR-30 | Skip records candidate as No-Show and removes from active queue; Defer moves candidate to end of current queue or next available slot; both actions audit-logged with actor and reason |
| BR-PNL-05 | Score Submission | Hiring Manager must submit structured interview scores; edits to submitted scores require TA Coordinator approval | P0 | FR-31, BR-04 | Score form defined by event rubric; submission locks score; edit request triggers approval workflow to TA Coordinator; all changes (original, new, requester, approver, timestamp) audit-logged |

### 4.8 Communication & Notifications

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-COM-01 | Bulk Email Dispatch | System must send bulk emails at 500 emails/minute throughput with delivery tracking | P0 | FR-32 | Bulk email triggered by TA Coordinator; template-based with personalization tokens (name, SBD, schedule slot); delivery status tracked per candidate; failed deliveries retried with configurable backoff |
| BR-COM-02 | Session Digest for Hiring Manager | System must send a Session Digest notification to Hiring Managers with interview schedule and kit link | P0 | FR-33, BR-05 | Digest includes: candidate list, time slots, room assignment, link to digital interview kit; sent 24–48h before event day; kit links expire 24h after event day |
| BR-COM-03 | Reschedule Notifications | System must notify candidates of schedule changes with updated slot details | P1 | FR-34 | Triggered on any confirmed candidate's schedule modification; notification includes old slot, new slot, and reason; sent via email (SMS added when gateway available) |
| BR-COM-04 | SMS Notifications | System may send SMS as a complement to email notifications | P2 | FR-35 | DEFERRED — pending SMS vendor selection; email is primary channel; SMS is additive once gateway contracted |

### 4.9 Bulk Operations

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-BLK-01 | Bulk Stage Advancement | TA Coordinator must advance multiple candidates through pipeline stages in a single operation | P0 | FR-36 | Multi-select candidates; choose target stage; skip-logic eligibility check runs before advancement; unresolved duplicates excluded and surfaced (BR-03); operation logged with actor, timestamp, count |
| BR-BLK-02 | Skip-Logic Eligibility Check | System must evaluate eligibility rules before bulk advancement and surface exceptions | P0 | FR-37 | Eligibility pop-up shows: eligible count, ineligible count with per-reason breakdown, unresolved duplicate count; TA can proceed with eligible subset, address exceptions, or cancel entire operation |
| BR-BLK-03 | Bulk Invitation Dispatch | TA Coordinator must dispatch invitations to a candidate cohort in bulk | P0 | FR-38 | Bulk dispatch to 1,000 candidates in <5 minutes; template selection required; delivery tracking per candidate; dispatch job runs asynchronously with progress indicator |
| BR-BLK-04 | Bulk Outcome Recording | TA Coordinator must record Pass/Fail/Hold outcomes for multiple candidates simultaneously | P1 | FR-39 | Outcomes: Pass, Fail, Hold, No-Show; bulk update with mandatory reason; all outcomes audit-logged with actor, timestamp, and justification |

### 4.10 Analytics & Reporting

| BR-ID | Title | Description | Priority | FR Reference | Acceptance Criteria |
|-------|-------|-------------|----------|--------------|---------------------|
| BR-ANL-01 | Real-Time Event Dashboard | TA Coordinator must view live metrics during event execution | P0 | FR-40 | Dashboard auto-refreshes every 5 seconds; metrics visible: total registered, checked-in, in assessment, in interview, passed, failed, no-show; per-track breakdown available |
| BR-ANL-02 | Dynamic Report Builder | HR Analytics Lead must build custom reports by selecting dimensions and metrics | P1 | FR-41 | Field-select or drag-and-drop UI; reports exportable to CSV and Excel; reports saveable as named templates; access controlled by RBAC |
| BR-ANL-03 | Pipeline Metrics | System must compute and display pipeline conversion metrics per stage and per track | P1 | FR-42 | Funnel view: Registered → Assessed → Scheduled → Interviewed → Passed; conversion rate per stage; per-track breakdown; time-in-stage averages |
| BR-ANL-04 | Source Attribution | System must attribute candidate source for ROI analysis | P2 | FR-43 | Source captured at registration (online form, QR walk-in, campus partner, referral); reports filterable by source; cost-per-hire estimable when source cost is entered |
| BR-ANL-05 | Audit Log | System must maintain a complete, tamper-evident audit trail for all consequential actions | P0 | FR-44, BR-04, BR-06, BR-08 | Audit covers: score changes, bulk operations, duplicate resolutions, capacity overrides, structural changes; log searchable by actor, event, timestamp, action type; append-only; retained minimum 3 years |

---

## 5. Business Rules Catalog

| BR-ID | Rule Name | Description | Source | Impact if Violated |
|-------|-----------|-------------|--------|-------------------|
| BR-01 | SBD Decoupling | SBD is valid and operational regardless of email delivery status. SBD is generated at the point of registration capture, not at point of email confirmation. | Onsite operations requirement | Walk-in candidates without email access cannot participate; onsite ops collapse if SBD requires email delivery to be valid |
| BR-02 | Duplicate Resolution Is Human | The system must never auto-merge or auto-reject duplicate candidate records. All duplicate resolution decisions must be made by a human (TA Coordinator). | Data integrity requirement | Auto-merge could destroy valid separate candidate records; auto-reject could exclude legitimate candidates without due process |
| BR-03 | Bulk Advancement Exclusions | Candidates with unresolved duplicate flags are ineligible for bulk stage advancement. They must be resolved first or explicitly excluded by the TA Coordinator with acknowledgment. | Data integrity requirement | Duplicate records advancing independently create split pipeline histories that are irreconcilable post-event |
| BR-04 | Score Finality | Submitted interview scores are locked. Any edit requires explicit TA Coordinator approval. All changes (original value, new value, requester, approver, timestamp) are recorded in the audit log. | Compliance / fairness requirement | Unlogged score changes enable score manipulation, creating legal and fairness liability |
| BR-05 | Manager Link Expiry | Session Digest links sent to Hiring Managers expire exactly 24 hours after the event day ends. Expiry is server-side enforced; client-side caching does not extend access. | Security requirement | Expired links allow unauthorized access to candidate PII after the event context is closed |
| BR-06 | Event Structural Immutability In Progress | Once an event transitions to In Progress state, no structural changes are permitted: no track additions/removals, no room/shift capacity changes, no form field modifications. Operational updates (individual schedule adjustments, score entry, status updates) remain permitted. | Operational integrity requirement | Structural changes mid-event invalidate SBD assignments, schedule commitments, and assessment configurations already in active use |
| BR-07 | Assessment Delivery Gate | Assessment access is delivered only to candidates whose status is Confirmed or Checked-In. Candidates in Registered, Waitlisted, or No-Show status do not receive assessment links. | Assessment fairness requirement | Unconfirmed candidates accessing assessments creates unfair advantage and pollutes assessment result data |
| BR-08 | Offline Data Integrity | Data captured in offline mode is marked provisional until server-side sync is confirmed. Sync failures do not result in data loss; failed records are routed to a manual review queue. Sync is atomic per record; partial record states are not permitted. | Data integrity / continuity requirement | Non-atomic sync could create partial records; data loss in sync creates candidate experience failures (missing SBD, failed check-in) |
| BR-09 | Per-Event RBAC | Role assignments for an event (coordinator, interviewer, analytics viewer) are per-event, not global. Per-event assignments extend but do not override the xTalent platform RBAC model. | Security requirement | Global role sharing allows coordinators from one business unit to access candidate data from another unit's events |
| BR-10 | Waitlist Ordering | Waitlist backfill is strictly first-come-first-served based on registration timestamp. Manual reordering of waitlist position is not permitted. Capacity override by coordinator is a separate operation from waitlist ordering. | Fairness / compliance requirement | Manual reordering creates favoritism liability and undermines candidate trust |

---

## 6. Non-Functional Requirements

| NFR-ID | Category | Requirement | Measurement Criteria | Priority |
|--------|----------|-------------|---------------------|----------|
| NFR-01 | Performance | System must support 1,000 concurrent users during active event windows without performance degradation | P95 API response time <2 seconds under 1,000 concurrent users; validated by load test before go-live | P0 |
| NFR-02 | Performance | Kiosk check-in end-to-end (scan/entry to status confirmed) must complete in <5 seconds | P95 <5 seconds measured from QR scan event to confirmed status write in system; tested in offline and online modes | P0 |
| NFR-03 | Real-Time | Check-in event must be reflected on HM queue display within 5 seconds | P95 <5 seconds from check-in timestamp to queue display timestamp; tested under concurrent load | P0 |
| NFR-04 | Reliability | Offline kiosk data must sync atomically on reconnect; no records may be lost in sync | Zero data loss in sync (100% of offline records either synced successfully or placed in manual review queue); no partial record states permitted | P0 |
| NFR-05 | Security | Session Digest links for Hiring Managers expire 24h after event day; expiry is server-side | Automated test: link returns HTTP 403 after expiry timestamp; CDN and browser cache cannot extend access; verified per deployment | P0 |
| NFR-06 | Compliance | Audit trail maintained for all score changes, bulk operations, duplicate resolutions, and structural changes | Audit log queryable by actor, event, action type, timestamp; entries are append-only (tamper-evident); minimum retention 3 years | P0 |
| NFR-07 | Usability | Candidate portal and HM interview kit must be mobile-responsive | Functional on screen widths >=375px; tested on iOS Safari and Android Chrome; WCAG 2.1 AA pass on candidate-facing screens | P0 |
| NFR-08 | Localization | Vietnamese is the primary UI language; English is secondary | All UI strings available in Vietnamese; language toggle accessible on all screens; no hard-coded English-only strings on candidate-facing interfaces | P1 |
| NFR-09 | Compliance | All data must reside in Vietnam | All storage, processing, and backup infrastructure in Vietnam data centers; no data egress to foreign jurisdictions; verified by architecture review and legal sign-off before go-live | P0 |
| NFR-10 | Accessibility | Candidate-facing interfaces must meet WCAG 2.1 Level AA | Automated scan (axe or equivalent) passes on candidate registration form, assessment portal, and status portal; manual screen reader test on critical flows | P0 |
| NFR-11 | Security | Per-event RBAC role assignments must be extensible from xTalent platform RBAC | Per-event roles assignable by TA Coordinator without platform admin intervention; assignments do not bypass xTalent base RBAC; per-event role audit log maintained | P0 |
| NFR-12 | Reliability | 99.5% uptime SLA during active event windows | Uptime measured per calendar month during event windows; planned maintenance windows excluded from active event times; P1 incident response within 1 hour | P0 |

---

## 7. Constraints & Assumptions

### 7.1 Constraints

| ID | Constraint | Impact on Design |
|----|------------|-----------------|
| CON-01 | Data residency in Vietnam (NFR-09) | Cloud provider must have Vietnam region; foreign SaaS components for assessment must be evaluated for data routing compliance before integration |
| CON-02 | xTalent Job Request API dependency | Event tracks link to Job Requests; if API is unavailable at go-live, fallback (freeform job title entry) must be designed in |
| CON-03 | xTalent RBAC model extensibility required | Per-event roles must operate within the existing xTalent permission model; no custom permission stores that bypass xTalent RBAC |
| CON-04 | SMS gateway not contracted at launch | Email is the sole guaranteed notification channel; system must not have SMS as a dependency for any P0 flows |
| CON-05 | Face capture legally blocked | Kiosk identity verification is QR + SBD only; no biometric data collection until DPO legal clearance |
| CON-06 | Badge printing hardware not standardized | Badge printing deferred; kiosk hardware integration layer must be designed to be hardware-agnostic |
| CON-07 | Assessment build vs. integrate decision pending | Assessment interface contract (input: candidate context; output: score) must be defined regardless of decision; no assessment implementation begins until decision is made |

### 7.2 Assumptions

| ID | Assumption | Impact if False |
|----|------------|----------------|
| ASM-01 | Candidates at events have a mobile phone number as minimum identity signal | Multi-factor dedup loses primary matching key; matching strategy must be redesigned |
| ASM-02 | Venue WiFi is available but unreliable (justifies offline mode); kiosks have stable power | Fully offline venues (no WiFi at all) require a different sync initiation mechanism (e.g., manual sync trigger, USB) |
| ASM-03 | SBD format is numeric with configurable prefix (e.g., "ECR2026-0001"); format governance owned by TA Coordinator per event | If enterprise-wide SBD format is mandated centrally, format builder must integrate with a central governance service |
| ASM-04 | Events have a maximum of 2 days duration at launch | Multi-day scheduling matrix design needs extension for programs spanning 3+ days (e.g., internship selection weeks) |
| ASM-05 | xTalent Job Request API will be available for integration by ECR go-live | If API not ready, event tracks require freeform fallback; post-launch linkage as a P1 enhancement |
| ASM-06 | Hiring Managers do not have xTalent accounts and access interview kits via secure link without login | If HMs have xTalent accounts, kit link design changes to authenticated session; link expiry mechanism still applies |
| ASM-07 | Assessment is delivered online; no paper-based assessment digitization required | Paper scoring workflow would require a separate manual score entry interface |
| ASM-08 | Walk-in capture volume peaks at 200 candidates/hour per kiosk station | Higher peak rates require a kiosk scaling plan; performance model must be revisited if volume exceeds this |

---

## 8. Risks & Mitigations

| Risk-ID | Description | Category | Probability | Impact | Risk Level | Mitigation |
|---------|-------------|----------|-------------|--------|------------|------------|
| Risk-01 | Assessment scope creep — build vs. integrate decision delays the entire module or causes a mid-development pivot | Scope | High | High | Critical | Timebox decision to 4 weeks from BRD sign-off; define integration interface contract regardless of decision; FR-14–18 development does not begin until decision is recorded |
| Risk-02 | Offline architecture complexity — sync conflicts, data loss, or consistency failures at scale under concurrent kiosk operations | Technical | Medium | High | High | Proof-of-concept for offline sync before full development sprint; define conflict resolution protocol in domain design phase; NFR-04 is the acceptance gate |
| Risk-03 | Legal blocking of face capture — Decree 13/2023 compliance review delays or permanently blocks FR-25 | Legal | Medium | Medium | Medium | Design kiosk without face capture dependency; FR-25 is P2 and strictly additive; no launch dependency on biometric capability |
| Risk-04 | SBD format governance — multiple coordinators using incompatible formats causes cross-event reporting confusion | Operational | Low | Medium | Low-Medium | Define SBD format governance policy in pilot; enforce prefix uniqueness per event at platform level; document governance in operational handbook |
| Risk-05 | xTalent Job Request API not ready at ECR go-live | Integration | Medium | Medium | Medium | Design ECR with freeform fallback for track-to-job-request linkage; API linkage as a P1 post-launch enhancement |
| Risk-06 | Bulk email throttling — email delivery provider throttles or rejects large sends above threshold | Technical | Low | High | Medium | Select provider supporting 500/min; implement retry with exponential backoff; delivery tracking per candidate; alert TA Coordinator on delivery failures |
| Risk-07 | Data residency breach — third-party component routes data outside Vietnam | Compliance | Low | High | Medium | Mandatory architecture review gate before any third-party integration; legal sign-off on data flow for each external system; DPO approval required |

---

## 9. Glossary

| Term | Definition |
|------|------------|
| SBD (Số Báo Danh) | Candidate serial number assigned per event. Vietnamese term for "examination number." Serves as the primary onsite identity token for a candidate at a specific event. Unique within an event. Generated at point of capture, valid regardless of email delivery. |
| Track | A distinct assessment and interview stream within a single event, targeting a specific role type or candidate profile (e.g., "Software Engineering Track," "Business Development Track"). Each track has independent capacity, schedule, and assessment configuration. |
| Event | The primary organizing construct in ECR. A bounded hiring activity with defined dates, venue, tracks, capacity, and a lifecycle state machine. Analogous to a "job fair" or "recruitment drive." |
| Phase | A major lifecycle stage of an event: Pre-Event, Registration, Assessment, Scheduling, Event Day (In Progress), Post-Event. Each phase has distinct permitted actions and UI controls. |
| Shift | A named time slot within an event day (e.g., "Morning 08:00–12:00"). Combined with Rooms and Days to form the scheduling capacity matrix. |
| Kiosk | A dedicated hardware + software station at the event venue used for walk-in candidate registration, QR check-in, and (deferred) badge printing. Must support offline operation. |
| Session Digest | A notification sent to Hiring Managers containing their interview schedule, candidate list, room assignment, and a secure link to their digital interview kit. Links expire 24h after event day (server-side enforced). |
| Panel | The structured interview stage of an event where Hiring Managers conduct interviews using a digital interview kit (candidate profile + scoring rubric + notes) with score submission. |
| Waitlist | A queue of candidates who registered after capacity was reached. Backfilled into confirmed slots when cancellations occur, in strict first-come-first-served order by registration timestamp. |
| Blueprint | An assessment configuration document defining: number of questions per section, difficulty distribution, question type mix, time limit, and randomization rules. Used to generate candidate-specific question sets from the question bank. |
| Dedup / Duplicate Detection | The process of identifying candidate records that may represent the same individual, using multi-factor matching. All resolution decisions are human-driven per BR-02. |
| Bulk Operation | An action applied to multiple candidates simultaneously (stage advancement, invitation dispatch, outcome recording). Subject to eligibility checks (BR-03) and skip-logic before execution. |
| Skip-Logic | Business rules that determine a candidate's eligibility for a specific stage transition based on prior outcomes, unresolved flags, or event configuration. Ineligible candidates are surfaced for human review before bulk operations execute. |
| Offline Mode | A kiosk operating state in which network connectivity is unavailable. All candidate capture and check-in operations continue using local storage; data is marked provisional and synced atomically when connectivity is restored. |
| Manual Review Queue | A holding queue for records that fail automated processing (sync failures, unresolvable conflicts). Requires human action to resolve or dismiss. No records are silently discarded. |
| RBAC | Role-Based Access Control. xTalent's permission model. ECR extends RBAC with per-event role assignments that do not bypass the base model. |
| TA Event Coordinator | The primary internal actor who creates, configures, and manages recruitment events from inception through post-event reporting. |
| Hiring Manager (HM) | A business stakeholder who conducts panel interviews at events. Accesses their interview kit via a secure link without requiring a full xTalent account login. |
| Walk-In Candidate | A candidate who arrives at an event venue without prior online registration. Captured via kiosk walk-in flow and assigned an SBD immediately. |
| Provisional Data | Candidate records captured in offline mode that have not yet been confirmed by server-side sync. Marked provisional until sync is confirmed; visible in the manual review queue if sync fails. |
| Aggregate | In domain-driven design, a cluster of domain objects treated as a single unit for data consistency. Each aggregate has a root entity that enforces business rules for the cluster (e.g., Event Aggregate, Candidate Aggregate). |
