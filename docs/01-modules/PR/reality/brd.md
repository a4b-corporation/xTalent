# Business Requirements Document (BRD)
# Payroll Module (PR)

> **Module**: Payroll (PR)
> **Phase**: Reality (Step 2)
> **Date**: 2026-03-31
> **Version**: 1.0
> **Status**: Draft

---

## Table of Contents

1. Executive Summary
2. Business Objectives
3. Scope
4. Stakeholders
5. Business Rules
6. Business Events
7. Constraints
8. Assumptions
9. Risks
10. Success Criteria

---

## 1. Executive Summary

### 1.1 Business Need

Vietnamese enterprises lack a flexible, configuration-focused payroll system that can adapt to complex statutory requirements (BHXH, BHYT, BHTN, PIT) while providing seamless integration with broader HCM ecosystems. Current solutions require technical expertise for configuration, have limited statutory compliance support, and suffer from integration fragmentation.

### 1.2 Proposed Solution

Build a **configuration-focused Payroll module** within xTalent HCM that:
- Enables non-technical users (Payroll Admins) to configure payroll with confidence
- Ensures statutory compliance through validated templates and version management
- Integrates seamlessly with upstream (CO, TA, TR) and downstream (Finance, Banking) systems
- Maintains complete audit trail for compliance and investigation
- Supports multi-entity organizations

### 1.3 Business Value

| Value Driver | Measurement | Target |
|--------------|-------------|--------|
| Configuration Time | Hours per pay element setup | Reduce from 4 hours to 30 minutes |
| Statutory Compliance | Audit pass rate | 100% statutory compliance |
| Integration Efficiency | Manual data entry hours | Eliminate manual data transfer |
| Audit Readiness | Audit preparation time | Reduce from 2 weeks to 1 day |
| Error Rate | Configuration errors per month | Reduce by 75% |

---

## 2. Business Objectives

### 2.1 Primary Objectives

| ID | Objective | SMART Definition | Priority |
|----|-----------|-----------------|----------|
| BO-001 | Enable Non-Technical Configuration | Payroll Admins can configure pay elements, profiles, and statutory rules without developer intervention. Success: 95% of configurations done by non-technical users within 3 months of go-live. | P0 |
| BO-002 | Ensure Vietnam Statutory Compliance | System supports BHXH (8%/17.5%), BHYT (1.5%/3%), BHTN (1%/1%), and PIT (7 brackets) with automatic version tracking. Success: 100% audit pass rate on statutory compliance. | P0 |
| BO-003 | Provide Complete Audit Trail | All configuration changes logged with SCD-2 versioning. Success: Complete version history queryable for any point in time within 24 hours of go-live. | P0 |
| BO-004 | Enable Seamless Integration | Data flows from CO, TA, TR modules and to Finance, Banking systems. Success: Zero manual data transfer for payroll configuration. | P0 |
| BO-005 | Support Multi-Entity Organizations | Companies with multiple legal entities can manage payroll centrally. Success: Support 10+ legal entities per tenant within 6 months. | P1 |

### 2.2 Secondary Objectives

| ID | Objective | SMART Definition | Priority |
|----|-----------|-----------------|----------|
| BO-006 | Reduce Configuration Errors | Validation framework prevents invalid configurations. Success: 75% reduction in configuration errors within 3 months. | P1 |
| BO-007 | Enable Formula Flexibility | Custom formulas for complex calculations. Success: Support arithmetic, conditional, lookup, and progressive formulas. | P1 |
| BO-008 | Improve User Experience | Intuitive interface with inline validation. Success: User satisfaction score >= 4.0/5.0. | P2 |
| BO-009 | Enable Configuration Templates | Pre-built templates for common scenarios. Success: 80% of configurations use templates within 6 months. | P2 |

---

## 3. Scope

### 3.1 In Scope

| Capability | Description | Priority |
|------------|-------------|----------|
| Pay Element Configuration | Create, update, delete pay elements with classification, calculation type, statutory flags | P0 |
| Pay Profile Configuration | Create pay profiles as aggregate roots containing pay elements, rules, policies | P0 |
| Statutory Rule Management | Create and manage Vietnam statutory rules (BHXH, BHYT, BHTN, PIT) | P0 |
| Formula Engine | Define and validate calculation formulas | P0 |
| Version Management | SCD-2 versioning for key entities | P0 |
| Validation Framework | Configuration validation and conflict detection | P0 |
| Pay Calendar Management | Define pay periods and cut-off dates | P0 |
| Pay Group Configuration | Assign employees to pay profiles | P0 |
| Integration Interfaces | APIs for CO, TA, TR, Finance, Banking integration | P0 |
| Audit Trail | Complete audit logging for all changes | P0 |
| GL Mapping Configuration | Map pay elements to GL accounts | P1 |
| Banking Templates | Configure bank file formats | P1 |

