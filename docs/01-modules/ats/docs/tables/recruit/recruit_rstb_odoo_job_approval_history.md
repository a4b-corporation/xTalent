# recruit.rstb_odoo_job_approval_history

## Mục đích
Lưu trữ lịch sử phê duyệt applicant (ứng viên) từ hệ thống Odoo, bao gồm các thay đổi trạng thái, người phê duyệt, và nhận xét trong quá trình duyệt đơn xin việc.

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| id | numeric | `recruit.rssq_odoo_job_approval_history` | `nextval('recruit.rssq_odoo_job_approval_history')` | ID tự tăng (sequence) cho mỗi record lịch sử |
| job_applicant_ref_id | numeric | `staging.job_applicant_history.job_applicant_id` | Trực tiếp | ID tham chiếu của ứng viên từ Odoo (link到 staging) |
| create_date | timestamptz | `staging.job_applicant_history.create_date` | Cast sang timestamptz | Ngày tạo record lịch sử từ Odoo |
| login | varchar | `staging.job_applicant_history.login` | Trực tiếp | Đăng nhập của người thực hiện approval (username) |
| old_state | varchar | `staging.job_applicant_history.old_state` | Trực tiếp | Trạng thái cũ trước khi thay đổi |
| new_state | varchar | `staging.job_applicant_history.new_state` | Trực tiếp | Trạng thái mới sau khi thay đổi |
| comment | varchar | `staging.job_applicant_history.comment` | Trực tiếp | Nhận xét/bình luận của người phê duyệt |
| ref_id | numeric | `staging.job_applicant_history.id` | Trực tiếp | ID tham chiếu từ bảng staging (dùng cho upsert) |
| tenant_code | varchar | `Parameter.P_TENANT_CODE` | Set từ parameter | Mã tenant/company (multi-tenant) |

## Quy tắc nghiệp vụ quan trọng

### Unique Constraint
```sql
UNIQUE (ref_id)
```
Mỗi record lịch sử từ Odoo chỉ được lưu một lần trong HRM.

### ON CONFLICT Action
Khi có conflict (duplicate ref_id), thực hiện UPDATE:
```sql
ON CONFLICT (ref_id) DO UPDATE SET
    job_applicant_ref_id = EXCLUDED.job_applicant_ref_id,
    create_date = EXCLUDED.create_date,
    login = EXCLUDED.login,
    old_state = EXCLUDED.old_state,
    new_state = EXCLUDED.new_state,
    comment = EXCLUDED.comment
```

### States thường gặp
| State | Mô tả |
|-------|-------|
| draft | Ứng viên mới tạo, chưa submit |
| applied | Ứng viên đã apply |
| screening | Đang sàng lọc hồ sơ |
| interview | Đang phỏng vấn |
| approved | Đã phê duyệt |
| reject | Từ chối |
| close | Đóng hồ sơ |

### Logic nghiệp vụ
1. **Approval Trail**: Lưu vết toàn bộ quá trình phê duyệt applicant
2. **State Transition**: Theo dõi chuyển trạng thái từ old_state → new_state
3. **Comment Log**: Ghi nhận nhận xét của người phê duyệt tại mỗi bước
4. **Audit**: Cung cấp audit trail cho compliance và debugging
5. **Sync Odoo → HRM**: Dữ liệu được đồng bộ từ Odoo sang HRM qua staging table

### Batch Processing
Script xử lý theo batch 100 records:
```python
WITH batch AS (
    SELECT ... FROM staging.job_applicant_history
    OFFSET {offset} LIMIT 100
)
INSERT INTO recruit.rstb_odoo_job_approval_history ...
```

## Script ETL
- **File:** `scripts_uat/j_import_all_history_approval.py`
- **Hàm:** `insert_candidate_approval_history()` (line 388-439)
- **Staging Source:** `staging.job_applicant_history`

## Related Tables
| Table | Mối quan hệ |
|-------|-------------|
| recruit.rstb_requisition_candidate | job_applicant_ref_id link đến applicant |
| recruit.rstb_odoo_approval_history | Approval history cho requisition (không phải applicant) |
| staging.job_applicant_history | Source data từ Odoo |

## Data Flow
```
Odoo API → staging.job_applicant_history → recruit.rstb_odoo_job_approval_history
```

## Upsert Pattern
```sql
INSERT INTO recruit.rstb_odoo_job_approval_history (
    job_applicant_ref_id, create_date, login, old_state, new_state, comment, ref_id
)
SELECT ... FROM batch
ON CONFLICT (ref_id) DO UPDATE SET
    job_applicant_ref_id = EXCLUDED.job_applicant_ref_id,
    create_date = EXCLUDED.create_date,
    login = EXCLUDED.login,
    old_state = EXCLUDED.old_state,
    new_state = EXCLUDED.new_state,
    comment = EXCLUDED.comment
```
