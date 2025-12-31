
# xTalent HCM - Employee 360 View
## Product Concept Document

**Version**: 1.1  
**Date**: December 2025  
**Audience**: Product Team, UX Designers, Stakeholders

---

## 1. Executive Summary

### 1.1 Vision Statement

> **"Một cái nhìn toàn diện về con người - không chỉ là nhân viên"**

Employee 360 View là màn hình trung tâm hiển thị toàn bộ thông tin liên quan đến một cá nhân trong hệ thống HCM. Đây là điểm đến từ Global Search khi user tìm kiếm nhân sự, cung cấp cái nhìn tổng quan và khả năng drill-down vào mọi khía cạnh của employee data graph.

### 1.2 Design Philosophy

```mermaid
mindmap
  root((Employee 360 Philosophy))
    Human-Centric
      Worker/Person first
      Role second
      Complete life context
      Career journey focus
    Progressive Disclosure
      Summary first
      Details on demand
      Contextual deep-dive
    Connected Data
      Relationship visualization
      Cross-module insights
      Timeline continuity
    Role-Aware
      Adaptive content
      Permission-based views
      Action-oriented
```

### 1.3 Key Objectives

| Objective | Description | Success Metric |
|-----------|-------------|----------------|
| **Comprehensive** | Hiển thị mọi thông tin liên quan trong một view | 100% data coverage |
| **Intuitive** | User tìm được thông tin trong < 3 clicks | Task completion < 10s |
| **Contextual** | Thông tin phù hợp với role của viewer | Role satisfaction > 85% |
| **Connected** | Thể hiện relationships và dependencies | Graph navigation success |
| **Actionable** | Quick actions từ context hiện tại | Action completion rate > 70% |

---

## 2. Data Model Foundation

### 2.1 Core Concept: Worker → Working Relationship → Assignment

```mermaid
flowchart TB
    subgraph WorkerLayer["👤 WORKER (Person/Người Lao Động)"]
        W["Worker<br/>The actual person"]
    end
    
    subgraph WRLayer["📋 WORKING RELATIONSHIPS"]
        WR1["Working Relationship 1<br/>Type: Employment"]
        WR2["Working Relationship 2<br/>Type: Contract"]
        WR3["Working Relationship 3<br/>Type: Contingent"]
    end
    
    subgraph LELayer["🏢 LEGAL ENTITIES"]
        LE1["ABC Corp Vietnam"]
        LE2["ABC Corp Singapore"]
        LE3["XYZ Consulting"]
    end
    
    subgraph AssignmentLayer["👔 ASSIGNMENTS"]
        E1["Employee<br/>EMP001"]
        E2["Employee<br/>EMP-SG-042"]
        C1["Contractor<br/>CON001"]
        CW1["Contingent Worker<br/>CW001"]
    end
    
    W --> WR1
    W --> WR2
    W --> WR3
    
    WR1 --> LE1
    WR2 --> LE2
    WR3 --> LE3
    
    WR1 -->|"creates"| E1
    WR2 -->|"creates"| E2
    WR3 -->|"creates"| CW1
    
    style WorkerLayer fill:#e3f2fd
    style WRLayer fill:#fff3e0
    style LELayer fill:#e8f5e9
    style AssignmentLayer fill:#fce4ec
```

### 2.2 Entity Relationship Model

```mermaid
erDiagram
    WORKER ||--o{ WORKING_RELATIONSHIP : "has"
    LEGAL_ENTITY ||--o{ WORKING_RELATIONSHIP : "engages"
    WORKING_RELATIONSHIP ||--o| EMPLOYEE : "creates (if employment)"
    WORKING_RELATIONSHIP ||--o| CONTRACTOR : "creates (if contract)"
    WORKING_RELATIONSHIP ||--o| CONTINGENT_WORKER : "creates (if contingent)"
    EMPLOYEE ||--o{ POSITION_ASSIGNMENT : "holds"
    POSITION ||--o{ POSITION_ASSIGNMENT : "filled by"
    DEPARTMENT ||--o{ POSITION : "contains"
    
    WORKER {
        uuid worker_id PK
        string first_name
        string last_name
        string full_name_vi
        string full_name_en
        date date_of_birth
        string gender
        string nationality
        string personal_email
        string phone
        string national_id
        string tax_id
    }
    
    LEGAL_ENTITY {
        uuid le_id PK
        string le_name
        string le_code
        string country
        string registration_no
        string tax_code
    }
    
    WORKING_RELATIONSHIP {
        uuid wr_id PK
        uuid worker_id FK
        uuid le_id FK
        string wr_type "employment|contract|contingent|internship"
        string wr_status "active|inactive|terminated"
        date start_date
        date end_date
        string contract_type
        string work_location
    }
    
    EMPLOYEE {
        uuid employee_id PK
        uuid wr_id FK
        string employee_number
        uuid primary_position_id FK
        uuid department_id FK
        uuid manager_id FK
        string employment_type "full-time|part-time"
        string employment_status
        date probation_end_date
    }
    
    CONTRACTOR {
        uuid contractor_id PK
        uuid wr_id FK
        string contractor_number
        string vendor_company
        decimal hourly_rate
        date contract_end_date
    }
    
    CONTINGENT_WORKER {
        uuid cw_id PK
        uuid wr_id FK
        string cw_number
        string agency_name
        string assignment_type
        date assignment_end_date
    }
```

### 2.3 Working Relationship Types

```mermaid
flowchart LR
    subgraph WRTypes["Working Relationship Types"]
        direction TB
        
        subgraph Employment["📋 Employment"]
            E1["Full-time Employee"]
            E2["Part-time Employee"]
            E3["Probationary Employee"]
            E4["Fixed-term Employee"]
        end
        
        subgraph Contract["📄 Contract"]
            C1["Independent Contractor"]
            C2["Freelancer"]
            C3["Consultant"]
        end
        
        subgraph Contingent["⏱️ Contingent"]
            CW1["Temporary Worker"]
            CW2["Agency Worker"]
            CW3["Seasonal Worker"]
        end
        
        subgraph Other["📎 Other"]
            O1["Intern"]
            O2["Apprentice"]
            O3["Volunteer"]
        end
    end
    
    Employment -->|"Creates"| EMP["Employee Record"]
    Contract -->|"Creates"| CON["Contractor Record"]
    Contingent -->|"Creates"| CWR["Contingent Record"]
    Other -->|"Creates"| OTH["Specific Record"]
    
    style Employment fill:#e8f5e9
    style Contract fill:#fff3e0
    style Contingent fill:#e3f2fd
    style Other fill:#fce4ec
```

