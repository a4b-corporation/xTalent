# **BÁO CÁO CHIẾN LƯỢC KIẾN TRÚC HỆ THỐNG: PHÂN TÍCH BOUNDED CONTEXT CHO NỀN TẢNG TUYỂN DỤNG TẬP TRUNG SỰ KIỆN (EVENT-CENTRIC RECRUITMENT \- ECR)**

## **1\. TỔNG QUAN ĐIỀU HÀNH VÀ CƠ SỞ LÝ LUẬN**

### **1.1. Sự Chuyển Dịch Mô Hình: Từ Job-Centric Sang Event-Centric**

Trong kỷ nguyên số hóa nguồn nhân lực hiện đại, các hệ thống Quản lý Tuyển dụng (Applicant Tracking Systems \- ATS) truyền thống đang đối mặt với một cuộc khủng hoảng về kiến trúc khi phải xử lý các chiến dịch tuyển dụng quy mô lớn (High-Volume Hiring). Mô hình cũ, vốn được xây dựng xung quanh thực thể cốt lõi là "Yêu cầu tuyển dụng" (Job Requisition), coi mỗi vị trí tuyển dụng là một silo dữ liệu riêng biệt. Tuy nhiên, thực tế vận hành của các chương trình như Fresher, Management Trainee, hay Job Fair đòi hỏi một cách tiếp cận hoàn toàn khác biệt: mô hình "Tuyển dụng Tập trung Sự kiện" (Event-Centric Recruitment \- ECR).1

Sự khác biệt căn bản nằm ở chỗ ECR đảo ngược mối quan hệ quản lý: "Sự kiện" (Event) trở thành thực thể trung tâm, đóng vai trò là một "container" chứa đựng nhiều luồng tuyển dụng (Tracks) và liên kết động với nhiều yêu cầu tuyển dụng khác nhau.1 Để hiện thực hóa tầm nhìn này, kiến trúc hệ thống không thể tiếp tục phát triển theo hướng "thêm tính năng" (feature-based) mà phải được tái cấu trúc triệt để dựa trên tư duy Thiết kế Hướng Tên miền (Domain-Driven Design \- DDD).

Báo cáo này trình bày một bản phân tích kiến trúc chuyên sâu, chia tách hệ thống ECR thành các Bounded Contexts (Miền dữ liệu/ngữ cảnh giới hạn). Việc phân chia này không dựa trên các tính năng bề mặt như "Check-in" hay "Phỏng vấn", mà dựa trên "Đối tượng quản lý" (Managed Objects) và các quy tắc nghiệp vụ bất biến (Invariants).2 Mục tiêu là tạo ra một hệ thống có tính liên kết lỏng (loose coupling) nhưng gắn kết chặt chẽ về mặt nội tại (high cohesion), nơi mỗi Context giải quyết một bài toán nghiệp vụ cụ thể và giao tiếp với nhau thông qua các giao diện lập trình ứng dụng (API) chuẩn hóa.3

### **1.2. Nguyên Tắc Thiết Kế: Bounded Context và Ubiquitous Language**

Trong DDD, Bounded Context không chỉ là ranh giới của mã nguồn, mà là ranh giới của ngôn ngữ và ý nghĩa.2 Một thuật ngữ như "Ứng viên" (Candidate) sẽ mang những ý nghĩa hoàn toàn khác nhau tùy thuộc vào ngữ cảnh:

* Trong **Identity Context**, "Ứng viên" là một thực thể định danh với Số điện thoại và Mã sinh viên.1  
* Trong **Scheduling Context**, "Ứng viên" chỉ đơn thuần là một ReservationHolderID chiếm dụng một khe thời gian, hệ thống không quan tâm đến tên tuổi hay kỹ năng của họ.1  
* Trong **Assessment Context**, "Ứng viên" là một TestTaker gắn liền với một TestInstance và kết quả điểm số.1

Việc phân tách này giúp hệ thống tránh được tình trạng "Big Ball of Mud" \- nơi mọi logic nghiệp vụ bị trộn lẫn, gây khó khăn cho việc bảo trì và mở rộng.5 Báo cáo này sẽ đi sâu vào phân tích 9 Bounded Contexts cốt lõi, xác định các Thực thể (Entities), Khả năng Nguyên tử (Atomic Capabilities), và các mẫu tích hợp (Integration Patterns) cần thiết để vận hành hệ thống ECR.

