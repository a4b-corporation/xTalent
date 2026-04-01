Cảm ơn bạn đã cung cấp thông tin chi tiết. Mình sẽ tiến hành các bước sau:

1. Rà soát lại toàn bộ thiết kế DBML trong file `5.Payroll.V3.dbml` theo chuẩn của các hệ thống như Oracle HCM, Workday, SAP SuccessFactors,… đảm bảo khả năng triển khai đa quốc gia, nhiều tiền tệ, luật pháp đa thị trường, hỗ trợ rule + scripting engine.
    
2. Tổng hợp lại toàn bộ các file YAML sub-module bạn đã cung cấp và viết lại thành một file OpenAPI 3.0 hoàn chỉnh, sử dụng `x-tag` để chia module rõ ràng: config, engine, input, audit, gateway, retro, profile.
    
3. Viết file mapping dạng CSV giữa API Spec và DBML theo cấu trúc bạn yêu cầu: API Name, API Endpoint, Table, Table Field, API Field, CRUD, Rule/Filter, Notes.
    

Mình sẽ bắt đầu thực hiện và sẽ gửi lại cho bạn khi hoàn tất.

# Đánh Giá Thiết Kế DBML Module Payroll và Mapping API-Database

## Rà Soát Các Phân Hệ Payroll Theo Tiêu Chuẩn Hiện Đại

Dựa trên thiết kế DBML hiện tại, module Payroll đã được chia thành các phân hệ: **Config**, **Input**, **Profile**, **Retro**, **Audit**, **Engine**, và **Gateway**. Đây là cách tiếp cận phù hợp, bao quát hầu hết chức năng của hệ thống tính lương hiện đại tương tự các giải pháp hàng đầu như Oracle HCM, SAP SuccessFactors, Workday. Sau đây là đánh giá chi tiết từng phân hệ, đối chiếu với nghiệp vụ chuẩn, đồng thời đề xuất mở rộng nếu còn thiếu:

### 1. **Payroll Config** – Cấu hình Bảng Lương

Phân hệ **Config** hiện tại đã có các mục chính: cấu hình chung (tiền tệ, định dạng số, phương pháp làm tròn), bảng luật thuế/BHXH (theo thời gian và vùng), mapping tài khoản kế toán (GL mapping), mẫu phiếu lương, và quy tắc kiểm tra trước khi chốt lương. Những thành phần này đáp ứng yêu cầu cấu hình linh hoạt cho hệ thống:

- **Global Config:** Lưu trữ tiền tệ mặc định, format số và quy tắc làm tròn. Điều này đảm bảo tính nhất quán cho tính toán và hiển thị kết quả lương. (Oracle, SAP cũng có thiết lập tương tự về tiền tệ và làm tròn)
    
- **Statutory Table (Tax & Insurance rules):** Cho phép quản lý các **quy định pháp lý** (thuế TNCN, BHXH, etc) theo thời gian hiệu lực và quốc gia/vùng. Thiết kế hiện tại cho phép tạo, cập nhật, xóa các luật thuế/BHXH với hiệu lực từ ngày đến ngày. Đây là tính năng quan trọng giúp hệ thống luôn tuân thủ pháp luật địa phương – tương tự module **Global Tax and Regulatory Compliance** của SAP SuccessFactors.
    
- **GL Mapping:** Cho phép ánh xạ mã **yếu tố lương** (các khoản thu nhập/khấu trừ) với mã **tài khoản kế toán** để phục vụ hạch toán. Hiện tại thiết kế đã có API CRUD cho GL mapping (tạo, cập nhật, xóa mapping). Tính năng này hỗ trợ tích hợp kết quả lương vào sổ cái kế toán, tương tự việc tích hợp với phân hệ tài chính trong các giải pháp lớn.
    
- **Payslip Template:** Cho phép cấu hình mẫu phiếu lương (template) – bao gồm layout PDF, các trường dữ liệu lương hiển thị. Đây là tính năng tốt để tùy biến phiếu lương cho từng công ty hoặc đơn vị. Tuy nhiên, hiện tại mới có **cấu hình** mẫu, chưa thấy API để **phát hành/xuất phiếu lương** cho nhân viên theo kỳ. Trong các hệ thống hiện đại, việc **phát hành phiếu lương điện tử** cho nhân viên là cần thiết. _Đề xuất:_ bổ sung chức năng xuất phiếu lương (ví dụ: endpoint để lấy PDF phiếu lương của nhân viên theo payrollRunId). Điều này có thể được thực hiện qua Gateway hoặc một service riêng, sử dụng mẫu đã cấu hình để điền dữ liệu và tạo file PDF.
    
- **Validation Rule:** Các quy tắc kiểm tra trước khi chốt kỳ lương (vd: thiếu thông tin tài khoản ngân hàng, lương âm, vượt trần...) đã được thiết kế đầy đủ với CRUD. Điều này tương tự **Payroll Control Center** trong SAP (PCC cung cấp công cụ kiểm tra lỗi trước khi chốt lương) – giúp phát hiện sai sót kịp thời.
    
- **Thiếu/Đề xuất:** Có thể xem xét **đa tiền tệ** và **đa quốc gia** kỹ hơn. Hiện tại, GlobalConfig có **defaultCurrency** cho toàn hệ thống. Trong trường hợp doanh nghiệp đa quốc gia, mỗi nhóm lương có thể dùng tiền tệ khác nhau. Giải pháp hiện tại cho phép cấu hình luật thuế theo vùng (region) nhưng tiền tệ thì cố định. _Đề xuất:_ thêm thuộc tính **currency** cho từng **Payroll Calendar hoặc Pay Group** (xem phần Engine bên dưới) để hỗ trợ vận hành song song nhiều pay group ở các quốc gia khác nhau. Các hệ thống lớn (Workday, SuccessFactors) đều hỗ trợ đa tiền tệ và đa địa phương trong cùng hệ thống.
    

Nhìn chung, **Payroll Config** đã khá đầy đủ và linh hoạt. Các bảng chính cần có trong DB: `GlobalConfig`, `StatutoryRule` (và bảng con cho bracket thuế nếu cần), `GLMapping`, `PayslipTemplate`, `ValidationRule`. Các quan hệ cần chú ý: `GLMapping.elementCode` nên tham chiếu tới mã yếu tố lương (từ bảng PayElement bên Engine) để đảm bảo tính đúng đắn; `StatutoryRule` có thể cần bảng con `TaxBracket` để lưu các bậc thuế thu nhập cá nhân (nếu không lưu dạng JSON).

### 2. **Payroll Input** – Tiếp Nhận Dữ Liệu Đầu Vào

Phân hệ **Input** đảm bảo thu thập mọi dữ liệu cần cho tính lương, từ nhiều nguồn: chấm công, nghỉ phép, thưởng/hoa hồng, nhập thủ công, thay đổi nhân sự. Thiết kế API hiện tại rất chi tiết và sát với thực tế:

- **Time & Attendance:** API `/time-attendance` nhận dữ liệu ngày công, giờ làm thêm của nhân viên theo kỳ lương. Điều này tích hợp chặt với hệ thống chấm công (Workday, SuccessFactors cũng có module T&A riêng). DB cần bảng (hoặc tập bản ghi) lưu các chỉ số như workDays, overtimeHours cho từng nhân viên, kỳ.
    
- **Absence:** API `/absence` nhận dữ liệu ngày nghỉ không lương, nghỉ phép hưởng lương. Dữ liệu này dùng để trừ lương đúng quy định.
    
- **Total Reward (Bonus/Commission):** API `/total-reward` nhận các khoản thu nhập bổ sung (thưởng, hoa hồng...). Hệ thống cho phép gửi nhiều loại khoản thưởng cho nhiều nhân viên cùng lúc, mỗi khoản có code riêng (VD: BONUS, COMMISSION).
    
- **Manual Input (Upload):** API `/manual-upload` hỗ trợ upload file CSV chứa dữ liệu lương thủ công. Cơ chế này hữu ích khi cần nhập liệu hàng loạt hoặc tích hợp từ nguồn chưa có API. Hệ thống tạo `jobId` xử lý file và có log kết quả cho từng dòng (kết quả tra qua audit log). _Đề xuất:_ trong DB có thể có bảng `ImportJob` để lưu trạng thái job upload (ID, thời gian, người thực hiện, trạng thái, kết quả). Mỗi dòng import thành công/lỗi đã được ghi vào Audit Log, nhưng để dễ truy cứu, bảng `ImportJobDetail` (hoặc dùng AuditLog) có thể lưu chi tiết lỗi từng dòng.
    
- **Employee Change:** API `/employee-changes` nhận sự kiện nhân sự (tuyển mới, thôi việc, điều chuyển). Điều này rất quan trọng để Payroll tự động cập nhật nhân viên trong kỳ lương: thêm nhân viên mới (tính prorate nếu vào giữa kỳ), đánh dấu nhân viên nghỉ việc (tính phần lương cuối cùng, trợ cấp nghỉ việc nếu có). Nhiều hệ thống lớn sử dụng “sự kiện nhân sự” để kích hoạt tính toán lương tương ứng – thiết kế này là phù hợp.
    
- **Input Summary:** API `/inputs` (GET) tổng hợp toàn bộ dữ liệu đầu vào đã có của một kỳ lương, cho phép lọc theo kỳ hoặc nhân viên. Kết quả nhóm theo nhân viên, liệt kê các **InputItem** (sourceType, code, value) cho từng người. Đây là tính năng hữu ích để đối chiếu, đảm bảo đủ dữ liệu trước khi tính lương.
    

**Đề xuất về thiết kế DB Input:** Hiện tại, mỗi API Input nhận một array các bản ghi (mỗi bản ghi có employeeId, khoảng kỳ lương, và dữ liệu cụ thể). Có hai hướng thiết kế bảng:

1. **Tách bảng theo loại input** – ví dụ bảng `TimeAttendanceInput(employeeId, payrollRunId?, workDays, overtimeHours, otherHours)`, bảng `AbsenceInput(employeeId, payrollRunId, unpaidDays, paidDays)`, bảng `RewardInput(employeeId, payrollRunId) + RewardItems`... Cách này phản ánh đúng cấu trúc từng loại dữ liệu, nhưng sẽ rải rác nhiều bảng và phức tạp khi tổng hợp.
    
2. **Gộp chung bảng InputRecords** – chứa các trường: `employeeId`, `payrollCalendarId` (hoặc payGroup), `periodStart`, `periodEnd`, `sourceType`, `code`, `value`. Theo cách này, mỗi chỉ số (workDays, OT hours, unpaidDays, BONUS…) sẽ là một dòng trong InputRecords. Ưu điểm: dễ truy vấn tổng hợp (dùng `sourceType` và `code` để phân loại), mở rộng linh hoạt khi có thêm loại dữ liệu. Thiết kế `InputSummary` trong API cũng thiên về hướng này (liệt kê list `InputItem` code/value cho mỗi nhân viên). _Đề xuất:_ sử dụng một bảng `PayrollInputItem` thống nhất, với khóa nhận diện kỳ lương (có thể là `payrollRunId` hoặc cặp `payrollCalendarId + periodStart/periodEnd` nếu muốn lưu cả khi chưa tạo run). Mỗi bản ghi lưu **một loại dữ liệu** cho một nhân viên. Ví dụ: 1 nhân viên tháng 1/2025 có 3 mục input – WORK_DAYS=26, OT_HOURS=10, BONUS=1,000,000 (3 dòng). Trường `sourceType` giúp biết đến từ đâu (TimeAttendance/Absence/Reward/Manual). Cần đánh chỉ mục cho `employeeId` + kỳ để truy vấn nhanh khi tổng hợp.
    

**Liên kết với kỳ lương (payroll run):** Điểm cần lưu ý là API Input hiện không truyền thẳng `payrollRunId` mà dùng `payGroupCode` hoặc ngày kỳ lương. Như vậy, hệ thống sẽ phải xác định kỳ lương tương ứng dựa trên nhóm lương và khoảng thời gian. Để hỗ trợ, DB nên có bảng `PayrollRun` (ở Engine) lưu các kỳ lương đã tạo. Input có thể được lưu tạm với thông tin kỳ (calendar, period), và khi `PayrollRun` được tạo (init kỳ lương), ta cập nhật gắn `runId` vào các input tương ứng. Việc này đảm bảo dữ liệu input gắn liền với kỳ lương cụ thể (nhất là trường hợp **rollback** tạo kỳ mới cho cùng khoảng thời gian).

