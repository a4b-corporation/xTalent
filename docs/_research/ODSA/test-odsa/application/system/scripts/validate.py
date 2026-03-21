#!/usr/bin/env python3
"""
ODDS System Builder - Validation Script
Validates generated system files against ontology sources.

Usage: python3 validate.py <context_dir>
Example: python3 validate.py application/
"""

import sys
import os
import yaml
import re
from pathlib import Path

def validate_dbml(dbml_path):
    """Validate DBML file syntax and structure."""
    print(f"\n{'='*60}")
    print(f"Validating DBML: {dbml_path}")
    print('='*60)

    if not os.path.exists(dbml_path):
        print(f"  [ERROR] File not found: {dbml_path}")
        return False

    with open(dbml_path, 'r') as f:
        content = f.read()

    errors = []
    warnings = []

    # Check for required Enums
    required_enums = [
        'ApplicationLifecycle', 'GenderEnum', 'MatchTypeEnum',
        'DuplicateStatusEnum', 'ResolutionMethodEnum', 'FieldTypeEnum',
        'QuestionTypeEnum', 'AttachmentTypeEnum', 'UploadStatusEnum'
    ]

    for enum in required_enums:
        if f'Enum {enum}' not in content:
            errors.append(f"Missing Enum: {enum}")

    # Check for required Tables
    required_tables = [
        'student', 'application', 'duplicate',
        'form_field_value', 'question_answer', 'attachment'
    ]

    for table in required_tables:
        if f'Table {table}' not in content:
            errors.append(f"Missing Table: {table}")

    # Check for PK in each table
    # Find each Table block and check for [pk]
    table_pattern = r'Table\s+(\w+)\s*\{([\s\S]*?)\}'
    tables = re.findall(table_pattern, content)

    for table_name, table_body in tables:
        if '[pk' not in table_body:
            errors.append(f"Table '{table_name}' missing [pk] designation")
        if 'created_at' not in table_body:
            warnings.append(f"Table '{table_name}' missing created_at audit field")
        if 'updated_at' not in table_body and table_name not in ['form_field_value', 'question_answer', 'duplicate']:
            warnings.append(f"Table '{table_name}' missing updated_at audit field")

    # Check for FK references
    fk_pattern = r'ref:\s*>\s*\w+\.\w+'
    fks = re.findall(fk_pattern, content)
    print(f"  [INFO] Found {len(fks)} foreign key references")

    # Validate Enum syntax
    enum_pattern = r'Enum\s+\w+\s*\{([^}]+)\}'
    enums = re.findall(enum_pattern, content, re.DOTALL)
    print(f"  [INFO] Found {len(enums)} Enum definitions")

    # Report
    print(f"\n  Tables found: {len(tables)}")
    print(f"  Enums found: {len(enums)}")
    print(f"  FK references: {len(fks)}")

    if errors:
        print(f"\n  [ERROR] {len(errors)} errors found:")
        for err in errors:
            print(f"    - {err}")
        return False

    if warnings:
        print(f"\n  [WARN] {len(warnings)} warnings:")
        for warn in warnings:
            print(f"    - {warn}")

    print(f"\n  [OK] DBML validation passed")
    return True


