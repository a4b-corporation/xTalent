# Complexity Assessment Report
## Payroll Engine — Sample Data Evaluation (MVEL + Drools)

> **Kỳ đánh giá:** 2025-03  
> **Bộ dữ liệu:** 6 nhân viên mẫu — 3 loại hình Việt Nam  
> **Ngày:** 2025-03-04  
> **Mục đích:** Xác định mức độ phức tạp engineering, risks, và đề xuất trước khi implementation chính thức

---

## 1. Tổng Quan Bộ Dữ Liệu

| Artifact | Mô tả | Quy mô |
|---------|-------|--------|
| `employees.json` | Master data 6 nhân viên | 3 loại hình × 2 nhân viên |
| `policy-config.json` | Chính sách: biểu thuế, BHXH, tables | 7 policy groups, 20+ config keys |
| `attendance-2025-03.json` | Chấm công, lịch trực, lịch ca | 6 bản ghi, 8 ca trực, 26 ngày ca công nhân |
| `element-registry.json` | Payroll Elements | **27 elements** (EARNING/DEDUCTION/INFO/TAX) |
| `dependency-chain.md` | Dependency graphs | 3 chains, 12/17/18 nodes |
| MVEL formulas | 4 files | **~40 formula expressions** |
| Drools rules | 5 files .drl | **34 rules** tổng cộng |
| Expected output | Kết quả tính toán manual | 6 nhân viên × ~20 elements |

---

## 2. Complexity Score theo Loại Hình

| Tiêu chí | Nhân viên Văn phòng | Bác sỹ BV | Công nhân Sản phẩm |
|---------|--------------------|-----------|--------------------|
| **Số nodes (elements)** | 12 | 17 | 18 |
| **Số stages** | 5 | 7 | 6 |
| **Branching rules** | 1 (KPI tier) | 3 (hazard+duty+OT) | 4 (quality+shift+floor+OT) |
| **Tax-exempt layers** | 2 (transport+lunch) | **3 layers riêng biệt** | 0 |
| **Intermediate facts** | 0 | **2** (HAZARD split) | 1 (NightShiftFact) |
| **Floor enforcement** | ❌ | ❌ | ✅ GROSS ≥ MinWage |
| **Salary type** | Fixed/monthly | Fixed/monthly | **Piece-rate (dynamic)** |
| **Regulatory references** | 2 | 5 | 3 |
| **Drools rules count** | 6 | **10** | **12** |
| **⭐ Complexity Score** | **3 / 5** | **4 / 5** | **5 / 5** |

---

## 3. Phát Hiện Quan Trọng (Engineering Insights)

### 3.1 Hazard Tax Split — Bác sỹ (★★ HIGH IMPACT ★★)

**Vấn đề phát hiện:** Phụ cấp độc hại VN cần phân tách thành **2 intermediate elements** trước khi vào GROSS:
- `HAZARD_TAX_EXEMPT`: phần ≤ 3,600,000 VNĐ → miễn thuế TNCN
- `HAZARD_TAXABLE`: phần vượt trần → phải chịu thuế TNCN bình thường

**Tại sao phức tạp:** Drools working memory phải lưu cả 2 intermediate facts, GROSS bao gồm TOÀN BỘ, nhưng TAXABLE_INCOME chỉ trừ phần exempt.

**Impact lên engine design:**
- Cần `insert(hazardExemptFact)` + `insert(hazardTaxableFact)` trong cùng 1 rule action
- Rule GROSS_SALARY phải match cả 2 facts riêng
- Rule TAXABLE_INCOME phải match `HAZARD_TAX_EXEMPT` nhưng bỏ qua `HAZARD_TAXABLE`

**Case EMP-004:** Hazard C = 9.6M → exempt=3.6M, taxable=6.0M → thêm 6M vào base PIT
→ **Nếu engine tính sai, PIT sẽ thiếu hơn 1,200,000 VNĐ/nhân viên**

---

### 3.2 progressiveTax() PHẢI là BuiltinFunction

**Vấn đề phát hiện:** DSL grammar cấm `for/while` loop (security constraint từ `01-problem-statement.md`).  
Nhưng tính thuế lũy tiến bắt buộc phải duyệt qua 7 brackets — không thể viết inline MVEL.

**Giải pháp xác nhận:** `progressiveTax(BigDecimal income, List<TaxBracket> brackets)` implemented trong `vn.xtalent.payroll.functions.BuiltinFunctions` (Java), được đăng ký vào MVEL whitelist.

