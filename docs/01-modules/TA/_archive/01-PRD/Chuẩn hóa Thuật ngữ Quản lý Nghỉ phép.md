# **Báo cáo Nghiên cứu Chuyên sâu: Chuẩn hóa Thuật ngữ và Mô hình Dữ liệu Quản trị Nghỉ phép (Absence Management) trong Hệ thống Quản trị Nguồn nhân lực (HCM)**

## **1\. Tóm tắt Điều hành và Bối cảnh Chiến lược**

Trong kỷ nguyên số hóa quy trình quản trị nguồn nhân lực (Human Capital Management \- HCM), sự chính xác của hệ thống thuật ngữ không chỉ đơn thuần là vấn đề ngữ nghĩa mà là nền tảng cốt lõi của kiến trúc hệ thống, tính toàn vẹn dữ liệu và tuân thủ pháp lý. Yêu cầu từ phía người dùng về việc chuẩn hóa các thuật ngữ như "leave balance" (số dư nghỉ phép) và "leave instant" (tạm dịch: thời điểm/sự kiện nghỉ phép) phản ánh một thách thức phổ biến trong việc triển khai các nền tảng HRIS (Human Resource Information System): khoảng cách giữa ngôn ngữ thông thường của lực lượng lao động và các mô hình dữ liệu (Data Models) chặt chẽ được yêu cầu bởi các hệ thống doanh nghiệp như Oracle Fusion Cloud, Workday, SAP SuccessFactors và các nền tảng ERP hiện đại.

Báo cáo này cung cấp một phân tích thấu đáo, toàn diện về hệ thống thuật ngữ tiêu chuẩn ngành cho quản trị vắng mặt (Absence Management). Tài liệu sẽ giải cấu trúc các khung khái niệm được sử dụng bởi các nhà cung cấp HCM hàng đầu thế giới để đề xuất một từ điển tiêu chuẩn hóa. Cụ thể, báo cáo sẽ phân tích việc chuyển đổi "leave balance" thành các cấu trúc kỹ thuật như **Sổ cái Tài khoản Thời gian (Time Account Ledgers)**, **Số dư Tích lũy (Accrual Balances)**, và **Quyền lợi Ròng (Net Entitlements)**. Đồng thời, báo cáo sẽ làm rõ ý nghĩa kỹ thuật của thuật ngữ "leave instant", định hình lại nó dưới các khái niệm **Bản ghi Vắng mặt (Absence Entry)**, **Sự kiện Nghỉ phép (Leave Event)**, hoặc **Đối tượng Giao dịch (Transactional Object)**.

Hơn nữa, tài liệu này khám phá các hàm ý kiến trúc của những thuật ngữ này, chi tiết hóa cách các "số dư" hoạt động như những sổ cái động chịu sự chi phối của các quy tắc phân bổ theo tỷ lệ (proration), quy tắc trao quyền (vesting), và quy tắc tịch thu (forfeiture). Thông qua phân tích so sánh giữa Oracle, SAP và Workday, cùng với việc xem xét các cấu trúc API và thực tiễn tốt nhất, báo cáo này nhằm mục đích trang bị cho các kiến trúc sư giải pháp và chuyên gia nhân sự một hệ thống từ vựng cần thiết để thiết kế các hệ thống quản lý vắng mặt mạnh mẽ, tuân thủ và có khả năng mở rộng.

## **2\. Khung Khái niệm: Vật lý của Thời gian như một Loại Tiền tệ**

Để thấu hiểu hệ thống thuật ngữ tiêu chuẩn ngành, trước tiên chúng ta phải chấp nhận tiền đề nền tảng của các hệ thống Quản trị Vắng mặt (Absence Management) hiện đại: **Thời gian được xử lý như một loại tiền tệ (Time as Currency).** Do đó, kiến trúc phần mềm phản chiếu các hệ thống sổ cái ngân hàng và tài chính thay vì các lịch trình làm việc đơn giản.

### **2.1 Từ "Leave Balance" đến Kiến trúc Sổ cái (Ledger Architecture)**

Trong các hệ thống sơ khai, "số dư" (balance) thường được coi là một trường dữ liệu tĩnh (static field) trong cơ sở dữ liệu—một con số đơn lẻ được cập nhật ghi đè (overwrite). Tuy nhiên, trong các hệ thống HCM hiện đại chuẩn ngành (Enterprise-grade HCM), khái niệm này đã tiến hóa thành một mô hình **Sổ cái Kép (Double-Entry Bookkeeping)** hoặc **Sổ cái Giao dịch (Transactional Ledger)**.

Khi một nhân viên nhìn thấy "Leave Balance: 12 ngày", hệ thống thực tế đang thực hiện một truy vấn tổng hợp (aggregation query) trên hàng loạt các giao dịch tín dụng (credit) và nợ (debit). Không có con số "12" tĩnh nào tồn tại độc lập mà không có ngữ cảnh lịch sử.

* **Tín dụng (Credits):** Các khoản được cộng vào, thường được gọi là **Accruals** (Tích lũy) hoặc **Entitlements** (Quyền lợi).  
* **Nợ (Debits):** Các khoản bị trừ đi, đại diện cho các ngày nghỉ đã thực hiện, thường gọi là **Absence Takes** hoặc **Withdrawals**.  
* **Điều chỉnh (Adjustments):** Các giao dịch sửa lỗi hoặc thay đổi thủ công, ví dụ như **Accrual Adjustments** hoặc **Balance Transfers**.1

### **2.2 Từ "Leave Instant" đến Đối tượng Sự kiện (Event Object)**

Thuật ngữ "Leave Instant" trong truy vấn của người dùng gợi ý về một điểm thời gian cụ thể hoặc một sự kiện đơn lẻ. Trong mô hình dữ liệu kỹ thuật, điều này ánh xạ tới khái niệm **Sự kiện (Event)** hoặc **Giao dịch (Transaction)**. Sự khác biệt giữa một "Instant" (khoảnh khắc) và một "Instance" (thể hiện/trường hợp) là rất quan trọng trong thiết kế hướng đối tượng (Object-Oriented Design).

