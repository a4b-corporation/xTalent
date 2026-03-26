# User Stories: ECR Module
## xTalent HCM Solution | 2026-03-25

---

## Overview

This document contains 39 user stories organized into 10 epics, covering the full functional scope of the Event-Centric Recruitment (ECR) module. Each story includes Gherkin acceptance criteria with a minimum of one happy path and one error/alternate path scenario.

**Actors used in this document:**
- TA Event Coordinator (TA Coordinator)
- Hiring Manager (HM)
- Candidate — Fresher
- Candidate — Experienced
- Candidate — Walk-In
- Onsite Operations Staff
- HR Analytics Lead
- System (automated reaction)

---

## Epic 1: Event Lifecycle Management

### US-01: Create a Multi-Track Event via Wizard

**As a** TA Event Coordinator
**I want to** create a new recruitment event with multiple tracks using a self-service wizard
**So that** I can launch a structured mass hiring event without depending on IT support

**Priority:** P0
**FR Reference:** FR-01, FR-04

**Acceptance Criteria:**

```gherkin
Feature: Event Creation Wizard

  Scenario: TA Coordinator successfully creates a multi-track event
    Given I am logged in as a TA Event Coordinator
    And I navigate to "Create New Event"
    When I complete the wizard with:
      | Field          | Value                    |
      | Event Name     | VNG Fresher Fair 2026    |
      | Start Date     | 2026-04-15               |
      | End Date       | 2026-04-16               |
      | Venue          | GEM Center, Ho Chi Minh  |
      | Tracks         | Engineering, Business    |
      | Capacity       | 500 per track            |
    And I click "Save as Draft"
    Then the event is created in "Draft" state
    And both tracks are created with independent capacity configurations
    And the wizard completion time is recorded under 15 minutes
    And a success confirmation is displayed

  Scenario: Wizard blocks saving with missing required fields
    Given I am on the event creation wizard
    When I attempt to save without entering an Event Name
    Then the system displays an inline validation error on the Event Name field
    And the event is not saved
    And I remain on the wizard step with the missing field highlighted

  Scenario: Wizard enforces minimum one track
    Given I am on the event creation wizard step for Track Configuration
    When I attempt to proceed with zero tracks defined
    Then the system displays an error: "At least one track is required"
    And the wizard does not advance to the next step
```

---

### US-02: Clone a Previous Event

**As a** TA Event Coordinator
**I want to** clone a previous event to inherit its structure
**So that** I can rapidly set up recurring events without re-entering configuration

**Priority:** P0
**FR Reference:** FR-02

**Acceptance Criteria:**

```gherkin
Feature: Event Cloning

  Scenario: TA Coordinator clones a completed event successfully
    Given I am logged in as a TA Event Coordinator
    And a completed event "Fresher Fair 2025" exists with tracks, form fields, and a question bank
    When I select "Clone Event" on "Fresher Fair 2025"
    And I confirm the clone action
    Then a new event "Fresher Fair 2025 (Copy)" is created in "Draft" state
    And the new event inherits: tracks, capacity structure, registration form fields, question bank references
    And the new event does not inherit: candidate records, SBDs, assessment scores, scheduled slots
    And the original event "Fresher Fair 2025" is unchanged
    And the clone operation completes in under 30 seconds

  Scenario: Clone creates a new independent event — changes do not affect original
    Given I have cloned "Fresher Fair 2025" to create "Fresher Fair 2026 (Copy)"
    When I modify the capacity of Track "Engineering" in the cloned event to 600
    Then the capacity in original event "Fresher Fair 2025" remains at its original value
    And the cloned event shows capacity 600 for Track "Engineering"
```

---

### US-03: Transition Event Through State Machine

**As a** TA Event Coordinator
**I want to** move an event through its lifecycle states (Draft → Published → Registration Open → In Progress → Closed)
**So that** the system enforces the correct controls and candidate-facing availability at each phase

**Priority:** P0
**FR Reference:** FR-03, BR-06

**Acceptance Criteria:**

```gherkin
Feature: Event State Machine

  Scenario: Coordinator transitions event from Draft to Published
    Given I am a TA Event Coordinator
    And I have an event in "Draft" state with all required fields complete
    When I click "Publish Event"
    Then the event transitions to "Published" state
    And the event appears in the internal event registry
    And the state transition is logged in the audit trail

  Scenario: System blocks structural changes in In Progress state
    Given I am a TA Event Coordinator
    And the event "VNG Fresher Fair 2026" is in "In Progress" state
    When I attempt to add a new track to the event
    Then the system rejects the action with error: "Structural changes are not permitted while event is In Progress"
    And the track is not created
    And the event state remains "In Progress"

  Scenario: System blocks backward state transition
    Given an event is in "Registration Open" state
    When I attempt to transition the event back to "Draft"
    Then the system rejects the transition with error: "Invalid state transition"
    And the event state remains "Registration Open"
```

---

### US-04: Define Custom Registration Form Fields

**As a** TA Event Coordinator
**I want to** add custom fields to the event registration form
**So that** I can collect role-specific information from candidates without IT involvement

**Priority:** P1
**FR Reference:** FR-05

**Acceptance Criteria:**

```gherkin
Feature: Dynamic Form Builder

  Scenario: Coordinator adds a custom dropdown field to a registration form
    Given I am a TA Event Coordinator editing the registration form for event "Fresher Fair 2026"
    When I add a field with:
      | Property     | Value                          |
      | Field Type   | Dropdown                       |
      | Field Label  | Preferred Work Location        |
      | Options      | Hanoi, Ho Chi Minh, Da Nang    |
      | Required     | Yes                            |
    And I click "Save Form"
    Then the field appears in the form preview
    And the field is marked as required
    And candidates registering for this event see the dropdown with the defined options

  Scenario: Form preview shows validation behavior before publishing
    Given I have added a required text field "GitHub Profile URL" to the form
    When I open the form preview
    And I attempt to submit the preview form without entering the field
    Then the preview shows an inline validation error on "GitHub Profile URL"
    And the preview form does not submit
```

---

### US-05: Monitor Event Phase Transitions

**As a** TA Event Coordinator
**I want to** see which operational phase the event is currently in and what actions are available
**So that** I can manage event operations without confusion about what is permitted at each stage

**Priority:** P0
**FR Reference:** FR-06

**Acceptance Criteria:**