### 2.4 Data Layer Architecture

```mermaid
flowchart TB
    subgraph L1["Layer 1: WORKER (Person Identity)"]
        direction LR
        W1["Personal Information"]
        W2["Contact Details"]
        W3["Identity Documents"]
        W4["Emergency Contacts"]
        W5["Skills & Qualifications"]
        W6["Education History"]
    end
    
    subgraph L2["Layer 2: WORKING RELATIONSHIP (Engagement)"]
        direction LR
        WR1["Contract Terms"]
        WR2["Work Location"]
        WR3["Legal Entity Link"]
        WR4["Relationship Status"]
        WR5["Start/End Dates"]
    end
    
    subgraph L3["Layer 3: ASSIGNMENT (Role-specific)"]
        direction LR
        
        subgraph EmpData["Employee Data"]
            ED1["Position & Job"]
            ED2["Department & Org"]
            ED3["Manager Hierarchy"]
            ED4["Compensation"]
            ED5["Benefits"]
            ED6["Time & Attendance"]
            ED7["Performance"]
        end
        
        subgraph ConData["Contractor Data"]
            CD1["Rate & Billing"]
            CD2["Project Assignment"]
            CD3["Deliverables"]
            CD4["Vendor Info"]
        end
        
        subgraph CWData["Contingent Data"]
            CW1["Agency Details"]
            CW2["Assignment Terms"]
            CW3["Billing Rate"]
        end
    end
    
    L1 -->|"Shared across all WRs"| L2
    L2 -->|"Type determines"| L3
    
    style L1 fill:#e3f2fd
    style L2 fill:#fff3e0
    style L3 fill:#e8f5e9
```

### 2.5 Multi-Relationship Scenario

```mermaid
flowchart TB
    subgraph Worker["👤 NGUYỄN VĂN A (Worker)"]
        W["Worker ID: W-001<br/>Personal Identity"]
    end
    
    subgraph Relationships["📋 Working Relationships"]
        WR1["WR-001<br/>Employment<br/>ABC Corp Vietnam<br/>Since: Jan 2020<br/>Status: Active"]
        WR2["WR-002<br/>Employment<br/>ABC Corp Singapore<br/>Since: Jul 2024<br/>Status: Active (Secondment)"]
        WR3["WR-003<br/>Contract<br/>XYZ Consulting<br/>Mar 2023 - Jun 2023<br/>Status: Completed"]
    end
    
    subgraph Assignments["👔 Assignments"]
        E1["Employee: EMP-VN-001<br/>Senior Engineer<br/>Engineering Dept<br/>Manager: Trần B"]
        E2["Employee: EMP-SG-042<br/>Tech Lead<br/>Regional Tech<br/>Manager: John D"]
        C1["Contractor: CON-XYZ-15<br/>Technical Consultant<br/>Rate: $XXX/day<br/>(Historical)"]
    end
    
    Worker --> WR1
    Worker --> WR2
    Worker --> WR3
    
    WR1 --> E1
    WR2 --> E2
    WR3 --> C1
    
    style Worker fill:#e3f2fd
    style WR1 fill:#e8f5e9
    style WR2 fill:#e8f5e9
    style WR3 fill:#fff3e0
```

---

## 3. Competitive Analysis

### 3.1 Oracle HCM Cloud - Person Spotlight

**Key Features:**
- **Spotlight Card**: Quick summary với photo, name, position, contact
- **Connections**: Visual org relationships
- **Journey Timeline**: Employment history as timeline
- **Quick Actions**: Context-sensitive actions
- **Feedback Integration**: Recognition và feedback inline

```
┌─────────────────────────────────────────────────────────────┐
│  ORACLE HCM - PERSON SPOTLIGHT                              │
├─────────────────────────────────────────────────────────────┤
│  ┌──────┐  John Smith                                       │
│  │ 📷   │  Senior Software Engineer                         │
│  │      │  Engineering Department                           │
│  └──────┘  📧 john.smith@company.com  📱 +1-xxx-xxx         │
│                                                             │
│  [Actions ▼] [Org Chart] [Directory] [Send Kudos]          │
├─────────────────────────────────────────────────────────────┤
│  Tabs: Overview | Career | Performance | Compensation | ... │
└─────────────────────────────────────────────────────────────┘
```

**Strengths**: Deep integration, comprehensive data, enterprise-grade  
**Weaknesses**: Complex navigation, steep learning curve

### 3.2 SAP SuccessFactors - People Profile

**Key Features:**
- **Profile Header**: Rich header với badges, status
- **Talent Card**: Skills, competencies, potential
- **Live Profile**: Social-media style updates
- **Continuous Performance**: Ongoing feedback
- **Development Plan**: Career aspirations visible

```
┌─────────────────────────────────────────────────────────────┐
│  SAP SUCCESSFACTORS - PEOPLE PROFILE                        │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │  👤 Maria Garcia         🏆 Top Performer             │   │
│  │  Product Manager         📍 Barcelona, Spain          │   │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │   │
│  │  Skills: Agile ● Product Strategy ● Analytics        │   │
│  │  Badges: 🎯 Goal Champion  💡 Innovator               │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  📊 Talent Snapshot    📈 Performance    🎯 Goals           │
└─────────────────────────────────────────────────────────────┘
```

**Strengths**: Talent-centric, social features, modern UX  
**Weaknesses**: Module silos, inconsistent experience

### 3.3 Workday - Worker Profile

**Key Features:**
- **Related Actions**: Extensive action menu
- **Worklets**: Configurable information blocks
- **Org Viewer**: Interactive org chart
- **Timeline**: Activity stream
- **Worker History**: Complete employment timeline

