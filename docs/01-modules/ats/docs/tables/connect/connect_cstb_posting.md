# Data Dictionary - connect.cstb_posting

**Mô tả bảng:** Lưu thông tin tin đăng tuyển dụng (job posting)

**Nguồn dữ liệu:** `staging.hr_job_post_job_mapping_upsert`

**Scripts ETL:** `j_import_all_posting_job.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `post_job_id` từ staging | Trực tiếp | Mã định danh tin đăng từ hệ thống nguồn |
| code | varchar | `posting_code` từ staging | Trực tiếp | Mã tin tuyển dụng (duy nhất) |
| name | varchar | `posting_name` (từ `job_title->>'name'`) | Trực tiếp | Tên tin tuyển dụng |
| posting_refno | varchar | `posting_refno` từ staging | Trực tiếp | Số tham chiếu tin đăng |
| job_title | jsonb | Từ `rstb_requisition_job.job_title` | JSONB object | Chức danh công việc tuyển dụng |
| job_category | jsonb | `job_family` từ staging | JSONB | Nhóm nghề (job family) |
| job_group | jsonb | `job_group` từ staging | JSONB | Nhóm công việc |
| start_date | date | `maker_date` từ requisition | Trực tiếp | Ngày bắt đầu tin đăng |
| job_type | jsonb | Từ lookup | JSONB | Loại công việc |
| description | jsonb | Từ requisition | JSONB từ multi-language fields | Mô tả công việc (đa ngôn ngữ) |
| requirement | jsonb | Từ requisition | JSONB từ multi-language fields | Yêu cầu công việc (đa ngôn ngữ) |
| special_note | jsonb | Từ requisition | JSONB từ multi-language fields | Ghi chú đặc biệt |
| selling_point | jsonb | Từ requisition | JSONB từ multi-language fields | Điểm bán hàng (thu hút ứng viên) |
| status | varchar | `hr_job.state` từ requisition | Map: `DONE`, `CLOSE`, `CANCEL` → `"DONE"`, khác → `"PENDING"` | Trạng thái tin đăng |
| city | jsonb | Build từ `hrm.hrtb_office`, `hrm.pltm_locality` | JSON array: `[{id, code, name, countryId, countryCode}]` | Danh sách thành phố/địa điểm làm việc |
| hashtag | jsonb | Aggregate từ `rstb_requisition_skill` | JSON array của `skill_list` | Danh sách kỹ năng (hashtag) |
| fts_string | varchar | Build từ tất cả JSON fields | Concat text từ code, refno, và tất cả JSON fields | Chuỗi tìm kiếm full-text |
| mod_no | integer | Increment | `mod_no + 1` khi update | Số lần chỉnh sửa |
| update_date | timestamptz | Hệ thống | `now()` khi update | Thời điểm cập nhật |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant quản lý |

---

## Quy tắc nghiệp vụ quan trọng

### 1. MERGE Logic
```sql
MERGE INTO connect.cstb_posting t
USING source s
ON t.code + t.tenant_code = s.code + s.tenant_code
WHEN MATCHED THEN 
  UPDATE SET ..., mod_no = mod_no + 1, update_date = now()
WHEN NOT MATCHED THEN 
  INSERT (...) VALUES (...);
```

### 2. JSON Conversion
Tất cả fields dạng multi-language được convert từ dict → JSON string:
- description: `{"vi": "...", "en": "..."}`
- requirement: `{"vi": "...", "en": "..."}`
- selling_point: `{"vi": "...", "en": "..."}`

### 3. City Info
Tạo từ `jsonb_build_object` với cấu trúc:
```json
{
  "id": 123,
  "code": "HCM",
  "name": "Hồ Chí Minh",
  "countryId": 1,
  "countryCode": "VN"
}
```

### 4. Skill Aggregation
```sql
SELECT requisition_id, 
       jsonb_agg(jsonb_build_object('id', skill_id, 'code', code, 'name', name)) as skill_list
FROM rstb_requisition_skill
GROUP BY requisition_id
```

### 5. Full-text Search
```python
fts_string = concat(
    code, ' ',
    posting_refno, ' ',
    job_title->>'name', ' ',
    job_family->>'name', ' ',
    ...
).lower().strip()
```

### 6. Status Mapping
```python
if state in ['DONE', 'CLOSE', 'CANCEL']:
    status = 'DONE'
else:
    status = 'PENDING'
```