Nhìn chung, phân hệ **Input** đã bao quát các nguồn dữ liệu chính ảnh hưởng lương (công, nghỉ, thưởng, điều chỉnh thủ công). Đây cũng chính là các nhóm dữ liệu mà giải pháp SAP liệt kê: **Time Data, Absence, Compensation Data (Bonus)** là đầu vào cho tính lương. Thiết kế API không thiếu mảng nào đáng kể. Chỉ cần đảm bảo thiết kế bảng lưu trữ phù hợp để không mất dữ liệu và thuận tiện khi tính toán.

### 3. **Payroll Profile** – Hồ Sơ Lương Nhân Viên

Phân hệ **Profile** hiện tập trung vào **thông tin chi trả lương cố định của nhân viên** (Employee Payroll Profile), như: tài khoản ngân hàng, mã số thuế TNCN, số người phụ thuộc, số sổ BHXH, mã nhóm lương (pay group) của nhân viên. Đây là những thông tin thiết yếu cần có trước khi tính lương cho mỗi nhân viên:

- **API /employees (GET):** Lấy danh sách hồ sơ lương của nhân viên, hoặc chi tiết hồ sơ của một người (lọc theo employeeId). Kết quả bao gồm các trường như tài khoản ngân hàng, mã số thuế, người phụ thuộc, BHXH, nhóm lương...
    
- **API /employees (POST):** Tạo hồ sơ lương cho một nhân viên mới. Khi có nhân viên mới gia nhập, cần gọi API này để thêm thông tin chi trả của họ, đảm bảo payroll có đủ dữ liệu tính thuế, trả lương. Sau khi tạo thành công có phát sự kiện báo hồ sơ lương sẵn sàng.
    

Thiết kế này tương tự việc quản lý **Personal Payment Method và Tax Details** trong các hệ thống lớn (Oracle HCM có đối tượng Personal Payment Method lưu thông tin tài khoản ngân hàng, và Calculation Card cho thông tin thuế/TNCN).

**Bảng DB cần thiết:** `EmployeePayrollProfile` với khóa chính `employeeId` (trùng với Employee từ HR Core). Các cột: `bankAccountNo`, `bankName`, `taxId`, `dependentsCount`, `socialInsuranceNo`, `payGroupCode` (hoặc `payrollCalendarId` nếu dùng calendar làm nhóm lương). Những thông tin này thường ít thay đổi, nhưng nếu thay đổi cũng nên audit (và Audit Log sẽ ghi lại thay đổi do category PROFILE).

**Liên kết với HR Core:** Trong mô hình headless, ta giả định nhân viên đã tồn tại ở HRM core. Hồ sơ lương là phần mở rộng gắn vào nhân viên đó. Cần thống nhất nguồn dữ liệu `employeeId` (UUID) giữa HR Core và Payroll. Có thể không lưu quá nhiều thông tin cá nhân ở đây, chỉ các trường liên quan trả lương. Nếu hệ thống lớn, các thông tin như **mức lương cơ bản, phụ cấp cố định của nhân viên** thường nằm ở **phân hệ Quản lý Nhân sự/Compensation**, và payroll chỉ tham chiếu khi tính toán (qua input hoặc công thức). Thiết kế hiện tại không có bảng lưu lương cơ bản của từng nhân viên – điều này ổn vì có thể nhập lương cơ bản như một **yếu tố lương** (Pay Element) được gán vào mỗi nhân viên (qua input hoặc cấu hình công thức lấy từ HR).

**Pay Group:** Thuộc tính `payGroupCode` trong profile cho phép nhóm nhân viên theo chế độ trả lương. Theo ví dụ, có thể một nhóm lương theo kỳ tháng (“THANG1-2025” chỉ kỳ trả lương tháng 1/2025). Tuy nhiên, code này gây hiểu nhầm do chứa cả thời gian. Có lẽ `payGroupCode` nên là mã **nhóm trả lương cố định** (ví dụ: `MONTHLY_VN` cho nhóm trả lương hàng tháng tại VN). Mỗi nhóm lương sẽ gắn với một **Payroll Calendar** tương ứng. _Đề xuất:_ Cần định nghĩa rõ khái niệm **Pay Group** và **Payroll Calendar**:

- **Payroll Calendar** (xem phần Engine) định nghĩa tần suất trả lương (hàng tháng, 2 lần/tháng, hàng tuần...) và các mốc cắt kỳ.
    
- **Pay Group** có thể là thực thể đại diện cho **nhóm nhân viên** dùng chung một Payroll Calendar và chính sách trả lương. Để đơn giản, có thể đồng nhất PayGroup với PayrollCalendar (1 lịch lương ~ 1 nhóm nhân viên). Trong DB, nên có bảng `PayrollCalendar` (hoặc PayGroup) chứa mã và tần suất. Trường `payGroupCode` trong `EmployeePayrollProfile` sẽ là foreign key tới bảng này (nếu dùng code, phải đảm bảo mã unique).
    

Nhìn chung, phân hệ **Profile** hiện tại đã cover phần thông tin tĩnh cần cho tính lương. Không có khoảng trống lớn nào cần bổ sung. Một cải tiến nhỏ có thể cân nhắc: cho phép **quản lý nhiều tài khoản ngân hàng** (trường hợp nhân viên muốn chia lương vào 2 tài khoản) – nhưng điều này phức tạp, thường giải pháp cho phép 1 tài khoản chính.

### 4. **Payroll Retro** – Xử Lý Hồi Tố, Điều Chỉnh, Đảo Ngược

Phân hệ **Retro** là phần phức tạp nhưng vô cùng quan trọng để đảm bảo tính đúng đắn khi có thay đổi dữ liệu quá khứ. Thiết kế hiện tại đã gồm 3 chức năng chính: **Điều chỉnh thủ công**, **Tính hồi tố**, **Đảo ngược kỳ lương**:

- **Manual Adjustments:** Cho phép thêm/sửa/xóa **điều chỉnh lương thủ công** cho nhân viên trong một kỳ lương nhất định. API GET `/manual-adjustments` hỗ trợ lọc theo trạng thái (PENDING/APPLIED), nhân viên, hoặc khoảng thời gian kỳ lương. API POST tạo mới adjustment ở trạng thái PENDING; PUT cập nhật adjustment (đổi số tiền, lý do hoặc trạng thái); DELETE xóa điều chỉnh (chỉ khi PENDING).  
    _DB:_ Cần bảng `ManualAdjustment` (id, employeeId, periodStart, periodEnd, elementCode, amount, reason, status, createdBy, createdAt). Lược đồ này đã thể hiện trong schema. Lưu ý: `elementCode` dùng để xác định yếu tố lương nào được điều chỉnh (VD: **BASIC_SALARY** hoặc **OT_PAY**...). Phải khớp với bảng PayElement. Ngoài ra, thay vì lưu periodStart/End, ta có thể lưu `payrollRunId` nếu có (giúp liên kết điều chỉnh với kỳ lương cụ thể). Tuy nhiên, do thiết kế cho phép tạo trước khi áp dụng, có thể chưa có runId (nếu điều chỉnh cho kỳ chưa chốt?). Cách Oracle xử lý concept này là có **Element Entry** bổ sung cho từng người, và khi tính toán lại, những entry (điều chỉnh) PENDING sẽ được áp dụng. Giải pháp hiện tại với ManualAdjust PENDING/APPLIED cũng tương tự: khi chạy tính lương, engine cần lấy các bản ghi PENDING phù hợp kỳ để cộng vào kết quả, sau đó chuyển trạng thái APPLIED.
    
- **Retroactive Calculation:** API POST `/calculate` thực hiện tính **hồi tố lương** cho một kỳ lương đã chốt trước đó. Người gọi cung cấp `originalBatchId` (ID kỳ lương gốc cần tính lại) và tùy chọn danh sách employeeIds (nếu chỉ muốn tính cho một số nhân viên). Hệ thống tạo một “đợt tính toán hồi tố” và so sánh kết quả mới với kết quả cũ, chênh lệch sẽ được áp dụng vào kỳ hiện tại hoặc tạo hẳn một kỳ lương **loại RETRO** riêng. API trả về status 202 Accepted, kèm `retroBatchId` (nếu có tạo batch mới) và số nhân viên ảnh hưởng.
    
    - Đây là cơ chế **Retropay** phổ biến: không sửa kết quả kỳ cũ, mà tạo phiếu lương chênh lệch ở kỳ hiện tại hoặc kỳ đặc biệt. Hệ thống Oracle HCM cũng thực hiện tương tự: khi chạy retropay, kết quả tính lại không sửa dữ liệu lịch sử mà tạo các **retroactive entries** để cộng/trừ vào kỳ hiện tại.  
        _DB:_ Nên có cách đánh dấu một kỳ lương là **Retro Batch**. Có thể thêm thuộc tính `type` cho bảng `PayrollRun` (NORMAL, RETRO). Nếu `retroBatchId` được tạo, tức là hệ thống đã thêm một bản ghi `PayrollRun` mới kiểu RETRO (liên kết với originalBatch). Có thể có bảng `RetroCalculation` để log chi tiết (originalBatchId, retroBatchId, lý do, time run, người thực hiện), nhưng cũng có thể không cần nếu Audit log đã ghi sự kiện.
        
    - Cũng nên lưu các **chênh lệch** ở cấp độ chi tiết: hoặc là tạo các ManualAdjustment tự động cho từng chênh lệch, hoặc trực tiếp nhập vào kết quả kỳ retro. Tùy thiết kế Engine, nhưng cần tính đến để có lịch sử minh bạch.
        
- **Payroll Reversal (Rollback):** API `/reverse-run` tạo yêu cầu **đảo ngược một kỳ lương đã chốt**. Truyền vào batchId cần rollback, hệ thống sẽ: đánh dấu kỳ đó là đã đảo ngược, mở ra một kỳ lương mới (trạng thái INIT) với cùng khoảng thời gian để tính lại từ đầu. Kết quả trả về `newBatchId` của kỳ mới. Tính năng này rất quan trọng khi phát hiện sai sót nghiêm trọng sau khi chốt lương (VD: cấu hình sai công thức, cần hủy bỏ toàn bộ kỳ lương cũ).  
    _DB:_ Thuộc tính `status` của `PayrollRun` cần có giá trị như **REVERSED** (hoặc một flag `isReversed=true`). Cần lưu tham chiếu `reversedByRunId` (kỳ mới thay thế kỳ cũ) hoặc `originalRunId` (kỳ gốc bị đảo) cho kỳ mới. Điều này cho phép truy vết quan hệ giữa các kỳ.
    

Thiết kế hiện tại của **Retro** module khá đầy đủ, tương đồng với chức năng “Retroactive Pay” và “Reversal/Retry Payroll” trong các hệ thống lớn. **Manual adjustment** cho phép xử lý các trường hợp ngoại lệ thủ công (ví dụ truy lĩnh, truy thu đặc biệt) – đây cũng là yêu cầu phổ biến. Không thấy thiếu mảng chức năng nào lớn.

Chỉ có một lưu ý nhỏ: nên cân nhắc thêm endpoint hoặc tùy chọn để **áp dụng hàng loạt manual adjustments** khi chốt lương. Hiện tại, có lẽ khi finalizeRun, engine sẽ tự kiểm tra các adjustment PENDING và áp vào, sau đó chuyển chúng thành APPLIED. Điều này cần được làm rõ trong phần Engine (có thể ẩn trong logic).

### 5. **Payroll Audit** – Lịch Sử & Kiểm Toán

Phân hệ **Audit** phục vụ mục đích truy vết, báo cáo kiểm toán – một thành phần không thể thiếu để đảm bảo minh bạch và tuân thủ. Hiện tại Audit service có:

- **Audit Log (GET /logs):** Truy vấn danh sách log theo các tiêu chí lọc: category (CONFIG, PROFILE, INPUT, RUN), khoảng thời gian, employeeId, batchId. Log bao gồm các thay đổi cấu hình, thay đổi dữ liệu đầu vào/hồ sơ, các hành động quy trình (chạy tính lương, chốt lương, hồi tố, đảo ngược). Điều này tương tự chức năng “Audit Trail” của Oracle – cho biết **ai thay đổi gì, khi nào** trên đối tượng payroll. Thiết kế schema AuditLog cũng hợp lý: timestamp, user, category, action, detail, referenceId (tham chiếu đối tượng liên quan).
    
- **Audit Export (GET /logs/export):** Xuất báo cáo audit (CSV) cho một kỳ lương cụ thể. Báo cáo bao gồm các cột: thời gian, người thực hiện, loại sự kiện, hành động, chi tiết. Điều này hữu ích cho kiểm toán bên ngoài hoặc lưu trữ lâu dài.
    

