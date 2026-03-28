# Recognition Programs Guide

**Version**: 1.0  
**Last Updated**: 2025-12-15  
**Audience**: All Users (Employees, Managers, HR Administrators)  
**Reading Time**: 20-25 minutes

---

## 📋 Overview

This guide helps you understand and use the Recognition Programs feature in xTalent, from giving recognition to redeeming points for perks.

### What You'll Learn
- How recognition programs work (events, points, perks)
- How to give and receive recognition
- How to manage your point balance
- How to browse and redeem perks
- How to set up and administer recognition programs (HR)

### Prerequisites
- Basic understanding of HR concepts
- Access to xTalent Total Rewards module
- Employee, Manager, or HR Administrator role

---

## 🎯 Section 1: Recognition Fundamentals

### 1.1 What is Recognition?

**Recognition** is a way to acknowledge and reward employees for their achievements, behaviors, and contributions. In xTalent, recognition is point-based: employees earn points for achievements and redeem them for perks.

**Key Benefits**:
- **Boosts Morale**: Employees feel valued and appreciated
- **Reinforces Culture**: Recognizes behaviors aligned with company values
- **Increases Engagement**: Encourages continued high performance
- **Builds Community**: Strengthens peer and manager relationships
- **Tangible Rewards**: Points can be redeemed for real perks

### 1.2 Recognition Event Types

A **Recognition Event Type** defines what can be recognized and how many points are awarded.

**Common Event Types**:

| Event Type | Description | Points | Who Can Give |
|------------|-------------|--------|--------------|
| **Peer Recognition** | Colleague helping colleague | 50-100 | Any employee |
| **Manager Recognition** | Manager recognizing direct report | 100-500 | Managers only |
| **Team Achievement** | Team completing project | 200-1000 | Managers, HR |
| **Milestone** | Work anniversary, project completion | 500-2000 | HR, System |
| **Spot Bonus** | Exceptional one-time achievement | 1000-5000 | Managers, Executives |
| **Values Award** | Living company values | 250-500 | Any employee |

**Example**:
```yaml
Recognition Event Type: "Teamwork Excellence"
  Code: TEAMWORK_EXCELLENCE
  Category: PEER_RECOGNITION
  Points Awarded: 100
  Description: "Recognizing a colleague who went above and beyond to help the team"
  Who Can Give: All employees
  Requires Approval: No
  Visible To: Everyone
```

### 1.3 Point System Fundamentals

**How Points Work**:
1. **Earning**: Receive points when someone recognizes you
2. **Balance**: Track your total points (earned - redeemed - expired)
3. **Expiration**: Points expire after X months (typically 12 months) using FIFO
4. **Redemption**: Exchange points for perks from catalog

**Point Balance Components**:
```yaml
Point Account:
  Total Earned: 5,000 points
  Total Redeemed: 2,000 points
  Total Expired: 500 points
  Available Balance: 2,500 points
  
  Breakdown:
    - Jan 2024: 500 points (expires Jan 2025)
    - Mar 2024: 1,000 points (expires Mar 2025)
    - Jun 2024: 500 points (expires Jun 2025)
    - Sep 2024: 500 points (expires Sep 2025)
```

**FIFO Expiration Logic**:
- Oldest points expire first
- Redemptions deduct from oldest points first
- Prevents hoarding, encourages regular redemption

### 1.4 Perk Catalog Structure

The **Perk Catalog** is a collection of items and experiences employees can redeem with points.

**Perk Categories**:

| Category | Examples | Typical Point Range |
|----------|----------|---------------------|
| **Gift Cards** | Amazon, Starbucks, restaurants | 500-5,000 |
| **Experiences** | Spa, concert tickets, travel vouchers | 1,000-10,000 |
| **Merchandise** | Electronics, apparel, home goods | 2,000-15,000 |
| **Wellness** | Gym membership, fitness tracker | 1,000-5,000 |
| **Charitable Donations** | Donate to charity in your name | 500-10,000 |
| **Time Off** | Extra PTO day | 2,000-5,000 |
| **Learning** | Online course, book voucher | 500-3,000 |

