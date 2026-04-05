# recruit.rstb_requisition_offer

## Mục đích
Lưu trữ thông tin đề nghị tuyển dụng (offer) cho ứng viên đã pass qua các vòng phỏng vấn, bao gồm các thông tin về vị trí, lương, phúc lợi và các điều khoản tuyển dụng.

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| req_candidate_id | numeric | `staging.candidate_matching.id` | Trực tiếp | ID của ứng viên trong requisition (liên kết với rstb_requisition_candidate) |
| line_manager_id | numeric | `hrm.hrtb_employee.id` | Lookup từ employee qua ref_id | ID của Line Manager trực tiếp quản lý nhân viên mới |
| report_to | jsonb | `hrm.hrtb_employee` | `jsonb_build_object('id', id, 'code', code, 'name', name, 'email', email)` | Thông tin JSON về người quản lý trực tiếp |
| mentor_id | numeric | `hrm.hrtb_employee.id` | Lookup từ employee qua ref_id | ID của Mentor/Counselor hỗ trợ nhân viên mới (có thể NULL) |
| mentor | jsonb | `hrm.hrtb_employee` | `jsonb_build_object` | Thông tin JSON về Mentor |
| department_id | numeric | `hrm.hrtb_department.id` | Lookup từ department | ID của Department/Phòng ban |
| department | jsonb | `hrm.hrtb_department` | `jsonb_build_object` | Thông tin JSON về Department |
| team_id | numeric | `hrm.tatm_team.id` | Lookup từ team | ID của Team/Đội nhóm |
| team | jsonb | `hrm.tatm_team` | `jsonb_build_object` | Thông tin JSON về Team |
| market_id | numeric | `hrm.hrtb_market.id` | Lookup từ market | ID của Market/Thị trường |
| market | jsonb | `hrm.hrtb_market` | `jsonb_build_object` | Thông tin JSON về Market |
| working_for | jsonb | `hrm.hrtb_unit` hoặc `hrm.hrtb_market` | `jsonb_build_object` | Thông tin JSON về đơn vị công tác (Working For) |
| job_type_id | numeric | `hrm.tatm_job_type.id` | Lookup từ job_type | ID của Job Type/Loại công việc |
| job_type | jsonb | `hrm.tatm_job_type` | `jsonb_build_object` | Thông tin JSON về Job Type |
| offer_date | date | `staging.candidate_matching.offer_date` | Cast sang date | Ngày đề nghị tuyển dụng (Offer Date) |
| job_title_id | numeric | `hrm.tatm_title.id` | Lookup từ title | ID của Job Title/Chức danh (Part of unique constraint) |
| title_offer | jsonb | `hrm.tatm_title` | `jsonb_build_object` | Thông tin JSON về Job Title Offer |
| career_path_id | numeric | `hrm.tatm_career_track.id` | Lookup từ career_track | ID của Career Path/Lộ trình nghề nghiệp |
| carrer_path_offer | jsonb | `hrm.tatm_career_track` | `jsonb_build_object` | Thông tin JSON về Career Path Offer |
| job_family_id | numeric | `hrm.tatm_job_family.id` | Lookup từ job_family | ID của Job Family/Nhóm nghề |
| job_family_offer | jsonb | `hrm.tatm_job_family` | `jsonb_build_object` | Thông tin JSON về Job Family Offer |
| job_group_id | numeric | `hrm.tatm_job_group.id` | Lookup từ job_group | ID của Job Group/Nhóm công việc |
| job_group_offer | jsonb | `hrm.tatm_job_group` | `jsonb_build_object` | Thông tin JSON về Job Group Offer |
| job_subgroup_id | numeric | `hrm.tatm_sub_group.id` | Lookup từ sub_group | ID của Job Sub-Group/Nhóm công việc con |
| job_subgroup_offer | jsonb | `hrm.tatm_sub_group` | `jsonb_build_object` | Thông tin JSON về Job Sub-Group Offer |
| job_level_id | numeric | `hrm.tatm_job_level.id` | Lookup từ job_level | ID của Job Level/Cấp bậc công việc |
| job_level_offer | jsonb | `hrm.tatm_job_level` | `jsonb_build_object` | Thông tin JSON về Job Level Offer |
| probationary_type_id | numeric | `hrm.tatm_probation_type.id` | Lookup từ probation_type | ID của Probationary Type/Loại thử việc |
| probationary_type | jsonb | `hrm.tatm_probation_type` | `jsonb_build_object` | Thông tin JSON về Probationary Type |
| start_date | date | `staging.candidate_matching.start_date` | Cast sang date | Ngày bắt đầu làm việc (Start Date/Onboard Date) |
| salary | numeric | `staging.candidate_matching.salary` | Cast sang numeric | Lương chính thức sau thử việc (gross salary) |
| probation_salary | numeric | `staging.candidate_matching.probation_salary` | Cast sang numeric | Lương trong thời gian thử việc |
| currency_id | numeric | `hrm.tatm_currency.id` | Lookup từ currency | ID của Currency/Đơn vị tiền tệ |
| currency | jsonb | `hrm.tatm_currency` | `jsonb_build_object` | Thông tin JSON về Currency |
| ex_employee | varchar | `staging.candidate_matching.ex_employee` | Giữ nguyên | Flag xác định ứng viên là nhân viên cũ (Ex-Employee) |
| create_account_flg | numeric | `staging.candidate_matching.create_account_flg` | Cast sang numeric (0/1) | Flag tạo tài khoản hệ thống (1 = tạo, 0 = không) |
| asset_flg | numeric | `staging.candidate_matching.asset_flg` | Cast sang numeric (0/1) | Flag cấp phát tài sản (1 = cấp, 0 = không) |
| noted_for_cnb | jsonb | `staging.candidate_matching.noted_for_cnb` | Cast sang jsonb | Note cho CNB (Campus & Brand) |
| noted_for_ifnaf | jsonb | `staging.candidate_matching.noted_for_ifnaf` | Cast sang jsonb | Note cho IFNAF (Internal Finance & Admin) |
| exception_account_flg | numeric | `staging.candidate_matching.exception_account_flg` | Cast sang numeric (0/1) | Flag exception cho account creation |
| direct_erp | numeric | `staging.candidate_matching.direct_erp` | Cast sang numeric (0/1) | Flag đẩy trực tiếp vào ERP (1 = push, 0 = manual) |
| probation_start_date | date | `staging.candidate_matching.probation_start_date` | Cast sang date | Ngày bắt đầu thử việc |
| probation_end_date | date | `staging.candidate_matching.probation_end_date` | Cast sang date | Ngày kết thúc thử việc |
| employee_type_id | numeric | `hrm.tatm_employee_type.id` | Lookup từ employee_type | ID của Employee Type/Loại nhân viên |
| employee_type | jsonb | `hrm.tatm_employee_type` | `jsonb_build_object` | Thông tin JSON về Employee Type |
| record_status | varchar | Default | Set default 'O' | Trạng thái record: 'O' = Active, 'C' = Closed |
| auth_status | varchar | Default | Set default 'A' | Trạng thái approval: 'A' = Approved |
| maker_id | varchar | Default | Set default 'system_etl_upsert' | ID người tạo record (hệ thống ETL) |
| maker_date | timestamptz | `staging.candidate_matching.write_date` | Cast sang timestamptz | Ngày tạo record từ nguồn |
| create_date | timestamptz | `now() at time zone 'ICT'` | Current timestamp ICT | Timestamp khi insert vào HRM |
| update_date | timestamptz | `staging.candidate_matching.create_date` | Cast sang timestamptz | Ngày cập nhật record từ nguồn |
| update_id | varchar | Default | Set default 'system_etl_upsert' | ID người cập nhật record |
| tenant_code | varchar | `Parameter.P_TENANT_CODE` | Set từ parameter | Mã tenant/company (multi-tenant) |
| location_id | numeric | `hrm.tatm_location.id` | Lookup từ location | ID của Location/Địa điểm làm việc |
| working_place | jsonb | `hrm.tatm_location` | `jsonb_build_object` | Thông tin JSON về Working Place |
| group_company_id | numeric | `hrm.hrtb_group_company.id` | Lookup từ group_company | ID của Group Company |
| group_company | jsonb | `hrm.hrtb_group_company` | `jsonb_build_object` | Thông tin JSON về Group Company |
| f2p_bonus_flg | numeric | `staging.candidate_matching.f2p_bonus_flg` | Cast sang numeric (0/1) | Flag F2P Bonus (Fresher to Professional) |
| c2p_bonus_flg | numeric | `staging.candidate_matching.c2p_bonus_flg` | Cast sang numeric (0/1) | Flag C2P Bonus (Campus to Professional) |