def validate_openapi(openapi_path):
    """Validate OpenAPI 3.0 spec."""
    print(f"\n{'='*60}")
    print(f"Validating OpenAPI: {openapi_path}")
    print('='*60)

    if not os.path.exists(openapi_path):
        print(f"  [ERROR] File not found: {openapi_path}")
        return False

    with open(openapi_path, 'r') as f:
        content = f.read()

    try:
        spec = yaml.safe_load(content)
    except yaml.YAMLError as e:
        print(f"  [ERROR] YAML syntax error: {e}")
        return False

    errors = []
    warnings = []

    # Check OpenAPI version
    if spec.get('openapi') != '3.0.3':
        warnings.append(f"OpenAPI version is {spec.get('openapi')}, expected 3.0.3")

    # Check required fields
    if 'info' not in spec:
        errors.append("Missing 'info' section")
    if 'paths' not in spec:
        errors.append("Missing 'paths' section")
    if 'components' not in spec:
        errors.append("Missing 'components' section")

    # Check required endpoints
    required_paths = [
        '/applications/submit',
        '/applications/{applicationId}',
        '/applications/{applicationId}/form',
        '/applications/{applicationId}/withdraw',
        '/applications/{applicationId}/attachments'
    ]

    paths = spec.get('paths', {})
    for path in required_paths:
        if path not in paths:
            errors.append(f"Missing required path: {path}")

    print(f"  [INFO] Found {len(paths)} paths")

    # Check schemas
    schemas = spec.get('components', {}).get('schemas', {})
    required_schemas = [
        'ApplicationResponse',
        'StudentResponse',
        'AttachmentResponse',
        'ApplicationLifecycleEnum'
    ]

    for schema in required_schemas:
        if schema not in schemas:
            errors.append(f"Missing required schema: {schema}")

    print(f"  [INFO] Found {len(schemas)} schemas")

    # Check for ApplicationLifecycleEnum values
    lifecycle_schema = schemas.get('ApplicationLifecycleEnum', {})
    lifecycle_values = lifecycle_schema.get('enum', [])
    expected_states = ['DRAFT', 'SUBMITTED', 'SCREENING', 'TEST', 'INTERVIEW', 'OFFER', 'ACCEPTED', 'REJECTED', 'WITHDRAWN']

    for state in expected_states:
        if state not in lifecycle_values:
            errors.append(f"Missing lifecycle state in schema: {state}")

    print(f"  [INFO] Lifecycle states: {len(lifecycle_values)}")

    # Report
    if errors:
        print(f"\n  [ERROR] {len(errors)} errors found:")
        for err in errors:
            print(f"    - {err}")
        return False

    if warnings:
        print(f"\n  [WARN] {len(warnings)} warnings:")
        for warn in warnings:
            print(f"    - {warn}")

    print(f"\n  [OK] OpenAPI validation passed")
    return True


def validate_events(events_path):
    """Validate domain events file."""
    print(f"\n{'='*60}")
    print(f"Validating Events: {events_path}")
    print('='*60)

    if not os.path.exists(events_path):
        print(f"  [ERROR] File not found: {events_path}")
        return False

    with open(events_path, 'r') as f:
        content = f.read()

    try:
        docs = list(yaml.safe_load_all(content))
    except yaml.YAMLError as e:
        print(f"  [ERROR] YAML syntax error: {e}")
        return False

    # Filter out None documents (empty YAML docs)
    docs = [d for d in docs if d is not None]

    errors = []
    warnings = []

    # Expected events based on lifecycle
    expected_events = [
        'ApplicationSubmitted',
        'ApplicationScreened',
        'ApplicationMovedToTest',
        'ApplicationMovedToInterview',
        'ApplicationOffered',
        'ApplicationAccepted',
        'ApplicationRejected',
        'ApplicationWithdrawn'
    ]

    found_events = []
    for doc in docs:
        event_type = doc.get('event_type')
        if event_type:
            found_events.append(event_type)

    print(f"  [INFO] Found {len(found_events)} event definitions")

    for expected in expected_events:
        if expected not in found_events:
            warnings.append(f"Missing expected event: {expected}")

    # Check each event has required fields
    required_fields = ['event_type', 'description', 'trigger', 'source_transition', 'actor', 'payload', 'affects']

    for i, doc in enumerate(docs):
        if doc is None:
            continue
        event_type = doc.get('event_type', f'Event #{i+1}')
        for field in required_fields:
            if field not in doc:
                errors.append(f"{event_type}: Missing required field '{field}'")

    # Check event naming convention: {Entity}{State}d
    naming_pattern = r'^[A-Z][a-zA-Z]+(Submitted|Screened|MovedToTest|MovedToInterview|Offered|Accepted|Rejected|Withdrawn|Detected|Resolved)$'
    for event_type in found_events:
        if not re.match(naming_pattern, event_type):
            warnings.append(f"Event '{event_type}' may not follow naming convention")

    # Report
    print(f"\n  Events found:")
    for event in found_events:
        print(f"    - {event}")

    if errors:
        print(f"\n  [ERROR] {len(errors)} errors found:")
        for err in errors:
            print(f"    - {err}")
        return False

    if warnings:
        print(f"\n  [WARN] {len(warnings)} warnings:")
        for warn in warnings:
            print(f"    - {warn}")

    print(f"\n  [OK] Events validation passed")
    return True


