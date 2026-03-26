# Requirements: Talent Acquisition — Event (ECR) Module
*xTalent HCM Solution | Step 1: Pre-Reality*
*Date: 2026-03-25*

---

## 1. Executive Summary

Vietnamese enterprises conducting mass-hiring campaigns — technology companies running annual Fresher programs, retail chains organizing Job Fairs, and walk-in recruitment drives — face a structural mismatch between their operational reality and the tools available to them. Traditional Applicant Tracking Systems (ATS) are designed around job requisitions: one requisition, one pipeline, sequential stages. When a company expects 1,000 candidates to arrive at a venue over two days, each competing for positions across multiple tracks, that model breaks entirely.

The Event-Centric Recruitment (ECR) module is a purpose-built capability within xTalent that restructures the recruitment data model around the event as the primary organizing unit. An event contains multiple recruitment tracks (for example: Game Development, Game Design, Quality Control), each mapped to distinct job requests with their own question sets, assessment blueprints, and interviewer panels. Candidates register once and are routed through the correct track. Onsite operations — check-in, badge printing, queue management, panel coordination — are handled within the same system, eliminating the clipboard-and-spreadsheet fallback that currently dominates Vietnamese enterprise practice.

This requirements document captures the full scope of the ECR module: from event creation through post-event reporting, including online assessment, scheduling, kiosk operations, panel interview management, bulk communications, and analytics. The goal is to give the downstream Business Analyst team a precise, unambiguous foundation for writing the Business Requirements Document (BRD).

---

## 2. Problem Statement

Traditional ATS platforms are job-requisition-centric. Each candidate application links to exactly one open position and moves through a sequential pipeline. This model is inadequate for mass hiring events where:

1. **Scale breaks sequential workflows.** Processing 500–1,000 candidates through manual scheduling, individual email invitations, and per-candidate stage transitions is not operationally feasible within a two-day event window.

2. **Multi-track hiring has no native representation.** A single Job Fair may simultaneously recruit for 10 different roles. There is no standard ATS concept for "one event, many tracks, shared physical resources."

3. **Onsite identity management is unresolved.** Candidate email addresses are frequently personal, non-unique (multiple candidates sharing one family email), or temporarily inaccessible on a mobile device. A short numeric identifier — Số Báo Danh (SBD) — is the operational standard in Vietnamese hiring events, but no existing platform supports it natively.

4. **Offline operations are not supported.** Event venues in Vietnam frequently have unreliable internet. Kiosk check-in, face capture, and queue display must function without connectivity and reconcile with the central system when connectivity is restored.

5. **Duplicate candidate detection requires multi-factor logic.** A candidate may register online, then also walk in on the day. Phone number + student ID + name matching is required; email alone is insufficient.

The ECR module must solve all five problems within a single coherent system embedded in the xTalent HCM platform.

---

## 3. Target Users & Personas

### Persona 1: TA Event Coordinator (Primary Creator)

**Role:** Talent Acquisition specialist responsible for planning and configuring the recruitment event.

**Goals:**
- Create the event structure (tracks, schedules, rooms, panels) without engineering assistance
- Monitor registration numbers and adjust capacity dynamically
- Generate bulk invitations and confirmations without manual email drafting
- Access real-time dashboards during the event

**Pain Points:**
- Currently maintains event configuration in Excel, shared across multiple TA team members with merge conflicts
- Sends individual confirmation emails or relies on batch mail-merge scripts outside the ATS
- Cannot see live check-in status or queue depth during the event

**Key Workflows:**
- Event creation wizard: define name, date range, tracks, registration form
- SBD batch generation before event day
- Session Digest dispatch to Hiring Managers the evening before
- Live event dashboard monitoring

### Persona 2: Hiring Manager / Panel Interviewer

**Role:** Line manager or senior IC conducting structured interviews at the event.

**Goals:**
- See their interview queue for the day without navigating complex ATS menus
- Score candidates on a mobile device between back-to-back interviews
- Access candidate CV and assessment results at the moment of interview, not beforehand

**Pain Points:**
- Currently receives a printed list of candidates in the morning; list becomes stale within hours as candidates no-show or are added
- Scores candidates on paper forms that must be manually entered into the system post-event
- Has no visibility into whether a candidate has actually arrived and been checked in