```gherkin
Feature: Event Lifecycle Phases

  Scenario: Phase-specific dashboard shows correct controls for Event Day phase
    Given I am a TA Event Coordinator
    And the event "Fresher Fair 2026" is in the "Event Day" phase
    When I open the event dashboard
    Then I see the "Event Day" phase indicator active
    And I can access: real-time check-in monitor, queue management, score review, bulk outcome recording
    And I cannot access: candidate bulk advancement to pre-event stages, form field editing, track additions

  Scenario: Phase transition is logged in the audit trail
    Given the event "Fresher Fair 2026" transitions from "Scheduling" to "Event Day"
    When I open the audit log for this event
    Then I see an entry with: actor (TA Coordinator name), action "Phase Transition", from "Scheduling", to "Event Day", timestamp
```

---

## Epic 2: Candidate Registration

### US-06: Register Online via Public Form

**As a** Candidate — Fresher
**I want to** register for a recruitment event using an online form on my mobile phone
**So that** I can secure a spot in the event without visiting the venue in advance

**Priority:** P0
**FR Reference:** FR-07

**Acceptance Criteria:**

```gherkin
Feature: Online Candidate Registration

  Scenario: Fresher candidate successfully registers via mobile
    Given the event "VNG Fresher Fair 2026" registration is open
    And I access the event registration URL on my mobile browser
    When I complete the form with:
      | Field            | Value                      |
      | Full Name        | Nguyen Van A               |
      | Phone            | 0901234567                 |
      | Email            | nva@email.com              |
      | Student ID       | 2021001234                 |
      | Track Preference | Engineering                |
      | CV Upload        | cv_nguyenvana.pdf          |
    And I submit the form
    Then I see a confirmation message: "Registration successful"
    And an SBD is generated and displayed immediately (e.g., "FAIR2026-0042")
    And a confirmation email is sent to nva@email.com with my SBD
    And my registration appears in the event candidate list with status "Registered"

  Scenario: Registration rejected when event capacity is full
    Given all confirmed slots for track "Engineering" are at capacity
    When I submit a valid registration for track "Engineering"
    Then I receive a confirmation: "You have been added to the waitlist for Engineering Track"
    And my status is set to "Waitlisted"
    And my waitlist position is displayed (e.g., "Position 12 on waitlist")

  Scenario: Form validation prevents submission with invalid phone number
    Given I am completing the online registration form
    When I enter "123" as my phone number and submit
    Then the form displays an inline error: "Please enter a valid Vietnamese phone number"
    And the form is not submitted
```

---

### US-07: Walk-In Registration at Kiosk

**As a** Candidate — Walk-In
**I want to** register at a kiosk on the day of the event
**So that** I can participate without having pre-registered online

**Priority:** P0
**FR Reference:** FR-08

**Acceptance Criteria:**

```gherkin
Feature: Walk-In Kiosk Registration

  Scenario: Walk-in candidate completes kiosk registration and receives SBD
    Given I am a walk-in candidate at the event venue
    And the kiosk is in online mode
    When an Onsite Operations Staff member or I complete the kiosk form with my basic details
      | Field      | Value          |
      | Full Name  | Tran Thi B     |
      | Phone      | 0912345678     |
      | ID Number  | 079201001234   |
      | Track      | Business       |
    And I submit the kiosk form
    Then an SBD is generated immediately (e.g., "FAIR2026-0101")
    And the SBD is displayed prominently on the kiosk screen
    And the total registration-to-SBD flow completes in under 2 minutes

  Scenario: Kiosk detects potential duplicate during walk-in registration
    Given a candidate with phone "0912345678" already registered online
    When I enter phone "0912345678" at the kiosk
    Then the kiosk displays a notification: "A registration with this phone number already exists"
    And a duplicate resolution flag is raised in the TA Coordinator dashboard
    And the walk-in capture proceeds (new record created provisionally)
    And I still receive an SBD for onsite operations continuity (BR-01)
```

---

### US-08: Capture Candidates Offline at Kiosk

**As an** Onsite Operations Staff member
**I want to** continue capturing walk-in candidates even when the venue network is down
**So that** event operations are not disrupted by connectivity failures

**Priority:** P0
**FR Reference:** FR-09, BR-08

**Acceptance Criteria:**

```gherkin
Feature: Offline Candidate Capture

  Scenario: Kiosk captures candidates during network outage and syncs on reconnect
    Given the kiosk has lost network connectivity
    And the kiosk has entered "Offline Mode" automatically
    When I capture 15 walk-in candidate registrations at the kiosk
    Then all 15 records are stored locally with status "Provisional"
    And each candidate receives an SBD immediately (locally generated)
    And the kiosk sync indicator shows "15 records pending sync"
    When the network connection is restored
    Then the kiosk initiates sync automatically
    And each record syncs atomically (one complete or not at all — no partial records)
    And successfully synced records change status from "Provisional" to "Confirmed"
    And the sync indicator shows "Sync complete: 15 records"

  Scenario: Sync failure routes records to manual review, not data loss
    Given the kiosk is syncing 5 offline-captured records on reconnect
    And records 4 and 5 encounter a sync conflict (duplicate phone detected server-side)
    Then records 1, 2, and 3 sync successfully and become "Confirmed"
    And records 4 and 5 are placed in the Manual Review Queue with the conflict reason
    And records 4 and 5 are not lost or silently discarded
    And the TA Coordinator receives a notification: "2 records require manual review after sync"
```

---

### US-09: SBD Generation and Assignment

**As a** TA Event Coordinator
**I want to** configure the SBD format for my event and have SBDs generated automatically for each registrant
**So that** every candidate has a unique onsite identity token regardless of their registration channel

**Priority:** P0
**FR Reference:** FR-10, BR-01

**Acceptance Criteria:**

```gherkin
Feature: SBD Generation

  Scenario: Coordinator configures SBD format and SBDs are auto-generated
    Given I am a TA Event Coordinator setting up event "Fresher Fair 2026"
    When I configure the SBD format as prefix "FAIR26" with 4-digit sequence
    And I save the event configuration
    Then the first registrant receives SBD "FAIR26-0001"
    And the second registrant receives SBD "FAIR26-0002"
    And SBDs increment sequentially without gaps

  Scenario: SBD is assigned even when confirmation email fails to deliver
    Given a candidate registers with a valid email address
    And the email delivery service is temporarily unavailable
    When the candidate submits their registration
    Then an SBD is generated and stored in the system immediately
    And the SBD is displayed on the confirmation screen
    And the SBD is valid for all onsite operations
    And the email delivery failure is logged separately (does not block SBD assignment per BR-01)
```