* **Tính chất Giao dịch (Transactional Nature):** Giống như một giao dịch chuyển tiền làm thay đổi số dư tài khoản, một **Leave Instance** là một giao dịch ghi nợ vào **Tài khoản Thời gian (Time Account)**.  
* **Trạng thái (Statefulness):** Một sự kiện nghỉ phép không phải là dữ liệu tĩnh; nó sở hữu một vòng đời trạng thái (ví dụ: Bản nháp \-\> Đã đệ trình \-\> Đang chờ duyệt \-\> Đã duyệt \-\> Đã ghi sổ).  
* **Mối quan hệ Phụ thuộc:** Mối quan hệ giữa Số dư và Sự kiện là vòng tròn nhân quả. Số dư giới hạn khả năng tạo ra Sự kiện (validation rules), và Sự kiện khi hoàn tất sẽ làm biến đổi Số dư (calculation engine).2

## **3\. Giải cấu trúc "Leave Balance": Phân tích Thuật ngữ và Mô hình Dữ liệu**

Thuật ngữ "Leave Balance" là không đủ để cấu hình hệ thống vì nó gộp chung nhiều khái niệm kỹ thuật riêng biệt. Để phù hợp với các tiêu chuẩn ngành, chúng ta phải phân rã thuật ngữ này thành các thành phần cấu tạo: **Accruals (Tích lũy)**, **Entitlements (Quyền lợi)**, và **Ledgers (Sổ cái)**.

### **3.1 Thuật ngữ Tiêu chuẩn cho "Leave Balance"**

Khi định nghĩa các trường hệ thống hoặc giao tiếp với các bên liên quan về "nơi lưu trữ" thời gian nghỉ, các thuật ngữ sau đây là tiêu chuẩn ngành, thay thế cho từ "Leave Balance" chung chung:

#### **3.1.1 Accrual (Sự Tích lũy \- Cơ chế Kiếm Thời gian)**

**Accrual** đại diện cho quá trình tích lũy thời gian qua một chu kỳ. Trong Oracle HCM Cloud, một **Accrual Plan** được định nghĩa rõ ràng là "một khoảng thời gian mà trong đó người lao động tích lũy thời gian".1 Đây là thuật ngữ chính xác nhất cho các loại nghỉ phép được "kiếm" dựa trên thời gian làm việc (như Phép năm).

* **Front-Loaded Accrual (Tích lũy Đầu kỳ):** Một khoản tổng (lump sum) được cấp vào đầu chu kỳ (thường gọi là "Grant" hoặc "Allocation"). Ví dụ: Cấp ngay 12 ngày phép vào ngày 1/1 hàng năm.  
* **Incremental Accrual (Tích lũy Gia tăng):** Thời gian được kiếm theo định kỳ (ví dụ: mỗi kỳ lương hoặc mỗi tháng). Ví dụ: Kiếm 1 ngày phép sau mỗi tháng làm việc.3  
* **Vesting (Trao quyền/Đủ điều kiện):** Khái niệm rằng thời gian đã tích lũy có thể chưa khả dụng để sử dụng ngay lập tức cho đến khi đạt được một thâm niên hoặc ngày cụ thể.

#### **3.1.2 Entitlement (Quyền lợi \- Khía cạnh Pháp lý)**

**Entitlement** thường đề cập đến quyền nghỉ phép theo luật định hoặc hợp đồng. Trong SAP SuccessFactors, điều này được xử lý thông qua **Time Accounts**, nơi các quyền lợi được tạo ra dựa trên các quy tắc kinh doanh (Business Rules).4 Sự phân biệt tuy tinh tế nhưng quan trọng:

* *Accrual* là cơ chế tính toán kỹ thuật.  
* *Entitlement* là giá trị pháp lý kết quả.  
* Trong Oracle, "Qualification Plans" (Kế hoạch Đủ điều kiện) quản lý các quyền lợi cho các kỳ nghỉ dài hạn (như Thai sản) nơi thời gian không phải được "kiếm" (earned) mà là "đủ điều kiện hưởng" (qualified for).5

#### **3.1.3 Ledger / Time Account (Sổ cái / Tài khoản Thời gian \- Nơi Lưu trữ)**

Thuật ngữ kỹ thuật chính xác nhất cho "nơi số dư tồn tại" là **Time Account** (SAP) hoặc **Time Account Ledger**. Điều này nhấn mạnh rằng số dư là một tổng hợp động của các khoản tín dụng (tích lũy) và nợ (vắng mặt).

* **Oracle:** Sử dụng "Accrual Plan Balance" (Số dư Kế hoạch Tích lũy) và "Plan Term" (Kỳ Kế hoạch).1  
* **Workday:** Sử dụng "Time Off Plan Balance" và khái niệm quan trọng "Balance as of Date" (Số dư tại ngày...).6  
* **SAP:** Sử dụng "Time Account" và "Time Account Snapshot" (Ảnh chụp nhanh Tài khoản Thời gian).8

### **3.2 Mô hình Dữ liệu Số dư Cụ thể theo Hệ thống (System-Specific Data Models)**

Để cung cấp một khuyến nghị cụ thể cho "Leave Balance", chúng ta cần xem xét cách các hệ thống hàng đầu đặt tên cho các thực thể này.

#### **3.2.1 Oracle Fusion Cloud HCM: Mô hình Tích lũy (Accrual Model)**

Oracle sử dụng một hệ thống thuật ngữ "Accrual" (Tích lũy) có cấu trúc cao.

* **Thuật ngữ chính:** **Accrual Balance**.  
* **Các thành phần con (Sub-Components):**  
  * *Ceiling (Trần):* Số dư tối đa cho phép (Cap).  
  * *Carryover (Chuyển tiếp):* Số lượng được chuyển sang kỳ kế tiếp.  
  * *Vested Balance (Số dư Đã trao quyền):* Phần tích lũy khả dụng để chi trả tiền mặt (disbursement).  
  * *Disbursement (Chi trả):* Thanh toán tiền mặt cho thời gian tích lũy (ví dụ: thanh toán phép dư khi nghỉ việc).1  
* **Hàm ý:** Nếu hệ thống của bạn mô phỏng logic của Oracle, hãy sử dụng **"Accrual Balance"** hoặc **"Plan Balance"**.

#### **3.2.2 SAP SuccessFactors: Mô hình Tài khoản Thời gian (Time Account Model)**

SAP sử dụng khái niệm **Time Accounts** rất mạnh mẽ, tương tự như tài khoản ngân hàng.

