# Event Storming Summary — ATS Fresher Module

> **Date:** 2026-03-20
> **Participants:** AI Assistant (facilitator), BA Team (stakeholder)
> **Duration:** 4 hours (estimated)
> **Source Documents:** `1.reality/brd.md`, `1.reality/user-stories.md`

---

## Session Info

| Attribute | Value |
|-----------|-------|
| **Domain** | ATS Fresher — Applicant Tracking System for Fresher Recruitment |
| **Session Type** | Big Picture Event Storming |
| **Facilitator** | AI Assistant |
| **Stakeholders** | BA Team (via BRD/User Stories) |
| **Status** | DRAFT — Awaiting stakeholder review |

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Domain Events (🟠) | 47 |
| Commands (🔵) | 42 |
| Actors (🟡) | 8 |
| Hot Spots (❓) | 15 |
| Discovery Questions | 12 |
| Policies | 8 |

---

## Actors (🟡)

| ID | Actor | Type | Role | Commands Issued | Events Responded To |
|----|-------|------|------|-----------------|---------------------|
| A01 | **TA** | Human | Talent Acquisition — Event organizer | CreateEvent, MapRequest, AddQuestions, SetupWorkflow, ScreenApplicant, SendAssignment, SendTestInvitation, SendInterviewInvitation, CreateSlot, CheckInStudent, ImportResult, CreateOffer, BulkAction | EventCreated, RequestMapped, ApplicantSubmitted, ScreeningCompleted, AssignmentSubmitted, TestCompleted, InterviewCompleted, OfferAccepted |
| A02 | **Student** | Human | Applicant for Fresher Event | ApplyEvent, SubmitAssignment, ConfirmSchedule, RequestChange, CheckIn, SubmitOfferResponse | EventPublished, AssignmentSent, TestInvitationSent, InterviewInvitationSent, OfferSent, ScreeningCompleted |
| A03 | **Manager** | Human | Hiring Manager — Grader/Interviewer | GradeAssignment, GradeOnsiteTest, GradeInterview, ProposeResult | AssignmentToGrade, OnsiteTestToGrade, InterviewToGrade |
| A04 | **Interviewer** | Human | Interview panel member | GradeInterview, ProposeOffer | InterviewToGrade, InterviewCompleted |
| A05 | **System** | System | Automated processor | AutoGenerateSBD, AutoAllocateSlot, AutoSendEmail, AutoCreateCandidateRR, AutoDetectDuplicate, AutoCompleteTask | ApplicantSubmitted, ScreeningPass, ScheduleConfirmed, ResultImported |
| A06 | **Career Site** | External System | External job portal | — | EventPublished, RequestMapped |
| A07 | **Email Service** | External System | SMTP/SendGrid | SendEmail | EmailRequested |
| A08 | **HR Admin** | Human | Policy administrator | ManageTemplates, ViewReports | — |

---

## Domain Events (🟠)

### Event Setup Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E01 | **EventCreated** | Event Fresher được tạo với thông tin cơ bản | TA tạo Event | High |
| E02 | **RequestMapped** | Request tuyển dụng được mapping vào Event | TA mapping Request | High |
| E03 | **QuestionsAdded** | Bộ câu hỏi được add cho Track | TA chọn bộ câu hỏi | High |
| E04 | **WorkflowConfigured** | Workflow vòng tuyển dụng được thiết lập | TA thiết lập workflow | High |
| E05 | **EventPublished** | Event được post lên Career Site | TA publish Event | High |

### Application Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E06 | **ApplicantSubmitted** | Student đã apply vào Event | Student submit application | High |
| E07 | **DuplicateDetected** | Hệ thống phát hiện ứng viên trùng | System auto-detect | High |
| E08 | **ApplicationReviewed** | TA đã review application | TA review xong | High |

### Screening Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E09 | **ScreeningCompleted** | Kết quả Screening được ghi nhận (Pass/Fail) | TA quyết định Pass/Fail | High |
| E10 | **CandidateRRCreated** | Candidate RR được tạo trong hệ thống | System auto-create khi Pass | High |
| E11 | **DuplicateResolved** | Duplicate case được resolve (Remove/Replace) | TA resolve duplicate | High |

