#!/bin/bash

# Extract remaining sections from 04-business-rules.md

cd 04-business-rules-sections

# Section 7: Deductions (lines 11341-11400 estimated)
sed -n '11341,/^# 8\. /p' ../04-business-rules.md | head -n -1 > 04.07-deductions.md
echo "Created 04.07-deductions.md: $(wc -l < 04.07-deductions.md) lines"

# Section 8: Tax Withholding
sed -n '/^# 8\. Tax Withholding/,/^# 9\. /p' ../04-business-rules.md | head -n -1 > 04.08-tax-withholding.md
echo "Created 04.08-tax-withholding.md: $(wc -l < 04.08-tax-withholding.md) lines"

# Section 9: Taxable Bridge
sed -n '/^# 9\. Taxable Bridge/,/^# 10\. /p' ../04-business-rules.md | head -n -1 > 04.09-taxable-bridge.md
echo "Created 04.09-taxable-bridge.md: $(wc -l < 04.09-taxable-bridge.md) lines"

# Section 10: Audit
sed -n '/^# 10\. Audit/,/^# 11\. /p' ../04-business-rules.md | head -n -1 > 04.10-audit.md
echo "Created 04.10-audit.md: $(wc -l < 04.10-audit.md) lines"

# Section 11: Calculation
sed -n '/^# 11\. Calculation/,$ p' ../04-business-rules.md > 04.11-calculation.md
echo "Created 04.11-calculation.md: $(wc -l < 04.11-calculation.md) lines"

echo ""
echo "=== All sections extracted ==="
ls -lh 04.0*.md

