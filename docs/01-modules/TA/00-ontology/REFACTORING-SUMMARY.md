# Absence Ontology - Refactoring Summary

**Date**: 2025-11-28  
**Version**: 2.0 (Refactored)

---

## 🔄 Major Changes

### 1. Removed Policy Entity

**Before**:
```
LeaveType → Policy → Rules (Eligibility, Validation, Accrual, etc.)
```

**After**:
```
LeaveType → Rules (directly)
LeaveClass → Rules (directly)
```

**Rationale**: 
- "Policy Library" is a **UI module** for managing rules, not a database entity
- Rules are independent entities that can be bound directly to LeaveType or LeaveClass
- Eliminates unnecessary indirection through Policy container
- Provides more flexibility in rule management

---

### 2. Rules as Independent, Reusable Entities

**Key Changes**:

#### Added to ALL Rule Entities:
- ✅ `code` - Unique identifier for reusability
- ✅ `name` - Human-readable name
- ✅ `description` - Optional description
- ✅ `leaveTypeId` (nullable) - Bind to specific leave type
- ✅ `leaveClassId` (nullable) - Bind to entire leave class
- ✅ `priority` - For conflict resolution
- ✅ `createdAt` / `updatedAt` - Audit timestamps

#### Removed from ALL Rule Entities:
- ❌ `policyId` - No longer needed
- ❌ `ruleName` - Replaced with `name`

#### New Constraints:
- "Either `leaveTypeId` OR `leaveClassId` must be set, not both"
- "code must be unique" (enables reusability)
- "Cannot have overlapping active rules for same leave type/class with same priority"

---

### 3. Binding Flexibility

Rules can now be bound at **two levels**:

#### Class-Level Binding
```yaml
EligibilityRule:
  code: "TENURE_6M"
  name: "Tenure >= 6 months"
  leaveClassId: "PTO_CLASS"  # Applies to entire class
  priority: 10
```
→ Applies to: All leave types in PTO class (Annual, Sick, etc.)

#### Type-Level Binding
```yaml
EligibilityRule:
  code: "TENURE_12M"
  name: "Tenure >= 12 months"  
  leaveTypeId: "ANNUAL_LEAVE"  # Applies to specific type only
  priority: 20
```
→ Applies to: Only Annual Leave type

---

### 4. Priority-Based Rule Resolution

When multiple rules apply to the same leave type:

**Scenario**:
- Rule A: Bound to LeaveClass "PTO", priority 10
- Rule B: Bound to LeaveType "Annual Leave", priority 20

**Resolution**:
- For Annual Leave: Rule B wins (higher priority)
- For other types in PTO class: Rule A applies

---

### 5. Rule Reusability

**Before**: Each rule was tied to a specific Policy
**After**: Rules can be reused across multiple leave types/classes

**Example**:
```yaml
# Create once
RoundingRule:
  code: "ROUND_HALF"
  name: "Round to nearest 0.5"
  roundingMethod: NEAREST_HALF
  # Not bound yet

# Reuse multiple times
- Bind to LeaveType "Annual Leave"
- Bind to LeaveType "Sick Leave"  
- Bind to LeaveClass "PTO"
```

---

## 📊 Updated Entity Count

### Before Refactoring:
- **19 entities** (including Policy)

### After Refactoring:
- **18 entities** (Policy removed)

### Entity Breakdown:

**Configuration Layer** (3):
- LeaveClass
- LeaveType
- PeriodProfile

**Rules Layer** (8):
- EligibilityRule
- ValidationRule
- AccrualRule
- CarryoverRule
- LimitRule
- OverdraftRule
- ProrationRule
- RoundingRule

**Period & Schedule Layer** (2):
- Schedule
- Holiday

**Transaction Layer** (5):
- LeaveRequest
- LeaveReservation
- LeaveMovement
- LeaveBalance
- Approval
- Event
- Trigger

---

## 🔗 Updated Relationships

### LeaveClass
```yaml
relationships:
  - hasLeaveTypes: LeaveType[]
  - hasEligibilityRules: EligibilityRule[]  # NEW
  - hasValidationRules: ValidationRule[]    # NEW
  - hasAccrualRules: AccrualRule[]          # NEW
  - hasCarryoverRules: CarryoverRule[]      # NEW
  - hasLimitRules: LimitRule[]              # NEW
  - hasOverdraftRules: OverdraftRule[]      # NEW
  - hasProrationRules: ProrationRule[]      # NEW
  - hasRoundingRules: RoundingRule[]        # NEW
```

### LeaveType
```yaml
relationships:
  - belongsToClass: LeaveClass
  - hasEligibilityRules: EligibilityRule[]  # NEW
  - hasValidationRules: ValidationRule[]    # NEW
  - hasAccrualRules: AccrualRule[]          # NEW
  - hasCarryoverRules: CarryoverRule[]      # NEW
  - hasLimitRules: LimitRule[]              # NEW
  - hasOverdraftRules: OverdraftRule[]      # NEW
  - hasProrationRules: ProrationRule[]      # NEW
  - hasRoundingRules: RoundingRule[]        # NEW
  - hasBalances: LeaveBalance[]
  - hasRequests: LeaveRequest[]
```

