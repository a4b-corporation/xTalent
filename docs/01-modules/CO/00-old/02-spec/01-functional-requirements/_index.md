# Core Module - Functional Requirements Index

> **Module**: Core (CO)  
> **Total Requirements**: ~450 FRs  
> **Last Updated**: 2026-01-08

---

## 00. Configuration (FR-CFG)

Quản lý code lists, currencies, timezones và master configurations.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-CFG-001 | Code List Category Management | MUST | Configuration | Planned |
| FR-CFG-002 | Code List Value Management | MUST | Configuration | Planned |
| FR-CFG-003 | Code List Search & Filter | SHOULD | Functional | Planned |
| FR-CFG-004 | Code List Import/Export | COULD | Integration | Planned |
| FR-CFG-005 | Code List Versioning | SHOULD | Functional | Planned |
| FR-CFG-010 | Currency Management | MUST | Configuration | Planned |
| FR-CFG-011 | Timezone Management | MUST | Configuration | Planned |
| FR-CFG-012 | Country & Region Management | MUST | Configuration | Planned |
| FR-CFG-013 | Language Configuration | SHOULD | Configuration | Planned |
| FR-CFG-014 | Date Format Configuration | SHOULD | Configuration | Planned |
| FR-CFG-020 | System Parameter Management | MUST | Configuration | Planned |
| FR-CFG-021 | Module Configuration | SHOULD | Configuration | Planned |
| FR-CFG-022 | Feature Toggle Management | SHOULD | Configuration | Planned |

**File**: [00-configuration.frs.md](./00-configuration.frs.md)

---

## 01. Person Management (FR-WRK)

Quản lý worker profiles, contacts, addresses và documents.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-WRK-001 | Create Worker Profile | MUST | Functional | Defined |
| FR-WRK-002 | Update Worker Profile | MUST | Functional | Defined |
| FR-WRK-003 | Worker Status Management | MUST | Workflow | Defined |
| FR-WRK-004 | Worker Deactivation | MUST | Workflow | Defined |
| FR-WRK-005 | Worker Search & Filter | MUST | Functional | Defined |
| FR-WRK-010 | Contact Information Management | MUST | Functional | Defined |
| FR-WRK-011 | Primary Contact Assignment | MUST | Validation | Defined |
| FR-WRK-012 | Emergency Contact Management | SHOULD | Functional | Defined |
| FR-WRK-020 | Address Management | MUST | Functional | Defined |
| FR-WRK-021 | Address Type Classification | MUST | Configuration | Defined |
| FR-WRK-022 | Address Validation | SHOULD | Validation | Planned |
| FR-WRK-030 | Personal Document Management | MUST | Functional | Defined |
| FR-WRK-031 | Document Type Configuration | MUST | Configuration | Defined |
| FR-WRK-032 | Document Expiry Tracking | SHOULD | Workflow | Defined |
| FR-WRK-033 | Document Verification | SHOULD | Workflow | Planned |
| FR-WRK-040 | Personal Identification Management | MUST | Functional | Defined |
| FR-WRK-041 | ID Type Configuration | MUST | Configuration | Defined |
| FR-WRK-042 | ID Uniqueness Validation | MUST | Validation | Defined |
| FR-WRK-050 | Probation Period Tracking | MUST | Workflow | Defined |
| FR-WRK-051 | Probation Extension | SHOULD | Workflow | Defined |
| FR-WRK-052 | Probation Outcome Recording | MUST | Functional | Defined |
| FR-WRK-060 | Consent Management | MUST | Functional | Defined |
| FR-WRK-061 | Consent Type Configuration | MUST | Configuration | Defined |
| FR-WRK-062 | Consent Withdrawal | MUST | Workflow | Defined |
| FR-WRK-070 | Rehire Processing | SHOULD | Workflow | Defined |
| FR-WRK-071 | Rehire Eligibility Check | SHOULD | Validation | Defined |
| FR-WRK-080 | Worker History Tracking | MUST | Functional | Defined |
| FR-WRK-081 | History Timeline View | SHOULD | UI/UX | Planned |