**Example Perk**:
```yaml
Perk: "Starbucks $50 Gift Card"
  Code: STARBUCKS_50
  Category: GIFT_CARDS
  Point Cost: 1,000 points
  Description: "$50 Starbucks gift card - delivered via email"
  Inventory: 100 available
  Delivery Method: EMAIL
  Fulfillment Time: 1-2 business days
  Redemption Limit: 2 per employee per month
  Active: Yes
```

---

## 🎁 Section 2: Giving Recognition

### 2.1 Peer-to-Peer Recognition Workflow

**Step-by-Step**:

1. **Navigate to Recognition**
   - Go to: Total Rewards → Recognition → Give Recognition
   - Or: Click "Recognize" button on colleague's profile

2. **Select Recipient**
   - Search for employee by name
   - Select from your team or recent collaborators
   - Cannot recognize yourself

3. **Choose Event Type**
   - Select recognition type (e.g., "Teamwork Excellence")
   - System shows point value
   - Read description to ensure it fits

4. **Write Recognition Message**
   - Describe what they did (required, min 50 characters)
   - Be specific and genuine
   - Examples:
     - "Thank you for staying late to help me debug the production issue!"
     - "Your presentation to the client was outstanding and won us the deal"
     - "You always go the extra mile to help new team members feel welcome"

5. **Choose Visibility**
   - **Public**: Visible to everyone (default)
   - **Private**: Only visible to recipient and their manager
   - **Team**: Visible to your team only

6. **Submit Recognition**
   - Click "Send Recognition"
   - Recipient receives notification
   - Points added to their account immediately

**Example**:
```yaml
Recognition Event:
  From: John Doe (Engineering)
  To: Jane Smith (Engineering)
  Event Type: Teamwork Excellence
  Points: 100
  Message: "Jane spent 3 hours helping me troubleshoot a critical bug before the release. Her expertise and patience saved the day!"
  Visibility: Public
  Date: 2025-12-15
  Status: Completed
```

### 2.2 Manager Recognition

**When to Use**:
- Direct report exceeds performance goals
- Employee demonstrates leadership
- Significant project completion
- Living company values

**Manager-Specific Features**:
- Higher point values (100-500 points)
- Can recognize entire team at once
- Can attach to performance review
- Visible to HR for tracking

**Example**:
```yaml
Manager Recognition:
  From: Sarah Johnson (Engineering Manager)
  To: Development Team (5 members)
  Event Type: Team Achievement
  Points: 500 each (2,500 total)
  Message: "The team delivered the mobile app 2 weeks ahead of schedule with zero critical bugs. Outstanding work!"
  Visibility: Public
  Attached To: Q4 Performance Review
```

### 2.3 Recognition Best Practices

✅ **DO**:
- **Be Specific**: Describe exactly what they did
- **Be Timely**: Recognize soon after the achievement
- **Be Genuine**: Write from the heart, not generic templates
- **Recognize Often**: Don't wait for big achievements
- **Recognize Publicly**: Share successes with the team (when appropriate)
- **Vary Recipients**: Recognize different people, not just favorites

❌ **DON'T**:
- **Be Vague**: "Good job" is not enough
- **Wait Too Long**: Recognition loses impact after time
- **Copy-Paste**: Each recognition should be unique
- **Recognize Only Results**: Also recognize effort, behavior, values
- **Forget to Recognize**: Make it a habit, not an afterthought
- **Play Favorites**: Recognize fairly across the team

---

## 💰 Section 3: Point Management

### 3.1 Viewing Your Point Balance

**Where to Check**:
- Dashboard widget: "My Recognition Points"
- Total Rewards → Recognition → My Points
- Mobile app: Recognition tab

**What You See**:
```yaml
Point Balance Summary:
  Available Points: 2,500
  Points Expiring Soon: 500 (expires in 30 days)
  Lifetime Earned: 5,000
  Lifetime Redeemed: 2,000
  
  Recent Activity:
    - Dec 15: +100 points (Teamwork recognition from John)
    - Dec 10: -1,000 points (Redeemed Starbucks gift card)
    - Dec 5: +200 points (Manager recognition from Sarah)
    - Nov 30: -500 points (Expired - not used within 12 months)
```

