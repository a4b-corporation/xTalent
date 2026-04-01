# Payroll Module - Hypothesis Document

> **Module**: Payroll (PR)
> **Phase**: Pre-Reality (Step 1)
> **Date**: 2026-03-31
> **Status**: Complete

---

## 1. Hypothesis Framework

### 1.1 Hypothesis Template

Each hypothesis follows this structure:

```
H{n}: [Statement]
Confidence: [High/Medium/Low] (X%)
Evidence Required: [What would prove/disprove]
Kill Criteria: [When to abandon]
Ambiguity Score: [0.0-1.0]
```

### 1.2 Hypothesis Categories

| Category | Purpose | Count |
|----------|---------|-------|
| Problem Hypotheses | Validate problem exists and is worth solving | 3 |
| Solution Hypotheses | Validate proposed solution is viable | 4 |
| Technical Hypotheses | Validate technical approach is feasible | 3 |
| Business Hypotheses | Validate business viability | 3 |
| User Hypotheses | Validate user needs and behaviors | 3 |

---

## 2. Problem Hypotheses

### H1: Configuration Complexity Problem

**Statement**: Payroll administrators struggle with complex, error-prone configuration processes that lead to calculation errors and compliance issues.

**Confidence**: Medium (65%)

**Evidence Required**:
- Interview 5+ payroll admins confirming pain points
- Document current configuration time and error rates
- Identify specific configuration errors causing problems

**Evidence Against**:
- Current systems may already be adequate
- Users may prefer manual control over automation
- Errors may stem from calculation, not configuration

**Kill Criteria**:
- If <50% of interviewed admins report configuration as major pain point
- If existing tools adequately address configuration needs
- If errors primarily originate from non-configuration sources

**Ambiguity Score**: 0.35

**Validation Method**: User interviews, error log analysis

---

### H2: Vietnam Statutory Compliance Problem

**Statement**: Vietnamese enterprises face significant compliance risk due to complex statutory rules (BHXH, BHYT, BHTN, PIT) that are difficult to configure and maintain.

**Confidence**: High (80%)

**Evidence Required**:
- Document statutory rule complexity
- Identify compliance violation cases
- Validate rule change frequency

**Evidence Against**:
- Existing solutions may already handle Vietnam rules well
- Compliance may not be a significant pain point
- Rules may be simpler than assumed

**Kill Criteria**:
- If Vietnam rules are adequately handled by existing solutions
- If compliance violations are rare despite complexity
- If rule changes are infrequent and well-managed

**Ambiguity Score**: 0.20

**Validation Method**: Regulatory research, compliance case studies

---

### H3: Integration Pain Problem

**Statement**: Current integration between payroll and other HCM modules (Core HR, Time, Compensation) is fragmented and causes data synchronization issues.

**Confidence**: Medium (60%)

**Evidence Required**:
- Document current integration pain points
- Identify synchronization errors
- Validate data flow requirements

**Evidence Against**:
- Existing integrations may be adequate
- Data synchronization may not be a major issue
- Users may have workarounds in place

**Kill Criteria**:
- If integration is not reported as a pain point
- If synchronization errors are rare and minor
- If current data flow meets user needs

**Ambiguity Score**: 0.40

**Validation Method**: Integration audit, user interviews

---

## 3. Solution Hypotheses

### H4: Configuration-First Approach

**Statement**: Separating configuration from runtime calculation enables better flexibility, testing, and compliance management.

**Confidence**: Medium (70%)

**Evidence Required**:
- Validate separation of concerns benefits
- Test configuration validation without calculation
- Measure improvement in error detection

**Evidence Against**:
- Configuration without preview may cause undetected errors
- Two-system coordination may introduce complexity
- Users may prefer integrated experience

**Kill Criteria**:
- If validation without calculation proves insufficient
- If users cannot effectively configure without preview
- If two-system complexity outweighs benefits

**Ambiguity Score**: 0.30

**Validation Method**: POC testing, user feedback

---

### H5: Template-Based Configuration

**Statement**: Pre-built configuration templates for common pay structures and statutory rules will reduce setup time by 60% or more.

**Confidence**: Medium (55%)

**Evidence Required**:
- Build and test template library
- Measure setup time with vs. without templates
- Validate template coverage for use cases

**Evidence Against**:
- Organizations may have unique requirements not covered by templates
- Templates may be too rigid for customization
- Setup time reduction may be less than expected

**Kill Criteria**:
- If templates cover <70% of use cases
- If setup time reduction is <40%
- If users find templates limiting rather than helpful

**Ambiguity Score**: 0.45

**Validation Method**: Template testing, time measurement

---

### H6: Formula Engine Flexibility

**Statement**: A flexible formula engine will enable users to define complex statutory calculations without code changes.

**Confidence**: High (75%)

**Evidence Required**:
- Build formula engine POC
- Test with Vietnam statutory formulas (PIT brackets, progressive rates)
- Validate user ability to configure formulas