Về **database**, một bảng `AuditLog` sẽ lưu tất cả các nhật ký. Các cột đã nêu trên. Cần chú ý:

- Trường `category` nên có enum giá trị (CONFIG, PROFILE, INPUT, RUN) để dễ lọc. Trong đó, **RUN** bao gồm các sự kiện quy trình (tạo kỳ lương, tính toán, finalize, retro, reverse...). **INPUT** bao gồm cả manual adjustments và file import. **PROFILE** cho thay đổi hồ sơ nhân viên. **CONFIG** cho các thay đổi cấu hình (global, luật, element, công thức…).
    
- Trường `referenceId` có thể lưu ID của đối tượng liên quan (ví dụ id của config được sửa, id của employee, hoặc batchId).
    
- Mọi API thay đổi dữ liệu trong các service khác cần tạo log tương ứng trong AuditLog. (Có thể các service tự ghi log hoặc thông qua event tập trung.)
    

Thiết kế **Audit** như vậy là phù hợp với best practice (Oracle, SAP đều có công cụ audit cho payroll). Không thiếu mảng nào. Thậm chí việc có sẵn API export CSV theo batch là điểm mạnh, giúp xuất nhanh toàn bộ log liên quan một kỳ lương để kiểm tra.

**Đề xuất:** Có thể bổ sung **category “CALCULATION”** hoặc chi tiết hơn trong RUN để log thêm chi tiết tính toán (như kết quả gross/net mỗi nhân viên). Tuy nhiên, việc này thường không log ở audit mà lưu ở kết quả (vì log quá nhiều). Audit nên tập trung vào thay đổi dữ liệu và các sự kiện chính.

### 6. **Payroll Engine** – Xử Lý Tính Lương

Phân hệ **Engine** là lõi tính toán Gross-to-Net, bao gồm quản lý lịch lương, yếu tố lương, công thức tính, quy tắc thuế, và các thao tác quy trình (tính lương, đối chiếu, chốt, rollback, sinh bút toán chi phí). Hiện tại thiết kế **API** cho Engine gồm:

- **Pay Calendar:** API `/payCalendar` GET trả danh sách hoặc lọc lịch lương theo id, mã, trạng thái; POST tạo hoặc cập nhật lịch lương (nếu `calendarId` có thì update, không thì tạo mới). Mỗi **Payroll Calendar** bao gồm các thuộc tính: mã, tên, tần suất (MONTHLY, SEMI_MONTHLY, BI_WEEKLY, v.v.), ngày cắt dữ liệu (cutOffDay), ngày trả lương (paymentDay), trạng thái kích hoạt.
    
    - **Đề xuất:** Thêm thuộc tính `defaultCurrency` cho PayCalendar (như đã nêu ở phần Config) nếu hỗ trợ đa tiền tệ. Ngoài ra, có thể thêm `startMonth` nếu muốn quản lý lịch lương theo năm tài chính khác năm dương lịch, nhưng không bắt buộc.
        
    - DB: Bảng `PayrollCalendar` (calendarId PK, code, name, frequency, cutOffDay, paymentDay, active, defaultCurrency?).
        
- **Pay Element:** API `/payElement` GET lấy danh sách yếu tố lương (có thể lọc theo elementId hoặc category); POST tạo/cập nhật yếu tố lương. Mỗi **yếu tố lương** (thu nhập, khấu trừ, đóng góp) có thuộc tính: elementId, code (unique), name, category (EARNING/DEDUCTION/CONTRIBUTION), taxable (có tính thuế không), defaultFormulaId (công thức mặc định nếu có).
    
    - DB: Bảng `PayElement` (id, code, name, category, taxable, defaultFormulaId -> FK tới PayFormula). Danh sách yếu tố lương sẽ được dùng khắp nơi: input (dưới dạng code), kết quả breakdown, GL mapping, v.v.
        
    - Thiết kế này tương tự khái niệm **Element** trong Oracle/SAP, định nghĩa từng khoản lương cụ thể (lương cơ bản, phụ cấp x, bảo hiểm y...). Hệ thống cho phép phân loại (thu nhập, khấu trừ, công ty đóng góp) và gắn công thức tính cho từng element.
        
- **Pay Formula:** API `/payFormula` GET lấy công thức theo id hoặc code; POST tạo/cập nhật công thức. Mỗi **công thức tính lương** có: formulaId, code, name, expression (biểu thức DSL/SQL).
    
    - DB: Bảng `PayFormula` (id, code, name, expression). Công thức có thể tham chiếu các biến (ví dụ tham chiếu input hoặc các element khác). Thiết kế không sâu vào chi tiết DSL, nhưng có thể coi expression là một chuỗi để engine diễn giải.
        
    - Lưu ý: công thức có thể phức tạp, có điều kiện, v.v. Hệ thống lớn thường có hẳn ngôn ngữ công thức riêng (vd Oracle Fast Formula). Ở đây chỉ cần lưu expression text, engine sẽ tự tính.
        
- **Tax Rule:** API `/taxRule` GET lấy danh sách quy tắc thuế/BHXH theo countryCode hoặc id; POST tạo/cập nhật quy tắc thuế. Mỗi **TaxRule** có: taxRuleId, countryCode, description, ruleJson (object chứa chi tiết luật).
    
    - Chức năng này có vẻ trùng với **StatutoryTable** bên Config. Có thể hiểu: Config/Statutory chứa nhiều phiên bản luật theo thời gian (để người dùng cập nhật), còn Engine/TaxRule có thể là tập hợp rule hiện hành mỗi nước để áp dụng tính toán. Có khả năng Engine sẽ đồng bộ hoặc gọi qua Config khi tính.
        
    - _Đề xuất:_ Không cần tách hai nơi, có thể dùng trực tiếp dữ liệu StatutoryRule. Tuy nhiên, để giảm phụ thuộc, Engine có thể có cache riêng. Dù sao, DB vẫn cần bảng `TaxRule` (hoặc có thể tái sử dụng bảng StatutoryRule). Nếu tách: `TaxRule` có thể chỉ lưu rule hiện hành (ruleJson) theo country, còn StatutoryRule lưu lịch sử. Tùy cách thiết kế, nhưng để đơn giản, có thể unify: dùng StatutoryRule luôn và thêm API filter theo region, effectiveDate (đã có). Engine API `/taxRule` có thể là wrapper.
        
- **Payroll Run Process (Gross-to-Net):** API `/grossToNet` (POST) để bắt đầu tính lương cho một kỳ nhất định. Yêu cầu gửi vào `payrollRunId`, hệ thống trả về ngay status “processing” (202 Accepted) và thực hiện tính toán bất đồng bộ. Khi hoàn tất sẽ phát sự kiện `payroll.run.processed`.
    
    - Đây chính là bước tính toàn bộ lương Gross-to-Net: Engine sẽ lấy dữ liệu input, profile, công thức, luật thuế... để tính cho từng nhân viên trong kỳ. Kết quả (gross, net, từng khoản chi tiết) cần được lưu vào bảng kết quả (thường gọi là **PayrollResult** hoặc **Payslip**).
        
    - DB: Sẽ có bảng `PayrollRun` (id, payrollCalendarId, periodStart, periodEnd, status, executedAt, ...), bảng `PayrollResult` (chứa tổng lương mỗi nhân viên) và bảng `PayrollResultDetail` (breakdown các element cho mỗi nhân viên). Dựa trên schema bên Gateway, `PayrollRun` cần các cột như payrollRunId, calendarId, periodStart, periodEnd, status (PENDING/PROCESSING/COMPLETED/ERROR,...), executedAt. Còn `PayrollResult` bao gồm employeeId, grossPay, netPay, currency, v.v., và mỗi dòng `breakdown` gồm elementCode + amount.
        
    - Trong quá trình tính, engine cũng phải áp dụng **ManualAdjustments PENDING** (nếu có) vào kết quả, và chuyển chúng thành APPLIED, cũng như xử lý **retro entries** (nếu retroBatch). Những hành động này nên được Audit log ghi lại (action: CALCULATE, detail: “Applied adjustment X for emp Y”, etc).
        
- **Validate Run:** API `/validateRun` (POST) thực hiện đối chiếu & xác thực kết quả kỳ lương trước khi chốt. Hệ thống sẽ chạy các **ValidationRule** đã cấu hình, kiểm tra các trường hợp như: thiếu dữ liệu, lương âm, chênh lệch lớn bất thường,... rồi trả về danh sách lỗi/cảnh báo nếu có.
    
    - Kết quả trả về là `ValidationResult` gồm payrollRunId, list errors, list warnings.
        
    - Chức năng này kết hợp chặt với các **quy tắc kiểm tra (ValidationRule)** từ Config. Rất giống **Payroll Control Center** trong SAP – nơi kiểm tra chất lượng dữ liệu trước khi chốt.
        
    - DB: không nhất thiết cần bảng riêng cho kết quả validate (có thể tính realtime mỗi lần gọi). Nếu cần lưu, có thể log vào Audit (như một action “VALIDATION” với chi tiết).
        
- **Finalize Run:** API `/finalizeRun` (POST) dùng để **chốt kỳ lương**. Khi gọi, engine sẽ khóa kết quả, đổi trạng thái kỳ lương thành COMPLETED, đồng thời sinh bút toán chi phí và phát sự kiện `payroll.run.finalized`.
    
    - Đây là bước quan trọng tương đương “confirm” hoặc “complete” trong các hệ thống khác. Sau bước này, dữ liệu lương coi như cuối cùng, không ai thay đổi được trừ khi rollback.
        
    - DB: Trường `status` trong `PayrollRun` chuyển từ PROCESSING (hoặc READY) -> COMPLETED. Có thể có cờ `isLocked=true`. Cũng nên lưu `finalizedAt` timestamp, `finalizedBy` user.
        
    - Sự kiện `payroll.run.finalized` có thể được các module khác (Gateway, Tài chính, v.v.) lắng nghe để thực hiện các bước tiếp theo (gửi phiếu lương, thanh toán ngân hàng...).
        
- **Reverse Run (within Engine):** API `/reverseRun` (POST) – có chức năng tương tự PayrollReversal ở Retro service, tạo một **batch đảo** cho payrollRunId đã chốt. Kết quả trả về PayrollRun mới (ở trạng thái INIT).
    
    - Có vẻ như hệ thống có hai cách gọi đảo ngược: qua Retro service (`/reverse-run`) hoặc trực tiếp Engine (`/reverseRun`). Có thể Gateway hoặc UI sẽ gọi Engine trực tiếp cho thao tác rollback.
        
    - DB: giống như đã nêu ở phần Retro, cập nhật status và tạo bản ghi mới.
        
- **Costing (Integration with Finance):** API `/costing` (POST) thực hiện **sinh bút toán chi phí** cho một kỳ lương đã chốt. Dựa trên payrollRunId, hệ thống sẽ dựa vào GL Mapping và kết quả lương để tạo các bút toán tổng hợp theo tài khoản kế toán. Kết quả trả về `journalUrl` (đường dẫn tới chứng từ nhật ký trong hệ thống tài chính) cùng timestamp.
    
    - Chức năng này giúp tích hợp chặt với phân hệ Tài chính (kế toán tổng hợp). Trong các giải pháp lớn, khi chốt lương sẽ tạo bút toán lương phải trả, thuế phải nộp, chi phí BHXH... Hệ thống ta đáp ứng qua endpoint này.
        
    - DB: có thể không lưu chi tiết bút toán trong payroll DB (vì có thể đẩy thẳng sang ERP). Tuy nhiên, để kiểm tra, có thể lưu bảng `PayrollCosting` với các dòng bút toán: payrollRunId, accountCode, amount (nếu cần). Ở mức tối thiểu, lưu `journalUrl` và `generatedAt` để biết đã thực hiện.
        
    - GL Mapping bảng đã có, nên việc tính toán tổng từng element theo GL account khá thuận lợi.
        

Nhìn chung, **Payroll Engine** module đã bao quát toàn bộ vòng đời xử lý tính lương:

- Quản lý lịch trả lương, nhóm lương (Pay Calendar) – giúp thiết lập cơ cấu kỳ lương định kỳ.
    
- Quản lý danh mục yếu tố lương và công thức – linh hồn của tính toán.
    
- Áp dụng luật thuế, bảo hiểm – đảm bảo tuân thủ (phối hợp với Config).
    
