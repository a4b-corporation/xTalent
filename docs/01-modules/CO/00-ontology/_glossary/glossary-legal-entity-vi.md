# Thuật ngữ Pháp nhân (Legal Entity Glossary)

## Tổng quan

Bảng thuật ngữ này định nghĩa các thực thể cấu trúc pháp nhân được sử dụng trong hệ thống xTalent HCM. Các pháp nhân đại diện cho cấu trúc doanh nghiệp bao gồm các công ty, chi nhánh, công ty con và thông tin pháp lý liên quan của chúng.

---

## Các thực thể (Entities)

### EntityType (Loại Pháp nhân)

**Định nghĩa:** Phân loại các loại pháp nhân định nghĩa cấu trúc phân cấp của các tổ chức doanh nghiệp.

**Mục đích:**
- Phân loại các pháp nhân theo loại (công ty, chi nhánh, công ty con, v.v.)
- Định nghĩa các mối quan hệ phân cấp được phép
- Hỗ trợ mô hình hóa cấu trúc doanh nghiệp

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã loại pháp nhân |
| `name` | string(100) | Không | Tên loại pháp nhân |
| `level_order` | integer | Không | Chỉ báo cấp độ phân cấp |
| `metadata` | jsonb | Không | Các loại cha được phép, ràng buộc |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại pháp nhân phổ biến:**

| Mã | Tên | Cấp độ | Mô tả |
|----|-----|--------|-------|
| `HOLDING` | Công ty Holding | 1 | Công ty mẹ cấp cao nhất |
| `COMPANY` | Công ty | 2 | Công ty hoạt động |
| `SUBSIDIARY` | Công ty con | 3 | Công ty con |
| `BRANCH` | Chi nhánh | 4 | Văn phòng chi nhánh |
| `REPRESENTATIVE` | Văn phòng đại diện | 4 | Văn phòng đại diện |

**Cấu trúc Metadata:**
```json
{
  "allowed_parent_types": ["HOLDING", "COMPANY"],
  "requires_license": true,
  "can_employ_workers": true,
  "tax_entity": true,
  "constraints": {
    "max_depth": 5,
    "requires_parent": true
  }
}
```

**Quy tắc nghiệp vụ:**
- Mã loại pháp nhân phải là duy nhất
- Thứ tự cấp độ xác định độ sâu phân cấp
- Sử dụng SCD Type 2 để theo dõi lịch sử

---

### Entity (Pháp nhân)

**Định nghĩa:** Pháp nhân (công ty, chi nhánh, công ty con) đại diện cho một tổ chức được đăng ký hợp pháp có thể thuê nhân viên và tiến hành kinh doanh.

**Mục đích:**
- Định nghĩa cấu trúc và phân cấp doanh nghiệp
- Theo dõi thông tin pháp nhân
- Hỗ trợ hoạt động đa pháp nhân
- Cho phép báo cáo và tuân thủ cấp pháp nhân

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã pháp nhân duy nhất |
| `name_vi` | string(150) | Không | Tên tiếng Việt |
| `name_en` | string(150) | Không | Tên tiếng Anh |
| `type_id` | UUID | Có | Tham chiếu loại pháp nhân |
| `parent_id` | UUID | Không | Pháp nhân cha |
| `path` | string(255) | Không | Đường dẫn phân cấp (ví dụ: /parent/child) |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Mối quan hệ:**
- **Thuộc về** `EntityType` (loại pháp nhân)
- **Thuộc về** `Entity` (pháp nhân cha)
- **Có nhiều** `Entity` (pháp nhân con)
- **Có một** `EntityProfile` (hồ sơ mở rộng)
- **Có nhiều** `EntityRepresentative` (người đại diện pháp luật)
- **Có nhiều** `EntityLicense` (giấy phép kinh doanh)
- **Có nhiều** `EntityBankAccount` (tài khoản ngân hàng)
- **Có nhiều** `Unit` (đơn vị kinh doanh)

**Quy tắc nghiệp vụ:**
- Mã pháp nhân phải là duy nhất trên tất cả các pháp nhân
- Đường dẫn phải phản ánh phân cấp thực tế
- Sử dụng SCD Type 2 để theo dõi thay đổi theo thời gian
- Pháp nhân cha phải thuộc loại được phép theo metadata của EntityType

