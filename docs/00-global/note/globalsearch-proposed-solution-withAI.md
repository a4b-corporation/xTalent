# xTalent HCM - Global Search
## Proposed Solution Document

**Version**: 1.1  
**Date**: December 2025  
**Audience**: Product Team, Stakeholders, Business Analysts

---

## 1. Vision & Objectives

### 1.1 Vision Statement

> **"Tìm bất kỳ thứ gì trong xTalent chỉ với một thanh search duy nhất - bằng ngôn ngữ tự nhiên"**

Global Search sẽ là điểm truy cập trung tâm giúp người dùng nhanh chóng tìm kiếm nhân viên, navigate đến các tính năng, và thực hiện các quick actions - tất cả từ một giao diện thống nhất. Hệ thống hiểu được ý định của người dùng, không chỉ match keywords.

### 1.2 Core Objectives

| Objective | Success Metric |
|-----------|----------------|
| **Speed** | Autocomplete < 100ms |
| **Accuracy** | >95% relevant results trong top 5 |
| **Understanding** | >85% intent detection accuracy |
| **Adoption** | 70% users sử dụng search thay vì menu navigation sau 3 tháng |
| **Discoverability** | Users khám phá được 30% features mới qua search |

### 1.3 Target Users

```mermaid
mindmap
  root((Global Search Users))
    Employee
      Tìm đồng nghiệp
      Self-service actions
      Company directory
      Natural language queries
    Manager
      Tìm team members
      Team management
      Approval workflows
      "Who in my team..."
    HR Admin
      Employee lookup
      HR operations
      Reports & Analytics
      Complex queries
    Executive
      Organization overview
      Strategic reports
      Workforce analytics
      Conversational insights
```

---

## 2. Product Concept

### 2.1 Unified Search Bar

Một thanh search duy nhất xuất hiện ở header của ứng dụng, có thể truy cập từ mọi màn hình.

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  Search or ask anything...                       ⌘K    🤖   │
└─────────────────────────────────────────────────────────────────┘
```

**Đặc điểm chính:**
- Luôn visible ở top navigation
- Keyboard shortcut: `Cmd/Ctrl + K`
- AI indicator khi hệ thống đang "hiểu" query
- Hỗ trợ cả keyword search và natural language

### 2.2 Search Paradigms

```mermaid
flowchart TB
    subgraph Input["User Input"]
        Q[Search Query]
    end
    
    subgraph Paradigms["Three Search Paradigms"]
        direction LR
        
        subgraph Keyword["🔤 Keyword Search"]
            K1["Exact matching"]
            K2["Fuzzy matching"]
            K3["Prefix search"]
        end
        
        subgraph Structured["📝 Structured Query"]
            S1["xTQL syntax"]
            S2["Filters & operators"]
            S3["Saved queries"]
        end
        
        subgraph Semantic["🧠 Semantic Search"]
            AI1["Intent detection"]
            AI2["Natural language"]
            AI3["Contextual understanding"]
        end
    end
    
    Q --> Keyword
    Q --> Structured
    Q --> Semantic
    
    style Keyword fill:#e3f2fd
    style Structured fill:#fff3e0
    style Semantic fill:#e8f5e9
```

### 2.3 Hai Đối Tượng Search Chính

```mermaid
flowchart TB
    subgraph GlobalSearch["🔍 Global Search"]
        direction TB
        SearchBar[Search Input]
    end
    
    subgraph Objects["Search Objects"]
        direction LR
        
        subgraph People["👤 People Search"]
            P1[Tìm theo tên]
            P2[Tìm theo department]
            P3[Tìm theo skill]
            P4[Tìm theo role]
            P5["Semantic: 'ai biết Python'"]
        end
        
        subgraph Navigation["📁 Navigation Search"]
            N1[Menu items]
            N2[Quick actions]
            N3[Recent pages]
            N4["Semantic: 'muốn xin nghỉ phép'"]
        end
    end
    
    SearchBar --> People
    SearchBar --> Navigation
    
    style GlobalSearch fill:#e3f2fd
    style People fill:#e8f5e9
    style Navigation fill:#fff3e0
```

---

## 3. Search Modes & Interaction

### 3.1 Smart Prefix System

Hệ thống prefix cho phép user narrow search scope một cách nhanh chóng:

| Prefix | Scope | Ví dụ | Kết quả |
|--------|-------|-------|---------|
| `@` | People | `@nguyen` | Tìm nhân viên tên Nguyễn |
| `/` | Navigation | `/payroll` | Navigate đến Payroll menu |
| `>` | Actions | `>create` | Hiện các quick actions |
| `#` | Department/Team | `#engineering` | Filter theo department |
| `?` | Help | `?` | Hiện hướng dẫn sử dụng |
| *(none)* | **Smart/Semantic** | `ai biết Python trong team tôi` | AI phân tích và trả lời |

