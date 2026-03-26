# ECR-T-012: Offline Sync and Manual Review
**Type:** Transaction | **Priority:** P2 | **BC:** BC-05
**Permission:** ecr.sync.manage

## Purpose

When kiosk devices operate in offline mode (ECR-T-010 and ECR-T-011), all check-ins and walk-in registrations are stored in a local SQLite queue. When connectivity is restored, the kiosk app transmits the queued records to the server. The server applies conflict detection (duplicate SBD, already-checked-in, duplicate walk-in). Unresolved conflicts surface in a TA review queue for manual resolution.

---

## States

| State | Description | Entry Condition | Exit Transitions |
|-------|-------------|----------------|-----------------|
| Queued | Record in kiosk SQLite; not yet synced | Offline kiosk action | → Syncing |
| Syncing | Device transmitting batch to server | Connectivity restored / manual sync trigger | → Synced / ConflictFlagged |
| Synced | Server accepted record; no conflict | Clean sync | Terminal (success) |
| ConflictFlagged | Server detected conflict; needs TA review | Duplicate or integrity issue found | → Resolved / Rejected |
| Resolved | TA accepted / merged the conflicted record | TA action | Terminal |
| Rejected | TA rejected the conflicted record | TA action | Terminal |

---

## Flow

### Step 1: Kiosk Sync Trigger
**Screen:** Kiosk app — home screen sync indicator
**Actor sees:**
- Sync status bar: "Offline queue: N records pending" with [Sync Now] button
- Auto-sync happens automatically when connectivity is detected (no manual action required)
- Manual [Sync Now] available for staff who want immediate sync
**Actor does:** Optionally taps [Sync Now]; otherwise sync happens automatically
**System does:**
- Calls `POST /kiosk/sync` with batch payload: array of { record_type, local_id, payload, device_id, captured_at }
- Device receives response: { accepted: N, conflicts: M, sync_id }
- Updates queue status in local SQLite
**Validation:** Payload schema validation on server
**Errors:**
- "Sync failed: server unreachable. Will retry automatically." (retries with exponential backoff, max 5 attempts)
- "Sync partially completed: {N} records accepted, {M} require review."

### Step 2: Server Conflict Detection (Automated)
**Actor:** System
**System does for each record:**
- **Check-in records:** Verify SBD exists in event; verify candidate not already checked in by another device; verify event is in InProgress state
- **Walk-in records:** Check phone/email against existing registrations; verify SBD sequence integrity
- Records that pass all checks: marked Synced; `CandidateCheckedIn` or `WalkInRegistered` events emitted with `source: OFFLINE_SYNC`
- Records with conflicts: marked ConflictFlagged; conflict_reason stored; surfaced in TA review queue

**Conflict types:**
| Code | Description |
|------|-------------|
| ALREADY_CHECKED_IN | SBD already has a Confirmed check-in from another device or online scan |
| SBD_NOT_FOUND | Kiosk SBD does not match any registration in this event |
| DUPLICATE_WALKIN | Walk-in phone/email matches existing registration |
| EVENT_MISMATCH | Record belongs to a different event than the active kiosk session |
| TIMESTAMP_ANOMALY | Captured_at is outside valid event window (> 2h drift) |

### Step 3: TA Sync Review Queue
**Screen:** /events/:id/sync-review (accessible from event Operations tab)
**Actor sees:**
- Summary: "Sync completed: {N} records auto-resolved, {M} require manual review"
- Filterable list of ConflictFlagged records:
  - Columns: Device ID, Record Type (CheckIn / WalkIn), SBD / Name, Conflict Type, Captured At, Synced At
  - Status badge: Pending Review / Resolved / Rejected
- Bulk action: [Reject All] (for obvious junk/anomaly batches)
**Actor does:** Clicks a record to open detail review panel
**System does:** Loads conflict detail
**Validation:** None
**Errors:** None

### Step 4: Conflict Resolution
**Screen:** /events/:id/sync-review/:conflictId
**Actor sees:**
- Left panel: offline record data (SBD, name, timestamp, device, raw payload)
- Right panel: conflicting server record (if applicable)
- Conflict reason prominently displayed: e.g., "ALREADY_CHECKED_IN — This candidate was checked in online at 08:43 from Kiosk-02"
- Action buttons:
  - [Accept Offline Record] — overrides server record with offline data (e.g., offline was the true first check-in)
  - [Keep Server Record] — discards offline record as duplicate/invalid
  - [Merge] — for walk-in duplicates: link offline walk-in to existing registration
- Resolution notes field (required for Accept; optional for Keep/Merge)
**Actor does:** Reviews; selects action; enters note if required; clicks [Confirm]
**System does:**
- Accept: updates server record to reflect offline action; timestamps adjusted; emits corrected event
- Keep: marks conflict as Rejected; no server data changed; offline record archived
- Merge: links walk-in to existing candidate; assigns permanent SBD replacing TMP- prefix
- Emits: `KioskSyncCompleted` or `ConflictFlagged` resolution events
- Writes audit log: actor, action, record IDs, resolution_notes, resolved_at
**Validation:** Resolution notes required when choosing Accept
**Errors:** "Resolution note is required when accepting an offline record."

### Step 5: Sync Summary
**Screen:** /events/:id/sync-review (after all conflicts resolved)
**Actor sees:** "All sync conflicts resolved. {N} accepted, {M} rejected." with [Export Sync Report] button
**System does:** Emits `KioskSyncCompleted` { sync_id, accepted, rejected, resolved_by }

---

## Notifications Triggered

| Trigger | Notification | Recipient |
|---------|-------------|----------|
| Sync completed with conflicts | In-app: "Kiosk sync from {device_id} has {M} records requiring review." | TA users with ecr.sync.manage |
| All conflicts resolved | In-app: "Sync review complete for {event_name}." | TA who opened the review queue |

---

## Business Rules Enforced

- **BR-SYNC-001:** Auto-sync triggers within 30 seconds of connectivity restoration; no staff action required.
- **BR-SYNC-002:** Synced records retain the original captured_at timestamp (not the sync time) for accurate event reporting.
- **BR-SYNC-003:** ALREADY_CHECKED_IN conflicts default to Keep Server Record (server is authoritative); TA must explicitly choose Accept to override.
- **BR-SYNC-004:** TIMESTAMP_ANOMALY records (> 2h drift) are automatically Rejected without TA review; logged to audit.
- **BR-SYNC-005:** Rejected sync records are archived for 30 days and then purged; TA can export before purge.
- **BR-SYNC-006:** TMP- provisional SBDs must be replaced with permanent SBDs before event close; any outstanding TMP- SBDs at event close trigger a TA alert.

---

## Empty State

"No pending sync conflicts. All kiosk data has been successfully synchronized." with green checkmark.

---

## Edge Cases

- Device sync while event is Closed: server accepts check-in records with a warning flag ("Post-close sync record") but does not change event status; included in sync report with annotation.
- Multiple devices sync simultaneously: server uses database-level optimistic locking per candidateId to prevent race conditions.
- Partial sync failure (network drops mid-batch): server processes only fully received records; incomplete batch is re-queued on device; each record has idempotency key (local_id + device_id) to prevent double-processing on retry.
- Sync queue exceeds 500 records: server processes in chunks of 100; progress shown on kiosk sync bar.
