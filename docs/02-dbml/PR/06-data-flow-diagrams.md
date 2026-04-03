# Data Flow Diagrams — Payroll Execution Lifecycle

**Purpose**: Visualize data flow through Payroll V4 model  
**Last Updated**: 27Mar2026

---

## Overview

Tài liệu này minh họa data flow qua các schema trong Payroll V4:
- **Monthly Payroll Flow**: Regular payroll processing
- **Retroactive Adjustment Flow**: Backdated changes
- **Termination Final Pay Flow**: Off-cycle payment
- **Data Integration Flow**: Inbound from CO/TA/TR

---

## 1. Monthly Payroll Flow

### 1.1 High-Level Flow

```mermaid
flowchart TD
    subgraph Configuration
        CAL[PayCalendar]
        GRP[PayGroup]
        PRF[PayProfile]
        ELM[PayElement]
        RUL[StatutoryRule]
    end
    
    subgraph Orchestration
        PER[PayPeriod]
        BAT[Batch]
    end
    
    subgraph Calculation
        REQ[RunRequest]
        EMP[RunEmployee]
        INP[InputValue]
        RES[Result]
        BAL[Balance]
    end
    
    subgraph Output
        PAY[PaymentBatch]
        AUD[AuditLog]
    end
    
    CAL --> PER
    GRP --> BAT
    PRF --> BAT
    PER --> BAT
    
    BAT --> REQ
    REQ --> EMP
    
    ELM --> INP
    INP --> EMP
    
    RUL --> RES
    ELM --> RES
    EMP --> RES
    
    RES --> BAL
    
    BAT --> PAY
    RES --> PAY
    
    BAT --> AUD
    RES --> AUD
    
    style CAL fill:#e1f5fe
    style PRF fill:#e1f5fe
    style RUL fill:#e1f5fe
    style BAT fill:#fff3e0
    style REQ fill:#e8f5e9
    style RES fill:#e8f5e9
```

### 1.2 Detailed Sequence Flow

```mermaid
sequenceDiagram
    participant Scheduler
    participant PayPeriod as pay_mgmt.pay_period
    participant Batch as pay_mgmt.batch
    participant RunRequest as pay_engine.run_request
    participant RunStep as pay_engine.run_step
    participant RunEmployee as pay_engine.run_employee
    participant InputValue as pay_engine.input_value
    participant Result as pay_engine.result
    participant Balance as pay_engine.balance
    participant CumBalance as pay_engine.cumulative_balance
    participant PaymentBatch as pay_bank.payment_batch
    participant AuditLog as pay_audit.audit_log
    
    Note over Scheduler: Period start reached
    Scheduler->>PayPeriod: Open period (FUTURE → OPEN)
    
    Note over PayPeriod: Accept T&A, compensation data
    
    rect rgb(240, 248, 255)
        Note right of Batch: ORCHESTRATION PHASE
        PayrollAdmin->>Batch: Create REGULAR batch
        Batch->>Batch: status = DRAFT
        
        PayrollAdmin->>Batch: Select employees
        Batch->>RunEmployee: Create records (status=SELECTED)
        Batch->>Batch: status = SELECTING
        
        PayrollAdmin->>Batch: Submit to engine
        Batch->>Batch: status = SUBMITTED
        Batch->>RunRequest: Create request (status=QUEUED)
        Batch->>Batch: engine_request_id = FK
    end
    
    rect rgb(232, 245, 233)
        Note right of RunRequest: CALCULATION PHASE
        RunRequest->>RunRequest: status = PROCESSING
        
        RunRequest->>RunStep: Create 10 steps
        
        loop Step 1: INPUT_COLLECTION
            RunStep->>InputValue: Collect from T&A, Compensation
            InputValue-->>RunEmployee: Attach inputs
        end
        
        loop Step 3: EARNINGS
            RunStep->>Result: Calculate earnings
            Result-->>RunEmployee: Update gross_amount
        end
        
        loop Step 4: STATUTORY_DEDUCTIONS
            RunStep->>Result: Calculate SI (BHXH/BHYT/BHTN)
            Result-->>RunEmployee: Update deductions
        end
        
        loop Step 6: TAX
            RunStep->>Result: Calculate PIT
            Result-->>RunEmployee: Update tax
        end
        
        loop Step 7: NET_PAY
            RunStep->>RunEmployee: Calculate net_amount
            RunStep->>RunEmployee: Check variance
        end
        
        loop Step 9: BALANCING
            RunStep->>Balance: Create period balances
            RunStep->>CumBalance: Update YTD/QTD balances
        end
        
        RunRequest->>RunRequest: status = COMPLETED
        RunRequest-->>Batch: Update calc_completed_at
    end
    
    rect rgb(255, 243, 224)
        Note right of Batch: REVIEW & APPROVAL PHASE
        Batch->>Batch: status = REVIEW
        
        PayrollAdmin->>Batch: Review exceptions
        PayrollAdmin->>Batch: Acknowledge exceptions
        
        Manager->>Batch: Approve (Level 2)
        Batch->>Batch: status = APPROVED
        
        Finance->>Batch: Confirm
        Batch->>Batch: status = CONFIRMED
    end
    
    rect rgb(248, 232, 232)
        Note right of PaymentBatch: OUTPUT PHASE
        Batch->>PaymentBatch: Create payment batch
        PaymentBatch->>PaymentBatch: status = PENDING
        
        PaymentBatch->>PaymentBatch: Generate bank file
        PaymentBatch->>PaymentBatch: status = SENT
        
        Note over PaymentBatch: Submit to bank
        PaymentBatch->>PaymentBatch: status = CONFIRMED
    end
    
    Batch->>PayPeriod: Lock period (OPEN → CLOSED)
    Batch->>Batch: status = CLOSED
    
    Batch->>AuditLog: Log all actions
```