### Online Test Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E12 | **AssignmentCreated** | Bài kiểm tra Online được tạo | TA tạo Assignment | High |
| E13 | **AssignmentSent** | Assignment được gửi cho Students | TA gửi mail | High |
| E14 | **AssignmentSubmitted** | Student nộp bài làm | Student submit | High |
| E15 | **AssignmentGraded** | Bài làm được chấm điểm | Manager chấm xong | High |
| E16 | **ResultsImported** | Kết quả chấm được import hàng loạt | TA import | High |
| E17 | **OnlineTestCompleted** | Vòng Online Test hoàn tất | TA review kết quả | High |

### Onsite Test Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E18 | **OnsiteSlotCreated** | Ca thi onsite được tạo | TA tạo ca thi | High |
| E19 | **TestInvitationSent** | Email mời thi onsite được gửi | TA gửi mail | High |
| E20 | **SBDGenerated** | Số báo danh được gen cho Student | System auto-generate | High |
| E21 | **ScheduleConfirmed** | Student xác nhận tham gia | Student confirm | High |
| E22 | **ScheduleChanged** | Lịch thi được thay đổi | TA/Student request | Medium |
| E23 | **StudentCheckedIn** | Student đã check-in onsite | TA check-in | High |
| E24 | **PhotoCaptured** | Ảnh Student được chụp khi check-in | TA/Student chụp | High |
| E25 | **OnsiteTestGraded** | Bài thi onsite được chấm điểm | Manager chấm xong | High |
| E26 | **OnsiteTestCompleted** | Vòng Onsite Test hoàn tất | TA review kết quả | High |

### Interview Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E27 | **InterviewSlotCreated** | Ca phỏng vấn được tạo | TA tạo ca | High |
| E28 | **InterviewInvitationSent** | Email mời phỏng vấn được gửi | TA gửi mail | High |
| E29 | **InterviewerInvited** | Interviewer được mời tham gia | TA gửi mail | High |
| E30 | **InterviewScheduleConfirmed** | Lịch phỏng vấn được xác nhận | Student confirm | High |
| E31 | **InterviewCompleted** | Phỏng vấn đã diễn ra | Interviewer check-in | High |
| E32 | **InterviewGraded** | Kết quả phỏng vấn được ghi nhận | Manager chấm xong | High |
| E33 | **InterviewCompleted** | Vòng Interview hoàn tất | TA review kết quả | High |

### Offer Phase

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E34 | **OfferCreated** | Offer Letter được tạo | TA tạo Offer | High |
| E35 | **OfferSent** | Offer Letter được gửi cho Student | System gửi mail | High |
| E36 | **OfferAccepted** | Student chấp nhận Offer | Student Accept | High |
| E37 | **OfferRejected** | Student từ chối Offer | Student Reject | High |
| E38 | **CandidateScanned** | Candidate được scan sau khi Accept | TA scan documents | High |
| E39 | **CandidateTransferred** | Candidate được transfer sang CnB | TA transfer | High |

### Cross-Cutting Events

| ID | Event | Description | Trigger | Confidence |
|----|-------|-------------|---------|------------|
| E40 | **EmailSent** | Email được gửi thành công | Email Service | High |
| E41 | **EmailFailed** | Email gửi thất bại | Email Service | High |
| E42 | **BulkActionCompleted** | Bulk action hoàn tất | System process | High |
| E43 | **ThankYouSent** | Email Thank You được gửi | TA gửi | High |
| E44 | **TaskCreated** | Task được tạo cho Manager | System auto-create | High |
| E45 | **TaskCompleted** | Task được hoàn tất | Manager/System | High |
| E46 | **ReportGenerated** | Report được generate | TA request | Medium |
| E47 | **TemplateApplied** | Template được áp dụng | TA chọn template | High |

---

## Commands (🔵)

### Event Setup Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C01 | **CreateEvent** | TA | TA has permission, Program = Fresher | EventCreated |
| C02 | **MapRequest** | TA | Event exists, Request is Approved & not posted | RequestMapped |
| C03 | **AddQuestions** | TA | Track exists, Questionnaire available | QuestionsAdded |
| C04 | **ConfigureWorkflow** | TA | Event exists | WorkflowConfigured |
| C05 | **PublishEvent** | TA | Event setup complete | EventPublished |

