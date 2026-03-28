# Offer Management Guide

**Version**: 1.0  
**Last Updated**: 2025-12-15  
**Audience**: Recruiters, Hiring Managers, HR Administrators  
**Reading Time**: 25-30 minutes

---

## 📋 Overview

This guide helps you create, send, and manage job offers for candidates using xTalent's Offer Management feature.

### What You'll Learn
- How to create offer packages with total compensation breakdown
- How to use offer templates for consistency
- How to send offers with e-signature integration
- How to track offer status and acceptance
- How to handle counter-offers and negotiations

### Prerequisites
- Basic understanding of compensation and benefits
- Access to Total Rewards module
- Recruiter or Hiring Manager role
- Candidate data in Talent Acquisition module (optional)

---

## 🎯 Section 1: Offer Fundamentals

### 1.1 What is an Offer Package?

An **Offer Package** is a comprehensive document that presents the total compensation and benefits being offered to a candidate. It includes:

**Components**:
- **Base Compensation**: Salary, hourly rate, or contract rate
- **Variable Pay**: Bonuses, commissions, equity grants
- **Benefits**: Health insurance, retirement, PTO, perks
- **One-Time Payments**: Sign-on bonus, relocation assistance
- **Total Value**: Sum of all components (annual value)

**Example**:
```yaml
Offer Package: Senior Software Engineer
  
  Base Compensation:
    Annual Salary: 50,000,000 VND
    Payment Frequency: Monthly
    
  Variable Pay:
    Annual Bonus Target: 10,000,000 VND (20% of base)
    Equity Grant: 1,000 RSUs (vesting 4 years)
    Equity Value: ~15,000,000 VND (at current FMV)
    
  Benefits:
    Health Insurance: Premium plan (employer-paid)
    Dental Insurance: Included
    Life Insurance: 2x annual salary
    Retirement: 401k with 5% match
    PTO: 15 days/year + 12 holidays
    
  One-Time:
    Sign-On Bonus: 10,000,000 VND
    Relocation Assistance: 5,000,000 VND
    
  Total First Year Value: ~95,000,000 VND
  Ongoing Annual Value: ~80,000,000 VND
```

### 1.2 Offer Templates

**Offer Templates** standardize offer creation for consistency and efficiency.

**Why Use Templates**:
- **Consistency**: All offers for same role have same structure
- **Speed**: Pre-filled components, just adjust values
- **Compliance**: Ensures all required elements included
- **Approval**: Templates pre-approved by legal/HR

**Template Types**:

| Template Type | Use Case | Flexibility |
|---------------|----------|-------------|
| **Standard** | Most common roles | Medium (adjust salary, bonus) |
| **Executive** | C-level, VP positions | High (custom equity, perks) |
| **Hourly** | Contract, temp workers | Low (hourly rate only) |
| **Intern** | Internship programs | Low (fixed stipend) |
| **Sales** | Sales roles | High (commission structure) |

**Example Template**:
```yaml
Template: "Software Engineer - Senior Level"
  Code: SWE_SENIOR_VN
  Grade: G3
  Location: Vietnam
  
  Base Compensation:
    Salary Range: 40M - 50M VND (based on experience)
    Default: 45M VND
    Payment: Monthly
    
  Variable Pay:
    Bonus Target: 20% of base
    Equity Grant: 800-1,200 RSUs
    Default Equity: 1,000 RSUs
    
  Benefits (Standard Package):
    - Health Insurance: Premium
    - Dental: Included
    - Life: 2x salary
    - 401k: 5% match
    - PTO: 15 days
    
  One-Time (Optional):
    Sign-On Bonus: 0-15M VND (negotiable)
    Relocation: 0-10M VND (if applicable)
    
  Approval Required:
    - Salary > 48M: Director approval
    - Equity > 1,100: VP approval
    - Sign-on > 10M: VP approval
```

### 1.3 Total Compensation Calculation

**How Total Value is Calculated**:

```yaml
Calculation Formula:
  
  Annual Cash Compensation:
    = Base Salary
    + Target Bonus
    + Commission (if applicable)
  
  Annual Benefits Value:
    = Health Insurance (employer portion)
    + Retirement Match (employer portion)
    + Other Benefits (estimated value)
  
  Annual Equity Value:
    = (Total Equity Grant × Current FMV) / Vesting Years
  
  First Year Total:
    = Annual Cash Compensation
    + Annual Benefits Value
    + Annual Equity Value
    + Sign-On Bonus
    + Relocation
  
  Ongoing Annual Total:
    = Annual Cash Compensation
    + Annual Benefits Value
    + Annual Equity Value
```