```
┌─────────────────────────────────────────────────────────────┐
│  WORKDAY - WORKER PROFILE                                   │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────┐ ┌────────────────┐  │
│  │ David Chen                         │ │ Related Actions│  │
│  │ Staff Software Engineer            │ │ ─────────────  │  │
│  │ 📍 San Francisco • Eng-Platform    │ │ ▶ Job Change   │  │
│  │                                    │ │ ▶ Compensation │  │
│  │ Manager: Sarah Johnson             │ │ ▶ Time Off     │  │
│  │ 3 Direct Reports                   │ │ ▶ Benefits     │  │
│  └────────────────────────────────────┘ │ ▶ More...      │  │
│                                         └────────────────┘  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ Summary     │ │ Job Details │ │ Compensation│           │
│  │ Worklet     │ │ Worklet     │ │ Worklet     │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

**Strengths**: Configurable, action-oriented, unified data model  
**Weaknesses**: Dense UI, requires training

### 3.4 Competitive Comparison Matrix

| Feature | Oracle | SAP SF | Workday | xTalent (Target) |
|---------|--------|--------|---------|------------------|
| **Profile Completeness** | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★★ |
| **Visual Design** | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | ★★★★★ |
| **Navigation Ease** | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | ★★★★★ |
| **Multi-WR Support** | ★★★★☆ | ★★★☆☆ | ★★★★★ | ★★★★★ |
| **Graph Visualization** | ★★★☆☆ | ★★☆☆☆ | ★★★★☆ | ★★★★★ |
| **Quick Actions** | ★★★★☆ | ★★★☆☆ | ★★★★★ | ★★★★★ |
| **Mobile Experience** | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★★★ |
| **AI Integration** | ★★★☆☆ | ★★★☆☆ | ★★★☆☆ | ★★★★★ |

---

## 4. Worker 360 Data Graph

### 4.1 Complete Data Universe

```mermaid
flowchart TB
    subgraph Center["🎯 Worker 360"]
        W["Worker<br/>Profile"]
    end
    
    subgraph WorkerData["Worker-Level Data (Shared)"]
        WD1["Personal Info"]
        WD2["Contact Details"]
        WD3["Skills & Competencies"]
        WD4["Qualifications"]
        WD5["Education"]
        WD6["Documents"]
    end
    
    subgraph WRData["Working Relationship Data"]
        WR1["Relationship 1<br/>(Employment)"]
        WR2["Relationship 2<br/>(Contract)"]
        WR3["Historical WRs"]
    end
    
    subgraph EmpData["Employee-Specific Data"]
        E1["Position & Job"]
        E2["Organization"]
        E3["Compensation"]
        E4["Benefits"]
        E5["Time & Attendance"]
        E6["Performance"]
        E7["Goals"]
    end
    
    subgraph ConData["Contractor-Specific Data"]
        C1["Rate & Billing"]
        C2["Projects"]
        C3["Deliverables"]
        C4["Vendor Info"]
    end
    
    subgraph Relations["Relationships"]
        R1["Manager"]
        R2["Direct Reports"]
        R3["Team Members"]
        R4["Mentors"]
    end
    
    W --- WorkerData
    W --- WRData
    WR1 --- EmpData
    WR2 --- ConData
    W --- Relations
```

### 4.2 Data Categories by Layer

```mermaid
mindmap
  root((Worker 360 Data))
    Worker Layer
      Personal Identity
        Full name VI/EN
        Date of birth
        Gender
        Nationality
        Marital status
        Photo
      Contact Information
        Personal email
        Phone numbers
        Addresses
        Emergency contacts
      Identity Documents
        National ID/CCCD
        Passport
        Tax ID
        Social Insurance
      Skills & Qualifications
        Skills inventory
        Certifications
        Licenses
        Languages
      Education
        Degrees
        Institutions
        Graduation dates
    
    Working Relationship Layer
      Relationship Details
        Type employment/contract/contingent
        Legal Entity
        Start/End dates
        Status
      Contract Terms
        Contract type
        Notice period
        Work location
        Work schedule
      Relationship History
        Previous WRs
        Transitions
        Gaps
    
    Employee Assignment Layer
      Position & Job
        Job title
        Job family
        Job level/grade
        Position ID
      Organization
        Department
        Division
        Cost center
        Location
      Reporting
        Direct manager
        Matrix managers
        Direct reports
      Compensation
        Base salary
        Allowances
        Bonuses
        Total rewards
      Benefits
        Health insurance
        Retirement
        Other benefits
        Dependents
      Time Management
        Work schedule
        Leave balances
        Attendance
        Overtime
      Performance
        Current rating
        Goals progress
        Feedback history
        Reviews
    
    Contractor Assignment Layer
      Engagement
        Vendor company
        Project assignment
        Billing rate
      Deliverables
        SOW items
        Milestones
        Completion status
      Financials
        Rate card
        Invoices
        Payments
```

### 4.3 Relationship Graph

```mermaid
flowchart TB
    subgraph OrgRelations["Organizational Relationships"]
        M["👔 Manager<br/>Trần Văn B"]
        W["👤 Worker<br/>Nguyễn Văn A"]
        D1["👤 Direct Report 1"]
        D2["👤 Direct Report 2"]
        D3["👤 Direct Report 3"]
        
        M -->|"manages"| W
        W -->|"manages"| D1
        W -->|"manages"| D2
        W -->|"manages"| D3
    end
    
    subgraph TeamRelations["Team Relationships"]
        T1["👥 Peer 1"]
        T2["👥 Peer 2"]
        T3["👥 Peer 3"]
    end
    
    subgraph MatrixRelations["Matrix Relationships"]
        PM["📊 Project Manager"]
        MT["🎓 Mentor"]
        MB["🤝 Mentee"]
    end
    
    subgraph ExternalRelations["Extended Network"]
        HR["🏢 HR Partner"]
        FIN["💰 Finance Contact"]
        IT["💻 IT Support"]
    end
    
    W --- T1
    W --- T2
    W --- T3
    W -.->|"project"| PM
    W -.->|"mentored by"| MT
    W -.->|"mentors"| MB
    W -.-|"supported by"| HR
    W -.-|"supported by"| FIN
    W -.-|"supported by"| IT
```

---

## 5. UX Design Principles

### 5.1 Core UX Philosophy

```mermaid
mindmap
  root((UX Principles))
    Progressive Disclosure
      Show summary first
      Expand on demand
      Layer information
      Reduce cognitive load
    
    Contextual Relevance
      Role-based content
      WR-type adaptive
      Situational actions
      Smart defaults
    
    Visual Hierarchy
      Clear focal points
      Consistent patterns
      Scannable layout
      Meaningful grouping
    
    Connected Experience
      Seamless navigation
      Cross-reference links
      Relationship awareness
      Unified data view
    
    Actionable Insights
      Quick actions visible
      In-context operations
      Workflow integration
      Decision support
