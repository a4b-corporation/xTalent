# Data Dictionary - hrm.hrtb_worker_social

**Mô tả bảng:** Lưu thông tin mạng xã hội và các kênh liên lạc của worker

**Nguồn dữ liệu:** `staging.vhr_candidate_contact`

**Scripts ETL:** `j_import_all_candidate_contact.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| worker_id | numeric | Lookup từ `hrtb_candidate` | Merge candidate_id → ref_id → worker_id | Mã worker sở hữu thông tin liên lạc |
| channel_id | numeric | Lookup từ `rstm_channel` | Merge contact_type_id → ref_id | Mã kênh liên lạc (Facebook, LinkedIn, Email, Phone...) |
| social_link | varchar | `contact` từ staging | Trực tiếp | Link mạng xã hội hoặc thông tin liên hệ |
| record_status | varchar | Hằng số | 'O' (Open/Active) | Trạng thái bản ghi |
| auth_status | varchar | Hằng số | 'A' (Approved) | Trạng thái phê duyệt |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo bản ghi (hệ thống ETL) |
| maker_date | timestamptz | Hệ thống | `now()` | Thời điểm tạo bản ghi |
| create_date | timestamptz | Hệ thống | `now()` | Thời điểm tạo bản ghi |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị quản lý |
| ref_id | numeric | `id` từ staging | Trực tiếp | Mã tham chiếu từ hệ thống nguồn |

---

## Quy tắc nghiệp vụ quan trọng

### 1. MERGE Statement
- **UPDATE** khi tồn tại ref_id trong target table
- **INSERT** khi chưa tồn tại ref_id
- Đảm bảo không trùng lặp khi chạy lại ETL

### 2. Filter Logic
Chỉ load records có:
- `worker_id_new` NOT NULL (đã tìm được worker)

### 3. Channel Mapping
- contact_type_id từ source được map sang channel_id trong target
- Lookup qua bảng `rstm_channel`

### 4. Hằng số hệ thống
```
record_status = 'O' (Active)
auth_status = 'A' (Approved)
maker_id = 'system_etl'
```

### 5. Sử dụng
- Bảng này lưu trữ đa dạng các kênh liên lạc
- Một worker có thể có nhiều records (mỗi kênh 1 record)
- Support: Facebook, LinkedIn, Zalo, Email, Phone, Portfolio...
