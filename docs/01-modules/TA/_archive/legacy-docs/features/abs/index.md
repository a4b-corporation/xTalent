# Feature Index: Absence Management (ABS)

> Danh sách tất cả features của Absence Management sub-module — tuân thủ chuẩn OFDS v1

## Sub-module Overview

**Mục đích:** Quản lý toàn bộ vòng đời nghỉ phép của nhân viên — từ định nghĩa chính sách, tích lũy số dư, yêu cầu nghỉ, phê duyệt, đến theo dõi sử dụng và xử lý cuối kỳ.

**Số lượng features:** 50 | **Categories:** 6

| Category | Code | Count | Priority |
|---------|------|-------|---------|
| Leave Request Management | LR | 10 | P0: 8, P1: 2, P2: 0 |
| Leave Approval | APR | 10 | P0: 6, P1: 3, P2: 1 |
| Leave Balance Management | BAL | 8 | P0: 5, P1: 2, P2: 1 |
| Leave Accrual | ACC | 8 | P0: 4, P1: 3, P2: 1 |
| Leave Carryover | CARRY | 6 | P0: 3, P1: 2, P2: 1 |
| Leave Policy Rules | POL | 8 | P0: 4, P1: 3, P2: 1 |

---

## Category LR-01: Leave Request Management

**Mục đích:** Quản lý việc tạo, gửi, và theo dõi đơn xin nghỉ phép.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-LR-001](./ABS-LR-001.fsd.md) | Create Leave Request | P0 | Specified | ABS-BAL-001 | [Spec](./ABS-LR-001.fsd.md) |
| [ABS-LR-002](./ABS-LR-002.fsd.md) | Submit Leave Request for Approval | P0 | Specified | ABS-LR-001 | [Spec](./ABS-LR-002.fsd.md) |
| [ABS-LR-003](./ABS-LR-003.fsd.md) | View Leave Request Status | P0 | Specified | — | [Spec](./ABS-LR-003.fsd.md) |
| [ABS-LR-004](./ABS-LR-004.fsd.md) | Withdraw Leave Request | P0 | Specified | ABS-LR-002 | [Spec](./ABS-LR-004.fsd.md) |
| [ABS-LR-005](./ABS-LR-005.fsd.md) | Half-Day Leave Request | P0 | Specified | ABS-LR-001 | [Spec](./ABS-LR-005.fsd.md) |
| [ABS-LR-006](./ABS-LR-006.fsd.md) | Hourly Leave Request | P0 | Specified | ABS-LR-001 | [Spec](./ABS-LR-006.fsd.md) |
| [ABS-LR-007](./ABS-LR-007.fsd.md) | Leave Request with Attachments | P0 | Specified | ABS-LR-001 | [Spec](./ABS-LR-007.fsd.md) |
| [ABS-LR-008](./ABS-LR-008.fsd.md) | Leave Request Comments | P0 | Specified | ABS-LR-001 | [Spec](./ABS-LR-008.fsd.md) |
| [ABS-LR-009](./ABS-LR-009.fsd.md) | Cancel Approved Request | P1 | Identified | ABS-LR-002 | — |
| [ABS-LR-010](./ABS-LR-010.fsd.md) | Modify Pending Request | P1 | Identified | ABS-LR-001 | — |

---

## Category APR-02: Leave Approval

**Mục đích:** Quản lý quy trình phê duyệt đơn nghỉ phép với hỗ trợ đa cấp và ủy quyền.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-APR-001](./ABS-APR-001.fsd.md) | Approve Leave Request | P0 | Specified | ABS-LR-002 | [Spec](./ABS-APR-001.fsd.md) |
| [ABS-APR-002](./ABS-APR-002.fsd.md) | Reject Leave Request | P0 | Specified | ABS-LR-002 | [Spec](./ABS-APR-002.fsd.md) |
| [ABS-APR-003](./ABS-APR-003.fsd.md) | Multi-Level Approval | P0 | Specified | ABS-APR-001 | [Spec](./ABS-APR-003.fsd.md) |
| [ABS-APR-004](./ABS-APR-004.fsd.md) | Delegate Approval | P0 | Specified | ABS-APR-001 | [Spec](./ABS-APR-004.fsd.md) |
| [ABS-APR-005](./ABS-APR-005.fsd.md) | Batch Approval | P0 | Specified | ABS-APR-001 | [Spec](./ABS-APR-005.fsd.md) |
| [ABS-APR-006](./ABS-APR-006.fsd.md) | Approval Escalation | P1 | Identified | ABS-APR-003 | — |
| [ABS-APR-007](./ABS-APR-007.fsd.md) | Approval Comments | P0 | Specified | ABS-APR-001 | [Spec](./ABS-APR-007.fsd.md) |
| [ABS-APR-008](./ABS-APR-008.fsd.md) | View Approval History | P0 | Specified | — | [Spec](./ABS-APR-008.fsd.md) |
| [ABS-APR-009](./ABS-APR-009.fsd.md) | Conditional Approval Routing | P1 | Identified | ABS-APR-003 | — |
| [ABS-APR-010](./ABS-APR-010.fsd.md) | Parallel Approval | P1 | Identified | ABS-APR-003 | — |

