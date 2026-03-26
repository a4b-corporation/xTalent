# ECR-A-005: Event Performance Analytics
**Type:** Analytics | **Priority:** P2 | **BC:** BC-08
**Permission:** ecr.analytics.view

## Purpose

Provides TA Managers with a post-event KPI summary to evaluate event effectiveness and track improvement over time. Covers the full candidate lifecycle funnel: registered → checked-in → interviewed → scored → offered. Supports trend comparison across events to identify whether conversion rates are improving. Intended for use after an event closes (status = Closed or Archived). Data is not real-time; it is computed after event closure and may take up to 1 hour to fully settle as async scoring and comms data finalizes.

---

## Data Sources

| Data | Endpoint | Notes |
|------|----------|-------|
| Event KPI summary | GET /reports/event-performance?eventId={id} | Computed post-close; cached 1h |
| Multi-event trend | GET /reports/event-performance?eventIds=...&metric={metric} | Up to 12 events for trend charts |
| Track-level breakdown | GET /reports/event-performance?eventId={id}&groupBy=track | Per-track funnel within one event |

---

## Metrics & KPIs

| Metric | Definition | Source | Refresh |
|--------|-----------|--------|---------|
| Registration Conversion Rate | (Registered / Unique Landing Page Views) x 100 | candidate + web analytics | Post-close compute |
| Show-Up Rate | (Checked In / Registered) x 100 | check-in + candidate table | Post-close compute |
| No-Show Rate | 100 - Show-Up Rate | derived | Post-close compute |
| Interview Completion Rate | (Scored or Skipped / Checked In) x 100 | interview score table | Post-close compute |
| Score Submission Rate | (Scored / Checked In) x 100 | interview score table | Post-close compute |
| Skip Rate | (Skipped / Checked In) x 100 | interview score table | Post-close compute |
| Average Score | AVG of overall_score for scored candidates | interview score table | Post-close compute |
| Score Distribution | COUNT by score band (e.g., 1–3, 4–6, 7–10) | interview score table | Post-close compute |
| Offer Rate | (Offers Extended / Scored) x 100 | downstream HR system (if integrated) | Post-close; may show N/A if not available |
| Walk-In Rate | (Walk-In Check-Ins / Total Check-Ins) x 100 | check-in log | Post-close compute |

---

## Dimensions / Filters

| Dimension | Values | Notes |
|-----------|--------|-------|
| Primary Event | Single select from closed/archived events | Required |
| Comparison Events | Multi-select (up to 5) | Optional; enables trend comparison panels |
| Track | Multi-select from tracks in primary event | Optional; filters all panels |
| Date Range | Event date range (pre-set to event dates) | Fixed to event dates; not user-adjustable |

---

## Visualizations

| Panel | Type | Description |
|-------|------|-------------|
| Funnel Overview | Funnel chart | Stages: Registered → Checked In → Interviewed → Scored → Offered; absolute counts + conversion rates at each stage |
| KPI Summary Cards | Stat card row (6 cards) | Show-Up Rate, Interview Completion Rate, Score Submission Rate, Average Score, No-Show Count, Offer Rate |
| Score Distribution | Histogram / bar chart | X: score band; Y: count of candidates; one bar set per track (if track filter active) |
| Multi-Event Trend | Multi-line chart | X: event date; Y: selected metric (default: Show-Up Rate); one line per event; up to 6 events on single chart |
| Track Comparison Table | Table | One row per track: track name, registered, checked-in, show-up rate, scored, avg score, offer rate |
| Walk-In vs Pre-Registered | Stacked bar | Total check-ins split by type (Pre-Registered vs Walk-In); per event if multiple selected |

---

## Export Options

| Format | Content | Notes |
|--------|---------|-------|
| PDF Report | Full analytics summary with all visible panels | Formatted for management presentation; includes event metadata header |
| CSV | Raw metric values per track and per funnel stage | For further analysis in Excel or BI tools |
| Excel (.xlsx) | KPI table + track comparison table | Two sheets: Summary, Track Breakdown |

---

## Data Availability Notes

- Panels render only after event status = Closed or Archived
- If downstream HR integration (offer data) is not configured, Offer Rate metric shows "Not available — HR integration not configured" with link to integration settings
- Score data: if scoring is still in progress at time of view (e.g., HM has open edit requests), a banner warns "Score data may not be final — some edit requests are still pending"
- Registration Conversion Rate requires web analytics integration (landing page view tracking); if not available, shows "N/A — web analytics not configured"

---

## Empty / Loading State

| State | Display |
|-------|---------|
| No closed events available | "No closed events found. Event Performance Analytics is available after an event closes." |
| Event selected but data not yet computed | "Analytics are being computed for this event. This may take up to 1 hour after event closure. Check back shortly." Progress indicator shown. |
| Event has zero check-ins | Funnel shows Registered count at top; all downstream stages show 0 with note: "No candidates checked in for this event." |
| API error | "Unable to load event analytics. Please try again." [Retry] button |
| Trend chart with only one event selected | Line chart shows single point per metric with note: "Add more events in the comparison selector to see trends." |
| Offer Rate not integrated | Stat card shows "N/A" with tooltip: "Connect an HR system to track offer rates." |
