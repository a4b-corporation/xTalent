# Accounting & Reporting — Kế toán & Báo cáo

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-06  
**Đối tượng**: Finance, Accounting, Payroll Admin  
**Thời gian đọc**: ~20 phút

---

## Tổng quan

Sau khi tính lương xong, PR module cần hai nhóm output quan trọng: **Kế toán** (ghi nhận chi phí vào sổ cái GL) và **Báo cáo** (payslip, báo cáo ngân hàng, báo cáo thuế). Tầng Accounting & Reporting đảm bảo mọi số liệu được chuyển đúng địa chỉ, đúng định dạng, với đầy đủ trace để audit.

```
PayrollResult (đã tính)
      ├── GLMappingPolicy → GL Journal Entries (cho Kế toán)
      ├── PayslipTemplate → Employee Payslips (cho Nhân viên)
      ├── BankTemplate → Bank Payment Files (cho Ngân hàng)
      └── TaxReportTemplate → Tax Reports (cho Cơ quan Thuế)
```

---

## 1. GLMappingPolicy — Ánh xạ sang Sổ cái

**GLMappingPolicy** là ENTITY định nghĩa mapping từ PayElement sang GL Account — cho phép hệ thống tự động tạo journal entries kế toán sau mỗi production run.

### Cấu trúc GLMappingPolicy

```
GLMappingPolicy {
  policyCode: String           // VN-GL-STANDARD
  payElement: PayElement       // Element nào được map
  legalEntity: LegalEntity     // Mapping theo pháp nhân
  
  debitAccount: String         // Tài khoản ghi Nợ (chi phí)
  creditAccount: String        // Tài khoản ghi Có (phải trả)
  
  costCenter: CostCenter?      // Cost center mặc định (nếu không dùng CostingRule)
  dimension: Map<String, String>  // Thêm dimension kế toán (project, product line...)
  
  effectiveDate: Date
  expiryDate: Date?
}
```

### Ví dụ GL Mapping theo Chuẩn Kế toán VN (VAS)

| PayElement | Debit (Chi phí) | Credit (Phải trả) | Ghi chú |
|-----------|:---------------:|:-----------------:|---------|
| `BASE_SALARY` | 642 (Chi phí nhân viên) | 334 (Phải trả CNV) | Lương cơ bản |
| `OVERTIME` | 642 | 334 | Làm thêm giờ |
| `LUNCH_ALLOWANCE` | 642 | 334 | Phụ cấp ăn ca |
| `BHXH_EMPLOYER` | 642 | 3383 (BHXH, BHYT) | Phần công ty đóng |
| `BHYT_EMPLOYER` | 642 | 3383 | Phần công ty đóng |
| `BHTN_EMPLOYER` | 642 | 3383 | |
| `PIT_TAX` | 334 | 3335 (Thuế phải nộp NN) | Khấu trừ tại nguồn |
| `BHXH_EMPLOYEE` | 334 | 3383 | Khấu trừ từ lương |
| `NET_SALARY` | 334 | 112 (Tiền ngân hàng) | Khi thanh toán |

### Journal Entry tự động

Sau khi Production Run được approve, hệ thống tự động tạo journal entries:

```
Kỳ lương: 2025-03 | Legal Entity: VNG Vietnam | Journal: PR-2025-03-001

Dr 642 - Chi phí nhân viên     1,450,000,000
  Cr 334 - Phải trả CNV                          1,134,500,000
  Cr 3383 - BHXH, BHYT, BHTN phải trả              200,000,000
  Cr 3335 - Thuế TNCN phải nộp                     115,500,000

Memo: Lương tháng 3/2025 | 1,248 nhân viên | PayGroup: VN-ALL
Reference: PayrollRun-ID-2025-03-PROD-001
```

### Multi-Cost-Center Allocation

Khi CostingRule phân bổ lương sang nhiều cost center:

```
Nhân viên A: 70% Marketing (CC: MKT), 30% R&D (CC: R&D)

Dr 642 (CC: MKT)  35,000,000    ← 70% × 50M gross
Dr 642 (CC: R&D)  15,000,000    ← 30% × 50M gross
  Cr 334                         50,000,000
```