---

## Category BAL-03: Leave Balance Management

**Mục đích:** Quản lý và hiển thị số dư nghỉ phép, lịch sử biến động số dư.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-BAL-001](./ABS-BAL-001.fsd.md) | View Leave Balance | P0 | Specified | — | [Spec](./ABS-BAL-001.fsd.md) |
| [ABS-BAL-002](./ABS-BAL-002.fsd.md) | Leave Balance History | P0 | Specified | ABS-BAL-001 | [Spec](./ABS-BAL-002.fsd.md) |
| [ABS-BAL-003](./ABS-BAL-003.fsd.md) | Leave Balance Projection | P1 | Identified | ABS-BAL-001 | — |
| [ABS-BAL-004](./ABS-BAL-004.fsd.md) | Export Balance Report | P1 | Identified | ABS-BAL-002 | — |
| [ABS-BAL-005](./ABS-BAL-005.fsd.md) | Real-time Balance Update | P0 | Specified | ABS-BAL-001 | [Spec](./ABS-BAL-005.fsd.md) |
| [ABS-BAL-006](./ABS-BAL-006.fsd.md) | Multi-Class Balance View | P0 | Specified | ABS-BAL-001 | [Spec](./ABS-BAL-006.fsd.md) |
| [ABS-BAL-007](./ABS-BAL-007.fsd.md) | Balance Adjustment | P1 | Identified | ABS-BAL-005 | — |
| [ABS-BAL-008](./ABS-BAL-008.fsd.md) | Balance Audit Log | P2 | Identified | ABS-BAL-002 | — |

---

## Category ACC-04: Leave Accrual

**Mục đích:** Quản lý quy trình tích lũy nghỉ phép tự động và thủ công.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-ACC-001](./ABS-ACC-001.fsd.md) | Monthly Accrual Run | P0 | Specified | ABS-POL-005 | [Spec](./ABS-ACC-001.fsd.md) |
| [ABS-ACC-002](./ABS-ACC-002.fsd.md) | Accrual Policy Configuration | P0 | Specified | ABS-POL-001 | [Spec](./ABS-ACC-002.fsd.md) |
| [ABS-ACC-003](./ABS-ACC-003.fsd.md) | Manual Grant Leave | P0 | Specified | ABS-BAL-007 | [Spec](./ABS-ACC-003.fsd.md) |
| [ABS-ACC-004](./ABS-ACC-004.fsd.md) | Accrual History View | P0 | Specified | ABS-ACC-001 | [Spec](./ABS-ACC-004.fsd.md) |
| [ABS-ACC-005](./ABS-ACC-005.fsd.md) | Accrual Recalculation | P1 | Identified | ABS-ACC-001 | — |
| [ABS-ACC-006](./ABS-ACC-006.fsd.md) | Accrual Notification | P1 | Identified | ABS-ACC-001 | — |
| [ABS-ACC-007](./ABS-ACC-007.fsd.md) | Accrual Adjustment | P1 | Identified | ABS-ACC-003 | — |
| [ABS-ACC-008](./ABS-ACC-008.fsd.md) | Predictive Accrual Forecasting | P2 | Identified | Core Gap | — |

---

## Category CARRY-05: Leave Carryover

**Mục đích:** Quản lý quy trình chuyển số dư cuối kỳ và xử lý nghỉ hết hạn.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-CARRY-001](./ABS-CARRY-001.fsd.md) | Period End Carryover | P0 | Specified | ABS-POL-006 | [Spec](./ABS-CARRY-001.fsd.md) |
| [ABS-CARRY-002](./ABS-CARRY-002.fsd.md) | Carryover Rule Configuration | P0 | Specified | ABS-POL-001 | [Spec](./ABS-CARRY-002.fsd.md) |
| [ABS-CARRY-003](./ABS-CARRY-003.fsd.md) | Expired Leave Handling | P0 | Specified | ABS-CARRY-001 | [Spec](./ABS-CARRY-003.fsd.md) |
| [ABS-CARRY-004](./ABS-CARRY-004.fsd.md) | Carryover History | P1 | Identified | ABS-CARRY-001 | — |
| [ABS-CARRY-005](./ABS-CARRY-005.fsd.md) | Manual Carryover | P1 | Identified | ABS-CARRY-001 | — |
| [ABS-CARRY-006](./ABS-CARRY-006.fsd.md) | Carryover Notification | P2 | Identified | ABS-CARRY-001 | — |

---

## Category POL-06: Leave Policy Rules

**Mục đích:** Định nghĩa và cấu hình chính sách nghỉ, loại nghỉ, và quy tắc áp dụng.

