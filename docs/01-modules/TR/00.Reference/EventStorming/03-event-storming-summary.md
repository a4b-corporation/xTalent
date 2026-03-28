# Event Storming Summary: Total Rewards

**Domain**: Total Rewards (TR)
**Scope**: Multi-country Southeast Asia (6 countries: VN, TH, ID, SG, MY, PH)
**Innovation Level**: Full Innovation Play
**Timeline**: Fast Track

**Session Dates**: 2026-03-20
**Status**: ✅ COMPLETE — Pending P0 Question Resolution

---

## Session Info

| Attribute | Value |
|-----------|-------|
| **Domain** | Total Rewards (TR) |
| **Scope** | 6 SEA Countries (VN, TH, ID, SG, MY, PH) |
| **Innovation Level** | Full Innovation Play (8 USP features) |
| **Session Duration** | 1 day (fast track) |
| **Facilitator** | ODSA Event Storming Facilitator |
| **Participants** | Product Owner, Architecture Review Board, Country HR Heads (scheduled for interviews) |

---

## Summary Statistics

| Metric | Count | Status |
|--------|-------|--------|
| **Domain Events (🟠)** | 150 | ✅ Captured |
| **Commands (🔵)** | 80 | ✅ Captured |
| **Actors (🟡)** | 40+ | ✅ Mapped |
| **Hot Spots (❓)** | 28 | ✅ Prioritized |
| **Discovery Questions** | 45 | ✅ Generated |
| **Timeline Diagrams** | 5 | ✅ Created |
| **USP Innovation Events (⭐)** | 8 | ✅ Highlighted |

---

## Output Files

| File | Size | Purpose |
|------|------|---------|
| `00-session-brief.md` | 20.9 KB | Phase 1-2: Session prep, 150 Domain Events |
| `01-commands-actors.md` | 23.7 KB | Phase 3-4: 80 Commands, 40+ Actors |
| `02-hot-spots.md` | 12.5 KB | Phase 5: 28 Hot Spots (P0/P1/P2) |
| `timeline-compensation.md` | 9.3 KB | Phase 6: Compensation Cycle Timeline |
| `timeline-benefits.md` | 11.6 KB | Phase 6: Benefits Enrollment Timeline |
| `timeline-variable-pay.md` | 10.3 KB | Phase 6: Variable Pay Timeline |
| `timeline-recognition.md` | 11.3 KB | Phase 6: Recognition Timeline |
| `timeline-statement.md` | 11.4 KB | Phase 6: Statement Timeline |
| `discovery-questions.md` | 25.7 KB | Phase 7: 45 Discovery Questions |
| **Total Output** | **~137 KB** | **9 documents** |

---

## USP Innovation Events (⭐)

| Event ID | Event Name | Timeline | Business Value |
|----------|------------|----------|----------------|
| ⭐ E-USP-01 | `SocialRecognitionPosted` | Recognition | Employee engagement, culture building |
| ⭐ E-USP-02 | `PayEquityGapDetected` | Compensation | DEI compliance, pay transparency |
| ⭐ E-USP-03 | `AICompensationRecommended` | Compensation | 50% AI adoption target |
| ⭐ E-USP-04 | `RealTimeCommissionCalculated` | Variable Pay | Sales rep trust, real-time visibility |
| ⭐ E-USP-05 | `FlexCreditAllocated` | Benefits | Personalized benefits, employee choice |
| ⭐ E-USP-06 | `AIRecognitionSuggested` | Recognition | Increased recognition frequency |
| ⭐ E-USP-07 | `TaxOptimizationRecommended` | Statement | Employee financial wellness |
| ⭐ E-USP-08 | `OfferCompetitivenessScored` | Offer Mgmt | Candidate offer acceptance rate |

---

## P0 Hot Spots (Must Resolve Before Design)

| ID | Hot Spot | Timeline Impact | Owner | Status |
|----|----------|-----------------|-------|--------|
| **H01** | Vietnam SI Law 2024 (17.5%+8% BHXH, 3%+1.5% BHYT, 1%+1% BHTN, 20× cap) | Benefits, Tax | Legal/Compliance | 🔴 Open |
| **H02** | Multi-country FX rate source (Central bank vs. Reuters/OANDA) | Compensation, Statement | Finance + ARB | 🔴 Open |
| **H03** | Data residency (Vietnamese PII cross-border restrictions, PDPA) | Platform, Statement | Legal + IT Security | 🔴 Open |
| **H04** | Tax Authority API failure during filing deadline | Tax | Tax Admin + ARB | 🔴 Open |
| **H05** | Payroll bridge failure during pay cycle | All | Payroll Admin + ARB | 🔴 Open |
| **H06** | Vietnam 4-region minimum wage validation (VND 3.25M-4.68M) | Compensation | Compliance + Vietnam HR | 🔴 Open |

