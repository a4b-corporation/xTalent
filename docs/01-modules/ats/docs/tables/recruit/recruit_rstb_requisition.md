# Data Dictionary - recruit.rstb_requisition

**Mô tả bảng:** Lưu thông tin yêu cầu tuyển dụng (requisition)

**Nguồn dữ liệu:** `staging.hr_job` (hoặc `hr_job_upsert`)

**Scripts ETL:** `j_import_all_request.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `hr_job.id` từ staging | Trực tiếp | Mã định danh yêu cầu tuyển dụng từ hệ thống nguồn |
| create_date | timestamptz | `hr_job.create_date` từ staging | Trực tiếp | Ngày giờ tạo yêu cầu |
| write_date | timestamptz | `hr_job.write_date` từ staging | Trực tiếp | Ngày giờ cập nhật gần nhất |
| code | varchar | `hr_job.code` từ staging | Trực tiếp + deduplication (thêm _1, _2, _3 nếu trùng) | Mã yêu cầu tuyển dụng (duy nhất) |
| name | varchar | `hr_job.name` từ staging | Trực tiếp | Tên yêu cầu tuyển dụng |
| req_status | varchar | `hr_job.state` từ staging | Map qua MAP_STATE: draft→DRAFT, in_progress→INPROCESS, waiting_rrm→WAITING_RRM, waiting_hrbp→WAITING_HRBP, waiting_dept→WAITING_DEPT, done→DONE, close→CLOSE, cancel→CANCEL | Trạng thái hiện tại của yêu cầu |
| company_info | jsonb | Lookup `hrm.hrtb_unit` | JSON: `{"id": id, "code": code, "name": name}` | Thông tin công ty yêu cầu |
| department_info | jsonb | Lookup `hrm.hrtb_unit` | JSON: `{"id": id, "code": code, "name": name}` | Thông tin phòng ban yêu cầu |
| department_id_new | numeric | Lookup `hrm.hrtb_unit.id` | Match by ref_id | ID phòng ban trong hệ thống mới |
| department_code | varchar | Lookup `hrm.hrtb_unit.code` | Match by ref_id | Mã phòng ban |
| hiring_manager_info | jsonb | Lookup `hrm.hrtb_employee` | JSON: `{id, code, name, email, domain_account}` | Thông tin quản lý tuyển dụng |
| hiring_manager_id | numeric | Lookup `hrm.hrtb_employee.id` | Match by report_to | ID quản lý tuyển dụng |
| hiring_manager_code | varchar | Lookup `hrm.hrtb_employee.code` | Match by report_to | Mã quản lý tuyển dụng |
| requestor_id_new | varchar | Lookup `hrm.hrtb_employee.email` | Match by ref_id | Email người yêu cầu tuyển dụng |
| handle_by_info | jsonb | Lookup `hrm.hrtb_employee` | JSON: `{id, code, name, email}` | Thông tin người xử lý yêu cầu |
| handle_by_id | numeric | Lookup `hrm.hrtb_employee.id` | Match by handle_by | ID người xử lý |
| handle_by_code | varchar | Lookup `hrm.hrtb_employee.code` | Match by handle_by | Mã người xử lý |
| handle_by_email | varchar | Lookup `hrm.hrtb_employee.email` | Match by handle_by | Email người xử lý |
| rrm_approve_id | varchar | Lookup `staging.res_users.email` | Match by rrm_approve | Email phê duyệt RRM |
| hrbp_approve_id | varchar | Lookup `staging.res_users.email` | Match by hrbp_approve | Email phê duyệt HRBP |
| dept_head_approve_id | varchar | Lookup `staging.res_users.email` | Match by dept_head_approve | Email phê duyệt Dept Head |
| rrm_approve_date | timestamptz | `hr_job.rrm_approve_date` | Cast date | Ngày phê duyệt RRM |
| is_specialerp | boolean | `hr_job.is_specialerp` | Cast boolean | Cờ đặc biệt ERP |
| is_critical | boolean | `hr_job.is_critical` | Cast boolean | Cờ yêu cầu critical (khẩn cấp) |
| none_official | boolean | `hr_job.none_official` | Cast boolean | Cờ không chính thức |
| gender | varchar | `hr_job.gender` | Upper case | Giới tính yêu cầu (MALE/FEMALE) |
| description_info | jsonb | `hr_job.description`, `description_en` | JSON: `{"vi": description, "en": description_en}` | Mô tả công việc (đa ngôn ngữ) |
| requirement_info | jsonb | `hr_job.requirements`, `requirement_en` | JSON: `{"vi": requirements, "en": requirement_en}` | Yêu cầu công việc (đa ngôn ngữ) |
| selling_point_info | jsonb | `hr_job.selling_point`, `selling_point_en` | JSON: `{"vi": selling_point, "en": selling_point_en}` | Điểm bán hàng (thu hút ứng viên) |
| workflow_id | uuid | Generated | `uuid.uuid4()` | ID workflow (duy nhất) |
| root_workflow_id | uuid | workflow_id | Copy từ workflow_id | ID workflow gốc |
| create_user_id | varchar | `hr_job.create_user` | Trực tiếp | User tạo yêu cầu |
| no_of_recruitment | numeric | `hr_job.no_of_recruitment` | FillNA -1 | Số lượng tuyển dụng |
| no_of_hired_recruitment | numeric | `hr_job.no_of_hired` | Trực tiếp | Số lượng đã tuyển |
| job_title_id_new | numeric | Lookup `hrm.tatm_title.id` | Match by ref_id | ID chức danh công việc |
| job_title_info | jsonb | Lookup `hrm.tatm_title` | JSON: `{id, code, name}` | Thông tin chức danh |
| job_path_id_new | numeric | Lookup `hrm.tatm_career_path.id` | Match by ref_id | ID lộ trình sự nghiệp |
| job_path_info | jsonb | Lookup `hrm.tatm_career_path` | JSON: `{id, code, name}` | Lộ trình sự nghiệp |
| job_family_id_new | numeric | Lookup `hrm.tatb_job.id` | Match (classification=FAMILY) | ID job family |
| job_family_info | jsonb | Lookup `hrm.tatb_job` | JSON: `{id, code, name}` | Job family |
| job_group_id_new | numeric | Lookup `hrm.tatb_job.id` | Match (classification=GROUP) | ID job group |
| job_group_info | jsonb | Lookup `hrm.tatb_job` | JSON: `{id, code, name}` | Job group |
| sub_group_id_new | numeric | Lookup `hrm.tatb_job.id` | Match (classification=SUBGROUP) | ID sub group |
| sub_group_info | jsonb | Lookup `hrm.tatb_job` | JSON: `{id, code, name}` | Job sub group |
| job_level_id_new | numeric | Lookup `hrm.tatm_level.id` | Match by ref_id | ID cấp bậc công việc |
| job_level_info | jsonb | Lookup `hrm.tatm_level` | JSON: `{id, code, name}` | Cấp bậc công việc |
| office_id_new | numeric | Lookup `hrm.hrtb_office.id` | Match by ref_id | ID văn phòng làm việc |
| office_info | jsonb | Lookup `hrm.hrtb_office` | JSON: `{id, code, name}` | Văn phòng làm việc |
| job_type_id_new | numeric | Lookup `hrm.tatm_type.id` | Match by ref_id | ID loại công việc |
| job_type_info | jsonb | Lookup `hrm.tatm_type` | JSON: `{id, code, name}` | Loại công việc |
| req_type_id_new | numeric | Lookup `recruit.rstm_req_type.id` | Match by ref_id | ID loại yêu cầu |
| qualification_id | numeric | Lookup `hrm.tatm_qualification.id` | Match (degree) | ID bằng cấp yêu cầu |
| qualification_info | jsonb | Lookup `hrm.tatm_qualification` | JSON: `{id, code, name}` | Bằng cấp yêu cầu |
| job_parent_id | numeric | Computed | Coalesce(family_id, group_id, sub_group_id) | ID cha (trong hierarchy công việc) |
| classification_id | numeric | Lookup `hrm.tatm_classification` | Match code='JOB' | ID phân loại |
| urgency_name | varchar | Lookup `staging.vhr_business_impact` | Format: Level X → LEVEL_X | Mức độ khẩn cấp |
| justification | varchar | Lookup `staging.job_reason` | Match by reason_id | Lý do tuyển dụng |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant quản lý |
| fts_string | text | Build từ nhiều fields | Concat: code, title, level, handle_by | Chuỗi tìm kiếm full-text |
| hired_by_rr | varchar | `hr_job.hired_by_rr` | Trực tiếp | Tuyển bởi RR |
| hired_by_dept | varchar | `hr_job.hired_by_dept` | Trực tiếp | Tuyển bởi Dept |
| internal_source | varchar | `hr_job.internal_source` | Trực tiếp | Nguồn nội bộ |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Mapping Trạng thái
Chuyển đổi state từ Odoo sang hệ thống mới:
- draft → DRAFT
- in_progress → INPROCESS
- waiting_rrm → WAITING_RRM
- waiting_hrbp → WAITING_HRBP
- waiting_dept → WAITING_DEPT
- done → DONE
- close → CLOSE
- cancel → CANCEL

### 2. Xử lý DRAFT
Requisition trạng thái DRAFT được tạo qua API thay vì insert trực tiếp

### 3. Full-text Search
Xây dựng chuỗi tìm kiếm từ code, job title, job level, handle_by email

### 4. Hierarchy Mapping
job_parent_id được tính từ priority: family → group → sub_group

### 5. Boolean Casting
Chuyển đổi true/false, yes/no, 1/0 sang 1/0 integer

### 6. JSON Construction
Tạo JSON objects cho các field info từ multiple columns

### 7. Deduplication
Xử lý trùng code bằng suffix _1, _2, _3

### 8. Retry Logic
Xử lý deadlock với 3 lần retry, delay 2 giây
