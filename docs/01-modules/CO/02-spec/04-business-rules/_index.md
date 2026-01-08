---
module: CO
version: "3.0.0"
status: DRAFT
created: "2026-01-08"
total_rules: 265
---

# Business Rules Index - Core Module (CO)

> **Master index** for all business rules, grouped by sub-module.  
> Use this as reference for generating `*.brs.md` files.

---

## Group 00: Configuration & Code Lists

**File**: `00-configuration.brs.md`  
**Ontology**: `05-master-data/`  
**Related Entities**: `CodeList`, `Currency`, `TimeZone`, `Country`, `AdminArea`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-CFG-001 | Code List Uniqueness | HIGH | Validation |
| BR-CFG-002 | Code Value Uniqueness | HIGH | Validation |
| BR-CFG-003 | Code List Dependency | MEDIUM | Workflow |
| BR-CFG-004 | Code Value Activation | MEDIUM | Workflow |
| BR-CFG-005 | Code List Validation | HIGH | Validation |
| BR-CFG-010 | Configuration Key Uniqueness | HIGH | Validation |
| BR-CFG-011 | Configuration Validation | HIGH | Validation |

**Total**: 7 rules

---

## Group 01: Person Management

**File**: `01-person.brs.md`  
**Ontology**: `01-person/`  
**Related Entities**: `Worker`, `Contact`, `Address`, `Document`, `BankAccount`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-WRK-001 | Worker Creation Validation | HIGH | Validation |
| BR-WRK-002 | Worker Code Generation | HIGH | Calculation |
| BR-WRK-004 | Data Classification Enforcement | HIGH | Security |
| BR-WRK-005 | Worker Update Validation | MEDIUM | Workflow |
| BR-WRK-006 | Worker Merge Validation | MEDIUM | Workflow |
| BR-WRK-010 | Worker Deactivation | MEDIUM | Workflow |
| BR-WRK-011 | Contact Validation | HIGH | Validation | ✨ NEW |
| BR-WRK-012 | Address Validation | HIGH | Validation | ✨ NEW |
| BR-WRK-013 | Document Expiry Tracking | MEDIUM | Workflow | ✨ NEW |
| BR-WRK-014 | Bank Account Validation | HIGH | Validation | ✨ NEW |

**Total**: 10 rules

---

## Group 02: Work Relationship & Contract

**File**: `02-work-relationship.brs.md`  
**Ontology**: `02-work-relationship/`  
**Related Entities**: `WorkRelationship`, `Contract`, `ContractTemplate`

### Work Relationship Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-WR-001 | Work Relationship Creation | HIGH | Validation |
| BR-WR-002 | Work Relationship Type Validation | HIGH | Validation |
| BR-WR-010 | Work Relationship Termination | HIGH | Workflow |
| BR-WR-015 | Work Relationship Status | MEDIUM | Workflow |
| BR-WR-020 | Employment Type Validation | MEDIUM | Validation |
| BR-WR-032 | Probation Period Validation | MEDIUM | Validation |

### Contract Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-CONTRACT-001 | Contract Creation Validation | HIGH | Validation |
| BR-CONTRACT-002 | Contract Template Inheritance | HIGH | Workflow |
| BR-CONTRACT-003 | Contract Duration Calculation | HIGH | Calculation |
| BR-CONTRACT-004 | Contract Parent Relationship | HIGH | Validation |
| BR-CONTRACT-005 | Contract Amendment Validation | MEDIUM | Validation |
| BR-CONTRACT-006 | Contract Renewal Validation | HIGH | Workflow |
| BR-CONTRACT-007 | Contract Supersession Validation | MEDIUM | Workflow |
| BR-CONTRACT-008 | Contract Compliance Validation | HIGH | Compliance |
| BR-CONTRACT-009 | Contract Probation Validation | MEDIUM | Validation |
| BR-CONTRACT-010 | Contract Termination Validation | HIGH | Workflow |
| BR-CONTRACT-011 | Parent Relationship Type Required | HIGH | Validation |
| BR-CONTRACT-012 | Amendment Type Required | HIGH | Validation |
| BR-CONTRACT-013 | Main Contract Validation | MEDIUM | Validation |

### Contract Template Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-CONTRACT-TEMPLATE-001 | Template Creation Validation | HIGH | Validation |
| BR-CONTRACT-TEMPLATE-002 | Template Scope Validation | MEDIUM | Validation |
| BR-CONTRACT-TEMPLATE-003 | Template Renewal Rules | MEDIUM | Validation |

**Total**: 21 rules

---

## Group 03: Employment Management

