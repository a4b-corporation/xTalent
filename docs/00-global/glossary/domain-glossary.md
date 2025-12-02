# xTalent Domain Glossary

## Core Entities

### Person
Cá nhân (con người) trong hệ thống. Một Person có thể có nhiều Worker records (nhiều quan hệ lao động với các công ty khác nhau hoặc trong các thời kỳ khác nhau).

### Worker
Quan hệ lao động giữa Person và Organization. Đại diện cho việc một người làm việc cho một công ty cụ thể. Worker có Worker Number (mã nhân viên) và các thông tin về ngày vào làm, trạng thái làm việc.

### Legal Entity
Pháp nhân - công ty theo luật pháp. Một tập đoàn có thể có nhiều Legal Entities ở các quốc gia khác nhau.

### Organization Unit (OrgUnit)
Đơn vị tổ chức - phòng ban, bộ phận, team. Có cấu trúc phân cấp (parent-child).

### Job
Định nghĩa công việc/chức danh (ví dụ: Software Engineer, HR Manager). Là "template" chung, không gắn với vị trí cụ thể.

### Position
Vị trí cụ thể trong cơ cấu tổ chức. Một Position thuộc về một Job và một OrgUnit. Ví dụ: "Senior Developer position in Engineering Team A".

### Assignment
Phân công Worker vào Position. Một Worker có thể có nhiều Assignments (ví dụ: kiêm nhiệm), nhưng chỉ có một Primary Assignment tại một thời điểm.

---

## Time & Absence

### Time Type
Loại thời gian: làm việc, nghỉ phép, tăng ca, nghỉ ốm, v.v. Mỗi Time Type có các thuộc tính như có được trả lương không, có cần phê duyệt không.

### Time Balance
Số dư thời gian cho một Worker và một Time Type cụ thể. Ví dụ: số ngày phép năm còn lại, số giờ tăng ca đã tích lũy.

**Công thức:** Available = Total Allocated - Used - Pending

### Time Event
Sự kiện liên quan đến thời gian: đơn xin nghỉ phép, đăng ký tăng ca, thay đổi lịch làm việc. Có lifecycle: Draft → Pending → Approved/Rejected.

### Time Movement
Bút toán ghi sổ cho Time Balance. Mỗi khi có thay đổi balance (cấp phép, sử dụng phép, điều chỉnh), tạo một Movement record để audit trail.

**Movement Types:**
- **ALLOCATION**: Cấp phép (credit)
- **USAGE**: Sử dụng phép (debit)
- **ADJUSTMENT**: Điều chỉnh (có thể + hoặc -)
- **CARRYOVER**: Chuyển sang năm sau

---

## Total Rewards

### Compensation Plan
Kế hoạch lương thưởng - định nghĩa cấu trúc lương cho một nhóm nhân viên. Ví dụ: "Monthly Salary Plan", "Annual Bonus Plan".

### Compensation Component
Thành phần lương thưởng cụ thể trong một Plan. Ví dụ: Base Salary, Housing Allowance, Performance Bonus.

**Component Types:**
- **FIXED**: Cố định (base salary)
- **VARIABLE**: Biến động (bonus, commission)
- **RECURRING**: Định kỳ (monthly allowance)
- **ONE_TIME**: Một lần (signing bonus)

### Compensation Assignment
Gán một Compensation Component cho một Worker cụ thể với số tiền và thời gian hiệu lực.

### Grade
Bậc lương/cấp bậc. Mỗi Grade có min/mid/max salary range. Jobs thường được gán vào Grades để xác định mức lương chuẩn.

---

## Payroll

### Payroll Period
Kỳ tính lương - thường là tháng, có thể là tuần hoặc hai tuần tùy chính sách công ty.

### Payroll Run
Lần chạy tính lương cho một Payroll Period. Có thể có nhiều runs (draft, final, correction).

### Payroll Element
Các khoản trong bảng lương: lương cơ bản, phụ cấp, khấu trừ, thuế, bảo hiểm.

**Element Types:**
- **EARNING**: Các khoản thu nhập (salary, bonus, allowance)
- **DEDUCTION**: Các khoản khấu trừ (tax, insurance, loan)
- **EMPLOYER_CONTRIBUTION**: Đóng góp của công ty (employer's insurance)

### Payroll Result
Kết quả tính lương cho một Worker trong một Payroll Period. Bao gồm tất cả các elements và net pay (lương thực nhận).

---

## Common Terms

### Effective Date
Ngày hiệu lực - ngày bắt đầu áp dụng một thay đổi.

### End Date
Ngày kết thúc - có thể null nếu không có ngày kết thúc xác định.

### Status
Trạng thái - thường có các giá trị: ACTIVE, INACTIVE, PENDING, APPROVED, REJECTED, CANCELLED.

### Lifecycle
Vòng đời - chuỗi các trạng thái mà một entity có thể đi qua. Ví dụ: DRAFT → PENDING → APPROVED.

### Primary
Chính - đánh dấu record chính khi có nhiều records cùng loại. Ví dụ: Primary Assignment là assignment chính của worker.

### Audit Trail
Dấu vết kiểm toán - lịch sử các thay đổi của dữ liệu, thường thông qua Movement/Transaction records.

---

## Abbreviations

- **CO**: Core (Core HR module)
- **TA**: Time & Absence
- **TR**: Total Rewards
- **PR**: Payroll
- **LE**: Legal Entity
- **OU**: Organization Unit
- **WD**: Workday (có thể dùng trong context scheduling)
- **FTE**: Full-Time Equivalent
- **YTD**: Year-to-Date
- **MTD**: Month-to-Date
