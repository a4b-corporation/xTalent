# ATS Fresher - Clarification Questions

**Document Type:** Requirements Clarification for BRD Construction
**Source Document:** `ATS_Flow Fresher (Sent) _ Internal (1).md`
**Date Created:** 2026-03-20
**Status:** Awaiting Responses

---

## Ambiguity Score Tracker

| Dimension | Score (0-1) | Weight | Weighted Score |
|-----------|------------|--------|----------------|
| Goal Clarity | TBD | 0.40 | TBD |
| Constraint Clarity | TBD | 0.30 | TBD |
| Success Criteria | TBD | 0.30 | TBD |
| **Total Clarity** | — | — | **TBD** |
| **Ambiguity (1-Total)** | — | — | **TBD** |

**Target:** Ambiguity ≤ 0.2 to proceed to BRD construction

---

## A. Event & Request Mapping (Critical - Must Answer Before BRD)

### A1. Event Program Type Eligibility
**Context:** Hiện tại có các Program: Job Fair, Fresher, và có thể có Program khác.

**Câu hỏi:** Event thuộc Program nào mới được map với Request tuyển dụng?

**Options:**
- [ ] Chỉ Program = "FresHER"
- [ ] Tất cả các Program
- [ ] Một danh sách cụ thể: _______________

**Default assumption nếu không trả lời:** Chỉ Fresher event mới được map Request

---

### A2. Mandatory Mapping
**Context:** Khi tạo Event Fresher, có bắt buộc phải mapping Request tuyển dụng không?

**Câu hỏi:** Event có "bắt buộc" mapping Yêu cầu tuyển dụng được không?

**Options:**
- [ ] Bắt buộc (không map không tạo được Event)
- [ ] Không bắt buộc (có thể tạo Event standalone)
- [ ] Tùy Program type

**Default assumption nếu không trả lời:** Không bắt buộc

---

### A3. One-to-Many Mapping (Request → Event)
**Context:** Một Request tuyển dụng có thể map vào bao nhiêu Event?

**Câu hỏi:** Một yêu cầu tuyển dụng có thể mapping nhiều event cùng lúc không?

**Options:**
- [ ] Có, một Request mapping nhiều Event
- [ ] Không, một Request chỉ mapping 1 Event duy nhất
- [ ] Có, nhưng chỉ khi các Event chưa start

**Default assumption nếu không trả lời:** Một Request chỉ mapping 1 Event

---

### A4. Post Job After Mapping
**Context:** Request sau khi map vào Event rồi có được Post lên Career Site không?

**Câu hỏi:** Một yêu cầu tuyển dụng sau khi đã map vào Event rồi có được Post lên CS?

**Options:**
- [ ] Không được post (chỉ apply qua Event)
- [ ] Vẫn được post bình thường
- [ ] Tùy option khi mapping (có checkbox "Allow Post Job")

**Default assumption nếu không trả lời:** Không được post lên CS

---

### A5. Unmap Conditions
**Context:** Khi nào được bỏ mapping giữa Request và Event?

**Câu hỏi:** Khi mapping request vào event rồi, thì có được bỏ mapping không? Điều kiện được/bị bỏ?

**Options:**
- [ ] Bất cứ lúc nào trước khi Event start
- [ ] Bất cứ lúc nào nếu chưa có Student apply
- [ ] Không được unmap một khi đã map
- [ ] Khác: _______________

**Default assumption nếu không trả lời:** Unmap được nếu chưa có Student apply

---

### A6. Add Mapping After Event Published
**Context:** Event đã Post lên Career Site rồi có add thêm mapping Job mới được không?

**Câu hỏi:** Khi event đã Post lên CS thì có thêm được mapping Job hay không?

**Options:**
- [ ] Có, bất cứ lúc nào
- [ ] Có, nhưng chỉ khi Event chưa start
- [ ] Không, khóa mapping khi publish

**Default assumption nếu không trả lời:** Không add được sau khi publish

---

## B. Student Apply & Multi-Track

### B1. Multi-Track Application
**Context:** Event có thể có nhiều Track (VD: Game Development, Game Design, Game QC).

