# **BÁO CÁO NGHIÊN CỨU CHIẾN LƯỢC: KIẾN TRÚC VÀ ĐẶC TẢ CHỨC NĂNG HỆ THỐNG TUYỂN DỤNG TẬP TRUNG SỰ KIỆN (EVENT-CENTRIC RECRUITMENT \- ECR)**

## **TÓM TẮT ĐIỀU HÀNH**

Trong bối cảnh thị trường nhân sự toàn cầu đang chuyển dịch mạnh mẽ từ các hình thức tuyển dụng thụ động sang các chiến dịch chủ động quy mô lớn, các hệ thống Quản lý Tuyển dụng (ATS) truyền thống đang bộc lộ những hạn chế nghiêm trọng về khả năng mở rộng và tính linh hoạt. Báo cáo này trình bày một nghiên cứu chuyên sâu về mô hình "Tuyển dụng Tập trung Sự kiện" (Event-Centric Recruitment \- ECR), được thiết kế đặc biệt để giải quyết các thách thức của tuyển dụng khối lượng lớn (High-Volume Hiring) như các chương trình Fresher, Management Trainee, và Job Fair.

Nghiên cứu này được tổng hợp từ việc phân tích kỹ lưỡng các tài liệu nghiệp vụ nội bộ 1 và đối chiếu với các tiêu chuẩn công nghệ hàng đầu thế giới từ các nền tảng như Avature, Yello, HackerRank và Cvent.2 Trọng tâm của báo cáo xoay quanh ba trụ cột công nghệ chính:

1. **Quản lý Sự kiện (Event Creation & Management):** Chuyển đổi từ mô hình quản lý dựa trên yêu cầu tuyển dụng (Job-centric) sang mô hình lấy sự kiện làm trung tâm (Event-centric), cho phép quản lý đa luồng (multi-track), cấu hình bộ câu hỏi động (dynamic questionnaires) và quy trình xét duyệt linh hoạt.  
2. **Thu thập Ứng viên Tại chỗ (Onsite Capture & Kiosk):** Ứng dụng công nghệ Kiosk, mã QR và OCR để số hóa tức thì quy trình check-in và thu thập dữ liệu ứng viên vãng lai (walk-ins), giải quyết bài toán nút thắt cổ chai tại các sự kiện vật lý.  
3. **Hệ thống Đánh giá Trực tuyến (Online Assessment System):** Xây dựng ngân hàng câu hỏi thông minh với khả năng sinh đề ngẫu nhiên theo ma trận (blueprinting), tích hợp các giải pháp chống gian lận (proctoring) đa lớp để đảm bảo tính toàn vẹn của kết quả đánh giá trên quy mô lớn.

Báo cáo cũng đi sâu vào các cơ chế vận hành tự động hóa như logic hàng chờ (waitlist logic), lập lịch phỏng vấn thông minh (smart scheduling), và các chiến lược quản lý dữ liệu để đảm bảo tính chính xác và nhất quán trong suốt vòng đời tuyển dụng.

## ---

**PHẦN 1: TƯ DUY CHIẾN LƯỢC VÀ KIẾN TRÚC HỆ THỐNG ECR**

### **1.1. Sự Chuyển Dịch Từ Request-Centric Sang Event-Centric**

Mô hình ATS truyền thống được xây dựng xung quanh thực thể cốt lõi là "Job Requisition" (Yêu cầu tuyển dụng). Trong mô hình này, mỗi vị trí tuyển dụng là một silo dữ liệu riêng biệt, với quy trình, ứng viên và báo cáo độc lập. Tuy nhiên, khi áp dụng vào các chiến dịch tuyển dụng quy mô lớn như "Fresher 2026" \- nơi mục tiêu là tuyển dụng hàng trăm nhân sự cho nhiều phòng ban khác nhau trong cùng một khoảng thời gian \- mô hình Job-centric trở nên cồng kềnh và thiếu hiệu quả.2

Hệ thống ECR đề xuất một kiến trúc đảo ngược, đặt "Sự kiện" (Event) làm thực thể quản lý trung tâm. Một sự kiện không chỉ đơn thuần là một hoạt động marketing, mà là một "container" quản lý chứa đựng nhiều luồng tuyển dụng (Tracks) và liên kết với nhiều yêu cầu tuyển dụng (Requests) khác nhau.1

**Các đặc điểm kiến trúc cốt lõi của ECR:**

* **Tính Đa Chiều (Multidimensionality):** Một sự kiện đơn lẻ có thể phục vụ nhiều mục tiêu tuyển dụng (ví dụ: vừa tuyển Developer, vừa tuyển Designer) thông qua cơ chế "Tracks".1 Mỗi Track hoạt động như một phân đoạn của đường ống (pipeline segment) với các quy tắc sàng lọc riêng biệt nhưng chia sẻ chung hạ tầng vận hành (địa điểm, thời gian, nguồn lực).  
* **Ánh Xạ Động (Dynamic Mapping):** Hệ thống cho phép ánh xạ linh hoạt giữa Sự kiện và các Yêu cầu Tuyển dụng (Requests). Theo phân tích nghiệp vụ nội bộ, một Sự kiện chỉ được phép ánh xạ với các Request loại "Fresher" đã được phê duyệt nhưng chưa đăng tuyển (Post Job).1 Điều này tạo ra một lớp bảo vệ logic, ngăn chặn việc một vị trí vừa được tuyển qua kênh Job Board truyền thống vừa được tuyển qua Sự kiện, gây xung đột nguồn ứng viên.  
* **Vòng Đời Sự Kiện Mở Rộng:** Khác với một Job Posting có ngày đóng/mở đơn giản, một Sự kiện trong ECR quản lý một vòng đời phức tạp hơn, bao gồm các giai đoạn "Master Event" (trước và sau sự kiện) 1, cho phép nuôi dưỡng nguồn ứng viên (Talent Pool) dài hạn ngay cả khi sự kiện đã kết thúc.3

