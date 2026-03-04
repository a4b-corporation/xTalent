# CO Module — Executive Summary

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: Business Stakeholders, Product Leadership

---

## Core Module là gì?

**Core Module (CO)** là lớp nền tảng dữ liệu nhân sự của xTalent HCM — nơi định nghĩa **ai làm việc trong tổ chức, với vai trò gì, trong cơ cấu nào**. Đây không phải là module để người dùng tương tác hàng ngày, mà là **"engine room"** cung cấp dữ liệu và rule nền tảng cho toàn bộ hệ thống.

Nếu không có CO hoạt động ổn định, các module khác (Chấm công, Tính lương, Tuyển dụng, Đãi ngộ) sẽ không có đủ dữ liệu để vận hành chính xác.

---

## Vấn đề mà CO giải quyết

Hầu hết các hệ thống HR truyền thống được xây dựng từ 15–20 năm trước, với giả định rằng:
- Nhân sự = nhân viên chính thức (không có contractor, intern, consultant)
- Mỗi người chỉ có một hợp đồng, một vị trí, một cấp trên
- Tổ chức có cấu trúc phẳng, đơn giản, không có matrix

Thực tế của doanh nghiệp hiện đại **đã vượt xa những giả định này**:

| Vấn đề thực tế | Hệ thống truyền thống | CO giải quyết |
|---------------|----------------------|---------------|
| Contractor/freelancer cần được quản lý như nhân viên, nhưng không có hợp đồng lao động | Bắt buộc tạo "nhân viên ảo", dữ liệu sai bản chất | Mô hình Work Relationship tách biệt với Employment Contract |
| Nhân viên tái gia nhập công ty (rehire) | Tạo hồ sơ mới, mất toàn bộ lịch sử cũ | Worker identity bất biến, lịch sử được giữ đầy đủ |
| Người báo cáo về chuyên môn khác người phê duyệt nghỉ phép | Chỉ hỗ trợ 1 cấp trên, phải dùng workaround | Tách biệt Operational structure vs Supervisory structure |
| Tổ chức vừa dùng position cố định (management), vừa cần tuyển linh hoạt (IC) | Phải chọn 1 trong 2, không thể mix | Hỗ trợ đồng thời cả Position-Based và Job-Based staffing |
| Điều kiện hưởng lợi (leave policy, benefit) bị định nghĩa lại 3–5 lần ở các module khác nhau | Khi thay đổi phải sửa nhiều chỗ, dễ sai sót | Eligibility Engine tập trung, định nghĩa 1 lần, dùng ở khắp nơi |

---

## Scale và độ hoàn chỉnh

CO Module được thiết kế để đáp ứng yêu cầu của **các tổ chức phức tạp** — đa pháp nhân, đa quốc gia, đa mô hình nhân sự:

| Thống kê | Số liệu |
|---------|---------|
| Tổng số entities | **68 entities** |
| Aggregate Roots (domain objects chính) | **12** |
| Sub-modules | **7** |
| Loại quan hệ tổ chức được hỗ trợ | DIVISION, DEPARTMENT, TEAM, PROJECT, SUPERVISORY, COST_CENTER |
| Loại Work Relationship | EMPLOYEE, CONTRACTOR, CONSULTANT, INTERN, VOLUNTEER |
| Loại Contract | PERMANENT, FIXED_TERM, PROBATION, SEASONAL |

---

## Alignment với thị trường

CO Module được thiết kế để tương đương với các hệ thống HCM hàng đầu thế giới:

| Hệ thống | Độ tương đồng | Ghi chú |
|---------|--------------|---------|
| **Workday HCM** | ~95% | Worker, WorkRelationship, Assignment, Supervisory Org |
| **Oracle HCM Cloud** | ~95% | Person, Work Relationship, Assignment, Grade |
| **SAP SuccessFactors** | ~90% | User, Employment Info, Job Code, Position |

Sự tương đồng này có nghĩa là:
- (1) **Dữ liệu migration** từ các hệ thống trên dễ dàng hơn
- (2) **Best practices** của thị trường đã được tích hợp vào thiết kế
- (3) **Người dùng có kinh nghiệm** với Workday/Oracle sẽ dễ làm quen

