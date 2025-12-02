# Phân hệ Con người (Person) - Thuật ngữ

**Phiên bản**: 2.0  
**Cập nhật lần cuối**: 01/12/2025  
**Phân hệ con**: Dữ liệu chủ Người lao động (Worker)

---

## 📋 Tổng quan

Phân hệ Con người quản lý dữ liệu cốt lõi của người lao động bao gồm thông tin tiểu sử, liên hệ, địa chỉ, bằng cấp, kỹ năng và năng lực. Đây là **nền tảng** của mọi dữ liệu nhân sự.

**Mới trong v2.0**: Phân loại Loại đối tượng (Person Type) xác định hành vi hệ thống và các tính năng khả dụng.

### Các thực thể (10)
1. **Worker** 🔄 (Nâng cấp với Person Types) - Người lao động
2. **Contact** - Liên hệ
3. **Address** - Địa chỉ
4. **Document** - Tài liệu/Giấy tờ
5. **BankAccount** - Tài khoản ngân hàng
6. **WorkerRelationship** - Quan hệ nhân thân (không phải quan hệ công việc)
7. **WorkerQualification** - Bằng cấp/Chứng chỉ
8. **WorkerSkill** 🔄 (Nâng cấp với Phân tích khoảng cách kỹ năng) - Kỹ năng
9. **WorkerCompetency** - Năng lực hành vi
10. **WorkerInterest** - Sở thích/Nguyện vọng nghề nghiệp

---

## 🔑 Các thực thể chính

### Worker 🔄 NÂNG CẤP

**Định nghĩa**: Thực thể con người cốt lõi đại diện cho bất kỳ cá nhân nào trong hệ thống với danh tính bất biến trong suốt vòng đời.

**Mục đích**:
- Danh tính trung tâm cho mọi cá nhân.
- Dữ liệu tiểu sử và nhân khẩu học.
- Phân loại đối tượng (Person type).
- Điểm khởi đầu cho mọi quy trình nhân sự.

**Các thuộc tính chính**:
- `id` - **ID người lao động bất biến** (không bao giờ thay đổi, ngay cả khi nghỉ việc và quay lại).
- `person_type_code` ✨ - Phân loại hệ thống:
  - `EMPLOYEE` - Nhân viên chính thức (đầy đủ tính năng HR).
  - `CONTRACTOR` - Nhà thầu độc lập (tính năng hạn chế).
  - `CONTINGENT` - Nhân sự thời vụ/thuê ngoài.
  - `NON_WORKER` - Tham gia nhưng không được tuyển dụng (vd: thành viên HĐQT, cố vấn).
  - `PENDING` - Đang chờ tuyển dụng/Onboarding.
  - `FORMER` - Cựu nhân viên (lưu trữ dữ liệu lịch sử).
- `first_name`, `middle_name`, `last_name` - Họ tên pháp lý.
- `preferred_name` - Tên gọi khác/Biệt danh.
- `date_of_birth` - Ngày sinh (tính tuổi, quyền lợi).
- `gender_code` - Giới tính (từ CodeList).
- `nationality_code` - Quốc tịch (mã ISO-3166).
- `marital_status_code` - Tình trạng hôn nhân.
- `data_classification` ✨ - Siêu dữ liệu bảo mật (JSONB).

**Ví dụ Phân loại Dữ liệu**:
```json
{
  "sensitivity_level": "CONFIDENTIAL",
  "encryption_required": true,
  "pii_fields": ["date_of_birth", "nationality_code", "marital_status_code"],
  "access_scope": "SELF_AND_HR",
  "retention_years": 7,
  "gdpr_subject": true
}
```

**Hành vi theo Loại đối tượng**:

