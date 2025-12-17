# Hướng dẫn Slowly Changing Dimension Type 2 (SCD Type 2)

> [!NOTE]
> **Tài liệu liên quan**
> - [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md) - Phân loại dữ liệu và khi nào dùng SCD2
> - [SCD2 Implementation Standard](./SCD2-IMPLEMENTATION-STANDARD.md) - Tiêu chuẩn kỹ thuật SCD2

## Tổng quan

### Định nghĩa

**Slowly Changing Dimension Type 2 (SCD Type 2)** là một kỹ thuật quản lý dữ liệu lịch sử trong data warehouse và hệ thống OLTP, cho phép theo dõi tất cả các thay đổi của một bản ghi theo thời gian bằng cách tạo ra các phiên bản (version) mới thay vì cập nhật trực tiếp.

### Mục đích

- **Theo dõi lịch sử đầy đủ**: Lưu giữ tất cả các thay đổi của dữ liệu theo thời gian
- **Audit trail**: Hỗ trợ kiểm toán và truy vết thay đổi
- **Point-in-time reporting**: Cho phép truy vấn dữ liệu tại một thời điểm cụ thể trong quá khứ
- **Compliance**: Đáp ứng yêu cầu pháp lý về lưu trữ lịch sử dữ liệu

### Khi nào áp dụng SCD2?

**SCD2 chỉ áp dụng cho Master Data**, không áp dụng cho:
- **Transaction Data**: Dữ liệu có effective date từ nghiệp vụ (như leave_request, compensation_adjustment)
- **Audit/Log Data**: Dữ liệu bất biến, chỉ INSERT
- **Reference Data**: Dữ liệu tra cứu tĩnh (có thể dùng optional)

> Xem chi tiết tại [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md)

---

## Cấu trúc SCD Type 2 trong xTalent

### Các trường bắt buộc

Trong hệ thống xTalent, chúng ta sử dụng **phiên bản mở rộng** của SCD Type 2 với các trường sau:

| Trường | Kiểu dữ liệu | Bắt buộc | Mô tả |
|--------|--------------|----------|-------|
| `id` | UUID | Có | **Row ID** - Primary key, duy nhất cho mỗi version (mỗi row) |
| `code` | VARCHAR(50) | Có | **Business Key** - Mã định danh nghiệp vụ (có thể trùng giữa các version) |
| `effective_start_date` | DATE | Có | Ngày bắt đầu hiệu lực của version |
| `effective_end_date` | DATE | Không | Ngày kết thúc hiệu lực (NULL = đang hiệu lực) |
| `is_current_flag` | BOOLEAN | Có | Cờ đánh dấu version hiện tại (TRUE/FALSE) |

### Phân biệt Row ID và Business Key

**Quan trọng:** Trong SCD Type 2, cần phân biệt rõ hai loại identifier:

1. **Row ID (`id`)**: 
   - UUID duy nhất cho **mỗi row/version**
   - Là Primary Key của bảng
   - Mỗi lần tạo version mới sẽ có `id` mới
   - **Không bao giờ trùng lặp**

2. **Business Key (`code`)**:
   - Mã định danh nghiệp vụ (ví dụ: `employee_code`, `job_code`, `entity_code`)
   - **Có thể trùng lặp** giữa các version của cùng một entity
   - Dùng để nhóm các version lại với nhau
   - Dùng để tham chiếu trong relationships (FK logic)

**Ví dụ minh họa:**

```
Employee versions:
┌──────────┬───────────────┬────────────┬────────────────┬─────────────┐
│ id (PK)  │ code (BizKey) │ full_name  │ effective_from │ is_current  │
├──────────┼───────────────┼────────────┼────────────────┼─────────────┤
│ uuid-001 │ EMP001        │ Nguyen A   │ 2025-01-01     │ FALSE       │ ← Version 1
│ uuid-002 │ EMP001        │ Nguyen A   │ 2025-07-01     │ TRUE        │ ← Version 2 (current)
└──────────┴───────────────┴────────────┴────────────────┴─────────────┘
         ↑                 ↑
    Unique per row    Same business entity
```

### Ví dụ cấu trúc bảng

```sql
CREATE TABLE employee (
    -- Primary Key: Row ID (unique per version)
    id UUID PRIMARY KEY,
    
    -- Business Key (can duplicate across versions)
    employee_code VARCHAR(50) NOT NULL,
    
    -- Business data
    full_name VARCHAR(255),
    job_title VARCHAR(150),
    salary DECIMAL(14,2),
    department_code VARCHAR(50),  -- FK logic, không có constraint
    
    -- SCD Type 2 fields
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMP,
    updated_by UUID
);

-- Index for performance
CREATE INDEX idx_employee_current ON employee(employee_code, is_current_flag) 
WHERE is_current_flag = TRUE;

CREATE INDEX idx_employee_effective_dates ON employee(effective_start_date, effective_end_date);

-- Index for business key lookups
CREATE INDEX idx_employee_code ON employee(employee_code);
```

### Quy tắc dữ liệu

1. **Row ID unique**: Mỗi `id` chỉ xuất hiện **một lần** trong toàn bộ bảng
2. **Business Key có thể trùng**: `code` có thể trùng lặp giữa các version
3. **Duy nhất một bản ghi current**: Với mỗi `code`, chỉ có **một** bản ghi có `is_current_flag = TRUE`
4. **End date của version cũ = Start date của version mới - 1 ngày**
5. **Version hiện tại**: `effective_end_date = NULL` VÀ `is_current_flag = TRUE`
6. **Version lịch sử**: `effective_end_date != NULL` VÀ `is_current_flag = FALSE`
7. **Không overlap**: Các version của cùng một `code` không được chồng lấn về thời gian