---

## Discovery Questions Summary

| Priority | Count | Target Resolution | Current Status |
|----------|-------|-------------------|----------------|
| **P0** | 15 | Before Design | 🔴 Pending Interviews |
| **P1** | 20 | Before Implementation | 🟡 Scheduled |
| **P2** | 10 | During Implementation | 🟢 Can Defer |

### P0 Questions by Category

| Category | Questions | Primary Stakeholder |
|----------|-----------|---------------------|
| Compliance | Q01, Q06, Q07, Q09, Q13 | Legal/Compliance |
| Technical | Q02, Q04, Q05, Q08, Q10, Q12, Q15 | Architecture Review Board |
| Data Privacy | Q03, Q11, Q14 | Legal + IT Security |

---

## Stakeholder Interview Schedule

### Week 1: Legal & Compliance (P0 Focus)

| Date | Time | Stakeholders | Questions |
|------|------|--------------|-----------|
| Mon 2026-03-23 | 10:00-11:30 | Legal/Compliance, Vietnam HR Head | Q01, Q06, Q09, Q13, Q31 |
| Mon 2026-03-23 | 14:00-15:30 | Legal/Compliance, IT Security | Q03, Q08, Q11, Q14, Q42 |
| Tue 2026-03-24 | 10:00-11:30 | Tax Administrator, Country HR Heads | Q04, Q07, Q15, Q22, Q27 |

### Week 2: Technical & Architecture (P0 Focus)

| Date | Time | Stakeholders | Questions |
|------|------|--------------|-----------|
| Wed 2026-03-26 | 10:00-12:00 | Architecture Review Board, Finance Director | Q02, Q05, Q10, Q12, Q28 |
| Thu 2026-03-27 | 10:00-11:30 | Payroll Administrator, Tech Lead | Q05, Q12, Q23, Q26 |
| Fri 2026-03-28 | 10:00-11:00 | IT Security, Architecture Review Board | Q03, Q08, Q11, Q28 |

### Week 3: Business & Product (P1 Focus)

| Date | Time | Stakeholders | Questions |
|------|------|--------------|-----------|
| Mon 2026-03-30 | 10:00-11:30 | Product Owner, Compensation Manager | Q16-Q18, Q29, Q32-Q35 |
| Tue 2026-03-31 | 10:00-11:30 | Product Owner, Sales Operations | Q19, Q24, Q30 |
| Wed 2026-04-01 | 10:00-11:30 | Product Owner, Benefits Admin | Q20, Q21, Q43 |
| Thu 2026-04-02 | 10:00-11:30 | Product Owner, Talent Acquisition | Q25, Q44 |
| Fri 2026-04-03 | 10:00-11:00 | Product Owner, UX Designer | Q36-Q41, Q45 |

---

## Ambiguity Score

**Current Score**: 0.35 (Target: ≤0.2 to proceed to design)

| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Goal Clarity | 0.8 | 0.40 | 0.32 |
| Constraint Clarity | 0.5 | 0.30 | 0.15 |
| Success Criteria | 0.6 | 0.30 | 0.18 |
| **Total Clarity** | — | — | **0.65** |
| **Ambiguity** | — | — | **0.35** |

**Verdict**: 🔴 NEED CLARIFICATION — P0 stakeholder interviews required

**Path to ≤0.2**:
- Resolve all 15 P0 questions: −0.10
- Resolve 12+ P1 questions: −0.05
- Document all decisions in assumptions.md: −0.05
- **Expected Post-Interview Score**: 0.15 ✅

---

## Event Clusters

| Cluster | Events | Commands | Key Timelines |
|---------|--------|----------|---------------|
| **Compensation** | 25 | 15 | `timeline-compensation.md` |
| **Benefits** | 20 | 12 | `timeline-benefits.md` |
| **Variable Pay** | 18 | 10 | `timeline-variable-pay.md` |
| **Recognition** | 15 | 8 | `timeline-recognition.md` |
| **Statement** | 12 | 6 | `timeline-statement.md` |
| **Audit/Compliance** | 10 | 5 | All timelines |
| **Platform** | 50 | 24 | Cross-cutting |

---

## Critical Success Factors

