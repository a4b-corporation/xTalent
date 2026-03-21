# User Stories — ATS Fresher Module

> **Version:** 1.0
> **Last updated:** 2026-03-20
> **Source BRD:** `1.reality/brd.md`
> **Status:** DRAFT

---

## Story US-FRSH-001: Tạo Event Fresher

**As a** TA (Talent Acquisition),
**I want to** tạo Event loại Fresher với thông tin mô tả và thời gian chạy event,
**So that** tôi có thể post lên Career Site và bắt đầu nhận applications từ sinh viên.

### Acceptance Criteria

**Scenario 1: Tạo Event thành công**
- GIVEN tôi có quyền TA trong hệ thống
- WHEN tôi nhập đầy đủ thông tin Event (tên, mô tả, thời gian bắt đầu/kết thúc, Program = Fresher)
- AND khai báo form fields cần thiết cho ứng viên
- AND khai báo bộ câu hỏi cho ứng viên
- WHEN tôi nhấn "Tạo Event"
- THEN Event được tạo với status = "Draft"
- AND Event ID được sinh tự động
- AND tôi có thể tiếp tục thiết lập các vòng tuyển dụng

**Scenario 2: Validation thiếu thông tin bắt buộc**
- GIVEN tôi đang tạo Event mới
- WHEN tôi nhấn "Tạo Event" mà thiếu thông tin bắt buộc (tên, thời gian)
- THEN hệ thống hiển thị lỗi với các field thiếu
- AND Event KHÔNG được tạo

**Scenario 3: Thiết lập quà tặng cho chương trình quay số**
- GIVEN Event đã được tạo ở status Draft
- WHEN tôi khai báo các quà tặng cho chương trình quay số
- THEN quà tặng được lưu vào Event
- AND hiển thị trong form apply của ứng viên

---

## Story US-FRSH-002: Mapping Request tuyển dụng vào Event

**As a** TA,
**I want to** mapping một hoặc nhiều Request tuyển dụng đã được approve vào Event Fresher,
**So that** tôi có thể quản lý ứng viên theo từng Request cụ thể và track được nguồn tuyển dụng.

### Acceptance Criteria

**Scenario 1: Mapping Request thành công**
- GIVEN Event thuộc Program "Fresher" ở status Draft
- AND các Request tuyển dụng có type = "Fresher"
- AND các Request đã được approve (status = Approved)
- AND các Request chưa được post lên Career Site
- WHEN tôi chọn và mapping các Request này vào Event
- THEN mapping được lưu thành công
- AND mỗi Request chỉ được mapping 1 Event duy nhất
- AND Event hiển thị danh sách các Request đã mapping

**Scenario 2: Validation Request không hợp lệ**
- GIVEN tôi đang mapping Request vào Event
- WHEN tôi chọn Request có type ≠ "Fresher"
- THEN hệ thống hiển thị lỗi và không cho mapping
- AND giải thích lý do (sai type)

**Scenario 3: Validation Request đã được post**
- GIVEN tôi đang mapping Request vào Event
- WHEN tôi chọn Request đã được post lên Career Site
- THEN hệ thống hiển thị lỗi và không cho mapping
- AND giải thích lý do (Request đã được post)

**Scenario 4: Unmap Request khi chưa có Student apply**
- GIVEN Event đã mapping Request
- AND chưa có Student nào apply vào Event đó
- WHEN tôi thực hiện unmap Request
- THEN mapping được xóa thành công
- AND Request trở lại trạng thái chưa mapping

**Scenario 5: Unmap Request khi đã có Student apply**
- GIVEN Event đã mapping Request
- AND đã có Student apply vào Event đó
- WHEN tôi thực hiện unmap Request
- THEN hệ thống hiển thị lỗi và không cho unmap
- AND giải thích lý do (đã có Student apply)

---

## Story US-FRSH-003: Thiết lập bộ câu hỏi theo Track

**As a** TA,
**I want to** add bộ câu hỏi riêng cho từng Track trong Event,
**So that** tôi có thể thu thập thông tin phù hợp cho từng vị trí tuyển dụng.

### Acceptance Criteria

**Scenario 1: Thêm bộ câu hỏi cho Track**
- GIVEN Event đã được tạo với nhiều Tracks (VD: Game Development, Game Design, Game QC)
- WHEN tôi chọn một Track và add bộ câu hỏi từ Questionnaire library
- THEN bộ câu hỏi được lưu cho Track đó
- AND chỉ hiển thị khi ứng viên chọn Track tương ứng

**Scenario 2: Validation bộ câu hỏi**
- GIVEN tôi đang add bộ câu hỏi cho Track
- WHEN bộ câu hỏi chưa được chọn
- THEN hệ thống hiển thị warning
- AND cho phép tiếp tục (không bắt buộc)

**Scenario 3: Xem trước bộ câu hỏi**
- GIVEN tôi đang chọn bộ câu hỏi từ library
- WHEN tôi click vào bộ câu hỏi
- THEN hệ thống hiển thị preview các câu trong bộ
- AND tôi có thể confirm hoặc hủy

---

## Story US-FRSH-004: Thiết lập workflow vòng tuyển dụng

**As a** TA,
**I want to** thiết lập các vòng tuyển dụng cho Event và bypass vòng không cần thiết,
**So that** quy trình tuyển dụng phù hợp với yêu cầu của từng Event.

### Acceptance Criteria

**Scenario 1: Thiết lập full workflow**
- GIVEN Event đã được tạo
- WHEN tôi thiết lập workflow với đầy đủ 5 vòng: Screening → Online Test → Onsite Test → Interview → Offer
- THEN workflow được lưu với thứ tự các vòng
- AND mỗi vòng có thể thiết lập chi tiết riêng

**Scenario 2: Bypass Online Test**
- GIVEN Event đã được tạo
- WHEN tôi thiết lập workflow bypass vòng Online Test
- THEN workflow được lưu: Screening → Onsite Test → Interview → Offer
- AND vòng Online Test được mark = "Skipped"
- AND ứng viên không trải qua vòng này

**Scenario 3: Bypass Tests (chỉ Screening → Interview)**
- GIVEN Event đã được tạo
- WHEN tôi thiết lập workflow bypass cả Online Test và Onsite Test
- THEN workflow được lưu: Screening → Interview → Offer
- AND cả 2 vòng được mark = "Skipped"

**Scenario 4: Validation workflow tối thiểu**
- GIVEN tôi đang thiết lập workflow
- WHEN tôi bypass tất cả các vòng (chỉ còn Screening → Offer)
- THEN hệ thống cảnh báo workflow không hợp lệ
- AND yêu cầu có ít nhất 1 vòng đánh giá (Test hoặc Interview)

---

## Story US-FRSH-005: Student apply vào Event Fresher

**As a** Student,
**I want to** apply vào Event Fresher bằng cách chọn Track và trả lời bộ câu hỏi,
**So that** tôi có thể tham gia chương trình tuyển dụng Fresher.

### Acceptance Criteria

**Scenario 1: Apply thành công**
- GIVEN Event đang trong thời gian hiệu lực
- AND tôi chưa từng apply vào Event này
- WHEN tôi chọn 1 Track trong Event
- AND điền đầy đủ thông tin form field
- AND trả lời bộ câu hỏi của Track đã chọn
- WHEN tôi nhấn "Submit"
- THEN application được tạo với status = "Submitted"
- AND tôi nhận được email confirmation
- AND tôi không thể apply lại cùng Event này

**Scenario 2: Validation thời gian apply**
- GIVEN Event đã hết hạn (past end date)
- WHEN tôi cố gắng apply
- THEN hệ thống hiển thị lỗi "Event đã kết thúc"
- AND nút Submit bị disable

**Scenario 3: Validation duplicate application**
- GIVEN tôi đã apply vào Event này trước đó
- WHEN tôi cố gắng apply lại (có thể bằng account khác)
- THEN hệ thống detect duplicate (theo SĐT hoặc StudentID)
- AND hiển thị lỗi "Bạn đã apply vào Event này rồi"
- AND application KHÔNG được tạo

**Scenario 4: Validation chọn Track**
- GIVEN Event có nhiều Tracks
- WHEN tôi chưa chọn Track nào
- THEN hệ thống hiển thị lỗi "Vui lòng chọn Track"
- AND application KHÔNG được submit