def validate_tracability(context_dir):
    """Validate tracability from ontology to generated files."""
    print(f"\n{'='*60}")
    print(f"Validating Tracability")
    print('='*60)

    # Try multiple ontology locations
    ontology_dirs = [
        os.path.join(context_dir, '..', '..', '5.ontology', 'application'),
        os.path.join(os.path.dirname(context_dir), '..', '..', '5.ontology', 'application'),
        '/Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/Project/A4B/test-odsa/5.ontology/application'
    ]

    ontology_dir = None
    for path in ontology_dirs:
        if os.path.exists(path):
            ontology_dir = path
            break

    if not ontology_dir:
        print(f"  [WARN] Ontology directory not found")
        return True

    # Read ontology files
    ontology_entities = []
    for f in os.listdir(ontology_dir):
        if f.endswith('.yaml'):
            with open(os.path.join(ontology_dir, f), 'r') as file:
                content = file.read()
                # Extract class names
                class_match = re.search(r'^(\w+):', content, re.MULTILINE)
                if class_match:
                    ontology_entities.append(class_match.group(1))

    print(f"  [INFO] Ontology entities: {ontology_entities}")

    # Check DBML has all entities
    dbml_path = os.path.join(context_dir, 'system', 'db.dbml')
    if os.path.exists(dbml_path):
        with open(dbml_path, 'r') as f:
            dbml_content = f.read().lower()

        for entity in ontology_entities:
            entity_snake = entity.lower()
            if f'table {entity_snake}' not in dbml_content:
                print(f"  [WARN] Entity '{entity}' not found as table in DBML")

    print(f"\n  [OK] Tracability check completed")
    return True


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 validate.py <context_dir>")
        print("Example: python3 validate.py application/")
        sys.exit(1)

    context_dir = sys.argv[1]
    system_dir = os.path.join(context_dir, 'system')

    print(f"\n{'#'*60}")
    print(f"# ODDS System Builder - Validation Report")
    print(f"# Context: {context_dir}")
    print(f"{'#'*60}")

    results = []

    # Validate DBML
    dbml_path = os.path.join(system_dir, 'db.dbml')
    results.append(('DBML', validate_dbml(dbml_path)))

    # Validate OpenAPI
    openapi_path = os.path.join(system_dir, 'canonical_api.openapi.yaml')
    results.append(('OpenAPI', validate_openapi(openapi_path)))

    # Validate Events
    events_path = os.path.join(system_dir, 'events.yaml')
    results.append(('Events', validate_events(events_path)))

    # Validate Tracability
    results.append(('Tracability', validate_tracability(context_dir)))

    # Summary
    print(f"\n{'='*60}")
    print(f"VALIDATION SUMMARY")
    print('='*60)

    all_passed = True
    for name, passed in results:
        status = "[PASS]" if passed else "[FAIL]"
        print(f"  {status} {name}")
        if not passed:
            all_passed = False

    print(f"\n{'='*60}")
    if all_passed:
        print(f"[SUCCESS] All validations passed!")
        sys.exit(0)
    else:
        print(f"[FAILURE] Some validations failed!")
        sys.exit(1)


if __name__ == '__main__':
    main()
