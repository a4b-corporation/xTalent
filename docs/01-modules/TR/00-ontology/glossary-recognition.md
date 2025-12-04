# Recognition - Glossary

**Version**: 2.0  
**Last Updated**: 2025-12-04  
**Module**: Total Rewards (TR)  
**Sub-module**: Recognition

---

## Overview

Recognition manages employee recognition programs, reward points, and perk redemptions. This sub-module provides:

- **Recognition Events**: Peer-to-peer and manager recognition with point awards
- **Point System**: Employee point accounts with earning, spending, and expiration tracking
- **Perk Catalog**: Redeemable perks and rewards (electronics, travel, wellness, experiences)
- **Redemption Management**: Perk redemption requests and fulfillment tracking
- **Event Types**: Configurable recognition event types with point values

This sub-module is critical for **employee engagement** and **culture building**.

---

## Entities

### 1. RecognitionEventType

**Definition**: Types of recognition events defining point values and approval requirements.

**Purpose**: Standardizes recognition categories with consistent point awards.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `code` | string(50) | Yes | Primary key - Event type code (e.g., PEER_RECOGNITION, MILESTONE, INNOVATION) |
| `name` | string(100) | Yes | Event type name |
| `description` | text | No | Detailed description |
| `default_points` | integer | Yes | Default points awarded |
| `min_points` | integer | No | Minimum points allowed |
| `max_points` | integer | No | Maximum points allowed |
| `requires_approval` | boolean | No | Whether requires manager approval (default: false) |
| `is_active` | boolean | No | Active status (default: true) |

**Business Rules**:
1. Points awarded must be within min/max range
2. Approval required if `requires_approval = true`
3. Event types can be enabled/disabled via `is_active`

**Examples**:

```yaml
Example 1: Peer Recognition
  RecognitionEventType:
    code: "PEER_RECOGNITION"
    name: "Peer Recognition"
    description: "Recognize a colleague for great work"
    default_points: 100
    min_points: 50
    max_points: 200
    requires_approval: false

Example 2: Innovation Award
  RecognitionEventType:
    code: "INNOVATION"
    name: "Innovation Award"
    description: "Recognize innovative ideas and solutions"
    default_points: 500
    min_points: 500
    max_points: 1000
    requires_approval: true
```

---

### 2. PerkCategory

**Definition**: Categories for organizing perk catalog (Electronics, Travel, Wellness, Experiences).

**Purpose**: Groups perks for easier browsing and management.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Category code (unique) |
| `name` | string(100) | Yes | Category name |
| `description` | text | No | Category description |
| `is_active` | boolean | No | Active status (default: true) |

**Examples**:

```yaml
Example Categories:
  - code: "ELECTRONICS"
    name: "Electronics & Gadgets"
  - code: "TRAVEL"
    name: "Travel & Experiences"
  - code: "WELLNESS"
    name: "Health & Wellness"
  - code: "GIFT_CARDS"
    name: "Gift Cards"
```

---

### 3. PerkCatalog

**Definition**: Catalog of redeemable perks/rewards that employees can purchase with points.

**Purpose**: Provides variety of rewards for employee recognition program.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `code` | string(50) | Yes | Perk code (unique) |
| `name` | string(200) | Yes | Perk name |
| `category_id` | UUID | Yes | FK to PerkCategory |
| `points_cost` | integer | Yes | Points required to redeem |
| `inventory` | integer | No | Available inventory (NULL = unlimited) |
| `redeem_limit_per_employee` | integer | No | Max redemptions per employee (NULL = unlimited) |
| `status` | enum | No | ACTIVE, INACTIVE, OUT_OF_STOCK, DISCONTINUED |
| `image_url` | string(500) | No | Image URL |
| `description` | text | No | Perk description |
| `effective_start_date` | date | Yes | When perk becomes available |
| `effective_end_date` | date | No | When perk expires |

**Business Rules**:
1. Inventory decremented on redemption
2. Status changes to OUT_OF_STOCK when inventory = 0
3. redeem_limit_per_employee enforced per employee
4. Only ACTIVE perks can be redeemed

**Examples**:

```yaml
Example 1: Laptop
  PerkCatalog:
    code: "LAPTOP_MACBOOK_PRO"
    name: "MacBook Pro 14-inch"
    category_id: "ELECTRONICS_UUID"
    points_cost: 50000
    inventory: 10
    redeem_limit_per_employee: 1
    status: ACTIVE
    description: "MacBook Pro 14-inch with M3 chip"

Example 2: Spa Voucher
  PerkCatalog:
    code: "SPA_VOUCHER_500K"
    name: "Spa Voucher 500,000 VND"
    category_id: "WELLNESS_UUID"
    points_cost: 5000
    inventory: null  # Unlimited
    redeem_limit_per_employee: 4  # Max 4 per year
    status: ACTIVE
```

