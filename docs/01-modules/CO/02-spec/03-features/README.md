# Core Module Features

> **Thư mục này chứa Feature Specification Documents (`*.feat.md`)** cho module Core HR - xTalent HCM.

## Tổng quan

Mỗi feature document mô tả **HOW to implement** một user journey cụ thể, bao gồm:
- YAML metadata (data for AI)
- User Story, Acceptance Criteria (Gherkin)
- Data Contract (JSON5)
- Activities Flow (sequenceDiagram)
- UI Sketch (wireframe)

## Cấu trúc thư mục

```
03-features/
├── README.md                    # File này
├── _index.md                    # Danh mục features (YAML + Table)
├── 01-person/                   # Person Management
│   ├── create-worker.feat.md
│   ├── update-worker.feat.md
│   └── manage-documents.feat.md
├── 02-employment/               # Employment Management
│   ├── hire-employee.feat.md
│   ├── create-contract.feat.md
│   ├── transfer-employee.feat.md
│   └── terminate-employment.feat.md
├── 03-organization/             # Organization Structure
│   ├── manage-legal-entity.feat.md
│   ├── manage-business-unit.feat.md
│   └── view-org-chart.feat.md
├── 04-job-position/             # Job & Position
│   ├── manage-job-catalog.feat.md
│   ├── create-position.feat.md
│   └── define-career-path.feat.md
├── 05-master-data/              # Master Data & Configuration
│   ├── manage-code-list.feat.md
│   └── manage-skill-catalog.feat.md
└── 06-eligibility/              # Eligibility Management
    ├── create-eligibility-profile.feat.md
    └── evaluate-eligibility.feat.md
```

## Tài liệu liên quan

| Tài liệu | Đường dẫn | Mô tả |
|----------|-----------|-------|
| **FRS** | `01-functional-requirements/` | Chi tiết Functional Requirements |
| **BRS** | `00-business-rules/` | Chi tiết Business Rules |
| **Ontology** | `00-ontology/domain/` | Entity definitions |
| **FEATURE-LIST** | `FEATURE-LIST.yaml` | Master feature catalog |

## Quy ước đặt tên

- **File**: `{action}-{noun}.feat.md` (ví dụ: `create-worker.feat.md`)
- **FEAT ID**: `FEAT-CO-{NNN}` (ví dụ: `FEAT-CO-001`)
- **Sub-module folder**: `{NN}-{sub-module-name}/`

## Phụ thuộc

```mermaid
graph TD
    subgraph Phase 0
        F015[015 Code List]
    end
    subgraph Phase 1
        F001[001 Worker]
        F002[002 Work Relationship]
        F003[003 Employee]
        F004[004 Assignment]
        F005[005 Reporting]
    end
    subgraph Phase 2
        F006[006 Business Unit]
        F007[007 Job Taxonomy]
        F008[008 Job Profile]
        F009[009 Position]
        F010[010 Matrix Reporting]
    end
    subgraph Phase 3
        F011[011 Skill Catalog]
        F012[012 Skill Assessment]
        F013[013 Career Paths]
        F014[014 Data Privacy]
    end
    
    F015 --> F001
    F001 --> F002 --> F003 --> F004
    F004 --> F005
    F006 --> F009
    F007 --> F008 --> F009
    F004 --> F010
    F011 --> F012 --> F013
    F001 --> F014
```

## Trạng thái

| Status | Count |
|--------|-------|
| PLANNED | 15 |
| IN_PROGRESS | 0 |
| COMPLETED | 0 |