| Loại đối tượng | Hồ sơ HR | Phân công | Nghỉ phép | Lương | Tài năng |
|----------------|----------|-----------|-----------|-------|----------|
| EMPLOYEE | ✅ Đầy đủ | ✅ Có | ✅ Có | ✅ Có | ✅ Có |
| CONTRACTOR | ⚠️ Hạn chế | ✅ Có | ❌ Không | ⚠️ Hóa đơn | ❌ Không |
| CONTINGENT | ⚠️ Hạn chế | ✅ Có | ⚠️ Hạn chế | ⚠️ Agency | ❌ Không |
| NON_WORKER | ❌ Không | ❌ Không | ❌ Không | ❌ Không | ❌ Không |
| PENDING | ⚠️ Một phần | ❌ Không | ❌ Không | ❌ Không | ❌ Không |
| FORMER | 🔒 Chỉ xem | ❌ Không | ❌ Không | ❌ Không | ❌ Không |

**Quy tắc nghiệp vụ**:
- ✅ ID Worker là **bất biến** trọn đời (giữ nguyên ID nếu được tuyển dụng lại).
- ✅ Loại đối tượng xác định các tính năng và quy trình làm việc khả dụng.
- ✅ Loại `NON_WORKER` không thể có phân công công việc, nghỉ phép, hồ sơ tài năng.
- ✅ Loại `FORMER` giữ dữ liệu lịch sử nhưng bị khóa thay đổi.
- ✅ Một người lao động có thể có nhiều quan hệ công việc (xem phân hệ Employment).
- ✅ Dữ liệu cá nhân tập trung tại đây, dữ liệu việc làm tách biệt.
- ⚠️ Các trường PII (Thông tin định danh cá nhân) phải được mã hóa khi lưu trữ theo `data_classification`.

**Ví dụ**:
```yaml
Worker:
  id: WORKER-001
  person_type: EMPLOYEE
  first_name: "Nguyễn Văn"
  last_name: "An"
  preferred_name: "Andy"
  date_of_birth: 15/05/1990
  nationality: "VN"
  data_classification:
    sensitivity_level: "CONFIDENTIAL"
    pii_fields: ["date_of_birth", "nationality"]
```

---

### Contact

**Định nghĩa**: Thông tin liên hệ của người lao động bao gồm số điện thoại, email, tin nhắn tức thời và tài khoản mạng xã hội.

**Mục đích**:
- Nhiều phương thức liên hệ cho mỗi người.
- Chỉ định liên hệ chính.
- Xác thực loại liên hệ.

**Các thuộc tính chính**:
- `worker_id` - Người sở hữu liên hệ.
- `contact_type_code` - Loại từ danh mục ContactType:
  - `MOBILE_PERSONAL` - Di động cá nhân.
  - `MOBILE_WORK` - Di động công việc.
  - `EMAIL_PERSONAL` - Email cá nhân.
  - `EMAIL_WORK` - Email công việc.
  - `LINKEDIN`
  - `SKYPE`
  - `WHATSAPP`
- `contact_value` - Thông tin liên hệ thực tế.
- `is_primary` - Là liên hệ chính của loại này.
- Các trường SCD Type 2 (ngày hiệu lực, v.v.).

**Quy tắc nghiệp vụ**:
- ✅ Chỉ một liên hệ chính cho mỗi loại đối với mỗi người.
- ✅ Giá trị liên hệ phải khớp với regex xác thực từ ContactType.
- ✅ Email công việc thường tuân theo mẫu tên miền công ty.

**Ví dụ**:
```yaml
Worker: Nguyễn Văn An
Contacts:
  - type: EMAIL_WORK
    value: "an.nguyen@company.com"
    is_primary: true
  - type: MOBILE_PERSONAL
    value: "+84-901-234-567"
    is_primary: true
  - type: LINKEDIN
    value: "linkedin.com/in/annguyen"
    is_primary: false
```

---

### Address

**Định nghĩa**: Địa chỉ vật lý của người lao động (nhà riêng, thường trú, tạm trú).

**Mục đích**:
- Theo dõi nơi cư trú.
- Hỗ trợ tính toán thuế theo khu vực.
- Mục đích liên hệ khẩn cấp.
- Địa chỉ gửi thư từ/hồ sơ thuế.