- Thực thi tính toán, kiểm tra, chốt – đầy đủ các bước.
    
- Khả năng rollback – xử lý sai sót.
    
- Kết nối kết quả sang tài chính – hoàn thiện chu trình.
    

Không có mảng tính năng lớn nào bị thiếu trong Engine. Một số đề xuất nhỏ đã nêu:

- Thêm hỗ trợ đa tiền tệ ở PayCalendar.
    
- Gắn kết PayGroup (nếu có khái niệm riêng) với PayCalendar.
    
- Quan hệ foreign key: PayElement <-> PayFormula, PayElement <-> GLMapping (qua code), PayElement <-> các bảng kết quả (qua elementCode), PayrollRun <-> PayrollCalendar, PayrollResult <-> PayrollRun, PayrollResultDetail <-> (PayrollResult, PayElement)…
    
- Khi thiết kế DBML, chú ý các quan hệ này để tránh thiếu sót.
    

### 7. **Payroll Gateway** – Cổng Tích Hợp Bên Ngoài

Phân hệ **Gateway** đóng vai trò cổng API tổng hợp cho bên ngoài (HR Core, Finance, v.v.) tương tác với module Payroll. Theo YAML, Gateway chủ yếu cung cấp các API high-level:

- **Payroll Run (Gateway):** API `/payrollRun` hỗ trợ GET (danh sách hoặc chi tiết kỳ lương) và POST (tạo hoặc cập nhật kỳ lương).
    
    - GET cho phép lọc theo payrollRunId, payrollCalendarId, trạng thái, khoảng ngày, trả về danh sách các kỳ lương thỏa mãn.
        
    - POST cho phép khởi tạo một kỳ lương mới (nếu không truyền id) hoặc cập nhật thông tin kỳ lương (nếu có payrollRunId). Sau khi khởi tạo thành công, **sự kiện** `payroll.run.created` được phát để Engine bắt đầu tính toán.
        
    - Thực tế, Gateway thực hiện việc tạo **PayrollRun** bằng cách gọi vào Engine service hoặc trực tiếp thao tác bảng `PayrollRun`. Sự kiện tạo kỳ lương giúp tách biệt – hệ thống khác có thể lắng nghe (ví dụ module chấm công tự động gửi input khi kỳ được mở).
        
- **Payroll Result (Gateway):** API `/payrollResult` (GET) để lấy kết quả lương của nhân viên. Có tham số payrollRunId (bắt buộc) và employeeId (tùy chọn).
    
    - Nếu chỉ định employeeId, trả về net pay và breakdown cho nhân viên đó; nếu không, trả về kết quả của **toàn bộ nhân viên** trong kỳ (dùng cho xuất CSV hoặc chuyển ngân hàng).
        
    - Đây là API rất quan trọng cho tích hợp: ví dụ HR Core muốn hiển thị payslip cho nhân viên, hoặc module Thanh toán cần lấy danh sách lương để chuyển khoản ngân hàng.
        
    - Kết quả trả về tuân theo schema `PayrollResultList` gồm nhiều PayrollResult (employeeId, gross, net, currency, breakdown...).
        
    - Gateway thực chất sẽ truy vấn bảng `PayrollResult` và chi tiết để dựng JSON.
        
- **Payment File Generation:** API `/paymentFile` (POST) tạo file thanh toán ngân hàng cho kỳ lương. Đầu vào gồm payrollRunId và mã mẫu ngân hàng (bankTemplateCode, ví dụ VCB, Vietin). Hệ thống sẽ tạo file (CSV/TXT) theo mẫu ngân hàng tương ứng, sau đó trả về URL tải file và phát sự kiện `payroll.payment.generated`.
    
    - Chức năng này rất hữu ích để tự động hóa bước chuyển lương: mỗi ngân hàng có định dạng file khác nhau, hệ thống chỉ cần chuẩn bị mẫu trước (có thể lưu trong `bankTemplate` config nào đó).
        
    - DB: Thông thường file này được tạo động, lưu tạm (có thể trong storage, không nhất thiết DB). Có thể lưu một bản ghi `PaymentFile` (id, payrollRunId, filePath, generatedAt) nếu cần audit việc tạo file. Hiện tại có `PaymentFileResponse` trả về fileUrl và generatedAt.
        
- **Tax Report:** API `/taxReport` (GET) xuất báo cáo thuế TNCN cho kỳ lương. Tham số: payrollRunId và format (PDF hoặc XML). API sẽ tạo báo cáo thuế theo mẫu (ví dụ: mẫu 05/QTT, 02/KK tùy kỳ) và trả về URL file báo cáo.
    
    - Chức năng này nhằm hỗ trợ bộ phận thuế/kế toán lấy số liệu thuế thu nhập cá nhân để khai báo. Mỗi quốc gia có mẫu biểu riêng (VD Việt Nam có tờ khai quyết toán thuế). Hệ thống có thể linh hoạt tạo nhiều định dạng (PDF để xem, XML để nộp qua cổng thuế điện tử).
        
    - DB: Tương tự payment file, file báo cáo có thể không cần lưu DB, chỉ lưu file. Nếu cần, bảng `TaxReport` (id, payrollRunId, reportType, filePath, generatedAt). Nhưng audit log có thể ghi “tax report generated for run X”.
        

Nhìn chung, **Payroll Gateway** tập trung vào **giao tiếp bên ngoài**: tạo kỳ lương mới, lấy kết quả lương, tạo file ngân hàng, báo cáo thuế. Đây đều là những **điểm tích hợp** quan trọng:

- Oracle, Workday thường cũng có module **Payroll Interface/Integration** hoặc **API Gateway** cho phép các hệ thống khác lấy dữ liệu lương sau khi tính xong.
    
- Việc phát sinh file ngân hàng và báo cáo thuế tự động giúp giảm thao tác thủ công, tăng độ chính xác.
    

**Đề xuất bổ sung:**

- **API lấy phiếu lương (payslip) chi tiết dạng PDF**: Như đã đề cập ở phần Config, có thể thêm endpoint, ví dụ `GET /payrollResult/payslip?payrollRunId=&employeeId=` trả về file PDF phiếu lương cho nhân viên đó. Gateway có thể sử dụng PayslipTemplate đã cấu hình để render dữ liệu kết quả thành PDF. Nhiều hệ thống cho phép nhân viên tự xem phiếu lương của mình qua cổng self-service, tính năng này sẽ cần. Nếu không tự thực hiện trong Payroll, có thể tích hợp với một service tài liệu. Dù sao, vì đã có mẫu phiếu lương, việc thiếu API xuất phiếu là một lỗ hổng nhỏ cần lấp.
    
- **API lấy danh sách pay group/ lịch lương**: Gateway có thể lộ ra danh sách payGroup (hoặc payCalendar) để hệ thống khác biết có những chu kỳ nào. Tuy nhiên, có thể không cần do Engine `/payCalendar` đã có và có thể dùng nội bộ. Nếu HR Core muốn hiển thị thông tin lịch lương thì cân nhắc cho phép gọi.
    
- **Bảo mật & Paging**: Tất cả API đều bảo mật bằng JWT (đã nêu). Với các API trả danh sách lớn (như /payrollResult toàn bộ nhân viên), có thể cần hỗ trợ paging hoặc streaming xuất file. Nhưng đây là chi tiết mức thực thi, không phải thiết kế DB.
    

Tổng thể, **Gateway** đã cover các chức năng tích hợp quan trọng. Không thiếu nghiệp vụ nào rõ rệt. Triển khai DB cho Gateway chủ yếu tái sử dụng bảng của Engine (PayrollRun, PayrollResult) và có thể có bảng nhỏ cho log file (PaymentFile, TaxReport) nếu cần.

## Đề Xuất Format Tài Liệu Mapping API ↔ Database

Để tài liệu rõ ràng cho developer, ta sẽ trình bày **bảng mapping** giữa từng API (hoặc nhóm API) với các bảng và trường cơ sở dữ liệu liên quan. Mục tiêu là lập bản đồ: **API này tương tác với bảng nào, thao tác gì, các trường dữ liệu chính từ/đến.** Việc này giúp lập trình viên dễ dàng hiểu được cần truy vấn hay cập nhật những bảng nào khi implement mỗi API.

Chúng ta sẽ tổ chức mapping theo **từng phân hệ (service)** của Payroll, do mỗi phân hệ tương ứng một nhóm chức năng và cơ sở dữ liệu riêng. Cụ thể, dưới đây là các bảng mapping cho: **Payroll Config**, **Payroll Input**, **Payroll Profile**, **Payroll Retro**, **Payroll Audit**, **Payroll Engine**, và **Payroll Gateway**.

Trong bảng:

- Cột **API (Method)**: Tên endpoint và phương thức HTTP.
    
- Cột **Chức năng**: Mô tả ngắn gọn mục đích API.
    
- Cột **Bảng CSDL & Thao tác**: Liệt kê bảng và hành động CRUD (Create/Read/Update/Delete) tương ứng khi API được gọi. Nếu có điều kiện lọc, cũng thể hiện qua thao tác READ (WHERE ...).
    
- Cột **Ghi chú**: Thông tin bổ sung như mối quan hệ giữa các bảng, các trường quan trọng được sử dụng.
    

Nếu một API tương tác với nhiều bảng, chúng được liệt kê đầy đủ. Các **bảng hoặc cột mới được đề xuất thiết kế thêm** sẽ được đánh dấu _in nghiêng_ trong bảng và giải thích ở phần ghi chú.

### Mapping: **Payroll Config Service** (Cấu hình)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/global-config` **GET**|Lấy cấu hình chung hệ thống lương|**GlobalConfig** – **READ** (SELECT * LIMIT 1)|Trả về bản ghi cấu hình chung (tiền tệ mặc định, format số, rounding).|
|`/global-config` **PUT**|Cập nhật cấu hình chung|**GlobalConfig** – **UPDATE** (UPDATE ... WHERE id)|Cập nhật các trường: `defaultCurrency`, `numberFormat`, `roundingMethod`, `roundingScale`. Phát sự kiện audit (CONFIG).|
|`/statutory-tables` **GET**|Liệt kê các quy định thuế/BHXH|**StatutoryRule** – **READ** (SELECT ... WHERE type/region/effDate...)|Lọc theo `type`, `region`, `effectiveDate` nếu có. Trả về danh sách các bản ghi luật.|
|`/statutory-tables` **POST**|Thêm mới một quy định pháp luật|**StatutoryRule** – **CREATE** (INSERT)|Tạo bản ghi luật mới (tạo id). Nếu có mảng `taxBrackets`, lưu trong JSON hoặc bảng con _TaxBracket_.|
|`/statutory-tables` **PUT**|Cập nhật quy định pháp luật|**StatutoryRule** – **UPDATE** (UPDATE ... WHERE id)|Dựa theo `id` quy định, cập nhật giá trị (thay đổi tỷ lệ thuế, hiệu lực...).|
|`/statutory-tables` **DELETE**|Xóa một quy định pháp luật|**StatutoryRule** – **DELETE** (DELETE ... WHERE id)|Xóa bản ghi luật. Lưu ý bảo toàn log audit. (Có thể ghi nhận trong AuditLog việc xóa).|
|`/gl-mappings` **GET**|Danh sách ánh xạ yếu tố lương - tài khoản kế toán|**GLMapping** – **READ** (SELECT * ...)|Lấy toàn bộ danh sách mapping hiện có.|
|`/gl-mappings` **POST**|Thêm mới GL mapping|**GLMapping** – **CREATE** (INSERT)|Thêm mapping yếu tố lương (`elementCode`) với tài khoản (`accountCode`, `accountName`).|
|`/gl-mappings` **PUT**|Cập nhật GL mapping|**GLMapping** – **UPDATE** (UPDATE ... WHERE id)|Thay đổi tài khoản hoặc mô tả mapping dựa trên `id` mapping.|
|`/gl-mappings` **DELETE**|Xóa GL mapping|**GLMapping** – **DELETE** (DELETE ... WHERE id)|Xóa mapping theo `id`. Chỉ cho phép nếu không ảnh hưởng dữ liệu lịch sử (logic app).|
|`/payslip-templates` **GET**|Danh sách mẫu phiếu lương|**PayslipTemplate** – **READ** (SELECT * ...)|Lấy tất cả các mẫu phiếu lương: `code, name, format, templateData, description`.|
|`/payslip-templates` **POST**|Tạo mới mẫu phiếu lương|**PayslipTemplate** – **CREATE** (INSERT)|Tạo bản ghi mới với mã, tên, format (vd PDF) và dữ liệu mẫu (JSON).|
|`/payslip-templates` **PUT**|Cập nhật mẫu phiếu lương|**PayslipTemplate** – **UPDATE** (UPDATE ... WHERE id/code)|Cập nhật nội dung mẫu (logo, trường dữ liệu...) dựa theo `id` hoặc `code`.|
|`/payslip-templates` **DELETE**|Xóa mẫu phiếu lương|**PayslipTemplate** – **DELETE** (DELETE ... WHERE id)|Xóa mẫu theo `id`. Cần kiểm tra mẫu không được sử dụng. Phát sự kiện ngừng sử dụng mẫu.|
|`/validation-rules` **GET**|Danh sách quy tắc kiểm tra kỳ lương|**ValidationRule** – **READ** (SELECT * ...)|Lấy tất cả các validation rule hiện có.|
|`/validation-rules` **POST**|Thêm mới quy tắc kiểm tra|**ValidationRule** – **CREATE** (INSERT)|Tạo rule mới (code, description, severity, expression, active).|
|`/validation-rules` **PUT**|Cập nhật quy tắc kiểm tra|**ValidationRule** – **UPDATE** (UPDATE ... WHERE id)|Cập nhật nội dung hoặc trạng thái (active) của rule dựa theo `id`.|
|`/validation-rules` **DELETE**|Xóa quy tắc kiểm tra|**ValidationRule** – **DELETE** (DELETE ... WHERE id)|Xóa rule theo `id`. (Các rule mặc định hệ thống không cho xóa theo mô tả).|

