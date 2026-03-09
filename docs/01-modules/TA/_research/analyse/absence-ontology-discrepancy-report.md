# 📋 ABSENCE ONTOLOGY DISCREPANCY REPORT

**Ngày phân tích:** 2026-03-06 (cập nhật: 2026-03-09)
**Người phân tích:** AI Review Agent  
**Phạm vi:** Module Absence (Leave Management) – TA module  

---

> [!WARNING]
> **Đính chính (2026-03-09):** Phiên bản gốc của report đã nhầm lẫn phân loại các file `*.onto.md` trong `_archive/00-ontology/domain/` là "Domain v2 active standard". Thực tế:  
> - `*.onto.md` là **format ODD era cũ** (đề xuất từ `ODD/03-Solution/08-the-living-spec.md`), đã bị **superseded** bởi ODDS standard.  
> - Tất cả các file `*.onto.md` đã được chuyển vào `_archive/` và **không còn là tài liệu active**.  
> - Tiêu chuẩn hiện hành là **ODDS** (`_research/ODSA/`): ontology dùng pure YAML (`ontology/concepts/*.yaml`), narrative dùng plain markdown, không mix.
> 
> Report đã được cập nhật để phản ánh đúng thực tế.

---

## 1. Tổng quan tài liệu được review

| Tài liệu | Vai trò | Trạng thái |
|----------|---------|-----------|
| `fsd-absence-ov.md` | **Tiêu chuẩn** – Tổng quan thiết kế Absence | ✅ Active canonical |
| `fsd-Absence-LC.md` | **Tiêu chuẩn** – Lifecycle Absence | ✅ Active canonical |
| `03-design/3.Absence.v4.dbml` | **Tiêu chuẩn** – Database schema v4 | ✅ Active canonical |
| `_archive/00-ontology/entities/*.yaml` | **Phiên bản 1** – Ontology entity YAML | ⚠️ Active nhưng lỗi thời – cần align với FSD |
| `_archive/00-ontology/domain/**/*.onto.md` | **Legacy ODD** – format mix YAML+MD | 🗑️ **Đã archive** – không phải active standard |

> [!NOTE]
> **Phạm vi phân tích hợp lệ:** Chỉ có 2 nguồn cần so sánh thực sự là **Entities v1 YAML** (vẫn còn active ở _archive nhưng dùng làm reference) vs **FSD+DBML** (canonical). Các file `*.onto.md` là legacy format, phân tích xung đột với chúng là không còn phù hợp.

---

## 2. TÓM TẮT CÁC ĐIỂM BẤT ĐỒNG NHẤT

> [!CAUTION]  
> Dev team phản ánh entities YAML không khớp với FSD+DBML. Dưới đây là phân tích các xung đột thực sự giữa **Entities v1** và **FSD+DBML canvas**.

| # | Vấn đề | Mức độ | Ảnh hưởng |
|---|--------|--------|-----------|
| 1 | **Entity naming**: `LeaveInstant` (FSD) vs `LeaveBalance` (entities v1) — khác concept | 🔴 Critical | Architecture |
| 2 | **Hierarchy đảo ngược**: `LeaveClass → LeaveType` (entities v1) thay vì `LeaveType → LeaveClass` (FSD) | 🔴 Critical | Data model |
| 3 | **`LeavePolicy` bị xóa** khỏi entities v1; FSD+DBML vẫn giữ | 🔴 Critical | Business logic |
| 4 | **`LeaveInstantDetail`** không tồn tại trong entities v1 | 🟠 High | Lot management / FEFO |
| 5 | **`LeaveEventDef` / `LeaveEventRun`** chỉ có trong FSD+DBML | 🟠 High | Automation |
| 6 | **`LeaveBalanceHistory`** không có trong entities v1 | 🟡 Medium | Reporting |
| 7 | **Attribute mismatches** trong `LeaveType` | 🟡 Medium | Field-level |
| 8 | **`LeaveMovement` field mismatch** — FK sai, thiếu nhiều fields | 🟡 Medium | Field-level |
| 9 | **Enum values** của `LeaveClass.category` sai hoàn toàn | 🟡 Medium | Enum |