**Scenario 5: Ứng viên chọn Track khác sau khi apply**
- GIVEN tôi đã apply vào 1 Track
- WHEN tôi muốn đổi sang Track khác
- THEN hệ thống KHÔNG cho phép đổi Track
- AND hiển thị thông báo "Vui lòng liên hệ TA nếu cần thay đổi"

---

## Story US-FRSH-006: Xem danh sách Student apply Event

**As a** TA,
**I want to** xem danh sách Student đã apply Event với các thông tin chi tiết,
**So that** tôi có thể review và screening ứng viên.

### Acceptance Criteria

**Scenario 1: Xem danh sách đầy đủ**
- GIVEN Event có Student đã apply
- WHEN tôi mở màn hình "Danh sách Student apply"
- THEN hiển thị tất cả Student đã apply
- AND sắp xếp theo thời gian apply (giảm dần)
- AND hiển thị các cột core: Name, Email, SĐT, Student ID, Track, Status, Apply Date

**Scenario 2: Quick Search**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi nhập từ khóa vào Quick Search
- THEN hệ thống tìm theo: Name, SĐT, Email, Student ID, Identity ID, ID number
- AND kết quả được filter realtime
- AND highlight từ khóa trong kết quả

**Scenario 3: Filter theo Status**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi chọn filter Status = "Not Send Email"
- THEN chỉ hiển thị Student chưa gửi email
- AND số lượng Student được hiển thị (badge)

**Scenario 4: Filter theo Stage/Round**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi chọn filter Stage = "Screening"
- AND filter Round = "Online Test"
- THEN chỉ hiển thị Student đang ở vòng đó
- AND số lượng được cập nhật

**Scenario 5: Advanced Search theo Field động**
- GIVEN Event có các custom form fields
- WHEN tôi mở Advanced Search
- THEN hiển thị các field động để filter
- AND tôi có thể chọn giá trị mong muốn cho mỗi field

**Scenario 6: Advanced Search theo Question**
- GIVEN Event có các câu hỏi cho ứng viên
- WHEN tôi mở Advanced Search
- THEN hiển thị các câu hỏi để filter
- AND tôi có thể chọn câu trả lời mong muốn
- AND filter ra Student có câu trả lời phù hợp

**Scenario 7: Dynamic column hiển thị**
- GIVEN Event có các custom fields và questions
- WHEN tôi mở column settings
- THEN hiển thị danh sách cột có thể chọn (bao gồm fields và questions)
- AND tôi có thể bật/tắt hiển thị cột
- AND mặc định bộ câu hỏi được ẩn
- AND khi filter theo Track, câu hỏi của Track đó tự động hiển thị

---

## Story US-FRSH-007: Cảnh báo trùng Student apply

**As a** TA,
**I want to** được cảnh báo khi có Student tạo nhiều Account để apply cùng 1 Event,
**So that** tôi có thể xử lý duplicate và đảm bảo công bằng trong tuyển dụng.

### Acceptance Criteria

**Scenario 1: Phát hiện duplicate theo SĐT**
- GIVEN 2 Student apply vào cùng 1 Event
- AND có cùng SĐT
- WHEN hệ thống detect duplicate
- THEN highlight (làm nổi) cả 2 records trong danh sách
- AND hiển thị badge "Duplicate - Same Phone"
- AND tự động chuyển vào tab "Duplicate"

**Scenario 2: Phát hiện duplicate theo StudentID**
- GIVEN 2 Student apply vào cùng 1 Event
- AND có cùng StudentID
- WHEN hệ thống detect duplicate
- THEN highlight cả 2 records
- AND hiển thị badge "Duplicate - Same Student ID"

**Scenario 3: Duplicate detection theo cả 2 tiêu chí**
- GIVEN 2 Student apply vào cùng 1 Event
- AND có cùng cả SĐT và StudentID
- WHEN hệ thống detect duplicate
- THEN highlight với badge "Duplicate - Same Phone & Student ID"
- AND hiển thị warning mức độ cao

**Scenario 4: TA Remove duplicate**
- GIVEN duplicate đã được highlight
- AND tôi đã review và xác nhận đây là duplicate
- WHEN tôi click "Remove" trên 1 trong 2 records
- THEN hệ thống hiển thị confirmation modal
- AND khi confirm, record được chọn bị xóa
- AND record còn lại giữ nguyên
- AND lý do xóa được log vào audit trail

**Scenario 5: TA Replace data**
- GIVEN duplicate đã được highlight
- AND tôi muốn keep thông tin từ record mới hơn
- WHEN tôi click "Replace Data"
- THEN hệ thống hiển thị confirmation modal với preview data thay đổi
- AND khi confirm, thông tin từ record mới overwrite record cũ
- AND record mới bị xóa
- AND audit trail ghi nhận thay đổi

**Scenario 6: Xem tab Duplicate**
- GIVEN có duplicate trong Event
- WHEN tôi mở tab "Duplicate"
- THEN hiển thị tất cả duplicate cases
- AND status (Resolved/Pending) cho mỗi case
- AND action đã thực hiện (Remove/Replace/No Action)

---

## Story US-FRSH-008: Xem chi tiết Student apply

**As a** TA,
**I want to** xem chi tiết thông tin Student đã apply (field, note, question, result),
**So that** tôi có thể đánh giá và quyết định screening.

### Acceptance Criteria

**Scenario 1: Xem thông tin cơ bản**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi click vào 1 Student
- THEN hiển thị popup/modal chi tiết
- AND hiển thị đầy đủ thông tin: Name, Email, SĐT, Student ID, Track, Apply Date

**Scenario 2: Xem form fields**
- GIVEN Student đã điền form fields
- WHEN tôi mở chi tiết Student
- THEN hiển thị tất cả field values đã điền
- AND label của mỗi field

**Scenario 3: Xem câu trả lời questions**
- GIVEN Student đã trả lời bộ câu hỏi của Track
- WHEN tôi mở chi tiết Student
- THEN hiển thị từng câu hỏi và câu trả lời
- AND phân biệt rõ câu hỏi - câu trả lời

**Scenario 4: Xem attached files**
- GIVEN Student đã upload CV/attachments
- WHEN tôi mở chi tiết Student
- THEN hiển thị danh sách file đã upload
- AND cho phép click để xem (image, pdf) hoặc tải về
- AND hiển thị file size, upload date

**Scenario 5: Xem notes**
- GIVEN Student đã có notes từ TA
- WHEN tôi mở chi tiết Student
- THEN hiển thị tất cả notes theo timeline
- AND note mới nhất ở trên cùng
- AND hiển thị người tạo note và thời gian

**Scenario 6: Update Pass/Fail Screening**
- GIVEN Student chưa có kết quả screening
- AND Student chưa qua vòng sau
- WHEN tôi click "Pass" hoặc "Fail"
- THEN hệ thống cập nhật kết quả ngay
- AND lưu vào audit trail
- AND nếu Pass, Candidate RR được tự động tạo

**Scenario 7: Xem lịch sử actions**
- GIVEN Student đã trải qua nhiều actions
- WHEN tôi mở chi tiết
- THEN hiển thị timeline các actions (apply, screening, send mail, etc.)
- AND timestamp cho mỗi action

---

## Story US-FRSH-009: Export danh sách Student

**As a** TA,
**I want to** export danh sách Student với đầy đủ thông tin apply,
**So that** tôi có thể làm báo cáo offline hoặc chia sẻ với Hiring Manager.

### Acceptance Criteria

**Scenario 1: Export tất cả columns**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi click "Export" và chọn "All Columns"
- THEN hệ thống generate file Excel/CSV
- AND bao gồm tất cả columns đang hiển thị
- AND bao gồm form fields và câu trả lời questions

**Scenario 2: Export selected columns**
- GIVEN tôi đã chọn hiển thị một số columns
- WHEN tôi click "Export" và chọn "Selected Columns"
- THEN hệ thống generate file Excel/CSV
- AND chỉ bao gồm columns đã chọn
- AND hiển thị preview trước khi export

**Scenario 3: Export filtered data**
- GIVEN tôi đã filter danh sách theo tiêu chí nào đó
- WHEN tôi click "Export"
- THEN hệ thống hỏi "Export all or filtered?"
- AND nếu chọn "Filtered", chỉ export data đã filter

