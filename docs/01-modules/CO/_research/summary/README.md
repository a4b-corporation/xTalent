# CO Module - Summary Documents

**Phiên bản**: 1.0
**Cập nhật**: 2026-03-06
**Module**: Core HR (CO)

---

## Giới thiệu

Bộ tài liệu summary tổng hợp và tổ chức lại thông tin từ các research documents về CO Module thành 2 tài liệu chính phục vụ cho cả Business Stakeholders và Technical Team.

---

## Danh sách Tài liệu

| Tài liệu | Mô tả | Thời gian đọc |
|----------|-------|--------------|
| **[01-feature-list.md](./01-feature-list.md)** | Danh sách chi tiết 72 features được gom thành 10 nhóm capabilities | ~30 phút |
| **[02-menu-structure.md](./02-menu-structure.md)** | Cấu trúc menu UI với 6 menu chính, phân tích từng submenu | ~25 phút |

---

## Lộ trình đọc đề xuất

### Dành cho Business Stakeholders

1. Bắt đầu với **01-feature-list.md** để hiểu về các capabilities của module
2. Đọc phần **2. Feature List** - tập trung vào phần mô tả và user stories
3. Sau đó đọc **02-menu-structure.md** để hình dung UI/UX cho end-users
4. Tập trung vào phần **Mục đích** và **Persona chính** của từng menu

### Dành cho Technical Team

1. Bắt đầu với **01-feature-list.md** để hiểu toàn bộ feature scope
2. Đọc kỹ phần **Related Entities** và **Priority** của từng feature
3. Sau đó đọc **02-menu-structure.md** để hiểu navigation structure
4. Tập trung vào phần **Implementation Considerations** và **Best Practices**

### Dành cho UI/UX Designers

1. Đọc trước **02-menu-structure.md** để hiểu menu hierarchy
2. Sau đó đọc **01-feature-list.md** để hiểu detail của từng feature
3. Tập trung vào section **User Story** để understand user needs

---

## Tóm tắt Nội dung

### 01-feature-list.md

Tài liệu này tổ chức 72 features thành 10 nhóm capabilities:

1. **Quản lý Nhân sự (Person Management)** - 8 features
2. **Quản lý Lao động (Employment Management)** - 11 features
3. **Cấu trúc Tổ chức (Organization Structure)** - 9 features
4. **Quản lý Công việc & Vị trí (Job & Position)** - 12 features
5. **Master Data & Dữ liệu Tham chiếu** - 6 features
6. **Eligibility Engine** - 4 features
7. **Quản lý Địa điểm Làm việc (Facility Management)** - 5 features
8. **Sàn Cơ hội Nội bộ (Talent Marketplace)** - 5 features
9. **Bảo mật & Tuân thủ (Data Security & Compliance)** - 6 features
10. **Báo cáo & Lịch sử (Reporting & History)** - 6 features

Mỗi feature bao gồm:
- ID (FR-CO-XXX)
- Tên feature
- Mô tả ngắn
- Priority (MUST/SHOULD/COULD)
- User Story
- Related Entities

### 02-menu-structure.md

Tài liệu này định nghĩa cấu trúc menu UI với 6 menu chính:

1. **Dashboard** - Tổng quan nhân sự, chỉ số tổ chức, alerts, quick actions
2. **Nhân sự (People)** - Hồ sơ, employment, skills, talent marketplace
3. **Tổ chức (Organization)** - Legal entities, org structure, jobs/positions, locations
4. **Quản trị (Administration)** - Tài chính, eligibility, master data, security
5. **Báo cáo (Reports)** - Workforce, employment, talent, audit reports

Mỗi menu item bao gồm:
- Mục đích
- Persona chính
- Chức năng chi tiết
- Tính năng chính
- Quyền truy cập (Role-based)
- Related Features

---

## Số liệu Key

| Thông số | Giá trị |
|----------|---------|
| Tổng số Features | **72** |
| Tổng số Capabilities Groups | **10** |
| Tổng số Menu Chính | **6** |
| Tổng số Submenu Items | **20+** |
| Tổng số Related Entities | **43** |

---

## Thông tin Nguồn

Các tài liệu này được tổng hợp từ:

- **Feature Catalog**: `/_research/feature-catalog.md` (25 features)
- **Entity Catalog**: `/_research/entity-catalog.md` (43 entities)
- **Overview Documents**: `/_research/overview/`
  - 01 - Executive Summary
  - 02 - Employment Model
  - 03 - Organization Model
  - 04 - Job & Position Model
  - 05 - People & Skills Data
  - 06 - Cross-Module Capabilities

---

## Quy ước & Legend

### Priority Levels
- **MUST**: Bắt buộc có trong Phase 1 - Core functionality (19 features, 43%)
- **SHOULD**: Nên có trong Phase 1 hoặc đầu Phase 2 (6 features, 14%)
- **COULD**: Có thể có trong Phase 2 hoặc sau (19 features, 43%)

### Feature Types
- **Functional**: Chức năng nghiệp vụ chính
- **Configuration**: Thiết lập và cấu hình hệ thống
- **Workflow**: Quy trình nghiệp vụ có nhiều bước
- **Calculation**: Tính toán tự động
- **UI/UX**: Giao diện và trải nghiệm người dùng

### Technical Terms (Tiếng Anh)
Tài liệu giữ lại các technical terms tiếng Anh để đảm bảo accuracy:
- SCD Type 2, Position-Based Staffing, Job-Based Staffing
- Dual Structure, Matrix Organization
- Job Taxonomy, Job Profile, Career Path
- Skill Gap Analysis, Eligibility Profile
- GDPR, PDPA, Point-in-Time Reporting

---

## Thông tin Liên hệ

Nếu bạn có câu hỏi hoặc cần thêm thông tin về:
- **Feature Details**: Tham khảo `/_research/feature-catalog.md`
- **Entity Relationships**: Tham khảo `/_research/entity-catalog.md`
- **Deep-dive Technical**: Tham khảo các documents trong `/_research/overview/`

---

## Change Log

| Phiên bản | Ngày | Người thực hiện | Thay đổi |
|----------|------|-----------------|----------|
| 1.0 | 2026-03-06 | AI Assistant | Tạo bản đầu tiên - Tổng hợp từ overview documents và feature/entity catalogs |

---

*Bản tài liệu này là hướng dẫn đọc cho bộ summary của CO Module.*
