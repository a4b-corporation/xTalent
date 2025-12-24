# Thuật ngữ Công việc & Vị trí (Job & Position Glossary)

## Tổng quan

Bảng thuật ngữ này định nghĩa các thực thể cấu trúc công việc và vị trí được sử dụng trong hệ thống xTalent HCM.

**Các hướng tiếp cận triển khai**:
- **Thiết kế Đơn giản hóa (Khuyến nghị)**: Cấu trúc 3 thực thể (JobTaxonomy, Job, JobProfile) phù hợp với hầu hết các tổ chức.
- **Thiết kế Nâng cao (Tùy chọn)**: Kiến trúc đa cây (multi-tree) cho các tổ chức phức tạp yêu cầu các danh mục công việc độc lập.

Tài liệu này chủ yếu mô tả thiết kế đơn giản hóa. Các tính năng nâng cao được đánh dấu bằng **[NÂNG CAO]** và được mô tả chi tiết trong phần [Tính năng Nâng cao](#tính-năng-nâng-cao).

---

## Các Khái niệm Cốt lõi

### Công việc (Job) vs Vị trí (Position)

- **Công việc (Job)**: Bản mẫu định nghĩa công việc cần làm (trách nhiệm, yêu cầu, mức lương thưởng).
- **Vị trí (Position)**: Một trường hợp cụ thể của công việc trong bối cảnh tổ chức (một vị trí nhân sự được lập ngân sách).

### Phân loại Công việc (Job Taxonomy)

Hệ thống phân loại phân cấp tổ chức công việc thành:
- **Cấp 1 - TRACK (Lĩnh vực)**: Nhóm nghề nghiệp rộng (ví dụ: Kỹ thuật, Kinh doanh).
- **Cấp 2 - FAMILY (Nhóm công việc)**: Nhóm công việc cụ thể trong lĩnh vực (ví dụ: Kỹ thuật phần mềm, Bán hàng doanh nghiệp).
- **Cấp 3 - GROUP (Nhóm chi tiết)**: Nhóm công việc chi tiết (ví dụ: Phát triển Backend, Quản lý tài khoản).
- **Cấp 4 - SUBGROUP (Nhóm phụ)**: Phân loại chuyên sâu (ví dụ: Backend Microservices, Khách hàng chiến lược).

---

## Các thực thể (Entities)

### JobTaxonomy (Phân loại Công việc)

**Định nghĩa:** Các nút phân loại công việc phân cấp trong một cây phân loại. Cung cấp phân loại công việc được chuẩn hóa.

**Mục đích:**
- Phân loại công việc thành các danh mục phân cấp.
- Hỗ trợ cấu trúc nhóm công việc (job family).
- Cho phép báo cáo dựa trên phân loại.
- Tạo điều kiện phân tích thị trường việc làm.

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã phân loại (duy nhất) |
| `name` | string(150) | Có | Tên phân loại |
| `taxonomy_type` | enum | Có | TRACK, FAMILY, GROUP, SUBGROUP |
| `parent_id` | UUID | Không | Nút cha (null đối với TRACK) |
| `level` | integer | Không | Cấp độ phân cấp (1, 2, 3, 4) |
| `path` | string(255) | Không | Đường dẫn materialized |
| `description` | text | Không | Mô tả phân loại |
| `metadata` | jsonb | Không | Dữ liệu phân loại bổ sung |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các cấp độ phân loại (Taxonomy Levels):**

| Cấp độ | taxonomy_type | Mô tả | Ví dụ |
|--------|---------------|-------|-------|
| 1 | TRACK | Lĩnh vực nghề nghiệp rộng | Kỹ thuật, Kinh doanh, Vận hành |
| 2 | FAMILY | Nhóm công việc trong lĩnh vực | Kỹ thuật phần mềm, Bán hàng doanh nghiệp |
| 3 | GROUP | Nhóm công việc cụ thể | Phát triển Backend, Quản lý tài khoản |
| 4 | SUBGROUP | Nhóm phụ chi tiết | Backend Microservices, Khách hàng chiến lược |

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
- **Thuộc về** `JobTaxonomy` (cha) - để phân cấp.
- **Có nhiều** `JobTaxonomy` (con).
- **Có nhiều** `Job` (các công việc được phân loại theo taxonomy này).

**Quy tắc nghiệp vụ:**
- Mã (Code) phải là duy nhất.
- `taxonomy_type` phải khớp với `level` (TRACK=1, FAMILY=2, GROUP=3, SUBGROUP=4).
- Yêu cầu nút cha (Parent) cho các cấp FAMILY, GROUP và SUBGROUP (TRACK không có cha).
- Đường dẫn (Path) phải phản ánh đúng phân cấp thực tế.
- Khuyến nghị tối đa 4 cấp độ.
- Sử dụng SCD Type 2 để theo dõi lịch sử.
- Công việc nên được liên kết với cấp GROUP hoặc SUBGROUP để phân loại cụ thể nhất.

**Ví dụ:**

```yaml
# Cấp 1: Track
id: tax_eng_001
code: ENG
name: Engineering
taxonomy_type: TRACK
parent_id: null
level: 1
path: /ENG
sort_order: 1

# Cấp 2: Family
id: tax_sw_eng_001
code: SW_ENG
name: Software Engineering
taxonomy_type: FAMILY
parent_id: tax_eng_001
level: 2
path: /ENG/SW_ENG
sort_order: 1

# Cấp 3: Group
id: tax_backend_001
code: BACKEND
name: Backend Development
taxonomy_type: GROUP
parent_id: tax_sw_eng_001
level: 3
path: /ENG/SW_ENG/BACKEND
sort_order: 1

# Cấp 4: Sub-Group
id: tax_microservices_001
code: MICROSERVICES
name: Microservices Backend
taxonomy_type: SUBGROUP
parent_id: tax_backend_001
level: 4
path: /ENG/SW_ENG/BACKEND/MICROSERVICES
sort_order: 1
```

**[NÂNG CAO] Hỗ trợ Đa cây (Multi-Tree Support):**

Đối với các tổ chức phức tạp yêu cầu nhiều cây phân loại độc lập, các thuộc tính bổ sung sau có sẵn:
- `tree_id`: Tham chiếu đến container cây phân loại.
- `owner_scope`: CORP | LE | BU (Phạm vi sở hữu).
- `owner_unit_id`: ID đơn vị kinh doanh sở hữu.
- `inherit_flag`: Kiểm soát kế thừa.
- `override_name`: Ghi đè tên theo BU cụ thể.
- `visibility`: PUBLIC | PRIVATE | RESTRICTED.

Xem phần [Tính năng Nâng cao](#tính-năng-nâng-cao) để biết thêm chi tiết.

---

### Job (Công việc)

**Định nghĩa:** Định nghĩa công việc đại diện cho một vai trò hoặc loại vị trí trong tổ chức. Xác định trách nhiệm, yêu cầu và năng lực độc lập với những người nắm giữ cụ thể.

**Mục đích:**
- Định nghĩa các vai trò công việc tiêu chuẩn.
- Xác định yêu cầu và trình độ công việc.
- Hỗ trợ đánh giá và xếp hạng công việc.
- Cho phép lập kế hoạch lực lượng lao động.

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| **Định danh cốt lõi** | | | |
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã công việc (duy nhất trong cây) |
| `title` | string(150) | Có | Chức danh công việc |
| `parent_id` | UUID | Không | Công việc cha (để phân cấp) |
| **Cây & Quyền sở hữu** | | | |
| `tree_id` | UUID | Không | Tham chiếu cây công việc (tùy chọn) |
| `owner_scope` | enum | Có | CORP | LE | BU (phạm vi sở hữu) |
| `owner_unit_id` | UUID | Không | Đơn vị kinh doanh sở hữu (bắt buộc nếu owner_scope=BU) |
| `inherit_flag` | boolean | Có | Kiểm soát kế thừa (mặc định: true) |
| `override_title` | string(255) | Không | Ghi đè chức danh cho BU cụ thể |
| `visibility` | enum | Không | PUBLIC | PRIVATE | RESTRICTED |
| **Phân loại** | | | |
| `job_type_code` | string(50) | Không | code_list(JOB_TYPE) - ví dụ: INDIVIDUAL_CONTRIBUTOR, MANAGER |
| `ranking_level_code` | string(50) | Không | code_list(JOB_RANK) - ví dụ: ENTRY, JUNIOR, MID, SENIOR, PRINCIPAL |
| **Ngạch & Cấp bậc** | | | |
| `level_id` | UUID | Không | Tham chiếu cấp bậc công việc (FK tới JobLevel) |
| `grade_id` | UUID | Không | Tham chiếu ngạch lương công việc (FK tới JobGrade) |
| **Phân loại Lao động Mỹ** | | | |
| `flsa_status` | enum | Không | EXEMPT | NON_EXEMPT |
| `is_manager` | boolean | Không | Chỉ báo vai trò quản lý |
| **Phân cấp & Đường dẫn** | | | |
| `path` | string(500) | Không | Đường dẫn vật chất hóa (định dạng ltree) |
| `sort_order` | integer | Không | Thứ tự hiển thị |
| **Mô tả & Metadata** | | | |
| `description` | text | Không | Mô tả công việc |
| `metadata` | jsonb | Không | Các thuộc tính công việc bổ sung |
| **SCD Type-2** | | | |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Cấu trúc Metadata:**
```json
{
  "responsibilities": [
    "Thiết kế và phát triển các dịch vụ backend",
    "Hướng dẫn các kỹ sư cấp dưới",
    "Tham gia vào các quyết định kiến trúc"
  ],
  "requirements": {
    "education": "Cử nhân Khoa học Máy tính hoặc lĩnh vực liên quan",
    "experience_years": 5,
    "certifications": []
  },
  "working_conditions": {
    "remote_eligible": true,
    "travel_required": "Thỉnh thoảng",
    "physical_demands": "Văn phòng"
  },
  "market_data": {
    "benchmark_job": "Kỹ sư phần mềm III",
    "market_percentile": 50
  }
}
```

**Mối quan hệ:**
- **Thuộc về** `Job` (công việc cha) - để phân cấp.
- **Liên kết tới** `JobTaxonomy` qua `JobTaxonomyMap` (phân loại nhiều-nhiều).
- **Thuộc về** `JobLevel` (cấp bậc).
- **Thuộc về** `JobGrade` (lương thưởng).
- **Thuộc về** `JobTree` (cây chứa tùy chọn).
- **Có một** `JobProfile` (hồ sơ chi tiết).
- **Có nhiều** `Position` (các vị trí nhân sự).
- **Có nhiều** `Assignment` (gán trực tiếp trong mô hình JOB_BASED).

**Quy tắc nghiệp vụ:**
- Mã công việc phải duy nhất trong cây.
- Có thể kế thừa từ công việc cha (trách nhiệm, yêu cầu).
- Công việc liên kết với phân loại qua JobTaxonomyMap (nhiều-nhiều).
- Một liên kết phân loại phải được đánh dấu là chính (is_primary=true).
- Phân loại chính nên ở cấp GROUP hoặc SUBGROUP.
- Trường path hỗ trợ ltree để truy vấn phân cấp hiệu quả.
- Sử dụng SCD Type 2 để theo dõi lịch sử.
- Công việc định nghĩa CÁI GÌ cần làm (bản mẫu).
- Vị trí định nghĩa Ở ĐÂU công việc được thực hiện (vị trí trong tổ chức).
- `JobProfile` cung cấp mô tả chi tiết (trách nhiệm, yêu cầu, kỹ năng).

**Ví dụ:**

```yaml
id: job_senior_backend_001
code: SR_BACKEND_ENG
title: Kỹ sư Backend Cấp cao
parent_id: job_backend_eng_001
tree_id: tree_corp_jobs  # Tùy chọn
owner_scope: CORP
inherit_flag: true
level_id: level_senior
grade_id: grade_p3
job_type_code: INDIVIDUAL_CONTRIBUTOR
ranking_level_code: SENIOR
flsa_status: EXEMPT
is_manager: false
path: /ENG/SW_ENG/BACKEND/SR_BACKEND
description: "Thiết kế và phát triển các dịch vụ backend có khả năng mở rộng..."

# Liên kết phân loại (qua JobTaxonomyMap):
# - taxonomy_id: tax_backend_dev (is_primary: true, level: GROUP)
# - taxonomy_id: tax_cloud_services (is_primary: false, level: GROUP)
```

**Phân loại Taxonomy:**

Công việc được phân loại sử dụng mối quan hệ nhiều-nhiều với JobTaxonomy qua entity `JobTaxonomyMap`.

**Điểm chính:**
- Một công việc có thể thuộc về nhiều node phân loại
- Một liên kết phân loại phải được đánh dấu là chính (`is_primary = true`)
- Phân loại chính nên ở cấp GROUP hoặc SUBGROUP
- Phân loại phụ có thể được sử dụng cho các vai trò đa chức năng

**Ví dụ**: Một "Kỹ sư DevOps" có thể có:
- Chính: Công nghệ > Kỹ thuật Phần mềm > DevOps (GROUP)
- Phụ: Công nghệ > Hạ tầng > Dịch vụ Đám mây (GROUP)

Xem phần [Tính năng Nâng cao](#tính-năng-nâng-cao) để biết thêm chi tiết.

---

### JobProfile (Hồ sơ Công việc)

**Định nghĩa:** Hồ sơ mở rộng cho công việc bao gồm trách nhiệm chi tiết, yêu cầu, năng lực và kỹ năng.

**Mục đích:**
- Tài liệu hóa các yêu cầu chi tiết của công việc.
- Định nghĩa các kỹ năng và năng lực cần thiết.
- Hỗ trợ đánh giá công việc.
- Cho phép thu hút và phát triển nhân tài.

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `job_id` | UUID | Có | Tham chiếu công việc (PK và FK) |
| `summary` | text | Không | Tóm tắt công việc |
| `responsibilities` | text | Không | Trách nhiệm chính |
| `qualifications` | text | Không | Trình độ yêu cầu |
| `min_education_level` | string(50) | Không | Trình độ học vấn tối thiểu |
| `min_experience_years` | decimal(4,1) | Không | Kinh nghiệm tối thiểu (năm) |
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
      "language": "Tiếng Anh",
      "proficiency": "Chuyên nghiệp"
    }
  ]
}
```

**Mối quan hệ:**
- **Thuộc về** `Job` (một-một).
- **Tham chiếu** `SkillMaster` (thông qua metadata).
- **Tham chiếu** `CompetencyMaster` (thông qua metadata).

**Quy tắc nghiệp vụ:**
- Một hồ sơ cho mỗi công việc.
- Kỹ năng và năng lực được định nghĩa trong metadata.
- Hồ sơ được kế thừa từ công việc cha nếu không được quy định cụ thể.

---

### JobLevel (Cấp bậc Công việc)

**Định nghĩa:** Phân loại cấp bậc công việc (ví dụ: Junior, Mid, Senior, Principal, Executive) xác định các bậc thăng tiến nghề nghiệp.

**Mục đích:**
- Định nghĩa các cấp độ thăng tiến nghề nghiệp.
- Hỗ trợ khung phân cấp (leveling framework).
- Cho phép chi trả lương dựa trên cấp bậc.
- Tạo điều kiện quản lý nhân tài.

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã cấp bậc |
| `name` | string(100) | Không | Tên cấp bậc |
| `level_order` | integer | Không | Thứ tự phân cấp (1=thấp nhất) |
| `category` | enum | Không | NV_CHUYEN_MON, QUAN_LY, LANH_DAO |
| `description` | text | Không | Mô tả cấp bậc |
| `metadata` | jsonb | Không | Tiêu chí cấp bậc, kỳ vọng |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Ví dụ Cấp bậc:**

| Mã | Tên | Thứ tự | Danh mục |
|----|-----|--------|----------|
| `JUNIOR` | Junior | 1 | NV_CHUYEN_MON |
| `MID` | Mid-Level | 2 | NV_CHUYEN_MON |
| `SENIOR` | Senior | 3 | NV_CHUYEN_MON |
| `PRINCIPAL` | Principal | 4 | NV_CHUYEN_MON |
| `MANAGER` | Manager | 3 | QUAN_LY |
| `DIRECTOR` | Director | 5 | QUAN_LY |
| `VP` | Vice President | 6 | LANH_DAO |

**Cấu trúc Metadata:**
```json
{
  "expectations": {
    "scope": "Cấp đội nhóm",
    "impact": "Đáng kể",
    "autonomy": "Cao",
    "leadership": "Hướng dẫn người khác"
  },
  "typical_experience_years": "5-8",
  "career_progression": {
    "next_level": "PRINCIPAL",
    "typical_time_in_level": "2-3 năm"
  }
}
```

**Quy tắc nghiệp vụ:**
- Mã cấp bậc phải là duy nhất.
- Thứ tự (level_order) xác định lộ trình thăng tiến.
- Sử dụng SCD Type 2 để theo dõi lịch sử.

---

### JobGrade (Ngạch lương Công việc)

**Định nghĩa:** Phân loại ngạch lương dùng cho mục đích lương thưởng và đánh giá giá trị công việc. Ánh xạ công việc vào các bậc lương.

**Mục đích:**
- Hỗ trợ cấu trúc lương thưởng.
- Cho phép đánh giá công việc.
- Định nghĩa các dải lương.
- Tạo điều kiện quản trị tiền lương.

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
- Mã ngạch phải là duy nhất.
- Lương tối thiểu ≤ Trung bình ≤ Tối đa.
- Sử dụng SCD Type 2 để theo dõi lịch sử.
- Đơn vị tiền tệ là bắt buộc nếu có quy định mức lương.

---

### Position (Vị trí)

**Định nghĩa:** Một trường hợp cụ thể của một công việc tại một đơn vị kinh doanh. Đại diện cho một chỉ tiêu nhân sự (headcount slot) đã lập ngân sách.

**Mục đích:**
- Hỗ trợ mô hình nhân sự dựa trên vị trí.
- Cho phép lập ngân sách và kiểm soát số lượng nhân sự.
- Theo dõi người đang nắm giữ vị trí.
- Tạo điều kiện lập kế hoạch tổ chức.

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã vị trí |
| `name` | string(150) | Không | Tên vị trí |
| `job_id` | UUID | Có | Tham chiếu công việc |
| `business_unit_id` | UUID | Có | Tham chiếu đơn vị kinh doanh |
| `reports_to_position_id` | UUID | Không | Vị trí báo cáo trực tiếp |
| `location_id` | UUID | Không | Địa điểm làm việc chính |
| `fte` | decimal(4,2) | Không | Định biên toàn thời gian (mặc định: 1.0) |
| `max_incumbents` | integer | Không | Số lượng người tối đa (mặc định: 1) |
| `current_incumbents` | integer | Không | Số lượng người hiện có |
| `status_code` | string(50) | Không | ACTIVE, FROZEN, ELIMINATED |
| `position_type` | enum | Không | CHINH_THUC, TAM_THOI, DU_AN |
| `is_budgeted` | boolean | Không | Cờ vị trí đã có ngân sách |
| `metadata` | jsonb | Không | Dữ liệu vị trí bổ sung |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Trạng thái Vị trí (Position Status):**

| Trạng thái | Mô tả |
|------------|-------|
| `ACTIVE` | Đang hoạt động, có thể tuyển dụng |
| `FROZEN` | Đang đóng băng, không được tuyển mới |
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
- **Thuộc về** `Job`.
- **Thuộc về** `Unit` (Đơn vị kinh doanh).
- **Thuộc về** `Position` (Quan hệ báo cáo).
- **Thuộc về** `WorkLocation`.
- **Có nhiều** `Assignment` (Những người đang giữ vị trí).

**Quy tắc nghiệp vụ:**
- Mã vị trí phải là duy nhất.
- Số lượng hiện tại ≤ Số lượng tối đa.
- Sử dụng SCD Type 2 để theo dõi lịch sử.
- Vị trí báo cáo phải nằm trong cùng BU hoặc BU cha.
- Nhân sự dựa trên Vị trí: một vị trí, một (hoặc giới hạn) người giữ.
- Nhân sự dựa trên Công việc: không cần vị trí, gán công việc trực tiếp.

**Ví dụ:**

```yaml
id: pos_backend_lead_001
code: POS-TECH-BE-001
name: Trưởng nhóm Kỹ thuật Backend
job_id: job_senior_backend_001
business_unit_id: bu_engineering
reports_to_position_id: pos_eng_manager_001
location_id: loc_hanoi_office
fte: 1.0
max_incumbents: 1
current_incumbents: 1
status_code: ACTIVE
position_type: CHINH_THUC
is_budgeted: true
```

---

## Các Mô hình Nhân sự (Staffing Models)

### Nhân sự dựa trên Vị trí (Position-Based Staffing)

**Mô tả**: Mô hình truyền thống nơi nhân viên được phân bổ vào các vị trí đã định nghĩa trước và được lập ngân sách.

**Đặc điểm**:
- Kiểm soát định biên chặt chẽ.
- Ánh xạ một-một (hoặc giới hạn) giữa vị trí và con người.
- Yêu cầu phê duyệt ngân sách cho các vị trí mới.
- Phù hợp cho các vai trò vận hành, quản lý.

**Ví dụ**:
```
Vị trí (Trưởng nhóm Backend) → Gán việc → Nhân viên
```

### Nhân sự dựa trên Công việc (Job-Based Staffing)

**Mô tả**: Mô hình linh hoạt nơi nhân viên được gán trực tiếp vào các công việc mà không cần định nghĩa vị trí trước.

**Đặc điểm**:
- Quản lý năng lực linh hoạt.
- Nhiều người có thể có cùng một công việc (không giới hạn slots).
- Không bị ràng buộc bởi ngân sách cho từng vị trí riêng lẻ.
- Phù hợp cho nhân viên theo giờ, thời vụ, nhóm dự án.

**Ví dụ**:
```
Công việc (Kỹ sư Backend) → Gán việc → Nhân viên
```

### Mô hình Kết hợp (Hybrid Model)

Tổ chức có thể sử dụng đồng thời cả hai mô hình:
- Các vai trò chính yếu/quản lý: Dựa trên Vị trí.
- Nhân sự theo giờ/thời vụ: Dựa trên Công việc.
- Các nhóm dự án: Dựa trên Công việc.

---

## Tính năng Nâng cao (Advanced Features)

> [!NOTE]
> **Triển khai Giai đoạn 2**
>
> Các tính năng sau đây hỗ trợ kiến trúc đa cây nâng cao dành cho các tổ chức phức tạp. Đây là các tùy chọn không bắt buộc cho giai đoạn đầu.

### Khi nào nên sử dụng Kiến trúc Đa cây

**Khuyến nghị cho**:
- Các tập đoàn đa quốc gia có sự khác biệt về công việc theo khu vực.
- Các tập đoàn đa ngành (ví dụ VNG: Gaming, FinTech, Cloud, E-commerce).
- Kịch bản M&A (Mua lại & Sáp nhập) cần tích hợp các danh mục công việc khác nhau.
- Các tổ chức phân quyền cao với các BU tự chủ.

**Không khuyến nghị cho**:
- Doanh nghiệp nhỏ và vừa (SMEs).
- Các tổ chức nhân sự tập trung.
- Tổ chức có cấu trúc công việc chuẩn hóa hoàn toàn.

### Các thực thể Đa cây

#### TaxonomyTree (Cây Phân loại)

**Định nghĩa**: Container cho các phân cấp phân loại công việc độc lập. Cho phép nhiều hệ thống phân loại cùng tồn tại.

**Các thuộc tính chính**:

| Thuộc tính | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| `id` | UUID | Định danh duy nhất |
| `code` | string(50) | Mã cây (ví dụ: CORP_TAX, BU_GAMING_TAX) |
| `name` | string(150) | Tên cây |
| `owner_scope` | enum | CORP, LE, BU |
| `owner_unit_id` | UUID | ID đơn vị tham chiếu (nếu owner_scope=BU) |
| `is_active` | boolean | Trạng thái hoạt động |

**Ví dụ**:
```yaml
# Cây phân loại của Tập đoàn
code: CORP_TAX_2025
name: Danh mục phân loại 2025 của Tập đoàn
owner_scope: CORP
owner_unit_id: null

