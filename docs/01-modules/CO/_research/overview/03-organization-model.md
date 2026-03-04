# Mô hình Tổ chức — Dual Structure & Matrix Organization

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: Business Users, HR Administrators, Managers  
**Thời gian đọc**: ~20 phút

---

## Tổng quan

Cơ cấu tổ chức trong xTalent được thiết kế để giải quyết một thực tế thường bị bỏ qua: **cách tổ chức công việc** (ai thuộc team nào) và **cách tổ chức báo cáo** (ai phê duyệt ai) là **hai chuyện khác nhau**, nhưng hầu hết hệ thống HR cố gộp chúng lại thành một.

---

## Vấn đề của Org Chart truyền thống

Hầu hết doanh nghiệp quản lý tổ chức bằng một org chart duy nhất, cố gắng thể hiện **tất cả** trong một sơ đồ:
- Ai thuộc team nào
- Ai báo cáo cho ai
- Ai phê duyệt nghỉ phép
- Ai chịu trách nhiệm ngân sách

**Vấn đề phát sinh**:

```
Ví dụ — Công ty tech 500 người, 3 vùng:

Engineering Division
  ├── Backend Team (Vietnam) — 10 người
  ├── Frontend Team (Vietnam) — 8 người
  ├── Mobile Team (Singapore) — 6 người
  └── DevOps Team (Singapore) — 5 người

Câu hỏi không thể trả lời với org chart này:
  ❌ Alice quản lý cả Backend VÀ Frontend (không phải quản lý theo team)
  ❌ VP Engineering APAC quản lý nhân sự Vietnam + Singapore (theo địa lý)
  ❌ Khi John xin nghỉ phép, gửi cho ai duyệt?
      → Team Lead Bob (không phải cấp trên trực tiếp)
      → Alice — Engineering Manager APAC (cấp trên chính thức)
```

---

## Giải pháp: Dual Structure

CO tách biệt hoàn toàn hai lớp tổ chức:

```
┌─────────────────────────────────────────────────────────────────┐
│  LỚP 1: OPERATIONAL STRUCTURE — "Tổ chức công việc như thế nào?"│
│                                                                  │
│  Engineering Division                                           │
│    ├── Backend Team (Vietnam)                                   │
│    ├── Frontend Team (Vietnam)                                  │
│    ├── Mobile Team (Singapore)                                  │
│    └── DevOps Team (Singapore)                                  │
│                                                                  │
│  Mục đích: Phân công công việc, đánh dấu thuộc team nào        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  LỚP 2: SUPERVISORY STRUCTURE — "Ai báo cáo cho ai?"            │
│                                                                  │
│  VP Engineering (Supervisory Org)                               │
│    ├── Engineering Manager APAC                                 │
│    │     ├── Toàn bộ nhân sự Backend Team (VN)                 │
│    │     └── Toàn bộ nhân sự Frontend Team (VN)                │
│    └── Engineering Manager Singapore                            │
│          ├── Toàn bộ nhân sự Mobile Team (SG)                  │
│          └── Toàn bộ nhân sự DevOps Team (SG)                  │
│                                                                  │
│  Mục đích: Phê duyệt, review hiệu suất, phát triển nghề nghiệp │
└─────────────────────────────────────────────────────────────────┘
```

**Cùng một nhóm người, hai góc nhìn tổ chức hoàn toàn khác nhau.**

---

## So sánh hai lớp

| Khía cạnh | Operational Structure | Supervisory Structure |
|-----------|----------------------|----------------------|
| **Câu hỏi trả lời** | "Tôi thuộc team nào?" | "Ai là cấp trên của tôi?" |
| **Tần suất thay đổi** | Ít thay đổi (chỉ khi tái cơ cấu) | Thay đổi nhiều hơn (khi đổi manager) |
| **Dùng để làm gì** | Phân công công việc, collaboration | Phê duyệt, review, kiểm soát truy cập dữ liệu |
| **Loại unit** | DIVISION, DEPARTMENT, TEAM, PROJECT | SUPERVISORY |
| **Ảnh hưởng approval** | ❌ Không | ✅ Có |
| **Ảnh hưởng data access** | ❌ Không | ✅ Có |

**Quy tắc quan trọng**:
- Khi nhân viên xin nghỉ phép → đi theo **Supervisory Structure**
- Khi assign task → dùng **Operational Structure**
- Khi review hiệu suất → dùng **Supervisory Structure**
- Khi lập kế hoạch sprint → dùng **Operational Structure**

---

## Cấu trúc Pháp nhân (Legal Entity)

Ngoài Business Unit, CO còn quản lý cấu trúc **pháp nhân** — quan trọng với các tập đoàn đa quốc gia:

```
VNG Corporation (Công ty mẹ — Singapore)
  ├── VNG Vietnam Co., Ltd (Công ty con — VN, sở hữu 100%)
  ├── VNG Singapore Pte. Ltd (Công ty con — SG, sở hữu 100%)
  └── VNG Thailand JV (Liên doanh — TH, sở hữu 51%)
```

**Tại sao cần phân biệt?**
- Hợp đồng lao động ký với pháp nhân nào → tuân thủ luật lao động của quốc gia đó
- Lương → trả từ ngân hàng của pháp nhân đó
- Báo cáo thuế → nộp cho cơ quan thuế quốc gia của pháp nhân đó

Một nhân viên có thể làm việc tại văn phòng ở Việt Nam (Operational) nhưng có hợp đồng với pháp nhân Singapore (Legal Entity) — CO xử lý được tình huống này.

