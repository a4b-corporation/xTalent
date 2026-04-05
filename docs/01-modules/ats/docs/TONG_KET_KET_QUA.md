# TỔNG KẾT KẾT QUẢ PHÂN TÍCH ETL DATA DICTIONARY

**Ngày hoàn thành:** 2026-04-04
**Phạm vi:** 46 script ETL trong `/scripts_uat`
**Cập nhật:** Đã tạo 28 file data dictionary chi tiết trong `tables/<domain>/`
**Cấu trúc mới:** `docs/tables/hrm/`, `docs/tables/recruit/`, `docs/tables/connect/`, `docs/tables/kpi/`

---

## I. SỐ LƯỢNG SCRIPT ĐÃ PHÂN TÍCH

| Nhóm | Số lượng | Scripts |
|------|----------|---------|
| **Candidate** | 13 | j_import_all_candidate.py, j_import_all_candidate_*.py (10 files), j_import_candidate_file_cv.py, j_import_all_matching_candidate.py, j_import_all_online_candidate.py, j_import_online_candidate_file_cv.py |
| **Employee/HRM** | 8 | j_import_all_employee.py, j_get_api_to_staging_employee.py, j_get_api_to_staging_wr_ex_employee.py, j_import_wr_ex_employee.py, hrm_prod_j_add_role_for_user.py, hrm_staging_j_add_role_for_user.py, hrm_staging_j_get_api_to_staging_data_upsert.py, j_get_api_to_staging_data.py |
| **Request/Approval** | 6 | j_import_all_request.py, j_update_all_request_for_emp.py, j_import_all_history_approval.py, j_import_add_share_handles.py, j_import_update_member_assignment.py, j_import_mapping_data.py |
| **Interview/Recruitment** | 8 | j_import_all_interview_note.py, j_import_all_interviewers.py, j_update_all_interview_result.py, j_import_all_posting_job.py, j_import_all_requisition_skill.py, j_assign_role_for_user.py, j_check_sum_data_staging.py, j_get_api_to_staging_data.py |
| **Program/Event/Other** | 11 | j_import_all_program_event.py, j_import_all_program_event_online.py, j_import_all_student_program.py, j_import_all_survey_result.py, j_import_all_event_field.py, j_import_all_event_gift.py, j_import_all_event_question.py, j_import_key_student.py, j_import_all_erp_payment.py, j_import_all_erp_payment_line.py |

**Tổng cộng:** 46 scripts

---

## II. DATA DICTIONARY ĐÃ TẠO (28 FILES TRONG TABLES/)

### Files Index & Summary (vẫn ở docs/)
- `DATA_DICTIONARY_INDEX.md` - Mục lục toàn bộ 33+ tables
- `TONG_KET_KET_QUA.md` - Tổng kết kết quả
- `README.md` - Hướng dẫn sử dụng
- `online_candidate_function.md` - Function documentation

### Files Chi Tiết (28 files trong tables/)

#### HRM Domain (9 files) - `tables/hrm/`
1. `hrm_hrtb_worker.md` - 48 fields
2. `hrm_hrtb_worker_summary.md` - 17 fields
3. `hrm_hrtb_worker_qualification.md` - 19 fields
4. `hrm_hrtb_worker_record.md` - 23 fields
5. `hrm_hrtb_worker_social.md` - 10 fields
6. `hrm_hrtb_worker_attachment.md` - 15 fields
7. `hrm_hrtb_employee.md` - 34 fields
8. `hrm_hrtb_wr_ex_employee.md` - 14 fields
9. `hrm_hrtb_etl_key_student.md` - 36 fields