# Cây phân loại của BU Gaming
code: BU_GAMING_TAX
name: Danh mục phân loại của khối Gaming
owner_scope: BU
owner_unit_id: <id_bu_gaming>
```

#### JobTree (Cây Công việc)

**Định nghĩa**: Container cho các phân cấp công việc độc lập. Tương tự TaxonomyTree nhưng dành cho danh mục công việc.

**Các thuộc tính chính**:

| Thuộc tính | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| `id` | UUID | Định danh duy nhất |
| `code` | string(50) | Mã cây (ví dụ: CORP_JOBS, BU_GAMING_JOBS) |
| `name` | string(150) | Tên cây |
| `owner_scope` | enum | CORP, LE, BU |
| `owner_unit_id` | UUID | ID đơn vị tham chiếu (nếu owner_scope=BU) |
| `parent_tree_id` | UUID | Cây cha (để kế thừa) |

#### TaxonomyXMap (Ánh xạ chéo Phân loại)

**Định nghĩa**: Ánh xạ giữa các nút của các cây phân loại khác nhau để phục vụ báo cáo hợp nhất.

**Các thuộc tính chính**:

| Thuộc tính | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| `src_node_id` | UUID | Nút phân loại nguồn (cây của BU) |
| `target_node_id` | UUID | Nút phân loại đích (cây của Tập đoàn) |
| `map_type_code` | enum | REPORT_TO, ALIGN_WITH, DUPLICATE_OF |

#### JobXMap (Ánh xạ chéo Công việc)

**Định nghĩa**: Ánh xạ giữa các công việc của các cây khác nhau.

**Mục đích**: Ánh xạ các công việc cụ thể của BU sang công việc tiêu chuẩn của Tập đoàn để báo cáo định biên và lương thưởng.

#### JobTaxonomyMap (Ánh xạ Công việc - Phân loại)

**Định nghĩa**: Quan hệ nhiều-nhiều giữa công việc và các nút phân loại.

**Mục đích**: Cho phép một công việc thuộc về nhiều phân loại đồng thời (ví dụ: khối Kỹ thuật + khối Quản lý).

---

## Các trường hợp sử dụng (Use Cases)

### Lập kế hoạch Nguồn nhân lực
- Định nghĩa danh mục công việc và cấu trúc vị trí.
- Lập kế hoạch định biên và ngân sách.
- Theo dõi các vị trí còn trống.

### Tuyển dụng
- Tạo yêu cầu tuyển dụng (Requisition) từ vị trí.
- Khớp ứng viên với yêu cầu công việc.

### Phát triển Nghề nghiệp
- Định nghĩa lộ trình thăng tiến.
- Ánh xạ cấp bậc và ngạch lương.

### Quản lý Lương thưởng
- Liên kết công việc với ngạch bậc lương.
- Định nghĩa dải lương thị trường.

---

## Thực hành Tốt nhất (Best Practices)

1. **Thiết kế Công việc**:
   - Sử dụng chức danh rõ ràng, mang tính mô tả.
   - Luôn duy trì danh mục công việc cập nhật.
2. **Quản lý Vị trí**:
   - Duy trì hệ thống báo cáo (hierarchy) chính xác.
   - Đối soát định biên (headcount reconciliation) định kỳ.
3. **Chiến lược Đa cây**:
   - Dùng một cây tập đoàn làm tiêu chuẩn chung.
   - Dùng các cây BU để linh hoạt cho địa phương/đặc thù ngành.

---

## Lịch sử phiên bản

| Phiên bản | Ngày | Thay đổi |
|-----------|------|----------|
| 4.0 | 2025-12-23 | Cập nhật cấu trúc phân loại 4 cấp (Track > Family > Group > Subgroup), chuẩn hóa tree_id |
| 3.0 | 2025-12-15 | Bổ sung kiến trúc đa cây và các ánh xạ chéo |
| 2.0 | 2025-12-01 | Phân tách mô hình dựa trên Vị trí và dựa trên Công việc |
| 1.0 | 2025-11-01 | Bản thảo đầu tiên |
