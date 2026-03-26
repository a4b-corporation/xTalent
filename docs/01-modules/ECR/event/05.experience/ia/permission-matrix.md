# Permission Matrix: ECR Module
## xTalent HCM Solution | 2026-03-26

---

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ Full | Can read, create, update, delete / perform all actions for this feature |
| ✅ Read-only | Can view data but cannot create, modify, or perform workflow actions |
| ⚠️ Own records only | Can act only on records assigned to them (e.g., their session) |
| ⚠️ Token-gated | Access granted only via time-limited token, not by RBAC role |
| ⚠️ Device-bound | Access granted via kiosk session on designated device |
| ❌ No access | Feature not visible or accessible |

## Roles

| Role ID | Role Name | Description |
|---------|-----------|-------------|
| ROLE-TA | TA Event Coordinator | Internal staff managing recruitment events |
| ROLE-HM | Hiring Manager | Internal staff conducting interviews; accesses only via KitLink |
| ROLE-OS | Onsite Staff | Kiosk operators at event venue |
| ROLE-CAND | Candidate | External user; public portal only, no system login |
| ROLE-ADMIN | HR Admin / System Admin | Full system access including settings and cross-event data |

---

## Permission Matrix

| Feature ID | Feature Name | Permission Required | TA Coordinator (ROLE-TA) | Hiring Manager (ROLE-HM) | Onsite Staff (ROLE-OS) | Candidate (ROLE-CAND) | Admin (ROLE-ADMIN) |
|-----------|-------------|--------------------|-|-|-|-|-|
| **BC-01: Event Management** | | | | | | | |
| ECR-M-001 | Event Configuration | ecr.event.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-001 | Event Lifecycle Management | ecr.event.publish (publish/close), ecr.event.manage (others) | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-M-002 | Track Configuration | ecr.event.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-002 | Registration Form Builder | ecr.event.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-003 | Event Cloning | ecr.event.create | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| **BC-02: Candidate Registration** | | | | | | | |
| ECR-T-004 | Candidate Self-Registration Portal | Public (no auth required) | ✅ Read-only (admin view) | ❌ No access | ❌ No access | ✅ Full (via public portal) | ✅ Full |
| ECR-T-005 | Duplicate Flag Resolution | ecr.candidate.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-006 | Waitlist Management | ecr.candidate.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-M-003 | SBD Management | ecr.candidate.manage | ✅ Full | ❌ No access | ✅ Read-only (view own session SBDs) | ❌ No access | ✅ Full |
| **BC-03: Assessment** | | | | | | | |
| ECR-T-007 | Assessment Delivery | ecr.assessment.manage (deferred) | ✅ Read-only (placeholder) | ❌ No access | ❌ No access | ❌ No access | ✅ Read-only (placeholder) |
| **BC-04: Schedule & Capacity** | | | | | | | |
| ECR-M-004 | Schedule Matrix Builder | ecr.schedule.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-008 | Candidate Slot Allocation | ecr.schedule.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-009 | Slot Invitation and Confirmation | ecr.schedule.manage (dispatch), ecr.candidate.view (read) | ✅ Full | ❌ No access | ❌ No access | ⚠️ Own records only (confirm/decline own slot via email link) | ✅ Full |
| **BC-05: Onsite Operations** | | | | | | | |
| ECR-T-010 | Kiosk Check-In | ecr.kiosk.operate (device-bound session) | ✅ Read-only (monitor in TA view) | ❌ No access | ⚠️ Device-bound (kiosk session required) | ❌ No access | ✅ Full |
| ECR-T-011 | Walk-In Registration | ecr.kiosk.operate (device-bound session) | ✅ Read-only (monitor in TA view) | ❌ No access | ⚠️ Device-bound (kiosk session required) | ❌ No access | ✅ Full |
| ECR-T-012 | Offline Sync and Manual Review | ecr.kiosk.manage (sync review), ecr.kiosk.operate (trigger sync) | ✅ Full (conflict review) | ❌ No access | ⚠️ Device-bound (trigger sync only) | ❌ No access | ✅ Full |
| **BC-06: Interview Management** | | | | | | | |
| ECR-T-013 | Session Digest Dispatch | ecr.interview.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-014 | HM Interview Kit | KitLink token (no RBAC role) | ❌ No access (TA dispatches but does not use kit) | ⚠️ Token-gated (KitLink, 24h TTL, own session only) | ❌ No access | ❌ No access | ✅ Full |
| ECR-T-015 | Score Edit Request | ecr.interview.manage (TA approve/reject); KitLink (HM request) | ✅ Full (approve/reject requests) | ⚠️ Token-gated (submit edit request only, own session) | ❌ No access | ❌ No access | ✅ Full |
| ECR-M-005 | Panel and Interviewer Assignment | ecr.interview.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| **BC-07: Communication** | | | | | | | |
| ECR-T-016 | Bulk Email Dispatch | ecr.communication.send | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-M-006 | Email Template Management | ecr.communication.manage | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-A-001 | Communication Job Tracking | ecr.communication.view | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| **BC-08: Analytics & Audit** | | | | | | | |
| ECR-A-002 | Live Event Dashboard | ecr.analytics.view | ✅ Full | ❌ No access | ✅ Read-only (own session room stats only) | ❌ No access | ✅ Full |
| ECR-A-003 | Custom Report Builder | ecr.report.generate | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-A-004 | Audit Log Viewer | ecr.audit.view | ✅ Read-only | ❌ No access | ❌ No access | ❌ No access | ✅ Full |
| ECR-A-005 | Event Performance Analytics | ecr.analytics.view | ✅ Full | ❌ No access | ❌ No access | ❌ No access | ✅ Full |