**File**: [01-person.frs.md](./01-person.frs.md)

---

## 02. Work Relationship (FR-WR, FR-CONTRACT)

Quản lý employment contracts và work relationships.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-WR-001 | Create Work Relationship | MUST | Functional | Defined |
| FR-WR-002 | Work Relationship Type Management | MUST | Configuration | Defined |
| FR-WR-003 | Work Relationship Status Management | MUST | Workflow | Defined |
| FR-WR-004 | Work Relationship Suspension | SHOULD | Workflow | Defined |
| FR-WR-005 | Work Relationship Reactivation | SHOULD | Workflow | Defined |
| FR-WR-006 | Work Relationship Conversion | SHOULD | Workflow | Defined |
| FR-WR-007 | Work Relationship History | MUST | Functional | Defined |
| FR-WR-010 | Multiple Work Relationships | SHOULD | Functional | Defined |
| FR-WR-011 | Primary Work Relationship | MUST | Validation | Defined |
| FR-CONTRACT-001 | Create Employment Contract | MUST | Functional | Defined |
| FR-CONTRACT-002 | Contract Type Management | MUST | Configuration | Defined |
| FR-CONTRACT-003 | Contract Template Management | SHOULD | Configuration | Defined |
| FR-CONTRACT-004 | Contract Duration Rules | MUST | Validation | Defined |
| FR-CONTRACT-005 | Contract Renewal | SHOULD | Workflow | Defined |
| FR-CONTRACT-006 | Contract Amendment | SHOULD | Workflow | Defined |
| FR-CONTRACT-007 | Contract Termination | MUST | Workflow | Defined |
| FR-CONTRACT-008 | Contract Expiry Notification | SHOULD | Workflow | Defined |
| FR-CONTRACT-009 | Contract Document Attachment | SHOULD | Functional | Defined |
| FR-CONTRACT-010 | Contract Approval Workflow | SHOULD | Workflow | Planned |
| FR-CONTRACT-011 | Contract Hierarchy (Parent-Child) | COULD | Functional | Defined |
| FR-CONTRACT-012 | Probation Period in Contract | MUST | Functional | Defined |
| FR-CONTRACT-013 | Notice Period Configuration | MUST | Configuration | Defined |
| FR-CONTRACT-020 | Contract Search & Filter | MUST | Functional | Defined |
| FR-CONTRACT-021 | Contract Reporting | SHOULD | Functional | Planned |

**File**: [02-work-relationship.frs.md](./02-work-relationship.frs.md)

---

## 03. Employment (FR-EMP)

Quản lý employee records, probation và termination.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-EMP-001 | Create Employee Record | MUST | Functional | Defined |
| FR-EMP-002 | Employee ID Generation | MUST | Functional | Defined |
| FR-EMP-003 | Employee Status Management | MUST | Workflow | Defined |
| FR-EMP-004 | Employee Onboarding Checklist | SHOULD | Workflow | Planned |
| FR-EMP-010 | Employee Hire Processing | MUST | Workflow | Defined |
| FR-EMP-011 | Employee Rehire Processing | SHOULD | Workflow | Defined |
| FR-EMP-020 | Employee Termination | MUST | Workflow | Defined |
| FR-EMP-021 | Termination Type Configuration | MUST | Configuration | Defined |
| FR-EMP-022 | Termination Reason Configuration | MUST | Configuration | Defined |
| FR-EMP-023 | Termination Checklist | SHOULD | Workflow | Planned |
| FR-EMP-024 | Final Settlement Calculation | SHOULD | Calculation | Planned |
| FR-EMP-030 | Employment History Tracking | MUST | Functional | Defined |
| FR-EMP-031 | Employment Timeline View | SHOULD | UI/UX | Planned |
| FR-EMP-040 | Employee Search & Filter | MUST | Functional | Defined |
| FR-EMP-041 | Advanced Employee Search | SHOULD | Functional | Planned |
| FR-EMP-050 | Employee Self-Service Portal | SHOULD | UI/UX | Planned |
| FR-EMP-051 | Personal Info Update Request | SHOULD | Workflow | Planned |
| FR-EMP-060 | Employee Reporting | MUST | Functional | Defined |
| FR-EMP-061 | Headcount Report | MUST | Functional | Defined |
| FR-EMP-062 | Turnover Report | SHOULD | Functional | Planned |
| FR-EMP-063 | Tenure Analysis Report | SHOULD | Functional | Planned |