* **Thuật ngữ chính:** **Time Account**.  
* **Các thành phần con:**  
  * *Time Account Type:* Định nghĩa loại tài khoản (ví dụ: Nghỉ phép Hàng năm).  
  * *Time Account Snapshot:* Một khung nhìn đóng băng (frozen view) của số dư tại một thời điểm cụ thể, rất quan trọng cho việc xử lý cuối năm và báo cáo nợ phải trả (liability reporting).8  
  * *Bookings (Ghi sổ):* Các bút toán dương (tích lũy) hoặc âm (nghỉ phép) đối với tài khoản.  
* **Hàm ý:** Nếu hệ thống của bạn liên quan đến các quy tắc ghi sổ phức tạp và tính hiệu lực (validities), hãy sử dụng **"Time Account"** hoặc **"Time Account Balance"**.

#### **3.2.3 Workday: Mô hình Thời gian Nghỉ (Time Off Model)**

Workday tập trung vào trải nghiệm người dùng cuối (User Experience).

* **Thuật ngữ chính:** **Time Off Balance** hoặc **Balance As Of**.  
* **Các thành phần con:**  
  * *Plan Eligibility:* Ai nhận được số dư này.  
  * *Period:* Khung thời gian cho số dư.10  
* **Hàm ý:** Đối với giao diện người dùng (UI) hoặc Self-Service, hãy sử dụng **"Time Off Balance"**.

### **3.3 Các Khái niệm Số dư Nâng cao (Advanced Balance Concepts)**

Khi thiết kế một "Plan" (Kế hoạch), các số dư đơn giản hiếm khi đủ. Bạn phải tính đến các biến thể tiêu chuẩn ngành này:

#### **3.3.1 Proration (Phân bổ theo tỷ lệ)**

Khi một nhân viên gia nhập giữa năm, số dư của họ không phải là toàn bộ quyền lợi hàng năm. Đây được gọi là **Prorated Entitlement** (Quyền lợi Phân bổ) hoặc **Prorated Accrual**.

* **Cập nhật Oracle 23B:** Đã giới thiệu các quy tắc phân bổ định sẵn (predefined proration rules) để thay thế các "Partial Period Formulas" phức tạp, tính toán dựa trên "Days spent in plan" (Số ngày tham gia kế hoạch).3  
* **Logic:** ![][image1].  
* **Thực tiễn:** Hệ thống cần có thuật ngữ riêng cho giá trị này, ví dụ **"Pro-rated Balance"**.

#### **3.3.2 Retroactive Recalculation (Tính toán lại Hồi tố)**

Số dư mang tính lịch sử. Nếu lịch làm việc của nhân viên thay đổi hồi tố (ví dụ: họ chuyển từ toàn thời gian sang bán thời gian từ tháng trước), hệ thống phải thực hiện **Retroactive Recalculation** cho số dư.

* **Thuật ngữ:** **Retroactive Event** hoặc **Retro-Processing**.  
* **SAP:** Sử dụng các trường "Recalculation" trong Time Account Types để xử lý các thay đổi này.11

#### **3.3.3 Forecasting (Dự báo Số dư Tương lai)**

Người dùng thường muốn biết: "Nếu tôi nghỉ phép vào tháng 12, số dư của tôi *lúc đó* sẽ là bao nhiêu?" Đây không phải là số dư *hiện tại*.

* **Thuật ngữ:** **Projected Balance** hoặc **Simulated Balance**.  
* **SAP:** Công cụ "Time Account Process Simulator" cho phép trực quan hóa các khoản tích lũy tương lai.11  
* **PeopleSoft:** "Absence Forecasting" sử dụng một công cụ logic cụ thể để dự đoán tính đủ điều kiện.12  
* **Workday:** Tính năng "Balance as of Date" cho phép người dùng truy vấn các ngày trong tương lai.7

### **3.4 Bảng Khuyến nghị cho Thuật ngữ "Leave Balance"**

Bảng dưới đây tổng hợp các đề xuất thay thế cho "Leave Balance" dựa trên ngữ cảnh sử dụng:

| Thuật ngữ Đề xuất | Ngữ cảnh Sử dụng | Mức độ Tương thích Tiêu chuẩn Ngành | Ghi chú Triển khai |
| :---- | :---- | :---- | :---- |
| **Accrual Balance** | Kỹ thuật / Backend | Rất mạnh (Oracle/PeopleSoft) | Tốt nhất cho các loại nghỉ phép được "kiếm" (earned) theo thời gian. |
| **Time Account** | Kiến trúc / Schema | Rất mạnh (SAP) | Tốt nhất cho các hệ thống dựa trên sổ cái (ledger-based). |
| **Time Off Balance** | Giao diện Người dùng (UI) | Rất mạnh (Workday) | Thân thiện với người dùng, phù hợp cho ESS (Employee Self Service). |
| **Net Entitlement** | Pháp lý / Hợp đồng | Rất mạnh (Châu Âu / Úc) | Tốt nhất cho các quyền lợi pháp định cố định (Quota). |
| **Available Balance** | Chức năng (Functional) | Phổ quát | Làm rõ câu hỏi "tôi có thể dùng bao nhiêu ngay bây giờ?". |

**Đề xuất Tổng hợp:** Đối với "Plan" của bạn, nếu giá trị được tính toán dựa trên thời gian làm việc, hãy sử dụng **"Accrual Balance"**. Nếu đó là một khoản cấp cố định (như 12 ngày/năm), hãy sử dụng **"Annual Entitlement"**. Nếu bạn cần một thuật ngữ chung cho giao diện, **"Time Off Balance"** là tiêu chuẩn hiện đại nhất.

## **4\. Giải cấu trúc "Leave Instant": Giao dịch, Sự kiện và Đối tượng**

Thuật ngữ "Leave Instant" trong truy vấn của người dùng có khả năng là một sự nhầm lẫn về dịch thuật cho từ **"Leave Instance"** (một trường hợp/sự kiện nghỉ phép) hoặc có thể là **"Instant Leave"** (nghỉ phép tức thì). Tuy nhiên, trong mô hình dữ liệu, đối trọng của "Balance" (Số dư \- Tĩnh/Trạng thái) chính là "Instance" (Sự kiện \- Động/Giao dịch).