**Scenario 4: Export với attachments**
- GIVEN Student đã upload CV/attachments
- WHEN tôi chọn export option "Include Attachments"
- THEN hệ thống generate ZIP file
- AND trong đó có Excel + folder chứa attachments
- AND file được đặt tên theo quy tắc: [StudentName]_[FileType]

---

## Story US-FRSH-010: Screening Pass/Fail

**As a** TA,
**I want to** ghi nhận kết quả Screening Pass/Fail cho Student,
**So that** tôi có thể lọc ứng viên phù hợp qua vòng đầu tiên.

### Acceptance Criteria

**Scenario 1: Screening Pass**
- GIVEN Student đã apply và tôi đã review
- WHEN tôi click "Pass" cho Student
- THEN status Student chuyển sang "Screening Pass"
- AND Candidate RR được tự động tạo trong hệ thống
- AND Student được chuyển sang vòng tiếp theo (theo workflow)
- AND audit trail ghi nhận Pass với timestamp

**Scenario 2: Screening Fail**
- GIVEN Student đã apply và tôi đã review
- WHEN tôi click "Fail" cho Student
- THEN status Student chuyển sang "Screening Fail"
- AND Candidate RR KHÔNG được tạo
- AND Student vẫn hiển thị trong danh sách với Result = Failed
- AND tôi có thể gửi mail Thank You từ đây

**Scenario 3: Bulk Screening Pass**
- GIVEN tôi đã chọn nhiều Students (checkbox)
- AND tất cả đều chưa có kết quả screening
- WHEN tôi click "Bulk Pass"
- THEN hệ thống hiển thị confirmation modal với số lượng Students
- AND khi confirm, tất cả Students chuyển sang "Pass"
- AND Candidate RR được tạo cho từng Student

**Scenario 4: Bulk Screening Fail**
- GIVEN tôi đã chọn nhiều Students
- AND tất cả đều chưa có kết quả screening
- WHEN tôi click "Bulk Fail"
- THEN hệ thống hiển thị confirmation modal
- AND khi confirm, tất cả Students chuyển sang "Fail"
- AND Candidate RR KHÔNG được tạo

**Scenario 5: Update Screening result**
- GIVEN Student đã có kết quả screening (Pass/Fail)
- AND Student chưa qua vòng sau
- WHEN tôi click để change kết quả
- THEN hệ thống cho phép update
- AND log lý do thay đổi vào audit trail

---

## Story US-FRSH-011: Tạo Assignment (Online Test)

**As a** TA,
**I want to** tạo bài kiểm tra Online với mô tả, link, file đính kèm và deadline,
**So that** Student có thể làm bài và nộp qua hệ thống.

### Acceptance Criteria

**Scenario 1: Tạo Assignment thành công**
- GIVEN tôi có quyền TA
- WHEN tôi nhập thông tin Assignment (tên, mô tả, link bài kiểm tra nếu có, deadline, người chấm)
- AND attach file đề bài (nếu cần)
- WHEN tôi nhấn "Create Assignment"
- THEN Assignment được tạo với status = "Draft"
- AND Assignment ID được sinh tự động
- AND tôi có thể preview Assignment trước khi gửi

**Scenario 2: Validation deadline**
- GIVEN tôi đang tạo Assignment
- WHEN deadline nằm trong quá khứ
- THEN hệ thống hiển thị lỗi "Deadline phải là thời gian tương lai"
- AND không cho tạo Assignment

**Scenario 3: Thiết lập người chấm**
- GIVEN tôi đang tạo Assignment
- WHEN tôi chọn 1 hoặc nhiều Managers làm người chấm
- THEN Managers được lưu vào Assignment
- AND chỉ những Managers này mới chấm được Assignment này
- AND Task chấm bài được tạo cho Managers

**Scenario 4: Upload file đề bài**
- GIVEN tôi đang tạo Assignment
- WHEN tôi upload file đề bài
- THEN hệ thống validate file type (Word/PDF/Excel/PPT)
- AND validate file size ≤ 10MB
- AND hiển thị tên file đã upload
- AND cho phép xóa và upload file khác

---

## Story US-FRSH-012: Gửi Assignment cho Student

**As a** TA,
**I want to** gửi bài kiểm tra cho một hoặc nhiều Candidates qua email,
**So that** Student có thể nhận link làm bài và nộp submission.

### Acceptance Criteria

**Scenario 1: Gửi Assignment cho 1 Student**
- GIVEN Assignment đã được tạo
- AND Student đã Pass Screening
- WHEN tôi chọn Student và click "Send Assignment"
- THEN hệ thống hiển thị preview email content
- AND khi confirm, email được gửi đến Student
- AND email chứa link submission unique cho Student
- AND log vào audit trail

**Scenario 2: Gửi Assignment cho nhiều Students (Bulk)**
- GIVEN tôi đã chọn nhiều Students (checkbox)
- AND tất cả đều đã Pass Screening
- AND chưa được gửi Assignment
- WHEN tôi click "Bulk Send Assignment"
- THEN hệ thống hiển thị confirmation modal với số lượng Students
- AND khi confirm, email được gửi cho tất cả Students
- AND mỗi Student nhận link submission riêng

**Scenario 3: Gửi Assignment theo schedule**
- GIVEN tôi đã chọn Students và Assignment
- WHEN tôi chọn "Send Later" và chọn thời gian
- THEN hệ thống lên lịch gửi email
- AND hiển thị countdown đến thời gian gửi
- AND cho phép hủy/cancel trước khi gửi

**Scenario 4: Resend Assignment**
- GIVEN Student đã nhận Assignment nhưng không nhận được email
- WHEN tôi click "Resend"
- THEN hệ thống gửi lại email với cùng link submission
- AND log lý do resend vào audit trail

---

## Story US-FRSH-013: Nộp Assignment online

**As a** Student,
**I want to** nộp bài làm trực tiếp qua link nhận được trong email,
**So that** bài làm của tôi được ghi nhận và gửi cho Manager chấm.

### Acceptance Criteria

**Scenario 1: Nộp bài thành công**
- GIVEN tôi nhận được email với link submission
- AND còn hạn nộp (current time < deadline)
- WHEN tôi click vào link
- THEN hiển thị form nộp bài với:
  - Banner/Cover chương trình
  - Nội dung mô tả bài kiểm tra
  - Thời gian còn lại để nộp (countdown)
  - Hướng dẫn nộp bài
- AND tôi có thể upload file bài làm

**Scenario 2: Upload file bài làm**
- GIVEN tôi đang ở form nộp bài
- WHEN tôi upload file bài làm
- THEN hệ thống validate file type (Word/PDF/Excel/PPT)
- AND validate file size ≤ 10MB
- AND cho phép upload nhiều file (không cần zip)
- AND hiển thị danh sách file đã upload
- AND cho phép xóa file và upload lại

**Scenario 3: Preview file trước khi nộp**
- GIVEN tôi đã upload 1 file
- WHEN tôi click "Preview"
- THEN hệ thống hiển thị preview file (nếu supported: PDF, image)
- AND cho phép xem nội dung trước khi submit

**Scenario 4: Submit bài làm**
- GIVEN tôi đã upload file bài làm
- WHEN tôi click "Submit"
- THEN hệ thống hiển thị confirmation modal
- AND khi confirm, bài làm được ghi nhận
- AND tôi nhận được email confirmation
- AND status chuyển sang "Submitted"
- AND Manager được giao chấm nhận notification

**Scenario 5: Nộp bài sau deadline**
- GIVEN tôi cố gắng nộp bài sau deadline
- WHEN tôi mở link submission
- THEN hệ thống hiển thị thông báo "Deadline đã qua"
- AND nút Submit bị disable
- AND tôi có thể liên hệ TA để hỗ trợ

**Scenario 6: Xem lời cảm ơn sau nộp**
- GIVEN tôi đã submit bài làm thành công
- THEN hệ thống hiển thị trang cảm ơn
- AND nội dung hướng dẫn next steps
- AND thông báo thời gian có kết quả dự kiến

---

## Story US-FRSH-014: Chấm điểm Assignment thủ công

**As a** Manager,
**I want to** chấm bài cho Student được giao,
**So that** Student có kết quả và quyết định qua vòng.

### Acceptance Criteria

