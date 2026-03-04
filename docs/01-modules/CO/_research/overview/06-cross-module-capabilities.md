# Capabilities Liên Module — Eligibility Engine, Talent Marketplace & Design Patterns

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: All Stakeholders  
**Thời gian đọc**: ~15 phút

---

## Tổng quan

Ngoài các chức năng quản lý nội bộ, CO Module còn cung cấp một số **capabilities nền tảng hoạt động xuyên suốt** toàn bộ hệ thống xTalent. Đây là những thành phần mà các module khác (TA, TR, PR, RC) đều phụ thuộc vào.

---

## Eligibility Engine — Quản lý Điều kiện Hưởng lợi

### Vấn đề

Trong một hệ thống HR, nhiều chính sách có **điều kiện hưởng lợi** — "nhóm nhân viên nào được áp dụng chính sách này?":

- Nhân viên grade G4 trở lên → accrual phép năm 15 ngày/năm
- Nhân viên grade G4 trở lên → bảo hiểm sức khỏe premium
- Nhân viên grade G4 trở lên → bonus plan senior

Nếu mỗi module tự định nghĩa lại "nhân viên grade G4 trở lên", khi grade structure thay đổi, phải đi cập nhật **ở nhiều chỗ khác nhau** — dẫn đến sai sót và mất tính nhất quán.

### Giải pháp: Eligibility Profile tập trung

CO cung cấp một **kho điều kiện dùng chung** (Eligibility Profiles). Mỗi profile định nghĩa **"ai"** đáp ứng điều kiện — dựa trên các tiêu chí tổ chức và nhân sự như grade, loại hợp đồng, thâm niên, quốc gia, department.

Các module khác chỉ việc **tham chiếu đến profile này** thay vì tự định nghĩa lại.

```
Eligibility Profile: "Senior Staff" (định nghĩa 1 lần tại CO)
  → Grade: G4 trở lên
  → Loại hợp đồng: Full-time
  → Thâm niên tối thiểu: 12 tháng

Module TA (Chấm công): AccrualRule "Senior Annual Leave" 
  → Điều kiện hưởng: Senior Staff ← dùng lại profile từ CO
  → Accrual: 1.25 ngày/tháng

Module TR (Đãi ngộ): BenefitOption "Premium Health Insurance"
  → Điều kiện hưởng: Senior Staff ← dùng lại profile từ CO
  → Coverage: 100 triệu/năm

Module TR (Compensation): BonusPlan "Senior Bonus"
  → Điều kiện hưởng: Senior Staff ← dùng lại profile từ CO
  → Bonus: 20% lương cơ bản
```

**Kết quả**: Khi định nghĩa "Senior Staff" thay đổi (ví dụ: hạ xuống G3), chỉ cần cập nhật **một chỗ** — tự động áp dụng cho toàn bộ leave, benefit, và compensation liên quan.

### Hybrid Model: Default + Override

Eligibility Engine hỗ trợ mô hình phân cấp linh hoạt:

```
Cấp Class (mặc định cho toàn bộ loại nghỉ phép):
  Leave Class: PTO → Default: Toàn bộ nhân viên full-time

Cấp Type (ghi đè cho loại nghỉ phép cụ thể):
  Leave Type: Annual Leave → Default (kế thừa từ Class)

Cấp Rule (ghi đè cho chính sách cụ thể):
  Accrual Rule: Senior Accrual → Override: Chỉ Senior Staff
  Accrual Rule: Junior Accrual → Override: Chỉ Junior Staff
```

**Lợi ích**: Chính sách đơn giản không cần configure gì thêm; chính sách phức tạp (có nhiều tier) vẫn được handle mà không cần phá vỡ cấu trúc chung.

---

## Internal Talent Marketplace — Sàn Cơ hội Nội bộ

CO Module có sẵn nền tảng cho một **internal job marketplace** — cho phép nhân viên chủ động tìm kiếm và ứng tuyển vào các cơ hội bên trong tổ chức.

