# Data Dictionary - hrm.hrtb_worker

**Mô tả bảng:** Bảng chính lưu thông tin worker/candidate trong hệ thống HRM

**Nguồn dữ liệu:** `staging.hr_applicant`

**Scripts ETL:** `j_import_all_candidate.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging.hr_applicant | Trực tiếp | Mã định danh ứng viên từ hệ thống nguồn |
| create_date | timestamptz | `create_date` từ staging | Trực tiếp | Ngày giờ tạo hồ sơ ứng viên |
| write_date | timestamptz | `write_date` từ staging | Trực tiếp | Ngày giờ cập nhật hồ sơ gần nhất |
| last_name | varchar | `last_name` từ staging | Trực tiếp | Họ của ứng viên |
| first_name | varchar | `first_name` từ staging | Trực tiếp | Tên của ứng viên |
| fullname | varchar | `name` từ staging | Trực tiếp | Tên đầy đủ của ứng viên |
| email | varchar | `email` từ staging | Generate + dedup: `ca{id}{email}` (non-PROD), thêm suffix `_1`, `_2`... nếu trùng | Email liên hệ của ứng viên, được sinh tự động để tránh trùng lặp |
| mobile | varchar | `mobile` + `isd_code` từ staging | Kết hợp: `+{isd_code} {mobile}` | Số điện thoại liên hệ với mã vùng quốc tế |
| source_type_id | numeric | Lookup từ `vhr_recruitment_source_type` | Map 3 lớp qua bảng mapping | Loại nguồn tuyển dụng (website, referral, agency) |
| source_id | numeric | Lookup từ `hr_recruitment_source` | Map 3 lớp qua bảng mapping | Nguồn tuyển dụng cụ thể |
| auto_mail_flg | numeric | `auto_send_email` từ staging | Boolean cast (true=1, false=0) | Cờ cho phép gửi email tự động cho ứng viên |
| apply_date | timestamptz | `apply_date` từ staging | Trực tiếp | Ngày ứng viên nộp hồ sơ |
| fresher_flg | numeric | `is_fresher` từ staging | Boolean cast | Cờ đánh dấu ứng viên là fresher (ít kinh nghiệm) |
| fresh_graduate_flg | numeric | `fresh_graduate` từ staging | Boolean cast | Cờ đánh dấu sinh viên mới tốt nghiệp |
| staff_movement_flg | numeric | `is_staff_movement` từ staging | Boolean cast | Cờ đánh dấu luân chuyển nội bộ |
| ex_employee_flg | numeric | `ex_employee` từ staging | Boolean cast | Cờ đánh dấu cựu nhân viên |
| ex_account | jsonb | `employee_json_new` từ staging | JSON từ bảng hrtb_employee | Thông tin tài khoản nhân viên cũ (nếu có) |
| never_recruit_flg | numeric | `never_recruit` từ staging | Boolean cast | Cờ đánh dấu ứng viên không bao giờ được tuyển |
| current_salary | numeric | `current_salary` từ staging | Trực tiếp | Mức lương hiện tại của ứng viên |
| expected_salary | numeric | `expected_salary` từ staging | Trực tiếp | Mức lương mong muốn của ứng viên |
| total_income | numeric | `total_income` từ staging | Trực tiếp | Tổng thu nhập hàng năm |
| benefit | jsonb | `benefits` từ staging | Wrap: `{"benefit": value}` | Các phúc lợi ứng viên nhận được |
| status | varchar | `state` từ staging | Chuyển sang chữ HOA | Trạng thái hiện tại của ứng viên |
| description | varchar | `description` từ staging | Trực tiếp | Ghi chú về ứng viên |
| source_info | jsonb | Build từ bảng mapping | JSON: `{"id": id, "name": name, "code": code}` | Thông tin chi tiết về nguồn tuyển dụng |
| source_type_info | jsonb | Build từ bảng mapping | JSON: `{"id": id, "name": name, "code": code}` | Thông tin chi tiết về loại nguồn tuyển dụng |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị/tổ chức quản lý ứng viên |
| fts_string_candidate | varchar | Build từ nhiều fields | Chuỗi tìm kiếm full-text | Chuỗi dùng để tìm kiếm ứng viên nhanh |
| fts_string_worker | varchar | Build từ name, email, mobile | Chuỗi tìm kiếm full-text | Chuỗi tìm kiếm worker |
| fts_string_doc | varchar | Build từ document fields | Chuỗi tìm kiếm full-text | Chuỗi tìm kiếm giấy tờ tùy thân |
| legaldoc_type_id | numeric | Lookup `hrtm_legaldoc_type` | Match bằng ref_id | Loại giấy tờ pháp lý (CMND/CCCD/Hộ chiếu) |
| identity_no | varchar | `identity_id` từ staging | Trực tiếp | Số CCCD/CMND của ứng viên |
| issue_date | date | `issue_date` từ staging | Trực tiếp | Ngày cấp giấy tờ tùy thân |
| issue_place | jsonb | Lookup `pltm_issuing_authorities` | JSON: `{"id": id, "name": name, "code": code}` | Nơi cấp giấy tờ |
| issue_place_id | numeric | Lookup `pltm_issuing_authorities` | Match bằng ref_id | Mã nơi cấp giấy tờ |
| talent_flg | numeric | `is_talent` từ staging | Boolean cast | Cờ đánh dấu nhân tài |
| potential_flg | numeric | `is_potential` từ staging | Boolean cast | Cờ đánh dấu ứng viên tiềm năng |
| porfolio_link | varchar | `porfolio_link` từ staging | Trực tiếp | Link portfolio của ứng viên |
| student_code | varchar | `student_code` từ staging | Trực tiếp | Mã sinh viên (nếu là sinh viên) |
| gender | jsonb | Lookup `tatm_gender` | JSON từ table | Giới tính của ứng viên |
| dob | date | `birthday` từ staging | Parse date | Ngày sinh của ứng viên |
| pob_id | numeric | Coalesce từ ward_id_new, district_id_new, city_id_new | Ưu tiên ward → district → city | Mã nơi sinh (tỉnh/thành phố) |
| nation_id | numeric | Lookup `pltm_country` | Match country_id → ref_id | Mã quốc tịch |
| marital_status_id | numeric | Lookup `hrtm_marital_status` | Match bằng code (upper) | Tình trạng hôn nhân |
| gender_id | numeric | Lookup `tatm_gender` | Match bằng name (upper) | Mã giới tính |
| nationality_id | numeric | Lookup `hrtm_nationality` | Match nationality_id → ref_id | Mã quốc tịch chi tiết |
| worker_id | numeric | Lookup `hrtb_worker` bằng personal_email | Left join email | ID worker liên kết (nếu có) |
| street | varchar | `street` từ staging | Fill NaN = 'N/A' | Địa chỉ đường phố |

---

## Quy tắc nghiệp vụ quan trọng

1. **Email deduplication:** Trong môi trường non-PROD, email được thêm suffix để tránh trùng
2. **Mobile combine:** Ghép mã quốc tế + số điện thoại
3. **POB ID:** Ưu tiên ward → district → city khi xác định nơi sinh
4. **Boolean casting:** true/false/yes/no/1/0 đều được chuẩn hóa thành 1/0
5. **Full-text search:** Tự động build các chuỗi tìm kiếm cho candidate, worker, document