**Câu hỏi:** Một Student có thể apply vào nhiều Track/Job Title khác nhau trong 1 event hay không?

**Options:**
- [ ] Có, apply unlimited Track
- [ ] Có, nhưng giới hạn __ Track
- [ ] Không, chỉ 1 Track/Student/Event

**Default assumption nếu không trả lời:** Chỉ 1 Track/Student/Event

---

### B2. Duplicate Detection Rules
**Context:** Hiện tại hệ thống detect duplicate dựa trên SĐT và StudentID.

**Câu hỏi:** Có cần thêm tiêu chí nào để detect duplicate không?

**Current rules:**
- [x] SĐT trùng
- [x] StudentID trùng
- [ ] Email trùng
- [ ] DOB trùng
- [ ] CCCD/Passport trùng
- [ ] Khác: _______________

**Default assumption nếu không trả lời:** Giữ nguyên SĐT + StudentID

---

### B3. Replace Data Definition
**Context:** Khi phát hiện duplicate, TA có option "Replace data".

**Câu hỏi:** "Replace data" cụ thể là gì?

**Options:**
- [ ] Overwrite toàn bộ thông tin Student cũ bằng thông tin Student mới
- [ ] Merge thông tin (giữ data đầy đủ nhất cho mỗi field)
- [ ] Giữ record đầu tiên, discard record sau
- [ ] Khác: _______________

**Default assumption nếu không trả lời:** Overwrite toàn bộ

---

### B4. Duplicate Tab Behavior
**Context:** Student duplicate được highlight và có tab Duplicate riêng.

**Câu hỏi:** Student sau khi được xác định duplicate có được chuyển sang tab Duplicate không?

**Options:**
- [ ] Có, tự động chuyển
- [ ] Không, chỉ highlight trong tab chính
- [ ] Tùy action của TA (move/not move)

**Default assumption nếu không trả lời:** Chỉ highlight, không chuyển tab

---

## C. Screening & Candidate RR

### C1. Candidate RR Creation on Pass
**Context:** Khi Student Pass Screening, hệ thống có tạo Candidate RR không?

**Câu hỏi:** Nếu Pass Screening sẽ tiến hành tạo thông tin Candidate RR?

**Options:**
- [ ] Có, tự động tạo
- [ ] Không, để TA manual tạo
- [ ] Tùy setting của Event

**Default assumption nếu không trả lời:** Tự động tạo

---

### C2. Candidate RR Creation on Fail
**Context:** Khi Student Fail Screening, hệ thống xử lý thế nào?

**Câu hỏi:** Nếu Fail khi Screening thì có tạo Candidate RR không?

**Options:**
- [ ] Không tạo
- [ ] Vẫn tạo nhưng mark status = Failed
- [ ] Tùy option

**Default assumption nếu không trả lời:** Không tạo

---

### C3. Failed Applicants Display
**Context:** Student fail Screening sẽ hiển thị ở đâu?

**Câu hỏi:** Nếu có Fail khi thì các Applicant bị Fail sẽ hiển thị ở đâu?

**Options:**
- [ ] Vẫn hiện ở Applicant list, chỉ đổi Result = Failed
- [ ] Chuyển sang tab Failed riêng
- [ ] Ẩn khỏi danh sách chính, chỉ xem được qua filter

**Default assumption nếu không trả lời:** Vẫn hiện ở Applicant, Result = Failed

---

### C4. Screening Result Update
**Context:** Có cho phép update Screening result sau khi đã set không?

**Câu hỏi:** Xem chi tiết có cho Update Pass/Fail không?

**Options:**
- [ ] Có, update được
- [ ] Không, một khi đã set thì không sửa
- [ ] Có, nhưng chỉ trong vòng __ giờ

**Default assumption nếu không trả lời:** Update được trước khi Student qua vòng sau

---

## D. Assignment/Online Test

### D1. Assignment Grader Assignment
**Context:** Ai chấm bài Assignment?

**Câu hỏi:** Manager chỉ được thấy các thông tin student/submission được TA giao cho đánh giá hay có thể thấy all student tham gia event?