```

### 5.2 Information Architecture

```mermaid
flowchart TB
    subgraph L1["Level 1: Profile Header (Always Visible)"]
        H1["Photo + Name + Current Role"]
        H2["Quick Status Indicators"]
        H3["Primary Actions"]
        H4["WR Switcher (if multiple)"]
    end
    
    subgraph L2["Level 2: Summary Cards"]
        S1["Worker<br/>Summary"]
        S2["Current WR<br/>Summary"]
        S3["Assignment<br/>Summary"]
        S4["Quick Stats"]
    end
    
    subgraph L3["Level 3: Detail Sections"]
        D1["Personal<br/>Information"]
        D2["Working<br/>Relationships"]
        D3["Assignment<br/>Details"]
        D4["Performance<br/>& Goals"]
    end
    
    subgraph L4["Level 4: Related Entities"]
        R1["Documents"]
        R2["Transactions"]
        R3["History"]
        R4["Related People"]
    end
    
    L1 --> L2
    L2 --> L3
    L3 --> L4
```

### 5.3 Responsive Layout Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│  DESKTOP LAYOUT (1440px+)                                           │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    PROFILE HEADER                            │    │
│  │  [WR Switcher: Employment @ ABC VN ▼]                       │    │
│  └─────────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────┐ ┌───────────────────────────────┐  │
│  │                             │ │                               │  │
│  │      MAIN CONTENT           │ │     SIDE PANEL                │  │
│  │      (Scrollable)           │ │     - Quick Info              │  │
│  │      - Worker Summary       │ │     - Actions                 │  │
│  │      - WR Details           │ │     - Related People          │  │
│  │      - Assignment Details   │ │     - Activity Feed           │  │
│  │                             │ │                               │  │
│  └─────────────────────────────┘ └───────────────────────────────┘  │
│         ~70% width                      ~30% width                   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────┐
│  TABLET LAYOUT (768-1439px)     │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │  PROFILE HEADER + WR ▼    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │     TAB NAVIGATION        │  │
│  │  [Worker][WR][Assignment] │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │     TAB CONTENT           │  │
│  │     (Full width)          │  │
│  │                           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘

┌─────────────────────┐
│  MOBILE (< 768px)   │
├─────────────────────┤
│  ┌───────────────┐  │
│  │ Compact Header│  │
│  │ [WR: ABC VN ▼]│  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Swipeable     │  │
│  │ Summary Cards │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ Accordion     │  │
│  │ Sections      │  │
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ [FAB Actions] │  │
│  └───────────────┘  │
└─────────────────────┘
```

---

## 6. Feature Design

### 6.1 Profile Header

**Purpose**: Instant recognition và primary information at a glance

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ← Back to Search                                          [⋯] Actions   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌────────┐   NGUYỄN VĂN A                          ┌────────────────┐  │
│   │        │   Worker ID: W-001                       │  ✅ Active     │  │
│   │  📷    │                                          │  📍 Ho Chi Minh│  │
│   │        │   📧 nguyen.a@gmail.com (Personal)       │  🎂 34 years   │  │
│   │        │   📱 0912-345-678                        │                │  │
│   └────────┘                                          └────────────────┘  │
│                                                                          │
│   ┌──────────────────────────────────────────────────────────────────┐   │
│   │ 📋 CURRENT WORKING RELATIONSHIP                              [▼] │   │
│   │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │   │
│   │ 🏢 ABC Corporation Vietnam          Type: Employment (Full-time) │   │
│   │ 👔 Senior Software Engineer         Since: Jan 2020 (5yr 0mo)    │   │
│   │ 🏛️ Engineering Department           Manager: Trần Văn B          │   │
│   └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   Skills: Python ● AWS ● React ● System Design ● +5 more                │
│                                                                          │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│   │ 📧 Message   │ │ 📅 Schedule  │ │ 📊 Org Chart │ │ ⚡ Actions ▼ │   │
│   └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

**Header Components:**

| Component | Content | Purpose |
|-----------|---------|---------|
| **Photo** | Profile picture với fallback initials | Visual recognition |
| **Worker Name** | Full name (primary identity) | Primary identification |
| **Worker ID** | System identifier | Reference |
| **Personal Contact** | Personal email, phone | Direct contact |
| **Status Badge** | Active/Inactive across all WRs | Overall state |
| **WR Summary** | Current/Primary working relationship | Context |
| **Current Role** | Job title from current WR | Professional identity |
| **Tenure** | Duration với current LE | Context |
| **Skills Tags** | Top skills (worker-level) | Quick expertise view |
| **Quick Actions** | Context-sensitive action buttons | Primary operations |

### 6.2 Working Relationship Switcher

**Purpose**: Navigate between multiple working relationships

```
┌──────────────────────────────────────────────────────────────────────────┐
│  📋 WORKING RELATIONSHIPS                                         [▼]   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │ ✓ SELECTED (Primary)                                               │  │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │  │
│  │ 🏢 ABC Corporation Vietnam                                         │  │
│  │ Type: Employment (Full-time)                                       │  │
│  │ Role: Senior Software Engineer                                     │  │
│  │ Since: Jan 15, 2020                Status: ✅ Active               │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │ 🏢 ABC Corporation Singapore                                       │  │
│  │ Type: Employment (Secondment)                                      │  │
│  │ Role: Tech Lead - Regional                                         │  │
│  │ Period: Jul 2024 - Jun 2025        Status: ✅ Active               │  │
│  │                                                          [View →]  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │ 🏢 XYZ Consulting                                        HISTORY   │  │
│  │ Type: Contract (Consultant)                                        │  │
│  │ Role: Technical Consultant                                         │  │
│  │ Period: Mar 2023 - Jun 2023        Status: ⏹️ Completed            │  │
│  │                                                          [View →]  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Summary Dashboard

**Purpose**: Holistic view of key information across all layers

```
┌──────────────────────────────────────────────────────────────────────────┐
│  SUMMARY DASHBOARD                                                        │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────┐  ┌─────────────────────────────┐       │
│  │ 👤 WORKER PROFILE           │  │ 📋 CURRENT WR               │       │
│  │ ─────────────────────────── │  │ ─────────────────────────── │       │
│  │ Name: Nguyễn Văn A          │  │ Legal Entity: ABC Corp VN   │       │
│  │ DOB: Mar 15, 1990 (34y)     │  │ Type: Employment            │       │
│  │ Nationality: Vietnamese     │  │ Contract: Indefinite        │       │
│  │ Skills: 12 verified         │  │ Location: HCM Office        │       │
│  │ Certifications: 5           │  │ Since: Jan 2020 (5yr)       │       │
│  │                             │  │ Status: Active ✅            │       │
│  │ [View Personal Info →]      │  │ [View WR Details →]         │       │
│  └─────────────────────────────┘  └─────────────────────────────┘       │
│                                                                          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  📊 ASSIGNMENT DETAILS (Employee @ ABC Corp VN)                          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                          │
│  ┌─────────────────────────────┐  ┌─────────────────────────────┐       │
│  │ 🏢 ORGANIZATION             │  │ 🕐 TIME & ATTENDANCE        │       │
│  │ ─────────────────────────── │  │ ─────────────────────────── │       │
│  │ Position: Senior Eng        │  │ This Month                  │       │
│  │ Department: Engineering     │  │ ━━━━━━━━━━━━━━━ 85%         │       │
│  │ Grade: L5                   │  │ 17/20 working days          │       │
│  │ Manager: Trần Văn B         │  │                             │       │
│  │ Reports: 8 people           │  │ Leave Balance               │       │
│  │                             │  │ Annual: 12 days             │       │
│  │ [View Org Chart →]          │  │ [View Timesheet →]          │       │
│  └─────────────────────────────┘  └─────────────────────────────┘       │
│                                                                          │
│  ┌─────────────────────────────┐  ┌─────────────────────────────┐       │
│  │ 💰 COMPENSATION             │  │ 🎯 PERFORMANCE              │       │
│  │ ─────────────────────────── │  │ ─────────────────────────── │       │
│  │ Annual Package              │  │ Current Rating              │       │
│  │ Base: ██████████░ 70%       │  │ ★★★★★ Exceeds               │       │
│  │ Variable: ████░░░ 20%       │  │                             │       │
│  │ Benefits: ██░░░░░ 10%       │  │ Goals Progress              │       │
│  │                             │  │ ━━━━━━━━━━━━━━━ 75%         │       │
│  │ Next Review: Mar 2026       │  │ 3/4 goals on track          │       │
│  │ [View Details →]            │  │ [View Performance →]        │       │
│  └─────────────────────────────┘  └─────────────────────────────┘       │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.4 Detail Sections

