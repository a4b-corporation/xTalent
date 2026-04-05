# Data Dictionary - recruit.rstb_erp_payment

**Mô tả bảng:** Lưu thông tin thanh toán ERP bonus (chi trả thưởng qua ERP)

**Nguồn dữ liệu:** `staging.vhr_erp_bonus_payment_upsert`

**Scripts ETL:** `j_import_all_erp_payment.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID tham chiếu thanh toán từ hệ thống nguồn |
| create_date | timestamptz | `create_date` từ staging | Trực tiếp | Ngày giờ tạo yêu cầu thanh toán |
| write_date | timestamptz | `write_date` từ staging | Trực tiếp | Ngày giờ cập nhật gần nhất |
| payment_code | varchar | `code` từ staging | Trực tiếp | Mã yêu cầu thanh toán |
| payment_name | varchar | `name` từ staging | Trực tiếp | Tên yêu cầu thanh toán |
| employee_id | numeric | Lookup `hrtb_employee` | Match bằng ref_id | ID nhân viên nhận thanh toán |
| employee_info | jsonb | Build từ employee | JSON: `{id, code, name, email}` | Thông tin nhân viên |
| payment_time_id | numeric | Lookup `vhr_erp_payment_time` | Match bằng ref_id | ID thời điểm thanh toán |
| payment_time_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin thời điểm thanh toán |
| bonus_scheme_id | numeric | Lookup `vhr_erp_bonus_scheme` | Match bằng ref_id | ID scheme bonus |
| bonus_scheme_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin scheme bonus |
| amount | numeric | `amount` từ staging | Trực tiếp | Số tiền thanh toán |
| currency_id | numeric | Lookup `res_currency` | Match bằng ref_id | ID loại tiền tệ |
| currency_info | jsonb | Lookup `res_currency` | JSON: `{id, code, name}` | Thông tin tiền tệ (VND, USD...) |
| status | varchar | `state` từ staging | Map state (draft, confirmed, paid, cancelled) | Trạng thái thanh toán |
| paid_date | date | `paid_date` từ staging | Parse date | Ngày thực tế thanh toán |
| note | varchar | `note` từ staging | Trực tiếp | Ghi chú thanh toán |
| is_special | boolean | `is_special` từ staging | Cast boolean | Cờ thanh toán đặc biệt |
| special_reason | varchar | `special_reason` từ staging | Trực tiếp | Lý do đặc biệt (nếu có) |
| approval_date | timestamptz | `approval_date` từ staging | Trực tiếp | Ngày phê duyệt |
| approver_id | varchar | Lookup `res_users` | Match bằng user id | Email người phê duyệt |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã tenant quản lý |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo (hệ thống ETL) |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Function Call
Dữ liệu được xử lý qua stored function:
```sql
SELECT staging.vhrfn_etl_upsert_erp_bonus_payment(...)
```

### 2. Status Mapping
```python
MAP_STATE = {
    'draft': 'DRAFT',
    'confirmed': 'CONFIRMED',
    'paid': 'PAID',
    'cancelled': 'CANCELLED'
}
```

### 3. Employee Lookup
```python
df = df.merge(
    hrtb_employee[['ref_id', 'id', 'code', 'name', 'email']],
    left_on='employee_id',
    right_on='ref_id',
    how='left'
)
```

### 4. Amount Validation
- Amount > 0
- Currency không null

### 5. Batch Processing
Xử lý 100 records/batch

### 6. Error Logging
Ghi lỗi ra S3 bucket