### Application Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C06 | **ApplyEvent** | Student | Event is active, Student not applied | ApplicantSubmitted |
| C07 | **DetectDuplicate** | System | Application submitted | DuplicateDetected |
| C08 | **ResolveDuplicate** | TA | Duplicate detected | DuplicateResolved |
| C09 | **ReviewApplication** | TA | Application submitted | ApplicationReviewed |

### Screening Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C10 | **ScreenPass** | TA | Application reviewed | ScreeningCompleted (Pass) |
| C11 | **ScreenFail** | TA | Application reviewed | ScreeningCompleted (Fail) |
| C12 | **CreateCandidateRR** | System | Screening = Pass | CandidateRRCreated |
| C13 | **ExportApplicants** | TA | Applications exist | ReportGenerated |

### Online Test Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C14 | **CreateAssignment** | TA | Event exists, TA has permission | AssignmentCreated |
| C15 | **SendAssignment** | TA | Assignment created, Students selected | AssignmentSent |
| C16 | **SubmitAssignment** | Student | Assignment received, Before deadline | AssignmentSubmitted |
| C17 | **GradeAssignment** | Manager | Assignment submitted, Manager assigned | AssignmentGraded |
| C18 | **ImportResults** | TA | Results collected from Managers | ResultsImported |
| C19 | **ReviewOnlineTest** | TA | Results imported/graded | OnlineTestCompleted |

### Onsite Test Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C20 | **CreateOnsiteSlot** | TA | Event exists, Onsite round configured | OnsiteSlotCreated |
| C21 | **SendTestInvitation** | TA | Students selected, Slots available | TestInvitationSent |
| C22 | **GenerateSBD** | System | Students allocated to slots | SBDGenerated |
| C23 | **ConfirmSchedule** | Student | Invitation received, Before deadline | ScheduleConfirmed |
| C24 | **RequestScheduleChange** | Student | Invitation received, Before deadline | ScheduleChanged |
| C25 | **CheckInStudent** | TA | Student arrived, At venue | StudentCheckedIn |
| C26 | **CapturePhoto** | TA/Student | Student checked in | PhotoCaptured |
| C27 | **GradeOnsiteTest** | Manager | Onsite test completed | OnsiteTestGraded |
| C28 | **ReviewOnsiteTest** | TA | Results graded | OnsiteTestCompleted |

### Interview Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C29 | **CreateInterviewSlot** | TA | Event exists, Interview round configured | InterviewSlotCreated |
| C30 | **SendInterviewInvitation** | TA | Students selected, Slots available | InterviewInvitationSent |
| C31 | **InviteInterviewer** | TA | Interview slot created | InterviewerInvited |
| C32 | **ConfirmInterviewSchedule** | Student | Invitation received | InterviewScheduleConfirmed |
| C33 | **CheckInInterview** | TA | Student arrived | InterviewCompleted |
| C34 | **GradeInterview** | Manager/Interviewer | Interview completed | InterviewGraded |
| C35 | **ReviewInterview** | TA | Results graded | InterviewCompleted |

### Offer Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C36 | **CreateOffer** | TA | Interview = Pass, Request matched | OfferCreated |
| C37 | **SendOffer** | TA | Offer created | OfferSent |
| C38 | **AcceptOffer** | Student | Offer received, Before deadline | OfferAccepted |
| C39 | **RejectOffer** | Student | Offer received, Before deadline | OfferRejected |
| C40 | **ScanCandidate** | TA | Offer accepted, Documents ready | CandidateScanned |
| C41 | **TransferCandidate** | TA | Candidate scanned | CandidateTransferred |

### Cross-Cutting Commands

| ID | Command | Actor | Preconditions | Resulting Event |
|----|---------|-------|---------------|-----------------|
| C42 | **SendEmail** | System | Email requested | EmailSent/EmailFailed |
| C43 | **SendThankYou** | TA | Decision = Fail/Reject | ThankYouSent |
| C44 | **CreateTask** | System | Action requires grading | TaskCreated |
| C45 | **CompleteTask** | Manager/System | Action completed | TaskCompleted |
| C46 | **BulkAction** | TA | Multiple students selected | BulkActionCompleted |
| C47 | **ApplyTemplate** | TA | Template available | TemplateApplied |

