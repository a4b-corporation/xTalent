# Feature Spec: Version History Viewer

> **Feature ID**: PR-VM-A-001
> **Classification**: Analytics (A)
> **Priority**: P0 (MVP)
> **Spec Depth**: Medium
> **Date**: 2026-03-31

---

## Overview

Version History Viewer provides access to SCD-2 version history for PayElement, PayProfile, and StatutoryRule. Users can view timeline, compare versions, query by effective date, and export history.

---

## Data Sources

| Entity | Table | Version Columns |
|--------|-------|-----------------|
| PayElement | pr_pay_element | effectiveStartDate, effectiveEndDate, isCurrentFlag, versionReason |
| PayProfile | pr_pay_profile | effectiveStartDate, effectiveEndDate, isCurrentFlag, versionReason |
| StatutoryRule | pr_statutory_rule | effectiveStartDate, effectiveEndDate, isCurrentFlag, versionReason |

---

## Metrics and Dimensions

### Metrics

| Metric | Type | Description |
|--------|------|-------------|
| Version Count | Count | Total versions for entity |
| Version Duration | Days | Days each version was effective |
| Change Frequency | Count | Versions per year |

### Dimensions

| Dimension | Type | Values |
|-----------|------|--------|
| Version Number | Integer | Sequential 1, 2, 3... |
| Effective Date Range | Time | Start to End dates |
| Change Reason | Category | Reason text |
| Creator | String | User who created version |

---

## Version Timeline Visualization

### Timeline Layout

| Component | Description |
|-----------|-------------|
| Horizontal Timeline | Visual representation of versions over time |
| Version Markers | Circular markers for each version |
| Current Version | Green highlight for isCurrentFlag=true |
| Historical Versions | Gray markers for closed versions |
| Date Labels | Effective start/end dates below markers |
| Hover Info | Tooltip with version details |

### Timeline Example

```
|----[v1]--------|----[v2]--------|----[v3]--------|----[v4(current)]----|
     Jan 1           Jul 1           Jan 1           Jul 1
      - Jun 30        - Dec 31        - Jun 30        - null
```

---

## Version Comparison

### Comparison Mode

| Feature | Description |
|---------|-------------|
| Side-by-Side | Two column layout: Version A | Version B |
| Field Matching | Same fields aligned for comparison |
| Change Highlight | Yellow highlight for changed values |
| No Change | Gray text for unchanged fields |

### Comparison Fields

| Entity | Comparable Fields |
|--------|-------------------|
| PayElement | elementName, classification, calculationType, rate, amount, formulaId, statutoryFlag, taxableFlag |
| PayProfile | profileName, payFrequencyId, description |
| StatutoryRule | ruleName, rate, ceilingAmount, personalExemption, dependentExemption |

---

## Version Query by Date

### Use Cases

| Use Case | Description |
|----------|-------------|
| Retroactive Calculation | Get version effective on a past date |
| Audit Investigation | What was the rate on March 15? |
| Configuration Snapshot | Export all entities effective on a date |

### Query Process

1. Enter effective date
2. System finds version where:
   - effectiveStartDate <= queryDate
   - effectiveEndDate >= queryDate OR effectiveEndDate IS NULL
3. Return version details

---

## Export Options

### Version History Export

| Format | Fields | Filename |
|--------|--------|----------|
| CSV | Version #, Start, End, Reason, Creator, Timestamp | version-history-{entityCode}.csv |
| PDF | Timeline visual + version details | version-history-{entityCode}.pdf |

---

## Screen Specifications

### Version Timeline Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Version History - {entityName}" |
| Header | Entity Info | Entity code, type, current version badge |
| Header | Back Button | Return to entity detail |
| Visual | Timeline | Horizontal timeline with markers |
| Visual | Current Marker | Green highlight |
| Visual | Historical Markers | Gray markers |
| Visual | Hover | Tooltip with version summary |
| Table | Version List | Below timeline, detailed list |
| Table | Columns | Version #, Effective Start, Effective End, Creator, Created At, Reason |
| Table | Actions | View Version, Compare |
| Actions | Compare Button | Open comparison modal |
| Actions | Query by Date | Open query modal |
| Actions | Export | Download CSV/PDF |

### Version Detail Screen

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Version {versionNumber} - {entityName}" |
| Header | Effective Dates | Start date - End date |
| Header | Status Badge | Current or Historical |
| Panel | Metadata | Created by, Created at, Reason |
| Panel | Attributes | All entity attributes for this version |
| Actions | Compare with... | Open comparison with another version |
| Actions | View Entity | Navigate to entity detail |

### Version Comparison Modal

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Compare Versions" |
| Dropdowns | Version A | Select first version |
| Dropdowns | Version B | Select second version |
| Split View | Left Column | Version A attributes |
| Split View | Right Column | Version B attributes |
| Highlight | Changed Fields | Yellow highlight |
| Actions | Close | Close modal |

### Version Query Modal

| Section | Component | Description |
|---------|-----------|-------------|
| Header | Title | "Query Version by Date" |
| Input | Effective Date | Date picker |
| Actions | Query | Find version |
| Result | Version Info | Display version effective on date |
| Result | Attributes | Show attributes for that version |
| Actions | Close | Close modal |

---

## API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /pay-elements/{code}/versions | GET | List PayElement versions |
| /pay-elements/{code}/versions/{id} | GET | Get specific version |
| /pay-elements/query | GET | Query version by date |
| /pay-profiles/{code}/versions | GET | List PayProfile versions |
| /pay-profiles/{code}/versions/{id} | GET | Get specific version |
| /statutory-rules/{code}/versions | GET | List StatutoryRule versions |
| /statutory-rules/{code}/versions/{id} | GET | Get specific version |

---

## Events

| Event | Trigger | Consumer |
|-------|---------|----------|
| VersionQueried | GET versions | Analytics (optional) |
| VersionCompared | Compare action | None |

---

## Permissions

| Role | View Timeline | View Details | Compare | Query by Date | Export |
|------|---------------|--------------|---------|---------------|--------|
| Payroll Admin | YES | YES | YES | YES | YES |
| Compliance Officer | YES | YES | YES | YES | YES |
| HR Manager | YES | YES | NO | NO | NO |
| Finance Controller | YES | YES | NO | NO | NO |

---

## Traceability

| User Story | BRD Requirement | API Endpoint |
|------------|-----------------|--------------|
| US-016: View Version History | FR-016 | GET /{entity}/{code}/versions |
| US-017: Query Version by Date | FR-017 | GET /{entity}/query |

---

**Spec Version**: 1.0
**Created**: 2026-03-31