### 3.2 Point Earning

**How You Earn Points**:

1. **Receive Recognition**
   - Peer recognition: 50-100 points
   - Manager recognition: 100-500 points
   - Team achievement: 200-1,000 points

2. **Milestones**
   - Work anniversary: 500-2,000 points
   - Project completion: 500-1,500 points
   - Certification earned: 1,000-3,000 points

3. **Automated Awards**
   - Perfect attendance: 100 points/month
   - Referral hired: 1,000 points
   - Training completion: 200-500 points

**Point Transaction History**:
```yaml
Transaction History:
  Dec 15, 2025:
    Type: RECOGNITION
    From: John Doe
    Amount: +100 points
    Balance: 2,500
    Reason: "Teamwork Excellence"
    Expires: Dec 15, 2026
  
  Dec 10, 2025:
    Type: REDEMPTION
    Perk: Starbucks $50 Gift Card
    Amount: -1,000 points
    Balance: 2,400
    Deducted From: 
      - Jan 2024 batch: 500 points
      - Mar 2024 batch: 500 points
  
  Dec 5, 2025:
    Type: RECOGNITION
    From: Sarah Johnson (Manager)
    Amount: +200 points
    Balance: 3,400
    Reason: "Outstanding code review"
    Expires: Dec 5, 2026
```

### 3.3 Point Expiration (FIFO)

**How Expiration Works**:
- Points expire 12 months after earning (configurable)
- Oldest points expire first (FIFO = First In, First Out)
- Expiration warnings sent 30, 14, and 7 days before
- Expired points cannot be recovered

**Example Scenario**:
```yaml
Current Date: Dec 15, 2025

Point Batches:
  Batch 1 (Jan 15, 2024): 500 points → Expires Jan 15, 2025 ⚠️ EXPIRED
  Batch 2 (Mar 15, 2024): 1,000 points → Expires Mar 15, 2025 ⚠️ Expiring in 3 months
  Batch 3 (Jun 15, 2024): 500 points → Expires Jun 15, 2025
  Batch 4 (Sep 15, 2024): 500 points → Expires Sep 15, 2025

What Happened:
  - Jan 15, 2025: Batch 1 (500 points) expired automatically
  - Available balance reduced from 3,000 to 2,500
  - Email sent: "You lost 500 points due to expiration"
  
Redemption Impact:
  - If you redeem 1,000 points today:
    - Deducted from Batch 2 (oldest): 1,000 points
    - Batch 2 now has 0 points (fully used)
    - Prevents future expiration of Batch 2
```

**Expiration Warnings**:
```yaml
Warning Email (30 days before):
  Subject: "500 points expiring soon!"
  Body: "You have 500 points expiring on Jan 15, 2025 (30 days). 
         Redeem now to avoid losing them!"
  Link: Browse Perk Catalog
  
Warning Email (7 days before):
  Subject: "⚠️ URGENT: 500 points expire in 7 days!"
  Body: "Last chance! 500 points expire on Jan 15, 2025. 
         Redeem today or lose them forever!"
  Link: Browse Perk Catalog
```

### 3.4 Point History and Reporting

**View Your History**:
- Total Rewards → Recognition → Point History
- Filter by: Date range, transaction type, status
- Export to Excel for personal tracking

**What You Can See**:
- All recognition received (who, when, why, points)
- All redemptions (what, when, points spent)
- All expirations (when, how many points lost)
- Point balance over time (chart)

---

## 🛍️ Section 4: Redeeming Perks

### 4.1 Browsing the Perk Catalog

**How to Browse**:
1. Navigate to: Total Rewards → Recognition → Perk Catalog
2. View by:
   - **Category**: Gift Cards, Experiences, Merchandise, etc.
   - **Point Range**: 0-1000, 1000-5000, 5000+
   - **Availability**: In Stock, Coming Soon, Out of Stock
3. Search by keyword (e.g., "Starbucks", "spa", "headphones")
4. Sort by: Point cost, popularity, newest