Ngành công nghiệp chia khái niệm này thành hai loại chính: **Short-Term Absences** (Nghỉ ngắn hạn/Time Off) và **Long-Term Leaves** (Nghỉ dài hạn/Leave of Absence \- LOA).

### **4.1 Phân tích Ngôn ngữ và Đối tượng Bản thể học (Ontological Analysis)**

Dựa trên mô hình bản thể học (Ontology) của Palantir và các hệ thống dữ liệu lớn, việc phân biệt giữa **Object Type** (Loại Đối tượng) và **Event** (Sự kiện) là rất quan trọng.13

* **Object Type:** Là định nghĩa trừu tượng (ví dụ: Nhân viên, Loại Nghỉ phép).  
* **Event/Instance:** Là sự cụ thể hóa của hành động (ví dụ: Nhân viên A nghỉ phép ngày X).

Do đó, "Leave Instant" nên được chuẩn hóa thành **Leave Instance** hoặc **Absence Entry**.

### **4.2 Thuật ngữ Tiêu chuẩn cho "Leave Instant"**

#### **4.2.1 Absence Entry / Time Off Request (Giao dịch Nghỉ phép)**

Đối với các ngày nghỉ phép thông thường (phép năm, nghỉ ốm), thuật ngữ ngành là một **Absence Entry** hoặc **Time Off Request**.

* **Oracle:** Sử dụng **"Absence Entry"** hoặc **"Absence Record"**. Đầu vào được xác thực dựa trên "Absence Type".5  
* **Workday:** Sử dụng **"Time Off Request"**. Lưu ý sự phân biệt: "Time Off" dùng cho thời gian ngắn; "Leave of Absence" dùng cho thời gian dài.16  
* **SAP:** Sử dụng đối tượng **"Employee Time"**. Đối tượng chung này bao gồm cả chấm công (attendance) và vắng mặt (absence), được phân biệt bởi trường "Time Type".4

#### **4.2.2 Absence Event / Leave of Absence (Sự kiện/Trường hợp Nghỉ phép)**

Đối với các kỳ nghỉ phức tạp, dài hạn (Thai sản, FMLA, Nghỉ ốm dài hạn), thuật ngữ "Instance" thường được nâng cấp thành **"Absence Case"** hoặc **"Leave of Absence (LOA)"**.

* **Quản lý Trường hợp (Case Management):** Đây không chỉ là các ngày tháng; chúng liên quan đến quy trình công việc (workflows), đính kèm tài liệu, và chứng nhận y tế.  
* **Workday:** Phân biệt rõ ràng giữa "Time Off" (yêu cầu) và "Leave of Absence" (sự kiện/trường hợp). Một **"Absence Case"** theo dõi các cột mốc quan trọng và kế hoạch quay lại làm việc (return-to-work plans).17  
* **Oracle:** Sử dụng **"Absence Case"** để nhóm các mục nhập vắng mặt có liên quan (ví dụ: nghỉ phép ngắt quãng cho cùng một điều kiện y tế).2

#### **4.2.3 Absence Pattern (Mẫu hình Vắng mặt)**

Oracle giới thiệu khái niệm **"Absence Pattern"** để định nghĩa hành vi của instance.

* *Generic Absence:* Nghỉ phép thường/Du lịch.  
* *Illness or Injury:* Nghỉ ốm (yêu cầu bằng chứng y tế).  
* *Childbirth/Placement:* Thai sản/Nhận con nuôi (yêu cầu ngày dự sinh).5  
* **Insight:** "Instance" được định nghĩa bởi "Pattern" của nó.

### **4.3 Khái niệm "Soft Booking" và "Hard Booking"**

Nếu "Leave Instant" hàm ý một trạng thái tạm thời hoặc chưa được xác nhận (như từ "instant" có thể gợi ý một khoảnh khắc thoáng qua), khái niệm ngành phù hợp là **Soft Booking**.

* **Soft Booking (Đặt chỗ Mềm):** Một sự giữ chỗ tạm thời về thời gian. Nó ảnh hưởng đến khả năng hiển thị tính sẵn sàng (availability visibility) nhưng có thể chưa trừ vào số dư sổ cái chính thức "Hard" cho đến khi được phê duyệt cuối cùng.  
* **Hard Booking (Đặt chỗ Cứng):** Một cam kết thời gian đã được xác nhận, chính thức ghi nợ vào số dư tích lũy.19  
* **Trường hợp sử dụng:** Các tổ chức dựa trên dự án (Professional Services Automation \- PSA) sử dụng Soft Booking để ước tính tính khả dụng của nguồn lực trước khi dự án được xác nhận.21 Điều này đặc biệt quan trọng nếu hệ thống của bạn tích hợp với Quản lý Dự án (Project Management).

### **4.4 Mô hình Dữ liệu Kỹ thuật cho "Leave Instance"**

Khi định nghĩa lược đồ (schema) cho thực thể này, hãy xem xét các trường và cấu trúc tiêu chuẩn sau:

#### **4.4.1 Cấu trúc Oracle REST API**

Oracle gọi tài nguyên này là **"absenceEntries"**.

* **Các trường khóa:** absenceType (Loại), startDate, endDate, duration (Thời lượng), status (Trạng thái).23  
* **Đối tượng con:** absenceMaternityDetails, absenceCertifications.

#### **4.4.2 Cấu trúc Workday REST API**

Workday sử dụng **"Absence\_Request\_Event"** hoặc **"Time\_Off\_Request"**.

* **Các trường khóa:** descriptor (tên mô tả), date, units, type.  
* **Sự khác biệt:** Workday tách biệt "Event" (logic nghiệp vụ) khỏi "Request" (hành động người dùng).25

#### **4.4.3 Cấu trúc SAP OData API**

SAP sử dụng **"EmployeeTime"**.

* **Các trường khóa:** timeType, startDate, endDate, quantityInHours, approvalStatus.  
* **Liên kết:** Liên kết ngược lại với TimeAccount thông qua các quy tắc ghi sổ (posting rules).26

### **4.5 Bảng Khuyến nghị cho Thuật ngữ "Leave Instant"**