---

## Epic 3: Candidate Identity & Deduplication

### US-10: Detect Multi-Factor Duplicates

**As a** TA Event Coordinator
**I want to** be automatically alerted when a new registration matches an existing candidate on multiple identity signals
**So that** I can prevent duplicate records from creating split pipeline histories

**Priority:** P0
**FR Reference:** FR-11

**Acceptance Criteria:**

```gherkin
Feature: Multi-Factor Duplicate Detection

  Scenario: System flags a high-confidence duplicate on phone + student ID match
    Given candidate "Nguyen Van A" is registered with phone "0901234567" and student ID "2021001234"
    When a new registration is submitted with phone "0901234567" and student ID "2021001234"
    Then the system flags a potential duplicate with confidence score "High"
    And the new registration is placed in "Pending Duplicate Review" status
    And the TA Coordinator receives a notification: "High-confidence duplicate detected for new registration"
    And the duplicate appears in the event's Duplicate Tab

  Scenario: System flags a medium-confidence duplicate on phone + name + DOB match
    Given candidate "Tran Thi B" is registered with phone "0912345678", name "Tran Thi B", DOB "1998-05-15"
    When a new registration arrives with phone "0912345678", name "Tran Thi B", DOB "1998-05-15" but different email
    Then the system flags a potential duplicate with confidence score "Medium"
    And the duplicate is added to the Duplicate Tab for review
    And the new registration is held in "Pending Duplicate Review" status
    And automatic merge or rejection does not occur (BR-02)
```

---

### US-11: Resolve Duplicate Candidate Records

**As a** TA Event Coordinator
**I want to** review side-by-side duplicate records and choose to merge, keep both, or reject one
**So that** the candidate pipeline remains accurate without the system making decisions on my behalf

**Priority:** P0
**FR Reference:** FR-12, BR-02, BR-03

**Acceptance Criteria:**

```gherkin
Feature: Human Duplicate Resolution

  Scenario: Coordinator merges two duplicate records
    Given two candidate records are flagged as duplicates in the Duplicate Tab
    When I open the duplicate review for these two records
    Then I see both records side-by-side with all fields displayed
    And I see the matching signals that triggered the flag (e.g., "Matched on: Phone + Student ID")
    When I select "Merge" and choose the primary record
    Then the two records are merged into one, preserving all data from both records
    And the resolution action is logged: actor, timestamp, action "Merge", records involved
    And the merged record is no longer in "Pending Duplicate Review" status
    And the merged candidate is now eligible for bulk advancement

  Scenario: Coordinator keeps both records as legitimate separate individuals
    Given two records are flagged as duplicates with confidence "Medium"
    When I review both records and determine they are different people with the same phone number (family phone)
    And I select "Keep Both" with reason "Different individuals using shared family phone"
    Then both records remain as separate candidates with "Duplicate Resolved: Keep Both" status
    And both are now eligible for independent pipeline progression
    And the reason is stored in the audit log

  Scenario: Bulk advancement blocks candidate with unresolved duplicate
    Given candidate "Nguyen Van A" has an unresolved duplicate flag
    When I attempt to include "Nguyen Van A" in a bulk stage advancement to "Scheduled"
    Then "Nguyen Van A" is excluded from the bulk operation
    And the skip-logic eligibility pop-up shows: "1 candidate excluded: unresolved duplicate flag"
    And the remaining eligible candidates can proceed with the bulk advancement
```

---

### US-12: Manage Duplicate Queue in Event Dashboard

**As a** TA Event Coordinator
**I want to** see all unresolved duplicates for my event in a dedicated tab with count and filter
**So that** I can systematically clear the duplicate backlog before running bulk operations

**Priority:** P1
**FR Reference:** FR-13

**Acceptance Criteria:**

```gherkin
Feature: Duplicate Management Tab

  Scenario: Coordinator views and filters the duplicate queue
    Given the event "Fresher Fair 2026" has 12 unresolved duplicate pairs
    When I navigate to the "Duplicates" tab in the event dashboard
    Then I see the count "12 unresolved duplicates"
    And I can filter by confidence level (High / Medium / Low)
    And I can filter by detection method (Phone + Student ID / Phone + Name + DOB / Email + Phone)
    And each row shows: candidate names, match signals, confidence score, and resolution action buttons

  Scenario: Duplicate count decrements on resolution
    Given I have 12 unresolved duplicates displayed
    When I resolve one duplicate pair by selecting "Merge"
    Then the duplicate count updates to "11 unresolved duplicates" without page reload
    And the resolved pair is removed from the unresolved list
```

---

## Epic 4: Assessment

### US-13: Configure Assessment Blueprint

**As a** TA Event Coordinator
**I want to** define an assessment blueprint that specifies question mix and difficulty distribution
**So that** all candidates in a track receive a consistently structured assessment

**Priority:** P1
**FR Reference:** FR-15

**Acceptance Criteria:**

```gherkin
Feature: Assessment Blueprint

  Scenario: Coordinator creates an assessment blueprint for Engineering track
    Given I am a TA Event Coordinator and the Assessment module is available
    When I create a blueprint for "Engineering Track Assessment" with:
      | Section   | Type | Count | Difficulty |
      | Logic     | MCQ  | 10    | Medium     |
      | Technical | MCQ  | 15    | Hard       |
      | Essay     | Open | 2     | Hard       |
    And I set a 60-minute time limit
    And I save the blueprint
    Then the blueprint is saved and available for assignment to the track
    And the system confirms: "Blueprint will generate unique question sets per candidate from the question bank"

  Scenario: Blueprint creation fails when question bank has insufficient questions
    Given the question bank has only 8 Medium Logic MCQ questions
    When I define a blueprint requiring 10 Medium Logic MCQ questions
    And I attempt to save the blueprint
    Then the system displays a warning: "Insufficient questions in bank: Medium Logic MCQ requires 10, available 8"
    And the blueprint is not saved in an invalid state
    And I am prompted to either add questions to the bank or reduce the blueprint requirement
```

---

### US-14: Deliver Assessment to Confirmed Candidates Only

**As a** System (automated process)
**I want to** send assessment access only to candidates with Confirmed or Checked-In status
**So that** unconfirmed candidates do not receive assessments and the assessment gate is enforced

**Priority:** P0
**FR Reference:** FR-16, BR-07

