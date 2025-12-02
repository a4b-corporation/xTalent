# Thuật ngữ Công việc & Vị trí (Job & Position Glossary)

## Tổng quan

Bảng thuật ngữ này định nghĩa các thực thể cấu trúc công việc và vị trí được sử dụng trong hệ thống xTalent HCM. Mô hình công việc-vị trí hỗ trợ thiết kế tổ chức linh hoạt với phân loại đa cây (multi-tree taxonomy), phân cấp công việc và cả hai mô hình nhân sự dựa trên vị trí (position-based) và dựa trên công việc (job-based).

---

## Kiến trúc

Mô-đun Công việc & Vị trí sử dụng **kiến trúc đa cây (multi-tree architecture)** hỗ trợ:

1. **Cây Công việc Doanh nghiệp (Corporate Job Tree):** Danh mục công việc toàn doanh nghiệp
2. **Cây Công việc Đơn vị Kinh doanh (Business Unit Job Trees):** Cấu trúc công việc cụ thể theo BU
3. **Ánh xạ chéo cây (Cross-tree Mapping):** Hợp nhất và báo cáo trên các cây

Thiết kế này cho phép:
- Tiêu chuẩn công việc tập trung với sự linh hoạt cục bộ
- Quản lý công việc BU độc lập
- Báo cáo doanh nghiệp hợp nhất
- Hỗ trợ tích hợp M&A (Sáp nhập & Mua lại)

---

## Các thực thể (Entities)

### TaxonomyTree (Cây Phân loại)

**Định nghĩa:** Container cho các phân cấp phân loại công việc độc lập. Cho phép nhiều hệ thống phân loại công việc cùng tồn tại (doanh nghiệp so với đơn vị kinh doanh cụ thể).

**Mục đích:**
- Hỗ trợ nhiều phân loại công việc độc lập
- Cho phép phân loại theo doanh nghiệp và BU cụ thể
- Tạo điều kiện tích hợp M&A
- Cung cấp sự linh hoạt cho các mô hình tổ chức khác nhau

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã cây (ví dụ: CORP, BU_SALES, BU_TECH) |
| `name` | string(150) | Không | Tên cây |
| `tree_type` | enum | Có | CORPORATE, BUSINESS_UNIT, LEGACY |
| `owner_entity_id` | UUID | Không | Pháp nhân hoặc BU sở hữu |
| `description` | text | Không | Mô tả cây |
| `is_active` | boolean | Có | Trạng thái hoạt động (mặc định: true) |
| `metadata` | jsonb | Không | Cấu hình cây, quy tắc |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại cây (Tree Types):**

| Loại | Mô tả | Trường hợp sử dụng |
|------|-------|--------------------|
| `CORPORATE` | Phân loại toàn doanh nghiệp | Tiêu chuẩn công việc toàn cầu |
| `BUSINESS_UNIT` | Phân loại cụ thể theo BU | Cấu trúc công việc cục bộ |
| `LEGACY` | Phân loại hệ thống cũ | Tích hợp M&A |
| `CUSTOM` | Phân loại tùy chỉnh | Mục đích đặc biệt |

**Cấu trúc Metadata:**
```json
{
  "classification_system": "O*NET",
  "version": "2.0",
  "max_depth": 5,
  "allow_cross_tree_mapping": true,
  "consolidation_rules": {
    "map_to_corporate": true,
    "reporting_tree": "CORP"
  },
  "approval_required": true
}
```

**Mối quan hệ:**
- **Có nhiều** `JobTaxonomy` (các nút phân loại)
- **Có nhiều** `JobTree` (các cây công việc)

**Quy tắc nghiệp vụ:**
- Mã cây phải là duy nhất
- Khuyến nghị một cây doanh nghiệp
- Cho phép nhiều cây BU
- Ánh xạ chéo cây thông qua các bảng xmap

**Ví dụ:**

```yaml
# Cây Phân loại Doanh nghiệp
id: tree_corp_001
code: CORP
name: Corporate Job Taxonomy
tree_type: CORPORATE
owner_entity_id: entity_holding
is_active: true
metadata:
  classification_system: "O*NET"
  max_depth: 5

# Cây Phân loại Đơn vị Kinh doanh
id: tree_bu_tech_001
code: BU_TECH
name: Technology Division Job Taxonomy
tree_type: BUSINESS_UNIT
owner_entity_id: bu_technology
is_active: true
```

---

### JobTaxonomy (Phân loại Công việc)