## ---

**2\. PHÂN TÍCH CHI TIẾT CÁC BOUNDED CONTEXTS CỐT LÕI**

### **2.1. Event Management Context (Miền Quản lý Sự kiện)**

Đây là "trái tim" của hệ thống ECR, đóng vai trò điều phối và định nghĩa cấu trúc của toàn bộ chiến dịch tuyển dụng. Context này chịu trách nhiệm trả lời câu hỏi: "Chúng ta đang tổ chức cái gì, cho ai, và quy trình như thế nào?".

#### **2.1.1. Các Thực thể và Aggregates (Core Entities)**

| Thực thể (Entity) | Loại (Type) | Mô tả Chi tiết & Trách nhiệm |
| :---- | :---- | :---- |
| **Event** (Sự kiện) | Aggregate Root | Thực thể gốc quản lý vòng đời của chiến dịch. Chứa metadata (Tên, Thời gian, Địa điểm), trạng thái (Draft, Published, Archived) và các thiết lập toàn cục. Event đóng vai trò là "Master Event" quản lý cả giai đoạn trước và sau sự kiện.1 |
| **Track** (Luồng) | Entity | Phân đoạn chuyên môn hóa trong một sự kiện (ví dụ: "Java Developer", "Game Designer"). Track thay thế vai trò của Job Description truyền thống trong bối cảnh sự kiện, cho phép cấu hình quy trình riêng biệt cho từng nhóm đối tượng.1 |
| **Stage** (Giai đoạn) | Value Object | Các bước trong quy trình tuyển dụng của một Track (Check-in \-\> Test \-\> Interview). |
| **Request Mapping** | Entity | Bản ghi liên kết giữa một Track và một Job Requisition ID từ hệ thống ATS lõi. |

#### **2.1.2. Khả năng Nguyên tử (Atomic Capabilities)**

**a. Khởi tạo và Cấu hình Sự kiện (Event Creation & Configuration)** Hệ thống cho phép tạo lập một Event như một thực thể độc lập. Khả năng này bao gồm việc định nghĩa các thuộc tính thời gian thực (real-time attributes) như thời gian bắt đầu/kết thúc sự kiện vật lý, và thời gian của "vòng đời mở rộng" (nuôi dưỡng ứng viên trước và sau sự kiện).1

* *Quy tắc nghiệp vụ:* Một sự kiện phải có ít nhất một Track để có thể chuyển sang trạng thái "Published".

**b. Quản lý Đa luồng (Multi-Track Management)**

Khả năng "Gán Track cho Event" cho phép nhà tuyển dụng (TA) định nghĩa các luồng tuyển dụng song song.

* *Cơ chế:* Mỗi Track hoạt động như một tiểu dự án với các cấu hình riêng về quy trình (Workflow). Ví dụ: Track "Game Design" có thể bỏ qua bước "Coding Test" và thay bằng bước "Portfolio Review", trong khi Track "Backend" bắt buộc phải có "Coding Test".1  
* *Giá trị:* Cho phép một sự kiện duy nhất phục vụ nhiều mục tiêu tuyển dụng mà không gây xung đột quy trình.

**c. Ánh xạ Động (Dynamic Mapping)**

Đây là khả năng quan trọng nhất để kết nối ECR với hệ thống ATS truyền thống.

* *Logic:* Hệ thống cho phép ánh xạ linh hoạt giữa Track và Request ID.  
* *Invariant (Bất biến):* Một Event chỉ được phép ánh xạ với các Request loại "Fresher" đã được phê duyệt (Approved) nhưng **chưa đăng tuyển (Not Posted)** trên các kênh Job Board.1 Điều này tạo ra một lớp bảo vệ logic (corruption layer), ngăn chặn xung đột nguồn ứng viên giữa kênh sự kiện và kênh tuyển dụng thông thường.

#### **2.1.3. Sự kiện Miền (Domain Events)**