| Thuật ngữ Đề xuất | Ngữ cảnh Sử dụng | Mức độ Tương thích Tiêu chuẩn Ngành | Ghi chú Triển khai |
| :---- | :---- | :---- | :---- |
| **Absence Entry** | Tổng quát / Kỹ thuật | Rất mạnh (Oracle) | Bao gồm tất cả các loại vắng mặt. Tốt nhất cho bản ghi CSDL. |
| **Time Off Request** | Giao diện Người dùng | Rất mạnh (Workday) | Tốt nhất cho nghỉ ngắn hạn (Vacation/Sick). |
| **Leave Event** | Chức năng | Tốt | Phân biệt các sự kiện rời rạc. Hữu ích cho báo cáo. |
| **Absence Case** | Phức tạp / Y tế | Rất mạnh (Workday/Oracle) | Chỉ sử dụng nếu "instant" đề cập đến nghỉ dài hạn/phức tạp (Thai sản). |
| **Booking** | Quản lý Nguồn lực | Đặc thù (PSA/Project) | Tốt nhất nếu ngữ cảnh là tính sẵn sàng của dự án (Soft/Hard). |
| **Leave Instance** | Mô hình Đối tượng | Chấp nhận được | Dùng trong lập trình hướng đối tượng (Object Instance). |

**Đề xuất Tổng hợp:** Thay thế "Leave Instant" bằng **"Absence Entry"** (nếu đề cập đến bản ghi cơ sở dữ liệu) hoặc **"Time Off Request"** (nếu đề cập đến hành động của người dùng). Nếu hệ thống xử lý các trường hợp phức tạp (thai sản), hãy xem xét thêm **"Absence Case"**.

## **5\. Các Cân nhắc Kiến trúc: Kết nối Số dư và Sự kiện**

Mối quan hệ giữa **Balance** (Sổ cái) và **Instance** (Giao dịch) là động cơ cốt lõi của bất kỳ hệ thống HCM nào. Trong kế hoạch của bạn, bạn phải định nghĩa **"Logic Ghi nợ" (Debiting Logic)** hoặc **"Quy tắc Tiêu thụ" (Consumption Rule)**.

### **5.1 Hệ thống Sổ cái (Double-Entry Bookkeeping)**

Các hệ thống HCM hiện đại không chỉ đơn giản là "ghi đè" một trường số dư. Chúng sử dụng một nhật ký giao dịch (transaction log).

1. *Trạng thái Ban đầu:* Balance \= 10 ngày.  
2. *Instance:* Yêu cầu 2 ngày (Trạng thái: Đã duyệt).  
3. *Ledger Entry:* Ghi nợ 2 ngày.  
4. *Trạng thái Tính toán:* Balance \= 8 ngày.

Điều này cho phép tạo ra **Audit Trails** (Vết kiểm toán). Nếu một "Leave Instant" bị xóa, hệ thống tạo ra một *giao dịch bù trừ* (Ghi có 2 ngày) thay vì chỉ xóa khoản ghi nợ. Điều này cực kỳ quan trọng đối với tuân thủ tài chính và tính toán Công nợ Nghỉ phép (Leave Liability).27

### **5.2 Thứ tự Xử lý (FEFO/LIFO)**

Khi một "Instance" xảy ra, nó tiêu thụ "Balance" nào?

* **Logic Thùng (Bucket Logic):** Nhân viên thường có nhiều "thùng" thời gian (ví dụ: Chuyển tiếp từ năm 2024, Tích lũy năm 2025).  
* **Quy tắc Tiêu thụ:** Thực tiễn tiêu chuẩn là **FEFO (First Expiring, First Out \- Hết hạn trước, Xuất trước)**. Hệ thống phải trừ vào số dư Chuyển tiếp (Carryover) *trước khi* trừ vào số dư Tích lũy Hiện tại để ngăn nhân viên bị mất các ngày sắp hết hạn.  
* **Logic Oracle:** "Periodic accrual balance calculation takes precedence" (Tính toán số dư tích lũy định kỳ được ưu tiên). Nó xử lý **Rollover** (chuyển sang kế hoạch mới) trước, sau đó là **Carryover** (cùng kế hoạch, kỳ tiếp theo).1

### **5.3 Đơn vị Đo lường (Unit of Measure \- UOM)**

"Plan" phải định nghĩa đơn vị tiền tệ.

* **Hours vs. Days:** "Leave Instant" có thể là 1 ngày, nhưng "Balance" có thể được lưu trữ dưới dạng giờ.  
* **Công thức Chuyển đổi:** Bạn cần một công thức xác định để chuyển đổi thời lượng của Instance thành khoản khấu trừ Balance.  
  * *Oracle:* Yêu cầu UOM của kế hoạch và loại nghỉ phải khớp nhau, hoặc phải có công thức chuyển đổi.5  
  * *SAP:* Hỗ trợ đơn vị tuần (weeks) cho các loại nghỉ phép đặc thù như Long Service Leave ở Úc và yêu cầu logic chuyển đổi phức tạp.9

## **6\. Sắc thái Quy định & Khu vực (Bối cảnh: Việt Nam)**

Dựa trên ngôn ngữ truy vấn của người dùng (tiếng Việt), điều quan trọng là áp dụng các thuật ngữ tiêu chuẩn này vào bối cảnh quy định cụ thể của **Bộ luật Lao động Việt Nam 2019** (Labour Code 2019).

### **6.1 Tích lũy Dựa trên Thâm niên (Seniority-Based Accruals)**

Việt Nam có quy tắc cụ thể (Điều 114\) trong đó phép năm tăng thêm 1 ngày cho mỗi 5 năm làm việc.29

* **Thuật ngữ Ngành:** **"Length of Service (LOS) Banding"** hoặc **"Seniority Accrual Matrix"**.  
* **Triển khai Oracle:** Sử dụng "Accrual Bands" dựa trên "derived factors" (các yếu tố dẫn xuất \- ở đây là Thâm niên).5  
* **Khuyến nghị:** "Plan" của bạn phải bao gồm thuộc tính **"Service Band"** (Dải thâm niên) để xử lý logic **"Accrual Balance"** động này.

### **6.2 "Leave Instant" và Ngày Lễ (Public Holidays)**

Tại Việt Nam, nếu một ngày lễ công cộng rơi vào trong một "Leave Instance", ngày đó thường không được tính là ngày nghỉ phép (không bị trừ vào Balance).

