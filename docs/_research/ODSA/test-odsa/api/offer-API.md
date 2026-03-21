# Offer API Documentation

> **Version:** 1.0.0
> **Context:** Offer Bounded Context - xTalent ATS
> **OpenAPI Spec:** `offer-api.openapi.yaml`

---

## Overview

API này cung cấp các endpoints để quản lý quy trình tạo Offer, gửi Offer, student phản hồi (Accept/Reject),
auto-remind trước deadline, scan documents, và transfer candidate sang hệ thống CnB.

### Base URLs

| Environment | URL |
|-------------|-----|
| Production | `https://api.xtalent.io/ats/v1` |
| Staging | `https://staging-api.xtalent.io/ats/v1` |
| Development | `http://localhost:8080/ats/v1` |

---

## Use Cases

| Use Case | Endpoint | Description |
|----------|----------|-------------|
| Create Offer | `POST /offers/create` | TA tạo Offer cho Candidate sau khi Pass Interview |
| Send Offer | `POST /offers/{id}/send` | TA gửi Offer cho Candidate |
| Accept Offer | `POST /offers/{id}/accept` | Student accept Offer trước deadline |
| Reject Offer | `POST /offers/{id}/reject` | Student reject Offer trước deadline |
| Scan Documents | `POST /offers/{id}/scan-documents` | TA scan documents sau khi Candidate Accept Offer |
| Transfer to CnB | `POST /offers/{id}/transfer` | System auto-transfer Candidate sang CnB |

---

## Business Rules

| Rule ID | Description |
|---------|-------------|
| **BR-OFR-001** | Offer chỉ được tạo cho Candidates Pass Interview (CandidateRR.current_stage = INTERVIEW, Interview.result = PASS) |
| **BR-OFR-002** | Offer phải matching với Request đã map trong Event (salary trong range min-max) |
| **BR-OFR-004** | Auto-Expire khi deadline qua (status = EXPIRED) |
| **BR-OFR-011** | Student chỉ có Accept/Reject options (không Negotiate) |
| **BR-OREM-001** | Auto-remind 24h + 2h trước deadline (configurable) |
| **BR-OTRF-001** | Transfer chỉ được thực hiện sau khi Accept Offer |
| **BR-OTRF-002** | Transfer cần ACL để translate sang CnB model |
| **BR-OSCN-001** | Scan chỉ được thực hiện sau khi Accept Offer |

---

## Entity Lifecycle

### Offer Lifecycle

```
DRAFT → SENT → ACCEPTED → DocumentsScanned → CandidateTransferred → HIRED
              → REJECTED (Student reject)
              → EXPIRED (qua deadline) → CANCELLED (sau grace period)
              → CANCELLED (TA manually cancel)
```

**Terminal States:** HIRED, REJECTED, CANCELLED

### OfferResponse Lifecycle

- **ACCEPT:** Student chấp nhận Offer
- **REJECT:** Student từ chối Offer

### CandidateScan Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                    → FAILED
```

### CandidateTransfer Lifecycle

```
PENDING → IN_PROGRESS → COMPLETED
                    → FAILED → RETRY → IN_PROGRESS
