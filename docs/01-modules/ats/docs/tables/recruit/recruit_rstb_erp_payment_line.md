# Data Dictionary - recruit.rstb_erp_payment_line

**Mô tả bảng:** Lưu chi tiết thanh toán ERP bonus (payment line items)

**Nguồn dữ liệu:** `staging.vhr_erp_bonus_payment_line_upsert`

**Scripts ETL:** `j_import_all_erp_payment_line.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID tham chiếu dòng thanh toán |
| payment_id | numeric | Lookup `rstb_erp_payment` | Match bằng ref_id | ID yêu cầu thanh toán cha |
| employee_id | numeric | Lookup `hrtb_employee` | Match bằng ref_id | ID nhân viên |
| employee_info | jsonb | Build từ employee | JSON: `{id, code, name, email}` | Thông tin nhân viên |
| amount | numeric | `amount` từ staging | Trực tiếp | Số tiền dòng thanh toán |
| currency_id | numeric | Lookup `res_currency` | Match bằng ref_id | ID loại tiền tệ |
| currency_info | jsonb | Lookup `res_currency` | JSON: `{id, code, name}` | Thông tin tiền tệ |
| note | varchar | `note` từ staging | Trực tiếp | Ghi chú dòng thanh toán |
| status | varchar | `state` từ staging | Map state | Trạng thái dòng thanh toán |
| paid_date | date | `paid_date` từ staging | Parse date | Ngày thanh toán |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.vhrfn_etl_upsert_erp_bonus_payment_line(...)
```

### 2. Parent Lookup
```python
df = df.merge(
    rstb_erp_payment[['ref_id', 'id']],
    left_on='payment_id',
    right_on='ref_id',
    how='left'
)
df['payment_id_new'] = df['id']
```

### 3. Master-Detail
- Một payment có nhiều payment_line
- Link qua `payment_id`
