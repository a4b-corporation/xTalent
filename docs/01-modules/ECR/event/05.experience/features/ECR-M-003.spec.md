# ECR-M-003: SBD Management
**Type:** Masterdata | **Priority:** P1 | **BC:** BC-02
**Permission:** ecr.sbd.manage

## Purpose

SBD (So Bao Danh — Candidate Identification Number) is the primary candidate identifier on event day. This feature allows TA staff to view assigned SBDs per event, regenerate individual SBDs for edge cases, batch-generate missing SBDs, and configure SBD format. SBDs are automatically issued on successful registration; this screen handles gaps, corrections, and configuration.

---

## Fields

### SBD Format Configuration

| Field | Type | Required | Validation | Notes |
|-------|------|----------|-----------|-------|
| sbd_prefix | String | No | 0–5 alphanumeric chars | E.g., "ECR" → produces "ECR00123" |
| sbd_pad_length | Integer | Yes | 3–8 digits | Total zero-padded numeric portion length |
| sbd_sequence_start | Integer | Yes | 1–9999; default 1 | Starting number; locked once first SBD is issued |
| sbd_scope | Enum | Yes | PerEvent / PerTrack | PerEvent: unique across whole event; PerTrack: unique per track |

Format configuration is accessible via event Settings tab and is locked once any SBD has been issued for the event.

### Per-Candidate SBD Record (read-only display)

| Column | Notes |
|--------|-------|
| SBD | Formatted value e.g. "ECR00042" |
| Candidate Name | Full name |
| Track | Track name |
| Registration Status | Registered / Waitlisted / Cancelled |
| Issued At | Timestamp |
| Source | Auto / Manual (regenerated) |

---

## List View

**Screen:** /events/:id/sbds

**Search:** By SBD value (exact prefix match) or candidate name (partial)
**Filters:** Track (multi-select), Status (Registered / Waitlisted / Cancelled), Source (Auto / Manual)
**Default sort:** SBD ascending
**Page size:** 50 rows; pagination

---

## Actions

| Action | Scope | Description | Guard |
|--------|-------|-------------|-------|
| Regenerate SBD | Single candidate | Issues a new SBD and voids the old value | Confirmation dialog: "Old SBD ECR00042 will be voided. All printed materials must be updated." |
| Batch Generate Missing | Event-level | Issues SBDs to all registered/waitlisted candidates who have none | Preview count before confirm; runs async; toast on completion |
| Export SBD List | Event-level | CSV download: SBD, name, track, status, issued_at | Available at any event state |
| Print SBD Badges | Selected rows | Opens print-preview for selected SBD badges (PDF) | Requires print template configured |

---

## Empty State

"No SBDs issued yet. SBDs are auto-issued on candidate registration. Use Batch Generate to issue any missing SBDs." with [Batch Generate] button.

---

## Business Rules

- SBD is globally unique within scope (PerEvent or PerTrack).
- A voided SBD cannot be reissued to another candidate in the same event.
- If sbd_scope = PerTrack, the SBD list is grouped by track with sub-headers.
- Alert banner shown when fewer than 10 SBDs remain in the sequence (approaching pad_length rollover): "SBD sequence is near capacity. Increase pad length or adjust prefix."
