# Domain Research Report: Time & Absence Management

**Domain:** Time & Attendance + Absence Management
**Module Code:** TA
**Version:** 1.0
**Date:** 2026-03-23
**Prepared For:** xTalent HR Solution

---

## Executive Summary

Module Time & Absence thuộc giải pháp xTalent HR được thiết kế để quản lý toàn diện hai nghiệp vụ cốt lõi: **Time Tracking** (theo dõi thời gian làm việc) và **Absence Management** (quản lý vắng mặt/nghỉ phép).

Nghiên cứu này phân tích các giải pháp HR hàng đầu thế giới (Workday, SAP SuccessFactors, Oracle HCM, ADP, UKG) để xác định các mẫu thiết kế, yêu cầu nghiệp vụ và xu hướng kiến trúc cho xTalent.

**Phát hiện chính:**
- Các hệ thống enterprise đang chuyển dịch sang mô hình **real-time accrual engine** với khả năng cấu hình linh hoạt
- **Compliance automation** (FMLA, ADA, state leave laws) là yếu tố bắt buộc cho thị trường Mỹ
- **Mobile-first experience** với geofencing, biometric authentication trở thành tiêu chuẩn
- **Integration-first architecture**: Time, Absence, Payroll, Scheduler phải seamless integration
- **Event-driven ledger architecture** thay thế cho transaction-based truyền thống

---

## Domain Classification

| Dimension | Classification | Rationale |
|-----------|---------------|-----------|
| **Strategic Type** | **CORE DOMAIN** | Thời gian & chấm công là USP của HR system, ảnh hưởng trực tiếp payroll |
| **Investment Level** | HIGH | Yêu cầu R&D liên tục cho compliance, accrual engine phức tạp |
| **Build vs Buy** | BUILD | Cần customization cho thị trường VN/APAC, compliance địa phương |
| **Competitive Priority** | PARITY + INNOVATION | Cơ bản phải bằng đối thủ, innovation ở UX và automation |

---

## Explicit Non-Goals (Scope Protection)

Module Time & Absence sẽ **KHÔNG** làm những việc sau:

| Non-Goal | Rationale | Boundary Owner |
|----------|-----------|----------------|
| **Payroll calculation** | Chỉ xuất dữ liệu cho Payroll module, không tính lương | Payroll Module |
| **Schedule optimization** | Lập lịch ca làm việc thuộc module Workforce Planning | Workforce Planning |
| **Performance tracking** | Đánh giá KPI thuộc module Performance Management | Performance Module |
| **Recruitment/ATS** | Tuyển dụng là module riêng | Talent Acquisition |
| **Learning/Training** | Đào tạo là module riêng | LMS Module |
| **Expense management** | Chi phí công tác thuộc Expense module | Finance Module |
| **Real-time GPS tracking** | Chỉ geofencing tại điểm chấm công, không track liên tục | Privacy by Design |
| **Biometric storage** | Không lưu trữ dữ liệu sinh trắc học, chỉ lưu reference token | Security/Compliance |

---

## Evolution Horizons (H1/H2/H3)

### Horizon 1 (0-12 tháng) - Compliance & Core Stability

**Trọng tâm:** Xây dựng nền tảng vững chắc, đáp ứng compliance cơ bản

| Initiative | Description | Priority |
|------------|-------------|----------|
| **Accrual Engine v1** | Hỗ trợ accrual methods: flat rate, per hour, per payroll period | P0 |
| **Leave Types** | Annual Leave, Sick Leave, Maternity, Unpaid Leave với rule engine cơ bản | P0 |
| **Time Tracking** | Punch in/out, break management, overtime calculation | P0 |
| **Approval Workflow** | Multi-level approval với escalation timeout | P0 |
| **Vietnam Compliance** | Labor Code 2019, overtime caps, holiday calendar | P0 |
| **Integration** | REST API cho Payroll, Employee Central | P1 |

### Horizon 2 (1-3 năm) - Automation & Intelligence

**Trọng tâm:** Tự động hóa, predictive analytics, mở rộng regional compliance

| Initiative | Description | Priority |
|------------|-------------|----------|
| **Predictive Absence Analytics** | Bradford Factor, absence pattern detection, early warning system | P1 |
| **Regional Compliance** | Singapore, Thailand, Indonesia leave laws | P1 |
| **AI-Powered Scheduling** | Auto-suggest shifts dựa trên availability, demand forecasting | P2 |
| **Mobile Biometric** | Face ID, Touch ID integration cho mobile clock-in | P2 |
| **Geofencing 2.0** | Dynamic geofences, multiple locations, task-based clock-in | P2 |
| **Self-Service Portal** | Employee/Manager self-service với approval dashboard | P1 |
| **FMLA/ADA Compliance** | US compliance cho khách sạn multinational | P1 |

