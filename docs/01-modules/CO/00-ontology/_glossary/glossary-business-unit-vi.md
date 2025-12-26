# BusinessUnit Sub-Module - Thuật ngữ

**Phiên bản**: 2.0  
**Cập nhật lần cuối**: 01/12/2025  
**Phân hệ con**: Đơn vị Tổ chức Vận hành

---

## 📋 Tổng quan

Business Units (Đơn vị Kinh doanh) đại diện cho cấu trúc vận hành của tổ chức (khối, phòng ban, nhóm). Cấu trúc này tách biệt với cấu trúc pháp nhân (legal entity) và hỗ trợ mô hình hóa tổ chức linh hoạt.

**Mới trong v2.0**: Khái niệm Tổ chức Giám sát (Supervisory Organization) tách biệt hệ thống báo cáo/phê duyệt khỏi cấu trúc vận hành.

### Thực thể (3)
1. **UnitType** 🔄 (Nâng cấp hỗ trợ Supervisory)
2. **Unit** - Các đơn vị kinh doanh cụ thể
3. **UnitTag** - Phân loại đơn vị linh hoạt

---

## 🔑 Các Thực thể Chính

### UnitType 🔄 NÂNG CẤP

**Định nghĩa**: Các loại đơn vị kinh doanh định nghĩa nên cấu trúc tổ chức.

**Mục đích**:
- Phân loại các đơn vị kinh doanh theo chức năng và mục đích
- Định nghĩa các quy tắc và ràng buộc phân cấp
- Hỗ trợ cả cấu trúc vận hành và cấu trúc giám sát
- Cho phép cấu hình đặc thù theo tổ chức

**Thuộc tính chính**:
- `code` - Mã loại đơn vị
- `name` - Tên hiển thị
- `level_order` - Cấp độ phân cấp (1=cao nhất, ví dụ: Khối/Division)
- `is_supervisory` ✨ - Cờ đánh dấu tổ chức giám sát (MỚI trong v2.0)
- `metadata` - Cấu hình đặc thù cho loại đơn vị
- Các trường SCD Type 2

**Các Loại Đơn vị** (Nâng cấp trong v2.0):

| Mã | Tên | Cấp độ | Giám sát | Mục đích |
|----|-----|--------|----------|----------|
| DIVISION | Khối (Division) | 1 | Không | Đơn vị kinh doanh cấp cao nhất |
| DEPARTMENT | Phòng ban (Department) | 2 | Không | Phòng ban trong khối |
| TEAM | Nhóm (Team) | 3 | Không | Nhóm làm việc |
| ✨ SUPERVISORY | Tổ chức Giám sát | Đa dạng | Có | Hệ thống báo cáo/phê duyệt |
| ✨ COST_CENTER | Trung tâm Chi phí | Đa dạng | Không | Đơn vị kế toán chi phí |
| ✨ MATRIX | Tổ chức Ma trận | Đa dạng | Không | Đơn vị tổ chức ma trận |
| PROJECT | Nhóm Dự án | 3 | Không | Tổ chức dự án tạm thời |

**Giám sát vs Vận hành** ✨ KHÁI NIỆM MỚI:

```yaml
# Cấu trúc Vận hành (cách tổ chức công việc)
UnitTypes:
  - code: DIVISION
    level_order: 1
    is_supervisory: false
    
  - code: DEPARTMENT
    level_order: 2
    is_supervisory: false
    
  - code: TEAM
    level_order: 3
    is_supervisory: false

# Cấu trúc Giám sát (hệ thống báo cáo/phê duyệt)
  - code: SUPERVISORY
    level_order: null  # Có thể tồn tại ở bất kỳ cấp nào
    is_supervisory: true
    metadata:
      purpose: "Hệ thống báo cáo và phê duyệt"
      affects_security: true
      affects_approvals: true
```

**Tại sao cần Tổ chức Giám sát?**

Trong nhiều doanh nghiệp, **cấu trúc vận hành** (cách tổ chức công việc) khác với **cấu trúc báo cáo** (ai báo cáo cho ai):