**Acceptance Criteria:**

```gherkin
Feature: Assessment Delivery Gate

  Scenario: Assessment link sent to Confirmed candidate
    Given candidate "Nguyen Van A" has status "Confirmed" for event "Fresher Fair 2026"
    And the TA Coordinator triggers assessment dispatch for the Engineering track
    When the system processes the dispatch
    Then "Nguyen Van A" receives an assessment link via email
    And the link is time-limited (valid for the assessment window defined in the blueprint)
    And the assessment access event is logged

  Scenario: Assessment link not sent to Waitlisted candidate
    Given candidate "Le Van C" has status "Waitlisted"
    When the TA Coordinator triggers assessment dispatch for the Engineering track
    Then "Le Van C" does not receive an assessment link
    And the dispatch log shows "Le Van C: Skipped — status Waitlisted (not eligible per BR-07)"

  Scenario: Candidate attempts to access assessment link after it expires
    Given candidate "Nguyen Van A" received an assessment link valid for 90 minutes
    When "Nguyen Van A" attempts to open the link after 95 minutes
    Then the system returns an "Assessment link has expired" page
    And the access attempt is logged with the expired timestamp
```

---

### US-15: Review Auto-Graded Assessment Results

**As a** TA Event Coordinator
**I want to** see auto-graded MCQ scores for all candidates and a list of essays pending manual review
**So that** I can efficiently process assessment results without manual scoring of objective questions

**Priority:** P1
**FR Reference:** FR-17

**Acceptance Criteria:**

```gherkin
Feature: Auto-Grading

  Scenario: MCQ questions auto-graded and score visible to coordinator
    Given 50 candidates have completed the Engineering track assessment
    When I open the Assessment Results view
    Then I see each candidate's MCQ score calculated automatically
    And I see a separate column "Essay Review Required" flagged for candidates with essay submissions
    And I can sort candidates by MCQ score descending

  Scenario: Essay flagged for manual reviewer
    Given candidate "Nguyen Van A" has submitted an essay response
    When I open the manual review queue
    Then I see "Nguyen Van A"'s essay with the rubric criteria alongside it
    And I can enter a score for each rubric criterion
    And I can submit the manual score which merges with the auto-graded MCQ score for a composite total
```

---

### US-16: Flag Proctoring Anomalies

**As a** TA Event Coordinator
**I want to** see proctoring flags (tab switches, copy-paste, time outside window) for candidate assessments
**So that** I can make informed review decisions without the system automatically disqualifying anyone

**Priority:** P2
**FR Reference:** FR-18

**Acceptance Criteria:**

```gherkin
Feature: Proctoring Flags

  Scenario: Assessment with proctoring flags shown in review with flag details
    Given candidate "Tran Thi B" completed an assessment with 3 tab-switch events and 1 copy-paste event
    When I open "Tran Thi B"'s assessment result
    Then I see a proctoring flag indicator: "3 flags detected"
    And I can expand to see: "Tab Switch: 3 occurrences, Copy-Paste: 1 occurrence, Time Outside Window: 0"
    And "Tran Thi B"'s assessment result is not automatically invalidated

  Scenario: No auto-disqualification on proctoring flags
    Given candidate "Le Van C" has 5 tab-switch flags
    Then "Le Van C" is not automatically disqualified or removed from the pipeline
    And "Le Van C" remains eligible for manual review by the TA Coordinator
```

---

## Epic 5: Scheduling & Capacity

### US-17: Build Day x Shift x Room Schedule Matrix

**As a** TA Event Coordinator
**I want to** define a schedule matrix of days, shifts, and rooms with capacity for my event
**So that** the system can intelligently allocate candidates to sessions

**Priority:** P0
**FR Reference:** FR-19

**Acceptance Criteria:**

```gherkin
Feature: Schedule Builder

  Scenario: Coordinator creates a 2-day event schedule matrix
    Given I am setting up the schedule for "Fresher Fair 2026" (April 15–16)
    When I define the following matrix:
      | Day     | Shift     | Room        | Capacity |
      | Day 1   | Morning   | Room A      | 50       |
      | Day 1   | Morning   | Room B      | 50       |
      | Day 1   | Afternoon | Room A      | 50       |
      | Day 2   | Morning   | Room A      | 50       |
    And I save the schedule
    Then the schedule matrix is created with total capacity 200
    And the matrix is available for candidate allocation

  Scenario: System detects and rejects room double-booking
    Given Room A on Day 1 Morning already has 50 capacity assigned
    When I attempt to add a second session in Room A on Day 1 Morning with overlapping time
    Then the system displays an error: "Room A is already assigned for Day 1 Morning"
    And the conflicting session is not saved
```

---

### US-18: Allocate Candidates to Schedule Slots Automatically

**As a** TA Event Coordinator
**I want to** automatically allocate confirmed candidates to schedule slots using a configurable strategy
**So that** I avoid spending hours manually assigning hundreds of candidates to interview sessions

**Priority:** P0
**FR Reference:** FR-20

**Acceptance Criteria:**

```gherkin
Feature: Smart Allocation

  Scenario: Coordinator runs Round-Robin allocation for Engineering track
    Given 100 confirmed candidates are in the Engineering track
    And the schedule has 4 slots of 25 capacity each
    When I select "Round-Robin" allocation strategy and run allocation
    Then 25 candidates are assigned to each of the 4 slots
    And distribution is balanced across all available rooms and shifts
    And I see an allocation preview before I confirm

  Scenario: Coordinator reviews allocation preview and confirms
    Given allocation preview shows 100 candidates distributed across 4 slots
    When I review the preview and click "Confirm Allocation"
    Then all 100 candidates receive their schedule slot assignments
    And each candidate's status updates to "Scheduled"
    And confirmation notifications are queued for dispatch

  Scenario: Fill-First strategy maximizes room utilization
    Given 60 confirmed candidates and 3 slots of 30 capacity each
    When I select "Fill-First" strategy and run allocation
    Then slots are filled in order: Slot 1 gets 30, Slot 2 gets 30, Slot 3 gets 0
    And the allocation preview shows this distribution before confirmation
```

---

### US-19: Manage Waitlist and Backfill

**As a** TA Event Coordinator
**I want to** see the waitlist and have the system automatically backfill when a confirmed candidate cancels
**So that** no session slot goes unfilled due to cancellations

**Priority:** P0
**FR Reference:** FR-21, BR-10

