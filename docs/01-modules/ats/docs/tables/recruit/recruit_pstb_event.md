# Data Dictionary - recruit.pstb_event

**Mô tả bảng:** Lưu thông tin sự kiện tuyển dụng (event)

**Nguồn dữ liệu:** `staging.program_events_upsert`

**Scripts ETL:** `j_import_all_program_event_online.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `id` từ staging | Trực tiếp | ID sự kiện từ hệ thống nguồn |
| create_date | timestamptz | `create_date` từ staging | Trực tiếp | Ngày giờ tạo sự kiện |
| write_date | timestamptz | `write_date` từ staging | Trực tiếp | Ngày giờ cập nhật |
| code | varchar | `code` từ staging | Trực tiếp | Mã sự kiện |
| name | varchar | `name` từ staging | Trực tiếp | Tên sự kiện |
| program_id | numeric | Lookup `pstb_program` | Match bằng ref_id | ID chương trình cha |
| program_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin chương trình |
| start_date | timestamptz | `start_date` từ staging | Parse datetime | Ngày giờ bắt đầu |
| end_date | timestamptz | `end_date` từ staging | Parse datetime | Ngày giờ kết thúc |
| location | jsonb | `location` từ staging | JSON: `{vi, en}` | Địa điểm tổ chức |
| description | jsonb | `description` từ staging | JSON: `{vi, en}` | Mô tả sự kiện |
| status | varchar | `state` từ staging | Map state (draft, published, cancelled, completed) | Trạng thái sự kiện |
| max_participants | numeric | `max_participants` từ staging | Trực tiếp | Số người tham gia tối đa |
| current_participants | numeric | Count từ participant table | Aggregate | Số người tham gia hiện tại |
| organizer_id | numeric | Lookup `hrtb_employee` | Match bằng ref_id | ID người tổ chức |
| organizer_info | jsonb | Build từ employee | JSON: `{id, code, name, email}` | Thông tin người tổ chức |
| event_type_id | numeric | Lookup `pstm_event_type` | Match bằng ref_id | ID loại sự kiện |
| event_type_info | jsonb | Lookup từ table | JSON: `{id, code, name}` | Thông tin loại sự kiện |
| registration_deadline | timestamptz | `registration_deadline` từ staging | Parse datetime | Hạn chót đăng ký |
| is_online | boolean | `is_online` từ staging | Cast boolean | Cờ sự kiện online |
| online_link | varchar | `online_link` từ staging | Trực tiếp | Link tham gia online (Zoom, Teams...) |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |

---

## Quy tắc nghiệp vụ

### 1. Function Call
```sql
SELECT staging.psfn_etl_upsert_program_event(...)
```

### 2. Status Mapping
```python
MAP_STATE = {
    'draft': 'DRAFT',
    'published': 'PUBLISHED',
    'cancelled': 'CANCELLED',
    'completed': 'COMPLETED'
}
```

### 3. Online Event
- `is_online = true` → yêu cầu `online_link`
- Offline event → yêu cầu `location`

### 4. Participant Count
```sql
SELECT COUNT(*) FROM pstb_event_participant 
WHERE event_id = {event_id}
```
