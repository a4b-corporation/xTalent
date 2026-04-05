# Data Dictionary - Online Candidate Functions

**Mô tả:** Function `staging.csfn_etl_upsert_online_candidate` được gọi để xử lý online candidate

**Nguồn dữ liệu:** `staging.online_candidate_upsert`

**Scripts ETL:** `j_import_all_online_candidate.py`

---

## Fields truyền vào Function

### 1. ref_id
- **Kiểu dữ liệu:** numeric
- **Extract:** `id` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Mã định danh online candidate

### 2. create_date
- **Kiểu dữ liệu:** timestamptz
- **Extract:** `create_date` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Ngày giờ tạo hồ sơ

### 3. write_date
- **Kiểu dữ liệu:** timestamptz
- **Extract:** `write_date` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Ngày giờ cập nhật hồ sơ

### 4. first_name
- **Kiểu dữ liệu:** jsonb
- **Extract:** `first_name` từ staging
- **Transform:** JSON: `{"vi": value, "en": value}`
- **Mô tả nghiệp vụ:** Tên (đa ngôn ngữ)

### 5. last_name
- **Kiểu dữ liệu:** jsonb
- **Extract:** `last_name` từ staging
- **Transform:** JSON: `{"vi": value, "en": value}`
- **Mô tả nghiệp vụ:** Họ (đa ngôn ngữ)

### 6. full_name
- **Kiểu dữ liệu:** jsonb
- **Extract:** `name` từ staging
- **Transform:** JSON: `{"vi": value, "en": value}`
- **Mô tả nghiệp vụ:** Tên đầy đủ (đa ngôn ngữ)

### 7. birth_date
- **Kiểu dữ liệu:** timestamptz
- **Extract:** `birthday` từ staging
- **Transform:** Parse date
- **Mô tả nghiệp vụ:** Ngày sinh

### 8. mobile_phone
- **Kiểu dữ liệu:** varchar
- **Extract:** `mobile_new` từ staging
- **Transform:** Combine: `+{isd_code} {mobile}`
- **Mô tả nghiệp vụ:** Số điện thoại với mã quốc tế

### 9. email
- **Kiểu dữ liệu:** varchar
- **Extract:** `email` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Email liên hệ

### 10. tenant_code
- **Kiểu dữ liệu:** varchar
- **Extract:** Tham số đầu vào
- **Transform:** Hằng số
- **Mô tả nghiệp vụ:** Mã đơn vị quản lý

### 11. fts_string
- **Kiểu dữ liệu:** varchar
- **Extract:** Build từ name, email, mobile
- **Transform:** Full-text search string
- **Mô tả nghiệp vụ:** Chuỗi tìm kiếm candidate

### 12. note
- **Kiểu dữ liệu:** varchar
- **Extract:** `note` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Ghi chú về candidate

### 13. status
- **Kiểu dữ liệu:** varchar
- **Extract:** `state` từ staging
- **Transform:** Map:
  - `draft` → `DRAFT`
  - `approved` → `APPROVED`
  - `reject` → `REJECT`
- **Mô tả nghiệp vụ:** Trạng thái hồ sơ

### 14. gender
- **Kiểu dữ liệu:** numeric
- **Extract:** Lookup `tatm_gender`
- **Transform:** Match bằng English name (upper)
- **Mô tả nghiệp vụ:** Mã giới tính

### 15. gender_info
- **Kiểu dữ liệu:** jsonb
- **Extract:** Lookup `tatm_gender`
- **Transform:** JSON: `{"id": id, "name": name, "code": code}`
- **Mô tả nghiệp vụ:** Thông tin giới tính chi tiết

### 16. facebook
- **Kiểu dữ liệu:** varchar
- **Extract:** `facebook_link` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Link Facebook cá nhân

### 17. linkedin
- **Kiểu dữ liệu:** varchar
- **Extract:** `linkedin_link` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Link LinkedIn cá nhân

### 18. porfolio
- **Kiểu dữ liệu:** varchar
- **Extract:** `porfolio_link` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Link Portfolio cá nhân

### 19. student_code
- **Kiểu dữ liệu:** varchar
- **Extract:** `student_code` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Mã số sinh viên

### 20. student_email
- **Kiểu dữ liệu:** varchar
- **Extract:** `student_email` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Email sinh viên

### 21. gpa
- **Kiểu dữ liệu:** numeric
- **Extract:** `cumulative_gpa` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Điểm trung bình tích lũy (GPA)

### 22. channel_name
- **Kiểu dữ liệu:** varchar
- **Extract:** `channel` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Tên kênh tuyển dụng

### 23. recommender_email
- **Kiểu dữ liệu:** varchar
- **Extract:** `referrer_email` từ staging
- **Transform:** Trực tiếp
- **Mô tả nghiệp vụ:** Email người giới thiệu

### 24. spin_flg
- **Kiểu dữ liệu:** numeric
- **Extract:** `is_spin` từ staging
- **Transform:** Boolean cast
- **Mô tả nghiệp vụ:** Cờ SPIN (chương trình đặc biệt)

### 25. nationality_info
- **Kiểu dữ liệu:** jsonb
- **Extract:** Lookup `hrtm_nationality`
- **Transform:** JSON từ table
- **Mô tả nghiệp vụ:** Thông tin quốc tịch

### 26. post_job_id
- **Kiểu dữ liệu:** numeric
- **Extract:** Lookup `cstb_posting`
- **Transform:** Match post_job_id → ref_id
- **Mô tả nghiệp vụ:** Mã tin đăng tuyển dụng

### 27. source_id
- **Kiểu dữ liệu:** numeric
- **Extract:** Lookup từ mapping tables
- **Transform:** Source mapping
- **Mô tả nghiệp vụ:** Mã nguồn tuyển dụng

---

## Quy tắc nghiệp vụ quan trọng

### 1. Status Mapping
```
draft → DRAFT
approved → APPROVED
reject → REJECT
```

### 2. Mobile Combine
```
Input: isd_code="84", mobile="123456789"
Output: "+84 123456789"
```

### 3. Name Info JSON
```json
{
  "vi": "Nguyễn Văn A",
  "en": "Nguyen Van A"
}
```

### 4. Gender Match
- Match bằng English name từ `tatm_gender`
- Upper case để chuẩn hóa

### 5. Function Call
- Gọi `staging.csfn_etl_upsert_online_candidate` với 27 parameters
- Function thực hiện upsert logic
- Không INSERT/UPDATE trực tiếp trong script