**Acceptance Criteria:**

```gherkin
Feature: Waitlist and Backfill

  Scenario: Waitlisted candidate is automatically notified when a slot opens
    Given candidate "Pham Van D" is at position 1 on the waitlist for Day 1 Morning
    And candidate "Le Van C" (confirmed, Day 1 Morning) cancels their registration
    When the cancellation is processed
    Then "Pham Van D" is automatically assigned the freed slot
    And "Pham Van D" receives a notification: "Good news — you have been moved from the waitlist to a confirmed slot: Day 1 Morning, Room A"
    And "Pham Van D"'s status changes from "Waitlisted" to "Scheduled"

  Scenario: Waitlist ordering is first-come-first-served and cannot be manually reordered
    Given candidates on the waitlist in order: [Candidate X at 08:00, Candidate Y at 09:00, Candidate Z at 10:00]
    When a slot opens
    Then Candidate X (earliest registration) is offered the slot first
    And I as TA Coordinator cannot manually move Candidate Z to position 1 in the waitlist (BR-10)
```

---

### US-20: Override Room Capacity

**As a** TA Event Coordinator
**I want to** override the scheduled capacity of a room with a mandatory reason
**So that** I can accommodate last-minute changes in room assignments at my discretion

**Priority:** P1
**FR Reference:** FR-22

**Acceptance Criteria:**

```gherkin
Feature: Capacity Override

  Scenario: Coordinator successfully overrides room capacity before event starts
    Given event "Fresher Fair 2026" is in "Scheduling" phase (not yet In Progress)
    And Room A Day 1 Morning has capacity set to 50
    When I click "Override Capacity" and set new capacity to 60
    And I enter reason "Venue confirmed additional seating available"
    And I confirm the override
    Then Room A Day 1 Morning capacity updates to 60
    And an audit entry is created: actor, old capacity 50, new capacity 60, reason, timestamp

  Scenario: Override blocked during In Progress state
    Given event "Fresher Fair 2026" is in "In Progress" state
    When I attempt to override the capacity of Room A Day 1 Morning
    Then the system displays: "Capacity changes are not permitted once the event is In Progress (BR-06)"
    And the capacity remains unchanged
```

---

### US-21: Handle Over-Capacity Registration

**As a** Candidate — Experienced
**I want to** know my waitlist position when I register for a full event
**So that** I can decide whether to attend and plan accordingly

**Priority:** P0
**FR Reference:** FR-21

**Acceptance Criteria:**

```gherkin
Feature: Waitlist Registration Experience

  Scenario: Candidate registers when track is at capacity and is placed on waitlist
    Given the "Business Track" for "Fresher Fair 2026" has 0 confirmed slots remaining
    When I complete and submit the registration form for "Business Track"
    Then I see a confirmation: "You have been added to the waitlist for Business Track — Position 7"
    And my status is "Waitlisted"
    And I receive a confirmation email with my SBD and waitlist position

  Scenario: Candidate receives waitlist update notification
    Given I am at waitlist position 3 for "Business Track"
    When 2 candidates ahead of me cancel
    Then I receive an email: "Your waitlist position has moved to Position 1 — you are next in line if a slot opens"
```

---

## Epic 6: Onsite Kiosk Operations

### US-22: Check In via QR Code Scan

**As a** Candidate (any type)
**I want to** check in at the event venue by scanning a QR code from my confirmation email
**So that** my attendance is recorded instantly without manual lookup

**Priority:** P0
**FR Reference:** FR-23

**Acceptance Criteria:**

```gherkin
Feature: QR Code Check-In

  Scenario: Candidate checks in via QR scan in under 5 seconds
    Given I am at the event venue with my confirmation email QR code
    And the kiosk is in online mode
    When an Onsite Staff member scans my QR code
    Then my status updates to "Checked In" in the system
    And the kiosk displays my name, SBD, and assigned room
    And the check-in completes end-to-end in under 5 seconds (P95)
    And the HM queue display updates to show me as checked in within 5 seconds

  Scenario: Duplicate check-in is detected and rejected
    Given candidate "Nguyen Van A" (SBD: FAIR26-0001) has already checked in
    When an Onsite Staff member attempts to scan "Nguyen Van A"'s QR code again
    Then the kiosk displays: "Already checked in — SBD: FAIR26-0001, Check-in time: 08:15"
    And no duplicate check-in record is created
```

---

### US-23: Check In via Manual SBD Entry

**As an** Onsite Operations Staff member
**I want to** look up and check in a candidate by entering their SBD manually
**So that** candidates who cannot display their QR code (lost phone, no data) can still check in

**Priority:** P0
**FR Reference:** FR-23

**Acceptance Criteria:**

```gherkin
Feature: SBD Manual Check-In

  Scenario: Onsite staff checks in candidate via SBD manual entry
    Given candidate "Tran Thi B" has SBD "FAIR26-0101" and status "Scheduled"
    When I type "FAIR26-0101" into the kiosk SBD search field
    Then the kiosk displays "Tran Thi B", track "Business", assigned room "Room B", shift "Morning"
    And I click "Confirm Check-In"
    Then "Tran Thi B"'s status updates to "Checked In"
    And the check-in is logged in the audit trail

  Scenario: SBD not found in system
    Given I enter SBD "FAIR26-9999" which does not exist
    When I submit the search
    Then the kiosk displays: "SBD not found. Please verify the number or register as a walk-in."
    And no check-in record is created
```

---

### US-24: Operate Kiosk in Offline Mode

**As an** Onsite Operations Staff member
**I want to** continue checking in candidates when the venue WiFi goes down
**So that** a network outage does not halt event operations

**Priority:** P0
**FR Reference:** FR-24, BR-08

**Acceptance Criteria:**

```gherkin
Feature: Offline Kiosk Mode

  Scenario: Kiosk auto-switches to offline mode and operations continue
    Given the kiosk is operating normally
    When the venue network connection drops
    Then the kiosk displays a banner: "Offline Mode Active — Check-ins are being stored locally"
    And all subsequent check-ins are stored locally with provisional status
    And SBD lookups work from the locally cached candidate list
    And the event-day operations continue without interruption

  Scenario: Kiosk sync resumes automatically and clears provisional queue
    Given the kiosk has 25 check-ins stored locally in offline mode
    When the network connection is restored
    Then the kiosk displays: "Reconnected — syncing 25 records..."
    And each record syncs atomically
    And the banner updates: "Sync complete — all records confirmed"
    And the 25 check-ins are now visible in the system as "Checked In"
```