### 3.2 Out of Scope

| Excluded | Rationale |
|----------|-----------|
| Runtime Payroll Calculation | Handled by separate Calculation Engine module |
| Payroll Processing Workflow | Handled by separate Payroll Processing module |
| Payslip Generation | Handled by Payslip module |
| Real-time Tax Filing | Integration with government systems (future phase) |
| Employee Self-Service Portal | Handled by ESS module |
| Multi-Currency Support | Future phase for international expansion |
| Visual Formula Builder | Future UX enhancement |

### 3.3 Scope Boundaries

| Boundary | This Module | External Module |
|----------|-------------|-----------------|
| Worker Data | Reference only | Core HR (CO) |
| Time Data | Reference only | Time & Absence (TA) |
| Compensation Data | Reference only | Total Rewards (TR) |
| Payroll Calculation | Configuration only | Calculation Engine |
| GL Posting | Configuration only | Finance System |
| Payment Files | Template only | Banking System |

---

## 4. Stakeholders

### 4.1 Primary Stakeholders

| Stakeholder | Role | Responsibilities | Key Requirements |
|-------------|------|------------------|------------------|
| Payroll Admin | Configure & maintain payroll | Create pay elements, configure profiles, manage statutory rules | Easy configuration, error prevention, intuitive interface |
| HR Manager | Oversee payroll operations | Approve configurations, review compliance, manage audit | Compliance visibility, audit reports, approval workflow |
| Finance Controller | GL integration | Configure GL mappings, reconcile payroll costs, approve postings | Accurate GL mapping, cost center allocation, reconciliation |
| Compliance Officer | Statutory adherence | Validate statutory rules, manage updates, handle audits | Statutory accuracy, version history, audit export |

### 4.2 Secondary Stakeholders

| Stakeholder | Role | Key Requirements |
|-------------|------|------------------|
| IT Admin | System maintenance | Performance, security, backup |
| System Integrator | Connect with other modules | Clear APIs, documentation |
| Employee (end-user) | Receive accurate pay | Correct pay on time (indirect) |
| External Auditor | Audit compliance | Complete records, easy export |
| Government Authority | Receive filings | Accurate, timely submissions |

### 4.3 Stakeholder Influence Matrix

| Stakeholder | Influence | Interest | Engagement Strategy |
|-------------|-----------|----------|---------------------|
| Payroll Admin | High | High | Key user, involve in design |
| HR Manager | High | High | Key approver, regular demos |
| Finance Controller | Medium | High | Integration requirements |
| Compliance Officer | High | High | Statutory accuracy |
| IT Admin | Medium | Medium | Technical requirements |
| System Integrator | Medium | Medium | API contracts early |

---

## 5. Business Rules

### 5.1 Pay Element Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-PE-001 | Unique Element Code | Pay element code must be unique per legal entity | System validation |
| BR-PE-002 | Classification Impact | Classification determines gross/net impact direction | Automatic |
| BR-PE-003 | Soft Delete Only | Elements never physically deleted | System enforced |
| BR-PE-004 | In-Use Protection | Cannot delete element if in active pay profile | System validation |
| BR-PE-005 | Version Continuity | New version effective date must follow previous version end date | System validation |

### 5.2 Pay Profile Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-PP-001 | Unique Profile Code | Pay profile code must be unique per legal entity | System validation |
| BR-PP-002 | Element Priority | Priority determines calculation sequence (1-99) | System validation |
| BR-PP-003 | No Duplicate Elements | Same element cannot be assigned twice to profile | System validation |
| BR-PP-004 | Active Element Only | Only active elements can be assigned | System validation |
| BR-PP-005 | Effective Date Required | Assignment must have effective start date | Mandatory field |