**Key Workflows:**
- Receive Session Digest notification the evening before their scheduled panel slots
- Open digital interview kit (CV, assessment score, track-specific question guide) per candidate
- Score and submit evaluation in real time
- Request to skip or defer a candidate with reason code

### Persona 3: Candidate (Fresher / Experienced / Walk-In)

**Role:** Applicant engaging with the event, either pre-registered or arriving on the day.

**Goals:**
- Complete registration quickly from a mobile device
- Know their SBD and scheduled time slot before arriving
- Check in at the venue without queuing at a staffed desk

**Pain Points:**
- Currently fills out paper forms at the venue, which are re-keyed into spreadsheets
- Receives no confirmation or schedule update after registration
- Does not know which room or panel they are assigned to until they physically ask staff

**Key Workflows:**
- Online registration via mobile web form or QR code scan
- Receive SBD and schedule confirmation by email/SMS
- Self-service kiosk check-in on event day
- Receive reschedule notification if their assigned slot changes

### Persona 4: Onsite Operations Staff

**Role:** TA coordinator or admin staff managing the physical check-in desk and kiosk.

**Goals:**
- Process candidate check-in at speed (target: under 30 seconds per candidate)
- Print name badges without manual lookup
- Handle walk-in candidates who have no pre-registration
- Manage queue overflow and room reassignment

**Pain Points:**
- Currently runs a laptop with a local Excel file; connectivity is unreliable
- Badge printing requires a separate tool not integrated with the ATS
- Walk-in candidates must be manually added to a spreadsheet before they can be slotted

**Key Workflows:**
- Kiosk QR scan or SBD entry → instant check-in confirmation
- Walk-in registration at kiosk: capture name, phone, student ID, take photo
- Offline mode: continue check-in operations during connectivity loss, auto-sync on reconnect
- Badge print trigger from kiosk upon successful check-in

### Persona 5: HR Analytics / Compliance Officer

**Role:** HR leadership or compliance team reviewing event outcomes and data governance.

**Goals:**
- Export post-event reports by track, source, outcome
- Confirm that manager access links to candidate data have expired per policy
- Track pipeline conversion rates across events over time

**Pain Points:**
- Post-event data lives in multiple Excel files owned by different TA team members
- No standard report format; each event report is manually assembled
- No audit trail for when manager links were generated and when they expired

**Key Workflows:**
- Generate dynamic report by event, track, stage outcome
- Verify manager link expiry log
- Export aggregate KPI metrics for executive review

---

## 4. Market Context & Competitive Landscape

### Vietnamese Market Specifics

- **Fresher hiring season:** Vietnamese tech companies (VNG, FPT, VinGroup tech subsidiaries, Nashtech, KMS Technology) run annual Fresher campaigns targeting university graduates from October to December and from March to May. Event scales routinely reach 500–1,000 candidates over 2–3 days.
- **Retail mass hiring:** Chains such as Mobile World Group (MWG), Co.opmart, and Vinmart operate continuous walk-in recruitment at regional career fairs. Candidate volume is high; track depth is shallow (2–3 stages).
- **Student ID as identity anchor:** Unlike Western markets where email is the primary identity signal, Vietnamese university students are reliably identified by their student ID number (MSSV) and personal phone number. Email uniqueness cannot be assumed.
- **On-premise or private-cloud preference:** Large Vietnamese enterprises express strong preference for data residency within Vietnam, which affects hosting architecture decisions.
- **Offline venue reality:** University campuses and convention centers used for Job Fairs frequently have overloaded shared Wi-Fi. Any system that requires persistent internet for basic check-in will fail in practice.

### Competitive Landscape

| Capability | Avature | Yello | Pinpoint ATS | HackerRank | Cvent | ECR (Target) |
|---|---|---|---|---|---|---|
| Event-centric data model | Partial | Yes | No | No | Yes (events only) | Yes |
| Multi-track per event | No | Yes | No | No | No | Yes |
| SBD / candidate serial number | No | No | No | No | No | Yes |
| Kiosk check-in (offline) | No | No | No | No | Partial | Yes |
| Duplicate detection (phone+ID) | No | No | No | No | No | Yes |
| Online assessment with blueprint | No | No | No | Yes | No | Yes |
| Panel queue management | No | Partial | No | No | No | Yes |
| Badge printing integration | No | Yes | No | No | Yes | Yes |
| Vietnamese language / VN market | No | No | No | No | No | Yes |
| Bulk email with skip-logic | Partial | Yes | Partial | No | Yes | Yes |