---

### US-25: Display Check-In Queue for Hiring Manager

**As a** Hiring Manager
**I want to** see a real-time queue display showing which candidates are waiting and who is currently being interviewed
**So that** I can manage my interview pace without relying on manual coordination

**Priority:** P0
**FR Reference:** FR-29

**Acceptance Criteria:**

```gherkin
Feature: Real-Time Queue Display

  Scenario: HM sees live queue status after each check-in
    Given I am a Hiring Manager with a digital interview kit link for Room A
    And I have 5 candidates scheduled for my room
    When candidate "Nguyen Van A" checks in at the kiosk
    Then within 5 seconds, the queue display on my screen shows "Nguyen Van A — Waiting"
    And the queue shows: position, candidate name, check-in time, status

  Scenario: Queue reflects skip action in real time
    Given "Le Van C" is shown as "Waiting" in my queue
    When I mark "Le Van C" as "Skip (No-Show)"
    Then "Le Van C"'s status updates to "No-Show" on the queue display immediately
    And the next candidate advances in the queue
```

---

## Epic 7: Panel Interview Management

### US-26: Assign Interviewers to Sessions

**As a** TA Event Coordinator
**I want to** assign Hiring Managers to interview sessions as hard, soft, or queue-mode assignments
**So that** interview coverage is planned and flexible enough to handle last-minute absences

**Priority:** P0
**FR Reference:** FR-27

**Acceptance Criteria:**

```gherkin
Feature: Interviewer Assignment

  Scenario: Coordinator creates a hard assignment for a session
    Given I am a TA Event Coordinator setting up interview sessions for Day 1 Morning
    When I assign "HM Nguyen" to Room A Day 1 Morning as "Hard Assignment"
    Then "HM Nguyen" is locked to that session
    And the session shows "Hard Assignment: HM Nguyen" in the schedule view
    And a Session Digest is queued to be sent to "HM Nguyen"

  Scenario: Queue-mode session allows any assigned interviewer to pick from pool
    Given I configure the "Business Track" interviews in "Queue Mode" with 3 assigned interviewers
    When any of the 3 assigned interviewers is available
    Then they can claim the next candidate from the shared queue
    And the system records which interviewer claimed each candidate
```

---

### US-27: Access Digital Interview Kit via Secure Link

**As a** Hiring Manager
**I want to** access my interview kit through a secure email link without needing an xTalent login
**So that** I can review candidate profiles and score rubrics from any device without account management overhead

**Priority:** P0
**FR Reference:** FR-28, BR-05

**Acceptance Criteria:**

```gherkin
Feature: Digital Interview Kit Access

  Scenario: HM accesses interview kit via Session Digest link
    Given I am a Hiring Manager who received a Session Digest email for "Fresher Fair 2026"
    When I click the interview kit link in the email
    Then I am taken to my interview kit without being asked to log in to xTalent
    And I can see: my candidate queue, each candidate's profile summary, the scoring rubric, and a notes area
    And the kit link shows a countdown: "This link expires in 20 hours"

  Scenario: Expired kit link returns access denied
    Given 26 hours have passed since event day ended
    When I click the Session Digest link from my email
    Then I see a page: "This interview kit link has expired. Please contact your TA Coordinator for assistance."
    And access to candidate data is denied (server-side enforcement per BR-05)
```

---

### US-28: Submit Interview Scores

**As a** Hiring Manager
**I want to** submit structured interview scores using the scoring rubric in my kit
**So that** candidate evaluations are standardized and immediately available to the TA Coordinator

**Priority:** P0
**FR Reference:** FR-31, BR-04

**Acceptance Criteria:**

```gherkin
Feature: Score Submission

  Scenario: HM submits scores and they are locked
    Given I am reviewing candidate "Nguyen Van A" in my interview kit
    When I score each rubric criterion:
      | Criterion           | Score |
      | Problem Solving     | 4/5   |
      | Communication       | 3/5   |
      | Technical Knowledge | 5/5   |
    And I click "Submit Scores"
    Then the scores are locked and a "Submitted" badge appears
    And I cannot edit the scores directly
    And the TA Coordinator can see the submitted scores in the event dashboard

  Scenario: HM requests score edit — triggers approval workflow
    Given I submitted scores for "Nguyen Van A" but made an error on "Technical Knowledge"
    When I click "Request Score Edit" and describe the error
    Then the TA Coordinator receives an approval request: "HM Nguyen requests score edit for Nguyen Van A — Technical Knowledge: 5 → 3"
    And the original score (5) remains locked until the TA Coordinator approves or rejects the edit request
    And the approval/rejection is logged in the audit trail with both the original and new value

  Scenario: Score edit rejected by TA Coordinator
    Given a score edit request is pending TA Coordinator review
    When the TA Coordinator selects "Reject Edit Request" with reason "Score appears correct per interview notes"
    Then the original score remains unchanged
    And the HM receives a notification: "Your score edit request was rejected"
    And the rejection is logged
```

---

### US-29: Skip or Defer a Candidate from Queue

**As a** Hiring Manager
**I want to** skip a no-show candidate or defer a late candidate within the event
**So that** my interview session flows efficiently without blocking the queue on absent candidates

**Priority:** P1
**FR Reference:** FR-30

**Acceptance Criteria:**

```gherkin
Feature: Skip and Defer

  Scenario: Interviewer skips a no-show candidate
    Given "Tran Thi B" is next in my interview queue with status "Waiting"
    And "Tran Thi B" has not appeared after 10 minutes
    When I click "Skip — No Show" on "Tran Thi B"'s queue entry
    Then "Tran Thi B"'s status updates to "No-Show"
    And "Tran Thi B" is removed from the active queue
    And the next candidate advances to "In Interview" position
    And the skip action is logged with actor, timestamp, and reason

  Scenario: Interviewer defers a late-arriving candidate
    Given "Le Van C" arrives late and I am mid-interview with the next candidate
    When I click "Defer" on "Le Van C"'s queue entry
    Then "Le Van C" is moved to the end of the current queue (or next available slot)
    And "Le Van C"'s status updates to "Deferred"
    And the deferral is logged
```

---

### US-30: View Candidate Profile During Interview

**As a** Hiring Manager
**I want to** see a candidate's profile (CV, registration answers, assessment score) during the interview
**So that** I can conduct an informed, structured interview without separate systems

