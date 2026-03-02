# **Product Requirement Analysis: Event-Centric Recruitment (ECR) Module**

**Vai trò:** Product Owner

**Phạm vi:** Tuyển dụng số lượng lớn (Mass Hiring), Job Fair, Fresher, Retail Walk-in.

## ---

**1\. Business Capability: Quản lý Năng lực & Lịch trình (Capacity & Scheduling Logic)**

Đây là phân hệ phức tạp nhất, chịu trách nhiệm "khớp" (matching) giữa hàng nghìn ứng viên và tài nguyên hữu hạn (phòng thi, giám khảo, khung giờ).

### **1.1 Cấu trúc Dữ liệu Lịch trình (Hierarchy of Schedule)**

Hệ thống cần quản lý lịch trình theo cấu trúc phân tầng chặt chẽ để đảm bảo không bị chồng chéo (conflict):

1. **Event (Sự kiện):** Ví dụ "Fresher 2026".  
2. **Phase (Giai đoạn):** Ví dụ "Test Onsite" hoặc "Interview".  
3. **Day (Ngày tổ chức):** Ngày cụ thể (VD: 10/02/2026).  
4. **Shift/Session (Ca/Kíp):** Khung giờ cụ thể (VD: Ca sáng 08:00 \- 10:00).  
5. **Room/Location (Phòng/Địa điểm):** Tài nguyên vật lý (VD: Phòng họp 101 \- Sức chứa 30 người).  
6. **Panel/Council (Hội đồng/Bàn phỏng vấn):** Tài nguyên con người gắn vào Phòng (VD: Bàn 1 \- Giám khảo A & B).

**Business Rules:**

* **Capacity Inheritance:** Sức chứa (Capacity) của Ca \= Tổng sức chứa các Phòng trong Ca đó.  
* **Slot Generation:** Hệ thống tự động sinh ra các "Slot" dựa trên công thức: Số lượng Hội đồng \* Thời lượng mỗi slot.

### **1.2 Logic Phân ca & Mời lịch (Allocation & Invitation Logic)**

Thay vì để ứng viên "tràn" vào tự do, hệ thống cần cơ chế phân phối thông minh (Smart Distribution).

**Tính năng 1: Auto-Allocation (Phân bổ tự động)**

* **Input:** Danh sách 1.000 ứng viên Pass vòng trước.  
* **Logic:** Hệ thống chia đều ứng viên vào các Ca có sẵn theo thuật toán *Round-robin* hoặc *Fill-first* (lấp đầy ca đầu rồi mới sang ca sau) để tối ưu hóa việc setup phòng ốc.1  
* **Output:** Trạng thái ứng viên chuyển từ Ready\_to\_Schedule \-\> Tentative\_Scheduled (Dự kiến).

**Tính năng 2: Invitation & Confirmation (Mời & Xác nhận)**

* Hệ thống gửi email chứa thông tin: Ngày, Giờ, Địa điểm (Chưa cần hiện số phòng cụ thể nếu chưa chốt).  
* **Action của Ứng viên:**  
  1. **Confirm:** Hệ thống khóa slot, trạng thái chuyển thành Scheduled.  
  2. **Reject (Cancel):** Hủy slot, hệ thống yêu cầu nhập lý do. Slot đó ngay lập tức được giải phóng (release) về Pool.  
  3. **Reschedule (Xin đổi):** Ứng viên được xem danh sách các Ca *còn trống* (Available Slots).

### **1.3 Cơ chế Hàng chờ & Tự động lấp đầy (Waitlist & Backfill Engine)**

Đây là tính năng "Must-have" để giải quyết yêu cầu: "Không có lịch thì chờ, có lịch trống thì báo".

**Flow xử lý:**

1. **Trạng thái Chờ (Pending Availability):** Nếu ứng viên muốn đổi lịch nhưng tất cả các Ca đều đã đầy (Full Capacity), ứng viên được đưa vào danh sách Waitlist.  
2. **Sự kiện Kích hoạt (Trigger Event):** Khi một ứng viên đã có lịch thực hiện hủy (Cancel) hoặc bị Admin xóa \-\> Slot trống xuất hiện.  
3. **Cơ chế Backfill (Tự động điền):**  
   * *Option A (First-come-first-served):* Gửi email thông báo cho toàn bộ nhóm Waitlist: "Đã có lịch trống vào 10:00 AM, ai vào xác nhận trước sẽ được".  
   * *Option B (Auto-assign):* Tự động lấy người xếp hàng đầu tiên trong Waitlist, gán vào slot trống và gửi email yêu cầu confirm trong X giờ.  
   * *Requirement Decision:* Chọn **Option A** cho Mass Hiring để tối ưu tốc độ lấp đầy.1