**Example Calculation**:
```yaml
Position: Senior Software Engineer

Base Salary: 50,000,000 VND/year

Target Bonus: 10,000,000 VND (20% of base)

Equity Grant: 1,000 RSUs
  Current FMV: $15/share = 375,000 VND/share
  Total Value: 375,000,000 VND
  Vesting: 4 years
  Annual Value: 93,750,000 VND

Benefits (Employer Portion):
  Health Insurance: 12,000,000 VND/year
  Retirement Match: 2,500,000 VND/year (5% of base)
  Life Insurance: 1,000,000 VND/year
  Total Benefits: 15,500,000 VND/year

One-Time:
  Sign-On Bonus: 10,000,000 VND
  Relocation: 5,000,000 VND

First Year Total:
  = 50M (base) + 10M (bonus) + 93.75M (equity) + 15.5M (benefits) + 10M (sign-on) + 5M (relocation)
  = 184,250,000 VND

Ongoing Annual Total:
  = 50M + 10M + 93.75M + 15.5M
  = 169,250,000 VND
```

### 1.4 Approval Workflows

**Why Approvals Are Needed**:
- **Budget Control**: Ensure offers within budget
- **Equity**: Prevent pay inequity
- **Authority**: Higher compensation requires higher approval
- **Compliance**: Legal/HR review for risk

**Approval Levels**:

| Offer Element | Threshold | Approver |
|---------------|-----------|----------|
| **Base Salary** | Within range | Hiring Manager |
| **Base Salary** | Above range | Director |
| **Base Salary** | 20%+ above range | VP |
| **Equity Grant** | Standard amount | Hiring Manager |
| **Equity Grant** | Above standard | VP |
| **Sign-On Bonus** | < 10M VND | Director |
| **Sign-On Bonus** | >= 10M VND | VP |
| **Total Package** | > 200M VND | CFO |

**Approval Workflow Example**:
```yaml
Offer: Senior Engineer - 55M VND base

Validation:
  Grade Range: 40M - 50M VND
  Proposed: 55M VND
  Variance: +10% above range
  
Routing:
  Step 1: Hiring Manager creates offer
  Step 2: System detects above-range salary
  Step 3: Routes to Director for approval
  Step 4: Director approves with justification
  Step 5: Routes to VP (>10% above range)
  Step 6: VP approves
  Step 7: Offer ready to send
  
Justification Required:
  "Candidate has 10 years experience (vs 5-7 typical for G3).
   Expertise in AI/ML critical for new product line.
   Market data shows top talent at 55M+ for this skill set."
```

---

## 📝 Section 2: Creating Offers

### 2.1 Using Offer Templates

**Step-by-Step**:

1. **Navigate to Offer Management**
   - Total Rewards → Offers → Create Offer
   - Or: From candidate profile → Create Offer

2. **Select Template**
   - Choose template matching role and level
   - System pre-fills components
   - Review default values

3. **Enter Candidate Information**
   ```yaml
   Candidate Details:
     Name: Nguyen Van A
     Email: nguyenvana@email.com
     Phone: +84 90 123 4567
     Position: Senior Software Engineer
     Department: Engineering
     Location: Hanoi, Vietnam
     Start Date: 2026-01-15
     Reports To: Engineering Manager
   ```

4. **Customize Compensation**
   ```yaml
   Adjustments from Template:
     Base Salary: 45M → 48M VND (based on experience)
     Equity Grant: 1,000 → 1,100 RSUs (strong candidate)
     Sign-On Bonus: 0 → 8M VND (to match current salary)
     
   Justification:
     "Candidate has 8 years experience and expertise in our tech stack.
      Sign-on bonus offsets loss of unvested equity at current company."
   ```

5. **Review Total Value**
   - System calculates total compensation
   - Review first-year vs ongoing value
   - Compare to budget and peers

6. **Add Custom Terms** (if needed)
   - Probation period
   - Non-compete clause
   - Intellectual property agreement
   - Remote work policy

7. **Submit for Approval**
   - System routes based on approval rules
   - Approvers receive notification
   - Track approval status

### 2.2 Creating Custom Offers