**Các thuộc tính chính**:
- `worker_id` - Người lao động.
- `address_type_code`:
  - `HOME` - Nơi ở hiện tại.
  - `PERMANENT` - Thường trú (quê quán).
  - `TEMPORARY` - Tạm trú.
  - `MAILING` - Địa chỉ nhận thư.
- `admin_area_id` - Liên kết đến AdminArea (cấp phường/xã).
- `street_line` - Số nhà, tên đường.
- `postal_code` - Mã bưu chính.
- `is_primary` - Địa chỉ chính của loại này.
- Theo dõi SCD Type 2.

**Phân cấp Địa chỉ** (qua admin_area_id):
```
Quốc gia (Việt Nam)
  → Tỉnh/Thành phố (Hồ Chí Minh)
    → Quận/Huyện (Quận 1)
      → Phường/Xã (Phường Bến Nghé) ← admin_area_id trỏ vào đây
```

**Quy tắc nghiệp vụ**:
- ✅ Một địa chỉ chính cho mỗi loại.
- ✅ Phải liên kết đến cấp hành chính thấp nhất (phường/xã).
- ✅ Mã bưu chính phải khớp định dạng của quốc gia.

**Ví dụ**:
```yaml
Address:
  type: HOME
  admin_area_id: WARD-HCM-Q1-BENNGHE
  street_line: "123 Nguyễn Huệ"
  postal_code: "700000"
  is_primary: true
```

---

### Document

**Định nghĩa**: Các tài liệu/giấy tờ liên quan đến người lao động (CCCD, hộ chiếu, bằng cấp, chứng chỉ).

**Mục đích**:
- Lưu trữ siêu dữ liệu tài liệu và tham chiếu tệp.
- Theo dõi ngày hết hạn.
- Tuân thủ pháp lý (xác minh quyền làm việc).

**Các thuộc tính chính**:
- `worker_id` - Chủ sở hữu tài liệu.
- `document_type_code`:
  - `NATIONAL_ID` - CCCD/CMND.
  - `PASSPORT` - Hộ chiếu.
  - `DRIVERS_LICENSE` - Bằng lái xe.
  - `DEGREE` - Bằng cấp học thuật.
  - `CERTIFICATE` - Chứng chỉ nghề nghiệp.
  - `WORK_PERMIT` - Giấy phép lao động (người nước ngoài).
  - `VISA` - Thị thực.
- `document_number` - Số hiệu tài liệu.
- `issuing_authority` - Cơ quan cấp (vd: "Cục Cảnh sát QLHC về TTXH").
- `issue_date` / `expiry_date` - Thời hạn hiệu lực.
- `file_url` - Liên kết đến bản scan.
- SCD Type 2.

**Quy tắc nghiệp vụ**:
- ✅ Cảnh báo hết hạn cho giấy phép lao động, visa.
- ✅ CCCD và Hộ chiếu phải là duy nhất cho mỗi người.
- ⚠️ Tài liệu chứa dữ liệu cá nhân yêu cầu mã hóa.

**Ví dụ**:
```yaml
Documents:
  - type: NATIONAL_ID
    number: "001090012345"
    issue_date: 15/01/2020
    expiry_date: 15/01/2030
    issuing_authority: "Cục Cảnh sát QLHC về TTXH"
    
  - type: WORK_PERMIT
    number: "WP-2024-001"
    issue_date: 01/01/2024
    expiry_date: 31/12/2026
    issuing_authority: "Sở Lao động - Thương binh và Xã hội"
```

---

### BankAccount

**Định nghĩa**: Thông tin tài khoản ngân hàng của người lao động (trả lương, hoàn ứng).

**Mục đích**:
- Chuyển khoản lương trực tiếp.
- Hoàn trả chi phí công tác.
- Hỗ trợ nhiều tài khoản (chính + tiết kiệm).