**File**: [03-employment.frs.md](./03-employment.frs.md)

---

## 04. Assignment Management (FR-ASG, FR-MTX)

Quản lý job assignments, managers và matrix reporting.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-ASG-001 | Create Employee Assignment | MUST | Functional | Defined |
| FR-ASG-002 | Assignment Type Configuration | MUST | Configuration | Defined |
| FR-ASG-003 | Position-Based Assignment | MUST | Functional | Defined |
| FR-ASG-004 | Job-Based Assignment | SHOULD | Functional | Defined |
| FR-ASG-005 | Assignment Status Management | MUST | Workflow | Defined |
| FR-ASG-010 | Manager Assignment | MUST | Functional | Defined |
| FR-ASG-011 | Direct Manager | MUST | Functional | Defined |
| FR-ASG-012 | Dotted-Line Manager | SHOULD | Functional | Defined |
| FR-ASG-013 | Manager Type Configuration | SHOULD | Configuration | Defined |
| FR-ASG-020 | Employee Transfer | MUST | Workflow | Defined |
| FR-ASG-021 | Transfer Effective Date | MUST | Validation | Defined |
| FR-ASG-022 | Transfer Approval Workflow | SHOULD | Workflow | Planned |
| FR-ASG-030 | Employee Promotion | MUST | Workflow | Defined |
| FR-ASG-031 | Promotion Eligibility Check | SHOULD | Validation | Planned |
| FR-ASG-032 | Promotion Approval Workflow | SHOULD | Workflow | Planned |
| FR-ASG-040 | Employee Demotion | SHOULD | Workflow | Defined |
| FR-ASG-050 | Concurrent Assignments | SHOULD | Functional | Defined |
| FR-ASG-051 | FTE Allocation Validation | MUST | Validation | Defined |
| FR-ASG-052 | Primary Assignment Designation | MUST | Validation | Defined |
| FR-ASG-060 | Assignment Suspension | SHOULD | Workflow | Defined |
| FR-ASG-061 | Assignment Reactivation | SHOULD | Workflow | Defined |
| FR-ASG-070 | Assignment History Tracking | MUST | Functional | Defined |
| FR-ASG-071 | Assignment Timeline View | SHOULD | UI/UX | Planned |
| FR-ASG-080 | Assignment Reporting | MUST | Functional | Defined |
| FR-MTX-001 | Matrix Manager Assignment | SHOULD | Functional | Defined |
| FR-MTX-002 | Matrix Reporting Chain | SHOULD | Functional | Defined |
| FR-MTX-003 | Direct Reports View | MUST | Functional | Defined |
| FR-MTX-004 | Dotted-Line Reports View | SHOULD | Functional | Defined |
| FR-MTX-005 | Reporting Hierarchy Validation | MUST | Validation | Defined |
| FR-MTX-006 | Span of Control Analysis | COULD | Calculation | Planned |
| FR-MTX-007 | Manager Workload Analysis | COULD | Calculation | Planned |

**File**: [04-assignment.frs.md](./04-assignment.frs.md)

---

## 05. Organization Structure (FR-BU)

