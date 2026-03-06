# 📋 ABSENCE ONTOLOGY DISCREPANCY REPORT

**Ngày phân tích:** 2026-03-06  
**Người phân tích:** AI Review Agent  
**Phạm vi:** Module Absence (Leave Management) – TA module  

---

## 1. Tổng quan tài liệu được review

| Tài liệu | Vai trò | Ghi chú |
|----------|---------|---------|
| `fsd-absence-ov.md` | **Tiêu chuẩn** – Tổng quan thiết kế Absence | Canonical, approved by product team |
| `fsd-Absence-LC.md` | **Tiêu chuẩn** – Lifecycle Absence | Canonical, approved by product team |
| `03-design/3.Absence.v4.dbml` | **Tiêu chuẩn** – Database schema v4 | Canonical, FSD đồng bộ với DBML này |
| `00-ontology/entities/*.yaml` | **Phiên bản 1** – Ontology entity format | 34 files YAML riêng lẻ, version "2.0" trong file |
| `00-ontology/domain/**/*.onto.md` | **Phiên bản 2** – Domain ontology format | 3 leave-definition + scheduling + overtime |

> **Lưu ý quan trọng:** Mặc dù entities YAML tự đánh phiên bản "2.0" trong file, nhưng theo yêu cầu review đây là **Phiên bản 1** (entities) và domain/*.onto.md là **Phiên bản 2**.

---

## 2. TÓM TẮT CÁC ĐIỂM BẤT ĐỒNG NHẤT

> [!CAUTION]  
> Dev team phản ánh 2 file FSD (`fsd-absence-ov`, `fsd-Absence-LC.md`) **không khớp** với cả domain v2 lẫn entities v1. Phân tích dưới đây xác nhận và phân loại chi tiết các bất đồng nhất này.

| # | Vấn đề | Mức độ | Ảnh hưởng |
|---|--------|--------|-----------|
| 1 | **Entity naming không đồng nhất**: LeaveInstant vs LeaveAccount/LeaveBalance | 🔴 Critical | Architecture |
| 2 | **Hierarchy LeaveClass bị đảo ngược** giữa entities v1 và FSD+DBML | 🔴 Critical | Data model |
| 3 | **LeavePolicy bị xóa** khỏi entities v1; FSD+DBML vẫn giữ | 🔴 Critical | Business logic |
| 4 | **LeaveInstantDetail** không tồn tại trong entities v1 và domain v2 | 🟠 High | Lot management |
| 5 | **LeaveEventDef/LeaveEventRun** chỉ có trong FSD+DBML | 🟠 High | Automation |
| 6 | **LeaveBalanceHistory** không có trong entities v1 | 🟡 Medium | Reporting |
| 7 | **Attribute mismatches** trong LeaveType | 🟡 Medium | Field-level |
| 8 | **LeaveMovement field mismatch** | 🟡 Medium | Field-level |
| 9 | **Domain v2 incomplete** – chỉ có 3/12+ entities | 🔴 Critical | Coverage |
| 10 | **Scope/Mode enum values** khác nhau | 🟡 Medium | Enum |

---

## 3. PHÂN TÍCH CHI TIẾT

### 3.1 🔴 Critical – Entity Naming: LeaveInstant vs LeaveAccount/LeaveBalance

**Vấn đề cốt lõi: Sự khác biệt tên gọi entity "tài khoản nghỉ"**

| Tài liệu | Tên entity | Ghi chú |
|----------|-----------|---------|
| FSD (`fsd-absence-ov.md`) | `LeaveInstant` | "Tài khoản nghỉ" của từng nhân viên |
| DBML (`3.Absence.v4.dbml`) | `absence.leave_instant` | Table chính thức trong DB |
| Entities v1 (`leave-balance.yaml`) | `LeaveBalance` | Lưu current balance per worker+type+period |
| Domain v2 (`leave-class.onto.md`) | `LeaveAccount` | Trong ER diagram: `LEAVE_CLASS ||--o{ LEAVE_ACCOUNT` |

**Chi tiết sai lệch:**  
- FSD+DBML dùng `LeaveInstant` là **tài khoản đa kỳ (multi-period account)** cho từng nhân viên, tổng hợp `current_qty`, `hold_qty`, `available_qty`.
- Entities v1 có `LeaveBalance` với trường `periodYear`, `periodStartDate`, `periodEndDate` — tức là **balance per period**, không phải multi-period account.
- Domain v2 (trong ER diagram) tham chiếu `LEAVE_ACCOUNT` — entity này không có file YAML riêng trong entities v1.
- **Hệ quả**: Entities v1 giả định một balance mới mỗi năm; FSD+DBML thiết kế một account sống xuyên kỳ. Đây là khác biệt kiến trúc cơ bản.

**Mapping cần làm rõ:**
```
FSD:      LeaveInstant (multi-period, id, class_id, current_qty, hold_qty, available_qty)
         ↕ KHÔNG TƯƠNG ĐƯƠNG
Entities: LeaveBalance (per-period, workerId, leaveTypeId, periodYear, totalAllocated, used, pending)
```

---

### 3.2 🔴 Critical – Hierarchy LeaveClass Đảo Ngược

**Vấn đề: Quan hệ LeaveClass ↔ LeaveType ngược chiều**

| Tài liệu | Quan hệ |
|----------|---------|
| FSD+DBML | `LeaveType` **1 → N** `LeaveClass` (Type là gốc, Class là lớp vận hành) |
| Entities v1 (`leave-class.yaml`) | `LeaveClass` **1 → N** `LeaveType` (Class là gốc, Type là con) |
| Domain v2 (`leave-class.onto.md`) | `LeaveType` **1 → N** `LeaveClass` — **đúng với FSD** |

**Chi tiết sai lệch trong entities v1:**

File `entities/leave-type.yaml`:
```yaml
attributes:
  - leaveClassId: string (UUID)  # LeaveType là CON của LeaveClass
relationships:
  - belongsToClass: LeaveClass   # FK ngược
```

File `entities/leave-class.yaml`:
```yaml
attributes:
  - category: enum [PAID, UNPAID, STATUTORY, SPECIAL]  # Khác hoàn toàn với FSD concept
relationships:
  - hasLeaveTypes: LeaveType[]   # Class là parent
```

Trong FSD/DBML, `LeaveClass` là **lớp vận hành chi tiết** (ví dụ: `ANL_VN_ACC_G12`), không phải là nhóm category. Trong entities v1, `LeaveClass` được dùng như **category** (PTO, UNPAID, STATUTORY).

**Đây là hai concept hoàn toàn khác nhau:**
- FSD `LeaveClass`: có `mode_code` (ACCOUNT/LIMIT), `period_profile`, `posting_map`, `eligibility_json`, `emit_expire_turnover` — là lớp vận hành.
- Entities v1 `LeaveClass`: có `category` (PAID/UNPAID/STATUTORY/SPECIAL) — là nhóm phân loại đơn giản.

---

### 3.3 🔴 Critical – LeavePolicy Bị Xóa Khỏi Entities v1

**Vấn đề: Entities v1 đã xóa LeavePolicy nhưng FSD+DBML vẫn giữ**

Từ `entities/absence-ontology-index.yaml`, phần `version_info`:
```yaml
breaking_changes:
  - "Removed Policy entity - rules now bind directly to LeaveType/LeaveClass"
```

| Tài liệu | LeavePolicy |
|----------|-------------|
| FSD+DBML | ✅ Tồn tại – `absence.leave_policy` table với `accrual_rule_json`, `carry_rule_json`, `limit_rule_json`, v.v. |
| Entities v1 | ❌ Bị xóa – thay bằng `AccrualRule`, `CarryoverRule`, `LimitRule`, v.v. (các entity riêng lẻ) |
| Domain v2 (`leave-policy.onto.md`) | ✅ Tồn tại – `LeavePolicy` với `accrualRuleJson`, `carryRuleJson` |

**Hệ quả:**  
- Entities v1 phân mảnh các rule thành 8 entities riêng biệt (`AccrualRule`, `CarryoverRule`, `LimitRule`, `OverdraftRule`, `ProrationRule`, `RoundingRule`, `EligibilityRule`, `ValidationRule`).
- FSD+DBML dùng JSON columns trong `leave_policy` (`accrual_rule_json`, `carry_rule_json`, `limit_rule_json`).
- Domain v2 dùng `LeavePolicy` với JSON attributes.
- Domain v2 đồng thuận với FSD+DBML hơn về khái niệm, nhưng entities v1 đi theo hướng khác hoàn toàn.

**Conflict giữa entities v1 và domain v2:**  
Domain v2 có `leave-policy.onto.md` với `LeavePolicy` là entity riêng có `accrualRuleJson`, `carryRuleJson` — **đây là confict đặc biệt quan trọng** vì chính domain v2 cũng mâu thuẫn với entities v1 (entities v1 đã xóa Policy entity).

---

### 3.4 🟠 High – LeaveInstantDetail Không Tồn Tại

**Vấn đề: Grant lot management missing**

| Tài liệu | Trạng thái |
|----------|-----------|
| FSD+DBML | `absence.leave_instant_detail` – quản lý grant lots với `eff_date`, `expire_date`, `lot_qty`, FEFO priority |
| Entities v1 | ❌ Không có entity tương đương |
| Domain v2 | ❌ Không có entity tương đương |

FSD mô tả rõ FEFO (First Expire First Out) consumption model. Entities v1 và domain v2 không có cơ chế này. Đây là thiếu sót functionality quan trọng trong cả 2 phiên bản ontology.

---

### 3.5 🟠 High – LeaveEventDef/LeaveEventRun Chỉ Có Trong FSD+DBML

**Vấn đề: Event automation layer missing**

| Tài liệu | Trạng thái |
|----------|-----------|
| FSD+DBML | `leave_event_def` + `leave_event_run` + `leave_class_event` – event system đầy đủ |
| Entities v1 | `event.yaml` + `trigger.yaml` – generic event system, không specific với leave events |
| Domain v2 | ❌ Không có EventDef, EventRun entities |

Entities v1 có `Event` và `Trigger` nhưng là generic. FSD+DBML có event system cụ thể: `ACCRUAL`, `CARRY`, `EXPIRE`, `START_POST`, `RESET_LIMIT`.

Domain v2 hoàn toàn thiếu event layer.

---

### 3.6 🟡 Medium – LeaveBalanceHistory Không Có Trong Entities v1

| Tài liệu | Trạng thái |
|----------|-----------|
| FSD+DBML | `absence.leave_balance_history` – daily EOD snapshot với `opening_qty`, `turnover_dr`, `turnover_cr`, `closing_qty` |
| Entities v1 | ❌ Không có. `LeaveBalance` track current state, không có history |
| Domain v2 | ❌ Không có |

---

### 3.7 🟡 Medium – Attribute Mismatches trong LeaveType

**So sánh chi tiết attributes của LeaveType:**

| Attribute | FSD+DBML | Entities v1 | Domain v2 | Ghi chú |
|-----------|----------|-------------|-----------|---------|
| `unit_code`/`unitCode` | ✅ (`HOUR`/`DAY`) | ✅ (`unitOfMeasure: DAYS/HOURS`) | ✅ | Tên khác |
| `core_min_unit` | ✅ | ❌ Không có | ✅ (`coreMinUnit`) | Missing trong entities v1 |
| `holiday_handling` | ✅ (`EXCLUDE_HOLIDAYS`, `INCLUDE_HOLIDAYS`, `STOP_AT_HOLIDAY`) | ❌ Không có | ✅ (chỉ 2 values: `EXCLUDE`, `INCLUDE`) | Missing trong entities v1; domain v2 thiếu giá trị `STOP_AT_HOLIDAY` |
| `overlap_policy` | ✅ (`ALLOW`/`DENY`) | ❌ Không có | ✅ (`ALLOW`/`DENY`) | Missing trong entities v1 |
| `support_scope` | ✅ | ❌ Không có | ❌ Không có | Missing trong cả 2 |
| `is_quota_based` | ✅ | ❌ Không có (dùng `isQuotaBased` concept khác) | ✅ (`isQuotaBased`) | Entities v1 có nhưng semantic khác |
| `requires_documentation` | ❌ Không có | ✅ | ❌ | Extra trong entities v1 |
| `allows_hourly` | ❌ Không có | ✅ | ❌ | Extra trong entities v1 |
| `color`, `icon` | ❌ Không có | ✅ | ❌ | UI fields chỉ trong entities v1 |
| `metadata` | ✅ (jsonb) | ❌ | ❌ | Extra trong FSD+DBML |

---

### 3.8 🟡 Medium – LeaveMovement Field Mismatch

**So sánh fields của LeaveMovement:**

| Field | FSD+DBML (`leave_movement`) | Entities v1 (`leave-movement.yaml`) | Ghi chú |
|-------|----------------------------|-------------------------------------|---------|
| Link đến account | `instant_id` (FK → leave_instant) | `leaveBalanceId` (FK → LeaveBalance) | Khác entity reference |
| Qty field | `qty` decimal (+ / -) | `amount` decimal (positive for credit, negative for debit) | Tương đương |
| Balance snapshot | ❌ Không có | `balanceBefore`, `balanceAfter` | Extra trong entities v1 |
| `event_code` | ✅ varchar(50) | `movementType: enum [ALLOCATION, ACCRUAL, USAGE, ADJUSTMENT, CARRYOVER, EXPIRY, PAYOUT, REVERSAL]` | Enum vs free varchar |
| `unit_code` | ✅ | ❌ | Missing trong entities v1 |
| `period_id` | ✅ | ❌ | Missing trong entities v1 |
| `expire_date` | ✅ | ❌ | Missing trong entities v1 |
| `lot_id` | ✅ | ❌ | Missing (vì không có InstantDetail) |
| `run_id` | ✅ | ❌ | Missing (vì không có EventRun) |
| `idempotency_key` | ✅ | ❌ | Missing trong entities v1 |
| `referenceType/referenceId` | ❌ | ✅ | Extra trong entities v1 |
| `isReversed`, `reversalMovementId` | ❌ | ✅ | Extra trong entities v1 |
| `bu_id`, `le_id`, `country_code` | ✅ | ❌ | Context dimension missing |

---

### 3.9 🔴 Critical – Domain v2 Incomplete (Coverage)

**Domain v2 chỉ cover được 4/12+ entities cần thiết:**

| Entity (FSD+DBML) | Domain v2 | Entities v1 |
|-------------------|-----------|-------------|
| LeaveType | ✅ (`leave-type.onto.md`) | ✅ |
| LeaveClass | ✅ (`leave-class.onto.md`) | ✅ |
| LeavePolicy | ✅ (`leave-policy.onto.md`) | ❌ (removed) |
| LeaveInstant | ❌ | ❌ (→ LeaveBalance) |
| LeaveInstantDetail | ❌ | ❌ |
| LeaveMovement | ❌ | ✅ |
| LeaveRequest | ❌ | ✅ |
| LeaveReservation | ❌ | ✅ |
| LeaveEventDef | ❌ | ❌ (→ generic Event) |
| LeaveEventRun | ❌ | ❌ |
| LeavePeriod | ❌ | ✅ (`period-profile.yaml`) |
| LeaveBalanceHistory | ❌ | ❌ |
| HolidayCalendar | ✅ (`holiday-calendar.onto.md` in scheduling) | ✅ |
| TeamLeaveLimit | ❌ | ❌ |

**Domain v2 còn nhiều file trong scheduling/overtime không liên quan đến FSD Absence core.**

---

### 3.10 🟡 Medium – Enum Values Khác Nhau

| Enum | FSD+DBML | Entities v1 | Domain v2 |
|------|----------|-------------|-----------|
| LeaveClass mode | `ACCOUNT`, `LIMIT`, `UNPAID`, `CUSTOM` | `PAID`, `UNPAID`, `STATUTORY`, `SPECIAL` (category) | `ACCOUNT`, `LIMIT`, `UNPAID` |
| LeaveRequest status | `DRAFT`, `SUBMITTED`, `APPROVED`, `REJECTED` | `DRAFT`, `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`, `WITHDRAWN` | N/A |
| LeaveInstant state | `ACTIVE`, `SUSPENDED`, `CLOSED`, `EXPIRED` | N/A | N/A |

---

## 4. SO SÁNH TỔNG HỢP THEO ENTITY

### 4.1 Entities có trong FSD+DBML (14 entities)

| Entity (FSD+DBML) | Entities v1 | Domain v2 | Đồng bộ FSD? |
|-------------------|-------------|-----------|--------------|
| `LeaveType` | ✅ (khác hierarchy) | ✅ | ⚠️ Partial |
| `LeaveClass` | ✅ (concept khác) | ✅ | ⚠️ Partial |
| `LeavePolicy` | ❌ Removed | ✅ | ❌ Conflict |
| `LeaveInstant` | ❌ → `LeaveBalance` | ❌ | ❌ Missing |
| `LeaveInstantDetail` | ❌ | ❌ | ❌ Missing |
| `LeaveEventDef` | ❌ → generic `Event` | ❌ | ❌ Missing |
| `LeaveEventRun` | ❌ | ❌ | ❌ Missing |
| `LeaveClassEvent` | ❌ | ❌ | ❌ Missing |
| `LeaveMovement` | ✅ (fields khác) | ❌ | ⚠️ Partial |
| `LeaveRequest` | ✅ (fields khác) | ❌ | ⚠️ Partial |
| `LeaveReservation` | ✅ | ❌ | ⚠️ Partial |
| `LeavePeriod` | ✅ (→ `PeriodProfile`) | ❌ | ⚠️ Partial |
| `LeaveBalanceHistory` | ❌ | ❌ | ❌ Missing |
| `HolidayCalendar` | ✅ | ✅ | ✅ |
| `TeamLeaveLimit` | ❌ | ❌ | ❌ Missing |

**Tóm tắt đồng bộ:**  
- ✅ Đồng bộ: 1/15 entities (HolidayCalendar)  
- ⚠️ Partial: 6/15 entities  
- ❌ Missing/Conflict: 8/15 entities

---

### 4.2 Entities chỉ có trong Entities v1 (không có trong FSD+DBML)

| Entity | File | Ghi chú |
|--------|------|---------|
| `AccrualRule` | `accrual-rule.yaml` | Tách rời từ LeavePolicy |
| `CarryoverRule` | `carryover-rule.yaml` | Tách rời từ LeavePolicy |
| `LimitRule` | `limit-rule.yaml` | Tách rời từ LeavePolicy |
| `OverdraftRule` | `overdraft-rule.yaml` | Tách rời từ LeavePolicy |
| `ProrationRule` | `proration-rule.yaml` | Tách rời từ LeavePolicy |
| `RoundingRule` | `rounding-rule.yaml` | Tách rời từ LeavePolicy |
| `EligibilityRule` | `eligibility-rule.yaml` | Phần của `eligibility_json` trong FSD |
| `ValidationRule` | `validation-rule.yaml` | Phần của `validation_json` trong FSD |
| `Approval` | `approval.yaml` | Implicit trong FSD workflow |
| `Event` (generic) | `event.yaml` | Thay thế `LeaveEventDef` |
| `Trigger` | `trigger.yaml` | Thay thế `LeaveEventRun` |
| `Schedule` | `schedule.yaml` | Trong FSD là implicit |

---

## 5. NGUYÊN NHÂN GỐC RỄ

### Root Cause Analysis

```
┌─────────────────────────────────────────────────────────┐
│  FSD + DBML (v4)          │   Entities v1 (Ontology)   │
│  (Canonical – Oct2025)    │   (Nov2025, version "2.0")  │
└─────────────────────────────────────────────────────────┘
         ↑                              ↑
    Designed by Product            Designed independently
    team with DB-centric           with DDD/Ontology approach
    Event-driven model             Rule entity decomposition
         ↓                              ↓
  LeaveInstant (multi-period)   LeaveBalance (per-period)
  LeavePolicy (JSON columns)    8 separate Rule entities
  LeaveEventDef/Run             Generic Event/Trigger
  FEFO InstantDetail            No lot management
```

**Kết luận:** Entities v1 và Domain v2 được xây dựng **độc lập** với FSD+DBML, theo hướng tiếp cận DDD (Domain-Driven Design) khác với thiết kế DB của FSD. Điều này dẫn đến 2 "thế giới" khác nhau:

1. **FSD+DBML world**: Event-driven, movement-based ledger, LeaveInstant là multi-period account, LeavePolicy là policy container với JSON.
2. **Ontology world (entities v1)**: Rule decomposition, LeaveBalance là per-period balance, không có Policy entity (removed as breaking change), không có lot management.

Domain v2 cố gắng hòa giải nhưng vẫn mâu thuẫn với entities v1 (domain v2 giữ LeavePolicy, entities v1 xóa).

---

## 6. KHUYẾN NGHỊ

### 6.1 Ưu tiên cao – Cần giải quyết ngay

> [!IMPORTANT]  
> Các vấn đề này block dev team nếu không được làm rõ.

1. **Quyết định canonical model**: FSD+DBML là tiêu chuẩn, do đó cần update cả entities v1 và domain v2 để align. Cụ thể:
   - Rename `LeaveBalance` → `LeaveInstant` hoặc thêm entity mới
   - Restore `LeavePolicy` với JSON structure (reverting entities v1 breaking change)
   - Fix hierarchy LeaveType → LeaveClass (đúng theo FSD)

2. **Bổ sung entities còn thiếu** vào cả entities v1 và domain v2:
   - `LeaveInstant` (multi-period account)
   - `LeaveInstantDetail` (grant lots với FEFO)
   - `LeaveEventDef` / `LeaveEventRun` / `LeaveClassEvent`
   - `LeaveBalanceHistory`
   - `TeamLeaveLimit`

3. **Cập nhật Domain v2** bổ sung đủ các leaf entities hiện thiếu.

### 6.2 Ưu tiên trung bình – Nên cập nhật

4. **Align enum values**: `LeaveClass.modeCode` phải là `ACCOUNT`/`LIMIT`/`UNPAID` (không phải PAID/UNPAID/STATUTORY).
5. **Align `LeaveType` attributes**: Bổ sung `core_min_unit`, `holiday_handling` (3 values), `overlap_policy`, `support_scope` vào entities v1.
6. **Align `LeaveMovement`**:  
   - Link đến `LeaveInstant` thay vì `LeaveBalance`
   - Bổ sung `unit_code`, `period_id`, `expire_date`, `lot_id`, `run_id`, `idempotency_key`, context dimensions

### 6.3 Ưu tiên thấp – Cần thảo luận design

7. **8 Rule entities trong entities v1 vs JSON columns trong FSD**: Đây là trade-off design. Rule entities linh hoạt hơn ở ORM layer nhưng phức tạp hơn. Cần team quyết định.
8. **`balanceBefore`/`balanceAfter` trong entities v1 LeaveMovement**: FSD không có. Có thể loại bỏ (tính toán từ movements) hoặc giữ như denormalized cache.

---

## 7. CHECKLIST HÀNH ĐỘNG

### Entities v1 (entities/*.yaml) – Cần cập nhật

- [ ] **Bỏ `leaveClassId` FK trong `leave-type.yaml`** (hierarchy đảo ngược)
- [ ] **Thay `LeaveBalance` bằng `LeaveInstant`** hoặc align concept
- [ ] **Restore `leave-policy.yaml`** với structure JSON columns (align với FSD+DBML)
- [ ] **Tạo `leave-instant.yaml`** (multi-period account)
- [ ] **Tạo `leave-instant-detail.yaml`** (grant lots, FEFO)
- [ ] **Tạo `leave-event-def.yaml`**, `leave-event-run.yaml`, `leave-class-event.yaml`
- [ ] **Tạo `leave-balance-history.yaml`** (EOD snapshot)
- [ ] **Tạo `team-leave-limit.yaml`**
- [ ] **Update `leave-movement.yaml`**: fix FK reference, thêm missing fields
- [ ] **Update `leave-type.yaml`**: thêm `core_min_unit`, `holiday_handling`, `overlap_policy`, `support_scope`
- [ ] **Update `leave-class.yaml`**: thay đổi concept từ category → operational class
- [ ] **Update absence-ontology-index.yaml**: sync với entities mới

### Domain v2 (domain/**/*.onto.md) – Cần cập nhật

