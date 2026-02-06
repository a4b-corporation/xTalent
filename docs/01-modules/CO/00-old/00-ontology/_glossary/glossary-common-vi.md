# Phân hệ con Common - Thuật ngữ

**Phiên bản**: 2.0  
**Cập nhật lần cuối**: 01/12/2025  
**Phân hệ con**: Dữ liệu Chủ & Bảng Tham chiếu

---

## 📋 Tổng quan

Phân hệ con Common cung cấp dữ liệu chủ nền tảng và các bảng tham chiếu được sử dụng trên tất cả các phân hệ. Đây là các danh mục toàn hệ thống đảm bảo tính nhất quán, tiêu chuẩn hóa và hỗ trợ bản địa hóa.

**Mục đích**: Kho lưu trữ trung tâm cho các giá trị tra cứu, phân loại và dữ liệu tham chiếu mà nhiều phân hệ phụ thuộc vào.

### Thực thể (10)
1. **CodeList** - Giá trị tra cứu đa năng
2. **Currency** - Mã tiền tệ ISO
3. **TimeZone** - Múi giờ IANA
4. **Industry** - Phân cấp ngành nghề
5. **ContactType** - Loại phương thức liên hệ
6. **RelationshipGroup** - Nhóm mối quan hệ
7. **RelationshipType** - Loại mối quan hệ cá nhân
8. **TalentMarket** - Cấu trúc đa thị trường
9. **SkillMaster** - Danh mục kỹ năng chuyên môn/kỹ thuật
10. **CompetencyMaster** - Danh mục năng lực hành vi

---

## 🔑 Các Thực thể Chính

### CodeList

**Định nghĩa**: Bảng tra cứu đa năng linh hoạt cho các giá trị mã và phân loại toàn hệ thống.

**Mục đích**:
- Tập trung hóa các giá trị tra cứu để tránh hardcoding
- Hỗ trợ bản địa hóa (đa ngôn ngữ)
- Cho phép người dùng nghiệp vụ quản lý các mã
- Duy trì lịch sử thay đổi (SCD Type 2)

**Thuộc tính chính**:
- `group_code` - Nhóm logic (ví dụ: GENDER, MARITAL_STATUS)
- `code` - Giá trị mã thực tế (ví dụ: M, F, SINGLE, MARRIED)
- `display_en` - Văn bản hiển thị tiếng Anh
- `display_local` - Văn bản hiển thị ngôn ngữ địa phương
- `sort_order` - Thứ tự hiển thị
- `is_active` - Cờ hoạt động/không hoạt động
- `metadata` - Thuộc tính bổ sung (màu sắc, biểu tượng, quy tắc xác thực)
- Các trường SCD Type 2

**Các Nhóm Mã Phổ biến**:

| Mã Nhóm | Giá trị | Sử dụng |
|---------|---------|---------|
| GENDER | M, F, O, U | Giới tính nhân sự |
| MARITAL_STATUS | SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED | Tình trạng hôn nhân |
| EMPLOYEE_STATUS | ACTIVE, TERMINATED, SUSPENDED, ON_LEAVE | Trạng thái nhân viên |
| ASSIGNMENT_REASON | HIRE, TRANSFER, PROMOTION, DEMOTION, RETURN | Lý do thay đổi phân công |
| CONTRACT_TYPE | PERMANENT, FIXED_TERM, PROBATION, SEASONAL | Loại hợp đồng |
| DOCUMENT_TYPE | NATIONAL_ID, PASSPORT, DEGREE, CERTIFICATE | Loại tài liệu |

**Quy tắc Nghiệp vụ**:
- ✅ Các mã trong một nhóm phải là duy nhất
- ✅ Văn bản hiển thị hỗ trợ đa ngôn ngữ
- ✅ Mã không hoạt động không thể sử dụng cho bản ghi mới
- ✅ Mã lịch sử được giữ lại để báo cáo

**Ví dụ**:
```yaml
CodeList:
  - group: MARITAL_STATUS
    code: MARRIED
    display_en: "Married"
    display_local: "Đã kết hôn"
    sort_order: 2
    is_active: true
    metadata:
      icon: "💑"
      tax_impact: true
```

---

### Currency