**Scenario 1: Xem danh sách Student cần chấm**
- GIVEN tôi được TA phân công chấm Assignment
- WHEN tôi mở màn hình "Chấm bài"
- THEN hiển thị danh sách Student được giao
- AND số lượng Student cần chấm (badge)
- AND deadline chấm bài cho mỗi Student

**Scenario 2: Xem chi tiết bài làm**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi click vào 1 Student
- THEN hiển thị chi tiết bài làm:
  - File đã upload (cho phép preview/download)
  - Thời gian nộp
  - Thông tin Student
- AND tôi có thể download file về chấm offline

**Scenario 3: Chấm điểm và nhận xét**
- GIVEN tôi đang xem bài làm của Student
- WHEN tôi nhập điểm (thang điểm 10/100)
- AND nhập nhận xét (required field)
- AND chọn Pass/Fail
- WHEN tôi click "Save"
- THEN kết quả được lưu
- AND status chuyển sang "Graded"
- AND TA có thể xem kết quả

**Scenario 4: Chấm điểm hàng loạt**
- GIVEN tôi đã download file và chấm offline
- WHEN tôi mở "Bulk Grading"
- THEN hiển thị form để nhập điểm hàng loạt
- AND tôi có thể paste từ Excel hoặc upload file kết quả
- AND hệ thống match Student theo tên/ID
- AND hiển thị preview trước khi submit

**Scenario 5: Validation chấm điểm**
- GIVEN tôi đang nhập điểm
- WHEN điểm nằm ngoài range hợp lệ (0-10 hoặc 0-100)
- THEN hệ thống hiển thị lỗi "Điểm không hợp lệ"
- AND không cho lưu

**Scenario 6: Update kết quả đã chấm**
- GIVEN tôi đã chấm xong cho Student
- AND TA chưa gửi kết quả cho Student
- WHEN tôi muốn update điểm/nhận xét
- THEN hệ thống cho phép update
- AND log vào audit trail

---

## Story US-FRSH-015: Import kết quả chấm điểm hàng loạt

**As a** TA,
**I want to** import kết quả chấm điểm từ Managers để ghi nhận cho Students,
**So that** tiết kiệm thời gian nhập liệu thủ công.

### Acceptance Criteria

**Scenario 1: Import kết quả từ Excel**
- GIVEN tôi có file Excel với kết quả chấm điểm
- WHEN tôi mở "Import Results" và upload file
- THEN hệ thống validate file format
- AND hiển thị preview data import
- AND match Student theo tên/ID
- AND hiển thị warnings nếu có Students không match

**Scenario 2: Mapping columns**
- GIVEN file Excel có columns khác với hệ thống
- WHEN tôi mở import wizard
- THEN hệ thống cho phép mapping columns:
  - Student Name/ID → Student column
  - Score → Điểm column
  - Comment → Nhận xét column
  - Pass/Fail → Result column
- AND lưu mapping template cho lần sau

**Scenario 3: Validation kết quả import**
- GIVEN tôi đang import kết quả
- WHEN có Students không tìm thấy trong hệ thống
- THEN hệ thống hiển thị warning list
- AND cho phép skip hoặc manual match
- AND chỉ import records hợp lệ

**Scenario 4: Auto-complete task Managers**
- GIVEN Managers có task chấm bài chưa complete
- WHEN tôi import kết quả cho Students
- THEN task của Managers được auto complete
- AND lý do = "Result imported by TA"
- AND audit trail ghi nhận import

**Scenario 5: Confirm và commit import**
- GIVEN preview data import hiển thị
- WHEN tôi click "Confirm Import"
- THEN kết quả được commit vào hệ thống
- AND Students nhận được notification (nếu configured)
- AND audit trail ghi nhận import với timestamp

---

## Story US-FRSH-016: Review kết quả thi Online

**As a** TA,
**I want to** tổng hợp kết quả thi Online để quyết định sinh viên qua vòng hay fail,
**So that** chỉ những ứng viên đạt yêu cầu mới vào vòng trong.

### Acceptance Criteria

**Scenario 1: Xem danh sách kết quả**
- GIVEN Assignment đã có kết quả chấm
- WHEN tôi mở màn hình "Review Results"
- THEN hiển thị danh sách Students với kết quả:
  - Điểm
  - Nhận xét
  - Pass/Fail status
- AND filter theo Pass/Fail

**Scenario 2: Filter Students Pass**
- GIVEN có cả Students Pass và Fail
- WHEN tôi chọn filter "Pass"
- THEN chỉ hiển thị Students Pass
- AND số lượng hiển thị (badge)
- AND tôi có thể bulk action cho Pass students

**Scenario 3: Filter Students Fail**
- GIVEN có cả Students Pass và Fail
- WHEN tôi chọn filter "Fail"
- THEN chỉ hiển thị Students Fail
- AND tôi có thể bulk send Thank You email

**Scenario 4: Bulk gửi mail mời Test Onsite (cho Pass)**
- GIVEN tôi đã filter Students Pass
- WHEN tôi click "Send Onsite Test Invitation"
- THEN hệ thống hiển thị confirmation modal
- AND khi confirm, email mời Test Onsite được gửi
- AND Students chuyển sang vòng Onsite Test

**Scenario 5: Bulk gửi mail Thank You (cho Fail)**
- GIVEN tôi đã filter Students Fail
- WHEN tôi click "Send Thank You Email"
- THEN hệ thống tự động gợi ý template theo stage (Online Test Fail)
- AND hiển thị confirmation modal
- AND khi confirm, email Thank You được gửi
- AND status chuyển sang "Ended - Thank You Sent"
- AND Students Fail vẫn hiển thị trong danh sách với filter

**Scenario 6: Exception - Fail nhưng vẫn cho qua vòng**
- GIVEN Student Fail nhưng tôi muốn cho qua vòng (exception)
- WHEN tôi click "ReOpen" cho Student
- THEN Student được đánh dấu = "Exception - Proceed"
- AND Student có thể qua vòng tiếp theo
- AND audit trail ghi nhận exception với lý do

---

## Story US-FRSH-017: Thiết lập vòng thi Onsite (ca thi)

**As a** TA,
**I want to** thiết lập các ca thi onsite với ngày giờ, địa điểm, phòng, số lượng tối đa,
**So that** tôi có thể sắp xếp lịch thi cho ứng viên.

### Acceptance Criteria

**Scenario 1: Tạo ca thi mới**
- GIVEN tôi có quyền TA
- WHEN tôi nhập thông tin ca thi (mô tả, ngày thi, giờ bắt đầu-kết thúc, địa điểm, phòng, số lượng tối đa)
- AND chọn 1 hoặc nhiều người chấm thi
- AND chọn 1 hoặc nhiều TA phụ trách check-in
- AND nhập deadline confirm
- WHEN tôi nhấn "Create Slot"
- THEN ca thi được tạo với status = "Open"
- AND số lượng slot trống = max capacity

**Scenario 2: Validation số lượng tối đa**
- GIVEN tôi đang tạo ca thi
- WHEN số lượng tối đa ≤ 0
- THEN hệ thống hiển thị lỗi "Số lượng tối đa phải > 0"
- AND không cho tạo ca thi

**Scenario 3: Validation giờ thi**
- GIVEN tôi đang tạo ca thi
- WHEN giờ kết thúc ≤ giờ bắt đầu
- THEN hệ thống hiển thị lỗi "Giờ kết thúc phải sau giờ bắt đầu"
- AND không cho tạo ca thi

**Scenario 4: Validation deadline confirm**
- GIVEN tôi đang tạo ca thi
- WHEN deadline confirm < current time
- THEN hệ thống hiển thị lỗi "Deadline phải là thời gian tương lai"
- AND không cho tạo ca thi

**Scenario 5: Xem danh sách ca thi**
- GIVEN vòng thi Onsite đã có ca thi được tạo
- WHEN tôi mở màn hình "Ca thi"
- THEN hiển thị danh sách ca thi với:
  - Ngày giờ
  - Phòng
  - Số lượng đã đăng ký / tối đa
  - Status (Open/Closed)

**Scenario 6: Edit ca thi**
- GIVEN ca thi chưa có Student đăng ký
- WHEN tôi edit thông tin ca thi
- THEN hệ thống cho phép update
- AND log vào audit trail