---

## 2. PayAdjustReason — Lý do Điều chỉnh

**PayAdjustReason** là REFERENCE_DATA cung cấp danh sách lý do chuẩn để ghi vào audit trail khi tạo adjustment hoặc retroactive:

| Code | Mô tả | Requires Approval |
|------|-------|:------------------:|
| `SALARY_INCREASE` | Nâng lương theo review cycle | ✅ |
| `CORRECTION_ERROR` | Sửa lỗi tính toán kỳ trước | ✅ |
| `POLICY_CHANGE` | Áp dụng chính sách mới hồi tố | ✅ |
| `CONTRACT_CHANGE` | Thay đổi hợp đồng lao động | ✅ |
| `BONUS_ONE_TIME` | Thưởng đột xuất | ✅ |
| `DATA_CORRECTION` | Sửa dữ liệu master (attendance, grade...) | ✅ |
| `ADVANCE_DEDUCTION` | Khấu trừ tạm ứng | ❌ (auto) |

---

## 3. PayslipTemplate — Mẫu Phiếu Lương

**PayslipTemplate** là ENTITY cho phép cấu hình layout phiếu lương linh hoạt — mỗi PayGroup hoặc Legal Entity có thể có template riêng.

### Cấu trúc PayslipTemplate

```
PayslipTemplate {
  templateCode: String         // VN-STANDARD-PAYSLIP
  language: String             // vi | en | bilingual
  
  sections: [Section] {
    sectionTitle: String       // "I. THU NHẬP", "II. CÁC KHOẢN KHẤU TRỪ"
    displayOrder: Integer
    elements: [ElementDisplay] {
      elementCode: String      // Chọn PayElements để hiển thị
      displayName: String      // Có thể override tên element
      format: String           // currency | number | date | text
      showIfZero: Boolean      // Hiện dòng kể cả khi = 0?
    }
  }
  
  summarySection: {
    showGross: Boolean
    showTotalDeduction: Boolean
    showNetSalary: Boolean
    showYTD: Boolean           // Hiện YTD cộng dồn không?
  }
  
  footer: {
    legalStatement: String     // "Phiếu lương theo Luật Lao động..."
    signatureRequired: Boolean
    digitalSignature: Boolean  // Chữ ký số / e-signature
  }
}
```

### Ví dụ Payslip Layout

```
┌─────────────────────────────────────────────────────┐
│  PHIẾU LƯƠNG THÁNG 3/2025                          │
│  Nhân viên: NGUYEN VAN A  |  Mã NV: EMP-001        │
│  Phòng: Engineering       |  Ngân hàng: VC-xxx      │
├─────────────────────────────────────────────────────┤
│  I. THU NHẬP                                        │
│  Lương cơ bản                          30,000,000   │
│  Phụ cấp điện thoại                     1,000,000   │
│  Phụ cấp ăn ca                            800,000   │
│  Làm thêm giờ (18h)                     2,700,000   │
│  ─────────────────────────────────────────────────  │
│  TỔNG THU NHẬP (GROSS)                34,500,000   │
├─────────────────────────────────────────────────────┤
│  II. CÁC KHOẢN KHẤU TRỪ                            │
│  BHXH nhân viên (8%)                    2,760,000   │
│  BHYT nhân viên (1.5%)                    517,500   │
│  BHTN nhân viên (1%)                      345,000   │
│  Thuế TNCN                              1,224,375   │
│  ─────────────────────────────────────────────────  │
│  TỔNG KHẤU TRỪ                         4,846,875   │
├─────────────────────────────────────────────────────┤
│  LƯƠNG THỰC NHẬN (NET)                29,653,125   │
├─────────────────────────────────────────────────────┤
│  YTD (Cộng dồn từ đầu năm)                         │
│  Gross YTD: 98,000,000 | PIT YTD: 3,521,250        │
└─────────────────────────────────────────────────────┘
```

### Phân phối Payslip

