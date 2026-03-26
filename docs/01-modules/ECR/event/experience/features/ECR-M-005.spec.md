# ECR-M-005: Panel and Interviewer Assignment
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-06
**Permission:** ecr.panel.manage

## Purpose

Assigns Hiring Manager (HM) interviewers to interview sessions (room + slot combinations) within an event. Supports hard assignment (specific person to specific slot) and soft assignment (available pool for flexible scheduling). Interviewer assignments drive KitLink generation in ECR-T-013 (Session Digest Dispatch).

---

## Fields

### Panel Definition

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| session_id | Reference | Yes | Existing room × slot cell in schedule matrix | Links to ECR-M-004 grid cell |
| interviewer_id | Reference | Yes | Active HM user in the system | Can add multiple interviewers per session |
| assignment_type | Enum | Yes | Hard / Soft | Hard = confirmed seat; Soft = available pool, finalized later |
| role | Enum | No | Lead / Panelist / Observer | Default: Panelist |
| notes | String | No | Max 200 chars | E.g., "Remote via video link" |

### Per-Session Panel View (display)

| Column | Notes |
|--------|-------|
| Interviewer Name | Full name with avatar |
| Assignment Type | Hard / Soft badge |
| Role | Lead / Panelist / Observer |
| KitLink Status | Not Generated / Generated / Sent / Expired |
| Actions | Remove / Change Type / Generate Kit |

---

## List View

**Screen:** /events/:id/panels

Presented as two views (tab toggle):

**By Session view:**
- Groups assignments by room and slot
- Shows session time, room, track, interviewer count
- Click to expand → list of assigned interviewers with actions

**By Interviewer view:**
- Groups assignments by interviewer
- Shows all sessions an interviewer is assigned to
- Useful for detecting over-assignment (interviewer in two concurrent sessions)

**Search:** By interviewer name
**Filters:** Assignment type (Hard / Soft), Session date, Track, KitLink status
**Default sort:** Session date/time ascending

---

## Empty State

"No interviewers assigned yet. Assign panelists to interview sessions so KitLinks can be generated." with [Assign Interviewer] button.

---

## Bulk Actions

| Action | Scope | Notes |
|--------|-------|-------|
| Generate KitLinks for selected | Selected Hard assignments | Batch-generates KitLinks; requires ECR-T-013 dispatch to send |
| Remove from all sessions | Single interviewer | Removes all assignments for an interviewer; confirmation required |
| Export panel list | Event-level | CSV: interviewer, session, room, slot, assignment_type, role |

---

## Business Rules

- An interviewer cannot be Hard-assigned to two sessions with overlapping times (system blocks with error: "Interviewer is already assigned to an overlapping session").
- Soft assignments do not block overlapping time checks.
- KitLink is generated per interviewer per session (not per event); one interviewer may have multiple KitLinks for different sessions.
- Removing a Hard assignment after KitLink has been sent: system warns "KitLink has already been sent to this interviewer. Removing assignment will not revoke the link — contact them directly." (KitLinks are not technically revocable; they expire by TTL).
- Maximum 10 interviewers per session; warning shown at 8.