Quản lý legal entities, business units và hierarchy.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-BU-001 | Create Business Unit | MUST | Functional | Defined |
| FR-BU-002 | Update Business Unit | MUST | Functional | Defined |
| FR-BU-003 | Deactivate Business Unit | MUST | Workflow | Defined |
| FR-BU-004 | Business Unit Status Management | MUST | Workflow | Defined |
| FR-BU-010 | Business Unit Type Configuration | MUST | Configuration | Defined |
| FR-BU-011 | Operational Organization | MUST | Functional | Defined |
| FR-BU-012 | Supervisory Organization | SHOULD | Functional | Defined |
| FR-BU-020 | Business Unit Hierarchy | MUST | Functional | Defined |
| FR-BU-021 | Parent-Child Relationship | MUST | Validation | Defined |
| FR-BU-022 | Hierarchy Depth Limit | SHOULD | Validation | Defined |
| FR-BU-023 | Circular Reference Prevention | MUST | Validation | Defined |
| FR-BU-030 | Business Unit Manager Assignment | MUST | Functional | Defined |
| FR-BU-031 | Manager History Tracking | SHOULD | Functional | Defined |
| FR-BU-040 | Cost Center Assignment | SHOULD | Functional | Defined |
| FR-BU-041 | Cost Center Configuration | SHOULD | Configuration | Defined |
| FR-BU-050 | Business Unit Search & Filter | MUST | Functional | Defined |
| FR-BU-051 | Org Chart Visualization | SHOULD | UI/UX | Planned |
| FR-BU-052 | Hierarchy Tree View | SHOULD | UI/UX | Planned |
| FR-BU-060 | Business Unit Reporting | SHOULD | Functional | Planned |
| FR-BU-061 | Headcount by Unit Report | SHOULD | Functional | Planned |
| FR-LE-001 | Create Legal Entity | MUST | Functional | Planned |
| FR-LE-002 | Legal Entity Configuration | MUST | Configuration | Planned |
| FR-LE-003 | Legal Entity Hierarchy | SHOULD | Functional | Planned |
| FR-LE-004 | Legal Entity Search | MUST | Functional | Planned |
| FR-LOC-001 | Location Management | MUST | Functional | Planned |
| FR-LOC-002 | Location Type Configuration | MUST | Configuration | Planned |
| FR-LOC-003 | Location Hierarchy | SHOULD | Functional | Planned |

**File**: [05-organization.frs.md](./05-organization.frs.md)

---

## 06. Job & Position Management (FR-TAX, FR-PRF, FR-POS)

