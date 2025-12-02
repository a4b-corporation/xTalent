# Phân hệ Việc làm (Employment) - Thuật ngữ

**Phiên bản**: 2.0  
**Cập nhật lần cuối**: 01/12/2025  
**Phân hệ con**: Quan hệ việc làm & Phân công công việc

---

## 📋 Tổng quan

Phân hệ Việc làm quản lý **hệ thống phân cấp 4 cấp độ** từ quan hệ công việc đến các phân công công việc cụ thể. Đây là **lõi** của quản lý dữ liệu nhân sự.

**Mới trong v2.0**: Thực thể `WorkRelationship` tách biệt quan hệ công việc tổng thể khỏi các chi tiết hợp đồng lao động (thực tiễn tốt nhất từ Workday/Oracle).

### Các thực thể (6)
1. ✨ **WorkRelationship** (MỚI) - Quan hệ công việc
2. **Employee** - Nhân viên
3. **Contract** - Hợp đồng
4. **Assignment** - Phân công công việc
5. **EmployeeIdentifier** - Định danh nhân viên
6. **GlobalAssignment** - Phân công toàn cầu

---

## 🔑 Các thực thể chính

### WorkRelationship ✨ MỚI

**Định nghĩa**: Mối quan hệ làm việc tổng thể giữa Người lao động (Worker) và Tổ chức, độc lập với các chi tiết hợp đồng lao động cụ thể.

**Mục đích**: 
- Tách biệt mối quan hệ cấp cao khỏi chi tiết hợp đồng.
- Hỗ trợ người lao động không phải nhân viên chính thức (nhà thầu, nhân sự thời vụ).
- Cho phép một người lao động có nhiều mối quan hệ đồng thời.

**Các thuộc tính chính**:
- `worker_id` - Tham chiếu đến Worker.
- `legal_entity_code` - Pháp nhân có mối quan hệ.
- `relationship_type_code` - Loại quan hệ:
  - `EMPLOYEE` - Quan hệ lao động chính thức.
  - `CONTRACTOR` - Nhà thầu độc lập.
  - `CONTINGENT_WORKER` - Nhân sự thời vụ/thuê ngoài.
  - `INTERN` - Thực tập sinh.
  - `VOLUNTEER` - Tình nguyện viên (không hưởng lương).
- `is_primary_relationship` - Là quan hệ chính nếu có nhiều quan hệ đồng thời.
- `status_code` - ACTIVE (Hoạt động), INACTIVE (Không hoạt động), TERMINATED (Chấm dứt), SUSPENDED (Đình chỉ).
- `start_date` / `end_date` - Thời hạn của mối quan hệ.

**Quy tắc nghiệp vụ**:
- ✅ Một người lao động có thể có nhiều quan hệ công việc (khác pháp nhân hoặc loại hình).
- ✅ Chỉ có một quan hệ công việc chính tại một thời điểm.
- ✅ Loại `EMPLOYEE` bắt buộc phải có bản ghi `Employee` tương ứng.
- ✅ Loại `CONTRACTOR`/`CONTINGENT` có thể bỏ qua bản ghi `Employee`.
- ⚠️ Không thể xóa nếu còn các phân công công việc (assignments) đang hoạt động.

**Ví dụ**:
```yaml
# John Doe làm nhân viên tại Công ty A và nhà thầu tại Công ty B
WorkRelationship#1:
  worker_id: WORKER-001 (John Doe)
  legal_entity_code: COMPANY-A
  relationship_type: EMPLOYEE
  is_primary: true
  
WorkRelationship#2:
  worker_id: WORKER-001 (John Doe)
  legal_entity_code: COMPANY-B
  relationship_type: CONTRACTOR
  is_primary: false
```

**Tại sao quan trọng**: 
- Tuân thủ thực tiễn tốt nhất của Workday/Oracle HCM.
- Phân tách trách nhiệm rõ ràng.
- Hỗ trợ các kịch bản phức tạp (làm việc kép, nhà thầu).

---

### Employee

**Định nghĩa**: Thông tin chi tiết về hợp đồng lao động cho người lao động có quan hệ công việc loại `EMPLOYEE`.

**Mục đích**: 
- Lưu trữ dữ liệu đặc thù của nhân viên (mã nhân viên, ngày tuyển dụng, thử việc).
- Liên kết với hợp đồng và bảng lương.
- Tương ứng 1-1 với `WorkRelationship` (đối với loại EMPLOYEE).