### 5.3 Statutory Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-SR-001 | Rate Validation | Rate must be between 0 and 1 (percentage) | System validation |
| BR-SR-002 | Ceiling Required | Social insurance rules require ceiling amount | Mandatory field |
| BR-SR-003 | Progressive Brackets | PIT brackets must cover full income range | System validation |
| BR-SR-004 | Version Non-Overlap | Statutory rule versions cannot overlap in effective dates | System validation |
| BR-SR-005 | Government Rates | Statutory rates should match current government regulations | Warning + Manual override |

### 5.4 Formula Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-FM-001 | Valid Syntax | Formula must pass syntax validation | System enforced |
| BR-FM-002 | Reference Exists | Referenced elements must exist and be active | System validation |
| BR-FM-003 | No Circular Reference | Formula cannot create circular dependency | System validation |
| BR-FM-004 | Division Safety | Formula cannot divide by zero or nullable value | System validation |

### 5.5 Version Management Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-VM-001 | SCD-2 Pattern | All SCD entities use effective start/end date pattern | System enforced |
| BR-VM-002 | Single Current | Only one version can have isCurrentFlag = true | System enforced |
| BR-VM-003 | Change Reason | All version changes require reason documentation | Mandatory field |
| BR-VM-004 | Audit Trail | All changes logged with user, timestamp, old/new values | System enforced |

### 5.6 Pay Calendar Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-PC-001 | Period Sequence | Period dates must be sequential without gaps | System validation |
| BR-PC-002 | Cut-Off Before Pay | Cut-off date must be before pay date | System validation |
| BR-PC-003 | Frequency Alignment | Period count must match frequency (12 for monthly) | System validation |

### 5.7 Pay Group Rules

| Rule ID | Rule Name | Description | Enforcement |
|---------|-----------|-------------|-------------|
| BR-PG-001 | Single Assignment | Employee can be in only one pay group at a time | System validation |
| BR-PG-002 | Active Profile | Pay profile must be active for assignment | System validation |
| BR-PG-003 | Active Calendar | Pay calendar must be active for assignment | System validation |

---

## 6. Business Events

### 6.1 Configuration Events

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-001 | PayElementCreated | Admin creates new pay element | Payroll Admin | Validate, save, create version 1, log audit |
| BE-002 | PayElementUpdated | Admin updates pay element | Payroll Admin | Validate, create new version, close previous, log audit |
| BE-003 | PayElementDeleted | Admin soft-deletes pay element | Payroll Admin | Check in-use, set inactive flag, log audit |
| BE-004 | PayProfileCreated | Admin creates pay profile | Payroll Admin | Validate, save, create version 1, log audit |
| BE-005 | PayProfileUpdated | Admin updates pay profile | Payroll Admin | Validate, create new version, close previous, log audit |
| BE-006 | StatutoryRuleCreated | Admin creates statutory rule | Payroll Admin, Compliance Officer | Validate rates, save, create version 1, log audit |
| BE-007 | StatutoryRuleUpdated | Admin updates statutory rule | Payroll Admin, Compliance Officer | Validate, create new version, close previous, log audit |
| BE-008 | FormulaDefined | Admin creates formula | Payroll Admin | Validate syntax, check references, save, log audit |
| BE-009 | FormulaValidated | System validates formula | System | Check syntax, check references, return validation result |

### 6.2 Assignment Events

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-010 | ElementAssignedToProfile | Admin assigns element to profile | Payroll Admin | Validate element, check priority, save assignment, log audit |
| BE-011 | ElementRemovedFromProfile | Admin removes element from profile | Payroll Admin | Validate not in use, remove assignment, log audit |
| BE-012 | EmployeeAssignedToGroup | Admin assigns employee to pay group | Payroll Admin | Check single assignment, validate profile/calendar, save, log audit |
| BE-013 | EmployeeRemovedFromGroup | Admin removes employee from group | Payroll Admin | Validate, remove, log audit |

### 6.3 Calendar Events

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-014 | PayCalendarCreated | Admin creates pay calendar | Payroll Admin | Validate, generate periods, save, log audit |
| BE-015 | PayCalendarPeriodAdjusted | Admin adjusts period dates | Payroll Admin | Validate sequence, save, log audit |

### 6.4 Integration Events (Inbound)

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-016 | WorkerDataReceived | CO module sends worker data | Core HR (CO) | Validate, cache reference, trigger validation |
| BE-017 | TimeDataReceived | TA module sends time data | Time & Absence (TA) | Validate, map to elements, cache reference |
| BE-018 | CompensationDataReceived | TR module sends compensation data | Total Rewards (TR) | Validate, map to elements, cache reference |