---

## 3. PHÂN TÍCH CHI TIẾT

### 3.1 🔴 Critical – Entity Naming: `LeaveInstant` vs `LeaveBalance`

**Vấn đề cốt lõi: Sự khác biệt tên gọi và concept của "tài khoản nghỉ"**

| Tài liệu | Tên entity | Ghi chú |
|----------|-----------|---------|
| FSD (`fsd-absence-ov.md`) | `LeaveInstant` | Tài khoản nghỉ đa kỳ của từng nhân viên |
| DBML (`3.Absence.v4.dbml`) | `absence.leave_instant` | Table DB chính thức |
| Entities v1 (`leave-balance.yaml`) | `LeaveBalance` | Balance per worker + type + **period** |

**Chi tiết sai lệch:**
- FSD+DBML: `LeaveInstant` là **multi-period account** — sống xuyên kỳ, tổng hợp `current_qty`, `hold_qty`, `available_qty`.
- Entities v1: `LeaveBalance` có `periodYear`, `periodStartDate`, `periodEndDate` — tức là **balance per period**, tạo mới mỗi năm.
- Đây là **khác biệt kiến trúc cơ bản**, không chỉ là đổi tên.

```
FSD:      LeaveInstant (multi-period, class_id, current_qty, hold_qty, available_qty)
         ≠
Entities: LeaveBalance (per-period, leaveTypeId, periodYear, totalAllocated, used, pending)
```

---

### 3.2 🔴 Critical – Hierarchy `LeaveClass` Đảo Ngược

| Tài liệu | Quan hệ |
|----------|---------|
| FSD+DBML | `LeaveType` **1 → N** `LeaveClass` — Type là gốc, Class là lớp vận hành |
| Entities v1 | `LeaveClass` **1 → N** `LeaveType` — Class là parent, Type là con |

**Entities v1 còn dùng `LeaveClass` sai concept:**
- FSD `LeaveClass`: operational class với `mode_code` (ACCOUNT/LIMIT), `period_profile`, `posting_map`, `eligibility_json`
- Entities v1 `LeaveClass`: chỉ là `category: enum [PAID, UNPAID, STATUTORY, SPECIAL]` — nhóm phân loại đơn giản

---

### 3.3 🔴 Critical – `LeavePolicy` Bị Xóa Khỏi Entities v1

Trong `entities/absence-ontology-index.yaml`:
```yaml
breaking_changes:
  - "Removed Policy entity - rules now bind directly to LeaveType/LeaveClass"
```

| Tài liệu | `LeavePolicy` |
|----------|--------------|
| FSD+DBML | ✅ Tồn tại — table `absence.leave_policy` với `accrual_rule_json`, `carry_rule_json`, `limit_rule_json` |
| Entities v1 | ❌ Bị xóa — thay bằng 8 rule entities riêng lẻ |

Entities v1 phân mảnh policy thành: `AccrualRule`, `CarryoverRule`, `LimitRule`, `OverdraftRule`, `ProrationRule`, `RoundingRule`, `EligibilityRule`, `ValidationRule`. FSD+DBML dùng JSON columns trong một entity `leave_policy`. Đây là trade-off design cần quyết định chiều đi.

---

### 3.4 🟠 High – `LeaveInstantDetail` Không Tồn Tại

FSD+DBML có `absence.leave_instant_detail` — quản lý grant lots với `eff_date`, `expire_date`, `lot_qty`, FEFO priority. Entities v1 **không có entity tương đương nào**. FEFO (First Expire First Out) consumption model hoàn toàn vắng mặt trong entities v1.

---

### 3.5 🟠 High – Event Layer Chỉ Có Trong FSD+DBML

| Tài liệu | Trạng thái |
|----------|-----------|
| FSD+DBML | `leave_event_def` + `leave_event_run` + `leave_class_event` — event system đầy đủ |
| Entities v1 | `event.yaml` + `trigger.yaml` — generic, không specific với leave business events |

FSD có event types cụ thể: `ACCRUAL`, `CARRY`, `EXPIRE`, `START_POST`, `RESET_LIMIT`. Entities v1 không có equivalent.

