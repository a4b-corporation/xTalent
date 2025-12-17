# Merit Review Process Guide

**Version**: 1.0  
**Last Updated**: 2025-12-17  
**Audience**: HR Administrators, Compensation Managers  
**Reading Time**: 15-20 minutes

---

## Overview

Guide for conducting annual merit review cycles with grade-based compensation adjustments.

---

## Merit Review Cycle Setup

### Step 1: Create Compensation Plan

```python
plan = tr_api.create_compensation_plan({
    "code": "MERIT_2025",
    "name": "Annual Merit Review 2025",
    "plan_type": "MERIT",
    "eligibility_rule": {
        "min_tenure_months": 6,
        "min_performance_rating": "MEETS_EXPECTATIONS",
        "employment_status": ["ACTIVE"]
    },
    "guideline_json": {
        "merit_matrix": [
            {"performance": "EXCEEDS", "compa_ratio_range": "<90%", "increase_range": "8-10%"},
            {"performance": "EXCEEDS", "compa_ratio_range": "90-110%", "increase_range": "6-8%"},
            {"performance": "MEETS", "compa_ratio_range": "<90%", "increase_range": "4-6%"},
            {"performance": "MEETS", "compa_ratio_range": "90-110%", "increase_range": "3-5%"}
        ]
    }
})
```

### Step 2: Create Compensation Cycle

```python
cycle = tr_api.create_compensation_cycle({
    "plan_id": plan['id'],
    "code": "MERIT_2025_Q1",
    "period_start": "2025-01-01",
    "period_end": "2025-03-31",
    "effective_date": "2025-04-01",
    "budget_amount": 5_000_000_000,  # 5B VND
    "budget_currency": "VND",
    "status": "DRAFT"
})
```

---

## Employee Eligibility

### Determine Eligible Employees

```python
def get_eligible_employees(cycle_id):
    """Get employees eligible for merit review"""
    cycle = tr_api.get_cycle(cycle_id)
    eligibility = cycle['plan']['eligibility_rule']
    
    eligible = []
    
    for employee in core_api.get_all_active_employees():
        # Check tenure
        tenure_months = calculate_tenure_months(employee['hire_date'])
        if tenure_months < eligibility['min_tenure_months']:
            continue
        
        # Check performance
        perf_rating = get_latest_performance_rating(employee['id'])
        if perf_rating not in eligibility['min_performance_rating']:
            continue
        
        # Get compensation context
        comp_context = integration_api.get_compensation_context(employee['id'])
        
        eligible.append({
            "employee_id": employee['id'],
            "grade_code": comp_context['grade']['grade_code'],
            "current_salary": comp_context['current_compensation']['base_salary'],
            "pay_range": comp_context['pay_range'],
            "performance_rating": perf_rating
        })
    
    return eligible
```

---

## Compa-Ratio Calculation

```python
def calculate_employee_compa_ratio(employee_data):
    """
    Calculate compa-ratio for merit review
    
    Compa-Ratio = (Current Salary / Grade Midpoint) × 100
    """
    current_salary = employee_data['current_salary']
    midpoint = employee_data['pay_range']['mid_amount']
    
    compa_ratio = (current_salary / midpoint) * 100
    
    return {
        "compa_ratio": round(compa_ratio, 2),
        "position_in_range": get_position_category(compa_ratio)
    }

def get_position_category(compa_ratio):
    """Categorize position in range"""
    if compa_ratio < 80:
        return "BELOW_RANGE"
    elif compa_ratio < 90:
        return "LOW_IN_RANGE"
    elif compa_ratio < 110:
        return "MID_RANGE"
    elif compa_ratio < 120:
        return "HIGH_IN_RANGE"
    else:
        return "ABOVE_RANGE"
```

---

## Merit Matrix Application