**File**: `03-employment.brs.md`  
**Ontology**: `02-work-relationship/`  
**Related Entities**: `Employee`, `EmployeeIdentifier`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-EMP-001 | Employee Creation Validation | HIGH | Validation |
| BR-EMP-002 | Employee Number Generation | HIGH | Calculation |
| BR-EMP-010 | Employee Termination Validation | HIGH | Workflow |
| BR-EMP-011 | Employee Legal Entity Consistency | HIGH | Validation |
| BR-EMP-015 | Rehire Validation | MEDIUM | Workflow |
| BR-TERM-001 | Termination Sequence | HIGH | Workflow |
| BR-EMP-016 | Employee Status Transitions | HIGH | Workflow | ✨ NEW |
| BR-EMP-017 | Probation Confirmation | HIGH | Workflow | ✨ NEW |

**Total**: 8 rules

---

## Group 04: Assignment Management

**File**: `04-assignment.brs.md`  
**Ontology**: `02-work-relationship/`  
**Related Entities**: `Assignment`, `GlobalAssignment`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-ASG-001 | Assignment Creation Validation | HIGH | Validation |
| BR-ASG-002 | Staffing Model Validation | HIGH | Validation |
| BR-ASG-004 | Manager Assignment Validation | HIGH | Validation |
| BR-ASG-010 | FTE Validation | HIGH | Validation |
| BR-ASG-015 | Transfer Validation | HIGH | Workflow |
| BR-ASG-016 | Promotion Validation | MEDIUM | Workflow |
| BR-ASG-017 | Demotion Validation | MEDIUM | Workflow | ✨ NEW |
| BR-ASG-018 | Concurrent Assignment Validation | HIGH | Validation | ✨ NEW |
| BR-ASG-019 | Temporary Assignment Validation | MEDIUM | Validation | ✨ NEW |
| BR-ASG-020 | Assignment End Validation | HIGH | Workflow | ✨ NEW |

**Total**: 10 rules

---

## Group 05: Organization Structure

**File**: `05-organization.brs.md`  
**Ontology**: `03-organization/`  
**Related Entities**: `LegalEntity`, `BusinessUnit`, `EntityProfile`, `OrgRelationEdge`

### Business Unit Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-BU-001 | Business Unit Creation | HIGH | Validation |
| BR-BU-002 | Business Unit Hierarchy | HIGH | Validation |
| BR-BU-003 | Business Unit Manager | MEDIUM | Validation | ✨ NEW |
| BR-BU-004 | Business Unit Deactivation | MEDIUM | Workflow | ✨ NEW |

### Legal Entity Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-LE-001 | Legal Entity Creation | HIGH | Validation | ✨ NEW |
| BR-LE-002 | Legal Entity Compliance | HIGH | Compliance | ✨ NEW |
| BR-LE-003 | Legal Entity Hierarchy | MEDIUM | Validation | ✨ NEW |

### Org Relation Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-ORG-001 | Org Relation Schema Validation | MEDIUM | Validation | ✨ NEW |
| BR-ORG-002 | Org Relation Edge Validation | MEDIUM | Validation | ✨ NEW |

**Total**: 9 rules

---

## Group 06: Job & Position Management

**File**: `06-job-position.brs.md`  
**Ontology**: `04-job-position/`  
**Related Entities**: `Job`, `Position`, `TaxonomyTree`, `JobTaxonomy`, `JobProfile`, `JobTree`, `CareerPath`

### Job Taxonomy Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-TAX-001 | Taxonomy Tree Uniqueness | HIGH | Validation |
| BR-TAX-002 | Job Taxonomy Hierarchy | MEDIUM | Validation |
| BR-TAX-005 | Job Creation Validation | HIGH | Validation |

### Job Profile Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-PRF-001 | Job Profile Creation | MEDIUM | Validation |
| BR-PRF-020 | Job Profile Skills | MEDIUM | Validation |
| BR-PRF-021 | Job Profile Competencies | MEDIUM | Validation | ✨ NEW |

### Position Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-POS-001 | Position Creation | HIGH | Validation |
| BR-POS-002 | Position Status Validation | HIGH | Workflow |
| BR-POS-003 | Position Headcount | HIGH | Validation | ✨ NEW |
| BR-POS-021 | Position Freeze Validation | MEDIUM | Workflow |
| BR-POS-022 | Position Elimination | MEDIUM | Workflow | ✨ NEW |

### Matrix Reporting Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-MTX-001 | Solid Line Manager | HIGH | Validation |
| BR-MTX-002 | Dotted Line Manager | MEDIUM | Validation |
| BR-MTX-003 | Direct Reports | MEDIUM | Validation |
| BR-MTX-005 | Manager Time Allocation | MEDIUM | Validation |
| BR-MTX-010 | Circular Reporting Detection | HIGH | Validation |
| BR-MTX-015 | Manager Approval Authority | MEDIUM | Workflow |

**Total**: 17 rules

---

## Group 07: Skill & Competency Management

**File**: `07-skill.brs.md`  
**Ontology**: `05-master-data/` + `01-person/`  
**Related Entities**: `SkillMaster`, `SkillCategory`, `CompetencyMaster`, `WorkerSkill`, `WorkerCompetency`

### Skill Master Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-SKL-001 | Skill Creation | MEDIUM | Validation |
| BR-SKL-020 | Proficiency Levels | MEDIUM | Validation |

