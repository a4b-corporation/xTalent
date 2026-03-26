# ECR-A-003: Custom Report Builder
**Type:** Analytics | **Priority:** P2 | **BC:** BC-08
**Permission:** ecr.reports.view, ecr.reports.export

## Purpose

Enables TA Managers and Event Coordinators to construct ad-hoc reports by selecting dimensions, metrics, and filters without engineering involvement. Reports can be previewed in-app as a paginated table and exported as CSV or Excel. No reports are saved or scheduled in this phase (P2); each run is a fresh query. The feature targets power users who need one-off data extractions that the standard Live Dashboard (ECR-A-002) and Event Performance Analytics (ECR-A-005) do not cover.

---

## Data Sources

| Data | Endpoint | Notes |
|------|----------|-------|
| Report metadata (available dimensions + metrics) | GET /reports/schema | Cached; loaded once on page open |
| Report preview | POST /reports/preview with {dimensions, metrics, filters} | Max 500 rows in preview; paginated |
| Full export | POST /reports/export with {dimensions, metrics, filters, format} | Async job; returns download URL |

---

## Metrics & KPIs

| Metric | Definition | Source | Refresh |
|--------|-----------|--------|---------|
| Candidate Count | COUNT of unique candidates matching filter | candidate table | Per run |
| Registered Count | COUNT with status >= Registered | candidate table | Per run |
| Checked-In Count | COUNT with status = CheckedIn or Provisional | check-in log | Per run |
| Interviewed Count | COUNT with at least one score record | interview score table | Per run |
| Score Average | AVG of overall_score for scored candidates | interview score table | Per run |
| Offer Count | COUNT with offer_status = Offered (if available) | downstream HR system | Per run |
| No-Show Count | COUNT registered but not checked-in at event close | derived | Per run |

---

## Dimensions / Filters

| Dimension | Values | Notes |
|-----------|--------|-------|
| Event | Multi-select from accessible events | Required; at least one event must be selected |
| Track | Multi-select from tracks in selected event(s) | Optional |
| Registration Status | Registered / Waitlisted / Cancelled | Optional |
| Check-In Status | Checked In / Not Arrived / Walk-In | Optional |
| Interview Status | Pending / Scored / Skipped | Optional |
| Date Range | Registration date / Check-in date; from–to picker | Optional |
| Gender | If collected in registration form | Optional; subject to PII access policy |
| Score Range | Min–max slider for overall_score | Optional; only relevant if metrics include Score Average |

---

## Report Builder UI Flow

### Step 1: Select Dimensions
User selects one or more grouping dimensions from a checklist panel. Example: Event + Track + Check-In Status. System shows estimated row count as dimensions are added.

### Step 2: Select Metrics
User selects one or more metrics from a checklist panel. System warns if a metric is incompatible with selected dimensions (e.g., Score Average requires Interview Status or track with scoring enabled).

### Step 3: Apply Filters
User applies optional filters to narrow the data scope (date range, statuses, event/track selection).

### Step 4: Preview
User taps [Run Preview]. System renders paginated table (max 500 rows). Column headers = selected dimensions + metrics. Rows sorted by event name then track name by default; sortable by column header click.

### Step 5: Export
User selects [Export CSV] or [Export Excel]. System submits async export job. Banner appears: "Your export is being prepared. You will be notified when it is ready." Download link appears in notification panel within < 30 seconds for typical report sizes.

---

## Visualizations

| Panel | Type | Description |
|-------|------|-------------|
| Report Builder Panel | Form layout (left sidebar) | Dimension selector, metric selector, filter panel |
| Preview Table | Paginated table (main area) | Up to 500 rows; sortable columns; row count indicator |
| Column Type Indicator | Icon per column header | Dimension icon (tag) vs. Metric icon (chart) for readability |
| Row Count Estimate | Inline counter | Updates as dimensions/filters change; "Estimated: ~X rows" |

---

## Export Options

| Format | Content | Notes |
|--------|---------|-------|
| CSV | Full result set matching current dimensions + metrics + filters | UTF-8 with BOM; no row limit |
| Excel (.xlsx) | Same as CSV but formatted with frozen header row, auto-column widths | Sheet name = event name + date |

---

## Validation Rules

| Rule | Message |
|------|---------|
| No dimensions selected | "Select at least one dimension to build a report" |
| No metrics selected | "Select at least one metric to build a report" |
| No event selected in filters | "Select at least one event to scope the report" |
| Incompatible metric + dimension combination | Warning inline: "Score Average requires scored candidates — add Interview Status filter or select a track with scoring enabled" |
| Preview result set > 10,000 rows | Advisory: "This report contains more than 10,000 rows. Only the first 500 are shown in preview. Use Export for the full result." |

---

## Empty / Loading State

| State | Display |
|-------|---------|
| No dimensions selected (initial state) | "Select dimensions and metrics to build your report." Instruction panel visible |
| Preview returns 0 rows | "No data matches your current filters. Try broadening your selection." |
| Export job in progress | Progress notification: "Preparing your export…" spinner in notification panel |
| Export ready | Notification: "Your report is ready. [Download]" (link valid for 1 hour) |
| API error during preview | "Preview failed. Please check your selections and try again." [Retry] button |