---

## 7 Capabilities cốt lõi

### 1. Mô hình Employment 4 cấp
Tách biệt hoàn toàn identity của người (Worker), mối quan hệ lao động (WorkRelationship), hợp đồng (Employee), và phân công công việc (Assignment). Cho phép xử lý mọi tình huống nhân sự phức tạp mà không cần hack dữ liệu.

→ Chi tiết: [02 · Mô hình Employment](./02-employment-model.md)

### 2. Cơ cấu tổ chức Dual Structure
Tổ chức có hai "lớp" song song: cơ cấu vận hành (ai thuộc team nào) và cơ cấu báo cáo (ai phê duyệt, ai review). Hai lớp này độc lập và có thể thay đổi mà không ảnh hưởng lẫn nhau.

→ Chi tiết: [03 · Mô hình Tổ chức](./03-organization-model.md)

### 3. Job & Position Management linh hoạt
Hỗ trợ đồng thời cả mô hình position-based (headcount slot được duyệt trước) và job-based (gán trực tiếp vào job description). Tổ chức có thể mix cả hai.

→ Chi tiết: [04 · Job & Position](./04-job-position-model.md)

### 4. Quản lý Skills & Competency
Catalog kỹ năng và năng lực được liên kết với cả yêu cầu vị trí (Job Profile) lẫn hồ sơ cá nhân (WorkerSkill). Hệ thống tự động phát hiện skill gap để hỗ trợ quyết định tuyển dụng, đào tạo, và nội bộ luân chuyển.

→ Chi tiết: [05 · Quản lý Nhân sự & Skills](./05-people-skills-data.md)

### 5. Bảo mật dữ liệu & GDPR/PDPA Compliance
Dữ liệu được phân loại 4 cấp (PUBLIC → RESTRICTED), với kiểm soát truy cập theo vai trò và audit trail bắt buộc cho tất cả dữ liệu nhạy cảm.

→ Chi tiết: [05 · Quản lý Nhân sự & Skills](./05-people-skills-data.md)

### 6. Eligibility Engine tập trung
Thay vì mỗi module tự định nghĩa "ai được hưởng chính sách gì", CO cung cấp một engine tập trung. Điều kiện hưởng lợi chỉ cần định nghĩa **một lần**, sau đó được tái sử dụng cho leave policy, benefits, bonus, v.v.

→ Chi tiết: [06 · Capabilities Liên Module](./06-cross-module-capabilities.md)

### 7. Lịch sử đầy đủ (Point-in-time Reporting)
Mọi thay đổi dữ liệu đều được lưu lại với effective dates. Hệ thống có thể trả lời câu hỏi: *"Vào ngày X, nhân viên Y thuộc phòng ban nào, giữ chức vụ gì, báo cáo cho ai?"*

---

## Integration với các module khác

CO cung cấp dữ liệu nền tảng cho toàn bộ hệ thống xTalent:

```
                        CO Module
                           │
        ┌──────────────────┼──────────────────────┐
        ↓                  ↓                       ↓                        ↓
  TA (Chấm công)     TR (Đãi ngộ)          PR (Lương)           RC (Tuyển dụng)
  Worker + Org data  Worker + Position     Worker + Assignment  Worker data
  cho leave mgmt     data cho compensation  data cho payroll     cho candidates
```

---

## Lộ trình phát triển

| Phase | Nội dung | Trạng thái |
|-------|---------|-----------|
| **Phase 1** | Infrastructure + Worker (Person sub-module) | 🚧 Đang phát triển |
| **Phase 2** | Organization: Employee + LegalEntity + BusinessUnit | 📋 Kế hoạch |
| **Phase 3** | Job & Position: Job, Position, TaxonomyTree, CareerPath | 📋 Kế hoạch |
| **Phase 4** | Advanced: TalentMarket, Opportunity, EligibilityProfile | 📋 Kế hoạch |

---

*Để đọc chi tiết từng capability, xem bộ tài liệu đầy đủ tại [README](./README.md).*