---

## Các thao tác cơ bản

### 1. INSERT - Tạo bản ghi mới

#### Trường hợp 1: Tạo bản ghi đầu tiên (Initial Insert)

```sql
-- Tạo nhân viên mới
INSERT INTO employee (
    id, employee_code, full_name, job_title, salary,
    effective_start_date, effective_end_date, is_current_flag,
    created_at, created_by
) VALUES (
    gen_random_uuid(),
    'EMP001',
    'Nguyen Van A',
    'Software Engineer',
    20000000,
    '2025-01-01',  -- Ngày bắt đầu làm việc
    NULL,          -- Đang hiệu lực
    TRUE,          -- Version hiện tại
    NOW(),
    'user_hr_001'
);
```

**Kết quả:**

| id | employee_code | full_name | job_title | salary | effective_start_date | effective_end_date | is_current_flag |
|----|---------------|-----------|-----------|--------|---------------------|-------------------|-----------------|
| uuid-1 | EMP001 | Nguyen Van A | Software Engineer | 20000000 | 2025-01-01 | NULL | TRUE |

---

### 2. UPDATE - Cập nhật dữ liệu

Khi cập nhật, **KHÔNG** update trực tiếp bản ghi cũ. Thay vào đó:
1. Đóng version cũ (set `effective_end_date` và `is_current_flag = FALSE`)
2. Tạo version mới với dữ liệu mới

#### Ví dụ: Thăng chức và tăng lương

```sql
-- Bước 1: Đóng version cũ
UPDATE employee
SET 
    effective_end_date = '2025-06-30',  -- Ngày cuối cùng của version cũ
    is_current_flag = FALSE,
    updated_at = NOW(),
    updated_by = 'user_hr_001'
WHERE employee_code = 'EMP001' 
  AND is_current_flag = TRUE;

-- Bước 2: Tạo version mới
INSERT INTO employee (
    id, employee_code, full_name, job_title, salary,
    effective_start_date, effective_end_date, is_current_flag,
    created_at, created_by
) VALUES (
    gen_random_uuid(),
    'EMP001',
    'Nguyen Van A',
    'Senior Software Engineer',  -- Thay đổi
    25000000,                     -- Thay đổi
    '2025-07-01',                 -- = effective_end_date cũ + 1 ngày
    NULL,
    TRUE,
    NOW(),
    'user_hr_001'
);
```

**Kết quả:**

| id | employee_code | full_name | job_title | salary | effective_start_date | effective_end_date | is_current_flag |
|----|---------------|-----------|-----------|--------|---------------------|-------------------|-----------------|
| uuid-1 | EMP001 | Nguyen Van A | Software Engineer | 20000000 | 2025-01-01 | 2025-06-30 | FALSE |
| uuid-2 | EMP001 | Nguyen Van A | Senior Software Engineer | 25000000 | 2025-07-01 | NULL | TRUE |

---

### 3. DELETE - Xóa bản ghi

Trong SCD Type 2, **KHÔNG BAO GIỜ** xóa vật lý (physical delete). Thay vào đó sử dụng **soft delete**:

#### Phương án 1: Đóng version hiện tại

```sql
-- Đánh dấu nhân viên nghỉ việc
UPDATE employee
SET 
    effective_end_date = '2025-12-31',  -- Ngày nghỉ việc
    is_current_flag = FALSE,
    updated_at = NOW(),
    updated_by = 'user_hr_001'
WHERE employee_code = 'EMP001' 
  AND is_current_flag = TRUE;
```

**Kết quả:**

| id | employee_code | full_name | job_title | salary | effective_start_date | effective_end_date | is_current_flag |
|----|---------------|-----------|-----------|--------|---------------------|-------------------|-----------------|
| uuid-1 | EMP001 | Nguyen Van A | Software Engineer | 20000000 | 2025-01-01 | 2025-06-30 | FALSE |
| uuid-2 | EMP001 | Nguyen Van A | Senior Software Engineer | 25000000 | 2025-07-01 | 2025-12-31 | FALSE |

#### Phương án 2: Sử dụng status field

Nếu cần phân biệt rõ trạng thái, thêm trường `status`:

```sql
ALTER TABLE employee ADD COLUMN status VARCHAR(20) DEFAULT 'ACTIVE';

-- Tạo version mới với status = TERMINATED
INSERT INTO employee (
    id, employee_code, full_name, job_title, salary, status,
    effective_start_date, effective_end_date, is_current_flag,
    created_at, created_by
) VALUES (
    gen_random_uuid(),
    'EMP001',
    'Nguyen Van A',
    'Senior Software Engineer',
    25000000,
    'TERMINATED',  -- Đánh dấu đã nghỉ việc
    '2026-01-01',
    NULL,
    TRUE,
    NOW(),
    'user_hr_001'
);
```

---

## Quan hệ giữa các Entity (Foreign Key Relationships)

### Nguyên tắc chung về Foreign Key trong SCD Type 2

**Vấn đề:** Trong SCD Type 2, `code` (business key) có thể trùng lặp giữa các version, nên **không thể tạo FK constraint** từ database.

