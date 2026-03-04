# Sample Payroll Data — xTalent HCM Payroll Engine (MVEL + Drools 8)

> **Mục đích:** Bộ dữ liệu mô phỏng để đánh giá mức độ phức tạp khi triển khai Payroll Engine theo kiến trúc H4 (Drools 8 + Restricted MVEL + Business DSL Layer)  
> **Kỳ mẫu:** 2025-03  
> **Thị trường:** Việt Nam  
> **Ngày tạo:** 2025-03-04

---

## Cấu Trúc Thư Mục

```
sample-payroll/
├── README.md                              ← File này
├── docs/                                  ← 📖 Tài liệu diễn giải (MỚI)
│   ├── data-dictionary.md                ← Từ điển dữ liệu: giải thích mọi field JSON
│   └── calculation-walkthrough.md        ← Trace từng bước tính EMP-004 và EMP-006
├── sample-data/
│   ├── master-data/
│   │   ├── employees.json                 ← 6 nhân viên (2 per loại hình)
│   │   └── policy-config.json            ← Biểu thuế, BHXH, bảng phụ cấp y tế, piece-rate
│   └── time-attendance/
│       └── attendance-2025-03.json        ← Chấm công tháng 3/2025
├── formulas/
│   ├── element-registry.json             ← 27 Payroll Elements (EARNING/DEDUCTION/INFO/TAX)
│   ├── dependency-chain.md               ← Dependency graphs, 5 key design decisions
│   └── mvel/
│       ├── common-formulas.mvel          ← BHXH, PIT, Net (dùng chung)
│       ├── office-formulas.mvel          ← Pro-rata, OT, KPI bonus, taxable income
│       ├── doctor-formulas.mvel          ← Hazard tax split, duty pay, 3-layer exemption
│       └── worker-formulas.mvel          ← Piece-rate, quality tier, ca đêm, floor enforcement
├── drools/
│   └── rules/
│       ├── vn-common-insurance.drl       ← BHXH/BHYT/BHTN/TNLĐ (9 rules)
│       ├── vn-common-pit-tax.drl         ← PIT 7 bậc cho 3 loại hình (6 rules)
│       ├── vn-office-payroll.drl         ← Văn phòng (6 rules)
│       ├── vn-doctor-payroll.drl         ← Bác sỹ (10 rules) ★★ PHỨC TẠP ★★
│       └── vn-worker-payroll.drl         ← Công nhân (12 rules) ★★ PHỨC TẠP NHẤT ★★
└── output/
    ├── payroll-results/
    │   └── all-employees-expected.json   ← Kết quả tính tay cho 6 nhân viên
    └── complexity-assessment.md          ← Báo cáo đánh giá phức tạp + đề xuất
```

---

## 📖 Tài Liệu Hỗ Trợ (docs/)

### [`data-dictionary.md`](docs/data-dictionary.md) — Từ Điển Dữ Liệu

Giải thích **mọi trường** trong các file JSON và quy ước viết engine:

- **`employees.json`**: Ý nghĩa từng field (salary, allowances, hazardInfo, shiftInfo, taxInfo), enum values hợp lệ, cách đọc cấu trúc lồng nhau
- **`policy-config.json`**: Biểu thuế 7 bậc (công thức), BHXH ceiling/rates, bảng phụ cấp độc hại A/B/C, đơn giá piece-rate, quality tier table
- **`attendance-2025-03.json`**: Cách đọc OT records, lịch trực bác sỹ (duty schedule), lịch ca công nhân (rotating shift — quy tắc xác định CA_DEM theo ĐẦU CA)
- **`element-registry.json`**: Cấu trúc 1 element, phân loại type/subtype, bảng executionOrder 1–11
- **Drools rules**: Quy ước agenda-group, salience, guard pattern (`not PayrollElement`)
- **MVEL formulas**: BigDecimal everywhere, RoundingMode bắt buộc, ternary vs if-else, whitelist function calls

### [`calculation-walkthrough.md`](docs/calculation-walkthrough.md) — Trace Tính Toán

Trace **từng rule Drools** theo đúng thứ tự thực thi cho 2 case phức tạp nhất:

**EMP-004 — Trưởng Khoa Ung Bướu (Hazard C):**
- Stage-by-stage từ `BASE_SALARY` đến `NET_SALARY` (11 stages)
- Hiển thị rõ tại sao `HAZARD_TAXABLE = 6,000,000` phải chịu thuế
- Giải thích tại sao `BHXH_BASE` bị cap tại 46.8M dù GROSS = 60.6M
- PIT trace qua 4 bậc với số liệu cụ thể

