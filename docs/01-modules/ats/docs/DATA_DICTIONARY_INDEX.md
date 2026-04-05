# DATA DICTIONARY - ETL TARGET TABLES

**Hệ thống:** ATS (Applicant Tracking System)
**Môi trường:** UAT
**Ngày cập nhật:** 2026-04-04

---

## MỤC LỤC

### A. HRM DOMAIN (Human Resource Management)

| STT | Table | Mô tả | Script ETL | File chi tiết |
|-----|-------|-------|------------|---------------|
| 1 | `hrm.hrtb_worker` | Thông tin worker/candidate chính | j_import_all_candidate.py | [hrm_hrtb_worker.md](tables/hrm/hrm_hrtb_worker.md) |
| 2 | `hrm.hrtb_worker_summary` | Tổng hợp thông tin worker (note, job track, skill) | j_import_all_candidate_note.py, j_import_all_candidate_job_track.py, j_import_all_candidate_skill.py | [hrm_hrtb_worker_summary.md](tables/hrm/hrm_hrtb_worker_summary.md) |
| 3 | `hrm.hrtb_worker_qualification` | Trình độ học vấn, chứng chỉ | j_import_all_candidate_certificate_info.py | [hrm_hrtb_worker_qualification.md](tables/hrm/hrm_hrtb_worker_qualification.md) |
| 4 | `hrm.hrtb_worker_record` | Quá trình làm việc/kinh nghiệm | j_import_all_candidate_working_background.py | [hrm_hrtb_worker_record.md](tables/hrm/hrm_hrtb_worker_record.md) |
| 5 | `hrm.hrtb_worker_social` | Thông tin mạng xã hội, liên lạc | j_import_all_candidate_contact.py | [hrm_hrtb_worker_social.md](tables/hrm/hrm_hrtb_worker_social.md) |
| 6 | `hrm.hrtb_worker_attachment` | File đính kèm (CV, giấy tờ) | j_import_candidate_file_cv.py | [hrm_hrtb_worker_attachment.md](tables/hrm/hrm_hrtb_worker_attachment.md) |
| 7 | `hrm.hrtb_employee` | Thông tin nhân viên chính thức | j_import_all_employee.py | [hrm_hrtb_employee.md](tables/hrm/hrm_hrtb_employee.md) |
| 8 | `hrm.hrtb_wr_ex_employee` | Nhân viên nghỉ việc | j_import_wr_ex_employee.py | [hrm_hrtb_wr_ex_employee.md](tables/hrm/hrm_hrtb_wr_ex_employee.md) |
| 9 | `hrm.hrtb_etl_key_student` | Sinh viên chủ chốt | j_import_all_program_event.py, j_import_key_student.py | [hrm_hrtb_etl_key_student.md](tables/hrm/hrm_hrtb_etl_key_student.md) |
| 10 | `hrm.hrtb_candidate_recommender` | Người giới thiệu ứng viên (referral) | j_import_all_candidate_recommender.py | [hrm_hrtb_candidate_recommender.md](tables/hrm/hrm_hrtb_candidate_recommender.md) |

### B. RECRUIT DOMAIN (Recruitment)