**When to Use Custom Offers**:
- Unique role not covered by templates
- Executive-level position
- Consultant/contractor arrangement
- Special circumstances (retention, counter-offer)

**Step-by-Step**:

1. **Start from Blank**
   - Create Offer → Custom Offer
   - No pre-filled components

2. **Define Base Compensation**
   ```yaml
   Base Compensation Options:
     
     Option 1: Annual Salary
       Amount: 60,000,000 VND
       Frequency: Monthly
       Prorated: Yes
     
     Option 2: Hourly Rate
       Rate: 300,000 VND/hour
       Expected Hours: 40/week
       Overtime: 1.5x after 40 hours
     
     Option 3: Contract Rate
       Rate: 50,000,000 VND/month
       Duration: 6 months
       Renewal: Optional
   ```

3. **Add Variable Pay Components**
   ```yaml
   Variable Pay (Select applicable):
     
     ☑ Annual Bonus
       Target: 15,000,000 VND
       Based On: Company + Individual performance
       Payment: March annually
     
     ☑ Equity Grant
       Type: RSU
       Quantity: 1,500 shares
       Vesting: 4 years (1-year cliff, monthly thereafter)
       FMV: 375,000 VND/share
     
     ☐ Commission
       (Not applicable for this role)
     
     ☑ Spot Bonus Eligible
       Discretionary bonuses for exceptional work
   ```

4. **Select Benefits Package**
   ```yaml
   Benefits (Choose package or customize):
     
     Package: Executive Package
       Health: Premium Plus (family coverage)
       Dental: Premium
       Vision: Included
       Life: 3x salary
       Disability: Long-term disability
       Retirement: 401k with 7% match
       PTO: 20 days + 12 holidays
       Wellness: $2,000 annual allowance
       Parking: Reserved spot
       Phone: Company phone + plan
   ```

5. **Add One-Time Payments**
   ```yaml
   One-Time Payments:
     
     Sign-On Bonus: 15,000,000 VND
       Payment: First paycheck
       Repayment: If leave within 1 year
     
     Relocation Assistance: 20,000,000 VND
       Covers: Moving, temporary housing, travel
       Payment: Reimbursement with receipts
     
     Equipment Allowance: 5,000,000 VND
       For: Home office setup
       Payment: Upon start
   ```

6. **Calculate Total Value**
   - System sums all components
   - Shows annual and first-year totals
   - Compares to market data (if available)

### 2.3 Offer Customization Options

**Customizable Elements**:

| Element | Customization | Example |
|---------|---------------|---------|
| **Start Date** | Any date | Flexible for candidate notice period |
| **Probation** | 0-6 months | 3 months standard, 6 for senior roles |
| **Work Schedule** | Full-time, Part-time, Flex | 40 hrs/week, remote 2 days/week |
| **Salary Review** | Frequency | Annual review in March |
| **Bonus Timing** | Payment schedule | Quarterly vs annual |
| **Equity Vesting** | Schedule | 4-year standard, 3-year for retention |
| **Benefits Start** | Effective date | Day 1 vs after probation |
| **PTO Accrual** | Immediate vs accrued | 15 days immediate vs 1.25/month |

**Example Customizations**:
```yaml
Offer Customizations for Remote Candidate:
  
  Work Arrangement:
    Location: Remote (Hanoi-based)
    Office Visits: Quarterly (company pays travel)
    Equipment: Laptop, monitor, chair provided
    Internet: 1M VND/month allowance
  
  Compensation Adjustments:
    Base Salary: Same as office-based
    No Lunch Allowance: (not applicable for remote)
    No Transportation: (not applicable for remote)
    + Home Office Allowance: 2M VND/month
  
  Benefits Adjustments:
    Health Insurance: Same coverage
    Wellness: Virtual gym membership option
    PTO: Same (15 days + holidays)
```

---

## 📧 Section 3: Sending Offers

### 3.1 Offer Letter Generation

**What's Included in Offer Letter**:
1. **Header**: Company logo, date, candidate name
2. **Position Details**: Title, department, location, start date, reports to
3. **Compensation Summary**: Base, bonus, equity, benefits
4. **Total Value**: First-year and ongoing annual
5. **Benefits Overview**: Health, retirement, PTO, perks
6. **Terms and Conditions**: Probation, at-will employment, confidentiality
7. **Acceptance**: Signature block, deadline
8. **Attachments**: Benefits guide, equity plan details, employee handbook