---

## RBAC Permission Codes Summary

| Permission Code | Description | Roles Holding It |
|----------------|-------------|------------------|
| ecr.event.create | Create new events and clone templates | ROLE-TA, ROLE-ADMIN |
| ecr.event.publish | Publish event and open registration | ROLE-TA, ROLE-ADMIN |
| ecr.event.manage | Edit event details, tracks, form, lifecycle transitions | ROLE-TA, ROLE-ADMIN |
| ecr.candidate.manage | Manage candidate records, duplicates, waitlist, SBDs | ROLE-TA, ROLE-ADMIN |
| ecr.candidate.view | Read-only access to candidate lists | ROLE-TA, ROLE-ADMIN |
| ecr.schedule.manage | Build schedule matrix, run allocation, send invitations | ROLE-TA, ROLE-ADMIN |
| ecr.kiosk.operate | Operate kiosk check-in and walk-in (device-bound) | ROLE-OS |
| ecr.kiosk.manage | Review sync queue, resolve conflicts | ROLE-TA, ROLE-ADMIN |
| ecr.interview.manage | Assign panels, dispatch digests, manage score edit requests | ROLE-TA, ROLE-ADMIN |
| ecr.communication.send | Send bulk emails | ROLE-TA, ROLE-ADMIN |
| ecr.communication.manage | Create and manage email templates | ROLE-TA, ROLE-ADMIN |
| ecr.communication.view | View communication job history | ROLE-TA, ROLE-ADMIN |
| ecr.analytics.view | Access dashboards and performance reports | ROLE-TA, ROLE-ADMIN |
| ecr.report.generate | Build and export custom reports | ROLE-TA, ROLE-ADMIN |
| ecr.audit.view | View audit log | ROLE-TA, ROLE-ADMIN |
| ecr.admin | Full settings access including user management | ROLE-ADMIN |

---

## Special Access Patterns (Non-RBAC)

| Access Pattern | Feature(s) | Mechanism | Expiry |
|---------------|------------|-----------|--------|
| KitLink | ECR-T-014, ECR-T-015 (HM side) | Time-limited signed token in URL; no session cookie | 24 hours from dispatch |
| Public Portal | ECR-T-004 | Unauthenticated public URL; event must be in RegOpen state | Registration window close date |
| Kiosk Device Session | ECR-T-010, ECR-T-011, ECR-T-012 | Device-bound session started by Onsite Staff; PIN-protected | Manually ended or auto-expire after 12h |
| Slot Confirmation | ECR-T-009 (candidate side) | Per-candidate confirmation token in invitation email | 72 hours or event start, whichever earlier |

---

## PII Access Control Notes

- Candidate full name, ID number, date of birth, phone: visible to ROLE-TA and ROLE-ADMIN only
- HM (KitLink) sees: candidate SBD, name, track, registration answers — no ID number or raw contact details
- Onsite Staff sees: SBD, name, track, room assignment — no sensitive PII fields
- Candidate portal: candidate sees only their own data
- All PII rendered exclusively within Vietnam-hosted infrastructure (data residency enforcement at infrastructure layer, not application layer)
