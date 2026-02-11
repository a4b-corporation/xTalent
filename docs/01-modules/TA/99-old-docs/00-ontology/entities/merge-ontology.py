#!/usr/bin/env python3
"""
Script to merge individual entity files back into a monolithic absence-ontology.yaml.
This restores the single file structure from the split entities.
"""

import os
from pathlib import Path

# Define directories
BASE_DIR = Path("/Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/TA/00-ontology")
OUTPUT_FILE = BASE_DIR / "absence-ontology.yaml"

# Order of entities to maintain logical structure
ENTITY_ORDER = [
    # Configuration
    "leave-class.yaml",
    "leave-type.yaml",
    "period-profile.yaml",
    
    # Rules
    "eligibility-rule.yaml",
    "validation-rule.yaml",
    "accrual-rule.yaml",
    "carryover-rule.yaml",
    "limit-rule.yaml",
    "overdraft-rule.yaml",
    "proration-rule.yaml",
    "rounding-rule.yaml",
    
    # Schedule
    "schedule.yaml",
    "holiday.yaml",
    
    # Transaction
    "leave-request.yaml",
    "leave-reservation.yaml",
    "leave-movement.yaml",
    "leave-balance.yaml",
    "approval.yaml",
    
    # Automation
    "event.yaml",
    "trigger.yaml"
]

HEADER = """# Absence Management Ontology
# Version: 2.0
# Last Updated: 2025-11-28
# Module: Time & Absence (TA) - Absence

module: Absence
description: |
  Comprehensive ontology for absence management including leave types, 
  policies, requests, balances, and ledger-based tracking.

# =============================================================================
# ENTITY DEFINITIONS
# =============================================================================

entities:
"""

def merge_files():
    print(f"Merging entities into {OUTPUT_FILE}...")
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as outfile:
        # Write header
        outfile.write(HEADER)
        
        # Process each file
        for filename in ENTITY_ORDER:
            file_path = BASE_DIR / filename
            
            if not file_path.exists():
                print(f"Warning: File {filename} not found, skipping.")
                continue
                
            with open(file_path, 'r', encoding='utf-8') as infile:
                content = infile.read()
                
                # Extract the entity name and content, skipping the header lines
                lines = content.split('\n')
                entity_name = ""
                entity_content = []
                
                for line in lines:
                    if line.startswith("entity:"):
                        entity_name = line.split(":")[1].strip()
                    elif line.startswith("version:") or line.startswith("layer:") or line.strip() == "":
                        continue
                    else:
                        entity_content.append(line)
                
                # Write to output file with proper indentation
                outfile.write(f"  {entity_name}:\n")
                
                # Re-indent content
                for line in entity_content:
                    if line.strip():
                        outfile.write(f"    {line}\n")
                    else:
                        outfile.write("\n")
                
                outfile.write("\n")
                print(f"✓ Added {entity_name}")

    print("-" * 60)
    print(f"✓ Successfully restored {OUTPUT_FILE}")

if __name__ == "__main__":
    merge_files()