| ID | Feature Name | Priority | Status | Dependencies | Spec Link |
|----|-------------|---------|--------|-------------|-----------|
| [ABS-POL-001](./ABS-POL-001.fsd.md) | Leave Policy Definition | P0 | Specified | — | [Spec](./ABS-POL-001.fsd.md) |
| [ABS-POL-002](./ABS-POL-002.fsd.md) | Leave Type Configuration | P0 | Specified | — | [Spec](./ABS-POL-002.fsd.md) |
| [ABS-POL-003](./ABS-POL-003.fsd.md) | Leave Class Configuration | P0 | Specified | ABS-POL-002 | [Spec](./ABS-POL-003.fsd.md) |
| [ABS-POL-004](./ABS-POL-004.fsd.md) | Eligibility Rules | P0 | Specified | ABS-POL-003 | [Spec](./ABS-POL-004.fsd.md) |
| [ABS-POL-005](./ABS-POL-005.fsd.md) | Accrual Rules | P0 | Specified | ABS-POL-001 | [Spec](./ABS-POL-005.fsd.md) |
| [ABS-POL-006](./ABS-POL-006.fsd.md) | Carryover Rules | P1 | Identified | ABS-POL-001 | — |
| [ABS-POL-007](./ABS-POL-007.fsd.md) | Overdraft Rules | P1 | Identified | ABS-POL-001 | — |
| [ABS-POL-008](./ABS-POL-008.fsd.md) | Proration Rules | P2 | Identified | ABS-POL-001 | — |

---

## Ontology References

| Ontology Artifact | Path |
|------------------|------|
| Primary Concepts | [`../ontology/concepts/`](../ontology/concepts/) |
| LeaveRequest | [`../ontology/concepts/leave-request.yaml`](../ontology/concepts/leave-request.yaml) |
| LeaveType | [`../ontology/concepts/leave-type.yaml`](../ontology/concepts/leave-type.yaml) |
| LeaveClass | [`../ontology/concepts/leave-class.yaml`](../ontology/concepts/leave-class.yaml) |
| LeaveInstant | [`../ontology/concepts/leave-instant.yaml`](../ontology/concepts/leave-instant.yaml) |
| LeaveBalance | [`../ontology/concepts/leave-balance.yaml`](../ontology/concepts/leave-balance.yaml) |
| LeaveMovement | [`../ontology/concepts/leave-movement.yaml`](../ontology/concepts/leave-movement.yaml) |
| Lifecycle | [`../ontology/lifecycle.yaml`](../ontology/lifecycle.yaml) |
| Rules | [`../ontology/rules.yaml`](../ontology/rules.yaml) |
| Events | [`../system/events.yaml`](../system/events.yaml) |

---

## Feature Dependency Graph

```
ABS-LR-001 (Create Request)
    ↓ requires
ABS-BAL-001 (View Balance)
ABS-VAL-001 (Validation Rules)

ABS-LR-002 (Submit Request)
    ↓ requires
ABS-LR-001 (Create Request)
ABS-APR-001 (Approve Request)

ABS-APR-001 (Approve Request)
    ↓ requires
ABS-LR-002 (Submit Request)
ABS-RES-001 (Create Reservation)

ABS-ACC-001 (Monthly Accrual)
    ↓ requires
ABS-POL-005 (Accrual Rules)
ABS-MVT-001 (Create Movement)

ABS-CARRY-001 (Period End Carryover)
    ↓ requires
ABS-POL-006 (Carryover Rules)
ABS-MVT-001 (Create Movement)
```

---

## P0 Features Priority Matrix

| Feature ID | Feature Name | Business Value | Technical Complexity | Risk Level |
|-----------|-------------|----------------|---------------------|------------|
| ABS-LR-001 | Create Leave Request | High | Low | Low |
| ABS-LR-002 | Submit Leave Request | High | Low | Low |
| ABS-APR-001 | Approve Leave Request | High | Low | Low |
| ABS-BAL-001 | View Leave Balance | High | Low | Low |
| ABS-ACC-001 | Monthly Accrual Run | High | Medium | Medium |
| ABS-CARRY-001 | Period End Carryover | High | Medium | Medium |
| ABS-POL-001 | Leave Policy Definition | High | Medium | Low |

---

## Release Planning Summary

| Phase | Features | Target Date | Status |
|-------|----------|-------------|--------|
| Phase 1A | ABS-LR-001 to 008 (8 P0 Leave Request) | Q2 2026-W1 | Ready |
| Phase 1B | ABS-APR-001 to 008 (8 P0 Approval) | Q2 2026-W2 | Ready |
| Phase 1C | ABS-BAL-001 to 006 (6 P0 Balance) | Q2 2026-W3 | Ready |
| Phase 2A | ABS-ACC-001 to 004 (4 P0 Accrual) | Q2 2026-W4 | In Progress |
| Phase 2B | ABS-CARRY-001 to 003 (3 P0 Carryover) | Q2 2026-W5 | Planned |
| Phase 2C | ABS-POL-001 to 005 (5 P0 Policy) | Q2 2026-W6 | Planned |
| Phase 3 | All P1 features (15 features) | Q3 2026 | Planned |
| Phase 4 | All P2 features (5 features) | Q4 2026 | Planned |