---

### 4. PointAccount

**Definition**: Employee point account tracking balance, earned, spent, and expiration.

**Purpose**: Maintains current point balance and lifetime statistics for each employee.

**Key Characteristics**:
- One account per employee (1:1 relationship)
- Tracks lifetime earned, spent, and expired points
- Point expiration support (typically 12 months)
- Expiration warnings and auto-expiration

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `employee_id` | UUID | Yes | Primary key and FK to Core.Employee |
| `balance` | integer | No | Current available points (default: 0) |
| `lifetime_earned` | integer | No | Total points earned all time (default: 0) |
| `lifetime_spent` | integer | No | Total points spent all time (default: 0) |
| `lifetime_expired` | integer | No | Total points expired (default: 0) |
| `pending_expiration` | integer | No | Points expiring soon (within 30 days) |
| `next_expiration_date` | date | No | Date of next point expiration |
| `next_expiration_amount` | integer | No | Amount expiring on next_expiration_date |
| `expiration_policy_json` | jsonb | No | Point expiration policy |
| `last_updated` | timestamp | No | Last update timestamp |

**Expiration Policy JSON**:

```yaml
expiration_policy_json:
  enabled: true
  expiration_months: 12
  warning_days: 30
  auto_expire: true
```

**Business Rules**:
1. balance = lifetime_earned - lifetime_spent - lifetime_expired
2. Points expire after expiration_months (typically 12 months)
3. Warning sent when pending_expiration > 0
4. Auto-expiration runs monthly
5. Balance must be >= 0 (enforced by CHECK constraint)

**Examples**:

```yaml
Example: Active Point Account
  PointAccount:
    employee_id: "EMP_001_UUID"
    balance: 5000
    lifetime_earned: 12000
    lifetime_spent: 6000
    lifetime_expired: 1000
    pending_expiration: 500
    next_expiration_date: "2025-04-15"
    next_expiration_amount: 500
    expiration_policy_json:
      enabled: true
      expiration_months: 12
      warning_days: 30
```

---

### 5. RecognitionEvent

**Definition**: Individual recognition event recording who recognized whom, for what, and points awarded.

**Purpose**: Tracks all recognition activities with approval workflow.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_from_id` | UUID | Yes | FK to Core.Employee (giver) |
| `employee_to_id` | UUID | Yes | FK to Core.Employee (receiver) |
| `event_type_code` | string(50) | Yes | FK to RecognitionEventType |
| `points_awarded` | integer | Yes | Points awarded in this event |
| `reason` | enum | No | PERFORMANCE, TEAMWORK, INNOVATION, VALUES, MILESTONE, CUSTOMER_SERVICE, LEADERSHIP |
| `message` | text | No | Recognition message/note |
| `status` | enum | No | PENDING, APPROVED, REJECTED, CANCELLED |
| `approver_id` | UUID | No | FK to Core.Employee (approver) |
| `decision_date` | timestamp | No | When decision was made |
| `created_at` | timestamp | No | When event was created |

**Business Rules**:
1. Points awarded when status = APPROVED
2. Points must be within min/max range for event type
3. Approval required if event_type.requires_approval = true
4. Cannot recognize yourself (employee_from_id != employee_to_id)

**Examples**:

```yaml
Example: Peer Recognition
  RecognitionEvent:
    employee_from_id: "EMP_001_UUID"
    employee_to_id: "EMP_002_UUID"
    event_type_code: "PEER_RECOGNITION"
    points_awarded: 100
    reason: TEAMWORK
    message: "Great collaboration on the Q4 project!"
    status: APPROVED
    created_at: "2025-03-15T10:30:00Z"