**Định nghĩa**: Mã tiền tệ ISO-4217 với quy tắc về độ chính xác và định dạng.

**Mục đích**:
- Chuẩn hóa xử lý tiền tệ
- Hỗ trợ bảng lương đa tiền tệ
- Định nghĩa độ chính xác thập phân cho từng loại tiền
- Quản lý tỷ giá hối đoái

**Thuộc tính chính**:
- `code` - Mã ISO-4217 (VND, USD, EUR)
- `name` - Tên tiền tệ
- `symbol` - Ký hiệu tiền tệ (₫, $, €)
- `decimal_places` - Số chữ số thập phân (0 cho VND, 2 cho USD)
- `is_active` - Cờ hoạt động
- SCD Type 2

**Các Loại Tiền tệ Phổ biến**:
```yaml
Currencies:
  - code: VND
    name: "Vietnamese Dong"
    symbol: "₫"
    decimal_places: 0
    
  - code: USD
    name: "US Dollar"
    symbol: "$"
    decimal_places: 2
    
  - code: EUR
    name: "Euro"
    symbol: "€"
    decimal_places: 2
    
  - code: SGD
    name: "Singapore Dollar"
    symbol: "S$"
    decimal_places: 2
```

**Quy tắc Nghiệp vụ**:
- ✅ Mã tiền tệ tuân theo chuẩn ISO-4217
- ✅ Số chữ số thập phân xác định quy tắc làm tròn
- ✅ Được sử dụng trong lương, phụ cấp, yêu cầu thanh toán chi phí
- ✅ Tỷ giá hối đoái được quản lý riêng biệt

---

### TimeZone

**Định nghĩa**: Cơ sở dữ liệu múi giờ IANA để quản lý thời gian toàn cầu.

**Mục đích**:
- Hỗ trợ lực lượng lao động toàn cầu
- Theo dõi thời gian chính xác giữa các khu vực
- Xử lý giờ mùa hè (DST)
- Lên lịch họp

**Thuộc tính chính**:
- `code` - Mã múi giờ IANA
- `name` - Tên múi giờ
- `utc_offset` - Độ lệch UTC chuẩn
- `supports_dst` - Cờ hỗ trợ giờ mùa hè
- `is_active` - Cờ hoạt động

**Các Múi giờ Phổ biến**:
```yaml
TimeZones:
  - code: "Asia/Ho_Chi_Minh"
    name: "Indochina Time"
    utc_offset: "+07:00"
    supports_dst: false
    
  - code: "America/New_York"
    name: "Eastern Time"
    utc_offset: "-05:00"
    supports_dst: true
    
  - code: "Asia/Singapore"
    name: "Singapore Time"
    utc_offset: "+08:00"
    supports_dst: false
```

**Trường hợp Sử dụng**:
- Múi giờ địa điểm làm việc
- Lên lịch phân công toàn cầu
- Theo dõi chấm công
- Dấu thời gian tạo báo cáo

---

### Industry

**Định nghĩa**: Phân loại ngành nghề theo cấp bậc dựa trên chuẩn ISIC/NAICS.

**Mục đích**:
- Phân loại pháp nhân theo ngành nghề
- Hỗ trợ các quy định đặc thù của ngành
- So sánh chuẩn với tiêu chuẩn ngành
- Báo cáo và phân tích

**Thuộc tính chính**:
- `code` - Mã ngành
- `name` - Tên ngành
- `parent_id` - Ngành cha (phân cấp)
- `level` - Cấp độ phân cấp (1=lĩnh vực, 2=ngành, 3=nhóm)
- `path` - Đường dẫn vật lý
- SCD Type 2

**Ví dụ Phân cấp**:
```
Công nghệ (Cấp 1)
  ├─ Phần mềm (Cấp 2)
  │   ├─ SaaS (Cấp 3)
  │   ├─ Phần mềm Doanh nghiệp (Cấp 3)
  │   └─ Ứng dụng Di động (Cấp 3)
  └─ Phần cứng (Cấp 2)
      ├─ Bán dẫn (Cấp 3)
      └─ Điện tử Tiêu dùng (Cấp 3)

Dịch vụ Tài chính (Cấp 1)
  ├─ Ngân hàng (Cấp 2)
  └─ Bảo hiểm (Cấp 2)
```