**Key differentiator:** No existing platform combines event-centric multi-track hiring, SBD identity management, offline kiosk operations, and Vietnamese market localization in a single integrated product. ECR's competitive position is a focused vertical advantage within the xTalent HCM ecosystem rather than a head-on competition with global ATS platforms.

---

## 5. Functional Requirements

### 5.1 Event Lifecycle Management

**FR-01: Event Creation Wizard**
A TA Coordinator must be able to create a new recruitment event through a guided multi-step form capturing: event name, description, event type (Job Fair / Fresher Program / Walk-In Drive / Campus Recruitment), date range, physical venue details, and visibility settings (internal / public / invite-only). The wizard must validate that the end date is not before the start date and that at least one Track is defined before the event can be published.

**FR-02: Track Configuration**
Each event must support one or more Tracks. A Track represents a distinct recruitment stream (e.g., Game Development, Game Design, QC). Each Track must be independently configurable with: linked Job Request(s), a custom registration question set, assessment blueprint, target headcount, and assigned interviewer panels. Tracks are created and edited within the event configuration screen.

**FR-03: Event Lifecycle State Machine**
Events must transition through defined states: Draft → Published → Registration Open → Registration Closed → In Progress → Completed → Archived. Each transition must be triggerable manually by the TA Coordinator and, where applicable, automatically based on date. State transitions must be logged with timestamp and actor ID. Business Rule: only events in Draft or Published state may be edited structurally (track additions, capacity changes). Events In Progress may only update operational parameters (room assignments, shift capacity).

**FR-04: Phase and Day Structure**
Within an event, TA must be able to define Phases (e.g., Online Assessment Phase, Onsite Interview Phase) and within each Phase, define Days with specific dates. Each Day contains Shifts (time blocks, e.g., 08:00–10:00). This hierarchy (Event → Phase → Day → Shift) governs scheduling and capacity management.

**FR-05: Dynamic Registration Form Builder**
The TA Coordinator must be able to define a custom registration form per Track. The form builder must support field types: short text, long text, single-select dropdown, multi-select checkbox, date picker, file upload (CV), and URL. Fields must support required/optional toggle and conditional display logic (show field X if answer to field Y equals value Z). The form must be mobile-responsive by default.

**FR-06: Event Cloning**
A TA Coordinator must be able to clone an existing event, including all Track configurations, form definitions, assessment blueprints, and capacity structures, creating a new Draft event with all dates reset. Business Rule: cloning does not copy candidate data, SBD assignments, or interview records from the source event.

### 5.2 Candidate Capture & Registration

**FR-07: Online Registration Portal**
Each published event must generate a unique registration URL. Candidates must be able to access this URL on a mobile device, select their Track, and complete the Track-specific registration form without creating an xTalent user account. Upon submission, the system must create a Candidate Event Profile and send a confirmation notification (email and/or SMS) with the candidate's SBD and any scheduled time slot details.

**FR-08: QR Walk-In Kiosk Registration**
Each event must generate a venue-specific QR code that opens a streamlined walk-in registration form on any mobile device. The walk-in form must capture: full name, phone number, student ID (optional), track selection, and photo capture. Walk-in registrations must be immediately visible in the TA dashboard and included in the check-in queue.

**FR-09: Offline Registration Capture**
The kiosk application must support full registration capture when the device has no internet connectivity. Offline registrations must be queued locally and synchronized to the central system when connectivity is restored. Sync conflicts (e.g., same phone number registers online and offline) must trigger the duplicate detection workflow (FR-12) upon sync.

**FR-10: SBD Generation**
The system must support two modes of SBD generation: (a) Batch Pre-Generation — TA triggers SBD generation for all confirmed registrations at a defined cutoff time before the event; (b) On-Demand Generation — SBD is assigned at the moment of walk-in check-in. SBDs must be numeric, unique within the event scope, and formatted according to configurable rules (e.g., prefix by track: G001 for Game Dev, D001 for Design). Business Rule: SBD assignment is decoupled from email delivery — an SBD can be generated and used for check-in purposes even if the candidate has not yet received the confirmation email.

### 5.3 Candidate Identity & Deduplication

**FR-11: Multi-Factor Identity Matching**
The system must evaluate candidate uniqueness using a composite key: phone number + student ID + normalized name. Email alone must not be used as the sole identity anchor. The matching algorithm must apply fuzzy normalization to names (remove diacritics, lowercase, trim spaces) before comparison.

