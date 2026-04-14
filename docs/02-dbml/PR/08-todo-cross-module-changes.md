# TODO: Cross-Module Changes — Payroll Integration

**Purpose**: Ghi lại các thay đổi cần thiết cho các modules khác ngoài Payroll (TA, TR) để hoàn thiện integration.  
**Nguyên tắc**: Các thay đổi này **KHÔNG được implement ngay** mà **phải có planning riêng** với team của module đó.  
**Status**: Draft — 14Apr2026  
**Related**: [07-integration-blueprint.md](./07-integration-blueprint.md)

---

## Summary

| ID | Module | Priority | Effort | Status |
|----|--------|----------|--------|--------|
| [GAP-PR-001](#gap-pr-001) | TR | Medium | Medium | 📋 Planned |
| [TA-TODO-001](#ta-todo-001) | TA | High | Low | 📋 Planned |
| [TA-TODO-002](#ta-todo-002) | TA | Medium | Low | 📋 Planned |

---

## GAP-PR-001

**Title**: `comp_core.pay_component_def` → `pay_master.pay_element` — Missing FK Mapping  
**Modules**: Total Rewards (TR) + Payroll (PR)  
**Priority**: Medium  
**Effort**: Medium (cần design review với TR team)

### Problem

Khi Payroll engine đọc `compensation.basis_line`:
```
compensation.basis_line:
  pay_component_def_id = <MEAL_ALLOWANCE_UUID>  ← chỉ refer TR table
  amount = 500,000
```

Engine cần biết: `MEAL_ALLOWANCE` trong TR → element nào trong Payroll?  
Hiện không có FK cứng nối hai bảng → engine phải dùng naming convention tạm thời qua `input_source_config.mapping_json`.

### Current Workaround

```json
// input_source_config.mapping_json cho COMP_BASIS_CHANGE:
{
  "component_mappings": [
    { "pay_component_def_id": "<MEAL_UUID>",       "target_element_code": "MEAL_ALLOWANCE" },
    { "pay_component_def_id": "<TRANSPORT_UUID>",  "target_element_code": "TRANSPORT_ALLOW" },
    { "pay_component_def_id": "<PHONE_UUID>",      "target_element_code": "PHONE_ALLOW" }
  ]
}
```

Vấn đề: nếu TR thêm `pay_component_def` mới → payroll phải manually update `input_source_config.mapping_json`.

### Proposed Solution

**Option A** (preferred — minimal TR change):
- Thêm field vào `comp_core.pay_component_def`:
  ```dbml
  payroll_element_id uuid [ref: > pay_master.pay_element.id, null]
  -- null = component không map sang payroll element (e.g. STOCK_OPTION)
  -- not null = engine tự động lấy element_id từ đây
  ```

**Option B** (more flexible — separate mapping table):
- Tạo bảng mới `pay_master.component_element_map` trong PR:
  ```dbml
  Table pay_master.component_element_map {
    pay_component_def_id  uuid [ref: > comp_core.pay_component_def.id, not null]
    pay_element_id        uuid [ref: > pay_master.pay_element.id, not null]
    is_active             boolean [default: true]
    effective_start_date  date
    effective_end_date    date [null]
    [indexes: (pay_component_def_id, pay_element_id) unique]
  }
  ```

### Action Items

- [ ] Design review với TR team — chọn Option A hay B
- [ ] Nếu Option A: update `4.TotalReward.V5.dbml` + `CHANGELOG.md`
- [ ] Nếu Option B: update `5.Payroll.V4.dbml` + tạo migration SQL
- [ ] Update `07-integration-blueprint.md` §5.2 khi implemented
- [ ] Remove workaround `component_mappings` trong `input_source_config.mapping_json`

---

## TA-TODO-001

**Title**: `ta.period` ↔ `pay_mgmt.pay_period` — Missing Reverse Link  
**Modules**: Time & Absence (TA)  
**Priority**: High  
**Effort**: Low (chỉ thêm 1 FK field trong TA)

### Problem

Hiện tại, `pay_mgmt.pay_period.ta_period_id` → `ta.period.id` (Change 56 — 14Apr2026).  
**Nhưng phía TA không có FK ngược lại**: `ta.period` không biết nó được link với PR period nào.

**Risk**: TA admin close/archive một period nhưng không biết payroll đang refer đến nó.

### Current State

```
pay_mgmt.pay_period.ta_period_id → ta.period.id  ✅ (Change 56)
ta.period                        → pay_mgmt.pay_period  ❌ (missing)
```

### Proposed Solution

Thêm vào `ta.period` (trong `TA-database-design-v5.dbml`):
```dbml
payroll_period_id  uuid [ref: > pay_mgmt.pay_period.id, null]
-- null = period chưa được link với payroll
-- Soft-link: TA module không phụ thuộc hard vào PR schema
```

**Alternative** (nếu không muốn cross-schema FK trong TA):
- Thêm `payroll_period_ref varchar(50) [null]` (soft reference)
- Hoặc chỉ document as application-layer concern (TA UI hiển thị link info)

### Action Items

- [ ] Xác nhận với TA team: soft FK hay application-layer concern
- [ ] Nếu FK: update `TA-database-design-v5.dbml` + `CHANGELOG.md`
- [ ] TA admin UI: warning khi cố close/archive period đang được referenced bởi payroll
- [ ] Engine pre-flight check: đã implemented (Change 56) — kiểm tra ta_period.status_code = 'LOCKED'

---

## TA-TODO-002

**Title**: `ta.payroll_export_package.payroll_system_ref` → Hard FK to `pay_engine.run_request`  
**Modules**: Time & Attendance (TA)  
**Priority**: Medium  
**Effort**: Low

### Problem

`ta.payroll_export_package` có field:
```dbml
payroll_system_ref varchar(100) [null]  // soft reference: "batch-uuid-xyz"
```

Field này là **soft reference** (varchar) → engine không thể query, join, hay enforce integrity.

### Current Workaround

Payroll engine set `ta.payroll_export_package.dispatch_status = 'ACKNOWLEDGED'` sau khi đọc,  
nhưng không có FK back reference từ TA → PR run_request.

### Proposed Solution

Thêm vào `ta.payroll_export_package` (trong `TA-database-design-v5.dbml`):
```dbml
-- Thay payroll_system_ref varchar → thêm explicit FK:
payroll_run_request_id  uuid [null]
-- FK sang pay_engine.run_request.id (cross-schema, enforce at app layer)
-- Thêm khi engine ACKNOWLEDGES export: UPDATE payroll_export_package
--   SET payroll_run_request_id = :run_request_id, dispatch_status = 'ACKNOWLEDGED'
```

> **Note**: Cross-schema FK giữa TA và PR có thể gây tight coupling.
> Nếu muốn loose coupling: giữ varchar `payroll_system_ref` nhưng enforce format là UUID string.
> Application layer lookup khi cần.

### Action Items

- [ ] Xác nhận coupling strategy với Architecture team
- [ ] Nếu FK: update `TA-database-design-v5.dbml` + `CHANGELOG.md`
- [ ] Nếu soft: enforce UUID format + add app-layer validation
- [ ] Update `07-integration-blueprint.md` §3.1 khi implemented

---

## Future Considerations (Out of Scope)

| Item | Notes |
|------|-------|
| `ta.leave_request` → `pay_engine.result` link | Trace which payroll run processed a leave deduction |
| `pay_bank.payment_line` → `employment.employee` FK | Currently soft via employee_id varchar |
| Real-time compensation change notification | Event-driven instead of period snapshot |
| Benefits enrollment `effective_date` → Payroll proration | Benefits change mid-period not yet handled |

---

## How to Use This Document

1. Khi có sprint planning liên quan đến cross-module integration → review document này
2. Khi item được approved implement → tạo task, update DBML, update CHANGELOG, remove từ đây
3. Khi architecture decision thay đổi → update proposed solution trước khi implement

---

*[Integration Blueprint](./07-integration-blueprint.md) · [CHANGELOG](../CHANGELOG.md) · [Back to README](./00-README.md)*
