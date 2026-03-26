# ECR-A-002: Live Event Dashboard
**Type:** Analytics | **Priority:** P0 | **BC:** BC-08
**Permission:** ecr.analytics.view

## Purpose

Provides TA Event Coordinators with a real-time view of event day operations: check-in progress, room-by-room throughput, interview funnel status, and kiosk sync health. The dashboard is the command-and-control screen during a live event. It must load within 5s P95 (Redis-backed) and refresh automatically every 30 seconds. Read-only; no edits are performed from this screen.

---

## Data Sources (API Endpoints)

| Data | Endpoint | Cache Layer | Refresh SLA |
|------|----------|-------------|-------------|
| Check-in counts | GET /events/{id}/dashboard | Redis (30s TTL) | 30s auto-refresh |
| Check-in by room | GET /events/{id}/dashboard | Redis | 30s auto-refresh |
| Check-in over time | GET /events/{id}/dashboard?series=checkin-timeseries | Redis | 30s auto-refresh |
| Interview funnel | GET /events/{id}/dashboard | Redis | 30s auto-refresh |
| Kiosk sync status | GET /events/{id}/kiosk/status | Redis | 30s auto-refresh |
| Score submission rate | GET /events/{id}/dashboard | Redis | 30s auto-refresh |

---

## Metrics & KPIs

| Metric | Definition | Data Source | Refresh |
|--------|-----------|-------------|---------|
| Total Checked In | COUNT of candidates with CheckedIn OR Provisional status | check-in log | 30s |
| Registered Total | COUNT of registered candidates for this event | candidate table | on load |
| Check-In Rate (%) | (Checked In / Registered) × 100 | derived | 30s |
| Not Yet Arrived | Registered Total − Checked In | derived | 30s |
| Interviewed Count | COUNT of candidates with at least one score submitted | interview score table | 30s |
| Interview Rate (%) | (Interviewed / Checked In) × 100 | derived | 30s |
| Scored Count | COUNT of candidates with non-null final score | interview score table | 30s |
| Skipped Count | COUNT of skip events in session | interview log | 30s |
| Room Occupancy | (Checked In in Room / Room Capacity) × 100, per room | check-in + schedule | 30s |
| Sync Queue Depth | COUNT of unsynced provisional records per kiosk | kiosk sync log | 30s |
| Bounce / No-Show Rate | (Registered − Checked In when event ends) / Registered | post-event derived | On close |

---

## Dimensions / Filters

| Dimension | Values | Notes |
|-----------|--------|-------|
| Event | Current event (fixed; no cross-event on this view) | Filter is implicit |
| Track | All tracks in this event; multi-select | Filters funnel and candidate counts by track |
| Room | All rooms in schedule matrix | Filters room occupancy cards |
| Time range | Last 30 min / 1h / 2h / All day | Filters check-in timeseries chart only |
| Kiosk | All kiosks registered to event | Filters sync status cards |

---

## Visualizations

| Panel | Chart Type | Description |
|-------|-----------|-------------|
| Top KPI Cards | Stat cards (4 cards) | Checked In, Check-In Rate, Interviewed, Not Yet Arrived |
| Check-In Over Time | Line chart | X: time (15-min buckets), Y: cumulative check-ins; overlay: registered target line |
| Check-In by Room | Horizontal bar chart | One bar per room; color: green (< 80%), amber (80–95%), red (> 95%) occupancy |
| Track Funnel | Funnel chart (per track) | Stages: Registered → Checked In → Interviewed → Scored; shows conversion at each stage |
| Score Submission Rate | Progress bar per session | X of Y candidates scored, per interview session |
| Kiosk Sync Status | Status card grid | One card per kiosk: Online/Offline indicator, sync queue depth, last sync time |

---

## Alert States (ambient indicators, not modal interrupts)

| Condition | Alert Type | Presentation |
|-----------|-----------|--------------|
| Room occupancy > 90% | Amber badge on room card | "Room 3A: 91% — approaching capacity" |
| Check-in rate stalls (< 5/min for 15+ min) | Amber banner | "Check-in rate has slowed — check kiosk status" |
| Kiosk offline with > 50 unsynced records | Orange warning in Sync panel | "Kiosk 2: 67 unsynced — reconnect needed" |
| Kiosk offline with > 100 unsynced records | Red alert in Sync panel | "Critical: Kiosk 1 has 112 unsynced records" |
| Score submission rate < 50% with 75% of session time elapsed | Advisory notice | "Interview sessions may be running behind schedule" |

---

## Refresh Behavior

- Auto-refresh every 30 seconds (configurable in session settings: 15s / 30s / 60s)
- Refresh spinner in top-right: "Last updated: HH:MM:SS"
- Manual refresh: [Button] Refresh Now always available
- On tab blur (user switches browser tab): refresh pauses after 5 missed cycles; resumes on tab focus
- On API error: shows last-known data with warning: "Data may be outdated — last successful refresh: HH:MM:SS"

---

## Export Options

| Format | Content | Notes |
|--------|---------|-------|
| PDF Snapshot | Current dashboard state as formatted report | Includes timestamp; for printing or sharing |
| CSV | Raw check-in log for this event | All columns; full candidate list with timestamps |

---

## Empty / Loading State

| State | Display |
|-------|---------|
| Event not yet started | "Event has not started. Dashboard will activate when event status is InProgress." |
| Event started, zero check-ins | All counters show 0; charts show "No data yet" placeholder; auto-refreshing |
| Event closed | Banner: "This event has ended. Showing final snapshot." Auto-refresh stops. Export options active. |
| API error | Last cached data displayed; error banner: "Unable to reach server. Showing last known data from [timestamp]." |
| Loading (first render) | Skeleton loaders for all cards and charts; resolved within < 5s (Redis-backed) |