### 3.2 Search Flow với AI Processing

```mermaid
flowchart TB
    subgraph Input["User Input"]
        Query["Search Query"]
    end
    
    subgraph Detection["Query Analysis"]
        PD["Prefix Detection"]
        ID["Intent Detection AI"]
        LP["Language Processing"]
    end
    
    subgraph Processing["Search Processing"]
        direction TB
        KS["Keyword Search"]
        SS["Semantic Search"]
        QP["Query Parser xTQL"]
    end
    
    subgraph Results["Results"]
        Rank["AI Ranking"]
        Format["Response Formatting"]
    end
    
    Query --> PD
    Query --> ID
    Query --> LP
    
    PD -->|"Has prefix"| KS
    ID -->|"Clear intent"| SS
    LP -->|"Complex query"| QP
    ID -->|"Unclear"| KS
    ID -->|"Unclear"| SS
    
    KS --> Rank
    SS --> Rank
    QP --> Rank
    
    Rank --> Format
```

### 3.3 Search States với AI Feedback

```mermaid
stateDiagram-v2
    [*] --> Idle: Mở Search (⌘K)
    
    Idle --> ShowRecent: Không nhập gì
    
    Idle --> Processing: Nhập query
    Processing --> AIThinking: Complex/NL query detected
    Processing --> KeywordSearch: Simple query
    
    AIThinking --> SemanticResults: AI processed
    KeywordSearch --> KeywordResults: Direct match
    
    SemanticResults --> ShowAnswer: Single answer
    SemanticResults --> ShowList: Multiple results
    KeywordResults --> ShowList: Results found
    
    ShowAnswer --> [*]: Done
    ShowList --> SelectItem: User selects
    SelectItem --> [*]: Navigate/Action
```

---

## 4. AI & Semantic Search Features

### 4.1 Natural Language Processing Pipeline

```mermaid
flowchart LR
    subgraph Input["Input Processing"]
        Raw["Raw Query"]
        Norm["Normalization"]
        Token["Tokenization"]
    end
    
    subgraph NLP["NLP Analysis"]
        Lang["Language Detection<br/>VI/EN"]
        NER["Named Entity<br/>Recognition"]
        Intent["Intent<br/>Classification"]
        Slot["Slot Filling"]
    end
    
    subgraph Understanding["Query Understanding"]
        Parse["Semantic Parsing"]
        Resolve["Entity Resolution"]
        Context["Context Injection"]
    end
    
    subgraph Output["Search Execution"]
        Plan["Query Plan"]
        Execute["Execute Search"]
        Rank["AI Ranking"]
    end
    
    Raw --> Norm --> Token
    Token --> Lang --> NER --> Intent --> Slot
    Slot --> Parse --> Resolve --> Context
    Context --> Plan --> Execute --> Rank
```

### 4.2 Intent Detection Categories

Hệ thống nhận diện các loại intent chính:

```mermaid
mindmap
  root((User Intents))
    Find Person
      By name
      By attribute
      By relationship
      By skill/expertise
    Navigate
      To menu/page
      To specific feature
      To report
    Take Action
      Create something
      Submit request
      Approve/Reject
    Get Information
      About someone
      About policy
      Statistics/metrics
    Compare/Analyze
      Compare people
      Team composition
      Skill gaps
```

### 4.3 Intent Examples & Mapping

| User Query (Vietnamese) | Detected Intent | Extracted Entities | Action |
|------------------------|-----------------|-------------------|--------|
| "tìm Nguyễn Văn A" | `find_person` | name: "Nguyễn Văn A" | People search |
| "ai trong team tôi biết Python" | `find_person_by_skill` | skill: "Python", scope: "my_team" | Filtered search |
| "muốn xin nghỉ phép" | `take_action` | action: "leave_request" | Navigate to form |
| "sếp của Minh là ai" | `get_info_relationship` | person: "Minh", relation: "manager" | Show manager |
| "bao nhiêu người trong Engineering" | `get_statistics` | department: "Engineering", metric: "headcount" | Show count |
| "so sánh skill của team A và B" | `compare_analyze` | teams: ["A", "B"], aspect: "skills" | Show comparison |

### 4.4 Semantic Search vs Keyword Search

