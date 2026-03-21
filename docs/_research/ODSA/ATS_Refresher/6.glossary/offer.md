# Glossary — Offer Context

> **Scope:** Offer context — Tạo Offer, Student phản hồi (Accept/Reject), auto-remind, scan documents, và transfer sang CnB
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **Offer** | Thư mời nhận việc với salary, benefits, deadline gửi cho Candidate sau khi Pass Interview. Student chỉ có Accept/Reject options (không Negotiate). | JobOffer (cách gọi khác), Proposal (chưa chính thức), Contract (hợp đồng lao động) | "OFR-000001: Application APP-000001, Candidate CRR-000001, salary = 15000000 VND, benefits = '13th month salary, 12 days PTO', deadline = 2026-05-15 23:59, status = SENT, reoffer_count = 0" | DRAFT, SENT, ACCEPTED, REJECTED, EXPIRED, CANCELLED |
| **OfferResponse** | Phản hồi của Student cho Offer (Accept/Reject), không có option Negotiate. | Negotiation (đàm phán — không hỗ trợ), Feedback (phản hồi chung) | "OFRSP-000001: Offer OFR-000001, response = ACCEPT, reason = null, response_at = 2026-05-10 14:30, created_by = STU-000001" | — |
| **OfferReminder** | Reminder tự động gửi cho Student trước deadline Offer (24h/2h), với configurable timing. | Notification (thông báo chung), Email (phương tiện gửi) | "OREM-000001: Offer OFR-000001, reminder_type = REMIND_24H, scheduled_at = 2026-05-14 09:00, sent_at = 2026-05-14 09:00, status = SENT" | PENDING, SENT, FAILED, CANCELLED |
| **CandidateScan** | Record scan documents của Candidate sau khi Accept Offer (CMND, bằng cấp, hồ sơ sức khỏe). | DocumentUpload (upload chung), Attachment (file đính kèm) | "OSCN-000001: Candidate CRR-000001, documents = ['DOC-001', 'DOC-002', 'DOC-003'], status = COMPLETED, scanned_at = 2026-05-12 10:00, scanned_by = TA-001" | PENDING, IN_PROGRESS, COMPLETED, FAILED |
| **CandidateTransfer** | Record transfer Candidate sang hệ thống CnB (Corporate Network) sau khi Accept Offer và scan documents xong, với ACL translation. | Onboarding (quy trình onboard), EmployeeRecord (nhân viên chính thức) | "OTRF-000001: Candidate CRR-000001, cnb_reference_id = 'CNB-2026-0001', status = COMPLETED, transferred_at = 2026-05-13 15:00, error_message = null" | PENDING, IN_PROGRESS, COMPLETED, FAILED, RETRY |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **OfferCreated** | TA tạo Offer mới với salary, benefits, deadline | TA | offerId, applicationId, candidateRrId, requestId, salary, benefits, deadline, templateId |
| **OfferSent** | Offer được gửi cho Candidate | TA/System | offerId, candidateRrId, sentAt, emailTemplateId |
| **OfferAccepted** | Student accept Offer trước deadline | Student (Candidate) | offerId, candidateRrId, responseId, acceptedAt |
| **OfferRejected** | Student reject Offer trước deadline | Student (Candidate) | offerId, candidateRrId, responseId, reason, rejectedAt |
| **OfferExpired** | Offer expired sau deadline (không phải Reject) | System (automated) | offerId, deadline, expiredAt, autoRejectScheduled |
| **OfferReminderSent** | Reminder tự động gửi cho Student (24h/2h trước deadline) | System (automated) | reminderId, offerId, reminderType (REMIND_24H/REMIND_2H), sentAt |
| **DocumentsScanned** | TA scan documents của Candidate sau Accept Offer | TA | scanId, candidateRrId, documents[], scannedAt, scannedBy |
| **CandidateTransferred** | Candidate được transfer sang hệ thống CnB | System (automated) | transferId, candidateRrId, cnbReferenceId, transferredAt, aclTranslationApplied |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CreateOffer** | Yêu cầu tạo Offer mới với salary, benefits, deadline | TA | CandidateRR.current_stage = INTERVIEW, Interview.result = PASS, RequestMapping exists | Offer created ở status DRAFT, reoffer_count = 0 |
| **SendOffer** | Yêu cầu gửi Offer cho Candidate | TA | Offer.status = DRAFT, Offer có đầy đủ salary, benefits, deadline | Offer.status = SENT, auto-remind scheduled (nếu enabled) |
| **AcceptOffer** | Yêu cầu accept Offer | Student (Candidate) | Offer.status = SENT, chưa qua deadline (+ grace period) | Offer.status = ACCEPTED, DocumentsScan initiated |
| **RejectOffer** | Yêu cầu reject Offer | Student (Candidate) | Offer.status = SENT, chưa qua deadline | Offer.status = REJECTED, CandidateRR.status cập nhật |
| **ExtendDeadline** | Yêu cầu extend deadline Offer | TA | Offer.status = SENT, chưa expired (hoặc trong grace period) | Offer.deadline cập nhật, reminder rescheduled |
| **ScanDocuments** | Yêu cầu scan documents sau Accept Offer | TA | Offer.status = ACCEPTED, Candidate có documents cần scan | CandidateScan created, status = COMPLETED |
| **TransferCandidate** | Yêu cầu transfer Candidate sang CnB | System | CandidateScan.status = COMPLETED, Offer.status = ACCEPTED | CandidateTransfer created, ACL translation applied, cnb_reference_id generated |