#### Section: Worker Information (Shared across all WRs)

```
┌──────────────────────────────────────────────────────────────────────────┐
│  👤 WORKER INFORMATION                                            [Edit] │
│  ℹ️ This information is shared across all working relationships          │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─ PERSONAL IDENTITY ──────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Full Name (VI):    Nguyễn Văn A                                 │   │
│  │  Full Name (EN):    Nguyen Van A                                 │   │
│  │  Preferred Name:    A                                            │   │
│  │  Date of Birth:     15 March 1990 (34 years old)                 │   │
│  │  Gender:            Male                                         │   │
│  │  Nationality:       Vietnamese                                   │   │
│  │  Marital Status:    Married                                      │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ IDENTITY DOCUMENTS ─────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  CCCD/National ID:  079190xxxxxx    Issued: 2021  [View Doc]     │   │
│  │  Tax ID:            8xxxxxxxxx                                   │   │
│  │  Social Insurance:  79xxxxxxxx                                   │   │
│  │  Passport:          Cxxxxxx          Expires: 2030  [View Doc]   │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ CONTACT INFORMATION ────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Personal Email:    nguyenvana90@gmail.com                       │   │
│  │  Mobile Phone:      +84 912 345 678               [📱 Call]      │   │
│  │                                                                   │   │
│  │  Permanent Address: 456 Le Loi, District 3, HCMC                 │   │
│  │  Current Address:   123 Nguyen Hue, District 1, HCMC             │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ EMERGENCY CONTACTS ─────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Primary:   Nguyễn Thị B (Spouse)    +84 909 xxx xxx             │   │
│  │  Secondary: Nguyễn Văn C (Brother)   +84 908 xxx xxx             │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ SKILLS & QUALIFICATIONS ────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Technical Skills:                                               │   │
│  │  Python ████████░░ Expert    AWS ███████░░░ Advanced             │   │
│  │  React  ██████░░░░ Advanced  K8s █████░░░░░ Intermediate         │   │
│  │                                                                   │   │
│  │  Certifications:                                                 │   │
│  │  🎓 AWS Solutions Architect Professional (2023)                  │   │
│  │  🎓 Kubernetes Administrator (CKA) (2022)                        │   │
│  │  🎓 PMP - Project Management Professional (2021)                 │   │
│  │                                                                   │   │
│  │  Languages:                                                      │   │
│  │  Vietnamese (Native) • English (Fluent) • Japanese (Basic)       │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

#### Section: Working Relationship Details

```
┌──────────────────────────────────────────────────────────────────────────┐
│  📋 WORKING RELATIONSHIP DETAILS                                  [Edit] │
│  🏢 ABC Corporation Vietnam                                              │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─ RELATIONSHIP INFORMATION ───────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Legal Entity:      ABC Corporation Vietnam                      │   │
│  │  LE Code:           ABC-VN                                       │   │
│  │  Country:           Vietnam                                      │   │
│  │                                                                   │   │
│  │  Relationship Type: Employment                                   │   │
│  │  Employment Type:   Full-time, Indefinite                        │   │
│  │  Status:            Active ✅                                     │   │
│  │                                                                   │   │
│  │  Start Date:        January 15, 2020                             │   │
│  │  Tenure:            4 years 11 months                            │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ CONTRACT TERMS ─────────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Contract Type:     Indefinite Term                              │   │
│  │  Probation:         Completed (Apr 15, 2020) ✓                   │   │
│  │  Notice Period:     30 days                                      │   │
│  │  Work Location:     HCM Office - 123 Nguyen Hue, D1              │   │
│  │  Work Schedule:     Standard (Mon-Fri, 8:30-17:30)               │   │
│  │                                                                   │   │
│  │  Contract Document: [📄 View Current Contract]                   │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ WORK EMAIL & SYSTEMS ───────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Work Email:        nguyen.a@abccorp.com.vn      [📧 Send]       │   │
│  │  Work Phone:        +84 28 xxxx xxxx ext 1234                    │   │
│  │  Employee Portal:   Active                                       │   │
│  │  SSO Accounts:      Google Workspace, Slack, Jira                │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

#### Section: Employee Assignment Details