**Các thuộc tính chính**:
- `worker_id` - Chủ tài khoản.
- `account_type_code`:
  - `SALARY` - Tài khoản nhận lương chính.
  - `SAVINGS` - Tài khoản tiết kiệm/phụ.
  - `EXPENSE_REIMBURSEMENT` - Nhận hoàn ứng chi phí.
- `bank_code` - Mã ngân hàng.
- `branch_code` - Mã chi nhánh.
- `account_number` - Số tài khoản.
- `account_holder_name` - Tên chủ tài khoản.
- `is_primary` - Tài khoản lương chính.
- `currency_code` - VND, USD, v.v.
- SCD Type 2.

**Quy tắc nghiệp vụ**:
- ✅ Chỉ một tài khoản lương chính tại một thời điểm.
- ✅ Tên chủ tài khoản nên khớp với tên pháp lý của người lao động.
- ✅ Loại tiền tệ phải khớp với loại tiền trả lương.
- ⚠️ Số tài khoản được mã hóa trong cơ sở dữ liệu.

**Ví dụ**:
```yaml
BankAccounts:
  - type: SALARY
    bank: "Vietcombank"
    branch: "HCM Quận 1"
    account_number: "0011000123456"
    currency: VND
    is_primary: true
    
  - type: SAVINGS
    bank: "Techcombank"
    account_number: "19036000123456"
    currency: USD
    is_primary: false
```

---

### WorkerRelationship

**Định nghĩa**: Quan hệ nhân thân giữa các cá nhân (gia đình, người phụ thuộc, liên hệ khẩn cấp).

⚠️ **Không nhầm lẫn với** `WorkRelationship` trong phân hệ Employment (là quan hệ công việc).

**Mục đích**:
- Theo dõi thành viên gia đình cho các chế độ phúc lợi.
- Người phụ thuộc giảm trừ gia cảnh.
- Liên hệ khẩn cấp.
- Người thụ hưởng bảo hiểm.

**Các thuộc tính chính**:
- `worker_id` - Người lao động chính.
- `related_worker_id` - Người liên quan (nếu cũng là worker trong hệ thống).
- `relationship_type_id` - Từ danh mục RelationshipType:
  - Gia đình: FATHER (Cha), MOTHER (Mẹ), SPOUSE (Vợ/Chồng), CHILD (Con), SIBLING (Anh chị em).
  - Tài chính: DEPENDENT (Người phụ thuộc).
  - Khẩn cấp: EMERGENCY_CONTACT (Liên hệ khẩn cấp).
- `related_person_name` - Tên người liên quan (nếu không phải worker).
- `dependency_flag` - Cờ người phụ thuộc tài chính (thuế).
- `is_emergency_contact` - Cờ liên hệ khẩn cấp.
- SCD Type 2.

**Quy tắc nghiệp vụ**:
- ✅ Quan hệ nghịch đảo tự động tạo (CHA ↔ CON).
- ✅ Người phụ thuộc ảnh hưởng đến tính thuế TNCN.
- ✅ Liên hệ khẩn cấp phải có số điện thoại hợp lệ.

**Ví dụ**:
```yaml
Worker: Nguyễn Văn An
Relationships:
  - related_person: "Trần Thị Bích" (vợ)
    relationship: SPOUSE
    dependency: true
    emergency_contact: true
    
  - related_person: "Nguyễn An Khang" (con)
    relationship: CHILD
    dependency: true
    date_of_birth: 01/05/2015
```

---

### WorkerQualification

**Định nghĩa**: Bằng cấp giáo dục và chứng chỉ nghề nghiệp.

**Mục đích**:
- Theo dõi bằng đại học, cao đẳng, chứng chỉ.
- Xác minh năng lực.
- Quy hoạch phát triển nghề nghiệp.

**Các thuộc tính chính**:
- `worker_id` - Người lao động.
- `qualification_type_code`:
  - Giáo dục: `BACHELOR` (Cử nhân), `MASTER` (Thạc sĩ), `PHD` (Tiến sĩ), `DIPLOMA` (Cao đẳng/Trung cấp).
  - Nghề nghiệp: `CPA`, `PMP`, `CISSP`, `AWS_CERTIFIED`.