**EMP-006 — Công Nhân Luân Ca 3 Ca:**
- Pre-processing rule ca đêm (salience=300) chạy trước tất cả
- Piece-rate + Quality Tier 1 bonus
- OT ca đêm Chủ nhật = 2 elements tách riêng (OT_200 + NIGHT_OT_PREMIUM)
- GROSS floor check: 8.76M > 4.96M min wage → floor không áp dụng

Kèm **Verification Checklist** 14 điểm để QA/Engineer cross-check kết quả engine.

---

## 3 Loại Hình Nhân Viên

| ID | Tên | Loại | Đặc thù | Complexity |
|----|-----|------|---------|------------|
| EMP-001 | Nguyễn Thị Mai | Văn phòng Junior | Pro-rata (nghỉ phép), KPI bonus, OT 150% | ⭐⭐⭐ |
| EMP-002 | Trần Văn Hùng | Sales Manager | OT 3 loại (150/200/300%), KPI cao, PIT bậc 5 | ⭐⭐⭐⭐ |
| EMP-003 | Lê Thị Thu Hà | Bác sỹ Nội (Hazard B) | Nghỉ bệnh, 3 ca trực (1 lễ + 1 CN + 1 thường), Hazard B = 0 taxable | ⭐⭐⭐⭐ |
| **EMP-004** | **Phạm Đức Minh** | **TK Ung bướu (Hazard C)** | **Hazard vượt trần 6M chịu thuế, BHXH capped, PIT bậc 4** | **⭐⭐⭐⭐⭐** |
| EMP-005 | Hoàng Văn Dũng | Công nhân ca ngày | Piece-rate, quality tier 2, không ca đêm | ⭐⭐⭐ |
| **EMP-006** | **Vũ Thị Lan** | **Công nhân luân ca 3 ca** | **3 loại ca, OT ca đêm CN = 2 khoản, quality tier 1** | **⭐⭐⭐⭐⭐** |

---

## 5 Engineering Insights Quan Trọng

### D1 — Hazard Tax Split (Doctor)
Phụ cấp độc hại phải tách thành `HAZARD_TAX_EXEMPT` + `HAZARD_TAXABLE` (2 facts trong working memory).  
**Impact:** Rule TAXABLE_INCOME phải trừ exempt, giữ taxable trong gross base.

### D2 — progressiveTax() phải là BuiltinFunction  
DSL grammar cấm loop → không thể inline. Phải implement trong Java và đăng ký vào MVEL whitelist.

### D3 — GROSS Floor qua 2-stage Rules (Worker)
Floor `max(rawGross, minWage)` cần barrier pattern: `WRK_006` insert TemporaryFact, `WRK_007` apply floor.

### D4 — Ca Đêm Count qua Pre-processing Rule  
`nightShiftCount` tính từ lịch tháng, xác định theo ĐẦU CA. Cần rule `salience=300` trước mọi rule khác.

### D5 — OT Ca Đêm = 2 Elements Riêng  
`OT_200` (×2 cuối tuần) + `NIGHT_OT_PREMIUM` (+30% ca đêm) → tách riêng cho audit trail và BHXH handling.

---

## Kết Quả Tóm Tắt (Manual Calculation)

| Nhân viên | GROSS | PIT | NET |
|----------|-------|-----|-----|
| EMP-001 Văn phòng Jr | 18,514,616 | 0 | 16,570,582 |
| EMP-002 Sales Manager | 56,666,347 | 5,500,587 | 46,251,760 |
| EMP-003 BS Nội B | 25,399,667 | 366,070 | 22,332,632 |
| EMP-004 TK Ung bướu C | 60,636,498 | 4,140,000 | **51,582,538** |
| EMP-005 CN ca ngày | 6,951,880 | 0 | 6,221,933 |
| EMP-006 CN luân ca | 8,757,275 | 0 | 7,837,761 |

> Chi tiết từng element: xem `output/payroll-results/all-employees-expected.json`  
> Báo cáo phức tạp đầy đủ: xem `output/complexity-assessment.md`

---

## Liên Kết Tài Liệu Nghiên Cứu

Bộ sample này là output thực hành từ nghiên cứu tại thư mục cha (`../`):
- `01-problem-statement.md` — Business requirements & 3 execution modes
- `02-detailed-analysis.md` — KPI analysis, 11 candidates, Drools 8 xếp #1
- `03-proposal.md` — H4 hybrid architecture (Drools + MVEL + Business DSL)