**Định nghĩa:** Các nút phân loại công việc phân cấp trong một cây phân loại. Cung cấp phân loại công việc được chuẩn hóa (ví dụ: nhóm công việc, chức năng công việc, loại công việc).

**Mục đích:**
- Phân loại công việc thành các danh mục phân cấp
- Hỗ trợ cấu trúc nhóm công việc (job family)
- Cho phép báo cáo dựa trên phân loại
- Tạo điều kiện phân tích thị trường việc làm

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `tree_id` | UUID | Có | Tham chiếu cây phân loại |
| `parent_id` | UUID | Không | Nút phân loại cha |
| `code` | string(50) | Có | Mã phân loại |
| `name` | string(150) | Không | Tên phân loại |
| `level` | integer | Không | Cấp độ phân cấp (1=cao nhất, 2=giữa, 3=thấp nhất) |
| `path` | string(255) | Không | Đường dẫn materialized |
| `description` | text | Không | Mô tả phân loại |
| `metadata` | jsonb | Không | Dữ liệu phân loại bổ sung |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các cấp độ phân loại:**

| Cấp độ | Tên | Mô tả | Ví dụ |
|--------|-----|-------|-------|
| 1 | Job Family (Nhóm công việc) | Nhóm nghề nghiệp rộng | Kỹ thuật (Engineering) |
| 2 | Job Function (Chức năng công việc) | Lĩnh vực chức năng cụ thể | Kỹ thuật phần mềm (Software Engineering) |
| 3 | Job Category (Loại công việc) | Loại chi tiết | Phát triển Backend (Backend Development) |

**Cấu trúc Metadata:**
```json
{
  "onet_code": "15-1252.00",
  "industry_classification": "Technology",
  "skill_cluster": ["Programming", "System Design"],
  "career_path_group": "Technical Track",
  "market_data_available": true
}
```

**Mối quan hệ:**
- **Thuộc về** `TaxonomyTree`
- **Thuộc về** `JobTaxonomy` (cha)
- **Có nhiều** `JobTaxonomy` (con)
- **Có nhiều** `Job` (các công việc trong phân loại này)

**Quy tắc nghiệp vụ:**
- Mã phải là duy nhất trong cây
- Đường dẫn phải phản ánh phân cấp
- Khuyến nghị tối đa 5 cấp độ
- Sử dụng SCD Type 2 để theo dõi lịch sử

**Ví dụ:**

```yaml
# Cấp 1: Nhóm công việc
id: tax_eng_001
tree_id: tree_corp_001
parent_id: null
code: ENG
name: Engineering
level: 1
path: /ENG

# Cấp 2: Chức năng công việc
id: tax_sw_eng_001
tree_id: tree_corp_001
parent_id: tax_eng_001
code: SW_ENG
name: Software Engineering
level: 2
path: /ENG/SW_ENG

# Cấp 3: Loại công việc
id: tax_backend_001
tree_id: tree_corp_001
parent_id: tax_sw_eng_001
code: BACKEND
name: Backend Development
level: 3
path: /ENG/SW_ENG/BACKEND
```

---

### JobTree (Cây Công việc)

**Định nghĩa:** Container cho các phân cấp công việc độc lập. Tương tự như TaxonomyTree nhưng dành riêng cho cấu trúc công việc.

**Mục đích:**
- Hỗ trợ nhiều phân cấp công việc độc lập
- Cho phép danh mục công việc doanh nghiệp và cụ thể theo BU
- Tạo điều kiện quản lý công việc phi tập trung
- Hỗ trợ tích hợp M&A

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã cây công việc |
| `name` | string(150) | Không | Tên cây công việc |
| `tree_type` | enum | Có | CORPORATE, BUSINESS_UNIT, LEGACY |
| `owner_entity_id` | UUID | Không | Pháp nhân hoặc BU sở hữu |
| `taxonomy_tree_id` | UUID | Không | Cây phân loại liên kết |
| `is_active` | boolean | Có | Trạng thái hoạt động |
| `metadata` | jsonb | Không | Cấu hình cây |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Mối quan hệ:**
- **Tham chiếu** `TaxonomyTree` (tùy chọn)
- **Có nhiều** `Job` (các công việc trong cây này)

**Quy tắc nghiệp vụ:**
- Mã cây công việc phải là duy nhất
- Công việc có thể kế thừa từ công việc cha
- Hỗ trợ ánh xạ chéo cây thông qua các bảng xmap

---

### Job (Công việc)