**Ví dụ:**

```yaml
# Công ty Holding
id: entity_vng_holding
code: VNG_HOLDING
name_vi: Tập đoàn VNG
name_en: VNG Corporation
type_id: type_holding
parent_id: null
path: /VNG_HOLDING

# Công ty Hoạt động
id: entity_vng_corp
code: VNG_CORP
name_vi: Công ty Cổ phần VNG
name_en: VNG Corporation JSC
type_id: type_company
parent_id: entity_vng_holding
path: /VNG_HOLDING/VNG_CORP

# Chi nhánh
id: entity_vng_hn
code: VNG_HN_BRANCH
name_vi: Chi nhánh Hà Nội
name_en: Hanoi Branch
type_id: type_branch
parent_id: entity_vng_corp
path: /VNG_HOLDING/VNG_CORP/VNG_HN_BRANCH
```

---

### EntityProfile (Hồ sơ Pháp nhân)

**Định nghĩa:** Thông tin hồ sơ mở rộng cho các pháp nhân bao gồm địa chỉ, liên hệ, thông tin thuế và thương hiệu.

**Mục đích:**
- Lưu trữ thông tin pháp nhân chi tiết
- Duy trì dữ liệu liên hệ và địa chỉ
- Theo dõi mã số thuế và bảo hiểm
- Hỗ trợ thương hiệu và nhận diện doanh nghiệp

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `legal_entity_id` | UUID | Có | Khóa chính và FK đến Entity |
| `logo_url` | string(255) | Không | URL logo công ty |
| `legal_name_local` | string(255) | Không | Tên pháp lý đầy đủ (ngôn ngữ địa phương) |
| `legal_name_en` | string(255) | Không | Tên pháp lý đầy đủ (tiếng Anh) |
| `group_name` | string(255) | Không | Tên tập đoàn |
| `address1_country_code` | string(2) | Không | Quốc gia địa chỉ chính |
| `address1_admin_area_id` | UUID | Không | Khu vực hành chính địa chỉ chính |
| `address1_street` | string(255) | Không | Đường phố địa chỉ chính |
| `address1_postal_code` | string(20) | Không | Mã bưu chính địa chỉ chính |
| `address2_country_code` | string(2) | Không | Quốc gia địa chỉ phụ |
| `address2_admin_area_id` | UUID | Không | Khu vực hành chính địa chỉ phụ |
| `address2_street` | string(255) | Không | Đường phố địa chỉ phụ |
| `address2_postal_code` | string(20) | Không | Mã bưu chính địa chỉ phụ |
| `phone` | string(50) | Không | Số điện thoại chính |
| `fax` | string(50) | Không | Số fax |
| `email` | string(100) | Không | Email chính |
| `email_suffix` | string(100) | Không | Tên miền email doanh nghiệp (ví dụ: @company.com) |
| `website` | string(255) | Không | Website công ty |
| `tagline` | string(255) | Không | Khẩu hiệu công ty |
| `is_head_office` | boolean | Không | Chỉ báo trụ sở chính (mặc định: false) |
| `is_member` | boolean | Không | Thành viên của tập đoàn (mặc định: true) |
| `ceo_worker_id` | UUID | Không | Tham chiếu CEO |
| `tax_id` | string(50) | Không | Mã số thuế |
| `insurance_type_code` | string(50) | Không | Mã loại bảo hiểm |
| `description` | text | Không | Mô tả pháp nhân |
| `metadata` | jsonb | Không | Các thuộc tính bổ sung |
| `active` | boolean | Không | Trạng thái hoạt động (mặc định: true) |

**Cấu trúc Metadata:**
```json
{
  "registration_number": "0100109106",
  "registration_date": "2004-04-08",
  "registration_authority": "Department of Planning and Investment of Hanoi",
  "charter_capital": 1000000000000,
  "charter_capital_currency": "VND",
  "business_sectors": ["Technology", "Entertainment", "E-commerce"],
  "employee_count_range": "1000-5000",
  "fiscal_year_end": "12-31",
  "stock_exchange": "HOSE",
  "stock_symbol": "VNZ"
}
```