- `institution_name` - Trường hoặc tổ chức cấp.
- `field_of_study` - Chuyên ngành.
- `graduation_date` hoặc `issue_date` - Ngày tốt nghiệp/cấp.
- `expiry_date` - Ngày hết hạn (đối với chứng chỉ có thời hạn).
- `grade_gpa` - Điểm số/Xếp loại.
- `verification_status` - VERIFIED (Đã xác minh), PENDING (Chờ), NOT_VERIFIED (Chưa xác minh).
- SCD Type 2.

**Quy tắc nghiệp vụ**:
- ✅ Chứng chỉ nghề nghiệp cần theo dõi gia hạn.
- ✅ Bằng cấp thường không hết hạn, chứng chỉ có thể có.
- ✅ Yêu cầu xác minh cho mục đích tuân thủ.

**Ví dụ**:
```yaml
Qualifications:
  - type: BACHELOR
    institution: "Đại học Bách Khoa"
    field_of_study: "Khoa học Máy tính"
    graduation_date: 30/06/2012
    gpa: 3.65
    verification_status: VERIFIED
    
  - type: PMP
    institution: "PMI"
    issue_date: 15/01/2023
    expiry_date: 15/01/2026
    verification_status: VERIFIED
```

---

### WorkerSkill 🔄 NÂNG CẤP

**Định nghĩa**: Kỹ năng của người lao động cùng với mức độ thành thạo và phân tích khoảng cách (gap analysis).

**Mục đích**:
- Theo dõi kỹ năng hiện tại và trình độ.
- Xác định khoảng cách kỹ năng (MỚI trong v2.0).
- Lập kế hoạch phát triển.
- Khớp nối công việc (Job matching).

**Các thuộc tính chính**:
- `worker_id` - Người lao động.
- `skill_id` - Liên kết đến SkillMaster.
- `proficiency_level` - Mức độ hiện tại (1-5 hoặc theo thang đo).
- `target_proficiency_level` ✨ - Mức độ mong muốn (MỚI).
- `proficiency_gap` ✨ - Tính toán: mục tiêu - hiện tại (MỚI).
- `estimated_gap_months` ✨ - Thời gian ước tính để lấp đầy khoảng cách (MỚI).
- `years_experience` - Số năm kinh nghiệm.
- `last_used_date` - Lần cuối sử dụng.
- `source_code`:
  - `SELF` - Tự đánh giá.
  - `MANAGER` - Quản lý đánh giá.
  - `CERT` - Dựa trên chứng chỉ.
  - `ASSESS` - Đánh giá chính thức.
- `verified_flag` - Đã được xác minh bởi quản lý/HR.
- `verified_date` ✨ - Ngày xác minh (MỚI).
- `verified_by_worker_id` ✨ - Người xác minh (MỚI).
- SCD Type 2.

**Thang đo Thành thạo** (ví dụ):
```
1 = Beginner (Nhận biết)
2 = Novice (Cơ bản, cần hướng dẫn)
3 = Intermediate (Độc lập)
4 = Advanced (Nâng cao, hướng dẫn người khác)
5 = Expert (Chuyên gia, dẫn dắt đổi mới)
```

**Phân tích Khoảng cách Kỹ năng** ✨ MỚI:
```yaml
Skill: Lập trình Python
  current_proficiency: 3 (Intermediate)
  target_proficiency: 5 (Expert)
  proficiency_gap: 2
  estimated_gap_months: 18
  development_plan:
    - Khóa học Python nâng cao (3 tháng)
    - Dẫn dắt 2 dự án Python (9 tháng)
    - Mentor cho lập trình viên trẻ (6 tháng)
```

