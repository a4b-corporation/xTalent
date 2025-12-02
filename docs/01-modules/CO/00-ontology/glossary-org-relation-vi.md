# Phân hệ con OrganizationRelation - Thuật ngữ

**Phiên bản**: 2.0  
**Cập nhật lần cuối**: 01/12/2025  
**Phân hệ con**: Quan hệ Tổ chức Động

---

## 📋 Tổng quan

Phân hệ con OrganizationRelation cho phép mô hình hóa các mối quan hệ phức tạp, động giữa các thực thể tổ chức, vượt ra ngoài các phân cấp đơn giản. Điều này hỗ trợ các tổ chức ma trận, nhóm dự án, cấu trúc báo cáo tài chính và các mối quan hệ phi phân cấp khác.

**Mục đích**: Cung cấp sự linh hoạt để mô hình hóa nhiều đồ thị quan hệ chồng lên cấu trúc tổ chức.

### Thực thể (3)
1. **RelationSchema** - Mẫu đồ thị quan hệ
2. **RelationType** 🔄 (Nâng cấp với các loại báo cáo rõ ràng)
3. **RelationEdge** - Các thể hiện quan hệ thực tế

---

## 🔑 Các Thực thể Chính

### RelationType 🔄 NÂNG CẤP

**Định nghĩa**: Các loại mối quan hệ có thể tồn tại giữa các thực thể tổ chức (pháp nhân, đơn vị kinh doanh, vị trí).

**Mục đích**:
- Định nghĩa ngữ nghĩa của mối quan hệ
- Hỗ trợ nhiều ngữ cảnh mối quan hệ
- Cho phép tổ chức ma trận và mạng lưới
- Phân biệt mối quan hệ chính và phụ

**Thuộc tính chính**:
- `code` - Mã loại mối quan hệ
- `name` - Tên hiển thị
- `relationship_category` ✨ - Danh mục (MỚI trong v2.0)
  - `STRUCTURAL` - Cấu trúc tổ chức
  - `REPORTING` - Quan hệ báo cáo
  - `FUNCTIONAL` - Quan hệ chức năng
  - `FINANCIAL` - Luồng tài chính/ngân sách
- `is_primary_reporting` ✨ - Cờ báo cáo chính (MỚI)
- `affects_approval_chain` ✨ - Ảnh hưởng đến phê duyệt (MỚI)
- `is_bidirectional` - Quan hệ hai chiều
- `inverse_type_id` - Loại quan hệ nghịch đảo
- `metadata` - Thuộc tính bổ sung
- SCD Type 2

**Các Loại Mối quan hệ** (Nâng cấp trong v2.0):

| Mã | Danh mục | Chính | Ảnh hưởng Phê duyệt | Mô tả |
|----|----------|-------|---------------------|-------|
| OWNERSHIP | STRUCTURAL | N/A | Không | Sở hữu pháp lý/cổ phần |
| ✨ REPORTING_SOLID_LINE | REPORTING | Có | Có | Báo cáo chính (quản lý trực tiếp) |
| ✨ REPORTING_DOTTED_LINE | REPORTING | Không | Không | Báo cáo phụ/ma trận |
| FUNCTIONAL | FUNCTIONAL | Không | Không | Quan hệ chức năng không có thẩm quyền |
| MATRIX | STRUCTURAL | Không | Đa dạng | Quan hệ tổ chức ma trận |
| DELEGATION | FUNCTIONAL | Không | Có | Ủy quyền |
| BUDGET_FLOW | FINANCIAL | N/A | Không | Luồng phân bổ ngân sách |
| COST_ALLOCATION | FINANCIAL | N/A | Không | Chia sẻ/phân bổ chi phí |
| PROJECT_MEMBERSHIP | FUNCTIONAL | Không | Không | Thành viên nhóm dự án |

**Báo cáo Nét liền vs Nét đứt** ✨ NÂNG CẤP:

```yaml
RelationTypes:
  - code: REPORTING_SOLID_LINE
    name: "Báo cáo Nét liền (Solid Line)"
    category: REPORTING
    is_primary_reporting: true
    affects_approval_chain: true
    description: "Quan hệ báo cáo chính"
    metadata:
      implications:
        - "Đánh giá hiệu suất"
        - "Phê duyệt nghỉ phép"
        - "Quyết định lương thưởng"
        - "Phát triển nghề nghiệp"
        
  - code: REPORTING_DOTTED_LINE
    name: "Báo cáo Nét đứt (Dotted Line)"
    category: REPORTING
    is_primary_reporting: false
    affects_approval_chain: false
    description: "Báo cáo phụ/ma trận"
    metadata:
      implications:
        - "Hướng dẫn dự án"
        - "Chuyên môn chức năng"
        - "Chỉ mang tính thông tin"
        - "Không có thẩm quyền phê duyệt"
```

**Quy tắc Nghiệp vụ**:
- ✅ Chỉ báo cáo nét liền ảnh hưởng đến chuỗi phê duyệt
- ✅ Báo cáo nét đứt chỉ mang tính thông tin/hướng dẫn
- ✅ Một quan hệ báo cáo chính cho mỗi nhân viên
- ✅ Cho phép nhiều quan hệ báo cáo nét đứt
- ✅ Báo cáo nét liền thường tuân theo tổ chức giám sát
- ✅ Báo cáo nét đứt hỗ trợ tổ chức ma trận

**Ví dụ - Tổ chức Ma trận**:
```yaml
Kỹ sư: John
  Nét liền (Chính):
    type: REPORTING_SOLID_LINE
    to: Quản lý Kỹ thuật (Chức năng)
    affects_approvals: true
    
  Nét đứt (Phụ):
    type: REPORTING_DOTTED_LINE
    to: Trưởng Dự án Alpha (Dự án)
    affects_approvals: false
    
  # Đánh giá hiệu suất: Quản lý Kỹ thuật
  # Phê duyệt nghỉ phép: Quản lý Kỹ thuật
  # Hướng dẫn dự án: Trưởng Dự án Alpha
```

---

### RelationSchema

**Định nghĩa**: Định nghĩa một mẫu đồ thị quan hệ (schema) cho một mục đích cụ thể.

**Mục đích**:
- Tạo nhiều đồ thị quan hệ độc lập
- Hỗ trợ các góc nhìn tổ chức khác nhau
- Cho phép các mối quan hệ theo ngữ cảnh cụ thể
- Duy trì sự phân tách các mối quan tâm

**Thuộc tính chính**:
- `code` - Mã schema
- `name` - Tên schema
- `description` - Mục đích và cách sử dụng
- `applies_to` - Các loại thực thể (LEGAL_ENTITY, BUSINESS_UNIT, POSITION)
- `allowed_relation_types` - Các loại mối quan hệ được phép
- `is_active` - Cờ hoạt động
- `metadata` - Quy tắc đặc thù của schema

**Các Schema Phổ biến**:

#### 1. Tổ chức Báo cáo
```yaml
RelationSchema:
  code: REPORTING_ORG
  name: "Tổ chức Báo cáo"
  description: "Cấu trúc báo cáo chính thức (nét liền + nét đứt)"
  applies_to: [POSITION, BUSINESS_UNIT]
  allowed_relation_types:
    - REPORTING_SOLID_LINE
    - REPORTING_DOTTED_LINE
  metadata:
    purpose: "Quản lý hiệu suất, phê duyệt"
    update_frequency: "Khi cần thiết"
```

#### 2. Báo cáo Tài chính
```yaml
RelationSchema:
  code: FINANCIAL_REPORTING
  name: "Cấu trúc Báo cáo Tài chính"
  description: "Luồng ngân sách và phân bổ chi phí"
  applies_to: [BUSINESS_UNIT, LEGAL_ENTITY]
  allowed_relation_types:
    - BUDGET_FLOW
    - COST_ALLOCATION
  metadata:
    purpose: "Hợp nhất tài chính, P&L"
    update_frequency: "Hàng tháng"
```

#### 3. Ma trận Dự án
```yaml
RelationSchema:
  code: PROJECT_MATRIX
  name: "Tổ chức Dự án"
  description: "Cấu trúc nhóm dự án và các mối quan hệ"
  applies_to: [POSITION, BUSINESS_UNIT]
  allowed_relation_types:
    - PROJECT_MEMBERSHIP
    - REPORTING_DOTTED_LINE
  metadata:
    purpose: "Quản lý dự án, phân bổ nguồn lực"
    temporary: true
```

