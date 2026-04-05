# Data Dictionary - recruit.rstb_assessment_screening

**Mô tả bảng:** Lưu thông tin đánh giá screening (vòng loại) ứng viên

**Nguồn dữ liệu:** `staging.vhr_interview_round_evaluation_upsert`

**Scripts ETL:** `j_import_all_interview_note.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| assessment_screening_id | numeric | Generated/lookup | Tự động tạo hoặc lookup | ID đánh giá screening |
| req_candidate_id | numeric | Từ staging | Trực tiếp | ID ứng viên cho requisition |
| screening_note | jsonb | Pivot từ staging | Wrap `<p>...</p>` → JSONB | Ghi chú screening |
| screening_result | varchar | Từ staging | Map status | Kết quả screening |
| record_status | varchar | Hằng số | 'O' | Trạng thái bản ghi |
| auth_status | varchar | Hằng số | 'A' | Trạng thái phê duyệt |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |

---

## Quy tắc nghiệp vụ

### 1. Screening vs Interview
- Screening: `interview_round_id IS NULL`
- Interview: `interview_round_id IS NOT NULL`

### 2. Note Pivot
Chuyển từ dạng dọc (evaluation_name, note) sang ngang (functional_note, non_functional_note, others_note)

### 3. JSON Wrapping
Notes được wrap trong `<p>...</p>` để lưu trữ dạng HTML