```mermaid
flowchart TB
    subgraph Query["Query: 'developer có kinh nghiệm cloud'"]
        Q1["User Input"]
    end
    
    subgraph Keyword["🔤 Keyword Search"]
        K1["Match: 'developer'"]
        K2["Match: 'cloud'"]
        K3["Match: 'kinh nghiệm'"]
        K4["Result: Exact matches only"]
    end
    
    subgraph Semantic["🧠 Semantic Search"]
        S1["Understand: Looking for person"]
        S2["Role: Developer/Engineer/Programmer"]
        S3["Skill: AWS/Azure/GCP/Cloud"]
        S4["Experience: Senior level"]
        S5["Result: Conceptually relevant"]
    end
    
    Q1 --> Keyword
    Q1 --> Semantic
    
    subgraph Results["Combined Results"]
        R1["✅ Exact: 'Cloud Developer'"]
        R2["✅ Semantic: 'AWS Engineer' with 5yr exp"]
        R3["✅ Semantic: 'DevOps' with Azure cert"]
    end
    
    Keyword --> R1
    Semantic --> R2
    Semantic --> R3
    
    style Keyword fill:#ffebee
    style Semantic fill:#e8f5e9
```

### 4.5 Vietnamese Language Understanding

```mermaid
flowchart TB
    subgraph Vietnamese["Vietnamese NLP Challenges"]
        V1["Diacritics<br/>nguyen = Nguyễn"]
        V2["Word Segmentation<br/>'nhân viên' = 1 word"]
        V3["Synonyms<br/>nghỉ phép = leave = PTO"]
        V4["Colloquial<br/>'sếp' = manager"]
        V5["Mixed Language<br/>'team' + 'nhóm'"]
    end
    
    subgraph Solution["Solutions"]
        S1["Diacritic normalization"]
        S2["Vietnamese tokenizer"]
        S3["Synonym dictionary"]
        S4["Colloquial mapping"]
        S5["Bilingual embeddings"]
    end
    
    V1 --> S1
    V2 --> S2
    V3 --> S3
    V4 --> S4
    V5 --> S5
```

**Vietnamese Query Understanding Examples:**

| Query | Understanding |
|-------|--------------|
| "nguyen van a" | → Matches "Nguyễn Văn A" (diacritic handling) |
| "xin nghi phep" | → Intent: Leave request (without diacritics) |
| "sep cua toi" | → "manager of currentUser()" |
| "team dev" | → "Engineering/Development department" |
| "ai ranh Python" | → "who has skill Python" (colloquial "rành") |

---

## 5. AI-Powered Features

### 5.1 Conversational Search

Cho phép user hỏi bằng ngôn ngữ tự nhiên và nhận câu trả lời trực tiếp:

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  bao nhiêu người trong team Engineering đang on leave?      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🤖 AI Answer                                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Hiện có 3 người trong Engineering đang nghỉ phép:         │ │
│  │                                                             │ │
│  │  👤 Nguyễn Văn A - Annual Leave (Dec 25-30)                │ │
│  │  👤 Trần Thị B - Sick Leave (Dec 28)                       │ │
│  │  👤 Lê Văn C - Personal Leave (Dec 27-29)                  │ │
│  │                                                             │ │
│  │  [View All Engineering Members] [View Leave Calendar]       │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  💬 Follow-up: "ai sẽ quay lại sớm nhất?"                       │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Question Types & AI Responses

```mermaid
flowchart TB
    subgraph Questions["Question Types"]
        Q1["❓ Factual<br/>'Ai là manager của Minh?'"]
        Q2["📊 Analytical<br/>'Bao nhiêu người mới trong Q4?'"]
        Q3["🔍 Discovery<br/>'Ai biết về Machine Learning?'"]
        Q4["📋 List<br/>'Team members của tôi'"]
        Q5["🧭 Navigation<br/>'Làm sao để xin nghỉ phép?'"]
    end
    
    subgraph Responses["AI Response Types"]
        R1["Direct Answer<br/>+ Source person card"]
        R2["Number + Breakdown<br/>+ Chart if applicable"]
        R3["Ranked list<br/>+ Skill match scores"]
        R4["People list<br/>+ Quick actions"]
        R5["Step-by-step guide<br/>+ Direct link"]
    end
    
    Q1 --> R1
    Q2 --> R2
    Q3 --> R3
    Q4 --> R4
    Q5 --> R5
```

### 5.3 Smart Suggestions & Auto-complete

