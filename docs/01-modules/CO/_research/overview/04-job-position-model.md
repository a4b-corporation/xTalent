# Job & Position Management — Cấu trúc Công việc & Staffing Models

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: HR Administrators, Finance, Business Managers  
**Thời gian đọc**: ~20 phút

---

## Tổng quan

CO Module cung cấp một hệ thống quản lý Job & Position linh hoạt, bao gồm:
- **Job Taxonomy**: Phân loại công việc theo cây phân cấp chuẩn hóa
- **Job Profiles**: Mô tả yêu cầu cho từng vị trí (skills, competencies, education)
- **Position Management**: Quản lý các "headcount slot" trong tổ chức
- **Staffing Models**: Hỗ trợ cả hai mô hình bố trí nhân sự phổ biến
- **Career Paths**: Lộ trình thăng tiến được thiết kế sẵn

---

## Job Taxonomy — Phân loại Công việc

### Cấu trúc 3-cấp

Tất cả công việc trong tổ chức được phân loại theo một cây phân cấp 3 cấp:

```
Cấp 1: Job Family (Nhóm nghề lớn)
  └── Cấp 2: Job Sub-family (Nhóm nghề con)
        └── Cấp 3: Job Function (Chức năng cụ thể)
```

**Ví dụ thực tế**:

```
Technology (Family)
  ├── Software Engineering (Sub-family)
  │     ├── Backend Development (Function)
  │     ├── Frontend Development (Function)
  │     └── Mobile Development (Function)
  └── Data & Analytics (Sub-family)
        ├── Data Engineering (Function)
        └── Data Science (Function)

Business (Family)
  ├── Sales (Sub-family)
  │     ├── Enterprise Sales (Function)
  │     └── SMB Sales (Function)
  └── Marketing (Sub-family)
        ├── Digital Marketing (Function)
        └── Brand Management (Function)
```

### Multi-tree: Taxonomy riêng cho từng bộ phận

Bên cạnh taxonomy toàn công ty, mỗi Business Unit có thể có **taxonomy riêng** phản ánh đặc thù của mình. Taxonomy BU có thể kế thừa từ taxonomy toàn công ty và customize thêm.

```
VNG Corp Taxonomy (Corporate)
  └── Technology → Software Engineering → Backend

VNG Cloud Taxonomy (BU-specific, kế thừa corporate)
  └── Technology → Cloud Engineering → Infrastructure
                                     → Kubernetes Platform
                                     → ← (BU-specific functions)
```

---

## Job — Định nghĩa Công việc

### Cây kế thừa Job

Các Job được tổ chức theo cây cha–con, với job con **kế thừa thuộc tính** từ job cha và có thể override:

```
Software Engineer (Job cha)
  ├── Backend Engineer (Job con)
  │     ├── Junior Backend Engineer
  │     ├── Senior Backend Engineer
  │     └── Principal Backend Engineer
  └── Frontend Engineer (Job con)
        ├── Junior Frontend Engineer
        └── Senior Frontend Engineer
```

### Job Level & Job Grade

Mỗi Job được gắn với hai thông số quan trọng:

| Thông số | Ý nghĩa | Ví dụ |
|---------|---------|-------|
| **Job Level** | Cấp bậc kinh nghiệm/seniority | Junior (L1), Mid (L2), Senior (L3), Principal (L4) |
| **Job Grade** | Band lương/compensation | Grade 5, Grade 6, Grade 7 |

```
Ví dụ:
Senior Backend Engineer
  └── Job Level: Senior (Level 3) — thường 5–8 năm kinh nghiệm
  └── Job Grade: Grade 7
          Min salary: 90 tr VND/tháng
          Mid salary: 120 tr VND/tháng
          Max salary: 150 tr VND/tháng
```

### Job Profile — Yêu cầu Vị trí

Mỗi Job có một **Job Profile** mô tả đầy đủ yêu cầu:

```
Job Profile: Senior Backend Engineer
  
  Mô tả: Thiết kế và xây dựng các hệ thống backend có khả năng mở rộng

  Trách nhiệm:
    • Kiến trúc microservices
    • Mentor junior engineers
    • Code review và đảm bảo chất lượng

  Yêu cầu:
    Học vấn: Đại học CNTT hoặc tương đương
    Kinh nghiệm: 5+ năm backend development

  Kỹ năng kỹ thuật:
    • Python: Cấp độ 4/5 (bắt buộc)
    • AWS: Cấp độ 3/5 (bắt buộc)
    • Kubernetes: Cấp độ 3/5 (ưu tiên có)

  Năng lực:
    • Leadership: Cấp độ 4/5
    • Problem Solving: Cấp độ 5/5
```

---

## Position — Headcount Slots

**Position** là một **"ô"** cụ thể trong sơ đồ tổ chức — một chỗ làm việc được phê duyệt trong ngân sách. Khác với Job (là định nghĩa role), Position là **instance thực tế** của Job trong một phòng ban cụ thể.

```
Job: Senior Backend Engineer (định nghĩa chung)
  ↕
Position: POS-ENG-BACKEND-001 (instance cụ thể)
  → Job: Senior Backend Engineer
  → Phòng ban: Backend Team
  → Báo cáo cho: Engineering Manager
  → Ngân sách: Đã được duyệt năm 2024
  → Trạng thái: VACANT / FILLED
```