```
Cấu trúc Vận hành:
  Khối Kinh doanh (Sales Division)
    ├─ Phòng Kinh doanh Doanh nghiệp (Enterprise Sales Dept)
    ├─ Phòng Kinh doanh SMB (SMB Sales Dept)
    └─ Phòng Kinh doanh Kênh (Channel Sales Dept)

Cấu trúc Giám sát (cho báo cáo/phê duyệt):
  Phó Tổng Giám đốc Kinh doanh (Tổ chức Giám sát)
    ├─ Giám đốc Kinh doanh Khu vực APAC
    │   ├─ Giám đốc Quốc gia Việt Nam
    │   └─ Giám đốc Quốc gia Singapore
    └─ Giám đốc Kinh doanh Khu vực EMEA
```

**Quy tắc Nghiệp vụ**:
- ✅ Đơn vị loại SUPERVISORY định nghĩa hệ thống báo cáo và chuỗi phê duyệt
- ✅ Tổ chức giám sát có thể khác với cấu trúc vận hành (DIVISION/DEPARTMENT)
- ✅ Quyền bảo mật thường gắn liền với thành viên của tổ chức giám sát
- ✅ Một nhân viên có thể thuộc đơn vị vận hành VÀ tổ chức giám sát
- ✅ Quy trình phê duyệt tuân theo hệ thống giám sát, không phải vận hành

**Ví dụ Metadata**:
```yaml
UnitType: SUPERVISORY
metadata:
  allowed_child_types: ["SUPERVISORY"]
  requires_manager: true
  approval_authority_levels:
    - EXPENSE_APPROVAL: 10000
    - LEAVE_APPROVAL: true
    - HIRE_APPROVAL: true
  security_implications:
    - "Thành viên kế thừa quyền truy cập dữ liệu từ tổ chức giám sát"
    - "Quản lý có thể xem dữ liệu của cấp dưới"
```

---

### Unit

**Định nghĩa**: Một đơn vị kinh doanh cụ thể đại diện cho một đơn vị tổ chức.

**Mục đích**:
- Đại diện cho cấu trúc tổ chức vận hành
- Hỗ trợ sơ đồ tổ chức phân cấp
- Liên kết nhân viên với các đơn vị tổ chức
- Cho phép báo cáo và phân tích theo tổ chức

**Thuộc tính chính**:
- `id` - Định danh đơn vị duy nhất
- `code` - Mã đơn vị (ví dụ: BU-SALES-HCMC)
- `name` - Tên đơn vị
- `type_id` - Liên kết đến UnitType
- `parent_id` - Đơn vị cha (cho phân cấp)
- `legal_entity_code` - Pháp nhân liên kết
- `manager_worker_id` - Quản lý đơn vị
- `path` - Đường dẫn vật lý (ví dụ: /division/department/team)
- `level` - Cấp độ phân cấp (tính toán từ path)
- `cost_center_code` - Trung tâm chi phí liên kết
- `location_id` - Địa điểm chính
- `metadata` - Dữ liệu đặc thù của đơn vị
- Các trường SCD Type 2

**Ví dụ Phân cấp**:
```yaml
# Phân cấp Vận hành
Units:
  - code: VNG-CORP
    name: "VNG Corporation"
    type: DIVISION
    parent: null
    path: "/VNG-CORP"
    level: 1
    
  - code: VNG-ENG
    name: "Khối Kỹ thuật (Engineering Division)"
    type: DIVISION
    parent: VNG-CORP
    path: "/VNG-CORP/VNG-ENG"
    level: 2
    manager: WORKER-001
    
  - code: VNG-ENG-BACKEND
    name: "Phòng Kỹ thuật Backend"
    type: DEPARTMENT
    parent: VNG-ENG
    path: "/VNG-CORP/VNG-ENG/VNG-ENG-BACKEND"
    level: 3
    manager: WORKER-010
    
  - code: VNG-ENG-BACKEND-API
    name: "Nhóm API"
    type: TEAM
    parent: VNG-ENG-BACKEND
    path: "/VNG-CORP/VNG-ENG/VNG-ENG-BACKEND/VNG-ENG-BACKEND-API"
    level: 4
    manager: WORKER-050

# Phân cấp Giám sát (cấu trúc song song)
  - code: SUP-ENG-VP
    name: "Tổ chức Giám sát VP Kỹ thuật"
    type: SUPERVISORY
    parent: null
    is_supervisory: true
    manager: WORKER-001
    metadata:
      approval_levels:
        expense: 50000
        hire: true
        
  - code: SUP-ENG-DIR-BACKEND
    name: "Giám đốc Kỹ thuật Backend"
    type: SUPERVISORY
    parent: SUP-ENG-VP
    is_supervisory: true
    manager: WORKER-010
```

