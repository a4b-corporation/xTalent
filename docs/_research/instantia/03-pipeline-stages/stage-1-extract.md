# Stage 1: Extract - Data Ingestion

## Purpose
Extract raw trade data from various file formats (Excel, CSV, PDF) and convert to a structured tabular format.

---

## Input Sources

### Excel/CSV Files
```
File: trades_2024.xlsx
Columns: Counter Amt, Strike Price, Maturity, Buy/Sell, Call/Put, ...
Rows: 15 (5 strategies × 3 legs average)
```

### PDF Documents
```
File: bank_confirmation.pdf
Content: Table embedded in document
Format: May include logos, headers, formatting
```

---

## Process Flow

### Step 1: File Upload
```
User action: Upload file via UI
Validation:
  - File size < 50MB
  - Extension in [.xlsx, .xls, .csv, .pdf]
```

### Step 2: Format Detection
```
IF extension in [.xlsx, .xls]:
    parser = ExcelParser
ELIF extension == .csv:
    parser = CSVParser
ELIF extension == .pdf:
    parser = PDFParser (with AI OCR)
```

### Step 3: Data Extraction

**Excel/CSV**: Direct parsing
```python
import pandas as pd

if file.endswith('.csv'):
    df = pd.read_csv(file)
else:
    df = pd.read_excel(file)
```

**PDF**: AI-powered OCR
```
Process:
  1. Convert PDF pages to images
  2. Send to Vision LLM (e.g., LLaVA, GPT-4V)
  3. Prompt: "Extract the trade table from this image"
  4. LLM returns structured JSON/CSV
  5. Convert to DataFrame
```

### Step 4: Initial Validation
```
Checks:
  - Is data tabular? (rows × columns)
  - Are there at least 2 columns?
  - At least 1 row?

IF validation fails:
    Return error: "Cannot parse file structure"
```

---

## Output Format

### Raw DataFrame
```
Columns: Variable (vendor-specific names)
Rows: Individual trade legs
Index: Auto-generated (0, 1, 2, ...)
```

**Example Output**:
```
   Counter Amt  Strike Price  Maturity    Buy/Sell  Call/Put  Terms
0  100000       1.08          2024-06-15  Sell      Put       EUR/USD
1  100000       1.10          2024-06-15  Buy       Call      EUR/USD
2  200000       1.06          2024-06-15  Sell      Put       EUR/USD
3  200000       1.12          2024-06-15  Buy       Call      EUR/USD
```

---

## Edge Cases

### Case 1: Multi-Sheet Excel
```
Problem: File has multiple sheets

Handling:
  - Default: Read first sheet only
  - Advanced: Allow user to select sheet
```

### Case 2: Header Row Detection
```
Problem: Data starts at row 5 (after logos/titles)

Handling:
  - Auto-detect: Find first row with >50% non-empty cells
  - Fallback: Assume row 0 is header
```

### Case 3: Merged Cells (Excel)
```
Problem: Excel merged cells break parsing

Handling:
  - Unmerge cells
  - Forward-fill values
```

### Case 4: PDF Table Extraction Failure
```
Problem: LLM cannot find table structure

Handling:
  - Retry with different prompt
  - Allow manual CSV paste
  - Suggest image quality improvement
```

### Case 5: Encoding Issues (CSV)
```
Problem: Non-UTF8 characters (e.g., Asian languages)

Handling:
  - Try multiple encodings: UTF-8, Latin-1, Windows-1252
  - User override: Specify encoding
```

---

## Quality Checks

### Post-Extraction Validation

**Check 1**: Column count
```
Expected: 5-20 columns (typical trade data)
Warning: < 3 columns → may be mis-parsed
```

**Check 2**: Row count
```
Expected: 1-10,000 rows
Warning: 0 rows → parsing failed
Warning: > 10,000 → performance impact
```

**Check 3**: Data types
```
Expected mix:
  - Numeric columns (amounts, rates)
  - Text columns (buy_sell, call_put)
  - Date columns (trade_date, expiry)

Warning: All text → may need type conversion
```

---

## Performance Considerations

### File Size Limits
```
Excel/CSV: Up to 50MB (≈500K rows)
PDF: Up to 20MB (≈50 pages)

Rationale: Beyond this, use batch processing
```

### Caching
```
# Cache uploaded files temporarily
cache_path = f"temp/{file_hash}.csv"

IF file already uploaded:
    df = load_from_cache(cache_path)
ELSE:
    df = parse_file(file)
    save_to_cache(df, cache_path)
```

### Concurrent Processing
```
# For PDF with multiple pages
pages = split_pdf(file)

results = parallel_map(
    function=extract_page,
    inputs=pages,
    workers=4
)

df = concat(results)
```

---

## Example: Complete Extraction

### Input File: `bank_trades.xlsx`
```
Sheet: "Trades"
Header Row: 1
Data Rows: 2-16 (15 legs)
```

### Extraction Process
```
1. Read Excel: pd.read_excel("bank_trades.xlsx", sheet_name=0)

2. Detect header: Row 1 has column names

3. Parse data types:
   - "Counter Amt" → float64
   - "Maturity" → datetime64
   - "Buy/Sell" → object (string)

4. Validate:
   ✓ 15 rows extracted
   ✓ 8 columns detected
   ✓ No empty rows
```

### Output DataFrame
```python
print(df.shape)  # (15, 8)

print(df.columns)
# ['Counter Amt', 'Strike Price', 'Maturity', 'Buy/Sell', 
#  'Call/Put', 'Terms', 'Premium', 'Trade Date']

print(df.dtypes)
# Counter Amt      float64
# Strike Price     float64
# Maturity         datetime64[ns]
# Buy/Sell         object
# Call/Put         object
# Terms            object
# Premium          float64
# Trade Date       datetime64[ns]
```

---

## UI/UX Flow

### User Actions
```
1. Navigate to "Extract" page
2. Click "Upload File" button
3. Select file from file system
4. Wait for processing (< 5 seconds for typical files)
5. View extracted data in table
```

### User Feedback
```
During upload:
  - Progress indicator
  - "Processing..." message

On success:
  - ✅ "Loaded 15 rows, 8 columns"
  - Display data table preview

On error:
  - ❌ "Failed to parse file. Please check format."
  - Suggest troubleshooting steps
```

---

## Data Persistence

### State Storage
```
# Save to in-memory state for next stage
state['extract_data'] = df
state['extract_metadata'] = {
    'filename': file.name,
    'row_count': len(df),
    'col_count': len(df.columns),
    'timestamp': datetime.now()
}
```

### Restart Capability
```
# Allow re-running extract without re-upload
IF state['extract_data'] exists:
    Show: "Previous data: 15 rows"
    Option: "Use previous" OR "Upload new file"
```

---

## Summary

**Stage**: Extract (Stage 1 of 5)  
**Input**: Excel/CSV/PDF files  
**Output**: Pandas DataFrame with vendor-specific column names  
**Key Challenge**: Multi-format support (especially PDF OCR)  
**Performance**: < 5 seconds for typical files  
**Next Stage**: Standardize (map columns to standard names)

---

## Transition to Stage 2

```
Extract Output → Standardize Input

DataFrame columns: Vendor-specific (e.g., "Counter Amt")
Next step: Map to standard names (e.g., "counter_amt")
```