**Quy tắc Nghiệp vụ**:
- ✅ Hỗ trợ tối đa 4 cấp độ phân cấp
- ✅ Pháp nhân liên kết với cấp độ thấp nhất có thể áp dụng
- ✅ Được sử dụng cho tuân thủ và báo cáo

---

### ContactType

**Định nghĩa**: Các loại phương thức liên hệ với quy tắc xác thực và định dạng.

**Mục đích**:
- Chuẩn hóa thông tin liên hệ
- Xác thực giá trị liên hệ
- Hỗ trợ nhiều kênh liên hệ
- Hiển thị giao diện người dùng (biểu tượng, mặt nạ nhập liệu)

**Thuộc tính chính**:
- `code` - Mã loại liên hệ
- `name` - Tên hiển thị
- `validation_regex` - Mẫu xác thực (Regex)
- `input_mask` - Mặt nạ định dạng nhập liệu
- `icon` - Tham chiếu biểu tượng giao diện
- `is_active` - Cờ hoạt động

**Các Loại Liên hệ**:
```yaml
ContactTypes:
  - code: MOBILE_PERSONAL
    name: "Di động Cá nhân"
    validation_regex: "^\\+?[0-9]{10,15}$"
    input_mask: "+84-###-###-####"
    icon: "📱"
    
  - code: EMAIL_WORK
    name: "Email Công việc"
    validation_regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
    icon: "📧"
    
  - code: LINKEDIN
    name: "Hồ sơ LinkedIn"
    validation_regex: "^(https?://)?(www\\.)?linkedin\\.com/in/[a-zA-Z0-9-]+/?$"
    icon: "💼"
    
  - code: WHATSAPP
    name: "WhatsApp"
    validation_regex: "^\\+?[0-9]{10,15}$"
    icon: "💬"
```

**Quy tắc Nghiệp vụ**:
- ✅ Giá trị liên hệ phải khớp với regex xác thực
- ✅ Mặt nạ nhập liệu hướng dẫn người dùng nhập
- ✅ Biểu tượng nâng cao trải nghiệm người dùng

---

### RelationshipGroup

**Định nghĩa**: Nhóm cấp cao của các loại mối quan hệ.

**Mục đích**:
- Tổ chức các loại mối quan hệ một cách logic
- Hỗ trợ các ngữ cảnh mối quan hệ khác nhau
- Cho phép phân quyền cấp nhóm

**Các Nhóm**:
```yaml
RelationshipGroups:
  - code: FAMILY
    name: "Quan hệ Gia đình"
    description: "Quan hệ huyết thống và hôn nhân"
    
  - code: FINANCIAL_DEPENDENT
    name: "Người phụ thuộc Tài chính"
    description: "Người phụ thuộc thuế và phúc lợi"
    
  - code: EMERGENCY
    name: "Liên hệ Khẩn cấp"
    description: "Người liên hệ khi khẩn cấp"
    
  - code: PROFESSIONAL
    name: "Mạng lưới Chuyên nghiệp"
    description: "Người hướng dẫn, người tham chiếu"
```

---

### RelationshipType

**Định nghĩa**: Các loại mối quan hệ cá nhân cụ thể giữa các nhân sự.

**Mục đích**:
- Định nghĩa quan hệ gia đình
- Theo dõi người phụ thuộc cho thuế/phúc lợi
- Liên hệ khẩn cấp
- Quản lý mối quan hệ nghịch đảo

**Thuộc tính chính**:
- `code` - Mã mối quan hệ
- `name` - Tên hiển thị
- `group_id` - Liên kết đến RelationshipGroup
- `inverse_type_id` - Mối quan hệ nghịch đảo (CHA ↔ CON TRAI)
- `affects_tax` - Ảnh hưởng đến tính thuế
- `is_active` - Cờ hoạt động

**Các Loại Mối quan hệ**:
```yaml
RelationshipTypes:
  - code: FATHER
    name: "Cha"
    group: FAMILY
    inverse: SON/DAUGHTER
    affects_tax: false
    
  - code: SPOUSE
    name: "Vợ/Chồng"
    group: FAMILY
    inverse: SPOUSE
    affects_tax: true
    
  - code: CHILD
    name: "Con"
    group: FAMILY
    inverse: FATHER/MOTHER
    affects_tax: true
    
  - code: DEPENDENT
    name: "Người phụ thuộc"
    group: FINANCIAL_DEPENDENT
    affects_tax: true
```