---

## 2. Configuration Lookup Flow

### 2.1 PayProfile Resolution

```mermaid
flowchart TD
    START[Employee needs payroll config] --> CHECK1{Employee has<br/>individual profile?}
    
    CHECK1 -->|Yes| INDIV[Get pay_profile_map<br/>where employee_id = X]
    CHECK1 -->|No| CHECK2{PayGroup has<br/>default profile?}
    
    INDIV --> PROFILE[Load PayProfile]
    
    CHECK2 -->|Yes| GRP[Get pay_group.default_profile_id]
    CHECK2 -->|No| ERROR[Error: No profile assigned]
    
    GRP --> PROFILE
    
    PROFILE --> PARENT{Has<br/>parent_profile_id?}
    
    PARENT -->|Yes| MERGE[Merge with parent<br/>Child overrides parent]
    PARENT -->|No| BINDINGS[Load bindings]
    
    MERGE --> BINDINGS
    
    BINDINGS --> ELEM[Load pay_profile_element]
    BINDINGS --> RULE[Load pay_profile_rule]
    
    ELEM --> ELEMENTS[Get PayElement details]
    RULE --> RULES[Get StatutoryRule details]
    
    ELEMENTS --> READY[Configuration ready<br/>for calculation]
    RULES --> READY
    
    style PROFILE fill:#e1f5fe
    style MERGE fill:#fff3e0
    style READY fill:#e8f5e9
```

### 2.2 Rate Lookup (3-Layer)