### **1.2. Cấu Trúc Dữ Liệu "Tracks" và Bộ Câu Hỏi Động (Dynamic Question Sets)**

Một trong những thách thức lớn nhất của tuyển dụng tập trung là cân bằng giữa sự đơn giản trong trải nghiệm ứng viên và sự chi tiết trong dữ liệu thu thập. Nếu sử dụng một bộ câu hỏi chung cho tất cả ứng viên, dữ liệu thu được sẽ quá chung chung hoặc quá dài dòng. Giải pháp kiến trúc của ECR là sử dụng "Bộ câu hỏi động theo Track" (Track-Specific Dynamic Question Sets).

#### **Cơ Chế Hoạt Động**

Trong quá trình tạo sự kiện, Talent Acquisition (TA) định nghĩa các "Tracks" (Hướng chuyên môn). Mỗi Track tương ứng với một hoặc một nhóm Request ID.1 Thay vì gán câu hỏi cho Sự kiện, hệ thống gán câu hỏi cho từng Track.

* **Tại Giao diện Ứng viên (Candidate Experience):** Khi ứng viên truy cập trang đăng ký sự kiện, họ được yêu cầu chọn Track quan tâm (ví dụ: "Game Development" hoặc "Game Design"). Ngay lập tức, hệ thống sẽ render (hiển thị) bộ câu hỏi tương ứng với Track đó.1 Ví dụ, Track "Game Dev" sẽ hiển thị các câu hỏi về ngôn ngữ lập trình (C++, C\#), trong khi Track "Game Design" sẽ yêu cầu link Portfolio và kỹ năng đồ họa. Cơ chế này đảm bảo ứng viên chỉ phải cung cấp thông tin liên quan, giảm tỷ lệ bỏ dở (drop-off rate) trong quá trình đăng ký.  
* **Tại Giao diện Quản lý (Recruiter View):** Việc hiển thị dữ liệu từ nhiều bộ câu hỏi khác nhau trên cùng một bảng danh sách (Grid View) là một bài toán khó về UI/UX. Hệ thống ECR giải quyết bằng cơ chế "Hiển thị theo Ngữ cảnh" (Contextual Visibility).1 Mặc định, các cột câu hỏi chuyên môn được ẩn đi để giữ giao diện gọn gàng. Khi TA sử dụng bộ lọc (Filter) để xem danh sách ứng viên thuộc Track cụ thể, hệ thống tự động hiển thị các cột dữ liệu tương ứng với bộ câu hỏi của Track đó.

#### **Tác Động Đến Cấu Trúc Báo Cáo**

Việc sử dụng câu hỏi động đặt ra thách thức cho việc chuẩn hóa báo cáo. Theo phân tích nghiệp vụ 1, báo cáo cần hỗ trợ xuất dữ liệu bao gồm cả các trường thông tin chuẩn (Standard Fields) và các câu hỏi động. Để đảm bảo tính nhất quán, hệ thống yêu cầu TA phải xác nhận bộ câu hỏi (Lock Question Set) trước khi tạo Request hoặc xuất báo cáo cố định. Dữ liệu báo cáo sẽ được cấu trúc theo chiều ngang, với các cột động được thêm vào dựa trên Track của ứng viên.

### **1.3. Chiến Lược Kiểm Soát Dữ Liệu: Duplicate Check và Data Integrity**

Trong tuyển dụng khối lượng lớn, rủi ro về "rác dữ liệu" (data pollution) là cực kỳ cao. Ứng viên có thể nộp đơn nhiều lần, sử dụng nhiều email khác nhau, hoặc tham gia cả online và offline. ECR cần một chiến lược kiểm soát trùng lặp (Duplicate Check) tinh vi hơn so với các hệ thống thông thường.

#### **Logic Định Danh Đa Yếu Tố (Multi-factor Identification)**

Thay vì chỉ dựa vào Email (vốn dễ thay đổi), hệ thống ECR sử dụng cặp khóa định danh chính là **Số điện thoại (SĐT)** và **Mã sinh viên (Student ID)**.1 Đối với đối tượng Fresher/Sinh viên, Mã sinh viên là một định danh duy nhất và ổn định gắn liền với hồ sơ học vấn, trong khi Số điện thoại là kênh liên lạc chính xác thực nhất.

#### **Quy Trình Xử Lý Xung Đột (Conflict Resolution Workflow)**

Hệ thống không được phép tự động xóa bỏ các bản ghi trùng lặp một cách mù quáng ("Black box"), vì điều này có thể dẫn đến mất mát dữ liệu lịch sử quan trọng. Thay vào đó, ECR áp dụng quy trình "Cảnh báo và Quyết định" (Alert & Decision Support):

1. **Detection & Highlighting:** Khi phát hiện một ứng viên mới có SĐT hoặc Student ID trùng với dữ liệu hiện có, hệ thống sẽ đánh dấu (highlight) hồ sơ này trong danh sách chờ duyệt.1  
2. **Intelligent Suggestion:** Hệ thống phân tích mức độ trùng khớp và đề xuất hành động:  
   * *Match 100% (SĐT \+ Student ID):* Đề xuất **Remove** bản ghi mới (coi là spam hoặc submit lỗi).  
   * *Match Partial (Chỉ SĐT hoặc chỉ Student ID):* Đề xuất **Replace Data** hoặc **Merge**. Điều này xử lý các trường hợp ứng viên nhập sai mã sinh viên hoặc cập nhật số điện thoại mới.1  
3. **Audit Trail:** Một khu vực riêng biệt ("Duplicate Tab") được duy trì để lưu trữ tạm thời các bản ghi trùng lặp, cho phép TA rà soát lại (audit) trước khi thực hiện hành động xóa vĩnh viễn, đảm bảo tính toàn vẹn của dữ liệu.1

## ---

**PHẦN 2: CÔNG NGHỆ THU THẬP ỨNG VIÊN TẠI CHỖ (ONSITE CAPTURE & KIOSK MODE)**

Sự thành công của một sự kiện tuyển dụng offline phụ thuộc rất lớn vào khả năng xử lý dòng người (flow management) và tốc độ thu thập dữ liệu. Các phương pháp thủ công như thu CV giấy hay điền form trên giấy không còn phù hợp. ECR triển khai một hệ sinh thái công nghệ tại chỗ (Onsite Tech Ecosystem) để giải quyết vấn đề này.

### **2.1. Chế Độ Kiosk và Quy Trình Check-in Không Chạm (Contactless & Self-Service)**

Học hỏi từ các giải pháp quản lý sự kiện hàng đầu như Yello và Cvent 7, ECR triển khai chế độ Kiosk Mode cho phép biến các thiết bị thông thường (iPad, Laptop) thành các trạm check-in tự phục vụ.

#### **Quy trình Check-in bằng QR Code**

Đây là quy trình tối ưu cho các ứng viên đã đăng ký trước (Pre-registered Candidates).

* **Cơ chế:** Trước sự kiện, hệ thống gửi email xác nhận chứa một mã QR duy nhất (Unique QR Code) cho mỗi ứng viên. Mã này chứa thông tin định danh được mã hóa (Candidate ID/SBD).7  
* **Tại sự kiện:** Ứng viên sử dụng điện thoại cá nhân để quét mã này tại trạm Kiosk hoặc đưa mã cho nhân viên TA quét.  
* **Hiệu quả:** Thời gian check-in giảm xuống dưới 5 giây/người. Hệ thống ghi nhận trạng thái "Attended" (Đã tham dự) ngay lập tức và kích hoạt các luồng công việc tiếp theo (ví dụ: gửi tin nhắn chào mừng, kích hoạt bài test online).1

#### **Quy trình Đăng ký Vãng lai (Walk-in Registration)**

Đối với ứng viên chưa đăng ký trước, Kiosk cung cấp một quy trình "Lite Registration" để tránh ùn tắc.

* **Lite Form:** Thay vì yêu cầu điền toàn bộ hồ sơ (vốn mất 10-15 phút), Kiosk chỉ yêu cầu các thông tin tối thiểu: Họ tên, SĐT, Email, và Track quan tâm.9  
* **Post-Event Enrichment:** Sau khi đăng ký nhanh, hệ thống tự động gửi một email chứa liên kết "Hoàn thiện hồ sơ" (Complete Profile) để ứng viên có thể upload CV và bổ sung thông tin chi tiết sau khi rời quầy check-in. Điều này giúp tối ưu hóa lưu lượng người tại cửa vào.9

#### **Khả Năng Hoạt Động Offline (Offline Mode Capabilities)**

Một yêu cầu phi chức năng (Non-functional Requirement) quan trọng cho Kiosk là khả năng hoạt động trong môi trường mạng không ổn định – điều thường thấy tại các hội trường lớn hoặc khuôn viên trường đại học.10

* **Local Storage & Sync:** Kiosk App phải có khả năng lưu trữ dữ liệu đăng ký cục bộ (Local Database). Khi có kết nối internet trở lại, hệ thống sẽ thực hiện cơ chế đồng bộ hóa (Background Sync) lên máy chủ trung tâm.11  
* **Conflict Resolution:** Trong trường hợp đồng bộ chậm, hệ thống sử dụng Timestamp để giải quyết các xung đột dữ liệu (ví dụ: ứng viên check-in tại hai cửa khác nhau).

### **2.2. Số Hóa Hồ Sơ Với Công Nghệ OCR (Optical Character Recognition)**

Mặc dù hướng tới "Paperless", thực tế các sự kiện vẫn nhận được lượng lớn CV giấy. ECR tích hợp module OCR để xử lý luồng dữ liệu vật lý này.

* **Mobile Capture:** Nhân viên TA sử dụng ứng dụng di động của hệ thống để chụp ảnh CV ứng viên ngay tại bàn phỏng vấn hoặc quầy thu hồ sơ.1  
* **Parsing & Extraction:** Công nghệ OCR (tương tự như giải pháp của Talentera hay Google Vision API) sẽ phân tích hình ảnh, nhận diện văn bản và trích xuất các trường thông tin quan trọng (Tên, Email, Kỹ năng, Học vấn) để điền tự động vào hồ sơ ứng viên trên hệ thống.13  
* **Automated Standardization:** Hệ thống tự động đổi tên file ảnh scan theo quy tắc Full Name \_ CV 1 và gắn thẻ (tag) hồ sơ với Sự kiện và Track tương ứng. Điều này đảm bảo rằng ngay cả hồ sơ giấy cũng có thể tìm kiếm và truy xuất được (searchable & retrievable) như hồ sơ số.

### **2.3. Tạo và Quản lý Số Báo Danh (SBD Generation Logic)**

Trong các kỳ thi tuyển dụng tập trung, Số báo danh (SBD) là định danh quan trọng nhất để liên kết ứng viên với bài thi và kết quả phỏng vấn.

* **Trigger Linh Hoạt:** Hệ thống hiện tại tạo SBD khi gửi email mời. Tuy nhiên, để xử lý các trường hợp Walk-in hoặc lỗi gửi mail, ECR cần hỗ trợ tính năng **"On-demand SBD Generation"**.1 TA có thể tạo SBD cho một hoặc một nhóm ứng viên bất cứ lúc nào từ giao diện quản lý.  
* **Consistency Logic:** Một quy tắc nghiệp vụ quan trọng là tính nhất quán của SBD qua các vòng.1 SBD được cấp tại vòng Check-in phải được giữ nguyên tại vòng Test và Phỏng vấn để đảm bảo tính liên tục của dữ liệu. Nếu ứng viên được đặc cách bỏ qua vòng Check-in (ví dụ: phỏng vấn online), hệ thống phải có logic tự động sinh SBD mới ngay khi ứng viên được chuyển sang trạng thái "Invited to Interview".1

## ---

**PHẦN 3: HỆ THỐNG ĐÁNH GIÁ TRỰC TUYẾN (ONLINE ASSESSMENT SYSTEM)**

Hệ thống đánh giá là bộ lọc chất lượng quan trọng nhất trong quy trình ECR. Để thay thế các bài kiểm tra giấy truyền thống và các nền tảng rời rạc, ECR tích hợp một module Assessment toàn diện, hỗ trợ đa dạng các loại hình đánh giá từ trắc nghiệm, lập trình (coding) đến tự luận (essay).

### **3.1. Quản lý Ngân hàng Câu hỏi (Question Bank Management)**

Xây dựng một ngân hàng câu hỏi chất lượng cao là nền tảng cho sự công bằng và chính xác trong đánh giá.

#### **Cấu Trúc Dữ Liệu Đa Chiều (Metadata & Taxonomy)**

Mỗi câu hỏi (Item) trong ngân hàng được quản lý như một đối tượng dữ liệu độc lập với hệ thống thẻ (Tagging) phong phú 14:

* **Topic/Domain:** Chủ đề kiến thức (ví dụ: Java, Python, Logical Reasoning, English).  
* **Difficulty Level:** Mức độ khó (Dễ, Trung bình, Khó) dựa trên độ phức tạp nhận thức (Bloom's Taxonomy).16  
* **Question Type:** Loại câu hỏi (MCQ, Multi-select, Coding, File Upload, Video Response).  
* **Performance Metrics:** Các chỉ số lịch sử như độ khó thực tế (dựa trên tỷ lệ trả lời đúng của các ứng viên trước), độ phân biệt (discrimination index).17

#### **Logic Sinh Đề Thi (Blueprinting & Randomization)**

Để ngăn chặn gian lận (đặc biệt là việc lộ đề), hệ thống sử dụng thuật toán "Blueprinting" (Ma trận đề thi) thay vì các đề thi cố định (Fixed Forms).16

* **Blueprint Definition:** TA định nghĩa cấu trúc của bài thi, ví dụ: "Bài thi Java gồm 10 câu Dễ, 5 câu Trung bình, 2 câu Khó; 30% Lý thuyết, 70% Thực hành".  
* **Dynamic Generation:** Khi ứng viên bắt đầu làm bài, hệ thống sẽ rút ngẫu nhiên các câu hỏi từ ngân hàng thỏa mãn các điều kiện trong Blueprint. Kết quả là mỗi ứng viên nhận được một đề thi duy nhất (Unique Test Instance) nhưng vẫn đảm bảo độ khó và phạm vi kiến thức tương đương nhau (Psychometric Equivalence).19

### **3.2. Các Chế Độ Thi và Nộp Bài (Assessment Modes)**

Hệ thống hỗ trợ linh hoạt các phương thức thi để phù hợp với từng Track:

#### **Online Test (Trắc nghiệm & Coding)**

* **Cơ chế:** Ứng viên làm bài trực tiếp trên trình duyệt. Hệ thống tự động chấm điểm (Auto-grading) dựa trên đáp án đúng hoặc test cases (đối với bài code).1  
* **Kết quả:** Trả về trạng thái Pass/Fail ngay lập tức dựa trên ngưỡng điểm (Cut-off score) được cấu hình trước.

#### **Assignment Submission (Bài tập lớn/Portfolio)**

Dành cho các vị trí sáng tạo (Design, Marketing) yêu cầu nộp sản phẩm.

* **Cấu hình:** TA thiết lập đề bài, file đính kèm, hạn nộp và người chấm.1  
* **File Handling:** Hệ thống hỗ trợ upload file dung lượng lớn. Nếu nộp 1 file, hệ thống hỗ trợ Preview trực tiếp (PDF, Image). Nếu nộp nhiều file, hệ thống yêu cầu nén Zip.1 Quy tắc đặt tên file tự động Full Name – Submit Đề được áp dụng để tránh thất lạc.  
* **Grading Workflow:** Người chấm (Hiring Manager) nhận thông báo, truy cập hệ thống để xem bài làm và nhập điểm/nhận xét. Hệ thống hỗ trợ nhắc nhở (Reminder) tự động cho cả ứng viên (nhắc nộp bài) và người chấm (nhắc chấm bài).1

### **3.3. Bảo Mật và Chống Gian Lận (Proctoring & Integrity Stack)**

Trong bối cảnh thi trực tuyến, đặc biệt là với các bài thi kỹ thuật, nguy cơ gian lận là rất cao. ECR tích hợp các lớp bảo mật (Integrity Stack) học hỏi từ HackerRank và TestGorilla.4

* **Browser Lockdown:** Ngăn chặn ứng viên mở tab mới, copy/paste, hoặc sử dụng các phím tắt hệ thống trong quá trình làm bài.23  
* **Tab Switching Detection:** Ghi nhận và cảnh báo nếu ứng viên rời khỏi màn hình thi. Nếu vi phạm quá số lần quy định, bài thi có thể bị tự động nộp hoặc hủy bỏ.22  
* **Plagiarism Detection:** Đối với bài thi Code, hệ thống so sánh mã nguồn của ứng viên với cơ sở dữ liệu nội bộ và các kho mã nguồn công khai (GitHub, StackOverflow) để phát hiện sao chép. Các thuật toán như MOSS (Measure Of Software Similarity) được sử dụng để phát hiện sự tương đồng về cấu trúc logic ngay cả khi tên biến bị thay đổi.4  
* **Image Proctoring:** Chụp ảnh ngẫu nhiên qua webcam trong quá trình thi để xác minh danh tính người làm bài và phát hiện sự hiện diện của người lạ.21

## ---

**PHẦN 4: TỰ ĐỘNG HÓA QUY TRÌNH VÀ LẬP LỊCH (WORKFLOW AUTOMATION & SCHEDULING)**

Quản lý hàng nghìn ứng viên qua các vòng tuyển dụng đòi hỏi mức độ tự động hóa cao để giảm tải cho con người và loại bỏ sai sót.

### **4.1. Logic Hàng Chờ Thông Minh (Smart Waitlist Logic)**

Một trong những tính năng đột phá của ECR là cơ chế xử lý yêu cầu đổi lịch (Reschedule) thông qua "Hàng chờ" (Waitlist) tự động.1

* **Vấn đề:** Trong các hệ thống cũ, khi ứng viên xin đổi lịch, TA phải thủ công kiểm tra các slot trống, gọi điện xác nhận và cập nhật lại lịch. Với 1.000 ứng viên, quy trình này tiêu tốn hàng trăm giờ công.  
* **Giải pháp Waitlist Tự động:**  
  1. **Queueing:** Khi ứng viên yêu cầu đổi lịch nhưng không còn slot trống phù hợp, họ được đưa vào danh sách Waitlist.  
  2. **Monitoring & Auto-Fill:** Hệ thống liên tục giám sát trạng thái các slot. Ngay khi có một slot bị hủy (do ứng viên khác từ chối hoặc hủy lịch), hệ thống tự động quét Waitlist.  
  3. **Priority Allocation:** Dựa trên quy tắc ưu tiên (FIFO \- First In First Out hoặc mức độ ưu tiên của ứng viên), hệ thống tự động gán slot trống cho ứng viên trong Waitlist.  
  4. **Instant Notification:** Hệ thống tự động gửi email thông báo: *"Đã tìm thấy lịch phỏng vấn phù hợp vào lúc. Vui lòng xác nhận..."*.1  
* **Manual Intervention:** Trong trường hợp đặc biệt (ví dụ: chỉ có 1 ca phỏng vấn duy nhất), TA có thể can thiệp thủ công để "Resend Invitation". Lúc này, hệ thống sẽ khóa quyền "Đổi lịch" của ứng viên, chỉ cho phép "Accept" hoặc "Reject" để chốt danh sách cuối cùng.1

### **4.2. Quản lý Ca và Lập Lịch Phỏng Vấn (Shift & Capacity Management)**

Hệ thống hỗ trợ lập kế hoạch công suất (Capacity Planning) chi tiết cho các ngày hội tuyển dụng.

* **Shift Structure:** Sự kiện được chia thành các Ca (Shifts) cố định (Sáng/Chiều, hoặc theo khung giờ 2 tiếng).1  
* **Capacity Constraints:** TA thiết lập giới hạn tối đa (Max Capacity) cho mỗi ca dựa trên số lượng phòng và hội đồng phỏng vấn (ví dụ: 166 ứng viên/ca). Khi đạt giới hạn, ca sẽ tự động đóng đăng ký.  
* **Auto-Distribution Algorithm:** Dựa trên số lượng ứng viên Pass vòng trước, hệ thống tự động phân bổ đều họ vào các ca còn trống. Thuật toán cân bằng tải (Load Balancing) đảm bảo không có ca nào quá tải trong khi ca khác lại vắng.1  
* **Quy tắc "1 Council \- 1 Candidate":** Hệ thống tuân thủ quy tắc nghiệp vụ nghiêm ngặt trong lập lịch chi tiết: Tại một thời điểm cụ thể (Time Slot), một Hội đồng chỉ được gán cho một Ứng viên. Hệ thống tự động kiểm tra tính khả dụng (Availability) của cả hai phía để tránh xung đột (Double-booking).1

### **4.3. Tự Động Hóa Giao Tiếp (Communication Automation)**

* **Trigger-based Emails:** Hệ thống gửi email tự động dựa trên các sự kiện (Triggers): Mời test, Nhắc lịch (Reminder), Thông báo kết quả, Cảm ơn (Thank you letter).  
* **Bulk Actions with Safety Net:** Khi TA gửi thư hàng loạt (ví dụ: Mời phỏng vấn cho 50 người), hệ thống kích hoạt cơ chế bảo vệ hai lớp (Confirmation Modal). Nó tự động quét danh sách, phát hiện và loại bỏ các ứng viên không đủ điều kiện (trạng thái Fail/Rejected) khỏi danh sách gửi, sau đó hiển thị báo cáo: "Ready to Send (45)" và "Skipped (5)". Điều này ngăn chặn tai nạn gửi nhầm thư mời cho người đã rớt.1  
* **Stage-Specific Templates:** Hệ thống tự động chọn template email phù hợp với giai đoạn hiện tại của ứng viên (ví dụ: Thư cảm ơn cho vòng Hồ sơ sẽ khác với Thư cảm ơn cho vòng Phỏng vấn).1

## ---

**PHẦN 5: TRẢI NGHIỆM ỨNG VIÊN VÀ GAMIFICATION**

Trong thị trường nhân sự lấy ứng viên làm trung tâm, trải nghiệm (Candidate Experience) là yếu tố then chốt. ECR tích hợp các yếu tố Gamification để tăng tương tác.

### **5.1. Gamification và Lucky Draw**

Để giữ chân ứng viên tại sự kiện và khuyến khích họ hoàn thành các bước check-in/test, hệ thống tích hợp module Gamification.1

* **Cơ chế:** Ứng viên hoàn thành các "nhiệm vụ" (Check-in, Nộp CV, Làm bài Test nhanh) để tích điểm hoặc nhận vé tham gia quay số trúng thưởng (Lucky Draw).  
* **Digital Lucky Draw:** Hệ thống thực hiện quay số ngẫu nhiên dựa trên danh sách ứng viên đã check-in (Attended), hiển thị kết quả trực quan trên màn hình lớn tại sự kiện để tạo không khí sôi động.  
* **Gift Management:** Quản lý kho quà tặng, ghi nhận trạng thái đã trao quà để tránh gian lận.

### **5.2. Khảo Sát và Phản Hồi (Feedback Loop)**

* **NPS & CSAT:** Sau mỗi vòng hoặc sau sự kiện, hệ thống tự động gửi khảo sát ngắn (Candidate Experience Survey) để đo chỉ số NPS (Net Promoter Score).27  
* **Actionable Insights:** Dữ liệu phản hồi được tổng hợp thành báo cáo thời gian thực, giúp ban tổ chức điều chỉnh quy trình ngay trong khi sự kiện đang diễn ra (ví dụ: điều phối thêm nhân sự nếu khu vực check-in bị phàn nàn là quá chậm).

## ---

**PHẦN 6: BÁO CÁO VÀ PHÂN TÍCH DỮ LIỆU (REPORTING & ANALYTICS)**

### **6.1. Báo Cáo Động (Dynamic Reporting)**

Do cấu trúc dữ liệu của ECR thay đổi theo Event và Track, hệ thống báo cáo cũng phải linh hoạt tương ứng.

* **Dynamic Columns:** Báo cáo cho phép hiển thị/ẩn các cột dữ liệu câu hỏi tùy theo ngữ cảnh. Khi xuất báo cáo tổng hợp, hệ thống có thể bao gồm tất cả các câu hỏi của mọi Track, hoặc chỉ xuất dữ liệu của một Track cụ thể để gửi cho Hiring Manager chuyên môn.1  
* **Fixed Report Templates:** Đối với các sự kiện định kỳ (như Fresher hàng năm), TA có thể "chốt" (confirm) một bộ câu hỏi chuẩn để tạo ra các mẫu báo cáo cố định, giúp so sánh dữ liệu qua các năm (Year-over-Year Analysis).1

### **6.2. Phân Tích Hiệu Quả Tuyển Dụng (Recruitment Metrics)**

Hệ thống cung cấp Dashboard theo dõi các chỉ số quan trọng 28:

* **Funnel Efficiency:** Tỷ lệ chuyển đổi qua từng phễu (Applied \-\> Checked-in \-\> Test Pass \-\> Interview \-\> Offer). Giúp nhận diện điểm gãy (drop-off points) của quy trình.  
* **Time to Hire:** Thời gian trung bình từ lúc ứng viên Apply đến khi nhận Offer.  
* **Sourcing Channel Effectiveness:** Hiệu quả của từng kênh nguồn (Social, Referral, Job Board) dựa trên số lượng và chất lượng ứng viên thu được tại sự kiện.  
* **Event ROI:** Tính toán chi phí trên mỗi lượt tuyển (Cost per Hire) cho từng sự kiện cụ thể.

## ---

**KẾT LUẬN VÀ KHUYẾN NGHỊ**

Hệ thống Tuyển dụng Tập trung Sự kiện (ECR) không chỉ là một bản nâng cấp của ATS mà là một sự thay đổi mô hình (paradigm shift) trong công nghệ tuyển dụng. Bằng cách kết hợp khả năng quản lý sự kiện linh hoạt, công nghệ thu thập dữ liệu tại chỗ mạnh mẽ (Kiosk, OCR), và hệ thống đánh giá trực tuyến bảo mật, ECR cung cấp lời giải toàn diện cho bài toán tuyển dụng số lượng lớn.

**Các khuyến nghị triển khai:**

1. **Chiến lược Dữ liệu:** Ưu tiên xây dựng quy tắc định danh duy nhất (SĐT \+ StudentID) và quy trình xử lý trùng lặp ngay từ giai đoạn đầu để đảm bảo cơ sở dữ liệu sạch.  
2. **Đầu tư Hạ tầng Kiosk:** Triển khai đủ số lượng trạm Kiosk và nhân sự hỗ trợ QR Code tại sự kiện để đảm bảo trải nghiệm check-in mượt mà, vì đây là điểm chạm đầu tiên của ứng viên.  
3. **Tối ưu hóa "Blueprinting":** Đầu tư thời gian xây dựng ngân hàng câu hỏi phong phú và cấu trúc Blueprint hợp lý để tận dụng tối đa khả năng sinh đề ngẫu nhiên, đảm bảo công bằng và bảo mật.  
4. **Tự động hóa có Giám sát:** Tận dụng tối đa các tính năng tự động (Waitlist, Reminder) nhưng luôn duy trì các chốt kiểm soát (Confirmation Modal, Audit Tab) để con người có thể can thiệp khi cần thiết.

Việc áp dụng mô hình ECR sẽ giúp doanh nghiệp không chỉ tiết kiệm đáng kể nguồn lực vận hành mà còn nâng cao vị thế thương hiệu tuyển dụng, thu hút hiệu quả nguồn nhân lực chất lượng cao trong kỷ nguyên số.

### ---

**Bảng 1: So sánh Đặc tả Chức năng giữa ATS Truyền thống và Hệ thống ECR**

| Đặc tả Chức năng | ATS Truyền thống (Job-Centric) | Hệ thống ECR (Event-Centric) |
| :---- | :---- | :---- |
| **Đơn vị Quản lý Cốt lõi** | Yêu cầu Tuyển dụng (Job Requisition) | Sự kiện (Event) chứa nhiều Tracks/Requests |
| **Cấu trúc Dữ liệu** | Cố định theo Job Template | Động theo Track (Dynamic Question Sets) |
| **Quy trình Check-in** | Thủ công (Giấy tờ) hoặc không hỗ trợ | Kiosk Mode, QR Code, OCR, Offline Sync |
| **Lập lịch Phỏng vấn** | Ghép đôi thủ công (Manual pairing) | Phân bổ tự động (Auto-distribution), Hàng chờ thông minh (Smart Waitlist) |
| **Đánh giá Năng lực** | Tích hợp bên thứ 3 rời rạc | Tích hợp sâu (Built-in), Blueprinting, Proctoring đa lớp |
| **Xử lý Trùng lặp** | Chặn (Block) hoặc Gộp (Merge) tự động | Cảnh báo & Hỗ trợ ra quyết định (Alert & Decision Support) |
| **Trải nghiệm Ứng viên** | Điền form tuyến tính, thụ động | Tương tác qua Kiosk, Gamification, Phản hồi thời gian thực |

### **Bảng 2: Ma trận Logic Xử lý Hàng chờ (Waitlist Processing Logic)**

| Tình huống (Scenario) | Điều kiện Kích hoạt | Hành động của Hệ thống | Kết quả / Thông báo |
| :---- | :---- | :---- | :---- |
| **Yêu cầu Đổi lịch (Reschedule)** | Ứng viên chọn "Change Time" | Kiểm tra slot trống ở các ca khác. Nếu không có, đưa vào Waitlist. | Thông báo: "Bạn đã được đưa vào danh sách chờ. Chúng tôi sẽ thông báo khi có lịch trống." |
| **Xuất hiện Slot trống** | Ứng viên khác hủy/từ chối hoặc mở thêm ca | Quét Waitlist, chọn ứng viên có thời gian đăng ký sớm nhất (FIFO). | Tự động gán slot & Gửi email: "Đã tìm thấy lịch phỏng vấn phù hợp vào lúc. Vui lòng xác nhận." |
| **Hết hạn Xác nhận** | Quá deadline cấu hình | Khóa nút hành động (Disable Action buttons). | Hiển thị thông báo: "Hết thời gian xác nhận. Vui lòng liên hệ bộ phận tuyển dụng." |
| **Can thiệp Thủ công** | TA nhấn "Resend Invitation" | Gửi lại thư mời với lịch mới do TA sắp xếp. | Ứng viên nhận thư mới, chỉ còn tùy chọn "Accept" hoặc "Reject" (Mất quyền đổi lịch). |

#### **Nguồn trích dẫn**

1. ATS\_Flow Fresher (Sent) \_ Internal.xlsx  
2. The Applicant Tracking System (ATS) for High-Volume Hiring \- Pinpoint ATS, truy cập vào tháng 2 10, 2026, [https://www.pinpointhq.com/use-cases/ats-high-volume-hiring/](https://www.pinpointhq.com/use-cases/ats-high-volume-hiring/)  
3. Intelligent Automation for High-Volume Recruiting \- Avature, truy cập vào tháng 2 10, 2026, [https://www.avature.net/high-volume-recruiting/](https://www.avature.net/high-volume-recruiting/)  
4. HackerRank vs TestGorilla for technical screening: 2025 pricing & features, truy cập vào tháng 2 10, 2026, [https://www.hackerrank.com/writing/hackerrank-vs-testgorilla-technical-screening-2025-pricing-features](https://www.hackerrank.com/writing/hackerrank-vs-testgorilla-technical-screening-2025-pricing-features)  
5. Recruiting Events Management \- Avature, truy cập vào tháng 2 10, 2026, [https://www.avature.net/recruiting-events-management/](https://www.avature.net/recruiting-events-management/)  
6. Proctored testing: a necessary feature or an overused hype? \- Testportal, truy cập vào tháng 2 10, 2026, [https://www.testportal.com/en/guides/online-test-cheating/online-proctoring/](https://www.testportal.com/en/guides/online-test-cheating/online-proctoring/)  
7. New Feature: Keep Recruiters & Candidates Safe with Contactless Event Check-In \- Yello, truy cập vào tháng 2 10, 2026, [https://yello.co/blog/new-feature-keep-recruiters-candidates-safe-with-contactless-event-check-in/](https://yello.co/blog/new-feature-keep-recruiters-candidates-safe-with-contactless-event-check-in/)  
8. Cvent features, truy cập vào tháng 2 10, 2026, [https://www.cvent.com/en/event-management-software/features](https://www.cvent.com/en/event-management-software/features)  
9. Product Update: Virtual Candidate Registration Enhancements \- Yello, truy cập vào tháng 2 10, 2026, [https://yello.co/blog/product-update-virtual-candidate-registration-enhancements/](https://yello.co/blog/product-update-virtual-candidate-registration-enhancements/)  
10. Cvent LeadCapture \- Apps on Google Play, truy cập vào tháng 2 10, 2026, [https://play.google.com/store/apps/details?id=com.cvent.leadcap\&hl=en\_US](https://play.google.com/store/apps/details?id=com.cvent.leadcap&hl=en_US)  
11. Yello Pro \- App Store, truy cập vào tháng 2 10, 2026, [https://apps.apple.com/us/app/yello-pro/id1140964557](https://apps.apple.com/us/app/yello-pro/id1140964557)  
12. How QR Code and Offline Check-In Work in Handshake, truy cập vào tháng 2 10, 2026, [https://support.joinhandshake.com/hc/en-us/articles/34042581374231-How-QR-Code-and-Offline-Check-In-Work-in-Handshake](https://support.joinhandshake.com/hc/en-us/articles/34042581374231-How-QR-Code-and-Offline-Check-In-Work-in-Handshake)  
13. Parse Scanned CVs With Our OCR Technology \- Talentera, truy cập vào tháng 2 10, 2026, [https://www.talentera.com/en/blog/parse-scanned-cvs-ocr-technology/](https://www.talentera.com/en/blog/parse-scanned-cvs-ocr-technology/)  
14. 5 Key Features to Look for in Online Question Bank Software for Better Exam Management, truy cập vào tháng 2 10, 2026, [https://synap.ac/blog/5-features-to-look-for-in-online-question-bank-software](https://synap.ac/blog/5-features-to-look-for-in-online-question-bank-software)  
15. Crush Online Tests | Track, Score & Actually See Real Progress \- Groom LMS, truy cập vào tháng 2 10, 2026, [https://www.groomlms.com/features/online-test-and-management-system](https://www.groomlms.com/features/online-test-and-management-system)  
16. Question Bank Management | Online Skill Assessment | Online Exam Software | Eklavvya.com, truy cập vào tháng 2 10, 2026, [https://www.eklavvya.com/blog/category/question-bank-management-online-exam/feed/](https://www.eklavvya.com/blog/category/question-bank-management-online-exam/feed/)  
17. Item Analysis in Online Exams: Improve Question Quality & Reliability \- SpeedExam, truy cập vào tháng 2 10, 2026, [https://www.speedexam.net/blog/item-analysis-improve-exam-question-quality/](https://www.speedexam.net/blog/item-analysis-improve-exam-question-quality/)  
18. Online Question Bank Software – Empower Students with Self-Generated Practice Tests, truy cập vào tháng 2 10, 2026, [https://www.addmengroup.com/question-bank/online-question-bank-software.htm](https://www.addmengroup.com/question-bank/online-question-bank-software.htm)  
19. 3 Psychometric Methods for Secure Online Test Design and Development, truy cập vào tháng 2 10, 2026, [https://www.meazurelearning.com/resources/3-psychometric-methods-for-secure-online-test-design-and-development](https://www.meazurelearning.com/resources/3-psychometric-methods-for-secure-online-test-design-and-development)  
20. Online Examination System: The Definitive Guide to Digital Exams \- ExamOnline, truy cập vào tháng 2 10, 2026, [https://examonline.in/online-examination-system-complete-guide/](https://examonline.in/online-examination-system-complete-guide/)  
21. TestGorilla vs. HackerRank, truy cập vào tháng 2 10, 2026, [https://www.testgorilla.com/blog/testgorilla-vs-hackerrank/](https://www.testgorilla.com/blog/testgorilla-vs-hackerrank/)  
22. Proctor Mode vs. Secure Mode: How HackerRank Detects ChatGPT and Other AI Cheats in 2025, truy cập vào tháng 2 10, 2026, [https://www.hackerrank.com/writing/proctor-mode-vs-secure-mode-hackerrank-detects-chatgpt-ai-cheats-2025](https://www.hackerrank.com/writing/proctor-mode-vs-secure-mode-hackerrank-detects-chatgpt-ai-cheats-2025)  
23. TestGorilla vs. HackerRank vs. iMocha (Detailed Comparison) in 2025, truy cập vào tháng 2 10, 2026, [https://blog.imocha.io/testgorilla-vs-hackerrank](https://blog.imocha.io/testgorilla-vs-hackerrank)  
24. How Does Hackerrank Detect Cheating (& Tips to Pass Honestly) \- Interview Coder, truy cập vào tháng 2 10, 2026, [https://www.interviewcoder.co/blog/how-does-hackerrank-detect-cheating](https://www.interviewcoder.co/blog/how-does-hackerrank-detect-cheating)  
25. The Ultimate Guide to Event Gamification | Leap Event Tech, truy cập vào tháng 2 10, 2026, [https://leapevent.tech/blog/event-gamification-guide/](https://leapevent.tech/blog/event-gamification-guide/)  
26. Case Study: Digital Lucky Draw Implementation \- Vouchermatic, truy cập vào tháng 2 10, 2026, [https://vouchermatic.app/case-study-digital-lucky-draw/](https://vouchermatic.app/case-study-digital-lucky-draw/)  
27. Best Practices for High-Volume Hiring | Criteria Corp, truy cập vào tháng 2 10, 2026, [https://www.criteriacorp.com/blog/best-practices-high-volume-hiring](https://www.criteriacorp.com/blog/best-practices-high-volume-hiring)  
28. 23 Recruiting Metrics You Should Know \- AIHR, truy cập vào tháng 2 10, 2026, [https://www.aihr.com/blog/recruiting-metrics/](https://www.aihr.com/blog/recruiting-metrics/)  
29. Benchmark Metrics to Improve Your Recruiting Funnel \- HackerEarth, truy cập vào tháng 2 10, 2026, [https://www.hackerearth.com/blog/benchmark-metrics-to-improve-your-recruiting-funnel](https://www.hackerearth.com/blog/benchmark-metrics-to-improve-your-recruiting-funnel)