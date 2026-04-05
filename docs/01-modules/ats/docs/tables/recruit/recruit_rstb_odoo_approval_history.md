# Data Dictionary - recruit.rstb_odoo_approval_history

**Mô tả bảng:** Lưu lịch sử phê duyệt từ Odoo

**Nguồn dữ liệu:** 
- `staging.approval_history`
- `staging.job_applicant_history`

**Scripts ETL:** `j_import_all_history_approval.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| job_ref_id | numeric | `approval_history.job_id` từ staging | Trực tiếp | ID job tham chiếu |
| job_applicant_ref_id | numeric | `job_applicant_history.job_applicant_id` từ staging | Trực tiếp | ID applicant tham chiếu |
| create_date | timestamptz | `create_date` từ staging | Cast timestamptz | Ngày giờ thay đổi trạng thái |
| login | varchar | `login` từ staging | Trực tiếp | User đăng nhập (người phê duyệt) |
| old_state | varchar | `old_state` từ staging | Trực tiếp | Trạng thái cũ |
| new_state | varchar | `new_state` từ staging | Trực tiếp | Trạng thái mới |
| comment | varchar | `comment` từ staging | Trực tiếp | Bình luận của người phê duyệt |
| ref_id | numeric | `approval_history.id` hoặc `job_applicant_history.id` | Trực tiếp | ID lịch sử từ nguồn |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Latest Record Selection
```python
# Sort và lấy record đầu tiên
df = df.sort_values(['job_applicant_id', 'create_date'], ascending=[True, False])
df = df.drop_duplicates(subset=['job_applicant_id'], keep='first')
```

### 2. Filter Close State
Chỉ xử lý records có:
```python
df = df[df['new_state'] == 'close']
```

### 3. Status Mapping từ S3
File: `mapping_status/candidate_matching_status.json`

```python
# Đọc mapping từ S3
mapping = read_s3_json('mapping_status/candidate_matching_status.json')

# Apply mapping
def apply_mapping(row):
    key = f"{row['old_state']}:{row['current_row']}"
    if key in mapping:
        return mapping[key]
    return None

df['pre_status'] = df.apply(apply_mapping, axis=1)
```

### 4. Batch Upsert
```python
# ON CONFLICT DO UPDATE
INSERT INTO rstb_odoo_approval_history (...)
VALUES (...)
ON CONFLICT (ref_id) DO UPDATE SET
  create_date = EXCLUDED.create_date,
  login = EXCLUDED.login,
  ...
```

### 5. Two Target Tables
Script này update 2 tables:
1. `rstb_odoo_approval_history` - Lịch sử job
2. `rstb_odoo_job_approval_history` - Lịch sử applicant
3. `rstb_requisition_candidate` - Update pre_status

### 6. S3 Mapping Structure
```json
{
  "draft:0": {
    "status": "DRAFT",
    "stage": "INITIAL",
    "display_status": "Bản nháp",
    "task_key": "DFT001",
    "offer_status": null
  },
  "interview:1": {
    "status": "INTERVIEWING",
    "stage": "INTERVIEW",
    "display_status": "Đang phỏng vấn",
    "task_key": "INT001",
    "offer_status": null
  }
}
```
