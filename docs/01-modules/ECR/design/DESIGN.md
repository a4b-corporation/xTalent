# ECR Module - Design Documentation

> **Version:** 1.0.0
> **Created:** 2026-03-10
> **Module:** Event-Centric Recruitment (ECR)
> **Database:** PostgreSQL 15+

---

## Table of Contents

1. [Kiến trúc tổng quan](#1-kiến-trúc-tổng-quan)
2. [9 Bounded Contexts](#2-9-bounded-contexts)
3. [Quyết định thiết kế quan trọng](#3-quyết-định-thiết-kế-quan-trọng)
4. [Business Rules Mapping](#4-business-rules-mapping)
5. [Integration Patterns](#5-integration-patterns)
6. [Indexing Strategy](#6-indexing-strategy)
7. [Performance Considerations](#7-performance-considerations)
8. [Security Considerations](#8-security-considerations)

---

## 1. Kiến trúc tổng quan

### 1.1 Triết lý thiết kế

Module ECR (Event-Centric Recruitment) được thiết kế theo tư duy **Domain-Driven Design (DDD)** với kiến trúc **Event-Driven**, giải quyết bài toán tuyển dụng số lượng lớn (Mass Hiring) như:
- Chương trình Fresher
- Management Trainee
- Job Fair
- Retail Walk-in Hiring

**Sự khác biệt cốt lõi:**

| Aspect | Traditional ATS (Job-Centric) | ECR (Event-Centric) |
|--------|------------------------------|---------------------|
| **Aggregate Root** | Job Requisition | Event |
| **Quy trình** | Linear per Job | Parallel per Track |
| **Identity** | Email-based | Phone + StudentID |
| **Scheduling** | Manual per candidate | Inventory-based (Slot/Shift) |
| **Assessment** | One test per job | Blueprint-based randomization |

### 1.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ECR Module Architecture                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │    Event     │────▶│    Form &    │────▶│   Identity   │            │
│  │  Management  │     │    Data      │     │   & Profile  │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│         │                   │                       │                   │
│         ▼                   ▼                       ▼                   │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │  Scheduling  │◀───▶│  Assessment  │◀───▶│   Onsite     │            │
│  │   & Resource │     │   & Exam     │     │  Operations  │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│         │                   │                       │                   │
│         ▼                   ▼                       ▼                   │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │ Communication│     │ Gamification │     │  Analytics   │            │
│  │ & Notification│    │ & Engagement │     │  & Reporting │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 9 Bounded Contexts

### 2.1 Event Management Context

**Responsibility:** Quản lý cấu trúc sự kiện, multi-track, mapping với ATS

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `events` | Aggregate Root - Master event | code, name, status, dates, location |
| `tracks` | Luồng chuyên môn (Java, QC, HR) | event_id, code, type, quota |
| `stages` | Workflow stages per track | track_id, type, order_index |
| `request_mappings` | Link Track ↔ ATS Requisition | track_id, requisition_id |

**Invariants:**
- Event phải có ≥1 Track để chuyển sang `published`
- Event chỉ map với Approved/Not Posted Fresher Requests

---

### 2.2 Form & Data Management Context

**Responsibility:** Metadata management, dynamic form rendering

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `question_banks` | Kho câu hỏi trung tâm | code, category, difficulty, tags |
| `question_items` | Câu hỏi cụ thể | question_bank_id, type, content |
| `field_blueprints` | Bộ câu hỏi cho Track | track_id, status, fields (JSONB) |
| `rendering_schemas` | UI rendering config | blueprint_id, track_id, schema |
| `validators` | Validation rules | blueprint_id, field_name, rule |

**Key Design:**
- `fields` column dùng JSONB để lưu dynamic field definitions
- `rendering_schemas` cho phép track-specific form rendering
- Blueprint locking đảm bảo reporting integrity

---

### 2.3 Identity & Profile Context

**Responsibility:** Single Source of Truth về ứng viên

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `candidates` | Aggregate Root - Định danh | sbd, phone, student_id, full_name |
| `profiles` | Event-specific data | candidate_id, event_id, attributes |
| `duplicate_records` | Trùng lặp chờ xử lý | candidate_id, new_candidate_id, match_type |
| `merge_rules` | Policy merge dữ liệu | priority, conditions, action |

**Critical Business Rule (BRS-ID-001):**
```
PRIMARY IDENTIFIER = (phone, student_id)
NOT EMAIL
```

**Duplicate Detection Logic:**
| Match Type | Condition | Suggested Action |
|------------|-----------|------------------|
| Full Match | Same phone + student_id | Remove (spam) |
| Partial Phone | Same phone only | Merge/Replace |
| Partial StudentID | Same student_id only | Merge/Replace |

---

### 2.4 Scheduling & Resource Context

**Responsibility:** Inventory management cho thời gian và không gian

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `capacities` | Tổng capacity per shift | event_id, shift_id, total/confirmed/locked |
| `shifts` | Ca thi (Sáng/Chiều) | event_id, date, start_time, end_time |
| `slots` | Đơn vị nguyên tử (1 ghế) | shift_id, room_id, panel_id, status |
| `reservations` | Xác nhận booking | candidate_id, slot_id, status |
| `waitlists` | Hàng chờ khi full | event_id, track_id, candidate_id, priority |
| `rooms` | Phòng vật lý | event_id, code, max_capacity |
| `panels` | Hội đồng phỏng vấn | room_id, lead_interviewer, interviewers |

**Capacity Formula (BRS-SCH-001):**
```
available_count = total_capacity - confirmed_count - locked_count
```

**Optimistic Locking (BRS-SCH-003):**
```
locked_until = NOW() + INTERVAL '10 minutes'
Auto-release khi locked_until < NOW()
```

---

### 2.5 Assessment & Examination Context

**Responsibility:** Test generation, proctoring, grading

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `blueprints` | Ma trận đề thi | track_id, question_matrix, duration |
| `test_instances` | Bài thi cụ thể | blueprint_id, candidate_id, status |
| `test_items` | Câu hỏi trong đề | test_instance_id, question_item_id |
| `submissions` | Bài làm + điểm | test_item_id, answer, scores |
| `proctor_sessions` | Giám sát thi | test_instance_id, violations, screenshots |
| `assignments` | Bài tập lớn (Portfolio) | blueprint_id, submission_url |

**Randomization Strategy (BRS-ASM-001):**
```json
{
  "question_matrix": {
    "easy": {"java": 3, "sql": 2},
    "medium": {"java": 2, "sql": 1},
    "hard": {"java": 1}
  }
}
```

---

### 2.6 Onsite Operations Context

**Responsibility:** Offline-online bridge, QR check-in, OCR

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `kiosk_sessions` | Phiên Kiosk device | device_id, event_id, last_sync_at |
| `checkin_records` | Check-in record | candidate_id, checkin_time, photo_url |
| `qr_tokens` | QR định danh | candidate_id, token_hash, expires_at |
| `badges` | Thẻ đeo in ra | candidate_id, badge_number, qr_code_data |
| `cv_scan_records` | OCR CV giấy | original_file_url, ocr_text, extracted_data |

**Time Window Validation (BRS-OPS-001):**
```
EARLY_CHECKIN_MINUTES = 30
LATE_CHECKIN_MINUTES = 15

IF checkin_time < (shift_start - 30min) → REJECT
IF checkin_time > (shift_start + 15min) → OVERRIDE required
```

---

### 2.7 Communication & Notification Context

**Responsibility:** Event-driven messaging, bulk action safety

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `message_templates` | Email/SMS template | code, type, channel, body_template |
| `trigger_rules` | Điều kiện kích hoạt | event_id, trigger_event, template_id |
| `campaigns` | Chiến dịch gửi | event_id, recipient_criteria, status |
| `notification_logs` | Lịch sử gửi | campaign_id, candidate_id, status |

**Session Digest Pattern (BRS-COM-001):**
- 01 email duy nhất per session (không spam)
- Secure Link → Digital Interview Kit
- Không đính kèm 50 CV rời rạc

---

### 2.8 Gamification & Engagement Context

**Responsibility:** Candidate experience enhancement

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `missions` | Nhiệm vụ | event_id, mission_type, points |
| `point_ledgers` | Sổ cái điểm | candidate_id, points, transaction_type |
| `lucky_draw_sessions` | Quay số | event_id, eligibility_criteria, drawn_winners |
| `rewards` | Quà tặng | candidate_id, reward_type, status |

**Eligibility Rule (BRS-GAM-001):**
```
Lucky Draw Participants =
  SELECT candidate_id
  FROM checkin_records
  WHERE status = 'checked_in'
```

---

### 2.9 Analytics & Reporting Context

**Responsibility:** Dynamic column flattening, KPI widgets

| Entity | Purpose | Key Attributes |
|--------|---------|----------------|
| `report_schemas` | Cấu trúc báo cáo | event_id, columns (JSONB), filters |
| `dashboard_widgets` | Widget KPI | event_id, widget_type, config |
| `funnel_stages` | Phễu chuyển đổi | event_id, track_id, candidate_count |

**Dynamic Column Flattening (BRS-RPT-001):**
```
JSONB attributes → CSV columns
Per-Track dynamic columns
```

---

## 3. Quyết định thiết kế quan trọng

### 3.1 Primary Key Strategy

| Table Type | PK Type | Rationale |
|------------|---------|-----------|
| **External Entities** (Event, Track, Candidate, TestInstance) | `UUID v7` | Distributed system, external IDs, time-ordered inserts |
| **Internal Resources** (Shift, Slot, Room, Panel) | `BIGINT` | Single-server, sequential inserts, storage efficiency |
| **Junction Tables** | `UUID` | Consistency with parent tables |

**UUID v7 Benefits:**
- Time-ordered → Better insert performance than random UUID
- Globally unique → No coordination needed across services
- External-safe → Can expose in APIs (unlike internal BIGINT)

---

### 3.2 Standard System Columns

Mọi table đều có:

```dbml
id uuid [pk, default: `gen_random_uuid()`]
created_at timestamp [not null, default: `now()`]
updated_at timestamp [not null, default: `now()`]
deleted_at timestamp [null, note: 'Soft delete']
```

**Trigger for updated_at:**
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to each table
CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

---

### 3.3 JSONB for Dynamic Attributes

**Pattern:** Sử dụng JSONB thay vì EAV (Entity-Attribute-Value)

```sql
-- Profile attributes (dynamic form answers)
CREATE TABLE profiles (
    ...
    attributes JSONB NOT NULL
);

-- GIN index for JSONB queries
CREATE INDEX idx_profiles_attributes ON profiles USING GIN (attributes);
```

**Query Example:**
```sql
-- Find candidates with specific university
SELECT * FROM profiles
WHERE attributes->>'university' = 'FTU';

-- Find candidates with GPA > 3.5
SELECT * FROM profiles
WHERE (attributes->>'gpa')::numeric > 3.5;
```

---

### 3.4 Normalization Strategy

| Context | Normalization | Rationale |
|---------|---------------|-----------|
| Event, Identity, Scheduling | **3NF strict** | OLTP, data integrity critical |
| Profile attributes | **JSONB denormalized** | Dynamic fields, flexible schema |
| Analytics | **Controlled denormalization** | Materialized views for reporting |

---

### 3.5 Soft Delete Pattern

**Implementation:**
```dbml
deleted_at timestamp [null, note: 'Soft delete']
```

**Partial Index for active records:**
```sql
CREATE INDEX idx_events_active ON events(deleted_at, status)
WHERE deleted_at IS NULL;
```

**Cascade soft delete:**
- When Event is soft-deleted → child Tracks should be soft-deleted
- Application-level enforcement (no ON DELETE CASCADE for soft delete)

---

## 4. Business Rules Mapping

### 4.1 Event Management Rules

| Rule ID | Description | Schema Implementation |
|---------|-------------|----------------------|
| **BRS-EVT-001** | Event chỉ map với Approved/Not Posted Fresher Requests | Application validation on `request_mappings.status` |
| **BRS-EVT-002** | Event phải có ≥1 Track để Published | CHECK constraint hoặc application logic |
| **BRS-EVT-003** | Track.QuestionSet phải locked trước khi tạo Report | `field_blueprints.status = 'locked'` |

---

### 4.2 Identity Rules

| Rule ID | Description | Schema Implementation |
|---------|-------------|----------------------|
| **BRS-ID-001** | Primary identifier = Phone + StudentID | UNIQUE constraint on `(phone, student_id)` |
| **BRS-ID-002** | Trùng 100% → đề xuất Remove | `duplicate_records.suggested_action = 'remove'` |
| **BRS-ID-003** | Trùng partial → đề xuất Merge/Replace | `duplicate_records.suggested_action IN ('merge', 'replace')` |
| **BRS-ID-004** | Duplicate Tab lưu audit trail | `duplicate_records.audit_data JSONB` |

---

### 4.3 Scheduling Rules

| Rule ID | Description | Schema Implementation |
|---------|-------------|----------------------|
| **BRS-SCH-001** | AvailableSlots = Total - Confirmed - Locked | Computed column `available_count` |
| **BRS-SCH-002** | Slot không Overbook (trừ Waitlist Overflow) | Application validation |
| **BRS-SCH-003** | Lock Slot max 5-10 phút | `slots.locked_until TIMESTAMP` + background job |
| **BRS-SCH-004** | Capacity of Shift = Sum(Room capacities) | Computed on Shift save |
| **BRS-SCH-005** | SlotReleased → quét Waitlist (FIFO) | Background job triggered by event |

**Background Job Pattern:**
```sql
-- Release expired locks
UPDATE slots
SET status = 'available', locked_until = NULL
WHERE status = 'locked'
  AND locked_until < NOW();

-- Process waitlist (simplified)
WITH next_in_line AS (
    SELECT candidate_id, assigned_slot_id
    FROM waitlists
    WHERE status = 'waiting'
      AND expires_at > NOW()
    ORDER BY priority
    LIMIT 1
)
UPDATE waitlists w
SET status = 'assigned',
    assigned_slot_id = nl.assigned_slot_id
FROM next_in_line nl
WHERE w.candidate_id = nl.candidate_id;
```

---

### 4.4 Assessment Rules

| Rule ID | Description | Schema Implementation |
|---------|-------------|----------------------|
| **BRS-ASM-001** | TestInstance sinh ngẫu nhiên từ Blueprint | Application logic, `test_instances.blueprint_id` |
| **BRS-ASM-002** | Randomization theo độ khó tương đương | `blueprints.question_matrix JSONB` |
| **BRS-ASM-003** | Plagiarism check dùng MOSS | `submissions.plagiarism_check JSONB` |
| **BRS-ASM-004** | Auto-grading MCQ/Coding, Manual cho Essay | `submissions.grading_status` enum |
| **BRS-ASM-005** | Assignment file rename pattern | `assignments.submission_filename` |

---

### 4.5 Onsite Rules

| Rule ID | Description | Schema Implementation |
|---------|-------------|----------------------|
| **BRS-OPS-001** | Check-in sớm 30p, muộn 15p | Time window validation |
| **BRS-OPS-002** | Sai Shift → cảnh báo + Admin Override | `checkin_records.is_override`, `override_by` |
| **BRS-OPS-003** | Offline Mode: Local cache + sync | `kiosk_sessions.last_sync_at` |
| **BRS-OPS-004** | Photo Capture bắt buộc | `checkin_records.photo_url NOT NULL` |
| **BRS-OPS-005** | Walk-in Lite: Tên, SĐT, Email, Track → SBD | Minimal candidate creation |

---

## 5. Integration Patterns

### 5.1 Event-Driven Integration

```
┌─────────────┐     CandidateCheckedIn      ┌─────────────┐
│   Onsite    │ ──────────────────────────▶ │  Identity   │
│  Operations │                             │   & Profile │
└─────────────┘                             └─────────────┘
       │                                            │
       │                                            ▼
       │                                    ┌─────────────┐
       │                                    │ Assessment  │
       │                                    │  Activate   │
       │                                    │ TestInstance│
       │                                    └─────────────┘
       │                                            │
       │                                            ▼
       │                                    ┌─────────────┐
       └──────────────────────────────────▶ │  Gamification│
                CheckInEvent                │  +50 points  │
                                            └─────────────┘
```

**Domain Events:**
- `EventPublished` → Form, Scheduling contexts start configuration
- `TrackConfigured` → Form context prepares schemas
- `CandidateCheckedIn` → Identity updates status, Assessment activates test
- `SlotReleased` → Scheduling processes waitlist, Communication sends notification
- `TestCompleted` → Communication sends result, Scheduling releases next stage

---

### 5.2 Anti-Corruption Layer (ACL)

**Event ↔ ATS Core Integration:**

```
┌─────────────┐         ACL          ┌─────────────┐
│   Event     │ ◀──────────────────▶ │  ATS Core   │
│  Management │  TrackConfig         │     Job     │
│   (ECR)     │  RequestMapping      │ Requisition │
└─────────────┘                      └─────────────┘
```

**ACL Function:**
```typescript
// Convert ATS Job Requisition → ECR Track
async function createTrackFromRequisition(requisitionId: string): Promise<Track> {
  const atsJob = await atsCore.getJob(requisitionId);

  // Transform ATS terminology → ECR terminology
  return {
    code: atsJob.jobCode,
    name: atsJob.title,
    type: mapJobTypeToTrackType(atsJob.category),
    quota: atsJob.openings,
    // ... ECR-specific fields
  };
}
```

---

### 5.3 Open Host Service (OHS)

**Form Context → Frontend:**

```
GET /api/forms/schema?track_id={id}

Response:
{
  "track_id": "uuid",
  "schema": {
    "fields": [
      {"name": "full_name", "type": "text", "required": true},
      {"name": "portfolio", "type": "file", "accept": ".pdf,.zip"}
    ],
    "validation": {...},
    "order": ["full_name", "portfolio"]
  }
}
```

---

## 6. Indexing Strategy

### 6.1 Foreign Key Indexes

Tất cả FK columns đều được index:

```sql
-- Single column FK indexes
CREATE INDEX idx_tracks_event_id ON tracks(event_id);
CREATE INDEX idx_stages_track_id ON stages(track_id);
CREATE INDEX idx_profiles_candidate_id ON profiles(candidate_id);
CREATE INDEX idx_reservations_slot_id ON reservations(slot_id);
CREATE INDEX idx_test_instances_blueprint_id ON test_instances(blueprint_id);
```

### 6.2 Composite Indexes

| Table | Index | Query Pattern |
|-------|-------|---------------|
| `candidates` | `(phone, deleted_at)` | Duplicate check |
| `candidates` | `(student_id, deleted_at)` | Duplicate check |
| `slots` | `(shift_id, status)` | Find available slots |
| `reservations` | `(candidate_id, event_id)` | Candidate's reservations |
| `test_instances` | `(status, expires_at)` | In-progress tests |
| `waitlists` | `(status, expires_at)` | Active waitlist |
| `notification_logs` | `(status, created_at)` | Failed notifications |

### 6.3 GIN Indexes for JSONB

```sql
-- Profile dynamic attributes
CREATE INDEX idx_profiles_attributes ON profiles USING GIN (attributes);

-- Blueprint question matrix
CREATE INDEX idx_blueprints_question_matrix ON blueprints USING GIN (question_matrix);

-- Campaign recipient criteria
CREATE INDEX idx_campaigns_recipient_criteria ON campaigns USING GIN (recipient_criteria);
```

### 6.4 Partial Indexes

**Note:** DBML does not support `WHERE` clause for partial indexes. These must be created manually after generating SQL from the DBML schema:

```sql
-- Active slots only
CREATE INDEX idx_slots_available ON slots(shift_id)
WHERE status = 'available';

-- Locked slots needing release
CREATE INDEX idx_slots_locked_expiry ON slots(locked_until)
WHERE status = 'locked';

-- Pending reservations
CREATE INDEX idx_reservations_pending ON reservations(status, created_at)
WHERE status = 'pending';

-- Non-deleted records
CREATE INDEX idx_candidates_active ON candidates(deleted_at)
WHERE deleted_at IS NULL;

-- Active waitlist entries
CREATE INDEX idx_waitlists_active ON waitlists(status, expires_at)
WHERE status = 'waiting';

-- In-progress tests
CREATE INDEX idx_tests_in_progress ON test_instances(status, expires_at)
WHERE status = 'in_progress';

-- Active QR tokens
CREATE INDEX idx_qr_tokens_active ON qr_tokens(expires_at, status)
WHERE status = 'active';
```

---

## 7. Performance Considerations

### 7.1 Concurrency Handling

**Requirement:** 1,000+ simultaneous candidates

**Patterns:**

1. **Optimistic Locking for Slot Selection:**
```sql
BEGIN;

-- Lock slot for 10 minutes
UPDATE slots
SET status = 'locked',
    locked_until = NOW() + INTERVAL '10 minutes',
    reserved_by = :candidate_id
WHERE id = :slot_id
  AND status = 'available';

-- Check if update succeeded
GET DIAGNOSTICS row_count = ROW_COUNT;

IF row_count = 0 THEN
    ROLLBACK;
    RETURN 'Slot already taken';
END IF;

COMMIT;
```

2. **Waitlist FIFO with SKIP LOCKED:**
```sql
SELECT candidate_id
FROM waitlists
WHERE status = 'waiting'
  AND expires_at > NOW()
ORDER BY priority
FOR UPDATE SKIP LOCKED
LIMIT 1;
```

---

### 7.2 Real-time Sync

**Requirement:** Kiosk check-in → Manager screen < 5s delay

**Pattern:** PostgreSQL LISTEN/NOTIFY
```sql
-- Kiosk check-in triggers notification
CREATE OR REPLACE FUNCTION notify_checkin()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('checkin_events', row_to_json(NEW)::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER checkin_notification
    AFTER INSERT ON checkin_records
    FOR EACH ROW EXECUTE FUNCTION notify_checkin();
```

---

### 7.3 Batch Operations

**Bulk Invitation Pattern:**
```sql
-- Validation before sending
WITH validated_candidates AS (
    SELECT c.id, c.sbd, r.status as reservation_status, t.status as test_status
    FROM candidates c
    LEFT JOIN reservations r ON r.candidate_id = c.id AND r.event_id = :event_id
    LEFT JOIN test_instances t ON t.candidate_id = c.id AND t.event_id = :event_id
    WHERE c.id = ANY(:candidate_ids)
      AND c.deleted_at IS NULL
)
SELECT
    COUNT(*) FILTER (WHERE reservation_status IS NULL) as eligible,
    COUNT(*) FILTER (WHERE reservation_status = 'confirmed') as already_scheduled,
    COUNT(*) FILTER (WHERE test_status IN ('not_started', 'in_progress')) as pending_test
FROM validated_candidates;
```

---

## 8. Security Considerations

### 8.1 Sensitive Data Handling

| Data Type | Protection |
|-----------|------------|
| Passwords | bcrypt hash (never stored) |
| Phone, StudentID | Column-level encryption consideration |
| QR Tokens | Hash stored, plaintext never logged |

### 8.2 Audit Trail

**Soft delete + Audit columns:**
```dbml
deleted_at timestamp [null]
created_by uuid [null]
updated_by uuid [null]
```

**Duplicate merge audit:**
```dbml
duplicate_records {
    ...
    audit_data jsonb [not null, note: 'Before/after merge data']
    resolved_at timestamp [null]
    resolved_by uuid [null]
}
```

### 8.3 Token Expiry

**Secure Link Pattern:**
```dbml
qr_tokens {
    ...
    expires_at timestamp [not null]
    usage_count int [not null, default: 0]
    max_usage int [not null, default: 1]
}
```

**Manager Digest Link:**
```
Expires: 24h sau khi sự kiện kết thúc
Single-use: max_usage = 1
```

---

## Appendix: File Locations

| File | Path |
|------|------|
| DBML Schema | `ecr-schema.dbml` |
| ERD Diagram | `ecr-erd.md` |
| Design Doc | `DESIGN.md` (this file) |

---

## References

1. `01-Nghiên cứu Tuyển dụng Số lượng Lớn.md`
2. `02-Bổ sung tính năng tuyển dụng tập trung sự kiện.md`
3. `03-Phân tích Bounded Context từ BRD.md`
4. `04-Product Specs_ Event-Centric Recruitment (ECR) Module.md`
5. `ecr-ontology-analysis.md`