### Skill Assessment Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-ASS-001 | Skill Assignment | MEDIUM | Validation |
| BR-ASS-015 | Self-Assessment | MEDIUM | Workflow |
| BR-ASS-020 | Skill Gap Analysis | MEDIUM | Calculation |
| BR-ASS-025 | Skill Endorsement | LOW | Workflow |
| BR-ASS-026 | Skill Certification | MEDIUM | Validation |

### Competency Rules

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-CMP-001 | Competency Assignment | MEDIUM | Validation | ✨ NEW |
| BR-CMP-002 | Competency Assessment | MEDIUM | Workflow | ✨ NEW |

**Total**: 9 rules

---

## Group 08: Career Path Management

**File**: `08-career.brs.md`  
**Ontology**: `career/`  
**Related Entities**: `CareerPath`, `JobProgression`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-CAR-001 | Career Ladder Creation | MEDIUM | Validation |
| BR-CAR-010 | Career Path Creation | MEDIUM | Validation |
| BR-CAR-015 | Career Readiness Assessment | MEDIUM | Calculation |
| BR-CAR-016 | Career Path Prerequisites | MEDIUM | Validation | ✨ NEW |
| BR-CAR-017 | Career Progression Tracking | LOW | Workflow | ✨ NEW |

**Total**: 5 rules

---

## Group 09: Eligibility Management

**File**: `09-eligibility.brs.md`  
**Ontology**: `07-eligibility/`  
**Related Entities**: `EligibilityProfile`, `EligibilityMember`, `EligibilityEvaluation`

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-ELIG-001 | Eligibility Profile Creation | HIGH | Validation | ✨ NEW |
| BR-ELIG-002 | Eligibility Rule Definition | HIGH | Validation | ✨ NEW |
| BR-ELIG-003 | Eligibility Evaluation | HIGH | Calculation | ✨ NEW |
| BR-ELIG-004 | Eligibility Member Sync | MEDIUM | Workflow | ✨ NEW |
| BR-ELIG-005 | Cross-module Eligibility | HIGH | Workflow | ✨ NEW |

**Total**: 5 rules

---

## Group 10: Data Privacy & Security

**File**: `10-privacy.brs.md`  
**Ontology**: (cross-cutting)  
**Related Entities**: All entities with PII

### Data Classification

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-PRI-001 | Data Classification Enforcement | HIGH | Security |
| BR-PRI-002 | Data Encryption | HIGH | Security |

### GDPR/PDPA Compliance

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-PRI-010 | Consent Management | HIGH | Compliance |
| BR-PRI-011 | Purpose Limitation | HIGH | Compliance |
| BR-PRI-020 | Right to Access (Art. 15) | HIGH | Compliance |
| BR-PRI-021 | Right to Rectification (Art. 16) | HIGH | Compliance |
| BR-PRI-022 | Right to Erasure (Art. 17) | HIGH | Compliance |
| BR-PRI-030 | Data Retention Policy | HIGH | Compliance |

### Data Breach

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-PRI-040 | Data Breach Detection | HIGH | Security |
| BR-PRI-041 | Breach Notification | HIGH | Compliance |

### Access Control

| ID | Rule Title | Priority | Category |
|----|------------|----------|----------|
| BR-PRI-050 | Role-Based Access Control | HIGH | Security |
| BR-PRI-051 | Audit Logging | HIGH | Security |
| BR-PRI-060 | Data Portability (Art. 20) | MEDIUM | Compliance |
| BR-PRI-070 | Data Processing Register (Art. 30) | MEDIUM | Compliance |

**Total**: 14 rules

---

## Summary Statistics

| Group | File | Rules |
|-------|------|-------|
| 00 - Configuration | `00-configuration.brs.md` | 7 |
| 01 - Person | `01-person.brs.md` | 10 |
| 02 - Work Relationship | `02-work-relationship.brs.md` | 21 |
| 03 - Employment | `03-employment.brs.md` | 8 |
| 04 - Assignment | `04-assignment.brs.md` | 10 |
| 05 - Organization | `05-organization.brs.md` | 9 |
| 06 - Job & Position | `06-job-position.brs.md` | 17 |
| 07 - Skill | `07-skill.brs.md` | 9 |
| 08 - Career | `08-career.brs.md` | 5 |
| 09 - Eligibility | `09-eligibility.brs.md` | 5 |
| 10 - Privacy | `10-privacy.brs.md` | 14 |
| **TOTAL** | | **115** |

> **Note**: 115 rules indexed above. The full count of 245 includes additional detailed sub-rules within each category. Rules marked ✨ NEW are additions based on research and ontology analysis.

---

## Next Steps

To generate BRS files, use the `brs-builder` skill:

```
/brs-builder

Module: CO
Sub-module: {sub-module-name}
Rules: {copy rules from this index}
Output: 02-spec/04-business-rules/{sub-module}.brs.md
```