AI gợi ý dựa trên context và intent:

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  ai trong team                                              │
├─────────────────────────────────────────────────────────────────┤
│  🤖 Suggested completions:                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  ai trong team tôi biết [skill]...                         │ │
│  │  ai trong team Engineering...                               │ │
│  │  ai trong team đang nghỉ phép...                           │ │
│  │  ai trong team mới join gần đây...                         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  💡 Based on: your role (Manager), recent searches              │
└─────────────────────────────────────────────────────────────────┘
```

### 5.4 Context-Aware Search

Hệ thống hiểu context của user để personalize kết quả:

```mermaid
flowchart LR
    subgraph Context["User Context"]
        C1["Role: Manager"]
        C2["Department: Engineering"]
        C3["Direct Reports: 8 people"]
        C4["Recent: Viewed leave calendar"]
        C5["Time: End of month"]
    end
    
    subgraph Query["Query: 'team status'"]
        Q1["Ambiguous query"]
    end
    
    subgraph Understanding["AI Understanding"]
        U1["'team' = User's direct reports"]
        U2["'status' = Likely attendance<br/>(EOD context)"]
        U3["Priority: Leave/WFH info<br/>(recent activity)"]
    end
    
    subgraph Result["Personalized Result"]
        R1["Team Attendance Today"]
        R2["3 WFH, 4 Office, 1 Leave"]
        R3["Pending approvals: 2"]
    end
    
    Context --> Understanding
    Query --> Understanding
    Understanding --> Result
```

### 5.5 Follow-up Questions

Hỗ trợ conversation flow với follow-up:

```mermaid
sequenceDiagram
    participant U as User
    participant AI as AI Search
    participant S as Search Engine
    
    U->>AI: "ai trong Engineering biết React"
    AI->>S: Semantic search
    S->>AI: 5 results
    AI->>U: Shows 5 developers with React skill
    
    Note over U,AI: Context maintained
    
    U->>AI: "trong số đó ai senior nhất"
    AI->>AI: Reference previous results
    AI->>S: Filter by seniority
    S->>AI: 2 results
    AI->>U: Shows 2 senior developers
    
    U->>AI: "contact của người đầu tiên"
    AI->>AI: Reference first result
    AI->>U: Shows contact card directly
```

---

## 6. People Search Features

### 6.1 Search Capabilities

```mermaid
graph TB
    subgraph Input["User Input"]
        Q[Search Query]
    end
    
    subgraph Processing["Search Processing"]
        F1[Fuzzy Matching<br/>Cho phép typo]
        F2[Vietnamese Support<br/>Có/không dấu]
        F3[Synonym Matching<br/>Bill = William]
        F4[Semantic Matching<br/>'dev' = Developer]
        F5[Relationship Query<br/>'reports to X']
    end
    
    subgraph Results["Search Results"]
        R1[Exact Matches]
        R2[Similar Names]
        R3[Semantically Related]
        R4[AI Ranked]
    end
    
    Q --> F1 & F2 & F3 & F4 & F5
    
    F1 & F2 & F3 --> R1
    F1 & F2 & F3 --> R2
    F4 & F5 --> R3
    R1 & R2 & R3 --> R4
    
    style Input fill:#e3f2fd
    style Processing fill:#fff3e0
    style Results fill:#e8f5e9
```

### 6.2 Natural Language People Queries

| Natural Language Query | Interpreted As |
|----------------------|----------------|
| "ai biết Python" | skill = "Python" |
| "developer senior trong Product" | position ~ "Developer" AND level = "Senior" AND dept = "Product" |
| "người mới join tháng này" | hire_date >= startOfMonth() |
| "team của Minh" | reportsTo("Minh") |
| "ai đang nghỉ phép" | status = "On Leave" |
| "manager của Engineering" | position ~ "Manager" AND dept = "Engineering" |
| "người có thể thay thế A khi nghỉ" | Semantic: backup/similar skills to A |

### 6.3 Skill & Expertise Search

```mermaid
flowchart TB
    subgraph Query["Query: 'ai có thể help về AWS'"]
        Q1["Natural language input"]
    end
    
    subgraph Analysis["AI Analysis"]
        A1["Intent: Find expert"]
        A2["Topic: AWS/Cloud"]
        A3["Purpose: Get help"]
    end
    
    subgraph Search["Multi-factor Search"]
        S1["Skills: AWS, Cloud"]
        S2["Certifications: AWS certs"]
        S3["Projects: AWS projects"]
        S4["Experience: Cloud exp"]
    end
    
    subgraph Ranking["AI Ranking"]
        R1["🥇 AWS Certified + 5yr exp"]
        R2["🥈 Cloud Engineer + active projects"]
        R3["🥉 DevOps with AWS experience"]
    end
    
    Query --> Analysis --> Search --> Ranking
