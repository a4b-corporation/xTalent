# Data Dictionary - hrm.hrtb_worker_attachment

**Mô tả bảng:** Lưu thông tin file đính kèm của worker (CV, giấy tờ, bằng cấp...)

**Nguồn dữ liệu:** 
- S3 CSV files
- `staging.candidate_cv` (validate)
- Lookup từ staging tables

**Scripts ETL:** `j_import_candidate_file_cv.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| worker_id | numeric | Lookup từ `hrtb_candidate` | Merge candidate_record_id → ref_id | Mã worker sở hữu file đính kèm |
| attachment_type_id | numeric | Lookup từ `hrtm_attachment_type` | Match code='AT003' (CV/Resume) | Mã loại file đính kèm |
| attachment_refno | varchar | `file_path` từ staging | Trực tiếp | Đường dẫn file trên S3/storage |
| extra_info | jsonb | Build từ metadata file | JSON: `{"size": size, "type": mimeType, "fileName": name, "identifier": id}` | Thông tin bổ sung về file (kích thước, loại, tên) |
| using_flg | numeric | `is_main` từ staging | Boolean cast (true=1, false=0) | Cờ đánh dấu file chính/main |
| tenant_code | varchar | Tham số đầu vào | Hằng số | Mã đơn vị quản lý |
| recruit_source_id | numeric | Lookup từ mapping tables | Map 3 bước như candidate | Mã nguồn tuyển dụng liên kết |
| source_type_id | numeric | Lookup từ mapping tables | Map 3 bước như candidate | Mã loại nguồn tuyển dụng |
| recruit_source | jsonb | Build từ mapping | JSON: `{"id": id, "name": name, "code": code}` | Thông tin nguồn tuyển dụng |
| source_type | jsonb | Build từ mapping | JSON: `{"id": id, "name": name, "code": code}` | Thông tin loại nguồn tuyển dụng |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo bản ghi (hệ thống ETL) |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| create_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo bản ghi |
| update_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm cập nhật gần nhất |
| update_id | varchar | Hằng số | 'system_etl' | Người cập nhật gần nhất |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Validate File Path
- Kiểm tra file_path tồn tại trong `staging.candidate_cv`
- Chỉ load files đã được validate

### 2. Source Mapping (3 bước)
```
Old Source → Mapping Table → New Source Taxonomy
```

### 3. ON CONFLICT Logic
- Upsert khi có conflict
- Đảm bảo không trùng file

### 4. Filter Logic
Chỉ load records có:
- `worker_id` NOT NULL (đã tìm được worker)
- File path đã validate

### 5. Attachment Type
- Code 'AT003' thường là CV/Resume
- Có thể mở rộng cho các loại file khác

### 6. Extra Info JSON
```json
{
  "size": 123456,
  "type": "application/pdf",
  "fileName": "cv_original.pdf",
  "identifier": "s3-key-uuid"
}
```