| STT | Table | Mô tả | Script ETL | File chi tiết |
|-----|-------|-------|------------|---------------|
| 10 | `recruit.cstb_candidate_checkin` | Check-in ứng viên tham gia sự kiện | j_import_all_candidate_checkin.py | [recruit_cstb_candidate_checkin.md](tables/recruit/recruit_cstb_candidate_checkin.md) |
| 11 | `recruit.rstb_assessment_interview` | Đánh giá phỏng vấn | j_import_all_interview_note.py, j_import_all_interviewers.py | [recruit_rstb_assessment_interview.md](tables/recruit/recruit_rstb_assessment_interview.md) |
| 12 | `recruit.rstb_assessment_screening` | Đánh giá screening | j_import_all_interview_note.py | [recruit_rstb_assessment_screening.md](tables/recruit/recruit_rstb_assessment_screening.md) |
| 13 | `recruit.rstb_interview` | Thông tin buổi phỏng vấn | j_import_all_matching_candidate.py | [recruit_rstb_interview.md](tables/recruit/recruit_rstb_interview.md) |
| 13.5 | `recruit.rstb_requisition_offer` | Đề nghị tuyển dụng (Offer) | j_import_all_matching_candidate.py | [recruit_rstb_requisition_offer.md](tables/recruit/recruit_rstb_requisition_offer.md) |
| 14 | `recruit.rstb_requisition` | Yêu cầu tuyển dụng | j_import_all_request.py | [recruit_rstb_requisition.md](tables/recruit/recruit_rstb_requisition.md) |
| 15 | `recruit.rstb_requisition_candidate` | Ứng viên cho requisition | j_import_all_history_approval.py, j_import_update_member_assignment.py | [recruit_rstb_requisition_candidate.md](tables/recruit/recruit_rstb_requisition_candidate.md) |
| 16 | `recruit.rstb_odoo_approval_history` | Lịch sử phê duyệt | j_import_all_history_approval.py | [recruit_rstb_odoo_approval_history.md](tables/recruit/recruit_rstb_odoo_approval_history.md) |
| 17 | `recruit.rstb_odoo_job_approval_history` | Lịch sử phê duyệt applicant | j_import_all_history_approval.py | [recruit_rstb_odoo_job_approval_history.md](tables/recruit/recruit_rstb_odoo_job_approval_history.md) |
| 18 | `recruit.rstb_survey_result` | Kết quả khảo sát | j_import_all_survey_result.py | [recruit_rstb_survey_result.md](tables/recruit/recruit_rstb_survey_result.md) |
| 19 | `recruit.rstb_erp_payment` | Thanh toán ERP bonus | j_import_all_erp_payment.py | [recruit_rstb_erp_payment.md](tables/recruit/recruit_rstb_erp_payment.md) |
| 20 | `recruit.rstb_erp_payment_line` | Chi tiết thanh toán ERP | j_import_all_erp_payment_line.py | [recruit_rstb_erp_payment_line.md](tables/recruit/recruit_rstb_erp_payment_line.md) |
| 21 | `recruit.rstb_requisition_skill` | Kỹ năng yêu cầu | j_import_all_requisition_skill.py | [recruit_rstb_requisition_skill.md](tables/recruit/recruit_rstb_requisition_skill.md) |
| 22 | `recruit.pstb_event` | Sự kiện tuyển dụng | j_import_all_program_event_online.py | [recruit_pstb_event.md](tables/recruit/recruit_pstb_event.md) |
| 23 | `recruit.pstb_student_program` | Chương trình sinh viên | j_import_all_student_program.py | [recruit_pstb_student_program.md](tables/recruit/recruit_pstb_student_program.md) |
| 24 | `recruit.pstb_event_field` | Trường sự kiện | j_import_all_event_field.py | [recruit_pstb_event_field.md](tables/recruit/recruit_pstb_event_field.md) |
| 25 | `recruit.gstb_event_gift` | Quà tặng sự kiện | j_import_all_event_gift.py | [recruit_gstb_event_gift.md](tables/recruit/recruit_gstb_event_gift.md) |
| 26 | `recruit.qstb_event_question` | Câu hỏi sự kiện | j_import_all_event_question.py | [recruit_qstb_event_question.md](tables/recruit/recruit_qstb_event_question.md) |
| 27 | `recruit.tm_rrm` | RRM (Recruitment Relationship Manager) | hrm_staging_j_add_role_for_user.py | - |
| 28 | `recruit.tm_rrmbu` | RRM Business Unit | hrm_staging_j_add_role_for_user.py | - |
| 29 | `recruit.tm_recruiter` | Recruiter | hrm_staging_j_add_role_for_user.py | - |
| 30 | `recruit.tm_recruiterbu` | Recruiter Business Unit | hrm_staging_j_add_role_for_user.py | - |

### C. CONNECT DOMAIN (Job Posting)

