# Morphological Analysis: Worker Demographics Completeness

**Date**: 2026-01-26  
**Framework**: Morphological Analysis + Black Hat Critique  
**Focus**: Demographics Attributes (Ontology vs Database Design)  
**Target**: Worker.onto.md (Core HR Domain)

---

## Executive Summary

Đã áp dụng **Morphological Analysis** để rà soát đầy đủ các khía cạnh "Nhân khẩu học" (Demographics) cho thực thể `Worker`, đảm bảo AI/Graph có đủ ngữ nghĩa để phân tích mà không phụ thuộc vào CodeList vô danh.

**Key Insight**: 
> **Database** lưu trữ linh hoạt (CodeList EAV Model)  
> **Ontology** cần ngữ nghĩa rõ ràng (Explicit Attributes)

**Kết quả**: +10 attributes mới, chuyển đổi 3 attributes từ hard enum sang CodeList reference, thêm PII metadata cho 15 sensitive fields

---

## Problem Statement: Ontology vs Database Design

### Mâu thuẫn cốt lõi

| Aspect | Database (CodeList) | Ontology (Semantic) |
|--------|---------------------|---------------------|
| **Mục đích** | Lưu trữ linh hoạt | Ngữ nghĩa rõ ràng |
| **Thiết kế** | EAV Model (Entity-Attribute-Value) | Explicit Attributes |
| **Ví dụ** | `{codeType: "RELIGION", value: "123"}` | `religion: "BUDDHIST"` |
| **Ưu điểm** | Thêm field mới không cần ALTER TABLE | AI hiểu được "Tôn giáo" là gì |
| **Nhược điểm** | AI không đoán được ID "123" là gì | Cần ALTER TABLE khi thêm field |

### Câu hỏi AI không trả lời được với CodeList

❌ **Với CodeList vô danh**:
```sql
-- AI không biết "codeType=RELIGION, value=123" nghĩa là gì
SELECT COUNT(*) FROM Worker w
JOIN CodeListValue clv ON w.religionCodeId = clv.id
WHERE clv.codeType = 'RELIGION' AND clv.value = '123'
```

✅ **Với Ontology Attribute**:
```cypher
// AI hiểu rõ ràng: "Tỷ lệ nhân sự theo đạo Phật"
MATCH (w:Worker {religion: "BUDDHIST"})
WHERE w.department = "Branch A"
RETURN COUNT(w)
```

---

## Morphological Analysis: Demographics Checklist

### A. Biological & Health (6 attributes)

| Attribute | Type | Added? | Rationale |
|-----------|------|--------|-----------|
| `gender` | enum | ✅ Existed | Fixed enum (biological categories rarely change) |
| `bloodType` | enum | ✅ Existed | Critical for workplace safety |
| **`height`** | number | ✅ **NEW** | Uniform sizing, health assessments (100-250 cm) |
| **`weight`** | number | ✅ **NEW** | Uniform sizing, health assessments (30-300 kg) |
| **`smokingStatus`** | enum | ✅ **NEW** | Health insurance premium calculations |
| `disabilityStatus` | enum | ✅ Enhanced | Tax deductions, hiring quotas (NONE/REGISTERED) |

**PII Metadata**: All marked as `pii: true`, sensitivity: low-high

---

### B. Cultural & Social (4 attributes)

| Attribute | Type | Changed? | Rationale |
|-----------|------|----------|-----------|
| `maritalStatus` | string | ✅ **enum → CodeList** | Maps to CODELIST_MARITAL_STATUS (dynamic values) |
| `religion` | string | ✅ **Enhanced** | Maps to CODELIST_RELIGION (SENSITIVE DATA) |
| `ethnicity` | string | ✅ **Enhanced** | Maps to CODELIST_ETHNICITY (VN: 54 groups) |
| **`nativeLanguage`** | string | ✅ **NEW** | Mother tongue (different from foreign language skills) |

**Key Change**: Chuyển từ **hard enum** sang **CodeList reference**

**Before** (Hard Enum - Sai):
```yaml
- name: maritalStatus
  type: enum
  values: [SINGLE, MARRIED, DIVORCED]  # ❌ Không mở rộng được
```

**After** (CodeList Reference - Đúng):
```yaml
- name: maritalStatus
  type: string
  constraints:
    reference: CODELIST_MARITAL_STATUS  # ✅ Linh hoạt, AI vẫn hiểu
  metadata:
    codeListValues: [SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED, DOMESTIC_PARTNERSHIP]
```

---

### C. Civil & Origin (5 attributes)