**Letter Format**:
```yaml
Offer Letter Structure:

[Company Letterhead]

December 15, 2025

Nguyen Van A
nguyenvana@email.com

Dear Van A,

We are pleased to offer you the position of Senior Software Engineer at [Company Name].

POSITION DETAILS
- Title: Senior Software Engineer
- Department: Engineering
- Location: Hanoi, Vietnam
- Start Date: January 15, 2026
- Reports To: Engineering Manager

COMPENSATION
Your compensation package includes:

Base Salary: 48,000,000 VND per year, paid monthly

Annual Bonus: Target of 9,600,000 VND (20% of base salary), based on company and individual performance

Equity Grant: 1,100 Restricted Stock Units (RSUs), vesting over 4 years with a 1-year cliff

Sign-On Bonus: 8,000,000 VND, paid with your first paycheck

BENEFITS
You will be eligible for our comprehensive benefits package including:
- Health Insurance (Premium plan, employer-paid)
- Dental and Vision Insurance
- Life Insurance (2x annual salary)
- 401(k) Retirement Plan (5% employer match)
- Paid Time Off (15 days annually + 12 holidays)
- [Additional benefits...]

TOTAL VALUE
Your total first-year compensation value is approximately 95,000,000 VND.

TERMS
This offer is contingent upon:
- Successful background check
- Proof of eligibility to work in Vietnam
- Signing of confidentiality and IP agreement

This is an at-will employment relationship. You will serve a 3-month probationary period.

ACCEPTANCE
To accept this offer, please sign and return by December 22, 2025.

We are excited about the possibility of you joining our team!

Sincerely,
[Hiring Manager Name]
[Title]

ACCEPTANCE
I accept the above offer of employment:

_______________________  __________
Signature                Date
```

### 3.2 E-Signature Integration

**How E-Signature Works**:

1. **Generate Offer Letter**
   - System creates PDF from offer data
   - Includes all compensation details
   - Adds signature fields

2. **Send for E-Signature**
   - Integrates with DocuSign, Adobe Sign, or similar
   - Candidate receives email with link
   - Can sign from any device

3. **Candidate Reviews and Signs**
   - Opens offer letter in browser
   - Reviews all details
   - Signs electronically
   - Submits signature

4. **System Receives Signed Copy**
   - Signed PDF returned to xTalent
   - Offer status updated to ACCEPTED
   - Notifications sent to hiring team
   - Document archived

**E-Signature Workflow**:
```yaml
E-Signature Process:

Step 1: Recruiter Sends Offer
  Action: Click "Send Offer with E-Signature"
  System: Generates PDF, sends to DocuSign
  
Step 2: Candidate Receives Email
  From: DocuSign (on behalf of Company)
  Subject: "Job Offer - Senior Software Engineer"
  Body: "Please review and sign your offer letter"
  Link: Secure DocuSign link
  
Step 3: Candidate Opens Link
  View: Offer letter PDF in browser
  Actions: Review, Download, Sign
  
Step 4: Candidate Signs
  Method: Draw, Type, or Upload signature
  Required: Signature + Date
  Optional: Initials on each page
  
Step 5: Candidate Submits
  Action: Click "Finish"
  System: Validates signature
  Email: Confirmation sent to candidate
  
Step 6: System Updates
  Offer Status: PENDING → ACCEPTED
  Notification: Hiring Manager, HR, Recruiter
  Document: Signed PDF attached to candidate record
  Next Steps: Onboarding workflow triggered
```

### 3.3 Offer Expiration and Deadlines

**Why Set Deadlines**:
- **Planning**: Need to know if candidate accepts to plan onboarding
- **Alternatives**: If declined, need time to pursue other candidates
- **Urgency**: Creates sense of urgency for candidate decision
- **Budget**: Hold budget allocation for limited time

**Typical Deadlines**:

| Offer Type | Deadline | Rationale |
|------------|----------|-----------|
| **Standard** | 7 days | Reasonable time to decide |
| **Senior** | 10-14 days | May need to negotiate current employer |
| **Executive** | 14-30 days | Complex decision, may involve relocation |
| **Intern** | 3-5 days | Simple offer, quick decision |
| **Counter-Offer** | 2-3 days | Already in negotiation, faster decision |