---

## Event Timeline

### Happy Path — Full Pipeline

```mermaid
sequenceDiagram
    participant S as Student
    participant TA as TA
    participant SYS as System
    participant M as Manager
    participant E as Email Service

    Note over TA,SYS: Event Setup
    TA->>SYS: CreateEvent
    SYS->>SYS: EventCreated
    TA->>SYS: MapRequest
    SYS->>SYS: RequestMapped
    TA->>SYS: AddQuestions
    SYS->>SYS: QuestionsAdded
    TA->>SYS: ConfigureWorkflow
    SYS->>SYS: WorkflowConfigured
    TA->>SYS: PublishEvent
    SYS->>SYS: EventPublished

    Note over S,SYS: Application
    S->>SYS: ApplyEvent
    SYS->>SYS: ApplicantSubmitted
    SYS->>SYS: DuplicateDetected

    Note over TA,SYS: Screening
    TA->>SYS: ScreenPass
    SYS->>SYS: ScreeningCompleted
    SYS->>SYS: CandidateRRCreated

    Note over TA,S,M: Online Test
    TA->>SYS: CreateAssignment
    SYS->>SYS: AssignmentCreated
    TA->>SYS: SendAssignment
    SYS->>E: SendEmail
    E->>SYS: EmailSent
    SYS->>SYS: AssignmentSent
    S->>SYS: SubmitAssignment
    SYS->>SYS: AssignmentSubmitted
    M->>SYS: GradeAssignment
    SYS->>SYS: AssignmentGraded
    TA->>SYS: ReviewOnlineTest
    SYS->>SYS: OnlineTestCompleted

    Note over TA,S,M: Onsite Test
    TA->>SYS: CreateOnsiteSlot
    SYS->>SYS: OnsiteSlotCreated
    TA->>SYS: SendTestInvitation
    SYS->>E: SendEmail
    E->>SYS: EmailSent
    SYS->>SYS: TestInvitationSent
    SYS->>SYS: SBDGenerated
    S->>SYS: ConfirmSchedule
    SYS->>SYS: ScheduleConfirmed
    TA->>SYS: CheckInStudent
    SYS->>SYS: StudentCheckedIn
    TA->>SYS: CapturePhoto
    SYS->>SYS: PhotoCaptured
    M->>SYS: GradeOnsiteTest
    SYS->>SYS: OnsiteTestGraded
    TA->>SYS: ReviewOnsiteTest
    SYS->>SYS: OnsiteTestCompleted

    Note over TA,S,M: Interview
    TA->>SYS: CreateInterviewSlot
    SYS->>SYS: InterviewSlotCreated
    TA->>SYS: SendInterviewInvitation
    SYS->>E: SendEmail
    E->>SYS: EmailSent
    SYS->>SYS: InterviewInvitationSent
    S->>SYS: ConfirmInterviewSchedule
    SYS->>SYS: InterviewScheduleConfirmed
    TA->>SYS: CheckInInterview
    SYS->>SYS: InterviewCompleted
    M->>SYS: GradeInterview
    SYS->>SYS: InterviewGraded
    TA->>SYS: ReviewInterview
    SYS->>SYS: InterviewCompleted

    Note over TA,S: Offer
    TA->>SYS: CreateOffer
    SYS->>SYS: OfferCreated
    TA->>SYS: SendOffer
    SYS->>E: SendEmail
    E->>SYS: EmailSent
    SYS->>SYS: OfferSent
    S->>SYS: AcceptOffer
    SYS->>SYS: OfferAccepted
    TA->>SYS: ScanCandidate
    SYS->>SYS: CandidateScanned
    TA->>SYS: TransferCandidate
    SYS->>SYS: CandidateTransferred
```

### Alternative Path — Fail at Screening

```
🟡 Student → 🔵 ApplyEvent → 🟠 ApplicantSubmitted
  ↓
🟡 TA → 🔵 ScreenFail → 🟠 ScreeningCompleted (Fail)
  ↓
🟡 System → 🔵 CreateTask (Send Thank You) → 🟠 TaskCreated
  ↓
🟡 TA → 🔵 SendThankYou → 🟠 ThankYouSent
  ↓
🟠 END (No Candidate RR created)
```