## ---

**2\. Business Capability: Vận hành Onsite & Check-in (Onsite Operations)**

Tại điểm thi/phỏng vấn, hệ thống chuyển sang chế độ "Thực thi" (Execution Mode) với yêu cầu tốc độ cao và chính xác tuyệt đối.

### **2.1 Logic Xác thực Check-in (Check-in Validation Rules)**

Khi ứng viên đến và đưa QR Code/SBD:

* **Rule 1: Time Window Validation (Kiểm tra khung giờ):**  
  * Cho phép check-in sớm trước X phút (VD: 30p) và muộn sau Y phút (VD: 15p) so với giờ bắt đầu Ca.  
  * *Edge Case:* Nếu đến sai Ca (đến chiều thay vì sáng) \-\> Hệ thống cảnh báo (Warning Alert) nhưng cho phép Admin dùng quyền "Override" (Ghi đè) để cho vào nếu Phòng còn ghế trống.  
* **Rule 2: Room/Panel Validation (Kiểm tra Phân phòng):**  
  * Nếu Event đã phân phòng cụ thể (VD: Phòng 101): Kiosk Check-in tại cửa phòng 101 chỉ chấp nhận ứng viên có mã phòng 101\. Các ứng viên khác sẽ báo lỗi "Sai phòng" và hiển thị hướng dẫn đúng.1  
  * Nếu Event dạng "Free Seating" (Ngồi tự do): Bỏ qua validate phòng, chỉ validate Ca.

### **2.2 Quy trình "Check-in Kiosk" & Định danh**

* **Input:** Scan QR Code hoặc Nhập SBD/CCCD.  
* **Display:** Hiển thị to, rõ: Tên, Ảnh (nếu có), Vị trí ứng tuyển, Phòng thi.  
* **Action:**  
  * **Photo Capture (Bắt buộc):** Hệ thống kích hoạt camera, yêu cầu chụp ảnh ứng viên tại thời điểm check-in. Ảnh này được lưu đè hoặc lưu mới vào hồ sơ để Hội đồng phỏng vấn đối chiếu (tránh thi hộ).1  
  * **Auto-Print (Tùy chọn):** In phiếu SBD hoặc Sticker dán ngực (Badge) có chứa mã QR định danh nội bộ.

## ---

**3\. Business Capability: Quản lý Hội đồng & Đánh giá (Panel & Scoring)**

Giải quyết yêu cầu: "Nhiều hội đồng, nhiều ứng viên, chỉ gửi 1 mail cho Manager".

### **3.1 Logic Phân luồng Hội đồng (Panel Distribution Logic)**

* **Many-to-One Relation:** Một Ca phỏng vấn có thể có 10 Hội đồng. Mỗi Hội đồng xử lý 1 dòng ứng viên (Queue).  
* **Dynamic Assignment:**  
  * *Hard Assignment:* Gán cứng ứng viên A vào Hội đồng 1\.  
  * *Soft Assignment (Queue Mode):* Ứng viên check-in xong sẽ ngồi chờ. Hội đồng nào trống việc (Idle) thì hệ thống "gọi" (Dispatch) ứng viên tiếp theo vào. Đây là mô hình tối ưu nhất cho Mass Hiring để tránh việc Hội đồng A xong sớm ngồi chơi, Hội đồng B bị quá tải.

### **3.2 Giao tiếp Hiring Manager (Consolidated Communication)**

Để tránh spam Hiring Manager (HM), hệ thống sử dụng cơ chế **"Session Digest"**:

* **Trigger:** Gửi trước giờ bắt đầu Ca phỏng vấn (ví dụ: 1 ngày hoặc 2 giờ).  
* **Content:** "Lịch phỏng vấn Chiều nay (14:00 \- 17:00)".  
* **Attachment/Link:**  
  * Không đính kèm 50 file CV rời rạc.  
  * Cung cấp **01 "Secure Link"** duy nhất dẫn đến **"Digital Interview Kit"**.  
  * Trong Digital Kit: HM thấy danh sách ứng viên của phiên đó, click vào từng người để xem CV (PDF Viewer) và Bảng điểm ngay trên trình duyệt mà không cần tải về.1