### Horizon 3 (3-5 năm) - Strategic Innovation

**Trọng tâm:** Disruptive innovation, business model evolution

| Initiative | Description | Priority |
|------------|-------------|----------|
| **Wellness Integration** | Mental health days, burnout prediction, wellness scoring | P3 |
| **Gig Economy Support** | Flexible workforce, contractor time tracking, project-based | P2 |
| **Blockchain Verification** | Immutable time records cho compliance audit | P3 |
| **Voice-First Interface** | "Clock me in", "How much leave do I have?" qua voice | P3 |
| **AR/VR Time Entry** | AR visualization cho shift planning, capacity planning | P3 |
| **Ecosystem API** | Public API cho third-party integrations (marketplace) | P2 |

---

## Domain Confidence Assessment

| Dimension | Score | Evidence |
|-----------|-------|----------|
| **Regulatory Clarity** | **HIGH** | Labor Code các nước ổn định, leave laws well-documented (FMLA 1993, Vietnam Labor Code 2019) |
| **Market Consensus** | **HIGH** | ≥5 vendors (Workday, SAP, Oracle, ADP, UKG) có cùng pattern: accrual plans, leave types, approval workflows |
| **Business Stability** | **MEDIUM** | Core rules ổn định, nhưng state-level leave laws thay đổi hàng năm (US: 150+ local leave laws) |
| **Technical Maturity** | **HIGH** | Event-driven ledger patterns proven, open-source libraries sẵn có |

**Overall Confidence: HIGH** (3 HIGH, 1 MEDIUM)

**Architecture Recommendation:** Proceed với confidence, sử dụng standard patterns đã được kiểm chứng qua Workday/SAP/Oracle. Tập trung differentiation ở UX và regional compliance.

---

## Architectural Decision Records (ADRs)

### ADR-TA-001: Event-Driven Ledger Architecture

**Status:** PROPOSED
**Date:** 2026-03-23
**Source Conflict:** P2 (Market Leaders) vs P3 (Internal Stakeholder - legacy mindset)

#### Context
Thiết kế database cho leave balance: nên dùng **transaction-based** (balance snapshot) hay **event-driven ledger** (movement-based)?

#### Decision
Chọn **Event-Driven Ledger Architecture** với immutable movement records, balance được tính toán real-time từ movement stream.

#### Rationale
- Workday, Oracle đều dùng movement-ledger pattern (xem `leave_movement` table)
- Audit trail tự động, không cần separate history table
- Real-time balance chính xác, không race condition
- Supports multi-period, FEFO (First-Expired-First-Out) allocation

#### Consequences
- **Positive:** Audit compliance, real-time accuracy, temporal queries
- **Negative:** Query complexity cao hơn, cần materialized views cho performance
- **Trade-off:** Chấp nhận complexity để đổi lấy auditability và accuracy

---

### ADR-TA-002: Accrual Engine Design Pattern

**Status:** PROPOSED
**Date:** 2026-03-23
**Source Conflict:** P2 (SAP/Oracle patterns) vs P2 (Workday pattern)

#### Context
Accrual calculation nên design theo pattern nào: **periodic batch** hay **real-time earning**?

#### Decision
Chọn **Hybrid Approach**: Real-time earning tracking + periodic batch accrual (monthly).

#### Rationale
- SAP SuccessFactors: Monthly accrual batch với rule engine
- Workday: Real-time accrual với event triggers
- Hybrid: Track hours real-time, accrue monthly để đơn giản hóa calculation và audit

#### Consequences
- **Positive:** Balance giữa performance và accuracy, dễ debug
- **Negative:** Balance có thể không chính xác trong tháng (chỉ correct sau batch run)
- **Trade-off:** Chấp nhận temporary inaccuracy để đổi lấy simplicity và performance

---

### ADR-TA-003: Compliance Strategy - Vietnam First, Then Regional

**Status:** PROPOSED
**Date:** 2026-03-23
**Source Conflict:** P0 (Vietnam Labor Code) vs P1 (US/EU compliance)

#### Context
Nên build compliance cho thị trường nào trước: Vietnam (home market) hay US/EU (enterprise customers)?

#### Decision
**Vietnam First**, sau đó mở rộng sang Singapore, Thailand, rồi US/EU.