#### 4. Mạng lưới Đổi mới
```yaml
RelationSchema:
  code: INNOVATION_NETWORK
  name: "Mạng lưới Hợp tác Đổi mới"
  description: "Quan hệ đổi mới liên chức năng"
  applies_to: [BUSINESS_UNIT, POSITION]
  allowed_relation_types:
    - FUNCTIONAL
    - MATRIX
  metadata:
    purpose: "Chia sẻ kiến thức, hợp tác"
    informal: true
```

**Quy tắc Nghiệp vụ**:
- ✅ Nhiều schema có thể cùng tồn tại
- ✅ Cùng một thực thể có thể tham gia vào nhiều schema
- ✅ Mỗi schema có quy tắc quan hệ riêng
- ✅ Schema có thể tạm thời (dự án) hoặc vĩnh viễn

---

### RelationEdge

**Định nghĩa**: Thể hiện quan hệ thực tế (cạnh trong đồ thị) giữa hai thực thể tổ chức.

**Mục đích**:
- Đại diện cho các mối quan hệ cụ thể
- Liên kết các thực thể trong đồ thị quan hệ
- Hỗ trợ quan hệ có trọng số/thuộc tính
- Cho phép truy vấn và phân tích đồ thị

**Thuộc tính chính**:
- `schema_id` - Đồ thị quan hệ nào
- `from_entity_type` - Loại thực thể nguồn (LEGAL_ENTITY, BUSINESS_UNIT, POSITION)
- `from_entity_id` - ID thực thể nguồn
- `to_entity_type` - Loại thực thể đích
- `to_entity_id` - ID thực thể đích
- `relation_type_id` - Loại mối quan hệ
- `weight` - Trọng số/độ mạnh quan hệ (0.0-1.0)
- `percentage` - Tỷ lệ phân bổ (ví dụ: 60% thời gian cho dự án)
- `metadata` - Thuộc tính đặc thù của cạnh
- SCD Type 2

**Ví dụ 1 - Báo cáo Ma trận**:
```yaml
# Kỹ sư báo cáo cho cả quản lý chức năng và trưởng dự án
RelationEdges:
  # Nét liền (Chính)
  - schema: REPORTING_ORG
    from_type: POSITION
    from_id: POS-ENG-001 (John - Kỹ sư)
    to_type: POSITION
    to_id: POS-MGR-ENG (Quản lý Kỹ thuật)
    relation_type: REPORTING_SOLID_LINE
    weight: 1.0
    metadata:
      primary: true
      
  # Nét đứt (Phụ)
  - schema: REPORTING_ORG
    from_type: POSITION
    from_id: POS-ENG-001 (John - Kỹ sư)
    to_type: POSITION
    to_id: POS-LEAD-PROJ-A (Trưởng Dự án Alpha)
    relation_type: REPORTING_DOTTED_LINE
    weight: 0.5
    percentage: 40  # 40% thời gian cho dự án
    metadata:
      project_code: PROJ-ALPHA
      start_date: 2024-01-01
      end_date: 2024-12-31
```

**Ví dụ 2 - Sở hữu Pháp nhân**:
```yaml
# Công ty mẹ sở hữu các công ty con
RelationEdges:
  - schema: CORPORATE_STRUCTURE
    from_type: LEGAL_ENTITY
    from_id: LE-PARENT-CORP
    to_type: LEGAL_ENTITY
    to_id: LE-SUBSIDIARY-A
    relation_type: OWNERSHIP
    percentage: 100  # Sở hữu 100%
    
  - schema: CORPORATE_STRUCTURE
    from_type: LEGAL_ENTITY
    from_id: LE-PARENT-CORP
    to_type: LEGAL_ENTITY
    to_id: LE-JOINT-VENTURE-B
    relation_type: OWNERSHIP
    percentage: 51  # Sở hữu 51% (đa số)
```