**Định nghĩa:** Định nghĩa công việc đại diện cho một vai trò hoặc loại vị trí trong tổ chức. Xác định trách nhiệm, yêu cầu và năng lực độc lập với những người nắm giữ cụ thể.

**Mục đích:**
- Định nghĩa các vai trò công việc tiêu chuẩn
- Xác định yêu cầu và trình độ công việc
- Hỗ trợ đánh giá và xếp hạng công việc
- Cho phép lập kế hoạch lực lượng lao động

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `tree_id` | UUID | Có | Tham chiếu cây công việc |
| `parent_id` | UUID | Không | Công việc cha (cho phân cấp) |
| `taxonomy_id` | UUID | Không | Phân loại công việc |
| `code` | string(50) | Có | Mã công việc |
| `title` | string(150) | Không | Chức danh công việc |
| `level_id` | UUID | Không | Tham chiếu cấp bậc công việc |
| `grade_id` | UUID | Không | Tham chiếu ngạch công việc |
| `job_family_code` | string(50) | Không | Mã nhóm công việc |
| `job_function_code` | string(50) | Không | Mã chức năng công việc |
| `flsa_status` | enum | Không | EXEMPT, NON_EXEMPT (phân loại Mỹ) |
| `is_manager` | boolean | Không | Chỉ báo vai trò quản lý |
| `description` | text | Không | Mô tả công việc |
| `metadata` | jsonb | Không | Các thuộc tính công việc bổ sung |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Cấu trúc Metadata:**
```json
{
  "responsibilities": [
    "Design and develop backend services",
    "Mentor junior engineers",
    "Participate in architecture decisions"
  ],
  "requirements": {
    "education": "Bachelor's degree in Computer Science or related field",
    "experience_years": 5,
    "certifications": []
  },
  "working_conditions": {
    "remote_eligible": true,
    "travel_required": "Occasional",
    "physical_demands": "Sedentary"
  },
  "market_data": {
    "benchmark_job": "Software Engineer III",
    "market_percentile": 50
  }
}
```

**Mối quan hệ:**
- **Thuộc về** `JobTree`
- **Thuộc về** `Job` (công việc cha)
- **Thuộc về** `JobTaxonomy`
- **Thuộc về** `JobLevel`
- **Thuộc về** `JobGrade`
- **Có một** `JobProfile` (hồ sơ chi tiết)
- **Có nhiều** `Position` (các trường hợp vị trí)
- **Có nhiều** `Assignment` (gán công việc trực tiếp trong mô hình JOB_BASED)

**Quy tắc nghiệp vụ:**
- Mã công việc phải là duy nhất trong cây
- Có thể kế thừa từ công việc cha
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Hồ sơ công việc cung cấp chi tiết mở rộng

**Ví dụ:**

```yaml
id: job_senior_backend_001
tree_id: tree_corp_001
parent_id: job_backend_eng_001
taxonomy_id: tax_backend_001
code: SR_BACKEND_ENG
title: Senior Backend Engineer
level_id: level_senior
grade_id: grade_p3
job_family_code: ENG
job_function_code: SW_ENG
flsa_status: EXEMPT
is_manager: false
description: "Designs and develops scalable backend services..."
```

---

### JobProfile (Hồ sơ Công việc)

**Định nghĩa:** Hồ sơ mở rộng cho công việc bao gồm trách nhiệm chi tiết, yêu cầu, năng lực và kỹ năng.

**Mục đích:**
- Tài liệu hóa yêu cầu công việc chi tiết
- Xác định kỹ năng và năng lực cần thiết
- Hỗ trợ đánh giá công việc
- Cho phép thu hút và phát triển nhân tài

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `job_id` | UUID | Có | Tham chiếu công việc (PK và FK) |
| `summary` | text | Không | Tóm tắt công việc |
| `responsibilities` | text | Không | Trách nhiệm chính |
| `qualifications` | text | Không | Trình độ yêu cầu |
| `min_education_level` | string(50) | Không | Trình độ học vấn tối thiểu |
| `min_experience_years` | decimal(4,1) | Không | Số năm kinh nghiệm tối thiểu |
| `preferred_certifications` | text | Không | Chứng chỉ ưu tiên |
| `physical_requirements` | text | Không | Yêu cầu thể chất |
| `working_conditions` | text | Không | Điều kiện làm việc |
| `travel_percentage` | decimal(5,2) | Không | Tỷ lệ đi lại (0-100) |
| `remote_eligible` | boolean | Không | Đủ điều kiện làm việc từ xa |
| `metadata` | jsonb | Không | Dữ liệu hồ sơ bổ sung |

