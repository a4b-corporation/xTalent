# Glossary — Event Management Context

> **Scope:** Event Management context — Tạo và config Event Fresher, mapping Request, workflow setup, publish Event
> **Last updated:** 2026-03-20
> **Owners:** TA Operations Team + Tech Lead
> **Status:** DRAFT

---

## Entities (Danh từ)

| Term | Định nghĩa | Khác với | Ví dụ | Trạng thái |
|------|-----------|---------|------|-----------|
| **Event** | Sự kiện tuyển dụng Fresher được tạo và quản lý trong hệ thống ATS, bao gồm thông tin cơ bản (tên, mô tả, thời gian), tracks, workflow configuration, và request mappings. | Job Post (đã publish lên Career Site), Career Fair (sự kiện vật lý) | "EVT-000001: Fresher Journey 2026 - Hanoi, application window từ 2026-04-01 đến 2026-04-30, có 3 tracks: Game Dev, Game Design, Game QC" | DRAFT, PUBLISHED, ACTIVE, COMPLETED, CANCELLED |
| **Track** | Phân nhánh trong Event cho các vị trí/vai trò khác nhau, mỗi Track có bộ câu hỏi riêng áp dụng cho applications. | Stream (cách gọi khác), Position (vị trí cụ thể sau khi hire) | "TRK-000001: Game Development - yêu cầu ứng viên có kinh nghiệm lập trình C++/C#, portfolio game dự án" | ACTIVE, INACTIVE, CANCELLED |
| **Workflow** | Cấu hình trình tự các vòng tuyển dụng cho Event, cho phép skip một số vòng nếu cần. | Process Flow (cách gọi khác), Pipeline (cách gọi khác) | "WFL-000001: Screening → Online Test → Onsite Test → Interview → Offer (không skip vòng nào)" | DRAFT, ACTIVE, INACTIVE |
| **QuestionSet** | Bộ câu hỏi áp dụng cho Track, được TA chọn từ thư viện câu hỏi có sẵn. | Questionnaire (cách gọi khác), Survey (không phải mục đích tuyển dụng) | "QST-000001: Game Developer Questions - 5 câu hỏi về OOP, 3 câu hỏi về design patterns, 2 câu hỏi tình huống" | DRAFT, ACTIVE, INACTIVE |
| **RequestMapping** | Liên kết giữa Event và Request tuyển dụng từ hệ thống khác, chỉ允许 Request type 'Fresher' và status 'Approved' mới được map. | Job Mapping (cách gọi khác), Request Link (cách gọi khác) | "MAP-000001: Event EVT-000001 map với Request REQ-2026-001 (Fresher, Approved, chưa posted)" | ACTIVE, INACTIVE, CANCELLED |

---

## Events (Động từ — những gì đã xảy ra)

| Event | Khi nào xảy ra | Actor trigger | Payload (nếu có) |
|-------|---------------|---------------|------------------|
| **EventCreated** | TA tạo Event mới với thông tin cơ bản | TA (Talent Acquisition) | eventId, name, description, programType, startDate, endDate |
| **EventPublished** | TA publish Event lên Career Site, Event chính thức mở nhận applications | TA | eventId, publishedAt, applicationWindow (start, end) |
| **RequestMapped** | TA map Request tuyển dụng vào Event | TA | mappingId, eventId, requestId, requestType, mappedAt |
| **WorkflowConfigured** | TA thiết lập workflow các vòng tuyển dụng cho Event | TA | workflowId, eventId, rounds[], skippedRounds[] |
| **EventConfigUpdated** | TA cập nhật cấu hình Event (tracks, fields, questions) | TA | eventId, updatedFields[], updatedTracks[] |

---

## Commands (Lệnh — những gì được yêu cầu)