**Catalog View**:
```yaml
Perk Catalog (Gift Cards Category):
  
  Starbucks $50 Gift Card:
    Points: 1,000
    Availability: In Stock (87 available)
    Delivery: Email (1-2 business days)
    Limit: 2 per month
    Rating: ⭐⭐⭐⭐⭐ (4.8/5 from 234 redemptions)
  
  Amazon $100 Gift Card:
    Points: 2,000
    Availability: In Stock (45 available)
    Delivery: Email (1-2 business days)
    Limit: 1 per month
    Rating: ⭐⭐⭐⭐⭐ (4.9/5 from 567 redemptions)
  
  Grab $30 Voucher:
    Points: 600
    Availability: Out of Stock
    Delivery: Email
    Limit: 5 per month
    Notify Me: When back in stock
```

### 4.2 Redemption Workflow

**Step-by-Step**:

1. **Select Perk**
   - Click on perk to view details
   - Read description, delivery method, terms

2. **Check Eligibility**
   - System validates:
     - Sufficient points? ✅
     - Perk in stock? ✅
     - Not exceeded redemption limit? ✅
     - Meets any special requirements? ✅

3. **Confirm Redemption**
   - Review point cost
   - Confirm delivery address (if physical item)
   - Accept terms and conditions
   - Click "Redeem Now"

4. **Receive Confirmation**
   - Points deducted immediately (FIFO)
   - Redemption confirmation email sent
   - Tracking number provided (if applicable)

5. **Track Delivery**
   - View status: Total Rewards → Recognition → My Redemptions
   - Statuses: Pending → Processing → Shipped → Delivered

**Example Redemption**:
```yaml
Redemption Request:
  Employee: Jane Smith
  Perk: Starbucks $50 Gift Card
  Point Cost: 1,000 points
  Current Balance: 2,500 points
  
  Validation:
    ✅ Sufficient points (2,500 >= 1,000)
    ✅ Perk in stock (87 available)
    ✅ Under limit (0/2 redeemed this month)
    ✅ No special requirements
  
  Deduction (FIFO):
    - Batch from Mar 2024: 1,000 points deducted
    - New balance: 1,500 points
  
  Fulfillment:
    Status: Processing
    Delivery Method: Email
    Expected: Within 1-2 business days
    Tracking: REF-2025-12345
```

### 4.3 Delivery and Fulfillment

**Delivery Methods**:

| Method | Description | Typical Time | Examples |
|--------|-------------|--------------|----------|
| **Email** | Digital code sent to email | 1-2 business days | Gift cards, vouchers |
| **Physical** | Item shipped to address | 5-10 business days | Merchandise, apparel |
| **In-Person** | Pick up at office | Same day | Event tickets, vouchers |
| **Digital Download** | Download link sent | Immediate | E-books, courses |
| **Account Credit** | Added to HR system | Immediate | Extra PTO, parking |

**Tracking Your Redemption**:
```yaml
My Redemptions:
  
  Redemption #1:
    Perk: Starbucks $50 Gift Card
    Date: Dec 10, 2025
    Points: 1,000
    Status: Delivered ✅
    Delivery: Email sent to jane.smith@company.com
    Code: SBUX-XXXX-XXXX-XXXX
    Expires: Dec 10, 2026
  
  Redemption #2:
    Perk: Wireless Headphones
    Date: Nov 15, 2025
    Points: 3,000
    Status: Shipped 📦
    Tracking: UPS 1Z999AA10123456784
    Expected Delivery: Nov 20, 2025
    Delivery Address: 123 Main St, Hanoi, Vietnam
  
  Redemption #3:
    Perk: Spa Day Package
    Date: Oct 1, 2025
    Points: 2,500
    Status: Completed ✅
    Appointment: Oct 15, 2025 at 2:00 PM
    Location: Zen Spa, District 1, HCMC
    Confirmation: SPA-2025-789
```

### 4.4 Redemption Limits and Rules

**Why Limits Exist**:
- Prevent abuse (e.g., redeeming all gift cards and reselling)
- Ensure fair distribution (limited inventory)
- Encourage variety (try different perks)
- Manage costs (high-value items)