**Cấu trúc Metadata:**
```json
{
  "skills": [
    {
      "skill_id": "skill_python",
      "proficiency_required": 4,
      "is_mandatory": true
    },
    {
      "skill_id": "skill_aws",
      "proficiency_required": 3,
      "is_mandatory": false
    }
  ],
  "competencies": [
    {
      "competency_id": "comp_problem_solving",
      "level_required": 4
    }
  ],
  "languages": [
    {
      "language": "English",
      "proficiency": "Professional"
    }
  ]
}
```

**Mối quan hệ:**
- **Thuộc về** `Job` (một-một)
- **Tham chiếu** `SkillMaster` (thông qua metadata)
- **Tham chiếu** `CompetencyMaster` (thông qua metadata)

**Quy tắc nghiệp vụ:**
- Một hồ sơ cho mỗi công việc
- Kỹ năng và năng lực được định nghĩa trong metadata
- Hồ sơ được kế thừa từ công việc cha nếu không được chỉ định

---

### JobLevel (Cấp bậc Công việc)

**Định nghĩa:** Phân loại cấp bậc công việc (ví dụ: Junior, Mid, Senior, Principal, Executive) xác định các tầng thăng tiến nghề nghiệp.

**Mục đích:**
- Định nghĩa các cấp độ thăng tiến nghề nghiệp
- Hỗ trợ khung cấp bậc
- Cho phép trả lương theo cấp bậc
- Tạo điều kiện quản lý nhân tài

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã cấp bậc |
| `name` | string(100) | Không | Tên cấp bậc |
| `level_order` | integer | Không | Thứ tự phân cấp (1=thấp nhất) |
| `category` | enum | Không | INDIVIDUAL_CONTRIBUTOR, MANAGER, EXECUTIVE |
| `description` | text | Không | Mô tả cấp bậc |
| `metadata` | jsonb | Không | Tiêu chí cấp bậc, kỳ vọng |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Ví dụ Cấp bậc:**

| Mã | Tên | Thứ tự | Danh mục |
|----|-----|--------|----------|
| `JUNIOR` | Junior | 1 | INDIVIDUAL_CONTRIBUTOR |
| `MID` | Mid-Level | 2 | INDIVIDUAL_CONTRIBUTOR |
| `SENIOR` | Senior | 3 | INDIVIDUAL_CONTRIBUTOR |
| `PRINCIPAL` | Principal | 4 | INDIVIDUAL_CONTRIBUTOR |
| `MANAGER` | Manager | 3 | MANAGER |
| `DIRECTOR` | Director | 5 | MANAGER |
| `VP` | Vice President | 6 | EXECUTIVE |

**Cấu trúc Metadata:**
```json
{
  "expectations": {
    "scope": "Team level",
    "impact": "Significant",
    "autonomy": "High",
    "leadership": "Mentor others"
  },
  "typical_experience_years": "5-8",
  "career_progression": {
    "next_level": "PRINCIPAL",
    "typical_time_in_level": "2-3 years"
  }
}
```

**Quy tắc nghiệp vụ:**
- Mã cấp bậc phải là duy nhất
- Thứ tự cấp bậc xác định sự thăng tiến
- Sử dụng SCD Type 2 để theo dõi lịch sử

---

### JobGrade (Ngạch Công việc)

**Định nghĩa:** Phân loại ngạch công việc cho mục đích lương thưởng và đánh giá công việc. Ánh xạ công việc vào các ngạch lương.

**Mục đích:**
- Hỗ trợ cấu trúc lương thưởng
- Cho phép đánh giá công việc
- Định nghĩa các dải lương
- Tạo điều kiện quản trị tiền lương

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã ngạch |
| `name` | string(100) | Không | Tên ngạch |
| `grade_order` | integer | Không | Thứ tự phân cấp |
| `min_salary` | decimal(14,2) | Không | Lương tối thiểu |
| `mid_salary` | decimal(14,2) | Không | Lương trung bình |
| `max_salary` | decimal(14,2) | Không | Lương tối đa |
| `currency_code` | string(3) | Không | Mã tiền tệ |
| `description` | text | Không | Mô tả ngạch |
| `metadata` | jsonb | Không | Quy tắc ngạch, dải lương |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Cấu trúc Metadata:**
```json
{
  "pay_structure": "BROADBAND",
  "compa_ratio_min": 0.80,
  "compa_ratio_max": 1.20,
  "market_reference": "P50",
  "progression_rules": {
    "max_increase_percent": 15,
    "typical_increase_percent": 8
  }
}
```