**Quy tắc Nghiệp vụ**:
- ✅ Phải liên kết với pháp nhân (mọi đơn vị đều thuộc về một pháp nhân)
- ✅ Path phải phản ánh phân cấp thực tế
- ✅ Đơn vị cha phải có level_order cao hơn hoặc bằng
- ✅ Quản lý phải có phân công (assignment) hoạt động trong cùng đơn vị hoặc đơn vị cha
- ✅ Không thể xóa đơn vị đang có nhân viên hoạt động
- ✅ SCD Type 2 theo dõi các thay đổi tổ chức theo thời gian

**Ví dụ Metadata**:
```yaml
Unit: Engineering Division
metadata:
  budget_annual: 10000000
  headcount_target: 150
  headcount_actual: 142
  strategic_focus:
    - "Hạ tầng Cloud"
    - "Nền tảng AI/ML"
  kpis:
    - name: "Tần suất Triển khai"
      target: "10/ngày"
    - name: "MTTR (Thời gian trung bình phục hồi)"
      target: "< 1 giờ"
```

---

### UnitTag

**Định nghĩa**: Hệ thống gắn thẻ linh hoạt cho các đơn vị kinh doanh để hỗ trợ phân loại chéo.

**Mục đích**:
- Thêm các phân loại linh hoạt ngoài phân cấp
- Hỗ trợ các góc nhìn tổ chức ma trận
- Cho phép nhóm và lọc động
- Báo cáo và phân tích dựa trên thẻ

**Thuộc tính chính**:
- `unit_id` - Đơn vị được gắn thẻ
- `tag_type_code` - Danh mục thẻ (từ CodeList)
- `tag_value` - Giá trị thẻ
- `is_primary` - Thẻ chính của loại này
- SCD Type 2

**Các Loại Thẻ Phổ biến**:

| Loại Thẻ | Giá trị | Mục đích |
|----------|---------|----------|
| REGION | APAC, EMEA, AMERICAS | Khu vực địa lý |
| COST_CENTER | CC-1000, CC-2000 | Kế toán chi phí |
| STRATEGIC_INITIATIVE | DIGITAL_TRANSFORM, CLOUD_FIRST | Chương trình chiến lược |
| CUSTOMER_SEGMENT | ENTERPRISE, SMB, CONSUMER | Phân khúc khách hàng |
| PRODUCT_LINE | PRODUCT_A, PRODUCT_B | Dòng sản phẩm |
| INNOVATION_LAB | YES, NO | Chỉ định đổi mới sáng tạo |
| REMOTE_FIRST | YES, NO | Chính sách làm việc từ xa |

**Các Trường hợp Sử dụng**:

#### 1. Nhóm theo Khu vực
```yaml
# Gắn thẻ đơn vị theo khu vực (phân cấp chéo)
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: REGION
    tag_value: APAC
    
  - unit: VNG-SALES-VIETNAM
    tag_type: REGION
    tag_value: APAC
    
  - unit: VNG-SALES-SINGAPORE
    tag_type: REGION
    tag_value: APAC

# Truy vấn: Tất cả các đơn vị APAC trên toàn bộ các khối
```

#### 2. Ánh xạ Trung tâm Chi phí
```yaml
# Nhiều đơn vị có thể chia sẻ cùng một trung tâm chi phí
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: COST_CENTER
    tag_value: CC-ENG-1000
    
  - unit: VNG-ENG-FRONTEND
    tag_type: COST_CENTER
    tag_value: CC-ENG-1000
    
  - unit: VNG-ENG-MOBILE
    tag_type: COST_CENTER
    tag_value: CC-ENG-2000
```

