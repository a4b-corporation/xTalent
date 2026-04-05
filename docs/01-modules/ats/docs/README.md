# ETL DATA DICTIONARY - DIRECTORY

**Hệ thống:** ATS (Applicant Tracking System)
**Môi trường:** UAT
**Ngày cập nhật:** 2026-04-04
**Tổng số files:** 32 markdown files trong `tables/`

---

## 📚 CÁCH SỬ DỤNG THƯ MỤC NÀY

### 1. Bắt đầu từ đâu?
- **Mới tìm hiểu:** Đọc [DATA_DICTIONARY_INDEX.md](../DATA_DICTIONARY_INDEX.md) đầu tiên
- **Cần tổng quan:** Xem [TONG_KET_KET_QUA.md](../TONG_KET_KET_QUA.md)
- **Tìm table cụ thể:** Dùng danh sách bên dưới hoặc search theo tên table

### 2. Cấu trúc file naming
```
tables/<domain>/<schema>_<table_name>.md
```
Ví dụ: `tables/hrm/hrm_hrtb_worker.md` → table `hrm.hrtb_worker`

---

## 📁 DANH SÁCH FILES THEO DOMAIN

### HRM Domain (10 files)
| File | Table | Mô tả | Fields |
|------|-------|-------|--------|
| [hrm_hrtb_worker.md](tables/hrm/hrm_hrtb_worker.md) | hrm.hrtb_worker | Thông tin worker/candidate | 48 |
| [hrm_hrtb_worker_summary.md](tables/hrm/hrm_hrtb_worker_summary.md) | hrm.hrtb_worker_summary | Summary: notes, job tracks, skills | 17 |
| [hrm_hrtb_worker_qualification.md](tables/hrm/hrm_hrtb_worker_qualification.md) | hrm.hrtb_worker_qualification | Học vấn, chứng chỉ | 19 |
| [hrm_hrtb_worker_record.md](tables/hrm/hrm_hrtb_worker_record.md) | hrm.hrtb_worker_record | Quá trình làm việc | 23 |
| [hrm_hrtb_worker_social.md](tables/hrm/hrm_hrtb_worker_social.md) | hrm.hrtb_worker_social | Social media, liên lạc | 10 |
| [hrm_hrtb_worker_attachment.md](tables/hrm/hrm_hrtb_worker_attachment.md) | hrm.hrtb_worker_attachment | File đính kèm, CV | 15 |
| [hrm_hrtb_employee.md](tables/hrm/hrm_hrtb_employee.md) | hrm.hrtb_employee | Nhân viên chính thức | 34 |
| [hrm_hrtb_wr_ex_employee.md](tables/hrm/hrm_hrtb_wr_ex_employee.md) | hrm.hrtb_wr_ex_employee | Nhân viên nghỉ việc | 14 |
| [hrm_hrtb_etl_key_student.md](tables/hrm/hrm_hrtb_etl_key_student.md) | hrm.hrtb_etl_key_student | Sinh viên chủ chốt | 36 |
| [hrm_hrtb_candidate_recommender.md](tables/hrm/hrm_hrtb_candidate_recommender.md) | hrm.hrtb_candidate_recommender | Người giới thiệu ứng viên (referral) | 20 |

