# Data Dictionary - hrm.hrtb_wr_ex_employee

**Mô tả bảng:** Lưu thông tin nhân viên nghỉ việc (ex-employee) và working record

**Nguồn dữ liệu:** `staging.wr_ex_employee_daily/hourly/upsert`

**Scripts ETL:** `j_import_wr_ex_employee.py`, `j_get_api_to_staging_wr_ex_employee.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `wr_id` từ staging | Trực tiếp | ID working record từ hệ thống nguồn |
| sdomain_account | varchar | `domain_account` từ staging | Trực tiếp | Tài khoản domain |
| effective_date_wr | date | `effective_date_wr` từ staging | Trực tiếp | Ngày hiệu lực của working record |
| last_working_date | date | `last_working_date` từ staging | Trực tiếp | Ngày làm việc cuối cùng |
| change_type | varchar | `change_type` từ staging | Trực tiếp | Loại thay đổi (nghỉ việc, thuyên chuyển...) |
| leave_reason | varchar | `leave_reason` từ staging | Trực tiếp | Lý do nghỉ việc |
| recruiting_again_name | varchar | Query `recruiting_again` table | Map từ `recruiting_again` code | Có được tuyển lại không (tiếng Việt) |
| recruiting_again_name_en | varchar | Query `recruiting_again` table | Map từ `recruiting_again` code | Có được tuyển lại không (tiếng Anh) |
| leave_type_name | varchar | Query `vhr_resignation_type` | Map từ `leave_type` code | Loại nghỉ việc (tiếng Việt) |
| leave_type_name_en | varchar | Query `vhr_resignation_type` | Map từ `leave_type` code | Loại nghỉ việc (tiếng Anh) |
| job_title_id | numeric | `job_title_id` từ staging | Trực tiếp | ID chức danh công việc |
| department_id | numeric | `department_id` từ staging | Trực tiếp | ID phòng ban |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant quản lý |
| extra_info | jsonb | Build từ nhiều fields | JSON: `{"changeType": change_type, "recruitAgain": {"vi": ..., "en": ...}, "terminationType": {"vi": ..., "en": ...}, "reportTo": {...}}` | Thông tin mở rộng về nghỉ việc |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Lookup Resignation Type
```python
df = df.merge(
    vhr_resignation_type[['code', 'name', 'name_en']],
    left_on='leave_type',
    right_on='code',
    how='left'
)
```

### 2. Lookup Recruiting Again
```python
df = df.merge(
    recruiting_again[['code', 'name', 'name_en']],
    left_on='recruiting_again',
    right_on='code',
    how='left'
)
```

### 3. Report-To Lookup
```python
df = df.merge(
    hrtb_employee[['id', 'name', 'email', 'code']],
    left_on='report_to_id',
    right_on='id',
    how='left'
)
# Build JSON: {"id": id, "name": name, "email": email}
```

### 4. Extra Info JSON Construction
```python
extra_info = {
    "changeType": row['change_type'],
    "recruitAgain": {
        "vi": row['recruiting_again_name'],
        "en": row['recruiting_again_name_en']
    },
    "terminationType": {
        "vi": row['resignation_type_name'],
        "en": row['resignation_type_name_en']
    },
    "reportTo": json.loads(row['report_to_info'])
}
```

### 5. Stored Procedure Call
Dữ liệu được upsert qua stored procedure:
```sql
CALL hrm.hrfn_etl_wr_ex_employee_upsert(...)
```

### 6. Error Handling
Ghi lỗi ra S3:
```
s3://{bucket}/xhrm/Error-File/wr_ex_employee/error_{job_id}.csv
```

### 7. Workflow Type
- **DAILY:** `staging.wr_ex_employee_daily`
- **HOURLY:** `staging.wr_ex_employee_hourly`
- **ALL:** `staging.wr_ex_employee_upsert`
