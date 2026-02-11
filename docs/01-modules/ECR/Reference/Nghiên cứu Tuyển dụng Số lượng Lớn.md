# 

# 

# **Báo cáo Nghiên cứu Chiến lược:** 

# 

# 

# **Kiến trúc Hệ thống ATS Thế hệ mới cho Tuyển dụng Mass Hiring, Bán lẻ và Job Fair**

## *Mục Lục*

[1\. Tổng quan Điều hành và Tầm nhìn Kiến trúc](#heading=)

[1.1 Triết lý Hệ thống: Hệ sinh thái Tuyển dụng Lai (Hybrid)](#heading=)

[2\. Bối cảnh Thị trường và Yêu cầu Vận hành Đặc thù](#heading=)

[2.1 Thách thức trong Tuyển dụng Bán lẻ (Retail Hiring)](#heading=)

[2.2 Động lực của Tuyển dụng Fresher và Job Fair](#heading=)

[3\. Kiến trúc Quản lý Sự kiện: Từ Yêu cầu đến Đăng ký](#heading=)

[3.1 Bản đồ Quan hệ: Một Sự kiện \- Đa Yêu cầu (Many-to-One)](#heading=)

[3.2 Luồng Ứng tuyển Động (Dynamic Application Workflow)](#heading=)

[3.3 Chiến lược Phát hiện và Xử lý Trùng lặp (De-duplication Strategy)](#heading=)

[4\. Hệ thống Định danh và Theo dõi Ứng viên (SBD Logic)](#heading=)

[4.1 Động cơ Sinh SBD Độc lập (Decoupled SBD Generation Engine)](#heading=)

[4.2 Vòng đời và Tính Nhất quán của SBD](#heading=)

[5\. Kiến trúc Kiểm tra và Đánh giá: Online và Onsite](#heading=)

[5.1 Phân hệ Bài tập/Test Online (Assignment Module)](#heading=)

[5.2 Quản lý Test Onsite & Hoạch định Sức chứa (Capacity Planning)](#heading=)

[6\. Tổ hợp Quản lý Phỏng vấn (Interview Management Complex)](#heading=)

[6.1 Logic Phỏng vấn Hội đồng (Panel Interview)](#heading=)

[6.2 Lập lịch và Quản lý Slot (Scheduling)](#heading=)

[6.3 Chế độ Online vs. Onsite](#heading=)

[7\. Vận hành Onsite và Trải nghiệm Kiosk](#heading=)

[7.1 Quy trình Check-in Kiosk Thông minh](#heading=)

[7.2 In thẻ và Badge (Badge Printing)](#heading=)

[8\. Thao tác Hàng loạt (Bulk Operations) và UX/UI Quy mô lớn](#heading=)

[8.1 Thanh công cụ Thao tác Hàng loạt "Thông minh" (Smart Bulk Action Toolbar)](#heading=)

[8.2 Giao tiếp Hàng loạt (Mass Communication)](#heading=)

[9\. Quản lý Đề nghị Tuyển dụng (Offer Management)](#heading=)

[9.1 Vị trí của Logic Offer](#heading=)

[9.2 Quy trình Offer Số hóa](#heading=)

[10\. Báo cáo và Phân tích (Reporting & Analytics)](#heading=)

[10.1 Báo cáo Động (Dynamic Reporting)](#heading=)

[10.2 Các Chỉ số KPI Chính (Key Metrics)](#heading=)

[11\. Kết luận và Lộ trình Triển khai](#heading=)

[11.1 Tóm tắt các Tùy biến Cốt lõi (Critical Customizations)](#heading=)

[11.2 Khuyến nghị Lộ trình Phát triển](#heading=)

[Nguồn trích dẫn](#heading=)

## **1\. Tổng quan Điều hành và Tầm nhìn Kiến trúc**

Trong bối cảnh thị trường lao động hiện đại, đặc biệt là tại các nền kinh tế đang phát triển mạnh mẽ như Việt Nam, nhu cầu tuyển dụng số lượng lớn (Mass Hiring) trong các ngành bán lẻ và tuyển dụng sinh viên mới tốt nghiệp (Campus Hiring/Job Fair) đang đặt ra những thách thức chưa từng có đối với các hệ thống Quản lý Tuyển dụng (Applicant Tracking Systems \- ATS) truyền thống. Báo cáo này cung cấp một phân tích chuyên sâu về các yêu cầu chức năng, logic vận hành và kiến trúc kỹ thuật cần thiết để xây dựng một nền tảng Tuyển dụng Sự kiện (Event-Centric Recruitment Platform) toàn diện.

Phân tích này được tổng hợp từ dữ liệu nghiên cứu thị trường toàn cầu về các giải pháp ATS hàng đầu, các tình huống thực tế (case study) từ những gã khổng lồ bán lẻ như Walmart và các doanh nghiệp đầu ngành tại Việt Nam như Thế Giới Di Động (MWG) và Saigon Co.op. Đồng thời, báo cáo tích hợp chặt chẽ các yêu cầu nghiệp vụ nội bộ (Internal Requirements) được trích xuất từ các tài liệu quy trình Fresher và Mass Hiring đính kèm, nhằm giải quyết các điểm nghẽn cụ thể về định danh ứng viên (SBD), phân luồng phỏng vấn hội đồng, và quản lý năng lực kiểm tra tập trung.1

### **1.1 Triết lý Hệ thống: Hệ sinh thái Tuyển dụng Lai (Hybrid)**

Đặc điểm cốt lõi của giải pháp được đề xuất là khả năng quản lý một "Hệ sinh thái Tuyển dụng Lai". Điều này đòi hỏi sự đồng bộ hóa hoàn hảo giữa các quy trình kỹ thuật số (bài kiểm tra online, nộp hồ sơ qua QR Code) và các thực tế vật lý (check-in tại sự kiện, bài thi trên giấy, phỏng vấn trực tiếp). Hệ thống không chỉ đơn thuần là kho lưu trữ dữ liệu thụ động mà phải đóng vai trò là bộ não trung tâm ("Master of Event"), điều phối tương tác thời gian thực giữa hàng ngàn ứng viên, hàng trăm giám khảo và đội ngũ Talent Acquisition (TA).1

**Các trụ cột chiến lược bao gồm:**

* **Mô hình Dữ liệu Hướng Sự kiện (Event-Centric):** Chuyển dịch từ quản lý theo "Yêu cầu tuyển dụng" (Job Requisition) đơn lẻ sang quản lý theo "Sự kiện" (Event) chứa nhiều yêu cầu con, cho phép tuyển dụng đa vị trí trong một chiến dịch tập trung.1  
* **Cơ chế Định danh Linh hoạt:** Tách rời logic tạo Số Báo Danh (SBD) khỏi các trigger gửi email, cho phép tạo định danh tức thì tại mọi điểm chạm (touchpoint) trong hành trình ứng viên.1  
* **Quyền lực Thao tác Hàng loạt (Bulk Action Sovereignty):** Trang bị cho nhà tuyển dụng các công cụ xử lý theo lô (batch processing) tinh vi với logic bỏ qua lỗi (skip-logic) và cảnh báo thông minh để ngăn chặn tắc nghẽn quy trình.1  
* **Hậu cần Thông minh (Capacity-Aware Logistics):** Các thuật toán lập lịch tự động phân bổ ứng viên vào các ca thi (shift) dựa trên sức chứa phòng và thời gian thực, giải quyết bài toán "1.000 ứng viên trong 2 ngày".1

## ---

**2\. Bối cảnh Thị trường và Yêu cầu Vận hành Đặc thù**

### **2.1 Thách thức trong Tuyển dụng Bán lẻ (Retail Hiring)**

Tuyển dụng bán lẻ được đặc trưng bởi tốc độ, tỷ lệ biến động nhân sự cao và tính chất mùa vụ.4 Chỉ số quan trọng nhất không phải là "chất lượng tuyển dụng dài hạn" mà là "thời gian lấp đầy" (time-to-fill). Các mô hình bán lẻ tại Việt Nam như Thế Giới Di Động hay Bách Hóa Xanh yêu cầu một quy trình "tuyển dụng trong ngày" (same-day hiring) – nơi ứng viên có thể nộp đơn, phỏng vấn và nhận việc chỉ trong vài giờ.6

**Phân tích Case Study:**

* **Thế Giới Di Động (MWG):** Thành công của MWG nằm ở việc tự động hóa quy trình sàng lọc và thông báo kết quả. Hệ thống của họ tích hợp sâu với SMS Brandname và Website để cập nhật trạng thái ứng viên theo thời gian thực, giảm thiểu tối đa các thao tác thủ công của bộ phận nhân sự tại cửa hàng.5  
* **Co.opmart:** Với đặc thù mở mới các siêu thị quy mô lớn, Co.opmart đối mặt với bài toán "Mass Mobilization" – huy động hàng trăm nhân sự cùng lúc. Yêu cầu đặt ra là hệ thống phải hỗ trợ phân luồng ứng viên vào các ca phỏng vấn (shift) một cách khoa học để tránh ùn tắc tại địa điểm tuyển dụng.8

**Hàm ý cho thiết kế ATS:** Hệ thống phải hỗ trợ luồng "Walk-in" (ứng viên vãng lai), cho phép ứng viên đến trực tiếp cửa hàng, quét QR Code tại quầy Kiosk và tạo hồ sơ ngay lập tức mà không cần đăng ký trước trên website.10

### **2.2 Động lực của Tuyển dụng Fresher và Job Fair**

Sự kiện tuyển dụng tại trường đại học (Job Fair) mang đến một lớp phức tạp khác: sự bùng nổ về số lượng (volume surge). Các tài liệu nội bộ chỉ ra rằng một sự kiện Fresher có thể thu hút hàng nghìn sinh viên đăng ký vào nhiều "Track" (ngạch chuyên môn) khác nhau như Game Development, Game Design, hay QC.1

**Các ràng buộc vận hành:**

* **Xử lý Khối lượng lớn:** Hệ thống phải duy trì hiệu năng ổn định khi xử lý 1.000+ check-in trong một buổi sáng.1  
* **Đồng bộ hóa Đa kênh:** Đảm bảo một sinh viên làm bài test online tại nhà được định danh chính xác khi đến làm bài test onsite hoặc phỏng vấn trực tiếp.  
* **Tính Toàn vẹn Dữ liệu:** Ngăn chặn việc tạo hồ sơ trùng lặp (duplicate) khi một sinh viên nộp đơn vào nhiều vị trí trong cùng một sự kiện, đồng thời vẫn cho phép họ ứng tuyển đa ngạch nếu quy định cho phép.1

## ---

**3\. Kiến trúc Quản lý Sự kiện: Từ Yêu cầu đến Đăng ký**

Mô đun **Quản lý Sự kiện (Event Management)** là trái tim của hệ thống ATS Mass Hiring. Khác với mô hình ATS truyền thống xoay quanh "Job Requisition", kiến trúc mới đặt "Event" làm đối tượng trung tâm, kết nối "Cầu" (Nhu cầu tuyển dụng) và "Cung" (Nguồn ứng viên) thông qua một lớp logic nghiệp vụ linh hoạt.

### **3.1 Bản đồ Quan hệ: Một Sự kiện \- Đa Yêu cầu (Many-to-One)**

Yêu cầu nghiệp vụ mới xác định rõ ràng mối quan hệ **Một-Nhiều (One-to-Many)** giữa Event và Request.1 Điều này giải quyết bài toán tuyển dụng tập trung cho nhiều vị trí khác nhau trong cùng một đợt.

**Logic Nghiệp vụ Chi tiết:**

1. **Khởi tạo Request:** Trước khi tạo Event, TA phải tạo các Yêu cầu Tuyển dụng (Request) trên hệ thống. Các Request này phải ở trạng thái "Approved" (Đã duyệt), loại "Fresher", và đặc biệt là **chưa được đăng (Not Posted)** lên Career Site.1 Điều này ngăn chặn việc ứng viên nộp đơn sai luồng (nộp trực tiếp vào Job thay vì qua Event).  
2. **Mapping Sự kiện:** Khi tạo Event (ví dụ: "Fresher 2026"), TA sẽ chọn và map các Request đã tạo vào Event này. Hệ thống sẽ khóa các Request này lại, không cho phép đăng lẻ tẻ bên ngoài Event.  
3. **Cấu hình Track:** Mỗi Request được map sẽ tương ứng với một "Track" (Ngạch) trong Event. Ví dụ: Request "Junior Java Dev" map vào Track "Developer", Request "QC Intern" map vào Track "Quality Control".1

### **3.2 Luồng Ứng tuyển Động (Dynamic Application Workflow)**

Để xử lý sự đa dạng của các vị trí trong cùng một sự kiện, biểu mẫu ứng tuyển (Application Form) phải có khả năng biến đổi linh hoạt (Dynamic Rendering).1

**Kịch bản Người dùng (User Story):**

*Là một sinh viên ứng tuyển vào sự kiện Fresher, khi tôi chọn Track "Game Design", hệ thống phải hiển thị bộ câu hỏi chuyên môn về thiết kế (Portfolio, Toolset). Ngược lại, nếu bạn tôi chọn Track "Game QC", hệ thống phải ẩn các câu hỏi thiết kế và hiển thị câu hỏi về tư duy logic và kiểm thử.*

**Cơ chế Kỹ thuật:**

* **Bộ Câu hỏi (Question Set):** Thay vì gán câu hỏi trực tiếp vào Event, hệ thống quản lý các "Bộ câu hỏi" trong thư viện (Questionnaire Library). Khi map Request vào Event, TA sẽ chọn Bộ câu hỏi tương ứng cho Request đó.1  
* **Lưu trữ Dữ liệu:** Dữ liệu ứng tuyển được lưu trữ dưới dạng cấu trúc linh hoạt (như JSON hoặc EAV \- Entity Attribute Value) gắn liền với cặp khóa {CandidateID, EventID, TrackID}.  
* **Hiển thị Báo cáo:** Khi xuất báo cáo (Export), hệ thống phải có khả năng "làm phẳng" (flatten) cấu trúc dữ liệu này. Nếu TA lọc danh sách theo Track "Game Design", các cột báo cáo phải tự động cập nhật để chỉ hiển thị các câu hỏi liên quan đến Design, ẩn đi các cột của Track khác.1

### **3.3 Chiến lược Phát hiện và Xử lý Trùng lặp (De-duplication Strategy)**

Trong các sự kiện Mass Hiring, việc ứng viên nộp đơn nhiều lần (do lo lắng hoặc muốn thử sức nhiều vị trí) là rất phổ biến. Hệ thống cần một cơ chế "Cảnh báo Trùng lặp" (Duplicate Alert) thông minh thay vì ngăn chặn cứng nhắc.1

**Thuật toán Phát hiện:**

* **Khóa chính:** Số điện thoại (Phone) VÀ/HOẶC Mã Sinh viên (Student ID).  
* **Thời điểm kích hoạt:** Ngay khi ứng viên nhấn "Submit" hoặc khi TA import danh sách từ Excel.

**Quy trình Xử lý Trùng lặp:**

1. **Cảnh báo:** Hệ thống không tự động xóa. Thay vào đó, nó đánh dấu (flag) hồ sơ trùng lặp trong danh sách ứng viên và hiển thị tại tab "Duplicate" riêng biệt.  
2. **Quyết định của TA:** TA sẽ được cung cấp công cụ so sánh (side-by-side comparison) để quyết định:  
   * **Remove:** Xóa bản ghi mới, giữ bản ghi cũ (nếu ứng viên spam).  
   * **Replace/Merge:** Cập nhật thông tin mới vào hồ sơ cũ (nếu ứng viên muốn cập nhật CV).  
   * **Allow:** Cho phép cả hai hồ sơ tồn tại (nếu ứng viên được phép thi cả 2 Track).  
* **Logic Thay thế dữ liệu (Replace Data):** Nếu chọn Replace, hệ thống sẽ ghi đè các trường thông tin mới lên ID cũ, đảm bảo lịch sử hoạt động không bị mất.1

## ---

**4\. Hệ thống Định danh và Theo dõi Ứng viên (SBD Logic)**

Một trong những điểm nghẽn lớn nhất được xác định trong tài liệu nội bộ là sự phụ thuộc của **Số Báo Danh (SBD)** vào quy trình gửi email.1 Trong các sự kiện quy mô lớn, việc tạo ID phải được tách rời khỏi hoạt động giao tiếp để đảm bảo tính sẵn sàng cho mọi tình huống (bao gồm cả walk-in không cần email).

### **4.1 Động cơ Sinh SBD Độc lập (Decoupled SBD Generation Engine)**

Hệ thống cần một service riêng biệt để sinh SBD, có thể được gọi (trigger) từ nhiều điểm khác nhau trong quy trình tuyển dụng.

**Các điểm kích hoạt (Triggers):**

1. **Khi Đăng ký (On Registration):** Sinh SBD ngay khi ứng viên submit form. Phù hợp cho các sự kiện Job Fair mở, nơi SBD đóng vai trò là vé vào cửa (Ticket ID).  
2. **Khi Chuyển Trạng thái (On Stage Transition):** Chỉ sinh SBD khi ứng viên vượt qua vòng Sàng lọc (Screening) và chuyển sang vòng Test/Interview. Điều này giúp tiết kiệm tài nguyên số và tránh cấp SBD cho hồ sơ rác.  
3. **Gán Thủ công (Manual Override):** Cho phép TA nhập SBD thủ công hoặc sinh SBD tức thì cho các ứng viên walk-in tại địa điểm thi.1

**Cấu trúc SBD:** Cần hỗ trợ định dạng cấu hình được (Configurable Format) để dễ quản lý.

* Ví dụ: {EventCode}-{TrackPrefix}-{RandomNumber} (VD: F26-DEV-0159).  
* Việc sử dụng tiền tố Track (DEV, QC, HR) giúp nhân viên điều phối tại hiện trường dễ dàng phân loại ứng viên vào đúng phòng thi.

### **4.2 Vòng đời và Tính Nhất quán của SBD**

Giải đáp thắc mắc về việc SBD có thay đổi giữa các vòng (Check-in vs. Interview) hay không 1:

* **Nguyên tắc "Single Source of Truth":** SBD được cấp phát lần đầu tiên (ví dụ: tại vòng Test Onsite) phải là định danh duy nhất đi theo ứng viên suốt sự kiện. Không sinh SBD mới tại vòng Interview trừ khi đó là một quy trình hoàn toàn tách biệt.  
* **Xử lý Ngoại lệ (Bypass):** Nếu quy trình cho phép bypass vòng Check-in (ví dụ: phỏng vấn online), hệ thống vẫn phải ngầm định tạo SBD cho ứng viên. Điều này đảm bảo khi xuất báo cáo hoặc khi ứng viên đến nhận việc (Offer), họ vẫn có mã định danh hệ thống.1  
* **Hiển thị:** SBD phải xuất hiện trên mọi giao diện: Email mời, Danh sách ứng viên (Grid View), Màn hình Check-in Kiosk, và Bảng điểm của Hội đồng phỏng vấn.

## ---

**5\. Kiến trúc Kiểm tra và Đánh giá: Online và Onsite**

Hệ thống phải hỗ trợ mô hình "Đánh giá Lai" (Hybrid Assessment Model), cho phép chuyển đổi linh hoạt giữa làm bài tại nhà (Test Online) và làm bài tập trung (Test Onsite/Assessment Center).

### **5.1 Phân hệ Bài tập/Test Online (Assignment Module)**

Phân hệ này quản lý việc giao đề, nộp bài và chấm điểm cho hàng loạt ứng viên.

Quy trình Nghiệp vụ 1:

1. **Tạo Bài tập:** TA thiết lập nội dung Assignment (Link đề bài, File đính kèm, Deadline, Người chấm).  
2. **Gửi Hàng loạt:** Hệ thống gửi email chứa "Link Nộp bài" (Submission Link) duy nhất cho từng ứng viên.  
3. **Cổng Nộp bài (Submission Portal):**  
   * Ứng viên truy cập link, xem đề (Banner, Hướng dẫn).  
   * Upload file bài làm (Hỗ trợ Zip nếu nhiều file).  
   * **Quy tắc Đặt tên:** Hệ thống tự động đổi tên file theo format \[FullName\]\_\_ để tránh thất lạc khi TA tải về hàng loạt.  
4. **Nhắc nhở (Reminders):** Hệ thống tự động chạy job quét các ứng viên chưa nộp bài trước Deadline 24h để gửi email nhắc nhở.1

**Cơ chế Chấm điểm:**

* **Chấm Online:** Manager truy cập hệ thống, xem trước (preview) bài làm và nhập điểm/nhận xét trực tiếp.  
* **Chấm Offline & Import:** Đối với các bài test kỹ thuật phức tạp (Code), TA có thể tải toàn bộ bài làm về, chuyển cho bộ phận chuyên môn chấm, sau đó tổng hợp kết quả vào file Excel và Import ngược lại vào hệ thống. Hệ thống phải tự động khớp SBD và cập nhật trạng thái Pass/Fail.1

### **5.2 Quản lý Test Onsite & Hoạch định Sức chứa (Capacity Planning)**

Bài toán "1.000 ứng viên" yêu cầu một thuật toán phân chia ca thi (Shift/Session) thông minh.1

**Thuật toán Tạo Ca Thi (Shift Generation Logic):**

* **Input:** Tổng số ứng viên (N), Số ngày tổ chức (D), Số ca mỗi ngày (S), Sức chứa tối đa mỗi phòng (Max\_Cap).  
* **Tính toán:**  
  1. Tổng số Slot khả dụng \= D \* S \* Max\_Cap.  
  2. Nếu N \> Tổng Slot \-\> Cảnh báo thiếu tài nguyên.  
  3. Nếu N \<= Tổng Slot \-\> Phân bổ đều: Số ứng viên mỗi ca \= N / (D \* S).  
* Ví dụ thực tế 1: 1.000 ứng viên chia cho 2 ngày, mỗi ngày 3 ca (Sáng 2, Chiều 1\) \=\> Tổng 6 ca.  
  * Kết quả: \~166 ứng viên/ca.  
* **Xử lý Tràn (Overflow Handling):** Nếu có thêm 20 ứng viên mới (Late Passers) sau khi đã chia ca:  
  * Hệ thống kiểm tra các ca hiện tại xem còn slot trống (dưới Max\_Cap) không.  
  * Nếu còn: Tự động điền vào (Backfill).  
  * Nếu đầy: Yêu cầu TA mở thêm "Ca phụ" hoặc cho phép "Overbook" (Chấp nhận vượt quá sức chứa) với cảnh báo rủi ro.1

Công nghệ Chống gian lận & Ngân hàng câu hỏi 12:

* **Ngân hàng câu hỏi (Question Bank):** Hỗ trợ phân loại theo độ khó và chủ đề.  
* **Randomization:** Hệ thống tự động sinh đề thi ngẫu nhiên từ ngân hàng câu hỏi cho từng ca thi hoặc từng ứng viên để tránh lộ đề.  
* **Proctoring:** Tích hợp các công cụ giám sát (nếu thi online tập trung) để khóa trình duyệt hoặc theo dõi hành vi.

## ---

**6\. Tổ hợp Quản lý Phỏng vấn (Interview Management Complex)**

Module Phỏng vấn giải quyết sự phức tạp của việc điều phối hội đồng (Panel), phòng họp và lịch trình cho số lượng lớn ứng viên.

### **6.1 Logic Phỏng vấn Hội đồng (Panel Interview)**

Khác với phỏng vấn 1:1, Mass Hiring thường sử dụng các "Hội đồng" (Council) gồm nhiều người phỏng vấn.

**Quy tắc Nghiệp vụ:**

* **Giao tiếp Hợp nhất (Consolidated Communication):** Đây là yêu cầu quan trọng để giảm tải cho Hiring Manager. Thay vì nhận 10 email cho 10 ứng viên, Manager chỉ nhận **01 email duy nhất** cho mỗi buổi phỏng vấn.1  
  * *Nội dung email:* "Lịch phỏng vấn ngày 10/02: Ca sáng (8:00 \- 12:00) bao gồm 5 ứng viên...".  
  * *Đính kèm:* Link tải file Zip chứa toàn bộ CV và Bảng điểm của 5 ứng viên đó, hoặc link truy cập vào "Hiring Manager Portal" để xem online.  
* **Cơ chế Chấm điểm Hội đồng:** Mỗi thành viên trong hội đồng có quyền truy cập độc lập để chấm điểm ứng viên. Hệ thống sẽ tổng hợp các điểm số này (trung bình cộng hoặc đồng thuận) để đưa ra kết quả cuối cùng (Pass/Fail).1

### **6.2 Lập lịch và Quản lý Slot (Scheduling)**

Hệ thống cần hỗ trợ **Lập lịch Hàng loạt** (Bulk Scheduling) với khả năng tự động hóa cao.

* **Thiết lập:** TA định nghĩa khung giờ (Window), thời lượng (Duration), và số lượng Hội đồng.  
* **Phân bổ:** Hệ thống tự động xếp ứng viên vào các slot theo nguyên tắc FIFO (First-In-First-Out) hoặc Random.  
* **Xác nhận của Ứng viên (Candidate Confirmation):**  
  * Email gửi cho ứng viên chỉ chứa: Ngày, Giờ, Địa điểm. **Không hiển thị** thông tin về thành viên Hội đồng hay số phòng cụ thể (để TA có thể đổi phòng phút chót mà không cần gửi lại mail).1  
  * **Deadline:** Link xác nhận có hiệu lực trong X giờ. Sau đó, slot sẽ bị thu hồi.  
* **Hàng đợi Đổi lịch (Rescheduling Queue):** Nếu ứng viên xin đổi lịch, họ được đưa vào hàng đợi. Khi có slot trống (do người khác hủy), hệ thống tự động thông báo cho ứng viên trong hàng đợi này.1

### **6.3 Chế độ Online vs. Onsite**

Hệ thống cần nút chuyển đổi (Toggle) giữa chế độ Online và Onsite cho từng vòng thi.1

* **Onsite Mode:** Kích hoạt tính năng đặt phòng họp, in phiếu điểm, Check-in bằng QR.  
* **Online Mode:** Tự động sinh link họp (Zoom/Teams/Google Meet), bỏ qua bước check-in vật lý, kích hoạt phiếu điểm điện tử (Digital Scorecard).

## ---

**7\. Vận hành Onsite và Trải nghiệm Kiosk**

Tại địa điểm tổ chức sự kiện (Job Fair, Cửa hàng bán lẻ), sự hiệu quả của quy trình Check-in quyết định trải nghiệm của ứng viên.

### **7.1 Quy trình Check-in Kiosk Thông minh**

Ứng dụng "Check-in Kiosk" (trên Tablet/Laptop) dành cho TA tại hiện trường cần các tính năng sau:

1. **Nhận diện Đa phương thức:**  
   * Quét QR Code từ email mời.  
   * Tìm kiếm nhanh theo SBD, Số điện thoại hoặc CCCD.1  
2. **Xác thực và Thu thập dữ liệu:**  
   * Hiển thị ảnh ứng viên (nếu đã có) để xác thực.  
   * **Chụp ảnh tại chỗ:** TA chụp ảnh ứng viên bằng camera của thiết bị. Ảnh này được upload tức thì vào hồ sơ để Hội đồng phỏng vấn nhận diện người thật.1  
   * **Thu hồ sơ giấy:** Nếu ứng viên mang theo CV bản cứng, TA có thể chụp ảnh CV đó và đính kèm vào hệ thống ngay tại bàn Check-in.  
3. **Xử lý Ngoại lệ (Walk-in):** Với ứng viên chưa đăng ký, Kiosk cho phép tạo hồ sơ nhanh (Quick Apply) với các trường tối thiểu (Tên, SĐT, Email) và sinh SBD ngay lập tức để họ có thể vào thi.

### **7.2 In thẻ và Badge (Badge Printing)**

Đối với các sự kiện lớn, hệ thống tích hợp với máy in để in thẻ đeo (Badge) ngay khi check-in.14

* Nội dung Badge: Tên, SBD (dạng Barcode/QR), Track ứng tuyển (mã màu để dễ phân biệt), và Lịch trình (Số phòng, Giờ thi).

## ---

**8\. Thao tác Hàng loạt (Bulk Operations) và UX/UI Quy mô lớn**

Xử lý hàng nghìn hồ sơ đòi hỏi các mẫu thiết kế UX chuyên biệt để ngăn chặn sai sót.

### **8.1 Thanh công cụ Thao tác Hàng loạt "Thông minh" (Smart Bulk Action Toolbar)**

Khi TA chọn 50 ứng viên để "Mời Phỏng vấn", hệ thống không được thực hiện ngay lập tức mà phải chạy qua một lớp **Logic Xác thực (Validation Logic)**.2

**Logic Modal Xác nhận (Confirmation Modal):**

Thay vì câu hỏi "Bạn có chắc chắn không?", Modal sẽ hiển thị báo cáo chi tiết:

**Thao tác: Gửi Thư Mời Phỏng Vấn**

* ✅ **Sẵn sàng gửi:** 45 Ứng viên (Trạng thái: Đã đậu Test Online).  
* ⚠️ **Bị loại bỏ (Skipped):** 5 Ứng viên (Lý do: Trạng thái là "Failed" hoặc "Đã từ chối").

*Hành động:* Hệ thống tự động bỏ chọn 5 ứng viên không hợp lệ và chỉ xử lý 45 người còn lại khi TA nhấn "Xác nhận".

**Phản hồi Trực quan (Visual Feedback):** Trong danh sách lưới (Grid View), các hàng ứng viên có trạng thái "Failed" hoặc "Rejected" sẽ bị làm mờ (dimmed/greyed out). Tuy nhiên, checkbox vẫn hoạt động để TA có thể chọn họ cho các hành động phù hợp khác (như gửi thư cảm ơn).1

### **8.2 Giao tiếp Hàng loạt (Mass Communication)**

* **Template Engine:** Hệ thống tự động chọn mẫu email phù hợp dựa trên *Trạng thái hiện tại* và *Track* của ứng viên.  
  * Ví dụ: Ứng viên rớt vòng CV nhận "Screening Fail Email", ứng viên rớt phỏng vấn nhận "Interview Fail Email".1  
* **Khóa Hành động (Action Locking):** Một khi email "Cảm ơn" (Từ chối) đã được gửi, nút gửi lại sẽ bị vô hiệu hóa (disabled) đối với ứng viên đó để ngăn chặn việc gửi trùng lặp gây phiền hà.1

## ---

**9\. Quản lý Đề nghị Tuyển dụng (Offer Management)**

### **9.1 Vị trí của Logic Offer**

Một quyết định kiến trúc quan trọng được đưa ra dựa trên tài liệu nội bộ: **Giai đoạn Offer sẽ được quản lý ở cấp độ "Request" (Yêu cầu tuyển dụng), không phải cấp độ "Event"**.1

**Lý do:** Event chỉ là kênh nguồn (Sourcing Channel). Offer là cam kết pháp lý gắn liền với một vị trí công việc cụ thể (Headcount) và ngân sách của phòng ban.

**Luồng xử lý:** Khi ứng viên đậu phỏng vấn tại Event, hồ sơ của họ sẽ được "Chuyển" (Transfer) sang Request tương ứng. Tại đây, TA sẽ tạo Offer Letter với mức lương, chế độ phúc lợi cụ thể.

### **9.2 Quy trình Offer Số hóa**

* **Gửi Offer:** Qua link an toàn (Secure Link).  
* **Phản hồi:** Ứng viên chọn "Accept" (Chấp nhận) hoặc "Reject" (Từ chối). Tính năng "Negotiate" (Thương lượng) không được hỗ trợ trên hệ thống để đơn giản hóa quy trình mass.1  
* **Hậu Offer:** Sau khi ứng viên chấp nhận, hệ thống tự động kích hoạt quy trình "Scan Candidate" (Thu thập hồ sơ nhân sự, Background Check) và chuyển dữ liệu sang bộ phận C\&B (Lương thưởng).1

## ---

**10\. Báo cáo và Phân tích (Reporting & Analytics)**

Đối với Mass Hiring, báo cáo cần vượt ra ngoài các danh sách đơn giản.

### **10.1 Báo cáo Động (Dynamic Reporting)**

Do mỗi Track trong sự kiện có bộ câu hỏi khác nhau, báo cáo xuất ra (Excel/CSV) phải có cấu trúc động.1

* **Input:** Chọn Event \+ Track "Game Design".  
* **Output:** File Excel chỉ chứa các cột câu hỏi liên quan đến Design. Các cột của Track "Developer" sẽ bị ẩn đi để file báo cáo gọn gàng, dễ đọc.

### **10.2 Các Chỉ số KPI Chính (Key Metrics)**

Hệ thống cần cung cấp Dashboard theo dõi thời gian thực:

* **Hiệu suất Phễu (Funnel Efficiency):** Tỷ lệ chuyển đổi qua từng vòng (Đăng ký \-\> Nộp bài \-\> Đậu Test \-\> Đậu Phỏng vấn \-\> Nhận việc).17  
* **Nguồn Tuyển dụng (Source Effectiveness):** Phân tích xem trường Đại học nào cung cấp nhiều ứng viên đạt chất lượng nhất.  
* **Tốc độ Xử lý:** Thời gian trung bình để xử lý một ứng viên từ lúc check-in đến lúc có kết quả phỏng vấn.

## ---

**11\. Kết luận và Lộ trình Triển khai**

Phân tích cho thấy một hệ thống ATS tiêu chuẩn (off-the-shelf) là không đủ để đáp ứng nhu cầu chuyên biệt của Mass Hiring và tuyển dụng bán lẻ tại Việt Nam. Yêu cầu đặt ra là một **Nền tảng Tuyển dụng Sự kiện Module hóa** (Modular Recruitment Event Platform) tích hợp sâu với ATS lõi.

### **11.1 Tóm tắt các Tùy biến Cốt lõi (Critical Customizations)**

1. **SBD Engine độc lập:** Tạo mã định danh không phụ thuộc vào email.  
2. **Cấu trúc Event-Request:** Một Event quản lý nhiều Request con.  
3. **Cầu nối Vật lý \- Số:** Đồng bộ liền mạch từ Test Online \-\> Chia ca tự động \-\> Check-in QR Onsite.  
4. **Bulk Logic an toàn:** Xử lý hàng loạt với cơ chế xác thực và bỏ qua lỗi thông minh.

### **11.2 Khuyến nghị Lộ trình Phát triển**

* **Giai đoạn 1 (Core Flow):** Xây dựng module Event, Mapping Request và Form ứng tuyển động.  
* **Giai đoạn 2 (Logistics):** Phát triển Service sinh SBD và Thuật toán Chia ca/Hoạch định sức chứa.  
* **Giai đoạn 3 (Assessment):** Tích hợp module Test Online và Ứng dụng Check-in Kiosk.  
* **Giai đoạn 4 (Automation):** Hoàn thiện các Modal xác nhận Bulk Action và cơ chế thông báo hợp nhất cho Manager.

Việc triển khai kiến trúc này sẽ giúp doanh nghiệp giảm 40-60% khối lượng công việc hành chính 19, loại bỏ sai sót dữ liệu và nâng cao hình ảnh chuyên nghiệp trong mắt hàng nghìn ứng viên trẻ tiềm năng.

#### **Nguồn trích dẫn**

1. ATS\_Flow Fresher (Sent) \_ Internal.xlsx  
2. Using the bulk action toolbar \- Lever Help Center, truy cập vào tháng 2 10, 2026, [https://help.lever.co/s/article/Using-the-bulk-action-toolbar](https://help.lever.co/s/article/Using-the-bulk-action-toolbar)  
3. High-volume recruiting strategies: How to scale hiring without compromise | Metaview Blog, truy cập vào tháng 2 10, 2026, [https://www.metaview.ai/resources/blog/high-volume-recruiting-strategies](https://www.metaview.ai/resources/blog/high-volume-recruiting-strategies)  
4. Mastering Retail Recruitment: Unveiling the Top Strategies for ..., truy cập vào tháng 2 10, 2026, [https://www.phenom.com/blog/retail-recruitment-guide](https://www.phenom.com/blog/retail-recruitment-guide)  
5. Comparative analysis of the brand strategy of Big4 in electronics supermarkets in Vietnam, truy cập vào tháng 2 10, 2026, [https://www.researchgate.net/publication/373874924\_Comparative\_analysis\_of\_the\_brand\_strategy\_of\_Big4\_in\_electronics\_supermarkets\_in\_Vietnam](https://www.researchgate.net/publication/373874924_Comparative_analysis_of_the_brand_strategy_of_Big4_in_electronics_supermarkets_in_Vietnam)  
6. Mass Recruitment Campaign \- Vietnam Manpower, truy cập vào tháng 2 10, 2026, [http://vnmanpower.com/en/mass-recruitment-campaign-bl275.html](http://vnmanpower.com/en/mass-recruitment-campaign-bl275.html)  
7. Quy trình tuyển dụng Thegioididong trong thời đại 4.0 như thế nào? \- MISA AMIS, truy cập vào tháng 2 10, 2026, [https://amis.misa.vn/85083/quy-trinh-tuyen-dung-thegioididong-trong-thoi-dai-4-0-nhu-the-nao/](https://amis.misa.vn/85083/quy-trinh-tuyen-dung-thegioididong-trong-thoi-dai-4-0-nhu-the-nao/)  
8. What is Mass Recruitment and Why is It Crucial for Scaling Businesses? \- Talentnet Group, truy cập vào tháng 2 10, 2026, [https://www.talentnetgroup.com/vn/featured-insights/hr-operations/what-is-mass-recruitment-why-it-important](https://www.talentnetgroup.com/vn/featured-insights/hr-operations/what-is-mass-recruitment-why-it-important)  
9. Customer service culture at Coop Mart retail chain in Vietnam \- ResearchGate, truy cập vào tháng 2 10, 2026, [https://www.researchgate.net/publication/354522819\_Customer\_service\_culture\_at\_Coop\_Mart\_retail\_chain\_in\_Vietnam](https://www.researchgate.net/publication/354522819_Customer_service_culture_at_Coop_Mart_retail_chain_in_Vietnam)  
10. Using an In-store Kiosk for Job Application | EmploymentCrossing.com, truy cập vào tháng 2 10, 2026, [https://www.employmentcrossing.com/article/231670/Using-an-In-store-Kiosk-for-Job-Application/](https://www.employmentcrossing.com/article/231670/Using-an-In-store-Kiosk-for-Job-Application/)  
11. Kiosk Software Development: Practical Insights and Lessons Learnt \- Leobit, truy cập vào tháng 2 10, 2026, [https://leobit.com/blog/kiosk-software-development/](https://leobit.com/blog/kiosk-software-development/)  
12. 5 Key Features to Look for in Online Question Bank Software for Better Exam Management, truy cập vào tháng 2 10, 2026, [https://synap.ac/blog/5-features-to-look-for-in-online-question-bank-software](https://synap.ac/blog/5-features-to-look-for-in-online-question-bank-software)  
13. Create Smart, Secure Tests with Randomized Question Bank Quizzes \- AutoProctor, truy cập vào tháng 2 10, 2026, [https://www.autoproctor.co/features/randomize-questions-with-question-banks/](https://www.autoproctor.co/features/randomize-questions-with-question-banks/)  
14. In-Person Job Fair \- Host Interactive Onsite Job Fairs \- vFairs.com, truy cập vào tháng 2 10, 2026, [https://www.vfairs.com/event-management-platform/in-person-job-fair/](https://www.vfairs.com/event-management-platform/in-person-job-fair/)  
15. Event Check-In & Badge Printing | On-Demand & Efficient \- vFairs.com, truy cập vào tháng 2 10, 2026, [https://www.vfairs.com/event-management-platform/event-check-in-and-badge-printing/](https://www.vfairs.com/event-management-platform/event-check-in-and-badge-printing/)  
16. Designing Confirmation by Andrew Coyle, truy cập vào tháng 2 10, 2026, [https://www.andrewcoyle.com/blog/designing-confirmation](https://www.andrewcoyle.com/blog/designing-confirmation)  
17. Applicant Tracking System: The Right Tool to Track KPI \- MokaHR, truy cập vào tháng 2 10, 2026, [https://www.mokahr.io/myblog/applicant-tracking-system-track-kpi/](https://www.mokahr.io/myblog/applicant-tracking-system-track-kpi/)  
18. 15 Key Metrics for High-Volume Recruitment Success \- Talkpush, truy cập vào tháng 2 10, 2026, [https://www.talkpush.com/post/15-metrics-you-should-consider-for-high-volume-recruitment](https://www.talkpush.com/post/15-metrics-you-should-consider-for-high-volume-recruitment)  
19. ATS for High Volume Hiring: Streamline Your Recruitment in 2025-2026, truy cập vào tháng 2 10, 2026, [https://pitchnhire.com/blog/ats-high-volume-hiring-recruitment-company-2026](https://pitchnhire.com/blog/ats-high-volume-hiring-recruitment-company-2026)