## ---

**4\. Feature Specification: Các tính năng "Phải có" (Must-Haves)**

Dựa trên phân tích trên, đây là danh sách tính năng cần đưa vào Backlog:

| Mã | Tính năng | Mô tả Business Logic (Requirement) |
| :---- | :---- | :---- |
| **ECR-01** | **Global Schedule Builder** | Cho phép tạo matrix: Ngày x Ca x Phòng. Định nghĩa Max Capacity cho từng ô. |
| **ECR-02** | **Smart Invite & Reschedule** | Gửi email mời hàng loạt. Link cho phép ứng viên chọn lại lịch. Nếu full slot \-\> Hiện nút "Join Waitlist". |
| **ECR-03** | **Waitlist Trigger** | Job chạy ngầm (Background Job): Khi slot được giải phóng \-\> Auto gửi email cho N người đầu waitlist. First-come-first-serve. |
| **ECR-04** | **Check-in Kiosk Mode** | Giao diện tối giản cho tablet. Scan QR. Validate lịch (Ca/Phòng). Chụp ảnh khuôn mặt (Face Capture) force-save vào hồ sơ. |
| **ECR-05** | **Manager Session View** | Dashboard cho HM: Thấy hàng đợi ứng viên (Queue). Trạng thái (Đang chờ/Đã đến). Chấm điểm online (Scorecard). |
| **ECR-06** | **Bulk Action Verification** | Khi chọn 100 ứng viên để "Mời PV": Hệ thống phải hiện Pop-up báo: "Có 5 người chưa Pass Test, 3 người đã từ chối. Bạn có muốn bỏ qua họ và chỉ gửi cho 92 người hợp lệ không?" (Skip Logic).1 |
| **ECR-07** | **Offline Mode Support** | (Cho Kiosk) Cho phép check-in đệm (cache) khi mất mạng và đồng bộ (sync) lại khi có mạng. Quan trọng cho các Job Fair tại trường ĐH sóng yếu. |

## **5\. Non-Functional Requirements (Yêu cầu phi chức năng)**

1. **Concurrency:** Hệ thống không được "treo" (crash) khi 1.000 ứng viên cùng bấm vào link đổi lịch tại một thời điểm (cần cơ chế Lock slot database).  
2. **Real-time Sync:** Khi Kiosk check-in "Thành công", màn hình của Hiring Manager ở trong phòng phải hiện "Ứng viên đã đến" ngay lập tức (Delay \< 5s).  
3. **Data Privacy:** Link gửi cho Hiring Manager phải hết hạn (expire) sau khi sự kiện kết thúc 24h để bảo mật thông tin ứng viên.

#### **Nguồn trích dẫn**

1. ATS\_Flow Fresher (Sent) \_ Internal.xlsx  
2. Minimizing Interview Rescheduling: Best Practices | Reczee Blog, truy cập vào tháng 2 10, 2026, [https://www.reczee.com/blog/minimizing-interview-rescheduling-best-practices](https://www.reczee.com/blog/minimizing-interview-rescheduling-best-practices)  
3. Kiosk Check-in Flow Configuration form \- ServiceNow, truy cập vào tháng 2 10, 2026, [https://www.servicenow.com/docs/r/xGHm5nN1KlkEq58WJHJoPw/KSQJvEb7t\~3mcACY4g2HpA](https://www.servicenow.com/docs/r/xGHm5nN1KlkEq58WJHJoPw/KSQJvEb7t~3mcACY4g2HpA)  
4. The Applicant Tracking System (ATS) for High-Volume Hiring \- Pinpoint ATS, truy cập vào tháng 2 10, 2026, [https://www.pinpointhq.com/use-cases/ats-high-volume-hiring/](https://www.pinpointhq.com/use-cases/ats-high-volume-hiring/)  
5. Interview Scheduling Software | Pinpoint, truy cập vào tháng 2 10, 2026, [https://www.pinpointhq.com/features/interview-scheduling-software](https://www.pinpointhq.com/features/interview-scheduling-software)