```
┌──────────────────────────────────────────────────────────────────────────┐
│  👔 EMPLOYEE ASSIGNMENT                                           [Edit] │
│  Employee ID: EMP-VN-001 @ ABC Corporation Vietnam                       │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─ POSITION & JOB ─────────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Employee Number:   EMP-VN-001                                   │   │
│  │  Job Title:         Senior Software Engineer                     │   │
│  │  Job Family:        Engineering > Software Development           │   │
│  │  Job Level:         L5 (Senior Individual Contributor)           │   │
│  │  Position ID:       POS-ENG-042                                  │   │
│  │                                                                   │   │
│  │  Effective Date:    June 1, 2022 (Promoted)                      │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ ORGANIZATION ───────────────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Department:        Engineering                                  │   │
│  │  Division:          Technology                                   │   │
│  │  Team:              Platform Team                                │   │
│  │  Cost Center:       CC-ENG-001                                   │   │
│  │  Work Location:     HCM Office                                   │   │
│  │                                                                   │   │
│  │  [View Organization Chart →]                                     │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│  ┌─ REPORTING RELATIONSHIPS ────────────────────────────────────────┐   │
│  │                                                                   │   │
│  │  Direct Manager:    👔 Trần Văn B (Engineering Manager)          │   │
│  │  Skip-Level:        👔 Lê Văn C (Director of Engineering)        │   │
│  │                                                                   │   │
│  │  Direct Reports (8):                                             │   │
│  │  👤 Ngô Văn D (Software Engineer)                                │   │
│  │  👤 Đinh Thị E (Software Engineer)                               │   │
│  │  👤 Vũ Văn F (Junior Engineer)                                   │   │
│  │  ... +5 more                           [View All Reports →]      │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.5 Working Relationship Timeline

**Purpose**: Visual representation of all working relationships over time

```
┌──────────────────────────────────────────────────────────────────────────┐
│  📅 WORKING RELATIONSHIP TIMELINE                                        │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  2020 ────── 2021 ────── 2022 ────── 2023 ────── 2024 ────── 2025 ──▶   │
│                                                                          │
│  ABC Corp Vietnam (Employment)                                           │
│  ██████████████████████████████████████████████████████████████████▶    │
│  │ Junior Eng │    Senior Engineer    │   Tech Lead (current)   │       │
│  └─────┬──────┴──────────┬────────────┴────────────┬────────────┘       │
│        │                 │                          │                    │
│        ●                 ●                          ●                    │
│     Hired            Promoted                  Promoted                  │
│     Jan 2020         Jun 2022                  Jul 2024                  │
│                                                                          │
│  ABC Corp Singapore (Employment - Secondment)                            │
│                                            ████████████░░░░░             │
│                                            │ Tech Lead Regional │        │
│                                            └────────┬───────────┘        │
│                                                     │                    │
│                                                     ●                    │
│                                                  Secondment              │
│                                                  Jul 2024                │
│                                                                          │
│  XYZ Consulting (Contract)                                               │
│                          ████░                                           │
│                          │ Tech Consultant │                             │
│                          └────────┬────────┘                             │
│                                   │                                      │
│                                 ● ●                                      │
│                          Contract Start/End                              │
│                          Mar - Jun 2023                                  │
│                                                                          │
│  Legend: ██ Active  ░░ Future  ● Event                                  │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 6.6 Organization View

```mermaid
flowchart TB
    subgraph OrgView["Organization View - Nguyễn Văn A @ ABC Corp VN"]
        direction TB
        
        subgraph UpLine["Upward Line"]
            CEO["CEO<br/>Lê Văn X"]
            VP["VP Engineering<br/>Phạm Thị Y"]
            DIR["Director<br/>Hoàng Văn Z"]
            MGR["Manager<br/>Trần Văn B"]
        end
        
        EMP["👤 Nguyễn Văn A<br/>Senior Engineer<br/>YOU ARE HERE"]
        
        subgraph DownLine["Direct Reports (8)"]
            DR1["Ngô A<br/>Engineer"]
            DR2["Đinh B<br/>Engineer"]
            DR3["Vũ C<br/>Jr Engineer"]
            DR4["...+5 more"]
        end
        
        subgraph Peers["Peers (4)"]
            P1["Peer 1<br/>Sr Engineer"]
            P2["Peer 2<br/>Sr Engineer"]
            P3["Peer 3<br/>Sr Engineer"]
        end
        
        CEO --> VP --> DIR --> MGR --> EMP
        EMP --> DR1
        EMP --> DR2
        EMP --> DR3
        EMP --> DR4
        
        MGR --> P1
        MGR --> P2
        MGR --> P3
    end
    
    style EMP fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
```

---

## 7. View Modes by WR Type

### 7.1 View Adaptation by Working Relationship Type

```mermaid
flowchart TB
    subgraph WRType["Working Relationship Type"]
        T1["Employment"]
        T2["Contract"]
        T3["Contingent"]
        T4["Internship"]
    end
    
    subgraph Content["Content Shown"]
        C1["Full Employee View<br/>+ Position & Org<br/>+ Compensation & Benefits<br/>+ Performance & Goals<br/>+ Time & Attendance"]
        
        C2["Contractor View<br/>+ Project Assignment<br/>+ Rate & Billing<br/>+ Deliverables<br/>+ Vendor Info"]
        
        C3["Contingent View<br/>+ Agency Details<br/>+ Assignment Terms<br/>+ Billing Info<br/>+ Limited Org Access"]
        
        C4["Intern View<br/>+ Program Details<br/>+ Mentor Assignment<br/>+ Learning Goals<br/>+ Evaluation"]
    end
    
    T1 --> C1
    T2 --> C2
    T3 --> C3
    T4 --> C4
```

### 7.2 Contractor View Example

```
┌──────────────────────────────────────────────────────────────────────────┐
│  👤 JOHN DOE                                                             │
│  Contractor @ ABC Corporation                                            │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─ WORKER INFO ────────────┐  ┌─ CONTRACT DETAILS ─────────────────┐   │
│  │ Personal details...      │  │ Vendor: XYZ Consulting              │   │
│  │ Skills...                │  │ Type: Independent Contractor        │   │
│  │ Contact...               │  │ Period: Jan 2025 - Jun 2025         │   │
│  └──────────────────────────┘  │ Status: Active ✅                    │   │
│                                └─────────────────────────────────────┘   │
│                                                                          │
│  ┌─ PROJECT ASSIGNMENT ────────────────────────────────────────────┐    │
│  │ Project: Platform Modernization                                  │    │
│  │ Role: Technical Architect                                       │    │
│  │ Project Manager: 👤 Trần B                                       │    │
│  │ Start: Jan 15, 2025                                             │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─ RATE & BILLING ────────────────────────────────────────────────┐    │
│  │ Daily Rate: $XXX/day                                            │    │
│  │ This Month: 15 days worked = $X,XXX                             │    │
│  │ YTD Billing: $XX,XXX                                            │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─ DELIVERABLES ──────────────────────────────────────────────────┐    │
│  │ ✅ Architecture Document (Completed)                             │    │
│  │ 🔄 API Design (In Progress - 60%)                                │    │
│  │ ⏳ Implementation Guide (Pending)                                │    │
│  └──────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Role-Based View Permissions

```mermaid
flowchart TB
    subgraph Viewer["Who is Viewing?"]
        V1["👤 Self<br/>(Worker viewing own profile)"]
        V2["👥 Peer<br/>(Colleague viewing)"]
        V3["👔 Manager<br/>(Direct/Skip manager viewing)"]
        V4["🏢 HR<br/>(HR Admin viewing)"]
        V5["👑 Executive<br/>(Leadership viewing)"]
    end
    
    subgraph Content["Content Shown"]
        C1["Full personal access<br/>All WRs visible<br/>All actions available"]
        C2["Public profile only<br/>Current WR summary<br/>Contact info & Skills"]
        C3["Team context<br/>Relevant WR details<br/>Management actions"]
        C4["Full HR access<br/>All WRs & history<br/>All actions available"]
        C5["Strategic view<br/>Aggregated insights<br/>Succession info"]
    end
    
    V1 --> C1
    V2 --> C2
    V3 --> C3
    V4 --> C4
    V5 --> C5