**Evidence Against**:
- Formulas may be too complex for users
- Edge cases may not be handleable by formulas
- Performance may be insufficient for complex formulas

**Kill Criteria**:
- If <60% of statutory formulas can be expressed
- If users cannot configure formulas without technical help
- If formula evaluation performance is unacceptable

**Ambiguity Score**: 0.25

**Validation Method**: Formula engine POC, user testing

---

### H7: API-First Design

**Statement**: Designing APIs before UI will enable better integration flexibility and support multiple consumers.

**Confidence**: High (80%)

**Evidence Required**:
- Define comprehensive API contract
- Test API patterns with integration partners
- Validate API coverage for use cases

**Evidence Against**:
- API-first may delay UI development
- Users may need UI to understand capabilities
- API design may not anticipate UI needs

**Kill Criteria**:
- If API design significantly delays user-facing features
- If API proves too complex for integration partners
- If API doesn't support required UI workflows

**Ambiguity Score**: 0.20

**Validation Method**: API design review, integration testing

---

## 4. Technical Hypotheses

### H8: SCD-2 Versioning Adequacy

**Statement**: Slowly Changing Dimension Type 2 (SCD-2) versioning will adequately handle historical tracking for audit and compliance requirements.

**Confidence**: High (85%)

**Evidence Required**:
- Implement SCD-2 pattern for key entities
- Test query performance with historical data
- Validate audit trail requirements

**Evidence Against**:
- SCD-2 may cause query complexity
- Performance may degrade with large history
- Alternative versioning patterns may be better

**Kill Criteria**:
- If query performance is unacceptable
- If audit trail requirements cannot be met
- If versioning complexity is unmanageable

**Ambiguity Score**: 0.15

**Validation Method**: Database testing, performance benchmarking

---

### H9: Integration Architecture Feasibility

**Statement**: The proposed integration architecture (API for CO/TR, batch for TA, file for banking) is technically feasible and performant.

**Confidence**: Medium (65%)

**Evidence Required**:
- Build integration prototypes
- Test data volume handling
- Validate error handling patterns

**Evidence Against**:
- Real-time integration may have latency issues
- Batch processing may not meet timeliness needs
- File-based integration may be unreliable

**Kill Criteria**:
- If integration latency exceeds requirements
- If error handling proves inadequate
- If data volume causes performance issues

**Ambiguity Score**: 0.35

**Validation Method**: Integration POC, load testing

---

### H10: Multi-Tenant Data Isolation

**Statement**: Database-level tenant isolation can be achieved while maintaining acceptable query performance.

**Confidence**: Medium (60%)

**Evidence Required**:
- Design multi-tenant data model
- Test query performance with tenant isolation
- Validate data isolation security

**Evidence Against**:
- Query performance may degrade with tenant filtering
- Data isolation may be compromised
- Alternative approaches (schema per tenant) may be needed

**Kill Criteria**:
- If query performance degrades significantly (>20%)
- If data isolation cannot be guaranteed
- If implementation complexity is too high

**Ambiguity Score**: 0.40

**Validation Method**: Database testing, security audit

---

## 5. Business Hypotheses

### H11: Market Demand

**Statement**: Vietnamese enterprises have sufficient demand for a configuration-focused payroll solution to justify development investment.

**Confidence**: Medium (55%)

**Evidence Required**:
- Market size analysis for Vietnam HCM
- Competitive landscape assessment
- Customer willingness-to-pay research

**Evidence Against**:
- Market may be saturated with existing solutions
- Customers may not see value in configuration focus
- Price sensitivity may limit revenue potential

**Kill Criteria**:
- If addressable market is <target threshold
- If competitive alternatives meet customer needs
- If willingness-to-pay is below cost structure

**Ambiguity Score**: 0.45

**Validation Method**: Market research, competitive analysis

---

### H12: Development Timeline

**Statement**: MVP can be delivered within 6 months with a team of 5-6 engineers.

**Confidence**: Low (40%)

**Evidence Required**:
- Detailed technical estimation
- Resource availability confirmation
- Dependency risk assessment

**Evidence Against**:
- Scope may expand beyond MVP
- Technical complexity may be underestimated
- Dependencies may cause delays

**Kill Criteria**:
- If estimation reveals >9 month timeline
- If critical dependencies are unavailable
- If scope expands beyond MVP definition

**Ambiguity Score**: 0.60

**Validation Method**: Detailed estimation, resource planning

---

### H13: Integration Value

**Statement**: Integration with CO, TA, TR modules provides sufficient value to justify integration effort.

**Confidence**: High (75%)

**Evidence Required**:
- Document integration touchpoints
- Validate data flow requirements
- Measure integration value for users

**Evidence Against**:
- Integration may be too complex
- Users may not use integrated features
- Standalone value may be sufficient

**Kill Criteria**:
- If integration effort exceeds 30% of total effort
- If users don't leverage integrated features
- If standalone solution provides equivalent value

**Ambiguity Score**: 0.25

**Validation Method**: User interviews, integration value analysis

---

