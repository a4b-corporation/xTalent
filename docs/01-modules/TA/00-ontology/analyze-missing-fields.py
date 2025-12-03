#!/usr/bin/env python3
"""
Script to analyze time-absence-ontology.yaml and identify entities missing:
1. SCD Type 2 fields (effective_start_date, effective_end_date, is_current_flag)
2. Audit fields (created_by, updated_by)
"""

import yaml
import re

# Read the ontology file
with open('time-absence-ontology.yaml', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract entity names from the entities section
entity_pattern = r'^  (\w+):\s*$'
entities = re.findall(entity_pattern, content, re.MULTILINE)

print("=" * 80)
print("ENTITY AUDIT ANALYSIS")
print("=" * 80)
print(f"\nTotal entities found: {len(entities)}\n")

# Check each entity for missing fields
missing_scd2 = []
missing_audit_created_by = []
missing_audit_updated_by = []
has_all_fields = []

for entity in entities:
    # Find entity block
    entity_pattern = rf'^  {entity}:\s*\n(.*?)(?=^  \w+:|^architecture:|^design_patterns:|$)'
    match = re.search(entity_pattern, content, re.MULTILINE | re.DOTALL)
    
    if match:
        entity_block = match.group(1)
        
        # Check for SCD Type 2 fields
        has_effective_start = 'effective_start_date:' in entity_block
        has_effective_end = 'effective_end_date:' in entity_block
        has_current_flag = 'is_current_flag:' in entity_block
        
        # Check for audit fields
        has_created_by = 'created_by:' in entity_block
        has_updated_by = 'updated_by:' in entity_block
        
        # Categorize
        if not (has_effective_start and has_effective_end and has_current_flag):
            # Check if it should have SCD2 (temporal entities)
            # Entities with effectiveStart/effectiveEnd or effective dates should have SCD2
            if 'effectiveStart:' in entity_block or 'effectiveDate:' in entity_block:
                missing_scd2.append(entity)
        
        if not has_created_by:
            missing_audit_created_by.append(entity)
        
        if not has_updated_by:
            missing_audit_updated_by.append(entity)
        
        if has_created_by and has_updated_by:
            has_all_fields.append(entity)

print("✅ ENTITIES WITH COMPLETE AUDIT TRAIL:")
print("-" * 80)
for entity in has_all_fields:
    print(f"  ✅ {entity}")
print(f"\nTotal: {len(has_all_fields)}/{len(entities)}")

print("\n⚠️  ENTITIES MISSING created_by:")
print("-" * 80)
for entity in missing_audit_created_by:
    print(f"  ⚠️  {entity}")
print(f"\nTotal: {len(missing_audit_created_by)}/{len(entities)}")

print("\n⚠️  ENTITIES MISSING updated_by:")
print("-" * 80)
for entity in missing_audit_updated_by:
    print(f"  ⚠️  {entity}")
print(f"\nTotal: {len(missing_audit_updated_by)}/{len(entities)}")

print("\n🔍 ENTITIES POTENTIALLY NEEDING SCD TYPE 2:")
print("-" * 80)
for entity in missing_scd2:
    print(f"  🔍 {entity}")
print(f"\nTotal: {len(missing_scd2)}/{len(entities)}")

print("\n" + "=" * 80)
print("SUMMARY")
print("=" * 80)
print(f"Total Entities: {len(entities)}")
print(f"Complete Audit Trail: {len(has_all_fields)} ({len(has_all_fields)*100//len(entities)}%)")
print(f"Missing created_by: {len(missing_audit_created_by)} ({len(missing_audit_created_by)*100//len(entities)}%)")
print(f"Missing updated_by: {len(missing_audit_updated_by)} ({len(missing_audit_updated_by)*100//len(entities)}%)")
print(f"Potentially need SCD2: {len(missing_scd2)}")
print("=" * 80)