**Các thuộc tính chính**:
- `work_relationship_id` 🔄 - Quan hệ công việc cha (MỚI trong v2.0).
- `worker_id` - Phi chuẩn hóa để tăng hiệu năng.
- `legal_entity_code` - Pháp nhân tuyển dụng.
- `employee_code` - Mã nhân viên (duy nhất trong pháp nhân).
- `employee_class_code` - Phân loại (CHÍNH THỨC, THỬ VIỆC, v.v.).
- `hire_date` - Ngày tuyển dụng chính thức.
- `termination_date` - Ngày chấm dứt (nếu có).
- `probation_end_date` 🔄 - Ngày kết thúc thử việc (MỚI).
- `seniority_date` 🔄 - Ngày tính thâm niên (MỚI).

**Quy tắc nghiệp vụ**:
- ✅ Phải tham chiếu đến `WorkRelationship` có type = `EMPLOYEE`.
- ✅ Mã nhân viên phải duy nhất trong pháp nhân.
- ✅ Ngày tuyển dụng <= ngày bắt đầu phân công công việc đầu tiên.
- ✅ `worker_id` phải khớp với `work_relationship.worker_id`.
- ⚠️ Không thể tạo `Employee` cho các quan hệ công việc không phải `EMPLOYEE`.

**Ví dụ**:
```yaml
Employee:
  work_relationship_id: WR-001
  employee_code: "EMP-2024-001"
  legal_entity_code: "VNG-CORP"
  hire_date: 2024-01-15
  probation_end_date: 2024-04-15
  status: ACTIVE
```

**Mối quan hệ với WorkRelationship**:
```
Worker → WorkRelationship (type=EMPLOYEE) → Employee
         WorkRelationship (type=CONTRACTOR) → (không có bản ghi Employee)
```

---

### Contract

**Định nghĩa**: Văn bản và các điều khoản hợp đồng lao động hoặc dịch vụ pháp lý.

**Mục đích**:
- Theo dõi loại hợp đồng, thời hạn, gia hạn.
- Liên kết với tài liệu hợp đồng.
- Hỗ trợ phân cấp hợp đồng (gia hạn).

**Các thuộc tính chính**:
- `employee_id` hoặc `work_relationship_id` - Người đứng tên hợp đồng.
- `contract_type_code`:
  - `PERMANENT` - Không xác định thời hạn.
  - `FIXED_TERM` - Có thời hạn (ví dụ: 12 tháng).
  - `PROBATION` - Thử việc.
  - `SEASONAL` - Thời vụ.
- `work_schedule_type_code`:
  - `FULL_TIME` - Toàn thời gian (40 giờ/tuần).
  - `PART_TIME` - Bán thời gian (< 40 giờ/tuần).
  - `FLEXIBLE` - Giờ giấc linh hoạt.
- `parent_contract_id` - Cho việc gia hạn, liên kết với hợp đồng trước đó.
- `contract_number` - Số hợp đồng chính thức.
- `start_date` / `end_date` - Thời hạn hiệu lực hợp đồng.
- `supplier_id` - Nhà cung cấp (đối với nhân sự thuê ngoài).

**Quy tắc nghiệp vụ**:
- ✅ Chỉ một hợp đồng chính cho mỗi nhân viên tại một thời điểm.
- ✅ Hợp đồng có thời hạn phải có `end_date`.
- ✅ Hợp đồng gia hạn liên kết qua `parent_contract_id`.
- ⚠️ Ngày hợp đồng phải nằm trong khoảng thời gian của quan hệ công việc.

**Ví dụ Phân cấp Hợp đồng**:
```
Hợp đồng Ban đầu (01/01/2023 đến 31/12/2023)
  ↓ parent_contract_id
Gia hạn #1 (01/01/2024 đến 31/12/2024)
  ↓ parent_contract_id  
Gia hạn #2 / Chính thức (01/01/2025 trở đi)
```

---

### Assignment 🔄 NÂNG CẤP

**Định nghĩa**: Phân công người lao động thực hiện công việc tại một đơn vị kinh doanh và công việc/vị trí cụ thể.

**Mục đích**:
- Theo dõi phân công công việc thực tế.
- Hỗ trợ các mô hình định biên linh hoạt.
- Quản lý các mối quan hệ báo cáo (trực tiếp + gián tiếp).