---

### 3.6 🟡 Medium – `LeaveBalanceHistory` Không Có Trong Entities v1

FSD+DBML có `absence.leave_balance_history` — daily EOD snapshot với `opening_qty`, `turnover_dr`, `turnover_cr`, `closing_qty`. Entities v1 chỉ track current state trong `LeaveBalance`, không có history snapshots.

---

### 3.7 🟡 Medium – Attribute Mismatches trong `LeaveType`

| Attribute | FSD+DBML | Entities v1 | Ghi chú |
|-----------|----------|-------------|---------|
| `core_min_unit` | ✅ | ❌ | Missing |
| `holiday_handling` (3 values) | ✅ | ❌ | Missing |
| `overlap_policy` | ✅ | ❌ | Missing |
| `support_scope` | ✅ | ❌ | Missing |
| `metadata` jsonb | ✅ | ❌ | Missing |
| `requires_documentation` | ❌ | ✅ | Extra (entities v1 only) |
| `allows_hourly` | ❌ | ✅ | Extra (entities v1 only) |
| `color`, `icon` | ❌ | ✅ | UI fields không cần trong FSD |

---

### 3.8 🟡 Medium – `LeaveMovement` Field Mismatch

| Field | FSD+DBML | Entities v1 | Ghi chú |
|-------|----------|-------------|---------|
| FK đến account | `instant_id` → `leave_instant` | `leaveBalanceId` → `LeaveBalance` | Sai entity reference |
| `unit_code`, `period_id`, `expire_date` | ✅ | ❌ | Missing |
| `lot_id`, `run_id` | ✅ | ❌ | Missing (vì thiếu InstantDetail/EventRun) |
| `idempotency_key` | ✅ | ❌ | Missing |
| `bu_id`, `le_id`, `country_code` | ✅ | ❌ | Context dimensions missing |
| `balanceBefore`, `balanceAfter` | ❌ | ✅ | Extra — denormalized cache |
| `isReversed`, `reversalMovementId` | ❌ | ✅ | FSD dùng movement reversal thay vì flag |

---

### 3.9 🟡 Medium – Enum Values Sai

| Enum | FSD+DBML | Entities v1 |
|------|----------|-------------|
| `LeaveClass` mode | `ACCOUNT`, `LIMIT`, `UNPAID`, `CUSTOM` | `PAID`, `UNPAID`, `STATUTORY`, `SPECIAL` (category — hoàn toàn khác) |
| `LeaveRequest` status | `DRAFT`, `SUBMITTED`, `APPROVED`, `REJECTED` | `DRAFT`, `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`, `WITHDRAWN` |
| `LeaveInstant` state | `ACTIVE`, `SUSPENDED`, `CLOSED`, `EXPIRED` | N/A |

---

## 4. SO SÁNH COVERAGE

| Entity (FSD+DBML) | Entities v1 | Đồng bộ FSD? |
|-------------------|-------------|--------------|
| `LeaveType` | ✅ (hierarchy + attrs khác) | ⚠️ Partial |
| `LeaveClass` | ✅ (concept khác) | ⚠️ Partial |
| `LeavePolicy` | ❌ Removed | ❌ Conflict |
| `LeaveInstant` | ❌ → `LeaveBalance` (khác concept) | ❌ Missing |
| `LeaveInstantDetail` | ❌ | ❌ Missing |
| `LeaveEventDef` | ❌ → generic `Event` | ❌ Missing |
| `LeaveEventRun` | ❌ | ❌ Missing |
| `LeaveClassEvent` | ❌ | ❌ Missing |
| `LeaveMovement` | ✅ (fields khác nhiều) | ⚠️ Partial |
| `LeaveRequest` | ✅ (fields khác) | ⚠️ Partial |
| `LeaveReservation` | ✅ | ⚠️ Partial |
| `LeavePeriod` | ✅ → `PeriodProfile` | ⚠️ Partial |
| `LeaveBalanceHistory` | ❌ | ❌ Missing |
| `HolidayCalendar` | ✅ | ✅ |
| `TeamLeaveLimit` | ❌ | ❌ Missing |

