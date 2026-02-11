#!/usr/bin/env python3
"""
Split the monolithic time-attendance-ontology.yaml into individual entity files.
This avoids external dependencies (PyYAML not required) by using a lightweight
indent-based parser tailored to the current ontology file structure.
"""

from pathlib import Path
import sys

# Base locations
BASE_DIR = Path("/Users/nguyenhuyvu/Library/CloudStorage/OneDrive-VNGCorporation/Apps/mygit/a4b-doc-xtalent/product/xTalent/docs/01-modules/TA/00-ontology")
INPUT_FILE = BASE_DIR / "time-attendance-ontology.yaml"
OUTPUT_DIR = BASE_DIR

# Default metadata
VERSION = "1.0"

# Map entity names to logical layers (used in file headers)
LAYER_MAP = {
    # Configuration
    "ShiftPattern": "configuration",
    "ShiftBreak": "configuration",
    "Shift": "configuration",
    "Schedule": "configuration",
    # Attendance tracking
    "AttendanceRecord": "attendance-tracking",
    "TimesheetEntry": "attendance-tracking",
    "TimeException": "attendance-tracking",
    # Shift management
    "ShiftSwapRequest": "shift-management",
    "ShiftBid": "shift-management",
    # Overtime
    "OvertimeRule": "overtime",
    "OvertimeRequest": "overtime",
    "OvertimeCalculation": "overtime",
}


def camel_to_kebab(name: str) -> str:
    """Convert CamelCase names to kebab-case file names."""
    result = []
    for char in name:
        if char.isupper() and result:
            result.append("-")
        result.append(char.lower())
    return "".join(result)


def parse_entities(raw_lines):
    """
    Extract entity blocks from the ontology file by inspecting indentation.
    Expects entities to be defined under an 'entities:' root with two-space
    indentation and each entity starting with '  EntityName:'.
    """
    entities = {}
    in_entities_section = False
    current_entity = None
    current_lines = []

    for line in raw_lines:
        if not in_entities_section:
            if line.strip() == "entities:":
                in_entities_section = True
            continue

        # Entities section ends when indentation returns to column 0 and is not blank/comment
        if line and not line.startswith("  "):
            break

        # Skip comments or blank lines at the entity root level
        if line.startswith("  #") or line.strip() == "":
            continue

        stripped = line.strip()
        is_entity_header = line.startswith("  ") and not line.startswith("    ") and stripped.endswith(":")

        if is_entity_header:
            # Save previous entity if present
            if current_entity:
                entities[current_entity] = current_lines
            current_entity = stripped[:-1]  # Remove trailing colon
            current_lines = []
            continue

        if current_entity:
            # Remove four spaces (entity indent + property indent) to make the block top-level
            if line.startswith("    "):
                cleaned = line[4:]
            else:
                cleaned = line.lstrip()
            current_lines.append(cleaned)

    if current_entity:
        entities[current_entity] = current_lines

    return entities


def split_ontology():
    if not INPUT_FILE.exists():
        sys.exit(f"Input file not found: {INPUT_FILE}")

    raw_lines = INPUT_FILE.read_text(encoding="utf-8").splitlines()
    entities = parse_entities(raw_lines)

    if not entities:
        sys.exit("No entities found in the ontology file.")

    written = []
    for entity_name, entity_lines in entities.items():
        output_filename = f"{camel_to_kebab(entity_name)}.yaml"
        output_path = OUTPUT_DIR / output_filename

        layer = LAYER_MAP.get(entity_name)
        header = [
            f"entity: {entity_name}",
            f'version: "{VERSION}"',
        ]
        if layer:
            header.append(f"layer: {layer}")
        header.append("")  # Blank line before body

        output_content = "\n".join(header + entity_lines) + "\n"
        output_path.write_text(output_content, encoding="utf-8")
        written.append(output_path.name)
        print(f"✓ Wrote {output_path}")

    print("-" * 60)
    print(f"Completed splitting {INPUT_FILE.name} into {len(written)} files.")


if __name__ == "__main__":
    split_ontology()