**Mối quan hệ:**
- **Thuộc về** `Entity` (một-một)
- **Tham chiếu** `Worker` (CEO)

**Quy tắc nghiệp vụ:**
- Một hồ sơ cho mỗi pháp nhân
- Ít nhất một địa chỉ nên được cung cấp
- Mã số thuế bắt buộc cho các pháp nhân chịu thuế
- Tên miền email nên khớp với tên miền doanh nghiệp

**Ví dụ:**

```yaml
legal_entity_id: entity_vng_corp
logo_url: https://cdn.vng.com/logo.png
legal_name_local: Công ty Cổ phần VNG
legal_name_en: VNG Corporation Joint Stock Company
group_name: VNG Corporation
address1_country_code: VN
address1_admin_area_id: admin_vn_hanoi
address1_street: 182 Le Dai Hanh, Hai Ba Trung
address1_postal_code: "100000"
phone: "+84 24 7300 8855"
email: contact@vng.com.vn
email_suffix: "@vng.com.vn"
website: https://www.vng.com.vn
is_head_office: true
ceo_worker_id: worker_ceo_001
tax_id: "0100109106"
metadata:
  registration_number: "0100109106"
  registration_date: "2004-04-08"
  charter_capital: 1000000000000
```

---

### EntityRepresentative (Người Đại diện Pháp nhân)

**Định nghĩa:** Người đại diện theo pháp luật và người ký được ủy quyền của các pháp nhân.

**Mục đích:**
- Theo dõi người đại diện theo pháp luật
- Quản lý người ký được ủy quyền
- Hỗ trợ thẩm quyền ký tài liệu
- Duy trì tuân thủ quản trị doanh nghiệp

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `legal_entity_id` | UUID | Có | Tham chiếu pháp nhân |
| `rep_type_code` | string(50) | Không | Loại đại diện (LEGAL_REP, AUTH_REP, CEO) |
| `worker_id` | UUID | Có | Tham chiếu nhân viên |
| `document_id` | UUID | Không | Tài liệu ủy quyền |
| `metadata` | jsonb | Không | Số quyết định, ghi chú |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại đại diện:**

| Mã | Mô tả | Mức độ thẩm quyền |
|----|-------|-------------------|
| `LEGAL_REP` | Người đại diện theo pháp luật | Thẩm quyền pháp lý đầy đủ |
| `AUTH_REP` | Người đại diện được ủy quyền | Thẩm quyền hạn chế theo tài liệu |
| `CEO` | Giám đốc điều hành | Thẩm quyền điều hành |
| `CHAIRMAN` | Chủ tịch Hội đồng quản trị | Thẩm quyền Hội đồng |
| `DIRECTOR` | Giám đốc | Thẩm quyền phòng ban |

**Cấu trúc Metadata:**
```json
{
  "decision_number": "123/QĐ-VNG",
  "decision_date": "2025-01-15",
  "appointment_authority": "Board of Directors",
  "signing_authority": ["contracts", "bank_documents", "legal_filings"],
  "delegation_scope": "Full authority",
  "notes": "Appointed as legal representative"
}
```

**Mối quan hệ:**
- **Thuộc về** `Entity`
- **Tham chiếu** `Worker` (người đại diện)
- **Tham chiếu** `Document` (tài liệu ủy quyền)

**Quy tắc nghiệp vụ:**
- Sự kết hợp của pháp nhân, loại đại diện và ngày bắt đầu hiệu lực phải là duy nhất
- Nhân viên phải là nhân viên đang hoạt động của pháp nhân
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Tài liệu ủy quyền bắt buộc cho loại AUTH_REP

---

### EntityLicense (Giấy phép Pháp nhân)

**Định nghĩa:** Giấy phép kinh doanh và đăng ký cho các pháp nhân.

**Mục đích:**
- Theo dõi giấy phép kinh doanh và giấy phép
- Duy trì tài liệu tuân thủ
- Hỗ trợ báo cáo quy định
- Quản lý gia hạn giấy phép

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `legal_entity_id` | UUID | Có | Tham chiếu pháp nhân |
| `license_number` | string(100) | Không | Số giấy phép/đăng ký |
| `issue_date` | date | Không | Ngày cấp |
| `issued_by` | string(255) | Không | Cơ quan cấp |
| `metadata` | jsonb | Không | Đính kèm, ghi chú, ngày hết hạn |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại giấy phép (trong metadata):**