_Chú thích:_ Bảng _TaxBracket_ (nếu có) sẽ liên kết 1-n với StatutoryRule khi `type = 'tax'` để lưu các mức thu nhập và thuế suất tương ứng. Bảng GlobalConfig có thể chứa một dòng duy nhất (hoặc nhiều nếu hỗ trợ đa công ty, nhưng ở đây giả định một context). Mỗi thao tác CREATE/UPDATE/DELETE config đều ghi log Audit (category CONFIG).

### Mapping: **Payroll Input Service** (Dữ liệu đầu vào)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/time-attendance` **POST**|Nhận dữ liệu chấm công/OT cho kỳ lương|**PayrollInputItem** – **CREATE** (INSERT nhiều dòng)|Với mỗi phần tử trong mảng input: tạo các bản ghi: `employeeId`, `periodStart`, `periodEnd`, `payGroupCode` (hoặc payrollCalendarId), `sourceType='TimeAttendance'`. Các thuộc tính: `workDays`, `overtimeHours`, `otherHours` sẽ được lưu thành từng dòng với các `code` tương ứng (ví dụ: WORK_DAYS, OT_HOURS, OTHER_HOURS). Những giá trị này có thể lưu `value` trực tiếp. Nếu `PayrollRun` cho kỳ này đã tồn tại, có thể gán luôn `payrollRunId` cho các bản ghi; nếu chưa, lưu tạm với thông tin kỳ.|
|`/absence` **POST**|Nhận dữ liệu nghỉ phép/không lương|**PayrollInputItem** – **CREATE** (INSERT nhiều dòng)|Tương tự trên, sourceType='Absence'. Với mỗi nhân viên: lưu `UNPAID_DAYS` và nếu có `paidDays` thì lưu `PAID_DAYS` (mặc dù paidDays không ảnh hưởng lương, vẫn lưu để tham chiếu).|
|`/total-reward` **POST**|Nhận dữ liệu thưởng/hoa hồng|**PayrollInputItem** – **CREATE** (INSERT nhiều dòng)|Mỗi phần tử input có thể chứa nhiều khoản reward: với mỗi `rewards[i]` (code, amount), tạo một bản ghi PayrollInputItem: `sourceType='TotalReward'`, `code=<code>`, `value=<amount>` cho employeeId tương ứng.|
|`/manual-upload` **POST**|Upload file CSV dữ liệu lương thủ công|**ImportJob** – **CREATE** (INSERT job record) **PayrollInputItem** – **CREATE** (INSERT nhiều dòng) **AuditLog** – **CREATE** (INSERT logs)|Khi file được upload, hệ thống ghi nhận một job xử lý: tạo bản ghi ImportJob (trạng thái Processing, time start, người thực hiện). Sau đó parse file: với mỗi dòng, tạo các bản ghi PayrollInputItem tương tự như trên (sourceType='Manual'). Nếu dòng nào lỗi, không tạo bản ghi nhưng ghi vào AuditLog (category INPUT, action=IMPORT_ERROR, detail dòng lỗi). Sau khi xử lý xong, cập nhật ImportJob (status, total records, success count, fail count). Cuối cùng trả về jobId.|
|`/employee-changes` **POST**|Nhận sự kiện thay đổi nhân viên (new hire, termination, transfer)|**EmployeePayrollProfile** – **READ/UPDATE** **PayrollRun** – **UPDATE** (nếu cần) **PayrollInputItem** – **CREATE** (cho prorate hoặc payoff) **AuditLog** – **CREATE**|Tùy loại sự kiện: NEW_HIRE – thêm nhân viên vào kỳ lương hiện tại (có thể cần tạo ngay các record lương cơ bản prorate cho nhân viên này, hoặc đơn giản là ghi log để Engine tính prorate dựa trên ngày vào). TERMINATION – đánh dấu nhân viên sẽ nghỉ, có thể tạo input điều chỉnh lương (vd trừ lương những ngày không làm đủ tháng, trợ cấp nghỉ việc). TRANSFER – có thể không ảnh hưởng lương trừ khi thay đổi pay group. Hệ thống sẽ: tra profile nhân viên để biết payGroup; tìm kỳ lương hiện tại (theo payGroup và effectiveDate nằm trong khoảng kỳ nào) – nếu kỳ đang OPEN, có thể thêm nhân viên vào (Engine khi tính sẽ thấy profile mới). Cập nhật gì cần thiết (profile.payGroup nếu chuyển nhóm). Ghi log Audit (category RUN hoặc INPUT, action=EMP_CHANGE, detail...).|
|`/inputs` **GET**|Xem tổng hợp dữ liệu input của kỳ lương|**PayrollInputItem** – **READ** (SELECT ... WHERE payGroupCode/period and employeeId)|Nếu gọi với `payGroupCode` (vd "THANG1-2025") thì lấy tất cả input có thuộc kỳ tương ứng (có thể cần join bảng PayrollRun hoặc bảng Calendar để xác định khoảng thời gian). Nếu chỉ có periodStart & periodEnd, thì SELECT theo cặp ngày. Nếu có `employeeId`, thì thêm điều kiện lọc theo nhân viên. Sau đó nhóm kết quả theo employeeId, gộp thành mảng `inputs` cho từng người trong JSON trả về.|

_Chú thích:_ Bảng `PayrollInputItem` là bảng được đề xuất gộp chung để lưu tất cả các loại dữ liệu input. Khóa chính có thể là composite (employeeId, payrollRunId, code) hoặc một surrogate id. Trường `payrollRunId` có thể để null nếu run chưa tồn tại. Liên kết với `PayrollRun` (hoặc PayCalendar) thông qua `payGroupCode` + dates. Bảng `ImportJob` (đề xuất) lưu các cột: jobId (UUID), fileName, submitBy, submitTime, status, completedTime, successCount, failCount, etc. Mỗi lỗi dòng CSV được ghi chi tiết trong AuditLog (hoặc bảng ImportJobDetail nếu thiết kế, nhưng có thể không cần nếu audit đã đủ).

Các thao tác Input đa số là **CREATE nhiều bản ghi** – nên chú ý sử dụng transaction đảm bảo tính toàn vẹn (VD: upload file, nếu lỗi giữa chừng có rollback hoặc ghi nhận đầy đủ lỗi).

### Mapping: **Payroll Profile Service** (Hồ sơ lương nhân viên)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/employees` **GET**|Lấy danh sách hoặc chi tiết hồ sơ lương nhân viên|**EmployeePayrollProfile** – **READ** (SELECT ... WHERE employeeId/payGroupCode)|Nếu có `employeeId` query, SELECT * FROM EmployeePayrollProfile WHERE employeeId = ... (trả 1 bản ghi chi tiết). Nếu có `payGroupCode`, lọc WHERE payGroupCode = ... (trả nhiều bản ghi thuộc nhóm lương đó). Nếu không có filter, trả toàn bộ hồ sơ (nên giới hạn/paging nếu nhiều).|
|`/employees` **POST**|Tạo hồ sơ lương cho nhân viên mới|**EmployeePayrollProfile** – **CREATE** (INSERT)|Thêm mới một bản ghi profile: bao gồm các trường chính: `employeeId` (FK tới HR Employee), `bankAccountNo`, `bankName`/`branch` (nếu có), `taxId`, `dependentsCount`, `socialInsuranceNo`, `payGroupCode` (FK tới PayrollCalendar.code). Sau khi INSERT, phát sự kiện `payroll.profile.created` để thông báo các module khác (vd Engine có thể kiểm tra rule BANK_INFO_MISSING...). AuditLog: log tạo profile (category PROFILE, action=CREATE).|

_Chú thích:_ Bảng `EmployeePayrollProfile` có quan hệ 1-1 với nhân viên (mỗi nhân viên tối đa một hồ sơ lương). Trường `payGroupCode` liên kết đến `PayrollCalendar.code` (giả định code của lịch lương cũng là mã nhóm). Nếu thiết kế tách **PayGroup**: nên có bảng PayGroup (id, code, payrollCalendarId, description), khi đó `payGroupCode` trong profile là FK sang PayGroup. Tuy nhiên, để đơn giản, có thể dùng luôn PayrollCalendar như nhóm (một calendar = một nhóm).

Cột `dependentsCount` dùng tính giảm trừ gia cảnh thuế. `taxId` (MST cá nhân) dùng cho báo cáo thuế. `socialInsuranceNo` dùng cho đối chiếu BHXH. Những thông tin này có thể cần được engine sử dụng trong công thức thuế, BHXH (ví dụ mức giảm trừ gia cảnh = dependentsCount * 4.4tr VND trong công thức thuế VN).

