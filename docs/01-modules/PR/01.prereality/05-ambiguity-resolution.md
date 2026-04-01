# Payroll Module — Ambiguity Resolution Document

**Artifact**: 05-ambiguity-resolution.md
**Module**: Payroll (PR)
**Date**: 2026-03-27
**Version**: 1.0
**Status**: Awaiting stakeholder sign-off

---

## META CONDITION (applies to every decision in this document)

> The solution must be **flexible and configurable**. ALL business rules, legal requirements, pay methods, rates, thresholds, and calculation logic must be **modeled as data** and **configurable via parameters, rules, and configuration** — not hardcoded in application code. Every time a decision is made about how something works, the answer must include: "...and this is controlled by a config parameter / rule / formula."

Every recommended option below has been chosen with this condition as the primary selection criterion.

---

## Section 1: Architecture and Ownership Decisions

---

### AQ-01: TR/PR Boundary — Who Owns Calculation Logic

**Ambiguity Score**: 0.9 (Critical)

**Question**: Who owns calculation rule definitions — Total Rewards (`calculation_rule_def`, `basis_calculation_rule`, `tax_calculation_cache`) versus Payroll (`statutory_rule`, formula engine)?

**Context**: The current DBML has calculation tables in both TR and PR. If both modules maintain independent calculation logic for the same statutory rates (SI ceiling, PIT brackets), a change to one module will not automatically propagate to the other.

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | TR owns all calculation rules; PR is a calculation consumer only — calls TR APIs to get computed values | Yes — single source of truth, but PR loses autonomy; tight coupling |
| B | PR owns all statutory calculation logic (`statutory_rule`, formula engine); TR becomes a compensation data provider only | Yes — PR has a self-contained rule engine with versioned rules; TR provides raw amounts |
| C | Shared calculation service — a third module (e.g., `calc-engine`) owned by platform team serves both TR and PR | Yes — maximum reuse; requires platform team capacity and ownership commitment |
| D | Dual ownership with a formal contract — TR owns HR-policy rules (compensation bands, bonus eligibility), PR owns statutory rules (PIT, SI, OT multipliers) | Yes — each domain owns what it understands; boundary enforced by ADR |

**Recommended Option**: Option D -> đồng ý optopn D

**Rationale**: HR-policy rules (what to pay) and statutory rules (how to withhold taxes and contributions) are fundamentally different domains. TR has domain authority over compensation policy; PR has domain authority over Vietnamese labor law compliance. Option D creates a clean boundary: TR manages compensation amounts and HR-policy formulas; PR manages all statutory calculation logic. This avoids both tight coupling (Option A/C) and duplication (Option B).

**Config Mechanism**: An Architecture Decision Record (ADR) defines the canonical list of entities owned by each module. `statutory_rule` records with `module_owner = "PR"` are created and versioned within the PR module only. `calculation_rule_def` records with `module_owner = "TR"` remain in TR. A platform-level event contract defines how TR compensation snapshots are delivered to PR at payroll cut-off — as data, not as executable rules.

**Decision Owner**: Architecture Lead + TR Team Lead + PR Team Lead. Must be signed before Sprint 1.

---

### AQ-02: PayProfile Schema — What Does PayProfile Contain

**Ambiguity Score**: 0.8 (High)

**Question**: The current DBML `pay_profile` table contains only `code`, `name`, `legal_entity_id`, `market_id`. The conceptual design promises a much richer "bundle" — component mappings, rule bindings, deduction policies, payment methods, proration methods, minimum wage region. What exactly must PayProfile contain before BRD story writing begins?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Minimal schema — PayProfile is just a named container; all bindings are on separate join tables (PayProfileElement, PayProfileRule) | Yes — maximum flexibility; nothing is hardcoded on the profile itself |
| B | Embedded schema — PayProfile contains all configuration as JSON columns (`element_bindings`, `deduction_priority`, `proration_config`) | Yes — simpler queries; harder to index and validate individual fields |
| C | Rich relational schema — PayProfile has explicit columns for: `pay_method`, `proration_method`, `rounding_method`, `min_wage_region`, `payment_method`, `parent_profile_id`; plus join tables for element bindings and rule bindings | Yes — each field is a configurable parameter; clear validation rules per field |
| D | Two-tier model — a lean `pay_profile` core plus a `pay_profile_config` JSONB extensions table for less common settings | Yes — stable core is relational; flexible extensions are JSONB |

**Recommended Option**: Option C -> đồng ý option C

**Rationale**: PayProfile is the central configuration object for an entire group of workers. Making its key parameters explicit relational columns (rather than opaque JSON) enables: (a) validation at the DB level, (b) querying by region or payment method without JSON parsing, (c) clear foreign key relationships to statutory tables. Option A is too loose — it pushes too much logic into join tables. Option B is opaque. Option C gives clarity without over-engineering.

**Config Mechanism**: Each PayProfile field is a configurable parameter. `pay_method` is an enum column (`MONTHLY_SALARY`, `HOURLY`, `PIECE_RATE`, `GRADE_STEP`, `TASK_BASED`). `min_wage_region` is a foreign key to `statutory_rule` region table. `proration_method` is an enum (`CALENDAR_DAYS`, `WORK_DAYS`, `NONE`). `rounding_method` is an enum (`ROUND_HALF_UP`, `ROUND_DOWN`, `ROUND_UP`). No default behavior is hardcoded in the engine — all defaults are stored as named configuration in a `pay_profile_defaults` system config table.

**Decision Owner**: PR Technical Lead + Database Architect. Must be completed before BRD story writing begins.

---

### AQ-03: Worker Identity Model — How Does PR Reference Workers

**Ambiguity Score**: 0.7 (High)