**Scenario 7: Validation edit khi đã có Student**
- GIVEN ca thi đã có Student đăng ký
- WHEN tôi muốn edit số lượng tối đa (giảm)
- THEN hệ thống cảnh báo "Đã có Student đăng ký"
- AND chỉ cho edit nếu số lượng mới ≥ số lượng đã đăng ký

---

## Story US-FRSH-018: Gửi mail mời tham gia thi Onsite

**As a** TA,
**I want to** gửi mail mời tham gia thi cho Students và chia đều vào các ca,
**So that** Students biết lịch thi và xác nhận tham gia.

### Acceptance Criteria

**Scenario 1: Chọn Students gửi mail mời**
- GIVEN Students đã Pass vòng trước
- WHEN tôi chọn nhiều Students (checkbox)
- AND click "Send Onsite Test Invitation"
- THEN hệ thống hiển thị wizard chọn ca thi

**Scenario 2: Chọn ca thi**
- GIVEN wizard mời thi hiển thị
- WHEN tôi chọn 1 hoặc nhiều ca thi
- THEN hệ thống hiển thị số lượng slots trống mỗi ca
- AND tổng capacity

**Scenario 3: Auto chia Students vào ca**
- GIVEN tôi đã chọn Students và ca thi
- WHEN tôi click "Auto Allocate"
- THEN hệ thống tự chia đều Students vào các ca theo rule:
  - slots = ceil(students / ca_count)
  - Ưu tiên ca còn trống
  - Tôn tại các ràng buộc (nếu có)
- AND hiển thị preview kết quả chia

**Scenario 4: Manual adjust kết quả chia**
- GIVEN hệ thống đã auto chia Students vào ca
- WHEN tôi muốn điều chỉnh
- THEN tôi có thể drag-drop Student sang ca khác
- AND hệ thống cảnh báo nếu ca quá số lượng tối đa
- AND cập nhật realtime số lượng mỗi ca

**Scenario 5: Gen SBD cho Students**
- GIVEN Students được chia vào ca thi Onsite
- WHEN tôi confirm danh sách mời thi
- THEN hệ thống tự động gen Số báo danh (SBD) cho từng Student
- AND SBD được lưu vào profile Student
- AND hiển thị trong mail mời thi

**Scenario 6: Gửi mail mời thi**
- GIVEN danh sách Students đã được chia ca
- WHEN tôi click "Send Invitations"
- THEN hệ thống gửi email cho từng Student với:
  - Thông tin ca thi (ngày, giờ, phòng, địa điểm)
  - SBD
  - Link confirm tham gia
  - Deadline confirm
- AND log vào audit trail

**Scenario 7: Gửi mail theo schedule**
- GIVEN tôi đã chuẩn bị mail mời thi
- WHEN tôi chọn "Send Later"
- THEN hệ thống lên lịch gửi vào thời gian指定
- AND hiển thị countdown
- AND cho phép cancel trước khi gửi

---

## Story US-FRSH-019: Student phản hồi mời tham gia thi

**As a** Student,
**I want to** xác nhận tham gia hoặc xin đổi lịch thi qua link trong email,
**So that** TA biết tôi có tham gia và sắp xếp lịch phù hợp.

### Acceptance Criteria

**Scenario 1: Xác nhận tham gia (Yes)**
- GIVEN tôi nhận được email mời thi với link confirm
- AND còn thời hạn confirm
- WHEN tôi click vào link và chọn "Yes, I will attend"
- THEN hệ thống ghi nhận tôi sẽ tham gia
- AND status của tôi chuyển sang "Confirmed"
- AND slot trong ca thi được giữ cho tôi
- AND TA nhận được notification (optional)

**Scenario 2: Từ chối tham gia (No)**
- GIVEN tôi nhận được email mời thi với link confirm
- AND còn thời hạn confirm
- WHEN tôi click vào link và chọn "No, I cannot attend"
- THEN hệ thống yêu cầu nhập lý do (required)
- AND status của tôi chuyển sang "Declined"
- AND slot trong ca thi được giải phóng
- AND TA nhận được notification với lý do

**Scenario 3: Yêu cầu đổi lịch (Change)**
- GIVEN tôi nhận được email mời thi với link confirm
- AND còn thời hạn confirm
- WHEN tôi click vào link và chọn "Request Change"
- THEN hệ thống hiển thị các ca khác còn slot trống
- AND tôi chọn ca mới phù hợp
- AND yêu cầu được gửi cho TA
- AND status chuyển sang "Pending Reschedule"

**Scenario 4: Hệ thống tự động check slot trống**
- GIVEN tôi yêu cầu đổi lịch
- AND không có ca nào còn slot
- WHEN tôi submit yêu cầu
- THEN hệ thống đưa tôi vào hàng chờ
- AND thông báo "Chúng tôi sẽ liên hệ khi có slot trống"
- AND TA nhận được notification

**Scenario 5: Hệ thống tự động gửi mail khi có slot**
- GIVEN tôi đang trong hàng chờ đổi lịch
- WHEN có slot trống từ ca khác (do有人hủy)
- THEN hệ thống tự động gửi email mời ca mới cho tôi
- AND email có link confirm
- AND deadline confirm mới

**Scenario 6: Lần đổi lịch thứ 2**
- GIVEN tôi đã đổi lịch 1 lần
- AND TA gửi lại lời mời mới
- WHEN tôi mở link confirm
- THEN chỉ còn 2 option: Yes/No (không còn Change)
- AND hệ thống hiển thị thông báo "Bạn chỉ được đổi lịch 1 lần"

**Scenario 7: Hết thời hạn confirm**
- GIVEN tôi chưa confirm tham gia
- AND đã quá deadline confirm
- WHEN tôi mở link confirm
- THEN hệ thống hiển thị thông báo "Thời gian xác nhận đã kết thúc"
- AND hiển thị thông tin liên hệ TA để hỗ trợ
- AND action bị disable

---

## Story US-FRSH-020: Ghi nhận check-in onsite

**As a** TA,
**I want to** ghi nhận thông tin check-in cho Student khi đến thi onsite,
**So that** tôi biết được Student nào đã đến và cho vào phòng thi.

### Acceptance Criteria

**Scenario 1: Search Student để check-in**
- GIVEN tôi đang ở màn hình check-in
- WHEN tôi nhập SBD, Student ID, SĐT, email hoặc tên
- THEN hệ thống tìm và hiển thị thông tin Student
- AND hiển thị ca thi đã mời, thời gian confirm
- AND status confirm (Yes/No/Change)

**Scenario 2: Xác nhận check-in**
- GIVEN Student đã được tìm thấy
- AND Student đã confirm tham gia
- WHEN tôi click "Check-in"
- THEN hệ thống ghi nhận thời gian check-in thực tế
- AND status chuyển sang "Checked In"
- AND Student được cho vào phòng thi

**Scenario 3: Validation check-in sớm**
- GIVEN Student đến trước giờ mời
- WHEN tôi cố gắng check-in
- THEN hệ thống cảnh báo "Chưa đến giờ check-in"
- AND cho phép check-in nếu TA confirm (override)

**Scenario 4: Validation check-in muộn**
- GIVEN Student đến sau giờ kết thúc ca thi
- WHEN tôi cố gắng check-in
- THEN hệ thống cảnh báo "Đã quá giờ check-in"
- AND yêu cầu lý do check-in muộn
- AND vẫn cho phép check-in (exception)

**Scenario 5: Xem thông tin Student khi check-in**
- GIVEN tôi đang check-in Student
- WHEN tôi mở chi tiết Student
- THEN hiển thị:
  - Thời gian check-in đã confirm
  - Ca thi đã mời
  - Thời gian đã thay đổi (nếu có)
  - SBD
- AND cho phép xem nhanh để đối chiếu

**Scenario 6: Export danh sách check-in**
- GIVEN check-in đang diễn ra hoặc kết thúc
- WHEN tôi click "Export Check-in List"
- THEN hệ thống generate file Excel
- AND bao gồm: Student đã check-in, thời gian thực tế
- AND Student chưa check-in

---

## Story US-FRSH-021: Chụp hình Student khi check-in

**As a** TA/Student,
**I want to** chụp ảnh Student sau khi check-in,
**So that** người phỏng vấn có thể xem hình ảnh và đối chiếu với thực tế.

### Acceptance Criteria

**Scenario 1: Chụp ảnh bằng mobile**
- GIVEN Student đã được check-in
- WHEN TA/Student mở camera trên mobile
- THEN chụp ảnh Student
- AND preview ảnh trước khi upload