**Common Limits**:
```yaml
Limit Types:
  
  Per Month:
    - Starbucks gift cards: 2 per month
    - Amazon gift cards: 1 per month
    - Grab vouchers: 5 per month
  
  Per Quarter:
    - Spa packages: 1 per quarter
    - Concert tickets: 2 per quarter
    - Electronics: 1 per quarter
  
  Per Year:
    - Extra PTO day: 2 per year
    - Gym membership: 1 per year
    - Travel vouchers: 1 per year
  
  Lifetime:
    - Charitable donation: Unlimited
    - Learning courses: Unlimited
    - Gift cards: Unlimited (subject to monthly limits)
```

**What Happens When Limit Reached**:
```yaml
Scenario: Trying to redeem 3rd Starbucks gift card this month

Error Message:
  "You have reached the redemption limit for this perk.
   
   Limit: 2 per month
   Already Redeemed: 2 this month (Dec 1, Dec 10)
   Next Available: Jan 1, 2026
   
   Suggestions:
   - Browse other gift cards (Amazon, Grab, etc.)
   - Try experiences or merchandise
   - Wait until next month"
```

---

## ⚙️ Section 5: Program Administration (HR)

### 5.1 Setting Up Recognition Event Types

**Step-by-Step** (HR Administrator):

1. **Navigate to Configuration**
   - Total Rewards → Configuration → Recognition → Event Types
   - Click "New Event Type"

2. **Define Event Type**
   ```yaml
   Event Type Configuration:
     Code: INNOVATION_AWARD
     Name: Innovation Award
     Category: MANAGER_RECOGNITION
     Description: "Recognizing innovative ideas that improve processes or products"
     
     Points:
       Base Points: 500
       Allow Custom: Yes (manager can adjust 250-1000)
     
     Permissions:
       Who Can Give: Managers, Directors, VPs
       Requires Approval: Yes (if > 500 points)
       Approver: Director or above
     
     Visibility:
       Default: Public
       Allow Private: Yes
     
     Settings:
       Active: Yes
       Start Date: 2025-01-01
       End Date: null (ongoing)
       Max Per Employee: 2 per quarter
   ```

3. **Configure Approval Workflow** (if required)
   ```yaml
   Approval Workflow:
     Trigger: Points > 500
     Approver: Employee's Director
     Escalation: VP if Director doesn't respond in 3 days
     Notification: Email + In-app
   ```

4. **Activate Event Type**
   - Review configuration
   - Test with sample employee
   - Activate for all users

### 5.2 Managing the Perk Catalog

**Adding a New Perk**:

1. **Navigate to Perk Catalog**
   - Total Rewards → Configuration → Recognition → Perk Catalog
   - Click "New Perk"

2. **Configure Perk**
   ```yaml
   Perk Configuration:
     Code: AIRPODS_PRO
     Name: Apple AirPods Pro (2nd Gen)
     Category: ELECTRONICS
     
     Pricing:
       Point Cost: 8,000 points
       Actual Cost: $249 USD
       Point Value: $0.031 per point
     
     Inventory:
       Initial Stock: 50 units
       Current Stock: 50 units
       Reorder Point: 10 units
       Supplier: Apple Store Vietnam
     
     Delivery:
       Method: PHYSICAL
       Fulfillment Time: 5-7 business days
       Shipping: Free
       Regions: Vietnam only
     
     Limits:
       Per Employee: 1 per year
       Max Redemptions: 50 (until restocked)
     
     Details:
       Description: "Active Noise Cancellation, Transparency mode, Personalized Spatial Audio"
       Image: airpods-pro.jpg
       Terms: "Non-returnable, 1-year Apple warranty"
     
     Status:
       Active: Yes
       Featured: Yes
       Available From: 2025-01-01
   ```

3. **Set Up Fulfillment**
   ```yaml
   Fulfillment Process:
     Vendor: Apple Store Vietnam
     Contact: vendor@apple.com.vn
     Process:
       1. Employee redeems perk
       2. System sends order to vendor (automated)
       3. Vendor ships to employee address
       4. Tracking number updated in system
       5. Employee receives item
       6. Employee confirms receipt (optional)
   ```

