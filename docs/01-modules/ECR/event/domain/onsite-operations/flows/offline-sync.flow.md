# Use Case: Offline Sync — Kiosk Reconnection and Queue Draining
## Bounded Context: Onsite Operations
## ECR Module | 2026-03-25

**Actor:** System (automated on connectivity restoration) or Kiosk Operator (manual trigger)
**Trigger:**
1. Kiosk detects network connectivity restored after an offline period
2. Kiosk Operator manually triggers sync from the operations dashboard
3. Configured sync timer fires (e.g., every 60 seconds when online, to catch records created during brief disconnections)

**Preconditions:**
- KioskSession is in `ACTIVE` or `SUSPENDED` state (not CLOSED)
- `OfflineSyncQueue` contains at least 1 item with `sync_item_status = PENDING` or `FAILED`
- Server is reachable (connectivity confirmed before attempting sync)

**Postconditions:**
- Every item in the OfflineSyncQueue has been processed: each is either `ACKNOWLEDGED` or `CONFLICT_ROUTED`
- No item is silently discarded (BR-08)
- Each successfully acknowledged CheckInRecord has `sync_status = SYNCED` and a `CheckInConfirmed` event emitted
- Each conflicted record has `sync_status = CONFLICT`, a `ManualReviewItem` created, and a `CheckInConflict` event emitted
- `KioskSessionSynced` event emitted with summary counts at end of sync run

**Business Rules:** BR-08

---

## Happy Path: Full Queue Drain (No Conflicts)

1. Kiosk detects connectivity restored (or timer fires or operator triggers).
2. Kiosk transitions `KioskSession.session_state` from `SUSPENDED` to `SYNCING`.
3. Kiosk reads the `OfflineSyncQueue` ordered by `queue_position` ascending.
4. For each item in the queue (processed strictly in order):

   **4a. Submit to server:**
   - Kiosk sends the `CheckInRecord` payload to the server sync endpoint.
   - Payload includes: `checkin_id`, `event_id`, `registration_id`, `sbd_number`, `check_in_method`, `captured_at`, `kiosk_session_id`, `face_capture_ref` (if present).

   **4b. Server validates:**
   - SBD exists in server registration records for this event.
   - No existing non-cancelled CheckInRecord for this candidate at this event.
   - SBD is within the kiosk's assigned SBDBlock range (for walk-in records).
   - Slot assignment consistency check (advisory — auto-correctable).

   **4c. Server acknowledges:**
   - Returns: `{ status: "ACKNOWLEDGED", synced_at: "<server_timestamp>" }`.
   - Kiosk updates `OfflineSyncQueueItem.sync_item_status = ACKNOWLEDGED`.
   - Kiosk updates `CheckInRecord.sync_status = SYNCED`, `synced_at = server_timestamp`.
   - Kiosk emits `CheckInConfirmed` event with the CheckInRecord reference.

5. Processing continues to the next queue item immediately. One item's acknowledgment does not gate the next.
6. After all items are processed:
   - Kiosk transitions `KioskSession.session_state` back to `ACTIVE`.
   - Kiosk emits `KioskSessionSynced` with:
     - `records_synced` = count of ACKNOWLEDGED items
     - `conflicts_routed` = 0 (happy path)
     - `synced_at` = sync run completion timestamp
7. If KioskSession's SBDBlock is `NEAR_EXHAUSTED` (< 10 remaining), kiosk requests a new block from the server in the same connection window.

---

## Alternate Flows

### A1: Partial Sync — Some Items Conflict, Others Succeed

During step 4:
- Some items validate successfully (ACKNOWLEDGED).
- Some items fail server validation (conflict detected).

For each conflicting item (step 4b validation failure):
- Server returns: `{ status: "CONFLICT", conflict_type: "<type>", detail: "<description>" }`.
- Kiosk updates `OfflineSyncQueueItem.sync_item_status = CONFLICT_ROUTED`.
- Kiosk updates `CheckInRecord.sync_status = CONFLICT`, `conflict_type` set from server response.
- Server creates a `ManualReviewItem` for this record (server-side creation, not kiosk-side).
- Kiosk emits `CheckInConflict` event with `review_item_id` reference returned by server.