**Scenario 2: Upload ảnh lên hệ thống**
- GIVEN ảnh đã được chụp
- WHEN tôi click "Upload"
- THEN hệ thống upload ảnh về server
- AND gắn ảnh vào profile Student
- AND hiển thị trong danh sách check-in

**Scenario 3: Xem ảnh Student**
- GIVEN Student đã có ảnh chụp
- WHEN tôi mở danh sách Students
- THEN hiển thị thumbnail ảnh
- AND cho phép click để xem ảnh lớn
- AND cho phép download ảnh

**Scenario 4: Upload ảnh hàng loạt**
- GIVEN nhiều Students đã check-in và chụp ảnh
- WHEN tôi muốn upload hàng loạt
- THEN tôi có thể chọn nhiều file ảnh
- AND hệ thống auto match theo SBD/tên file
- AND hiển thị preview kết quả match
- AND cho phép manual fix nếu match sai

**Scenario 5: Export ảnh Student**
- GIVEN Student đã có ảnh chụp
- WHEN tôi chọn "Export Photos"
- THEN hệ thống generate ZIP file
- AND trong đó có tất cả ảnh
- AND file được đặt tên theo: [SBD]_[StudentName].jpg

---

## Story US-FRSH-022: Đánh giá kết quả bài test onsite

**As a** Manager,
**I want to** chấm điểm bài test onsite cho Student được giao,
**So that** Student có kết quả và quyết định qua vòng.

### Acceptance Criteria

**Scenario 1: Xem danh sách Student cần chấm**
- GIVEN tôi được TA phân công chấm Onsite Test
- WHEN tôi mở màn hình "Chấm Onsite Test"
- THEN hiển thị danh sách Student được giao
- AND số lượng Student cần chấm
- AND deadline chấm bài

**Scenario 2: Xem chi tiết bài làm**
- GIVEN tôi đang xem danh sách Student
- WHEN tôi click vào 1 Student
- THEN hiển thị thông tin:
  - Bài thi onsite (nếu có file)
  - Thời gian làm bài
  - Thông tin Student
- AND tôi có thể download file (nếu có)

**Scenario 3: Chấm điểm và nhận xét**
- GIVEN tôi đang xem bài thi của Student
- WHEN tôi nhập điểm
- AND nhập nhận xét (required)
- AND chọn Pass/Fail
- WHEN tôi click "Save"
- THEN kết quả được lưu
- AND status chuyển sang "Graded"

**Scenario 4: Import kết quả hàng loạt**
- GIVEN TA đã export template và thu thập kết quả từ Managers
- WHEN TA import kết quả vào hệ thống
- THEN kết quả được ghi nhận cho Students
- AND task của Managers được auto complete
- AND audit trail ghi nhận import

**Scenario 5: Validation kết quả**
- GIVEN tôi đang nhập điểm
- WHEN điểm nằm ngoài range hợp lệ
- THEN hệ thống hiển thị lỗi
- AND không cho lưu

---

## Story US-FRSH-023: Review kết quả thi Onsite

**As a** TA,
**I want to** tổng hợp kết quả thi Onsite để quyết định Student qua Interview hay Fail,
**So that** chỉ ứng viên đạt yêu cầu mới vào vòng trong.

### Acceptance Criteria

**Scenario 1: Xem danh sách kết quả**
- GIVEN Onsite Test đã có kết quả
- WHEN tôi mở màn hình "Review Results"
- THEN hiển thị danh sách Students với:
  - Điểm
  - Nhận xét
  - Pass/Fail status
- AND filter theo Pass/Fail

**Scenario 2: Bulk gửi mail mời Interview (cho Pass)**
- GIVEN tôi đã filter Students Pass
- WHEN tôi click "Send Interview Invitation"
- THEN hệ thống hiển thị wizard thiết lập Interview round
- AND khi confirm, email mời Interview được gửi

**Scenario 3: Bulk gửi mail Thank You (cho Fail)**
- GIVEN tôi đã filter Students Fail
- WHEN tôi click "Send Thank You Email"
- THEN hệ thống gợi ý template theo stage (Onsite Test Fail)
- AND hiển thị confirmation modal
- AND khi confirm, email Thank You được gửi
- AND status chuyển sang "Ended"

**Scenario 4: Exception - Fail vẫn cho Interview**
- GIVEN Student Fail nhưng tôi muốn cho Interview (exception)
- WHEN tôi click "ReOpen" cho Student
- THEN Student được đánh dấu = "Exception - Proceed"
- AND Student có thể qua vòng Interview
- AND audit trail ghi nhận exception

---

## Story US-FRSH-024: Thiết lập vòng phỏng vấn (Interview)

**As a** TA,
**I want to** thiết lập vòng phỏng vấn với ca, hội đồng, địa điểm, hình thức Online/Offline,
**So that** tôi có thể sắp xếp lịch phỏng vấn cho ứng viên và interviewers.

### Acceptance Criteria

**Scenario 1: Tạo ca phỏng vấn**
- GIVEN tôi có quyền TA
- WHEN tôi nhập thông tin ca (mô tả, ngày, giờ bắt đầu-kết thúc, hình thức Online/Offline, địa điểm, phòng, số lượng tối đa)
- AND chọn 1 hoặc nhiều Interviewers trong ca
- AND chọn 1 hoặc nhiều TA phụ trách check-in
- AND nhập deadline confirm
- WHEN tôi nhấn "Create Interview Slot"
- THEN ca phỏng vấn được tạo với status = "Open"

**Scenario 2: Thiết lập hình thức Online**
- GIVEN tôi đang tạo ca phỏng vấn
- WHEN tôi chọn hình thức = "Online"
- THEN hệ thống cho phép nhập link meeting (Zoom/Google Meet)
- VÀ địa điểm có thể để trống hoặc nhập "Online"

**Scenario 3: Validation số lượng Interviewers**
- GIVEN tôi đang tạo ca phỏng vấn
- WHEN không có Interviewer nào được chọn
- THEN hệ thống cảnh báo "Cần ít nhất 1 Interviewer"
- AND vẫn cho tạo (warning, không phải error)

**Scenario 4: Xem danh sách ca phỏng vấn**
- GIVEN vòng Interview đã có ca được tạo
- WHEN tôi mở màn hình "Ca phỏng vấn"
- THEN hiển thị danh sách ca với:
  - Ngày giờ
  - Hình thức
  - Phòng/Link
  - Số lượng đã đăng ký / tối đa

---

## Story US-FRSH-025: Gửi mail mời phỏng vấn cho Student

**As a** TA,
**I want to** gửi lịch mời phỏng vấn cho Students và chia đều vào các ca,
**So that** Students biết lịch và xác nhận tham gia.

### Acceptance Criteria

**Scenario 1: Chọn Students gửi mail mời**
- GIVEN Students đã Pass vòng trước
- WHEN tôi chọn nhiều Students
- AND click "Send Interview Invitation"
- THEN hệ thống hiển thị wizard chọn ca

**Scenario 2: Auto chia Students vào ca**
- GIVEN tôi đã chọn Students và ca
- WHEN tôi click "Auto Allocate"
- THEN hệ thống tự chia đều theo rule
- AND ưu tiên ca còn trống
- AND hiển thị preview

**Scenario 3: Manual adjust**
- GIVEN hệ thống đã auto chia
- WHEN tôi muốn điều chỉnh
- THEN tôi có thể drag-drop Student sang ca khác
- AND cảnh báo nếu quá số lượng

**Scenario 4: Gen SBD (nếu chưa có)**
- GIVEN Students chưa có SBD
- WHEN tôi confirm danh sách mời
- THEN hệ thống gen SBD
- AND lưu vào profile

**Scenario 5: Gửi mail**
- GIVEN danh sách đã được chia ca
- WHEN tôi click "Send Invitations"
- THEN email được gửi cho Students với:
  - Thông tin ca (ngày, giờ, phòng/link)
  - SBD
  - Link confirm
  - Deadline confirm
- AND log audit trail

**Scenario 6: Booking Google Calendar/Outlook**
- GIVEN ca phỏng vấn đã được setup
- AND hình thức = "Online"
- WHEN tôi gửi mail mời
- THEN hệ thống tự động tạo event trên Google Calendar/Outlook
- AND đính kèm link meeting
- AND mời Interviewers