```

### 7.4 Content Visibility Matrix

| Data Category | Self | Peer | Manager | HR Admin | Executive |
|--------------|------|------|---------|----------|-----------|
| **Worker: Basic Info** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Worker: Personal Details** | ✅ | ❌ | ⚠️ | ✅ | ❌ |
| **Worker: Documents** | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Worker: Skills** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **WR: Summary** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **WR: Contract Terms** | ✅ | ❌ | ⚠️ | ✅ | ⚠️ |
| **WR: All Relationships** | ✅ | ❌ | ❌ | ✅ | ⚠️ |
| **Employee: Position** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Employee: Compensation** | ✅ | ❌ | ❌ | ✅ | ⚠️ |
| **Employee: Benefits** | ✅ | ❌ | ❌ | ✅ | ❌ |
| **Employee: Performance** | ✅ | ❌ | ✅ Team | ✅ | ✅ |
| **Contractor: Rate** | ✅ | ❌ | ⚠️ | ✅ | ⚠️ |

Legend: ✅ Full access | ⚠️ Partial/Contextual | ❌ No access

---

## 8. Quick Actions Framework

### 8.1 Actions by Context

```mermaid
mindmap
  root((Quick Actions))
    Worker Actions
      Update Personal Info
      Update Skills
      Upload Documents
      Update Contact
    
    WR Actions
      View Contract
      Request WR Change
      View History
    
    Employee Actions
      Request Leave
      View Payslip
      Update Timesheet
      Set Goals
      View Benefits
    
    Contractor Actions
      Log Time
      Submit Deliverable
      View SOW
      Submit Invoice
    
    Manager Actions
      Give Feedback
      Approve Requests
      Set Goals
      Request Transfer
      Performance Review
    
    HR Actions
      Edit Profile
      Process Job Change
      Compensation Change
      Terminate WR
      Create New WR
```

### 8.2 Contextual Action Display

```mermaid
flowchart TB
    subgraph Context["Context Factors"]
        C1["Viewer Role"]
        C2["WR Type"]
        C3["WR Status"]
        C4["Pending Items"]
    end
    
    subgraph Logic["Action Selection"]
        L1["Filter by viewer permissions"]
        L2["Filter by WR type"]
        L3["Prioritize by urgency"]
        L4["Show relevant actions"]
    end
    
    subgraph Actions["Displayed Actions"]
        A1["Primary (2-3 buttons)"]
        A2["Secondary (dropdown)"]
        A3["Disabled with reason"]
    end
    
    Context --> Logic --> Actions
```

---

## 9. Data Scope Clarity

### 9.1 Visual Indicators for Data Scope

```
┌──────────────────────────────────────────────────────────────────────────┐
│  DATA SCOPE INDICATORS                                                   │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ 👤 WORKER-LEVEL DATA                                            │    │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │    │
│  │ ℹ️ Shared across ALL working relationships                       │    │
│  │                                                                  │    │
│  │ • Personal Information                                          │    │
│  │ • Contact Details                                               │    │
│  │ • Skills & Certifications                                       │    │
│  │ • Education History                                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ 📋 WR-SPECIFIC DATA                    [ABC Corp Vietnam]       │    │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │    │
│  │ ℹ️ Specific to this working relationship only                    │    │
│  │                                                                  │    │
│  │ • Contract Terms                                                │    │
│  │ • Work Email & Systems                                          │    │
│  │ • Position & Organization                                       │    │
│  │ • Compensation & Benefits                                       │    │
│  │ • Time & Attendance                                             │    │
│  │ • Performance & Goals                                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Cross-WR Data Aggregation

```
┌──────────────────────────────────────────────────────────────────────────┐
│  📊 AGGREGATED VIEW (All Working Relationships)                          │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Total Tenure with Organization: 5 years                                 │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │ RELATIONSHIP         │ LE              │ TYPE       │ TENURE    │    │
│  │─────────────────────────────────────────────────────────────────│    │
│  │ Employment (Active)  │ ABC Corp VN     │ Full-time  │ 5yr 0mo   │    │
│  │ Employment (Active)  │ ABC Corp SG     │ Secondment │ 0yr 6mo   │    │
│  │ Contract (Completed) │ XYZ Consulting  │ Consultant │ 0yr 4mo   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  Combined Statistics:                                                    │
│  • Total Active WRs: 2                                                  │
│  • Historical WRs: 1                                                    │
│  • Total Compensation (visible to HR): Combined view available          │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 10. Mobile Experience

### 10.1 Mobile Layout with WR Switcher

```
┌─────────────────────────┐
│ ← Worker 360       ⋮    │
├─────────────────────────┤
│  ┌─────────────────┐    │
│  │    📷          │    │
│  │ Nguyễn Văn A   │    │
│  │ Worker: W-001  │    │
│  │ ✅ Active       │    │
│  └─────────────────┘    │
│                         │
│  📧 Email  📱 Call      │
│  📅 Meet   💬 Message   │
│                         │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 📋 ABC Corp VN   ▼  │ │
│ │ Employee • 5yr      │ │
│ └─────────────────────┘ │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │Worker│ WR │Assignment│ │
│ └─────────────────────┘ │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ 📋 Current WR     │  │
│  │ Sr Engineer       │  │
│  │ Engineering Dept  │  │
│  └───────────────────┘  │
│           ↕            │
│  ┌───────────────────┐  │
│  │ 🏢 Organization   │  │
│  │ Manager: Trần B   │  │
│  │ Reports: 8        │  │
│  └───────────────────┘  │
│                         │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │    [⚡ Actions]    │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

