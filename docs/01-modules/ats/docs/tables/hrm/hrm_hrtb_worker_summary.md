# Data Dictionary - hrm.hrtb_worker_summary

**Mô tả bảng:** Bảng tổng hợp thông tin worker (note, job track, skill)

**Nguồn dữ liệu:** 
- `staging.vhr_note` (cho note)
- `staging.hr_applicant_job_track_upsert` (cho job track)
- `staging.hr_applicant_skills_upsert` (cho skill)

**Scripts ETL:** 
- `j_import_all_candidate_note.py` (SUTP001 - Note)
- `j_import_all_candidate_job_track.py` (SUTP005 - Job Track)
- `j_import_all_candidate_skill.py` (SUTP004 - Skill)

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| worker_id | numeric | Lookup từ `hrtb_candidate` qua ref_id | Merge applicant_id → ref_id | Mã định danh worker trong hệ thống |
| summary_type_id | numeric | Lookup từ `hrtm_summary_type` | Match theo code: `SUTP001` (Note), `SUTP004` (Skill), `SUTP005` (Job Track) | Loại tổng hợp thông tin |
| description | varchar | `message` từ staging.vhr_note | Trực tiếp | Nội dung ghi chú về worker (chỉ có cho Note) |
| job_track_id | numeric | Lookup từ `tatb_job` | Match ref_id, filter classification_id='TRACK' | Mã quá trình công việc/công việc đã làm (chỉ có cho Job Track) |
| job_track | jsonb | Build từ job_track_id, code, name | `json_build_object('id', id, 'code', code, 'name', name)` | Thông tin chi tiết về công việc (JSON) |
| skill_id | numeric | Lookup từ `tatm_skill` | Map 3 bước: skill_name → skill_mapping → tatm_skill | Mã kỹ năng của worker (chỉ có cho Skill) |
| skill | jsonb | Build từ skill_id, code, name | `json_build_object('id', id, 'code', code, 'name', name)` | Thông tin kỹ năng (JSON) |
| record_status | varchar | Hằng số | 'O' (Open/Active) | Trạng thái bản ghi |
| auth_status | varchar | Hằng số | 'A' (Approved) | Trạng thái phê duyệt |
| maker_id | varchar | Hằng số | 'system_etl' hoặc 'system_etl_upsert' | Người tạo bản ghi (hệ thống ETL) |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| create_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị/tổ chức |
| update_id | varchar | Hằng số | 'system_etl_upsert' | Người cập nhật gần nhất |
| update_date | timestamptz | Hệ thống hoặc từ source | `now() at time zone 'ICT'` hoặc từ write_date/create_date | Thời điểm cập nhật gần nhất |
| mod_no | integer | Hằng số | 0 (tăng dần khi update) | Số lần chỉnh sửa bản ghi |
| ref_id | numeric | `id` từ staging hoặc null | Trực tiếp hoặc hardcoded null | Mã tham chiếu từ hệ thống nguồn |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Upsert Logic (Note)
- **Key:** (worker_id, summary_type_id, ref_id)
- **UPDATE** nếu tồn tại key
- **INSERT** nếu chưa tồn tại

### 2. On Conflict Logic (Job Track, Skill)
- **Key:** (worker_id, job_track_id/skill_id, tenant_code)
- **UPDATE** tất cả fields + increment mod_no khi conflict

### 3. Skill Mapping (3 bước)
```
hr_applicant_category 
  → skill_mapping (skill_name_old → skill)
  → tatm_skill (taxonomy lookup)
```

### 4. Skill Aggregation
- Group by worker_id
- Deduplicate skills
- Build JSON array
- UPDATE vào `hrtb_candidate.skill_list`

### 5. Filter Logic
- Chỉ load records có worker_id not null
- Job track: filter classification_id='TRACK'