### 5.3 Inventory Management

**Monitoring Stock Levels**:
```yaml
Inventory Dashboard:
  
  Low Stock Alerts:
    - Starbucks $50: 12 remaining (reorder at 20)
    - AirPods Pro: 8 remaining (reorder at 10) ⚠️
    - Spa Package: 3 remaining (reorder at 5) ⚠️
  
  Out of Stock:
    - Grab $30 Voucher: 0 remaining
    - Concert Tickets: 0 remaining (event passed)
  
  Overstocked:
    - Generic Gift Card: 200 remaining (consider promotion)
  
  Actions:
    - Reorder AirPods Pro (10 units)
    - Reorder Spa Packages (5 units)
    - Remove expired concert tickets
    - Promote generic gift cards (reduce points?)
```

**Reordering Process**:
1. System sends alert when stock reaches reorder point
2. HR reviews and approves reorder
3. Purchase order sent to vendor
4. Vendor confirms delivery date
5. Stock updated when items received

### 5.4 Program Analytics

**Key Metrics to Track**:

```yaml
Recognition Program Analytics (Q4 2025):
  
  Participation:
    Total Employees: 500
    Gave Recognition: 350 (70%)
    Received Recognition: 425 (85%)
    Active Redeemers: 300 (60%)
    
    Trend: ↑ 15% vs Q3
  
  Points:
    Total Awarded: 125,000 points
    Total Redeemed: 95,000 points
    Total Expired: 5,000 points
    Outstanding Balance: 25,000 points
    
    Redemption Rate: 76% (good)
    Expiration Rate: 4% (low, good)
  
  Recognition Events:
    Total Events: 850
    Peer Recognition: 600 (71%)
    Manager Recognition: 200 (23%)
    Milestones: 50 (6%)
    
    Top Givers:
      1. Sarah Johnson: 45 recognitions given
      2. John Doe: 38 recognitions given
      3. Mike Chen: 32 recognitions given
  
  Perk Redemptions:
    Total Redemptions: 320
    Top Perks:
      1. Starbucks $50: 120 redemptions
      2. Amazon $100: 80 redemptions
      3. Grab $30: 60 redemptions
    
    Average Points per Redemption: 1,200 points
    Fulfillment Time: 2.3 days average
    Satisfaction: 4.7/5 stars
  
  ROI:
    Total Cost: $30,000 (perks + admin)
    Engagement Increase: +25%
    Retention Improvement: +10%
    Employee Satisfaction: +15%
    
    Estimated Value: $150,000 (reduced turnover)
    ROI: 5:1
```

---

## ✅ Best Practices

### For Employees

✅ **DO**:
- **Recognize Often**: Make it a habit, not just for big wins
- **Be Specific**: Describe exactly what impressed you
- **Recognize Publicly**: Share successes with the team (when appropriate)
- **Redeem Regularly**: Don't let points expire
- **Try Variety**: Explore different perks, not just gift cards
- **Say Thank You**: Acknowledge recognition you receive

❌ **DON'T**:
- **Hoard Points**: They expire, use them!
- **Generic Messages**: "Good job" is not enough
- **Forget to Recognize**: Make time to appreciate others
- **Wait for Perfection**: Recognize progress and effort too
- **Only Recognize Up**: Peers and reports deserve recognition too

### For Managers

✅ **DO**:
- **Recognize Regularly**: At least 2-3 team members per month
- **Tie to Values**: Connect recognition to company values
- **Be Fair**: Recognize all team members, not just favorites
- **Use Higher Points**: Your recognition carries more weight
- **Make it Public**: Share team wins with broader organization
- **Track Patterns**: Notice who you haven't recognized lately

❌ **DON'T**:
- **Only Recognize Results**: Also recognize effort, behavior, growth
- **Wait for Annual Review**: Recognize in the moment
- **Play Favorites**: Distribute recognition fairly
- **Be Vague**: Specific examples have more impact
- **Forget Remote Workers**: Ensure virtual team members get recognized

### For HR Administrators