### Cơ chế hoạt động

```
1. HR/Manager tạo "Opportunity" (Cơ hội nội bộ):
   → Loại: Full-time position / Project assignment / Mentorship
   → Yêu cầu kỹ năng và competency
   → Thời gian và điều kiện

2. Nhân viên có thể:
   → Tìm kiếm cơ hội phù hợp với skill của mình
   → Xem mức độ match giữa skill của họ và yêu cầu cơ hội
   → Ứng tuyển vào cơ hội quan tâm

3. Hệ thống hỗ trợ:
   → Gợi ý cơ hội dựa trên skill profile của nhân viên
   → Skill Gap Analysis ngay trong quá trình ứng tuyển
```

### Các loại Opportunity được hỗ trợ

| Loại | Mô tả | Ví dụ |
|-----|-------|-------|
| **Internal Posting** | Vị trí tuyển dụng nội bộ | Mở vị trí Senior Engineer, ưu tiên ứng viên nội bộ |
| **Project Assignment** | Tham gia dự án ngắn hạn | Cần 2 engineer cho dự án 3 tháng |
| **Cross-BU Rotation** | Luân phiên sang bộ phận khác | Engineer sang trải nghiệm Product 6 tháng |
| **Mentorship** | Chương trình mentoring | Senior kỹ sư mentoring junior |

### Ý nghĩa chiến lược

- **Giữ chân nhân tài**: Nhân viên có nhiều cơ hội phát triển bên trong trước khi phải tìm kiếm bên ngoài
- **Tối ưu nguồn lực**: Tận dụng tốt hơn các kỹ năng sẵn có trong tổ chức
- **Linh hoạt workforce**: Dễ dàng điều phối nhân lực giữa các dự án/phòng ban

---

## Facility Management — Quản lý Địa điểm Làm việc

CO quản lý địa điểm làm việc theo **3 cấp phân tầng**, mỗi cấp phục vụ một mục đích riêng biệt:

### 3 Cấp địa điểm

**Place — Cơ sở kinh doanh**

Là một địa điểm thực tế có địa chỉ, có thể xác định trên bản đồ (Google Maps). Đây là cơ sở kinh doanh, văn phòng, nhà máy mang tính "landmark" của doanh nghiệp.

```
Ví dụ:
  VNG Campus (Tân Thuận, TP.HCM)
  Quang Trung Software City (Q.12, TP.HCM)
  WeWork Singapore (Marina Bay)
```

**Location — Khu vực trong Place**

Là một vùng hoặc tòa nhà nằm bên trong một Place. Cấp này phục vụ **indoor mapping** — quản lý chi tiết theo sơ đồ mặt bằng, hỗ trợ ứng dụng bản đồ tòa nhà và điều hướng nội bộ.

```
Ví dụ — VNG Campus:
  Red Zone, Blue Zone, Zone A, Zone B

Ví dụ — Quang Trung Software City:
  Building Telecom, Building A, Building B, Building ITC
```

**WorkLocation — Địa điểm làm việc cụ thể**

Là địa điểm chi tiết nhất: một tầng, một phòng, một khu vực làm việc cụ thể. WorkLocation được **gắn trực tiếp với Business Unit** — thể hiện chính xác "team này ngồi ở đâu".

```
Ví dụ — VNG Campus, Blue Zone:
  Tầng 5 — Engineering (gắn với BU: Engineering Division)
  Tầng 6 — Product & Design (gắn với BU: Product Team)
  Tầng 7 — Finance & HR (gắn với BU: Corporate Functions)
  Remote (Virtual) — cho nhân viên làm việc từ xa
```

---

### Tại sao cần cấu trúc phức tạp này?

Mục tiêu cốt lõi không chỉ là tiện ích tìm đường hay check-in — mà là **quản lý chính sách và phụ cấp theo địa điểm làm việc thực tế**:

