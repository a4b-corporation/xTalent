---
domain: Core HR
module: CO
version: "2.0.0"
status: DRAFT
created: "2026-01-23"
updated: "2026-01-23"
ontology_ref: "/docs/01-modules/CO/00-ontology/domain/"

# Summary Statistics
statistics:
  total_entities: 30
  by_submodule:
    person: 9
    work_relationship: 6
    organization: 7
    job_position: 8
---

# Entity Catalog: Core HR (CO)

> Aligned với ontology documentation tại `/docs/01-modules/CO/00-ontology/domain/`

---

## Terminology (ADR-CO-001)

| Entity | Vietnamese | Role |
|--------|------------|------|
| **Worker** | Người lao động | Physical person identity (lifetime) |
| **WorkRelationship** | Mối quan hệ lao động | Employment relationship type |
| **Employee** | Nhân viên | Employment record (when type=EMPLOYEE) |
| **LegalEntity** | Pháp nhân | Employer entity |
| **Contract** | Hợp đồng lao động | Employment contract |
| **Assignment** | Phân công công việc | Position assignment |

---

## Sub-module: Person

> Quản lý thông tin cá nhân của người lao động

| ID | Entity | Description | PII |
|----|--------|-------------|-----|
| CO-P01 | **Worker** | Người lao động - lifetime identity | HIGH |
| CO-P02 | Contact | Thông tin liên hệ (phone, email) | HIGH |
| CO-P03 | Address | Địa chỉ (home, mailing) | HIGH |
| CO-P04 | Document | Giấy tờ tùy thân (CMND, hộ chiếu) | HIGH |
| CO-P05 | BankAccount | Tài khoản ngân hàng | HIGH |
| CO-P06 | WorkerRelationship | Quan hệ gia đình (dependents, emergency) | HIGH |
| CO-P07 | WorkerQualification | Bằng cấp, chứng chỉ | LOW |
| CO-P08 | WorkerSkill | Kỹ năng | LOW |
| CO-P09 | WorkerCompetency | Năng lực hành vi | LOW |

### Worker Entity (Aggregate Root)

```mermaid
erDiagram
    WORKER ||--o{ CONTACT : "has"
    WORKER ||--o{ ADDRESS : "has"
    WORKER ||--o{ DOCUMENT : "has"
    WORKER ||--o{ BANK_ACCOUNT : "has"
    WORKER ||--o{ WORKER_RELATIONSHIP : "has"
    WORKER ||--o{ WORKER_SKILL : "has"
    WORKER ||--o{ WORK_RELATIONSHIP : "has (employment)"
```

---

## Sub-module: Work Relationship

> Quản lý mối quan hệ lao động và hồ sơ nhân viên

| ID | Entity | Description | PII |
|----|--------|-------------|-----|
| CO-WR01 | **WorkRelationship** | Mối quan hệ lao động | MEDIUM |
| CO-WR02 | **Employee** | Hồ sơ nhân viên (khi type=EMPLOYEE) | MEDIUM |
| CO-WR03 | Contract | Hợp đồng lao động | MEDIUM |
| CO-WR04 | ContractTemplate | Mẫu hợp đồng | NONE |
| CO-WR05 | Assignment | Phân công vị trí | LOW |
| CO-WR06 | GlobalAssignment | Phân công quốc tế (expatriate) | LOW |

### WorkRelationship Types

| Type | Vietnamese | Has Employee Record? |
|------|------------|---------------------|
| EMPLOYEE | Nhân viên chính thức | ✅ Yes |
| CONTINGENT | Lao động phái cử/outsource | ❌ No |
| CONTRACTOR | Nhà thầu độc lập | ❌ No |
| NON_WORKER | Không lao động (intern, board) | ❌ No |

### Work Relationship Model

```mermaid
erDiagram
    WORKER ||--o{ WORK_RELATIONSHIP : "has"
    WORK_RELATIONSHIP }o--|| LEGAL_ENTITY : "with"
    WORK_RELATIONSHIP ||--o| EMPLOYEE : "has (if EMPLOYEE type)"
    
    EMPLOYEE ||--o{ CONTRACT : "has"
    EMPLOYEE ||--o{ ASSIGNMENT : "has"
    
    ASSIGNMENT }o--|| POSITION : "fills"
    ASSIGNMENT }o--|| BUSINESS_UNIT : "in"
```

---

## Sub-module: Organization

> Quản lý cấu trúc tổ chức

| ID | Entity | Description | PII |
|----|--------|-------------|-----|
| CO-O01 | **LegalEntity** | Pháp nhân (công ty) | NONE |
| CO-O02 | EntityProfile | Thông tin chi tiết pháp nhân | NONE |
| CO-O03 | EntityLicense | Giấy phép kinh doanh | NONE |
| CO-O04 | EntityBankAccount | Tài khoản ngân hàng công ty | NONE |
| CO-O05 | **BusinessUnit** | Đơn vị tổ chức | NONE |
| CO-O06 | OrgRelationType | Loại quan hệ tổ chức | NONE |
| CO-O07 | OrgRelationEdge | Quan hệ giữa các đơn vị | NONE |