```mermaid
flowchart TD
    START[Need rate for<br/>OT_WEEKDAY] --> LAYER1{Check<br/>worker_rate_override?}
    
    LAYER1 -->|Found| RETURN1[Return override_rate<br/>e.g., 60000 VND/h]
    LAYER1 -->|Not found| LAYER2[Check<br/>pay_profile_rate_config]
    
    LAYER2 --> TYPE{rate_type?}
    
    TYPE -->|FIXED| RETURN2[Return base_rate_amount<br/>e.g., 50000 VND/h]
    TYPE -->|MULTIPLIER| LAYER3[Lookup<br/>statutory_rule]
    TYPE -->|FORMULA| FORMULA[Execute formula]
    
    LAYER3 --> STAT[Get multiplier<br/>e.g., VN_OT_WEEKDAY = 1.5]
    STAT --> CALC[regular_rate × multiplier<br/>50000 × 1.5 = 75000]
    CALC --> RETURN3[Return calculated rate]
    
    FORMULA --> RETURN4[Return formula result]
    
    style RETURN1 fill:#e8f5e9
    style RETURN2 fill:#e8f5e9
    style RETURN3 fill:#e8f5e9
    style RETURN4 fill:#e8f5e9
```

---

## 3. Calculation Pipeline

### 3.1 Calculation Steps

```mermaid
flowchart LR
    START[Start Calculation] --> S1[1. INPUT_COLLECTION]
    S1 --> S2[2. PRE_CALC]
    S2 --> S3[3. EARNINGS]
    S3 --> S4[4. STATUTORY_DEDUCTIONS]
    S4 --> S5[5. VOLUNTARY_DEDUCTIONS]
    S5 --> S6[6. TAX]
    S6 --> S7[7. NET_PAY]
    S7 --> S8[8. POST_CALC]
    S8 --> S9[9. BALANCING]
    S9 --> S10[10. COSTING]
    S10 --> END[Complete]
    
    style S3 fill:#e8f5e9
    style S4 fill:#fff3e0
    style S6 fill:#ffebee
    style S7 fill:#e1f5fe
```

### 3.2 Gross-to-Net Calculation

```mermaid
flowchart TD
    INPUTS[Inputs:<br/>- Base Salary<br/>- Work Days<br/>- OT Hours<br/>- Allowances] --> GROSS[Calculate Gross]
    
    GROSS --> GROSS_DET[Gross =<br/>Base Salary + OT + Allowances]
    
    GROSS_DET --> SI_BASIS[Calculate SI Basis]
    
    SI_BASIS --> SI_DET[SI Basis =<br/>Sum of elements where<br/>si_basis_inclusion = INCLUDED]
    
    SI_DET --> SI_CALC[Calculate SI]
    
    SI_CALC --> SI_EMP[BHXH Employee = 8%<br/>BHYT Employee = 1.5%<br/>BHTN Employee = 1%]
    
    SI_EMP --> TAXABLE[Calculate Taxable Income]
    
    TAXABLE --> TAX_DET[Taxable = Gross - SI - Deductions<br/>- Personal (11M) - Dependents (4.4M each)]
    
    TAX_DET --> PIT[Calculate PIT]
    
    PIT --> PIT_DET[PIT = Progressive tax<br/>7 brackets: 5% - 35%]
    
    PIT_DET --> NET[Calculate Net]
    
    NET --> NET_DET[Net = Gross - SI - PIT - Deductions]
    
    NET_DET --> CHECK{Net < 0?}
    
    CHECK -->|Yes| EXCEPTION[Flag NEGATIVE_NET<br/>exception]
    CHECK -->|No| MIN_WAGE{Net < Min Wage?}
    
    MIN_WAGE -->|Yes| EXCEPTION2[Flag MIN_WAGE_VIOLATION<br/>exception]
    MIN_WAGE -->|No| DONE[Calculation Complete]
    
    EXCEPTION --> ACK[Acknowledge exception]
    EXCEPTION2 --> ACK
    ACK --> DONE
    
    style GROSS fill:#e8f5e9
    style SI_CALC fill:#fff3e0
    style PIT fill:#ffebee
    style NET fill:#e1f5fe
```

---

## 4. Retroactive Adjustment Flow