| Loại | Mô tả |
|------|-------|
| `BUSINESS_REGISTRATION` | Giấy chứng nhận đăng ký kinh doanh |
| `TAX_REGISTRATION` | Giấy chứng nhận đăng ký thuế |
| `OPERATING_LICENSE` | Giấy phép hoạt động |
| `INDUSTRY_PERMIT` | Giấy phép chuyên ngành |
| `IMPORT_EXPORT` | Giấy phép xuất nhập khẩu |

**Cấu trúc Metadata:**
```json
{
  "license_type": "BUSINESS_REGISTRATION",
  "license_name": "Business Registration Certificate",
  "expiry_date": "2030-12-31",
  "renewal_required": false,
  "attachment_url": "https://storage.vng.com/licenses/brc_001.pdf",
  "status": "ACTIVE",
  "notes": "Main business registration"
}
```

**Mối quan hệ:**
- **Thuộc về** `Entity`

**Quy tắc nghiệp vụ:**
- Sự kết hợp của pháp nhân, số giấy phép và ngày bắt đầu hiệu lực phải là duy nhất
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Ngày hết hạn nên được theo dõi trong metadata
- Cảnh báo gia hạn nên được cấu hình

---

### EntityBankAccount (Tài khoản Ngân hàng Pháp nhân)

**Định nghĩa:** Tài khoản ngân hàng thuộc sở hữu của các pháp nhân cho các giao dịch tài chính.

**Mục đích:**
- Quản lý tài khoản ngân hàng doanh nghiệp
- Hỗ trợ xử lý lương và thanh toán
- Theo dõi chi tiết tài khoản cho các hoạt động tài chính
- Cho phép ngân hàng đa tiền tệ

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `legal_entity_id` | UUID | Có | Tham chiếu pháp nhân |
| `bank_name` | string(255) | Không | Tên ngân hàng |
| `account_number` | string(100) | Không | Số tài khoản |
| `account_holder` | string(255) | Không | Tên chủ tài khoản |
| `currency_code` | string(3) | Không | Tiền tệ tài khoản (ISO 4217) |
| `is_primary` | boolean | Không | Chỉ báo tài khoản chính (mặc định: false) |
| `metadata` | jsonb | Không | Chi tiết tài khoản bổ sung |

**Cấu trúc Metadata:**
```json
{
  "bank_code": "BIDVVNVX",
  "branch_name": "Hanoi Branch",
  "branch_code": "001",
  "swift_code": "BIDVVNVX",
  "iban": null,
  "account_type": "CORPORATE_CHECKING",
  "purpose": "PAYROLL",
  "status": "ACTIVE",
  "opened_date": "2004-05-01",
  "notes": "Primary payroll account"
}
```

**Mục đích tài khoản:**

| Mục đích | Mô tả |
|----------|-------|
| `PAYROLL` | Chi trả lương nhân viên |
| `OPERATING` | Chi phí hoạt động chung |
| `RECEIVABLES` | Thanh toán từ khách hàng |
| `PAYABLES` | Thanh toán cho nhà cung cấp |
| `TAX` | Thanh toán thuế |
| `SAVINGS` | Tài khoản tiết kiệm/đầu tư |

**Mối quan hệ:**
- **Thuộc về** `Entity`

**Quy tắc nghiệp vụ:**
- Sự kết hợp của pháp nhân và số tài khoản phải là duy nhất
- Chỉ một tài khoản chính cho mỗi pháp nhân cho mỗi loại tiền tệ
- Mã tiền tệ phải là mã ISO 4217 hợp lệ
- Tên chủ tài khoản nên khớp với tên pháp nhân

**Ví dụ:**

