# Context Map — C4 Level 1: System Context

**Artifact**: context-map-l1.md
**Module**: Payroll (PR)
**Solution**: xTalent HCM
**Step**: 4 — Solution Architecture
**Date**: 2026-03-31
**Version**: 1.0

---

## 1. Purpose

This C4 Level 1 diagram shows the Payroll (PR) system in the context of its human actors and external systems. It establishes integration boundaries, data flow directions, and communication protocols for all external connections.

---

## 2. C4 Level 1 — System Context Diagram

```mermaid
C4Context
  title System Context — Payroll (PR) — xTalent HCM

  Person(payroll_admin, "Payroll Admin", "Configures pay groups, elements, profiles. Initiates and monitors payroll runs.")
  Person(finance_manager, "Finance Manager", "Final approver for payroll runs. Triggers bank file generation and GL journal export.")
  Person(hr_manager, "HR Manager", "First-level approver for payroll runs.")
  Person(formula_approver, "Finance Lead / Formula Approver", "Approves PayElement formula versions before activation.")
  Person(platform_admin, "Platform Admin", "Manages statutory rules (PIT brackets, SI rates, minimum wage).")
  Person(worker, "Worker", "Accesses own payslip, YTD summary, and PIT certificate via self-service portal.")

  System(payroll, "Payroll (PR)", "Gross-to-net payroll computation for Vietnamese legal entities. Manages pay configuration, multi-tenancy payroll runs, statutory reporting, and bank disbursement.")

  System_Ext(core_hr, "Core HR (CO)", "xTalent Core HR module. Provides worker identity, working relationships, contract types, dependent counts, bank accounts, and cost centers.")
  System_Ext(time_attendance, "Time & Attendance (TA)", "xTalent Time & Attendance module. Provides actual work days, OT hours by type, shift data, and holiday calendar.")
  System_Ext(total_rewards, "Total Rewards (TR)", "xTalent Total Rewards module. Provides base salary, allowances, and approved bonus amounts at cut-off.")
  System_Ext(bank_vcb, "Bank — VCB / BIDV / TCB", "Vietnamese commercial banks. Receives bank payment files for salary disbursement.")
  System_Ext(accounting, "Accounting / GL System", "Enterprise GL system. Receives VAS-compliant journal entries (TK 334, 338, 3383, 3335, 642).")
  System_Ext(gdt, "GDT — Tax Authority", "General Department of Taxation. Receives PIT quarterly declarations (05/KK-TNCN) and annual settlement (05/QTT-TNCN) per Circular 08/2013/TT-BTC.")
  System_Ext(bhxh, "BHXH Agency — VssID", "Vietnam Social Insurance Agency. Receives monthly D02-LT contribution lists in VssID format.")

  Rel(payroll_admin, payroll, "Configures pay master, initiates payroll runs, manages exceptions", "HTTPS/Browser")
  Rel(finance_manager, payroll, "Final approval, bank file download, GL export", "HTTPS/Browser")
  Rel(hr_manager, payroll, "First-level approval of payroll runs", "HTTPS/Browser")
  Rel(formula_approver, payroll, "Approves PayElement formula versions", "HTTPS/Browser")
  Rel(platform_admin, payroll, "Manages statutory rules (PIT, SI, min wage)", "HTTPS/Browser")
  Rel(worker, payroll, "Views payslip, YTD summary, downloads PIT certificate", "HTTPS/Browser")

  Rel(core_hr, payroll, "Provides worker/working_relationship data at cut-off. ACL translation.", "REST API / ACL")
  Rel(time_attendance, payroll, "Publishes AttendanceLocked event with work days and OT hours.", "Domain Event / OHS")
  Rel(total_rewards, payroll, "Provides compensation snapshot (base_salary, allowances) at cut-off. ACL translation.", "REST API / ACL Snapshot Pull")

  Rel(payroll, bank_vcb, "Sends bank payment file (VCB/BIDV/TCB format). V1 = file download.", "SFTP / File Download (OHS)")
  Rel(payroll, accounting, "Publishes GlJournalGenerated event. VAS GL entries.", "Domain Event / Message Broker (OHS)")
  Rel(payroll, gdt, "Submits PIT XML declarations. Circular 08/2013/TT-BTC.", "File Upload / HTTPS (Conformist)")
  Rel(payroll, bhxh, "Submits D02-LT monthly contribution list. VssID format.", "File Upload / HTTPS (Conformist)")
```

---

## 3. Actor Summary

| Actor | Role | Interaction |
|-------|------|-------------|
| Payroll Admin | Internal — Payroll team | Configures pay master data; initiates/monitors payroll runs; acknowledges exceptions; generates statutory reports |
| Finance Manager | Internal — Finance team | Final approver (Level 3); triggers bank file generation; triggers GL journal export |
| HR Manager | Internal — HR team | First-level approver (Level 2) for payroll runs |
| Finance Lead / Formula Approver | Internal — Finance team | Approves PayElement formula versions before activation |
| Platform Admin | Internal — IT/Platform | Manages statutory rules for decree changes (PIT brackets, SI rates, minimum wage) |
| Worker | Internal — All employees | Self-service: views payslip, YTD summary, downloads PIT withholding certificate |

---

## 4. External System Integration Summary

| External System | Direction | Pattern | Protocol | Data / Events |
|-----------------|-----------|---------|----------|---------------|
| Core HR (CO) | Upstream | ACL (Anti-Corruption Layer) | REST API pull at cut-off | worker identity, working_relationship, contract_type, dependent_count, bank_account, cost_center, nationality |
| Time & Attendance (TA) | Upstream | OHS (Open Host Service) | Domain Event subscription | `AttendanceLocked` event: actual_work_days, OT hours by type, shift data; `HolidayCalendarUpdated` for cache invalidation |
| Total Rewards (TR) | Upstream | ACL (Anti-Corruption Layer) | REST API pull at cut-off | compensation snapshot: base_salary, allowances_json, approved bonuses — amounts only, no formulas |
| Bank — VCB/BIDV/TCB | Downstream | OHS | SFTP / File Download | Bank payment file in bank-specific format (VcbAdapter, BidvAdapter, TcbAdapter). V2 API push deferred. |
| Accounting / GL System | Downstream | OHS | Domain Event / Message Broker | `GlJournalGenerated` event with VAS journal lines (TK 334, TK 338, TK 3383, TK 3335, TK 642) |
| GDT (Tax Authority) | Downstream | Conformist | File Upload (XML) | PIT 05/KK-TNCN quarterly; 05/QTT-TNCN annual. Non-negotiable Circular 08/2013/TT-BTC format. |
| BHXH Agency (VssID) | Downstream | Conformist | File Upload | D02-LT monthly contribution list. Non-negotiable VssID format. |

---

## 5. Integration Pattern Notes

### ACL (Anti-Corruption Layer)
Used for CO and TR because these modules use different domain language. The ACL translates CO "worker/assignment" vocabulary into PR "working_relationship/compensation_snapshot" vocabulary. PR never exposes CO or TR internal types to its own domain model. `calculation_rule_def` from TR is explicitly blocked from entering PR (ADR enforcement).

### OHS (Open Host Service)
TA publishes a well-defined `AttendanceLocked` event schema that PR subscribes to. PR maps TA data to internal payroll variables without owning the TA domain model. Similarly PR acts as OHS producer toward Bank (payment files) and Accounting (GL events).

### Conformist
GDT and BHXH impose non-negotiable regulatory file formats (XML per Circular 08/2013/TT-BTC and VssID D02-LT). PR must conform to these schemas without negotiation.

---

*This document is the L1 input for context-map-l2.md (container decomposition).*
