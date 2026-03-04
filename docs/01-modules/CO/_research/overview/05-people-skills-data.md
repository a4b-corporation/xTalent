# Quản lý Nhân sự & Skills — Worker Data, Skill Gap Analysis & Data Security

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-04  
**Đối tượng**: HR Administrators, Talent Managers  
**Thời gian đọc**: ~15 phút

---

## Tổng quan

CO Module quản lý toàn bộ hồ sơ cá nhân của người lao động — từ thông tin nhân thân cơ bản đến portfolio kỹ năng và competency. Trên nền dữ liệu này, hệ thống hỗ trợ **Skill Gap Analysis** để ra quyết định nhân sự và **Data Classification** để bảo vệ thông tin nhạy cảm theo chuẩn GDPR/PDPA.

---

## Worker Sub-module — Hồ sơ Cá nhân

Một Worker record bao gồm 10 loại thông tin:

| Entity | Mô tả | Ví dụ |
|-------|-------|-------|
| **Worker** | Thông tin nhân thân cơ bản | Tên, ngày sinh, giới tính, CCCD |
| **Contact** | Thông tin liên lạc | Email cá nhân, điện thoại |
| **Address** | Địa chỉ | Thường trú, tạm trú |
| **Document** | Giấy tờ tùy thân | CCCD, hộ chiếu, bằng cấp |
| **BankAccount** | Tài khoản ngân hàng | Tài khoản nhận lương |
| **WorkerRelationship** | Quan hệ gia đình | Vợ/chồng, con cái (cho phúc lợi) |
| **WorkerQualification** | Bằng cấp, chứng chỉ | Bằng đại học, AWS Certified |
| **WorkerSkill** | Kỹ năng kỹ thuật | Python Level 4, SQL Level 3 |
| **WorkerCompetency** | Năng lực hành vi | Leadership Level 4, Problem Solving Level 5 |
| **WorkerInterest** | Định hướng nghề nghiệp | Muốn phát triển về AI/ML |

---

## Các loại Person Types

CO không chỉ quản lý "nhân viên" mà quản lý mọi người có liên quan đến tổ chức:

| Loại | Mô tả | Có hồ sơ Worker? |
|-----|-------|-----------------|
| **EMPLOYEE** | Nhân viên chính thức | ✅ Có, đầy đủ |
| **CONTRACTOR** | Freelancer, nhà thầu | ✅ Có, thông tin cơ bản |
| **CONSULTANT** | Chuyên gia tư vấn | ✅ Có, thông tin cơ bản |
| **APPLICANT** | Ứng viên đang xét tuyển | ✅ Có (từ Recruiting module) |
| **ALUMNUS** | Cựu nhân viên | ✅ Có (được giữ lại) |
| **DEPENDENT** | Người thụ hưởng (vợ/chồng/con) | ✅ Có (cho benefit management) |

**Tại sao quan trọng**: Khi một ứng viên được tuyển, hồ sơ của họ không bị xóa đi và tạo lại — Worker record được giữ nguyên, chỉ thay đổi `person_type` từ APPLICANT → EMPLOYEE.

---

## Skills & Competency Management

### Phân biệt Skills và Competencies

| | Skills | Competencies |
|-|-------|-------------|
| **Là gì** | Kỹ năng kỹ thuật, công cụ cụ thể | Năng lực hành vi, tư duy |
| **Ví dụ** | Python, AWS, Tableau, Figma | Leadership, Problem Solving, Communication |
| **Đo lường** | Cấp độ thành thục (1–5) | Cấp độ thể hiện (1–5) |
| **Nguồn** | Học, thực hành, được training | Rèn luyện theo thời gian |

### Proficiency Levels (Cấp độ Kỹ năng)

Mỗi kỹ năng được đánh giá trên thang điểm 5 cấp:

| Cấp độ | Tên | Mô tả |
|-------|-----|-------|
| 1 | Beginner | Biết cơ bản, cần hướng dẫn |
| 2 | Intermediate | Làm được việc độc lập với các task thông thường |
| 3 | Advanced | Làm thành thạo, giải quyết vấn đề phức tạp |
| 4 | Expert | Tư vấn cho người khác, architect giải pháp |
| 5 | Master | Định hình best practices, được công nhận ở cấp ngành |

---

## Skill Gap Analysis — Phân tích Khoảng cách Kỹ năng

**Mục đích**: Tự động so sánh kỹ năng của một nhân viên/ứng viên với yêu cầu của một vị trí cụ thể.

### Cách hoạt động

```
Job Profile (yêu cầu từ vị trí):     Worker Profile (thực tế của người):
  • Python: Level 4 (bắt buộc)          • Python: Level 5
  • AWS: Level 3 (bắt buộc)             • AWS: Level 2
  • Kubernetes: Level 3 (optional)      • Docker: Level 4
                                         • Redis: Level 3

Kết quả phân tích:
  ✅  Python: EXCEEDS (có 5, cần 4)
  ❌  AWS: GAP (có 2, cần 3) → Cần training
  ⚠️  Kubernetes: MISSING → Cơ hội phát triển
  ℹ️  Docker: EXTRA (có nhưng không yêu cầu) → Kỹ năng cộng thêm
```

### Ứng dụng thực tế