| STT | Table | Mô tả | Script ETL | File chi tiết |
|-----|-------|-------|------------|---------------|
| 31 | `connect.cstb_posting` | Tin đăng tuyển dụng | j_import_all_posting_job.py | [connect_cstb_posting.md](tables/connect/connect_cstb_posting.md) |
| 32 | `connect.cstb_candidate_resume` | CV/Resume ứng viên | j_import_online_candidate_file_cv.py | [connect_cstb_candidate_resume.md](tables/connect/connect_cstb_candidate_resume.md) |

### D. KPI DOMAIN (Goal Management)

| STT | Table | Mô tả | Script ETL | File chi tiết |
|-----|-------|-------|------------|---------------|
| 33 | `KPI.KSTB_GOAL_ASSIGNMENT` | Phân công mục tiêu | j_import_add_share_handles.py | [kpi_kstb_goal_assignment.md](tables/kpi/kpi_kstb_goal_assignment.md) |

**Tổng cộng:** 32 tables đã document (10 HRM + 17 Recruit + 2 Connect + 1 KPI + 2 Staging mapping)

### E. STAGING DOMAIN (Temporary Tables)

| STT | Table | Mô tả | Script ETL |
|-----|-------|-------|------------|
| 34 | `staging.employee_staging_upsert` | Employee staging | j_get_api_to_staging_employee.py |
| 35 | `staging.wr_ex_employee_daily/hourly/upsert` | Ex-employee staging | j_get_api_to_staging_wr_ex_employee.py |
| 36 | `staging.{master_data_tables}` | Master data staging | hrm_staging_j_get_api_to_staging_data_upsert.py |
| 37 | `staging.{s3_data_tables}_upsert` | Data từ S3/SharePoint | hrm_staging_j_get_api_to_staging_data_upsert.py |
| 38 | `staging.skill_mapping_upsert` | Mapping kỹ năng | j_import_mapping_data.py |
| 39 | `staging.source_mapping_upsert` | Mapping nguồn tuyển dụng | j_import_mapping_data.py |

---

## SƠ ĐỒ DATA FLOW

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │   Odoo API  │  │ SharePoint  │  │   S3 Files  │  │ Excel/CSV  │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └─────┬──────┘ │
└─────────┼────────────────┼────────────────┼────────────────┼────────┘
          │                │                │                │
          ▼                ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      STAGING SCHEMA                                  │
│  - staging.employee_staging_upsert                                   │
│  - staging.wr_ex_employee_*                                          │
│  - staging.hr_applicant_upsert                                       │
│  - staging.{master_data}_upsert                                      │
│  - staging.{mapping}_upsert                                          │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    TRANSFORMATION (ETL)                              │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  Lookup & Mapping:                                             │ │
│  │  - hrm.hrtb_employee, hrm.hrtb_unit, hrm.tatm_*                │ │
│  │  - recruit.rstb_*, pstb_*, gstb_*, qstb_*                      │ │
│  │                                                                │ │
│  │  Transform:                                                    │ │
│  │  - Boolean casting (true/false → 1/0)                          │ │
│  │  - Date parsing (pd.to_datetime)                               │ │
│  │  - JSON construction (multi-language)                          │ │
│  │  - Full-text search string building                            │ │
│  │  - Code deduplication (_1, _2, _3 suffix)                      │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      TARGET SCHEMAS                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │  hrm.*      │  │ recruit.*   │  │ connect.*   │  │  KPI.*     │ │
│  │  (Workers)  │  │ (Recruit)   │  │ (Posting)   │  │ (Goals)    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       VALIDATION                                     │
│  - j_check_sum_data_staging.py (Row count comparison)               │
│  - S3 Error Logs (xhrm/Error-File/)                                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## COMMON PATTERNS

### 1. Boolean Casting
```python
# true/false/yes/no/t/f/1/0 → 1/0
true_values = ['true', 't', 'yes', 'y', '1']
df['flag'] = df['source_flag'].astype(str).str.lower().isin(true_values).astype(int)
```