* **Thuật ngữ:** **"Non-working Day Exclusion"** (Loại trừ ngày không làm việc) hoặc **"Holiday Calendar Validation"** (Xác thực Lịch nghỉ lễ).  
* **Workday:** Xác thực dựa trên "Holiday Calendars".2  
* **Triển khai:** Thời lượng của "Leave Instance" (Calendar Duration \- ví dụ: 5 ngày từ Thứ 2 đến Thứ 6\) sẽ khác với "Recorded Duration" (Deductible Days \- ví dụ: 4 ngày, nếu Thứ 4 là ngày lễ). Hệ thống cần phân biệt rõ hai khái niệm này.

### **6.3 Nghỉ Ốm và Bảo hiểm Xã hội (Sick Leave vs. Social Insurance)**

Tại Việt Nam, nghỉ ốm thường được chi trả bởi Bảo hiểm Xã hội (BHXH) chứ không phải công ty trả lương trực tiếp (như Sick Pay ở Mỹ/Anh).

* **Thuật ngữ:** Cần phân biệt **"Paid Leave"** (Công ty trả \- Phép năm) và **"Social Insurance Leave"** (BHXH trả \- Nghỉ ốm).  
* **Hàm ý:** "Leave Balance" cho nghỉ ốm có thể không phải là một "Accrual Balance" (tích lũy) mà là một **"Entitlement Limit"** (Giới hạn tối đa theo luật BHXH \- ví dụ: 30 ngày/năm). Thuật ngữ **"Quota"** hoặc **"Limit"** phù hợp hơn **"Balance"** trong trường hợp này.

## **7\. Các Khuyến nghị Chiến lược cho Hệ thống Thuật ngữ trong Plan của Bạn**

Dựa trên nghiên cứu sâu về các mô hình dữ liệu của Oracle, Workday và SAP, dưới đây là đề xuất tổng hợp để đổi tên "Leave Balance" và "Leave Instant" trong thiết kế hệ thống của bạn.

### **7.1 Bản đồ Ánh xạ Thuật ngữ Đề xuất (Terminology Mapping Map)**

Bảng dưới đây ánh xạ từ ngữ hiện tại của bạn sang các chuẩn mực quốc tế, kèm theo các lựa chọn thay thế tùy thuộc vào độ phức tạp của hệ thống.

| Thuật ngữ Hiện tại (User Query) | Chuẩn Mực Ngành Đề xuất (Recommended) | Thay thế / Ngữ cảnh Cụ thể | Mô tả & Lý do (Rationale) |
| :---- | :---- | :---- | :---- |
| **Leave Balance** | **Accrual Balance** | *Plan Balance* | Nhấn mạnh việc nghỉ phép được "tích lũy" (earned) theo thời gian. Chuẩn trong Oracle/PeopleSoft. |
|  | **Time Off Balance** | *Available Balance* | Thân thiện với người dùng, chuẩn trong Workday/Modern SaaS. Tốt nhất cho ESS. |
|  | **Time Account** | *Ledger* | Thuật ngữ kỹ thuật cho vùng chứa cơ sở dữ liệu. Tốt nhất cho kiến trúc backend (kiểu SAP). |
|  | **Net Entitlement** | *Quota* | Nhấn mạnh quyền/giới hạn pháp lý. Phổ biến trong bối cảnh Châu Âu/Việt Nam (BHXH). |
| **Leave Instant** | **Absence Entry** | *Time Entry* | Bản ghi kỹ thuật của sự vắng mặt. Chuẩn trong Oracle. |
|  | **Time Off Request** | *Leave Request* | Hành động được khởi tạo bởi nhân viên. Chuẩn trong Workday. |
|  | **Absence Event** | *Leave Event* | Một sự kiện rời rạc. Hữu ích cho báo cáo (ví dụ: "3 sự kiện nghỉ phép năm nay"). |
|  | **Absence Case** | *LOA Case* | Chỉ sử dụng nếu "instant" đề cập đến nghỉ dài hạn phức tạp (Thai sản, FMLA). |

### **7.2 Từ điển Dữ liệu cho Plan của Bạn (Data Dictionary)**

Để đảm bảo "Plan" của bạn chuyên nghiệp và chuẩn ngành, hãy tích hợp các định nghĩa sau vào tài liệu thiết kế:

1. **Accrual Plan (Kế hoạch Tích lũy \- The Rules):** Cấu hình định nghĩa cách thời gian được kiếm (ví dụ: "Vietnam Annual Leave Plan").  
2. **Accrual Period (Kỳ Tích lũy \- The Frequency):** Chu kỳ lặp lại cho việc kiếm phép (ví dụ: "Monthly", "Bi-weekly").  
3. **Eligibility Profile (Hồ sơ Đủ điều kiện \- The Who):** Các tiêu chí xác định ai thuộc về kế hoạch (ví dụ: "Full-time Employees \> 1 year tenure").  
4. **Absence Type (Loại Vắng mặt \- The Category):** Phân loại của "Instance" (ví dụ: "Sick", "Vacation", "Bereavement").  
5. **Adjustment (Điều chỉnh \- The Manual Change):** Một sự sửa đổi thủ công đối với "Balance" (ví dụ: "HR Correction", "Payout").  
6. **Disbursement (Chi trả \- The Payout):** Chuyển đổi "Balance" thành tiền mặt (ví dụ: "Unused Leave Payout" khi nghỉ việc).  
7. **Snapshot (Ảnh chụp nhanh):** Số dư tại một thời điểm cụ thể trong quá khứ hoặc tương lai, dùng cho báo cáo tài chính hoặc dự báo.

### **7.3 Insight về "Instant" vs. "Instance"**

Rất có khả năng "Instant" trong truy vấn của bạn là một lỗi dịch thuật của khái niệm *instance* (một đối tượng hoặc sự kiện). Tuy nhiên, nếu ý định của bạn là **"Instant Leave"** (có nghĩa là nghỉ phép tức thì, đột xuất hoặc được phê duyệt tự động), thuật ngữ ngành là **"Unplanned Absence"** hoặc **"Emergency Leave"**.

* **Unplanned Absence:** Nghỉ phép không báo trước.  
* **Emergency Leave:** Một loại nghỉ cụ thể cho các khủng hoảng không lường trước.