| Factor | Status | Risk Level | Mitigation |
|--------|--------|------------|------------|
| Vietnam SI Law 2024 compliance | 🔴 Pending | HIGH | P0 interview scheduled 2026-03-23 |
| Multi-currency FX source decision | 🔴 Pending | HIGH | P0 interview with Finance 2026-03-26 |
| Data residency architecture | 🔴 Pending | CRITICAL | P0 interview with Legal + IT Security |
| Payroll bridge failure handling | 🔴 Pending | HIGH | P0 interview with Payroll Admin |
| USP feature validation | 🟡 Scheduled | MEDIUM | P1 interviews Week 3 |

---

## Recommended Next Steps

### Immediate (Week of 2026-03-23)

- [ ] **Conduct P0 stakeholder interviews** (15 questions)
  - [ ] Legal/Compliance: Q01, Q06, Q07, Q09, Q13, Q31
  - [ ] IT Security: Q03, Q08, Q11, Q14, Q28, Q42
  - [ ] Tax/Admin: Q04, Q07, Q15, Q22, Q27
  - [ ] Architecture/Finance: Q02, Q05, Q10, Q12, Q28

- [ ] **Document decisions in `assumptions.md`**
  - [ ] Create decision log per question
  - [ ] Link decisions to design documents
  - [ ] Update hot spots status

### Short-term (Week of 2026-03-30)

- [ ] **Conduct P1 stakeholder interviews** (20 questions)
  - [ ] Product Owner: Q16-Q19, Q29, Q30, Q32-Q35
  - [ ] Architecture Review Board: Q20-Q25, Q26-Q28
  - [ ] UX Designer: Q36-Q40, Q41, Q45

- [ ] **Recalculate ambiguity score**
  - [ ] Target: ≤0.2
  - [ ] If achieved: Proceed to design phase
  - [ ] If not: Schedule follow-up interviews

### Medium-term (April 2026)

- [ ] **Proceed to design phase**
  - [ ] Create bounded context definitions
  - [ ] Design aggregate models
  - [ ] Define API contracts
  - [ ] Create FSD (Functional Specification Document)

- [ ] **Address P2 questions iteratively**
  - [ ] UX design workshops for Q36-Q40
  - [ ] A/B test notification preferences (Q39)
  - [ ] Market data integration decision (Q41)

---

## Quality Checklist

| Checklist Item | Status | Notes |
|----------------|--------|-------|
| All business actors identified | ✅ | 40+ actors mapped |
| Domain Events in past tense | ✅ | 150 events, all past tense |
| Commands in imperative form | ✅ | 80 commands, all imperative |
| Timelines follow logical sequence | ✅ | 5 Mermaid diagrams created |
| Hot Spots marked with ❓ | ✅ | 28 hot spots, P0/P1/P2 prioritized |
| Domain Discovery Questions generated | ✅ | 45 questions, P0/P1/P2 prioritized |
| Stakeholders reviewed output | 🟡 | Interviews scheduled |
| Ambiguity score ≤0.3 | 🔴 | Current: 0.35, target ≤0.2 |

---

## Integration with ODSA Pipeline

```
✅ Event Storming Complete
         ↓
🔴 P0 Stakeholder Interviews (ooo interview)
         ↓
🟡 Document Decisions (assumptions.md)
         ↓
🔴 Recalculate Ambiguity Score (target ≤0.2)
         ↓
🟡 Bounded Context Identification
         ↓
🟡 Ontology Building (LinkML)
         ↓
🟡 FSD Building (Functional Specs)
         ↓
🟡 System Skeleton Generation
```

---

## Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-03-20 | Event Storming Session | Initial session output |
| 1.0.1 | 2026-03-20 | Post-Phase 6-7 | Added timelines and discovery questions |
| 1.1.0 | TBD | Post-P0 Interviews | Pending: Update with resolved decisions |

---

**Output Location**: `/Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-gh-pages/xTalent/modules/total-rewards/01-Requirements/EventStorming/`

**Related Documents**:
- BRD: `../BRD/00-MASTER-BRD.md` — Consolidated BRD for 11 sub-modules
- Innovation Sprints: `../BRD/12-Innovation-Sprints.md` — USP features roadmap
- Session Brief: `00-session-brief.md` — 150 Domain Events
- Commands & Actors: `01-commands-actors.md` — 80 Commands, 40+ Actors
- Hot Spots: `02-hot-spots.md` — 28 Hot Spots register
- Discovery Questions: `discovery-questions.md` — 45 questions

---

**Event Storming Phase Complete**: ✅

**Next Phase**: P0 Stakeholder Interviews → `ooo interview` command

**Target Design Phase Start**: 2026-04-06 (pending ambiguity score ≤0.2)