**Expiration Handling**:
```yaml
Offer Expiration Workflow:

Offer Sent: Dec 15, 2025
Deadline: Dec 22, 2025 (7 days)

Reminders:
  Day 3 (Dec 18): "Reminder: Offer expires in 4 days"
  Day 5 (Dec 20): "Reminder: Offer expires in 2 days"
  Day 6 (Dec 21): "Final reminder: Offer expires tomorrow"

If Accepted Before Deadline:
  Status: ACCEPTED
  Next: Onboarding workflow
  
If Deadline Passes:
  Status: EXPIRED
  Notification: Hiring team notified
  Options:
    - Extend deadline (requires approval)
    - Withdraw offer
    - Create new offer (if terms change)
```

### 3.4 Candidate Communication

**Best Practices for Offer Communication**:

✅ **DO**:
- **Call First**: Verbal offer before email
- **Be Enthusiastic**: Show excitement about candidate
- **Explain Components**: Walk through offer letter
- **Answer Questions**: Be available for clarifications
- **Set Expectations**: Clear deadline and next steps
- **Follow Up**: Check in during decision period

❌ **DON'T**:
- **Email Only**: Impersonal, candidate may have questions
- **Rush**: Give reasonable time to decide
- **Pressure**: Don't guilt-trip or threaten
- **Ghost**: Stay in touch during decision period
- **Surprise**: All terms should be discussed before formal offer

**Communication Timeline**:
```yaml
Offer Communication Flow:

Day 0 (Offer Decision Made):
  - Hiring Manager calls candidate
  - Verbal offer extended
  - Candidate asks questions
  - Manager explains next steps
  
Day 0 (2 hours later):
  - Formal offer letter sent via email
  - E-signature link included
  - Deadline clearly stated (7 days)
  
Day 2:
  - Recruiter checks in via email
  - "Any questions about the offer?"
  - Offers to schedule call if needed
  
Day 4:
  - Hiring Manager calls candidate
  - Checks on decision timeline
  - Addresses any concerns
  
Day 6:
  - Recruiter sends reminder
  - "Offer expires tomorrow"
  - Offers deadline extension if needed
  
Day 7:
  - Candidate accepts or declines
  - If accepted: Onboarding starts
  - If declined: Thank candidate, ask for feedback
```

---

## 📊 Section 4: Offer Tracking

### 4.1 Offer Status Management

**Offer Statuses**:

| Status | Description | Next Actions |
|--------|-------------|--------------|
| **DRAFT** | Offer being created | Complete and submit for approval |
| **PENDING_APPROVAL** | Awaiting approval | Approvers review and approve/reject |
| **APPROVED** | Approved, ready to send | Send to candidate |
| **SENT** | Sent to candidate | Wait for candidate response |
| **VIEWED** | Candidate opened offer | Follow up if no action |
| **ACCEPTED** | Candidate accepted | Start onboarding |
| **DECLINED** | Candidate declined | Pursue other candidates |
| **COUNTERED** | Candidate countered | Negotiate or create new offer |
| **EXPIRED** | Deadline passed | Extend or withdraw |
| **WITHDRAWN** | Company withdrew | Offer cancelled |

**Status Transitions**:
```yaml
Offer Lifecycle:

DRAFT
  ↓ (Submit for approval)
PENDING_APPROVAL
  ↓ (Approved)
APPROVED
  ↓ (Send to candidate)
SENT
  ↓ (Candidate opens)
VIEWED
  ↓ (Candidate responds)
ACCEPTED / DECLINED / COUNTERED
  ↓
ONBOARDING / CLOSED / NEGOTIATION
```

### 4.2 Offer Acceptance Tracking

**What Happens When Candidate Accepts**:

1. **E-Signature Captured**
   - Signed PDF received
   - Signature validated
   - Document archived

2. **Offer Status Updated**
   - Status: SENT → ACCEPTED
   - Acceptance date recorded
   - Signed document attached

3. **Notifications Sent**
   - Hiring Manager: "Candidate accepted!"
   - HR: "New hire onboarding needed"
   - IT: "Prepare equipment for start date"
   - Facilities: "Prepare workspace"

4. **Onboarding Triggered**
   - Create employee record (if not exists)
   - Assign to onboarding workflow
   - Send welcome email
   - Schedule orientation

5. **Budget Updated**
   - Mark position as filled
   - Allocate compensation budget
   - Update headcount