---

## Story US-FRSH-026: Gửi mail mời phỏng vấn cho Interviewer

**As a** TA,
**I want to** gửi lịch mời phỏng vấn cho Interviewers kèm CV Student,
**So that** Interviewers biết thông tin và chuẩn bị phỏng vấn.

### Acceptance Criteria

**Scenario 1: Gửi mail cho Interviewer**
- GIVEN ca phỏng vấn đã có Interviewers được chọn
- WHEN tôi click "Send Interviewer Invitation"
- THEN hệ thống hiển thị preview email
- AND email bao gồm:
  - Thông tin ca (ngày, giờ, phòng/link)
  - Danh sách Students trong ca
  - Đính kèm CV + bảng điểm của Students
- AND khi confirm, email được gửi

**Scenario 2: Auto tạo Calendar event**
- GIVEN email được gửi cho Interviewer
- THEN hệ thống tự động tạo event trên Google Calendar/Outlook
- VÀ đính kèm link meeting (nếu Online)
- AND event bao gồm thông tin ca

**Scenario 3: Gửi 1 mail duy nhất cho nhiều ca**
- GIVEN Interviewer phụ trách nhiều ca
- WHEN tôi gửi mail mời
- THEN hệ thống gộp thành 1 email duy nhất
- AND liệt kê tất cả ca
- AND đính kèm CV của tất cả Students

**Scenario 4: Interviewer không được confirm**
- GIVEN Interviewer nhận mail mời
- WHEN Interviewer mở mail
- THEN thông báo "Lịch đã được chốt, vui lòng tham gia đúng giờ"
- AND không có link confirm (vì đã chốt trước)

---

## Story US-FRSH-027: Student phản hồi mời phỏng vấn

**As a** Student,
**I want to** xác nhận tham gia hoặc xin đổi lịch phỏng vấn,
**So that** TA biết và sắp xếp lịch phù hợp.

### Acceptance Criteria

**Scenario 1: Xác nhận tham gia (Yes)**
- GIVEN tôi nhận được email mời phỏng vấn
- AND còn thời hạn confirm
- WHEN tôi click link và chọn "Yes"
- THEN hệ thống ghi nhận tôi sẽ tham gia
- AND status = "Confirmed"
- AND slot được giữ

**Scenario 2: Từ chối (No)**
- GIVEN tôi nhận được email mời phỏng vấn
- WHEN tôi chọn "No"
- THEN hệ thống yêu cầu lý do
- AND status = "Declined"
- AND slot được giải phóng

**Scenario 3: Đổi lịch (Change) - Lần 1**
- GIVEN tôi nhận được email mời phỏng vấn
- WHEN tôi chọn "Request Change"
- THEN hệ thống hiển thị các ca còn slot
- AND tôi chọn ca mới
- AND yêu cầu gửi cho TA

**Scenario 4: Đổi lịch - Lần 2**
- GIVEN tôi đã đổi lịch 1 lần
- AND TA gửi lại mời mới
- WHEN tôi mở link confirm
- THEN chỉ còn Yes/No options
- AND thông báo "Bạn chỉ được đổi 1 lần"

**Scenario 5: Hết thời hạn confirm**
- GIVEN đã quá deadline confirm
- WHEN tôi mở link confirm
- THEN thông báo "Thời gian xác nhận đã kết thúc"
- AND hiển thị thông tin liên hệ TA
- AND actions bị disable

**Scenario 6: Remind sau khi gửi lịch mới**
- GIVEN tôi đã yêu cầu đổi lịch
- AND TA đã gửi lịch mới
- WHEN tôi chưa confirm sau 24h
- THEN hệ thống gửi mail remind
- AND mail có link confirm

---

## Story US-FRSH-028: Ghi nhận check-in phỏng vấn

**As a** TA,
**I want to** ghi nhận check-in cho Student khi đến phỏng vấn,
**So that** tôi biết Student nào đã đến và chuẩn bị cho interviewer.

### Acceptance Criteria

**Scenario 1: Search Student để check-in**
- GIVEN tôi đang ở màn hình check-in interview
- WHEN tôi nhập SBD, Student ID, SĐT, email, tên
- THEN hệ thống tìm và hiển thị Student
- AND hiển thị ca phỏng vấn, status confirm

**Scenario 2: Xác nhận check-in**
- GIVEN Student đã confirm tham gia
- WHEN tôi click "Check-in"
- THEN hệ thống ghi nhận thời gian check-in
- AND status = "Checked In"

**Scenario 3: Validation check-in**
- GIVEN Student đến sớm hoặc muộn
- WHEN tôi check-in
- THEN hệ thống cảnh báo
- AND vẫn cho phép check-in với lý do

---

## Story US-FRSH-029: Chụp hình Student khi check-in interview

**As a** TA,
**I want to** chụp ảnh Student khi check-in interview,
**So that** interviewer xem hình ảnh và đối chiếu thực tế.

### Acceptance Criteria

**Scenario 1: Chụp và upload ảnh**
- GIVEN Student đã check-in
- WHEN tôi chụp ảnh bằng mobile
- AND upload lên hệ thống
- THEN ảnh được gắn vào profile Student
- AND hiển thị trong danh sách

**Scenario 2: Xem ảnh**
- GIVEN Student đã có ảnh
- WHEN tôi mở danh sách
- THEN hiển thị thumbnail
- AND cho phép xem lớn, download

**Scenario 3: Download CV, bảng điểm**
- GIVEN Student đã check-in
- WHEN tôi muốn tải CV, bảng điểm
- THEN tôi có thể download file
- AND file được đặt tên: [FullName]_CV.pdf

---

## Story US-FRSH-030: Đánh giá kết quả phỏng vấn

**As a** Manager/Interviewer,
**I want to** chấm điểm và đề xuất Offer/Reject sau phỏng vấn,
**So that** TA tổng hợp kết quả và ra quyết định.

### Acceptance Criteria

**Scenario 1: Xem danh sách cần phỏng vấn**
- GIVEN tôi là Interviewer
- WHEN tôi mở màn hình "Phỏng vấn"
- THEN hiển thị danh sách Students trong ca của tôi
- AND thông tin CV, bảng điểm đính kèm

**Scenario 2: Chấm điểm và đề xuất**
- GIVEN tôi đã phỏng vấn xong Student
- WHEN tôi nhập điểm, nhận xét
- VÀ chọn đề xuất (Offer/Reject/Need Discussion)
- WHEN tôi click "Save"
- THEN kết quả được lưu
- AND TA có thể xem

**Scenario 3: Import kết quả hàng loạt**
- GIVEN TA đã thu thập kết quả từ Interviewers
- WHEN TA import vào hệ thống
- THEN kết quả được ghi nhận
- AND task Interviewers auto complete

---

## Story US-FRSH-031: Review kết quả phỏng vấn

**As a** TA,
**I want to** tổng hợp kết quả phỏng vấn để quyết định Offer hay Fail,
**So that** chỉ ứng viên đạt yêu cầu nhận Offer.

### Acceptance Criteria

**Scenario 1: Xem danh sách kết quả**
- GIVEN Interview đã có kết quả
- WHEN tôi mở "Review Results"
- THEN hiển thị danh sách với điểm, nhận xét, đề xuất
- AND filter theo Pass/Fail/Offer

**Scenario 2: Bulk gửi mail Offer (cho Pass)**
- GIVEN tôi đã filter Students Pass
- WHEN tôi click "Create Offer"
- THEN hệ thống hiển thị wizard tạo Offer
- AND khi confirm, Offer được tạo

**Scenario 3: Bulk gửi mail Thank You (cho Fail)**
- GIVEN tôi đã filter Students Fail
- WHEN tôi click "Send Thank You"
- THEN hệ thống gợi ý template theo stage (Interview Fail)
- AND khi confirm, email được gửi
- AND status = "Ended"

**Scenario 4: Exception - Fail vẫn cho Interview round tiếp**
- GIVEN Student Fail nhưng tôi muốn cho Interview round 2
- WHEN tôi click "ReOpen"
- THEN Student được đánh dấu = "Exception - Next Round"
- AND Student có thể qua Interview round tiếp theo

---

## Story US-FRSH-032: Tạo Offer Letter