**FR-12: Duplicate Detection Workflow**
When a new registration (online, walk-in, or offline sync) matches an existing Candidate Event Profile on one or more identity factors, the system must: (a) flag the incoming record as a potential duplicate; (b) surface an Alert to the assigned TA Coordinator showing both records side by side; (c) present three decision options: Merge (keep existing record, discard new), Keep Both (treat as distinct candidates), or Reject New (block the incoming registration). The decision and actor must be logged. Business Rule: until a decision is made, the flagged candidate must be held in a Pending state and must not receive scheduling communications.

**FR-13: Candidate Event Profile**
Each candidate within an event must have a Candidate Event Profile that is distinct from any existing candidate record in the broader xTalent system. The profile must store: registration data, SBD, track assignment, assessment results, interview scores, check-in timestamp, and event outcome (Pass / Fail / No-Show / Withdrawn). If the candidate later appears in the main xTalent candidate pool, the Event Profile must be linkable to the global candidate record without destructive merge.

### 5.4 Assessment & Evaluation

**FR-14: Question Bank**
The system must maintain a Question Bank scoped at the organization level. Questions must support types: multiple choice (single answer), multiple choice (multiple answers), true/false, short answer (free text, no auto-grading), and code challenge (execution-based, auto-graded). Questions must be taggable by skill, topic, and difficulty level. Question Bank access must be role-gated: TA can read and use questions; only designated Question Bank Administrators may create or edit questions.

**FR-15: Assessment Blueprint**
A TA Coordinator must be able to define an Assessment Blueprint per Track. The blueprint specifies: total number of questions, distribution by difficulty (e.g., 40% easy, 40% medium, 20% hard), distribution by topic, time limit, passing score threshold, and randomization mode (fixed set vs. randomly drawn per candidate from pool). Blueprints must be reusable across events.

**FR-16: Candidate Assessment Delivery**
The system must deliver assessments to registered candidates via a time-limited access link sent by email. The assessment must be accessible on both desktop and mobile. The system must enforce: time countdown with auto-submit on expiry, single-session enforcement (no concurrent logins to the same assessment), and answer auto-save every 30 seconds. Business Rule: assessments may only be delivered to candidates in Confirmed or Checked-In status within the relevant phase.

**FR-17: Auto-Grading and Score Publication**
Multiple choice and true/false questions must be auto-graded immediately upon submission. Free-text and code challenge questions may be flagged for manual review. Final scores must be computed and published to the Candidate Event Profile within 5 minutes of submission. Scores must be visible to the TA Coordinator and, upon interview stage entry, to the assigned panel.

**FR-18: Assessment Proctoring Flags**
The assessment delivery engine must capture and log the following signals: tab-switch events, copy-paste attempts, window blur/focus transitions, and submission time relative to time limit. These signals must be surfaced as a Proctoring Flag summary on the Candidate Event Profile for TA review. Business Rule: proctoring flags do not automatically disqualify a candidate; they inform TA discretion.

### 5.5 Scheduling & Capacity Management

**FR-19: Global Schedule Builder**
The TA Coordinator must be able to configure the full capacity structure for an event: Rooms (with capacity per room), Panels (interviewer group assigned to a room for a shift), and Shifts (time block within a day). The system must display a visual schedule grid showing room × shift occupancy and panel assignments. Capacity must be calculated as: available slots = (number of panels × shift duration / average interview duration) per room per shift.

**FR-20: Smart Candidate-to-Slot Allocation**
When TA triggers slot allocation (either bulk pre-event or on-demand at check-in), the system must assign candidates to available slots respecting: (a) track match — candidate's track must match the panel's assigned track; (b) capacity — slot must not be over-filled; (c) preference — where available, candidate-provided time preference from registration. The system must present the allocation plan for TA review before committing. Business Rule: allocation is advisory — TA may override any individual assignment.

**FR-21: Waitlist and Backfill**
When all slots in a shift are full, additional confirmed candidates must be placed on a Waitlist for that shift. If a confirmed candidate cancels or no-shows, the system must automatically promote the first Waitlist candidate and send them a slot confirmation notification. TA must be able to manually trigger backfill for a specific slot.