### 6.5 Integration Events (Outbound)

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-019 | GLMappingExported | Finance requests GL mappings | Finance System | Generate export file, log audit |
| BE-020 | BankTemplateGenerated | Payment file template needed | Banking System | Generate template, log audit |
| BE-021 | ConfigurationSnapshotRequested | Calculation engine requests config | Calculation Engine | Generate snapshot, return configuration |

### 6.6 Validation Events

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-022 | ConfigurationValidated | Admin saves configuration | Payroll Admin | Run all validations, return results |
| BE-023 | ConflictDetected | System detects configuration conflict | System | Alert admin, block save, suggest resolution |
| BE-024 | VersionConflictDetected | System detects overlapping versions | System | Alert admin, block save, show conflicts |

### 6.7 Audit Events

| Event ID | Event Name | Trigger | Actors | System Response |
|----------|------------|---------|--------|-----------------|
| BE-025 | AuditLogQueried | Admin queries audit trail | HR Manager, Auditor | Return filtered results |
| BE-026 | AuditReportExported | Admin exports audit report | HR Manager, Auditor | Generate CSV/PDF, log export |
| BE-027 | VersionCompared | Admin compares versions | Payroll Admin | Return comparison results |

---

## 7. Constraints

### 7.1 Technical Constraints

| Constraint ID | Description | Impact |
|---------------|-------------|--------|
| TC-001 | xTalent platform technology stack | Must use approved frameworks, patterns |
| TC-002 | REST API requirement | All interfaces must be RESTful |
| TC-003 | PostgreSQL database | Schema design for PostgreSQL |
| TC-004 | SCD-2 versioning required | Additional columns, query complexity |
| TC-005 | Multi-tenant architecture | Tenant isolation in all queries |

### 7.2 Business Constraints

| Constraint ID | Description | Impact |
|---------------|-------------|--------|
| BC-001 | Vietnam statutory requirements | Specific rates, brackets, exemptions |
| BC-002 | 6-month MVP timeline | Prioritization required |
| BC-003 | 5-6 engineer team | Scope vs. capacity balance |
| BC-004 | Configuration-only scope | No runtime calculation |
| BC-005 | Multi-entity support | Legal entity separation |

### 7.3 Regulatory Constraints

| Constraint ID | Description | Impact |
|---------------|-------------|--------|
| RC-001 | BHXH rates 8%/17.5% | Employee/Employer contribution split |
| RC-002 | BHYT rates 1.5%/3% | Employee/Employer contribution split |
| RC-003 | BHTN rates 1%/1% | Employee/Employer contribution split |
| RC-004 | PIT 7 progressive brackets | Tax calculation complexity |
| RC-005 | 36M VND ceiling | Social insurance contribution cap |
| RC-006 | 11M VND personal exemption | PIT deduction |
| RC-007 | 4.4M VND dependent exemption | Per dependent deduction |

### 7.4 Integration Constraints

| Constraint ID | Description | Impact |
|---------------|-------------|--------|
| IC-001 | CO module dependency | Worker data from Core HR |
| IC-002 | TA module dependency | Time data from Time & Absence |
| IC-003 | TR module dependency | Compensation data from Total Rewards |
| IC-004 | Finance interface | GL posting format requirements |
| IC-005 | Banking formats | Multiple bank file formats |

---

## 8. Assumptions

### 8.1 Technical Assumptions

| ID | Assumption | Impact if False | Confidence |
|----|------------|-----------------|------------|
| TA-001 | xTalent platform is stable and available | Development delays | High |
| TA-002 | CO module provides complete worker data | Integration gaps | Medium |
| TA-003 | TA module provides accurate time data | Calculation errors | Medium |
| TA-004 | TR module provides current compensation | Configuration errors | Medium |
| TA-005 | PostgreSQL SCD-2 performance is acceptable | Query optimization needed | High |

### 8.2 Business Assumptions

| ID | Assumption | Impact if False | Confidence |
|----|------------|-----------------|------------|
| BA-001 | Payroll Admins have moderate technical skill | UX complexity | Medium |
| BA-002 | Customers accept configuration-only scope | Feature requests | Medium |
| BA-003 | Vietnam statutory rules are accurate | Compliance risk | High |
| BA-004 | 6-month timeline is achievable | Scope reduction | Medium |
| BA-005 | Team has payroll domain knowledge | Training needed | Medium |

### 8.3 User Assumptions