* EventPublished: Kích hoạt việc hiển thị sự kiện trên cổng thông tin (Portal) và cho phép các Context khác (như Form, Scheduling) bắt đầu nhận cấu hình.  
* TrackConfigured: Thông báo cho *Form Context* biết cần chuẩn bị các Schema dữ liệu tương ứng cho Track này.

### ---

**2.2. Form & Data Management Context (Miền Quản lý Biểu mẫu & Dữ liệu)**

Context này chịu trách nhiệm về "hình thái" của dữ liệu. Nó quản lý siêu dữ liệu (Metadata) và cấu trúc (Schema) của các thông tin cần thu thập, tách biệt hoàn toàn với việc lưu trữ giá trị dữ liệu thực tế (vốn thuộc về Identity Context).

#### **2.2.1. Các Thực thể và Aggregates (Core Entities)**

| Thực thể (Entity) | Loại (Type) | Mô tả Chi tiết & Trách nhiệm |
| :---- | :---- | :---- |
| **Question Bank** | Aggregate Root | Kho lưu trữ trung tâm các định nghĩa trường dữ liệu (Fields) và câu hỏi. Quản lý metadata chi tiết: Topic (Chủ đề), Difficulty (Độ khó \- Bloom's Taxonomy), Data Type (Text, Number, File, Code).1 |
| **Field Blueprint** | Entity | Bản thiết kế tập hợp các câu hỏi cho một mục đích cụ thể (ví dụ: "Form đăng ký cho Designer"). |
| **Rendering Schema** | Value Object | Cấu trúc JSON quy định cách hiển thị form trên UI (thứ tự, bắt buộc/không bắt buộc, dependencies). |
| **Validator** | Value Object | Logic kiểm tra tính hợp lệ của dữ liệu đầu vào (Regex, Max Length, File Size). |

#### **2.2.2. Khả năng Nguyên tử (Atomic Capabilities)**

**a. Quản lý Ngân hàng Câu hỏi và Metadata**

Khả năng định nghĩa các thuộc tính phong phú cho từng trường dữ liệu.

* *Chi tiết:* Mỗi Item trong Question Bank không chỉ là một chuỗi văn bản, mà là một đối tượng dữ liệu phức tạp chứa các thẻ (tags) như Domain: Java, Level: Hard, Type: MCQ.1 Điều này cho phép tái sử dụng câu hỏi cho cả Form đăng ký và Bài kiểm tra năng lực.

**b. Render Bộ câu hỏi Động theo Track (Track-Specific Rendering)**

Đây là giải pháp cho bài toán cân bằng giữa trải nghiệm ứng viên và nhu cầu dữ liệu.

* *Logic:* Thay vì một form chung (Generic Form), hệ thống tạo ra các Rendering Schema riêng biệt cho từng Track ID.  
* *Cơ chế:* Khi ứng viên chọn Track "Game Dev", API sẽ gọi đến Form Context với tham số track\_id=game\_dev. Context này trả về schema chứa các trường chuyên sâu về ngôn ngữ lập trình (C++, C\#). Ngược lại, với track\_id=game\_design, schema trả về sẽ chứa các trường upload Portfolio.1

**c. Validate Dữ liệu Đầu vào**

Cung cấp dịch vụ xác thực dữ liệu độc lập (Validation Service).

* *Cơ chế:* Nhận đầu vào là {SchemaID, DataPayload} và trả về kết quả hợp lệ hoặc danh sách lỗi. Điều này đảm bảo rằng mọi dữ liệu đi vào hệ thống đều tuân thủ các quy tắc định dạng đã thiết lập trước (ví dụ: định dạng Mã sinh viên phải là 8 chữ số).7

**d. Khóa Bộ câu hỏi (Lock Question Set)**

Một khả năng quan trọng để đảm bảo tính nhất quán của báo cáo (Reporting Integrity).

* *Invariant:* Trước khi một Request được tạo hoặc một báo cáo cố định được xuất ra, bộ câu hỏi (Blueprint) phải được chuyển sang trạng thái "Locked". Không được phép thêm/bớt trường dữ liệu khi đã có ứng viên bắt đầu nộp đơn, nhằm đảm bảo cấu trúc "Dynamic Columns" trong báo cáo không bị gãy.1

### ---

**2.3. Identity & Profile Context (Miền Định danh & Hồ sơ)**

Context này đóng vai trò là "Single Source of Truth" (Nguồn chân lý duy nhất) về con người. Nhiệm vụ cốt lõi là đảm bảo mỗi cá nhân thực tế chỉ có duy nhất một bản ghi định danh trong hệ thống, bất chấp việc họ tương tác qua nhiều kênh hay sự kiện khác nhau.

#### **2.3.1. Các Thực thể và Aggregates (Core Entities)**

| Thực thể (Entity) | Loại (Type) | Mô tả Chi tiết & Trách nhiệm |
| :---- | :---- | :---- |
| **Candidate** | Aggregate Root | Đại diện cho ứng viên. Được định danh bằng cặp khóa phức hợp {PhoneNumber \+ StudentID} thay vì Email.1 |
| **Profile** | Entity | Chứa các giá trị dữ liệu thực tế (Attributes) được thu thập từ Form Context (Tên, Email, CV Link, Answers). |
| **Duplicate Record** | Aggregate | Bản ghi tạm thời chứa các hồ sơ bị nghi ngờ trùng lặp, chờ xử lý. |
| **Merge Rule** | Policy | Tập hợp các quy tắc logic để quyết định cách gộp dữ liệu. |

#### **2.3.2. Khả năng Nguyên tử (Atomic Capabilities)**

**a. Định danh Đa yếu tố (Multi-factor Identification)**

Khả năng xác định duy nhất một ứng viên dựa trên logic nghiệp vụ đặc thù cho đối tượng Fresher/Sinh viên.

* *Logic:* Sử dụng StudentID (định danh ổn định gắn với học vấn) và PhoneNumber (kênh liên lạc xác thực) làm khóa chính (Primary Key). Email không được dùng làm khóa chính vì tính dễ thay đổi và khả năng tạo nhiều email rác.1

**b. Phát hiện Trùng lặp (Detect Duplicate)**

Hệ thống không tự động ghi đè hay tạo mới mà thực hiện quét trùng lặp chủ động.

* *Workflow:*  
  1. Nhận payload dữ liệu từ Form Context.  
  2. Kiểm tra sự tồn tại của StudentID HOẶC PhoneNumber.  
  3. Nếu phát hiện trùng khớp:  
     * Trùng 100% (Cả SĐT \+ ID): Đánh dấu là "Spam/Error" \-\> Gợi ý: **Remove**.  
     * Trùng một phần (Chỉ SĐT hoặc chỉ ID): Đánh dấu là "Conflict" \-\> Gợi ý: **Merge** hoặc **Replace Data**.1  
  4. Lưu vào khu vực Duplicate Tab để chờ xử lý (Audit Trail).1

**c. Hợp nhất Hồ sơ (Merge Profile)**

Khả năng thực thi giao dịch gộp hai bản ghi thành một.

* *Logic:* Khi TA xác nhận lệnh Merge, hệ thống sẽ tổng hợp dữ liệu từ bản ghi mới vào bản ghi cũ (ưu tiên thông tin mới nhất cho các trường liên lạc, giữ nguyên lịch sử ứng tuyển), sau đó đánh dấu bản ghi cũ là "Merged/Archived".

### ---

**2.4. Scheduling & Resource Context (Miền Lập lịch & Tài nguyên)**

Context này hoạt động như một hệ thống quản lý kho (Inventory Management) cho thời gian và không gian. Điểm đặc biệt là nó hoạt động theo nguyên tắc "mù" (blind): nó không quan tâm "Ai" (Candidate Name) đang đặt chỗ, mà chỉ quan tâm "ID" nào đang chiếm giữ tài nguyên (Slot).1

#### **2.4.1. Các Thực thể và Aggregates (Core Entities)**

| Thực thể (Entity) | Loại (Type) | Mô tả Chi tiết & Trách nhiệm |
| :---- | :---- | :---- |
| **Capacity** | Aggregate Root | Định nghĩa tổng cung tài nguyên cho một khung thời gian (ví dụ: "Ca sáng: 166 ghế"). |
| **Shift** | Entity | Tập hợp các Slot trong một khoảng thời gian liên tục (ví dụ: 08:00 \- 12:00). |
| **Slot** | Entity | Đơn vị nguyên tử của tài nguyên (Một ghế phỏng vấn, một máy tính thi). Có trạng thái: Available, Locked, Reserved. |
| **Reservation** | Entity | Sự xác nhận chiếm giữ Slot. Liên kết SlotID với CandidateID. |
| **Waitlist** | Aggregate | Hàng đợi ưu tiên chứa các RequestID khi Capacity \= 0\. |

#### **2.4.2. Khả năng Nguyên tử (Atomic Capabilities)**

**a. Kiểm tra Khả dụng (Check Availability)**

Truy vấn nhanh khả năng đáp ứng của hệ thống.

* *Công thức:* AvailableSlots \= TotalCapacity \- ConfirmedReservations \- LockedSlots.  
* *Invariant:* Một Slot không bao giờ được phép Overbook (đặt quá chỗ) trừ khi có cấu hình đặc biệt cho phép "Waitlist Overflow".

**b. Khóa và Giải phóng Slot (Lock & Release Slot)**

Quản lý trạng thái cạnh tranh (Concurrency Control).

* *Lock Slot:* Khi một ứng viên bắt đầu chọn giờ, hệ thống thực hiện "Optimistic Locking" (Khóa tạm thời) trong 5-10 phút. Nếu không hoàn tất, Slot tự động Release.  
* *Release Slot:* Khi một ứng viên hủy lịch hoặc bị loại, Slot chuyển trạng thái về Available.1

**c. Quản lý Hàng chờ Thông minh (Smart Waitlist Logic)**

Cơ chế tự động hóa việc lấp đầy chỗ trống.

* *Logic:* Khi một Slot được giải phóng (SlotReleased Event), hệ thống không mở ngay ra Public mà quét trong Waitlist.  
* *Priority Allocation:* Dựa trên quy tắc FIFO (Vào trước ra trước) hoặc mức độ ưu tiên của ứng viên để tự động gán Slot cho người trong hàng chờ và gửi thông báo xác nhận.1

**d. Phân bổ Tự động (Auto-Distribution)**

Thuật toán cân bằng tải (Load Balancing).

* *Logic:* Dựa trên số lượng ứng viên Pass vòng trước, hệ thống tự động phân bổ đều họ vào các Shift còn trống để tránh tình trạng một ca quá tải trong khi ca khác vắng vẻ.1

### ---

**2.5. Assessment & Examination Context (Miền Đánh giá & Khảo thí)**

Đây là engine chịu trách nhiệm sinh đề, tổ chức thi và chấm điểm. Nó tách biệt hoàn toàn với việc quản lý thông tin cá nhân hay lịch trình.

#### **2.5.1. Các Thực thể và Aggregates (Core Entities)**

| Thực thể (Entity) | Loại (Type) | Mô tả Chi tiết & Trách nhiệm |
| :---- | :---- | :---- |
| **Blueprint** | Aggregate Root | Ma trận cấu trúc đề thi (ví dụ: "3 câu Dễ Java, 2 câu Khó SQL"). Blueprint khác với đề thi thực tế.1 |
| **Test Instance** | Aggregate Root | Bài thi cụ thể được sinh ra cho một phiên thi. Chứa danh sách các ItemID cụ thể. |
| **Item** | Entity | Tham chiếu đến câu hỏi trong Question Bank (nhưng có thể snapshot lại nội dung tại thời điểm thi). |
| **Submission** | Entity | Dữ liệu bài làm của ứng viên. |
| **Proctor Session** | Entity | Dữ liệu giám sát (log vi phạm, ảnh chụp webcam). |

#### **2.5.2. Khả năng Nguyên tử (Atomic Capabilities)**

**a. Sinh đề thi từ Blueprint (Generate Test from Blueprint)**

Khả năng tạo ra các đề thi độc nhất (Unique Test Instances) để chống gian lận.

* *Cơ chế:* Engine nhận đầu vào là BlueprintID. Nó truy vấn *Form & Data Context* (Question Bank) để rút ngẫu nhiên các câu hỏi thỏa mãn tiêu chí (Topic, Difficulty) trong Blueprint. Kết quả là mỗi ứng viên nhận được một đề thi khác nhau nhưng có độ khó tương đương (Psychometric Equivalence).1

**b. Chấm điểm (Score Submission)**

* *Auto-grading:* Tự động chấm điểm cho các câu hỏi trắc nghiệm (MCQ) và Code (chạy Test Cases).  
* *Manual-grading:* Điều phối bài làm (Essay/Project) đến cho người chấm, quản lý trạng thái chấm (Pending \-\> Graded).

**c. Giám sát thi (Proctoring)** Tích hợp các giải pháp chống gian lận đa lớp.1

* *Browser Lockdown:* Ngăn chặn mở tab mới hoặc copy/paste.  
* *Plagiarism Detection:* So sánh mã nguồn của ứng viên với cơ sở dữ liệu để phát hiện sao chép.  
* *Identity Verification:* Chụp ảnh ngẫu nhiên qua webcam và đối chiếu.

## ---

**3\. CÁC BOUNDED CONTEXT BỔ TRỢ (SUPPORTING CONTEXTS)**

Ngoài 5 context nghiệp vụ lõi, hệ thống cần các context bổ trợ để hoàn thiện hệ sinh thái ECR.

### **3.1. Onsite Operations Context (Miền Vận hành Tại chỗ)**

Quản lý tương tác vật lý tại sự kiện, đóng vai trò cầu nối giữa thế giới thực (Offline) và hệ thống số (Online).

* **Entities:** KioskSession, CheckInRecord, QRToken.  
* **Atomic Capabilities:**  
  * **Check-in QR Code:** Giải mã QRToken để xác thực ứng viên và ghi nhận thời gian tham dự (\< 5 giây/người).1  
  * **Offline Sync:** Khả năng lưu trữ dữ liệu cục bộ (Local Storage/SQLite) khi mất mạng và đồng bộ nền (Background Sync) khi có kết nối. Sử dụng Timestamp để giải quyết xung đột dữ liệu.1  
  * **OCR Processing:** Tiếp nhận ảnh chụp CV, gọi OCR Engine để trích xuất text, và chuyển dữ liệu thô sang *Identity Context* để xử lý tiếp.1

### **3.2. Communication & Notification Context (Miền Giao tiếp & Thông báo)**

Quản lý toàn bộ luồng thông tin ra/vào với người dùng.

* **Entities:** MessageTemplate, TriggerRule, Campaign.  
* **Atomic Capabilities:**  
  * **Trigger-based Automation:** Lắng nghe các Domain Events (ví dụ: CandidateCheckedIn) để tự động gửi tin nhắn chào mừng hoặc link bài test.1  
  * **Bulk Action Safety:** Cơ chế "Confirmation Modal" quét danh sách người nhận, loại bỏ các trạng thái không hợp lệ (ví dụ: gửi thư mời cho người đã bị loại) trước khi gửi hàng loạt.1

### **3.3. Gamification & Engagement Context (Miền Tương tác & Trò chơi hóa)**

Tăng cường trải nghiệm ứng viên thông qua các cơ chế thưởng và nhiệm vụ.

* **Entities:** Mission (Nhiệm vụ), PointLedger (Sổ cái điểm), LuckyDrawSession.  
* **Atomic Capabilities:**  
  * **Mission Tracking:** Ghi nhận hoàn thành nhiệm vụ (ví dụ: "Check-in thành công", "Hoàn thành bài test") để cộng điểm.  
  * **Execute Lucky Draw:** Thực hiện quay số ngẫu nhiên dựa trên danh sách ứng viên có trạng thái Attended.1

### **3.4. Analytics & Reporting Context (Miền Phân tích & Báo cáo)**

Tổng hợp dữ liệu để ra quyết định.

* **Entities:** ReportSchema, DashboardWidget.  
* **Atomic Capabilities:**  
  * **Dynamic Column Flattening:** Khả năng biến đổi cấu trúc dữ liệu JSON động (từ Form Context) thành dạng bảng phẳng (CSV/Excel) với các cột động tương ứng với Track của ứng viên.1  
  * **Funnel Analysis:** Tính toán tỷ lệ chuyển đổi qua các phễu (Registered \-\> Attended \-\> Test Passed \-\> Interviewed \-\> Hired).1

## ---

**4\. CHIẾN LƯỢC TÍCH HỢP VÀ BẢN ĐỒ NGỮ CẢNH (CONTEXT MAPPING)**

Hệ thống ECR vận hành dựa trên sự phối hợp nhịp nhàng giữa các Bounded Contexts. Chúng ta sử dụng mẫu thiết kế **Event-Driven Architecture** (Kiến trúc hướng sự kiện) để đảm bảo tính lỏng lẻo.

### **4.1. Kịch bản Tích hợp 1: Quy trình Check-in và Kích hoạt Bài thi**

Đây là ví dụ điển hình về sự phối hợp giữa Onsite, Identity và Assessment Context.

| Bước | Context Chủ động | Hành động / Sự kiện | Context Thụ động | Phản ứng / Tác vụ |
| :---- | :---- | :---- | :---- | :---- |
| 1 | **Onsite Ops** | Quét QR Code \-\> Publish Event CandidateCheckedIn {SBD, Time} | **Identity** | Cập nhật trạng thái Status \= Attended. |
| 2 |  |  | **Assessment** | Nhận sự kiện, kiểm tra Blueprint của Track tương ứng, kích hoạt TestInstance cho SBD này. |
| 3 |  |  | **Communication** | Gửi tin nhắn: "Chào mừng, bài thi của bạn đã sẵn sàng tại \[Link\]". |
| 4 |  |  | **Gamification** | Cộng 50 điểm vào PointLedger cho nhiệm vụ "Early Check-in". |

### **4.2. Kịch bản Tích hợp 2: Lập lịch Thông minh và Xử lý Hàng chờ**

Minh họa cho sự tách biệt giữa Scheduling (ẩn danh) và Identity (định danh).

| Bước | Context Chủ động | Hành động / Sự kiện | Context Thụ động | Phản ứng / Tác vụ |
| :---- | :---- | :---- | :---- | :---- |
| 1 | **Scheduling** | Ứng viên A hủy lịch \-\> Publish Event SlotReleased {SlotID, ShiftID}. | **Scheduling** | (Internal Logic) Quét Waitlist, chọn Ứng viên B (Top Priority). |
| 2 | **Scheduling** | Gán Slot cho B \-\> Publish Event SlotReassigned {SlotID, NewCandidateID: B}. | **Identity** | (Không làm gì \- Context này không quan tâm slot). |
| 3 |  |  | **Communication** | Nhận sự kiện, truy vấn Identity Context để lấy Email của B, gửi thông báo: "Bạn đã có lịch phỏng vấn mới\!". |

### **4.3. Các Mẫu Tích hợp (Integration Patterns)**

* **Shared Kernel (Hạt nhân chia sẻ):** Các Value Object như SBD (Số Báo Danh) và TrackID được chia sẻ giữa tất cả các Context để đảm bảo tính nhất quán về định danh.1  
* **Anti-Corruption Layer (ACL \- Lớp chống tham nhũng):**  
  * Giữa **Event Context** và hệ thống **ATS Core**: Event Context sử dụng ACL để chuyển đổi JobRequisition từ ATS thành cấu hình Track mà không bị phụ thuộc vào mô hình dữ liệu cồng kềnh của ATS.  
* **Open Host Service (OHS):**  
  * **Form Context** cung cấp API GET /schema?track={id} như một dịch vụ mở cho Frontend (Web/Kiosk) để render giao diện mà không cần biết logic lưu trữ bên dưới.

## ---

**5\. KẾT LUẬN VÀ KHUYẾN NGHỊ TRIỂN KHAI**

### **5.1. Kết luận Chiến lược**

Việc áp dụng kiến trúc Bounded Context cho hệ thống ECR không chỉ giải quyết bài toán về hiệu năng xử lý khối lượng lớn (High-Volume Hiring) mà còn tạo ra nền tảng linh hoạt cho sự phát triển trong tương lai.

1. **Tách biệt mối quan tâm:** Việc tách Scheduling khỏi Identity cho phép hệ thống quản lý tài nguyên (phòng họp, máy tính) hiệu quả hơn mà không bị ràng buộc bởi logic quản lý con người.  
2. **Linh hoạt trong cấu hình:** Tách Event và Track khỏi Job Requisition cho phép Marketing và Tuyển dụng chạy các chiến dịch sáng tạo, đa chiều mà không làm ảnh hưởng đến cấu trúc dữ liệu nhân sự lõi.  
3. **Toàn vẹn dữ liệu:** Các quy tắc bất biến (Invariants) như "Lock Question Set" hay "Multi-factor Duplicate Check" giúp đảm bảo dữ liệu luôn sạch và nhất quán ngay từ đầu nguồn.

### **5.2. Lộ trình Triển khai Kỹ thuật (Technical Roadmap)**

Dựa trên mức độ quan trọng và phụ thuộc giữa các Context, lộ trình triển khai được đề xuất như sau:

* **Giai đoạn 1: Nền tảng (Core Foundation)**  
  * Xây dựng **Event Management Context** để định nghĩa cấu trúc sự kiện.  
  * Xây dựng **Form & Data Context** để quản lý metadata.  
  * Xây dựng **Identity Context** với logic Check trùng lặp cơ bản.  
* **Giai đoạn 2: Vận hành (Operations Layer)**  
  * Triển khai **Scheduling & Resource Context** để quản lý lịch.  
  * Phát triển **Onsite Operations Context** (Kiosk App, QR).  
* **Giai đoạn 3: Nâng cao (Intelligence & Experience)**  
  * Tích hợp **Assessment Context** với tính năng Blueprinting và Proctoring.  
  * Triển khai **Gamification** và **Analytics** chuyên sâu.

Kiến trúc này đảm bảo rằng hệ thống ECR sẽ không chỉ là một công cụ hỗ trợ tuyển dụng, mà là một nền tảng công nghệ mạnh mẽ, có khả năng mở rộng và thích ứng với những thay đổi nhanh chóng của thị trường nhân sự trong kỷ nguyên số.

#### **Nguồn trích dẫn**

1. Bổ sung tính năng tuyển dụng tập trung sự kiện.docx  
2. Bounded Context \- Martin Fowler, truy cập vào tháng 2 10, 2026, [https://www.martinfowler.com/bliki/BoundedContext.html](https://www.martinfowler.com/bliki/BoundedContext.html)  
3. Blog: From Good to Excellent in DDD: Understanding Bounded Contexts in Domain-Driven Design \- 8/10 \- Kranio, truy cập vào tháng 2 10, 2026, [https://www.kranio.io/en/blog/de-bueno-a-excelente-en-ddd-comprender-bounded-contexts-en-domain-driven-design---8-10](https://www.kranio.io/en/blog/de-bueno-a-excelente-en-ddd-comprender-bounded-contexts-en-domain-driven-design---8-10)  
4. Summary of the Domain Driven Design concepts | by robloxro \- Medium, truy cập vào tháng 2 10, 2026, [https://medium.com/@ruxijitianu/summary-of-the-domain-driven-design-concepts-9dd1a6f90091](https://medium.com/@ruxijitianu/summary-of-the-domain-driven-design-concepts-9dd1a6f90091)  
5. Strategic DDD by Example: Bounded Contexts Mapping | by Jarek Orzel | Level Up Coding, truy cập vào tháng 2 10, 2026, [https://levelup.gitconnected.com/strategic-ddd-by-example-bounded-contexts-mapping-d94ffcd45954](https://levelup.gitconnected.com/strategic-ddd-by-example-bounded-contexts-mapping-d94ffcd45954)  
6. Domain-driven design patterns: A metadata-based approach \- ResearchGate, truy cập vào tháng 2 10, 2026, [https://www.researchgate.net/publication/311980398\_Domain-driven\_design\_patterns\_A\_metadata-based\_approach](https://www.researchgate.net/publication/311980398_Domain-driven_design_patterns_A_metadata-based_approach)  
7. Validation and DDD \- Enterprise Craftsmanship, truy cập vào tháng 2 10, 2026, [https://enterprisecraftsmanship.com/posts/validation-and-ddd/](https://enterprisecraftsmanship.com/posts/validation-and-ddd/)  
8. Gamification 101: The Psychology Behind Points & Badges | Guul Games, truy cập vào tháng 2 10, 2026, [https://guul.games/blog/gamification-101-the-psychology-behind-points-and-badges](https://guul.games/blog/gamification-101-the-psychology-behind-points-and-badges)