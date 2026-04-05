# Data Dictionary - hrm.hrtb_worker_qualification

**Mô tả bảng:** Lưu thông tin trình độ học vấn, chứng chỉ của worker

**Nguồn dữ liệu:** `staging.vhr_certificate_info`

**Scripts ETL:** `j_import_all_candidate_certificate_info.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| worker_id | numeric | Lookup từ `hrtb_candidate` | Merge applicant_id → ref_id → worker_id | Mã worker liên kết với chứng chỉ/bằng cấp |
| qualification_type_id | numeric | Lookup từ `tatm_qualification_type` | Match code: `CER` (Certificate), `DEG` (Degree) | Loại trình độ (chứng chỉ hay bằng cấp) |
| main_flg | numeric | `is_main_degree` từ staging | Boolean cast (true=1, false=0) | Cờ đánh dấu bằng chính (bằng cao nhất/chính) |
| school_id | numeric | Lookup từ `tatm_school` | Match school_id → ref_id | Mã trường học/cơ sở đào tạo |
| faculty_id | numeric | Lookup từ `tatm_faculty` | Match faculty_id → ref_id | Mã khoa đào tạo |
| majoring_id | numeric | Lookup từ `tatm_majoring` | Match speciality_id → ref_id | Mã chuyên ngành học |
| oversea_id | numeric | Lookup từ `pltm_country` | Match overseas → ref_id | Mã quốc gia đào tạo nước ngoài (nếu có) |
| qualification_id | numeric | Lookup từ `tatm_qualification` | Match recruitment_degree_id + qualification_type_id | Mã trình độ (liên kết với taxonomy) |
| school_year_start | integer | `school_year_from` từ staging | Cast sang integer | Năm bắt đầu khóa học |
| school_year_end | integer | `school_year_to` hoặc `school_year_end` từ staging | Cast sang integer | Năm kết thúc khóa học |
| school_note | varchar | null | Hardcoded null | Ghi chú về trường học (chưa sử dụng) |
| qualification_rate_id | numeric | Lookup từ `tatm_qualification_rate` | Match certificate_rating_id → ref_id | Mã xếp loại học lực (Giỏi/Khá/Trung bình...) |
| gpa | numeric | `gpa` từ staging | Trực tiếp | Điểm trung bình (GPA) của khóa học |
| issue_date | date | `issue_date` từ staging | Parse date | Ngày cấp bằng/chứng chỉ |
| received_hardcopy_flg | numeric | `is_received_hard_copy` từ staging | Boolean cast | Cờ đã nhận bản cứng bằng/chứng chỉ |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'utc'` | Thời điểm tạo bản ghi (UTC) |
| update_date | timestamptz | Hệ thống | `now() at time zone 'utc'` | Thời điểm cập nhật gần nhất (UTC) |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị quản lý |
| ref_id | numeric | `id` từ staging | Trực tiếp | Mã tham chiếu từ hệ thống nguồn |

---

## Quy tắc nghiệp vụ quan trọng

### 1. MERGE Statement
- **UPDATE** khi tồn tại ref_id trong target table
- **INSERT** khi chưa tồn tại ref_id
- Đảm bảo không trùng lặp dữ liệu khi chạy lại ETL

### 2. Filter Logic
Chỉ load records thỏa mãn:
- `qualification_id_new` NOT NULL (đã map được trình độ)
- `worker_id_new` NOT NULL (đã tìm được worker)

### 3. Qualification Type Mapping
```
certificate → CER (chứng chỉ)
degree → DEG (bằng cấp)
```

### 4. Date Handling
- maker_date/update_date dùng UTC timezone
- issue_date parse từ source data

### 5. Three Scripts Update Worker Summary
Cùng với bảng này, 3 scripts khác cũng update `hrm.hrtb_worker_summary`:
- j_import_all_candidate_job_track
- j_import_all_candidate_note
- j_import_all_candidate_skill