**Quy tắc nghiệp vụ**:
- ✅ Chỉ kỹ năng đã xác minh mới được tính cho job matching.
- ✅ Đánh giá của quản lý ghi đè tự đánh giá.
- ✅ Chứng chỉ tự động được coi là đã xác minh.
- ✅ Gap > 0 kích hoạt gợi ý kế hoạch phát triển.
- ⚠️ Kỹ năng cũ hơn 3 năm có thể cần xác minh lại.

**Ví dụ**:
```yaml
WorkerSkills:
  - skill: "Python"
    current_proficiency: 4
    target_proficiency: 5
    gap: 1
    gap_months: 12
    years_experience: 5.5
    source: MANAGER
    verified: true
    
  - skill: "Machine Learning"
    current_proficiency: 2
    target_proficiency: 4
    gap: 2
    gap_months: 18
    source: SELF
    verified: false
```

---

### WorkerCompetency

**Định nghĩa**: Đánh giá năng lực hành vi (kỹ năng mềm).

**Mục đích**:
- Đánh giá hiệu suất.
- Phát triển lãnh đạo.
- Quy hoạch kế nhiệm.

**Các thuộc tính chính**:
- `worker_id` - Người lao động.
- `competency_id` - Liên kết đến CompetencyMaster.
- `rating_value` - Điểm số.
- `rating_scale_code` - Thang điểm (vd: 1-5, 1-10).
- `assessed_date` - Ngày đánh giá.
- `assessed_by_worker_id` - Người đánh giá.
- `source_code`:
  - `SELF` - Tự đánh giá.
  - `MGR` - Quản lý đánh giá.
  - `360` - Phản hồi 360 độ.
  - `SURVEY` - Khảo sát nhân viên.
- SCD Type 2.

**Năng lực phổ biến**:
- Lãnh đạo (Leadership)
- Giao tiếp (Communication)
- Làm việc nhóm (Teamwork)
- Giải quyết vấn đề (Problem Solving)
- Đổi mới (Innovation)
- Tập trung vào khách hàng (Customer Focus)
- Khả năng thích ứng (Adaptability)

**Ví dụ**:
```yaml
Competencies:
  - competency: "Lãnh đạo"
    rating: 4.5
    scale: "1-5"
    assessed_date: 30/06/2024
    source: "360"
    assessor: Quản lý
    
  - competency: "Giao tiếp"
    rating: 4.0
    scale: "1-5"
    source: "MGR"
```

---

### WorkerInterest

**Định nghĩa**: Sở thích và nguyện vọng nghề nghiệp của người lao động.

**Mục đích**:
- Quy hoạch lộ trình nghề nghiệp.
- Luân chuyển nội bộ.
- Khớp nối cơ hội trong thị trường tài năng (Talent marketplace).
- Theo dõi sự gắn kết.

**Các thuộc tính chính**:
- `worker_id` - Người lao động.
- `interest_type_code`:
  - `JOB_FAMILY` - Quan tâm đến nhóm nghề (vd: Kỹ thuật, Kinh doanh).
  - `JOB_ROLE` - Vai trò cụ thể (vd: Giám đốc sản phẩm).
  - `LOCATION` - Ưu tiên địa lý.
  - `PROJECT_TYPE` - Loại dự án ưu thích.
  - `LEARNING_TOPIC` - Chủ đề học tập.
- `interest_target_id` - Liên kết đến danh mục liên quan (Job, Location, v.v.).
- `interest_level` - 1-5 (5 = rất quan tâm).
- `willing_to_relocate` - Sẵn sàng chuyển nơi làm việc (Boolean).
- `available_from_date` - Thời gian sẵn sàng thay đổi.
- SCD Type 2.

**Quy tắc nghiệp vụ**:
- ✅ Sở thích được dùng để gợi ý công việc nội bộ.
- ✅ Cho phép nhiều sở thích.
- ✅ Sở thích liên kết với cơ hội trong Talent Marketplace.

