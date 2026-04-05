# Data Dictionary - recruit.rstb_survey_result

**Mô tả bảng:** Lưu kết quả khảo sát tuyển dụng

**Nguồn dữ liệu:** `staging.vhr_recruitment_temp_survey_upsert`

**Scripts ETL:** `j_import_all_survey_result.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID kết quả khảo sát |
| candidate_id | numeric | Lookup `hrtb_candidate` | Match bằng ref_id | ID ứng viên |
| requisition_id | numeric | Lookup `rstb_requisition` | Match bằng ref_id | ID yêu cầu tuyển dụng |
| survey_type | varchar | `survey_type` từ staging | Trực tiếp | Loại khảo sát |
| survey_date | timestamptz | `survey_date` từ staging | Parse datetime | Ngày khảo sát |
| surveyor_id | numeric | Lookup `hrtb_employee` | Match bằng ref_id | ID người khảo sát |
| surveyor_info | jsonb | Build từ employee | JSON: `{id, code, name, email}` | Thông tin người khảo sát |
| total_score | numeric | `total_score` từ staging | Trực tiếp | Tổng điểm khảo sát |
| max_score | numeric | `max_score` từ staging | Trực tiếp | Điểm tối đa |
| percentage | numeric | Computed | `(total_score / max_score) * 100` | Tỷ lệ phần trăm |
| result | varchar | `result` từ staging | Map (pass, fail, pending) | Kết quả khảo sát |
| note | varchar | `note` từ staging | Trực tiếp | Ghi chú |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.rsfn_etl_upsert_survey_result(...)
```

### 2. Result Mapping
```python
MAP_RESULT = {
    'pass': 'PASS',
    'fail': 'FAIL',
    'pending': 'PENDING'
}
```

### 3. Percentage Calculation
```python
df['percentage'] = (df['total_score'] / df['max_score']) * 100
```