**Priority:** P0
**FR Reference:** FR-28

**Acceptance Criteria:**

```gherkin
Feature: Candidate Profile in Interview Kit

  Scenario: HM sees candidate profile including assessment score in kit
    Given candidate "Nguyen Van A" has completed the Engineering track assessment with score 78/100
    When I open "Nguyen Van A"'s profile in my interview kit
    Then I see: name, contact info, track, registration form answers, uploaded CV, assessment score 78/100
    And I can download the CV
    And the profile is read-only (I cannot edit candidate data)

  Scenario: HM without assessment data sees profile without score field
    Given candidate "Tran Thi B" did not complete the assessment
    When I open "Tran Thi B"'s profile in my kit
    Then I see: name, contact info, track, registration answers
    And the assessment score field shows "Assessment not completed"
    And the scoring rubric is still available for me to evaluate the interview
```

---

## Epic 8: Communication & Notifications

### US-31: Send Bulk Invitations to Candidates

**As a** TA Event Coordinator
**I want to** dispatch assessment or interview invitations to all eligible candidates in a bulk operation
**So that** I can communicate with 1,000 candidates in minutes rather than hours

**Priority:** P0
**FR Reference:** FR-38, FR-32

**Acceptance Criteria:**

```gherkin
Feature: Bulk Invitation Dispatch

  Scenario: Coordinator dispatches 1,000 invitations within 5 minutes
    Given 1,000 candidates are in "Confirmed" status for event "Fresher Fair 2026"
    And I have selected the "Assessment Invitation" email template
    When I select all 1,000 candidates and click "Dispatch Invitations"
    Then the system initiates a bulk email job
    And a progress indicator shows: "Dispatching... 247/1000 sent"
    And all 1,000 invitations are dispatched within 5 minutes
    And I can see per-candidate delivery status (Sent, Delivered, Failed)

  Scenario: Failed deliveries are retried and reported
    Given 23 emails from a bulk dispatch of 1,000 fail to deliver (invalid addresses)
    Then the system retries failed deliveries with exponential backoff
    And after retries, the final report shows "977 Delivered, 23 Failed — see failed list"
    And the 23 failed candidates are listed with failure reason for TA Coordinator follow-up
```

---

### US-32: Send Session Digest to Hiring Managers

**As a** TA Event Coordinator
**I want to** send a Session Digest notification to all Hiring Managers 24–48 hours before the event
**So that** they know their schedule, candidate lineup, and have access to their interview kit before arriving

**Priority:** P0
**FR Reference:** FR-33, BR-05

**Acceptance Criteria:**

```gherkin
Feature: Session Digest Notification

  Scenario: Coordinator dispatches Session Digest to all HMs
    Given 5 Hiring Managers are assigned to sessions in "Fresher Fair 2026" on April 15
    When I click "Send Session Digests" on April 14 (24 hours before event)
    Then each HM receives an email containing:
      - Their name and assigned session details (room, shift, date)
      - A list of candidates scheduled in their session
      - A secure interview kit link (valid until April 16 + 24h = April 17)
    And the digest dispatch is logged with timestamp

  Scenario: Session Digest link expires server-side at correct time
    Given "HM Nguyen" received a Session Digest for event day April 15
    And it is now April 17 01:00 (25 hours after April 16 event day end)
    When "HM Nguyen" clicks the kit link
    Then the server returns 403: "This link has expired"
    And no candidate data is accessible
```

---

### US-33: Notify Candidates of Schedule Changes

**As a** TA Event Coordinator
**I want to** automatically notify candidates when their schedule is changed
**So that** candidates arrive at the correct time and location without confusion

**Priority:** P1
**FR Reference:** FR-34

**Acceptance Criteria:**

```gherkin
Feature: Reschedule Notifications

  Scenario: Candidate notified when their slot is changed by coordinator
    Given candidate "Nguyen Van A" is scheduled for Day 1 Morning Room A
    When I reschedule "Nguyen Van A" to Day 1 Afternoon Room B due to room change
    Then "Nguyen Van A" receives an email notification:
      "Your interview schedule has been updated:
       Previous: Day 1, Morning, Room A
       New: Day 1, Afternoon, Room B
       Reason: Room reassignment"
    And the notification is sent within 5 minutes of the reschedule action

  Scenario: No notification sent for same-slot schedule re-confirmation
    Given "Nguyen Van A" is confirmed for Day 1 Morning Room A
    When I re-save the schedule without changing "Nguyen Van A"'s slot
    Then no reschedule notification is sent to "Nguyen Van A"
```

---

## Epic 9: Bulk Operations

### US-34: Advance Multiple Candidates in Bulk

**As a** TA Event Coordinator
**I want to** advance all eligible candidates from one pipeline stage to the next in a single action
**So that** I can process hundreds of candidates at once instead of one by one

**Priority:** P0
**FR Reference:** FR-36, FR-37

**Acceptance Criteria:**

```gherkin
Feature: Bulk Stage Advancement

  Scenario: Coordinator advances 200 eligible candidates with full eligibility check
    Given 200 candidates are in "Assessment Completed" stage
    And 5 candidates have unresolved duplicate flags
    And 3 candidates are in "No-Show" status
    When I select all candidates and click "Advance to Scheduled"
    Then the eligibility check pop-up appears showing:
      | Category              | Count |
      | Eligible to advance   | 192   |
      | Excluded: Duplicates  | 5     |
      | Excluded: No-Show     | 3     |
    And I choose "Advance 192 eligible candidates"
    Then 192 candidates are moved to "Scheduled" stage
    And the 5 unresolved duplicates and 3 no-shows remain in their current stage
    And the bulk operation is logged: actor, timestamp, count, stage from, stage to

  Scenario: Entire bulk operation is cancelled when coordinator decides to resolve duplicates first
    Given the eligibility pop-up shows 5 unresolved duplicates
    When I click "Cancel — resolve duplicates first"
    Then no candidates are advanced
    And I am taken to the Duplicates tab with the 5 unresolved records highlighted
```

---

### US-35: Record Pass/Fail Outcomes in Bulk

**As a** TA Event Coordinator
**I want to** record Pass, Fail, or Hold outcomes for multiple candidates simultaneously after interviews
**So that** post-interview processing of hundreds of candidates completes in minutes

**Priority:** P1
**FR Reference:** FR-39

**Acceptance Criteria:**

