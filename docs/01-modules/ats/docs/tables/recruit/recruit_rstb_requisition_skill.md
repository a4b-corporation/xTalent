# Data Dictionary - recruit.rstb_requisition_skill

**Mô tả bảng:** Lưu kỹ năng yêu cầu cho requisition

**Nguồn dữ liệu:** `staging.job_skill_requirement_upsert`

**Scripts ETL:** `j_import_all_requisition_skill.py`

---

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| requisition_id | numeric | Lookup `rstb_requisition` | Match bằng ref_id | ID yêu cầu tuyển dụng |
| skill_id | numeric | Lookup `tatm_skill` | 3-level hierarchy lookup | ID kỹ năng yêu cầu |
| skill_info | jsonb | Lookup `tatm_skill.name` | JSONB multi-language | Thông tin kỹ năng |
| skill_code | varchar | Lookup `tatm_skill.code` | Trực tiếp | Mã kỹ năng |
| tenant_code | varchar | Tham số | Hằng số | Mã tenant |
| maker_id | varchar | Hằng số | 'system_etl' | Người tạo |
| maker_date | timestamptz | Hệ thống | `now() at time zone 'ICT'` | Thời điểm tạo |

---

## Quy tắc nghiệp vụ quan trọng

### 1. 3-Level Skill Mapping
```
staging.job_skill_requirement
  → staging.skill_mapping (skill_name_old → skill_new)
  → hrm.tatm_skill (category → subcategory → skill)
```

### 2. Skill Hierarchy
```python
df = df.merge(
    skill_mapping[['skill_name_old', 'category_skill', 'subcategory_skill', 'skill']],
    left_on='skill_name',
    right_on='skill_name_old',
    how='left'
)

df = df.merge(
    tatm_skill[['category', 'subcategory', 'name', 'id']],
    left_on=['category_skill', 'subcategory_skill', 'skill'],
    right_on=['category', 'subcategory', 'name'],
    how='left'
)
```

### 3. Filtering
Chỉ load records có:
- `requisition_id IS NOT NULL`
- `skill_id IS NOT NULL`

### 4. Function Call
```sql
SELECT staging.rsfn_etl_insert_requisition_skill(...)
```