**Options:**
- [ ] Chỉ thấy student được giao
- [ ] Thấy all student, nhưng chỉ chấm được student được giao
- [ ] Thấy all student và chấm được tất cả

**Default assumption nếu không trả lời:** Chỉ thấy student được giao

---

### D2. File Submission Format
**Context:** Format file cho phép nộp assignment.

**Câu hỏi:** Format file nào được chấp nhận? Size giới hạn?

**Current rules:**
- [x] Word (.doc/.docx)
- [x] PDF (.pdf)
- [x] Excel (.xls/.xlsx)
- [x] PowerPoint (.ppt/.pptx)
- [ ] ZIP (.zip) - nếu nhiều file
- [ ] RAR (.rar)
- [ ] Khác: _______________

**Size limit:** _______________ MB (default: 10MB)

**Default assumption nếu không trả lời:** Word/PDF/Excel/PPT, 10MB

---

### D3. Multiple File Submission
**Context:** Student có được nộp nhiều file không?

**Câu hỏi:** Có được nộp nhiều file không? Hay cần phải zip lại?

**Options:**
- [ ] Nộp nhiều file trực tiếp (không cần zip)
- [ ] Phải zip lại nếu > 1 file
- [ ] Tùy setting của Assignment

**Default assumption nếu không trả lời:** Nộp nhiều file trực tiếp

---

### D4. File Preview Behavior
**Context:** Khi xem submission, file nào preview được?

**Câu hỏi:** 1 file thì preview, nhiều file thì zip - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Preview từng file riêng lẻ (không cần zip)
- [ ] Chỉ preview PDF, còn lại download

**Default assumption nếu không trả lời:** Preview từng file riêng lẻ

---

### D5. Grader Notification
**Context:** TA có nhận thông báo khi Student nộp submission không?

**Câu hỏi:** TA có nhận được thông báo khi Student nộp Submission không?

**Options:**
- [ ] Có, email notification
- [ ] Có, in-app notification
- [ ] Không cần thông báo

**Default assumption nếu không trả lời:** Không cần thông báo

---

### D6. Manager Completion Notification
**Context:** TA có nhận thông báo khi Manager chấm xong không?

**Câu hỏi:** TA có nhận được thông báo khi Manager đánh giá xong không?

**Options:**
- [ ] Có, email notification
- [ ] Có, in-app notification
- [ ] Không cần thông báo

**Default assumption nếu không trả lời:** Không cần thông báo

---

### D7. Task Auto-Complete on Import
**Context:** Khi TA import kết quả, task của Manager có auto complete không?

**Câu hỏi:** Task đã tạo cho người chấm nhưng không thực hiện (do gửi upload kết quả), vậy sau khi upload kết quả thì task sẽ auto completed và ghi nhận lý do?

**Options:**
- [ ] Có, auto complete với lý do "Result imported by TA"
- [ ] Không, Manager vẫn phải manual mark complete
- [ ] Tùy option khi import

**Default assumption nếu không trả lời:** Auto complete

---

## E. Onsite Test & Interview

### E1. SBD Generation Timing
**Context:** Khi nào gen Số báo danh cho Student?

**Câu hỏi:** Cơ chế gen Số báo danh - từ vòng nào?

**Options:**
- [ ] Từ vòng Onsite Test
- [ ] Từ vòng Interview
- [ ] Từ khi tạo Event
- [ ] Khi Student confirm tham gia

**Default assumption nếu không trả lời:** Từ vòng Onsite Test

---

### E2. Onsite Grader Without Setup
**Context:** Nếu không setup người chấm khi tạo bài test onsite, ai được quyền chấm?

**Câu hỏi:** Nếu ở step không setup người chấm thì sẽ phân quyền cho những user manager nào được phép vào chấm bài test onsite?

**Options:**
- [ ] Tất cả Manager
- [ ] TA sẽ import kết quả
- [ ] Manager của Event/Program đó

**Default assumption nếu không trả lời:** TA sẽ import kết quả

---

### E3. Interview Online Support
**Context:** Có hỗ trợ phỏng vấn Online không?