**Giải pháp:** Sử dụng **Logical Foreign Key** thông qua `code` field:

```sql
-- ❌ KHÔNG THỂ làm như này (code không unique)
ALTER TABLE assignment 
ADD CONSTRAINT fk_assignment_job 
FOREIGN KEY (job_code) REFERENCES job(job_code);  -- Lỗi: job_code không unique

-- ✅ Đúng: Lưu code và enforce bằng application logic
CREATE TABLE assignment (
    id UUID PRIMARY KEY,
    assignment_code VARCHAR(50) NOT NULL,
    worker_code VARCHAR(50) NOT NULL,     -- FK logic đến worker
    job_code VARCHAR(50),                  -- FK logic đến job
    position_code VARCHAR(50),             -- FK logic đến position
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Index để tăng tốc lookup
CREATE INDEX idx_assignment_job_code ON assignment(job_code);
CREATE INDEX idx_assignment_worker_code ON assignment(worker_code);
```

### Các pattern quan hệ

#### Pattern 1: SCD2 ↔ SCD2 (Cả hai đều có lịch sử)

##### Quan hệ 1-1: Entity ↔ EntityProfile

**Đặc điểm:**
- Child (EntityProfile) không có effective dates riêng
- Child kế thừa lifecycle từ Parent (Entity)
- Khi Parent tạo version mới, Child cũng phải tạo version mới

**Cấu trúc:**

```sql
-- Parent: Entity (SCD2)
CREATE TABLE entity (
    id UUID PRIMARY KEY,                    -- Row ID
    code VARCHAR(50) NOT NULL,              -- Business key
    name_vi VARCHAR(150),
    name_en VARCHAR(150),
    type_code VARCHAR(50),
    parent_code VARCHAR(50),                -- FK logic đến entity khác
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Child: EntityProfile (SCD2, 1-1)
CREATE TABLE entity_profile (
    id UUID PRIMARY KEY,                    -- Row ID (riêng của profile)
    entity_code VARCHAR(50) NOT NULL,       -- FK logic đến entity
    tax_id VARCHAR(50),
    address TEXT,
    phone VARCHAR(50),
    -- KHÔNG có effective dates (kế thừa từ entity)
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index
CREATE INDEX idx_entity_profile_entity_code ON entity_profile(entity_code);
```

**Kịch bản UPDATE Entity:**

```sql
BEGIN;

-- Giả sử entity hiện tại: code='ENT001', id='uuid-v1'

-- Bước 1: Tạo version mới của Entity
INSERT INTO entity (id, code, name_vi, name_en, effective_start_date, is_current_flag)
VALUES (gen_random_uuid(), 'ENT001', 'VNG Mới', 'VNG New', '2025-07-01', TRUE);
-- Giả sử id mới = 'uuid-v2'

-- Bước 2: Tạo version mới của EntityProfile
INSERT INTO entity_profile (id, entity_code, tax_id, address, phone)
SELECT 
    gen_random_uuid(),      -- ID mới cho profile
    'ENT001',               -- Cùng entity_code
    tax_id,                 -- Copy data từ version cũ
    'New Address',          -- Hoặc update nếu cần
    phone
FROM entity_profile
WHERE entity_code = 'ENT001'
ORDER BY created_at DESC
LIMIT 1;

-- Bước 3: Đóng version cũ của Entity
UPDATE entity
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE code = 'ENT001' AND is_current_flag = TRUE AND id = 'uuid-v1';

-- Bước 4: Xóa hoặc đánh dấu profile cũ (tùy business rule)
-- Option A: Xóa version cũ (nếu không cần lịch sử profile)
DELETE FROM entity_profile 
WHERE entity_code = 'ENT001' AND id != (
    SELECT id FROM entity_profile WHERE entity_code = 'ENT001' ORDER BY created_at DESC LIMIT 1
);

-- Option B: Giữ lại để audit (khuyến nghị)
-- Không làm gì, giữ cả hai versions

COMMIT;
```

**Truy vấn current:**

```sql
-- Lấy Entity + Profile hiện tại
SELECT 
    e.id AS entity_id,
    e.code AS entity_code,
    e.name_vi,
    ep.tax_id,
    ep.address
FROM entity e
LEFT JOIN entity_profile ep ON e.code = ep.entity_code
WHERE e.code = 'ENT001' 
  AND e.is_current_flag = TRUE
ORDER BY ep.created_at DESC
LIMIT 1;  -- Lấy profile mới nhất
```

##### Quan hệ 1-N: Entity ↔ EntityLicense

