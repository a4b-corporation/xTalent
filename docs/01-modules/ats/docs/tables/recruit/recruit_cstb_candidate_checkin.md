# Data Dictionary - recruit.cstb_candidate_checkin

**Mô tả bảng:** Lưu thông tin check-in của ứng viên tham gia sự kiện

**Nguồn dữ liệu:** `staging.candidate_checkin`

**Scripts ETL:** `j_import_all_candidate_checkin.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | Mã định danh bản ghi check-in từ hệ thống nguồn |
| first_name | jsonb | `first_name` từ staging | JSON: `{"vi": value, "en": value}` | Tên của ứng viên (đa ngôn ngữ) |
| last_name | jsonb | `last_name` từ staging | JSON: `{"vi": value, "en": value}` | Họ của ứng viên (đa ngôn ngữ) |
| full_name | jsonb | `name` (kết hợp first_name + last_name) | JSON: `{"vi": value, "en": value}` | Tên đầy đủ của ứng viên (đa ngôn ngữ) |
| worker_id | numeric | Lookup `hrtb_worker` bằng email | Match personal_email | Mã worker liên kết với ứng viên |
| event_id | numeric | Lookup `pstb_event` | Match period_id → ref_id, filter program_id='CANDIDATE_CHECKIN' | Mã sự kiện check-in (chương trình candidate check-in) |
| participant_type_id | numeric | Lookup `pstm_participant_type` | Code='PPT001' (Participant type) | Mã loại người tham gia |
| birth_date | timestamptz | `birthday` từ staging | Trực tiếp | Ngày sinh của ứng viên |
| mobile_phone | varchar | `phone` từ staging | Trực tiếp | Số điện thoại liên hệ |
| email | varchar | `email` từ staging | Trực tiếp | Email liên hệ của ứng viên |
| school_id | numeric | Lookup `tatm_school` | Match school_name (VI) → ref_id | Mã trường học của ứng viên |
| gender_id | numeric | Lookup `tatm_gender` | Match bằng English name (upper case) | Mã giới tính |
| gender | jsonb | Lookup `tatm_gender` | JSON: `{"id": id, "code": code, "name": name}` | Thông tin giới tính chi tiết |
| student_code | varchar | `mssv` từ staging | Trực tiếp | Mã số sinh viên |
| form_data | jsonb | Build từ nhiều fields | JSON: `{"formData": {...}}` | Dữ liệu form đăng ký tham gia, bao gồm: school_id, school_name, program_event, student_code, time_graduation_id, recruitment_degree_id, actual_session, expected_session |
| checkin_date | timestamptz | `create_date` từ staging | Chỉ set khi `is_check_in='t'` | Thời điểm ứng viên check-in thực tế |
| send_email_date | timestamptz | `create_date` từ staging | Trực tiếp | Thời điểm gửi email xác nhận |
| fts_string_student | varchar | Build từ nhiều fields | Full-text search string | Chuỗi tìm kiếm sinh viên |
| fts_string_worker | varchar | Build từ nhiều fields | Full-text search string | Chuỗi tìm kiếm worker |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị quản lý |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Check-in Date Logic
```
if is_check_in = 't':
    checkin_date = create_date
else:
    checkin_date = NULL
```

### 2. Event Lookup
- Filter: `program_id = 'CANDIDATE_CHECKIN'`
- Match: period_id → ref_id
- Chỉ sự kiện thuộc chương trình candidate check-in

### 3. Worker Lookup
- Match qua personal_email
- Left join (có thể null nếu chưa có worker)

### 4. Form Data Structure
```json
{
  "formData": {
    "school_id": 123,
    "school_name": "...",
    "program_event": "...",
    "student_code": "...",
    "time_graduation_id": "...",
    "recruitment_degree_id": "...",
    "actual_session": "...",
    "expected_session": "..."
  }
}
```

### 5. Gender Matching
- Match bằng English name
- Upper case để chuẩn hóa

### 6. Full-text Search
- Tự động build 2 chuỗi tìm kiếm: student và worker
- Hỗ trợ tìm kiếm nhanh
