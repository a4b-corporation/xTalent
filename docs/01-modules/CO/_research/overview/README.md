# xTalent Core Module (CO) — Tổng quan Capabilities

**Phiên bản**: 1.0  
**Cập nhật**: 2026-03-04  
**Module**: Core HR (CO)

---

## Giới thiệu

**Core Module (CO)** là nền tảng dữ liệu của toàn bộ hệ thống xTalent HCM. Module này định nghĩa và quản lý những thực thể trung tâm nhất của một tổ chức: **con người, tổ chức, công việc và mối quan hệ giữa chúng**.

Mọi module khác trong xTalent (Chấm công, Tính lương, Tuyển dụng, Đãi ngộ) đều dựa vào CO để lấy dữ liệu nền tảng. CO không chỉ là một "Employee directory" đơn thuần — đây là một **enterprise-grade HR data platform** với thiết kế đủ linh hoạt để xử lý cả những tổ chức phức tạp nhất.

---

## Kiến trúc tổng thể

```
┌─────────────────────────────────────────────────────────────────┐
│                        CO MODULE                                │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │   PERSON     │  │  EMPLOYMENT  │  │   ORG STRUCTURE     │   │
│  │ 10 entities  │  │  7 entities  │  │    19 entities      │   │
│  │  Workers,    │  │  WorkRel,    │  │  Entity, Unit,      │   │
│  │  Skills,     │  │  Employee,   │  │  Supervisory,       │   │
│  │  Competency  │  │  Assignment  │  │  Relations          │   │
│  └──────────────┘  └──────────────┘  └─────────────────────┘   │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │ JOB/POSITION │  │  MASTER DATA │  │   ELIGIBILITY       │   │
│  │ 13 entities  │  │  15 entities │  │   3 entities        │   │
│  │  Job, Profile│  │  Skills,     │  │  (Cross-module      │   │
│  │  Position,   │  │  Codes,      │  │   Engine)           │   │
│  │  Career Path │  │  Geography   │  │                     │   │
│  └──────────────┘  └──────────────┘  └─────────────────────┘   │
│                                                                  │
│  Tổng: 68 entities · 12 Aggregate Roots · 7 Sub-modules        │
└─────────────────────────────────────────────────────────────────┘
          ↓              ↓              ↓              ↓
      TA Module      TR Module      PR Module      RC Module
    (Chấm công)    (Đãi ngộ)     (Lương)       (Tuyển dụng)
```

---

## Bộ tài liệu này

Bộ tài liệu overview được thiết kế để phục vụ nhiều đối tượng đọc khác nhau:

| Tài liệu | Nội dung | Đối tượng | Thời gian đọc |
|---------|----------|-----------|--------------|
| **[01 · Executive Summary](./01-executive-summary.md)** | Tầm nhìn, giá trị kinh doanh, so sánh thị trường | Business, CXO | ~10 phút |
| **[02 · Mô hình Employment](./02-employment-model.md)** | 4-level hierarchy, contract management, vòng đời nhân sự | Business, HR Admin | ~20 phút |
| **[03 · Mô hình Tổ chức](./03-organization-model.md)** | Dual structure, matrix organization, legal entity | Business, HR, Manager | ~20 phút |
| **[04 · Job & Position](./04-job-position-model.md)** | Job taxonomy, staffing models, career paths | HR, Finance, Manager | ~20 phút |
| **[05 · Quản lý Nhân sự & Skills](./05-people-skills-data.md)** | Worker data, skill gap analysis, data security | HR, Talent Manager | ~15 phút |
| **[06 · Capabilities Liên Module](./06-cross-module-capabilities.md)** | Eligibility engine, talent marketplace, design patterns | All | ~15 phút |

**Lộ trình đọc đề xuất**:
- **Business stakeholder**: Bắt đầu từ `01` → `02` → `03`
- **HR Administrator**: Đọc tuần tự từ `01` đến `06`
- **Technical/Product**: Bắt đầu từ `01` → `04` → `06`

---

## Điểm nổi bật của CO Module

| Innovation | Mô tả ngắn |
|-----------|-----------|
| **4-Level Employment** | Tách biệt: Person Identity / Work Relationship / Employment Contract / Job Assignment |
| **Dual Org Structure** | Cấu trúc Operational (tổ chức công việc) độc lập với Supervisory (báo cáo, phê duyệt) |
| **Flexible Staffing** | Hỗ trợ đồng thời cả Position-Based (kiểm soát headcount chặt) và Job-Based (linh hoạt) |
| **Matrix Organization** | Solid line (primary reporting) + Dotted line (project/functional reporting) |
| **Skill Gap Analysis** | So sánh tự động requirements của vị trí vs skills thực tế của người lao động |
| **Eligibility Engine** | Quản lý điều kiện hưởng lợi tập trung, tái sử dụng cho tất cả các module |
| **Full Audit Trail** | SCD Type 2 — lưu toàn bộ lịch sử thay đổi, hỗ trợ point-in-time reporting |
| **GDPR/PDPA Ready** | Phân loại dữ liệu 4 cấp, kiểm soát truy cập theo vai trò, audit trail bắt buộc |

---

*Tài liệu này thuộc bộ research overview của CO module. Nguồn gốc: tổng hợp từ `00-old/01-concept/`.*