> [!IMPORTANT]
> **EntityLicense KHÔNG dùng SCD2** vì đã có effective dates từ nghiệp vụ (issue_date, effective_start/end_date).
> Xem [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md#category-2b-linked-entities-with-business-dates)

**Đặc điểm:**
- Child (EntityLicense) có effective dates từ nghiệp vụ (ngày cấp, ngày hiệu lực)
- Một Entity có thể có nhiều Licenses
- License mới = record mới (KHÔNG phải version mới)
- Lịch sử được lưu bằng các records với dates khác nhau

**Cấu trúc:**

```sql
-- Child: EntityLicense (KHÔNG dùng SCD2)
CREATE TABLE entity_license (
    id UUID PRIMARY KEY,
    legal_entity_code VARCHAR(50) NOT NULL,  -- FK logic đến entity
    license_number VARCHAR(100),
    issue_date DATE,                         -- Business date
    effective_start_date DATE NOT NULL,      -- Business date (KHÔNG phải SCD2!)
    effective_end_date DATE,                 -- Business date (KHÔNG phải SCD2!)
    -- KHÔNG có is_current_flag
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_entity_license_entity_code ON entity_license(legal_entity_code);
```

**Kịch bản 1: Entity thay đổi, License KHÔNG thay đổi**

```sql
-- Entity tạo version mới (ENT001: uuid-v1 → uuid-v2)
-- License giữ nguyên, KHÔNG cần làm gì

-- Licenses vẫn tham chiếu đến entity_code='ENT001'
-- Khi query, sẽ join với current version của entity
```

**Kịch bản 2: License hết hạn, cấp license mới**

```sql
-- Option A: Kết thúc license cũ, tạo license mới
UPDATE entity_license
SET effective_end_date = '2025-12-31'
WHERE license_number = 'LIC001';

INSERT INTO entity_license (
    id, legal_entity_code, license_number, issue_date, effective_start_date
) VALUES (
    gen_random_uuid(), 'ENT001', 'LIC002', '2025-12-15', '2026-01-01'
);

-- Option B: Gia hạn license (cùng số, nội dung mới)
INSERT INTO entity_license (
    id, legal_entity_code, license_number, issue_date, effective_start_date
) VALUES (
    gen_random_uuid(), 'ENT001', 'LIC001', '2025-12-15', '2026-01-01'
);
```

**Truy vấn:**

```sql
-- Lấy Entity + tất cả Licenses đang hiệu lực
SELECT 
    e.code AS entity_code,
    e.name_vi,
    el.license_number,
    el.issue_date,
    el.effective_start_date,
    el.effective_end_date
FROM entity e
LEFT JOIN entity_license el ON e.code = el.legal_entity_code
    AND el.effective_start_date <= CURRENT_DATE
    AND (el.effective_end_date IS NULL OR el.effective_end_date >= CURRENT_DATE)
WHERE e.code = 'ENT001' 
  AND e.is_current_flag = TRUE;
```

---

#### Pattern 2: SCD2 ↔ Non-SCD2

##### Ví dụ: Assignment (SCD2) ↔ Worker (Non-SCD2)

**Đặc điểm:**
- Worker không có lịch sử (chỉ có một version)
- Assignment tham chiếu đến `worker_code`
- Khi Assignment thay đổi, Worker không bị ảnh hưởng

**Cấu trúc:**

```sql
-- Worker (Non-SCD2)
CREATE TABLE worker (
    id UUID PRIMARY KEY,
    worker_code VARCHAR(50) UNIQUE NOT NULL,  -- Unique vì không có version
    full_name VARCHAR(255),
    date_of_birth DATE
    -- Không có effective dates
);

-- Assignment (SCD2)
CREATE TABLE assignment (
    id UUID PRIMARY KEY,
    assignment_code VARCHAR(50) NOT NULL,
    worker_code VARCHAR(50) NOT NULL,     -- FK logic đến worker
    job_code VARCHAR(50),                  -- FK logic đến job (SCD2)
    position_code VARCHAR(50),             -- FK logic đến position (SCD2)
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_assignment_worker ON assignment(worker_code);
```

**Kịch bản: Worker chuyển job**

```sql
BEGIN;

-- Đóng assignment cũ
UPDATE assignment
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE worker_code = 'WRK001' AND is_current_flag = TRUE;

-- Tạo assignment mới
INSERT INTO assignment (
    id, assignment_code, worker_code, job_code, position_code,
    effective_start_date, is_current_flag
) VALUES (
    gen_random_uuid(),
    'ASG001',           -- Có thể cùng code hoặc code mới
    'WRK001',           -- Cùng worker
    'JOB002',           -- Job mới
    'POS002',           -- Position mới
    '2025-07-01',
    TRUE
);

COMMIT;
```

---

#### Pattern 3: Parent (SCD2) ↔ Child (Non-SCD2)

**⚠️ QUAN TRỌNG: Đây là pattern phức tạp nhất**

##### Nguyên tắc xử lý

Khi Parent là SCD2 và Child là Non-SCD2 (không theo dõi lịch sử):

1. **Parent thay đổi → Child KHÔNG tự động tạo version mới**
   - Child chỉ lưu `parent_code` (FK logic)
   - Child luôn tham chiếu đến current version của Parent

2. **Child thay đổi → Parent CÓ THỂ tạo version mới** (tùy business rule)
   - Nếu child data là **core attribute** của parent → Tạo parent version mới
   - Nếu child data là **supplementary data** → Chỉ update child, không động parent

##### Ví dụ 1: Job (SCD2) ↔ JobProfileSkill (Non-SCD2)

**Business Rule:** Skills là **supplementary data**, không trigger parent version

**Cấu trúc:**

```sql
-- Parent: Job (SCD2)
CREATE TABLE job (
    id UUID PRIMARY KEY,
    job_code VARCHAR(50) NOT NULL,
    title VARCHAR(150),
    level_code VARCHAR(50),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Child: JobProfileSkill (Non-SCD2)
CREATE TABLE job_profile_skill (
    id UUID PRIMARY KEY,
    job_code VARCHAR(50) NOT NULL,        -- FK logic, luôn trỏ đến current job
    skill_code VARCHAR(50) NOT NULL,
    proficiency_required INTEGER,
    is_mandatory BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_job_skill_job_code ON job_profile_skill(job_code);
```

**Kịch bản 1: Thêm/sửa/xóa skill → Parent KHÔNG thay đổi**

```sql
-- Thêm skill mới cho job
INSERT INTO job_profile_skill (id, job_code, skill_code, proficiency_required, is_mandatory)
VALUES (gen_random_uuid(), 'JOB001', 'SKILL_PYTHON', 4, TRUE);

-- Update skill
UPDATE job_profile_skill
SET proficiency_required = 5
WHERE job_code = 'JOB001' AND skill_code = 'SKILL_PYTHON';

-- Xóa skill
DELETE FROM job_profile_skill
WHERE job_code = 'JOB001' AND skill_code = 'SKILL_OLD';

-- Job KHÔNG tạo version mới
```

**Kịch bản 2: Job thay đổi (title, level) → Cần xử lý skills**

**Option A: Giữ nguyên skills (khuyến nghị nếu skills không đổi)**

```sql
BEGIN;

-- Đóng job version cũ
UPDATE job
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE job_code = 'JOB001' AND is_current_flag = TRUE;

-- Tạo job version mới
INSERT INTO job (id, job_code, title, level_code, effective_start_date, is_current_flag)
VALUES (gen_random_uuid(), 'JOB001', 'Senior Backend Engineer', 'LEVEL_SENIOR', '2025-07-01', TRUE);

-- Skills KHÔNG cần thay đổi, vẫn trỏ đến job_code='JOB001'

COMMIT;
```

**Option B: Copy skills sang version mới (nếu cần snapshot)**

```sql
BEGIN;

-- Đóng job version cũ
UPDATE job
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE job_code = 'JOB001' AND is_current_flag = TRUE;

-- Tạo job version mới với CODE MỚI (để phân biệt)
INSERT INTO job (id, job_code, title, level_code, effective_start_date, is_current_flag)
VALUES (gen_random_uuid(), 'JOB001_V2', 'Senior Backend Engineer', 'LEVEL_SENIOR', '2025-07-01', TRUE);

-- Copy skills sang code mới
INSERT INTO job_profile_skill (id, job_code, skill_code, proficiency_required, is_mandatory)
SELECT 
    gen_random_uuid(),
    'JOB001_V2',        -- Code mới
    skill_code,
    proficiency_required,
    is_mandatory
FROM job_profile_skill
WHERE job_code = 'JOB001';

-- Optional: Xóa skills cũ
DELETE FROM job_profile_skill WHERE job_code = 'JOB001';

COMMIT;
```

**⚠️ Lưu ý:** Option B thay đổi business key, cần cân nhắc kỹ về impact.

**Truy vấn:**

```sql
-- Lấy Job hiện tại + Skills
SELECT 
    j.job_code,
    j.title,
    j.level_code,
    jps.skill_code,
    jps.proficiency_required
FROM job j
LEFT JOIN job_profile_skill jps ON j.job_code = jps.job_code
WHERE j.job_code = 'JOB001' 
  AND j.is_current_flag = TRUE;
```

##### Ví dụ 2: Position (SCD2) ↔ PositionBudget (Non-SCD2)

**Business Rule:** Budget là **core attribute**, thay đổi budget → trigger parent version

**Cấu trúc:**

```sql
-- Parent: Position (SCD2)
CREATE TABLE position (
    id UUID PRIMARY KEY,
    position_code VARCHAR(50) NOT NULL,
    name VARCHAR(150),
    job_code VARCHAR(50),
    effective_start_date DATE NOT NULL,
    effective_end_date DATE,
    is_current_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Child: PositionBudget (Non-SCD2, nhưng trigger parent)
CREATE TABLE position_budget (
    id UUID PRIMARY KEY,
    position_code VARCHAR(50) NOT NULL UNIQUE,  -- 1-1 relationship
    budget_amount DECIMAL(14,2),
    budget_year INTEGER,
    approved_by VARCHAR(50),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Kịch bản: Thay đổi budget → Tạo Position version mới**

```sql
BEGIN;

-- Đóng position version cũ
UPDATE position
SET effective_end_date = CURRENT_DATE, is_current_flag = FALSE
WHERE position_code = 'POS001' AND is_current_flag = TRUE;

-- Tạo position version mới
INSERT INTO position (id, position_code, name, job_code, effective_start_date, is_current_flag)
SELECT 
    gen_random_uuid(),
    position_code,
    name,
    job_code,
    CURRENT_DATE + 1,
    TRUE
FROM position
WHERE position_code = 'POS001' AND effective_end_date = CURRENT_DATE;

-- Update budget (không tạo version mới, vì Non-SCD2)
UPDATE position_budget
SET 
    budget_amount = 500000000,
    budget_year = 2026,
    updated_at = NOW()
WHERE position_code = 'POS001';

COMMIT;
```

---

### Tổng kết các Pattern

> [!NOTE]
> Xem thêm [Data Classification Standard](./DATA-CLASSIFICATION-STANDARD.md#relationship-patterns-summary) cho decision tree đầy đủ

| Pattern | Parent | Child | Child có business dates? | Child dùng SCD2? | FK Type |
|---------|--------|-------|-------------------------|------------------|----------|
| **1-1 Extension** | SCD2 | Profile | ❌ Không | Theo parent | Logical (code) |
| **1-N Business Dates** | SCD2 | License, Rep | ✅ Có | ❌ KHÔNG | Logical (code) |
| **1-N Simple CRUD** | SCD2 | Bank Account | ❌ Không | ❌ KHÔNG | Logical (code) |
| **Parent-Child Supplementary** | SCD2 | Skills (Non-SCD2) | ❌ Không | ❌ KHÔNG | Logical (code) |
| **Parent-Child Core** | SCD2 | Budget (Non-SCD2) | ❌ Không | ❌ KHÔNG (trigger parent) | Logical (code) |

---

## Truy vấn dữ liệu SCD Type 2

### 1. Lấy bản ghi hiện tại (Current Version)

```sql
-- Cách 1: Sử dụng is_current_flag (Nhanh nhất - có index)
SELECT * FROM employee
WHERE employee_code = 'EMP001' 
  AND is_current_flag = TRUE;

-- Cách 2: Sử dụng effective_end_date
SELECT * FROM employee
WHERE employee_code = 'EMP001' 
  AND effective_end_date IS NULL;

-- Cách 3: Kết hợp cả hai (An toàn nhất)
SELECT * FROM employee
WHERE employee_code = 'EMP001' 
  AND is_current_flag = TRUE 
  AND effective_end_date IS NULL;
```

### 2. Lấy bản ghi tại một thời điểm (Point-in-Time Query)

```sql
-- Lấy thông tin nhân viên vào ngày 2025-05-15
SELECT * FROM employee
WHERE employee_code = 'EMP001'
  AND effective_start_date <= '2025-05-15'
  AND (effective_end_date IS NULL OR effective_end_date >= '2025-05-15');
```

### 3. Lấy toàn bộ lịch sử

```sql
-- Lấy tất cả versions của một nhân viên
SELECT 
    id,
    employee_code,
    full_name,
    job_title,
    salary,
    effective_start_date,
    effective_end_date,
    is_current_flag
FROM employee
WHERE employee_code = 'EMP001'
ORDER BY effective_start_date DESC;
```

### 4. Lấy thay đổi trong khoảng thời gian

```sql
-- Lấy các thay đổi từ 2025-01-01 đến 2025-12-31
SELECT * FROM employee
WHERE employee_code = 'EMP001'
  AND effective_start_date BETWEEN '2025-01-01' AND '2025-12-31'
ORDER BY effective_start_date;
```

### 5. JOIN với SCD2 entities

```sql
-- JOIN Assignment (SCD2) với Job (SCD2) - Current versions
SELECT 
    a.id AS assignment_id,
    a.worker_id,
    j.code AS job_code,
    j.title AS job_title,
    a.effective_start_date
FROM assignment a
INNER JOIN job j ON a.job_id = j.id
WHERE a.is_current_flag = TRUE 
  AND j.is_current_flag = TRUE;

-- JOIN Point-in-Time
SELECT 
    a.id AS assignment_id,
    a.worker_id,
    j.code AS job_code,
    j.title AS job_title
FROM assignment a
INNER JOIN job j ON a.job_id = j.id
WHERE a.effective_start_date <= '2025-06-15'
  AND (a.effective_end_date IS NULL OR a.effective_end_date >= '2025-06-15')
  AND j.effective_start_date <= '2025-06-15'
  AND (j.effective_end_date IS NULL OR j.effective_end_date >= '2025-06-15');
```

---

## Best Practices

### 1. Thiết kế Database

#### Indexes

```sql
-- Index cho current flag (quan trọng nhất)
CREATE INDEX idx_employee_current 
ON employee(employee_code, is_current_flag) 
WHERE is_current_flag = TRUE;

-- Index cho effective dates
CREATE INDEX idx_employee_dates 
ON employee(effective_start_date, effective_end_date);

-- Composite index cho point-in-time queries
CREATE INDEX idx_employee_pit 
ON employee(employee_code, effective_start_date, effective_end_date);
```

#### Constraints

```sql
-- Unique constraint: Chỉ một bản ghi current per business key
CREATE UNIQUE INDEX uq_employee_current 
ON employee(employee_code) 
WHERE is_current_flag = TRUE;

-- Check constraint: End date >= Start date
ALTER TABLE employee 
ADD CONSTRAINT chk_employee_dates 
CHECK (effective_end_date IS NULL OR effective_end_date >= effective_start_date);

-- Check constraint: Current flag logic
ALTER TABLE employee 
ADD CONSTRAINT chk_employee_current 
CHECK (
    (is_current_flag = TRUE AND effective_end_date IS NULL) OR
    (is_current_flag = FALSE AND effective_end_date IS NOT NULL)
);

-- ⚠️ KHÔNG THỂ tạo FK constraint với code field
-- Vì code có thể trùng lặp giữa các version
-- Thay vào đó, enforce referential integrity bằng application logic

-- ❌ KHÔNG làm như này:
-- ALTER TABLE assignment 
-- ADD CONSTRAINT fk_assignment_job 
-- FOREIGN KEY (job_code) REFERENCES job(job_code);  -- LỖI!

-- ✅ Đúng: Validate trong application code
-- - Check job_code exists trong job table với is_current_flag = TRUE
-- - Hoặc sử dụng trigger để validate
```

**Trigger để validate FK logic:**

```sql
CREATE OR REPLACE FUNCTION validate_job_code()
RETURNS TRIGGER AS $$
BEGIN
    -- Kiểm tra job_code có tồn tại không
    IF NEW.job_code IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM job 
            WHERE job_code = NEW.job_code 
            AND is_current_flag = TRUE
        ) THEN
            RAISE EXCEPTION 'Invalid job_code: % does not exist or is not current', NEW.job_code;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_assignment_validate_job