| ID | Assumption | Impact if False | Confidence |
|----|------------|-----------------|------------|
| UA-001 | Users understand payroll concepts | Training requirement | Medium |
| UA-002 | Users can write simple formulas | UX for formula builder | Low |
| UA-003 | Users need audit trail | Feature prioritization | High |
| UA-004 | Users prefer English interface | Localization needed | Medium |

---

## 9. Risks

### 9.1 High Risks

| Risk ID | Risk | Probability | Impact | Mitigation |
|---------|------|-------------|--------|------------|
| R-001 | Statutory rule errors | High | Critical | Expert review, validation testing, government regulation monitoring |
| R-002 | Formula engine complexity | Medium | High | POC early, simplified syntax, comprehensive testing |
| R-003 | Late statutory updates | Medium | High | Automated monitoring, update workflow, version management |

### 9.2 Medium Risks

| Risk ID | Risk | Probability | Impact | Mitigation |
|---------|------|-------------|--------|------------|
| R-004 | Integration failures | Medium | Medium | Clear contracts, error handling, monitoring |
| R-005 | Scope creep | Medium | Medium | Strict scope management, prioritization |
| R-006 | User skill gaps | Medium | Medium | Training, documentation, UX simplification |
| R-007 | Performance issues | Low | Medium | Query optimization, caching, load testing |

### 9.3 Low Risks

| Risk ID | Risk | Probability | Impact | Mitigation |
|---------|------|-------------|--------|------------|
| R-008 | Data migration | Low | Medium | Migration scripts, validation |
| R-009 | User adoption | Low | Low | Training, change management |
| R-010 | Technology changes | Low | Low | Standards compliance |

---

## 10. Success Criteria

### 10.1 Business Success Metrics

| Metric | Target | Measurement Method | Timeline |
|--------|--------|-------------------|----------|
| Configuration Time | 75% reduction | Time tracking | 3 months post-go-live |
| Statutory Compliance | 100% audit pass | Audit results | Every audit |
| Configuration Errors | 75% reduction | Error logs | 3 months post-go-live |
| User Satisfaction | >= 4.0/5.0 | Survey | 6 months post-go-live |
| Audit Preparation Time | 95% reduction | Time tracking | 1 month post-go-live |

### 10.2 Technical Success Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| API Response Time | <200ms for CRUD | Performance monitoring |
| System Uptime | 99.9% | Monitoring |
| Configuration Validation | 100% | Test coverage |
| Version Query Performance | <300ms | Performance monitoring |

### 10.3 Acceptance Criteria Summary

| Category | Criteria |
|----------|----------|
| Functionality | All 24 functional requirements implemented and tested |
| Performance | All NFR response time targets met |
| Compliance | Vietnam statutory rules correctly implemented |
| Integration | All 5 integration interfaces functional |
| Audit | Complete audit trail for all operations |
| Versioning | SCD-2 versioning working for all key entities |

---

## Appendix A: Glossary

| Term | Definition |
|------|------------|
| Pay Element | Fundamental payroll component (earning, deduction, tax) |
| Pay Profile | Configuration bundle for employee group |
| Pay Calendar | Time-based payroll period definition |
| Pay Group | Employee assignment to payroll configuration |
| Statutory Rule | Government-mandated contribution or tax rule |
| SCD-2 | Slowly Changing Dimension Type 2 (versioning pattern) |
| Aggregate Root | Entity with independent lifecycle (DDD pattern) |
| BHXH | Vietnamese Social Insurance (Bao Hiem Xa Hoi) |
| BHYT | Vietnamese Health Insurance (Bao Hiem Y Te) |
| BHTN | Vietnamese Unemployment Insurance (Bao Hiem That Nghiep) |
| PIT | Personal Income Tax (Thue TNCN) |
| GL | General Ledger |
| CO | Core HR module (organization, worker data) |
| TA | Time & Absence module |
| TR | Total Rewards module (compensation, benefits) |

---

## Appendix B: Document References

| Reference | Location |
|-----------|----------|
| Requirements Document | prereality/requirements.md |
| Step 1 Handoff | .odsa/handoff/step1-to-step2.md |
| Step 1 Summary | .odsa/context/step1-summary.md |
| Research Report | prereality/00-research-report.md |

---

**Document Version**: 1.0
**Created**: 2026-03-31
**Author**: Business Analyst Agent
**Status**: Draft - Pending Review