### Mapping: **Payroll Retro Service** (Hồi tố & điều chỉnh)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/manual-adjustments` **GET**|Danh sách điều chỉnh lương thủ công (lọc tùy chọn)|**ManualAdjustment** – **READ** (SELECT ... WHERE status/employeeId/period)|Nếu có query: lọc theo `status`, `employeeId`, `periodStart`/`periodEnd`. Ví dụ: SELECT * FROM ManualAdjustment WHERE (status=PENDING) AND (employeeId=...) AND (periodStart >= ... AND periodEnd <= ...). Trả về danh sách điều chỉnh thỏa mãn.|
|`/manual-adjustments` **POST**|Tạo mới một điều chỉnh lương thủ công|**ManualAdjustment** – **CREATE** (INSERT)|Thêm bản ghi mới: các trường từ requestBody (employeeId, periodStart, periodEnd, elementCode, amount, reason). Gán status = 'PENDING', `createdBy` từ JWT, `createdAt` = now. AuditLog: log tạo adjust (category INPUT hoặc RUN, action=ADJUST_CREATE).|
|`/manual-adjustments` **PUT**|Cập nhật điều chỉnh lương thủ công|**ManualAdjustment** – **UPDATE** (UPDATE ... WHERE id)|Cập nhật bản ghi theo `id` với các trường mới (có thể là amount, reason, hoặc chuyển status). Chỉ cho phép nếu status hiện tại = PENDING (logic trong service). Nếu chuyển status = 'APPLIED' có thể hiểu là đánh dấu đã áp vào lương (thường Engine làm việc này). Việc update này cũng có thể dùng để **hủy điều chỉnh** (bằng cách xóa hoặc đổi status). AuditLog: log update adjust (action=ADJUST_UPDATE).|
|`/manual-adjustments` **DELETE**|Xóa điều chỉnh lương thủ công|**ManualAdjustment** – **DELETE** (DELETE ... WHERE id)|Xóa bản ghi điều chỉnh theo `id`. Chỉ cho phép nếu PENDING (nếu đã APPLIED thì không cho xóa). AuditLog: log delete adjust (action=ADJUST_DELETE, referenceId = id).|
|`/calculate` **POST**|Tính toán hồi tố cho kỳ lương đã chốt|**RetroCalculation** – **(CREATE log)** **PayrollRun** – **CREATE** (INSERT retro batch nếu tách riêng) **ManualAdjustment** – **CREATE** (INSERT chênh lệch nếu gộp vào hiện tại) **PayrollResult** – **UPDATE/INSERT** (kết quả chênh lệch)|Khi gọi tính hồi tố: - Input: originalBatchId, danh sách employeeIds (optional), reason. - Engine sẽ: lấy kết quả gốc (originalBatchId) từ bảng `PayrollResult` lưu tạm, tính toán lại lương cho kỳ đó (với dữ liệu thay đổi), so sánh để tìm chênh lệch từng nhân viên, từng element. - Nếu thiết kế tạo **retro batch riêng**: Tạo mới một bản ghi `PayrollRun` (retroBatchId) kiểu RETRO, period có thể trùng original hoặc = current period? (Thông thường, retro entries được đưa vào kỳ hiện tại nếu kỳ hiện tại chưa chốt, hoặc tạo một kỳ phụ). Ở đây, YAML nói “cập nhật vào kỳ hiện tại hoặc kỳ RETRO riêng”, nghĩa là tùy config. Giả sử nếu có create batch: INSERT PayrollRun (loại RETRO, tham chiếu originalBatch). - Sau đó, tạo các `ManualAdjustment` hoặc trực tiếp `PayrollResultDetail` cho chênh lệch: Cách 1: thêm manual adjustments PENDING cho kỳ hiện tại (engine khi chạy kỳ hiện tại sẽ cộng), Cách 2: nếu tạo retroBatch, tính full kết quả và lưu vào PayrollResult cho retroBatch. - Cập nhật `RetroCalculation` log (có thể không cần bảng, chỉ audit log event). - Trả về retroBatchId (nếu đã tạo) và số nhân viên ảnh hưởng. - AuditLog: log sự kiện retro calculate (category RUN, action=RETRO_CALC, detail reason, originalBatchId, retroBatchId).|
|`/reverse-run` **POST**|Đảo ngược/rollback một kỳ lương đã chốt|**PayrollRun** – **UPDATE** (UPDATE status của batchId cũ) **PayrollRun** – **CREATE** (INSERT bản ghi kỳ lương mới)|Khi rollback: - Cập nhật PayrollRun (batchId) cần đảo: set status = 'REVERSED' (hoặc flag isReversed=1), có thể lưu thêm `reversedAt`, `reversedBy`. - Tạo bản ghi PayrollRun mới: copy các field chính (calendarId, periodStart, periodEnd) giống kỳ cũ, trạng thái = 'PENDING' hoặc 'INIT'. Liên kết: `originalRunId` = batchId cũ (hoặc lưu batchId cũ -> newRunId trong trường reversedByRunId). - Không copy kết quả hay input; kỳ mới ban đầu trống dữ liệu (có thể cần copy manual adjustments nếu cần). - Trả về newBatchId. - AuditLog: log sự kiện rollback (category RUN, action=REVERSE, detail lý do).|

_Chú thích:_ Bảng `ManualAdjustment` có cấu trúc theo schema. Trường `status` giúp phân biệt PENDING và APPLIED. Khi Engine tính xong kỳ lương, nó sẽ chuyển các adjustment PENDING -> APPLIED và có thể cập nhật `PayrollResult`. Có thể bổ sung trường `appliedInRunId` để biết adjustment nào đã áp dụng vào kỳ nào (đặc biệt quan trọng với hồi tố: một adjustment PENDING của kỳ trước có thể được áp vào kỳ hiện tại, sau đó đánh dấu APPLIED).

Bảng `RetroCalculation`: nếu chi tiết cần lưu, có thể tạo bảng lưu mỗi lần chạy retro (id, originalRunId, retroRunId, runDate, executedBy, reason, affectedCount). Tuy nhiên, nhiều hệ thống không lưu bảng riêng mà dùng audit + kết quả. Ở đây mapping không tạo bảng này, chỉ mô tả logic.

### Mapping: **Payroll Audit Service** (Log kiểm toán)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/logs` **GET**|Tra cứu nhật ký (log) thay đổi/hành động|**AuditLog** – **READ** (SELECT ... WHERE category/startDate/endDate/employeeId/batchId)|Dựa trên query param, xây dựng điều kiện SELECT. Ví dụ: Nếu category=INPUT, employeeId=123, batchId=X thì: SELECT * FROM AuditLog WHERE category='INPUT' AND referenceId like 'employee:123' AND referenceId like 'batch:X' AND timestamp BETWEEN startDate AND endDate. (Hoặc các referenceId có thể tách cột riêng). Trả về list các bản ghi log (timestamp, user, category, action, detail, referenceId).|
|`/logs/export` **GET**|Xuất báo cáo audit (CSV) theo kỳ lương|**AuditLog** – **READ** (SELECT * WHERE referenceId chứa batchId) (Rồi ghi ra file CSV)|Tham số batchId bắt buộc. Hệ thống lấy tất cả log có liên quan kỳ lương đó (có thể category bất kỳ nhưng referenceId hoặc detail đề cập đến batchId). Việc xác định "liên quan" có thể: hoặc AuditLog có trường riêng batchId (gợi ý thiết kế: thêm cột optional `batchId` trong AuditLog nếu log gắn liền với 1 kỳ cụ thể). Nếu không, parse detail/referenceId chuỗi. Kết quả được ghi ra file CSV (Time, User, Category, Action, Detail...). File có thể lưu tạm trên server hoặc stream trực tiếp. Trả về binary CSV.|

_Chú thích:_ Bảng `AuditLog` lưu mọi hành động từ các service khác. Mỗi service khi thao tác xong sẽ tạo 1 bản ghi AuditLog. Ví dụ:

- Khi `/global-config PUT`, tạo AuditLog: user=A, category=CONFIG, action=UPDATE, detail="Changed roundingMethod from X to Y".
    
- Khi `/payrollRun POST` tạo kỳ lương, AuditLog: category=RUN, action=CREATE_RUN, detail="Initiated payroll run for Jan-2025", referenceId có thể chứa new payrollRunId.
    
- Khi tính lương xong, Engine có thể log: category=RUN, action=CALCULATE, detail="Processed payroll run X for Y employees".
    
- Tùy chiến lược, `referenceId` có thể lưu kiểu `<objectType>:<id>` hoặc JSON với các id liên quan. Để dễ truy vấn, có thể tách cột `employeeId` và `batchId` riêng trong AuditLog (nullable) để hỗ trợ filter trực tiếp.
    

### Mapping: **Payroll Engine Service** (Tính lương lõi)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/payCalendar` **GET**|Danh sách/lọc lịch lương|**PayrollCalendar** – **READ** (SELECT ... WHERE id/code/status)|Nếu truyền `calendarId`, trả về 1 bản ghi tương ứng (hoặc DS 1 phần tử). Nếu truyền `code`, lọc theo code. Nếu không, trả về tất cả lịch lương (có thể kèm trạng thái active/inactive).|
|`/payCalendar` **POST**|Tạo hoặc cập nhật lịch lương|**PayrollCalendar** – **CREATE/UPDATE**|Nếu requestBody có `calendarId` (hoặc code trùng tồn tại): thực hiện UPDATE bản ghi đó với các giá trị mới (code, name, frequency, cutOffDay, paymentDay, active). Nếu không có id (tạo mới): INSERT bản ghi mới (gen id). Phát sự kiện `payroll.calendar.created` nếu create. AuditLog: log create/update calendar (category CONFIG, action=CREATE_CALENDAR).|
|`/payElement` **GET**|Lấy danh sách yếu tố lương (lọc tùy chọn)|**PayElement** – **READ** (SELECT ... WHERE elementId/category)|Nếu có `elementId`, lấy 1 bản ghi; nếu có `category`, lọc WHERE category=...; nếu không tham số, trả về tất cả yếu tố.|
|`/payElement` **POST**|Tạo hoặc cập nhật yếu tố lương|**PayElement** – **CREATE/UPDATE**|Tương tự PayCalendar: nếu request có elementId (hoặc code trùng khớp): UPDATE, ngược lại: INSERT mới (tạo elementId mới). Các trường: code (unique), name, category, taxable, defaultFormulaId (FK PayFormula). AuditLog: log create/update element (category CONFIG, action=CREATE_ELEMENT).|
|`/payFormula` **GET**|Lấy công thức tính lương|**PayFormula** – **READ** (SELECT ... WHERE formulaId/code)|Lọc theo formulaId hoặc code nếu có. Trả về một hoặc nhiều công thức (nếu không có filter có thể trả tất cả, nhưng thường sẽ có filter).|
|`/payFormula` **POST**|Tạo hoặc cập nhật công thức tính|**PayFormula** – **CREATE/UPDATE**|Nếu có formulaId (hoặc code trùng): UPDATE biểu thức, name... Nếu mới: INSERT tạo formulaId. AuditLog: log create/update formula (category CONFIG, action=CREATE_FORMULA).|
|`/taxRule` **GET**|Lấy danh sách quy tắc thuế/BHXH theo quốc gia|**TaxRule** – **READ** (SELECT ... WHERE taxRuleId/countryCode)|Nếu thiết kế tách `TaxRule` riêng: SELECT từ bảng TaxRule, có thể lọc countryCode. (Nếu dùng StatutoryRule chung, Engine có thể proxy gọi Config service hoặc query view).|
|`/taxRule` **POST**|Tạo hoặc cập nhật quy tắc thuế|**TaxRule** – **CREATE/UPDATE**|Nếu có taxRuleId: UPDATE ruleJson, desc; nếu không: INSERT mới. (Hoặc có thể update StatutoryRule tương ứng). AuditLog: log change taxRule (category CONFIG, action=UPDATE_TAX).|
|`/grossToNet` **POST**|Chạy tính lương (Gross-to-Net) cho kỳ lương|**PayrollRun** – **UPDATE** (status -> PROCESSING) **PayrollResult** – **CREATE** (INSERT kết quả nếu chưa có) **PayrollResultDetail** – **CREATE** (INSERT các dòng breakdown) **ManualAdjustment** – **UPDATE** (áp dụng adjustments)|Xử lý khi nhận yêu cầu tính: 1. Đọc `payrollRunId` từ request. Trước hết, cập nhật trạng thái của bản ghi `PayrollRun` tương ứng: status từ PENDING -> PROCESSING, `executedAt` = now. 2. Engine thu thập dữ liệu: lấy tất cả `PayrollInputItem` của kỳ (theo payrollRunId hoặc theo calendar+period), lấy `EmployeePayrollProfile` cho nhân viên trong kỳ (để biết taxId, dependents...), lấy `PayElement`, `PayFormula`, `StatutoryRule` áp dụng (dựa trên region, date),... 3. Tính toán cho từng nhân viên: tính từng element theo công thức. Kết quả từng nhân viên: tổng thu nhập, tổng khấu trừ, net pay, breakdown chi tiết (mã element và số tiền). 4. Ghi kết quả vào DB: với mỗi nhân viên, tạo bản ghi trong `PayrollResult` (nếu chưa có) hoặc cập nhật nếu đã có (trường hợp rerun). Cấu trúc PayrollResult: (payrollRunId, employeeId) làm key, grossPay, netPay, currency. 5. Ghi chi tiết: xóa các `PayrollResultDetail` cũ của (runId, empId) nếu có, rồi INSERT mới cho từng khoản (payrollRunId, employeeId, elementCode, amount). 6. Áp dụng manual adjustments: nếu có `ManualAdjustment` PENDING cho (employee, period) khớp run, cộng vào kết quả tương ứng (vd tăng/giảm net, thêm dòng breakdown hoặc điều chỉnh dòng element tương ứng). Đánh dấu adjustments đó thành APPLIED và có thể ghi nhận `appliedInRunId`. 7. Nếu có retro-chênh lệch cần áp (trường hợp retro calc cho kỳ trước, chênh lệch nhập vào kỳ này): xử lý tương tự adjustments (vì retro chênh lệch có thể đã được lưu dưới dạng ManualAdjustment PENDING). 8. Cập nhật trạng thái PayrollRun: có thể chuyển về PENDING hoặc một trạng thái “CALCULATED/READY” (đợi finalize). YAML không nói rõ, nhưng thường sau tính xong vẫn chưa Completed cho đến khi finalize. Có thể dùng status = PROCESSING xong vẫn để đó, hoặc đặt = "CALCULATED". 9. Phát sự kiện `payroll.run.processed`. AuditLog: log kết thúc tính (category RUN, action=CALCULATE_DONE, detail: "Processed run X, Y employees, status = ...").|
|`/validateRun` **POST**|Kiểm tra đối chiếu dữ liệu trước chốt|**PayrollRun** – **READ** (kiểm tra trạng thái, dữ liệu) **ValidationRule** – **READ** (lấy tất cả rule active) _(Không ghi DB, chỉ logic)_|Khi gọi validate: 1. Lấy payrollRunId, đọc PayrollRun (để chắc rằng run tồn tại, có kết quả). 2. Lấy danh sách ValidationRule (active=true). 3. Với mỗi rule, Engine áp công thức/điều kiện (`expression`) kiểm tra dữ liệu tương ứng. Ví dụ: rule "BANK_INFO_MISSING" – duyệt qua EmployeePayrollProfile của các nhân viên trong run, nếu ai thiếu bankAccount thì tạo 1 lỗi "Nhân viên A chưa có TK ngân hàng". Hoặc rule "NEGATIVE_NET" – duyệt PayrollResult, nếu netPay < 0 thì warning. v.v. 4. Tổng hợp tất cả lỗi, cảnh báo. 5. Trả về JSON ValidationResult với lists. Không có thay đổi DB nào trừ có thể AuditLog ghi lại kết quả validate (action=VALIDATE_RUN, detail: "X errors, Y warnings on run Z").|
|`/finalizeRun` **POST**|Chốt kỳ lương (hoàn tất tính và khóa sổ)|**PayrollRun** – **UPDATE** (status -> COMPLETED, finalizedAt) **PayrollResult** – **READ** (kiểm tra) **Costing** – **CREATE** (tự động gọi tạo bút toán, nếu cấu hình auto)|Khi finalize: 1. Cập nhật `PayrollRun` (runId) status = COMPLETED, `finalizedAt` = now, `finalizedBy` = user. Có thể có field `isLocked=true`. 2. Đảm bảo tất cả PayrollResult đã tính xong (nếu chưa, có thể từ chối finalize). 3. Kích hoạt tạo bút toán chi phí (có thể tự động gọi nội bộ hàm /costing hoặc nếu flag autoCosting=true). 4. Phát sự kiện `payroll.run.finalized`. AuditLog: log finalize (category RUN, action=FINALIZE, detail...). _Chú ý:_ Sau finalize, các API input nên bị khóa không cho thêm dữ liệu vào kỳ này.|
|`/reverseRun` **POST**|Đảo ngược kỳ lương (tạo batch để tính lại)|**PayrollRun** – **UPDATE** (status của runId -> REVERSED) **PayrollRun** – **CREATE** (tạo batch mới)|Giống như `/reverse-run` ở Retro. Engine implement thực tế thao tác DB: 1. Đánh dấu run hiện tại: status='REVERSED'. 2. Tạo run mới (newRun) với cùng calendar, period. Mã id mới, trạng thái PENDING (hoặc INIT). Liên kết newRun.originalRunId = oldRun.id. Copy các adjustments PENDING từ run cũ sang run mới nếu cần (ví dụ adjustments chưa áp dụng kỳ cũ có thể mang sang). 3. Trả về đối tượng PayrollRun của batch mới. AuditLog: log reverse (như trên).|
|`/costing` **POST**|Sinh bút toán chi phí (kết nối Finance)|**PayrollResultDetail** – **READ** (SELECT all results for run) **GLMapping** – **READ** (SELECT all mappings) **JournalEntry** (ở Finance DB) – **CREATE** (INSERT) **PayrollRun** – **UPDATE** (flag costed=1)|Xử lý khi costing: 1. Lấy toàn bộ kết quả chi tiết của kỳ (PayrollResultDetail where payrollRunId = X). 2. Lấy GLMapping để biết tài khoản cho từng elementCode. 3. Tổng hợp số tiền theo account: duyệt từng chi tiết, cộng dồn amount của các element cùng accountCode (chú ý phân biệt debit/credit tùy loại element: EARNING có thể vào nợ chi phí, DEDUCTION có thể vào có phải trả...). Có thể cần biết yếu tố nào thuộc **chi phí công ty** (như BHXH employer) để hạch toán. Giả sử đơn giản: tạo bút toán gồm: Nợ TK chi phí lương (tổng tất cả earnings + phụ cấp công ty đóng), Có TK phải trả lương (tổng net pay), Có TK thuế TNCN phải nộp (tổng PIT), Có TK BHXH phải nộp (tổng BHXH nhân viên + công ty?), etc. 4. Tạo các bút toán vào hệ thống tài chính: nếu có tích hợp realtime, có thể thông qua API Finance, hoặc ghi vào bảng trung gian JournalEntry để Finance import. Ở đây coi như gọi trực tiếp nên **JournalEntry** (hoặc tương tự) không nằm trong Payroll DB mà ở Finance. 5. Trả về `journalUrl` – đường dẫn tra cứu bút toán (có thể là link sang ERP). 6. Cập nhật PayrollRun.costed = true (hoặc lưu journalId trong PayrollRun). AuditLog: log costing (category RUN, action=COSTING, detail "Posted journal ... for run ...").|