BEFORE INSERT OR UPDATE ON assignment
FOR EACH ROW
EXECUTE FUNCTION validate_job_code();
```

### 2. Application Logic

#### Helper Functions

```sql
-- Function: Đóng version hiện tại
CREATE OR REPLACE FUNCTION close_current_version(
    p_table_name TEXT,
    p_business_key_column TEXT,
    p_business_key_value TEXT,
    p_end_date DATE
) RETURNS VOID AS $$
BEGIN
    EXECUTE format(
        'UPDATE %I SET effective_end_date = $1, is_current_flag = FALSE, updated_at = NOW() 
         WHERE %I = $2 AND is_current_flag = TRUE',
        p_table_name, p_business_key_column
    ) USING p_end_date, p_business_key_value;
END;
$$ LANGUAGE plpgsql;

-- Sử dụng
SELECT close_current_version('employee', 'employee_code', 'EMP001', '2025-06-30');
```

#### Transaction Pattern

```sql
BEGIN;

-- 1. Validate: Kiểm tra version hiện tại tồn tại
SELECT id INTO v_current_id
FROM employee
WHERE employee_code = 'EMP001' AND is_current_flag = TRUE
FOR UPDATE;  -- Lock row

IF NOT FOUND THEN
    RAISE EXCEPTION 'Current version not found for employee EMP001';
