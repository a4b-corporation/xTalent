# hrm.hrtb_candidate_recommender

## Mục đích
Lưu trữ thông tin người giới thiệu ứng viên (referral) cho hệ thống tuyển dụng, bao gồm thông tin về người giới thiệu, ứng viên được giới thiệu, và trạng thái thanh toán thưởng referral.

## Danh sách Fields

| Tên field | Kiểu dữ liệu | Extract | Transform | Mô tả nghiệp vụ |
|-----------|--------------|---------|-----------|-----------------|
| ref_id | numeric | `staging.vhr_erp_recommend_upsert.id` | Trực tiếp | ID tham chiếu từ hệ thống Odoo, dùng cho upsert logic |
| candidate_id | numeric | `hrm.hrtb_candidate.id` | Join với hrtb_candidate qua applicant_id (ref_id) | ID của ứng viên được giới thiệu trong hệ thống HRM |
| create_date | timestamptz | `staging.vhr_erp_recommend_upsert.create_date` | Trực tiếp | Ngày tạo record từ hệ thống nguồn |
| write_date | timestamptz | `staging.vhr_erp_recommend_upsert.write_date` | Trực tiếp | Ngày cập nhật record từ hệ thống nguồn |
| requisition_id | numeric | `recruit.rstb_requisition.id` | Join với rstb_requisition qua job_id (ref_id) | ID của vị trí tuyển dụng (requisition) |
| requisition_code | varchar | `recruit.rstb_requisition.code` | Trực tiếp sau khi join | Mã vị trí tuyển dụng |
| recommender_id | numeric | `hrm.hrtb_employee.id` | Join với hrtb_employee qua recommender_id (ref_id) | ID của nhân viên giới thiệu trong hệ thống HRM |
| recommender_email | varchar | `hrm.hrtb_employee.email` | Trực tiếp | Email của người giới thiệu |
| recommender_info | jsonb | `hrm.hrtb_employee` | `jsonb_build_object('id', id, 'code', code, 'name', name, 'email', email)` | Thông tin chi tiết người giới thiệu dưới dạng JSON |
| source_type | jsonb | `hrm.hrtb_candidate.source_type` | Convert sang JSON | Loại nguồn tuyển dụng (copy từ candidate) |
| recruit_source | jsonb | `hrm.hrtb_candidate.recruit_source` | Convert sang JSON | Nguồn tuyển dụng cụ thể (copy từ candidate) |
| source_type_id | numeric | `hrm.hrtb_candidate.source_type_id` | Trực tiếp | ID loại nguồn tuyển dụng |
| recruit_source_id | numeric | `hrm.hrtb_candidate.recruit_source_id` | Trực tiếp | ID nguồn tuyển dụng cụ thể |
| erp_duplicate | numeric | `staging.vhr_erp_recommend_upsert.erp_duplicate` | Cast boolean to numeric (0/1) | Flag đánh dấu record trùng lặp (1 = duplicate, bị skip) |
| erp_unpaid | numeric | `staging.vhr_erp_recommend_upsert.erp_unpaid` | Cast boolean to numeric (0/1) | Flag đánh dấu chưa thanh toán thưởng referral |
| apply_date | timestamptz | `staging.vhr_erp_recommend_upsert.apply_date` | Trực tiếp | Ngày ứng viên apply vào vị trí |
| erp_30 | numeric | `staging.vhr_erp_recommend_upsert.erp_30` | Cast boolean to numeric (0/1) | Flag đánh dấu ERP 30 ngày |
| is_erp_mail | numeric | `staging.vhr_erp_recommend_upsert.is_erp_mail` | Cast boolean to numeric (0/1) | Flag đánh dấu đã gửi mail ERP thông báo |
| state | varchar | `staging.vhr_erp_recommend_upsert.state` | Map: UNPAID → REJECT, PAID → APPROVE | Trạng thái thanh toán thưởng referral |
| note | varchar | `staging.vhr_erp_recommend_upsert.note` | Trực tiếp | Ghi chú về referral |
| tenant_code | varchar | `Parameter.P_TENANT_CODE` | Set từ parameter | Mã tenant/company (multi-tenant) |

## Quy tắc nghiệp vụ quan trọng

### State Mapping
| State (Odoo) | State (HRM) |
|--------------|-------------|
| UNPAID | REJECT |
| PAID | APPROVE |

### Điều kiện skip record
Record bị skip không insert nếu:
- job_id là NULL
- requisition_id là NULL
- candidate_id là NULL
- recommender_id là NULL
- erp_duplicate = 1 (record trùng lặp)

### Logic nghiệp vụ
1. **Referral Bonus**: Người giới thiệu thành công sẽ nhận thưởng khi ứng viên vượt qua thử việc
2. **Trạng thái thanh toán**: 
   - UNPAID (chưa thanh toán) → REJECT trong HRM
   - PAID (đã thanh toán) → APPROVE trong HRM
3. **Nguồn giới thiệu**: Thông tin source_type, recruit_source được copy từ candidate
4. **Multi-tenant**: Dữ liệu được phân tách theo tenant_code

## Script ETL
- **File:** `scripts_uat/j_import_all_candidate_recommender.py`
- **Function:** `hrfn_etl_insert_candidate_recommender` (stored function)
- **Staging Source:** `staging.vhr_erp_recommend_upsert`

## Upsert Pattern
Sử dụng stored function `hrfn_etl_insert_candidate_recommender` với 20 parameters để insert/update records.
