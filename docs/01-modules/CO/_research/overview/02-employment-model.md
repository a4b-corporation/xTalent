# Mô hình Employment — Vòng đời Nhân sự

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: Business Users, HR Administrators  
**Thời gian đọc**: ~20 phút

---

## Tổng quan

Đây là một trong những **thiết kế khác biệt lớn nhất** của CO Module so với các hệ thống HR truyền thống: thay vì dùng một entity "Nhân Viên" duy nhất gộp tất cả thông tin lại, CO tách thành **4 cấp độ rõ ràng**, mỗi cấp giải quyết một câu hỏi riêng biệt.

---

## Vấn đề của hệ thống HR truyền thống

Phần lớn hệ thống HR cũ dùng một bản ghi "Nhân viên" chứa tất cả:
- Thông tin cá nhân (tên, ngày sinh, CCCD)
- Thông tin hợp đồng (ngày vào, loại hợp đồng, mã nhân viên)
- Thông tin phân công (phòng ban, chức danh, cấp trên)

**Hệ quả thực tế**:

| Tình huống | Vấn đề với hệ thống cũ |
|-----------|----------------------|
| Thuê contractor/freelancer | Phải tạo "nhân viên giả", data không phản ánh thực tế |
| Nhân viên cũ tái gia nhập (rehire) | Phải tạo hồ sơ mới → mất toàn bộ lịch sử cũ |
| Một người vừa là nhân viên vừa là advisor (consultant) | Hệ thống không cho phép 1 người có 2 loại quan hệ đồng thời |
| Tách biệt lịch sử "con người" vs lịch sử "hợp đồng" | Không thể, vì tất cả trong cùng 1 bảng |

---

## Giải pháp: 4-Level Employment Hierarchy

CO tách biệt thành 4 cấp độ, mỗi cấp có vòng đời và mục đích riêng:

```
┌──────────────────────────────────────────────────────────────┐
│  Cấp 1: WORKER — "Người này là ai?"                          │
│  • Tên, ngày sinh, CCCD, thông tin cá nhân                  │
│  • Bất biến — tạo một lần, không bao giờ xóa               │
│  • Tồn tại dù người đó chưa/không còn làm việc             │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│  Cấp 2: WORK RELATIONSHIP — "Mối quan hệ với tổ chức là gì?"│
│  • Loại quan hệ: NHÂN VIÊN / CONTRACTOR / TƯ VẤN / INTERN  │
│  • Có ngày bắt đầu, ngày kết thúc                          │
│  • Một người có thể có nhiều mối quan hệ (đồng thời hoặc  │
│    tuần tự)                                                  │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│  Cấp 3: EMPLOYEE — "Hợp đồng lao động có điều khoản gì?"   │
│  • Chỉ áp dụng với NHÂN VIÊN (không áp dụng cho contractor) │
│  • Mã nhân viên, ngày vào làm, ngày hết thử việc            │
│  • Thâm niên, loại hợp đồng                                 │
└──────────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────────┐
│  Cấp 4: ASSIGNMENT — "Người này đang làm gì, ở đâu?"       │
│  • Vị trí/chức danh, phòng ban, địa điểm làm việc          │
│  • Cấp trên trực tiếp (solid line reporting)                │
│  • Lý do thay đổi: tuyển mới / thuyên chuyển / thăng chức  │
└──────────────────────────────────────────────────────────────┘
```

---

## Các loại Work Relationship

Không phải ai làm việc trong tổ chức cũng là "nhân viên". CO quản lý đầy đủ:

| Loại | Mô tả | Có hợp đồng lao động? | Có trên bảng lương? |
|-----|-------|----------------------|-------------------|
| **EMPLOYEE** | Nhân viên chính thức | ✅ Có | ✅ Có |
| **CONTRACTOR** | Freelancer, nhà thầu độc lập | ❌ Không | ❌ Không (thanh toán qua invoice) |
| **CONSULTANT** | Chuyên gia tư vấn bên ngoài | ❌ Không | ❌ Không |
| **INTERN** | Thực tập sinh | ⚠️ Tùy loại | ⚠️ Tùy hợp đồng |
| **VOLUNTEER** | Tình nguyện viên | ❌ Không | ❌ Không |

---

## Ví dụ thực tế

### Tình huống 1: Nhân viên mới vào làm

```
Bước 1: Tạo Worker (hồ sơ cá nhân)
  → Nguyễn Văn An, sinh 1990, CCCD: 001234567890

Bước 2: Tạo Work Relationship (mối quan hệ)
  → Loại: NHÂN VIÊN, bắt đầu: 01/01/2024

Bước 3: Tạo Employee (hợp đồng)
  → Mã nhân viên: EMP-2024-001
  → Ngày vào: 01/01/2024, hết thử việc: 01/03/2024

Bước 4: Tạo Assignment (phân công)
  → Vị trí: Backend Engineer
  → Phòng ban: Engineering
  → Lý do: HIRE (tuyển mới)
```

### Tình huống 2: Contractor chuyển thành nhân viên chính thức

```
Giai đoạn 1 — Contractor (01/01/2024 → 30/06/2024):
  Worker: Trần Thị Bình
  Work Relationship #1: CONTRACTOR (kết thúc 30/06/2024)
  → KHÔNG có hồ sơ Employee
  → Thanh toán qua invoice

Giai đoạn 2 — Nhân viên chính thức (01/07/2024):
  Worker: Trần Thị Bình  ← Cùng 1 bản ghi, không tạo mới
  Work Relationship #2: NHÂN VIÊN (bắt đầu 01/07/2024)
  Employee: EMP-2024-011 (tạo mới)
  Assignment: Senior Backend Engineer (tạo mới)

→ Toàn bộ lịch sử contractor được giữ nguyên
```