```yaml
id: bank_001
legal_entity_id: entity_vng_corp
bank_name: "BIDV - Bank for Investment and Development of Vietnam"
account_number: "12345678901"
account_holder: "CONG TY CO PHAN VNG"
currency_code: "VND"
is_primary: true
metadata:
  bank_code: "BIDVVNVX"
  branch_name: "Hanoi Branch"
  swift_code: "BIDVVNVX"
  account_type: "CORPORATE_CHECKING"
  purpose: "PAYROLL"
  status: "ACTIVE"
```

---

## Mối quan hệ

```mermaid
erDiagram
    EntityType ||--o{ Entity : "classifies"
    Entity ||--o{ Entity : "parent-child"
    Entity ||--o| EntityProfile : "has"
    Entity ||--o{ EntityRepresentative : "has"
    Entity ||--o{ EntityLicense : "has"
    Entity ||--o{ EntityBankAccount : "has"
    Worker ||--o{ EntityRepresentative : "is"
    
    EntityType {
        uuid id PK
        string code UK
        string name
        integer level_order
        jsonb metadata
    }
    
    Entity {
        uuid id PK
        string code UK
        string name_vi
        string name_en
        uuid type_id FK
        uuid parent_id FK
        string path
    }
    
    EntityProfile {
        uuid legal_entity_id PK_FK
        string legal_name_local
        string tax_id
        string email_suffix
        uuid ceo_worker_id FK
    }
    
    EntityRepresentative {
        uuid id PK
        uuid legal_entity_id FK
        string rep_type_code
        uuid worker_id FK
    }
    
    EntityLicense {
        uuid id PK
        uuid legal_entity_id FK
        string license_number
        date issue_date
    }
    
    EntityBankAccount {
        uuid id PK
        uuid legal_entity_id FK
        string account_number
        string currency_code
        boolean is_primary
    }
```

---

## Các trường hợp sử dụng (Use Cases)

### Quản lý Cấu trúc Doanh nghiệp
- Định nghĩa công ty holding và các công ty con
- Theo dõi các văn phòng chi nhánh và văn phòng đại diện
- Quản lý thay đổi phân cấp doanh nghiệp
- Hỗ trợ các hoạt động M&A

### Tuân thủ Pháp lý
- Duy trì giấy phép kinh doanh và giấy phép
- Theo dõi người đại diện theo pháp luật
- Quản lý quản trị doanh nghiệp
- Hỗ trợ báo cáo quy định

### Hoạt động Tài chính
- Quản lý tài khoản ngân hàng doanh nghiệp
- Xử lý thanh toán lương
- Xử lý thanh toán nhà cung cấp
- Theo dõi tài khoản đa tiền tệ

### Quản lý Nhân viên
- Gán nhân viên vào các pháp nhân
- Theo dõi hợp đồng lao động theo pháp nhân
- Hỗ trợ việc làm đa pháp nhân
- Cho phép báo cáo cấp pháp nhân

---

## Các thực hành tốt nhất

1. **Đặt tên Mã Pháp nhân:**
   - Sử dụng quy ước đặt tên nhất quán
   - Bao gồm tiền tố loại pháp nhân
   - Giữ mã ngắn gọn nhưng có ý nghĩa

2. **Quản lý Phân cấp:**
   - Duy trì mối quan hệ cha-con chính xác
   - Cập nhật đường dẫn khi phân cấp thay đổi
   - Xác thực độ sâu phân cấp

3. **Tính đầy đủ của Hồ sơ:**
   - Đảm bảo tất cả các trường bắt buộc được điền
   - Giữ thông tin liên hệ cập nhật
   - Cập nhật mã số thuế kịp thời

4. **Theo dõi Giấy phép:**
   - Thiết lập nhắc nhở gia hạn
   - Duy trì bản sao kỹ thuật số
   - Theo dõi ngày hết hạn

5. **Bảo mật Tài khoản Ngân hàng:**
   - Hạn chế quyền truy cập vào chi tiết tài khoản
   - Mã hóa dữ liệu nhạy cảm
   - Kiểm toán các thay đổi tài khoản

---

## Lịch sử phiên bản

| Phiên bản | Ngày | Thay đổi |
|-----------|------|----------|
| 2.0 | 2025-12-01 | Cấu trúc metadata nâng cao, thêm ví dụ |
| 1.0 | 2025-11-01 | Ontology pháp nhân ban đầu |
