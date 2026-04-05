# Data Dictionary - hrm.hrtb_employee

**Mô tả bảng:** Lưu thông tin nhân viên chính thức trong hệ thống HRM

**Nguồn dữ liệu:** `staging.employee_staging_upsert`

**Scripts ETL:** `j_import_all_employee.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| employee_id | numeric | `employee_id` từ staging | Trực tiếp | Mã định danh nhân viên từ hệ thống nguồn |
| emp_code | varchar | `emp_code` từ staging | Trực tiếp | Mã nhân viên (mã ngắn) |
| full_name_info | jsonb | `full_name` từ staging | JSON: `{"vi": full_name, "en": full_name}` | Tên đầy đủ của nhân viên (đa ngôn ngữ) |
| first_name_info | jsonb | `first_name` từ staging | JSON: `{"vi": first_name, "en": first_name}` | Tên của nhân viên (đa ngôn ngữ) |
| last_name_info | jsonb | `last_name` từ staging | JSON: `{"vi": last_name, "en": last_name}` | Họ của nhân viên (đa ngôn ngữ) |
| dob | date | `dob` từ staging | Trực tiếp | Ngày sinh của nhân viên |
| country_id | numeric | Query `res_country` | Map từ country_code | Mã quốc tịch của nhân viên |
| full_mobile | varchar | `full_mobile` từ staging | Trực tiếp | Số điện thoại đầy đủ (bao gồm mã vùng) |
| personal_email | varchar | `personal_email` từ staging | Concat: `employee_id + personal_email` | Email cá nhân của nhân viên |
| worker_status | varchar | `active` từ staging | Map: `ACTIVE` nếu active=True, else `INACTIVE` | Trạng thái worker (đang làm việc/nghỉ) |
| gender_id | numeric | Query `dim_gender` | Map từ gender_code | Mã giới tính |
| gender_info | jsonb | `gender` từ staging | JSON từ dim_gender | Thông tin giới tính chi tiết |
| worker_type_id | numeric | Query `hrm.hrfn_get_worker_type_id` | Từ worker_type_code | Loại worker (chính thức, thử việc, CTV...) |
| job_type_id | numeric | Query `hrm.hrfn_get_job_type_id` | Từ job_type_code | Loại công việc (toàn thời gian, bán thời gian...) |
| job_title | varchar | `job_title` từ staging | Trực tiếp | Chức danh công việc |
| job_parent_id | numeric | null | NULL | ID công việc cha (trong hierarchy) |
| job_classification_id | numeric | Function `findClassificationId` | Từ classification_code | Mã phân loại công việc |
| unit_id | numeric | Query `hrm.hrfn_get_unit_id` | Map từ department_code | Mã đơn vị/phòng ban làm việc |
| department_name | varchar | `department_name` từ staging | Trực tiếp | Tên phòng ban |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant quản lý |
| company_id | numeric | Query `hrtb_unit` (type=CO) | Map từ company_code | Mã công ty chủ quản |
| working_email | varchar | `working_email` từ staging | Trực tiếp | Email công việc |
| employee_status | varchar | `active` từ staging | Map: `EMPLOYEE` nếu active=True, else `OPENING` | Trạng thái nhân viên |
| last_working_date | timestamp | `last_working_date` từ staging | Trực tiếp | Ngày làm việc cuối cùng |
| domain_account | varchar | `domain_account` từ staging | Trực tiếp | Tài khoản domain |
| join_date | timestamp | `join_date` từ staging | Trực tiếp | Ngày vào làm việc |
| contract_name | varchar | `contract_type` từ staging | Trực tiếp | Tên loại hợp đồng |
| contract_type_id | numeric | Query `hrtm_probationary_type` | Map từ ref_code | Mã loại hợp đồng (chính thức, thử việc...) |
| office_type_id | numeric | Query `hrtb_unit` | Map từ office_code | Mã loại văn phòng |
| tax_code | varchar | Query `hrtb_unit` | Từ tax_code công ty | Mã thuế |
| location_id | numeric | Query `pltb_location` | Map từ office_type_id | Mã địa điểm làm việc |
| sub_group_id | numeric | Query `hrtb_unit` (type=SG) | Map từ sub_group_code | Mã nhóm con |
| team_id | numeric | Query `hrtb_unit` (type=TM) | Map từ team_code | Mã team |
| market_id | numeric | Query `hrtb_unit` (type=MKT) | Map từ market_code | Mã thị trường |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Transform Worker
- Build JSON cho tên (first_name, last_name, full_name)
- Map gender từ code
- Map worker_type từ code
- Map country từ country_code

### 2. Transform Employee
- Map department từ department_code
- Map company từ company_code
- Map location từ office_type_id
- Map job classification từ classification_code

### 3. Transform Line Manager
- Cập nhật thông tin quản lý trực tiếp từ `hrtb_employee`
- Lookup manager_id từ report_to

### 4. Auto Create User HRM
- Tạo user HRM tự động cho nhân viên active
- Call API `createNewUserForEmp`

### 5. Error Handling
- Ghi log lỗi ra S3 bucket
- Continue processing khi gặp lỗi individual records

### 6. Stored Procedure
- Dữ liệu được insert/update qua stored procedure `hrm.hrfn_etl_upsert_employee`
- Stored procedure xử lý upsert logic