**Quy tắc Nghiệp vụ**:
- ✅ Mối quan hệ nghịch đảo được tạo tự động
- ✅ Mối quan hệ ảnh hưởng thuế được sử dụng trong bảng lương
- ✅ Liên hệ khẩn cấp phải có số điện thoại hợp lệ

---

### TalentMarket

**Định nghĩa**: Cấu trúc tổ chức đa thị trường cho hoạt động toàn cầu.

**Mục đích**:
- Hỗ trợ hoạt động đa quốc gia/khu vực
- Cấu hình đặc thù theo thị trường
- Cấu trúc thị trường phân cấp
- Bản địa hóa theo từng thị trường

**Thuộc tính chính**:
- `code` - Mã thị trường
- `name` - Tên thị trường
- `parent_id` - Thị trường cha (phân cấp)
- `country_code` - Quốc gia chính
- `currency_code` - Tiền tệ mặc định
- `timezone_code` - Múi giờ mặc định
- `metadata` - Cấu hình đặc thù thị trường (quy tắc thâm niên, thời gian thử việc)

**Phân cấp Thị trường**:
```yaml
TalentMarkets:
  - code: GLOBAL
    name: "Thị trường Toàn cầu"
    parent: null
    
  - code: APAC
    name: "Châu Á Thái Bình Dương"
    parent: GLOBAL
    
  - code: VN
    name: "Thị trường Việt Nam"
    parent: APAC
    country: VN
    currency: VND
    timezone: "Asia/Ho_Chi_Minh"
    metadata:
      probation_months: 2
      notice_period_days: 30
      
  - code: SG
    name: "Thị trường Singapore"
    parent: APAC
    country: SG
    currency: SGD
    timezone: "Asia/Singapore"
```

**Trường hợp Sử dụng**:
- Đăng tuyển dụng theo thị trường
- Nguồn nhân tài khu vực
- Chính sách nhân sự bản địa hóa
- Luân chuyển giữa các thị trường

---

### SkillMaster

**Định nghĩa**: Danh mục các kỹ năng kỹ thuật và chức năng.

**Mục đích**:
- Chuẩn hóa phân loại kỹ năng
- Hỗ trợ khớp nối dựa trên kỹ năng
- Định nghĩa thang đo thành thạo
- Lập kế hoạch phát triển nghề nghiệp

**Thuộc tính chính**:
- `code` - Mã kỹ năng
- `name` - Tên kỹ năng
- `category_code` - Danh mục kỹ năng (KỸ THUẬT, CHỨC NĂNG, NGÔN NGỮ)
- `proficiency_scale_id` - Liên kết đến thang đo thành thạo
- `is_active` - Cờ hoạt động
- `metadata` - Chứng chỉ liên quan, tài liệu học tập

**Danh mục Kỹ năng & Ví dụ**:
```yaml
SkillMaster:
  # Kỹ năng Kỹ thuật
  - code: PYTHON
    name: "Lập trình Python"
    category: TECHNICAL
    proficiency_scale: TECH_5_LEVEL
    metadata:
      certifications: ["PCEP", "PCAP"]
      
  - code: AWS
    name: "Amazon Web Services"
    category: TECHNICAL
    proficiency_scale: TECH_5_LEVEL
    
  # Kỹ năng Chức năng
  - code: PROJECT_MGMT
    name: "Quản lý Dự án"
    category: FUNCTIONAL
    proficiency_scale: FUNC_5_LEVEL
    metadata:
      certifications: ["PMP", "PRINCE2"]
      
  # Kỹ năng Ngôn ngữ
  - code: ENGLISH
    name: "Tiếng Anh"
    category: LANGUAGE
    proficiency_scale: CEFR
    metadata:
      scale_levels: ["A1", "A2", "B1", "B2", "C1", "C2"]
```