---

## Business Rules

- **BR-OFR-001**: Offer chỉ được tạo cho Candidates Pass Interview (CandidateRR.current_stage = INTERVIEW, Interview.result = PASS)
- **BR-OFR-002**: Offer phải matching với Request đã map trong Event (salary trong range min-max)
- **BR-OFR-004**: Auto-Expire khi deadline qua (status = EXPIRED, không phải REJECT)
- **BR-OFR-011**: Student chỉ có Accept/Reject options (không Negotiate) — BRS-OFR-011, BRS-OFRSP-001
- **BR-OREM-001**: Auto-remind 24h + 2h trước deadline (configurable timing) — BRS-OREM-001
- **BR-OFRSP-001**: OfferResponse chỉ có ACCEPT/REJECT options (không có NEGOTIATE)
- **BR-OTRF-001**: Transfer chỉ được thực hiện sau khi Accept Offer (Offer.status = ACCEPTED)
- **BR-OTRF-002**: Transfer cần ACL để translate sang CnB model (Anti-Corruption Layer)
- **BR-OSCN-001**: Scan chỉ được thực hiện sau khi Accept Offer (Offer.status = ACCEPTED)

---

## Lifecycle States

### Offer Lifecycle

```
DRAFT → SENT → ACCEPTED → DocumentsScanned → CandidateTransferred → HIRED
              → REJECTED (Student reject)
              → EXPIRED (qua deadline) → CANCELLED (sau grace period)
              → CANCELLED (TA manually cancel)

Legend:
→ : transition bình thường
Terminal states: HIRED, REJECTED, CANCELLED

Transition conditions:
- DRAFT → SENT: TA send Offer
- SENT → ACCEPTED: Student accept trước deadline
- SENT → REJECTED: Student reject trước deadline
- SENT → EXPIRED: Qua deadline (auto-expire)
- EXPIRED → CANCELLED: Qua grace period (auto-reject) hoặc TA manually cancel
- ACCEPTED → DocumentsScanned: TA scan documents
- DocumentsScanned → CandidateTransferred: System transfer sang CnB
- CandidateTransferred → HIRED: Candidate onboarded
```

### OfferReminder Lifecycle

```
PENDING → SENT → COMPLETED
        → FAILED → RETRY
        → CANCELLED (Offer expired/cancelled)

Terminal states: COMPLETED, CANCELLED
```

### CandidateScan Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                    → FAILED