**Ví dụ 3 - Luồng Ngân sách**:
```yaml
# Ngân sách chảy từ tập đoàn xuống các khối
RelationEdges:
  - schema: FINANCIAL_REPORTING
    from_type: BUSINESS_UNIT
    from_id: BU-CORPORATE
    to_type: BUSINESS_UNIT
    to_id: BU-ENGINEERING
    relation_type: BUDGET_FLOW
    metadata:
      annual_budget: 10000000
      fiscal_year: 2024
      
  - schema: FINANCIAL_REPORTING
    from_type: BUSINESS_UNIT
    from_id: BU-CORPORATE
    to_type: BUSINESS_UNIT
    to_id: BU-SALES
    relation_type: BUDGET_FLOW
    metadata:
      annual_budget: 5000000
      fiscal_year: 2024
```

**Quy tắc Nghiệp vụ**:
- ✅ Các cạnh phải thuộc về một schema
- ✅ Loại mối quan hệ phải được phép trong schema
- ✅ Loại thực thể phải khớp với ràng buộc của schema
- ✅ Tỷ lệ phần trăm tổng cộng là 100% nếu áp dụng
- ✅ SCD Type 2 theo dõi thay đổi mối quan hệ
- ⚠️ Tránh phụ thuộc vòng trong các schema phân cấp

---

## 💡 Trường hợp Sử dụng

### Trường hợp 1: Tổ chức Ma trận

**Kịch bản**: Thành viên nhóm kỹ thuật báo cáo cho cả quản lý chức năng và trưởng dự án.

```yaml
# Báo cáo Chức năng (Nét liền)
Schema: REPORTING_ORG
Edges:
  Kỹ sư A → Quản lý Kỹ thuật (SOLID_LINE)
  Kỹ sư B → Quản lý Kỹ thuật (SOLID_LINE)
  
# Báo cáo Dự án (Nét đứt)
Schema: PROJECT_MATRIX
Edges:
  Kỹ sư A → Trưởng Dự án Alpha (DOTTED_LINE, 60% thời gian)
  Kỹ sư A → Trưởng Dự án Beta (DOTTED_LINE, 40% thời gian)
  Kỹ sư B → Trưởng Dự án Alpha (DOTTED_LINE, 100% thời gian)

# Truy vấn:
# - Ai báo cáo cho Quản lý Kỹ thuật? (Nét liền)
# - Ai làm việc trong Dự án Alpha? (Nét đứt)
# - Phân bổ thời gian của Kỹ sư A là gì?
```

### Trường hợp 2: Công ty Đa Pháp nhân

**Kịch bản**: Theo dõi mối quan hệ giữa các pháp nhân (công ty mẹ, công ty con, liên doanh).

```yaml
Schema: CORPORATE_STRUCTURE
Edges:
  Tập đoàn Mẹ → Công ty con Việt Nam (OWNERSHIP, 100%)
  Tập đoàn Mẹ → Công ty con Singapore (OWNERSHIP, 100%)
  Tập đoàn Mẹ → Liên doanh Thái Lan (OWNERSHIP, 51%)
  Đối tác → Liên doanh Thái Lan (OWNERSHIP, 49%)

# Truy vấn:
# - Tập đoàn Mẹ sở hữu những thực thể nào?
# - Cấu trúc sở hữu của Liên doanh Thái Lan là gì?
# - Hợp nhất báo cáo tài chính
```

### Trường hợp 3: Nhóm Dự án

**Kịch bản**: Tổ chức dự án tạm thời chồng lên cấu trúc chức năng.

```yaml
Schema: PROJECT_ALPHA
Edges:
  # Thành viên nhóm dự án
  Trưởng Dự án → Kỹ sư A (PROJECT_MEMBERSHIP)
  Trưởng Dự án → Kỹ sư B (PROJECT_MEMBERSHIP)
  Trưởng Dự án → Thiết kế C (PROJECT_MEMBERSHIP)
  
  # Báo cáo nét đứt
  Kỹ sư A → Trưởng Dự án (DOTTED_LINE)
  Kỹ sư B → Trưởng Dự án (DOTTED_LINE)

# Khi dự án kết thúc:
# - Đặt ngày kết thúc hiệu lực (effective_end_date) trên tất cả các cạnh
# - Các cạnh trở thành lịch sử (is_current = false)
# - Báo cáo chức năng không thay đổi
```

### Trường hợp 4: Phân bổ Chi phí

**Kịch bản**: Chi phí dịch vụ chia sẻ được phân bổ cho các đơn vị kinh doanh.