#### Rationale
- xTalent target market là Vietnam + APAC
- Vietnam Labor Code rõ ràng, ổn định (2019 version)
- US FMLA/ADA phức tạp, 150+ state/local laws
- EU Working Time Directive phức tạp nhưng ít enterprise VN cần

#### Consequences
- **Positive:** Time-to-market nhanh cho home market, ít risk ban đầu
- **Negative:** Hạn chế customer multinational muốn US/EU compliance ngay
- **Trade-off:** Chấp nhận limited market để đổi lấy faster launch

---

### ADR-TA-004: Biometric Data Storage Strategy

**Status:** PROPOSED
**Date:** 2026-03-23
**Source Conflict:** P2 (Convenience) vs P0 (Privacy/Compliance)

#### Context
Có nên lưu trữ dữ liệu sinh trắc học (fingerprint template, face data) trong database?

#### Decision
**KHÔNG lưu trữ raw biometric data**. Chỉ lưu reference token từ third-party biometric provider.

#### Rationale
- Illinois BIPA lawsuit: $1.685M settlement cho vi phạm biometric data
- GDPR Article 9: Biometric data là "special category" cần explicit consent
- Vietnam Cybersecurity Law: Data localization requirements
- Best practice từ Workday/Oracle: Không lưu raw biometric

#### Consequences
- **Positive:** Giảm compliance risk, không cần BIPA/GDPR biometric compliance
- **Negative:** Phụ thuộc vào third-party biometric provider
- **Trade-off:** Chấp nhận vendor dependency để đổi lấy compliance safety

---

## Competitor Analysis (Triangulation)

### Workday

| Capability | Approach | xTalent Learning |
|------------|----------|------------------|
| **Absence Calendar** | Shared calendar view, mobile-first, request từ calendar | UX pattern nên adopt |
| **Time Management Hub** | Centralized dashboard cho manager approvals | Manager self-service pattern |
| **Accrual Engine** | Real-time accrual với event triggers | Hybrid approach (real-time + batch) |
| **Compliance** | FMLA/ADA tự động, eligibility check | Vietnam Labor Code first |
| **Integration** | Seamless với Payroll, Scheduler | API-first architecture |

### SAP SuccessFactors

| Capability | Approach | xTalent Learning |
|------------|----------|------------------|
| **Time Off** | Separate module với Time Sheet | Tích hợp chặt Time + Absence |
| **Accrual** | Monthly accrual với simulation | Cần simulation capability |
| **Holiday Calendar** | Country-specific, variant handling | Multi-country support |
| **Workflow** | Rule-based approval với escalation | Multi-level approval pattern |

### Oracle HCM

| Capability | Approach | xTalent Learning |
|------------|----------|------------------|
| **Time & Labor** | Integrated với Absence trên time card | Single interface cho cả Work + Absence |
| **Accrual Plans** | Complex formula engine | Rule engine cần configurable |
| **Compliance** | FMLA integration sâu | Compliance automation critical |

### ADP Workforce Now

| Capability | Approach | xTalent Learning |
|------------|----------|------------------|
| **Total Absence** | Case-based leave management (FMLA cases) | Case management cho complex leave |
| **Geofencing** | Location-based clock-in | Mobile security feature |
| **Biometric** | Face scan, fingerprint options | Hardware integration |

### UKG Pro

| Capability | Approach | xTalent Learning |
|------------|----------|------------------|
| **Leave Management** | Concurrent paid/unpaid tracking | Complex leave scenarios |
| **Bradford Factor** | Absence scoring cho attendance management | Analytics capability |
| **AI Insights** | Predictive scheduling, demand forecasting | Future innovation direction |

---

## Dependencies Mapping

### Upstream Dependencies (Input)

| System | Data Received | Integration Pattern |
|--------|---------------|---------------------|
| **Employee Central** | Employee data, job info, org structure | Event-driven (hire, transfer, terminate) |
| **Holiday Calendar** | Public holidays by region | Static data + annual refresh |
| **Schedule Module** | Shift assignments, work patterns | Real-time lookup |
| **Payroll** | Pay period, rate info | Batch sync per pay period |

### Downstream Dependencies (Output)

| System | Data Provided | Integration Pattern |
|--------|---------------|---------------------|
| **Payroll** | Hours worked, leave taken, overtime | Batch export per pay period |
| **Analytics** | Time data, absence metrics | Real-time stream + daily snapshot |
| **Compliance** | FMLA hours, leave records | On-demand query |
| **Manager Dashboard** | Team availability, approval queue | Real-time API |

---

## Compliance Matrix