```gherkin
Feature: Bulk Outcome Recording

  Scenario: Coordinator records Pass outcome for 180 candidates in bulk
    Given 180 candidates have completed interviews and are in "Interview Completed" stage
    When I select 150 candidates and set outcome "Pass" with reason "Met minimum rubric threshold"
    And I confirm the bulk update
    Then 150 candidates' statuses update to "Pass"
    And each outcome is logged with actor, timestamp, reason, and candidate IDs
    And 30 candidates I did not select remain in "Interview Completed" for individual review

  Scenario: Bulk outcome blocked for candidates with pending score edits
    Given 5 candidates have pending score edit approval requests
    When I attempt to include them in a bulk "Pass" outcome
    Then the eligibility check shows: "5 candidates excluded: score edit approval pending"
    And those 5 are excluded from the bulk outcome update
```

---

### US-36: Run Skip-Logic Eligibility Check Before Bulk Actions

**As a** TA Event Coordinator
**I want to** see a pre-flight eligibility check before any bulk operation executes
**So that** I can make an informed decision about which candidates to advance and which need individual attention

**Priority:** P0
**FR Reference:** FR-37

**Acceptance Criteria:**

```gherkin
Feature: Skip-Logic Eligibility Check

  Scenario: Eligibility pop-up surfaces full breakdown before advancement
    Given I have selected 300 candidates for bulk advancement to "Interview Scheduled"
    When I click "Advance"
    Then before any records are updated, a pop-up appears with:
      | Eligibility Status                       | Count |
      | Eligible — will advance                  | 281   |
      | Ineligible: Unresolved duplicate         | 12    |
      | Ineligible: Assessment not completed     | 5     |
      | Ineligible: Waitlisted (not confirmed)   | 2     |
    And I can: proceed with 281, view details of 19 excluded, or cancel entire operation

  Scenario: All selected candidates are ineligible — operation blocked entirely
    Given I select 10 candidates all of which have unresolved duplicates
    When I attempt bulk advancement
    Then the pop-up shows: "0 eligible candidates — operation cannot proceed"
    And the advance button is disabled
    And I am prompted to resolve duplicates first
```

---

## Epic 10: Analytics & Reporting

### US-37: Monitor Real-Time Event Dashboard

**As a** TA Event Coordinator
**I want to** see live event metrics on a dashboard during event execution
**So that** I can identify bottlenecks, track progress, and make real-time operational decisions

**Priority:** P0
**FR Reference:** FR-40

**Acceptance Criteria:**

```gherkin
Feature: Real-Time Event Dashboard

  Scenario: Dashboard shows live metrics refreshing every 5 seconds
    Given the event "Fresher Fair 2026" is in "Event Day" phase
    When I open the event dashboard
    Then I see live metrics including:
      | Metric             | Example Value |
      | Total Registered   | 850           |
      | Checked In         | 423           |
      | In Assessment      | 87            |
      | In Interview       | 45            |
      | Passed             | 156           |
      | Failed             | 98            |
      | No-Show            | 41            |
    And the metrics auto-refresh every 5 seconds without manual page reload
    And I can toggle between overall view and per-track breakdown

  Scenario: Dashboard shows per-track breakdown on demand
    Given the event has two tracks: Engineering and Business
    When I click "View by Track" on the dashboard
    Then I see separate metric panels for "Engineering Track" and "Business Track"
    And each panel shows the same metrics as the overall view but filtered to that track
```

---

### US-38: Build Custom Reports

**As an** HR Analytics Lead
**I want to** build custom reports by selecting dimensions and metrics from the event data
**So that** I can answer ad-hoc business questions without requesting IT involvement

**Priority:** P1
**FR Reference:** FR-41, FR-42

**Acceptance Criteria:**

```gherkin
Feature: Dynamic Report Builder

  Scenario: Analytics Lead builds a conversion funnel report
    Given I am logged in as HR Analytics Lead with view access to "Fresher Fair 2026"
    When I open the Report Builder and select:
      | Dimension | Pipeline Stage |
      | Metric    | Count, Conversion Rate % |
      | Filter    | Track = Engineering |
    And I click "Generate Report"
    Then I see a funnel table:
      | Stage       | Count | Conversion Rate |
      | Registered  | 512   | 100%            |
      | Confirmed   | 489   | 95.5%           |
      | Assessed    | 430   | 87.9%           |
      | Scheduled   | 410   | 95.3%           |
      | Interviewed | 395   | 96.3%           |
      | Passed      | 198   | 50.1%           |
    And I can export the report to CSV or Excel
    And I can save the report as a template named "Engineering Funnel Report"

  Scenario: Analytics Lead without coordinator permissions cannot access candidate PII in reports
    Given I am HR Analytics Lead without TA Coordinator role
    When I build a report including a "Candidate Phone" dimension
    Then the system shows: "You do not have permission to include PII fields in reports"
    And the phone number column is not included in the report output
```

---

### US-39: Review Audit Log for Compliance

**As an** HR Analytics Lead
**I want to** query the event audit log by actor, action type, and date range
**So that** I can verify compliance with scoring policies and data governance requirements

**Priority:** P0
**FR Reference:** FR-44, NFR-06

**Acceptance Criteria:**

```gherkin
Feature: Audit Log

  Scenario: Analytics Lead queries score change audit entries
    Given a score edit was approved for candidate "Nguyen Van A" on April 16
    When I open the Audit Log and filter by:
      | Filter       | Value          |
      | Action Type  | Score Edit     |
      | Date Range   | April 15–17    |
      | Event        | Fresher Fair 2026 |
    Then I see an audit entry containing:
      - Timestamp: 2026-04-16T14:23:00
      - Actor: HM Nguyen (requestor), TA Coordinator Mai (approver)
      - Action: Score Edit Approved
      - Details: Criterion "Technical Knowledge" changed from 5 to 3
      - Candidate: Nguyen Van A

  Scenario: Audit log cannot be modified or deleted
    Given an audit entry exists for a bulk advancement operation
    When I attempt to edit or delete the audit entry via any UI action
    Then the system shows no edit or delete option on audit log entries
    And attempting to modify the record via API without appropriate system-level privilege returns 403
    And the original entry remains intact

  Scenario: Audit log query returns no results for non-existent action type
    Given I query the audit log for action type "Candidate Delete" for "Fresher Fair 2026"
    And no candidate deletions occurred for this event
    Then the audit log returns: "No entries found for the selected filters"
    And no error is thrown
```