**Quy tắc nghiệp vụ:**
- Mã ngạch phải là duy nhất
- Lương tối thiểu ≤ Trung bình ≤ Tối đa
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Mã tiền tệ là bắt buộc nếu lương được chỉ định

---

### Position (Vị trí)

**Định nghĩa:** Trường hợp cụ thể của một công việc trong một đơn vị kinh doanh. Đại diện cho một vị trí nhân sự (headcount) đã được lập ngân sách có thể được lấp đầy bởi một nhân viên.

**Mục đích:**
- Hỗ trợ mô hình nhân sự dựa trên vị trí
- Cho phép lập ngân sách và kiểm soát số lượng nhân sự
- Theo dõi người nắm giữ vị trí
- Tạo điều kiện lập kế hoạch tổ chức

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã vị trí |
| `name` | string(150) | Không | Tên vị trí |
| `job_id` | UUID | Có | Tham chiếu công việc |
| `business_unit_id` | UUID | Có | Tham chiếu đơn vị kinh doanh |
| `reports_to_position_id` | UUID | Không | Vị trí báo cáo |
| `location_id` | UUID | Không | Địa điểm chính |
| `fte` | decimal(4,2) | Không | Tương đương toàn thời gian (mặc định: 1.0) |
| `max_incumbents` | integer | Không | Số người nắm giữ tối đa (mặc định: 1) |
| `current_incumbents` | integer | Không | Số người nắm giữ hiện tại |
| `status_code` | string(50) | Không | ACTIVE, FROZEN, ELIMINATED |
| `position_type` | enum | Không | REGULAR, TEMPORARY, PROJECT |
| `is_budgeted` | boolean | Không | Cờ vị trí đã lập ngân sách |
| `metadata` | jsonb | Không | Dữ liệu vị trí bổ sung |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Trạng thái Vị trí:**

| Trạng thái | Mô tả |
|------------|-------|
| `ACTIVE` | Hoạt động, có thể lấp đầy |
| `FROZEN` | Đóng băng, không thể lấp đầy |
| `ELIMINATED` | Đã loại bỏ, không còn tồn tại |
| `PENDING_APPROVAL` | Đang chờ phê duyệt ngân sách |

**Cấu trúc Metadata:**
```json
{
  "budget_code": "DEPT-001-POS-123",
  "cost_center": "CC-1000",
  "approval_date": "2025-01-15",
  "approved_by": "worker_mgr_001",
  "requisition_id": "REQ-2025-001",
  "succession_plan": {
    "has_successor": true,
    "successor_ready": "1-2 years"
  }
}
```

**Mối quan hệ:**
- **Thuộc về** `Job`
- **Thuộc về** `Unit` (đơn vị kinh doanh)
- **Thuộc về** `Position` (báo cáo cho)
- **Thuộc về** `WorkLocation`
- **Có nhiều** `Assignment` (người nắm giữ vị trí)

**Quy tắc nghiệp vụ:**
- Mã vị trí phải là duy nhất
- Số người nắm giữ hiện tại ≤ số người tối đa
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Vị trí báo cáo phải nằm trong cùng BU hoặc BU cha
- Nhân sự dựa trên vị trí: một vị trí, một (hoặc giới hạn) người nắm giữ
- Nhân sự dựa trên công việc: không yêu cầu vị trí, gán công việc trực tiếp

**Ví dụ:**

```yaml
id: pos_backend_lead_001
code: POS-TECH-BE-001
name: Backend Engineering Lead
job_id: job_senior_backend_001
business_unit_id: bu_engineering
reports_to_position_id: pos_eng_manager_001
location_id: loc_hanoi_office
fte: 1.0
max_incumbents: 1
current_incumbents: 1
status_code: ACTIVE
position_type: REGULAR
is_budgeted: true
```

---

## Các mô hình nhân sự (Staffing Models)

### Nhân sự dựa trên vị trí (Position-Based Staffing)

**Mô tả:** Mô hình truyền thống nơi nhân viên được gán vào các vị trí đã được định nghĩa trước và lập ngân sách.

**Đặc điểm:**
- Kiểm soát số lượng nhân sự chặt chẽ
- Ánh xạ một-một (hoặc giới hạn) vị trí-người
- Yêu cầu phê duyệt ngân sách cho vị trí mới
- Phù hợp cho các vai trò doanh nghiệp, vị trí quản lý

