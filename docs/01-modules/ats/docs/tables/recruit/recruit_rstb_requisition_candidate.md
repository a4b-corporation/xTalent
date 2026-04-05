# Data Dictionary - recruit.rstb_requisition_candidate

**Mô tả bảng:** Lưu thông tin ứng viên gắn với requisition

**Nguồn dữ liệu:** 
- `staging.candidate_matching`
- `staging.approval_history`
- `staging.job_applicant_history`
- `staging.stg_req_member_assignment`

**Scripts ETL:** `j_import_all_history_approval.py`, `j_import_update_member_assignment.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| requisition_id | numeric | Từ staging | Trực tiếp | ID yêu cầu tuyển dụng |
| candidate_id | numeric | Từ staging | Trực tiếp | ID ứng viên |
| applicant_id | numeric | Từ staging | Trực tiếp | ID applicant (hệ thống nguồn) |
| status | varchar | Từ mapping JSON | Map từ `old_state` + `current_row` | Trạng thái ứng viên trong requisition |
| stage | varchar | Từ mapping JSON | Map từ staging | Stage hiện tại của ứng viên |
| display_status | varchar | Từ mapping JSON | Map từ staging | Trạng thái hiển thị |
| task_key | varchar | Từ mapping JSON | Map từ staging | Khóa task hiện tại |
| offer_status | varchar | Từ mapping JSON | Map từ staging | Trạng thái offer |
| pre_status | varchar | Từ mapping JSON (S3) | `old_state` + `current_row` key | Trạng thái trước đó |
| pre_stage | varchar | Từ mapping JSON | Map từ staging | Stage trước đó |
| pre_display_status | varchar | Từ mapping JSON | Map từ staging | Trạng thái hiển thị trước đó |
| pre_task_key | varchar | Từ mapping JSON | Map từ staging | Khóa task trước đó |
| pre_offer_status | varchar | Từ mapping JSON | Map từ staging | Trạng thái offer trước đó |
| member_assignment_id | numeric | `staging.stg_req_member_assignment` | Trực tiếp | ID gán thành viên |
| create_date | timestamptz | Hệ thống | `now()` | Thời điểm tạo |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Status Mapping (từ S3 JSON)
File: `mapping_status/candidate_matching_status.json`

Key format: `"interview:current_row"` hoặc `"old_state"`

Ví dụ:
```json
{
  "interview:1": {
    "status": "INTERVIEWING",
    "stage": "INTERVIEW",
    "display_status": "Đang phỏng vấn",
    "task_key": "INT001",
    "offer_status": null
  }
}
```

### 2. Filter Close State
Chỉ xử lý records có `new_state = 'close'` trong approval history

### 3. Latest Record
Sort by `job_applicant_id, create_date DESC`, lấy record đầu tiên

### 4. Batch Processing
Xử lý 100 records/batch với ON CONFLICT DO UPDATE

### 5. Upsert Logic
```sql
INSERT INTO rstb_requisition_candidate (...)
VALUES (...)
ON CONFLICT (ref_id) DO UPDATE SET
  pre_status = EXCLUDED.pre_status,
  pre_stage = EXCLUDED.pre_stage,
  ...
```