Processing continues to the next queue item (conflict does not block queue drain — BR-08 atomicity per record).

After all items:
- `KioskSessionSynced` emitted with accurate `records_synced` and `conflicts_routed` counts.
- TA Coordinator receives notification of pending ManualReviewItems.

### A2: Network Drop During Sync Run

During step 4, mid-queue:
- Network connectivity drops before all queue items are processed.
- Items that were `ACKNOWLEDGED` remain ACKNOWLEDGED (their CheckInRecords are now SYNCED — no regression).
- Items currently in `PROCESSING` state:
  - If server acknowledged before drop: server-side record exists. On next sync, kiosk re-submits; server detects `checkin_id` already exists and returns ACKNOWLEDGED (idempotent server endpoint).
  - If server did not acknowledge: item status remains `PENDING` (not corrupted). Kiosk resets it from `PROCESSING` to `PENDING` after timeout.
- Kiosk transitions back to `SUSPENDED` state.
- Sync run will resume from the first non-ACKNOWLEDGED item on next reconnection.
- No `KioskSessionSynced` event is emitted for an incomplete run.

### A3: Transient Network Error on a Single Item

During step 4 for a specific item:
- Server is unreachable (timeout, HTTP 5xx, network error — not a validation failure).
- Kiosk updates `OfflineSyncQueueItem.sync_item_status = FAILED`, increments `sync_attempt_count`, records `last_sync_attempt_at`.
- The item is **not** moved to CONFLICT_ROUTED — it will be retried on the next sync run.
- Processing continues to the next queue item (the failure does not block others).
- Item remains in the queue until it either succeeds (ACKNOWLEDGED) or is explicitly routed to conflict (CONFLICT_ROUTED) by server validation on a subsequent attempt.

**Retry behavior:** No backoff between items within a single sync run. Retries happen on subsequent sync runs (timer-based or connectivity events). Indefinite retry is permitted during the event day; at KioskSession close, all remaining FAILED items are force-routed to ManualReviewQueue.

### A4: Manual Sync Trigger by TA Coordinator

TA Coordinator opens the operations dashboard and clicks "Force Sync" on a kiosk:
- If kiosk is SUSPENDED: dashboard sends a sync command to the kiosk (push via websocket or polling).
- Kiosk checks connectivity. If online, proceeds with Happy Path.
- If kiosk cannot be reached (device offline): dashboard displays "Kiosk unreachable — sync will occur automatically on reconnection."

### A5: New SBDBlock Request During Sync

At step 7 (or detected during step 4 if NEAR_EXHAUSTED):
- Kiosk requests new block: `POST /kiosk-sessions/{sessionId}/sbd-blocks`.
- Server allocates the next available contiguous range and returns it.
- Kiosk updates `KioskSession.sbd_block` with the new block reference.
- Old block is marked `RECLAIMED` or `EXHAUSTED` on the server.
- This happens in the same connection as the sync run; no separate reconnection needed.

---

## Conflict Detection — Server-Side Validation Rules

| Conflict Type | Detection Logic | ManualReviewItem Created |
|---------------|----------------|--------------------------|
| `DUPLICATE_CHECKIN` | A non-cancelled CheckInRecord with the same `registration_id` already exists for this event | Yes |
| `SBD_CONFLICT` | The `sbd_number` is assigned to a different `registration_id` in server records | Yes |
| `SBD_NOT_FOUND` | The `sbd_number` does not exist in any confirmed registration for this event | Yes |
| `RECORD_MISMATCH` | Manual Entry record; candidate identity cannot be auto-matched to any registration | Yes |

All conflict types route to ManualReviewQueue. None are auto-resolved by the server. TA Coordinator performs resolution.

---

## Manual Review Queue Routing

When a record is routed to `CONFLICT_ROUTED`:
1. Server creates a `ManualReviewItem` with:
   - `checkin_id` reference
   - `conflict_type` and `conflict_detail` (human-readable explanation)
   - `review_state = OPEN`
   - `created_at = server_now()`
2. Server returns the `review_item_id` to the kiosk in the sync response.
3. Kiosk stores `manual_review_item_id` on the CheckInRecord.
4. TA Coordinator dashboard displays the ManualReviewItem in the review queue.

