---
id: ABS-LR-007
name: Leave Request with Attachments
module: TA
sub_module: ABS
category: Leave Request Management
priority: P0
status: Specified
differentiation: Parity
gap_type: Standard Fit
phase: 1

ontology_refs:
  concepts:
    - LeaveRequest
  rules:
    - rule_request_must_have_employee
  lifecycle: LeaveRequestLifecycle
  events:
    - LeaveRequested

dependencies:
  requires:
    - ABS-LR-001: "Create Leave Request - base functionality"
  required_by: []
  external:
    - "File Storage Service"
    - "Virus Scan Service"

created: 2026-03-13
author: BA Team
---

# ABS-LR-007: Leave Request with Attachments

> Cho phép nhân viên đính kèm tài liệu (giấy khám bệnh, giấy tờ) vào đơn nghỉ.

---

## 1. Business Context

### Job Story
> **Khi** tôi xin nghỉ ốm hoặc các loại nghỉ cần giấy tờ chứng minh,
> **tôi muốn** đính kèm tài liệu vào đơn,
> **để** cung cấp bằng chứng cho quản lý khi phê duyệt.

### Success Metrics
- Upload success rate ≥ 98%
- File processing time ≤ 5s

---

## 2. UI Workflow & Mockup

### UI Specifics
- Upload area với drag-drop
- Supported formats: PDF, JPG, JPEG, PNG
- Max file size: 10MB per file
- Max files: 5 files per request
- Progress indicator cho mỗi file
- Preview thumbnail cho images
- Delete button cho uploaded files

### Conditional Display
- Hiển thị "Required" badge nếu Sick Leave > 3 days
- Hidden cho các leave types không yêu cầu

---

## 3. System Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `LeaveRequested` | Submit với attachments | attachment_ids: [file_id_1, file_id_2, ...] |

---

## 4. Business Rules

### Feature-specific Rules
| Rule | Condition | Action |
|------|-----------|--------|
| Required for Sick > 3 days | leave_type = Sick AND days > 3 | Bắt buộc upload ít nhất 1 attachment |
| File type validation | Upload file | Chỉ chấp nhận PDF, JPG, JPEG, PNG |
| Size validation | Upload file | Max 10MB per file |
| Virus scan | After upload | Scan trước khi lưu trữ |

---

## 5. NFRs & Constraints

| NFR | Target |
|-----|--------|
| Upload speed | ≤ 5s per file (10MB) |
| Storage | Max 50MB per request |
| Security | Virus scan bắt buộc |

---

## 6. Dependency Map

| Requires | Reason |
|----------|--------|
| ABS-LR-001 | Base create request |
| File Storage Service | Lưu trữ files |
| Virus Scan Service | Security scan |

---

## 7. Edge & Corner Cases

| # | Case | Handling |
|---|------|----------|
| E1 | File > 10MB | Error: "File size exceeds 10MB limit" |
| E2 | Invalid file type | Error: "Only PDF, JPG, JPEG, PNG allowed" |
| E3 | Virus detected | Delete file, alert user, log security event |
| E4 | Upload fails giữa chừng | Retry button, resume upload |
| E5 | Storage service down | Graceful degradation - allow submit without attachment nếu không required |

---

## 8. Acceptance Criteria

```gherkin
Feature: ABS-LR-007 - Leave Request with Attachments

  Scenario: Upload attachment
    Given employee đang tạo leave request
    Khi employee upload file PDF < 10MB
    Thì file được upload thành công
    Và hiển thị thumbnail/preview

  Scenario: Required attachment for Sick > 3 days
    Given employee xin Sick Leave 5 ngày
    Khi employee không upload attachment
    Thì không thể submit
    Và hiển thị error "Giấy khám bệnh là bắt buộc"

  Scenario: File size validation
    Khi employee upload file 15MB
    Thì hiển thị error "File size must be under 10MB"

  Scenario: Multiple files
    Khi employee upload 5 files hợp lệ
    Và cố upload file thứ 6
    Thì hiển thị error "Maximum 5 files allowed"
```

---

## 9. Release Planning

- **Alpha:** Upload cơ bản, single file
- **Beta:** Multiple files, drag-drop, validation
- **GA:** Virus scan, preview, full validation

### Out of Scope (v1)
- OCR processing cho attachments
- E-signature verification
