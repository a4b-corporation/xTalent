# Interaction Map: ECR Module
## xTalent HCM Solution | 2026-03-26

Each feature is mapped to its primary interaction pattern, screen location, key user actions, and opportunities for AI-assisted friction reduction.

---

## Interaction Type Definitions

| Type | Description |
|------|-------------|
| **Wizard** | Multi-step guided flow with forward/back navigation; used for complex creation tasks |
| **Command** | Single action invoked from a context menu or action button; immediate or confirmation-gated |
| **Dashboard** | Read-only or low-interaction data view; primary purpose is situational awareness |
| **Grid+Detail** | List/table view with row selection opening a detail panel or page |
| **Form+Submit** | Single-page or modal form with submit action; lighter than a wizard |
| **Scan** | Camera or barcode scanner input as primary interaction modality (kiosk) |
| **Deep Link** | Tokenized URL grants access to a bounded scope without persistent session |
| **Timeline** | Chronological, append-only read-only log view |

---

## Interaction Map

| Feature ID | Feature Name | Interaction Type | Primary Screen | Key User Actions | AI-Assist Opportunity |
|-----------|-------------|-----------------|----------------|------------------|-----------------------|
| ECR-M-001 | Event Configuration | Form+Submit | /events/new (Step 1) | Fill name, dates, location, capacity; save draft | Auto-suggest event name from past events; suggest capacity from historical registrations |
| ECR-T-001 | Event Lifecycle Management | Command | /events/:id (Overview tab) | Publish, Open Registration, Start, Close, Archive (each a command button with confirmation) | Warn TA if required setup steps are incomplete before allowing lifecycle advance |
| ECR-M-002 | Track Configuration | Grid+Detail | /events/:id/tracks | Add track, edit track name/headcount/questions, link job request | Suggest headcount targets based on similar past event tracks |
| ECR-T-002 | Registration Form Builder | Wizard | /events/:id/form | Drag-and-drop field ordering, add/remove fields, toggle required, preview, publish form | Auto-generate default field set based on track type (fresh grad vs. experienced) |
| ECR-T-003 | Event Cloning | Wizard | /events (from kebab menu) or /templates/:id | Select source event/template, choose sections to clone, set new dates, save as draft | Suggest optimal dates based on similar events; flag if copied capacity exceeds room availability |
| ECR-T-004 | Candidate Self-Registration Portal | Wizard | /register/:eventSlug | Fill personal info, select track, answer questions, upload docs, submit | Real-time field validation; suggest track based on uploaded CV keywords (future) |
| ECR-T-005 | Duplicate Flag Resolution | Grid+Detail | /events/:id/candidates (Duplicate Flags sub-tab) | View flagged pairs side-by-side, Merge / Reject Duplicate / Override | Highlight differing fields automatically; suggest merge direction based on data completeness |
| ECR-T-006 | Waitlist Management | Grid+Detail | /events/:id/candidates (Waitlist sub-tab) | View queue, manually promote, set auto-promote toggle | Predict waitlist conversion rate from historical data |
| ECR-M-003 | SBD Management | Grid+Detail | /events/:id/candidates (SBD Management sub-tab) | View SBD list, regenerate individual, batch generate, export | Alert if SBD prefix collision detected with another event |
| ECR-T-007 | Assessment Delivery | Dashboard | /events/:id/tracks/:trackId (Assessment section) | View placeholder; no interactive actions until vendor activation | N/A (deferred) |
| ECR-M-004 | Schedule Matrix Builder | Grid+Detail | /events/:id/schedule (Schedule Matrix sub-tab) | Add rooms, add time slots, set capacity per cell, assign track to room, save grid | Suggest room assignments based on track headcount vs. room capacity; flag over-subscription |
| ECR-T-008 | Candidate Slot Allocation | Wizard | /events/:id/schedule (Allocation sub-tab) | Choose algorithm (Round-Robin / Fill-First), run allocation preview, review conflicts, commit | Optimize allocation to balance room fill rates; flag candidates with scheduling conflicts |
| ECR-T-009 | Slot Invitation and Confirmation | Command + Dashboard | /events/:id/schedule (Invitations sub-tab) | Send invitation batch, view confirmation status table, send reminders to unconfirmed | Auto-send reminder 48h before session to unconfirmed candidates |
| ECR-T-010 | Kiosk Check-In | Scan | /checkin (kiosk app) | Scan QR or enter SBD, confirm check-in; offline fallback writes locally | N/A (speed-critical, no AI latency acceptable) |
| ECR-T-011 | Walk-In Registration | Form+Submit | /walkin (kiosk app) | Fill personal info, capture doc photo, confirm provisional SBD | Suggest track based on stated position interest |
| ECR-T-012 | Offline Sync and Manual Review | Grid+Detail | /events/:id/onsite (Sync Status sub-tab, TA view) | Review sync conflicts, resolve duplicates, approve walk-ins, trigger manual sync | Flag high-risk conflicts (SBD collision, multiple check-ins) automatically |
| ECR-T-013 | Session Digest Dispatch | Command + Form+Submit | /events/:id/interviews (Session Digest sub-tab) | Select session(s), review panel assignments, configure link TTL, dispatch | Auto-detect sessions missing panel assignments and warn before dispatch |
| ECR-T-014 | HM Interview Kit | Deep Link + Grid+Detail | /kit/:token | View candidate queue, open candidate detail, submit score (with confirmation modal), skip | Surface top candidate summary from CV keywords for faster scoring context |
| ECR-T-015 | Score Edit Request | Form+Submit + Command | /events/:id/interviews (Score Edit Requests sub-tab) | HM submits edit request via KitLink; TA reviews and approves/rejects unlock | Flag statistically anomalous score changes (e.g., score flip from low to high) |
| ECR-M-005 | Panel and Interviewer Assignment | Grid+Detail | /events/:id/interviews (Panel Assignment sub-tab) | Assign interviewers to sessions, set hard/soft, remove assignments | Suggest interviewers based on track expertise tags |
| ECR-T-016 | Bulk Email Dispatch | Wizard | /events/:id/communications (Send Email) | Select template, filter recipients, preview count, confirm send; monitor async job | Suggest best send time based on open-rate patterns; warn if recipient list seems unexpectedly small |
| ECR-M-006 | Email Template Management | Grid+Detail | /settings/email-templates | Create template, edit (rich text + merge tags), preview, version, activate/deactivate | Suggest merge tags based on context; grammar/tone check on subject line |
| ECR-A-001 | Communication Job Tracking | Dashboard | /events/:id/communications (Job History) | Filter by date/event, view delivery breakdown, retry failed batch | Alert TA when bounce rate exceeds 10% threshold |
| ECR-A-002 | Live Event Dashboard | Dashboard | /events/:id/analytics (Live Dashboard tab) | View real-time charts; auto-refresh; no edit actions | Proactively surface rooms trending toward overflow; alert on stalled check-in rate |
| ECR-A-003 | Custom Report Builder | Wizard | /events/:id/analytics (Custom Reports tab) | Select dimensions, metrics, date range; preview table; export CSV/Excel | Suggest common dimension combinations based on user's previous report history |
| ECR-A-004 | Audit Log Viewer | Timeline | /events/:id/audit | Filter by actor, action, entity type, date; paginate; export (read-only) | Highlight unusual patterns (e.g., same actor modifying same record repeatedly) |
| ECR-A-005 | Event Performance Analytics | Dashboard | /events/:id/analytics (Performance Report tab) | View KPI summary; compare vs. previous events; export PDF | Surface insight: "Show-up rate 12% below average — possible cause: short registration window" |