**Ví dụ**:
```yaml
Interests:
  - type: JOB_ROLE
    target: "Giám đốc Sản phẩm"
    level: 5
    available_from: 01/01/2025
    
  - type: LOCATION
    target: "Văn phòng Singapore"
    level: 4
    willing_to_relocate: true
    
  - type: LEARNING_TOPIC
    target: "AI/Machine Learning"
    level: 5
```

---

## 🔄 Ví dụ Luồng Dữ liệu

### Onboarding Nhân viên Mới
```
1. Tạo Worker (person_type = PENDING)
   ↓
2. Thu thập thông tin cá nhân (liên hệ, địa chỉ)
   ↓
3. Tải lên tài liệu (CCCD, bằng cấp)
   ↓
4. Thiết lập tài khoản ngân hàng trả lương
   ↓
5. Ghi nhận bằng cấp và kỹ năng
   ↓
6. Cập nhật person_type thành EMPLOYEE (vào ngày tuyển dụng)
   ↓
7. Tạo WorkRelationship và Employee (xem phân hệ Employment)
```

### Chu trình Phát triển Kỹ năng
```
1. Quản lý đánh giá kỹ năng nhân viên
   ↓
2. Thiết lập mức độ thành thạo mục tiêu (xác định khoảng cách kỹ năng)
   ↓
3. Tính toán khoảng cách và ước tính thời gian
   ↓
4. Tạo kế hoạch phát triển
   ↓
5. Nhân viên hoàn thành đào tạo/dự án
   ↓
6. Đánh giá lại kỹ năng (mức độ thành thạo tăng)
   ↓
7. Khoảng cách được thu hẹp hoặc lấp đầy
```

---

## 💡 Thực tiễn Tốt nhất

### Quyền riêng tư & Bảo mật Dữ liệu
- ✅ Luôn điền `data_classification` cho PII.
- ✅ Mã hóa: số CCCD, số tài khoản ngân hàng, ngày sinh.
- ✅ Kiểm soát truy cập: SELF_AND_HR cho hầu hết dữ liệu cá nhân.
- ✅ Quyền được lãng quên (GDPR): Đánh dấu là FORMER, chỉ giữ lại dữ liệu tối thiểu.

### Quản lý Kỹ năng
- ✅ Đánh giá kỹ năng định kỳ (hàng năm).
- ✅ Quản lý xác minh cho các kỹ năng quan trọng.
- ✅ Liên kết kỹ năng với chương trình đào tạo.
- ✅ Sử dụng phân tích khoảng cách cho đánh giá hiệu suất.

### Quản lý Tài liệu
- ✅ Thiết lập cảnh báo hết hạn (giấy phép lao động, chứng chỉ).
- ✅ Scan và tải lên tất cả tài liệu quan trọng.
- ✅ Kiểm toán xác minh tài liệu định kỳ.

---

## ⚠️ Lưu ý Quan trọng

### Di chuyển dữ liệu Loại đối tượng (v2.0)
```sql
-- Thiết lập loại đối tượng cho worker hiện có
UPDATE person.worker
SET person_type_code = CASE
  WHEN EXISTS (SELECT 1 FROM employment.employee WHERE worker_id = worker.id)
    THEN 'EMPLOYEE'
  WHEN worker_category_code = 'CONTRACTOR'
    THEN 'CONTRACTOR'
  ELSE 'CONTINGENT'
END;
```

### Phân tích Khoảng cách Kỹ năng (v2.0)
- Các trường mới là tùy chọn để tương thích ngược.
- Điền mức độ mục tiêu trong các kỳ đánh giá hiệu suất.
- Sử dụng cho quy hoạch phát triển và kế nhiệm.

---

## 🔗 Thuật ngữ Liên quan

- **Employment** - Quan hệ công việc, nhân viên, phân công.
- **Common** - SkillMaster, CompetencyMaster, ContactType.
- **JobPosition** - Hồ sơ công việc với kỹ năng yêu cầu.

---

**Phiên bản Tài liệu**: 2.0  
**Đánh giá lần cuối**: 01/12/2025