### Organization Model

```mermaid
erDiagram
    LEGAL_ENTITY ||--o{ ENTITY_PROFILE : "has"
    LEGAL_ENTITY ||--o{ ENTITY_LICENSE : "has"
    LEGAL_ENTITY ||--o{ BUSINESS_UNIT : "has"
    
    BUSINESS_UNIT ||--o{ ORG_RELATION_EDGE : "source"
    BUSINESS_UNIT ||--o{ ORG_RELATION_EDGE : "target"
    ORG_RELATION_EDGE }o--|| ORG_RELATION_TYPE : "type"
```

---

## Sub-module: Job-Position

> Quản lý công việc và vị trí

| ID | Entity | Description | PII |
|----|--------|-------------|-----|
| CO-JP01 | **Job** | Công việc | NONE |
| CO-JP02 | JobProfile | Mô tả công việc chi tiết | NONE |
| CO-JP03 | JobTaxonomy | Phân loại công việc (family/level) | NONE |
| CO-JP04 | TaxonomyTree | Cây phân loại chức danh | NONE |
| CO-JP05 | **Position** | Vị trí (seat in org) | NONE |
| CO-JP06 | JobLevel | Cấp bậc | NONE |
| CO-JP07 | JobGrade | Ngạch lương | NONE |
| CO-JP08 | CareerPath | Lộ trình nghề nghiệp | NONE |

### Job-Position Model

```mermaid
erDiagram
    JOB ||--|| JOB_PROFILE : "has"
    JOB }o--|| JOB_TAXONOMY : "classified by"
    JOB_TAXONOMY }o--|| TAXONOMY_TREE : "in"
    
    POSITION }o--|| JOB : "uses template"
    POSITION }o--|| BUSINESS_UNIT : "belongs to"
    POSITION ||--o{ ASSIGNMENT : "filled by"
```

---

## Sub-module: Facility (Location)

> Quản lý địa điểm làm việc

| ID | Entity | Description | PII |
|----|--------|-------------|-----|
| CO-F01 | Place | Địa điểm vật lý | NONE |
| CO-F02 | Location | Vị trí (office, branch) | NONE |
| CO-F03 | WorkLocation | Nơi làm việc của nhân viên | NONE |

---

## Sub-module: Reference Data

> Dữ liệu danh mục

| ID | Entity | Description |
|----|--------|-------------|
| CO-R01 | CodeList | Danh mục mã dùng chung |
| CO-R02 | Currency | Loại tiền |
| CO-R03 | TimeZone | Múi giờ |
| CO-R04 | Country | Quốc gia |
| CO-R05 | AdminArea | Đơn vị hành chính (tỉnh/huyện) |
| CO-R06 | Industry | Ngành nghề |
| CO-R07 | SkillCategory | Danh mục kỹ năng |
| CO-R08 | SkillMaster | Danh sách kỹ năng |
| CO-R09 | CompetencyCategory | Danh mục năng lực |
| CO-R10 | CompetencyMaster | Danh sách năng lực |
| CO-R11 | RelationshipType | Loại quan hệ gia đình |
| CO-R12 | ContactType | Loại liên hệ |

---

## Cross-Domain Dependencies

```mermaid
graph LR
    subgraph Upstream
        IDM[Identity.IAM]
    end
    
    subgraph "Core HR (CO)"
        W[Worker] --> WR[WorkRelationship]
        WR --> E[Employee]
        E --> C[Contract]
        E --> A[Assignment]
        A --> P[Position]
        P --> J[Job]
    end
    
    subgraph Downstream
        PA[Payroll]
        TA[Time & Attendance]
        BN[Benefits]
        TM[Talent]
    end
    
    IDM --> W
    E --> PA
    W --> TA
    E --> BN
    W --> TM
```

---

## PII Sensitivity Summary

| Level | Count | Entities |
|-------|-------|----------|
| **HIGH** | 7 | Worker, Contact, Address, Document, BankAccount, WorkerRelationship, WorkerQualification |
| **MEDIUM** | 3 | WorkRelationship, Employee, Contract |
| **LOW** | 3 | Assignment, WorkerSkill, WorkerCompetency |
| **NONE** | 17 | Org, Job, Position, Reference Data |

---

## Ontology Reference

All entity definitions available at:
- `/docs/01-modules/CO/00-ontology/domain/person/` - Worker và child entities
- `/docs/01-modules/CO/00-ontology/domain/work-relationship/` - WorkRelationship, Employee
- `/docs/01-modules/CO/00-ontology/domain/organization/` - LegalEntity, BusinessUnit
- `/docs/01-modules/CO/00-ontology/domain/job-position/` - Job, Position
- `/docs/01-modules/CO/00-ontology/domain/facility/` - Place, Location