### Tình huống 3: Nhân viên cũ tái gia nhập (Rehire)

```
2020–2022: Nhân viên lần 1
  Worker: Lê Văn Cường (ID: WORKER-003)
  Work Relationship #1: NHÂN VIÊN (2020 → 2022, nghỉ việc)
  Employee: EMP-020 (lịch sử)

2024: Tái gia nhập
  Worker: Lê Văn Cường (ID: WORKER-003) ← Cùng bản ghi!
  Work Relationship #2: NHÂN VIÊN (2024 → nay)
  Employee: EMP-031 (mới) — hire_date: 2024
                           — original_hire_date: 2020 ← giữ nguyên gốc

→ Thâm niên được tính từ 2020, không phải 2024
→ Lịch sử không bị mất
```

### Tình huống 4: Một người, hai mối quan hệ đồng thời

```
Nguyễn Văn Dũng là:
  Work Relationship #1: NHÂN VIÊN toàn thời gian (Engineering)
  Work Relationship #2: CONTRACTOR bán thời gian (Technical Advisor, 20%)

→ Hệ thống quản lý được cả hai song song
→ Lương nhân viên và phí tư vấn được tách biệt
```

---

## Quản lý Hợp đồng Lao động

CO quản lý vòng đời hợp đồng với đầy đủ các trạng thái chuyển tiếp:

### Các loại hợp đồng được hỗ trợ

| Loại | Mô tả | Đặc điểm |
|-----|-------|----------|
| **PROBATION** | Thử việc | Có thời hạn, thường 60–180 ngày |
| **FIXED_TERM** | Xác định thời hạn | Tối đa 36 tháng theo luật VN |
| **PERMANENT** | Không xác định thời hạn | Không có ngày kết thúc |
| **SEASONAL** | Thời vụ | Lặp lại theo mùa vụ |

### Mối quan hệ giữa các hợp đồng

Hợp đồng có thể có quan hệ cha–con để theo dõi lịch sử thay đổi:

```
AMENDMENT    → Sửa đổi điều khoản (ví dụ: tăng lương)
ADDENDUM     → Bổ sung điều khoản mới (ví dụ: thêm bonus structure)
RENEWAL      → Gia hạn hợp đồng (ví dụ: tái ký thêm 1 năm)
SUPERSESSION → Thay thế hoàn toàn (ví dụ: thử việc → chính thức)
```

**Ví dụ thực tế — Vòng đời hợp đồng điển hình (Việt Nam)**:

```
01/01/2025: Hợp đồng thử việc 2 tháng
    ↓ [SUPERSESSION — chuyển sang chính thức]
01/03/2025: Hợp đồng XĐTHN 12 tháng (lương tăng)
    ↓ [AMENDMENT — điều chỉnh lương giữa kỳ]
01/07/2025: Hợp đồng XĐTHN 12 tháng (đã sửa lương)
    ↓ [RENEWAL — gia hạn thêm 12 tháng]
01/03/2026: Hợp đồng XĐTHN 12 tháng (ký mới)
    ↓ [SUPERSESSION — chuyển sang vô thời hạn]
01/03/2027: Hợp đồng vô thời hạn (PERMANENT)
```

### Contract Templates

CO cho phép tạo **mẫu hợp đồng tiêu chuẩn** theo quốc gia và loại nhân sự. Templates đảm bảo tuân thủ pháp luật lao động và tính nhất quán:

```
Ví dụ — Template: Nhân viên IT Việt Nam, Fixed-Term 12 tháng
  • Quốc gia: VN
  • Thời hạn mặc định: 12 tháng
  • Thời hạn tối đa: 36 tháng (luật lao động VN)
  • Số lần gia hạn tối đa: 1 lần (sau đó phải ký HĐLĐ)
  • Thử việc: Bắt buộc, 60 ngày
```

---

## Vòng đời Employment đầy đủ

```
[Ứng tuyển]     → Worker (type: APPLICANT)
      ↓
[Được tuyển]    → Worker (type: EMPLOYEE)
                   Work Relationship (NHÂN VIÊN)
                   Employee (hợp đồng thử việc)
                   Assignment (phân công ban đầu)
      ↓
[Thử việc qua] → Hợp đồng chính thức (SUPERSESSION)
      ↓
[Thăng chức]   → Assignment mới (lý do: PROMOTION)
      ↓
[Thuyên chuyển]→ Assignment mới (lý do: TRANSFER)
      ↓
[Nghỉ việc]    → Work Relationship kết thúc
                   Worker (type: ALUMNUS — cựu nhân viên)
      ↓
[Tái gia nhập] → Work Relationship mới
                   Employee mới (giữ original_hire_date)
```

---

## Lý do Assignment (Assignment Reasons)

Mỗi lần thay đổi phân công đều có lý do rõ ràng, phục vụ cho báo cáo và analytics:

| Mã | Ý nghĩa |
|----|---------|
| HIRE | Tuyển mới |
| TRANSFER | Thuyên chuyển nội bộ |
| PROMOTION | Thăng chức |
| DEMOTION | Giáng chức |
| RETURN | Trở lại sau nghỉ phép dài |
| RESTRUCTURE | Do tái cơ cấu tổ chức |
| LATERAL_MOVE | Chuyển ngang (cùng cấp, khác vai trò) |

---

*Tài liệu tiếp theo: [03 · Mô hình Tổ chức](./03-organization-model.md)*