END IF;

-- 2. Close current version
UPDATE employee
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE id = v_current_id;

-- 3. Insert new version
INSERT INTO employee (...) VALUES (...);

COMMIT;
```

### 3. API Design

#### Request/Response Models

```typescript
// Request: Update employee
interface UpdateEmployeeRequest {
    employeeCode: string;
    effectiveDate: string;  // Ngày bắt đầu hiệu lực của thay đổi
    changes: {
        jobTitle?: string;
        salary?: number;
        departmentId?: string;
    };
}

// Response: Employee with version info
interface EmployeeResponse {
    id: string;
    employeeCode: string;
    fullName: string;
    jobTitle: string;
    salary: number;
    effectiveStartDate: string;
    effectiveEndDate: string | null;
    isCurrent: boolean;
    version: number;  // Computed field
}
```

#### API Endpoints

```
GET    /api/employees/{code}                    # Lấy current version
GET    /api/employees/{code}?asOf=2025-06-15   # Point-in-time query
GET    /api/employees/{code}/history            # Lấy toàn bộ lịch sử
POST   /api/employees                           # Tạo mới
PUT    /api/employees/{code}                    # Update (tạo version mới)
DELETE /api/employees/{code}                    # Soft delete
```

### 4. Testing Checklist

#### Unit Tests

- [ ] Tạo bản ghi mới với effective dates đúng
- [ ] Update tạo version mới và đóng version cũ
- [ ] Chỉ có một bản ghi current cho mỗi business key
- [ ] End date = Start date của version tiếp theo - 1 ngày
- [ ] Soft delete đóng version hiện tại
- [ ] Point-in-time query trả về đúng version

#### Integration Tests

- [ ] Transaction rollback khi có lỗi
- [ ] Concurrent updates không tạo duplicate current versions
- [ ] Foreign key relationships được duy trì đúng
- [ ] Cascade updates cho parent-child relationships

---

## Use Cases thực tế

### Use Case 1: Thay đổi thông tin nhân viên

**Kịch bản:** Nhân viên được thăng chức từ "Software Engineer" lên "Senior Software Engineer" và tăng lương từ 20M lên 25M vào ngày 01/07/2025.

**Giải pháp:**

```sql
-- Đóng version cũ
UPDATE employee
SET effective_end_date = '2025-06-30', is_current_flag = FALSE
WHERE employee_code = 'EMP001' AND is_current_flag = TRUE;