```

### 6.4 Relationship-based Queries

```mermaid
flowchart LR
    subgraph Queries["Relationship Queries"]
        Q1["'sếp của Minh'"]
        Q2["'team members của tôi'"]
        Q3["'ai report cho Hà'"]
        Q4["'đồng nghiệp cùng team'"]
        Q5["'skip-level manager'"]
    end
    
    subgraph Resolution["Entity Resolution"]
        R1["manager_of(Minh)"]
        R2["direct_reports(currentUser)"]
        R3["reports_to(Hà)"]
        R4["same_team(currentUser)"]
        R5["manager.manager(currentUser)"]
    end
    
    Q1 --> R1
    Q2 --> R2
    Q3 --> R3
    Q4 --> R4
    Q5 --> R5
```

---

## 7. Navigation Search Features

### 7.1 Intent-based Navigation

```mermaid
flowchart TB
    subgraph UserIntent["User Intent Expressions"]
        I1["'muốn xin nghỉ phép'"]
        I2["'cần duyệt đơn'"]
        I3["'xem phiếu lương'"]
        I4["'update thông tin cá nhân'"]
        I5["'tìm policy nghỉ phép'"]
    end
    
    subgraph AIMapping["AI Intent Mapping"]
        M1["Action: Submit leave request"]
        M2["Action: Review approvals"]
        M3["View: Payslip"]
        M4["Action: Update profile"]
        M5["Info: Leave policy document"]
    end
    
    subgraph Navigation["Navigate To"]
        N1["Leave Request Form"]
        N2["Pending Approvals Page"]
        N3["My Payslip Page"]
        N4["Personal Info Edit"]
        N5["Policy Document + Summary"]
    end
    
    I1 --> M1 --> N1
    I2 --> M2 --> N2
    I3 --> M3 --> N3
    I4 --> M4 --> N4
    I5 --> M5 --> N5
```

### 7.2 Multi-language Action Mapping

| Vietnamese | English | Colloquial | → Action |
|------------|---------|------------|----------|
| "xin nghỉ phép" | "leave request" | "xin off" | Leave Request Form |
| "xem lương" | "view salary" | "check lương" | Payslip |
| "chấm công" | "attendance" | "điểm danh" | Timesheet |
| "duyệt đơn" | "approve request" | "approve" | Pending Approvals |
| "thêm nhân viên" | "add employee" | "tạo NV mới" | Create Employee |

### 7.3 Smart Action Suggestions

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  nghỉ phép                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🎯 ACTIONS                                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ ▶ Đăng ký nghỉ phép              Tạo đơn xin nghỉ mới     │ │
│  │   Xem số ngày phép còn lại        12 ngày remaining       │ │
│  │   Lịch sử nghỉ phép              Xem các đơn đã submit    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  📄 RELATED INFO                                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │   Leave Policy 2025              Company leave guidelines  │ │
│  │   Holiday Calendar               Lịch nghỉ lễ năm 2025    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  👥 PEOPLE ON LEAVE                                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │   3 people in your team are on leave this week            │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Advanced Search (xTQL)

### 8.1 Concept

Cho power users cần tìm kiếm phức tạp, hệ thống hỗ trợ query language với **AI-assisted building**:

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  department = "Engineering" AND status = "Active"    [Run]  │
│  ─────────────────────────────────────────────────────────────  │
│  🤖 AI Suggestion: Add "AND hire_date > '2024-01-01'" for       │
│     new hires, or "AND hasSkill('Python')" to filter by skill   │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 Natural Language to xTQL

AI có thể convert natural language thành xTQL:

```mermaid
flowchart LR
    subgraph NL["Natural Language"]
        N1["'developer mới join năm nay<br/>biết React trong Engineering'"]
    end
    
    subgraph AI["AI Translation"]
        A1["Parse intent"]
        A2["Extract entities"]
        A3["Build query"]
    end
    
    subgraph xTQL["Generated xTQL"]
        Q1["position ~ 'Developer'<br/>AND hire_date >= '2025-01-01'<br/>AND hasSkill('React')<br/>AND department = 'Engineering'"]
    end
    
    NL --> AI --> xTQL
