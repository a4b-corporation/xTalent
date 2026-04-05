# Data Dictionary - hrm.hrtb_etl_key_student

**Mô tả bảng:** Lưu thông tin sinh viên chủ chốt (key student)

**Nguồn dữ liệu:** `staging.key_student`

**Scripts ETL:** `j_import_all_program_event.py`, `j_import_key_student.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID sinh viên từ nguồn |
| student_code | varchar | `student_code` từ staging | Trực tiếp | Mã số sinh viên |
| full_name | jsonb | `first_name`, `last_name` từ staging | JSON: `{vi, en}` | Tên đầy đủ |
| email | varchar | `email` từ staging | Trực tiếp | Email sinh viên |
| mobile | varchar | `mobile` từ staging | Trực tiếp | Số điện thoại |
| school_id | numeric | Lookup `tatm_school` | Match bằng ref_id | ID trường học |
| school_info | jsonb | Lookup `tatm_school` | JSON: `{id, code, name}` | Thông tin trường |
| faculty_id | numeric | Lookup `tatm_faculty` | Match bằng ref_id | ID khoa học |
| majoring_id | numeric | Lookup `tatm_majoring` | Match bằng ref_id | ID chuyên ngành |
| graduation_year | integer | `graduation_year` từ staging | Cast integer | Năm tốt nghiệp |
| gpa | numeric | `gpa` từ staging | Trực tiếp | Điểm trung bình |
| gender_id | numeric | Lookup `tatm_gender` | Match bằng name | ID giới tính |
| gender_info | jsonb | Lookup `tatm_gender` | JSON: `{id, code, name}` | Thông tin giới tính |
| dob | date | `birthday` từ staging | Parse date | Ngày sinh |
| channel_id | numeric | Lookup `rstm_channel` | Match bằng ref_id | ID kênh tuyển dụng |
| channel_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin kênh |
| is_spin | boolean | `is_spin` từ staging | Cast boolean | Cờ SPIN |
| referrer_email | varchar | `referrer_email` từ staging | Trực tiếp | Email người giới thiệu |
| note | varchar | `note` từ staging | Trực tiếp | Ghi chú |
| status | varchar | `state` từ staging | Map state | Trạng thái sinh viên |
| program_id | numeric | Lookup `pstb_program` | Match bằng ref_id | ID chương trình |
| program_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin chương trình |
| event_id | numeric | Lookup `pstb_event` | Match bằng ref_id | ID sự kiện |
| registration_date | timestamptz | `registration_date` từ staging | Trực tiếp | Ngày đăng ký |
| confirmation_date | timestamptz | `confirmation_date` từ staging | Trực tiếp | Ngày xác nhận |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Two Scripts
Cả 2 scripts đều import vào cùng 1 table:
- `j_import_all_program_event.py`
- `j_import_key_student.py`

### 2. Lookup Pattern
```python
df = df.merge(
    tatm_school[['school_name', 'ref_id', 'code']],
    left_on='school_name',
    right_on='school_name',
    how='left'
)
```

### 3. Boolean Casting
```python
df['is_spin'] = df['is_spin'].astype(str).str.lower().isin(['true', 't', '1', 'yes']).astype(int)
```