#### 3. Theo dõi Sáng kiến Chiến lược
```yaml
# Gắn thẻ các đơn vị tham gia vào các sáng kiến chiến lược
UnitTags:
  - unit: VNG-ENG-BACKEND
    tag_type: STRATEGIC_INITIATIVE
    tag_value: CLOUD_MIGRATION
    
  - unit: VNG-ENG-DEVOPS
    tag_type: STRATEGIC_INITIATIVE
    tag_value: CLOUD_MIGRATION
    
  - unit: VNG-SALES-ENTERPRISE
    tag_type: STRATEGIC_INITIATIVE
    tag_value: DIGITAL_TRANSFORM
```

**Quy tắc Nghiệp vụ**:
- ✅ Cho phép nhiều thẻ trên mỗi đơn vị
- ✅ Một thẻ chính (primary) cho mỗi loại thẻ
- ✅ Thẻ không ảnh hưởng đến phân cấp
- ✅ Giá trị thẻ lấy từ CodeList để đảm bảo nhất quán

---

## 💡 Đi sâu vào Tổ chức Giám sát (Supervisory Organization) ✨ MỚI

### Giải quyết Vấn đề gì?

**Vấn đề**: Trong các tổ chức thực tế, **cách tổ chức công việc** (cấu trúc vận hành) thường khác với **ai báo cáo cho ai** (cấu trúc báo cáo).

**Kịch bản Ví dụ**:
```
Công ty: Global Tech Corp

Cấu trúc Vận hành (cách các nhóm được tổ chức):
  Kỹ thuật (Engineering)
    ├─ Nhóm Backend (Việt Nam)
    ├─ Nhóm Frontend (Việt Nam)
    ├─ Nhóm Mobile (Singapore)
    └─ Nhóm DevOps (Singapore)

Cấu trúc Báo cáo (ai phê duyệt cái gì):
  CTO
    ├─ VP Kỹ thuật APAC
    │   ├─ Quản lý Kỹ thuật Việt Nam (quản lý Backend + Frontend)
    │   └─ Quản lý Kỹ thuật Singapore (quản lý Mobile + DevOps)
    └─ VP Kỹ thuật EMEA
        └─ ...
```

### Cách Tổ chức Giám sát Hoạt động

**1. Thành viên Kép (Dual Membership)**:
```yaml
Nhân viên: John (Kỹ sư Backend)
  Phân công Vận hành:
    business_unit: Nhóm Backend
    
  Phân công Giám sát:
    supervisory_org: Quản lý Kỹ thuật Việt Nam
    manager: WORKER-MGR-VN
```

**2. Luồng Phê duyệt**:
```yaml
# Yêu cầu nghỉ phép của John
Chuỗi Phê duyệt:
  1. Quản lý Trực tiếp (từ Tổ chức Giám sát): Quản lý Kỹ thuật Việt Nam
  2. Cấp trên gián tiếp (Skip Level - từ Tổ chức Giám sát): VP Kỹ thuật APAC
  3. Cuối cùng (từ Tổ chức Giám sát): CTO

# KHÔNG dựa trên cấu trúc vận hành!
```

**3. Bảo mật & Truy cập Dữ liệu**:
```yaml
Quản lý Kỹ thuật Việt Nam (Tổ chức Giám sát):
  Có thể truy cập dữ liệu của:
    - Tất cả thành viên của tổ chức giám sát "Quản lý Kỹ thuật Việt Nam"
    - Bao gồm: Thành viên Nhóm Backend + Nhóm Frontend
    
  Không thể truy cập:
    - Nhóm Mobile (tổ chức giám sát khác)
    - Nhóm DevOps (tổ chức giám sát khác)
```

### Các Mẫu Triển khai

**Mẫu 1: Cấu trúc Song song**
```yaml
# Duy trì cả hai cấu trúc riêng biệt
Đơn vị Vận hành:
  - Nhóm Backend
  - Nhóm Frontend
  
Tổ chức Giám sát:
  - Quản lý Kỹ thuật Việt Nam (chứa cả hai nhóm)
```

**Mẫu 2: Cách tiếp cận Lai**
```yaml
# Một số đơn vị vừa là vận hành VỪA là giám sát
Unit: Khối Kỹ thuật
  is_operational: true
  is_supervisory: true
  manager: VP Kỹ thuật
```