```mermaid
sequenceDiagram
    participant PayrollAdmin
    participant Batch as pay_mgmt.batch
    participant RunRequest as pay_engine.run_request
    participant RunEmployee as pay_engine.run_employee
    participant RetroDelta as pay_engine.retro_delta
    participant Result as pay_engine.result
    participant PayPeriod as pay_mgmt.pay_period
    
    Note over PayrollAdmin: Salary increase effective 2025-01<br/>discovered in 2025-03
    
    PayrollAdmin->>Batch: Create RETRO batch
    Batch->>Batch: batch_type = RETRO
    Batch->>Batch: original_run_id = 2025-01 batch
    Batch->>Batch: status = DRAFT
    
    PayrollAdmin->>Batch: Select affected employees
    Batch->>Batch: status = SUBMITTED
    
    Batch->>RunRequest: Create request (RETRO)
    RunRequest->>RunRequest: status = PROCESSING
    
    loop Each affected employee
        RunRequest->>RunEmployee: Create retro calculation
        
        Note over RunEmployee: Recalculate 2025-01 with new salary
        
        RunEmployee->>RetroDelta: Calculate delta
        Note over RetroDelta: delta_amount = new_amount - old_amount
        
        RetroDelta-->>RunEmployee: Record delta
        RunEmployee->>Result: Create RETRO_ADJUSTMENT element
        Note over Result: Apply in current period (2025-03)
    end
    
    RunRequest->>RunRequest: status = COMPLETED
    Batch->>Batch: status = REVIEW
    
    PayrollAdmin->>Batch: Approve retro
    Batch->>Batch: status = CLOSED
    
    Batch->>PayPeriod: Update 2025-01 period
    PayPeriod->>PayPeriod: status = ADJUSTED
```

---

## 5. Termination Final Pay Flow

```mermaid
sequenceDiagram
    participant HR
    participant PayrollAdmin
    participant Batch as pay_mgmt.batch
    participant RunRequest as pay_engine.run_request
    participant RunEmployee as pay_engine.run_employee
    participant InputValue as pay_engine.input_value
    participant Result as pay_engine.result
    participant PaymentBatch as pay_bank.payment_batch
    
    HR->>PayrollAdmin: Termination effective 2025-03-15
    
    PayrollAdmin->>Batch: Create TERMINATION batch
    Batch->>Batch: batch_type = TERMINATION
    Batch->>Batch: period_start = 2025-03-01
    Batch->>Batch: period_end = 2025-03-15
    Batch->>Batch: status = DRAFT
    
    PayrollAdmin->>Batch: Add terminated employee
    Batch->>RunEmployee: Create record
    Batch->>Batch: status = SUBMITTED
    
    Batch->>RunRequest: Create request (QUICKPAY)
    RunRequest->>RunRequest: status = PROCESSING
    
    Note over RunRequest: Calculate final pay elements:<br/>1. Prorated salary (1-15 Mar)<br/>2. Leave payout (unused leave)<br/>3. 13th month pro-rate<br/>4. Severance (if applicable)
    
    RunRequest->>InputValue: Collect inputs
    InputValue-->>RunEmployee: Work days, leave balance
    
    RunRequest->>RunEmployee: Calculate elements
    
    RunEmployee->>Result: PRORATED_SALARY
    Note over Result: 15/22 × monthly_salary
    
    RunEmployee->>Result: LEAVE_PAYOUT
    Note over Result: unused_days × daily_rate
    
    RunEmployee->>Result: 13TH_MONTH_PRORATE
    Note over Result: 3/12 × monthly_salary
    
    alt RIF or Dismissal
        RunEmployee->>Result: SEVERANCE
        Note over Result: tenure_years × 0.5 × avg_salary
    end
    
    RunEmployee->>Result: NET_SALARY
    Note over Result: Sum all - deductions - tax
    
    RunRequest->>RunRequest: status = COMPLETED
    Batch->>Batch: status = REVIEW
    
    PayrollAdmin->>Batch: Approve
    Batch->>Batch: status = CONFIRMED
    
    Batch->>PaymentBatch: Create immediate payment
    PaymentBatch->>PaymentBatch: status = SENT
    
    Note over PaymentBatch: Generate bank file<br/>Submit immediately
```