```

### 8.3 Query Templates with AI Fill

| User Says | AI Generates |
|-----------|-------------|
| "new hires this year" | `hire_date >= "2025-01-01"` |
| "engineers who know cloud" | `department = "Engineering" AND hasSkill("AWS") OR hasSkill("Azure") OR hasSkill("GCP")` |
| "managers in my department" | `department = currentUserDepartment() AND position ~ "Manager"` |
| "people whose probation ends soon" | `probation_end_date BETWEEN today() AND dateAdd(today(), 30, "day")` |

---

## 9. User Experience Design

### 9.1 Search Panel Layout với AI

```
┌──────────────────────────────────────────────────────────────────────┐
│  🔍  ai trong team Engineering đang nghỉ phép                   ✕    │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  🤖 AI ANSWER                                                        │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Có 2 người trong Engineering đang nghỉ phép hôm nay:         │ │
│  │                                                                │ │
│  │  👤 Nguyễn Văn A    Annual Leave    Dec 25 - Dec 30           │ │
│  │  👤 Trần Thị B      Sick Leave      Dec 28                    │ │
│  │                                                                │ │
│  │  [View Leave Calendar]  [View All Engineering]                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  💬 FOLLOW-UP SUGGESTIONS                                            │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  "ai sẽ back sớm nhất?"  "coverage cho team?"  "approve đơn"  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ───────────────────────────────────────────────────────────────── │
│  🕐 RECENT: @minh  |  /payroll  |  ai biết Python                   │
└──────────────────────────────────────────────────────────────────────┘
```

### 9.2 Response Types

```mermaid
flowchart TB
    subgraph ResponseTypes["AI Response Types"]
        direction TB
        
        subgraph Direct["💬 Direct Answer"]
            D1["Single fact response"]
            D2["'Manager của Minh là Hà'"]
        end
        
        subgraph List["📋 List Response"]
            L1["Multiple results"]
            L2["Ranked by relevance"]
        end
        
        subgraph Card["👤 Rich Card"]
            C1["Person detail preview"]
            C2["Quick actions"]
        end
        
        subgraph Chart["📊 Visual Response"]
            CH1["Statistics"]
            CH2["Trends/Comparisons"]
        end
        
        subgraph Guide["🧭 Guide Response"]
            G1["Step-by-step"]
            G2["For 'how to' questions"]
        end
    end
```

### 9.3 AI Confidence Indicators

```
┌─────────────────────────────────────────────────────────────────┐
│  Query: "senior dev trong team mobile"                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🟢 High Confidence (95%)                                        │
│  Tìm thấy 3 Senior Developers trong Mobile Team:                │
│  [Results...]                                                    │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  Query: "ai giỏi nhất về cloud"                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🟡 Medium Confidence (70%)                                      │
│  Dựa trên skills và certifications, đây là những người có      │
│  expertise về Cloud:                                             │
│  [Results ranked by skill match...]                              │
│                                                                  │
│  💡 Bạn có thể clarify: certifications, years of experience?    │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  Query: "người phù hợp cho project X"                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🟠 Low Confidence - Need More Info                              │
│  Tôi cần thêm thông tin về Project X:                           │
│  - Required skills?                                              │
│  - Team size needed?                                             │
│  - Timeline?                                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Personalization & Learning

### 10.1 Smart Suggestions Engine

```mermaid
flowchart TB
    subgraph Learning["Learning Sources"]
        L1["Search history"]
        L2["Click patterns"]
        L3["Role & permissions"]
        L4["Time patterns"]
        L5["Team context"]
        L6["Organization data"]
    end
    
    subgraph Model["Personalization Model"]
        M1["User preferences"]
        M2["Intent prediction"]
        M3["Result ranking"]
    end
    
    subgraph Output["Personalized Experience"]
        O1["Relevant suggestions"]
        O2["Smart defaults"]
        O3["Predicted queries"]
        O4["Custom shortcuts"]
    end
    
    Learning --> Model --> Output
```

### 10.2 Time-based Contextual Suggestions

| Time/Context | Suggested Queries |
|--------------|------------------|
| **Monday morning** | "team attendance today", "week schedule" |
| **End of month** | "timesheet", "pending approvals", "overtime report" |
| **Performance review season** | "my team reviews", "goal progress" |
| **After viewing someone's profile** | "similar skills", "same team", "org chart" |
| **New hire's first week** | "onboarding checklist", "team members", "policies" |

### 10.3 Role-based Default Behavior

```mermaid
flowchart LR
    subgraph Roles["User Role"]
        R1["👤 Employee"]
        R2["👔 Manager"]
        R3["🏢 HR Admin"]
    end
    
    subgraph Defaults["Search Defaults"]
        D1["Self-service focused<br/>Personal info, leave, payslip"]
        D2["Team-focused<br/>Direct reports, approvals, team metrics"]
        D3["Organization-focused<br/>All employees, reports, analytics"]
    end
    
    subgraph Suggestions["Top Suggestions"]
        S1["'my leave balance'<br/>'my payslip'<br/>'my manager'"]
        S2["'my team'<br/>'pending approvals'<br/>'team attendance'"]
        S3["'all employees'<br/>'new hires report'<br/>'headcount by dept'"]
    end
    
    R1 --> D1 --> S1
    R2 --> D2 --> S2
    R3 --> D3 --> S3
```