**Question**: Does the Payroll module reference workers via `worker_id` directly, via `working_relationship_id`, or via a PR-local concept like `payroll_assignment_id`? The xTalent CO model uses `working_relationship` as the primary employment context object.

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | PR references `worker_id` directly — simpler foreign key, but misses employment context (contract type, legal entity, cost center) | No — worker_id alone does not carry the statutory eligibility information needed |
| B | PR references `working_relationship_id` as the primary key — this carries contract type, legal entity, effective dates, and eligibility context | Yes — all payroll decisions (SI eligibility, PIT residency, OT eligibility) can be derived from the working_relationship record |
| C | PR introduces its own `payroll_enrollment` record that references both `worker_id` and `working_relationship_id` — providing a PR-local snapshot of the worker's payroll-relevant attributes at the time of enrollment | Yes — PR is decoupled from CO schema changes; enrollment snapshot is versioned per payroll period |
| D | PR references `working_relationship_id` for live queries AND creates a `compensation_snapshot` at cut-off that captures all relevant attributes — hybrid approach | Yes — live link for active management; immutable snapshot for locked periods |

**Recommended Option**: Option D -> đồng ý option D

**Rationale**: Payroll has two modes: live administration (where changes to the working_relationship must immediately be visible) and locked period calculation (where results must be reproducible regardless of subsequent CO changes). Option D supports both modes: live queries use `working_relationship_id` as the join key; locked period calculations use the immutable `compensation_snapshot` created at cut-off. This is the industry-standard pattern (Oracle HCM's "snapshot at process time").

**Config Mechanism**: A configurable `SNAPSHOT_POINT` setting on the PayCalendar determines when the compensation snapshot is taken (e.g., `CUT_OFF_DATE` or `PERIOD_END_DATE`). The snapshot includes: `contract_type`, `legal_entity_id`, `cost_center_id`, `grade_code`, `dependent_count`, `nationality_code`, `base_salary`, all active allowance amounts. Snapshot structure is defined in the PR data model; the trigger is a configurable calendar event.

**Decision Owner**: PR Technical Lead + CO Team Lead. All new PR schema objects must use `working_relationship_id` not `employee_id`.

---

### AQ-04: Formula Governance Process — How Does Formula Studio Approval Work

**Ambiguity Score**: 0.5 (Medium)

**Question**: The requirements specify a `DRAFT → PENDING_APPROVAL → APPROVED → ACTIVE → DEPRECATED` lifecycle, and Finance Lead role approval. But the actual UI flow, notification chain, and escalation path are not defined.

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Single-approver gate — Finance Lead reviews and approves/rejects. Simple, fast, minimal configuration | Partially — role is configurable but the workflow is fixed to one level |
| B | Two-level gate — PR Admin submits → Finance Lead approves → System activates. Each level gets email notification with diff view | Yes — roles at each level are configurable; notification templates are configurable |
| C | Configurable multi-level workflow — each PayGroup can define its own approval chain (1–3 levels) with configurable role assignments and timeout policies | Yes — fully configurable per PayGroup; can be as simple or complex as needed |
| D | Formula activation is gated by simulation result — a formula must pass simulation against the last 3 periods before it can be sent for approval. Approval then is a lightweight confirmation of simulation review | Yes — simulation period count is configurable; the gate condition is data-driven |

**Recommended Option**: Option C (with Option D's simulation gate as a required pre-condition before submitting for approval) -> workflow sẽ config bằng temporal nên chúng ta không cần quan tâm yếu tố workflow ở đây

**Rationale**: Different organizations will have different governance maturity. A startup with 3 people in HR does not need 3 approval levels; a bank with 5,000 employees may require the CFO to sign off on formula changes. Making the workflow configurable per PayGroup satisfies both. The simulation gate (Option D) is not an alternative — it should be mandatory before any formula can be submitted for approval, regardless of the approval chain configuration.

**Config Mechanism**: A `formula_approval_workflow_config` table defines: `pay_group_id`, `level`, `required_role`, `notification_template_id`, `timeout_hours`, `escalation_role`. A `formula_simulation_gate_config` defines: `min_simulation_periods` (default: 3), `max_variance_threshold_pct` (default: 5%). Both are configurable per PayGroup and override-able at the tenant level.

**Decision Owner**: PR Product Owner + Security Lead. Must be defined before Formula Studio is built (V2).

---

### AQ-05: Bank File Generation — Automated API vs Manual File Upload

**Ambiguity Score**: 0.5 (Medium)

**Question**: Should V1 generate bank payment files for manual upload to the bank portal, or should it support automated API-based payment push to bank systems?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | V1: Manual file generation only — system generates VCB/BIDV/TCB formatted CSV/XML files; finance team uploads manually to bank portal | Yes — file format is a configurable template per bank; no bank API integration needed |
| B | V1: Automated API push to banks that have open APIs (some banks have corporate banking APIs) — requires bank partnership agreements | Partially — requires bank-specific API configuration but bypasses manual step |
| C | V1: Manual file generation; V2: Automated API — phased approach with a clean abstraction layer (BankPaymentGateway interface) so V2 implementation does not require engine changes | Yes — gateway interface is configurable; V1 implementation is file-based, V2 is API-based |
| D | V1: Both options available via configuration — a `payment_channel` config on PayGroup determines whether to generate file or call API. Banks without API support use file; banks with API support use API | Yes — `payment_channel` is a configurable parameter per PayGroup with values: `FILE_MANUAL`, `API_PUSH` |

**Recommended Option**: Option C -> tôi chọn D, chúng ta cần thiết kế đủ, còn việc chia phase implement là của dev trong timeline không phải là lựa chọn của product.

**Rationale**: Automated bank API integration requires formal partnership agreements, security certification, and bank-specific testing — none of which are in scope for V1. However, the engine should be built with a `BankPaymentGateway` interface from day one so that V2 can add API implementations without changing the payroll engine. Option D is the end-state architecture; Option C is the pragmatic V1 path to it.

**Config Mechanism**: A `bank_payment_config` table stores: `bank_code`, `file_format_template_id`, `file_encoding`, `column_mapping_json`. File format templates are configurable data (not hardcoded), so when a bank changes their file format, only the template data needs updating. The `BankPaymentGateway` interface is an internal abstraction; V1 implementation class is `FileBasedBankPaymentGateway`.

**Decision Owner**: PR Product Owner + Finance stakeholder from pilot customer. Must be validated with pilot customer before sprint planning.

---

## Section 2: Data Source and Integration Decisions

---

### AQ-06: Dependent Registration — Where Are Dependents Registered for PIT

**Ambiguity Score**: 0.6 (Medium)

**Question**: Workers in Vietnam may register dependents for PIT deduction (4.4M VND per registered dependent per month). Where is this data managed — in the CO system, in a separate HR process, or in the Payroll module itself?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Dependents registered in CO (Core HR) module — PR reads `dependent_count` from the working_relationship or worker profile via CO API | Yes — CO is the system of record; PR is a consumer; dependent_count is an effective-dated attribute |
| B | Dependents registered in PR itself — worker submits dependent registration through a PR self-service form; PR stores and manages the data | Yes — PR owns the data; but creates data duplication with CO; may conflict with CO's HR data |
| C | Hybrid — CO stores dependent personal details (name, relationship, ID number for compliance); PR reads only the aggregated `registered_dependent_count` and its effective date | Yes — CO is the system of record for data; PR gets a clean, versioned integer count; clear data ownership |
| D | External paper process — workers submit Form 02/ĐK-NPT-TNCN to the tax authority; HR enters the approved count into CO; PR reads from CO | This is the current real-world process in Vietnam; Option C describes the data flow correctly |

**Recommended Option**: Option C -> đồng ý C

**Rationale**: CO is the canonical HR data store. Personal dependent information (birth certificates, ID numbers) belongs in CO's worker/family records for compliance purposes. PR does not need the detail — it only needs the count and the date from which it is effective. Option C creates the cleanest integration: CO provides `registered_dependent_count` as an effective-dated attribute; PR's compensation snapshot captures it at cut-off. This matches the actual Vietnamese administrative process (Option D is not an alternative — it is the reality that Option C models correctly).

**Config Mechanism**: A configurable `DEPENDENT_SOURCE` parameter on the PayProfile specifies where dependent count is read from: `CO_API` (default for integrated deployments) or `PR_OVERRIDE` (for standalone deployments where CO integration is not yet live, allowing manual entry in PR). The CO API endpoint and field name are configurable parameters in the integration config.

**Decision Owner**: CO Team Lead + PR Team Lead. Required before PIT calculation sprint.

---

### AQ-07: Holiday Calendar Source — Who Owns the Public Holiday Calendar

**Ambiguity Score**: 0.6 (Medium)

**Question**: OT premium calculation requires knowing whether a given day is a public holiday (300% rate) vs. weekend (200%) vs. weekday (150%). Where is the authoritative holiday calendar maintained — in CO, TR, or PR?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | CO owns the holiday calendar — it is a general HR reference used for leave management, attendance, and scheduling as well as payroll | Yes — single source of truth across modules; CO manages and version-controls the calendar |
| B | PR owns its own holiday calendar — since it directly impacts payroll calculation, PR manages a `payroll_holiday_calendar` table independently | Yes — PR is self-contained; but creates duplication with CO's leave calendar; calendar changes must be made twice |
| C | Shared reference module — a platform-level `reference-data` service owns holiday calendars; CO, TA, and PR all query it | Yes — maximum reuse; requires platform service; may be over-engineering for V1 |
| D | PR reads from CO via API and caches the calendar locally at the start of each payroll period — PR is the consumer, CO is the master | Yes — CO owns; PR caches for performance; cache invalidated when CO calendar changes; configurable cache refresh policy |

**Recommended Option**: Option D (with Option A as the ownership principle) -> đồng ý option C nhưng tôi đang chọn TA giữ calendar rồi nên PR sẽ đọc từ TA.

**Rationale**: The holiday calendar is definitively an HR/CO domain — it is used for leave accrual, absence management, and attendance tracking. PR should not own a separate copy. However, for performance (PR should not make CO API calls mid-calculation for every work day check), PR caches the calendar at period start. The cache refresh trigger is configurable.

**Config Mechanism**: A `holiday_calendar_config` on the PayGroup specifies: `source_module` (`CO` or `PR_LOCAL`), `jurisdiction_code` (e.g., `VN_NATIONAL`, `VN_HCM_CITY`), `cache_refresh_trigger` (`PERIOD_START`, `MANUAL`, `CO_EVENT`). For V1 where CO integration may not be complete, a `PR_LOCAL` fallback allows the admin to maintain the calendar within PR. The calendar data itself is a configurable table, not hardcoded dates.

**Decision Owner**: Platform Architecture + CO Team Lead + PR Team Lead. Must resolve before OT premium calculation sprint.

---

## Section 3: Scope and Feature Decisions

---

### AQ-08: Multi-Entity Consolidated Reporting — Per-Entity Only vs Cross-Entity Rollup

**Ambiguity Score**: 0.4 (Low-Medium)

**Question**: Should V1 Payroll provide reports that roll up across multiple legal entities in a group (e.g., total payroll cost for the holding company), or only per-entity reports?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Per-entity reports only in V1 — each legal entity's data is isolated; no cross-entity aggregation | Yes — simpler; respects data isolation; V2 adds rollup |
| B | Cross-entity rollup in V1 — group-level reports for Finance leadership of holding companies | Yes — requires explicit role permission granting cross-entity read access; configurable report scope |
| C | Per-entity reports in V1, but build the data model and API to support cross-entity query in V2 — phased approach | Yes — V1 is clean; V2 extensions do not require schema changes |

**Recommended Option**: Option A with Option C's architecture constraint -> chọn option C, chúng ta thiết kế đủ; còn implement do dev, không quyết định phase này kia trong product

**Rationale**: Cross-entity reporting requires a separate permission model (not all payroll admins should see group-level data) and potentially complex data aggregation logic. For V1 serving pilot customers, per-entity reporting is sufficient. However, the data model must not preclude V2 cross-entity queries — `legal_entity_id` must be consistently indexed on all result tables.

**Config Mechanism**: A `report_scope_config` at the tenant level defines available report scopes: `SINGLE_ENTITY` (V1 default) or `MULTI_ENTITY` (V2 feature flag). Enabling `MULTI_ENTITY` requires explicit role assignment: `CROSS_ENTITY_REPORT_VIEWER` role. Report queries are parameterized by `legal_entity_ids[]` — V1 always passes a single-element array; V2 passes multiple.

**Decision Owner**: PR Product Owner. Confirmed in V1/V2 scope review.

---

### AQ-09: PIT Annual Settlement — Automatic vs Admin-Triggered, Timing

**Ambiguity Score**: 0.4 (Low-Medium)

**Question**: Vietnamese law allows annual PIT settlement (quyết toán thuế TNCN). Should the system trigger this automatically at year-end, or require an admin to manually trigger it? And when exactly — December payroll, January standalone, or both?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Admin-triggered only — admin manually initiates the annual settlement run at their chosen time | Yes — most flexible; admin controls timing; no risk of auto-run at wrong time |
| B | Automatic trigger — system schedules annual settlement to run on a configured date (e.g., January 10th) | Yes — configurable date; reduces admin workload; risk if data is not ready on scheduled date |
| C | Configurable — settlement can be run either as part of December payroll (adds settlement delta to December payslip) or as a standalone January run (separate settlement payslip) — admin selects the mode per PayGroup | Yes — `SETTLEMENT_TIMING` config on PayGroup: `DECEMBER_PAYROLL` or `JANUARY_STANDALONE`; admin-triggered in both modes |
| D | Both — system auto-generates a settlement preview in January; admin reviews and approves before any adjustments are applied | Yes — automated preview, human-in-the-loop for final approval; configurable preview generation date |

**Recommended Option**: Option C -> đồng ý, việc này tuỳ theo enterprise và product cần support cho các lựa chọn

**Rationale**: Different companies have different year-end processes. Some close their books in December and want settlement included in December payroll. Others prefer a standalone January settlement for cleaner period separation. Making the mode configurable per PayGroup (Option C) satisfies both. Admin must always explicitly trigger the settlement run — no fully automatic execution without admin review, consistent with the approval workflow principle.

**Config Mechanism**: `SETTLEMENT_TIMING` is a configurable parameter on the PayGroup with values: `DECEMBER_PAYROLL` (settlement delta added as a RETRO_ADJUSTMENT element in December) or `JANUARY_STANDALONE` (settlement generates a separate off-cycle run in January). Settlement run always requires admin initiation and approval workflow completion. The settlement formula logic is a configurable statutory rule, not hardcoded.

**Decision Owner**: PR Product Owner + Finance stakeholder. Default recommendation: `JANUARY_STANDALONE`.

---

### AQ-10: Termination Payroll — What Does the Final-Pay Run Include

**Ambiguity Score**: 0.3 (Low)

**Question**: When a worker terminates, a final-pay run is triggered. What components must it include, and how are they calculated?

#### Options

| Option | Description | Configurable? |
|--------|-------------|:-------------:|
| A | Minimal final pay — pro-rated base salary only for days worked in the final month. Severance and leave payout are separate, manual calculations outside the system | No — incomplete; misses legally required components |
| B | Standard final pay — pro-rated salary + accrued but untaken annual leave payout (nghỉ phép chưa nghỉ) + any approved separation allowance elements | Yes — each component is a configurable PayElement of type TERMINATION_EARNING |
| C | Full final pay — pro-rated salary + accrued leave + 13th month pro-rata for the year + any outstanding RETRO_ADJUSTMENT deltas + severance calculation (if applicable under Labor Code) | Yes — each component is a configurable PayElement; severance formula references tenure and contract type; all rates are statutory_rule parameters |
| D | Configurable scope per PayProfile — `termination_pay_elements` config defines which elements are included for each termination type (resignation, mutual agreement, reduction in force, end of contract) | Yes — maximum flexibility; HR policy decisions about termination pay are data-configurable, not hardcoded |

**Recommended Option**: Option D -> đồng ý 

**Rationale**: Termination pay rules vary significantly by: (a) reason for termination (resignation vs. layoff vs. contract expiry), (b) length of service, (c) company policy on 13th-month pro-rata. Option D models this correctly: the system has a general TERMINATION run type, and the specific elements included are configured per termination type. The formula for each element (e.g., leave payout = remaining_leave_days × daily_rate) is a configurable formula, not hardcoded.

**Config Mechanism**: A `termination_pay_config` table maps `termination_type` × `pay_profile_id` → `[list of PayElement codes to include]`. Each element included in termination pay has a formula that can reference `termination_date`, `tenure_months`, `remaining_leave_days`, and other configurable statutory rule parameters. Severance calculation (trợ cấp thôi việc) is a configurable PayElement with formula: `tenure_years × 0.5 × average_monthly_salary` (where the 0.5 coefficient is a statutory_rule parameter that can be updated if the law changes).

**Decision Owner**: PR Product Owner + HR Legal/Compliance. Severance formula must be validated by legal counsel before activation.

---

## Section 4: Open Questions Resolution (OQ-1 through OQ-8)

---

### OQ-1: Will TR Team Accept Re-Scoping of calculation_rule_def to PR?

**Original Question**: Will the TR team accept that `calculation_rule_def` and `basis_calculation_rule` are re-scoped to PR ownership? (Blocking — Sprint 1)

**Options**:

| Option | Description |
|--------|-------------|
| A | Full re-scope — TR deprecates `calculation_rule_def`; PR owns all calculation logic via `statutory_rule` and formula engine |
| B | Parallel ownership — TR retains `calculation_rule_def` for TR-specific compensation calculations; PR maintains `statutory_rule` for statutory deductions; clear contract defines what each provides |
| C | Phased handover — TR retains current tables through V1; PR's new statutory_rule tables run in parallel; V2 migration removes TR calculation tables after all PR formulas are validated |

**Recommended Option**: Option B (matching AQ-01 Option D recommendation above) -> phụ thuộc câu hỏi trên, implement vẫn nằm ở 2 nơi nhưng scope quy định ở logic và định nghĩa trong ADR

**Config Implications**: The ADR defines a canonical data contract. Any value that is needed by both modules (e.g., SI ceiling, minimum wage region) is owned by one module and exposed via a versioned read API. The consuming module stores a cached copy as a `statutory_rule` record with `source = "TR_API"` or `source = "PR_LOCAL"` — configurable per deployment.

**Status**: Blocking. Must be resolved before Sprint 1. Owner: Architecture Lead.

---

### OQ-2: Do V1 Pilot Customers Have Foreign National Workers?

**Original Question**: Do any V1 pilot customers have foreign national (non-tax-resident) workers? (Blocking — affects V1 scope)

**Options**:

| Option | Description |
|--------|-------------|
| A | No foreign nationals in V1 — scope to Vietnamese residents only (progressive PIT, SI-eligible) |
| B | Foreign nationals present — must include non-resident path (20% flat PIT, SI eligibility per work permit type) |
| C | Build non-resident path in V1 as a configurable flag (`tax_residency_status` on worker snapshot), but only fully test Vietnamese resident path |

**Recommended Option**: Option C -> chọn C, chúng tôi có dạng expat, và lại có cả chi nhánh nước ngoài

**Config Implications**: A `tax_residency_status` field on the compensation snapshot (values: `RESIDENT`, `NON_RESIDENT`) drives PIT calculation path selection. The non-resident rate (currently 20%) is a `statutory_rule` parameter — not hardcoded — so if Vietnam changes the flat rate, only the statutory rule record needs updating. Non-resident SI eligibility rules are also configurable via `si_eligibility_rule` by contract type and residency status.

**Status**: Must be confirmed by Customer Success / Pre-sales before V1 launch.

---

### OQ-3: Do V1 Pilot Customers Require Bi-Weekly or Semi-Monthly Payroll?

**Original Question**: Do any V1 pilot customers require bi-weekly or semi-monthly payroll? (Blocking — affects frequency scope)

**Options**:

| Option | Description |
|--------|-------------|
| A | Monthly only in V1 — confirmed assumption; pilot customers are monthly |
| B | Include bi-weekly — requires PayCalendar to support 26-period annual cycle |
| C | Build `frequency` as a configurable enum on PayCalendar (`MONTHLY`, `SEMI_MONTHLY`, `BIWEEKLY`) but only activate `MONTHLY` in V1; others are feature-flagged |

**Recommended Option**: Option C -> chọn C, đều phải chấp nhận dưới dạng cấu hình

**Config Implications**: `pay_frequency` is a configurable parameter on PayCalendar. V1 only activates `MONTHLY`. The feature flag `PAYROLL_FREQUENCY_MULTI` gates non-monthly frequencies. When enabled (V2), the YTD accumulator reset logic, PIT proration logic, and SI ceiling calculation must be adjusted — all driven by the frequency parameter, no code changes required.

**Status**: Must be confirmed by Customer Success / Pre-sales before sprint planning.

---

### OQ-4: Where Are Worker Dependents Registered for PIT Purposes?

**Original Question**: Where are worker dependents registered for PIT purposes? (Blocking — affects PIT calculation data source)

This question is fully resolved in AQ-06 above. See Section 2 recommendation: Option C (CO is the system of record; PR reads `registered_dependent_count` as an effective-dated attribute via CO API or compensation snapshot).

**Config Implications**: Same as AQ-06. `DEPENDENT_SOURCE` parameter on PayProfile.

**Status**: Resolved by AQ-06. Owner: CO Team Lead + PR Team Lead.

---

### OQ-5: Who Owns the Public Holiday Calendar?

**Original Question**: Who owns the public holiday calendar — CO, PR, or TR? (Moderate — affects OT premium calculation)

This question is fully resolved in AQ-07 above. See Section 2 recommendation: Option D (CO owns; PR caches with configurable refresh trigger).

**Config Implications**: Same as AQ-07. `holiday_calendar_config` on PayGroup. -> calendar ở TA module

**Status**: Resolved by AQ-07. Owner: Platform Architecture + CO Team Lead.

---

### OQ-6: What Is the Target Deployment Infrastructure?

**Original Question**: What is the target deployment infrastructure (cloud provider, JVM specs, database)? (Blocking — affects performance SLA validation)

**Options**:

| Option | Description |
|--------|-------------|
| A | Cloud-native on AWS (EKS/RDS) — standard enterprise cloud deployment |
| B | Cloud-native on GCP or Azure |
| C | On-premises deployment — customer-managed servers in Vietnam data center |
| D | Hybrid — cloud for SaaS customers, on-premises for enterprise self-hosted |

**Recommended Option**: Option D -> chọn D, việc này tuỳ theo khách hàng lựa chọn, giải pháp phải support all

**Config Implications**: Infrastructure-level configuration parameters must be externalizable (not hardcoded in application code): JVM heap size, database connection pool size, Drools KieSession parallelism factor, batch partition size. These are all configurable via environment variables or a `runtime_config` table, so the same application binary can run on different infrastructure profiles without code changes.

**Status**: Must be confirmed by Infrastructure / DevOps team. Performance SLA load test (Phase 0 gate) depends on this answer.

---

### OQ-7: Is Automated Bank API Integration Required by Any V1 Customer?

**Original Question**: Is automated bank API integration (direct payment push) required by any V1 customer? (Blocking — affects payment scope)

This question is resolved in AQ-05 above. See Section 1 recommendation: Option C (manual file generation in V1; `BankPaymentGateway` interface prepared for V2 API push).

**Config Implications**: Same as AQ-05. `bank_payment_config` table with `file_format_template_id` per bank.

**Status**: Must be confirmed by Product Manager + Customer Success before sprint planning.

---

### OQ-8: What Is the Required Payslip Language?

**Original Question**: What is the required payslip language — Vietnamese only, English only, or bilingual? (Non-blocking — affects payslip template design)

**Options**:

| Option | Description |
|--------|-------------|
| A | Vietnamese only in V1 |
| B | English only |
| C | Bilingual Vietnamese/English (two columns or two pages) |
| D | Configurable per PayGroup — `payslip_language` config determines language(s) |

**Recommended Option**: Option D -> đồng ý config được, tuỳ theo enterprise lựa chọn, họ có thể chọn chung, chọn theo quốc gia, theo legal entities, hay theo language của employee, hoặc chọn dual language, multi language

**Config Implications**: A `payslip_template_config` on the PayGroup specifies: `language_mode` (values: `VI_ONLY`, `EN_ONLY`, `BILINGUAL`), `template_id` (references a configurable template record). Element display names have localization records (`element_name_vi`, `element_name_en`) — all configurable data, not hardcoded strings. V1 default is `VI_ONLY`; bilingual is activated when `BILINGUAL_PAYSLIP` feature flag is enabled.

**Status**: Non-blocking. Default to `VI_ONLY` for V1. Owner: PR Product Owner.

---

## Section 5: Pay Method Type Decisions

---

### AQ-11: Pay Basis / Pay Method Types — What Pay Methods Must xTalent Payroll Support

**Ambiguity Score**: NEW (not in original audit)

**Question**: The current model assumes all workers are on monthly salary (`BASE_SALARY`). Real Vietnamese enterprises have workers on fundamentally different pay bases — hourly, piece-rate, grade-step, and task-based. How should these be supported?

#### Options

| Option | Description | How is this configurable? |
|--------|-------------|--------------------------|
| A | Support all 5 pay methods in V1 via a configurable `PAY_METHOD` field on PayProfile / PayElement | `PAY_METHOD` is an enum column on `pay_profile`; the formula set applied to gross calculation is determined by `PAY_METHOD` value; each method maps to a named formula group in `formula_config` table |
| B | Support Monthly + Hourly in V1 (covers 80%+ of cases), defer piece-rate and pay-scale to V2 | `PAY_METHOD` enum exists with all 5 values in V1 schema; only `MONTHLY_SALARY` and `HOURLY` have active formula sets; others return validation error "not yet supported" — controlled by a `supported_pay_methods` feature config |
| C | Model ALL pay methods in V1 schema but only build formulas for Monthly; others are custom formulas (HR configures the formula manually for their specific use case) | `PAY_METHOD` drives which formula template is loaded; templates exist for all 5 methods but non-Monthly templates have empty bodies — HR/developer fills in formulas in Phase 1; controlled by `formula_template_status` config per method |
| D | Implement a generic "Pay Method Engine" — each pay method is a named formula set (a collection of formulas for gross, SI basis, PIT basis, proration); engine is fully extensible | `pay_method_engine_config` table maps `pay_method_code` → `formula_set_id`; formula sets are configurable data; new pay methods can be added by creating a new `formula_set` record without code changes |

**Recommended Option**: Option D (with Option C as fallback if Option D is too complex for V1 delivery timeline) -> đồng ý D

**Rationale**: The Pay Method Engine approach (Option D) is the only option consistent with the META CONDITION. It treats pay methods as data: a pay method is a named collection of formula references (gross formula, SI basis formula, PIT basis formula, proration formula). Adding a new pay method requires creating configuration records, not writing code. Option B is pragmatic for V1 scope management but creates a schema/code divergence that must be cleaned up in V2.

**Config Mechanism**:
- `pay_method_def` table: `code` (MONTHLY_SALARY / HOURLY / PIECE_RATE / GRADE_STEP / TASK_BASED), `gross_formula_id`, `si_basis_formula_id`, `pit_basis_formula_id`, `proration_formula_id`, `min_wage_floor_formula_id`, `is_active` (feature flag per method).
- PayProfile has `pay_method_code` (FK to `pay_method_def`).
- The engine resolves which formula to execute based on PayProfile's `pay_method_code` — no code-level switch statements.

**Decision Owner**: PR Technical Lead + PR Product Owner. Architecture decision — must be made before sprint planning.

---

### AQ-12: Hourly Rate Differentiation — How Is Hourly Rate Determined

**Ambiguity Score**: NEW

**Question**: When a worker is on hourly pay (`PAY_METHOD = HOURLY`), how is their hourly rate determined? Real scenarios include different rates by shift type, work category, grade, and over time.

#### Options

| Option | Description | How is this configurable? |
|--------|-------------|--------------------------|
| A | Single hourly rate per worker, stored in compensation snapshot | `hourly_rate` is a field in the compensation snapshot; one value per worker per period; changed via CO/TR compensation update; no differentiation by shift type |
| B | Hourly rate table per worker with dimensions: `shift_type` × `work_category` | A `worker_hourly_rate` table stores `(worker_id, shift_type, work_category, rate, effective_date)`; formula references this table via a `lookupRate(shift_type, work_category)` function; rates are configurable data |
| C | Hourly rate driven by pay_element formula — each hour type is a separate PayElement (`REGULAR_HOURS`, `NIGHT_HOURS`, `OT_WEEKEND_HOURS`) with its own formula and rate parameter | Each element has a configurable rate parameter in `pay_element.metadata_json`; rate is a statutory_rule or config parameter; fully extensible for any number of hour types |
| D | Rate table config at PayProfile level (default rates for the profile) with worker-level rate multiplier override | `pay_profile_hourly_rate_config` stores default rates by shift type; worker's `compensation_snapshot` has an optional `hourly_rate_multiplier` (default 1.0); effective rate = profile_default_rate × worker_multiplier; both are configurable |

**Recommended Option**: Option D -> chọn hybrid C+D

**Rationale**: Most hourly workers within the same PayGroup share similar base rate structures (e.g., all factory floor workers have the same night shift premium percentage). Managing a per-worker rate table (Option B) creates high administrative overhead when there are thousands of workers. Option D provides profile-level defaults (easy to configure once for the group) with individual multipliers for workers who merit a different rate. This is the configurable, low-maintenance approach.

**Config Mechanism**:
- `pay_profile_rate_config` table: `pay_profile_id`, `rate_dimension` (REGULAR / NIGHT / OT_WEEKDAY / OT_WEEKEND / OT_HOLIDAY), `base_rate_vnd`, `effective_date`.
- `compensation_snapshot.hourly_rate_multiplier` (BigDecimal, default 1.00); workers with above/below-standard rates have a non-1.0 multiplier set via CO/TR.
- Effective rate formula: `PROFILE_BASE_RATE(shift_type) * WORKER_RATE_MULTIPLIER`.
- All values are stored as configurable data; no rates are hardcoded in application logic.

**Decision Owner**: PR Technical Lead + HR/Operations lead from pilot customer.

---

### AQ-13: Piece-Rate Configuration — How Is Lương Sản Phẩm Modeled

**Ambiguity Score**: NEW

**Question**: For workers in manufacturing, garments, and assembly on piece-rate pay (lương sản phẩm / khoán sản phẩm), how is piece-rate pay computed and configured?

#### Options

| Option | Description | How is this configurable? |
|--------|-------------|--------------------------|
| A | Model as a VARIABLE_PAY element — formula references `units_produced × config_rate`; rate config stored in `pay_element.metadata_json` or `statutory_rule` | Rate is a configurable parameter on the element; formula is: `INPUT_QTY * PIECE_RATE_CONFIG`; changing the rate requires updating the element config record |
| B | Dedicated PIECE_RATE element type with a rate table `(product_code → rate_per_unit)`, imported from production system via integration | Rate table is configurable data in a `piece_rate_table` entity; product codes and rates are data records; production system pushes completed quantities via integration; all rates are stored as configuration |
| C | Generic "input variable" framework — TA or external system pushes numeric input variables (e.g., `PIECE_QTY_PRODUCT_A = 150`); payroll formula references: `PIECE_QTY_PRODUCT_A * RATE_PRODUCT_A`; both qty and rate are configurable | Input variable names are configurable (`input_variable_def` table); rates are configurable statutory_rule parameters; formulas reference variable names — adding a new product requires a new variable definition and rate config, no code change |
| D | Piece rate is a separate sub-module with its own data model separate from standard payroll | Not configurable within payroll — separate system creates coupling; harder to maintain; does not meet META CONDITION |

**Recommended Option**: Option C

**Rationale**: Option C is the most flexible and fully aligns with the META CONDITION. By treating both quantities (from TA/production) and rates (from configuration) as named variables that formulas reference, the system can handle any piece-rate structure — single product, multi-product, quality grades, team-based — without code changes. Adding a new product type is a configuration task: create a new `input_variable_def` record for the quantity, create a new `statutory_rule` or `pay_element_param` record for the rate, and update the formula to reference the new variable names.

**Config Mechanism**:
- `input_variable_def` table: `variable_code` (e.g., `PIECE_QTY_SHIRT_A`), `source` (`TA_INTEGRATION` / `MANUAL_ENTRY`), `data_type` (`DECIMAL`), `description`.
- `piece_rate_config` table: `product_code`, `quality_grade`, `rate_per_unit_vnd`, `effective_date`.
- Formula example: `PIECE_QTY_SHIRT_A * lookupRate("SHIRT", "GRADE_A") + PIECE_QTY_SHIRT_B * lookupRate("SHIRT", "GRADE_B")`.
- Minimum wage floor: a configurable `MIN_WAGE_FLOOR_RULE` is applied after piece-rate calculation — if `PIECE_TOTAL < MIN_WAGE_REGION_X`, the system substitutes `MIN_WAGE_REGION_X` and flags as an exception.
- Quality multipliers: stored as configurable `quality_grade_multiplier` records in `piece_rate_config`.

**Decision Owner**: PR Technical Lead + Operations / Manufacturing HR lead from pilot customer. Integration contract with TA/production system must be defined.

---

### AQ-14: Pay Scale Configuration — How Is Bảng Lương / Ngạch Bậc Modeled

**Ambiguity Score**: NEW

**Question**: For workers on grade-step pay scales (bảng lương theo ngạch bậc — common in government, SOEs, and large corporates), how is the salary amount determined from a worker's grade and step assignment?

#### Options

| Option | Description | How is this configurable? |
|--------|-------------|--------------------------|
| A | Pay scale table in database — `PayScale(grade_code, step_code, amount_vnd, effective_date)`; worker's CO assignment has `grade_code` + `step_code`; payroll formula does a lookup | Fully configurable: scale table is data; adding/updating rows changes pay without code deployment; effective dates allow scale version management |
| B | Formula-driven — `GRADE_COEFFICIENT * LUONG_CO_SO` where `LUONG_CO_SO` is a statutory_rule parameter (used for government/SOE workers) | Fully configurable: both `GRADE_COEFFICIENT` and `LUONG_CO_SO` are configurable parameters; government announces new `LUONG_CO_SO` → admin updates statutory_rule record → next payroll run uses new value |
| C | Integration with TR Compensation module — salary amounts flow from TR's compensation bands into PR's BASE_SALARY compensation snapshot | TR is the configurable source; PR is a consumer; no PR-side configuration of pay scale needed; but requires TR to have implemented compensation band management |
| D | Both Option A and Option B as configuration choices per PayProfile — `GRADE_STEP` pay method supports two sub-modes: `TABLE_LOOKUP` and `COEFFICIENT_FORMULA`, selected by a `grade_step_mode` config on the PayProfile | Maximum flexibility: government/SOE workers use `COEFFICIENT_FORMULA` mode; corporate workers use `TABLE_LOOKUP` mode; each is configured independently |

**Recommended Option**: Option D -> đồng ý chọn D

**Rationale**: Vietnam has two distinct grade-step models: (1) Government/SOE workers whose salary is a coefficient multiplied by the statutory base wage (lương cơ sở) — which changes by decree; and (2) Private enterprise salary bands where HR sets the grade/step amount directly in a table. Both must be supported as they coexist in the market. Option D provides both modes as configuration choices — the admin selects the mode for each PayProfile, and the formula engine applies the appropriate calculation logic.

**Config Mechanism**:
- `pay_scale_table` entity: `table_code`, `grade_code`, `step_code`, `amount_vnd` (for TABLE_LOOKUP mode) or `coefficient` (for COEFFICIENT_FORMULA mode), `effective_date`.
- `pay_profile.grade_step_mode` enum: `TABLE_LOOKUP` / `COEFFICIENT_FORMULA`.
- For COEFFICIENT_FORMULA mode: `LUONG_CO_SO` is a `statutory_rule` record (`rule_code = "VN_LUONG_CO_SO"`, `value`, `effective_date`); formula: `GRADE_COEFFICIENT(grade, step) * VN_LUONG_CO_SO`.
- For TABLE_LOOKUP mode: formula calls `lookupPayScale(table_code, grade_code, step_code, period_date)`.
- Step progression: a configurable `step_progression_rule` defines months-at-step before automatic advancement (configurable per grade_code); the rule is data, not code.
- Multiple active scale tables: `pay_profile.pay_scale_table_code` (FK) allows different PayProfiles to reference different scale tables.

**Decision Owner**: PR Technical Lead + HR lead from pilot customer. Government/SOE customers require COEFFICIENT_FORMULA mode; private enterprises require TABLE_LOOKUP mode.

---

## Decision Log

| AQ/OQ | Question | Recommended Option | Decision Owner | Status |
|--------|----------|--------------------|:--------------:|--------|
| AQ-01 | TR/PR Boundary | Option D — dual ownership with ADR | Architecture Lead + TR + PR Leads | Open |
| AQ-02 | PayProfile Schema | Option C — rich relational schema | PR Tech Lead + DB Architect | Open |
| AQ-03 | Worker Identity Model | Option D — working_relationship_id + compensation snapshot | PR Tech Lead + CO Lead | Open |
| AQ-04 | Formula Governance | Option C + Option D simulation gate | PR Product Owner + Security Lead | Open |
| AQ-05 | Bank File Generation | Option C — file V1, API V2 interface | PR Product Owner + Finance stakeholder | Open |
| AQ-06 | Dependent Registration | Option C — CO owns, PR reads count | CO Lead + PR Lead | Open |
| AQ-07 | Holiday Calendar Source | Option D — CO owns, PR caches | Platform Arch + CO Lead | Open |
| AQ-08 | Multi-Entity Reporting | Option A (V1) + Option C architecture | PR Product Owner | Open |
| AQ-09 | PIT Annual Settlement | Option C — configurable timing | PR Product Owner + Finance | Open |
| AQ-10 | Termination Payroll | Option D — configurable scope per type | PR Product Owner + HR Legal | Open |
| OQ-1 | TR/PR ADR | Option B (same as AQ-01) | Architecture Lead | Blocking |
| OQ-2 | Foreign nationals | Option C — configurable flag, VN-first | Customer Success | Confirm |
| OQ-3 | Pay frequency | Option C — configurable enum, monthly V1 | Customer Success | Confirm |
| OQ-4 | Dependent source | Resolved by AQ-06 | CO Lead + PR Lead | Open |
| OQ-5 | Holiday calendar | Resolved by AQ-07 | Platform Arch | Open |
| OQ-6 | Infrastructure | Option D — hybrid cloud/on-prem | Infrastructure / DevOps | Open |
| OQ-7 | Bank API V1 | Resolved by AQ-05 | PR Product Owner | Open |
| OQ-8 | Payslip language | Option D — configurable per PayGroup | PR Product Owner | Open |
| AQ-11 | Pay Method Types | Option D — Pay Method Engine | PR Tech Lead + Product Owner | Open |
| AQ-12 | Hourly Rate | Option D — profile defaults + worker multiplier | PR Tech Lead + HR | Open |
| AQ-13 | Piece Rate Config | Option C — input variable framework | PR Tech Lead + Operations | Open |
| AQ-14 | Pay Scale / Ngạch Bậc | Option D — TABLE_LOOKUP + COEFFICIENT_FORMULA modes | PR Tech Lead + HR | Open |

---

*All decisions in this document require stakeholder sign-off before BRD story writing begins. The META CONDITION — all business rules and logic must be configurable data, never hardcoded — applies to every decision made herein.*
