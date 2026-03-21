# Glossary — Screening Context

> **Scope:** Screening context — Review applications, decide Pass/Fail, tạo Candidate RR, track failed applicants
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **Screening** | Kết quả review của TA cho một Application, quyết định ứng viên Pass hay Fail vào vòng tiếp theo. | ApplicationReview (cách gọi khác), Evaluation (không phải screening) | "SCR-000001: Application APP-000001, result = PASS, decided_by = TA-001, decided_at = 2026-04-20 14:30, notes = 'CV tốt, phù hợp yêu cầu'" | PENDING, PASS, FAIL |
| **CandidateRR** | Record của Candidate trong ATS, được auto tạo khi Application Pass Screening. Theo dõi candidate xuyên suốt các vòng tuyển dụng. | Candidate (cách gọi khác), Applicant (trước khi Pass Screening) | "CRR-000001: Student STU-000001, status = ACTIVE, current_stage = ONLINE_TEST, source_event = EVT-000001, created_at = 2026-04-20 14:35" | ACTIVE, HIRED, REJECTED, WITHDRAWN |
| **FailedApplicant** | Record theo dõi applications bị Fail ở Screening, hiển thị trong danh sách với Result = Failed, có thể gửi Thank You email. | RejectedApplication (cách gọi khác), CandidateRR (Pass Screening) | "FAIL-000001: Application APP-000002, fail_reason = INSUFFICIENT_SKILLS, thank_you_sent = true, ended_at = 2026-04-20 15:00" | — |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **ScreeningCompleted** | TA hoàn thành review và quyết định Pass/Fail cho Application | TA | screeningId, applicationId, result (PASS/FAIL), decidedBy, decidedAt, notes |
| **CandidateRRCreated** | Hệ thống auto tạo Candidate RR khi Screening = Pass | System (automated) | candidateRrId, applicationId, studentId, sourceEvent, screeningId, createdAt |
| **FailedApplicantRecorded** | Hệ thống auto tạo FailedApplicant record khi Screening = Fail | System (automated) | failedId, applicationId, screeningId, failReason, endedAt |
| **ThankYouEmailSent** | Thank You email được gửi cho Failed Applicant | System (automated) | failedId, applicationId, studentId, emailTemplate, sentAt |
| **ScreeningUpdated** | TA cập nhật Screening result trước khi candidate qua vòng sau | TA | screeningId, applicationId, updatedResult, updatedBy, updatedAt |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CompleteScreening** | Yêu cầu hoàn thành screening decision (Pass/Fail) cho Application | TA | Application status = SCREENING, TA có quyền review | Screening created ở result PASS hoặc FAIL, Candidate RR hoặc FailedApplicant được tạo |
| **CreateCandidateRR** | Yêu cầu hệ thống auto tạo Candidate RR khi Screening = Pass | System | Screening result = PASS | CandidateRR created ở status ACTIVE, current_stage = ONLINE_TEST |
| **RecordFailedApplicant** | Yêu cầu hệ thống ghi nhận Failed Applicant khi Screening = Fail | System | Screening result = FAIL | FailedApplicant created với fail_reason, ended_at timestamp |
| **SendThankYouEmail** | Yêu cầu gửi Thank You email cho Failed Applicant | System | FailedApplicant.thank_you_sent = false | Thank You email sent, thank_you_sent = true |
| **UpdateScreening** | Yêu cầu cập nhật Screening result | TA | Application status = SCREENING (chưa qua vòng sau) | Screening result updated, updated_at timestamp mới |

---

## Business Rules

- **BR-SCR-001**: Auto tạo Candidate RR khi Screening = Pass
- **BR-SCR-002**: KHÔNG tạo Candidate RR khi Screening = Fail
- **BR-SCR-003**: Screening result có thể update trước khi Application qua vòng sau
- **BR-SCR-004**: Chỉ TA được phân quyền mới được thực hiện Screening
- **BR-SCR-005**: FailedApplicant chỉ được tạo khi Screening = Fail

---

## Lifecycle States

### Screening Lifecycle

```
PENDING → PASS → CandidateRRCreated
        → FAIL → FailedApplicantRecorded → ThankYouEmailSent

Legend:
→ : transition bình thường
Terminal states: PASS, FAIL (sau khi action tương ứng hoàn tất)
```

### CandidateRR Lifecycle

```
ACTIVE → SCREENING → ONLINE_TEST → ONSITE_TEST → INTERVIEW → OFFER → HIRED
         ↓             ↓              ↓             ↓          ↓
      REJECTED    REJECTED      REJECTED     REJECTED   REJECTED
         ↓
    WITHDRAWN (từ bất kỳ state nào)

Terminal states: HIRED, REJECTED, WITHDRAWN

Transition conditions:
- ACTIVE → SCREENING: Candidate RR được tạo từ Screening Pass
- SCREENING → ONLINE_TEST: Pass Screening
- ONLINE_TEST → ONSITE_TEST: Pass Online Test
- ONSITE_TEST → INTERVIEW: Pass Onsite Test
- INTERVIEW → OFFER: Pass Interview
- OFFER → HIRED: Accept Offer
- Bất kỳ state nào → REJECTED: Fail ở vòng tương ứng
- Bất kỳ state nào → WITHDRAWN: Candidate rút lui
```

### FailedApplicant State

```
RECORDED → ThankYouEmailSent → COMPLETED

Terminal states: COMPLETED
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Application Context | Customer/Supplier | ApplicationSubmitted | ScreeningCompleted, CandidateRRCreated, FailedApplicantRecorded | Async (event bus) |
| Assessment Context | Published Language | — | CandidateRRCreated (để assign Online Test) | Async (event bus) |
| Test Session Context | Customer/Supplier | CandidateRRCreated | — | Async (event bus) |
| Interview Context | Published Language | CandidateRRCreated (đã qua Test) | — | Async (event bus) |
| Offer Context | Feedback | CandidateRRCreated (đã qua Interview) | — | Async (event bus) |
| Email Service (external) | Open Host Service | SendThankYouEmail | ThankYouEmailSent | Async (command) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | CandidateRR phải encrypt email, phone; consent checkbox khi submit | Data privacy review + encryption audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | FailedApplicant records phải lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |
| Labor Law | Thông báo kết quả cho ứng viên | Thank You email bắt buộc cho Failed Applicants | Email template audit + delivery tracking |

---

## Edge Cases Checklist

| Edge Case | Xử lý | Glossary Reference |
|-----------|-------|-------------------|
| TA thay đổi quyết định sau khi Screening | Cho phép update nếu Application chưa qua vòng sau | BR-SCR-003 |
| Candidate RR tạo nhầm (Screening = Pass nhầm) | Update Screening result → delete Candidate RR | ScreeningUpdated event |
| Thank You email gửi 2 lần | Flag thank_you_sent = true sau lần đầu | BR-FAIL-003 |
| Candidate Withdrawn sau khi tạo Candidate RR | Update status = WITHDRAWN, không xóa record | CandidateRR lifecycle |
| Application bị duplicate | Screening chỉ thực hiện sau khi Duplicate = RESOLVED | Duplicate entity |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép TA update Screening result sau khi candidate đã qua vòng Online Test không? | Tech Lead | RESOLVED: Không, chỉ được update khi Application status còn là SCREENING |
| 2026-03-20 | ❓ Thank You email gửi tự động hay manual? | BA | RESOLVED: Auto gửi khi FailedApplicant được tạo, nhưng TA có thể tắt nếu muốn |