Quản lý job catalog, profiles và positions.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-TAX-001 | Create Job Taxonomy Tree | MUST | Functional | Defined |
| FR-TAX-002 | Job Taxonomy Node Management | MUST | Functional | Defined |
| FR-TAX-003 | Job Family Definition | MUST | Functional | Defined |
| FR-TAX-004 | Job Function Definition | MUST | Functional | Defined |
| FR-TAX-005 | Job Taxonomy Hierarchy | MUST | Validation | Defined |
| FR-TAX-010 | Job Level Management | MUST | Configuration | Defined |
| FR-TAX-011 | Job Grade Management | MUST | Configuration | Defined |
| FR-TAX-012 | Level-Grade Mapping | SHOULD | Configuration | Defined |
| FR-TAX-020 | Job Taxonomy Search & Filter | MUST | Functional | Defined |
| FR-TAX-021 | Taxonomy Tree Visualization | SHOULD | UI/UX | Planned |
| FR-PRF-001 | Create Job Profile | MUST | Functional | Defined |
| FR-PRF-002 | Update Job Profile | MUST | Functional | Defined |
| FR-PRF-003 | Job Profile Status Management | MUST | Workflow | Defined |
| FR-PRF-004 | Job Profile Versioning | SHOULD | Functional | Planned |
| FR-PRF-010 | Job Description Management | MUST | Functional | Defined |
| FR-PRF-011 | Rich Text Job Description | SHOULD | UI/UX | Defined |
| FR-PRF-020 | Job Skill Requirements | MUST | Functional | Defined |
| FR-PRF-021 | Skill Proficiency Level | MUST | Configuration | Defined |
| FR-PRF-022 | Required vs Preferred Skills | SHOULD | Functional | Defined |
| FR-PRF-030 | Job Competency Requirements | SHOULD | Functional | Defined |
| FR-PRF-031 | Competency Level Mapping | SHOULD | Configuration | Defined |
| FR-PRF-040 | Education Requirements | SHOULD | Functional | Defined |
| FR-PRF-041 | Certification Requirements | SHOULD | Functional | Defined |
| FR-PRF-050 | Experience Requirements | SHOULD | Functional | Defined |
| FR-PRF-051 | Industry Experience | COULD | Functional | Planned |
| FR-PRF-060 | Physical Requirements | COULD | Functional | Defined |
| FR-PRF-061 | Working Conditions | COULD | Functional | Defined |
| FR-PRF-070 | Job Profile Approval Workflow | SHOULD | Workflow | Planned |
| FR-PRF-080 | Job Profile Search & Filter | MUST | Functional | Defined |
| FR-POS-001 | Create Position | MUST | Functional | Defined |
| FR-POS-002 | Update Position | MUST | Functional | Defined |
| FR-POS-003 | Position Status Management | MUST | Workflow | Defined |
| FR-POS-004 | Deactivate Position | MUST | Workflow | Defined |
| FR-POS-010 | Position-Job Linking | MUST | Functional | Defined |
| FR-POS-011 | Position-Business Unit Linking | MUST | Functional | Defined |
| FR-POS-020 | Position Budgeting | SHOULD | Functional | Defined |
| FR-POS-021 | Headcount Management | MUST | Functional | Defined |
| FR-POS-022 | FTE Tracking | MUST | Calculation | Defined |
| FR-POS-030 | Position Freeze/Unfreeze | SHOULD | Workflow | Defined |
| FR-POS-031 | Position Requisition | SHOULD | Workflow | Defined |
| FR-POS-040 | Position Hierarchy | SHOULD | Functional | Defined |
| FR-POS-041 | Reporting Position | SHOULD | Functional | Defined |
| FR-POS-050 | Position Location Tracking | SHOULD | Functional | Defined |
| FR-POS-060 | Position Search & Filter | MUST | Functional | Defined |
| FR-POS-061 | Position Reporting | SHOULD | Functional | Planned |
| FR-POS-062 | Vacant Position Report | MUST | Functional | Defined |

**File**: [06-job-position.frs.md](./06-job-position.frs.md)

---

## 07. Skill Management (FR-SKL, FR-ASS)

Quản lý skill catalog, assessments và certifications.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-SKL-001 | Create Skill | MUST | Functional | Defined |
| FR-SKL-002 | Update Skill | MUST | Functional | Defined |
| FR-SKL-003 | Deactivate Skill | MUST | Workflow | Defined |
| FR-SKL-010 | Skill Category Management | MUST | Configuration | Defined |
| FR-SKL-011 | Skill Taxonomy | SHOULD | Functional | Defined |
| FR-SKL-020 | Proficiency Level Definition | MUST | Configuration | Defined |
| FR-SKL-021 | Proficiency Scale Configuration | MUST | Configuration | Defined |
| FR-SKL-022 | Proficiency Descriptors | SHOULD | Configuration | Defined |
| FR-SKL-030 | Skill Search & Filter | MUST | Functional | Defined |
| FR-SKL-031 | Skill Catalog View | SHOULD | UI/UX | Defined |
| FR-SKL-040 | Skill Data Export | SHOULD | Integration | Defined |
| FR-SKL-041 | Skill Data Import | SHOULD | Integration | Planned |
| FR-SKL-050 | Skill Synonyms Management | COULD | Functional | Defined |
| FR-ASS-001 | Employee Skill Assignment | MUST | Functional | Planned |
| FR-ASS-002 | Skill Proficiency Recording | MUST | Functional | Planned |
| FR-ASS-003 | Skill Assessment Date | MUST | Functional | Planned |
| FR-ASS-010 | Self-Assessment | SHOULD | Workflow | Planned |
| FR-ASS-011 | Manager Assessment | SHOULD | Workflow | Planned |
| FR-ASS-012 | Assessment Approval | SHOULD | Workflow | Planned |
| FR-ASS-020 | Skill Gap Analysis | SHOULD | Calculation | Planned |
| FR-ASS-021 | Skill Match Report | SHOULD | Functional | Planned |
| FR-ASS-030 | Certification Tracking | SHOULD | Functional | Planned |
| FR-ASS-031 | Certification Expiry Notification | SHOULD | Workflow | Planned |

