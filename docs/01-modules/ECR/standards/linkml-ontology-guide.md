# LinkML Ontology Standards

> Tài liệu quy chuẩn cho việc viết ontology bằng LinkML trong dự án Knowledgebase Brain.

---

## 1. Tổng Quan

LinkML là ngôn ngữ mô hình hóa dữ liệu dùng YAML. Trong Brain, chúng ta sử dụng LinkML để định nghĩa:

- **Entity** (Thực thể): Employee, Worker, Assignment
- **Action** (Hành động/API): CreateEmployee, UpdateAssignment
- **Slot** (Thuộc tính): hire_date, salary
- **Enum** (Danh mục): EmploymentStatus, Gender
- **Rule** (Quy tắc nghiệp vụ): Constraints, validations

---

## 2. Cấu Trúc File

```
ontology/
├── _prefixes.yaml     # Shared prefixes
├── core/
│   ├── person.yaml    # Person entity
│   ├── employee.yaml  # Employee entity
│   └── assignment.yaml
├── actions/
│   ├── employee_actions.yaml  # CreateEmployee, UpdateEmployee
│   └── assignment_actions.yaml
└── enums/
    └── common_enums.yaml
```

---

## 3. Entity Definition

### 3.1 Cấu Trúc Cơ Bản

```yaml
id: https://xtalent.io/ontology/employee
name: employee_ontology
prefixes:
  xt: https://xtalent.io/ontology/

classes:
  Employee:
    description: "Người lao động có hợp đồng với tổ chức"
    is_a: Person  # Kế thừa từ Person
    
    # === ANNOTATIONS (Metadata) ===
    annotations:
      # Terminology mapping - REQUIRED
      oracle_hcm_term: "Worker"
      sap_term: "Personnel"
      workday_term: "Worker"
      disambiguation: "Oracle HCM gọi họ là Worker, không phải Employee"
      
      # Module info
      module: "core_hr"
      version: "1.0.0"
    
    # === SLOTS (Attributes) ===
    slots:
      - employee_id
      - hire_date
      - termination_date
      - employment_status
      - current_assignment
    
    # === SLOT USAGE (Constraints per slot) ===
    slot_usage:
      employee_id:
        required: true
        identifier: true
        pattern: "^EMP-\\d{6}$"  # Format: EMP-000001
      
      hire_date:
        required: true
      
      termination_date:
        required: false
      
      employment_status:
        range: EmploymentStatusEnum
        required: true
    
    # === RULES (Business Rules) ===
    rules:
      - description: "BRS-EMP-001: Termination date phải sau hire date"
        postconditions:
          slot_conditions:
            termination_date:
              minimum_value: "{hire_date}"
      
      - description: "BRS-EMP-002: Employee phải có ít nhất 1 assignment active"
        comments:
          - "Validated at API level, not schema level"
```

### 3.2 Giải Thích Các Thành Phần

| Thành phần | Mục đích | Bắt buộc? |
|------------|----------|-----------|
| `description` | Mô tả ngắn gọn | ✅ Yes |
| `is_a` | Kế thừa từ entity khác | Nếu có |
| `annotations` | Metadata tùy chỉnh (terminology, module) | ✅ Yes |
| `slots` | Danh sách attributes | ✅ Yes |
| `slot_usage` | Ràng buộc cụ thể cho từng slot | ✅ Yes |
| `rules` | Business rules dạng if-then | ✅ Yes |

---

## 4. Slot Definition

```yaml
slots:
  # === Basic Slot ===
  employee_id:
    description: "Mã nhân viên duy nhất"
    range: string
    required: true
    identifier: true
    pattern: "^EMP-\\d{6}$"
  
  # === Date Slot ===
  hire_date:
    description: "Ngày vào làm"
    range: date
    required: true
  
  # === Enum Slot ===
  employment_status:
    description: "Trạng thái làm việc"
    range: EmploymentStatusEnum
    required: true
  
  # === Reference Slot (FK) ===
  current_assignment:
    description: "Assignment hiện tại"
    range: Assignment  # Reference to another entity
    required: false
    multivalued: false
  
  # === Multi-valued Slot ===
  assignments:
    description: "Tất cả assignments"
    range: Assignment
    multivalued: true
    inlined: false  # Store as references, not embedded
```

### 4.1 Slot Properties

| Property | Mô tả |
|----------|-------|
| `range` | Kiểu dữ liệu: string, integer, date, boolean, Entity, Enum |
| `required` | Bắt buộc hay không |
| `identifier` | Là primary key |
| `multivalued` | Cho phép nhiều giá trị (array) |
| `pattern` | Regex validation |
| `minimum_value` / `maximum_value` | Ràng buộc số |
| `inlined` | Embed object hay reference |

---

## 5. Action Definition (APIs as Entities)

Actions là các operations/APIs, được định nghĩa như entities:

```yaml
classes:
  # === Base Action ===
  SystemAction:
    abstract: true
    description: "Base class cho tất cả actions"
    slots:
      - action_id
      - performed_by
      - performed_at
    annotations:
      entity_type: "action"
  
  # === Specific Action ===
  CreateEmployeeAction:
    is_a: SystemAction
    description: "API: Tạo mới Employee"
    
    annotations:
      # API metadata
      http_method: "POST"
      endpoint: "/api/employees"
      
      # Terminology
      oracle_hcm_action: "Create Person + Create Work Relationship"
    
    slots:
      - input_payload
      - output_result
    
    slot_usage:
      input_payload:
        range: EmployeeCreateRequest
        required: true
        inlined: true
      
      output_result:
        range: Employee
    
    rules:
      - description: "BRS-ACT-001: Hire date không được trong tương lai"
        preconditions:
          slot_conditions:
            input_payload:
              hire_date:
                maximum_value: "{today}"
```