**As a** TA,
**I want to** tạo thư mời nhận việc với mức lương, phúc lợi, deadline chấp nhận,
**So that** gửi cho ứng viên và mời nhận việc.

### Acceptance Criteria

**Scenario 1: Tạo Offer cho Student**
- GIVEN Student đã Pass Interview
- WHEN tôi nhập thông tin Offer (mức lương, phúc lợi, deadline, ngày nhận việc)
- AND chọn Request tuyển dụng matching (theo Track)
- WHEN tôi click "Create Offer"
- THEN Offer được tạo với status = "Pending"
- AND Student được transfer sang Request với status = "Waiting Offer"

**Scenario 2: Validation matching Request**
- GIVEN tôi đang tạo Offer
- WHEN tôi chọn Request không thuộc Event
- THEN hệ thống hiển thị lỗi và không cho chọn
- AND chỉ hiển thị Requests đã mapping vào Event

**Scenario 3: Chọn template Offer**
- GIVEN tôi đang tạo Offer
- WHEN tôi chọn template từ library
- THEN template được áp dụng vào Offer Letter
- AND tôi có thể customize nội dung

**Scenario 4: Gửi Offer Letter**
- GIVEN Offer đã được tạo
- WHEN tôi click "Send Offer"
- THEN email được gửi cho Student với link Offer Letter online
- AND status Offer = "Sent"
- AND audit trail ghi nhận

---

## Story US-FRSH-033: Student phản hồi Offer

**As a** Student,
**I want to** trả lời Accept hoặc Reject Offer Letter,
**So that** tôi xác nhận nhận việc hoặc từ chối.

### Acceptance Criteria

**Scenario 1: Accept Offer**
- GIVEN tôi nhận được email Offer Letter với link
- WHEN tôi mở link và chọn "Accept"
- THEN hệ thống ghi nhận tôi đã Accept
- AND status Offer = "Accepted"
- AND TA nhận được notification
- AND tôi được hướng dẫn scan documents

**Scenario 2: Reject Offer**
- GIVEN tôi nhận được email Offer Letter với link
- WHEN tôi chọn "Reject"
- THEN hệ thống yêu cầu lý do (required)
- AND status Offer = "Rejected"
- AND TA nhận được notification với lý do

**Scenario 3: Không có option Negotiate**
- GIVEN tôi muốn negotiate lương
- WHEN tôi mở link Offer
- THEN chỉ có 2 options: Accept/Reject
- AND thông báo "Nếu cần thương lượng, vui lòng liên hệ TA"

---

## Story US-FRSH-034: Scan Candidate sau khi Accept Offer

**As a** TA,
**I want to** scan documents của Candidate sau khi Accept Offer,
**So that** hoàn tất hồ sơ và transfer sang hệ thống CnB.

### Acceptance Criteria

**Scenario 1: Upload documents**
- GIVEN Candidate đã Accept Offer
- WHEN tôi upload documents (CMND, bằng cấp, etc.)
- THEN documents được lưu vào profile Candidate
- AND hiển thị checklist documents đã/ chưa upload

**Scenario 2: Scan Candidate**
- GIVEN documents đã đầy đủ
- WHEN tôi click "Scan Candidate"
- THEN hệ thống thực hiện scan
- AND kết quả scan được lưu
- AND Candidate sẵn sàng transfer

**Scenario 3: Transfer CnB**
- GIVEN Candidate đã scan xong
- WHEN tôi click "Transfer to CnB"
- THEN Candidate được transfer sang hệ thống CnB
- AND status = "Transferred"
- AND audit trail ghi nhận

---

## Story US-FRSH-035: Bulk Actions với confirmation modal

**As a** TA,
**I want to** thực hiện bulk actions (send mail, move rounds) với confirmation modal khi có mixed list,
**So that** tránh sai sót khi xử lý nhiều ứng viên cùng lúc.

### Acceptance Criteria

**Scenario 1: Visual feedback cho Failed/Rejected**
- GIVEN danh sách có Students với status Pass/Fail/Rejected
- WHEN tôi xem danh sách
- THEN rows của Failed/Rejected được dimmed (mờ nhẹ)
- AND checkbox vẫn enabled
- AND icon status có màu xám

**Scenario 2: Confirmation modal khi chọn mixed list**
- GIVEN tôi chọn nhiều Students (có cả Pass và Fail)
- WHEN tôi click "Send Interview Invitation"
- THEN hệ thống hiển thị modal:
  - Thông báo số lượng Students đã chọn
  - Cảnh báo số Students không đủ điều kiện (Fail/Rejected)
  - List "Ready to Send" với số lượng hợp lệ
  - List "Skipped" với số lượng bị loại
- AND nút "Confirm & Send (X)" với X = số hợp lệ

**Scenario 3: Auto skip Failed/Rejected**
- GIVEN modal confirmation hiển thị
- WHEN tôi confirm
- THEN action chỉ thực hiện cho Students hợp lệ
- AND Failed/Rejected bị auto skip
- AND log vào audit trail

**Scenario 4: Cancel action**
- GIVEN modal confirmation hiển thị
- WHEN tôi click "Cancel"
- THEN action bị hủy
- AND không có Students nào bị ảnh hưởng

---

## Story Index

| Story ID | Title | Actor | Category |
|----------|-------|-------|----------|
| US-FRSH-001 | Tạo Event Fresher | TA | Event Setup |
| US-FRSH-002 | Mapping Request tuyển dụng | TA | Event Setup |
| US-FRSH-003 | Thiết lập bộ câu hỏi theo Track | TA | Event Setup |
| US-FRSH-004 | Thiết lập workflow vòng tuyển dụng | TA | Event Setup |
| US-FRSH-005 | Student apply vào Event | Student | Application |
| US-FRSH-006 | Xem danh sách Student apply | TA | Screening |
| US-FRSH-007 | Cảnh báo trùng Student apply | TA | Screening |
| US-FRSH-008 | Xem chi tiết Student apply | TA | Screening |
| US-FRSH-009 | Export danh sách Student | TA | Screening |
| US-FRSH-010 | Screening Pass/Fail | TA | Screening |
| US-FRSH-011 | Tạo Assignment | TA | Online Test |
| US-FRSH-012 | Gửi Assignment cho Student | TA | Online Test |
| US-FRSH-013 | Nộp Assignment online | Student | Online Test |
| US-FRSH-014 | Chấm điểm Assignment | Manager | Online Test |
| US-FRSH-015 | Import kết quả chấm Assignment | TA | Online Test |
| US-FRSH-016 | Review kết quả Online Test | TA | Online Test |
| US-FRSH-017 | Thiết lập vòng thi Onsite | TA | Onsite Test |
| US-FRSH-018 | Gửi mail mời thi Onsite | TA | Onsite Test |
| US-FRSH-019 | Student phản hồi mời thi | Student | Onsite Test |
| US-FRSH-020 | Ghi nhận check-in onsite | TA | Onsite Test |
| US-FRSH-021 | Chụp hình khi check-in onsite | TA/Student | Onsite Test |
| US-FRSH-022 | Đánh giá kết quả Onsite Test | Manager | Onsite Test |
| US-FRSH-023 | Review kết quả Onsite Test | TA | Onsite Test |
| US-FRSH-024 | Thiết lập vòng phỏng vấn | TA | Interview |
| US-FRSH-025 | Gửi mail mời phỏng vấn cho Student | TA | Interview |
| US-FRSH-026 | Gửi mail mời phỏng vấn cho Interviewer | TA | Interview |
| US-FRSH-027 | Student phản hồi mời phỏng vấn | Student | Interview |
| US-FRSH-028 | Ghi nhận check-in phỏng vấn | TA | Interview |
| US-FRSH-029 | Chụp hình khi check-in interview | TA | Interview |
| US-FRSH-030 | Đánh giá kết quả phỏng vấn | Manager | Interview |
| US-FRSH-031 | Review kết quả phỏng vấn | TA | Interview |
| US-FRSH-032 | Tạo Offer Letter | TA | Offer |
| US-FRSH-033 | Student phản hồi Offer | Student | Offer |
| US-FRSH-034 | Scan Candidate sau Accept Offer | TA | Offer |
| US-FRSH-035 | Bulk Actions với confirmation modal | TA | Cross-Cutting |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | Initial draft created | AI Assistant | OPEN |
| | | | |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial draft from BRD |