**File**: [07-skill.frs.md](./07-skill.frs.md)

---

## 08. Career Management (FR-CAR)

Quản lý career paths, ladders và progression.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-CAR-001 | Create Career Ladder | SHOULD | Functional | Defined |
| FR-CAR-002 | Career Ladder Level Definition | SHOULD | Configuration | Defined |
| FR-CAR-003 | Career Ladder Status Management | SHOULD | Workflow | Defined |
| FR-CAR-010 | Define Career Path | SHOULD | Functional | Defined |
| FR-CAR-011 | Path Step Configuration | SHOULD | Configuration | Defined |
| FR-CAR-012 | Path Requirements | SHOULD | Functional | Defined |
| FR-CAR-020 | Career Readiness Assessment | COULD | Calculation | Defined |
| FR-CAR-021 | Readiness Score Calculation | COULD | Calculation | Planned |
| FR-CAR-022 | Gap Identification | COULD | Functional | Planned |
| FR-CAR-030 | Career Path Visualization | COULD | UI/UX | Planned |
| FR-CAR-031 | Career Progression Timeline | COULD | UI/UX | Planned |
| FR-CAR-040 | Career Path Recommendations | COULD | Calculation | Planned |
| FR-CAR-041 | Succession Planning Integration | COULD | Integration | Planned |

**File**: [08-career.frs.md](./08-career.frs.md)

---

## 09. Eligibility Management (FR-ELG)

Cross-module eligibility profiles và rules.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-ELG-001 | Create Eligibility Profile | MUST | Functional | Defined |
| FR-ELG-002 | Update Eligibility Profile | MUST | Functional | Defined |
| FR-ELG-003 | Eligibility Profile Status | MUST | Workflow | Defined |
| FR-ELG-010 | Eligibility Rule Definition | MUST | Functional | Defined |
| FR-ELG-011 | Rule Criteria Configuration | MUST | Configuration | Defined |
| FR-ELG-012 | Rule Operator Configuration | MUST | Configuration | Defined |
| FR-ELG-020 | Rule Combination Logic | MUST | Validation | Defined |
| FR-ELG-021 | AND/OR Logic Support | MUST | Functional | Defined |
| FR-ELG-022 | Nested Rule Groups | SHOULD | Functional | Planned |
| FR-ELG-030 | Eligibility Evaluation | MUST | Calculation | Defined |
| FR-ELG-031 | Batch Eligibility Processing | SHOULD | Workflow | Planned |
| FR-ELG-032 | Real-time Eligibility Check | SHOULD | Functional | Planned |
| FR-ELG-040 | Eligibility Override | SHOULD | Functional | Defined |
| FR-ELG-041 | Override Reason Requirement | MUST | Validation | Defined |
| FR-ELG-042 | Override Approval Workflow | SHOULD | Workflow | Planned |
| FR-ELG-050 | Eligibility Reporting | SHOULD | Functional | Planned |
| FR-ELG-051 | Eligibility Audit Trail | MUST | Functional | Defined |

**File**: [09-eligibility.frs.md](./09-eligibility.frs.md)

---

## 10. Privacy & Security (FR-PRI)

GDPR, data classification, consent và security.