---

## Matrix Organization — Solid & Dotted Line Reporting

Trong các tổ chức phức tạp (consulting, tech, global companies), nhân viên thường báo cáo cho **nhiều hơn một người** với các vai trò khác nhau. CO hỗ trợ mô hình này.

### Solid Line (Báo cáo chính thức — Primary)

```
Đặc điểm:
  • Mỗi nhân viên chỉ có DUY NHẤT một solid line
  • Ảnh hưởng đến phê duyệt (nghỉ phép, chi phí, tuyển dụng)
  • Người này làm review hiệu suất
  • Người này quyết định lương, thưởng, thăng chức
```

### Dotted Line (Báo cáo chức năng/dự án — Secondary)

```
Đặc điểm:
  • Có thể có NHIỀU dotted lines đồng thời
  • KHÔNG ảnh hưởng đến chuỗi phê duyệt
  • Chỉ mang tính hướng dẫn, phối hợp
  • Có thể gắn % thời gian (60% dự án A, 40% dự án B)
```

### Ví dụ thực tế

```
Nguyễn Văn An — Backend Engineer

Operational:
  → Thuộc Backend Team (ENG-BACKEND)
  → Làm việc hàng ngày với Backend Team

Solid Line (Supervisory):
  → Engineering Manager APAC — Alice
  → Alice phê duyệt nghỉ phép của An
  → Alice thực hiện performance review
  → Alice quyết định lương/thăng chức

Dotted Line 1 (Dự án):
  → Project Lead Alpha — Bob (60% thời gian)
  → Bob hướng dẫn về kỹ thuật dự án
  → Bob không có quyền phê duyệt gì

Dotted Line 2 (Chức năng):
  → Product Manager Beta — Carol (40% thời gian)
  → Carol ưu tiên feature cần làm
  → Carol không có quyền phê duyệt gì
```

---

## Các mô hình tổ chức được hỗ trợ

### Mô hình 1: Tổ chức truyền thống (Operational = Supervisory)

Phù hợp với: Doanh nghiệp nhỏ–vừa, cấu trúc đơn giản

```
Công ty A (50 nhân sự)
  Engineering (Manager: Alice)
    ├── Backend Team (Lead: Bob)
    └── Frontend Team (Lead: Carol)

→ Operational và Supervisory trùng nhau
→ Cấu trúc đơn giản, dễ quản lý
```

### Mô hình 2: Ma trận theo Địa lý (Geographic Matrix)

Phù hợp với: Công ty global, quản lý theo vùng

```
Operational (theo chức năng):    Supervisory (theo địa lý):
Engineering Division              Global Engineering
  ├── Backend Team                  ├── APAC Engineering
  ├── Frontend Team                 │     ├── Vietnam Manager
  └── Mobile Team                   │     └── Singapore Manager
                                    └── EMEA Engineering

→ An (Backend, VN): Làm trong Backend Team (Operational),
  Báo cáo cho Vietnam Manager (Supervisory)
```

### Mô hình 3: Ma trận theo Sản phẩm (Product Matrix)

Phù hợp với: Công ty product-driven, nhiều product teams

```
Operational (theo product):      Supervisory (theo chuyên môn):
Product A Team                   Engineering Leadership
Product B Team                     ├── Backend Engineering Mgr
Product C Team                     ├── Frontend Engineering Mgr
                                    └── Mobile Engineering Mgr

→ Jane (Backend Dev, Product A): Làm trong Product A Team,
  Báo cáo cho Backend Engineering Manager (Supervisory)
→ Career path gắn với chuyên môn, không gắn với product
```

---

## Các kịch bản thực tế

### Kịch bản 1: Thay đổi Manager

```
Alice (Engineering Manager APAC) nghỉ việc 01/07/2024.
Bob lên làm manager mới.

Thay đổi cần thực hiện:
  • Supervisory Structure: Cập nhật manager của SUP-MGR-APAC → Bob

Không cần thay đổi:
  • Operational Structure: Backend Team, Frontend Team giữ nguyên
  • Team membership: Không ai cần đổi team
  • Assignment của nhân viên: Không cần cập nhật

→ Tất cả approval từ 01/07/2024 tự động đi qua Bob
→ Performance review cycle 2024 do Bob thực hiện
```

### Kịch bản 2: Tái cơ cấu — Gộp 2 team thành 1

```
Gộp Backend Team + Frontend Team → Platform Team

Thay đổi cần thực hiện:
  • Operational Structure: Tạo unit mới ENG-PLATFORM,
    chuyển tất cả nhân viên sang

Không cần thay đổi:
  • Supervisory Structure: Giữ nguyên hoàn toàn
  • Manager relationships: Không đổi
  • Approval workflows: Không đổi

→ Tái cơ cấu không phá vỡ quy trình phê duyệt đang chạy
→ Performance reviews tiếp tục bình thường
```

### Kịch bản 3: Nhân viên tham gia dự án tạm thời

```
An (Backend Engineer) được assign thêm vào Project Alpha (40% time)

Operational:
  • Primary: Backend Team (60% FTE)
  • Secondary: Project Alpha Team (40% FTE)
  • Dotted line: Project Lead Alpha

Supervisory:
  • Không thay đổi — vẫn báo cáo cho Alice
  • Alice vẫn phê duyệt nghỉ phép, review hiệu suất

→ Sự tham gia dự án rõ ràng, nhưng không xáo trộn chuỗi quản lý
```

---

*Tài liệu tiếp theo: [04 · Job & Position](./04-job-position-model.md)*