**Câu hỏi:** Có hỗ trợ phỏng vấn Online không?

**Options:**
- [ ] Có, tích hợp video call
- [ ] Có, qua link third-party (Zoom/Google Meet)
- [ ] Không, chỉ Offline

**Default assumption nếu không trả lời:** Có, qua link third-party

---

### E4. Interviewer See Other Candidates
**Context:** Interviewer có thấy các candidate không thuộc scope đánh giá không?

**Câu hỏi:** Có được thấy các student khác không thuộc phạm vi hội đồng phụ trách?

**Options:**
- [ ] Không, chỉ thấy candidate được giao
- [ ] Có, thấy tất cả nhưng chỉ chấm được candidate được giao
- [ ] Có, thấy và chấm được tất cả

**Default assumption nếu không trả lời:** Chỉ thấy candidate được giao

---

### E5. Same Program Candidates Visibility
**Context:** Nếu cùng 1 Program, interviewer có thấy tất cả candidate không?

**Câu hỏi:** Nếu cùng 1 program sẽ thấy bình thường?

**Options:**
- [ ] Có, thấy tất cả candidate trong Program
- [ ] Không, vẫn chỉ thấy candidate được giao
- [ ] Tùy setting

**Default assumption nếu không trả lời:** Thấy tất cả candidate trong Program

---

### E6. Room Booking Method
**Context:** Booking phòng interview tự động hay manual?

**Câu hỏi:** (có thể gõ tay phòng vì lễ tân book phòng đó rồi) - Vậy có cần auto book Google Calendar/Outlook không?

**Options:**
- [ ] Có, auto book Google Calendar/Outlook
- [ ] Không, manual gõ tay phòng
- [ ] Tùy option

**Default assumption nếu không trả lời:** Manual gõ tay

---

### E7. Interviewer Change Request
**Context:** Interviewer có được quyền request đổi lịch không?

**Câu hỏi:** Interviewers có quyền phản hồi thay đổi thời gian phỏng vấn không?

**Options:**
- [ ] Có, được request đổi
- [ ] Không, đã chốt không đổi
- [ ] Có, nhưng chỉ trong vòng __ giờ

**Default assumption nếu không trả lời:** Không, đã chốt không đổi

---

## F. Offer

### F1. Offer Template Customization
**Context:** Template Offer Letter có customize được không?

**Câu hỏi:** Template mail gửi offer được phép customize design theo nhiều style?

**Options:**
- [ ] Có, customize hoàn toàn
- [ ] Có, nhưng chỉ chọn từ template có sẵn
- [ ] Không, fixed template

**Default assumption nếu không trả lời:** Chọn từ template có sẵn

---

### F2. Offer Negotiate Option
**Context:** Hiện tại ATS chỉ có Accept hoặc Reject.

**Câu hỏi:** Có cần thêm option Negotiate khi Student phản hồi Offer không?

**Options:**
- [ ] Có, thêm option Negotiate
- [ ] Không, chỉ Accept/Reject
- [ ] Có, nhưng chỉ cho một số Event/Program

**Default assumption nếu không trả lời:** Không, chỉ Accept/Reject

---

### F3. Failed Stage Mail Template
**Context:** Mỗi stage Fail (Screening Fail vs Interview Fail) có template mail cảm ơn khác nhau.

**Câu hỏi:** Hệ thống tự gợi ý template dựa trên stage hiện tại - có đúng không?

**Options:**
- [ ] Đúng, auto suggest template theo stage
- [ ] Không, TA chọn template manually
- [ ] Chỉ 1 template duy nhất cho tất cả

**Default assumption nếu không trả lời:** Auto suggest template theo stage

---

### F4. Thank You Letter After Send
**Context:** Khi đã Send Mail Thanks rồi có được Send nữa không?

**Câu hỏi:** Khi đã Send Mail Thanks rồi có được Send nữa không?

**Options:**
- [ ] Không, chỉ send 1 lần
- [ ] Có, send lại được nhưng có cảnh báo
- [ ] Có, send unlimited

**Default assumption nếu không trả lời:** Không, chỉ send 1 lần

---