**Engineering implication:**
- `BuiltinFunctions.java` phải được test riêng với đầy đủ test case 7 bậc
- MVEL whitelist chỉ expose method signature này, không expose class toàn bộ
- Phải test edge cases: income=0, income=5M exactly, income>80M (bậc 7)

---

### 3.3 Worker Night OT = 2 Elements Cộng Gộp

**Vấn đề phát hiện:** EMP-006 làm OT Chủ nhật ca đêm = đồng thời được tính:
1. `OT_200` (×2.0 vì ngày nghỉ tuần)
2. `NIGHT_OT_PREMIUM` (+30% vì ca đêm)

**Tại sao tách riêng:** Không thể merge thành 1 element vì:
- Thuế TNCN cần track từng khoản riêng
- BHXH: OT_200 không tính BHXH, nhưng NIGHT_OT_PREMIUM có tính SI? (cần confirm)
- Audit trail: HR muốn xem "được bao nhiêu OT" vs "được bao nhiêu ca đêm"

**Rule design:** Drools phải detect `hasNightOT == true` trong AttendanceRecord → trigger NIGHT_OT_PREMIUM rule riêng, **sau khi** OT_200 đã được insert.

---

### 3.4 GROSS Floor — Ordering Problem

**Vấn đề phát hiện:** Floor enforcement (`max(rawGross, minWage)`) không thể là formula đơn thuần. Phải implement qua **2 rules**:

```
Rule WRK_006 (salience=20): insert TemporaryFact(RAW_GROSS)
Rule WRK_007 (salience=15): read RAW_GROSS → apply floor → insert GROSS_SALARY
```

**Tại sao không thể 1 rule?** GROSS_SALARY rule đọc nhiều sub-elements (piece_rate, quality_bonus, night_allowance, OT). Nếu tất cả cùng được insert vào working memory theo Rete, không có guarantee về ordering. Cần `TemporaryFact` làm barrier.

**Drools pattern:** `not PayrollElement(code=="GROSS_SALARY")` + `not TemporaryFact("RAW_GROSS")` = đảm bảo idempotency.

---

### 3.5 Pre-processing Rule — Ca Đêm Count

**Vấn đề phát hiện:** `nightShiftCount` không phải input từ HR — phải **tính** từ shift schedule trong working memory. Cần pre-processing rule trước mọi rule khác.

**Implementation:** `agenda-group="pre-payroll-worker"` với `salience=300` chạy TRƯỚC `agenda-group="gross-calculation"`. Drools Agenda group ordering: `pre-payroll-worker` → `gross-calculation` → `insurance` → `tax` → `net-calculation`.

---

## 4. Rule Complexity Summary

| Rule File | Rules | Key Patterns | Avg Conditions/Rule |
|-----------|-------|-------------|---------------------|
| `vn-common-insurance.drl` | 9 | Pattern: "not exists" guard | 3-4 |
| `vn-common-pit-tax.drl` | 6 | 3 variants cho 3 loại hình | 5-6 |
| `vn-office-payroll.drl` | 6 | OT ternary, KPI tier | 3-4 |
| `vn-doctor-payroll.drl` | 10 | Hazard split, dual fact insert | **6-7** |
| `vn-worker-payroll.drl` | 12 | Pre-processing, 2-stage floor | **7-8** |
| **TỔNG** | **43** | | **4.6 avg** |

> **Note:** Số rule tăng từ 34 lên 43 khi tính đầy đủ (3 PIT rules split by group)

---

## 5. Risk Assessment

| # | Rủi ro | Likelihood | Impact | Mitigation |
|---|--------|-----------|--------|------------|
| **R1** | Hazard split tính sai → PIT thiếu | Medium | **HIGH** | Unit test `DOC_003` với EMP-004 case |
| **R2** | progressiveTax() edge case | Low | **HIGH** | Standalone test suite 7 bậc + boundary values |
| **R3** | Worker floor race condition | Medium | Medium | 2-rule barrier pattern (WRK_006/007) |
| **R4** | Ca đêm count sai (wrong shift type parse) | Low | Medium | Pre-processing rule + assertion test |
| **R5** | Night OT Premium missing (không trigger) | Medium | Low | Integration test EMP-006 full scenario |
| **R6** | BHXH_BASE không cap khi GROSS > 46.8M | Low | **HIGH** | Test EMP-004 (gross=60.6M → base=46.8M) |

---

## 6. Engineering Effort Estimate (Revised)

