# Data Dictionary - recruit.pstb_event_field

**Mô tả bảng:** Lưu các trường thông tin sự kiện (field registration)

**Nguồn dữ liệu:** `staging.event_field`

**Scripts ETL:** `j_import_all_event_field.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID trường từ nguồn |
| event_id | numeric | Lookup `pstb_event` | Match bằng ref_id | ID sự kiện cha |
| field_name | jsonb | `name` từ staging | JSON: `{vi, en}` | Tên trường thông tin |
| field_code | varchar | `code` từ staging | Trực tiếp | Mã trường (dùng cho form) |
| field_type | varchar | `type` từ staging | Map (text, textarea, select, radio, checkbox, date) | Loại trường input |
| is_required | boolean | `is_required` từ staging | Cast boolean | Cờ bắt buộc nhập |
| options | jsonb | `options` từ staging | JSON array: `[{value, label}]` | Danh sách lựa chọn (cho select/radio/checkbox) |
| default_value | varchar | `default_value` từ staging | Trực tiếp | Giá trị mặc định |
| placeholder | jsonb | `placeholder` từ staging | JSON: `{vi, en}` | Text hướng dẫn nhập |
| display_order | integer | `display_order` từ staging | Cast integer | Thứ tự hiển thị |
| is_active | boolean | `is_active` từ staging | Cast boolean | Cờ trường aktif |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |

---

## Quy tắc nghiệp vụ

### 1. Field Types
```
- text: Text input ngắn
- textarea: Text input dài
- select: Dropdown list
- radio: Radio buttons
- checkbox: Checkboxes
- date: Date picker
```

### 2. Options Format
```json
[
  {"value": "option1", "label": {"vi": "Lựa chọn 1", "en": "Option 1"}},
  {"value": "option2", "label": {"vi": "Lựa chọn 2", "en": "Option 2"}}
]
```

### 3. Display Order
Sắp xếp trường theo thứ tự tăng dần trên form