---

## 6. Data Integration Flow

### 6.1 Inbound Data Collection

```mermaid
flowchart TD
    subgraph External Modules
        CO[Core HR<br/>CO]
        TA[Time & Attendance<br/>TA]
        TR[Total Rewards<br/>TR]
        BEN[Benefits<br/>BEN]
    end
    
    subgraph Payroll Input
        CONFIG[input_source_config]
        INP[input_value]
    end
    
    subgraph Engine
        REQ[run_request]
        STEP[run_step: INPUT_COLLECTION]
    end
    
    CO --> |Employee data<br/>contract, dependents| CONFIG
    TA --> |Timesheet<br/>work days, OT hours| CONFIG
    TR --> |Compensation<br/>base salary, allowances| CONFIG
    BEN --> |Premiums<br/>insurance, deductions| CONFIG
    
    REQ --> STEP
    STEP --> CONFIG
    CONFIG --> INP
    
    CO -.-> |Trigger: Employee update| AUDIT[pay_audit.audit_log]
    TA -.-> |Trigger: AttendanceLocked| AUDIT
    TR -.-> |Trigger: CompensationSnapshot| AUDIT
    
    style CONFIG fill:#e1f5fe
    style INP fill:#e8f5e9
```

### 6.2 Outbound Data Distribution

```mermaid
flowchart TD
    subgraph Calculation Results
        RES[result]
        BAL[balance]
        CUM[cumulative_balance]
    end
    
    subgraph Output Files
        PAY[payment_batch<br/>payment_line]
        GEN[generated_file<br/>Payslip, Reports]
    end
    
    subgraph External Systems
        BANK[Banking Systems<br/>VCB, BIDV, TCB]
        GL[Finance/GL<br/>Journal entries]
        GDT[Tax Authority<br/>GDT]
        BHXH[BHXH Agency<br/>VssID]
        PORTAL[Worker Portal<br/>Self-service]
    end
    
    RES --> PAY
    RES --> GEN
    BAL --> GEN
    CUM --> GEN
    
    PAY --> BANK
    RES --> GL
    GEN --> GDT
    GEN --> BHXH
    GEN --> PORTAL
    
    style RES fill:#e8f5e9
    style PAY fill:#fff3e0
    style GEN fill:#e1f5fe
```

---

## 7. Exception Handling Flow

### 7.1 Negative Net Salary

```mermaid
flowchart TD
    START[Calculate Net] --> CHECK{Net < 0?}
    
    CHECK -->|No| DONE[Continue]
    CHECK -->|Yes| FLAG[Flag NEGATIVE_NET<br/>exception]
    
    FLAG --> HALT[Halt employee from<br/>payment file]
    
    HALT --> REVIEW[Payroll Admin reviews]
    
    REVIEW --> OPTIONS{Resolution?}
    
    OPTIONS -->|Waive deduction| WAIVE[Waive partial deduction<br/>Requires Finance approval]
    OPTIONS -->|Recover next period| RECOVER[Mark as recoverable<br/>Add to next period]
    OPTIONS -->|Structural (no work)| ZERO[Set net = 0<br/>No payment]
    
    WAIVE --> ADJUST[Adjust calculation]
    RECOVER --> SCHEDULE[Schedule recovery]
    ZERO --> FINALIZE[Finalize with net = 0]
    
    ADJUST --> ACK[Acknowledge exception]
    SCHEDULE --> ACK
    FINALIZE --> ACK
    
    ACK --> RESUME[Resume batch processing]
    
    style FLAG fill:#ffebee
    style HALT fill:#fff3e0
    style ACK fill:#e8f5e9
```

### 7.2 Missing Statutory Rule

