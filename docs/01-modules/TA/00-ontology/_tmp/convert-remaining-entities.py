#!/usr/bin/env python3
"""
Script to generate standardized dictionary format for remaining Absence entities.
This will create the replacement content for ValidationRule through Event entities.
"""

# List of remaining entities to convert
remaining_entities = [
    "ValidationRule",
    "AccrualRule", 
    "CarryoverRule",
    "LimitRule",
    "OverdraftRule",
    "ProrationRule",
    "RoundingRule",
    "Schedule",
    "Holiday",
    "LeaveRequest",
    "LeaveReservation",
    "LeaveMovement",
    "LeaveBalance",
    "Approval",
    "Event",
    "Trigger"
]

print("Remaining entities to convert:")
for i, entity in enumerate(remaining_entities, 1):
    print(f"{i}. {entity}")

print(f"\nTotal: {len(remaining_entities)} entities")
print("\nNext steps:")
print("1. Convert ValidationRule and AccrualRule (most complex)")
print("2. Convert CarryoverRule, LimitRule, OverdraftRule, ProrationRule, RoundingRule")
print("3. Convert Schedule and Holiday")
print("4. Convert LeaveRequest, LeaveReservation, LeaveMovement, LeaveBalance")
print("5. Convert Approval, Event, Trigger")