### F5. Create Offer Transfer
**Context:** Khi Create Offer thành công sẽ chuyển Candidate qua Request tương ứng.

**Câu hỏi:** Khi Create Offer thành công, Candidate được transfer qua Request nào?

**Options:**
- [ ] Request mà Student đã apply từ đầu
- [ ] Request mà TA chọn khi Create Offer
- [ ] Request default (matching theo Track)

**Default assumption nếu không trả lời:** Request matching theo Track

---

## G. Bulk Actions & UI

### G1. Visual Feedback for Failed/Rejected
**Context:** Khi Fail/Reject, row sẽ dimmed nhưng vẫn chọn được.

**Câu hỏi:** Hàng đó (row) nên được làm mờ nhẹ (dimmed) hoặc icon trạng thái có xám rõ rệt, nhưng vẫn cho phép Checkbox - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Không cho checkbox (disable hoàn toàn)
- [ ] Vẫn hiển thị bình thường, không dim

**Default assumption nếu không trả lời:** Dimmed nhưng vẫn checkbox được

---

### G2. Confirmation Modal for Mixed Selection
**Context:** Khi TA chọn mixed list (Pass + Fail), hệ thống sẽ cảnh báo và tự động skip Fail.

**Câu hỏi:** Khi chọn một danh sách hỗn hợp (gồm cả Pass, Fail) và bấm nút Interview/Interview Setting, hệ thống phải hiện ra một Pop-up xác nhận - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Không cần modal, tự động skip fail
- [ ] Cảnh báo nhưng vẫn cho chọn tất cả

**Default assumption nếu không trả lời:** Đúng như mô tả

---

### G3. Resend Invitation Flow
**Context:** Khi ứng viên vào hàng chờ và TA sắp xếp được lịch, TA có gửi lại thư mời không?

**Câu hỏi:** Nếu ứng viên vào hàng chờ và sau đó TA sắp xếp được lịch (manual), TA sẽ thao tác trên hệ thống để gửi lại thư mời (button Resend Invitation) - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Không, hệ thống auto gửi
- [ ] Tùy option

**Default assumption nếu không trả lời:** Đúng như mô tả

---

### G4. Second Invitation Options
**Context:** Student chọn Thay đổi và TA gửi lịch mới (lần 2) thì chỉ còn 2 option Yes or No.

**Câu hỏi:** Student chọn Thay đổi và TA gửi lịch mới (lần 2) thì chỉ còn 2 option Yes or No - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Vẫn đầy đủ 3 option (Yes/No/Change)
- [ ] Tùy setting

**Default assumption nếu không trả lời:** Đúng như mô tả

---

## H. Dynamic Columns & Export

### H1. Dynamic Column Display
**Context:** Danh sách applicant sẽ dynamic số cột do event đang dynamic field và question.

**Câu hỏi:** TA có thể chọn hiển thị column nào (Field/Question), mặc định sẽ ẩn bộ câu hỏi, khi filter theo Track thì câu hỏi ra tương ứng - có đúng không?

**Options:**
- [ ] Đúng như mô tả
- [ ] Hiển thị tất cả column mặc định
- [ ] Chỉ hiển thị column cố định

**Default assumption nếu không trả lời:** Đúng như mô tả

---

### H2. Export Template
**Câu hỏi:** Template export sẽ bao gồm những cột nào? Nghiệp vụ gửi lại template export cụ thể?

**Answer:** _______________

**Default assumption nếu không trả lời:** Export tất cả Field + Question + Answer

---

### H3. Report Template
**Câu hỏi:** Template report trên các thông tin applicant sẽ bao gồm những gì? Nghiệp vụ gửi lại template report?

**Answer:** _______________

**Default assumption nếu không trả lời:** Report tiêu chí phù hợp để chọn lọc

---

## I. Questions from Original Document (Unanswered)

Đây là các câu hỏi từ tài liệu gốc chưa được trả lời:

