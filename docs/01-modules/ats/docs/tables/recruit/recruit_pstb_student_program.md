# Data Dictionary - recruit.pstb_student_program

**Mô tả bảng:** Lưu thông tin sinh viên tham gia chương trình

**Nguồn dữ liệu:** `staging.student_program_upsert`

**Scripts ETL:** `j_import_all_student_program.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID tham chiếu từ nguồn |
| create_date | timestamptz | `create_date` từ staging | Trực tiếp | Ngày giờ tạo |
| write_date | timestamptz | `write_date` từ staging | Trực tiếp | Ngày giờ cập nhật |
| student_code | varchar | `student_code` từ staging | Trực tiếp | Mã số sinh viên |
| full_name | jsonb | `first_name`, `last_name` từ staging | JSON: `{vi, en}` | Tên đầy đủ sinh viên |
| email | varchar | `email` từ staging | Trực tiếp | Email sinh viên |
| mobile | varchar | `mobile` từ staging | Trực tiếp | Số điện thoại |
| school_id | numeric | Lookup `tatm_school` | Match bằng ref_id | ID trường học |
| school_info | jsonb | Lookup `tatm_school` | JSON: `{id, code, name}` | Thông tin trường |
| program_id | numeric | Lookup `pstb_program` | Match bằng ref_id | ID chương trình |
| program_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin chương trình |
| event_id | numeric | Lookup `pstb_event` | Match bằng ref_id | ID sự kiện |
| status | varchar | `state` từ staging | Map state (registered, confirmed, cancelled, completed) | Trạng thái tham gia |
| registration_date | timestamptz | `registration_date` từ staging | Trực tiếp | Ngày đăng ký |
| confirmation_date | timestamptz | `confirmation_date` từ staging | Trực tiếp | Ngày xác nhận |
| gender_id | numeric | Lookup `tatm_gender` | Match bằng name/code | ID giới tính |
| gender_info | jsonb | Lookup `tatm_gender` | JSON: `{id, code, name}` | Thông tin giới tính |
| dob | date | `birthday` từ staging | Parse date | Ngày sinh |
| faculty_id | numeric | Lookup `tatm_faculty` | Match bằng ref_id | ID khoa học |
| majoring_id | numeric | Lookup `tatm_majoring` | Match bằng ref_id | ID chuyên ngành |
| graduation_year | integer | `graduation_year` từ staging | Cast integer | Năm tốt nghiệp dự kiến |
| gpa | numeric | `gpa` từ staging | Trực tiếp | Điểm trung bình tích lũy |
| channel_id | numeric | Lookup `rstm_channel` | Match bằng ref_id | ID kênh tuyển dụng |
| channel_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin kênh tuyển dụng |
| note | varchar | `note` từ staging | Trực tiếp | Ghi chú về sinh viên |
| is_spin | boolean | `is_spin` từ staging | Cast boolean | Cờ SPIN (chương trình đặc biệt) |
| referrer_email | varchar | `referrer_email` từ staging | Trực tiếp | Email người giới thiệu |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.psfn_etl_upsert_student_program(...)
```

### 2. Status Mapping
```python
MAP_STATE = {
    'registered': 'REGISTERED',
    'confirmed': 'CONFIRMED',
    'cancelled': 'CANCELLED',
    'completed': 'COMPLETED'
}
```

### 3. School Lookup
```python
df = df.merge(
    tatm_school[['school_name', 'ref_id', 'code']],
    left_on='school_name',
    right_on='school_name',
    how='left'
)
```

### 4. Gender Match
Match bằng English name (upper case) từ `tatm_gender`