### 2. JSON Construction (Multi-language)
```python
# Vietnamese + English
df['name_info'] = df.apply(lambda x: json.dumps({
    'vi': x.get('name_vi', ''),
    'en': x.get('name_en', '')
}), axis=1)
```

### 3. Lookup Pattern
```python
# Merge với reference table
df = df.merge(
    ref_table[['ref_id', 'id', 'code', 'name']],
    left_on='source_id',
    right_on='ref_id',
    how='left'
)
df['target_id'] = df['id']
df['target_info'] = df.apply(lambda x: json.dumps({
    'id': x['id'], 'code': x['code'], 'name': x['name']
}), axis=1)
```

### 4. Batch Processing
```python
# execute_batch với page_size=100
from psycopg2.extras import execute_batch
execute_batch(cur, sql, values, page_size=100)
```

### 5. Upsert Pattern (ON CONFLICT)
```sql
INSERT INTO target (key, field1, field2)
VALUES (%s, %s, %s)
ON CONFLICT (key) DO UPDATE SET
    field1 = EXCLUDED.field1,
    field2 = EXCLUDED.field2,
    update_date = NOW(),
    mod_no = target.mod_no + 1
```

### 6. MERGE Statement (PostgreSQL 15+)
```sql
MERGE INTO target t
USING source s
ON t.ref_id = s.ref_id
WHEN MATCHED THEN UPDATE SET ...
WHEN NOT MATCHED THEN INSERT (...) VALUES (...);
```

### 7. Full-text Search String
```python
# Build FTS string từ multiple fields
df['fts_string'] = (
    df['code'].fillna('') + ' ' +
    df['name'].fillna('') + ' ' +
    df['email'].fillna('') + ' ' +
    df['mobile'].fillna('')
).str.lower().str.strip()
```

---

## STAGING → TARGET MAPPING

### Candidate Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.hr_applicant` | `hrm.hrtb_worker` | j_import_all_candidate.py |
| `staging.vhr_certificate_info` | `hrm.hrtb_worker_qualification` | j_import_all_candidate_certificate_info.py |
| `staging.candidate_checkin` | `recruit.cstb_candidate_checkin` | j_import_all_candidate_checkin.py |
| `staging.vhr_candidate_contact` | `hrm.hrtb_worker_social` | j_import_all_candidate_contact.py |
| `staging.hr_applicant_job_track_upsert` | `hrm.hrtb_worker_summary` | j_import_all_candidate_job_track.py |
| `staging.vhr_note` | `hrm.hrtb_worker_summary` | j_import_all_candidate_note.py |
| `staging.vhr_erp_recommend_upsert` | Function call | j_import_all_candidate_recommender.py |
| `staging.hr_applicant_skills_upsert` | `hrm.hrtb_worker_summary` + `hrtb_candidate` | j_import_all_candidate_skill.py |
| `staging.vhr_working_background` | `hrm.hrtb_worker_record` | j_import_all_candidate_working_background.py |
| `staging.candidate_cv` + S3 | `hrm.hrtb_worker_attachment` | j_import_candidate_file_cv.py |
| `staging.online_candidate_upsert` | Function call | j_import_all_online_candidate.py |
| `staging.online_candidate_cv_upsert` | `connect.cstb_candidate_resume` | j_import_online_candidate_file_cv.py |

### Employee Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.employee_staging_upsert` | `hrm.hrtb_employee` | j_import_all_employee.py |
| `staging.wr_ex_employee_*` | `hrm.hrtb_wr_ex_employee` | j_import_wr_ex_employee.py |

### Requisition Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.hr_job` | `recruit.rstb_requisition` | j_import_all_request.py |
| `staging.hr_job_reason_emp_rel_upsert` | `recruit.rstb_requisition` (for_employee) | j_update_all_request_for_emp.py |
| `staging.approval_history` | `recruit.rstb_odoo_approval_history` | j_import_all_history_approval.py |
| `staging.job_applicant_history` | `recruit.rstb_odoo_job_approval_history` | j_import_all_history_approval.py |
| `staging.stg_req_member_assignment` | `recruit.rstb_requisition_candidate` | j_import_update_member_assignment.py |
| `staging.hr_job_share_handles` | `KPI.KSTB_GOAL_ASSIGNMENT` | j_import_add_share_handles.py |