| Command | Nghĩa là | Actor | Pre-condition | Post-condition |
|---------|---------|-------|---------------|----------------|
| **CreateEvent** | Yêu cầu tạo một Event mới với thông tin cơ bản | TA | Program type = "Fresher" | Event created ở trạng thái DRAFT |
| **MapRequest** | Yêu cầu map Request tuyển dụng vào Event | TA | Event status = DRAFT, Request type = "Fresher", Request status = "Approved", Request chưa được map Event khác | RequestMapping created, Event có thêm 1 mapped request |
| **AddTrack** | Yêu cầu thêm Track vào Event | TA | Event status = DRAFT | Track created và linked với Event |
| **ConfigureWorkflow** | Yêu cầu thiết lập workflow cho Event | TA | Event status = DRAFT, Workflow có ít nhất 1 vòng đánh giá | Workflow created và linked với Event |
| **PublishEvent** | Yêu cầu publish Event lên Career Site | TA | Event có ít nhất 1 Track, Event có ít nhất 1 Request mapped, Workflow hợp lệ (≥1 vòng đánh giá) | Event status = PUBLISHED, không được add/remove Requests sau khi publish |

---

## Business Rules

- **BR-EM-001**: Chỉ Event thuộc Program "Fresher" mới được map Request tuyển dụng
- **BR-EM-002**: Chỉ Request type "Fresher" và status "Approved" mới được map
- **BR-EM-003**: Request đã map Event không được post lên Career Site
- **BR-EM-004**: Một Request chỉ được map 1 Event duy nhất
- **BR-EM-005**: Không được unmap Request nếu đã có Student apply
- **BR-EM-006**: Không được add mapping Request sau khi Event đã publish
- **BR-EM-007**: Workflow phải có ít nhất 1 vòng đánh giá (Test hoặc Interview)
- **BR-EM-008**: Số lần Re-offer tối đa cho 1 Candidate (configurable, default: 1-2)
- **BR-EM-009**: Approval workflow cho Re-offer (configurable, workflow-based)

---

## Lifecycle States

### Event Lifecycle

```
DRAFT → PUBLISHED → ACTIVE → COMPLETED
              ↓
           CANCELLED

Legend:
→ : transition bình thường
↓ : transition đặc biệt (có thể xảy ra ở nhiều trạng thái)
Terminal states: COMPLETED, CANCELLED

Transition conditions:
- DRAFT → PUBLISHED: TA click "Publish", Event có đủ tracks, requests, workflow hợp lệ
- PUBLISHED → ACTIVE: Application window bắt đầu
- ACTIVE → COMPLETED: Application window kết thúc, tất cả applications đã xử lý xong
- PUBLISHED/ACTIVE → CANCELLED: TA hủy Event (lý do business)
```

### Workflow Lifecycle

```
DRAFT → ACTIVE → INACTIVE

Terminal states: INACTIVE
```

### Track Lifecycle

```
DRAFT → ACTIVE → INACTIVE
              ↓
           CANCELLED

Terminal states: INACTIVE, CANCELLED
```

---

## Integration Points

| Context | Integration Type | Events Consumed | Events Published | Sync/Async |
|---------|-----------------|-----------------|------------------|------------|
| Application Context | Published Language | — | EventPublished, EventConfigUpdated | Async (event bus) |
| Offer Context | Feedback | ReofferRequest | — | Async (command) |
| Request System (external) | ACL (Anti-Corruption Layer) | — | GetRequestDetails | Sync (REST API) |
| Career Site (external) | Open Host Service | — | PublishEvent | Sync (REST API) |

---

## Compliance Notes

| Regulation | Requirement | Impact lên Design | Verification |
|------------|-------------|-------------------|--------------|
| Vietnam PDPL | Bảo vệ thông tin cá nhân ứng viên | Event không hiển thị thông tin PII khi publish | Data privacy review + audit |
| Vietnam Labor Law | Quy định về tuyển dụng fresher | Program type chỉ cho phép "Fresher" | Business rule validation |

---

## Review Notes

| Date | Comment | Author | Status |
|------|---------|--------|--------|
| 2026-03-20 | ❓ Có cho phép map nhiều Requests cùng loại vào 1 Event không? | Tech Lead | RESOLVED: Có, không giới hạn số lượng Requests map vào Event |
| 2026-03-20 | ❓ Workflow có thể thay đổi sau khi Event đã publish không? | BA | RESOLVED: Không, workflow phải cố định sau khi publish để đảm bảo consistency |