#### Recruit Domain (15 files) - `tables/recruit/`
10. `recruit_cstb_candidate_checkin.md` - 20 fields
11. `recruit_rstb_requisition.md` - 62 fields
12. `recruit_rstb_requisition_candidate.md` - 16 fields
13. `recruit_rstb_requisition_skill.md` - 7 fields
14. `recruit_rstb_assessment_interview.md` - 17 fields
15. `recruit_rstb_assessment_screening.md` - 9 fields
16. `recruit_rstb_odoo_approval_history.md` - 9 fields
17. `recruit_rstb_erp_payment.md` - 23 fields
18. `recruit_rstb_erp_payment_line.md` - 13 fields
19. `recruit_rstb_survey_result.md` - 13 fields
20. `recruit_pstb_event.md` - 24 fields
21. `recruit_pstb_student_program.md` - 30 fields
22. `recruit_pstb_event_field.md` - 13 fields
23. `recruit_gstb_event_gift.md` - 12 fields
24. `recruit_qstb_event_question.md` - 13 fields

#### Connect Domain (2 files) - `tables/connect/`
25. `connect_cstb_posting.md` - 20 fields
26. `connect_cstb_candidate_resume.md` - 4 fields

#### KPI Domain (1 file) - `tables/kpi/`
27. `kpi_kstb_goal_assignment.md` - 13 fields

---

## III. TARGET TABLES ĐÃ DOCUMENTED (28 tables)

### HRM Schema (9 tables) - ĐÃ DOCUMENTED
| Table | Fields | Script | File |
|-------|--------|--------|------|
| hrm.hrtb_worker | 48 | j_import_all_candidate.py | ✅ hrm_hrtb_worker.md |
| hrm.hrtb_worker_summary | 17 | 3 scripts | ✅ hrm_hrtb_worker_summary.md |
| hrm.hrtb_worker_qualification | 19 | j_import_all_candidate_certificate_info.py | ✅ hrm_hrtb_worker_qualification.md |
| hrm.hrtb_worker_record | 23 | j_import_all_candidate_working_background.py | ✅ hrm_hrtb_worker_record.md |
| hrm.hrtb_worker_social | 10 | j_import_all_candidate_contact.py | ✅ hrm_hrtb_worker_social.md |
| hrm.hrtb_worker_attachment | 15 | j_import_candidate_file_cv.py | ✅ hrm_hrtb_worker_attachment.md |
| hrm.hrtb_employee | 34 | j_import_all_employee.py | ✅ hrm_hrtb_employee.md |
| hrm.hrtb_wr_ex_employee | 14 | j_import_wr_ex_employee.py | ✅ hrm_hrtb_wr_ex_employee.md |
| hrm.hrtb_etl_key_student | 36 | j_import_all_program_event.py | ✅ hrm_hrtb_etl_key_student.md |

### Recruit Schema (15 tables) - ĐÃ DOCUMENTED
| Table | Fields | Script | File |
|-------|--------|--------|------|
| recruit.cstb_candidate_checkin | 20 | j_import_all_candidate_checkin.py | ✅ recruit_cstb_candidate_checkin.md |
| recruit.rstb_assessment_interview | 17 | j_import_all_interview_note.py, j_import_all_interviewers.py | ✅ recruit_rstb_assessment_interview.md |
| recruit.rstb_assessment_screening | 9 | j_import_all_interview_note.py | ✅ recruit_rstb_assessment_screening.md |
| recruit.rstb_requisition | 62 | j_import_all_request.py | ✅ recruit_rstb_requisition.md |
| recruit.rstb_requisition_candidate | 16 | j_import_all_history_approval.py | ✅ recruit_rstb_requisition_candidate.md |
| recruit.rstb_odoo_approval_history | 9 | j_import_all_history_approval.py | ✅ recruit_rstb_odoo_approval_history.md |
| recruit.rstb_survey_result | 13 | j_import_all_survey_result.py | ✅ recruit_rstb_survey_result.md |
| recruit.rstb_erp_payment | 23 | j_import_all_erp_payment.py | ✅ recruit_rstb_erp_payment.md |
| recruit.rstb_erp_payment_line | 13 | j_import_all_erp_payment_line.py | ✅ recruit_rstb_erp_payment_line.md |
| recruit.rstb_requisition_skill | 7 | j_import_all_requisition_skill.py | ✅ recruit_rstb_requisition_skill.md |
| recruit.pstb_event | 24 | j_import_all_program_event_online.py | ✅ recruit_pstb_event.md |
| recruit.pstb_student_program | 30 | j_import_all_student_program.py | ✅ recruit_pstb_student_program.md |
| recruit.pstb_event_field | 13 | j_import_all_event_field.py | ✅ recruit_pstb_event_field.md |
| recruit.gstb_event_gift | 12 | j_import_all_event_gift.py | ✅ recruit_gstb_event_gift.md |
| recruit.qstb_event_question | 13 | j_import_all_event_question.py | ✅ recruit_qstb_event_question.md |