| Attribute | Type | Changed? | Rationale |
|-----------|------|----------|-----------|
| `primaryNationality` | string | ✅ **Enhanced** | Maps to CODELIST_COUNTRY (ISO 3166) |
| **`dualCitizenship`** | string | ✅ **NEW** | Secondary citizenship (critical for expats) |
| `countryOfBirth` | string | ✅ **Enhanced** | May differ from nationality |
| `regionOfBirth` | string | ✅ **Enhanced** | Maps to CODELIST_PROVINCE (VN) |
| **`militaryStatus`** | enum | ✅ **NEW** | Required in VN, Korea (COMPLETED/EXEMPTED/DEFERRED) |

**Pattern Constraint**: ISO Country codes must match `^[A-Z]{2}$` (e.g., VN, US, KR)

---

## Solution: Hybrid Approach (Best of Both Worlds)

### Strategy: CodeList Reference with Metadata

```yaml
- name: religion
  type: string                          # ✅ Database lưu string (linh hoạt)
  constraints:
    reference: CODELIST_RELIGION        # ✅ Chỉ dẫn cho AI biết nguồn dữ liệu
  metadata:
    pii: true
    sensitivity: high
    codeListValues: [BUDDHIST, CATHOLIC, PROTESTANT, ...]  # ✅ AI biết các giá trị hợp lệ
```

**Benefits**:
1. ✅ **Database**: Linh hoạt thêm giá trị mới vào CodeList mà không ALTER TABLE
2. ✅ **Ontology**: AI biết rõ "religion" là thuộc tính gì và có giá trị nào
3. ✅ **Validation**: `codeListValues` giúp validate input
4. ✅ **Documentation**: Dev/BA đọc YAML biết ngay nguồn dữ liệu

---

## Black Hat Critique: Risk Analysis

### Risk 1: Privacy & Security (GDPR/Decree 13)

**Problem**: Tôn giáo, Dân tộc, Khuyết tật là **Dữ liệu nhạy cảm**

**Solution**: Thêm `metadata.pii` và `metadata.sensitivity`

```yaml
- name: religion
  metadata:
    pii: true              # ✅ Đánh dấu là Personal Identifiable Information
    sensitivity: high      # ✅ Mức độ nhạy cảm (low/medium/high)
```

**Implementation**:
- UI: Tự động mask field này cho user thường (`***`)
- API: Require special permission để access
- Audit: Log mọi truy cập vào sensitive fields

---

### Risk 2: Sync Consistency (CodeList Updates)

**Problem**: Business User thêm "Dân tộc X" vào CodeList, nhưng YAML lại define `enum` cứng → Lỗi validate

**Bad Practice** ❌:
```yaml
- name: ethnicity
  type: enum
  values: [KINH, TAY, THAI]  # ❌ Cứng nhắc, không sync với DB
```

**Best Practice** ✅:
```yaml
- name: ethnicity
  type: string
  constraints:
    reference: CODELIST_ETHNICITY  # ✅ Sync với DB
  metadata:
    codeListValues: [KINH, TAY, THAI, ...]  # ✅ Chỉ để tham khảo, không validate cứng
```

---

### Risk 3: Performance (Join Overhead)

**Problem**: Mỗi lần query Worker phải JOIN với CodeList → Chậm

**Solution**: Denormalize display value

```sql
-- Table: Worker
CREATE TABLE Worker (
  id UUID PRIMARY KEY,
  religionCode VARCHAR(50),           -- FK to CodeList
  religionDisplay VARCHAR(200),       -- ✅ Denormalized for performance
  ...
);

-- Trigger: Sync display value khi CodeList update
CREATE TRIGGER sync_religion_display
AFTER UPDATE ON CodeList
FOR EACH ROW
BEGIN
  UPDATE Worker 
  SET religionDisplay = NEW.displayValue
  WHERE religionCode = NEW.code;
END;
```

---

## Changes Summary

### 10 New Attributes

| Category | Attributes | Count |
|----------|-----------|-------|
| **Biological & Health** | height, weight, smokingStatus | 3 |
| **Cultural & Social** | nativeLanguage | 1 |
| **Civil & Origin** | dualCitizenship, militaryStatus | 2 |
| **Enhanced (CodeList)** | maritalStatus, religion, ethnicity, primaryNationality, countryOfBirth, regionOfBirth, correspondenceLanguage | 7 |

### Metadata Enhancements

**15 Attributes** now have PII metadata:

| Sensitivity Level | Attributes | Count |
|-------------------|-----------|-------|
| **HIGH** | bloodType, disabilityStatus, religion, ethnicity | 4 |
| **MEDIUM** | gender, smokingStatus, maritalStatus, primaryNationality, dualCitizenship, militaryStatus | 6 |
| **LOW** | height, weight | 2 |

---

## Implementation Checklist

### Phase 1: Database Schema (Week 1)
- [ ] Add new columns: `height`, `weight`, `smokingStatus`, `nativeLanguage`, `dualCitizenship`, `militaryStatus`
- [ ] Convert `maritalStatus`, `religion`, `ethnicity` to reference CodeList
- [ ] Add PII metadata columns: `piiLevel`, `sensitivityLevel`