```yaml
Schema: COST_ALLOCATION
Edges:
  Dịch vụ Chia sẻ → Kỹ thuật (COST_ALLOCATION, 40%)
  Dịch vụ Chia sẻ → Kinh doanh (COST_ALLOCATION, 30%)
  Dịch vụ Chia sẻ → Vận hành (COST_ALLOCATION, 30%)

# Phân bổ chi phí hàng tháng:
# - Tổng chi phí Dịch vụ Chia sẻ: $100,000
# - Kỹ thuật: $40,000
# - Kinh doanh: $30,000
# - Vận hành: $30,000
```

---

## 🔄 Các Kịch bản Phổ biến

### Kịch bản 1: Cấu trúc Báo cáo Đơn giản
```yaml
# Phân cấp truyền thống (không ma trận)
Schema: REPORTING_ORG
Edges:
  Kỹ sư → Trưởng nhóm (SOLID_LINE)
  Trưởng nhóm → Quản lý Kỹ thuật (SOLID_LINE)
  Quản lý Kỹ thuật → VP Kỹ thuật (SOLID_LINE)
```

### Kịch bản 2: Tổ chức Ma trận
```yaml
# Báo cáo Chức năng + Dự án
Chức năng (SOLID_LINE):
  Kỹ sư → Quản lý Kỹ thuật
  
Dự án (DOTTED_LINE):
  Kỹ sư → Trưởng Dự án A (50% thời gian)
  Kỹ sư → Trưởng Dự án B (50% thời gian)
```

### Kịch bản 3: Tái cơ cấu
```yaml
# Trước (01/01/2024 đến 30/06/2024)
Edge:
  Kỹ sư → Quản lý A (SOLID_LINE)
  effective_start: 2024-01-01
  effective_end: 2024-06-30
  is_current: false

# Sau (từ 01/07/2024)
Edge:
  Kỹ sư → Quản lý B (SOLID_LINE)
  effective_start: 2024-07-01
  effective_end: null
  is_current: true
```

---

## ⚠️ Lưu ý Quan trọng

### Thực tiễn Tốt nhất cho Nét liền vs Nét đứt
- ✅ Sử dụng nét liền cho báo cáo chính (một người một quan hệ)
- ✅ Sử dụng nét đứt cho báo cáo ma trận/dự án (cho phép nhiều quan hệ)
- ✅ Nét liền xác định thẩm quyền phê duyệt
- ✅ Nét đứt cung cấp hướng dẫn/điều phối
- ⚠️ Đừng nhầm lẫn với tổ chức vận hành vs giám sát

### Hướng dẫn Mô hình hóa Đồ thị
- ✅ Sử dụng schema để tách biệt các ngữ cảnh quan hệ khác nhau
- ✅ Giữ schema tập trung (mỗi schema một mục đích)
- ✅ Sử dụng metadata cho các thuộc tính đặc thù của cạnh
- ✅ Tận dụng SCD Type 2 cho phân tích lịch sử
- ⚠️ Tránh các đồ thị quá phức tạp (ảnh hưởng hiệu năng)

### Bảo trì Mối quan hệ
- ✅ Kiểm tra định kỳ độ chính xác của mối quan hệ
- ✅ Dọn dẹp các mối quan hệ dự án đã kết thúc
- ✅ Cập nhật mối quan hệ trong quá trình tái cơ cấu
- ✅ Tài liệu hóa ngữ nghĩa mối quan hệ rõ ràng
- ⚠️ Xem xét tác động đến các quy trình đang diễn ra

---

## 🔗 Các Thuật ngữ Liên quan

- **BusinessUnit** - Các đơn vị được liên kết
- **LegalEntity** - Quan hệ pháp nhân
- **Employment** - Các dòng báo cáo phân công (sử dụng khái niệm nét liền/đứt)
- **JobPosition** - Quan hệ vị trí

---

## 📚 Tài liệu Tham khảo

- Khái niệm Cơ sở dữ liệu Đồ thị: Neo4j, property graphs
- Workday: Tổ chức Ma trận
- SAP SuccessFactors: Quan hệ Tổ chức
- Oracle HCM: Cấu trúc Tổ chức

---

**Phiên bản Tài liệu**: 2.0  
**Đánh giá lần cuối**: 01/12/2025