| Component | Original Estimate | Revised (dựa trên sample) | Delta |
|-----------|-------------------|--------------------------|-------|
| Drools setup + Rule Units (VN) | 12 pw | 14 pw | +2 pw |
| MVEL sandbox implementation | 6 pw | 6 pw | 0 |
| BuiltinFunctions (progressiveTax, etc.) | — | **4 pw** | +4 pw (chưa tính) |
| Docker/Hazard split design | — | **3 pw** | +3 pw (phức tạp hơn dự kiến) |
| Worker pre-processing rules | — | **2 pw** | +2 pw |
| Formula registry + versioning | 4 pw | 4 pw | 0 |
| Simulation engine | 6 pw | 6 pw | 0 |
| Retroactive engine | 5 pw | 5 pw | 0 |
| Approval workflow | 3 pw | 3 pw | 0 |
| ANTLR4 DSL grammar + compiler | 8 pw | 8 pw | 0 |
| Formula Studio UI | 10 pw | 10 pw | 0 |
| Performance + testing | 6 pw | 8 pw | +2 pw |
| **Tổng** | **~60 pw** | **~73 pw** | **+13 pw (+22%)** |

> **Kết luận effort:** Sample data thực tế cho thấy phức tạp hơn ước tính ban đầu khoảng **22%**, chủ yếu do:
> - `progressiveTax()` cần BuiltinFunctions riêng (chưa tính)
> - Hazard split cần intermediate facts phức tạp trong working memory
> - Worker pre-processing rules

---

## 7. Đề Xuất Kiến Trúc (Từ Sample Data)

### 7.1 Confirm kiến trúc H4 là đúng hướng
Sample data xác nhận **Drools 8 + MVEL** là lựa chọn phù hợp:
- Drools working memory handle được intermediate facts (HAZARD split)
- Rete/Phreak ordering đảm bảo chain đúng thứ tự (salience + agenda-group)
- MVEL cho phép formula ngắn gọn với BuiltinFunctions inject
- Rule Units có thể tách riêng OFFICE / DOCTOR / WORKER

### 7.2 Recommended Agenda Group Ordering
```
pre-payroll-worker  (salience 300+) ← Pre-processing ca đêm, validate
pre-payroll-doctor  (salience 290+) ← Hazard classification
gross-calculation   (salience 70-90)← Tất cả earning elements
insurance           (salience 40-60)← BHXH/BHYT/BHTN
tax                 (salience 20-40)← Taxable income + PIT
net-calculation     (salience 10)   ← NET_SALARY final
post-processing     (salience 5)    ← Làm tròn, báo cáo
```

### 7.3 BuiltinFunctions cần implement (Priority)
1. `progressiveTax(BigDecimal income, List<TaxBracket> brackets)` — **CRITICAL**
2. `proRata(BigDecimal base, int actual, int standard)` — **HIGH**
3. `min(BigDecimal a, BigDecimal b)` / `max(BigDecimal a, BigDecimal b)` — **HIGH** (wrap BigDecimal.min/max)
4. `lookup(String tableName, String key)` — **MEDIUM** (gọi PolicyService)
5. `sumElements(List elements, Function fn)` — **MEDIUM** (aggregation)

### 7.4 Test Case Priority
Dựa trên risk assessment, **test theo thứ tự:**
1. **EMP-004** (Trưởng khoa, Loại C): Test hazard split + PIT bậc cao + BHXH cap
2. **EMP-006** (Công nhân luân ca): Test pre-processing ca đêm + OT ca đêm + floor
3. **EMP-002** (Sales Manager): Test OT 3 loại + KPI bonus + PIT bậc 5
4. **EMP-003** (BS Nội): Test duty pay 2 khoản + PIT case trung bình
5. **EMP-001** / **EMP-005**: Happy path validation

---

## 8. Kết Luận

> **Bộ dữ liệu sample này ĐỦ PHỨC TẠP** để:
> 1. Validate kiến trúc Drools + MVEL trước khi implement production code
> 2. Phát hiện 5 engineering issues quan trọng không có trong tài liệu thiết kế ban đầu
> 3. Cung cấp expected output để so sánh kết quả engine (verification baseline)
> 4. Estimate lại effort thực tế (+22% so với ban đầu)

**Khuyến nghị tiếp theo:**
- [ ] Implement POC nhỏ với **chỉ EMP-004** scenario (Hazard C + cap BHXH + PIT)
- [ ] Validate `progressiveTax()` và `HAZARD_SPLIT` rule trước khi Phase 1 production rules
- [ ] Checklist accept của Architecture Board cần bổ sung: test case EMP-004 khớp expected output