**Thang đo Thành thạo**:
- TECH_5_LEVEL: 1-5 (Mới bắt đầu đến Chuyên gia)
- FUNC_5_LEVEL: 1-5 (Cơ bản đến Nâng cao)
- CEFR: A1-C2 (Thành thạo ngôn ngữ)

**Quy tắc Nghiệp vụ**:
- ✅ Kỹ năng được liên kết với hồ sơ công việc
- ✅ Nhân sự được đánh giá dựa trên thang đo thành thạo
- ✅ Phân tích khoảng cách cho kế hoạch phát triển

---

### CompetencyMaster

**Định nghĩa**: Danh mục các năng lực hành vi (kỹ năng mềm).

**Mục đích**:
- Định nghĩa năng lực lãnh đạo/hành vi
- Khung đánh giá hiệu suất
- Lập kế hoạch kế nhiệm
- Phản hồi 360 độ

**Thuộc tính chính**:
- `code` - Mã năng lực
- `name` - Tên năng lực
- `category_code` - Danh mục (LÃNH ĐẠO, TƯƠNG TÁC, NHẬN THỨC)
- `rating_scale_id` - Thang đánh giá
- `description` - Mô tả chi tiết
- `behavioral_indicators` - Các hành vi quan sát được

**Ví dụ Năng lực**:
```yaml
CompetencyMaster:
  - code: LEADERSHIP
    name: "Lãnh đạo"
    category: LEADERSHIP
    rating_scale: "1-5"
    description: "Khả năng truyền cảm hứng và dẫn dắt cá nhân hoặc đội nhóm"
    behavioral_indicators:
      - "Thiết lập tầm nhìn và định hướng rõ ràng"
      - "Trao quyền cho thành viên nhóm"
      - "Đưa ra quyết định dứt khoát"
      
  - code: COMMUNICATION
    name: "Giao tiếp"
    category: INTERPERSONAL
    rating_scale: "1-5"
    behavioral_indicators:
      - "Trình bày ý tưởng rõ ràng"
      - "Lắng nghe chủ động"
      - "Thích ứng phong cách giao tiếp"
      
  - code: PROBLEM_SOLVING
    name: "Giải quyết Vấn đề"
    category: COGNITIVE
    rating_scale: "1-5"
    behavioral_indicators:
      - "Phân tích các tình huống phức tạp"
      - "Đưa ra các giải pháp sáng tạo"
      - "Ra quyết định dựa trên dữ liệu"
```

**Các Năng lực Phổ biến**:
- Lãnh đạo
- Giao tiếp
- Làm việc nhóm & Hợp tác
- Giải quyết Vấn đề
- Đổi mới & Sáng tạo
- Tập trung vào Khách hàng
- Khả năng Thích ứng
- Tư duy Chiến lược

**Trường hợp Sử dụng**:
- Đánh giá hiệu suất
- Phát triển lãnh đạo
- Lập kế hoạch kế nhiệm
- Đánh giá tuyển dụng

---

## 💡 Thực tiễn Tốt nhất

### Quản lý Mã
- ✅ Sử dụng mã có ý nghĩa, tự giải thích
- ✅ Giữ mã ổn định (không thay đổi mã hiện có)
- ✅ Hủy kích hoạt thay vì xóa
- ✅ Tài liệu hóa ý nghĩa mã trong metadata

### Bản địa hóa
- ✅ Luôn cung cấp cả tiếng Anh và ngôn ngữ địa phương
- ✅ Sử dụng Unicode cho các ký tự không phải ASCII
- ✅ Kiểm tra hiển thị trên tất cả các ngôn ngữ được hỗ trợ

### Quản lý Phân cấp
- ✅ Sử dụng đường dẫn vật lý để tối ưu truy vấn
- ✅ Giới hạn độ sâu phân cấp (thường là 3-4 cấp)
- ✅ Xác thực mối quan hệ cha-con

---

## 🔗 Các Thuật ngữ Liên quan

- **Person** - Sử dụng ContactType, RelationshipType, SkillMaster, CompetencyMaster
- **Employment** - Tham chiếu Currency, TimeZone, CodeList
- **JobPosition** - Sử dụng Industry, SkillMaster
- **LegalEntity** - Sử dụng Industry, Currency

---

**Phiên bản Tài liệu**: 2.0  
**Đánh giá lần cuối**: 01/12/2025