```python
def calculate_merit_increase(
    employee_data,
    performance_rating,
    merit_matrix
):
    """
    Apply merit matrix to determine increase
    """
    compa_ratio = calculate_employee_compa_ratio(employee_data)['compa_ratio']
    
    # Find applicable matrix cell
    for cell in merit_matrix:
        if cell['performance'] != performance_rating:
            continue
        
        # Check compa-ratio range
        if compa_ratio < 90 and cell['compa_ratio_range'] == "<90%":
            increase_range = cell['increase_range']
            break
        elif 90 <= compa_ratio <= 110 and cell['compa_ratio_range'] == "90-110%":
            increase_range = cell['increase_range']
            break
    
    # Parse increase range (e.g., "6-8%")
    min_pct, max_pct = parse_percentage_range(increase_range)
    
    # Use midpoint of range
    recommended_pct = (min_pct + max_pct) / 2
    
    current_salary = employee_data['current_salary']
    increase_amount = current_salary * (recommended_pct / 100)
    proposed_salary = current_salary + increase_amount
    
    return {
        "current_salary": current_salary,
        "recommended_increase_pct": recommended_pct,
        "increase_amount": increase_amount,
        "proposed_salary": proposed_salary,
        "compa_ratio_before": compa_ratio,
        "compa_ratio_after": (proposed_salary / employee_data['pay_range']['mid_amount']) * 100
    }
```

---

## Manager Workflow

### Step 1: Review Team Eligibility

```python
# Manager views eligible team members
team_eligible = get_eligible_employees_for_manager(manager_id, cycle_id)

for emp in team_eligible:
    print(f"{emp['name']}: {emp['performance_rating']}, Compa: {emp['compa_ratio']}%")
```

### Step 2: Propose Adjustments

```python
# Manager proposes merit increases
for employee in team_eligible:
    merit_calc = calculate_merit_increase(
        employee,
        employee['performance_rating'],
        merit_matrix
    )
    
    # Create adjustment proposal
    adjustment = tr_api.create_compensation_adjustment({
        "cycle_id": cycle_id,
        "employee_id": employee['employee_id'],
        "assignment_id": employee['assignment_id'],
        "component_id": base_salary_component_id,
        "current_amount": merit_calc['current_salary'],
        "proposed_amount": merit_calc['proposed_salary'],
        "increase_pct": merit_calc['recommended_increase_pct'],
        "rationale": f"Merit increase based on {employee['performance_rating']} performance",
        "status": "PENDING_APPROVAL"
    })
```

---

## Budget Tracking

```python
def track_budget_utilization(cycle_id):
    """Monitor budget usage during cycle"""
    cycle = tr_api.get_cycle(cycle_id)
    adjustments = tr_api.get_cycle_adjustments(cycle_id)
    
    total_budget = cycle['budget_amount']
    
    # Calculate utilized budget
    approved = sum(adj['increase_amount'] for adj in adjustments if adj['status'] == 'APPROVED')
    pending = sum(adj['increase_amount'] for adj in adjustments if adj['status'] == 'PENDING_APPROVAL')
    
    utilized_pct = (approved / total_budget) * 100
    committed_pct = ((approved + pending) / total_budget) * 100
    
    return {
        "total_budget": total_budget,
        "approved_amount": approved,
        "pending_amount": pending,
        "remaining": total_budget - approved - pending,
        "utilized_pct": utilized_pct,
        "committed_pct": committed_pct,
        "status": get_budget_status(committed_pct)
    }

def get_budget_status(committed_pct):
    if committed_pct < 80:
        return "GREEN"
    elif committed_pct < 95:
        return "YELLOW"
    elif committed_pct < 100:
        return "RED"
    else:
        return "OVER_BUDGET"
```

---

## Approval and Execution

### Approval Workflow

```yaml
Approval Thresholds:
  0-5% increase: Manager approval only
  5-10% increase: Director approval required
  >10% increase: VP approval required
```

### Execute Cycle

```python
# After all approvals
tr_api.close_compensation_cycle(cycle_id)

# System creates compensation snapshots
for adjustment in approved_adjustments:
    tr_api.create_compensation_snapshot({
        "employee_id": adjustment['employee_id'],
        "assignment_id": adjustment['assignment_id'],
        "base_salary": adjustment['proposed_amount'],
        "effective_date": cycle['effective_date'],
        "reason": "MERIT_REVIEW",
        "cycle_id": cycle_id
    })
```

---

**See Also**:
- [Conceptual Guide](./01-conceptual-guide.md)
- [Promotion Process](./04-promotion-process.md)
