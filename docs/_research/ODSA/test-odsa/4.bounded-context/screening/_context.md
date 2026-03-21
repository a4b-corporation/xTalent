# Context: Screening

> **Context ID:** `ats.screening`
> **Version:** 1.0
> **Last Updated:** 2026-03-20

---

## Trách Nhiệm (Responsibilities)

- **Review Applications** — TA xem xét applications để đánh giá sơ bộ
- **Screening Decision** — TA quyết định Pass/Fail cho từng application
- **Auto Create Candidate RR** — Tự động tạo Candidate RR khi Pass Screening
- **No Candidate RR on Fail** — Không tạo Candidate RR khi Fail
- **Failed Applicant Management** — Quản lý applications Failed (vẫn hiển thị, filter được)
- **Export Applicants** — Export danh sách applications với đầy đủ data
- **Advance Search & Filtering** — Search/filter theo dynamic fields và questions

## Không Chịu Trách Nhiệm (Non-Responsibilities)

- **Nhận applications** — Thuộc Application context
- **Tạo Assignment/Test** — Thuộc Assessment context
- **Gửi emails** — Thuộc Email Service
- **Grading tests** — Thuộc Assessment/Test Session contexts

---

## Core Entities

| Entity | Định Nghĩa Trong Context Này | Attributes Chính |
|--------|-----------------------------|-----------------|
| **Screening** | Kết quả screening decision cho Application | screeningId, applicationId, result (Pass/Fail), decidedBy, decidedAt, notes |
| **CandidateRR** | Candidate record được tạo khi Pass Screening | candidateRRId, applicationId, studentId, status, createdAt, sourceEvent |
| **FailedApplicant** | Record theo dõi applications Failed | failedId, applicationId, screeningId, failReason, thankYouSent, endedAt |

---

## Business Rules (Key Policies)

| Rule ID | Rule Description | Severity | Configurable? |
|---------|-----------------|----------|---------------|
| **SCR-001** | Auto tạo Candidate RR khi Screening = Pass | Error | No |
| **SCR-002** | KHÔNG tạo Candidate RR khi Screening = Fail | Error | No |
| **SCR-003** | Failed applicants vẫn hiển thị trong danh sách với Result = Failed | Warning | No |
| **SCR-004** | Có thể filter danh sách theo Result = Failed | Warning | No |
| **SCR-005** | Screening result có thể update trước khi qua vòng sau | Warning | No |
| **SCR-006** | Bulk Screening cho nhiều applications cùng lúc | Warning | No |
| **SCR-007** | Thank You Letter chỉ được gửi 1 lần per stage | Error | No |
| **SCR-008** | Template Thank You tự động gợi ý theo stage | Warning | No |
| **SCR-009** | Export bao gồm tất cả form fields và question answers | Warning | No |

---

## Ubiquitous Language (Key Terms)

| Term | Definition | Synonyms | Anti-Synonyms |
|------|------------|----------|---------------|
| **Screening** | Vòng đánh giá sơ bộ applications để lọc ứng viên phù hợp | Initial Review, First Pass | Grading, Evaluation |
| **Pass** | Ứng viên đạt yêu cầu và qua vòng tiếp theo | Approved, Selected | — |
| **Fail** | Ứng viên không đạt, không qua vòng tiếp theo | Rejected, Not Selected | — |
| **Candidate RR** | Candidate record trong ATS được tạo khi Pass Screening | Candidate Record, Applicant Record | Application |
| **Stage** | Vòng hiện tại của ứng viên trong pipeline | Round, Phase | Track |

---

## Team Owner

| Role | Name/Team |
|------|-----------|
| **Team** | TA Operations (Talent Acquisition) |
| **Tech Lead** | TBD |
| **Product Owner** | TA Director |
| **Stakeholders** | BA Team, Operations Team |

---

## Integration Points

| Direction | Context | Event/API | Data | Relationship Type |
|-----------|---------|-----------|------|-------------------|
| **Receives From** | Application | `ApplicationSubmitted` | applicationId, studentId, track, answers[] | Customer/Supplier |
| **Receives From** | Application | `DuplicateDetected` | applicationId1, applicationId2, matchType | Customer/Supplier |
| **Sends To** | Assessment | `ScreeningCompleted (Pass)` | applicationId, candidateRRId, studentId | Customer/Supplier |
| **Sends To** | Email Service | `SendThankYouEmail` | applicationId, templateId (stage-based) | Open Host Service |
| **Sends To** | Email Service | `SendAssignmentInvitation` | applicationId, assignmentId | Open Host Service |

---

## Context-Specific Flows

### Flow SCR-F01: Screening Pass

```
1. TA mở danh sách applications cần screening
2. TA review thông tin Application (form fields, questions, attachments)
3. TA click "Pass" cho Application
4. Hệ thống:
   - Cập nhật Screening result = "Pass"
   - Auto tạo Candidate RR
   - Gửi sự kiện `ScreeningCompleted (Pass)`
5. Application chuyển sang vòng tiếp theo (theo workflow)
6. TA có thể bulk send Assignment/Test Invitation cho Pass candidates
```

### Flow SCR-F02: Screening Fail

```
1. TA mở danh sách applications cần screening
2. TA review thông tin Application
3. TA click "Fail" cho Application
4. Hệ thống:
   - Cập nhật Screening result = "Fail"
   - KHÔNG tạo Candidate RR
   - Application vẫn hiển thị với Result = Failed
   - Gợi ý gửi Thank You email (template theo stage)
5. TA có thể gửi Thank You email ngay hoặc sau (bulk)
6. Failed applicant có thể filter trong danh sách
```

### Flow SCR-F03: Bulk Screening

```
1. TA chọn nhiều applications (checkbox)
2. TA click "Bulk Pass" hoặc "Bulk Fail"
3. Hệ thống hiển thị confirmation modal:
   - Số lượng applications đã chọn
   - Cảnh báo nếu có applications không đủ điều kiện (đã Fail/Rejected)
   - List "Ready to Process" và "Skipped"
4. TA confirm
5. Hệ thống xử lý từng application:
   - Pass → tạo Candidate RR
   - Fail → không tạo Candidate RR
6. Notify TA kết quả bulk action
```

---

## Out of Scope

- **Nhận applications** — Thuộc Application context
- **Tạo và chấm Assignment** — Thuộc Assessment context
- **Gửi emails** — Thuộc Email Service
- **Interview decisions** — Thuộc Interview context

---

## Configurable Parameters

| Parameter | Default | Range | Notes |
|-----------|---------|-------|-------|
| **Auto-create Candidate RR on Pass** | True | Boolean | Luôn auto |
| **Template gợi ý theo Stage** | True | Boolean | Auto-select Thank You template |
| **Bulk Action Confirmation Modal** | True | Boolean | Hiển thị modal với skipped list |
| **Max Applications per Bulk Action** | 100 | 10-500 | Giới hạn bulk action |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-20 | AI Assistant | Initial context definition |