- **Employee Self-service Portal**: Nhân viên tự xem/download PDF
- **Email**: Tự động gửi email sau khi period locked
- **Batch PDF**: Admin export toàn bộ payslip một lần
- **Digital Signature**: Hỗ trợ chữ ký điện tử theo Nghị định 130/2018

---

## 4. BankTemplate — File Thanh toán Ngân hàng

**BankTemplate** là REFERENCE_DATA định nghĩa format file payment cho từng ngân hàng:

| Bank | Format | Standard |
|------|--------|----------|
| Vietcombank | VCB.txt (fixed-width) | VCB Internet Banking |
| BIDV | BIDV.csv | BIDV Smart Banking |
| Techcombank | TCB.xlsx | TCB Payroll |
| VietinBank | CTG.txt | VietinBank eBanking |
| Agribank | AGR.txt | Agribank iB@nking |
| ACB | ACB.csv | ACB Online |
| Timo / FinTech | ISO 20022 XML | CB standard |

### File Generation Process

```
1. Production Run → LOCKED
2. Admin chọn bank template cho PayGroup
3. Hệ thống generate file với:
   - Batch header (ngày, tổng số tiền, số lệnh)
   - Detail records (mã NV, tên, số tài khoản, số tiền, nội dung)
   - Footer/control sum (checksum để ngân hàng verify)
4. Admin download và upload lên hệ thống ngân hàng
5. (Tương lai: Banking API integration — tự động submit)
```

---

## 5. TaxReportTemplate — Báo cáo Thuế

**TaxReportTemplate** định nghĩa các loại báo cáo thuế xuất ra cho cơ quan nhà nước:

### Báo cáo định kỳ VN

| Báo cáo | Mô tả | Kỳ | Nộp cho | Format |
|---------|-------|-----|---------|--------|
| **TK-TNCN Quý** | Khai thuế TNCN hàng quý | Quý | Cục Thuế | XML (TT8/2013) |
| **TK-TNCN Năm** | Quyết toán thuế năm | Năm | Cục Thuế | XML |
| **Bảng kê BHXH** | Danh sách đóng BHXH | Tháng | Cơ quan BHXH | VssID |
| **D01-TS** | Điều chỉnh thông tin BHXH | Khi có thay đổi | BHXH | VssID |
| **Phụ lục TNCN** | Danh sách khấu trừ cho từng NV | Năm | Đính kèm quyết toán | Excel |

### Báo cáo nội bộ

| Báo cáo | Nội dung |
|---------|---------|
| **Payroll Register** | Toàn bộ kết quả mọi employee, mọi element |
| **Variance Report** | So sánh kỳ này vs kỳ trước (% change) |
| **Exception Report** | Nhân viên có kết quả bất thường |
| **YTD Summary** | Cộng dồn từ đầu năm theo department |
| **Budget vs Actual** | So sánh quỹ lương kế hoạch vs thực tế |
| **Cost Center Report** | Chi phí nhân sự phân bổ theo CC |
| **Headcount Report** | Số lượng nhân viên trong payroll run |

---

## 6. Audit Trail — Vết kiểm toán

Mọi action liên quan đến accounting và reporting đều được log:

```
AuditEntry examples:
  PAYROLL_RUN_COMPLETED: runId, formulaVersionSnapshot, employeeCount, totalGross
  GL_ENTRIES_POSTED: journalBatchId, entryCount, totalAmount
  BANK_FILE_GENERATED: templateCode, fileHash, employeeCount
  PAYSLIP_DOWNLOADED: employeeId, downloadedBy, timestamp
  TAX_REPORT_EXPORTED: reportType, period, exportedBy
```

- **Retention**: 7 năm theo quy định kế toán VN (Thông tư 200/2014)
- **Immutable**: Không thể sửa hay xóa audit entries
- **Partitioned**: Log phân vùng theo tháng để query hiệu quả

---

*← [06 Formula Engine Architecture](./06-formula-engine-architecture.md) · [08 Integration Architecture →](./08-integration-architecture.md)*