**Resolution options for TA Coordinator:**
- `APPROVE`: The record is valid despite the conflict signal. CheckInRecord is promoted to SYNCED.
- `REJECT`: The record is invalid (genuine duplicate, fraudulent entry). CheckInRecord is cancelled.
- `MERGE`: Manual Entry walk-in matched to an existing registration. CheckInRecord linked to the registration; SYNCED.

On resolution: `ManualReviewResolvedEvent` is emitted. If APPROVED or MERGED: `CheckInConfirmed` is emitted (delayed path). Analytics & Audit receives both events.

---

## Domain Events Emitted

- `CheckInConfirmed` — per successfully synced record (one per ACKNOWLEDGED item)
- `CheckInConflict` — per record routed to ManualReviewQueue (one per CONFLICT_ROUTED item)
- `KioskSessionSynced` — once per completed sync run (summary)
- `ManualReviewResolvedEvent` — when a TA Coordinator resolves a ManualReviewItem (may result in delayed `CheckInConfirmed`)

---

## Sequence Diagram

```
KioskApp       OfflineSyncQueue    Server          ManualReviewQueue    Interview Mgmt
   │                  │               │                    │                  │
   │ (connectivity restored)          │                    │                  │
   │── state=SYNCING   │               │                    │                  │
   │── ReadQueue() ────►│               │                    │                  │
   │◄── [item1, item2, item3]           │                    │                  │
   │                   │               │                    │                  │
   │── POST /sync/item1 ────────────────►│                    │                  │
   │◄── ACK (synced_at) ────────────────│                    │                  │
   │── item1: ACKNOWLEDGED             │                    │                  │
   │── CheckInRecord1: SYNCED          │                    │                  │
   │── Emit CheckInConfirmed ─────────────────────────────────────────────────►│
   │                   │               │                    │                  │
   │── POST /sync/item2 ────────────────►│                    │                  │
   │◄── CONFLICT (DUPLICATE_CHECKIN) ──│                    │                  │
   │── item2: CONFLICT_ROUTED          │                    │                  │
   │── CheckInRecord2: CONFLICT        │                    │                  │
   │── Emit CheckInConflict            │── CreateManualReviewItem ─────────────►│
   │                   │               │                    │                  │
   │── POST /sync/item3 ────────────────►│                    │                  │
   │◄── ACK ───────────────────────────│                    │                  │
   │── item3: ACKNOWLEDGED             │                    │                  │
   │── Emit CheckInConfirmed ─────────────────────────────────────────────────►│
   │                   │               │                    │                  │
   │── state=ACTIVE    │               │                    │                  │
   │── Emit KioskSessionSynced (synced=2, conflicts=1)       │                  │
```

---

## Notes

- **Atomicity per record, not per run.** A sync run processes each record independently. A conflict on item N does not block item N+1. The OfflineSyncQueue guarantees ordering, not all-or-nothing atomicity.
- **No silent data loss.** A record leaves the OfflineSyncQueue only when its `sync_item_status` is either `ACKNOWLEDGED` (success) or `CONFLICT_ROUTED` (human review required). `FAILED` items (transient errors) remain in the queue for retry. This is the BR-08 guarantee.
- **Server endpoint idempotency.** The server sync endpoint uses `checkin_id` as the idempotency key. Re-submitting a record that was already successfully synced returns `ACKNOWLEDGED` without creating a duplicate. This ensures safe retry on network drops mid-sync.
- **KioskSession close procedure.** When a TA Coordinator closes a KioskSession, the system first checks for non-ACKNOWLEDGED items in the OfflineSyncQueue. If any exist, the system forces a final sync attempt. If items remain after the attempt, they are force-routed to ManualReviewQueue before the session is marked CLOSED.
- **Provisional queue entries.** `CheckInCaptured` events were emitted when records were first created (during the offline period). Interview Management BC has already added those candidates to the queue in Provisional state. The `CheckInConfirmed` events emitted during sync will promote those entries to Confirmed state. If sync results in a CONFLICT for a record, Interview Management should receive the `CheckInConflict` event and mark the queue entry accordingly.