**Các thuộc tính chính**:
- `work_relationship_id` - Liên kết trực tiếp WR (cho người không phải nhân viên) ✨.
- `employee_id` - Liên kết nhân viên (cho nhân viên) .
- `staffing_model_code` ✨ - `POSITION_BASED` (Theo vị trí) hoặc `JOB_BASED` (Theo công việc).
- `position_id` - Vị trí trong ngân sách (nếu là POSITION_BASED).
- `job_id` ✨ - Liên kết công việc trực tiếp (nếu là JOB_BASED).
- `business_unit_id` - Nơi làm việc.
- `primary_location_id` - Địa điểm làm việc vật lý.
- `is_primary_assignment` ✨ - Phân công chính nếu có nhiều phân công đồng thời.
- `assignment_category_code` ✨ - REGULAR (Thường xuyên), TEMPORARY (Tạm thời), PROJECT (Dự án).
- `fte` - Tương đương toàn thời gian (1.0 = toàn thời gian).
- `supervisor_assignment_id` - Người giám sát trực tiếp (Solid line).
- `dotted_line_supervisor_id` ✨ - Người giám sát ma trận (Dotted line).
- `status_code` - ACTIVE, SUSPENDED, ENDED.
- `start_date` / `end_date` - Thời gian phân công.

**Mô hình Định biên (Staffing Models)** ✨ MỚI:

#### POSITION_BASED (Theo Vị trí)
```yaml
# Sử dụng khi: Kiểm soát định biên chặt chẽ, các vai trò khối văn phòng/quản lý
Assignment:
  staffing_model: POSITION_BASED
  position_id: POS-FIN-MGR-001  # Bắt buộc
  job_id: JOB-FIN-MGR           # Dẫn xuất từ vị trí
  business_unit: Phòng Tài chính
```
- Vị trí trong ngân sách được định nghĩa trước.
- Một vị trí thường = một người.
- FTE được theo dõi ở cấp độ vị trí.
- Quản lý vị trí trống (vacancy).

#### JOB_BASED (Theo Công việc)
```yaml
# Sử dụng khi: Năng lực linh hoạt, công nhân theo giờ, nhà thầu
Assignment:
  staffing_model: JOB_BASED
  position_id: null             # Không có vị trí
  job_id: JOB-WAREHOUSE-WORKER  # Liên kết công việc trực tiếp
  business_unit: Kho vận
```
- Không yêu cầu vị trí định nghĩa trước.
- Nhiều người → cùng một công việc (job).
- Định biên linh hoạt.
- Năng lực động.

**Báo cáo Ma trận (Matrix Reporting)** ✨ NÂNG CẤP:
```yaml
Assignment:
  supervisor_assignment_id: MGR-001        # Báo cáo trực tiếp (Trưởng phòng Tài chính)
  dotted_line_supervisor_id: MGR-002       # Báo cáo gián tiếp (Trưởng dự án)
```

**Quy tắc nghiệp vụ**:
- ✅ Phải có `work_relationship_id` HOẶC `employee_id` (không cả hai).
- ✅ `POSITION_BASED` yêu cầu `position_id` (không null).
- ✅ `JOB_BASED` yêu cầu `position_id` là null, có thể chỉ định `job_id`.
- ✅ Chỉ một phân công chính cho mỗi người lao động tại một thời điểm.
- ✅ Người giám sát phải có phân công hoạt động trong cùng đơn vị hoặc đơn vị cha.
- ✅ Báo cáo gián tiếp (dotted line) chỉ mang tính thông tin (không ảnh hưởng chuỗi phê duyệt).

**Ví dụ**:

```yaml
# Ví dụ 1: Vai trò quản lý (theo vị trí)
Assignment:
  employee_id: EMP-001
  staffing_model: POSITION_BASED
  position_id: POS-CFO-001
  job_id: JOB-CHIEF-FINANCIAL-OFFICER
  fte: 1.0
  is_primary: true

# Ví dụ 2: Nhà thầu (theo công việc, không vị trí)
Assignment:
  work_relationship_id: WR-CONT-001
  staffing_model: JOB_BASED
  position_id: null
  job_id: JOB-SOFTWARE-CONSULTANT
  fte: 0.5
  is_primary: true

# Ví dụ 3: Công nhân theo giờ (theo công việc)
Assignment:
  employee_id: EMP-500
  staffing_model: JOB_BASED
  position_id: null
  job_id: JOB-RETAIL-ASSOCIATE
  fte: 1.0
```

---

### EmployeeIdentifier

