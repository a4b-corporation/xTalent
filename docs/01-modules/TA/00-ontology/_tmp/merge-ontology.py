#!/usr/bin/env python3
"""
Merge Time & Attendance and Absence ontology files into a single unified ontology.
This script reads both YAML files and creates a consolidated ontology following
the MODULE-DOCUMENTATION-STANDARDS.md template.
"""

import yaml
import sys
from pathlib import Path
from datetime import datetime

def load_yaml_file(filepath):
    """Load YAML file and return parsed content."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading {filepath}: {e}")
        sys.exit(1)

def merge_ontologies(ta_data, absence_data):
    """Merge two ontology files into a unified structure."""
    
    # Create unified ontology structure following Core module template
    unified = {
        '# Time & Absence Module (TA) - Ontology': None,
        '# Version': '2.0',
        '# Last Updated': datetime.now().strftime('%Y-%m-%d'),
        '# Module': 'Time & Absence (TA)',
        '# Description': 'Comprehensive ontology for time tracking, attendance management, and absence/leave management',
        
        'module': 'TimeAndAbsence',
        'code': 'TA',
        'description': '''Time & Absence module manages employee work time, attendance tracking, 
  leave requests, and absence management. It includes shift scheduling, time capture,
  timesheet processing, leave balances, and approval workflows.''',
        
        'sub_modules': {
            'TimeAttendance': {
                'description': 'Time tracking and attendance management',
                'entities': []
            },
            'Absence': {
                'description': 'Leave and absence management',
                'entities': []
            }
        },
        
        'entities': {}
    }
    
    # Extract entities from Time & Attendance
    if 'entities' in ta_data:
        ta_entities = ta_data['entities']
        unified['sub_modules']['TimeAttendance']['entities'] = list(ta_entities.keys())
        
        # Add TA entities to unified entities
        for entity_name, entity_data in ta_entities.items():
            unified['entities'][entity_name] = entity_data
    
    # Extract entities from Absence
    if 'entities' in absence_data:
        absence_entities = absence_data['entities']
        unified['sub_modules']['Absence']['entities'] = list(absence_entities.keys())
        
        # Add Absence entities to unified entities
        for entity_name, entity_data in absence_entities.items():
            unified['entities'][entity_name] = entity_data
    
    # Add architecture info if present
    if 'architecture' in ta_data:
        unified['architecture'] = ta_data['architecture']
    
    # Add design patterns
    unified['design_patterns'] = {
        'scd_type_2': {
            'description': 'Slowly Changing Dimensions Type 2 for historical tracking',
            'applies_to': [
                'ShiftDefinition', 'PatternTemplate', 'ScheduleAssignment',
                'LeaveType', 'LeavePolicy', 'LeaveBalance'
            ]
        },
        'hierarchical_data': {
            'description': '6-level hierarchical model for time scheduling',
            'applies_to': [
                'TimeSegment', 'ShiftDefinition', 'DayModel', 
                'PatternTemplate', 'ScheduleAssignment', 'GeneratedRoster'
            ]
        },
        'ledger_pattern': {
            'description': 'Double-entry ledger for leave balance tracking',
            'applies_to': ['LeaveBalance', 'LeaveTransaction', 'LeaveAdjustment']
        }
    }
    
    # Add version history
    unified['version_history'] = [
        {
            'version': '2.0',
            'date': datetime.now().strftime('%Y-%m-%d'),
            'changes': 'Unified Time & Attendance and Absence ontologies into single module'
        },
        {
            'version': '1.0',
            'date': '2025-11-28',
            'changes': 'Initial separate ontologies for TA and Absence'
        }
    ]
    
    return unified

def save_yaml_file(data, filepath):
    """Save data to YAML file with proper formatting."""
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            # Write header comments manually for better formatting
            f.write(f"# Time & Absence Module (TA) - Ontology\n")
            f.write(f"# Version: 2.0\n")
            f.write(f"# Last Updated: {datetime.now().strftime('%Y-%m-%d')}\n")
            f.write(f"# Module: Time & Absence (TA)\n")
            f.write(f"# Description: Comprehensive ontology for time tracking, attendance, and absence management\n\n")
            
            # Remove header comments from data before dumping
            clean_data = {k: v for k, v in data.items() if not k.startswith('#')}
            
            # Write YAML content
            yaml.dump(clean_data, f, 
                     default_flow_style=False,
                     allow_unicode=True,
                     sort_keys=False,
                     width=100,
                     indent=2)
        
        print(f"✅ Successfully saved merged ontology to: {filepath}")
        return True
    except Exception as e:
        print(f"❌ Error saving {filepath}: {e}")
        return False

def print_summary(unified):
    """Print summary of merged ontology."""
    print("\n" + "="*80)
    print("📊 MERGE SUMMARY")
    print("="*80)
    
    print(f"\n📦 Module: {unified.get('module', 'N/A')}")
    print(f"📝 Code: {unified.get('code', 'N/A')}")
    
    print(f"\n📂 Sub-modules:")
    for sub_name, sub_data in unified.get('sub_modules', {}).items():
        entity_count = len(sub_data.get('entities', []))
        print(f"   - {sub_name}: {entity_count} entities")
        for entity in sub_data.get('entities', [])[:5]:  # Show first 5
            print(f"     • {entity}")
        if entity_count > 5:
            print(f"     ... and {entity_count - 5} more")
    
    total_entities = len(unified.get('entities', {}))
    print(f"\n📊 Total Entities: {total_entities}")
    
    print(f"\n🎨 Design Patterns:")
    for pattern_name, pattern_data in unified.get('design_patterns', {}).items():
        applies_count = len(pattern_data.get('applies_to', []))
        print(f"   - {pattern_name}: applies to {applies_count} entities")
    
    print("\n" + "="*80)

def main():
    """Main execution function."""
    print("🔄 Starting Time & Absence Ontology Merge Process...")
    print("="*80)
    
    # Define file paths
    base_path = Path("c:/Users/LAP15399-local/OneDrive - VNG Corporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/TA/00-ontology")
    
    ta_file = base_path / "time-attendance-ontology.yaml"
    absence_file = base_path / "absence-ontology.yaml"
    output_file = base_path / "time-absence-ontology.yaml"
    
    # Check if files exist
    if not ta_file.exists():
        print(f"❌ Error: Time & Attendance ontology not found: {ta_file}")
        sys.exit(1)
    
    if not absence_file.exists():
        print(f"❌ Error: Absence ontology not found: {absence_file}")
        sys.exit(1)
    
    # Load both ontology files
    print(f"\n📖 Loading Time & Attendance ontology from: {ta_file.name}")
    ta_data = load_yaml_file(ta_file)
    
    print(f"📖 Loading Absence ontology from: {absence_file.name}")
    absence_data = load_yaml_file(absence_file)
    
    # Merge ontologies
    print(f"\n🔀 Merging ontologies...")
    unified = merge_ontologies(ta_data, absence_data)
    
    # Print summary
    print_summary(unified)
    
    # Save merged ontology
    print(f"\n💾 Saving merged ontology to: {output_file.name}")
    success = save_yaml_file(unified, output_file)
    
    if success:
        print(f"\n✅ Merge completed successfully!")
        print(f"\n📝 Next steps:")
        print(f"   1. Review the merged file: {output_file}")
        print(f"   2. Edit and enhance entity definitions as needed")
        print(f"   3. Add missing attributes, relationships, and constraints")
        print(f"   4. Validate against MODULE-DOCUMENTATION-STANDARDS.md")
        print(f"   5. Update glossaries to match the unified ontology")
    else:
        print(f"\n❌ Merge failed. Please check errors above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