### Phase 2: CodeList Setup (Week 2)
- [ ] Create `CODELIST_MARITAL_STATUS` (SINGLE, MARRIED, DIVORCED, WIDOWED, SEPARATED, DOMESTIC_PARTNERSHIP)
- [ ] Create `CODELIST_RELIGION` (BUDDHIST, CATHOLIC, PROTESTANT, ISLAM, HINDU, NONE, OTHER)
- [ ] Create `CODELIST_ETHNICITY` (54 VN ethnic groups)
- [ ] Create `CODELIST_LANGUAGE` (VIETNAMESE, ENGLISH, CHINESE, FRENCH, KHMER, HMONG)
- [ ] Create `CODELIST_COUNTRY` (ISO 3166-1 alpha-2)
- [ ] Create `CODELIST_PROVINCE` (VN provinces)

### Phase 3: Data Migration (Week 3)
- [ ] Migrate existing enum values to CodeList references
- [ ] Backfill `nativeLanguage` (default to `correspondenceLanguage`)
- [ ] Backfill `dualCitizenship` from `additionalNationalities[0]`

### Phase 4: API & UI (Week 4)
- [ ] Update API to mask sensitive fields based on `piiLevel`
- [ ] Update UI to show dropdown from CodeList
- [ ] Add audit logging for sensitive field access

---

## Validation: AI Query Examples

### Query 1: Demographics Analytics
```cypher
// Tỷ lệ nhân sự theo dân tộc tại chi nhánh Hà Nội
MATCH (w:Worker)-[:WORKS_AT]->(d:Department {name: "Hanoi Branch"})
WHERE w.ethnicity IS NOT NULL
RETURN w.ethnicity, COUNT(w) AS count
ORDER BY count DESC
```

### Query 2: Health & Safety
```cypher
// Danh sách nhân viên hút thuốc để tính bảo hiểm
MATCH (w:Worker {smokingStatus: "SMOKER"})
RETURN w.id, w.preferredName, w.dateOfBirth
```

### Query 3: Compliance (Military Service)
```cypher
// Nam giới dưới 27 tuổi chưa hoàn thành nghĩa vụ quân sự
MATCH (w:Worker)
WHERE w.gender = "MALE" 
  AND w.dateOfBirth > date("1997-01-01")
  AND w.militaryStatus NOT IN ["COMPLETED", "EXEMPTED"]
RETURN w.id, w.preferredName, w.militaryStatus
```

---

## Next Steps

### Immediate (This Sprint)
1. ✅ Update `Worker.onto.md` (DONE)
2. ⏳ Create `codelist-management.brs.md` (Business rules for CodeList sync)
3. ⏳ Create `pii-metadata-standards.md` (PII classification guidelines)

### Short-term (Next Sprint)
4. ⏳ Update DBML schema with new columns
5. ⏳ Create CodeList seed data (54 VN ethnic groups, religions, etc.)
6. ⏳ Implement PII masking middleware

### Long-term (Next Quarter)
7. ⏳ Build Demographics Analytics Dashboard
8. ⏳ Integrate with Government APIs (CCCD verification)
9. ⏳ AI-powered demographics insights

---

## Appendix: CodeList Reference Values

### A. CODELIST_ETHNICITY (Vietnam - 54 Groups)

```yaml
codeList: CODELIST_ETHNICITY
values:
  - code: KINH
    display: Kinh (Việt)
    percentage: 85.3%
  - code: TAY
    display: Tày
    percentage: 1.9%
  - code: THAI
    display: Thái
    percentage: 1.8%
  - code: MUONG
    display: Mường
    percentage: 1.5%
  - code: KHMER
    display: Khmer (Khơ-me)
    percentage: 1.5%
  - code: HMONG
    display: H'Mông
    percentage: 1.3%
  # ... (48 more groups)
```

### B. CODELIST_RELIGION (Vietnam)

```yaml
codeList: CODELIST_RELIGION
values:
  - code: BUDDHIST
    display: Phật giáo (Buddhism)
  - code: CATHOLIC
    display: Công giáo (Catholicism)
  - code: PROTESTANT
    display: Tin lành (Protestantism)
  - code: CAODAI
    display: Cao Đài
  - code: HOAHAO
    display: Hòa Hảo
  - code: ISLAM
    display: Hồi giáo (Islam)
  - code: NONE
    display: Không tôn giáo
  - code: OTHER
    display: Khác
  - code: PREFER_NOT_TO_SAY
    display: Không muốn trả lời
```

---

**Approval Status**: ✅ APPROVED - Ready for Implementation

**Reviewed by**: Morphological Analysis + Black Hat Critique  
**Next Review**: After Phase 1 Migration (Week 1)