**Định nghĩa**: Các mã định danh thay thế cho nhân viên (ngoài `employee_code` chính).

**Mục đích**:
- Liên kết với hệ thống bên ngoài (HRIS cũ, bảng lương).
- Số thẻ nhân viên, ID thẻ từ.
- Mã số thuế/BHXH cho bảng lương.

**Các loại định danh phổ biến**:
- `PAYROLL_ID` - Mã nhân viên hệ thống lương.
- `BADGE_ID` - Số thẻ ra vào.
- `LEGACY_SYSTEM_ID` - Mã nhân viên HRIS cũ.
- `BIOMETRIC_ID` - ID vân tay/khuôn mặt.
- `UNION_MEMBER_ID` - Số thẻ công đoàn.

**Quy tắc nghiệp vụ**:
- ✅ Cho phép nhiều định danh cho mỗi nhân viên.
- ✅ Mỗi tổ hợp (employee_id, id_type) là duy nhất.
- ✅ Một định danh chính cho mỗi loại.

**Ví dụ**:
```yaml
Employee: EMP-2024-001
Identifiers:
  - PAYROLL_ID: "PR-12345"
  - BADGE_ID: "BADGE-0001"
  - LEGACY_SYSTEM_ID: "OLD-HRIS-999"
```

---

### GlobalAssignment

**Định nghĩa**: Phân công quốc tế cho nhân viên làm việc xuyên quốc gia/pháp nhân.

**Mục đích**:
- Theo dõi phân công nhân sự nước ngoài (expatriate).
- Quản lý bảng lương xuyên biên giới.
- Điều chỉnh chi phí sinh hoạt (COLA).
- Bảng lương bóng (Shadow payroll).

**Các thuộc tính chính**:
- `employee_id` - Nhân viên được cử đi.
- `home_entity_id` - Pháp nhân gốc (chủ quản).
- `host_entity_id` - Pháp nhân tiếp nhận (nước sở tại).
- `assignment_type_code`:
  - `LONG_TERM` - Dài hạn (1+ năm).
  - `SHORT_TERM` - Ngắn hạn (< 1 năm).
  - `ROTATION` - Luân chuyển định kỳ.
- `home_country_code` / `host_country_code` - Quốc gia.
- `payroll_country_code` - Nơi xử lý lương.
- `shadow_payroll_flag` - Lương kép (cả hai nước).
- `housing_allowance_amt` - Phụ cấp nhà ở.
- `cola_factor` - Hệ số điều chỉnh sinh hoạt phí (vd: 1.25 = tăng 25%).
- `mobility_policy_code` - Chính sách luân chuyển của công ty.

**Quy tắc nghiệp vụ**:
- ✅ Pháp nhân gốc và tiếp nhận phải khác nhau.
- ✅ Nếu shadow_payroll = true, lương được tính ở cả hai nước.
- ✅ Hệ số COLA thường trong khoảng 0.8 đến 2.0.

**Ví dụ**:
```yaml
GlobalAssignment:
  employee_id: EMP-001
  home_entity: VNG-VIETNAM
  host_entity: VNG-SINGAPORE
  assignment_type: LONG_TERM
  payroll_country: SG
  shadow_payroll: true          # Vẫn có lương tại VN
  cola_factor: 1.35             # 35% COLA
  housing_allowance: 3000 USD/tháng
  start_date: 2024-01-01
  end_date: 2026-12-31
```

---

## 🔄 Luồng Hệ thống Phân cấp 4 Cấp độ

### Hành trình Nhân sự Trọn vẹn

```
1. TẠO NGƯỜI LAO ĐỘNG (WORKER)
   ↓
   Worker#001 (Nguyễn Văn A)
   - person_type: EMPLOYEE
   - date_of_birth: 15/05/1990
   
2. THIẾT LẬP QUAN HỆ CÔNG VIỆC
   ↓
   WorkRelationship#001
   - worker_id: Worker#001
   - legal_entity: VNG Corp
   - type: EMPLOYEE
   - start_date: 15/01/2024
   
3. KÝ HỢP ĐỒNG LAO ĐỘNG
   ↓
   Employee#001
   - work_relationship_id: WR#001
   - employee_code: "EMP-2024-001"
   - hire_date: 15/01/2024
   
   Contract#001
   - employee_id: Employee#001
   - type: PROBATION (Thử việc)
   - start: 15/01/2024
   - end: 15/04/2024
   
4. PHÂN CÔNG CÔNG VIỆC
   ↓
   Assignment#001
   - employee_id: Employee#001
   - staffing_model: POSITION_BASED
   - position: Lập trình viên Cao cấp
   - business_unit: Khối Kỹ thuật
   - start_date: 15/01/2024
```

