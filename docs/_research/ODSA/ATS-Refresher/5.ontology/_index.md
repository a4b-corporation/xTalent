# Ontology Index — ATS Fresher Module

> **Version:** 1.0.0
> **Last Updated:** 2026-03-20
> **Status:** Draft — Pending Review

---

## Overview

Đây là ontology chính thức cho ATS Fresher Module, được xây dựng theo chuẩn LinkML YAML format.

### Bounded Contexts

| Context | Entities | Status |
|---------|----------|--------|
| **Event Management** | Event, Track, Workflow, QuestionSet, RequestMapping | ✅ Complete |
| **Application** | Application, Student, Duplicate, FormFieldValue, QuestionAnswer, Attachment | ✅ Complete |
| **Screening** | Screening, CandidateRR, FailedApplicant | ✅ Complete |
| **Assessment** | Assignment, Submission, Grading, GradingTask | ✅ Complete |
| **Test Session** | TestSlot, Schedule, CheckIn, Grading | ✅ Complete |
| **Interview** | InterviewSlot, InterviewSchedule, InterviewerInvitation, CheckIn, Grading | ✅ Complete |
| **Offer** | Offer, OfferResponse, OfferReminder, CandidateScan, CandidateTransfer | ✅ Complete |

**Total Entities:** 29 entities across 7 bounded contexts

---

## Ontology Files by Context

### Event Management Context
```
5.ontology/event-management/
├── event.yaml                  # Event entity (Aggregate Root)
├── track.yaml                  # Track entity
├── workflow.yaml               # Workflow entity
├── question-set.yaml           # QuestionSet entity
└── request-mapping.yaml        # RequestMapping entity
```

### Application Context
```
5.ontology/application/
├── application.yaml            # Application entity (Aggregate Root)
├── student.yaml                # Student entity
├── duplicate.yaml              # Duplicate entity
├── form-field-value.yaml       # FormFieldValue entity
├── question-answer.yaml        # QuestionAnswer entity
└── attachment.yaml             # Attachment entity
```

### Screening Context
```
5.ontology/screening/
├── screening.yaml              # Screening entity (Aggregate Root)
├── candidate-rr.yaml           # CandidateRR entity
└── failed-applicant.yaml       # FailedApplicant entity
```

### Assessment Context
```
5.ontology/assessment/
├── assignment.yaml             # Assignment entity (Aggregate Root)
├── submission.yaml             # Submission entity
├── grading.yaml                # Grading entity
└── grading-task.yaml           # GradingTask entity
```

### Test Session Context
```
5.ontology/test-session/
├── test-slot.yaml              # TestSlot entity (Aggregate Root)
├── schedule.yaml               # Schedule entity
├── checkin.yaml                # CheckIn entity
└── grading.yaml                # Grading entity
```

### Interview Context
```
5.ontology/interview/
├── interview-slot.yaml         # InterviewSlot entity (Aggregate Root)
├── interview-schedule.yaml     # InterviewSchedule entity
├── interviewer-invitation.yaml # InterviewerInvitation entity
├── checkin.yaml                # CheckIn entity
└── grading.yaml                # Grading entity
```

### Offer Context
```
5.ontology/offer/
├── offer.yaml                  # Offer entity (Aggregate Root)
├── offer-response.yaml         # OfferResponse entity
├── offer-reminder.yaml         # OfferReminder entity
├── candidate-scan.yaml         # CandidateScan entity
└── candidate-transfer.yaml     # CandidateTransfer entity
```

---

## Key Design Decisions

### 1. Configurable Parameters
Tất cả các business rules từ P0 Hot Spot resolutions đã được embed vào ontology:

| Parameter | Entity | Property | Default |
|-----------|--------|----------|---------|
| Auto-allocate (FCFS + Time Window) | TestSlot, InterviewSlot | `auto_allocate_enabled`, `time_window_hours` | 24h |
| Max retry auto-allocate | TestSlot, InterviewSlot | `max_retry` | 2 |
| Grace period check-in | TestSlot | `grace_period_minutes` | 15 |
| Photo capture required | TestSlot, InterviewSlot | `photo_capture_required` | false |
| Offer remind timing | Offer | `remind_timing_24h`, `remind_timing_2h` | 24h + 2h |
| Offer grace period | Offer | `grace_period_hours` | 24-48h |
| Auto-reject after grace | Offer | `auto_reject_enabled` | true |
| Re-offer count | Offer | `reoffer_count` | 1-2 |

### 2. Terminology Mapping
Mỗi entity đều có terminology mapping annotations:
- `oracle_hcm_term`
- `sap_term`
- `workday_term`
- `disambiguation`

### 3. Ouroboros Evolution Tracking
Mỗi entity có evolution tracking annotations:
- `iteration`
- `parent_version`
- `evaluation_status`
- `last_evaluated`
- `evolution_notes`

### 4. Validation Hooks
Mỗi entity có validation hooks cho:
- `odds_system_builder`
- `database_schema_design`

---

## Cross-Context Relationships

| Relationship | From | To | Type |
|--------------|------|-----|------|
| Event → Track | Event | Track | 1:N |
| Event → Workflow | Event | Workflow | 1:1 |
| Event → RequestMapping | Event | RequestMapping | 1:N |
| Track → QuestionSet | Track | QuestionSet | 1:1 |
| Application → Student | Application | Student | N:1 |
| Application → Duplicate | Application | Duplicate | 1:1 |
| Application → FormFieldValue | Application | FormFieldValue | 1:N |
| Application → QuestionAnswer | Application | QuestionAnswer | 1:N |
| Application → Attachment | Application | Attachment | 1:N |
| Screening → CandidateRR | Screening | CandidateRR | 1:1 (on Pass) |
| Screening → FailedApplicant | Screening | FailedApplicant | 1:1 (on Fail) |
| Assignment → Submission | Assignment | Submission | 1:N |
| Submission → Grading | Submission | Grading | 1:1 |
| Assignment → GradingTask | Assignment | GradingTask | 1:N |
| TestSlot → Schedule | TestSlot | Schedule | 1:N |
| Schedule → CheckIn | Schedule | CheckIn | 1:1 |
| Schedule → Grading | Schedule | Grading | 1:1 |
| InterviewSlot → InterviewSchedule | InterviewSlot | InterviewSchedule | 1:N |
| InterviewSlot → InterviewerInvitation | InterviewSlot | InterviewerInvitation | 1:N |
| InterviewSchedule → CheckIn | InterviewSchedule | CheckIn | 1:1 |
| InterviewSchedule → Grading | InterviewSchedule | Grading | 1:1 |
| Offer → OfferResponse | Offer | OfferResponse | 1:1 |
| Offer → OfferReminder | Offer | OfferReminder | 1:N |
| CandidateRR → CandidateScan | CandidateRR | CandidateScan | 1:1 |
| CandidateRR → CandidateTransfer | CandidateRR | CandidateTransfer | 1:1 |

---

## Next Steps

1. **Review Ontology** — Stakeholder review các entities và relationships
2. **Generate System Skeleton** — Tạo `db.dbml`, `canonical_api.openapi.yaml` từ ontology
3. **Build Feature Specs (OFDS)** — Tạo *.fsd.md files cho features
4. **Create Mockups** — A2UI JSON DSL mockups cho key screens

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-03-20 | AI Assistant | Initial ontology for all 7 bounded contexts |