### Interview Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.vhr_interview_round_evaluation_upsert` | `recruit.rstb_assessment_interview/screening` | j_import_all_interview_note.py |
| `staging.{interviewer_rel}_upsert` | `recruit.rstb_assessment_interview` | j_import_all_interviewers.py |
| `staging.stg_interview` | `recruit.rstb_assessment_interview` | j_update_all_interview_result.py |

### Job Posting Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.hr_job_post_job_mapping_upsert` | `connect.cstb_posting` | j_import_all_posting_job.py |
| `staging.job_skill_requirement_upsert` | Function call | j_import_all_requisition_skill.py |

### Event/Program Domain
| Staging Table | Target Table | Script |
|---------------|--------------|--------|
| `staging.key_student` | `hrm.hrtb_etl_key_student` | j_import_all_program_event.py, j_import_key_student.py |
| `staging.program_events_upsert` | Function call | j_import_all_program_event_online.py |
| `staging.student_program_upsert` | Function call | j_import_all_student_program.py |
| `staging.vhr_recruitment_temp_survey_upsert` | `recruit.rstb_survey_result` | j_import_all_survey_result.py |
| `staging.event_field` | `recruit.pstb_event_field` | j_import_all_event_field.py |
| `staging.vhr_program_event_gift_upsert` | `recruit.gstb_event_gift` | j_import_all_event_gift.py |
| `staging.vhr_program_question_upsert` | `recruit.qstb_event_question` | j_import_all_event_question.py |
| `staging.vhr_erp_bonus_payment_upsert` | `recruit.rstb_erp_payment` | j_import_all_erp_payment.py |
| `staging.vhr_erp_bonus_payment_line_upsert` | `recruit.rstb_erp_payment_line` | j_import_all_erp_payment_line.py |

---

## API ENDPOINTS

| Endpoint | Mục đích | Script |
|----------|----------|--------|
| `{TARGET_URL_API}/partner/mcrhrc/api/employee/create` | Tạo employee | j_import_all_candidate.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/userRole/assignRolesOfUser` | Gán role cho user | j_assign_role_for_user.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/userRole/addRolesOfUser` | Thêm role cho user | hrm_prod_j_add_role_for_user.py |
| `{TARGET_URL_API}/partner/xpsecmt/api/draftRequisition/create` | Tạo draft requisition | j_import_all_request.py |
| `{SRC_URL_API}/getEmployeeForA4B` | Lấy employee data | j_get_api_to_staging_employee.py |
| `{SRC_URL_API}/getWRExEmployee` | Lấy ex-employee data | j_get_api_to_staging_wr_ex_employee.py |
| `{SRC_URL_API}/getMasterDataForA4B?model={model}` | Lấy master data | hrm_staging_j_get_api_to_staging_data_upsert.py |

---

## THAM KHẢO

### File Documentation Chi Tiết
- [hrm_hrtb_worker.md](hrm_hrtb_worker.md) - Worker thông tin chính
- [hrm_hrtb_worker_summary.md](hrm_hrtb_worker_summary.md) - Worker summary
- [hrm_hrtb_employee.md](hrm_hrtb_employee.md) - Employee chính thức
- [recruit_rstb_requisition.md](recruit_rstb_requisition.md) - Requisition
- [connect_cstb_posting.md](connect_cstb_posting.md) - Job posting

### Scripts ETL Chính
- `scripts_uat/j_import_all_candidate.py` - Import candidate
- `scripts_uat/j_import_all_employee.py` - Import employee
- `scripts_uat/j_import_all_request.py` - Import requisition
- `scripts_uat/j_get_api_to_staging_data.py` - Lấy data từ API/S3

---

*Tài liệu này được tạo tự động từ phân tích ETL scripts. Để biết chi tiết từng field, xem các file markdown riêng trong thư mục docs/*