---

## 6. Enum Definition

```yaml
enums:
  EmploymentStatusEnum:
    description: "Trạng thái làm việc"
    
    annotations:
      oracle_hcm_enum: "ASSIGNMENT_STATUS_TYPE"
      sap_enum: "STAT2"
    
    permissible_values:
      ACTIVE:
        description: "Đang làm việc"
        annotations:
          oracle_value: "ACTIVE_ASSIGN"
          sap_value: "3"
      
      INACTIVE:
        description: "Nghỉ việc"
      
      SUSPENDED:
        description: "Tạm ngưng"
      
      PENDING:
        description: "Chờ xử lý"
```

---

## 7. Rules & Constraints

### 7.1 Simple Constraint (trong slot_usage)

```yaml
slot_usage:
  age:
    minimum_value: 18
    maximum_value: 100
  
  email:
    pattern: "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
```

### 7.2 Complex Rule (trong rules block)

```yaml
rules:
  # Rule với precondition và postcondition
  - description: "BRS-ASN-001: Full-time phải có salary >= minimum wage"
    preconditions:
      slot_conditions:
        employment_type:
          equals_string: "FULL_TIME"
    postconditions:
      slot_conditions:
        salary:
          minimum_value: 4680000  # VN minimum wage
  
  # Rule với any_of (OR logic)
  - description: "BRS-ASN-002: Part-time hoặc có manager"
    postconditions:
      any_of:
        - slot_conditions:
            employment_type:
              equals_string: "PART_TIME"
        - slot_conditions:
            manager_id:
              required: true
```

---

## 8. Annotations - Terminology Mapping

### 8.1 Bắt Buộc Cho Mọi Entity

```yaml
annotations:
  # === TERMINOLOGY MAPPING ===
  oracle_hcm_term: "Worker"           # Tên trong Oracle HCM
  sap_term: "Personnel"               # Tên trong SAP
  workday_term: "Worker"              # Tên trong Workday
  disambiguation: "Chi tiết sự khác biệt..."
  
  # === MODULE INFO ===
  module: "core_hr"                   # Module: core_hr, payroll, time_attendance
  version: "1.0.0"
  
  # === OPTIONAL ===
  deprecated: false
  see_also: "https://docs.xtalent.io/entities/employee"
```

### 8.2 Cho Actions

```yaml
annotations:
  http_method: "POST"
  endpoint: "/api/employees"
  oracle_hcm_action: "Create Person + Create Assignment"
```

---

## 9. Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| **Entity** | PascalCase | `Employee`, `WorkAssignment` |
| **Action** | PascalCase + "Action" | `CreateEmployeeAction` |
| **Slot** | snake_case | `hire_date`, `employee_id` |
| **Enum** | PascalCase + "Enum" | `EmploymentStatusEnum` |
| **Enum Value** | UPPER_SNAKE_CASE | `ACTIVE`, `FULL_TIME` |
| **Rule ID** | BRS-{MODULE}-{NUMBER} | `BRS-EMP-001` |

---

## 10. Complete Example

```yaml
id: https://xtalent.io/ontology/employee
name: employee_ontology
version: "1.0.0"

prefixes:
  xt: https://xtalent.io/ontology/
  oracle: https://oracle.com/hcm/

imports:
  - ./person.yaml
  - ./enums/common_enums.yaml

default_range: string

# === SLOTS ===
slots:
  employee_id:
    description: "Mã nhân viên"
    identifier: true
    pattern: "^EMP-\\d{6}$"
  
  hire_date:
    range: date
  
  termination_date:
    range: date
  
  employment_status:
    range: EmploymentStatusEnum

# === CLASSES ===
classes:
  Employee:
    description: "Người lao động có hợp đồng"
    is_a: Person
    
    annotations:
      oracle_hcm_term: "Worker"
      sap_term: "Personnel"
      module: "core_hr"
      disambiguation: |
        Trong Oracle HCM, Person + Work Relationship = Worker.
        Trong hệ thống của chúng ta, Worker = Person, Employee = có hợp đồng.
    
    slots:
      - employee_id
      - hire_date
      - termination_date
      - employment_status
    
    slot_usage:
      employee_id:
        required: true
      hire_date:
        required: true
      employment_status:
        required: true
    
    rules:
      - description: "BRS-EMP-001: Termination sau hire"
        postconditions:
          slot_conditions:
            termination_date:
              minimum_value: "{hire_date}"

# === ENUMS ===
enums:
  EmploymentStatusEnum:
    permissible_values:
      ACTIVE:
        description: "Đang làm việc"
      INACTIVE:
        description: "Nghỉ việc"
```

---

## 11. Checklist Khi Viết Ontology

- [ ] Entity có `description` rõ ràng
- [ ] Có `annotations` đầy đủ (terminology mapping, module)
- [ ] Tất cả slots có `range` và `required` định nghĩa
- [ ] Business rules có ID (BRS-xxx-xxx)
- [ ] Enum values có description
- [ ] Đã kiểm tra naming conventions
