# ECR-A-004: Audit Log Viewer
**Type:** Analytics | **Priority:** P2 | **BC:** BC-08
**Permission:** ecr.audit.view (restricted to TA Manager and System Admin roles)

## Purpose

Provides a paginated, filterable, read-only view of all system actions performed within the ECR module. Supports compliance requirements, investigation of data discrepancies, and accountability for scored overrides, duplicate resolutions, and permission changes. The audit log is append-only; no record can be edited or deleted from this interface or by any user-level action. Used primarily by TA Managers and System Administrators during incident reviews or compliance audits.

---

## Data Sources

| Data | Endpoint | Notes |
|------|----------|-------|
| Audit log entries | GET /audit-log?filters... | Paginated; max 100 rows per page |
| Entry detail (before/after values) | GET /audit-log/{entryId} | Loaded on row expand |
| Export | GET /audit-log/export?filters... | Async; returns download URL |

---

## Metrics & KPIs

| Metric | Definition | Source | Refresh |
|--------|-----------|--------|---------|
| Total Entries (in current filter scope) | COUNT of audit log entries matching active filters | audit_log table | Per filter apply |
| Entries by Action Type | COUNT grouped by action category (Created / Updated / Deleted / Approved / Rejected) | audit_log table | Per filter apply |
| Entries by Actor | COUNT grouped by user identity | audit_log table | Per filter apply; used to identify high-frequency actors |

---

## Dimensions / Filters

| Dimension | Values | Notes |
|-----------|--------|-------|
| Event | Select from accessible events | Optional; omit to see module-wide log |
| Actor | Type-ahead user search | Filters to actions by a specific user |
| Action Type | Created / Updated / Deleted / Status Changed / Approved / Rejected / Accessed | Multi-select |
| Entity Type | Event / Candidate / Registration / Score / KitLink / Template / BulkJob / ScheduleSlot / Kiosk / AuditLog | Multi-select |
| Entity ID | Free text | Exact match; use to trace a specific record |
| Date Range | From–to datetime picker | Required for any export; optional for view |
| Outcome | Success / Failure | Optional; useful for spotting failed write attempts |

---

## Visualizations

| Panel | Type | Description |
|-------|------|-------------|
| Audit Log Table | Paginated table | Columns: Timestamp, Actor, Action, Entity Type, Entity ID, Summary, Outcome |
| Entry Detail Drawer | Read-only drawer | Opens on row click; shows full before/after field values as JSON diff |
| Action Distribution | Stacked bar chart (optional panel, collapsible) | Actions by type per day; useful for spotting anomalies in audit period |

---

## Audit Log Table Columns

| Column | Content | Notes |
|--------|---------|-------|
| Timestamp | ISO 8601 datetime with timezone | Sortable; default sort: descending (newest first) |
| Actor | Display name + role | "System" for automated actions |
| Action | Action label (e.g., "Score Submitted", "Event Published", "Duplicate Resolved") | Human-readable; maps to domain event type |
| Entity Type | Entity category label | E.g., "Candidate", "KitLink", "BulkEmailJob" |
| Entity ID | UUID or business key (e.g., SBD) | Truncated display; full ID on hover |
| Summary | One-line description of what changed | E.g., "Status changed from Pending to Scored" |
| Outcome | Success (green badge) / Failure (red badge) | |

---

## Row Expand: Before / After Detail

When a user clicks a row, a drawer opens showing:
- Actor: full name, role, email
- Timestamp: exact datetime
- Entity: type + ID + display name if available
- Before state: JSON object of fields before action (null for Create events)
- After state: JSON object of fields after action (null for Delete events)
- Changed fields highlighted with diff styling (amber background for changed lines)
- Action metadata: e.g., IP address (if captured), session token scope

---

## Export Options

| Format | Content | Notes |
|--------|---------|-------|
| CSV | All columns for entries matching current filters | No row limit; async for large exports |
| JSON | Raw audit log entries for selected filters | For programmatic ingestion by security tooling |

Export requires a date range to be set. Attempting export without a date range shows: "Please set a date range before exporting. Exports without a date range are disabled for performance reasons."

---

## Access Control Notes

- Only TA Manager and System Admin roles can access this screen (ecr.audit.view permission)
- The audit log itself records accesses to the audit log (access auditing)
- No user can delete, archive, or modify any audit log entry; the UI presents all data as read-only
- Search results for Entity ID exact match do not require event context (cross-event audit access granted by role)

---

## Empty / Loading State

| State | Display |
|-------|---------|
| No filters applied and no default event (first open) | "Apply filters to search the audit log. Select an event or date range to get started." |
| Filters applied with 0 results | "No audit log entries match your current filters. Try broadening your search." |
| Large filter scope (> 50,000 rows estimated) | Advisory: "This query may return a large number of results. Consider narrowing the date range or adding more filters before exporting." |
| Export in progress | "Preparing your export…" notification |
| API error | "Unable to load audit log. Please try again." [Retry] button |
| Row detail loading | Inline skeleton loader in drawer; resolves within 1s |