| Bài toán kinh doanh | Cách Facility Management giải quyết |
|--------------------|-------------------------------------|
| **Nhân viên làm việc tại nhiều văn phòng** | WorkLocation gắn vào Assignment, hệ thống biết mỗi ngày nhân viên đang ở đâu |
| **Đi công tác tỉnh/thành, quốc gia khác** | Assignment có thể có WorkLocation tạm thời ở địa điểm khác, trigger policy công tác đúng |
| **Phụ cấp đi lại, ăn trưa, điện thoại** | Tự động áp dụng phụ cấp theo Place/Location, không cần khai báo thủ công |
| **Chính sách khác nhau giữa các văn phòng** | Policy được định nghĩa theo WorkLocation/Place thay vì cố định tại một nơi |
| **Quản lý ủy quyền theo địa bàn** | Khi manager công tác, hệ thống biết vùng phủ và điều chỉnh chuỗi ủy quyền phù hợp |
| **Headcount report theo địa điểm** | Báo cáo số người tại từng văn phòng/khu vực chính xác theo WorkLocation thực tế |
| **Remote Work Management** | WorkLocation "Remote/Virtual" là một địa điểm hợp lệ, có policy riêng |

---

## Key Design Patterns — Nguyên tắc Kiến trúc Nền tảng

Ba pattern kiến trúc được áp dụng xuyên suốt CO Module, ảnh hưởng đến cách hệ thống vận hành:

### Pattern 1: Lịch sử Đầy đủ (SCD Type 2)

**Nguyên tắc**: Không xóa hay ghi đè dữ liệu — mọi thay đổi đều tạo ra một bản ghi lịch sử mới với effective dates.

**Ý nghĩa với business**:
- Trả lời được câu hỏi: "1 năm trước, đội Engineering có bao nhiêu người?"
- Audit trail đầy đủ cho kiểm toán nội bộ và externa
- Báo cáo point-in-time (nhìn lại bất kỳ thời điểm nào trong quá khứ)

### Pattern 2: Cây phân cấp Hiệu quả (Materialized Path)

**Nguyên tắc**: Mọi cấu trúc phân cấp (Org chart, Job taxonomy, Địa lý) đều lưu trữ đường dẫn đầy đủ từ gốc đến node.

**Ý nghĩa với business**:
- Truy vấn "toàn bộ nhân viên dưới VP Engineering" nhanh và hiệu quả
- Báo cáo theo vùng/phòng ban/đơn vị con không bị chậm dù tổ chức lớn
- Hỗ trợ delegated approval (phê duyệt được ủy quyền xuống nhiều cấp)

### Pattern 3: Quan hệ Đồ thị (Graph-Based Relationships)

**Nguyên tắc**: Các quan hệ phức tạp (reporting lines, cost allocation, project membership) được mô hình hóa như một đồ thị có hướng thay vì hệ thống phân cấp cứng.

**Ý nghĩa với business**:
- Hỗ trợ matrix organizations với nhiều loại quan hệ đồng thời
- Flexible: thêm loại quan hệ mới mà không cần thay đổi data model
- Mô hình hóa được cả quan hệ financial (budget flow) và quan hệ nhân sự

---

## Tổng kết — CO là nền tảng của xTalent HCM

```
Đây là những gì CO Module cung cấp cho toàn hệ thống:

NGƯỜI LAO ĐỘNG:      68 entities định nghĩa đầy đủ WHO là ai
TỔCHỨC:              Dual structure phản ánh thực tế phức tạp
CÔNG VIỆC:           Taxonomy, Profiles và Staffing Models linh hoạt
LỊCH SỬ:            SCD Type 2 — mọi thay đổi đều được lưu giữ
BẢO MẬT:            4-cấp phân loại dữ liệu, GDPR/PDPA compliant
ĐIỀU KIỆN:          Eligibility Engine tập trung, nhất quán, tái sử dụng
CƠ HỘI:             Internal Talent Marketplace khuyến khích career growth
```

---

*Xem lại bộ tài liệu đầy đủ tại [README](./README.md)*