**Tóm tắt:** ✅ 1/15 | ⚠️ 6/15 | ❌ 8/15

---

## 5. NGUYÊN NHÂN GỐC RỄ

```
FSD + DBML (Oct2025)         Entities v1 (Nov2025)
─────────────────────        ────────────────────────
DB-centric, Event-driven     DDD / Ontology approach
LeaveInstant multi-period    LeaveBalance per-period
LeavePolicy JSON columns     8 separate Rule entities
LeaveEventDef + Run          Generic Event/Trigger
FEFO grant lots              No lot management
```

Entities v1 được build **độc lập** với FSD+DBML theo hướng DDD. Kết quả là 2 world model khác nhau về cả kiến trúc lẫn concept. Không phải bug, mà là **alignment gap giữa 2 team/approach**.

---

## 6. KHUYẾN NGHỊ

> [!IMPORTANT]
> Cần quyết định **một** canonical model. Đề xuất lấy FSD+DBML làm chuẩn vì đây là design đã được approve ở product layer.

### 6.1 Cập nhật Entities v1 YAML (align với FSD+DBML)

- [ ] Fix hierarchy: `LeaveType → LeaveClass` (bỏ `leaveClassId` FK khỏi `leave-type.yaml`)
- [ ] Đổi `LeaveClass.category` → `LeaveClass.modeCode` (ACCOUNT/LIMIT/UNPAID)
- [ ] Restore `leave-policy.yaml` với JSON columns approach
- [ ] Tạo `leave-instant.yaml` (multi-period account, thay thế `leave-balance.yaml`)
- [ ] Tạo `leave-instant-detail.yaml` (grant lots, FEFO)
- [ ] Tạo `leave-event-def.yaml`, `leave-event-run.yaml`, `leave-class-event.yaml`
- [ ] Tạo `leave-balance-history.yaml` (EOD snapshot)
- [ ] Tạo `team-leave-limit.yaml`
- [ ] Update `leave-movement.yaml`: fix FK, thêm missing fields
- [ ] Update `leave-type.yaml`: thêm `core_min_unit`, `holiday_handling`, `overlap_policy`, `support_scope`
- [ ] Update `absence-ontology-index.yaml`: sync lại

### 6.2 Design decision cần team quyết định

- **8 Rule entities vs JSON columns trong LeavePolicy**: Rule entities linh hoạt hơn ở ORM layer nhưng phức tạp query hơn. Cần chọn một.
- **`balanceBefore`/`balanceAfter` trong LeaveMovement**: FSD không có (tính từ movements). Cân nhắc giữ như denormalized cache hay bỏ.

---

## 7. PHỤ LỤC – Entity Name Mapping

| FSD+DBML | Entities v1 | Notes |
|----------|-------------|-------|
| `LeaveType` | `LeaveType` | Đồng tên, khác hierarchy + attrs |
| `LeaveClass` | `LeaveClass` | Đồng tên, **khác concept hoàn toàn** |
| `LeavePolicy` | ❌ (removed) | Entities v1 đã xóa |
| `LeaveInstant` | `LeaveBalance` | Khác tên, **khác concept** |
| `LeaveInstantDetail` | ❌ | Missing |
| `LeaveEventDef` | `Event` (generic) | Khác concept |
| `LeaveEventRun` | `Trigger` (partial) | Khác concept |
| `LeaveMovement` | `LeaveMovement` | Đồng tên, nhiều fields khác |
| `LeaveRequest` | `LeaveRequest` | Đồng tên, một số fields khác |
| `LeaveReservation` | `LeaveReservation` | Partial match |
| `LeavePeriod` | `PeriodProfile` | Khác tên |
| `LeaveBalanceHistory` | ❌ | Missing |
| `HolidayCalendar` | `Holiday` | Partial match |
| `TeamLeaveLimit` | ❌ | Missing |

---

*Báo cáo phân tích entities v1 YAML vs FSD+DBML canonical standard. Các `*.onto.md` files không thuộc phạm vi phân tích — chúng là ODD legacy format đã được archive.*