```

---

### 6. RewardPointTransaction

**Definition**: Point transaction history tracking all point movements (earn, spend, adjust, expire).

**Purpose**: Provides complete audit trail of all point activities.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `points_delta` | integer | Yes | Point change (positive = earn, negative = spend/expire) |
| `balance_after` | integer | Yes | Balance after this transaction |
| `txn_type` | enum | Yes | EARNED, SPENT, ADJUSTED, EXPIRED, REVERSED |
| `reference_type` | enum | No | RECOGNITION_EVENT, PERK_REDEMPTION, MANUAL_ADJUSTMENT, EXPIRATION, REVERSAL |
| `reference_id` | UUID | No | ID of triggering record |
| `expiration_date` | date | No | When these points expire (for EARNED) |
| `description` | string(500) | No | Transaction description |
| `txn_date` | timestamp | No | Transaction date (default: now()) |

**Business Rules**:
1. EARNED points have expiration_date (typically +12 months)
2. SPENT/EXPIRED points are negative
3. balance_after must be >= 0
4. Oldest points spent/expired first (FIFO)

**Examples**:

```yaml
Example 1: Points Earned
  RewardPointTransaction:
    employee_id: "EMP_001_UUID"
    points_delta: 100
    balance_after: 5100
    txn_type: EARNED
    reference_type: RECOGNITION_EVENT
    reference_id: "RECOGNITION_EVENT_UUID"
    expiration_date: "2026-03-15"
    description: "Peer recognition for teamwork"

Example 2: Points Spent
  RewardPointTransaction:
    points_delta: -5000
    balance_after: 100
    txn_type: SPENT
    reference_type: PERK_REDEMPTION
    reference_id: "REDEMPTION_UUID"
    description: "Redeemed spa voucher"

Example 3: Points Expired
  RewardPointTransaction:
    points_delta: -500
    balance_after: 4600
    txn_type: EXPIRED
    reference_type: EXPIRATION
    description: "Auto-expired points from 2024-03-15"
```

---

### 7. PerkRedemption

**Definition**: Perk redemption request and fulfillment tracking.

**Purpose**: Manages the process of redeeming points for perks with delivery tracking.

**Attributes**:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Primary key |
| `employee_id` | UUID | Yes | FK to Core.Employee |
| `perk_id` | UUID | Yes | FK to PerkCatalog |
| `points_spent` | integer | Yes | Points deducted for this redemption |
| `quantity` | integer | No | Number of items redeemed (default: 1) |
| `status` | enum | No | REQUESTED, APPROVED, REJECTED, FULFILLED, CANCELLED |
| `request_date` | timestamp | No | When requested (default: now()) |
| `fulfillment_date` | timestamp | No | When perk was delivered/fulfilled |
| `fulfilled_by` | UUID | No | FK to Core.Employee (fulfillment admin) |
| `delivery_address_json` | jsonb | No | Delivery information |
| `tracking_number` | string(100) | No | Shipping tracking number |

**Delivery Address JSON**:

```yaml
delivery_address_json:
  address: "123 Main St, City, State, ZIP"
  phone: "+84-123-456-789"
  notes: "Leave at front desk"
```

**Business Rules**:
1. Points deducted when status = APPROVED
2. Inventory decremented when status = APPROVED
3. Cannot cancel FULFILLED redemption
4. Employee must have sufficient balance

**Examples**:

```yaml
Example: Spa Voucher Redemption
  PerkRedemption:
    employee_id: "EMP_001_UUID"
    perk_id: "SPA_VOUCHER_UUID"
    points_spent: 5000
    quantity: 1
    status: FULFILLED
    request_date: "2025-03-10T14:00:00Z"
    fulfillment_date: "2025-03-12T10:00:00Z"
    fulfilled_by: "HR_ADMIN_UUID"
    delivery_address_json:
      address: "123 Nguyen Hue, District 1, HCMC"
      phone: "+84-901-234-567"
```

---

## Summary

The Recognition sub-module provides **7 entities** that work together to manage:

1. **Event Configuration**: RecognitionEventType
2. **Perk Catalog**: PerkCategory, PerkCatalog
3. **Point Management**: PointAccount, RewardPointTransaction
4. **Recognition**: RecognitionEvent
5. **Redemption**: PerkRedemption

**Key Design Patterns**:
- ✅ Point expiration with FIFO (oldest first)
- ✅ Approval workflows for high-value events
- ✅ Inventory management for limited perks
- ✅ Complete audit trail via transactions
- ✅ Flexible event types and point values

**Engagement Features**:
- ✅ Peer-to-peer recognition
- ✅ Manager recognition
- ✅ Point-based reward system
- ✅ Diverse perk catalog
- ✅ Expiration warnings to drive engagement

**Integration Points**:
- **Core Module**: Employee linkages
- **Notification System**: Expiration warnings, recognition notifications
- **E-commerce**: Perk fulfillment and delivery

---

**Document Status**: ✅ Complete  
**Coverage**: 7 of 7 entities documented  
**Last Updated**: 2025-12-04  
**Next Steps**: Create glossary-offer-management.md (5 entities)