### Vòng đời của một Position

```
CREATED  →  POSTED  →  FILLED  →  VACANT  →  FROZEN
(Được     (Đăng       (Có người  (Có người   (Tạm dừng
 duyệt)    tuyển)      vào)       rời)        tuyển dụng)
                                                   ↓
                                             ELIMINATED
                                            (Xóa bỏ hẳn)
```

---

## Staffing Models — Hai cách bố trí nhân sự

Đây là một trong những điểm **khác biệt chiến lược** của CO Module: hỗ trợ đồng thời hai mô hình staffing mà nhiều tổ chức cần dùng cùng lúc.

### Position-Based Staffing

**Khái niệm cốt lõi**: Mỗi nhân viên được assign vào một **Position đã được phê duyệt trước**. Position tồn tại độc lập, có hay không có người ngồi.

```
Quy trình:
  1. Phê duyệt ngân sách → Position được tạo ra (vacant)
  2. Tuyển dụng → Nhân viên được assign vào Position
  3. Nhân viên rời → Position trở lại vacant (có thể backfill ngay)
```

**Ưu điểm**:
- Kiểm soát headcount nghiêm ngặt
- Dễ theo dõi tỷ lệ vacancy
- Backfill không cần phê duyệt mới (position đã có ngân sách)
- Org chart thể hiện được cả vị trí chưa có người

**Phù hợp với**:
- Tổ chức nhà nước, tập đoàn lớn có quy trình ngân sách chặt
- Các tổ chức cần succession planning rõ ràng
- Doanh nghiệp có quy trình phê duyệt headcount phức tạp

---

### Job-Based Staffing

**Khái niệm cốt lõi**: Nhân viên được assign **trực tiếp vào Job** mà không cần một Position cụ thể. Headcount được quản lý thông qua ngân sách nhân sự (số lượng người, không phải số ô).

```
Quy trình:
  1. Phê duyệt headcount budget (ví dụ: "5 Senior Engineers năm 2024")
  2. Tuyển dụng → Nhân viên được assign trực tiếp vào Job
  3. Nhân viên rời → Manager quyết định có backfill hay không
```

**Ưu điểm**:
- Linh hoạt, tuyển dụng nhanh
- Dễ scale up/down
- Phù hợp với tổ chức hay tái cơ cấu
- Ít overhead quản lý

**Phù hợp với**:
- Startup và công ty tăng trưởng nhanh
- Công ty tư vấn, project-based
- Các team IC (Individual Contributor) linh hoạt

---

### Hybrid — Cách tiếp cận được khuyến nghị

Hầu hết các tổ chức trưởng thành sử dụng **cả hai mô hình** cho các tầng khác nhau:

```
Management tầng cao (C-level, VP, Director):
  → Position-Based
  → Mỗi vị trí được Board hoặc CEO phê duyệt
  → Có succession plan

Management tầng trung (Manager, Senior Manager):
  → Position-Based
  → Ngân sách được duyệt theo năm
  → Headcount control chặt

Individual Contributors (Engineer, Analyst, Designer):
  → Job-Based
  → Budget theo số lượng người và grade
  → Linh hoạt khi thêm/bớt người

Contractors & Consultants:
  → Job-Based
  → Không cần position, kết thúc khi hết dự án
```

---

### So sánh nhanh

| Tiêu chí | Position-Based | Job-Based |
|---------|---------------|----------|
| Kiểm soát headcount | Chặt chẽ | Linh hoạt |
| Backfill khi có người rời | Dễ (position còn đó) | Cần quyết định mới |
| Thích hợp cho tái cơ cấu | Phức tạp hơn | Đơn giản |
| Tracking vacancy | Built-in | Cần tính thủ công |
| Phù hợp với | Tổ chức lớn, regulated | Startup, agile org |

---

## Career Paths — Lộ trình Thăng tiến

CO Module cho phép định nghĩa **lộ trình nghề nghiệp** cụ thể, giúp nhân viên hiểu rõ con đường phát triển của mình:

### IC Track (Individual Contributor)

```
Junior Engineer → Mid Engineer → Senior Engineer → Principal Engineer → Distinguished Engineer
(2–3 năm)        (3–4 năm)      (4–5 năm)         (5+ năm)
```

### Management Track

```
Team Lead → Engineering Manager → Senior Manager → Director → VP Engineering
```

### Career Path Cross-over

CO hỗ trợ cả **lateral moves** và **track switching**:

```
Senior Engineer (IC Track, Level 3)
  ↓ [PROMOTION]
Principal Engineer (IC Track, Level 4)
  
  HOẶC
  
  ↓ [LATERAL_MOVE]
Engineering Manager (Management Track)
```

Mỗi bước chuyển đổi trong career path được định nghĩa rõ ràng với:
- Job nguồn → Job đích
- Thời gian tối thiểu ở vị trí hiện tại
- Các điều kiện hoặc kỹ năng cần đáp ứng

---

*Tài liệu tiếp theo: [05 · Quản lý Nhân sự & Skills](./05-people-skills-data.md)*