### Connect Schema (2 tables) - ĐÃ DOCUMENTED
| Table | Fields | Script | File |
|-------|--------|--------|------|
| connect.cstb_posting | 20 | j_import_all_posting_job.py | ✅ connect_cstb_posting.md |
| connect.cstb_candidate_resume | 4 | j_import_online_candidate_file_cv.py | ✅ connect_cstb_candidate_resume.md |

### KPI Schema (1 table) - ĐÃ DOCUMENTED
| Table | Fields | Script | File |
|-------|--------|--------|------|
| KPI.KSTB_GOAL_ASSIGNMENT | 13 | j_import_add_share_handles.py | ✅ kpi_kstb_goal_assignment.md |

---

## IV. COMMON PATTERNS IDENTIFIED

### 1. Boolean Casting
```python
true_values = ['true', 't', 'yes', 'y', '1']
df['flag'] = df['source_flag'].astype(str).str.lower().isin(true_values).astype(int)
```

### 2. JSON Construction (Multi-language)
```python
df['name_info'] = json.dumps({'vi': x['name_vi'], 'en': x['name_en']})
```

### 3. Lookup Pattern
```python
df = df.merge(ref_table[['ref_id', 'id', 'code', 'name']], 
              left_on='source_id', right_on='ref_id', how='left')
```

### 4. Batch Processing
```python
from psycopg2.extras import execute_batch
execute_batch(cur, sql, values, page_size=100)
```

### 5. Upsert Pattern
```sql
INSERT INTO target VALUES (...) 
ON CONFLICT (key) DO UPDATE SET ..., mod_no = mod_no + 1
```

### 6. MERGE Statement
```sql
MERGE INTO target USING source ON key 
WHEN MATCHED THEN UPDATE SET ... 
WHEN NOT MATCHED THEN INSERT ...
```

---

## V. DATA FLOW ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│ DATA SOURCES                                                 │
│ - Odoo API (Master Data, Employee, Worker)                  │
│ - SharePoint Excel Files (60+ files)                        │
│ - S3 CSV/Excel Files                                        │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│ STAGING SCHEMA (AWS Glue Jobs)                              │
│ - staging.employee_staging_upsert                           │
│ - staging.wr_ex_employee_*                                  │
│ - staging.{master_data}_upsert                              │
│ - staging.{data}_upsert                                     │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│ TRANSFORMATION (46 Scripts)                                 │
│ - Lookup & Mapping (reference tables)                       │
│ - Boolean casting, Date parsing                             │
│ - JSON construction (multi-language)                        │
│ - Full-text search building                                 │
│ - Code deduplication                                        │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│ TARGET SCHEMAS                                               │
│ - hrm.* (Workers, Employees)                                │
│ - recruit.* (Requisition, Interview, Events)                │
│ - connect.* (Job Posting, Resume)                           │
│ - KPI.* (Goal Assignment)                                   │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│ VALIDATION                                                   │
│ - j_check_sum_data_staging.py (Row counts)                  │
│ - S3 Error Logs (xhrm/Error-File/)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## VI. API ENDPOINTS