---

## 11. Access Control & Security

### 11.1 AI-aware Permission System

```mermaid
flowchart TB
    subgraph Query["User Query"]
        Q1["'salary của team Engineering'"]
    end
    
    subgraph Check["Permission Check"]
        C1["User role?"]
        C2["Data sensitivity?"]
        C3["Scope allowed?"]
    end
    
    subgraph Response["AI Response"]
        R1["✅ Full data<br/>(HR Admin)"]
        R2["⚠️ Partial data<br/>(Manager - own team only)"]
        R3["❌ Access denied<br/>(Employee)"]
    end
    
    Query --> Check
    Check -->|"HR Admin"| R1
    Check -->|"Manager"| R2
    Check -->|"Employee"| R3
```

### 11.2 Sensitive Query Handling

| Query Type | Employee | Manager | HR Admin |
|------------|----------|---------|----------|
| "salary của X" | ❌ Không thể trả lời | ⚠️ Chỉ team mình | ✅ Full access |
| "performance rating của X" | ❌ | ⚠️ Direct reports | ✅ |
| "ai sắp bị terminate" | ❌ | ❌ | ✅ |
| "disciplinary records" | ❌ | ❌ | ✅ |

**AI Response for Restricted Queries:**
```
┌─────────────────────────────────────────────────────────────────┐
│  🔍  salary của team Engineering                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🔒 Restricted Information                                       │
│                                                                  │
│  Thông tin lương là dữ liệu nhạy cảm. Bạn có thể:               │
│                                                                  │
│  • Xem thông tin lương của bản thân → /my-payslip               │
│  • Liên hệ HR để được hỗ trợ → @hr-support                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 12. Feature Rollout Plan

### 12.1 Phase Overview với AI Features

```mermaid
gantt
    title Global Search Feature Rollout
    dateFormat YYYY-Q
    
    section Phase 1 - Foundation
    Basic Keyword Search        :p1a, 2025-Q1, 1q
    Prefix System               :p1b, 2025-Q1, 1q
    Vietnamese Fuzzy            :p1c, 2025-Q1, 1q
    
    section Phase 2 - Enhanced
    xTQL Basic                  :p2a, 2025-Q2, 1q
    Saved Searches              :p2b, 2025-Q2, 1q
    Search Analytics            :p2c, 2025-Q2, 1q
    
    section Phase 3 - NLP
    Intent Detection            :p3a, 2025-Q3, 1q
    Vietnamese NLP              :p3b, 2025-Q3, 1q
    Natural Language Queries    :p3c, 2025-Q3, 1q
    
    section Phase 4 - AI
    Semantic Search             :p4a, 2025-Q4, 1q
    Conversational Search       :p4b, 2025-Q4, 1q
    AI Suggestions              :p4c, 2025-Q4, 1q
    Follow-up Questions         :p4d, 2025-Q4, 1q
```

### 12.2 Phase Details

#### Phase 1: Foundation (Q1 2025)
| Feature | Description |
|---------|-------------|
| Basic Keyword Search | Exact & fuzzy matching |
| Prefix System | @, /, > routing |
| Vietnamese Support | Diacritic handling |
| Autocomplete | Real-time suggestions |

#### Phase 2: Enhanced (Q2 2025)
| Feature | Description |
|---------|-------------|
| xTQL Parser | Structured query support |
| Saved Searches | Save & share queries |
| Extended Attributes | Skills, relationships |
| Search Analytics | Usage tracking |

#### Phase 3: NLP (Q3 2025)
| Feature | Description |
|---------|-------------|
| Intent Detection | Classify user intent |
| Vietnamese NLP | Native language processing |
| Entity Extraction | Names, dates, departments |
| Natural Language | "ai biết Python" style queries |

#### Phase 4: AI-Powered (Q4 2025)
| Feature | Description |
|---------|-------------|
| Semantic Search | Meaning-based matching |
| Conversational | Multi-turn conversations |
| AI Answers | Direct question answering |
| Smart Suggestions | Context-aware recommendations |
| Follow-up | Conversation continuation |

---

## 13. Success Metrics

### 13.1 KPIs by Phase

```mermaid
flowchart TB
    subgraph Phase1["Phase 1 KPIs"]
        P1A["Search latency < 100ms"]
        P1B["Zero-result rate < 15%"]
        P1C["Basic adoption 50%"]
    end
    
    subgraph Phase2["Phase 2 KPIs"]
        P2A["xTQL adoption 20%<br/>of power users"]
        P2B["Saved search usage"]
        P2C["Query complexity ↑"]
    end
    
    subgraph Phase3["Phase 3 KPIs"]
        P3A["Intent accuracy > 85%"]
        P3B["NL query rate > 30%"]
        P3C["Vietnamese query success"]
    end
    
    subgraph Phase4["Phase 4 KPIs"]
        P4A["AI answer satisfaction > 80%"]
        P4B["Conversation depth > 2 turns"]
        P4C["Feature discovery +30%"]
    end