-- Tạo version mới
INSERT INTO employee (id, employee_code, full_name, job_title, salary, effective_start_date, is_current_flag)
VALUES (gen_random_uuid(), 'EMP001', 'Nguyen Van A', 'Senior Software Engineer', 25000000, '2025-07-01', TRUE);
```

### Use Case 2: Sửa lỗi dữ liệu lịch sử

**Kịch bản:** Phát hiện lương của nhân viên trong quá khứ bị nhập sai, cần sửa lại.

**Giải pháp:**

```sql
-- Update trực tiếp version lịch sử (KHÔNG tạo version mới)
UPDATE employee
SET salary = 22000000,  -- Sửa từ 20M thành 22M
    updated_at = NOW(),
    updated_by = 'user_hr_001'
WHERE id = 'uuid-version-cu'  -- Update theo ID cụ thể
  AND is_current_flag = FALSE;  -- Chỉ sửa version lịch sử
```

**Lưu ý:** Cần log lại việc sửa đổi này để audit trail.

### Use Case 3: Điều chỉnh ngày hiệu lực

**Kịch bản:** Thăng chức được quyết định muộn, cần backdated từ 01/07 về 15/06.

**Giải pháp:**

```sql
BEGIN;

-- Xóa version hiện tại (nếu chưa có dữ liệu phụ thuộc)
DELETE FROM employee WHERE id = 'uuid-version-moi';

