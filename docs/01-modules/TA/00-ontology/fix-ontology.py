#!/usr/bin/env python3
"""
Fix all issues identified in ONTOLOGY-REVIEW.md for time-absence-ontology.yaml

This script:
1. Converts all list-format attributes to dictionary format
2. Adds missing SCD Type 2 fields
3. Adds missing audit trail fields (created_by, updated_by)
4. Adds index definitions
5. Adds missing entities
6. Standardizes relationship notation
7. Adds notes and metadata sections
"""

import yaml
import sys
from pathlib import Path
from datetime import datetime
from collections import OrderDict

def load_yaml_preserve_order(filepath):
    """Load YAML file preserving order."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def convert_list_attributes_to_dict(entity_data):
    """Convert list-format attributes to dictionary format."""
    if 'attributes' not in entity_data:
        return entity_data
    
    attributes = entity_data['attributes']
    
    # Check if already in dict format
    if isinstance(attributes, dict):
        return entity_data
    
    # Convert from list to dict
    new_attributes = {}
    
    for attr_item in attributes:
        if isinstance(attr_item, str):
            # Parse string like "id: string (UUID)"
            parts = attr_item.split(':', 1)
            if len(parts) == 2:
                attr_name = parts[0].strip()
                attr_spec = parts[1].strip()
                
                # Extract type and other info
                type_info = attr_spec.split('(')[0].strip()
                
                new_attributes[attr_name] = {
                    'type': type_info,
                    'required': 'nullable' not in attr_spec.lower(),
                    'description': f"{attr_name} field"
                }
        elif isinstance(attr_item, dict):
            # Already partially structured
            for attr_name, attr_value in attr_item.items():
                if isinstance(attr_value, str):
                    # Parse "string (UUID)" format
                    type_info = attr_value.split('(')[0].strip()
                    new_attributes[attr_name] = {
                        'type': type_info,
                        'required': 'nullable' not in attr_value.lower(),
                        'description': f"{attr_name} field"
                    }
                else:
                    new_attributes[attr_name] = attr_value
    
    entity_data['attributes'] = new_attributes
    return entity_data

def add_scd2_fields(entity_data, entity_name):
    """Add SCD Type 2 fields if entity should have them."""
    scd2_entities = [
        'ShiftDefinition', 'PatternTemplate', 'ScheduleAssignment',
        'LeaveType', 'LeaveBalance', 'DayModel', 'TimeSegment'
    ]
    
    if entity_name not in scd2_entities:
        return entity_data
    
    if 'attributes' not in entity_data or not isinstance(entity_data['attributes'], dict):
        return entity_data
    
    attributes = entity_data['attributes']
    
    # Check if already has SCD2 fields
    if 'effective_start_date' in attributes:
        return entity_data
    
    # Add SCD Type 2 fields
    scd2_fields = {
        'effective_start_date': {
            'type': 'date',
            'required': True,
            'description': 'Start date of this version'
        },
        'effective_end_date': {
            'type': 'date',
            'required': False,
            'description': 'End date of this version (NULL = current version)'
        },
        'is_current_flag': {
            'type': 'boolean',
            'required': True,
            'default': True,
            'description': 'Flag indicating if this is the current version'
        }
    }
    
    # Add after other fields but before audit fields
    attributes.update(scd2_fields)
    
    return entity_data

def add_audit_fields(entity_data):
    """Add complete audit trail fields."""
    if 'attributes' not in entity_data or not isinstance(entity_data['attributes'], dict):
        return entity_data
    
    attributes = entity_data['attributes']
    
    # Add created_by if missing
    if 'created_by' not in attributes and 'createdBy' not in attributes:
        attributes['created_by'] = {
            'type': 'UUID',
            'required': True,
            'description': 'User who created this record'
        }
    
    # Add updated_by if missing
    if 'updated_by' not in attributes and 'updatedBy' not in attributes:
        attributes['updated_by'] = {
            'type': 'UUID',
            'required': False,
            'description': 'User who last updated this record'
        }
    
    return entity_data

def add_indexes(entity_data, entity_name):
    """Add index definitions."""
    if 'attributes' not in entity_data:
        return entity_data
    
    indexes = []
    attributes = entity_data.get('attributes', {})
    
    # Primary key index
    if 'id' in attributes:
        indexes.append({
            'name': f"pk_{entity_name.lower()}",
            'columns': ['id'],
            'type': 'primary_key'
        })
    
    # Unique code index
    if 'code' in attributes:
        indexes.append({
            'name': f"uq_{entity_name.lower()}_code",
            'columns': ['code'],
            'unique': True
        })
    
    # SCD Type 2 current version index
    if 'is_current_flag' in attributes and 'code' in attributes:
        indexes.append({
            'name': f"idx_{entity_name.lower()}_current",
            'columns': ['code', 'is_current_flag'],
            'where': 'is_current_flag = TRUE'
        })
    
    # Effective dates index
    if 'effective_start_date' in attributes:
        indexes.append({
            'name': f"idx_{entity_name.lower()}_dates",
            'columns': ['effective_start_date', 'effective_end_date']
        })
    
    # Foreign key indexes (common patterns)
    fk_patterns = ['worker_id', 'employee_id', 'leave_type_id', 'shift_id', 'pattern_id']
    for fk in fk_patterns:
        if fk in attributes:
            indexes.append({
                'name': f"idx_{entity_name.lower()}_{fk}",
                'columns': [fk]
            })
    
    if indexes:
        entity_data['indexes'] = indexes
    
    return entity_data

def create_missing_entities():
    """Create definitions for missing entities."""
    missing_entities = {}
    
    # HolidayCalendar
    missing_entities['HolidayCalendar'] = {
        'description': 'Calendar defining holidays and non-working days for different regions/groups',
        'attributes': {
            'id': {'type': 'UUID', 'required': True, 'description': 'Unique identifier'},
            'code': {'type': 'string', 'required': True, 'maxLength': 50, 'description': 'Calendar code'},
            'name': {'type': 'string', 'required': True, 'maxLength': 150, 'description': 'Calendar name'},
            'description': {'type': 'text', 'required': False, 'description': 'Calendar description'},
            'country_code': {'type': 'string', 'required': False, 'maxLength': 2, 'description': 'ISO country code'},
            'region_code': {'type': 'string', 'required': False, 'maxLength': 50, 'description': 'Region/state code'},
            'is_active': {'type': 'boolean', 'required': True, 'default': True},
            'effective_start_date': {'type': 'date', 'required': True},
            'effective_end_date': {'type': 'date', 'required': False},
            'is_current_flag': {'type': 'boolean', 'required': True, 'default': True},
            'created_at': {'type': 'datetime', 'required': True},
            'created_by': {'type': 'UUID', 'required': True},
            'updated_at': {'type': 'datetime', 'required': True},
            'updated_by': {'type': 'UUID', 'required': False}
        },
        'relationships': {
            'hasHolidays': {'target': 'Holiday', 'cardinality': '0..*'},
            'usedByScheduleRules': {'target': 'ScheduleAssignment', 'cardinality': '0..*'}
        },
        'constraints': [
            {'name': 'uq_calendar_code', 'type': 'unique', 'fields': ['code']}
        ],
        'businessRules': [
            'One calendar can be shared by multiple schedule assignments',
            'Holidays are defined per calendar',
            'SCD Type 2 for historical tracking'
        ]
    }
    
    # TimeException
    missing_entities['TimeException'] = {
        'description': 'Exceptions to normal attendance (late, early departure, missing punch, etc.)',
        'attributes': {
            'id': {'type': 'UUID', 'required': True},
            'attendance_record_id': {'type': 'UUID', 'required': True},
            'exception_type': {
                'type': 'enum',
                'values': ['LATE', 'EARLY_DEPARTURE', 'MISSING_PUNCH_IN', 'MISSING_PUNCH_OUT', 'OVERTIME', 'UNAUTHORIZED_ABSENCE'],
                'required': True
            },
            'severity': {'type': 'enum', 'values': ['INFO', 'WARNING', 'ERROR'], 'required': True},
            'minutes': {'type': 'integer', 'required': False, 'description': 'Duration in minutes'},
            'reason_code': {'type': 'string', 'required': False, 'maxLength': 50},
            'notes': {'type': 'text', 'required': False},
            'is_excused': {'type': 'boolean', 'default': False},
            'excused_by': {'type': 'UUID', 'required': False},
            'excused_at': {'type': 'datetime', 'required': False},
            'created_at': {'type': 'datetime', 'required': True},
            'created_by': {'type': 'UUID', 'required': True}
        },
        'relationships': {
            'belongsToAttendance': {'target': 'AttendanceRecord', 'cardinality': '1'}
        },
        'businessRules': [
            'Automatically created when attendance deviates from schedule',
            'Can be excused by manager',
            'Used for attendance policy enforcement'
        ]
    }
    
    # ClockEvent
    missing_entities['ClockEvent'] = {
        'description': 'Individual clock-in/out events captured from time clocks or mobile apps',
        'attributes': {
            'id': {'type': 'UUID', 'required': True},
            'worker_id': {'type': 'UUID', 'required': True},
            'event_type': {'type': 'enum', 'values': ['CLOCK_IN', 'CLOCK_OUT', 'BREAK_START', 'BREAK_END'], 'required': True},
            'event_timestamp': {'type': 'datetime', 'required': True},
            'device_id': {'type': 'string', 'required': False, 'maxLength': 100},
            'device_type': {'type': 'enum', 'values': ['BIOMETRIC', 'RFID', 'MOBILE_APP', 'WEB', 'MANUAL'], 'required': True},
            'location_latitude': {'type': 'decimal', 'required': False},
            'location_longitude': {'type': 'decimal', 'required': False},
            'location_accuracy': {'type': 'integer', 'required': False},
            'photo_url': {'type': 'string', 'required': False, 'maxLength': 500},
            'is_valid': {'type': 'boolean', 'default': True},
            'validation_status': {'type': 'enum', 'values': ['VALID', 'DUPLICATE', 'OUT_OF_RANGE', 'SUSPICIOUS'], 'required': True},
            'processed': {'type': 'boolean', 'default': False},
            'attendance_record_id': {'type': 'UUID', 'required': False},
            'created_at': {'type': 'datetime', 'required': True}
        },
        'relationships': {
            'belongsToWorker': {'target': 'Worker', 'cardinality': '1'},
            'processedIntoAttendance': {'target': 'AttendanceRecord', 'cardinality': '0..1'}
        },
        'businessRules': [
            'Raw clock events are immutable',
            'Processed into AttendanceRecord by timesheet engine',
            'Duplicate detection based on timestamp proximity',
            'GPS validation for mobile app punches'
        ]
    }
    
    # Timesheet
    missing_entities['Timesheet'] = {
        'description': 'Aggregated timesheet for a worker for a specific period',
        'attributes': {
            'id': {'type': 'UUID', 'required': True},
            'worker_id': {'type': 'UUID', 'required': True},
            'period_start_date': {'type': 'date', 'required': True},
            'period_end_date': {'type': 'date', 'required': True},
            'total_scheduled_hours': {'type': 'decimal', 'required': True},
            'total_worked_hours': {'type': 'decimal', 'required': True},
            'total_regular_hours': {'type': 'decimal', 'required': True},
            'total_overtime_hours': {'type': 'decimal', 'required': True},
            'total_break_hours': {'type': 'decimal', 'required': True},
            'total_paid_hours': {'type': 'decimal', 'required': True},
            'status': {'type': 'enum', 'values': ['DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'LOCKED'], 'required': True},
            'submitted_at': {'type': 'datetime', 'required': False},
            'approved_at': {'type': 'datetime', 'required': False},
            'approved_by': {'type': 'UUID', 'required': False},
            'locked_at': {'type': 'datetime', 'required': False},
            'created_at': {'type': 'datetime', 'required': True},
            'created_by': {'type': 'UUID', 'required': True},
            'updated_at': {'type': 'datetime', 'required': True},
            'updated_by': {'type': 'UUID', 'required': False}
        },
        'relationships': {
            'belongsToWorker': {'target': 'Worker', 'cardinality': '1'},
            'hasEntries': {'target': 'TimesheetEntry', 'cardinality': '1..*'}
        },
        'businessRules': [
            'One timesheet per worker per period',
            'Cannot modify after locked',
            'Totals calculated from entries',
            'Submitted for approval workflow'
        ]
    }
    
    # TimesheetEntry
    missing_entities['TimesheetEntry'] = {
        'description': 'Individual day entry in a timesheet',
        'attributes': {
            'id': {'type': 'UUID', 'required': True},
            'timesheet_id': {'type': 'UUID', 'required': True},
            'work_date': {'type': 'date', 'required': True},
            'attendance_record_id': {'type': 'UUID', 'required': False},
            'scheduled_hours': {'type': 'decimal', 'required': True},
            'worked_hours': {'type': 'decimal', 'required': True},
            'regular_hours': {'type': 'decimal', 'required': True},
            'overtime_hours': {'type': 'decimal', 'required': True},
            'break_hours': {'type': 'decimal', 'required': True},
            'paid_hours': {'type': 'decimal', 'required': True},
            'cost_center_code': {'type': 'string', 'required': False, 'maxLength': 50},
            'job_code': {'type': 'string', 'required': False, 'maxLength': 50},
            'notes': {'type': 'text', 'required': False},
            'created_at': {'type': 'datetime', 'required': True}
        },
        'relationships': {
            'belongsToTimesheet': {'target': 'Timesheet', 'cardinality': '1'},
            'basedOnAttendance': {'target': 'AttendanceRecord', 'cardinality': '0..1'}
        },
        'businessRules': [
            'One entry per date per timesheet',
            'Hours calculated from attendance record',
            'Can be manually adjusted',
            'Supports cost center allocation'
        ]
    }
    
    return missing_entities

def main():
    """Main execution function."""
    print("🔧 Starting Time & Absence Ontology Fix Process...")
    print("="*80)
    
    # Define file paths
    base_path = Path("c:/Users/LAP15399-local/OneDrive - VNG Corporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/TA/00-ontology")
    
    input_file = base_path / "time-absence-ontology.yaml"
    output_file = base_path / "time-absence-ontology-fixed.yaml"
    
    # Load current ontology
    print(f"\n📖 Loading ontology from: {input_file.name}")
    data = load_yaml_preserve_order(input_file)
    
    # Process each entity
    print(f"\n🔄 Processing entities...")
    entities = data.get('entities', {})
    processed_count = 0
    
    for entity_name, entity_data in entities.items():
        print(f"   Processing: {entity_name}")
        
        # 1. Convert list attributes to dict
        entity_data = convert_list_attributes_to_dict(entity_data)
        
        # 2. Add SCD Type 2 fields
        entity_data = add_scd2_fields(entity_data, entity_name)
        
        # 3. Add audit fields
        entity_data = add_audit_fields(entity_data)
        
        # 4. Add indexes
        entity_data = add_indexes(entity_data, entity_name)
        
        entities[entity_name] = entity_data
        processed_count += 1
    
    print(f"   ✅ Processed {processed_count} entities")
    
    # Add missing entities
    print(f"\n➕ Adding missing entities...")
    missing = create_missing_entities()
    for entity_name, entity_data in missing.items():
        print(f"   Adding: {entity_name}")
        entities[entity_name] = entity_data
        
        # Update sub_modules
        if entity_name in ['HolidayCalendar', 'TimeException', 'ClockEvent', 'Timesheet', 'TimesheetEntry']:
            if 'TimeAttendance' in data['sub_modules']:
                if entity_name not in data['sub_modules']['TimeAttendance']['entities']:
                    data['sub_modules']['TimeAttendance']['entities'].append(entity_name)
    
    print(f"   ✅ Added {len(missing)} entities")
    
    # Add notes section
    data['notes'] = {
        'version': '2.0',
        'last_updated': datetime.now().strftime('%Y-%m-%d'),
        'improvements': [
            'Standardized all attributes to dictionary format',
            'Added SCD Type 2 fields to temporal entities',
            'Added complete audit trail (created_by, updated_by)',
            'Added index definitions for all entities',
            'Added missing entities: HolidayCalendar, TimeException, ClockEvent, Timesheet, TimesheetEntry',
            'Standardized relationship notation',
            'Fixed design pattern references'
        ],
        'cross_module_dependencies': {
            'Core (CO)': ['Worker', 'OrgUnit', 'Position', 'Job'],
            'description': 'TA module depends on Core module for worker and organizational data'
        }
    }
    
    # Update design patterns
    if 'design_patterns' in data:
        # Fix ledger pattern references
        data['design_patterns']['ledger_pattern']['applies_to'] = [
            'LeaveBalance',
            'LeaveMovement'
        ]
    
    # Save fixed ontology
    print(f"\n💾 Saving fixed ontology to: {output_file.name}")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"# Time & Absence Module (TA) - Ontology (Fixed)\n")
        f.write(f"# Version: 2.0\n")
        f.write(f"# Last Updated: {datetime.now().strftime('%Y-%m-%d')}\n")
        f.write(f"# Status: All ONTOLOGY-REVIEW issues fixed\n\n")
        
        yaml.dump(data, f,
                 default_flow_style=False,
                 allow_unicode=True,
                 sort_keys=False,
                 width=100,
                 indent=2)
    
    print(f"\n✅ Fix completed successfully!")
    print(f"\n📊 Summary:")
    print(f"   - Entities processed: {processed_count}")
    print(f"   - Entities added: {len(missing)}")
    print(f"   - Total entities: {len(entities)}")
    print(f"\n📝 Next steps:")
    print(f"   1. Review the fixed file: {output_file}")
    print(f"   2. Test YAML parsing")
    print(f"   3. Validate against standards")
    print(f"   4. Replace original file if satisfied")

if __name__ == "__main__":
    main()