| FR ID | Name | Priority | Type | Status |
|-------|------|----------|------|--------|
| FR-PRI-001 | Data Classification | MUST | Configuration | Defined |
| FR-PRI-002 | Classification Level Definition | MUST | Configuration | Defined |
| FR-PRI-003 | Field-Level Classification | MUST | Functional | Defined |
| FR-PRI-010 | Data Encryption | MUST | Functional | Defined |
| FR-PRI-011 | Encryption Key Management | MUST | Configuration | Planned |
| FR-PRI-012 | At-Rest Encryption | MUST | Functional | Defined |
| FR-PRI-013 | In-Transit Encryption | MUST | Functional | Defined |
| FR-PRI-020 | Employee Consent Management | MUST | Functional | Defined |
| FR-PRI-021 | Consent Purpose Definition | MUST | Configuration | Defined |
| FR-PRI-022 | Consent Collection Workflow | MUST | Workflow | Defined |
| FR-PRI-023 | Consent Withdrawal | MUST | Workflow | Defined |
| FR-PRI-024 | Consent Audit Trail | MUST | Functional | Defined |
| FR-PRI-030 | Data Breach Notification | MUST | Workflow | Defined |
| FR-PRI-031 | Breach Impact Assessment | SHOULD | Functional | Planned |
| FR-PRI-032 | Notification Timeline Tracking | MUST | Workflow | Defined |
| FR-PRI-040 | Data Subject Rights | MUST | Functional | Defined |
| FR-PRI-041 | Right to Access | MUST | Functional | Defined |
| FR-PRI-042 | Right to Rectification | MUST | Functional | Defined |
| FR-PRI-043 | Right to Erasure | MUST | Workflow | Defined |
| FR-PRI-044 | Right to Portability | SHOULD | Functional | Planned |
| FR-PRI-050 | Data Retention Policies | SHOULD | Configuration | Planned |
| FR-PRI-051 | Retention Period Configuration | SHOULD | Configuration | Planned |
| FR-PRI-052 | Automated Data Purging | COULD | Workflow | Planned |
| FR-PRI-060 | Access Control | MUST | Functional | Defined |
| FR-PRI-061 | Role-Based Access Control | MUST | Configuration | Defined |
| FR-PRI-062 | Data Masking | SHOULD | Functional | Planned |
| FR-PRI-063 | Audit Logging | MUST | Functional | Defined |

**File**: [10-privacy.frs.md](./10-privacy.frs.md)

---

## Summary Statistics

### By Priority

| Priority | Count | Percentage |
|----------|-------|------------|
| MUST | ~200 | 44% |
| SHOULD | ~175 | 39% |
| COULD | ~75 | 17% |

### By Status

| Status | Count | Percentage |
|--------|-------|------------|
| Defined | ~280 | 62% |
| Planned | ~150 | 33% |
| In Progress | ~20 | 5% |

### By Type

| Type | Count |
|------|-------|
| Functional | ~180 |
| Workflow | ~95 |
| Configuration | ~75 |
| Validation | ~45 |
| UI/UX | ~25 |
| Calculation | ~20 |
| Integration | ~10 |

---

## Gap Analysis Notes

### Identified Gaps (từ Ontology & Research)

1. **Facility Management** - Chưa có FRs cho WorkLocation, Facility
2. **Competency Management** - Chỉ có FR-PRF liên quan, cần riêng FR-CMP
3. **Working Time** - Calendar, Work Schedule, Shift chưa có FRs
4. **Delegation** - Workflow delegation chưa được định nghĩa
5. **Integration Events** - Business events cho integration chưa có

### Recommended Additions

- FR-FAC-xxx: Facility & Workplace Management
- FR-CMP-xxx: Competency Catalog Management  
- FR-CAL-xxx: Calendar & Work Schedule Management
- FR-DEL-xxx: Workflow Delegation Management
- FR-EVT-xxx: Business Event Management

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-08 | System | Initial index creation |