### Alternative Path — Duplicate Detected

```
🟡 Student → 🔵 ApplyEvent → 🟠 ApplicantSubmitted
  ↓
🟡 System → 🔵 DetectDuplicate → 🟠 DuplicateDetected
  ↓
🟡 TA → 🔵 ResolveDuplicate (Remove/Replace) → 🟠 DuplicateResolved
  ↓
[If Remove] → Application rejected
[If Replace] → Continue with merged data
```

### Alternative Path — Schedule Change Request

```
🟡 System → 🔵 SendTestInvitation → 🟠 TestInvitationSent
  ↓
🟡 Student → 🔵 RequestScheduleChange → 🟠 ScheduleChanged
  ↓
🟡 System → 🔵 CheckSlotAvailability → IF slot available
  ↓
🟡 System → 🔵 ReallocateSlot → 🟠 ScheduleChanged
  ↓
🟡 System → 🔵 SendEmail → 🟠 EmailSent (new schedule)
```

### Alternative Path — Offer Rejected

```
🟡 TA → 🔵 SendOffer → 🟠 OfferSent
  ↓
🟡 Student → 🔵 RejectOffer → 🟠 OfferRejected
  ↓
🟡 TA → 🔵 ReOpen (exception) OR Close
  ↓
[If ReOpen] → Continue with next round
[If Close] → 🟠 ThankYouSent → END
```

---

## Policies (Business Rules as Policies)

| ID | Policy | Trigger | Action |
|----|--------|---------|--------|
| P01 | **Single Track Application** | Student apply Event | Only allow 1 Track per Event |
| P02 | **Duplicate Detection** | ApplicantSubmitted | Check SĐT + StudentID match |
| P03 | **Auto Create Candidate RR** | ScreeningCompleted (Pass) | Auto create Candidate RR |
| P04 | **No Candidate RR on Fail** | ScreeningCompleted (Fail) | Do NOT create Candidate RR |
| P05 | **SBD Generation** | Allocated to Onsite Slot | Auto generate SBD |
| P06 | **Thank You Template Selection** | SendThankYou | Auto select template based on stage |
| P07 | **Bulk Action Validation** | BulkAction requested | Skip Failed/Rejected candidates |
| P08 | **Schedule Change Limit** | RequestScheduleChange | Allow only 1 change per Student |

---

## Hot Spots (❓)

| ID | Hot Spot | Type | Priority | Related Event/Command | Owner | Status |
|----|----------|------|----------|----------------------|-------|--------|
| H01 | ❓ Khi Student request đổi lịch và không có slot trống, hệ thống đưa vào hàng chờ — khi nào và như thế nào để auto-allocate slot từ hàng chờ? | Ambiguity | P0 | ScheduleChanged, RequestScheduleChange | BA | Open |
| H02 | ❓ Deadline confirm cho Interviewer là bao lâu? Có khác với Student deadline không? | Missing Info | P1 | InterviewerInvited | BA | Open |
| H03 | ❓ Khi OfferRejected, TA có được tạo Offer mới cho cùng 1 Candidate không? Hay Candidate bị loại hoàn toàn? | Ambiguity | P0 | OfferRejected | BA | Open |
| H04 | ❓ Bulk Action khi chọn mixed list (Pass + Fail) — nếu TA force chọn Fail candidates thì sao? Có override được không? | Edge Case | P1 | BulkAction | Tech Lead | Open |
| H05 | ❓ PhotoCaptured có bắt buộc không? Nếu TA quên chụp ảnh thì hệ thống có block qua vòng sau không? | Ambiguity | P2 | PhotoCaptured | BA | Open |
| H06 | ❓ Interviewer có thể update kết quả sau khi đã submit không? Deadline là khi nào? | Missing Info | P1 | GradeInterview | BA | Open |
| H07 | ❓ Candidate RR được tạo tự động khi Pass Screening — nếu TA muốn manual tạo thì có được không? | Edge Case | P2 | CreateCandidateRR | BA | Open |
| H08 | ❓ EmailFailed — retry policy là gì? Retry bao nhiêu lần? Có notify TA không? | Missing Info | P0 | EmailFailed | Tech Lead | Open |
| H09 | ❓ Khi 1 Request đã map vào Event rồi, nhưng Event bị hủy — Request có tự động unmap không? | Ambiguity | P1 | EventCreated, RequestMapped | BA | Open |
| H10 | ❓ Student apply vào Event, sau đó Event bị hủy — Application status chuyển thành gì? Có được transfer sang Event khác không? | Edge Case | P1 | EventCreated, ApplicantSubmitted | BA | Open |
| H11 | ❓ Import Results khi có Student không match — TA phải manual match hay system skip? | Ambiguity | P1 | ImportResults | Tech Lead | Open |
| H12 | ❓ Offer deadline — nếu Student không phản hồi trước deadline, system auto gì? | Missing Info | P0 | OfferSent | BA | Open |
| H13 | ❓ Check-in muộn (sau giờ kết thúc ca) — TA có thể override không? Có cần lý do không? | Ambiguity | P2 | CheckInStudent | BA | Open |
| H14 | ❓ Khi Interview round có nhiều ca, và Student miss ca đầu — có được move sang ca sau không? | Edge Case | P1 | InterviewCompleted | BA | Open |
| H15 | ❓ Template Offer Letter customize đến mức nào? Chỉ text hay cả layout/design? | Ambiguity | P2 | CreateOffer | BA | Open |