---

## 💡 Các Kịch bản Phổ biến

### Kịch bản 1: Tuyển dụng Nhân viên Chính thức
```yaml
1. Tạo Worker (person_type = EMPLOYEE)
2. Tạo WorkRelationship (type = EMPLOYEE)
3. Tạo Employee (liên kết với WR)
4. Tạo Contract (THỬ VIỆC → CHÍNH THỨC)
5. Tạo Assignment (POSITION_BASED)
```

### Kịch bản 2: Thuê Nhà thầu
```yaml
1. Tạo Worker (person_type = CONTRACTOR)
2. Tạo WorkRelationship (type = CONTRACTOR)
3. Bỏ qua bản ghi Employee
4. Tạo Contract (liên kết trực tiếp với WR)
5. Tạo Assignment (JOB_BASED, không có vị trí)
```

### Kịch bản 3: Làm việc Kép (Dual Employment)
```yaml
Worker#001 (cùng một người)
  ↓
WorkRelationship#1 (Công ty A, EMPLOYEE, chính)
  ↓
  Employee#1 → Assignment#1 (Toàn thời gian)
  
WorkRelationship#2 (Công ty B, CONTRACTOR, phụ)
  ↓
  (Không có bản ghi Employee)
  Assignment#2 (Tư vấn bán thời gian)
```

### Kịch bản 4: Điều chuyển Nội bộ
```yaml
# Cùng Employee, Assignment mới
Employee#001 (không đổi)
  ↓
Assignment#1 (end_date = 30/06/2024)
  - position: Lập trình viên Sơ cấp
  - business_unit: Team A
  
Assignment#2 (start_date = 01/07/2024)
  - position: Lập trình viên Cao cấp
  - business_unit: Team B
  - reason_code: PROMOTION (Thăng chức)
```

---

## ⚠️ Lưu ý Quan trọng

### Thay đổi Phá vỡ Tương thích trong v2.0 (Breaking Changes)
1. **Employee bắt buộc phải có `work_relationship_id`**
   - Di chuyển dữ liệu: Tạo WorkRelationship cho mỗi Employee hiện có.
   
2. **Assignment có thể tham chiếu `work_relationship_id` HOẶC `employee_id`**
   - Nhân viên: Sử dụng `employee_id`.
   - Nhà thầu/Thời vụ: Sử dụng trực tiếp `work_relationship_id`.

3. **Mô hình định biên phải tường minh**
   - Phải chỉ định `POSITION_BASED` hoặc `JOB_BASED`.
   - Di chuyển dữ liệu: Thiết lập dựa trên sự tồn tại của `position_id`.

### Khi nào dùng Mô hình nào?

| Loại Người lao động | Quan hệ Công việc | Bản ghi Employee | Mô hình Định biên |
|---------------------|-------------------|------------------|-------------------|
| Nhân viên Chính thức | EMPLOYEE | Có | POSITION_BASED |
| Lãnh đạo/Quản lý | EMPLOYEE | Có | POSITION_BASED |
| Công nhân theo giờ | EMPLOYEE | Có | JOB_BASED |
| Nhà thầu Độc lập | CONTRACTOR | Không | JOB_BASED |
| Nhân sự Thời vụ | CONTINGENT_WORKER | Không | JOB_BASED |
| Thực tập sinh | INTERN | Tùy chọn | JOB_BASED |
| Thành viên HĐQT | NON_WORKER | Không | Không phân công |

---

## 🔗 Thuật ngữ Liên quan

- **Person** - Thực thể Worker và dữ liệu cá nhân.
- **JobPosition** - Cấu trúc Công việc và Vị trí.
- **BusinessUnit** - Đơn vị tổ chức.
- **LegalEntity** - Cấu trúc pháp nhân.

---

## 📚 Tài liệu Tham khảo

- Workday HCM: Khái niệm Work Relationship.
- Oracle HCM Cloud: Mô hình Con người Toàn cầu (Global Person Model).
- SAP SuccessFactors: Mô hình dữ liệu Employee Central.

---

**Phiên bản Tài liệu**: 2.0  
**Đánh giá lần cuối**: 01/12/2025  
**Đánh giá tiếp theo**: Q2 2025