✅ **DO**:
- **Keep Catalog Fresh**: Add new perks quarterly
- **Monitor Inventory**: Reorder before stockouts
- **Analyze Trends**: What perks are popular? What's not moving?
- **Promote Program**: Regular communications, contests, campaigns
- **Gather Feedback**: Survey employees on perk preferences
- **Track ROI**: Measure impact on engagement and retention

❌ **DON'T**:
- **Let Perks Go Stale**: Same catalog for years gets boring
- **Ignore Stockouts**: Nothing frustrates like "Out of Stock"
- **Set Unrealistic Limits**: Too restrictive kills enthusiasm
- **Forget Communication**: Program needs ongoing promotion
- **Ignore Data**: Analytics tell you what's working

---

## ⚠️ Common Pitfalls

### Pitfall 1: Letting Points Expire

❌ **Wrong**:
```yaml
Employee Behavior:
  - Saves points for "something big"
  - Ignores expiration warnings
  - Loses 2,000 points to expiration
  - Frustrated and disengaged
```

✅ **Correct**:
```yaml
Employee Behavior:
  - Redeems regularly (every 2-3 months)
  - Uses oldest points first (automatic via FIFO)
  - Never loses points to expiration
  - Enjoys steady stream of perks
```

**Why**: Points are meant to be used, not saved. Regular redemption maintains engagement.

---

### Pitfall 2: Generic Recognition Messages

❌ **Wrong**:
```yaml
Recognition Message:
  "Good job on the project!"
  
Problems:
  - Not specific
  - Could apply to anyone
  - Doesn't explain impact
  - Feels copy-pasted
```

✅ **Correct**:
```yaml
Recognition Message:
  "Your detailed documentation for the API integration saved our team 
   10+ hours of debugging. The code examples and troubleshooting guide 
   were exactly what we needed. Thank you for going above and beyond!"
  
Strengths:
  - Specific action (documentation)
  - Quantified impact (10+ hours saved)
  - Explains why it mattered
  - Genuine appreciation
```

**Why**: Specific recognition has more impact and feels more genuine.

---

### Pitfall 3: Ignoring Perk Inventory

❌ **Wrong** (HR):
```yaml
Perk Catalog Status:
  - Top 3 perks: Out of stock for 2 weeks
  - Employees frustrated
  - Redemption rate drops 40%
  - Points start expiring
  - Program engagement declines
```

✅ **Correct** (HR):
```yaml
Perk Catalog Management:
  - Monitor stock levels daily
  - Reorder at reorder point (automatic alerts)
  - Never out of stock for > 2 days
  - Redemption rate stays high (75%+)
  - Program engagement strong
```

**Why**: Stockouts kill program momentum. Keep popular perks in stock.

---

## 🎓 Quick Reference

### Recognition Checklist

**Giving Recognition**:
- [ ] Select appropriate event type
- [ ] Write specific, genuine message (50+ characters)
- [ ] Choose visibility (public/private/team)
- [ ] Submit recognition
- [ ] Recipient receives notification

**Redeeming Perks**:
- [ ] Check point balance
- [ ] Browse perk catalog
- [ ] Verify perk in stock
- [ ] Confirm sufficient points
- [ ] Review delivery method
- [ ] Submit redemption
- [ ] Track delivery status

**Managing Points** (Monthly):
- [ ] Check point balance
- [ ] Review expiration warnings
- [ ] Redeem points if expiring soon
- [ ] Thank people who recognized you
- [ ] Give recognition to at least 2 people

---

## 📚 Related Guides

- [Concept Overview](./01-concept-overview.md) - TR module overview
- [Conceptual Guide](./02-conceptual-guide.md) - Recognition workflow (Workflow 4)
- [Compensation Management Guide](./03-compensation-management-guide.md) - Total rewards context
- [Total Rewards Statements Guide](./08-total-rewards-statements-guide.md) - Recognition value reporting (Planned)
- [Eligibility Rules Guide](./11-eligibility-rules-guide.md) - Recognition program eligibility

---

**Document Version**: 1.0  
**Created**: 2025-12-15  
**Last Review**: 2025-12-15  
**Author**: xTalent Documentation Team  
**Status**: ✅ Complete