| # | Question | Status | Answer |
|---|----------|--------|--------|
| 1 | Replace data là gì? | Open | _______________ |
| 2 | Student đã xác định duplicate có được quay về not duplicate? | Open | _______________ |
| 3 | Xem chi tiết có cho Update Pass/Fail không? | Open | _______________ |
| 4 | TA có nhận thông báo khi Student nộp submission? | Open | _______________ |
| 5 | Manager chỉ thấy student được giao hay thấy all? | Open | _______________ |
| 6 | TA có nhận thông báo khi Manager chấm xong? | Open | _______________ |
| 7 | Nếu không setup người chấm, ai được quyền chấm? | Open | _______________ |
| 8 | Interviewer có thấy các candidate không thuộc scope? | Open | _______________ |
| 9 | TA có nhận thông báo khi Student phản hồi Yes/No/Change? | Open | _______________ |
| 10 | Student không phản hồi thì sao? Có remind không? | Open | _______________ |
| 11 | Nếu Offer reject thì gửi mail thank you rồi end? | Open | _______________ |

---

## J. Business Rules Confirmation

Xác nhận các business rules quan trọng:

### JR1. Event Flow Types
**Context:** Có nhiều flow áp dụng cho Event type Fresher và Non-Fresher.

**Fresher Flow:**
- [ ] Screening → Test Online (n) → Test Onsite (n) → Interview (n) → Offer
- [ ] Screening → Test Onsite (n) → Interview (n) → Offer
- [ ] Screening → Interview (n) → Offer

**Non-Fresher Flow:**
- [ ] Screening → Done
- [ ] Screening → Mời check in → Check in → Done

**Câu hỏi:** Các flow này có đúng như mô tả không? Có cần thêm flow nào không?

**Answer:** _______________

---

### JR2. Candidate Duplicate Rule
**Context:** Rule bắt trùng candidate khi tạo Candidate RR.

**Câu hỏi:** Rule bắt trùng candidate dựa trên tiêu chí nào?

**Options:**
- [ ] SĐT + Email
- [ ] SĐT + CCCD
- [ ] Email + CCCD
- [ ] Khác: _______________

**Default assumption nếu không trả lời:** SĐT + Email

---

### JR3. Bulk Action Confirmation
**Context:** Khi TA chọn multiple students để action (send mail, move to next round).

**Câu hỏi:** Có cần confirmation modal trước khi action không?

**Options:**
- [ ] Có, luôn confirm
- [ ] Không, action ngay
- [ ] Tùy action (important actions confirm, normal actions không)

**Default assumption nếu không trả lời:** Luôn confirm

---

## K. Additional Requirements

**Câu hỏi:** Có yêu cầu nào khác không có trong tài liệu này không?

**Answer:** _______________

---

## L. Priority & Timeline

**Câu hỏi:** Priority của project này là gì? Timeline mong muốn?

**Priority:**
- [ ] High (cần gấp trong __ tuần)
- [ ] Medium (trong __ tháng)
- [ ] Low (khi có thời gian)

**Timeline:** _______________

---

## M. Stakeholder Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Business Owner | _______________ | _______________ | _______________ |
| TA Representative | _______________ | _______________ | _______________ |
| Technical Lead | _______________ | _______________ | _______________ |
| Product Owner | _______________ | _______________ | _______________ |

---

## Instructions for Filling This Document

1. **Trả lời từng câu hỏi** bằng cách:
   - Tick [x] vào ô phù hợp
   - Điền vào chỗ trống _______________
   - Hoặc comment chi tiết nếu cần giải thích thêm

2. **Đối với câu hỏi Critical (Section A):** Phải trả lời trước khi xây dựng BRD

3. **Đối với câu hỏi có "Default assumption":** Nếu không trả lời, sẽ dùng default assumption để xây dựng BRD draft

4. **Sau khi điền xong:** Gửi lại document này để tiến hành xây dựng BRD

---

## Next Steps After Completion

1. Calculate Ambiguity Score
2. If Ambiguity ≤ 0.2 → Proceed to BRD construction
3. If Ambiguity > 0.2 → Schedule follow-up interview
4. Build BRD at `1.reality/brd.md`
5. Build Feature Catalog at `features/catalog.md`
6. Build Feature Specs at `features/**/*.fsd.md`
