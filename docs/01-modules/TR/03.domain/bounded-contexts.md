# Total Rewards — Bounded Contexts

> **Module**: Total Rewards (TR)
> **Giải pháp**: xTalent — HCM
> **Step**: 3 — Domain Architecture
> **Ngày**: 2026-03-26
> **Phiên bản**: 1.0.0

---

## Context Map Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        xTalent — Total Rewards Platform                        │
│                                                                                 │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐             │
│  │  BC-01        │    │   BC-02           │    │   BC-03           │             │
│  │  Compensation │───▶│   Calculation     │    │   Variable Pay    │             │
│  │  Management   │    │   Engine          │◀───│                   │             │
│  └──────────────┘    └──────────────────┘    └──────────────────┘             │
│         │                     │                        │                        │
│         │            ┌────────▼────────┐               │                        │
│         │            │   BC-08          │               │                        │
│         │            │   Taxable Bridge │◀──────────────┘                        │
│         │            │   (Cross-cutting)│                                        │
│         │            └────────┬────────┘                                        │
│         │                     │                                                 │
│         ▼                     ▼                                                 │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐             │
│  │  BC-04        │    │   BC-09           │    │   BC-05           │             │
│  │  Benefits     │    │   Tax &           │    │   Recognition     │             │
│  │  Admin        │    │   Compliance      │    │                   │             │
│  └──────────────┘    └──────────────────┘    └──────────────────┘             │
│         │                     │                        │                        │
│         └──────────┬──────────┘                        │                        │
│                    ▼                                    ▼                        │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐             │
│  │  BC-07        │    │   BC-06           │    │   BC-10           │             │
│  │  TR Statement │    │   Offer Mgmt      │    │   Audit &         │             │
│  │               │    │                   │    │   Observability   │             │
│  └──────────────┘    └──────────────────┘    └──────────────────┘             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
         ▲                                                          ▲
         │ WorkerCreated, GradeChanged,                            │ (read-only)
         │ WorkingRelationshipChanged                              │