### Vietnam (Primary Market)

| Regulation | Requirement | Design Impact |
|------------|-------------|---------------|
| **Labor Code 2019** | Annual leave: 14-16 days tùy thâm niên | Accrual rule với seniority multiplier |
| **Overtime Cap** | 40 giờ OT/tháng, 200-300 giờ OT/năm | OT tracking với alert khi vượt cap |
| **Public Holidays** | 11 ngày lễ/năm | Holiday calendar VN |
| **Sick Leave** | Paid sick leave với doctor note | Sick leave type với evidence requirement |
| **Maternity Leave** | 6 tháng cho mother | Maternity plan với special handling |

### Singapore (Secondary Market)

| Regulation | Requirement | Design Impact |
|------------|-------------|---------------|
| **Employment Act** | 7-14 days annual leave | Accrual rule cho SG |
| **Hospitalization Leave** | 60 days hospitalized sick leave | Separate leave type |
| **Public Holidays** | 11 days PH | Holiday calendar SG |

### US (Future Market)

| Regulation | Requirement | Design Impact |
|------------|-------------|---------------|
| **FMLA** | 12 weeks unpaid leave, job protection | Case management, eligibility tracking |
| **ADA** | Reasonable accommodation | Interactive process workflow |
| **State Leave Laws** | 150+ local paid leave laws | Rule engine configurable per jurisdiction |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Compliance Change** | MEDIUM | HIGH | Rule engine configurable, không hard-code |
| **Performance at Scale** | MEDIUM | MEDIUM | Materialized views, caching layer |
| **Integration Complexity** | HIGH | MEDIUM | API-first, event-driven architecture |
| **Data Privacy (BIPA/GDPR)** | LOW | HIGH | Không lưu raw biometric data |
| **Accrual Calculation Errors** | MEDIUM | HIGH | Dual-control verification, audit trail |

---

## Recommended Next Steps

1. **Entity Catalog Review** - Xem `entity-catalog.md` để hiểu entities và relationships
2. **Feature Catalog Review** - Xem `feature-catalog.md` để biết features chi tiết
3. **Ontology Building** - Kích hoạt `odsa:domain-ontology-builder` để tạo LinkML ontology
4. **Context Map Design** - Kích hoạt `odsa:build-architecture` để thiết kế C4 Context Map
5. **Feature Planning** - Kích hoạt `odsa:build-feature-plan` cho Step 5a

---

## References

### Tier 1 (Gold)
- [Workday Absence Management Datasheet](https://www.workday.com/content/dam/web/en-us/documents/datasheets/workday-absence-management-datasheet-en-us.pdf)
- [Workday Time Tracking Datasheet](https://www.workday.com/content/dam/web/en-us/documents/datasheets/datasheet-workday-time-tracking.pdf)
- [SAP SuccessFactors Time Management Documentation](https://help.sap.com/docs/successfactors-employee-central/implementing-time-management-in-sap-successfactors/time-management-in-sap-successfactors)
- [Oracle Time and Labor Documentation](https://docs.oracle.com/en/cloud/saas/human-resources/faitl/basic-process-to-integrate-absence-management-and-time-and-labor.html)
- [US DOL FMLA Toolkit](https://www.dol.gov/agencies/whd/compliance-assistance/toolkits/fmla)

### Tier 2 (Silver)
- [SAP SuccessFactors Time Tracking Best Practices (Zalaris)](https://zalaris.com/consulting/resources/blog/sap-successfactors-time-tracking-features-implementation-guide)
- [ADP Absence Management Best Practices](https://www.adp.com/resources/articles-and-insights/articles/a/absence-management.aspx)
- [UKG Pro Time and Attendance Features](https://www.ukg.com/products/features/time-and-attendance)
- [2024 Guide to Time & Attendance Software (Rolling Arrays)](https://rollingarrays.com/whitepaper/2024-guide-to-time-attendance-software-navigating-the-shift)

### Tier 3 (Bronze)
- [Reddit Workday Absence Calendar Discussion](https://www.reddit.com/r/workday/comments/1n5rp9i/new_absence_calendar_experience_r2_2025)
- [Medium: Designing Attendance Management System](https://medium.com/@mauryanaman097/designing-and-implementing-a-scalable-attendance-management-system-a-technical-deep-dive-ce8168b7f513)

---

**Document Control:**
- **Author:** AI Research Agent (ODSA Framework)
- **Reviewers:** [TBD - Domain Architect, Product Owner]
- **Approval Status:** DRAFT
- **Next Review Date:** 2026-04-23