### 10.2 Mobile-Specific Features

| Feature | Mobile Adaptation |
|---------|-------------------|
| **Header** | Compact với WR switcher dropdown |
| **WR Navigation** | Swipe hoặc dropdown to switch |
| **Cards** | Swipeable carousel cho summaries |
| **Actions** | Floating action button (FAB) |
| **Navigation** | Bottom tabs: Worker / WR / Assignment |
| **Details** | Full-screen modal khi expand |

---

## 11. Feature Rollout Plan

### 11.1 Phase Overview

```mermaid
gantt
    title Worker 360 Feature Rollout
    dateFormat YYYY-Q
    
    section Phase 1 - Foundation
    Worker Profile Header        :p1a, 2025-Q1, 1q
    Basic Worker Info Sections   :p1b, 2025-Q1, 1q
    Single WR Support            :p1c, 2025-Q1, 1q
    Employee Assignment View     :p1d, 2025-Q1, 1q
    
    section Phase 2 - Multi-WR
    WR Switcher                  :p2a, 2025-Q2, 1q
    Multi-WR Support             :p2b, 2025-Q2, 1q
    WR Timeline                  :p2c, 2025-Q2, 1q
    Contractor View              :p2d, 2025-Q2, 1q
    
    section Phase 3 - Advanced
    Organization View            :p3a, 2025-Q3, 1q
    Data Visualizations          :p3b, 2025-Q3, 1q
    Quick Actions Framework      :p3c, 2025-Q3, 1q
    Role-based Views             :p3d, 2025-Q3, 1q
    
    section Phase 4 - Enhancement
    Mobile Optimization          :p4a, 2025-Q4, 1q
    AI Insights                  :p4b, 2025-Q4, 1q
    Cross-WR Analytics           :p4c, 2025-Q4, 1q
```

### 11.2 Phase Details

#### Phase 1: Foundation (Q1 2025)

| Feature | Description | Priority |
|---------|-------------|----------|
| Worker Profile Header | Photo, name, status, contact | P0 |
| Worker Info Section | Personal, contact, emergency | P0 |
| Single WR Display | Basic WR information | P0 |
| Employee View | Position, org, manager | P0 |
| Basic Navigation | Sections, back nav | P0 |

#### Phase 2: Multi-WR Support (Q2 2025)

| Feature | Description | Priority |
|---------|-------------|----------|
| WR Switcher | Navigate between WRs | P1 |
| Multi-WR Timeline | Visual WR history | P1 |
| Contractor View | Contractor-specific content | P1 |
| Contingent View | Contingent worker content | P1 |
| Data Scope Indicators | Clear scope labeling | P1 |

#### Phase 3: Advanced Features (Q3 2025)

| Feature | Description | Priority |
|---------|-------------|----------|
| Organization Chart | Interactive org view | P2 |
| Skills Visualization | Radar/graph for skills | P2 |
| Quick Actions | Context-sensitive actions | P2 |
| Role Permissions | View adaptation by role | P2 |
| Performance Charts | Trend visualizations | P2 |

#### Phase 4: Enhancement (Q4 2025)

| Feature | Description | Priority |
|---------|-------------|----------|
| Mobile Optimization | Responsive, native-feel | P2 |
| AI Insights | Smart suggestions | P3 |
| Cross-WR Analytics | Aggregated views | P3 |
| Customizable Layout | User preferences | P3 |

---

## 12. Success Metrics

### 12.1 Key Performance Indicators

```mermaid
flowchart TB
    subgraph KPIs["Success Metrics"]
        direction TB
        
        subgraph Performance["⚡ Performance"]
            K1["Page load < 2s"]
            K2["WR switch < 500ms"]
        end
        
        subgraph Usability["✅ Usability"]
            K3["Info found < 10s"]
            K4["< 3 clicks to any data"]
        end
        
        subgraph Adoption["📈 Adoption"]
            K5["Daily views: 500+"]
            K6["WR switcher usage: 40%"]
        end
        
        subgraph Satisfaction["😊 Satisfaction"]
            K7["User satisfaction > 85%"]
            K8["NPS > 50"]
        end
    end
```

---

## 13. Open Questions

### 13.1 Key Decisions Needed

```mermaid
mindmap
  root((Discussion Points))
    Data Model
      WR type naming conventions?
      Default WR selection logic?
      Historical WR retention?
    
    UX Design
      Single page vs tabbed for WRs?
      WR switcher always visible?
      Mobile WR navigation pattern?
    
    Permissions
      Cross-WR data visibility?
      Manager view across WRs?
      Contractor data access?
    
    Features
      Aggregated cross-WR views?
      WR comparison feature?
      AI insights priority?
```

### 13.2 Questions for Discussion

1. **WR Selection**: Khi Worker có multiple active WRs, default hiển thị WR nào?

2. **Cross-WR View**: Có cần view aggregated data across all WRs không?

3. **Contractor Visibility**: Manager có thể view contractor details ở mức nào?

4. **Historical WRs**: Completed WRs hiển thị bao lâu? Có archive không?

5. **WR Transitions**: Khi Worker chuyển từ Contractor → Employee, flow như thế nào?

6. **Mobile Priority**: WR switcher trên mobile nên là dropdown hay tab?

---

## 14. Appendix

### A. Glossary

| Term | Definition |
|------|------------|
| **Worker** | Người lao động thực sự (Person), identity duy nhất trong hệ thống |
| **Working Relationship (WR)** | Entity kết nối Worker với Legal Entity, định nghĩa engagement type |
| **Employee** | Assignment record được tạo từ WR type Employment |
| **Contractor** | Assignment record được tạo từ WR type Contract |
| **Contingent Worker** | Assignment record được tạo từ WR type Contingent |
| **Legal Entity (LE)** | Pháp nhân tuyển dụng/engage worker |
| **Assignment** | Role-specific record (Employee, Contractor, etc.) |
| **Worker 360** | Comprehensive view of all worker-related data |

### B. Data Model Summary

```
Worker (1) ──────┬──────> Working Relationship (N) ──────> Legal Entity (1)
                 │                    │
                 │                    ├──> Employee (0..1)
                 │                    ├──> Contractor (0..1)
                 │                    └──> Contingent Worker (0..1)
                 │
                 └──> Skills, Documents, Education (shared)
```

---

*Document Status: Draft for Review*  
*Version: 1.1 - Updated Data Model (Worker → Working Relationship → Assignment)*  
*Next Review: [TBD with Product & UX Team]*