_Chú thích:_ Phần Engine có nhiều bảng: `PayrollRun`, `PayrollResult`, `PayrollResultDetail`, `PayrollCalendar`, `PayElement`, `PayFormula`, `TaxRule` (hoặc dùng StatutoryRule), `PayElementFormula` (nếu cần mapping nhiều-nhiều element với formula – nhưng hiện tại chỉ defaultFormulaId trong element).

Quan hệ quan trọng:

- `PayrollRun.payrollCalendarId` -> `PayrollCalendar.id`.
    
- `PayrollRun` liên quan nhiều `PayrollResult` (1-n).
    
- `PayrollResult` (runId + empId) liên quan nhiều `PayrollResultDetail` (1-n).
    
- `PayrollResultDetail.elementCode` -> `PayElement.code` (hoặc elementId).
    
- `ManualAdjustment` nên có `payrollRunId` (nếu chỉ rõ thuộc kỳ) hoặc dùng period để khớp run.
    
- `PayElement.defaultFormulaId` -> `PayFormula.formulaId`.
    
- `TaxRule` có thể liên quan `PayrollCalendar` (theo country nếu mỗi lịch lương ứng với quốc gia).
    
- `GLMapping.elementCode` -> `PayElement.code`.
    

Các API Engine hầu hết không lộ ra bên ngoài trực tiếp (trừ có thể /payCalendar khi admin cấu hình). Gateway mới là chỗ được gọi. Developer microservice Engine sẽ implement các API này và có thể nhận event từ Gateway (ví dụ event `payroll.run.created` -> tương đương /grossToNet gọi).

### Mapping: **Payroll Gateway Service** (Tích hợp ngoài)

|API (Method)|Chức năng|Bảng CSDL & Thao tác|Ghi chú|
|---|---|---|---|
|`/payrollRun` **GET**|Lấy danh sách hoặc chi tiết kỳ lương|**PayrollRun** – **READ** (SELECT ... WHERE payrollRunId/calendarId/status/fromDate/toDate)|Hỗ trợ các filter: - Nếu có `payrollRunId`: SELECT * FROM PayrollRun WHERE id = ... (trả 1 kết quả chi tiết). - Nếu có `payrollCalendarId`: SELECT * WHERE calendarId = ... (có thể kèm khoảng thời gian nếu fromDate/toDate). - Nếu có `status`: thêm điều kiện status = ... - Nếu có fromDate/toDate: lọc các kỳ có period giao với khoảng đó (VD periodStart >= fromDate AND periodEnd <= toDate). Trả về danh sách (hoặc 1) PayrollRun, bao gồm các trường chính (id, periodStart, periodEnd, status, executedAt...).|
|`/payrollRun` **POST**|Tạo hoặc cập nhật kỳ lương|**PayrollRun** – **CREATE/UPDATE**|- Nếu requestBody có `payrollRunId` (muốn cập nhật kỳ tồn tại): UPDATE các trường cho bản ghi đó (có thể cho phép sửa ngày kỳ lương hoặc trạng thái nếu chưa chốt). - Nếu _không có_ `payrollRunId`: tạo mới một kỳ lương: INSERT vào PayrollRun với một UUID mới. Các trường: `payrollCalendarId` (bắt buộc), `periodStart`, `periodEnd`, status ban đầu (có thể = 'PENDING'). Mã code của kỳ có thể auto-gen (vd `<calendarCode>-<tháng-năm>`). - Khi tạo mới: ngay lập tức phát sự kiện `payroll.run.created` (chứa payrollRunId vừa tạo). Engine service sẽ bắt sự kiện này để khởi động tính lương (tương đương tự động gọi `/grossToNet`). - Trả về đối tượng PayrollRun vừa tạo/cập nhật (có id). - AuditLog: log tạo hoặc cập nhật run (category RUN, action=INIT_RUN).|
|`/payrollResult` **GET**|Lấy kết quả lương của nhân viên hoặc toàn bộ kỳ|**PayrollResult** – **READ** (SELECT ... WHERE payrollRunId [AND employeeId]) **PayrollResultDetail** – **READ** (SELECT ... WHERE payrollRunId [AND employeeId])|Tham số: `payrollRunId` bắt buộc, `employeeId` tùy chọn. - Nếu có employeeId: truy vấn bảng PayrollResult cho đúng 1 nhân viên trong kỳ, và các dòng PayrollResultDetail tương ứng của nhân viên đó. Gộp thành object: employeeId, grossPay, netPay, currency, breakdown = [ {elementCode, amount}, ... ]. - Nếu không có employeeId: truy tất cả PayrollResult của runId, và toàn bộ detail của runId. Sau đó nhóm theo employeeId để xây dựng mảng PayrollResultList (mỗi phần tử như trên). Trường hợp nhiều nhân viên, nên cẩn thận performance; có thể dùng JOIN để lấy luôn breakdown cho từng người hoặc 2 query. - Kết quả trả JSON theo schema `PayrollResultList`. Đây có thể là nhiều data, nếu cần có thể paging, nhưng do mục đích xuất CSV chuyển khoản, có thể trả hết.|
|`/paymentFile` **POST**|Phát sinh file thanh toán ngân hàng|**PayrollResult** – **READ** (SELECT ... WHERE payrollRunId) **EmployeePayrollProfile** – **READ** (lấy tài khoản NH của nhân viên) **BankTemplate** – **READ** (mẫu format, nếu có bảng) **GeneratedFile** – **CREATE** (lưu file)|Xử lý: 1. Lấy tất cả nhân viên thuộc `payrollRunId` và số **net pay** của họ từ PayrollResult (có thể join Profile để lấy thông tin tài khoản ngân hàng). 2. Dựa vào `bankTemplateCode`, lấy mẫu file tương ứng (có thể từ Config – không thấy bảng, có thể mẫu được code sẵn hoặc lưu trong PayslipTemplate hay config riêng). _Nếu mẫu phức tạp, đề xuất:_ bảng `BankTemplate` (code, format, columns, delimiter, etc). 3. Sinh file CSV hoặc TXT: mỗi dòng gồm số tài khoản, tên người hưởng (có thể từ profile, cần tích hợp từ HR core tên NV), số tiền, nội dung... theo format ngân hàng. 4. Lưu file này vào một nơi (vd thư mục hoặc cloud storage). Tạo URL truy cập (có thể kèm token). 5. Trả về `fileUrl` và timestamp. 6. Phát sự kiện `payroll.payment.generated` kèm thông tin (để hệ thống khác biết file sẵn sàng, có thể tự động gửi ngân hàng nếu tích hợp). - Về DB: có thể có bảng `GeneratedFile` với (id, type=PAYMENT, payrollRunId, fileName, filePath, generatedAt). Hoặc đơn giản không lưu DB, chỉ cung cấp link. AuditLog: log generate payment file (category RUN, action=GEN_PAYFILE).|
|`/taxReport` **GET**|Lấy báo cáo thuế TNCN cho kỳ lương|**PayrollResultDetail** – **READ** (SELECT ... WHERE payrollRunId AND elementCode in tax elements) **PayrollRun** – **READ** (lấy thông tin kỳ, period...) **TaxReportTemplate** – (sẵn, nếu cần) **GeneratedFile** – **CREATE** (lưu file PDF/XML)|Xử lý: 1. Lấy tất cả các khoản thu nhập chịu thuế và thuế đã khấu trừ của nhân viên trong kỳ: ví dụ, lọc `PayrollResultDetail` với payrollRunId và elementCode loại thuế (PIT) hoặc thu nhập. Hoặc có thể đã tính sẵn tổng thuế từng người trong result. 2. Tổng hợp theo mẫu báo cáo thuế: Ví dụ mẫu 05/QTT đòi hỏi: Tổng thu nhập chịu thuế trong kỳ (hoặc năm), tổng thuế đã khấu trừ... Tùy thiết kế, có thể đòi hỏi tính lũy kế hoặc chi tiết từng người. Đơn giản có thể liệt kê mỗi nhân viên, thu nhập, thuế. 3. Chọn định dạng: PDF hoặc XML. 4. Sinh file báo cáo: Nếu PDF, điền vào form; nếu XML, tạo cấu trúc theo yêu cầu cơ quan thuế. 5. Lưu file, tạo URL tương tự như trên. 6. Trả về `reportUrl` và generatedAt. - DB: có thể có bảng `GeneratedFile` (type=TAX_REPORT, payrollRunId, ...). AuditLog: log generate tax report (category RUN, action=GEN_TAXREPORT).|