```

### 13.2 AI-specific Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Intent Detection Accuracy | >85% | Sampled evaluation |
| Query Understanding Rate | >90% | Successful parse rate |
| AI Answer Relevance | >80% satisfaction | User feedback |
| Conversation Completion | >60% | Follow-up engagement |
| Zero-result with AI Fallback | <5% | AI provides alternatives |

---

## 14. Open Questions for Discussion

### 14.1 AI Feature Decisions

```mermaid
mindmap
  root((AI Decisions))
    Scope
      Which queries get AI treatment?
      Fallback behavior?
      AI confidence threshold?
    UX
      How to show AI is thinking?
      Confidence indicators?
      Error handling?
    Vietnamese
      Priority vs English?
      Mixed language handling?
      Colloquial support level?
    Privacy
      Query logging for training?
      Opt-out options?
      Data retention?
    Cost
      AI processing cost per query?
      Caching strategy?
      Rate limiting?
```

### 14.2 Key Questions

1. **AI Trigger**: Khi nào query nên được xử lý bởi AI vs simple keyword search?

2. **Confidence Threshold**: Mức confidence nào AI nên trả lời trực tiếp vs yêu cầu clarification?

3. **Vietnamese Priority**: NLP tiếng Việt nên ở Phase 3 hay có thể delay đến Phase 4?

4. **Conversation Depth**: Hỗ trợ bao nhiêu follow-up turns trong một session?

5. **AI Training Data**: Có thể sử dụng search queries để improve AI model không? Privacy concerns?

6. **Cost Management**: AI processing cost per query? Có cần limit AI queries per user?

7. **Fallback UX**: Khi AI không confident, UX nên như thế nào?

8. **Hybrid Results**: Hiển thị kết quả keyword + semantic như thế nào cho user hiểu?

---

## 15. Appendix

### A. Sample Conversations

**Conversation 1: Finding Expert**
```
User: ai trong công ty giỏi về AWS
AI: Tìm thấy 8 người có expertise về AWS. Top 3:
    1. Nguyễn A - AWS Solutions Architect certified, 5 năm exp
    2. Trần B - DevOps Engineer, 3 AWS certifications
    3. Lê C - Cloud Engineer, lead AWS migration projects

User: người đầu tiên có thể contact qua đâu
AI: Nguyễn A - AWS Expert
    📧 nguyen.a@company.com
    📱 0912-xxx-xxx
    💬 Slack: @nguyena
    [Schedule Meeting] [Send Message]
```

**Conversation 2: HR Analytics**
```
User: bao nhiêu người mới join Q4 năm nay
AI: Q4 2025 có 23 new hires:
    • Engineering: 12 người
    • Product: 5 người  
    • Sales: 4 người
    • Others: 2 người
    [View Full List] [Compare with Q3]

User: so với Q3 thì sao
AI: So sánh hiring Q3 vs Q4 2025:
    Q3: 18 new hires | Q4: 23 new hires (+28%)
    Tăng nhiều nhất: Engineering (+5)
    [View Trend Chart] [Download Report]
```

### B. Glossary

| Term | Definition |
|------|------------|
| **Semantic Search** | Search dựa trên meaning, không chỉ keyword matching |
| **Intent Detection** | AI xác định user muốn làm gì |
| **NER** | Named Entity Recognition - nhận diện tên, ngày, org |
| **Slot Filling** | Điền các parameters từ natural language |
| **Embeddings** | Vector representation của text cho semantic matching |
| **Confidence Score** | Độ tin cậy của AI với câu trả lời |
| **Follow-up** | Câu hỏi tiếp theo trong conversation |

---

*Document Status: Draft for Review*  
*Version: 1.1 - Added AI & Semantic Search features*  
*Next Review: [TBD with Product Team]*