**FR-22: Capacity Override**
A TA Coordinator must be able to increase or decrease the declared capacity of a room or shift during the event, subject to a configurable maximum override percentage (default: 20% above original capacity). Overrides must be logged.

### 5.6 Onsite Operations & Kiosk

**FR-23: Kiosk Check-In by QR or SBD**
The kiosk application must support candidate check-in by: (a) QR code scan from the confirmation email/SMS; (b) manual SBD entry on a keypad interface. Upon successful check-in, the system must display the candidate's name, track, and assigned room/slot, and trigger badge print. Business Rule: check-in must update the Candidate Event Profile status to Checked-In and push a real-time notification to the relevant panel's interview queue within 5 seconds.

**FR-24: Offline Kiosk Mode**
The kiosk application must operate in full offline mode: check-in, walk-in registration, face capture, and badge print must all function without internet connectivity. The application must maintain a local queue of all offline operations and sync to the central system automatically when connectivity is restored. The sync must apply duplicate detection for walk-in registrations captured offline (FR-12). The kiosk must display a clear offline/online status indicator at all times.

**FR-25: Face Capture**
The kiosk must support optional face capture at check-in using the device camera. Captured images must be stored against the Candidate Event Profile. Face capture is used for: (a) identity verification by onsite staff; (b) badge photo printing. Business Rule: face capture consent language must be displayed before capture; candidates may decline without blocking check-in.

**FR-26: Badge Printing**
Upon successful check-in, the kiosk must trigger printing of a candidate badge to a connected label printer. Badge content must be configurable per event and must include at minimum: candidate name, SBD, track, and assigned room. Badge template must support logo placement and QR code embedding.

### 5.7 Panel Interview Management

**FR-27: Panel Assignment (Hard and Soft)**
Each interviewer must be assignable to a panel in two modes: Hard Assignment (the interviewer is committed to a specific room and shift; the system enforces this and blocks double-booking) and Soft Assignment (advisory; the interviewer may float between rooms). The schedule builder must display hard-assignment conflicts and prevent saving when conflicts exist.

**FR-28: Digital Interview Kit**
When a candidate's check-in status updates to Checked-In and they are assigned to a panel, each panel member must receive a digital interview kit accessible from their mobile device or desktop. The kit must contain: candidate name, SBD, photo (if captured), CV (if uploaded at registration), assessment score summary, track-specific structured interview guide (questions defined in Track configuration), and a scoring form. Business Rule: the interview kit must be delivered within 5 seconds of check-in confirmation.

**FR-29: Real-Time Interview Queue**
Each panel must have a real-time view of their interview queue for the current shift: candidates who have checked in and are awaiting interview, currently interviewing, and completed. Panel members must be able to signal Ready for Next Candidate to pull the next candidate from the queue. Queue state must be visible on both the panel member's device and the TA dashboard.

**FR-30: Candidate Skip and Defer**
A panel member must be able to mark a candidate as Skipped (candidate left the queue) or Deferred (move to the back of the queue, reason required). Skipped candidates must be flagged for TA follow-up. Deferred candidates must be re-inserted into the queue at the next available position.

**FR-31: Interview Score Submission**
Panel members must submit scores through the digital interview kit. The scoring form must support: numeric ratings per competency dimension (configured in Track setup), free-text comments, overall recommendation (Advance / Hold / Reject), and confidence level. Scores must be submitted individually per panel member; the system must not aggregate until all panel members have submitted or a TA override is applied. Business Rule: score submission is final — edits require TA Coordinator approval and must be logged.

### 5.8 Communication & Notifications

**FR-32: Bulk Email with Merge Fields**
The system must support composing and sending bulk email to segmented candidate lists (by event, track, status, stage). Emails must support merge fields (candidate name, SBD, track, interview time, room assignment, portal link). Emails must be sent via the xTalent email integration layer. Business Rule: bulk sends must be rate-limited to avoid SMTP abuse flagging; default rate limit is 500 emails per minute, configurable.

**FR-33: Session Digest for Hiring Managers**
The system must generate and dispatch a Session Digest notification to each panel member the evening before their scheduled interview day (default dispatch: 18:00 the prior day, configurable). The Digest must contain: the panel member's schedule for the next day, list of confirmed candidates with their name, SBD, and track, assessment score summary (if available), and a direct link to the panel's real-time queue. Business Rule: the Session Digest link must expire 24 hours after the event day ends.