_Chú thích:_ Gateway chủ yếu **đọc** dữ liệu từ các bảng do Engine và Profile quản lý. Bảng `GeneratedFile` đề xuất ở trên có thể gộp để quản lý các file đầu ra (loại Payment, Tax, Payslip...). Mỗi bản ghi chứa thông tin file, có thể cấu hình thời gian hết hạn cho link, v.v.

Riêng `BankTemplate` và `TaxReportTemplate` không được đề cập trong YAML, nhưng để hệ thống linh hoạt, có thể có:

- Bảng `BankTemplate` cấu hình mẫu cột cho từng mã ngân hàng (hoặc lưu trong code).
    
- Mẫu báo cáo thuế thường cố định theo luật, có thể tích hợp sẵn (XML schema do cơ quan thuế cung cấp). Nếu cần mềm dẻo, cũng lưu trong cấu hình.
    

**Đề xuất bổ sung API Gateway:**

- `GET /payrollRun/{id}`: chi tiết một kỳ lương cụ thể (thực ra GET /payrollRun với payrollRunId đã bao gồm).
    
- `GET /payslip` (như đã thảo luận) – nếu thêm:
    
    - **Input**: payrollRunId, employeeId, format (PDF).
        
    - **Process**: đọc `PayrollResult` + `PayrollResultDetail` + `PayslipTemplate`, xuất file PDF.
        
    - **Output**: file PDF (binary or URL).
        
    - **Mapping**: tương tự `GeneratedFile` – type=PAYSLIP.
        

Trên đây, các mapping table liệt kê đầy đủ mối liên hệ giữa API và các bảng CSDL. Dựa vào đây, developer có thể xác định rõ khi một API được gọi cần thao tác với bảng nào, trường gì.

## Bổ Sung Thiết Kế Bảng & Chức Năng (Nếu Thiếu)

Dựa trên quá trình rà soát và mapping ở trên, có một số bảng và quan hệ không có trong thiết kế DBML ban đầu nhưng cần thêm để hệ thống hoạt động trọn vẹn theo API Specs:

- **Bảng `PayrollRun`**: Bảng này rất quan trọng nhưng chưa thấy đề cập rõ trong DBML ban đầu. Cần thiết kế bảng `PayrollRun(payrollRunId, payrollCalendarId, periodStart, periodEnd, status, executedAt, finalizedAt, ... cùng các trường phụ như type, originalRunId, reversedByRunId, costedFlag)`. Bảng này liên kết trung tâm giữa nhiều phân hệ (Input, Retro, Engine, Gateway).
    
    - Trường `type`: đề xuất dùng để đánh dấu loại kỳ lương (`NORMAL` mặc định, `RETRO` cho batch hồi tố, `REVERSAL` hoặc `ROLLBACK` cho batch đảo).
        
    - Trường `status`: {PENDING, PROCESSING, COMPLETED, REVERSED, ERROR,...} để theo dõi tiến trình.
        
    - Trường quan hệ: `payrollCalendarId` (FK tới PayrollCalendar), `originalRunId` (FK tự liên kết khi run này là kết quả đảo/hồi tố của run trước).
        
- **Bảng `PayrollResult` và `PayrollResultDetail`**: Để lưu kết quả tính lương chi tiết mỗi kỳ.
    
    - `PayrollResult(payrollRunId, employeeId, grossPay, netPay, currency, etc)`.
        
    - `PayrollResultDetail(payrollRunId, employeeId, elementCode, amount)`.
        
    - Khóa chính `PayrollResult` có thể là (payrollRunId, employeeId). `PayrollResultDetail` có thể dùng (payrollRunId, employeeId, elementCode) làm key hoặc dùng id tự tăng.
        
    - Cần chỉ mục để truy vấn nhanh theo runId.
        
    - Mối quan hệ: PayrollResultDetail nhiều dòng thuộc một PayrollResult. `elementCode` tham chiếu PayElement.
        
- **Bảng `PayrollInputItem`** (đề xuất để gộp các đầu vào):
    
    - Nếu chưa có thiết kế ban đầu, cần thêm bảng này: `PayrollInputItem(id, payrollRunId NULL, payrollCalendarId, periodStart, periodEnd, employeeId, sourceType, code, value, unit?)`.
        
    - Trường `payrollRunId` để link tới kỳ (nếu run đã tồn tại). Nếu data nhập trước khi tạo run, lưu tạm với calendar+period, khi run được tạo trùng kỳ thì cập nhật fill `payrollRunId`.
        
    - Sử dụng bảng này giúp đơn giản hoá nhiều logic input và retro.
        
- **Bảng `EmployeePayrollProfile`**: Chắc chắn cần (theo Profile). Bao gồm các cột đã nói. Đảm bảo có index trên employeeId (tra nhanh hồ sơ từng người).
    
- **Bảng `ManualAdjustment`**: Cần cho Retro. Cột bổ sung: `payrollRunId` (nullable): nếu adjustment gắn với một run cụ thể. Hiện YAML dùng periodStart/End để xác định kỳ, nhưng nên lưu thêm runId cho chắc (sau khi run tạo, có thể update).
    
- **Bảng `AuditLog`**: Cần thiết kế theo schema đã mô tả. Có thể bổ sung cột `employeeId` và `payrollRunId` (nullable) để tiện lọc, thay vì chỉ có referenceId dạng text.
    
- **Bảng `ImportJob`** (tuỳ chọn): Để theo dõi việc xử lý file upload. Không bắt buộc nếu dùng audit log cho việc này, nhưng thêm bảng sẽ giúp UI/API kiểm tra status job dễ hơn (ví dụ có thể có API GET /manual-upload/{jobId}/status).
    
- **Bảng `GeneratedFile`** (tuỳ chọn): Để lưu thông tin các file đầu ra (pay slip, payment file, tax report). Gợi ý cấu trúc: `GeneratedFile(id, type, payrollRunId, employeeId NULL, fileName, filePath, generatedAt, expiresAt NULL)`. Mục đích: truy vết những file đã tạo, phục vụ tải lại nếu cần. Developer có thể lưu file ra disk và chỉ lưu path trong DB.
    
- **Bảng `PayElement`** và **`PayFormula`**: Những bảng này chắc chắn cần (Engine). Đảm bảo `code` unique trong PayElement, và gán defaultFormulaId làm FK tới PayFormula.
    
- **Bảng `PayrollCalendar`**: Cần cho Engine (lịch lương). Có quan hệ 1-n với PayrollRun (một lịch lương có nhiều kỳ).
    
    - Bổ sung trường `defaultCurrency` (nếu muốn hỗ trợ đa tiền tệ, override GlobalConfig).
        
    - Bảng này cũng gián tiếp đại diện cho PayGroup.
        
- **Bảng `TaxRule`** vs `StatutoryRule`**: Cần quyết định dùng 1 hay 2 bảng. Để tránh trùng lặp, có thể dùng duy nhất `StatutoryRule` (đã có đầy đủ trường, kể cả taxBrackets). Engine khi cần tính thuế cho một tháng sẽ query StatutoryRule WHERE type='tax' AND region='VN' AND effectiveDate <= periodEnd AND (expirationDate IS NULL OR expirationDate >= periodEnd) để lấy luật hiện hành. Tuy nhiên YAML đã tách API, có thể do thiết kế microservice riêng.
    
    - Nếu tách: Bảng `TaxRule` có thể đơn giản: (taxRuleId, countryCode, ruleJson). ruleJson có thể chứa những thông tin tương tự Statutory nhưng gộp vào một blob JSON cho engine xử lý nhanh.
        
    - Có thể sync tự động StatutoryRule -> TaxRule mỗi khi có thay đổi (sự kiện).
        
- **Mối quan hệ PayGroup**: Nếu cần chi tiết hơn, có thể tạo bảng `PayGroup(payGroupCode, payrollCalendarId, currency, ...)`. Trong trường hợp doanh nghiệp có nhiều nhóm trả lương dùng chung một lịch (ví dụ cùng hàng tháng nhưng khác công ty con, khác currency), PayGroup tách ra sẽ linh hoạt hơn. Profile trỏ sang PayGroup, PayGroup trỏ sang Calendar. Nhưng nếu không cần phức tạp, sử dụng luôn PayrollCalendar như PayGroup.
    
- **Trường currency**: Bổ sung trong `PayrollResult` (thực ra có trong schema trả về). Currency có thể điền từ GlobalConfig hoặc từ PayrollCalendar nếu ta thêm currency ở đó. Mỗi kết quả lương nên lưu rõ currency để tránh nhầm lẫn (nhất là nếu một hệ thống dùng đa quốc gia).
    
- **Trường khác**:
    
    - Trường `taxable` trong PayElement cho biết element có tính thuế hay không, engine dùng để quyết định cộng vào thu nhập chịu thuế.
        
    - Trường `severity` trong ValidationRule (ERROR/WARNING) đã có. Engine khi validate có thể tách dựa trên severity để đưa vào errors hay warnings list.
        
    - Trường `active` trong ValidationRule để engine biết rule nào cần chạy.
        
    - Trường `retroBatchId` trả về trong Retro Calc gợi ý ta cần phân biệt `PayrollRun` nào là batch retro. Có thể đặt `PayrollRun.type='RETRO'` và `originalRunId` liên kết.
        
    - **PayslipTemplate**: Bảng này đã có nhưng cần sử dụng: có thể link `PayrollCalendar` hoặc `PayGroup` với một `payslipTemplateCode` nào đó (nếu mỗi nhóm lương xài mẫu phiếu riêng). Nếu công ty chỉ 1 mẫu thì không cần liên kết, có thể chọn mặc định.
        
- **Phân quyền & phê duyệt**: Trong các hệ thống lớn, quy trình tính lương thường có phê duyệt (ví dụ: quản lý xác nhận bảng lương trước khi chốt). Hiện tại chưa đề cập, có thể tích hợp qua AuditLog (người nào thực hiện finalize) hoặc có cờ `approvedBy` ở PayrollRun. Nếu sau này cần, có thể thêm bảng `PayrollRunApproval` (runId, approverId, status).
    

Tóm lại, thiết kế DBML cần bổ sung các bảng cốt lõi đã liệt kê để hiện thực hóa toàn bộ API Specs. Việc mapping trên đã phơi bày chỗ nào DB còn thiếu: ví dụ thiếu bảng PayrollRun, thiếu quan hệ link run với input, v.v. Những đề xuất bổ sung này đảm bảo rằng khi developer phát triển microservice, họ có sẵn **cấu trúc dữ liệu** để lưu trữ và truy xuất thông tin theo yêu cầu nghiệp vụ.

Cuối cùng, qua sự đối chiếu với các giải pháp HRM hàng đầu, thiết kế module Payroll này đã bao quát hầu hết chức năng cần thiết: từ cấu hình linh hoạt, thu thập dữ liệu đầu vào đa nguồn, tính lương chuẩn xác kể cả hồi tố, kiểm soát thay đổi (audit) cho đến tích hợp thanh toán, thuế và kế toán. Một vài điểm hiện đại như hỗ trợ đa tiền tệ, phát hành phiếu lương điện tử... cũng đã được đề cập và có thể bổ sung dễ dàng trong kiến trúc hiện tại. Với tài liệu mapping API-Database chi tiết ở trên, các lập trình viên có thể tự tin triển khai từng microservice, đảm bảo các API Specs được hiện thực đúng đắn từ thiết kế DBML. Các nguồn tham khảo cho thấy hướng đi này phù hợp với chuẩn ngành (ví dụ: cơ chế retropay, audit trail đều đã có trong thiết kế). Như vậy, sau khi cập nhật các bảng/quan hệ còn thiếu, module Payroll sẽ **chuẩn chỉnh và đầy đủ**, sẵn sàng phục vụ bài toán tính lương phức tạp trong thực tế.