## Quy tắc nghiệp vụ quan trọng

### Unique Constraint
```sql
UNIQUE (req_candidate_id, job_title_id)
```
Mỗi ứng viên chỉ có một offer cho mỗi job title.

### ON CONFLICT Action
Khi có conflict, thực hiện UPDATE toàn bộ fields và tăng `mod_no = mod_no + 1`.

### Logic nghiệp vụ
1. **Offer Letter**: Thông tin offer được tạo khi ứng viên đã pass phỏng vấn
2. **Lương thử việc**: Thường = salary * tỷ lệ thử việc (85%)
3. **Probation Period**: probation_end_date = start_date + probation_period (thường 2 tháng)
4. **Bonus Programs**:
   - F2P (Fresher to Professional): Dành cho fresher mới ra trường
   - C2P (Campus to Professional): Dành cho sinh viên từ campus hiring
5. **Direct ERP**: Flag xác định offer có được đẩy thẳng vào ERP không
6. **Account & Asset**: Flags để tự động tạo tài khoản và cấp phát tài sản

### Lookup Tables
| Field | Lookup Table |
|-------|--------------|
| line_manager_id, mentor_id | hrm.hrtb_employee |
| department_id | hrm.hrtb_department |
| team_id | hrm.tatm_team |
| market_id | hrm.hrtb_market |
| job_type_id | hrm.tatm_job_type |
| job_title_id | hrm.tatm_title |
| career_path_id | hrm.tatm_career_track |
| job_family_id | hrm.tatm_job_family |
| job_group_id | hrm.tatm_job_group |
| job_subgroup_id | hrm.tatm_sub_group |
| job_level_id | hrm.tatm_job_level |
| probationary_type_id | hrm.tatm_probation_type |
| employee_type_id | hrm.tatm_employee_type |
| currency_id | hrm.tatm_currency |
| location_id | hrm.tatm_location |
| group_company_id | hrm.hrtb_group_company |

## Script ETL
- **File:** `scripts_uat/j_import_all_matching_candidate.py`
- **Hàm:** `insert_offer()` (line 1524-1755)
- **Staging Source:** `staging.candidate_matching`

## Upsert Pattern
```sql
ON CONFLICT (req_candidate_id, job_title_id) 
DO UPDATE SET
    line_manager_id = EXCLUDED.line_manager_id,
    report_to = EXCLUDED.report_to,
    mentor_id = EXCLUDED.mentor_id,
    ... (tất cả fields),
    mod_no = recruit.rstb_requisition_offer.mod_no + 1
```
