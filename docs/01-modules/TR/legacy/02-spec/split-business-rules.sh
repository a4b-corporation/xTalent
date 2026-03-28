#!/bin/bash

# Script to split 04-business-rules.md into separate files by section
# Keep original file intact

SOURCE_FILE="04-business-rules.md"
OUTPUT_DIR="04-business-rules-sections"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Splitting $SOURCE_FILE into sections..."

# Extract header (lines before first section)
sed -n '1,/^# 1\. Core Compensation Rules/p' "$SOURCE_FILE" | head -n -1 > "$OUTPUT_DIR/00-header.md"

# Extract each section using awk
awk '
/^# 1\. Core Compensation Rules/,/^# 2\. Variable Pay Rules/ {
    if (/^# 2\. Variable Pay Rules/) exit;
    print > "'"$OUTPUT_DIR"'/04.01-core-compensation.md"
}
' "$SOURCE_FILE"

awk '
/^# 2\. Variable Pay Rules/,/^# 3\. Benefits Rules/ {
    if (/^# 3\. Benefits Rules/) exit;
    print > "'"$OUTPUT_DIR"'/04.02-variable-pay.md"
}
' "$SOURCE_FILE"

awk '
/^# 3\. Benefits Rules/,/^# 4\. Recognition Rules/ {
    if (/^# 4\. Recognition Rules/) exit;
    print > "'"$OUTPUT_DIR"'/04.03-benefits.md"
}
' "$SOURCE_FILE"

awk '
/^# 4\. Recognition Rules/,/^# 5\. Offer Management Rules/ {
    if (/^# 5\. Offer Management Rules/) exit;
    print > "'"$OUTPUT_DIR"'/04.04-recognition.md"
}
' "$SOURCE_FILE"

awk '
/^# 5\. Offer Management Rules/,/^# 6\. / {
    if (/^# 6\. /) exit;
    print > "'"$OUTPUT_DIR"'/04.05-offer-management.md"
}
' "$SOURCE_FILE"

# Extract remaining sections (if any)
awk '
/^# 6\. /,0 {
    print > "'"$OUTPUT_DIR"'/04.06-remaining.md"
}
' "$SOURCE_FILE"

# Count files created
echo ""
echo "Files created in $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR"

echo ""
echo "Line counts:"
wc -l "$OUTPUT_DIR"/*.md

echo ""
echo "Original file preserved: $SOURCE_FILE"
