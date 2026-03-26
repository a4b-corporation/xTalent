# ECR-A-001: Communication Job Tracking
**Type:** Analytics | **Priority:** P1 | **BC:** BC-07
**Permission:** ecr.communication.view

## Purpose

Provides TA Event Coordinators with visibility into the status and health of bulk email dispatch jobs. After triggering a bulk send via ECR-T-016, coordinators need to monitor delivery progress, identify failures and bounces, and decide whether to retry failed messages. This view is read-only and report-oriented; no re-send actions are performed from this screen (retry is initiated from ECR-T-016). Refresh is on-demand; jobs are async so final delivery stats may take minutes to hours to settle from the email gateway.

---

## Data Sources

| Data | Endpoint | Refresh Behavior |
|------|----------|-----------------|
| Job list and summary | GET /communication/jobs?eventId={id} | On page load; manual refresh button |
| Job detail and recipient breakdown | GET /communication/jobs/{jobId} | On row expand / detail view open |
| Retry queue depth | GET /communication/jobs/{jobId}/retry-queue | On detail view open |
| Bounce details | GET /communication/jobs/{jobId}/bounces | On detail view open |

---

## Metrics & KPIs

| Metric | Definition | Source | Refresh |
|--------|-----------|--------|---------|
| Total Dispatched | COUNT of messages sent to email gateway | job.sent_count | On load |
| Delivered | COUNT of messages confirmed delivered by gateway | job.delivered_count | On load |
| Delivery Rate (%) | (Delivered / Dispatched) x 100 | derived | On load |
| Bounced | COUNT of hard + soft bounces | job.bounced_count | On load |
| Bounce Rate (%) | (Bounced / Dispatched) x 100 | derived | On load |
| Failed | COUNT of messages that errored and exhausted retries | job.failed_count | On load |
| In Retry Queue | COUNT of messages currently awaiting retry | retry-queue count | On detail load |
| Job Progress (%) | (Processed / Total Recipients) x 100 | job.processed / job.total_recipients | Poll during active job |

---

## Dimensions / Filters

| Dimension | Values | Notes |
|-----------|--------|-------|
| Event | Select from user's accessible events | Default: current/most recent event |
| Date range | Today / Last 7 days / Last 30 days / Custom | Filters job dispatch date |
| Job status | All / In Progress / Completed / Completed with Errors / Failed | Default: All |
| Template | Select from templates used in period | Filters to jobs using a specific template |

---

## Visualizations

| Panel | Type | Description |
|-------|------|-------------|
| Jobs Summary Table | Table | One row per job: Job ID, template name, dispatched at, total recipients, sent, delivered, bounced, failed, status badge |
| Job Detail Drawer | Drawer / side panel | Opens on row click; shows per-recipient breakdown with status per address |
| Delivery Status Breakdown | Donut chart (per job) | Delivered (green), Bounced (amber), Failed (red), In Progress (grey) |
| Bounce Rate Trend | Line chart | X: date, Y: bounce rate (%); one line per template; helps spot deliverability degradation |
| Retry Queue Card | Stat card (in detail drawer) | Current retry queue depth; estimated next retry time |

---

## Job Status Badges

| Status | Color | Meaning |
|--------|-------|---------|
| In Progress | Blue | Job is actively sending; not all recipients processed |
| Completed | Green | All messages processed; delivery rate >= 95% |
| Completed with Errors | Amber | All messages processed; some bounced or failed |
| Failed | Red | Job halted; unrecoverable error (e.g., gateway rejection, quota exceeded) |

---

## Export Options

| Format | Content | Notes |
|--------|---------|-------|
| CSV | Per-recipient delivery status for selected job | Email address, status, timestamp; one row per recipient |
| PDF Summary | Job summary card with KPI metrics | Useful for audit / reporting to management |

---

## Empty / Loading State

| State | Display |
|-------|---------|
| No jobs dispatched yet for selected event | "No communication jobs found for this event. Jobs appear here after a bulk send is dispatched." |
| Jobs exist but all In Progress | Table shows rows with progress bars; auto-polls every 30 seconds during active jobs |
| Selected event has no bulk email feature usage | Same empty state as above |
| API error on load | "Unable to load job data. Please refresh." with [Refresh] button |
| Detail drawer loading | Skeleton loader in drawer; resolves within 2s |

---

## Polling Behavior

- For jobs with status In Progress: progress bar polls GET /communication/jobs/{jobId} every 30 seconds
- Polling stops when job status transitions to Completed, Completed with Errors, or Failed
- Manual [Refresh] button always available to force re-fetch entire job list
- Tab blur behavior: polling pauses after 5 missed cycles; resumes on tab focus