## 6. User Hypotheses

### H14: Admin Skill Level

**Statement**: Payroll administrators have sufficient technical skill to configure complex pay elements and formulas.

**Confidence**: Low (35%)

**Evidence Required**:
- User skill assessment
- Configuration complexity testing
- Training requirement analysis

**Evidence Against**:
- Users may lack technical background
- Configuration may require specialized knowledge
- Training requirements may be extensive

**Kill Criteria**:
- If <50% of users can configure without extensive training
- If configuration requires specialized technical skills
- If error rates remain high after training

**Ambiguity Score**: 0.65

**Validation Method**: User testing, skill assessment

---

### H15: Workflow Preferences

**Statement**: Payroll administrators prefer self-service configuration over IT-dependent processes.

**Confidence**: Medium (60%)

**Evidence Required**:
- User workflow preference research
- Current vs. desired state analysis
- Self-service adoption measurement

**Evidence Against**:
- Users may prefer IT involvement for compliance
- Self-service may introduce errors
- Change management may be significant

**Kill Criteria**:
- If users prefer IT-dependent processes
- If self-service introduces unacceptable risk
- If change management cost is too high

**Ambiguity Score**: 0.40

**Validation Method**: User interviews, workflow analysis

---

### H16: Error Tolerance

**Statement**: Payroll administrators will tolerate configuration warnings if it provides more flexibility.

**Confidence**: Low (40%)

**Evidence Required**:
- User error tolerance testing
- Warning effectiveness measurement
- Error prevention preference analysis

**Evidence Against**:
- Users may prefer rigid validation over flexibility
- Warnings may be ignored leading to errors
- Zero-error expectation may exist

**Kill Criteria**:
- If users prefer rigid validation
- If warning fatigue leads to errors
- If error tolerance is low

**Ambiguity Score**: 0.60

**Validation Method**: User testing, error analysis

---

## 7. Hypothesis Summary

### 7.1 Confidence Distribution

| Confidence Level | Count | Hypotheses |
|------------------|-------|------------|
| High (70%+) | 5 | H2, H7, H8, H13 |
| Medium (50-69%) | 7 | H1, H3, H4, H5, H9, H10, H11, H15 |
| Low (<50%) | 4 | H12, H14, H16 |

### 7.2 Ambiguity Distribution

| Ambiguity Level | Count | Hypotheses |
|-----------------|-------|------------|
| Low (0.0-0.2) | 2 | H2, H7, H8 |
| Medium (0.21-0.4) | 8 | H1, H3, H4, H6, H9, H10, H13, H15 |
| High (0.41-1.0) | 6 | H5, H11, H12, H14, H16 |

### 7.3 Critical Hypotheses

**Must Validate Before MVP**:
- H1: Configuration Complexity Problem (problem exists)
- H4: Configuration-First Approach (solution is viable)
- H6: Formula Engine Flexibility (technical feasibility)
- H14: Admin Skill Level (user capability)

**Should Validate Before MVP**:
- H2: Vietnam Statutory Compliance Problem (market need)
- H5: Template-Based Configuration (time savings)
- H9: Integration Architecture Feasibility (technical)

---

## 8. Validation Plan

### 8.1 Validation Methods

| Method | Hypotheses | Timeline | Owner |
|--------|------------|----------|-------|
| User interviews | H1, H3, H14, H15, H16 | Week 1-2 | Product |
| Regulatory research | H2 | Week 1 | Product |
| Formula engine POC | H6 | Week 2-3 | Engineering |
| Integration POC | H9 | Week 2-3 | Engineering |
| Multi-tenant POC | H10 | Week 3-4 | Engineering |
| Market research | H11 | Week 2 | Product |
| Template testing | H5 | Week 3-4 | Product |

### 8.2 Success Criteria

| Hypothesis | Success Metric | Threshold |
|------------|----------------|-----------|
| H1 | Admins reporting pain point | >60% |
| H4 | Configuration errors reduced | >30% |
| H6 | Formulas expressible | >80% |
| H9 | Integration latency | <500ms |
| H14 | Users completing config | >70% |

---

## 9. Kill Decision Framework

### 9.1 Kill Triggers

| Trigger | Hypotheses Affected | Action |
|---------|---------------------|--------|
| Problem doesn't exist | H1, H2, H3 | Pivot or stop |
| Solution not viable | H4, H5, H6, H7 | Redesign or stop |
| Technical infeasible | H8, H9, H10 | Redesign or stop |
| Market too small | H11 | Stop or narrow focus |
| Timeline unrealistic | H12 | Rescope or stop |
| Users can't use it | H14, H15, H16 | Redesign UX |

### 9.2 Pivot Options

| Pivot From | Pivot To | Trigger |
|------------|----------|---------|
| Configuration-first | Integrated config+calc | H4 fails |
| Self-service | IT-assisted | H14 fails |
| Vietnam-only | Multi-market | H2 fails |
| API-first | UI-first | H7 fails |

---

**Next Artifact**: 04-research-synthesis.md