Nếu thuật ngữ "Instant" đề cập đến *tốc độ* cập nhật số dư (thời gian thực), khái niệm này là **"Real-Time Accrual"** hoặc **"Real-Time Balance Calculation"** (trái ngược với xử lý theo lô \- batch processing). Hầu hết các hệ thống hiện đại (Workday, Oracle Cloud) đều hoạt động trên các công cụ tính toán **Real-Time**.

## **8\. Kết luận**

Việc chuẩn hóa thuật ngữ là bước đầu tiên hướng tới một triển khai HCM mạnh mẽ. Bằng cách chuyển từ "Leave Balance" sang **"Accrual Balance"** hoặc **"Time Account,"** và từ "Leave Instant" sang **"Absence Entry"** hoặc **"Time Off Request,"** bạn đang điều chỉnh kế hoạch của mình phù hợp với kiến trúc của các hệ thống doanh nghiệp toàn cầu.

Sự đồng bộ này tạo điều kiện thuận lợi cho:

1. **Tích hợp API Tốt hơn:** Các nhà phát triển sẽ hiểu ngay lập tức các điểm cuối absenceEntry hoặc accrualBalance.  
2. **Định nghĩa Chính sách Rõ ràng hơn:** Phân biệt giữa "Entitlement" (Quyền) và "Balance" (Khả dụng) ngăn chặn sự mơ hồ về pháp lý.  
3. **Báo cáo Nâng cao:** Phân biệt giữa "Request" (Ý định người dùng) và "Case" (Sự kiện được quản lý) cho phép phân tích chi tiết hơn.

Đối với bối cảnh Việt Nam, hãy đảm bảo logic **Accrual Balance** của bạn hỗ trợ **Service Bands** (Điều 114 Bộ luật Lao động) và các **Absence Entries** của bạn tuân thủ các loại trừ của **Holiday Calendar**.

## **9\. Phụ lục: Tham chiếu Kỹ thuật**

### **9.1 Ma trận So sánh Thuật ngữ**

| Khái niệm | Oracle Fusion HCM | Workday | SAP SuccessFactors |
| :---- | :---- | :---- | :---- |
| **Lưu trữ (Storage)** | Accrual Plan | Time Off Plan | Time Account Type |
| **Giá trị (Value)** | Plan Balance / Accrual | Balance as of Date | Time Account Snapshot |
| **Giao dịch (Transaction)** | Absence Entry | Time Off Request | Employee Time |
| **Tính toán (Calculation)** | Fast Formula | Calculation Engine | Time Sheet / Rules |
| **Dài hạn (Long Term)** | Absence Case | Leave of Absence (LOA) | Leave of Absence |
| **Nhóm (Grouping)** | Absence Type | Time Off Type | Time Type |

### **9.2 Tham chiếu Đối tượng API (Dành cho Nhà phát triển)**

* **Oracle:** /hcmRestApi/resources/11.13.18.05/absences (Transaction), /hcmRestApi/resources/11.13.18.05/absencePlans (Balance Rules).24  
* **Workday:** Get\_Workers (chứa Time\_Off\_Balance), Put\_Absence\_Input (Transaction).31  
* **SAP:** TimeAccount (Balance), EmployeeTime (Transaction).9

**Lưu ý về Sử dụng:** Khi lập tài liệu cho kế hoạch của bạn, sự nhất quán là chìa khóa. Một khi bạn chọn một thuật ngữ (ví dụ: **Absence Entry**), hãy sử dụng nó độc quyền để tham chiếu đến bản ghi giao dịch, và tránh sử dụng hoán đổi với "request" hoặc "leave" để duy trì sự rõ ràng về kiến trúc.

#### **Nguồn trích dẫn**