**Acceptance Tracking Dashboard**:
```yaml
Offer Acceptance Metrics (Q4 2025):

Total Offers Sent: 50
  Accepted: 38 (76%)
  Declined: 8 (16%)
  Pending: 4 (8%)
  
Acceptance Rate by Level:
  Junior: 85% (17/20)
  Mid: 75% (15/20)
  Senior: 60% (6/10)
  
Average Time to Accept: 4.2 days

Top Decline Reasons:
  1. Compensation (4 offers)
  2. Location/Remote (2 offers)
  3. Accepted other offer (2 offers)
```

### 4.3 Handling Rejections

**When Candidate Declines**:

1. **Update Status**
   - Status: SENT → DECLINED
   - Decline date recorded
   - Reason captured (if provided)

2. **Request Feedback**
   - Email: "We'd love to understand your decision"
   - Questions:
     - What was the primary reason for declining?
     - Was there anything we could have done differently?
     - Would you consider us in the future?

3. **Analyze Feedback**
   - Common decline reasons
   - Competitive intelligence (if candidate shares)
   - Improve future offers

4. **Next Steps**
   - Pursue backup candidate
   - Re-open position
   - Adjust offer strategy if needed

**Decline Reasons Analysis**:
```yaml
Decline Reasons (Last 6 Months):

Compensation Too Low: 35%
  - Base salary below expectations
  - Total package not competitive
  - Better offer from competitor
  
Location/Remote Policy: 25%
  - Required office presence
  - No remote work option
  - Relocation not feasible
  
Accepted Other Offer: 20%
  - Timing (other offer came first)
  - Better fit with other company
  - Closer to home
  
Role/Responsibilities: 10%
  - Not aligned with career goals
  - Scope too narrow/broad
  - Unclear growth path
  
Company/Culture: 10%
  - Culture fit concerns
  - Company size/stage
  - Industry preference

Actions Taken:
  - Increased salary ranges for competitive roles
  - Introduced hybrid work policy
  - Improved offer turnaround time
  - Enhanced role descriptions
```

### 4.4 Counter-Offers and Negotiations

**When Candidate Counters**:

1. **Receive Counter-Offer**
   - Candidate responds with different terms
   - Typically: Higher salary, more equity, sign-on bonus, remote work

2. **Evaluate Counter**
   ```yaml
   Counter-Offer Evaluation:
     
     Original Offer:
       Base: 48M VND
       Equity: 1,100 RSUs
       Sign-On: 8M VND
       Total: ~95M VND
     
     Candidate Counter:
       Base: 52M VND (+8.3%)
       Equity: 1,300 RSUs (+18%)
       Sign-On: 10M VND (+25%)
       Remote: 3 days/week
       Total: ~105M VND (+10.5%)
     
     Assessment:
       Budget: Within range? ✅ (max 55M for role)
       Market: Competitive? ✅ (top 75th percentile)
       Equity: Reasonable? ⚠️ (above standard, needs VP approval)
       Remote: Feasible? ✅ (company policy allows)
       
     Decision: Counter-counter at 50M base, 1,200 RSUs, 10M sign-on, 2 days remote
   ```

3. **Respond to Counter**
   - **Accept**: If within budget and reasonable
   - **Counter-Counter**: Meet in the middle
   - **Decline**: If unreasonable or above budget

4. **Create Revised Offer**
   - Update offer with new terms
   - Re-submit for approval (if needed)
   - Send revised offer to candidate

**Negotiation Best Practices**:

✅ **DO**:
- **Understand Why**: Ask what's driving the counter
- **Be Flexible**: Find creative solutions (e.g., remote work, extra PTO)
- **Stay Professional**: Respectful even if declining
- **Move Quickly**: Don't lose momentum
- **Document Everything**: Track all negotiation points

❌ **DON'T**:
- **Take Personally**: It's business, not personal
- **Lowball**: Insultingly low counter-counter damages relationship
- **Drag Out**: Prolonged negotiation signals indecision
- **Break Budget**: Don't overpay to fill role
- **Ghost**: Always respond, even if declining

---

## 📈 Section 5: Offer Analytics

### 5.1 Offer Metrics

**Key Metrics to Track**:

```yaml
Offer Performance Dashboard:

Offer Volume:
  Q4 2025: 50 offers sent
  Q3 2025: 45 offers sent
  Trend: ↑ 11%

Acceptance Rate:
  Overall: 76%
  By Level:
    - Junior: 85%
    - Mid: 75%
    - Senior: 60%
  By Department:
    - Engineering: 70%
    - Sales: 80%
    - Operations: 85%

Time Metrics:
  Time to Offer: 12 days (from final interview)
  Time to Accept: 4.2 days (from offer sent)
  Total Time to Hire: 35 days

Offer Competitiveness:
  Above Market: 20%
  At Market: 65%
  Below Market: 15%
  
Decline Reasons:
  Compensation: 35%
  Location: 25%
  Other Offer: 20%
  Role Fit: 10%
  Company/Culture: 10%
```

### 5.2 Offer Competitiveness Analysis

**Comparing Offers to Market**:

```yaml
Market Comparison (Senior Engineer, Vietnam):

Our Offer:
  Base: 48M VND
  Bonus: 9.6M VND
  Equity: 1,100 RSUs (~20M VND/year)
  Total: ~77.6M VND/year

Market Data (Glassdoor, Salary.com):
  25th Percentile: 60M VND
  50th Percentile: 70M VND
  75th Percentile: 85M VND
  90th Percentile: 100M VND

Our Position: 70th Percentile (competitive)

Competitor Offers (from declined candidates):
  Company A: 75M VND total
  Company B: 80M VND total
  Company C: 72M VND total

Recommendation: 
  - Current offer competitive for mid-level seniors
  - Consider increasing for top talent (80M+ range)
  - Equity component differentiates us from competitors
```

### 5.3 Improving Offer Acceptance

**Strategies to Increase Acceptance**:

1. **Competitive Compensation**
   - Benchmark regularly against market
   - Adjust ranges annually
   - Offer top 75th percentile for critical roles

2. **Fast Turnaround**
   - Reduce time from interview to offer
   - Streamline approval process
   - Send offer within 48 hours of decision

3. **Clear Communication**
   - Verbal offer before formal letter
   - Explain total value clearly
   - Be available for questions

4. **Flexibility**
   - Remote work options
   - Flexible start dates
   - Customizable benefits

5. **Sell the Opportunity**
   - Growth potential
   - Exciting projects
   - Company culture
   - Team quality

**A/B Testing Offer Strategies**:
```yaml
Experiment: Sign-On Bonus vs Higher Base

Group A (25 offers):
  Base: 48M VND
  Sign-On: 10M VND
  Acceptance: 72%

Group B (25 offers):
  Base: 50M VND
  Sign-On: 0 VND
  Acceptance: 80%

Result: Higher base more attractive than sign-on bonus
Action: Adjust template to prioritize base over sign-on
```

---

## ✅ Best Practices

### For Recruiters

✅ **DO**:
- **Move Fast**: Send offer within 48 hours of decision
- **Call First**: Verbal offer before email
- **Explain Value**: Walk through total compensation
- **Be Available**: Answer questions promptly
- **Follow Up**: Check in during decision period
- **Track Metrics**: Monitor acceptance rates and reasons for decline

❌ **DON'T**:
- **Email Only**: Impersonal, candidate may have questions
- **Delay**: Candidate may accept other offer
- **Surprise**: All terms should be discussed beforehand
- **Pressure**: Give reasonable time to decide
- **Ghost**: Stay in touch during decision period

### For Hiring Managers

✅ **DO**:
- **Sell the Role**: Explain exciting projects and growth
- **Be Enthusiastic**: Show genuine excitement about candidate
- **Stay Involved**: Check in during offer period
- **Be Flexible**: Consider reasonable requests
- **Respect Budget**: Don't overpromise

❌ **DON'T**:
- **Overpromise**: Don't commit to things outside your control
- **Lowball**: Insultingly low offers damage employer brand
- **Rush**: Give candidate time to make informed decision
- **Ignore HR**: Work with HR on offer terms

### For HR Administrators

✅ **DO**:
- **Maintain Templates**: Keep templates current and compliant
- **Benchmark Regularly**: Update salary ranges quarterly
- **Streamline Approvals**: Fast approval process
- **Track Analytics**: Monitor offer performance
- **Ensure Compliance**: Legal review of offer terms
- **Document Everything**: Maintain offer history

❌ **DON'T**:
- **Stale Templates**: Outdated templates lead to errors
- **Slow Approvals**: Delays lose candidates
- **Ignore Market**: Non-competitive offers get declined
- **Skip Legal Review**: Risk of non-compliant terms

---

## ⚠️ Common Pitfalls