| Bài toán | Cách Skill Gap Analysis hỗ trợ |
|---------|-------------------------------|
| **Tuyển dụng** | Đánh giá nhanh mức độ phù hợp của ứng viên với vị trí |
| **Xác định nhu cầu training** | Xác định AWS gap → ưu tiên training AWS cho nhân viên |
| **Internal mobility** | Tìm nhân viên phù hợp nhất cho vị trí mở trong nội bộ |
| **Succession Planning** | Đánh giá mức độ sẵn sàng của backup candidate |
| **Workforce Planning** | Xác định những kỹ năng đang thiếu hụt trên toàn tổ chức |

---

## Master Data — Dữ liệu Kho

CO cung cấp kho dữ liệu tham chiếu dùng chung toàn hệ thống:

| Danh mục | Nội dung |
|---------|---------|
| **SkillMaster** | Catalog kỹ năng chuẩn hóa toàn công ty |
| **CompetencyMaster** | Catalog năng lực chuẩn hóa |
| **CodeList** | Bảng mã đa mục đích (status codes, reason codes, v.v.) |
| **Country / AdminArea** | Dữ liệu địa lý: quốc gia, tỉnh/thành, quận/huyện |
| **Currency / TimeZone** | Tiền tệ và múi giờ chuẩn ISO |
| **Industry** | Phân loại ngành nghề |

---

## Data Classification & Security — Bảo vệ Dữ liệu

### Bối cảnh

Dữ liệu nhân lực chứa nhiều thông tin **cực kỳ nhạy cảm**: số CCCD, ngày sinh, tài khoản ngân hàng, thông tin sức khỏe. CO áp dụng mô hình phân loại dữ liệu 4 tầng, tuân thủ GDPR (EU) và PDPA (Đông Nam Á).

### 4 Cấp độ Phân loại

| Cấp độ | Mô tả | Ví dụ dữ liệu | Ai được xem? |
|-------|-------|-------------|-------------|
| **PUBLIC** | Thông tin công khai | Tên, chức danh, email công ty | Toàn bộ nhân viên |
| **INTERNAL** | Thông tin nội bộ | Số điện thoại công ty, địa điểm làm việc | Cùng tổ chức |
| **CONFIDENTIAL** | Thông tin nhạy cảm kinh doanh | Mức lương, đánh giá hiệu suất | Manager + HR |
| **RESTRICTED** | PII nhạy cảm cao | CCCD, dữ liệu sinh trắc học, thông tin y tế | HR có thẩm quyền + có audit trail |

### Access Control theo vai trò

```
Nhân viên (xem thông tin của chính mình):
  ✅ PUBLIC · ✅ INTERNAL · ✅ CONFIDENTIAL · ✅ RESTRICTED

Manager (xem thông tin báo cáo trực tiếp):
  ✅ PUBLIC · ✅ INTERNAL · ✅ CONFIDENTIAL · ❌ RESTRICTED

HR Administrator:
  ✅ PUBLIC · ✅ INTERNAL · ✅ CONFIDENTIAL · ✅ RESTRICTED (có audit trail)

Nhân viên khác:
  ✅ PUBLIC · ❌ INTERNAL · ❌ CONFIDENTIAL · ❌ RESTRICTED
```

### Audit Trail — Nhật ký truy cập

Mọi truy cập vào dữ liệu **RESTRICTED** đều được ghi lại:
- **Ai** truy cập (user ID, role)
- **Khi nào** (timestamp)
- **Dữ liệu gì** (field-level logging)
- **Mục đích** (lý do truy cập)

Nhật ký này phục vụ báo cáo tuân thủ và điều tra khi xảy ra vi phạm.

### GDPR / PDPA Compliance

CO được thiết kế sẵn cho quyền của người lao động theo GDPR/PDPA:

| Quyền | Cách CO hỗ trợ |
|------|---------------|
| **Right to Access** | API cho phép xuất toàn bộ dữ liệu của một người |
| **Right to Rectification** | Workflow sửa đổi dữ liệu có audit trail |
| **Right to be Forgotten** | Soft delete + anonymization (không xóa vật lý, CCCD → "ANONYMIZED") |
| **Data Portability** | Xuất dữ liệu theo chuẩn JSON/CSV |

---

## SCD Type 2 — Lịch sử Đầy đủ

Tất cả thay đổi dữ liệu nhân lực đều được lưu lịch sử đầy đủ theo chuẩn **Slowly Changing Dimension Type 2**:

```
Ví dụ — Thay đổi phòng ban của An:

Trạng thái 1 (01/01/2024 → 30/06/2024):
  An | Phòng ban: Backend Team | effective_start: 01/01/2024 | effective_end: 30/06/2024

Trạng thái 2 (01/07/2024 → nay):
  An | Phòng ban: Platform Team | effective_start: 01/07/2024 | effective_end: NULL (hiện tại)
```

**Hệ thống trả lời được**: "Ngày 15/05/2024, An thuộc phòng ban nào?" → Backend Team.

Đây là nền tảng cho báo cáo **point-in-time** (nhìn lại quá khứ) và tuân thủ kiểm toán (audit compliance).

---

*Tài liệu tiếp theo: [06 · Capabilities Liên Module](./06-cross-module-capabilities.md)*