-- Update version cũ
UPDATE employee
SET effective_end_date = '2025-06-14'  -- Thay vì 30/06
WHERE id = 'uuid-version-cu';

-- Tạo lại version mới với ngày đúng
INSERT INTO employee (...)
VALUES (..., '2025-06-15', ...);  -- Thay vì 01/07

COMMIT;
```

### Use Case 4: Merge duplicate records

**Kịch bản:** Phát hiện nhân viên bị tạo trùng với 2 mã khác nhau, cần merge lại.

**Giải pháp:**

```sql
-- Giữ lại EMP001, xóa EMP001_DUP
-- Bước 1: Update tất cả references từ EMP001_DUP sang EMP001
UPDATE assignment SET worker_id = (
    SELECT id FROM worker WHERE worker_code = 'EMP001'
) WHERE worker_id = (
    SELECT id FROM worker WHERE worker_code = 'EMP001_DUP'
);

-- Bước 2: Soft delete EMP001_DUP
UPDATE employee
SET effective_end_date = CURRENT_DATE, is_current_flag = FALSE
WHERE employee_code = 'EMP001_DUP' AND is_current_flag = TRUE;
```

---

## Troubleshooting

### Vấn đề 1: Có nhiều hơn 1 bản ghi current

**Triệu chứng:**
```sql
SELECT employee_code, COUNT(*) 
FROM employee 
WHERE is_current_flag = TRUE 
GROUP BY employee_code 
HAVING COUNT(*) > 1;
```

**Nguyên nhân:** Race condition trong concurrent updates

**Giải pháp:**
```sql
-- Fix dữ liệu: Giữ version mới nhất, đóng các version khác
WITH ranked AS (
    SELECT id, employee_code, effective_start_date,
           ROW_NUMBER() OVER (PARTITION BY employee_code ORDER BY effective_start_date DESC) as rn
    FROM employee
    WHERE is_current_flag = TRUE
)
UPDATE employee e
SET is_current_flag = FALSE, effective_end_date = CURRENT_DATE
FROM ranked r
WHERE e.id = r.id AND r.rn > 1;
```

### Vấn đề 2: Gaps trong timeline

**Triệu chứng:** Có khoảng trống giữa các versions

**Kiểm tra:**
```sql
SELECT 
    e1.employee_code,
    e1.effective_end_date AS version1_end,
    e2.effective_start_date AS version2_start,
    e2.effective_start_date - e1.effective_end_date - 1 AS gap_days
FROM employee e1
JOIN employee e2 ON e1.employee_code = e2.employee_code
WHERE e1.effective_end_date IS NOT NULL
  AND e2.effective_start_date > e1.effective_end_date + 1
ORDER BY e1.employee_code, e1.effective_start_date;
```

**Giải pháp:** Điều chỉnh dates để liên tục

### Vấn đề 3: Overlapping dates

**Triệu chứng:** Các versions chồng lấn thời gian

**Kiểm tra:**
```sql
SELECT 
    e1.id AS id1, e2.id AS id2,
    e1.employee_code,
    e1.effective_start_date AS start1, e1.effective_end_date AS end1,
    e2.effective_start_date AS start2, e2.effective_end_date AS end2
FROM employee e1
JOIN employee e2 ON e1.employee_code = e2.employee_code AND e1.id != e2.id
WHERE e1.effective_start_date <= COALESCE(e2.effective_end_date, '9999-12-31')
  AND COALESCE(e1.effective_end_date, '9999-12-31') >= e2.effective_start_date;
```

---

## Tài liệu tham khảo

### Thuật ngữ

| Thuật ngữ | Giải thích |
|-----------|------------|
| **SCD Type 2** | Slowly Changing Dimension Type 2 - Kỹ thuật lưu trữ lịch sử bằng versioning |
| **Version** | Một bản ghi đại diện cho trạng thái của entity tại một khoảng thời gian |
| **Current Version** | Version đang hiệu lực (is_current_flag = TRUE) |
| **Historical Version** | Version đã kết thúc (is_current_flag = FALSE) |
| **Business Key** | Mã định danh nghiệp vụ (ví dụ: employee_code) |
| **Effective Date** | Ngày bắt đầu/kết thúc hiệu lực của version |
| **Point-in-Time Query** | Truy vấn dữ liệu tại một thời điểm cụ thể |
| **Soft Delete** | Xóa logic bằng cách đánh dấu, không xóa vật lý |

### Checklist triển khai

- [ ] Thêm các trường SCD2 vào bảng (effective_start_date, effective_end_date, is_current_flag)
- [ ] Tạo indexes cho performance
- [ ] Tạo constraints để đảm bảo data integrity
- [ ] Implement helper functions cho INSERT/UPDATE/DELETE
- [ ] Viết unit tests cho tất cả operations
- [ ] Document API endpoints và behaviors
- [ ] Training cho team về cách sử dụng
- [ ] Setup monitoring cho data quality issues

---

**Phiên bản:** 1.2  
**Ngày cập nhật:** 2025-12-17  
**Tác giả:** xTalent Development Team  
**Thay đổi v1.2:** Sửa ví dụ entity_license (KHÔNG dùng SCD2 vì có business dates)  
**Thay đổi v1.1:** Thêm tham chiếu đến Data Classification Standard và SCD2 Implementation Standard