```

---

## API Endpoints

### 1. Create Offer

```
POST /offers/create
```

**Description:** Tạo Offer mới cho Candidate sau khi Pass Interview.

#### Preconditions

- CandidateRR.current_stage = INTERVIEW
- Interview.result = PASS (Grading.proposal = OFFER)
- RequestMapping tồn tại cho Event (salary trong range min-max)
- reoffer_count < max_reoffer (default: 2)

#### Request Body

```json
{
  "candidate_rr_id": "CRR-000001",
  "application_id": "APP-000001",
  "request_id": "REQ-000001",
  "salary": 15000000.0,
  "benefits": "13th month salary, 12 days PTO, health insurance",
  "deadline": "2026-05-15T23:59:59+07:00",
  "template_id": "TMPL-JUNIOR",
  "auto_remind_enabled": true,
  "grace_period_hours": 48
}
```

#### Success Response (201)

```json
{
  "offer_id": "OFR-000001",
  "application_id": "APP-000001",
  "candidate_rr_id": "CRR-000001",
  "request_id": "REQ-000001",
  "salary": 15000000.0,
  "benefits": "13th month salary, 12 days PTO, health insurance",
  "deadline": "2026-05-15T23:59:59+07:00",
  "status": "DRAFT",
  "template_id": "TMPL-JUNIOR",
  "reoffer_count": 0,
  "auto_remind_enabled": true,
  "created_by": "TA-001",
  "created_at": "2026-03-20T10:30:00+07:00"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | `SALARY_OUT_OF_RANGE` | Salary ngoài Request range |
| 409 | `INTERVIEW_NOT_PASSED` | Candidate chưa Pass Interview |
| 409 | `REOFFER_LIMIT_REACHED` | Re-offer quá max count |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 1: Create & Send Offer (Steps 1-8)

---

### 2. Send Offer

```
POST /offers/{offer_id}/send
```

**Description:** Gửi Offer cho Candidate sau khi đã tạo Draft.

#### Preconditions

- Offer.status = DRAFT
- Offer có đầy đủ salary, benefits, deadline

#### Request Body

```json
{
  "email_template_id": "TMPL-OFFER-001",
  "send_reminders": true
}
```

#### Success Response (200)

```json
{
  "offer_id": "OFR-000001",
  "status": "SENT",
  "updated_at": "2026-03-20T10:35:00+07:00"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | `OFFER_INCOMPLETE` | Offer thiếu thông tin bắt buộc |
| 404 | `NOT_FOUND` | Offer not found |
| 409 | `INVALID_STATUS` | Offer đã ở trạng thái SENT |
| 500 | `EMAIL_SERVICE_ERROR` | Email service failure |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 1: Create & Send Offer (Steps 9-15)

---

### 3. Accept Offer

```
POST /offers/{offer_id}/accept
```

**Description:** Student accept Offer trước deadline.

#### Preconditions

- Offer.status = SENT
- currentTime <= deadline + grace_period

#### Request Body

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "student_id": "STU-000001"
}
```

#### Success Response (200)

```json
{
  "offer_id": "OFR-000001",
  "status": "ACCEPTED",
  "offer_response": {
    "response_id": "OFRSP-000001",
    "response": "ACCEPT",
    "response_at": "2026-03-20T14:45:00+07:00",
    "created_by": "STU-000001"
  }
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | `DEADLINE_EXPIRED` | Offer đã hết hạn phản hồi |
| 404 | `NOT_FOUND` | Offer not found |
| 409 | `ALREADY_RESPONDED` | Offer đã được phản hồi |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 2: Student Accept/Reject Offer (Steps 16-23)

---

### 4. Reject Offer

```
POST /offers/{offer_id}/reject
```

**Description:** Student reject Offer trước deadline.

#### Preconditions

- Offer.status = SENT
- currentTime <= deadline

#### Request Body

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "student_id": "STU-000001",
  "reason": "Accepted another offer with better benefits"
}
```

#### Success Response (200)

```json
{
  "offer_id": "OFR-000001",
  "status": "REJECTED",
  "offer_response": {
    "response_id": "OFRSP-000001",
    "response": "REJECT",
    "reason": "Accepted another offer with better benefits",
    "response_at": "2026-03-20T14:45:00+07:00"
  }
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 404 | `NOT_FOUND` | Offer not found |
| 409 | `ALREADY_RESPONDED` | Offer đã được phản hồi |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 2: Student Accept/Reject Offer (Steps 16-23)

---

### 5. Scan Documents

```
POST /offers/{offer_id}/scan-documents
```

**Description:** TA scan documents của Candidate sau khi Accept Offer.

#### Preconditions

- Offer.status = ACCEPTED
- TA có quyền scan documents

#### Request Body

```json
{
  "candidate_rr_id": "CRR-000001",
  "documents": [
    {
      "document_id": "DOC-001",
      "document_type": "CMND",
      "file_name": "cmnd_front.jpg",
      "storage_url": "https://storage.xtalent.io/docs/DOC-001"
    },
    {
      "document_id": "DOC-002",
      "document_type": "DIPLOMA",
      "file_name": "bang_dai_hoc.pdf",
      "storage_url": "https://storage.xtalent.io/docs/DOC-002"
    },
    {
      "document_id": "DOC-003",
      "document_type": "HEALTH_RECORD",
      "file_name": "ho_so_suc_khoe.pdf",
      "storage_url": "https://storage.xtalent.io/docs/DOC-003"
    }
  ]
}
```

#### Success Response (201)

```json
{
  "scan_id": "OSCN-000001",
  "candidate_rr_id": "CRR-000001",
  "documents": ["DOC-001", "DOC-002", "DOC-003"],
  "status": "COMPLETED",
  "scanned_at": "2026-03-20T15:00:00+07:00",
  "scanned_by": "TA-001"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | `MISSING_DOCUMENTS` | Thiếu documents bắt buộc |
| 403 | `OFFER_NOT_ACCEPTED` | Offer chưa được Accept |
| 404 | `NOT_FOUND` | Offer not found |
| 409 | `ALREADY_SCANNED` | Documents đã được scan |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 4: Scan Documents & Transfer to CnB (Steps 29-32)

---

### 6. Transfer Candidate to CnB

```
POST /offers/{offer_id}/transfer
```

**Description:** Transfer Candidate sang hệ thống CnB sau khi Accept Offer và scan documents hoàn tất.

#### Preconditions

- Offer.status = ACCEPTED
- CandidateScan.status = COMPLETED
- documents[] đầy đủ

#### Request Body (Optional)

```json
{
  "candidate_rr_id": "CRR-000001",
  "scan_id": "OSCN-000001"
}
```

#### Success Response (201)

```json
{
  "transfer_id": "OTRF-000001",
  "candidate_rr_id": "CRR-000001",
  "cnb_reference_id": "CNB-2026-0001",
  "status": "COMPLETED",
  "transferred_at": "2026-03-20T15:30:00+07:00"
}
```

#### Error Responses

| Code | Error | Description |
|------|-------|-------------|
| 400 | `DOCUMENTS_NOT_SCANNED` | Chưa hoàn thành scan documents |
| 404 | `NOT_FOUND` | Offer not found |
| 409 | `OFFER_NOT_ACCEPTED` | Offer chưa được Accept |
| 500 | `CNB_SERVICE_UNAVAILABLE` | CnB system unavailable |
| 500 | `ACL_TRANSLATION_FAILED` | ACL translation failed |

#### Flow Reference

`7.flows/offer-flow.md` - Phase 4: Scan Documents & Transfer to CnB (Steps 33-36)

---

## Data Models

### Offer

| Field | Type | Description |
|-------|------|-------------|
| offer_id | string | Unique identifier (pattern: `OFR-\\d{6}`) |
| application_id | string | Application ID |
| candidate_rr_id | string | Candidate RR ID |
| request_id | string | Request ID |
| salary | number | Mức lương đề xuất (VND) |
| benefits | string | Phúc lợi (mô tả chi tiết) |
| deadline | datetime | Deadline phản hồi Offer |
| status | OfferStatus | Trạng thái Offer |
| template_id | string | Offer Template ID |
| reoffer_count | integer | Số lần re-offer (0-3) |
| auto_remind_enabled | boolean | Auto remind enabled |
| grace_period_hours | integer | Grace period (giờ) |
| created_by | string | User ID tạo Offer (TA) |
| created_at | datetime | Timestamp tạo Offer |

### OfferStatus

| Status | Description |
|--------|-------------|
| DRAFT | Đang nháp |
| SENT | Đã gửi |
| ACCEPTED | Đã accept |
| REJECTED | Đã reject |
| EXPIRED | Đã expire (qua deadline) |
| CANCELLED | Đã hủy |

### OfferResponse

| Field | Type | Description |
|-------|------|-------------|
| response_id | string | Unique identifier (pattern: `OFRSP-\\d{6}`) |
| offer_id | string | Offer ID |
| response | Response | ACCEPT/REJECT |
| reason | string | Lý do (nếu Reject) |
| response_at | datetime | Thời điểm phản hồi |
| created_by | string | Student ID |

### CandidateScan

| Field | Type | Description |
|-------|------|-------------|
| scan_id | string | Unique identifier (pattern: `OSCN-\\d{6}`) |
| candidate_rr_id | string | Candidate RR ID |
| documents | string[] | Danh sách document IDs |
| status | ScanStatus | Trạng thái scan |
| scanned_at | datetime | Thời điểm scan |
| scanned_by | string | User ID thực hiện scan |

### ScanStatus

| Status | Description |
|--------|-------------|
| PENDING | Chưa scan |
| IN_PROGRESS | Đang scan |
| COMPLETED | Hoàn tất |
| FAILED | Thất bại |

### CandidateTransfer

| Field | Type | Description |
|-------|------|-------------|
| transfer_id | string | Unique identifier (pattern: `OTRF-\\d{6}`) |
| candidate_rr_id | string | Candidate RR ID |
| cnb_reference_id | string | CnB Reference ID (pattern: `CNB-YYYY-NNNN`) |
| status | TransferStatus | Trạng thái transfer |
| transferred_at | datetime | Thời điểm transfer |
| error_message | string | Lý do nếu failed |

### TransferStatus

| Status | Description |
|--------|-------------|
| PENDING | Chưa transfer |
| IN_PROGRESS | Đang transfer |
| COMPLETED | Hoàn tất |
| FAILED | Thất bại |
| RETRY | Đang retry |

---

## Error Handling

### Standard Error Format

```json
{
  "code": "ERROR_CODE",
  "message": "Error message",
  "details": { ... },
  "suggestion": "Gợi ý xử lý",
  "reference": "7.flows/offer-flow.md"
}
```

### Common Error Codes

| Code | Description |
|------|-------------|
| `SALARY_OUT_OF_RANGE` | Salary ngoài Request range |
| `INTERVIEW_NOT_PASSED` | Candidate chưa Pass Interview |
| `REOFFER_LIMIT_REACHED` | Re-offer quá max count |
| `DEADLINE_EXPIRED` | Offer đã hết hạn |
| `OFFER_INCOMPLETE` | Offer thiếu thông tin |
| `OFFER_NOT_ACCEPTED` | Offer chưa được Accept |
| `DOCUMENTS_NOT_SCANNED` | Chưa hoàn thành scan documents |
| `CNB_SERVICE_UNAVAILABLE` | CnB system unavailable |
| `ACL_TRANSLATION_FAILED` | ACL translation failed |

---

## Security

### Authentication

API hỗ trợ 2 phương thức authentication:

1. **Bearer Token (JWT)**
   ```
   Authorization: Bearer <jwt_token>
   ```

2. **API Key**
   ```
   X-API-Key: <api_key>
   ```

---

## Derived From

| Document | Path |
|----------|------|
| Glossary | `6.glossary/offer.md` |
| Flow | `7.flows/offer-flow.md` |
| Ontology | `5.ontology/offer/*.yaml` |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-20 | Initial release |
