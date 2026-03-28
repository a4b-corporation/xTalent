# COMP-A-001 — Compensation Analytics Dashboard

**Type**: Analytics | **Priority**: P1 | **BC**: BC-01 Compensation Management
**Country**: [All countries]

---

## Purpose

Provides Compensation Admin, Finance Approver, and HR leadership with aggregate insights on compensation distribution, pay equity, budget utilization, and compa-ratio positioning. Enables data-driven decisions for salary reviews and market positioning strategy. Key USP: Pay Equity Gap Detection (AI-assisted) identifying statistically significant gaps by gender/grade/department.

---

## Data Sources

| Source | Data Used |
|--------|---------|
| `tr.salary_record` | Current + historical salaries |
| `tr.pay_range` | Grade min/mid/max by country |
| `tr.compensation_cycle` | Budget utilization per cycle |
| `tr.compensation_proposal` | Proposal status, change % distribution |
| `co.worker` | Gender, seniority, hire date |
| `co.grade` | Grade level |
| `co.business_unit` | Department rollup |
| `co.legal_entity` | Country/LE scoping |

---

## Key Metrics

| Metric | Formula | Unit |
|--------|---------|------|
| Compa-Ratio | Actual / Midpoint × 100 | % |
| % Below Minimum | Workers with salary < PayRange.min / Total | % |
| % Above Maximum | Workers with salary > PayRange.max / Total | % |
| Average Compa-Ratio | Mean compa-ratio across cohort | % |
| Budget Utilization | Proposed / Budget × 100 | % |
| Avg Merit Increase | Mean change_pct in approved proposals | % |
| Pay Equity Gap | Unexplained salary difference after controlling for grade/seniority | % |
| Salary Cost as % Revenue | Total payroll / Revenue (if revenue data integrated) | % |

---

## Dimensions (Filters & Group-by)

| Dimension | Options |
|-----------|---------|
| Country | VN, SG, MY, ID, PH, TH |
| Legal Entity | Multi-select |
| Business Unit | Hierarchical picker |
| Grade | Range selector |
| Job Family | Multi-select |
| Employment Type | Full-time, Part-time, Contract |
| Gender | (Pay equity only) |
| Period | Current / Last 12 months / Custom range |
| Cycle | Compensation cycle selector |

---

## Visualizations

### 1. Compa-Ratio Distribution
- Box plot or histogram: distribution of compa-ratios across population
- Color coding: below 80% (red), 80–120% (green), above 120% (orange)
- Drill-down by grade / BU / country

### 2. Pay Range Positioning Heatmap
- Grid: Grade (Y) × Department (X)
- Cell color: average compa-ratio
- Hover: count of Workers, avg salary, avg compa-ratio

### 3. Budget Utilization Gauge (real-time)
- Radial gauge per CompensationCycle
- Shows: Used / Remaining / Total
- Real-time update as proposals approve/reject

### 4. Merit Increase Distribution
- Bar chart: % increase buckets (0–2%, 2–5%, 5–10%, >10%)
- Filter: by approver, grade, BU

### 5. Pay Equity Analysis [USP]
- Scatter plot: experience vs salary, colored by gender
- Regression line showing "expected" salary
- Highlighted dots = statistical outliers (potential gaps)
- "Unexplained gap" metric: after controlling for grade/seniority/performance
- Generate remediation report: Workers with identified gaps + suggested adjustments

### 6. Salary History Trend
- Line chart: average salary trend over 12 months
- Filter by grade, BU, country
- Overlay: inflation rate, market benchmark (if external data integrated)

---

## Update Frequency

| Visualization | Frequency | Method |
|--------------|-----------|--------|
| Budget Utilization | Real-time | Kafka event → WebSocket |
| Compa-Ratio Distribution | Daily refresh | Batch aggregation |
| Pay Equity Analysis | Weekly / on-demand | Scheduled analysis job |
| Merit Increase Distribution | On cycle completion | Event-driven refresh |
| Salary History Trend | Daily | Batch |

---

## Export Options

| Format | Contents |
|--------|---------|
| Excel | Raw data table with all dimensions + metrics |
| PDF | Formatted charts + summary metrics (for leadership review) |
| CSV | Filtered dataset for external analysis |

---

## Access Control

| Role | Access |
|------|--------|
| Compensation Admin | Full access — all BUs, all countries in scope |
| HR Admin | Full access within their LE scope |
| Finance Approver | Budget utilization + cost summaries only |
| People Manager | Own team's compa-ratio (no peer data) |
| Worker | Not accessible |
| External Auditor | Read-only, scoped to their audit mandate |

---

## Pay Equity Workflow [USP Feature]

1. System runs scheduled pay equity analysis (weekly)
2. If gap detected (> configurable threshold, e.g., > 10% unexplained):
   - `PayEquityGapDetected` event emitted
   - HR Admin notified with: affected cohort, gap %, suggested action
3. HR Admin reviews in Pay Equity report
4. Creates remediation plan: targeted CompensationProposals for affected Workers
5. Remediation tracked in next cycle's analytics

---

*COMP-A-001 — Compensation Analytics Dashboard*
*2026-03-27*
