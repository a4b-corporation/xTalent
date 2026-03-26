# Step 1 Summary: Pre-Reality
*ECR Module | Completed: 2026-03-25*

---

## What We Learned

### The Core Problem Is Structural, Not Feature-Level
Traditional ATS platforms are job-requisition-centric by design. Mass hiring events in Vietnam require an event-centric data model: one event containing multiple recruitment tracks, each track mapped to job requests, with shared physical resources (rooms, panels, shifts) managed within the event scope. No existing platform (Avature, Yello, Pinpoint, HackerRank) provides this combination out of the box.

### SBD Is the Operational Identity Anchor
In Vietnamese fresher and job fair contexts, email is not a reliable unique identifier. The Số Báo Danh (SBD) — a short numeric code assigned to each candidate — is the operational standard used by TA staff, onsite operations, and panel interviewers on event day. This must be a first-class system concept, not a workaround field.

### Offline Is Not Optional
Vietnamese event venues (university campuses, convention centers) have unreliable shared Wi-Fi. Any kiosk-based check-in system that requires persistent internet will fail in the field. Offline-first architecture with local queue and sync-on-reconnect is a hard requirement, not a nice-to-have.

### Duplicate Detection Requires Multi-Factor Logic
Email uniqueness cannot be assumed. Phone number + student ID + normalized name is the correct composite identity key. The duplicate detection workflow must surface alerts to TA for human resolution rather than automatically blocking or merging.

### The Data Model Has Been Validated at Two Levels
The Event → Track → Request hierarchy was derived from direct analysis of VNG Fresher program and MWG retail hiring structures. It generalizes to Job Fair, Fresher Program, Walk-In Drive, and Campus Day formats. Edge cases (multi-day campus tours with rotating HMs) require validation during BRD.

### Key Competitive Differentiator
No single platform combines: event-centric multi-track hiring + SBD identity management + offline kiosk operations + Vietnamese market localization. ECR's market position is a focused vertical advantage within xTalent, not a broad ATS replacement.

---

## Key Decisions Made

1. **Event as the organizing unit** — not the job requisition. The data model is Event → Track → Request, not Requisition → Pipeline.

2. **SBD generation is decoupled from email delivery** — SBD can be assigned and used for check-in even if the candidate has not received the confirmation email. This is operationally critical for walk-in candidates.

3. **Duplicate detection is advisory, not automated** — the system surfaces conflicts; humans resolve them. Automated merge or rejection risks data loss and candidate harm.

4. **Offline mode is the baseline for kiosk** — the system must be designed offline-first; online is an enhancement, not the assumption.

5. **Manager access links expire 24 hours after event day** — this is a data governance control, not a UX decision. It must be enforced at the infrastructure level, not just the UI.

6. **Assessment capability scope is flagged as an open question** — build vs. integrate decision (OQ-01) must be resolved in BRD before assessment architecture can be finalized.

---

## Critical Insights

- **Scale is the design driver.** 500–1,000 candidates over 2 days means every manual step is a bottleneck. The system must automate scheduling allocation, bulk communications, and status propagation as default behavior, with manual override available.

- **The Hiring Manager experience is underserved.** HMs currently receive a paper list in the morning and score on paper forms post-event. The digital interview kit (real-time queue, digital CV, in-session scoring) is a high-value differentiator that directly addresses HM satisfaction.

- **Retail walk-in hiring has different parameters than tech fresher programs.** Shorter interview cycles (10–15 min vs. 45–60 min), higher throughput, simpler scoring. The scheduling and capacity model must accommodate both extremes through configuration, not separate codepaths.

- **Face capture has a legal dependency.** Decree 13/2023/ND-CP (Vietnamese personal data protection) applies to biometric data. Legal review must occur before FR-25 (Face Capture) is scoped for development.

- **Source channel attribution adds long-term strategic value.** Tracking which channels produce candidates who convert to hire enables TA teams to optimize event marketing spend over time. This is low incremental implementation cost with high analytical payoff.

---

## What Step 2 Needs

Step 2 (Reality / BRD) must do the following with the material from Step 1:

1. **Resolve OQ-01** (assessment platform — build vs. integrate) with a formal build/buy/integrate decision log supported by xTalent platform owners and technology leadership.

2. **Define score aggregation logic** (OQ-05) with input from Hiring Manager stakeholders — this is a business rule that directly affects the interview data model.

3. **Conduct legal review** of face capture (OQ-06) against Decree 13/2023/ND-CP and document the compliance obligations or constraints.

4. **Validate the Event → Track → Request model** against at least two real enterprise customers (one tech, one retail) through structured workshops.

5. **Confirm integration contracts** with the xTalent Job Request module — specifically, what fields are required on a Job Request for ECR Track linkage.

6. **Specify the SBD format rules** in detail — prefix logic, numeric range, collision detection, edge cases for track deletion and re-addition.

7. **Define the Candidate Portal experience** (OQ-04) — transient event-scoped vs. persistent profile — as this drives the candidate-facing architecture.

8. **Confirm SMS gateway** (OQ-02) and badge printer hardware standard (OQ-03) with infrastructure and procurement teams.