1. Options to Define Accrual Plans \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/options-to-define-accrual-plans.html](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/options-to-define-accrual-plans.html)  
2. Workday Absence Management, truy cập vào tháng 2 11, 2026, [https://www.workday.com/content/dam/web/en-us/documents/datasheets/workday-absence-management-datasheet-en-us.pdf](https://www.workday.com/content/dam/web/en-us/documents/datasheets/workday-absence-management-datasheet-en-us.pdf)  
3. What's new in Oracle's 23B \- Absence Management \- Namos Solutions, truy cập vào tháng 2 11, 2026, [https://namossolutions.com/blog/whats-new-in-oracles-23b-absence-management/](https://namossolutions.com/blog/whats-new-in-oracles-23b-absence-management/)  
4. SAP SuccessFactors | Continuous Learning & Development, truy cập vào tháng 2 11, 2026, [https://ppalme.wordpress.com/category/sap-successfactors/](https://ppalme.wordpress.com/category/sap-successfactors/)  
5. Oracle Fusion Cloud Human Resources \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/implementing-absence-management.pdf](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/implementing-absence-management.pdf)  
6. Absence Management Software | Workday US, truy cập vào tháng 2 11, 2026, [https://www.workday.com/en-us/products/workforce-management/absence.html](https://www.workday.com/en-us/products/workforce-management/absence.html)  
7. Understanding Time Off (Absence) Balances, truy cập vào tháng 2 11, 2026, [https://apps.hr.cornell.edu/workdayCommunications/Workday%20Time%20Tracking%20Tutorials/JobAids/understanding\_time\_off\_balances.pdf](https://apps.hr.cornell.edu/workdayCommunications/Workday%20Time%20Tracking%20Tutorials/JobAids/understanding_time_off_balances.pdf)  
8. Operating Time Management in SAP SuccessFactors | PDF | Employment \- Scribd, truy cập vào tháng 2 11, 2026, [https://www.scribd.com/document/603234220/Operating-Time-Management-in-SAP-SuccessFactors](https://www.scribd.com/document/603234220/Operating-Time-Management-in-SAP-SuccessFactors)  
9. Describing Key SAP SuccessFactors Time Management 2H 2025 Feature, truy cập vào tháng 2 11, 2026, [https://learning.sap.com/courses/sap-successfactors-time-management/describing-the-new-features-and-enhancements-in-the-2h-2023-release\_a5a6e8cf-3142-4e9f-9c5d-0dd582894cae-1-1](https://learning.sap.com/courses/sap-successfactors-time-management/describing-the-new-features-and-enhancements-in-the-2h-2023-release_a5a6e8cf-3142-4e9f-9c5d-0dd582894cae-1-1)  
10. An Overview of Fusion Absence Management Part 1, truy cập vào tháng 2 11, 2026, [https://apps2fusion.com/old/oracle-fusion-online-training/fusion-applications/fusion-payroll/1190-fusion-absence-management-explanation-with-examples](https://apps2fusion.com/old/oracle-fusion-online-training/fusion-applications/fusion-payroll/1190-fusion-absence-management-explanation-with-examples)  
11. Accruals Time Account Process Simulator \- SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/docs/successfactors-employee-central/time-off-and-leave-of-absence-configuration-guide-getting-started/accruals-time-account-process-simulator](https://help.sap.com/docs/successfactors-employee-central/time-off-and-leave-of-absence-configuration-guide-getting-started/accruals-time-account-process-simulator)  
12. PeopleSoft PUM 43 | Absence Balance & Forecast Feature Enhancement \- Kovaion, truy cập vào tháng 2 11, 2026, [https://www.kovaion.com/blog/peoplesoft-pum-43-absence-balance-and-forecast-feature-enhancement/](https://www.kovaion.com/blog/peoplesoft-pum-43-absence-balance-and-forecast-feature-enhancement/)  
13. Object and link types • Object types • Overview \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/object-link-types/object-types-overview/](https://palantir.com/docs/foundry/object-link-types/object-types-overview/)  
14. Core concepts \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/ontology/core-concepts/](https://palantir.com/docs/foundry/ontology/core-concepts/)  
15. How You Set Up Absence Management \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-set-up-absence-management.html](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-set-up-absence-management.html)  
16. Workday Feature: Request Absence (Time Off), truy cập vào tháng 2 11, 2026, [https://workday.richmond.edu/features/article/-/25241/workday-feature-request-absence-time-off.html](https://workday.richmond.edu/features/article/-/25241/workday-feature-request-absence-time-off.html)  
17. Workday Absence Management online Training | Grow Smarter, truy cập vào tháng 2 11, 2026, [https://www.erpcloudtraining.com/courses/workday-absence-management-training](https://www.erpcloudtraining.com/courses/workday-absence-management-training)  
18. Workday Absence Management Datasheet en Us | PDF | Accrual | Working Time \- Scribd, truy cập vào tháng 2 11, 2026, [https://www.scribd.com/document/554210457/Workday-Absence-Management-Datasheet-en-Us](https://www.scribd.com/document/554210457/Workday-Absence-Management-Datasheet-en-Us)  
19. Project Portfolio Management with SAP RPM and cProjects \- Amazon S3, truy cập vào tháng 2 11, 2026, [https://s3-eu-west-1.amazonaws.com/gxmedia.galileo-press.de/leseproben/1838/sappress\_project\_portfolio\_management.pdf](https://s3-eu-west-1.amazonaws.com/gxmedia.galileo-press.de/leseproben/1838/sappress_project_portfolio_management.pdf)  
20. Deltek Vision 7.0 Concepts Guide, truy cập vào tháng 2 11, 2026, [https://dsm.deltek.com/DeltekSoftwareManagerWebServices/downloadFile.ashx?documentid=CEFC413D-4E0A-4CC3-8746-35B3D6B2F4E5](https://dsm.deltek.com/DeltekSoftwareManagerWebServices/downloadFile.ashx?documentid=CEFC413D-4E0A-4CC3-8746-35B3D6B2F4E5)  
21. Clarity PPM Fundamentals | PDF | Project Management \- Scribd, truy cập vào tháng 2 11, 2026, [https://www.scribd.com/document/794905311/Clarity-ppm-Fundamentals](https://www.scribd.com/document/794905311/Clarity-ppm-Fundamentals)  
22. NetSuite Applications Suite \- Glossary \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/netsuite-openair/nsoa-online-help/chapter\_3952997341.html](https://docs.oracle.com/en/cloud/saas/netsuite-openair/nsoa-online-help/chapter_3952997341.html)  
23. REST API for Oracle Fusion Cloud HCM \- Get an absence plan, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-absenceplanslov-absenceplanslovuniqid-get.html](https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-absenceplanslov-absenceplanslovuniqid-get.html)  
24. REST API for Oracle Fusion Cloud HCM \- Create an absence record, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-absences-post.html](https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-absences-post.html)  
25. workday.absencemanagement(v1.5.1) \- Ballerina Central, truy cập vào tháng 2 11, 2026, [https://central.ballerina.io/ballerinax/workday.absencemanagement/latest](https://central.ballerina.io/ballerinax/workday.absencemanagement/latest)  
26. User \- SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/docs/successfactors-platform/sap-successfactors-api-reference-guide-odata-v2/user](https://help.sap.com/docs/successfactors-platform/sap-successfactors-api-reference-guide-odata-v2/user)  
27. 10 Best Practices for Time & Attendance Professionals \- ADP, truy cập vào tháng 2 11, 2026, [https://www.adp.com/-/media/adp/resourcehub/pdf/10-best-practices-july-2019.pdf?rev=d8add0abee6647ffaaa8e881f5926696](https://www.adp.com/-/media/adp/resourcehub/pdf/10-best-practices-july-2019.pdf?rev=d8add0abee6647ffaaa8e881f5926696)  
28. Time Account Snapshots \- SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/docs/successfactors-employee-central/time-off-and-leave-of-absence-configuration-guide-getting-started/time-account-snapshots](https://help.sap.com/docs/successfactors-employee-central/time-off-and-leave-of-absence-configuration-guide-getting-started/time-account-snapshots)  
29. Benefits for employees with seniority \- LuatVietnam.vn \- Legal documents of Vietnamese laws, truy cập vào tháng 2 11, 2026, [https://english.luatvietnam.vn/legal-news/what-are-the-benefits-for-employees-with-seniority-4729-91358-article.html](https://english.luatvietnam.vn/legal-news/what-are-the-benefits-for-employees-with-seniority-4729-91358-article.html)  
30. REST API for Oracle Fusion Cloud HCM, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/farws/index.html](https://docs.oracle.com/en/cloud/saas/human-resources/farws/index.html)  
31. REST Directory \- Workday Community, truy cập vào tháng 2 11, 2026, [https://community.workday.com/sites/default/files/file-hosting/restapi/](https://community.workday.com/sites/default/files/file-hosting/restapi/)

[image1]: <data:image/png;base64,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>