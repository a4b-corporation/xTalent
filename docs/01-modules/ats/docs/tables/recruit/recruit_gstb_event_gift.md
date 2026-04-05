# Data Dictionary - recruit.gstb_event_gift

**Mô tả bảng:** Lưu thông tin quà tặng sự kiện

**Nguồn dữ liệu:** `staging.vhr_program_event_gift_upsert`

**Scripts ETL:** `j_import_all_event_gift.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID quà tặng từ nguồn |
| event_id | numeric | Lookup `pstb_event` | Match bằng ref_id | ID sự kiện |
| gift_name | jsonb | `name` từ staging | JSON: `{vi, en}` | Tên quà tặng |
| gift_code | varchar | `code` từ staging | Trực tiếp | Mã quà tặng |
| description | jsonb | `description` từ staging | JSON: `{vi, en}` | Mô tả quà tặng |
| quantity | numeric | `quantity` từ staging | Trực tiếp | Số lượng |
| unit_price | numeric | `unit_price` từ staging | Trực tiếp | Đơn giá |
| total_amount | numeric | Computed | `quantity * unit_price` | Tổng thành tiền |
| currency_id | numeric | Lookup `res_currency` | Match bằng ref_id | ID loại tiền tệ |
| currency_info | jsonb | Lookup `res_currency` | JSON: `{id, code, name}` | Thông tin tiền tệ |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.psfn_etl_upsert_event_gift(...)
```

### 2. Total Amount Calculation
```python
df['total_amount'] = df['quantity'] * df['unit_price']
```

### 3. Event Lookup
```python
df = df.merge(
    pstb_event[['ref_id', 'id']],
    left_on='event_id',
    right_on='ref_id',
    how='left'
)
```
