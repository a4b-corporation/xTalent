# Data Dictionary - recruit.qstb_event_question

**Mô tả bảng:** Lưu câu hỏi sự kiện (khảo sát, quiz)

**Nguồn dữ liệu:** `staging.vhr_program_question_upsert`

**Scripts ETL:** `j_import_all_event_question.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID câu hỏi từ nguồn |
| event_id | numeric | Lookup `pstb_event` | Match bằng ref_id | ID sự kiện |
| question_text | jsonb | `question` từ staging | JSON: `{vi, en}` | Nội dung câu hỏi |
| question_type_id | numeric | Lookup `question_type` | Match bằng ref_id | ID loại câu hỏi |
| question_type_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin loại câu hỏi |
| question_part_id | numeric | Lookup `question_part` | Match bằng ref_id | ID phần câu hỏi (section) |
| display_order | integer | `display_order` từ staging | Cast integer | Thứ tự hiển thị |
| is_required | boolean | `is_required` từ staging | Cast boolean | Cờ bắt buộc trả lời |
| options | jsonb | `options` từ staging | JSON array: `[{value, label, is_correct}]` | Lựa chọn trả lời |
| correct_answer | varchar | `correct_answer` từ staging | Trực tiếp | Đáp án đúng (nếu là quiz) |
| points | numeric | `points` từ staging | Trực tiếp | Số điểm (nếu là quiz) |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.psfn_etl_upsert_event_question(...)
```

### 2. Question Types
```
- MULTIPLE_CHOICE: Trắc nghiệm
- TRUE_FALSE: Đúng/Sai
- SHORT_ANSWER: Trả lời ngắn
- ESSAY: Tự luận
```

### 3. Options Format
```json
[
  {"value": "A", "label": "Đáp án A", "is_correct": true},
  {"value": "B", "label": "Đáp án B", "is_correct": false}
]
```