```mermaid
flowchart TD
    START[Pre-validation] --> CHECK{StatutoryRule<br/>exists for cutoff date?}
    
    CHECK -->|Yes| PASS[Pre-validation passes]
    CHECK -->|No| FAIL[Pre-validation fails]
    
    FAIL --> ALERT[Alert Platform Admin]
    
    ALERT --> CREATE[Create StatutoryRule]
    CREATE --> INPUT[Input rule data:<br/>- Rates<br/>- Ceilings<br/>- Effective dates]
    
    INPUT --> ACTIVATE[Activate rule]
    ACTIVATE --> RETRY[Retry pre-validation]
    
    RETRY --> CHECK
    
    style FAIL fill:#ffebee
    style PASS fill:#e8f5e9
```

---

## 8. Audit Trail Flow

```mermaid
flowchart TD
    subgraph Operations
        CONFIG[Configuration Change]
        RUN[Payroll Run]
        APPROVE[Approval Action]
        ADJUST[Manual Adjustment]
    end
    
    subgraph Audit
        LOG[audit_log]
        HASH[Integrity Hash<br/>SHA-256]
    end
    
    subgraph Verification
        NIGHTLY[Nightly Job]
        VERIFY[Verify Hashes]
        ALERT[Alert if mismatch]
    end
    
    CONFIG --> LOG
    RUN --> LOG
    APPROVE --> LOG
    ADJUST --> LOG
    
    RUN --> HASH
    HASH --> LOG
    
    NIGHTLY --> VERIFY
    VERIFY --> HASH
    VERIFY -->|Mismatch| ALERT
    
    style LOG fill:#e1f5fe
    style HASH fill:#fff3e0
    style VERIFY fill:#e8f5e9
```

---

## 9. Key Data Entities Flow

### 9.1 Entity Lifecycle

```mermaid
flowchart TD
    subgraph Configuration [pay_master]
        CAL[PayCalendar]
        GRP[PayGroup]
        PRF[PayProfile]
        ELM[PayElement]
        RUL[StatutoryRule]
    end
    
    subgraph Orchestration [pay_mgmt]
        PER[PayPeriod]
        BAT[Batch]
    end
    
    subgraph Calculation [pay_engine]
        REQ[RunRequest]
        EMP[RunEmployee]
        INP[InputValue]
        RES[Result]
        BAL[Balance]
        CUM[CumulativeBalance]
    end
    
    subgraph Output [pay_bank, pay_audit]
        PAY[PaymentBatch]
        AUD[AuditLog]
    end
    
    CAL --> PER
    GRP --> BAT
    PRF --> EMP
    ELM --> INP
    ELM --> RES
    RUL --> RES
    
    PER --> BAT
    BAT --> REQ
    REQ --> EMP
    
    EMP --> INP
    EMP --> RES
    EMP --> BAL
    
    BAL --> CUM
    
    BAT --> PAY
    RES --> PAY
    BAT --> AUD
    
    style Configuration fill:#e1f5fe
    style Orchestration fill:#fff3e0
    style Calculation fill:#e8f5e9
    style Output fill:#f3e5f5
```

---

## 10. Summary

### Key Flow Patterns

| Flow | Trigger | Duration | Key Tables |
|------|---------|----------|------------|
| **Monthly Payroll** | Scheduler (cutoff) | ~2-4 hours | batch, run_employee, result, balance |
| **Retroactive Adjustment** | Payroll Admin | ~30 min | batch (RETRO), retro_delta, result |
| **Termination Pay** | HR termination action | ~15 min | batch (TERMINATION), result |
| **Import Data** | Payroll Admin upload | ~5-10 min | import_job, iface_*, input_value |
| **Generate Payment** | Batch approval | ~10 min | payment_batch, payment_line |

### Performance Targets

| Operation | Target | Optimization |
|-----------|--------|--------------|
| Calculate 10,000 employees | < 5 min | Parallel KieSessions |
| Import 50,000 lines | < 2 min | Batch insert |
| Generate payment file | < 30 sec | Streaming write |
| Query YTD balance | < 100 ms | cumulative_balance table |

---

*[Previous: Support Schemas](./05-support-schemas.md) · [Back to README](./00-README.md)*