| Endpoint | Purpose | Scripts |
|----------|---------|---------|
| `{TARGET_URL_API}/partner/mcrhrc/api/employee/create` | Create employee | j_import_all_candidate.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/userRole/assignRolesOfUser` | Assign roles | j_assign_role_for_user.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/userRole/addRolesOfUser` | Add roles | hrm_prod/staging_j_add_role_for_user.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/draftRequisition/create` | Create draft requisition | j_import_all_request.py |
| `{SRC_URL_API}/getEmployeeForA4B` | Get employee data | j_get_api_to_staging_employee.py |
| `{SRC_URL_API}/getWRExEmployee` | Get ex-employee data | j_get_api_to_staging_wr_ex_employee.py |
| `{SRC_URL_API}/getMasterDataForA4B?model={model}` | Get master data | hrm_staging_j_get_api_to_staging_data_upsert.py |

---

## VII. STAGING → TARGET MAPPING

### Candidate Domain
| Source Staging | Target Table |
|----------------|--------------|
| staging.hr_applicant | hrm.hrtb_worker |
| staging.vhr_certificate_info | hrm.hrtb_worker_qualification |
| staging.candidate_checkin | recruit.cstb_candidate_checkin |
| staging.vhr_candidate_contact | hrm.hrtb_worker_social |
| staging.hr_applicant_job_track_upsert | hrm.hrtb_worker_summary |
| staging.vhr_note | hrm.hrtb_worker_summary |
| staging.hr_applicant_skills_upsert | hrm.hrtb_worker_summary + hrtb_candidate |
| staging.vhr_working_background | hrm.hrtb_worker_record |
| staging.candidate_cv + S3 | hrm.hrtb_worker_attachment |
| staging.online_candidate_upsert | Function call |
| staging.online_candidate_cv | connect.cstb_candidate_resume |

### Employee Domain
| Source Staging | Target Table |
|----------------|--------------|
| staging.employee_staging_upsert | hrm.hrtb_employee |
| staging.wr_ex_employee_* | hrm.hrtb_wr_ex_employee |

### Requisition Domain
| Source Staging | Target Table |
|----------------|--------------|
| staging.hr_job | recruit.rstb_requisition |
| staging.hr_job_reason_emp_rel_upsert | recruit.rstb_requisition (for_employee) |
| staging.approval_history | recruit.rstb_odoo_approval_history |
| staging.job_applicant_history | recruit.rstb_odoo_job_approval_history |
| staging.stg_req_member_assignment | recruit.rstb_requisition_candidate |
| staging.hr_job_share_handles | KPI.KSTB_GOAL_ASSIGNMENT |

---

## VIII. DANH SÁCH ĐẦY ĐỦ FILES (30 files)

### Documentation Index & Summary (2 files)
1. `DATA_DICTIONARY_INDEX.md` - Mục lục 33+ tables
2. `TONG_KET_KET_QUA.md` - Tổng kết kết quả

### HRM Domain Data Dictionary (9 files)
3. `hrm_hrtb_worker.md`
4. `hrm_hrtb_worker_summary.md`
5. `hrm_hrtb_worker_qualification.md`
6. `hrm_hrtb_worker_record.md`
7. `hrm_hrtb_worker_social.md`
8. `hrm_hrtb_worker_attachment.md`
9. `hrm_hrtb_employee.md`
10. `hrm_hrtb_wr_ex_employee.md`
11. `hrm_hrtb_etl_key_student.md`

### Recruit Domain Data Dictionary (15 files)
12. `recruit_cstb_candidate_checkin.md`
13. `recruit_rstb_requisition.md`
14. `recruit_rstb_requisition_candidate.md`
15. `recruit_rstb_requisition_skill.md`
16. `recruit_rstb_assessment_interview.md`
17. `recruit_rstb_assessment_screening.md`
18. `recruit_rstb_odoo_approval_history.md`
19. `recruit_rstb_erp_payment.md`
20. `recruit_rstb_erp_payment_line.md`
21. `recruit_rstb_survey_result.md`
22. `recruit_pstb_event.md`
23. `recruit_pstb_student_program.md`
24. `recruit_pstb_event_field.md`
25. `recruit_gstb_event_gift.md`
26. `recruit_qstb_event_question.md`

### Connect Domain Data Dictionary (2 files)
27. `connect_cstb_posting.md`
28. `connect_cstb_candidate_resume.md`

### KPI Domain Data Dictionary (1 file)
29. `kpi_kstb_goal_assignment.md`

### Function Documentation (1 file)
30. `online_candidate_function.md`

---

*Tài liệu này tổng kết kết quả phân tích 46 scripts ETL và tạo 30 file data dictionary chi tiết cho 28+ tables.*
