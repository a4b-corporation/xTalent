# Data Dictionary - KPI.KSTB_GOAL_ASSIGNMENT

**Mô tả bảng:** Lưu phân công mục tiêu (goal assignment) trong hệ thống KPI

**Nguồn dữ liệu:** `staging.hr_job_share_handles`

**Scripts ETL:** `j_import_add_share_handles.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| goal_id | numeric | Lookup từ `stg_req_member_assignment` | Match bằng `hr_job_id = ref_id` | ID mục tiêu được assign |
| assigned_empid | numeric | Lookup `hrtb_employee` | Match bằng `ref_id` | ID nhân viên được assign mục tiêu |
| target_value | numeric | Lookup từ `stg_req_member_assignment` | Trực tiếp | Giá trị mục tiêu |
| priority | numeric | Computed | Row number + 2 (partition by hr_job_id) | Độ ưu tiên (số thứ tự) |
| record_status | char | Hằng số | `'O'` (Open/Active) | Trạng thái bản ghi |
| auth_status | char | Hằng số | `'A'` (Approved) | Trạng thái phê duyệt |
| maker_id | varchar | Lookup từ `stg_req_member_assignment` | `requestor_id` | ID người tạo |
| maker_date | timestamptz | Lookup từ `stg_req_member_assignment` | `approval_date` | Ngày tạo |
| create_date | timestamptz | Lookup từ `stg_req_member_assignment` | `approval_date` | Ngày tạo bản ghi |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| update_id | varchar | Lookup từ `stg_req_member_assignment` | `requestor_id` | ID người cập nhật |
| update_date | timestamptz | Lookup từ `stg_req_member_assignment` | `approval_date` | Ngày cập nhật |
| mod_no | integer | Increment | `mod_no + 1` khi update | Số lần chỉnh sửa |

---

## Quy tắc nghiệp vụ quan trọng

### 1. UPSERT CTE Pattern
```sql
WITH cte_upsert AS (
  UPDATE KPI.KSTB_GOAL_ASSIGNMENT target
  SET target_value = src.target_value,
      priority = src.priority,
      update_date = src.update_date,
      mod_no = mod_no + 1
  FROM staging hr_job_share_handles src
  WHERE target.GOAL_ID = src.goal_id 
    AND target.ASSIGNED_EMPID = src.employee_id
  RETURNING 1
)
INSERT INTO KPI.KSTB_GOAL_ASSIGNMENT (...)
SELECT ...
WHERE NOT EXISTS (SELECT 1 FROM cte_upsert)
```

### 2. Priority Calculation
```python
df['priority'] = df.groupby('hr_job_id').cumcount() + 2
```

### 3. Data Validation
Chỉ insert records có:
- `goal_id IS NOT NULL`
- `assigned_empid IS NOT NULL`

### 4. Batch Processing
```python
execute_batch(cur, sql, values, page_size=100)
conn.commit()
```

### 5. Share Handles Purpose
- Phân chia mục tiêu (goal) cho nhiều nhân viên
- Mỗi goal có thể được assign cho nhiều người
- Priority xác định thứ tự quan trọng