### Pitfall 1: Slow Offer Process

❌ **Wrong**:
```yaml
Timeline:
  Final Interview: Dec 1
  Hiring Decision: Dec 3
  Offer Approval: Dec 10 (7 days delay)
  Offer Sent: Dec 12
  Candidate Accepts Other Offer: Dec 13
  
Result: Lost candidate to faster competitor
```

✅ **Correct**:
```yaml
Timeline:
  Final Interview: Dec 1
  Hiring Decision: Dec 1 (same day)
  Offer Approval: Dec 2 (next day)
  Offer Sent: Dec 2
  Candidate Accepts: Dec 5
  
Result: Candidate secured
```

**Why**: Top candidates have multiple offers. Speed matters.

---

### Pitfall 2: Unclear Total Value

❌ **Wrong**:
```yaml
Offer Letter:
  "Base Salary: 48M VND
   Bonus: Eligible for annual bonus
   Equity: You will receive stock options
   Benefits: Comprehensive benefits package"
   
Candidate Reaction: "What's the total value? How much equity?"
```

✅ **Correct**:
```yaml
Offer Letter:
  Base Salary: 48,000,000 VND/year
  Annual Bonus: 9,600,000 VND (20% target)
  Equity Grant: 1,100 RSUs (valued at ~20M VND/year over 4 years)
  Benefits Value: ~15M VND/year (employer portion)
  
  Total First Year Value: ~92.6M VND
  Ongoing Annual Value: ~82.6M VND
  
Candidate Reaction: "Clear and compelling!"
```

**Why**: Candidates need to understand total value to make informed decision.

---

### Pitfall 3: Ignoring Counter-Offers

❌ **Wrong**:
```yaml
Candidate: "I'd like to counter at 52M base"
Recruiter: "Sorry, that's our final offer"
Candidate: Accepts other offer
```

✅ **Correct**:
```yaml
Candidate: "I'd like to counter at 52M base"
Recruiter: "Let me understand what's driving that. Is it market data, 
           current salary, or other offers?"
Candidate: "Current salary is 50M, and I have another offer at 53M"
Recruiter: "I see. Let me discuss with the team. We may not be able 
           to match 52M base, but perhaps we can increase equity or 
           sign-on bonus to bridge the gap?"
           
Result: Negotiated solution at 50M base + 12M sign-on + 1,300 RSUs
```

**Why**: Negotiation is expected. Be flexible and creative.

---

## 🎓 Quick Reference

### Offer Creation Checklist

- [ ] Select appropriate template
- [ ] Enter candidate information
- [ ] Set base compensation (within range)
- [ ] Add variable pay (bonus, equity, commission)
- [ ] Select benefits package
- [ ] Add one-time payments (sign-on, relocation)
- [ ] Review total value calculation
- [ ] Add custom terms (if needed)
- [ ] Submit for approval
- [ ] Track approval status
- [ ] Send offer when approved

### Offer Sending Checklist

- [ ] Call candidate with verbal offer
- [ ] Explain compensation components
- [ ] Answer candidate questions
- [ ] Send formal offer letter via email
- [ ] Include e-signature link
- [ ] Set clear deadline (7 days typical)
- [ ] Follow up during decision period
- [ ] Track offer status
- [ ] Respond to counter-offers promptly

### Offer Acceptance Checklist

- [ ] Receive signed offer letter
- [ ] Update offer status to ACCEPTED
- [ ] Notify hiring team
- [ ] Trigger onboarding workflow
- [ ] Create employee record
- [ ] Allocate budget
- [ ] Update headcount
- [ ] Send welcome email
- [ ] Schedule orientation

---

## 📚 Related Guides

- [Concept Overview](./01-concept-overview.md) - TR module overview
- [Conceptual Guide](./02-conceptual-guide.md) - System workflows
- [Compensation Management Guide](./03-compensation-management-guide.md) - Salary structures and ranges
- [Variable Pay Guide](./04-variable-pay-guide.md) - Bonus and equity details
- [Benefits Administration Guide](./05-benefits-administration-guide.md) - Benefits packages
- [Total Rewards Statements Guide](./08-total-rewards-statements-guide.md) - Total value communication (Planned)

---

**Document Version**: 1.0  
**Created**: 2025-12-15  
**Last Review**: 2025-12-15  
**Author**: xTalent Documentation Team  
**Status**: ✅ Complete