**FR-34: Candidate Reschedule Notification**
When a candidate's assigned slot is changed (by TA, by overflow, or by backfill), the system must automatically send a reschedule notification to the candidate containing: original slot details, new slot details, and revised room/panel information. Business Rule: reschedule notifications must be sent at least 2 hours before the original slot time where possible; if less than 2 hours remain, the notification must be flagged as urgent and also surfaced to the TA dashboard.

**FR-35: Bulk SMS Support**
For candidates who do not have a valid email address on record, or as an additional channel, the system must support bulk SMS dispatch for confirmation and reschedule notifications. SMS content must be concise (under 160 characters) and include the SBD and a short URL to the candidate portal.

### 5.9 Bulk Operations

**FR-36: Bulk Stage Advancement**
A TA Coordinator must be able to select multiple candidates (by track, stage, or filter criteria) and advance them to the next stage in bulk. Before execution, the system must display an eligibility summary: how many candidates are eligible for advancement, how many have incomplete assessment scores, and how many have pending duplicate flags. Business Rule: candidates with unresolved duplicate flags (FR-12) must be excluded from bulk advancement and must be listed in a Blocked Items report.

**FR-37: Bulk Status Update with Skip-Logic**
Bulk operations must apply smart skip-logic: if a candidate's current status makes the bulk action inapplicable (e.g., already at target stage, or withdrawn), the system must skip that candidate silently and include them in a skipped-items summary rather than returning an error. The TA must be shown the count of successful, skipped, and blocked records before confirming the operation.

**FR-38: Bulk Invitation Dispatch**
TA must be able to trigger bulk dispatch of assessment invitations or interview invitations to all candidates in a specific track and stage who have not yet received the invitation. The dispatch must respect the rate limit defined in FR-32 and must queue excess invitations for delivery within a configurable window (default: same day).

**FR-39: Bulk Outcome Recording**
After an event, TA must be able to record outcomes (Pass / Fail / No-Show / Withdrawn) for multiple candidates simultaneously, filtered by track and interview panel. Outcome recording must support individual override for any candidate within the bulk selection before final commit.

### 5.10 Analytics & Reporting

**FR-40: Real-Time Event Dashboard**
During an active event, the TA Coordinator must have access to a real-time dashboard displaying: total registered vs. confirmed vs. checked-in candidates by track, current queue depth per panel/room, assessment completion rate, interview completion rate, and stage conversion funnel. Dashboard must refresh at a maximum interval of 30 seconds.

**FR-41: Dynamic Report Builder**
Post-event, TA and HR Analytics must be able to generate reports with configurable dimensions: filter by event, track, date range, stage, outcome, source channel, and demographic fields captured at registration. Reports must support column selection and sort order. Reports must be exportable to CSV and XLSX formats.

**FR-42: Pipeline Conversion Metrics**
The system must calculate and display conversion rates for each stage transition within a track: Registered → Confirmed → Assessment Completed → Onsite Checked-In → Interview Completed → Pass. These metrics must be comparable across events of the same type over time.

**FR-43: Source Channel Attribution**
If the registration form captures a referral source or the registration link contains a UTM-equivalent parameter, the system must attribute each candidate registration to a source channel (e.g., Facebook post, university partnership, employee referral). Source attribution must appear in the dynamic report builder (FR-41).

**FR-44: Manager Link Audit Log**
The system must maintain an audit log of all Session Digest links generated for Hiring Managers, recording: link generation timestamp, recipient email, event and date covered, first access timestamp (if accessed), and expiry timestamp. This log must be exportable by the HR Analytics / Compliance Officer role.

---

## 6. Non-Functional Requirements

**NFR-01: Concurrent User Capacity**
The system must support a minimum of 1,000 simultaneous active users during an event without degradation in response time. Active users include: candidates completing assessments, onsite staff operating kiosks, panel members submitting scores, and TA Coordinators monitoring dashboards.

**NFR-02: Check-In to Queue Latency**
From the moment a candidate check-in is confirmed at the kiosk, the candidate's name must appear in the assigned panel's real-time interview queue within 5 seconds under normal network conditions (minimum 10 Mbps uplink from venue).

**NFR-03: Assessment Auto-Save**
Candidate assessment answers must be auto-saved to persistent storage at a minimum interval of every 30 seconds. In the event of a browser crash or connectivity loss, candidates must be able to resume from the last saved state within the remaining time limit.