┌─────────────────────┐                                  ┌─────────────────────┐
│   CO Module          │                                  │   Payroll Module     │
│   (Upstream)         │                                  │   (Downstream)       │
│   Worker             │                                  │   PayrollRun         │
│   WorkingRelationship│                                  │   NetPayCalc         │
│   Grade, Job, LE     │                                  │                      │
└─────────────────────┘                                  └─────────────────────┘
```

**Ghi chú kiến trúc**:
- BC-02 (Calculation Engine) là trung tâm tính toán — mọi BC khác consume rules từ đây
- BC-08 (Taxable Bridge) là cross-cutting concern — nhận taxable events từ BC-01, BC-03, BC-04, BC-05
- BC-10 (Audit) là cross-cutting concern — capture mọi thay đổi từ tất cả BC
- CO Module là upstream dependency — TR không define Worker, WorkingRelationship, Grade, LegalEntity
- Payroll Module là downstream consumer — nhận kết quả tính toán từ TR

---

## Bounded Context Definitions

### BC-01: Compensation Management

**Responsibility**: Quản lý toàn bộ vòng đời lương cơ bản — cấu trúc lương, chu kỳ điều chỉnh, đề xuất và phê duyệt thay đổi, khấu trừ bắt buộc, và pay range theo cấp bậc.

**Aggregates**:
- `SalaryBasis` — Định nghĩa cấu trúc lương (HOURLY/MONTHLY/ANNUAL) với danh sách pay components
- `PayComponentDef` — Component lương tái sử dụng (BASE, ALLOWANCE, BONUS, DEDUCTION, OVERTIME)
- `SalaryRecord` (SCD Type 2) — Lịch sử lương của Worker tại từng thời điểm
- `PayRange` (SCD Type 2) — Khung lương theo grade, effective-dated
- `CompensationCycle` — Chu kỳ merit review với trạng thái lifecycle (DRAFT/OPEN/CLOSED)
- `CompensationProposal` — Đề xuất thay đổi lương trong một cycle
- `DeductionRecord` — Khoản khấu trừ (loan, garnishment, salary advance) với lịch trả

**External Dependencies**:
- `Worker` (từ CO module) — identity
- `WorkingRelationship` (từ CO module) — employment context, workplace_location
- `Grade` / `GradeVersion` (từ CO module) — SCD Type 2 grade reference
- `LegalEntity` (từ CO module) — regulatory context per country
- `ConfigScope` (từ comp_core schema) — scope hierarchy cho pay range và salary basis
- `CalculationRule` (từ BC-02) — proration, FX conversion
- `MinWageConfig` (từ BC-02) — validation ngưỡng tối thiểu

**Published Events**:
- `SalaryStructureCreated` — khi tạo salary basis mới
- `CompensationCycleOpened` / `CompensationCycleClosed`
- `MeritRecommendationSubmitted` — proposal submitted
- `CompensationApproved` — proposal approved, trigger effective date scheduling
- `CompensationRejected`
- `SalaryEffectiveDateReached` — salary activation (cron-triggered)
- `SalaryHistoryArchived` — SCD Type 2 snapshot created
- `MinimumWageViolated` — hard block event
- `BudgetVarianceAlerted`
- `PayEquityGapDetected` (USP)
- `DeductionSetup` / `DeductionsProcessed`

**Integration Pattern**:
- Subscribes to CO events: `WorkerCreated`, `WorkingRelationshipChanged`, `GradeChanged`
- Publishes to BC-08 (Taxable Bridge): salary effective events
- Publishes to Payroll via BC-08: `SalaryChanged`, `DeductionCreated`
- Reads from BC-02 for calculation execution

---

### BC-02: Calculation Engine

**Responsibility**: Engine tính toán pluggable và versioned — xử lý mọi quy tắc tính toán theo quốc gia (SI, thuế, proration, FX). HR SME cấu hình qua Admin UI mà không cần code deployment.

**Aggregates**:
- `CalculationRule` (versioned, SCD-like) — Công thức/tỷ lệ có effective dating, hỗ trợ rollback
- `ContributionConfig` (SCD Type 2) — Cấu hình SI/CPF/BPJS per country/LE
- `ProrationConfig` — Phương pháp tính proration per component per scope
- `MinWageConfig` (SCD Type 2) — Bảng lương tối thiểu theo vùng/quốc gia với effective date
- `FxRateRecord` — Tỷ giá hàng ngày với archive

**External Dependencies**:
- `ConfigScope` (từ comp_core) — scope resolution cho rule lookup
- `LegalEntity` (từ CO module) — xác định country context
- FX Rate providers (OANDA, Reuters — external)

**Published Events**:
- `CalculationRuleVersioned` — rule mới được tạo
- `SIContributionCalculated` / `SICapApplied`
- `SalaryProrated`
- `FxRateUpdated` / `FxDeltaAlerted`
- `CalculationCompleted` — tất cả components cho một period đã tính xong

**Integration Pattern**:
- Plugin interface: mỗi country plugin implement `CountryContributionEngine` interface
- Consumed by BC-01, BC-03, BC-04, BC-09 — tất cả invoke calculation engine
- Exposes `CalculationEnginePort` (interface) — callers không depend trực tiếp vào implementation

---

### BC-03: Variable Pay

**Responsibility**: Quản lý toàn bộ phần thưởng biến động — bonus, hoa hồng, equity (RSU/options). Bao gồm cả 13th month / THR / PD 851 như plugin per quốc gia.

**Aggregates**:
- `BonusPlan` — Thiết kế kế hoạch bonus với formula_json pluggable
- `BonusStatement` — Kết quả bonus đã tính per Worker per cycle
- `CommissionPlan` — Kế hoạch hoa hồng với tiers, quota, accelerator
- `CommissionStatement` — Kết quả commission monthly per Worker
- `SalesTransaction` — Import từ CRM, dùng để tính commission
- `CommissionDispute` — Dispute workflow với partial-freeze default
- `EquityGrant` — RSU/Options grant với vesting schedule

**External Dependencies**:
- `Worker` / `WorkingRelationship` (CO module)
- `CalculationRule` (BC-02) — formula engine, FX conversion
- CRM system (external) — SalesTransaction import
- Equity platform (external, Phase 2)

**Published Events**:
- `BonusPlanConfigured` / `BonusPoolReleased` / `BonusCalculated` / `BonusApproved`
- `CommissionPlanConfigured` / `SalesTransactionsImported`
- `CommissionCalculated` / `RealTimeCommissionCalculated` (USP — < 5s via Kafka)
- `DisputeSubmitted` / `CommissionDisputeResolved`
- `EquityGranted` / `EquityVested`

**Integration Pattern**:
- Kafka consumer cho real-time CRM events (Phase 2 — RealTimeCommission)
- Publishes to BC-08 (Taxable Bridge): `BonusApproved`, `EquityVested`
- Reads from BC-02 for formula execution

---

### BC-04: Benefits Administration

**Responsibility**: Quản lý vòng đời phúc lợi — thiết kế plan, enrollment, carrier sync (EDI 834), dependent management, và flex credits.

**Aggregates**:
- `BenefitPlan` — Thiết kế plan với eligibility profile và carrier config
- `BenefitEnrollment` — Election của Worker cho từng plan
- `DependentRecord` — Thông tin người phụ thuộc với verification workflow
- `EligibilityProfile` — Reusable profile cho eligibility rules

**External Dependencies**:
- `Worker` / `WorkingRelationship` (CO module)
- Benefits carriers (external — EDI 834)
- `CalculationRule` (BC-02) — deduction amount calculation

**Published Events**:
- `BenefitPlanConfigured` / `OpenEnrollmentStarted` / `OpenEnrollmentClosed`
- `BenefitElected` / `BenefitEligibilityVerified`
- `CarrierDataSynced` / `CarrierSyncFailed`
- `DependentAdded`
- `FlexCreditsAllocated` (USP)

**Integration Pattern**:
- EDI 834 carrier sync: webhook primary + 15-min polling fallback
- Publishes to BC-08 (Taxable Bridge): benefit in-kind events
- Publishes deduction creation to BC-01

---

### BC-05: Recognition

**Responsibility**: Hệ thống điểm thưởng và ghi nhận — peer recognition, social feed, perks catalog, FIFO point balance, milestone automation.

**Aggregates**:
- `RecognitionProgram` — Cấu hình chương trình với budget, loại award, monthly limits
- `PointBalance` — Số dư điểm per Worker với FIFO expiration (12 tháng)
- `RecognitionTransaction` — Từng transaction: send/receive/redeem/expire
- `PerkCatalog` — Danh mục phần thưởng có thể đổi điểm
- `SocialFeedPost` — Public recognition post với moderation

**External Dependencies**:
- `Worker` / `WorkingRelationship` (CO module)
- Perk fulfillment vendors (external)

**Published Events**:
- `RecognitionProgramConfigured`
- `PeerRecognitionSent` / `SocialRecognitionPosted` (USP)
- `PointsRedeemed` / `PointsExpired`
- `MilestoneDetected`
- `AIRecognitionSuggested` (USP)
- `TaxableRecognitionCreated` — khi perk có monetary value

**Integration Pattern**:
- Publishes to BC-08 (Taxable Bridge): `TaxableRecognitionCreated`
- Milestone detection subscribed to CO events (work anniversary, birthday)

---

### BC-06: Offer Management

**Responsibility**: Chuẩn hóa quy trình tạo offer cho candidate — templates, approval workflow, e-signature (multi-provider), counter-offer.

**Aggregates**:
- `OfferRecord` — Vòng đời offer từ DRAFT → APPROVED → SENT → ACCEPTED/DECLINED
- `OfferTemplate` — Template với merge fields và enterprise branding
- `OfferApproval` — Approval step trong workflow

**External Dependencies**:
- `LegalEntity` (CO module) — employer details
- E-signature providers (DocuSign, HelloSign — external multi-provider abstraction)
- CO module — nhận `OfferAccepted` để trigger onboarding
- Market benchmark data (external — AI scoring, Phase 2)

**Published Events**:
- `OfferCreated` / `OfferSubmittedForApproval` / `OfferApproved`
- `OfferLetterGenerated` / `OfferSentToCandidate`
- `OfferAccepted` / `OfferDeclined`
- `CounterOfferRequested`
- `OfferCompetitivenessScored` (USP)

**Integration Pattern**:
- E-signature: dual confirm — webhook primary + 15-min polling fallback
- Publishes `OfferAccepted` to CO module (trigger onboarding)
- Min wage validation tại `OfferCreated` (calls BC-02)

---

### BC-07: Total Rewards Statement

**Responsibility**: Tổng hợp và phát hành Total Rewards Statement — snapshot hàng năm toàn bộ giá trị đãi ngộ của Worker.

**Aggregates**:
- `TRStatement` — Annual/on-demand statement snapshot (immutable sau khi published)
- `StatementTemplate` — Template với branding và sections

**External Dependencies**:
- BC-01 (Compensation data)
- BC-03 (Variable Pay data)
- BC-04 (Benefits data)
- BC-05 (Recognition/Points data)
- `Worker` (CO module)

**Published Events**:
- `StatementsGenerated` (batch)
- `StatementViewed`

**Integration Pattern**:
- Read-only aggregation từ tất cả BC khác
- Không publish events sang Payroll
- PDF generation service (< 5 giây/statement)
- 7-year immutable archival

---

### BC-08: Taxable Bridge (Cross-cutting)

**Responsibility**: Capture mọi taxable event từ các BC khác và đảm bảo bridge sang Payroll module đúng kỳ, exactly-once, với idempotency.

**Aggregates**:
- `TaxableItem` — Taxable event với idempotency key, source reference, dedup window

**External Dependencies**:
- Tất cả BC trong TR module (publisher)
- Payroll Module (consumer — downstream)

**Published Events**:
- `TaxableItemCreated`
- `PayrollBridgeProcessed`
- `PayrollBridgeDelayed` (SLA alert — sau 15 phút không có ack)

**Integration Pattern**:
- Kafka at-least-once delivery + idempotency_key dedup (24h window)
- Payroll ack required — alert nếu không nhận trong 15 phút
- Daily batch reconciliation bổ sung cho real-time Kafka

---

### BC-09: Tax & Compliance

**Responsibility**: Tính và khai báo thuế thu nhập cá nhân — cấu hình bracket (SCD Type 2), tax profile Worker, e-filing dual-path.

**Aggregates**:
- `TaxBracket` (SCD Type 2) — Bảng thuế luỹ tiến có effective dating
- `TaxProfile` — Worker self-declared: dependents, deductions
- `TaxFiling` — Filing record với reference number từ authority

**External Dependencies**:
- `Worker` / `WorkingRelationship` (CO module)
- Tax Authority APIs (external — country-specific)
- BC-02 (Calculation Engine) — taxable income calculation
- BC-08 (Taxable Bridge) — taxable items source

**Published Events**:
- `TaxBracketConfigured`
- `TaxCalculated`
- `TaxDeclarationUpdated`
- `TaxReturnFiled`
- `TaxAPIFailed` (SLA alert)
- `TaxOptimizationRecommended` (USP — opt-in)

**Integration Pattern**:
- Dual-path e-filing: API primary + file export — BOTH paths prepared simultaneously, NOT sequential fallback
- SLA: Alert 15min → Escalate 1h → File path active at 2h

---

### BC-10: Audit & Observability

**Responsibility**: Capture immutable audit trail cho mọi TR entity, phát hiện anomaly, hỗ trợ compliance reporting.

**Aggregates**:
- `AuditRecord` — Immutable, append-only; không ai có thể update/delete

**External Dependencies**:
- Tất cả BC trong TR module (event source)

**Published Events**:
- `AuditRecordCreated`
- `AnomalyDetected`
- `ComplianceReportGenerated`
- `UnauthorizedAccessAttempted`

**Integration Pattern**:
- Event-driven: subscribe to all BC events
- Append-only storage (separate audit schema/database)
- External Auditor access: read-only, scoped per LegalEntity
- 7-year retention minimum; indefinite for executive compensation

---

## Context Map Relationships

| BC Source | BC Target | Relationship Type | Integration Pattern | Ghi chú |
|-----------|-----------|------------------|---------------------|---------|
| CO Module | BC-01 Compensation | Upstream/Downstream | Kafka events + REST query | Worker, WorkingRelationship, Grade feeds |
| CO Module | BC-03 Variable Pay | Upstream/Downstream | Kafka events | Worker/WorkingRelationship eligibility |
| CO Module | BC-04 Benefits | Upstream/Downstream | Kafka events | Eligibility check, QLE triggers |
| CO Module | BC-06 Offer Mgmt | Upstream/Downstream | Event (OfferAccepted → onboarding) | Offer accepted triggers CO onboarding |
| BC-01 Compensation | BC-02 Calculation | Customer/Supplier | Sync API call (CalculationEnginePort) | BC-01 invokes BC-02 for proration, FX |
| BC-03 Variable Pay | BC-02 Calculation | Customer/Supplier | Sync API call | Formula execution, FX conversion |
| BC-04 Benefits | BC-02 Calculation | Customer/Supplier | Sync API call | Deduction amount calculation |
| BC-06 Offer Mgmt | BC-02 Calculation | Customer/Supplier | Sync API call | Min wage validation |
| BC-01 Compensation | BC-08 Taxable Bridge | Published Language | Kafka event | SalaryChanged, DeductionCreated |
| BC-03 Variable Pay | BC-08 Taxable Bridge | Published Language | Kafka event | BonusApproved, EquityVested |
| BC-04 Benefits | BC-08 Taxable Bridge | Published Language | Kafka event | BenefitInKind events |
| BC-05 Recognition | BC-08 Taxable Bridge | Published Language | Kafka event | TaxableRecognitionCreated |
| BC-08 Taxable Bridge | Payroll Module | Published Language | Kafka + daily batch | SLA: 15-min ack window |
| BC-08 Taxable Bridge | BC-09 Tax | Customer/Supplier | Sync read | Taxable items for tax calculation |
| BC-09 Tax | Tax Authority | External System | Dual-path API + file | Both paths always ready |
| BC-04 Benefits | Benefits Carriers | External System | EDI 834 | Webhook + 15-min polling fallback |
| BC-06 Offer Mgmt | E-Signature Providers | External System | Multi-provider abstraction | Webhook + 15-min polling |
| All BCs | BC-10 Audit | Observer | Kafka event stream | Append-only capture |
| BC-01, 03, 04, 05 | BC-07 TR Statement | Anti-Corruption Layer | Aggregation read API | Read-only, no write-back |

---

## Anti-Pattern Checks

| Anti-Pattern | Status | Ghi chú |
|---|---|---|
| God Context | PASS — 10 BCs có ranh giới rõ ràng | BC-01 vẫn lớn nhưng cohesive xung quanh compensation lifecycle |
| Anemic Domain | PASS — mỗi BC có behavior, không chỉ data | CalculationEngine, EligibilityEngine, ProrationEngine là behavior-rich |
| Context Overlap | PASS — TaxableItem thuộc BC-08, Tax bracket thuộc BC-09 | Ranh giới rõ: Bridge vs Compliance |
| Shared Kernel Abuse | PASS — ConfigScope là shared infrastructure, không phải shared domain | Owned by comp_core schema |

---

*Bounded Contexts — Total Rewards / xTalent HCM — Step 3 Domain Architecture*
*2026-03-26*