Terminal states: COMPLETED, FAILED
```

### CandidateTransfer Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                    → FAILED → RETRY → IN_PROGRESS

Terminal states: COMPLETED, FAILED (sau max retries)
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Interview Context | Customer/Supplier | GradingSubmitted (proposal = OFFER) | OfferCreated | Async (event bus) |
| Application Context | Published Language | ApplicationSubmitted | — | Async (event bus) |
| Screening Context | Feedback | CandidateRRCreated | — | Async (event bus) |
| Request Context | Customer/Supplier | RequestApproved | OfferCreated (matching Request) | Async (event bus) |
| CnB System (external) | ACL (Anti-Corruption Layer) | TransferCandidate | CandidateTransferred | Sync (REST API) |
| Email Service (external) | Open Host Service | SendOffer, SendReminder | OfferSent, OfferReminderSent | Async (command) |
| Document Storage (external) | ACL | UploadDocument | DocumentsScanned | Sync (REST API) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Offer data encrypt salary, personal info; consent khi transfer sang CnB | Data privacy review + encryption audit |
| Vietnam Labor Law | Lưu trữ hồ sơ tuyển dụng | Offer, OfferResponse, Documents lưu trữ tối thiểu 1 năm | Data retention policy + backup strategy |
| Labor Law | Offer letter compliance | Offer template phải có đầy đủ terms theo Labor Law (salary, working hours, benefits) | Legal review + template audit |
| Data Residency | Data phải lưu tại Vietnam | Database placement trong Vietnam | Infrastructure review |

---

## Edge Cases Checklist

| Edge Case | Xử lý | Glossary Reference |
|-----------|-------|-------------------|
| Student không phản hồi trước deadline | Auto-Expire (EXPIRED status), grace period cho TA reactivate | BR-OFR-004 |
| Student không phản hồi sau grace period | Auto-Reject (CANCELLED status) | BR-OFR-004 |
| Student muốn negotiate salary | Không hỗ trợ — chỉ Accept/Reject, TA tạo Offer mới nếu cần | BR-OFR-011 |
| Reminder gửi thất bại | Retry logic với max 3 lần, notify TA nếu vẫn failed | BR-OREM-001 |
| Documents scan thiếu | Status = IN_PROGRESS, cho phép scan bổ sung | BR-OSCN-001 |
| Transfer sang CnB failed | Status = FAILED, retry với exponential backoff | BR-OTRF-002 |
| Offer tạo nhầm (salary wrong) | TA cancel Offer, tạo Offer mới với reoffer_count += 1 | BR-OFR-002 |
| Candidate rút lui sau Accept | Offer.status = ACCEPTED, CandidateRR.status = WITHDRAWN | CandidateRR lifecycle |
| Re-offer quá max count | Reject CreateOffer command, notify TA | Configurable reoffer_count (default 1-2) |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép TA extend deadline Offer không? | BA | RESOLVED: Có, với ExtendDeadline command trước khi expired |
| 2026-03-20 | ❓ Grace period default là bao lâu? | Tech Lead | RESOLVED: Default 24-48h, configurable per Event |
| 2026-03-20 | ❓ ACL translation có cần manual approval không? | BA | RESOLVED: Không, auto translation với error handling |
| 2026-03-20 | ❓ Re-offer count configurable per Event không? | Tech Lead | RESOLVED: Có, default 1-2 lần, configurable per Event/Request |

---

## Configurable Parameters (Embed trong Offer)

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `auto_remind_enabled` | true | boolean | Enable auto-remind 24h + 2h trước deadline |
| `remind_timing_24h` | 1440 (24h) | 0-1440 phút | Thời gian remind 24h trước deadline |
| `remind_timing_2h` | 120 (2h) | 0-120 phút | Thời gian remind 2h trước deadline |
| `grace_period_hours` | 48 | 0-168 giờ | Grace period sau deadline trước auto-reject |
| `auto_reject_enabled` | true | boolean | Auto reject sau grace period nếu TA không action |
| `reoffer_count` | 1-2 | 0-3 | Số lần re-offer tối đa cho 1 Candidate |

---

## Offer Template Library

| Template ID | Name | Description | Salary Range | Benefits |
|-------------|------|-------------|--------------|----------|
| TMPL-JUNIOR | Junior Fresher | Offer template cho Junior Fresher | 10M - 15M VND | 13th month, 12 days PTO |
| TMPL-SENIOR | Senior Fresher | Offer template cho Senior Fresher | 15M - 20M VND | 13th month, 15 days PTO, training budget |
| TMPL-INTERN | Intern Fresher | Offer template cho Intern | 5M - 8M VND | Stipend, certificate |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép re-offer sau khi Offer expired không? | BA | RESOLVED: Có, với reoffer_count < max (configurable) |
| 2026-03-20 | ❓ CnB reference ID format như thế nào? | Tech Lead | RESOLVED: Pattern 'CNB-YYYY-NNNN' |
| 2026-03-20 | ❓ Documents scan có bắt buộc không? | BA | RESOLVED: Có, bắt buộc trước khi transfer sang CnB |