**NFR-04: Offline Kiosk Reliability**
The kiosk application must be capable of operating in fully offline mode for a minimum of 8 continuous hours. Local storage must accommodate at minimum 2,000 candidate check-in records and associated face images per offline session.

**NFR-05: Offline Sync Integrity**
Upon reconnection, the kiosk must complete sync of all offline-captured records within 2 minutes for batches up to 500 records. Sync must be atomic per record: a record is either fully committed or rolled back, never partially written.

**NFR-06: Data Privacy — Manager Link Expiry**
All Hiring Manager Session Digest links must automatically expire no later than 24 hours after the event day they cover ends. Expired links must return a clear expiry message and must not expose any candidate data.

**NFR-07: Data Residency**
All candidate data captured during ECR events must be stored within Vietnam-hosted infrastructure (or the enterprise's designated private cloud environment) and must not be transmitted to external services without explicit data processing agreements. This applies specifically to face capture images and assessment responses.

**NFR-08: Accessibility**
The candidate-facing registration portal and assessment interface must conform to WCAG 2.1 Level AA standards. The kiosk interface must support font scaling and high-contrast mode.

**NFR-09: Mobile Responsiveness**
All candidate-facing interfaces (registration form, assessment, candidate portal) must render correctly on screens with a minimum width of 320px (iPhone SE) and must not require horizontal scrolling.

**NFR-10: Audit Trail**
All state-changing actions within the ECR module (event creation, candidate status changes, score submissions, bulk operations, duplicate resolution decisions) must generate immutable audit log entries with: actor user ID, timestamp, action type, before-state, and after-state. Audit logs must be retained for a minimum of 3 years.

**NFR-11: Role-Based Access Control**
The ECR module must enforce RBAC with at minimum the following roles: TA Coordinator (full event management), Hiring Manager (read candidate data for assigned events, submit scores), Onsite Staff (kiosk operations only), HR Analytics (read-only reporting), Candidate (self-service portal only). Role assignments must be per-event, not global, to prevent cross-event data leakage.

**NFR-12: API Availability**
All core ECR operations (candidate registration, check-in, score submission, status update) must be exposed via RESTful API to support integration with the broader xTalent HCM platform and potential third-party integrations (campus portals, HRIS). API must be documented with OpenAPI 3.0 specification.

---

## 7. Research Hypotheses

| ID | Hypothesis | Confidence | Evidence |
|----|-----------|------------|---------|
| H-01 | Vietnamese enterprise TA teams spend more than 40% of event-day effort on manual coordination tasks (scheduling changes, no-show management, ad-hoc communication) that could be automated by ECR. | 0.75 | Consistent pattern in user interviews with VNG and FPT TA teams; supported by general mass-hiring research on coordination overhead. Tier 2 evidence. |
| H-02 | SBD (Số Báo Danh) is the operationally preferred candidate identifier over email or phone number on event day in Vietnamese fresher programs. | 0.90 | Directly observed in VNG Fresher program process documentation; corroborated by FPT campus recruitment coordinator accounts. Tier 2 evidence. |
| H-03 | Internet connectivity at Vietnamese university campuses and convention centers is sufficiently unreliable that a kiosk system without offline capability will fail during at least 30% of events. | 0.70 | Reported by TA coordinators; venue connectivity reliability data is anecdotal (Tier 3). Warrants technical validation at target venues. |
| H-04 | Duplicate candidate registrations (same person submitting both online and walk-in) account for 5–15% of registrations at large-scale events without deduplication tooling. | 0.65 | Estimated from TA coordinator accounts of "cleaning" spreadsheets post-event. No primary data available (Tier 3). Recommend instrumenting ECR to measure this directly. |
| H-05 | Hiring Managers have significantly higher satisfaction with onsite interview days when they receive a structured digital candidate queue rather than a paper list, due to real-time accuracy. | 0.80 | Yello and Avature case studies show HM satisfaction improvement with digital queue tooling (Tier 2). Direct validation with Vietnamese HMs not yet conducted. |
| H-06 | The Event → Track → Request data model is sufficiently flexible to represent all major mass-hiring event formats used by Vietnamese enterprises (Job Fair, Fresher Program, Walk-In Drive, Campus Day). | 0.80 | Model derived from analysis of VNG Fresher program and MWG retail hiring structure. Edge cases (e.g., multi-day university campus tours with rotating hiring managers) require validation. |
| H-07 | Auto-graded online assessments with blueprint randomization reduce candidate anxiety about fairness compared to fixed assessment sets shared across candidates. | 0.60 | Supported by general assessment design literature (Tier 2); not validated specifically for Vietnamese fresher candidate population. |
| H-08 | A 24-hour expiry on Hiring Manager data access links is sufficient for event-day operational needs while satisfying Vietnamese enterprise data governance requirements. | 0.70 | Aligns with general data minimization principles and enterprise security policy patterns observed in Vietnamese tech companies. No regulatory citation available; legal review required. |
| H-09 | Retail walk-in hiring events (MWG, Co.opmart profile) have materially different scheduling requirements than tech fresher programs — specifically, shorter interview cycles (10–15 min vs. 45–60 min) and higher throughput per panel. | 0.85 | Derived from retail vs. tech hiring process documentation and TA coordinator accounts. Tier 2 evidence. |
| H-10 | Integration with the xTalent Job Request module is the most critical external dependency for the ECR module — without a valid Job Request linkage, track configuration is blocked. | 0.85 | Directly follows from the Event → Track → Request data model. Confirmed architectural constraint from xTalent domain model review. Tier 1 internal evidence. |

---

## 8. Open Questions & Ambiguities

**OQ-01: Assessment Platform Boundary**
Is the online assessment capability (FR-14 through FR-18) to be built within ECR, or should ECR integrate with an existing internal or third-party assessment platform (e.g., HackerRank, internal xTalent Quiz engine)? The build vs. integrate decision affects scope and timeline significantly.

**OQ-02: SMS Gateway**
Which SMS gateway provider is used by xTalent infrastructure? Are there pre-existing integrations, or does ECR need to establish a new gateway integration? Vietnamese carriers have specific sender ID registration requirements.

**OQ-03: Badge Printer Hardware Standardization**
Is there a standard label printer model mandated for ECR kiosk deployments, or must the system support multiple printer models? Printer driver integration scope depends on this answer.

**OQ-04: Candidate Portal vs. ATS Candidate Account**
Should candidates registered through ECR events have access to a persistent xTalent candidate portal (viewing past applications, event history) or is the ECR candidate experience purely event-scoped and transient?

**OQ-05: Score Aggregation Logic**
When multiple panel members score the same candidate, what is the official aggregation rule? Simple average? Weighted by panel member seniority? Chair-decides? This must be defined per Track configuration.

**OQ-06: Regulatory Compliance for Face Capture**
Vietnamese Decree 13/2023/ND-CP on personal data protection imposes specific consent and retention requirements for biometric data. The face capture feature (FR-25) requires legal review to confirm compliance obligations before implementation.

**OQ-07: Event Visibility and Candidate Portal Discovery**
How do candidates discover published events? Is there a public-facing event listing page, or are all events invite-only (candidates receive a direct link)? The answer affects the candidate acquisition funnel design.

**OQ-08: Multi-Language Support**
The requirements assume Vietnamese as the primary language for candidate-facing interfaces. Is English language support required for international student programs or multinational company events? Character set and right-to-left support are out of scope if so, but left-to-right bilingual UI must be planned.

---

## 9. Ambiguity Score: 0.15 / 1.0

**Assessment:**

The core problem statement is specific and supported by multiple evidence sources (H-01 through H-10). The functional requirements are enumerated at sufficient detail for a BRD author to proceed without re-interpreting intent. The data model (Event → Track → Request, SBD identity, capacity hierarchy) is clearly defined. Non-functional requirements are quantified where operationally critical (5-second latency, 1,000 concurrent users, 8-hour offline duration, 24-hour link expiry).

**Residual ambiguity sources (justification for score above 0.0):**

- OQ-01 (assessment platform boundary) introduces scope uncertainty in the 5.4 section — estimated 0.05 contribution.
- OQ-05 (score aggregation logic) is a business rule that must be resolved before the interview scoring data model can be finalized — estimated 0.05 contribution.
- OQ-06 (face capture legal compliance) is a regulatory gap that could constrain or eliminate FR-25 — estimated 0.03 contribution.
- OQ-04 (candidate portal persistence) affects downstream architecture for the candidate-facing experience — estimated 0.02 contribution.

Total ambiguity score: **0.15** — within the Gate G1 target of ≤ 0.20.