---

## Domain Discovery Questions

### P0 — Must Resolve Before Design

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Status |
|------|----------|----------|------------------|-------------------|--------|
| Q01 | Khi Student request đổi lịch và không có slot trống, hệ thống đưa vào hàng chờ — quy trình auto-allocate slot từ hàng chờ hoạt động như thế nào? Khi nào trigger? | Process | H01 | BA/Operations | Open |
| Q02 | Khi OfferRejected, TA có được tạo Offer mới cho cùng 1 Candidate không? Hay Candidate bị loại hoàn toàn khỏi quy trình? | Policy | H03 | HR Director | Open |
| Q03 | Email gửi thất bại (EmailFailed) — retry policy là gì? Retry bao nhiêu lần, khoảng cách bao lâu? Có notify TA không? | Technical | H08 | Tech Lead | Open |
| Q04 | Offer deadline — nếu Student không phản hồi trước deadline, hệ thống auto gửi remind hay auto Reject? | Policy | H12 | BA/Operations | Open |

### P1 — Resolve Before Implementation

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Status |
|------|----------|----------|------------------|-------------------|--------|
| Q05 | Deadline confirm cho Interviewer là bao lâu? Có khác với Student deadline không? | Policy | H02 | HR Admin | Open |
| Q06 | Bulk Action khi chọn mixed list — nếu TA force chọn Fail candidates thì sao? Có checkbox override không? | UI/UX | H04 | Tech Lead | Open |
| Q07 | Interviewer có thể update kết quả sau khi đã submit không? Deadline là khi nào? | Policy | H06 | BA | Open |
| Q08 | Khi 1 Request đã map vào Event rồi, nhưng Event bị hủy — Request có tự động unmap không? | Process | H09 | BA | Open |
| Q09 | Student apply vào Event, sau đó Event bị hủy — Application status chuyển thành gì? Có được transfer sang Event khác không? | Process | H10 | BA | Open |
| Q10 | Import Results khi có Student không match — TA phải manual match hay system skip record đó? | Process | H11 | Tech Lead | Open |
| Q11 | Khi Interview round có nhiều ca, và Student miss ca đầu — có được move sang ca sau không? Policy là gì? | Policy | H14 | BA | Open |

### P2 — Nice to Clarify

| Q-ID | Question | Category | Related Hot Spot | Target Stakeholder | Status |
|------|----------|----------|------------------|-------------------|--------|
| Q12 | PhotoCaptured có bắt buộc không? Nếu TA quên chụp ảnh thì hệ thống có block qua vòng sau không? | Policy | H05 | BA | Open |
| Q13 | Candidate RR được tạo tự động khi Pass Screening — nếu TA muốn manual tạo thì có được không? Use case nào? | Edge Case | H07 | BA | Open |
| Q14 | Check-in muộn (sau giờ kết thúc ca) — TA có thể override không? Có cần nhập lý do không? | Policy | H13 | Operations | Open |
| Q15 | Template Offer Letter customize đến mức nào? Chỉ text nội dung hay cả layout/design? | Technical | H15 | HR/Communications | Open |