### RECRUIT DOMAIN (17 files)
| File | Table | Mô tả | Fields |
|------|-------|-------|--------|
| [recruit_cstb_candidate_checkin.md](tables/recruit/recruit_cstb_candidate_checkin.md) | recruit.cstb_candidate_checkin | Check-in sự kiện | 20 |
| [recruit_rstb_requisition.md](tables/recruit/recruit_rstb_requisition.md) | recruit.rstb_requisition | Yêu cầu tuyển dụng | 62 |
| [recruit_rstb_requisition_candidate.md](tables/recruit/recruit_rstb_requisition_candidate.md) | recruit.rstb_requisition_candidate | Ứng viên cho requisition | 16 |
| [recruit_rstb_requisition_skill.md](tables/recruit/recruit_rstb_requisition_skill.md) | recruit.rstb_requisition_skill | Kỹ năng yêu cầu | 7 |
| [recruit_rstb_assessment_interview.md](tables/recruit/recruit_rstb_assessment_interview.md) | recruit.rstb_assessment_interview | Đánh giá phỏng vấn | 17 |
| [recruit_rstb_assessment_screening.md](tables/recruit/recruit_rstb_assessment_screening.md) | recruit.rstb_assessment_screening | Đánh giá screening | 9 |
| [recruit_rstb_interview.md](tables/recruit/recruit_rstb_interview.md) | recruit.rstb_interview | Thông tin buổi phỏng vấn | 16 |
| [recruit_rstb_requisition_offer.md](tables/recruit/recruit_rstb_requisition_offer.md) | recruit.rstb_requisition_offer | Đề nghị tuyển dụng (Offer) | 67 |
| [recruit_rstb_odoo_approval_history.md](tables/recruit/recruit_rstb_odoo_approval_history.md) | recruit.rstb_odoo_approval_history | Lịch sử phê duyệt Odoo | 9 |
| [recruit_rstb_odoo_job_approval_history.md](tables/recruit/recruit_rstb_odoo_job_approval_history.md) | recruit.rstb_odoo_job_approval_history | Lịch sử phê duyệt applicant | 8 |
| [recruit_rstb_erp_payment.md](tables/recruit/recruit_rstb_erp_payment.md) | recruit.rstb_erp_payment | Thanh toán ERP bonus | 23 |
| [recruit_rstb_erp_payment_line.md](tables/recruit/recruit_rstb_erp_payment_line.md) | recruit.rstb_erp_payment_line | Chi tiết thanh toán ERP | 13 |
| [recruit_rstb_survey_result.md](tables/recruit/recruit_rstb_survey_result.md) | recruit.rstb_survey_result | Kết quả khảo sát | 13 |
| [recruit_pstb_event.md](tables/recruit/recruit_pstb_event.md) | recruit.pstb_event | Sự kiện tuyển dụng | 24 |
| [recruit_pstb_student_program.md](tables/recruit/recruit_pstb_student_program.md) | recruit.pstb_student_program | Chương trình sinh viên | 30 |
| [recruit_pstb_event_field.md](tables/recruit/recruit_pstb_event_field.md) | recruit.pstb_event_field | Trường sự kiện | 13 |
| [recruit_gstb_event_gift.md](tables/recruit/recruit_gstb_event_gift.md) | recruit.gstb_event_gift | Quà tặng sự kiện | 12 |
| [recruit_qstb_event_question.md](tables/recruit/recruit_qstb_event_question.md) | recruit.qstb_event_question | Câu hỏi sự kiện | 13 |

### CONNECT DOMAIN (2 files)
| File | Table | Mô tả | Fields |
|------|-------|-------|--------|
| [connect_cstb_posting.md](tables/connect/connect_cstb_posting.md) | connect.cstb_posting | Tin đăng tuyển dụng | 20 |
| [connect_cstb_candidate_resume.md](tables/connect/connect_cstb_candidate_resume.md) | connect.cstb_candidate_resume | CV/Resume ứng viên | 4 |

### KPI DOMAIN (1 file)
| File | Table | Mô tả | Fields |
|------|-------|-------|--------|
| [kpi_kstb_goal_assignment.md](tables/kpi/kpi_kstb_goal_assignment.md) | KPI.KSTB_GOAL_ASSIGNMENT | Phân công mục tiêu | 13 |

### FUNCTION DOCUMENTATION (1 file - vẫn ở docs/)
| File | Mô tả |
|------|-------|
| [online_candidate_function.md](online_candidate_function.md) | Function `staging.csfn_etl_upsert_online_candidate` (27 parameters) |

### INDEX & SUMMARY (3 files - vẫn ở docs/)
| File | Mô tả |
|------|-------|
| [DATA_DICTIONARY_INDEX.md](DATA_DICTIONARY_INDEX.md) | Mục lục đầy đủ 33+ tables + Data Flow + API Endpoints |
| [TONG_KET_KET_QUA.md](TONG_KET_KET_QUA.md) | Tổng kết kết quả phân tích 46 scripts ETL |
| [README.md](README.md) | File hướng dẫn này |

---

## 🔍 TÌM KIẾM NHANH

### Theo tên table
```bash
# Ví dụ tìm table worker
find docs/tables -name "*worker*.md"
```

### Theo field (trong markdown tables)
```bash
# Ví dụ tìm field "tenant_code"
grep -l "tenant_code" docs/tables/*/*.md
```

### Theo script ETL
```bash
# Ví dụ tìm scripts liên quan candidate
grep -l "j_import_all_candidate" docs/tables/*/*.md
```

---

## 📊 THỐNG KÊ

| Domain | Số tables | Số fields (tổng) |
|--------|-----------|------------------|
| HRM | 10 | ~292 |
| Recruit | 17 | ~395 |
| Connect | 2 | ~24 |
| KPI | 1 | ~13 |
| **TỔNG** | **30** | **~724** |

---

## 📋 ĐỊNH DẠNG MỖI FILE

Mỗi file data dictionary bao gồm:

1. **Header** - Tên table, mô tả, nguồn dữ liệu, scripts ETL
2. **Danh sách Fields** (markdown table):
   | Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
3. **Quy tắc nghiệp vụ** - Business logic quan trọng

---

## 🔗 RELATED DOCUMENTATION

- **Scripts ETL:** `/scripts_uat/*.py`
- **Staging Tables:** Database schema `staging`
- **Target Tables:** Database schemas `hrm`, `recruit`, `connect`, `kpi`

---

*Thư mục này chứa 32 file data dictionary được tạo tự động từ phân tích 46 scripts ETL. Các file được tổ chức theo cấu trúc `tables/<domain>/<table>.md`*
