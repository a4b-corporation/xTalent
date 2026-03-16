# Time & Absence Module (TA) — Deep Analysis

**Files**:  
- `TA-database-design-v5.dbml` (1,352 lines) — V5.1, Dec 2025  
- `3.Absence.v4.dbml` (353 lines) — V4, Oct 2025  
**Assessed**: 2026-03-16

---

## 1. Schema Inventory

### File 1: TA-database-design-v5.dbml

| # | Schema | Tables | Purpose |
|:-:|--------|:------:|---------|
| 1 | `ta` (Time & Attendance) | ~18 | 6-level hierarchy + operational tables |
| 2 | `absence` | ~14 | Leave management (merged from v4) |
| 3 | `shared` | 3 | Shared components: schedule, holiday, period_profile |

### File 2: 3.Absence.v4.dbml (Standalone)

| # | Schema | Tables | Purpose |
|:-:|--------|:------:|---------|
| 1 | `absence` | ~15 | Leave management (original v4 design) |

**Tổng unique tables**: ~35 tables (sau khi deduplicate giữa 2 files)

---

## 2. Architecture Assessment — 6-Level Hierarchy

### 2.1 The Hierarchy

```
Level 1: time_segment     — Atomic time block (e.g., "08:00-12:00 = WORK")
   │
Level 2: shift_def        — Collection of segments → "Morning Shift"
   │ (via shift_segment)
Level 3: day_model         — Schedule template for a day → combines shifts
   │
Level 4: pattern_template  — Multi-day rotation → "5 days on, 2 off"
   │ (via pattern_day)
Level 5: schedule_assignment — Assign pattern to employee/group
   │
Level 6: shift (roster)    — Materialized individual shifts with full lineage
```

### 2.2 Evaluation

| Aspect | Score | Assessment |
|--------|:-----:|------------|
| **Conceptual clarity** | 4.5/5 | Clean separation of concerns — each level has clear responsibility |
| **Flexibility** | 5.0/5 | Can model any shift pattern: fixed, rotating, flexible, split |
| **Lineage tracking** | 4.5/5 | Level 6 shift tracks `pattern_template_id`, `day_model_id`, `schedule_assignment_id` |
| **Complexity** | 3.0/5 | 6 levels may be overkill for simple 9-5 scenarios |
| **Query performance** | 3.5/5 | Looking up "what shift is Employee X on March 15?" requires traversing multiple levels |

**Verdict**: Architecture là **technically excellent** cho complex shift operations. Tuy nhiên cần view/materialized view cho common queries.

**Đề xuất**:
- Add `employee_daily_schedule` view materializing all levels for date-range queries
- Document "simple setup" guide — cho org chỉ cần 1 shift type

---

## 3. Strengths (Điểm mạnh)

### 3.1 Absence Ledger Model — 5/5

Absence design sử dụng **double-entry accounting pattern**:

```
leave_class (Definition)
  → leave_instant (Account per employee)
    → leave_instant_detail (Lots — grant/carry/bonus with FEFO)
      → leave_movement (Immutable ledger entries)
```

Key features:
- **FEFO (First-Expire-First-Out)**: `priority` field trên `leave_instant_detail` cho phép trừ lot sắp hết hạn trước
- **Immutable movements**: `leave_movement` là append-only ledger — audit-friendly
- **Idempotency**: `idempotency_key` prevents duplicate processing
- **Run tracking**: `run_id` links movements to batch processing runs

→ **Đây là pattern tốt nhất** trong toàn bộ xTalent design. Accounting-grade rigorous.

### 3.2 Eligibility Integration — 4/5

TA đã tích hợp Core eligibility:
- `leave_type.default_eligibility_profile_id` → Core `eligibility_profile`
- `leave_class.default_eligibility_profile_id` → Core `eligibility_profile`
- `leave_policy.default_eligibility_profile_id` → Core `eligibility_profile`
- `leave_class.eligibility_json` → **DEPRECATED** ✅

→ Clean migration path — old JSON eligibility phased out, new Core engine phased in.

### 3.3 Shift Operations Pipeline — 4.5/5

Full lifecycle support:
- `shift_swap_request` — shift swap between workers
- `shift_bid` — bid for open shifts
- `overtime_request` — pre-approval for OT
- `overtime_calculation` — breakdown: regular, OT, double-time, holiday, night

### 3.4 Multi-level Approval — 4/5

`absence.approval` supports:
- Multi-level approval chain (level 1, 2, 3...)
- Per-level status tracking
- Escalation support

---

## 4. Weaknesses (Điểm yếu)

### 4.1 `_DUPLICATE` Tables — Critical 🔴

File `TA-database-design-v5.dbml` chứa:
- `ta.overtime_rule_DUPLICATE` (line 837) — trùng với `ta.eval_rule`
- `ta.overtime_calculation_DUPLICATE` (line 897) — trùng với `ta.eval_result`

> Comment ghi "RENAME" nhưng thực tế tạo bảng mới với suffix `_DUPLICATE` thay vì sửa bảng cũ.

**Impact**: DBML parser sẽ có 2 tables thực hiện cùng chức năng.

**Đề xuất**: 
- Xóa `ta.eval_rule` và `ta.eval_result` (old names)
- Rename `ta.overtime_rule_DUPLICATE` → `ta.overtime_rule`
- Rename `ta.overtime_calculation_DUPLICATE` → `ta.overtime_calculation`

### 4.2 Two Files cho cùng Absence — Confusing 🟡

