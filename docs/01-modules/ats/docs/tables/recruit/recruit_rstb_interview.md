# recruit.rstb_interview

## Mục đích
Lưu trữ thông tin lịch sử phỏng vấn ứng viên, bao gồm thời gian, vòng phỏng vấn, người phỏng vấn, và kết quả phỏng vấn.

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| id | numeric | `recruit.rssq_interview_booking` | `nextval('recruit.rssq_interview_booking')` | ID tự tăng (sequence) cho mỗi buổi phỏng vấn |
| requisition_candidate_id | numeric | `staging.candidate_matching.id` | Trực tiếp | ID của ứng viên trong requisition (liên kết với rstb_requisition_candidate) |
| interview_round_id | numeric | `staging.candidate_matching.interview_round_id` | Trực tiếp | ID vòng phỏng vấn (Round 1, Round 2, Round 3, ...) |
| interview_date | date | `staging.candidate_matching.start_time` | Cast sang date type | Ngày diễn ra buổi phỏng vấn |
| interview_starttime | timestamptz | `staging.candidate_matching.start_time` | Cast sang timestamptz | Thời gian bắt đầu phỏng vấn |
| interview_endtime | timestamptz | `staging.candidate_matching.end_time` | Cast sang timestamptz | Thời gian kết thúc phỏng vấn |
| record_status | varchar | Default | Set default 'O' | Trạng thái record: 'O' = Active, 'C' = Closed |
| auth_status | varchar | Default | Set default 'A' | Trạng thái approval: 'A' = Approved, 'U' = Unapproved |
| maker_id | varchar | Default | Set default 'system_etl_upsert' | ID người tạo record (hệ thống ETL) |
| maker_date | timestamptz | `staging.candidate_matching.write_date` | Cast sang timestamptz | Ngày tạo record từ nguồn |
| update_date | timestamptz | `staging.candidate_matching.create_date` | Cast sang timestamptz | Ngày cập nhật record từ nguồn |
| create_date | timestamptz | `now() at time zone 'ICT'` | Current timestamp ICT | Timestamp khi insert vào HRM |
| tenant_code | varchar | `staging.candidate_matching.tenant_code` | Trực tiếp | Mã tenant/company (multi-tenant) |
| reporter_id | numeric | `hrm.hrtb_employee.id` | Lookup từ employee | ID của người báo cáo/phỏng vấn viên chính |
| reporter | jsonb | `hrm.hrtb_employee` | `jsonb_build_object('id', id, 'code', code, 'name', name, 'email', email)` | Thông tin JSON về reporter |
| status | varchar | `staging.candidate_matching.interview_status` | Trực tiếp | Trạng thái buổi phỏng vấn (Completed, Scheduled, Cancelled, ...) |

## Quy tắc nghiệp vụ quan trọng

### Unique Constraint
```sql
UNIQUE (requisition_candidate_id, interview_round_id, tenant_code)
```
Mỗi ứng viên chỉ có một record phỏng vấn cho mỗi vòng phỏng vấn trong cùng một tenant.

### ON CONFLICT Action
Khi có conflict (duplicate key), thực hiện UPDATE các fields:
- interview_date, interview_starttime, interview_endtime
- reporter_id, reporter, status
- update_date = current timestamp
- mod_no = mod_no + 1

### Vòng phỏng vấn chuẩn
| Code | Tên vòng |
|------|----------|
| ROU001 | Vòng 1 (Screening) |
| ROU002 | Vòng 2 (Technical) |
| ROU003 | Vòng 3 (Final/Manager) |

### Logic nghiệp vụ
1. **Lịch sử phỏng vấn**: Mỗi lần ứng viên tham gia phỏng vấn sẽ tạo một record mới
2. **Vòng phỏng vấn**: Theo dõi ứng viên đã qua những vòng nào
3. **Kết quả**: Trạng thái phỏng vấn giúp xác định ứng viên đạt hay không đạt
4. **Reporter**: Người phụ trách buổi phỏng vấn, có thể khác interviewer

## Script ETL
- **File:** `scripts_uat/j_import_all_matching_candidate.py`
- **Hàm:** `insert_interview()` (line 1839-1997)
- **Staging Source:** `staging.candidate_matching`

## Staging Table
Ngoài insert vào `recruit.rstb_interview`, script còn insert vào `staging.stg_interview` để lưu lịch sử chi tiết hơn với các fields:
- interviewer_id, interviewer_info
- interview_result (kết quả số)
- keep_in_view (flag theo dõi)

## Upsert Pattern
```sql
ON CONFLICT (requisition_candidate_id, interview_round_id, tenant_code)
DO UPDATE SET
    interview_date = EXCLUDED.interview_date,
    interview_starttime = EXCLUDED.interview_starttime,
    interview_endtime = EXCLUDED.interview_endtime,
    reporter_id = EXCLUDED.reporter_id,
    reporter = EXCLUDED.reporter,
    status = EXCLUDED.status,
    mod_no = recruit.rstb_interview.mod_no + 1
```
