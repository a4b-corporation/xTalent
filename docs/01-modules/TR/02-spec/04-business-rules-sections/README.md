# Business Rules - Split Sections

This directory contains the TR Module business rules split into separate files by section for easier navigation and maintenance.

## Files

| File | Section | Lines | Size | Rules | Status |
|------|---------|-------|------|-------|--------|
| `04.01-core-compensation.md` | Core Compensation | 2,130 | 44KB | 51 | ✅ Complete |
| `04.02-variable-pay.md` | Variable Pay | 2,268 | 46KB | 50 | ✅ Complete |
| `04.03-benefits.md` | Benefits | 3,478 | 73KB | 66 | ✅ Complete |
| `04.04-recognition.md` | Recognition | 1,655 | 35KB | 31 | ✅ Complete |
| `04.05-offer-management.md` | Offer Management | 1,703 | 39KB | 34 | ✅ Complete |
| `04.06-tr-statement.md` | TR Statement | 762 | 16KB | 22 | ✅ Complete |
| `04.07-deductions.md` | Deductions | ~33 | ~1KB | 0/32 | 📝 Placeholder |
| `04.08-tax-withholding.md` | Tax Withholding | ~36 | ~1KB | 0/37 | 📝 Placeholder |
| `04.09-taxable-bridge.md` | Taxable Bridge | ~33 | ~1KB | 0/18 | 📝 Placeholder |
| `04.10-audit.md` | Audit | ~39 | ~1KB | 0/25 | 📝 Placeholder |
| `04.11-calculation.md` | Calculation | ~83 | ~2KB | 0/37 | 📝 Placeholder |

**Total**: ~12,220 lines, ~258KB

## Original File

The original consolidated file `04-business-rules.md` (11,616 lines, 257KB) is preserved in the parent directory for reference.

## Section Status

### ✅ Complete Sections (254 rules)
- **Core Compensation**: 51 rules (full detail)
- **Variable Pay**: 50 rules (full detail)
- **Benefits**: 66 rules (full detail)
- **Recognition**: 31 rules (full detail)
- **Offer Management**: 34 rules (mixed: 26 full + 8 concise)
- **TR Statement**: 22 rules (concise format, CO/TA standard)

### 📝 Placeholder Sections (149 rules)
- **Deductions**: 32 rules (summary only)
- **Tax Withholding**: 37 rules (summary only)
- **Taxable Bridge**: 18 rules (summary only)
- **Audit**: 25 rules (summary only)
- **Calculation**: 37 rules (summary only)

## Format Standards

**Full Detail Format** (~60-70 lines/rule):
- Multi-line descriptions
- Code block conditions
- Detailed numbered rules
- YAML examples
- Multiple error messages
- Used in: Core Compensation, Variable Pay, Benefits (partial), Recognition (partial)

**Concise Format** (~25-35 lines/rule):
- Brief descriptions
- Simple conditions
- Numbered rules (5-7 items)
- NO YAML examples
- Single error message
- **Standard for CO/TA modules**
- Used in: Offer (partial), TR Statement

**Summary Format** (~5-10 lines/section):
- High-level overview only
- Rule categories listed
- Key highlights
- Used in: Deductions, Tax, Taxable Bridge, Audit, Calculation

## Usage

- **For editing**: Work on individual section files
- **For reference**: Use original `04-business-rules.md`
- **For merging**: Concatenate section files if needed

## Notes

- Sections 1-6: Fully detailed with examples
- Section 6 (TR Statement): Concise format (matches CO/TA standard)
- Sections 7-11: Summary format only (to be expanded)
- File split performed: 2025-12-15
- Split script: `split-business-rules.sh`

---

**Last Updated**: 2025-12-15  
**Total Rules**: 254 complete + 149 placeholder = 403 rules