---

## Aggregate Candidates

Based on event clustering, identify potential Aggregate Roots:

| Aggregate Root | Events | Commands | Rationale |
|----------------|--------|----------|-----------|
| **Event** | EventCreated, RequestMapped, QuestionsAdded, WorkflowConfigured, EventPublished | CreateEvent, MapRequest, AddQuestions, ConfigureWorkflow, PublishEvent | Event là root entity, chứa thông tin Event và config |
| **Application** | ApplicantSubmitted, DuplicateDetected, ApplicationReviewed, ScreeningCompleted, DuplicateResolved | ApplyEvent, DetectDuplicate, ReviewApplication, ScreenPass, ScreenFail, ResolveDuplicate | Application là aggregate cho 1 ứng viên trong 1 Event |
| **Assignment** | AssignmentCreated, AssignmentSent, AssignmentSubmitted, AssignmentGraded, ResultsImported | CreateAssignment, SendAssignment, SubmitAssignment, GradeAssignment, ImportResults | Assignment aggregate quản lý bài test online |
| **TestSlot** | OnsiteSlotCreated, TestInvitationSent, SBDGenerated, ScheduleConfirmed, ScheduleChanged, StudentCheckedIn | CreateOnsiteSlot, SendTestInvitation, GenerateSBD, ConfirmSchedule, RequestScheduleChange, CheckInStudent | TestSlot aggregate quản lý ca thi onsite |
| **InterviewSlot** | InterviewSlotCreated, InterviewInvitationSent, InterviewerInvited, InterviewScheduleConfirmed, InterviewCompleted | CreateInterviewSlot, SendInterviewInvitation, InviteInterviewer, ConfirmInterviewSchedule, CheckInInterview | InterviewSlot aggregate quản lý ca phỏng vấn |
| **Offer** | OfferCreated, OfferSent, OfferAccepted, OfferRejected, CandidateScanned, CandidateTransferred | CreateOffer, SendOffer, AcceptOffer, RejectOffer, ScanCandidate, TransferCandidate | Offer aggregate quản lý thư mời nhận việc |

---

## Read Models (Query Projections)

| Read Model | Purpose | Events Projected |
|------------|---------|------------------|
| **EventDashboard** | Hiển thị tổng quan Events | EventCreated, EventPublished, RequestMapped |
| **ApplicantList** | Danh sách ứng viên cho TA | ApplicantSubmitted, ScreeningCompleted, DuplicateDetected |
| **AssignmentSubmissionTracker** | Track progress nộp bài | AssignmentSent, AssignmentSubmitted, AssignmentGraded |
| **TestSlotRoster** | Danh sách Student trong ca thi | TestInvitationSent, ScheduleConfirmed, StudentCheckedIn |
| **InterviewSchedule** | Lịch phỏng vấn | InterviewInvitationSent, InterviewScheduleConfirmed, InterviewCompleted |
| **OfferTracker** | Track Offer status | OfferCreated, OfferSent, OfferAccepted, OfferRejected |
| **CandidatePipeline** | Pipeline ứng viên qua các vòng | All Screening/Test/Interview events |

---

## Next Steps

- [ ] Share Event Storming summary với BA Team và stakeholders
- [ ] Schedule follow-up session để resolve P0 Hot Spots (H01, H03, H08, H12)
- [ ] Schedule follow-up session để resolve P1 Hot Spots (H02, H04, H06, H09, H10, H11, H14)
- [ ] Update BRD với các clarified requirements sau khi resolve Hot Spots
- [ ] Proceed to Bounded Context identification
- [ ] Update User Stories với新的 acceptance criteria từ Event Storming

---

## Artifacts Produced

| File | Description |
|------|-------------|
| `2.event-storming/event-storming-summary.md` | This document — full Event Storming output |
| `2.event-storming/timeline.md` | Event timeline diagrams (Mermaid) |
| `2.event-storming/hot-spots.md` | Hot Spots register with resolution status |
| `2.event-storming/discovery-questions.md` | Domain Discovery Questions for stakeholder interview |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial Event Storming session |