- [ ] **Tạo `leave-instant.onto.md`** trong `leave-definition/`
- [ ] **Tạo `leave-instant-detail.onto.md`**
- [ ] **Tạo `leave-movement.onto.md`**
- [ ] **Tạo `leave-request.onto.md`**
- [ ] **Tạo `leave-reservation.onto.md`**
- [ ] **Tạo `leave-period.onto.md`**
- [ ] **Tạo `leave-event-def.onto.md`**, `leave-event-run.onto.md`
- [ ] **Tạo `leave-balance-history.onto.md`**
- [ ] **Fix `leave-type.onto.md`**: bỏ `STOP_AT_HOLIDAY` thiếu, align enums

---

## 8. PHỤ LỤC – MAPPING BẢNG ĐỒNG NHẤT

### 8.1 Entity Name Mapping

| FSD+DBML | Entities v1 | Domain v2 | Notes |
|----------|-------------|-----------|-------|
| `LeaveType` | `LeaveType` | `LeaveType` | Đồng tên nhưng fields khác |
| `LeaveClass` | `LeaveClass` | `LeaveClass` | Đồng tên nhưng concept khác |
| `LeavePolicy` | ❌ (removed) | `LeavePolicy` | v1 đã xóa |
| `LeaveInstant` | `LeaveBalance` (partial) | `LeaveAccount` (implied) | Khác tên, khác concept |
| `LeaveInstantDetail` | ❌ | ❌ | Missing everywhere |
| `LeaveEventDef` | `Event` (generic) | ❌ | Khác concept |
| `LeaveEventRun` | `Trigger` (partial) | ❌ | Khác concept |
| `LeaveClassEvent` | ❌ | ❌ | Missing everywhere |
| `LeaveMovement` | `LeaveMovement` | ❌ | Đồng tên nhưng fields khác |
| `LeaveRequest` | `LeaveRequest` | ❌ | Đồng tên nhưng fields khác |
| `LeaveReservation` | `LeaveReservation` | ❌ | Chỉ có trong entities v1 |
| `LeavePeriod` | `PeriodProfile` | ❌ | Khác tên |
| `LeaveBalanceHistory` | ❌ | ❌ | Missing everywhere |
| `HolidayCalendar` | `Holiday` (partial) | `HolidayCalendar` | Partial match |
| `TeamLeaveLimit` | ❌ | ❌ | Missing everywhere |

### 8.2 Mức độ đồng bộ tổng quan

```
FSD+DBML (14 entities)
│
├── Đồng bộ tốt với entities v1: HolidayCalendar (1/14 = 7%)
├── Partial match với entities v1: LeaveType, LeaveMovement, LeaveRequest, 
│   LeaveReservation, PeriodProfile (5/14 = 36%)
├── Missing trong entities v1: 8/14 = 57%
│
├── Đồng bộ tốt với domain v2: HolidayCalendar, LeaveType, LeaveClass, 
│   LeavePolicy (4/14 = 29%)
└── Missing trong domain v2: 10/14 = 71%
```

---

*Báo cáo này được tạo dựa trên phân tích chi tiết 5 file tài liệu tham chiếu và 40+ entity files trong 2 phiên bản ontology. Khuyến nghị ưu tiên số 1 và 2 cần được xử lý trước khi dev team tiếp tục implementation.*
