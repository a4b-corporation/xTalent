# Data Dictionary - hrm.hrtb_worker_record

**Mô tả bảng:** Lưu quá trình làm việc/kinh nghiệm làm việc của worker

**Nguồn dữ liệu:** `staging.vhr_working_background`

**Scripts ETL:** `j_import_all_candidate_working_background.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| worker_id | numeric | Lookup từ `hrtb_candidate` | Merge applicant_id → ref_id | Mã worker sở hữu quá trình làm việc |
| company_name | jsonb | `company` từ staging | JSON: `{"vi": value, "en": value}`, fill "MASKED" nếu null | Tên công ty (tiếng Việt và Anh) |
| job_title_id | numeric | null | Hardcoded null | Mã chức danh công việc (chưa map) |
| job_title | jsonb | `job_title` từ staging | JSON: `{"vi": value, "en": value}` | Chức danh công việc |
| working_date | date | `from_date` từ staging | Parse date, default '1970-01-01' nếu null | Ngày bắt đầu làm việc |
| off_work_date | date | `to_date` từ staging | Parse date, default '1900-01-01' nếu null | Ngày nghỉ việc/kết thúc công việc |
| current_flg | numeric | `is_current` từ staging | Boolean cast (true=1, false=0) | Cờ đánh dấu công việc hiện tại |
| job_type_id | numeric | Lookup từ `tatm_type` | Match job_type_id → ref_id | Mã loại công việc (full-time, part-time...) |
| oversea_id | numeric | Lookup từ `pltm_country` | Match overseas → ref_id | Mã quốc gia làm việc nước ngoài (nếu có) |
| oversea | jsonb | Lookup từ `pltm_country` | JSON: `{"id": id, "code": code, "name": name}` | Thông tin quốc gia làm việc nước ngoài |
| industry_id | numeric | Lookup từ `tatm_industry` | Match industry_id → ref_id | Mã ngành nghề của công ty |
| industry | jsonb | Lookup từ `tatm_industry` | JSON: `{"id": id, "code": code, "name": name}` | Thông tin ngành nghề công ty |
| relevant_company_flg | numeric | `relevant` từ staging | Boolean cast | Cờ đánh dấu công ty có liên quan (cùng hệ thống) |
| description | varchar | `note` từ staging | Trực tiếp | Mô tả chi tiết về quá trình làm việc |
| record_status | varchar | Hằng số | 'O' (Open/Active) | Trạng thái bản ghi |
| auth_status | varchar | Hằng số | 'A' (Approved) | Trạng thái phê duyệt |
| maker_id | varchar | Hằng số | 'system_etl_upsert' | Người tạo bản ghi (hệ thống ETL) |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| create_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| update_id | varchar | Hằng số | 'system_etl_upsert' | Người cập nhật gần nhất |
| update_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm cập nhật gần nhất |
| mod_no | integer | Hằng số | 0 (tăng dần khi update) | Số lần chỉnh sửa bản ghi |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị quản lý |

---

## Quy tắc nghiệp vụ quan trọng

### 1. ON CONFLICT Logic
- **Key:** (company_name, worker_id, job_title_id, tenant_code)
- **UPDATE** tất cả fields khi conflict xảy ra
- Đảm bảo không trùng lặp khi chạy lại ETL

### 2. Default Date Handling
```
from_date null → '1970-01-01'
to_date null → '1900-01-01'
```

### 3. Company Name Masking
- Fill "MASKED" cho company name bị null
- Đảm bảo trường company_name không bao giờ null

### 4. Filter Logic
Chỉ load records có:
- `worker_id_new` NOT NULL (đã tìm được worker)

### 5. JSON Format
- company_name, job_title, oversea, industry đều lưu dạng JSON
- Hỗ trợ đa ngôn ngữ (vi, en)