`3.Absence.v4.dbml` là file standalone cho absence.  
`TA-database-design-v5.dbml` đã merge absence vào (chú thích "[v5.1] NEW TABLE - changed 12dec2025: Merged from 3.Absence.v4.dbml").

**Impact**: Có 2 sources of truth — developer không biết dùng file nào.

**Đề xuất**: 
- Retire `3.Absence.v4.dbml` → move to `_archive` 
- `TA-database-design-v5.dbml` là single source for cả TA + Absence

### 4.3 Holiday Calendar Duplication — 🟡

3 nơi lưu holiday data:
1. `absence.holiday_calendar` + `absence.holiday_date` (v4 standalone)
2. `shared.holiday` (v5.1)
3. `comp_core.holiday_calendar` (TR module)

**Đề xuất**: Consolidate to 1 table — chi tiết tại Doc 06.

### 4.4 Missing PR Integration Points — 🟡

TA → PR data flow hiện thiếu:
- Không có formal `ta_payroll_export` hoặc staging table
- `overtime_calculation` không link trực tiếp đến PR `pay_run.input_value`
- Attendance hours không có summary table cho payroll consumption

**Đề xuất**: Add `ta.payroll_summary` view hoặc table:
```
ta.payroll_summary:
  employee_id, period_start, period_end
  regular_hours, overtime_hours (by type)
  absence_hours (by type)
  attendance_days, absence_days
  status: DRAFT | APPROVED | EXPORTED
```

### 4.5 Shared Components Under-utilized — 🟡

`shared.schedule`, `shared.holiday`, `shared.period_profile` defined nhưng:
- Không được reference từ TA tables nào
- `shared.holiday` references `absence.holiday_calendar` (circular dependency concern)

**Đề xuất**: 
- `shared` schema → move to Core `common` schema
- Or keep `shared` but add proper references from TA tables

### 4.6 Naming Inconsistencies — 🟡

| Pattern | TA | Absence | Issue |
|---------|-----|---------|-------|
| Date fields | `clock_in`, `clock_out` | `start_dt`, `end_dt` | `_dt` suffix inconsistent |
| Status fields | `status_code` | `state_code` | Different naming |
| Effective dates | `effective_start` | `effective_start` | Missing `_date` suffix (vs Core `effective_start_date`) |
| PK pattern | `id uuid [pk]` | `id uuid [pk]` | OK — consistent |

---

## 5. TA ↔ PR Integration Analysis

### Current State

```
TA                                    PR
──                                    ──
ta.overtime_calculation               pay_run.input_value
  → regular_hours                       ← employee_id
  → overtime_hours                      ← element_code
  → double_time_hours                   ← value
  → holiday_hours                       ← batch_id
  → night_shift_hours                   
                                      (NO formal mapping exists)
```

### Proposed Integration

```
TA                                    PR
──                                    ──
1. ta.attendance_record               
   + ta.overtime_calculation          
   + absence.leave_movement           
   ↓ (aggregation)                    
2. ta.payroll_summary [NEW]           
   → employee_id                      
   → period_start/end                 
   → regular_hours                    
   → ot_weekday_hours                  
   → ot_weekend_hours                  ──API/Event──▶  PR Input Staging
   → ot_holiday_hours                 
   → night_shift_hours                
   → absence_paid_days                
   → absence_unpaid_days              
   → status: APPROVED                
```

---

## 6. Improvement Proposals

### P0 — Critical

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 1 | **Clean `_DUPLICATE` tables**: Remove old, rename to canonical | 0.5 sprint | TA |
| 2 | **Retire standalone Absence file**: Archive `3.Absence.v4.dbml` | Trivial | TA |
| 3 | **Holiday calendar consolidation**: Single source → Core or shared | Discussion | TA, TR, CO |

### P1 — Important

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 4 | **Add `ta.payroll_summary`**: Aggregated data for PR consumption | 1 sprint | TA, PR |
| 5 | **Naming convention alignment**: `effective_start` → `effective_start_date`, `state_code` → `status_code` | 0.5 sprint | TA |
| 6 | **Add materialized view**: `employee_daily_schedule` for Level 1-6 quick lookup | 1 sprint | TA |
| 7 | **Validate shared schema references**: Fix `shared.holiday` → proper Core reference | 0.5 sprint | TA |

### P2 — Nice to Have

| # | Improvement | Effort | Impact |
|:-:|-------------|:------:|:------:|
| 8 | Add `ta.timesheet_summary` for weekly/monthly rollups | 0.5 sprint | TA |
| 9 | Document simple setup guide for small orgs | Documentation | TA |
| 10 | Add `ta.shift_template_catalog` for reusable shift templates | 0.5 sprint | TA |

---

## 7. Score Summary

| Criterion | Score | Notes |
|-----------|:-----:|-------|
| 6-level hierarchy design | 4.5/5 | Elegant, comprehensive, good lineage tracking |
| Absence ledger model | 5.0/5 | Best design in xTalent — accounting-grade |
| Eligibility integration | 4.0/5 | Well-integrated with Core — migration path clear |
| File/schema organization | 2.5/5 | `_DUPLICATE` tables, two files for same domain |
| PR integration readiness | 2.5/5 | No formal TA→PR data pipeline |
| Naming consistency | 3.0/5 | Inconsistent with Core conventions |
| Shift operations | 4.5/5 | Swap, bid, OT request — complete workflow |
| **Overall** | **3.8/5** | Strong domain design, needs cleanup and integration formalization |

---

*← [01 Core Analysis](./01-core-analysis.md) · [03 TR Analysis →](./03-tr-analysis.md)*
