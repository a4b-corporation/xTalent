# Data Dictionary - connect.cstb_candidate_resume

**Mô tả bảng:** Lưu thông tin file CV/resume của candidate

**Nguồn dữ liệu:** 
- S3 CSV files
- `staging.online_candidate_cv_upsert` (validate)
- `staging.online_candidate_cv` (lookup)

**Scripts ETL:** `j_import_online_candidate_file_cv.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| cv_filename | varchar | `file_path` từ staging | Split: lấy filename từ path | Tên file CV lưu trữ |
| cv_info | jsonb | Build từ metadata file | JSON: `{"size": file_size, "mimeType": file_type, "name": original_filename, "dmsType": "curriculumVitae", "attachmentRefNo": reference_number}` | Thông tin chi tiết về file CV |
| update_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm cập nhật thông tin CV |
| update_id | varchar | Hằng số | `'system_etl'` | Người cập nhật (hệ thống ETL) |

---

## Quy tắc nghiệp vụ quan trọng

### 1. Validate File Path
- Kiểm tra file_path tồn tại trong `staging.online_candidate_cv_upsert`
- Chỉ process files đã được validate

### 2. Lookup Full Data
- Sau khi validate, lookup full data từ `staging.online_candidate_cv`
- Đảm bảo dữ liệu đầy đủ trước khi update

### 3. UPDATE Only
- Script chỉ thực hiện UPDATE
- Không INSERT records mới
- Giả định record đã tồn tại

### 4. DMS Type
- `dmsType = 'curriculumVitae'`
- Phân loại file là CV trong hệ thống DMS

### 5. File Path Split
```
Input: "s3://bucket/path/to/file/cv_original.pdf"
Output: "cv_original.pdf"
```

### 6. Attachment Reference
- `attachmentRefNo` được dùng để liên kết với `hrm.hrtb_worker_attachment`
- Tạo mối liên hệ giữa resume và worker

---

## Mối quan hệ với bảng khác

### hrm.hrtb_worker_attachment
- `connect.cstb_candidate_resume` lưu thông tin CV online candidate
- `hrm.hrtb_worker_attachment` lưu file đính kèm của worker
- Liên kết qua attachment_refno