**Ví dụ:**
```
Position (Backend Lead) → Assignment → Employee
```

### Nhân sự dựa trên công việc (Job-Based Staffing)

**Mô tả:** Mô hình linh hoạt nơi nhân viên được gán trực tiếp vào công việc mà không cần vị trí định nghĩa trước.

**Đặc điểm:**
- Quản lý năng lực linh hoạt
- Nhiều người có thể có cùng công việc
- Không có ràng buộc ngân sách vị trí
- Phù hợp cho nhân viên theo giờ, nhân viên thời vụ, nhóm dự án

**Ví dụ:**
```
Job (Backend Engineer) → Assignment → Employee
```

### Mô hình Kết hợp (Hybrid Model)

Các tổ chức có thể sử dụng cả hai mô hình:
- Vai trò doanh nghiệp: Dựa trên vị trí
- Theo giờ/thời vụ: Dựa trên công việc
- Nhóm dự án: Dựa trên công việc

---

## Kiến trúc Đa cây (Multi-Tree Architecture)

### Ánh xạ chéo cây (Cross-Tree Mapping)

**Mục đích:** Cho phép hợp nhất và báo cáo trên nhiều cây công việc.

**Triển khai:**
- Bảng `job_tree_xmap` ánh xạ công việc giữa các cây
- Hỗ trợ mối quan hệ nhiều-nhiều
- Cho phép báo cáo doanh nghiệp từ các công việc BU

**Ví dụ:**
```yaml
# BU Job → Corporate Job Mapping
bu_job_id: job_bu_tech_backend_001
corporate_job_id: job_corp_backend_001
mapping_type: EQUIVALENT
confidence_score: 0.95
```

---

## Các trường hợp sử dụng (Use Cases)

### Lập kế hoạch lực lượng lao động
- Định nghĩa danh mục công việc và cấu trúc vị trí
- Lập kế hoạch số lượng nhân sự và ngân sách
- Theo dõi vị trí trống
- Hỗ trợ lập kế hoạch kế nhiệm

### Thu hút nhân tài
- Tạo yêu cầu tuyển dụng từ vị trí
- Xác định yêu cầu và trình độ công việc
- Khớp ứng viên với công việc
- Hỗ trợ quản lý đề nghị

### Phát triển nghề nghiệp
- Định nghĩa lộ trình nghề nghiệp và thăng tiến
- Ánh xạ cấp bậc và ngạch công việc
- Hỗ trợ luân chuyển nội bộ
- Cho phép lập kế hoạch phát triển kỹ năng

### Quản lý lương thưởng
- Liên kết công việc với ngạch lương
- Định nghĩa dải lương
- Hỗ trợ đánh giá công việc
- Cho phép định giá thị trường

### Thiết kế tổ chức
- Mô hình hóa cấu trúc tổ chức
- Hỗ trợ tái cơ cấu
- Cho phép lập kế hoạch kịch bản
- Tạo điều kiện tích hợp M&A

---

## Các thực hành tốt nhất

1. **Thiết kế công việc:**
   - Sử dụng chức danh công việc rõ ràng, mô tả
   - Định nghĩa hồ sơ công việc toàn diện
   - Giữ danh mục công việc cập nhật
   - Đánh giá công việc thường xuyên

2. **Quản lý vị trí:**
   - Duy trì phân cấp vị trí chính xác
   - Theo dõi trạng thái vị trí
   - Đối chiếu số lượng nhân sự thường xuyên
   - Căn chỉnh ngân sách

3. **Chiến lược Đa cây:**
   - Một cây doanh nghiệp cho các tiêu chuẩn
   - Các cây BU cho sự linh hoạt cục bộ
   - Ánh xạ chéo cây thường xuyên
   - Báo cáo hợp nhất

4. **Lựa chọn mô hình nhân sự:**
   - Dựa trên vị trí cho các vai trò doanh nghiệp
   - Dựa trên công việc cho lực lượng lao động linh hoạt
   - Quản trị và phê duyệt rõ ràng

---

## Lịch sử phiên bản

| Phiên bản | Ngày | Thay đổi |
|-----------|------|----------|
| 2.0 | 2025-12-01 | Thêm hỗ trợ đa cây, các mô hình nhân sự |
| 1.0 | 2025-11-01 | Ontology công việc-vị trí ban đầu |
