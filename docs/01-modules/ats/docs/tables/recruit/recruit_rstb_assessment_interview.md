# Data Dictionary - recruit.rstb_assessment_interview

**Mô tả bảng:** Lưu thông tin đánh giá phỏng vấn ứng viên

**Nguồn dữ liệu:** `staging.vhr_interview_round_evaluation_upsert`

**Scripts ETL:** `j_import_all_interview_note.py`, `j_import_all_interviewers.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| interview_id | numeric | Lookup từ `rstb_interview` | Match qua `req_candidate_id` + `interview_round_id` | ID buổi phỏng vấn |
| assessment_screening_id | numeric | Lookup từ `rstb_assessment_screening` | Match qua `req_candidate_id` | ID đánh giá screening (vòng loại) |
| interviewer_id | numeric | Lookup từ `hrtb_employee` | Match từ các bảng relation (dept_interviewer, rr_interviewer) | ID người phỏng vấn |
| interviewer_name | jsonb | `hrtb_employee.name` | JSONB | Tên người phỏng vấn (đa ngôn ngữ) |
| interviewer_email | varchar | `hrtb_employee.email` | Trực tiếp | Email người phỏng vấn |
| interviewer_info | jsonb | Build từ employee | JSON: `{id, code, name, email, jobTitle}` | Thông tin chi tiết người phỏng vấn |
| interviewer_role | varchar | Hardcode theo nguồn | FuncInterview - Phỏng vấn viên chức năng, DeptHead - Trưởng phòng, RRInCharge - Nhân sự tuyển dụng | Vai trò người phỏng vấn |
| functional_note | jsonb | Pivot từ `staging.vhr_interview_round_evaluation_upsert` | Filter `evaluation_name = "Functional"` → wrap `<p>...</p>` → JSONB | Ghi chú đánh giá chuyên môn |
| non_functional_note | jsonb | Pivot từ staging | Filter `evaluation_name = "6 Core Values"` + "Interest Job" → JSONB | Ghi chú đánh giá phi chuyên môn (core values, sở thích) |
| others_note | jsonb | Pivot từ staging | Filter `evaluation_name = "Concerns"` + "Behavior" → JSONB | Ghi chú khác (lo ngại, hành vi) |
| result_flg | numeric | `staging.stg_interview.interview_result` | Cast to numeric | Kết quả phỏng vấn (Đạt/Rớt) |
| keep_in_view_flg | numeric | `staging.stg_interview.keep_in_view` | Cast to numeric | Cờ lưu hồ sơ để xem xét sau |
| record_status | varchar | Hằng số | 'O' (Open/Active) | Trạng thái bản ghi |
| auth_status | varchar | Hằng số | 'A' (Approved) | Trạng thái phê duyệt |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo (hệ thống ETL) |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Phân loại Interview vs Screening
```
interview_round_id IS NULL → screening
interview_round_id IS NOT NULL → interview
```

### 2. Mapping Vòng Phỏng vấn
```
Round 1 (Odoo) → ROU001 (HRM)
Round 2 (Odoo) → ROU001 (HRM)
Round 3 (Odoo) → ROU002 (HRM)
```

### 3. Pivot Data
Chuyển từ dạng dọc sang ngang:
```
Source (dọc):
- evaluation_name: "Functional", note: "Good"
- evaluation_name: "Behavior", note: "Friendly"

Target (ngang):
- functional_note: {"value": "<p>Good</p>"}
- others_note: {"value": "<p>Friendly</p>"}
```

### 4. 3 Loại Interviewer
- **FuncInterview:** Phỏng vấn viên chức năng (từ dept_interviewer_rel)
- **DeptHead:** Trưởng phòng (từ dept_head_interviewer_rel)
- **RRInCharge:** Nhân sự tuyển dụng (từ employee_rr_interviewer_rel)

### 5. Make Decision Update
Cập nhật `functional_interviewer_id` và `functional_interviewer` (JSONB) vào `rstb_interview` cho interviewer đầu tiên của mỗi buổi

### 6. JSON Wrapping
Mỗi note được wrap trong `<p>...</p>` và convert sang JSONB