**Mẫu 3: Tổ chức Ma trận**
```yaml
Nhân viên: Jane
  Đơn vị Vận hành: Nhóm Sản phẩm A
  Tổ chức Giám sát (Chức năng): Quản lý Kỹ thuật
  Tổ chức Giám sát (Dự án): Trưởng Dự án Alpha
  
  # Báo cáo kép: chức năng + dự án
```

---

## 🔄 Các Kịch bản Phổ biến

### Kịch bản 1: Phân cấp Đơn giản
```yaml
# Phân cấp đơn truyền thống
Công ty
  ├─ Khối Kinh doanh
  │   ├─ Kinh doanh Doanh nghiệp
  │   └─ Kinh doanh SMB
  └─ Khối Kỹ thuật
      ├─ Backend
      └─ Frontend

# Vận hành = Giám sát (cùng cấu trúc)
```

### Kịch bản 2: Ma trận Địa lý
```yaml
# Vận hành theo chức năng, Giám sát theo địa lý
Vận hành:
  Kỹ thuật
    ├─ Backend
    ├─ Frontend
    └─ Mobile

Giám sát:
  Kỹ thuật APAC
    ├─ Quản lý Kỹ thuật Việt Nam
    └─ Quản lý Kỹ thuật Singapore
```

### Kịch bản 3: Tái cơ cấu
```yaml
# Trước (01/01/2024 đến 30/06/2024)
Unit: Nhóm Backend
  parent: Khối Kỹ thuật
  manager: WORKER-001
  effective_start: 2024-01-01
  effective_end: 2024-06-30
  is_current: false

# Sau (từ 01/07/2024)
Unit: Nhóm Backend
  parent: Khối Nền tảng (Platform Division)  # Thay đổi!
  manager: WORKER-002                        # Quản lý mới!
  effective_start: 2024-07-01
  effective_end: null
  is_current: true

# SCD Type 2 lưu giữ lịch sử
```

---

## ⚠️ Lưu ý Quan trọng

### Thực tiễn Tốt nhất cho Tổ chức Giám sát
- ✅ Sử dụng tổ chức giám sát cho các luồng phê duyệt
- ✅ Sử dụng tổ chức giám sát cho bảo mật/truy cập dữ liệu
- ✅ Giữ cấu trúc vận hành đơn giản và ổn định
- ✅ Cho phép cấu trúc giám sát linh động hơn
- ⚠️ Đừng trộn lẫn vận hành và giám sát trong cùng một phân cấp

### Hướng dẫn Phân cấp Đơn vị
- ✅ Giữ độ sâu phân cấp hợp lý (tối đa 3-5 cấp)
- ✅ Sử dụng đường dẫn vật lý (materialized path) để tối ưu truy vấn
- ✅ Cập nhật đường dẫn khi phân cấp thay đổi
- ✅ Sử dụng thẻ (tags) cho các mối quan tâm chéo
- ⚠️ Tránh tham chiếu vòng

### Quản lý Thay đổi Tổ chức
- ✅ Lập kế hoạch tái cơ cấu cẩn thận
- ✅ Sử dụng SCD Type 2 để lưu giữ lịch sử
- ✅ Thông báo thay đổi cho nhân viên bị ảnh hưởng
- ✅ Cập nhật quan hệ báo cáo trong các phân công (assignments)
- ⚠️ Xem xét tác động đến các phê duyệt đang diễn ra

---

## 🔗 Các Thuật ngữ Liên quan

- **LegalEntity** - Cấu trúc pháp nhân cha
- **Employment** - Phân công vào đơn vị
- **OrganizationRelation** - Quan hệ động giữa các đơn vị
- **Person** - Nhân viên được phân công vào đơn vị

---

## 📚 Tài liệu Tham khảo

- Workday: Khái niệm Supervisory Organization
- SAP SuccessFactors: Quản lý Tổ chức (Organizational Management)
- Oracle HCM: Cấu trúc Tổ chức (Organization Structures)

---

**Phiên bản Tài liệu**: 2.0  
**Đánh giá lần cuối**: 01/12/2025