### All Rule Entities
```yaml
relationships:
  - appliesTo: LeaveType | LeaveClass  # NEW (replaces belongsToPolicy)
```

---

## 💡 Design Principles Updated

### New Principles:
5. **Flexible rule system** - rules can bind to LeaveType OR LeaveClass
6. **Policy Library is a UI module** for managing rules, not a database entity
7. **Rules are reusable** - same rule can be used across multiple leave types
8. **Priority-based rule resolution** when multiple rules apply

### Retained Principles:
1. Separation of Configuration and Transaction
2. Immutable ledger pattern for LeaveMovement
3. Reservation pattern for pending requests
4. Event-driven architecture
9. Support for both day-based and hour-based leave tracking
10. Multi-level approval workflows
11. Comprehensive audit trail for compliance

---

## 🎯 Benefits of Refactoring

### 1. **Simplified Data Model**
- Removed unnecessary Policy entity
- Direct relationship between LeaveType/LeaveClass and Rules
- Easier to understand and maintain

### 2. **Increased Flexibility**
- Rules can be bound at class or type level
- Easy to override class-level rules with type-specific rules
- Priority system handles conflicts elegantly

### 3. **Better Reusability**
- Rules are independent entities with unique codes
- Same rule can be applied to multiple leave types
- Reduces duplication in rule definitions

### 4. **Clearer Separation of Concerns**
- Policy Library = UI/UX concept (how users manage rules)
- Rules = Data model (how rules are stored and applied)
- No confusion between UI and data model

### 5. **Easier to Implement**
- Simpler queries (no join through Policy table)
- Clearer business logic (check rules directly on LeaveType/Class)
- Better performance (one less table join)

---

## 🔍 Migration Considerations

If migrating from old design to new design:

### Database Migration Steps:

1. **Add new columns to rule tables**:
   ```sql
   ALTER TABLE eligibility_rules ADD COLUMN code VARCHAR(50) UNIQUE;
   ALTER TABLE eligibility_rules ADD COLUMN name VARCHAR(255);
   ALTER TABLE eligibility_rules ADD COLUMN leave_type_id UUID;
   ALTER TABLE eligibility_rules ADD COLUMN leave_class_id UUID;
   ALTER TABLE eligibility_rules ADD COLUMN priority INTEGER DEFAULT 10;
   -- Repeat for all rule tables
   ```

2. **Migrate data from Policy → Rules**:
   ```sql
   -- For each rule, copy leaveTypeId/leaveClassId from its Policy
   UPDATE eligibility_rules er
   SET leave_type_id = p.leave_type_id,
       leave_class_id = p.leave_class_id
   FROM policies p
   WHERE er.policy_id = p.id;
   ```

3. **Remove policy_id column**:
   ```sql
   ALTER TABLE eligibility_rules DROP COLUMN policy_id;
   -- Repeat for all rule tables
   ```

4. **Drop Policy table** (after verifying migration):
   ```sql
   DROP TABLE policies;
   ```

### Application Code Changes:

**Before**:
```typescript
// Get rules for a leave type
const policy = await Policy.findOne({ leaveTypeId });
const eligibilityRules = await EligibilityRule.find({ policyId: policy.id });
```

**After**:
```typescript
// Get rules for a leave type (direct query)
const eligibilityRules = await EligibilityRule.find({ 
  leaveTypeId,
  isActive: true 
});

// Also check class-level rules
const leaveType = await LeaveType.findById(leaveTypeId);
const classRules = await EligibilityRule.find({
  leaveClassId: leaveType.leaveClassId,
  isActive: true
});

// Merge and sort by priority
const allRules = [...eligibilityRules, ...classRules]
  .sort((a, b) => b.priority - a.priority);
```

---

## 📝 Updated Documentation

### Files Updated:
1. ✅ `absence-ontology-index.yaml` - Master index for the module
2. ✅ Individual entity files (e.g., `leave-type.yaml`, `leave-request.yaml`) - Split from monolithic file
3. ✅ `absence-glossary.md` - Updated Policy section and links
4. ✅ This summary document

### Next Steps:
- [ ] Update concept documents (when generated)
- [ ] Update API specifications (when generated)
- [ ] Update UI specifications (when generated)
- [ ] Update implementation code
- [ ] Update tests

---

## ✅ Validation Checklist

- [x] Policy entity removed from ontology
- [x] All rule entities updated with new attributes
- [x] LeaveType relationships updated
- [x] LeaveClass relationships updated
- [x] Entity relationship summary updated
- [x] Design principles updated
- [x] Glossary updated
- [x] All rules have code, name, priority attributes
- [x] All rules have leaveTypeId OR leaveClassId (not both)
- [x] Constraints added for uniqueness and binding rules

---

**Reviewed By**: [Name]  
**Approved By**: [Name]  
**Date**: 2025-11-28
