# Core HR - Consolidated API Catalog

> **Module**: Core HR (CO)  
> **Version**: 2.0.0 - Atomic API Design  
> **Status**: Draft  
> **Last Updated**: 2026-01-30  
> **Design Principle**: Dynamic Query/Filter in Payload - Minimize Endpoints

---

## Design Philosophy

### Atomic API Design

Tài liệu này áp dụng nguyên tắc **Atomic API** - mỗi endpoint hỗ trợ query/filter động trong payload thay vì tạo nhiều endpoints riêng biệt.

| Pattern | Traditional | Atomic |
|---------|-------------|--------|
| **Query by Owner** | `GET /query/by-owner/{id}` | `POST /list` với `{ filters: { ownerId: "..." } }` |
| **Query by Status** | `GET /query/by-status/{status}` | `POST /list` với `{ filters: { status: "ACTIVE" } }` |
| **Query by Date** | `GET /query/by-date?from=...` | `POST /list` với `{ filters: { dateRange: {...} } }` |

### API Types

| Type | Description | Examples |
|------|-------------|----------|
| **CRUD** | Thao tác dữ liệu chuẩn | create, get, list, update, delete |
| **BUSINESS_ACTION** | Thay đổi trạng thái, workflow | hire, terminate, approve, sign |

### Standard CRUD Pattern (Mỗi Entity)

| Function | Description | Notes |
|----------|-------------|-------|
| `create` | Tạo mới record | Input: entity data |
| `get` | Lấy theo ID | Input: id |
| `list` | Query động với filters | Input: filters, pagination, sort |
| `update` | Cập nhật một phần | Input: id, partial data |
| `delete` | Soft delete | Input: id |

---

## Entity Summary

| # | Domain | Entity | VN Name | APIs |
|---|--------|--------|---------|------|
| 1 | Person Identity | Worker | Người lao động | 9 |
| 2 | Employment | Employee | Nhân viên | 15 |
| 3 | Employment | WorkRelationship | Quan hệ lao động | 12 |
| 4 | Employment | Assignment | Bố trí công việc | 14 |
| 5 | Employment | Contract | Hợp đồng lao động | 12 |
| 6 | Employment | ContractTemplate | Mẫu hợp đồng | 7 |
| 7 | Compensation | CompensationBasis | Mức lương hiệu lực | 13 |
| 8 | Job Architecture | Job | Vị trí công việc | 9 |
| 9 | Job Architecture | JobProfile | Hồ sơ vị trí | 8 |
| 10 | Job Architecture | JobLevel | Cấp bậc | 6 |
| 11 | Job Architecture | JobTaxonomy | Phân loại công việc | 10 |
| 12 | Job Architecture | TaxonomyTree | Cây phân loại | 8 |
| 13 | Job Architecture | JobTaxonomyMap | Ánh xạ Job-Taxonomy | 6 |
| 14 | Job Architecture | TaxonomyXMap | Ánh xạ chéo Taxonomy | 6 |
| 15 | Job Architecture | JobProfileSkill | Yêu cầu kỹ năng | 6 |
| 16 | Location | Address | Địa chỉ | 8 |
| 17 | Location | AdminArea | Đơn vị hành chính | 9 |
| 18 | Location | Place | Địa điểm (tòa nhà) | 8 |
| 19 | Location | Location | Không gian (phòng/tầng) | 9 |
| 20 | Location | WorkLocation | Địa điểm làm việc HR | 9 |
| 21 | Organization | LegalEntity | Pháp nhân | 12 |
| 22 | Organization | BusinessUnit | Đơn vị tổ chức | 13 |
| 23 | Organization | LegalRepresentative | Người đại diện pháp luật | 8 |
| 24 | Person Data | BankAccount | Tài khoản ngân hàng | 8 |
| 25 | Person Data | Contact | Thông tin liên hệ | 7 |
| 26 | Person Data | Document | Tài liệu/Giấy tờ | 10 |
| 27 | Person Data | WorkerQualification | Bằng cấp/Chứng chỉ | 8 |
| 28 | Person Data | WorkerRelationship | Quan hệ gia đình | 9 |
| 29 | Position | Position | Vị trí tổ chức | 12 |
| 30 | Skills | Skill | Kỹ năng | 9 |
| 31 | Skills | SkillCategory | Danh mục kỹ năng | 7 |
| 32 | Skills | Competency | Năng lực | 9 |
| 33 | Skills | CompetencyCategory | Danh mục năng lực | 7 |

**Tổng cộng: 33 Entities, ~290 APIs**

---

## 1. Person Identity Domain

### 1.1 Worker (Người lao động)

> Base entity cho tất cả người có quan hệ với tổ chức

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `worker.create` | Tạo worker mới | Đăng ký người lao động vào hệ thống | CRUD |
| 2 | `worker.get` | Lấy thông tin theo ID | Xem chi tiết hồ sơ người lao động | CRUD |
| 3 | `worker.list` | Query động với filters | Tìm kiếm, lọc danh sách theo tiêu chí | CRUD |
| 4 | `worker.update` | Cập nhật thông tin | Sửa đổi hồ sơ cá nhân | CRUD |
| 5 | `worker.delete` | Xóa mềm | Vô hiệu hóa hồ sơ (không xóa vật lý) | CRUD |
| 6 | `worker.merge` | Gộp hồ sơ trùng | Xử lý trường hợp 1 người có 2 hồ sơ | BUSINESS_ACTION |
| 7 | `worker.updateLegalName` | Đổi tên pháp lý | Xử lý thay đổi tên theo pháp luật | BUSINESS_ACTION |
| 8 | `worker.recordDeceased` | Ghi nhận qua đời | Cập nhật trạng thái khi NLĐ mất | BUSINESS_ACTION |
| 9 | `worker.anonymize` | Ẩn danh hóa (GDPR) | Xóa PII theo yêu cầu quyền riêng tư | BUSINESS_ACTION |

---

## 2. Employment Domain

### 2.1 Employee (Nhân viên)

> Quan hệ nhân viên với pháp nhân cụ thể

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `employee.create` | Tạo nhân viên | Đăng ký nhân viên mới (thường qua hire) | CRUD |
| 2 | `employee.get` | Lấy thông tin | Xem chi tiết hồ sơ nhân viên | CRUD |
| 3 | `employee.list` | Query động | Tìm kiếm nhân viên theo tiêu chí | CRUD |
| 4 | `employee.update` | Cập nhật | Sửa đổi thông tin nhân viên | CRUD |
| 5 | `employee.delete` | Xóa mềm | Vô hiệu hóa hồ sơ | CRUD |
| 6 | `employee.hire` | Tuyển dụng | Quy trình onboarding (tạo WR + Assignment) | BUSINESS_ACTION |
| 7 | `employee.terminate` | Chấm dứt HĐLĐ | Quy trình offboarding đầy đủ | BUSINESS_ACTION |
| 8 | `employee.suspend` | Đình chỉ công tác | Tạm ngưng làm việc (kỷ luật) | BUSINESS_ACTION |
| 9 | `employee.reactivate` | Kích hoạt lại | Phục hồi sau đình chỉ | BUSINESS_ACTION |
| 10 | `employee.startLeave` | Bắt đầu nghỉ dài hạn | Nghỉ không lương, thai sản, ốm đau | BUSINESS_ACTION |
| 11 | `employee.endLeave` | Kết thúc nghỉ phép | Quay lại làm việc sau nghỉ dài | BUSINESS_ACTION |
| 12 | `employee.retire` | Nghỉ hưu | Xử lý quy trình nghỉ hưu | BUSINESS_ACTION |
| 13 | `employee.transferLegalEntity` | Chuyển pháp nhân | Điều chuyển sang công ty khác trong group | BUSINESS_ACTION |
| 14 | `employee.changeManager` | Đổi quản lý | Thay đổi cấp trên trực tiếp | BUSINESS_ACTION |
| 15 | `employee.rehire` | Tái tuyển dụng | Tuyển lại nhân viên cũ | BUSINESS_ACTION |

### 2.2 WorkRelationship (Quan hệ lao động)

> Container cho legal engagement - quản lý hire/terminate

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `workRelationship.create` | Tạo quan hệ lao động | Thiết lập mối quan hệ pháp lý | CRUD |
| 2 | `workRelationship.get` | Lấy thông tin | Xem chi tiết quan hệ lao động | CRUD |
| 3 | `workRelationship.list` | Query động | Lọc theo tiêu chí (status, type, date) | CRUD |
| 4 | `workRelationship.update` | Cập nhật | Sửa đổi thông tin | CRUD |
| 5 | `workRelationship.delete` | Xóa mềm | Vô hiệu hóa (hiếm khi dùng) | CRUD |
| 6 | `workRelationship.activate` | Kích hoạt | Bắt đầu quan hệ lao động (ngày vào làm) | BUSINESS_ACTION |
| 7 | `workRelationship.terminate` | Chấm dứt | Kết thúc quan hệ lao động | BUSINESS_ACTION |
| 8 | `workRelationship.cancelHire` | Hủy tuyển dụng | Hủy trước ngày vào làm | BUSINESS_ACTION |
| 9 | `workRelationship.completeProbation` | Hoàn thành thử việc | Kết thúc thử việc (PASS/FAIL) | BUSINESS_ACTION |
| 10 | `workRelationship.extendProbation` | Gia hạn thử việc | Kéo dài thời gian thử việc | BUSINESS_ACTION |
| 11 | `workRelationship.convertType` | Chuyển đổi loại NLĐ | Employee ↔ Contractor | BUSINESS_ACTION |
| 12 | `workRelationship.closeSocialInsurance` | Chốt sổ BHXH | VN: Đóng sổ bảo hiểm khi nghỉ việc | BUSINESS_ACTION |

### 2.3 Assignment (Bố trí công việc)

> Where employee sits - Job placement, reporting line

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `assignment.create` | Tạo bố trí | Gán nhân viên vào vị trí/phòng ban | CRUD |
| 2 | `assignment.get` | Lấy thông tin | Xem chi tiết bố trí hiện tại | CRUD |
| 3 | `assignment.list` | Query động | Lọc theo BU, Position, Manager, Date | CRUD |
| 4 | `assignment.update` | Cập nhật | Sửa đổi thông tin bố trí | CRUD |
| 5 | `assignment.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `assignment.promote` | Thăng chức | Nâng cấp Job/Grade | BUSINESS_ACTION |
| 7 | `assignment.demote` | Giáng chức | Hạ cấp Job/Grade | BUSINESS_ACTION |
| 8 | `assignment.transfer` | Điều chuyển | Chuyển phòng ban/địa điểm | BUSINESS_ACTION |
| 9 | `assignment.changePosition` | Đổi vị trí | Thay đổi Position (cùng Job) | BUSINESS_ACTION |
| 10 | `assignment.changeJob` | Đổi công việc | Lateral move - đổi Job | BUSINESS_ACTION |
| 11 | `assignment.changeManager` | Đổi quản lý | Thay đổi cấp trên trực tiếp | BUSINESS_ACTION |
| 12 | `assignment.changeFTE` | Đổi FTE | Thay đổi tỷ lệ làm việc | BUSINESS_ACTION |
| 13 | `assignment.makePrimary` | Đặt làm chính | Multi-job: Đặt assignment chính | BUSINESS_ACTION |
| 14 | `assignment.terminate` | Kết thúc | Chấm dứt bố trí | BUSINESS_ACTION |

### 2.4 Contract (Hợp đồng lao động)

> Legal contract management with lifecycle

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `contract.create` | Tạo hợp đồng | Soạn HĐLĐ mới từ template | CRUD |
| 2 | `contract.get` | Lấy thông tin | Xem chi tiết hợp đồng | CRUD |
| 3 | `contract.list` | Query động | Lọc theo status, type, expire date | CRUD |
| 4 | `contract.update` | Cập nhật | Sửa đổi (chỉ draft) | CRUD |
| 5 | `contract.delete` | Xóa mềm | Hủy draft | CRUD |
| 6 | `contract.submitForSignature` | Gửi ký | Gửi HĐ cho nhân viên ký | BUSINESS_ACTION |
| 7 | `contract.sign` | Ký hợp đồng | Ghi nhận chữ ký | BUSINESS_ACTION |
| 8 | `contract.activate` | Kích hoạt | Cho HĐ có hiệu lực | BUSINESS_ACTION |
| 9 | `contract.renew` | Gia hạn | Tạo HĐ mới từ HĐ cũ | BUSINESS_ACTION |
| 10 | `contract.terminate` | Chấm dứt sớm | Kết thúc HĐ trước hạn | BUSINESS_ACTION |
| 11 | `contract.amend` | Sửa đổi/Phụ lục | Thêm phụ lục vào HĐ đang chạy | BUSINESS_ACTION |
| 12 | `contract.generateDocument` | Xuất PDF | Generate file HĐ từ template | BUSINESS_ACTION |

### 2.5 ContractTemplate (Mẫu hợp đồng)

> Configuration entity for contract templates

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `contractTemplate.create` | Tạo mẫu | Tạo template HĐLĐ mới | CRUD |
| 2 | `contractTemplate.get` | Lấy thông tin | Xem chi tiết template | CRUD |
| 3 | `contractTemplate.list` | Query động | Lọc theo type, language, status | CRUD |
| 4 | `contractTemplate.update` | Cập nhật | Sửa đổi template | CRUD |
| 5 | `contractTemplate.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `contractTemplate.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `contractTemplate.clone` | Sao chép | Tạo bản sao để chỉnh sửa | BUSINESS_ACTION |

---

## 3. Compensation Domain

### 3.1 CompensationBasis (Mức lương hiệu lực)

> Operational salary record - Effective dating, approval workflow

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `compensationBasis.create` | Tạo mức lương | Đăng ký mức lương mới | CRUD |
| 2 | `compensationBasis.get` | Lấy thông tin | Xem chi tiết mức lương | CRUD |
| 3 | `compensationBasis.list` | Query động | Lọc theo WR, status, date, reason | CRUD |
| 4 | `compensationBasis.update` | Cập nhật | Sửa đổi (chỉ draft) | CRUD |
| 5 | `compensationBasis.delete` | Xóa mềm | Hủy draft | CRUD |
| 6 | `compensationBasis.submit` | Gửi duyệt | Trình phê duyệt thay đổi lương | BUSINESS_ACTION |
| 7 | `compensationBasis.approve` | Phê duyệt | Duyệt thay đổi lương | BUSINESS_ACTION |
| 8 | `compensationBasis.reject` | Từ chối | Reject với lý do | BUSINESS_ACTION |
| 9 | `compensationBasis.cancel` | Hủy bỏ | Hủy trước khi có hiệu lực | BUSINESS_ACTION |
| 10 | `compensationBasis.createFromContract` | Tạo từ HĐ | Auto tạo khi ký HĐ mới | BUSINESS_ACTION |
| 11 | `compensationBasis.createFromPromotion` | Tạo từ thăng chức | Auto tạo khi promote | BUSINESS_ACTION |
| 12 | `compensationBasis.adjustSalary` | Điều chỉnh lương | Tạo record điều chỉnh mới | BUSINESS_ACTION |
| 13 | `compensationBasis.updateSocialInsuranceBasis` | Cập nhật đóng BHXH | VN: Cập nhật mức đóng BHXH | BUSINESS_ACTION |

---

## 4. Job Architecture Domain

### 4.1 Job (Vị trí công việc)

> Role template - What the job is

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `job.create` | Tạo Job | Định nghĩa vị trí công việc mới | CRUD |
| 2 | `job.get` | Lấy thông tin | Xem chi tiết Job | CRUD |
| 3 | `job.list` | Query động | Lọc theo taxonomy, level, status | CRUD |
| 4 | `job.update` | Cập nhật | Sửa đổi Job | CRUD |
| 5 | `job.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `job.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `job.inactivate` | Tạm ngưng | Tạm dừng sử dụng | BUSINESS_ACTION |
| 8 | `job.clone` | Sao chép | Tạo bản sao | BUSINESS_ACTION |
| 9 | `job.createVersion` | Tạo phiên bản | SCD Type-2 versioning | BUSINESS_ACTION |

### 4.2 JobProfile (Hồ sơ vị trí)

> Localized job content - Descriptions, requirements

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `jobProfile.create` | Tạo Profile | Tạo nội dung chi tiết cho Job | CRUD |
| 2 | `jobProfile.get` | Lấy thông tin | Xem chi tiết Profile | CRUD |
| 3 | `jobProfile.list` | Query động | Lọc theo Job, locale, status | CRUD |
| 4 | `jobProfile.update` | Cập nhật | Sửa đổi nội dung | CRUD |
| 5 | `jobProfile.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `jobProfile.publish` | Xuất bản | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `jobProfile.clone` | Sao chép | Clone sang ngôn ngữ khác | BUSINESS_ACTION |
| 8 | `jobProfile.createVersion` | Tạo phiên bản | SCD Type-2 versioning | BUSINESS_ACTION |

### 4.3 JobLevel (Cấp bậc)

> Seniority hierarchy - Junior, Senior, Lead, etc.

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `jobLevel.create` | Tạo cấp bậc | Định nghĩa level mới | CRUD |
| 2 | `jobLevel.get` | Lấy thông tin | Xem chi tiết level | CRUD |
| 3 | `jobLevel.list` | Query động | Lọc theo scope, status | CRUD |
| 4 | `jobLevel.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `jobLevel.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `jobLevel.reorder` | Sắp xếp lại | Thay đổi thứ tự levels | BUSINESS_ACTION |

### 4.4 JobTaxonomy (Phân loại công việc)

> Classification hierarchy - Family, Track, Group

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `jobTaxonomy.create` | Tạo node | Thêm nút phân loại | CRUD |
| 2 | `jobTaxonomy.get` | Lấy thông tin | Xem chi tiết node | CRUD |
| 3 | `jobTaxonomy.list` | Query động | Lọc theo tree, type, parent | CRUD |
| 4 | `jobTaxonomy.update` | Cập nhật | Sửa đổi node | CRUD |
| 5 | `jobTaxonomy.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `jobTaxonomy.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `jobTaxonomy.moveToParent` | Di chuyển | Reparent node | BUSINESS_ACTION |
| 8 | `jobTaxonomy.merge` | Gộp | Gộp 2 node thành 1 | BUSINESS_ACTION |
| 9 | `jobTaxonomy.split` | Tách | Tách 1 node thành nhiều | BUSINESS_ACTION |
| 10 | `jobTaxonomy.getTree` | Lấy cây | Lấy cấu trúc cây | BUSINESS_ACTION |

### 4.5 TaxonomyTree (Cây phân loại)

> Container for taxonomy - Multi-scope support

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `taxonomyTree.create` | Tạo tree | Tạo cây phân loại mới | CRUD |
| 2 | `taxonomyTree.get` | Lấy thông tin | Xem chi tiết tree | CRUD |
| 3 | `taxonomyTree.list` | Query động | Lọc theo scope, owner, status | CRUD |
| 4 | `taxonomyTree.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `taxonomyTree.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `taxonomyTree.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `taxonomyTree.clone` | Sao chép | Clone cho BU khác | BUSINESS_ACTION |
| 8 | `taxonomyTree.export` | Xuất cấu trúc | Export JSON/CSV | BUSINESS_ACTION |

### 4.6 JobTaxonomyMap (Ánh xạ Job-Taxonomy)

> Junction table - Links Job to Taxonomy nodes

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `jobTaxonomyMap.create` | Tạo ánh xạ | Gắn Job vào Taxonomy node | CRUD |
| 2 | `jobTaxonomyMap.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `jobTaxonomyMap.list` | Query động | Lọc theo Job, Node, status | CRUD |
| 4 | `jobTaxonomyMap.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `jobTaxonomyMap.delete` | Xóa | Gỡ ánh xạ | CRUD |
| 6 | `jobTaxonomyMap.setPrimary` | Đặt chính | Đánh dấu ánh xạ chính | BUSINESS_ACTION |

### 4.7 TaxonomyXMap (Ánh xạ chéo Taxonomy)

> Cross-tree mapping - BU tree to Corp tree

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `taxonomyXMap.create` | Tạo ánh xạ | Ánh xạ node từ tree này sang tree khác | CRUD |
| 2 | `taxonomyXMap.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `taxonomyXMap.list` | Query động | Lọc theo source, target, type | CRUD |
| 4 | `taxonomyXMap.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `taxonomyXMap.delete` | Xóa | Gỡ ánh xạ | CRUD |
| 6 | `taxonomyXMap.getRollupPath` | Lấy đường rollup | Tính đường roll-up lên CORP | BUSINESS_ACTION |

### 4.8 JobProfileSkill (Yêu cầu kỹ năng)

> Link: JobProfile ↔ Skill requirements

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `jobProfileSkill.create` | Thêm yêu cầu | Gắn skill vào profile | CRUD |
| 2 | `jobProfileSkill.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `jobProfileSkill.list` | Query động | Lọc theo profile, skill, importance | CRUD |
| 4 | `jobProfileSkill.update` | Cập nhật | Sửa level, importance | CRUD |
| 5 | `jobProfileSkill.delete` | Xóa | Gỡ yêu cầu | CRUD |
| 6 | `jobProfileSkill.batchUpdate` | Cập nhật hàng loạt | Cập nhật nhiều skill cùng lúc | BUSINESS_ACTION |

---

## 5. Location & Geography Domain

### 5.1 Address (Địa chỉ)

> Polymorphic address - Worker, Company, Place

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `address.create` | Tạo địa chỉ | Thêm địa chỉ cho owner | CRUD |
| 2 | `address.get` | Lấy thông tin | Xem chi tiết địa chỉ | CRUD |
| 3 | `address.list` | Query động | Lọc theo owner, type, adminArea | CRUD |
| 4 | `address.update` | Cập nhật | Sửa đổi địa chỉ | CRUD |
| 5 | `address.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `address.verify` | Xác minh | Xác thực địa chỉ hợp lệ | BUSINESS_ACTION |
| 7 | `address.setPrimary` | Đặt làm chính | Đánh dấu địa chỉ chính | BUSINESS_ACTION |
| 8 | `address.geocode` | Lấy tọa độ | Get lat/lng từ text | BUSINESS_ACTION |

### 5.2 AdminArea (Đơn vị hành chính)

> Geographic hierarchy - Country/Province/District/Ward

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `adminArea.create` | Tạo đơn vị | Thêm đơn vị hành chính | CRUD |
| 2 | `adminArea.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `adminArea.list` | Query động | Lọc theo country, level, parent | CRUD |
| 4 | `adminArea.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `adminArea.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `adminArea.getTree` | Lấy cây | Lấy hierarchy tree | BUSINESS_ACTION |
| 7 | `adminArea.merge` | Gộp | Gộp khi tái cơ cấu hành chính | BUSINESS_ACTION |
| 8 | `adminArea.split` | Tách | Tách khi tái cơ cấu | BUSINESS_ACTION |
| 9 | `adminArea.import` | Nhập hàng loạt | Import từ dữ liệu nhà nước | BUSINESS_ACTION |

### 5.3 Place (Địa điểm)

> Physical site on map - Building, Campus

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `place.create` | Tạo địa điểm | Đăng ký tòa nhà/campus | CRUD |
| 2 | `place.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `place.list` | Query động | Lọc theo type, adminArea, status | CRUD |
| 4 | `place.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `place.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `place.activate` | Kích hoạt | Mở cửa hoạt động | BUSINESS_ACTION |
| 7 | `place.close` | Đóng cửa | Đóng cửa vĩnh viễn | BUSINESS_ACTION |
| 8 | `place.geocode` | Lấy tọa độ | Get lat/lng | BUSINESS_ACTION |

### 5.4 Location (Không gian nội bộ)

> Internal space hierarchy - Floor/Room/Desk

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `location.create` | Tạo không gian | Thêm tầng/phòng/bàn | CRUD |
| 2 | `location.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `location.list` | Query động | Lọc theo place, type, parent | CRUD |
| 4 | `location.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `location.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `location.activate` | Kích hoạt | Mở cửa sử dụng | BUSINESS_ACTION |
| 7 | `location.startRenovation` | Bắt đầu sửa chữa | Đánh dấu đang bảo trì | BUSINESS_ACTION |
| 8 | `location.completeRenovation` | Hoàn thành sửa chữa | Kết thúc bảo trì | BUSINESS_ACTION |
| 9 | `location.getTree` | Lấy cây | Lấy hierarchy | BUSINESS_ACTION |

### 5.5 WorkLocation (Địa điểm làm việc HR)

> HR assignment point - Office/Remote/Hybrid

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `workLocation.create` | Tạo địa điểm HR | Đăng ký địa điểm cho Assignment | CRUD |
| 2 | `workLocation.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `workLocation.list` | Query động | Lọc theo LE, BU, type | CRUD |
| 4 | `workLocation.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `workLocation.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `workLocation.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `workLocation.close` | Đóng cửa | Đóng địa điểm | BUSINESS_ACTION |
| 8 | `workLocation.setPrimary` | Đặt làm chính | Đánh dấu địa điểm chính của BU | BUSINESS_ACTION |
| 9 | `workLocation.transferAssignments` | Chuyển nhân viên | Chuyển tất cả NV sang địa điểm khác | BUSINESS_ACTION |

---

## 6. Organization Domain

### 6.1 LegalEntity (Pháp nhân)

> Legal company - Tax, compliance, BHXH

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `legalEntity.create` | Tạo pháp nhân | Đăng ký công ty mới | CRUD |
| 2 | `legalEntity.get` | Lấy thông tin | Xem chi tiết công ty | CRUD |
| 3 | `legalEntity.list` | Query động | Lọc theo country, type, status | CRUD |
| 4 | `legalEntity.update` | Cập nhật | Sửa đổi thông tin | CRUD |
| 5 | `legalEntity.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `legalEntity.activate` | Kích hoạt | Cho phép hoạt động | BUSINESS_ACTION |
| 7 | `legalEntity.dissolve` | Giải thể | Đóng cửa công ty | BUSINESS_ACTION |
| 8 | `legalEntity.merge` | Sáp nhập | M&A - gộp pháp nhân | BUSINESS_ACTION |
| 9 | `legalEntity.updateRegistration` | Cập nhật ĐKKD | Thay đổi đăng ký kinh doanh | BUSINESS_ACTION |
| 10 | `legalEntity.updateTaxInfo` | Cập nhật MST | Thay đổi thông tin thuế | BUSINESS_ACTION |
| 11 | `legalEntity.registerBhxh` | Đăng ký BHXH | VN: Đăng ký mã đơn vị BHXH | BUSINESS_ACTION |
| 12 | `legalEntity.getTree` | Lấy cây | Lấy hierarchy group | BUSINESS_ACTION |

### 6.2 BusinessUnit (Đơn vị tổ chức)

> Org hierarchy - Division/Department/Team (N-level)

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `businessUnit.create` | Tạo đơn vị | Thêm phòng ban/nhóm | CRUD |
| 2 | `businessUnit.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `businessUnit.list` | Query động | Lọc theo LE, parent, type, status | CRUD |
| 4 | `businessUnit.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `businessUnit.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `businessUnit.activate` | Kích hoạt | Bắt đầu hoạt động | BUSINESS_ACTION |
| 7 | `businessUnit.close` | Đóng cửa | Giải thể đơn vị | BUSINESS_ACTION |
| 8 | `businessUnit.moveToParent` | Di chuyển | Reparent - đổi cấp trên | BUSINESS_ACTION |
| 9 | `businessUnit.merge` | Gộp | Gộp 2 đơn vị | BUSINESS_ACTION |
| 10 | `businessUnit.split` | Tách | Tách thành nhiều đơn vị | BUSINESS_ACTION |
| 11 | `businessUnit.assignManager` | Gán quản lý | Chỉ định trưởng đơn vị | BUSINESS_ACTION |
| 12 | `businessUnit.transferEmployees` | Chuyển nhân viên | Chuyển tất cả NV sang đơn vị khác | BUSINESS_ACTION |
| 13 | `businessUnit.getTree` | Lấy cây | Lấy org chart | BUSINESS_ACTION |

### 6.3 LegalRepresentative (Người đại diện pháp luật)

> Authorized person for contract signing

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `legalRepresentative.create` | Tạo đại diện | Đăng ký người đại diện | CRUD |
| 2 | `legalRepresentative.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `legalRepresentative.list` | Query động | Lọc theo LE, type, status | CRUD |
| 4 | `legalRepresentative.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `legalRepresentative.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `legalRepresentative.expire` | Hết hạn | Đánh dấu hết thời hạn ủy quyền | BUSINESS_ACTION |
| 7 | `legalRepresentative.revoke` | Thu hồi | Hủy trước thời hạn | BUSINESS_ACTION |
| 8 | `legalRepresentative.extend` | Gia hạn | Kéo dài thời hạn | BUSINESS_ACTION |

---

## 7. Person Data Domain

### 7.1 BankAccount (Tài khoản ngân hàng)

> Polymorphic bank account for payroll

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `bankAccount.create` | Tạo tài khoản | Đăng ký TK ngân hàng | CRUD |
| 2 | `bankAccount.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `bankAccount.list` | Query động | Lọc theo owner, bank, currency | CRUD |
| 4 | `bankAccount.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `bankAccount.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `bankAccount.verify` | Xác minh | Xác thực TK hợp lệ | BUSINESS_ACTION |
| 7 | `bankAccount.setPrimary` | Đặt làm chính | TK nhận lương chính | BUSINESS_ACTION |
| 8 | `bankAccount.block` | Khóa | Tạm khóa do nghi vấn | BUSINESS_ACTION |

### 7.2 Contact (Thông tin liên hệ)

> Phone, Email, Emergency contacts

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `contact.create` | Tạo liên hệ | Thêm SĐT/Email | CRUD |
| 2 | `contact.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `contact.list` | Query động | Lọc theo owner, type, status | CRUD |
| 4 | `contact.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `contact.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `contact.verify` | Xác minh | Gửi OTP/Link xác thực | BUSINESS_ACTION |
| 7 | `contact.setPrimary` | Đặt làm chính | Đánh dấu liên hệ chính | BUSINESS_ACTION |

### 7.3 Document (Tài liệu/Giấy tờ)

> File attachments, identity documents

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `document.create` | Upload tài liệu | Tải lên file mới | CRUD |
| 2 | `document.get` | Lấy thông tin | Xem metadata | CRUD |
| 3 | `document.list` | Query động | Lọc theo owner, type, status | CRUD |
| 4 | `document.update` | Cập nhật metadata | Sửa thông tin | CRUD |
| 5 | `document.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `document.submitForVerification` | Gửi xác minh | Trình xác thực giấy tờ | BUSINESS_ACTION |
| 7 | `document.verify` | Xác minh | Đánh dấu đã xác thực | BUSINESS_ACTION |
| 8 | `document.reject` | Từ chối | Reject với lý do | BUSINESS_ACTION |
| 9 | `document.createNewVersion` | Tạo phiên bản mới | Upload version mới | BUSINESS_ACTION |
| 10 | `document.download` | Tải xuống | Lấy signed URL | BUSINESS_ACTION |

### 7.4 WorkerQualification (Bằng cấp/Chứng chỉ)

> Education, Certifications, Licenses

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `workerQualification.create` | Thêm bằng cấp | Đăng ký trình độ học vấn | CRUD |
| 2 | `workerQualification.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `workerQualification.list` | Query động | Lọc theo worker, type, status | CRUD |
| 4 | `workerQualification.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `workerQualification.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `workerQualification.verify` | Xác minh | Xác thực bằng cấp | BUSINESS_ACTION |
| 7 | `workerQualification.expire` | Hết hạn | Đánh dấu chứng chỉ hết hạn | BUSINESS_ACTION |
| 8 | `workerQualification.renew` | Gia hạn | Cập nhật gia hạn chứng chỉ | BUSINESS_ACTION |

### 7.5 WorkerRelationship (Quan hệ gia đình)

> Family members, Dependents, Beneficiaries

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `workerRelationship.create` | Thêm quan hệ | Đăng ký người thân | CRUD |
| 2 | `workerRelationship.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `workerRelationship.list` | Query động | Lọc theo worker, relation type | CRUD |
| 4 | `workerRelationship.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `workerRelationship.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `workerRelationship.setAsDependent` | Đặt người phụ thuộc | Đăng ký giảm trừ thuế TNCN | BUSINESS_ACTION |
| 7 | `workerRelationship.removeAsDependent` | Gỡ người phụ thuộc | Hủy đăng ký giảm trừ | BUSINESS_ACTION |
| 8 | `workerRelationship.setAsBeneficiary` | Đặt người thụ hưởng | Đăng ký hưởng bảo hiểm | BUSINESS_ACTION |
| 9 | `workerRelationship.setAsEmergency` | Đặt liên hệ khẩn cấp | Đăng ký liên hệ khẩn cấp | BUSINESS_ACTION |

---

## 8. Position Domain

### 8.1 Position (Vị trí tổ chức)

> Organizational chair - Instance of Job in org chart

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `position.create` | Tạo vị trí | Thêm Position vào org chart | CRUD |
| 2 | `position.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `position.list` | Query động | Lọc theo BU, Job, status, vacancy | CRUD |
| 4 | `position.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `position.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `position.activate` | Kích hoạt | Cho phép tuyển dụng | BUSINESS_ACTION |
| 7 | `position.freeze` | Đóng băng | Tạm dừng tuyển dụng | BUSINESS_ACTION |
| 8 | `position.unfreeze` | Mở đóng băng | Cho phép tuyển lại | BUSINESS_ACTION |
| 9 | `position.close` | Đóng | Xóa khỏi org chart | BUSINESS_ACTION |
| 10 | `position.clone` | Sao chép | Tạo Position mới tương tự | BUSINESS_ACTION |
| 11 | `position.changeSupervisor` | Đổi cấp trên | Thay đổi reporting line | BUSINESS_ACTION |
| 12 | `position.getTree` | Lấy org chart | Lấy hierarchy tree | BUSINESS_ACTION |

---

## 9. Skills & Competencies Domain

### 9.1 Skill (Kỹ năng)

> Technical/functional ability master data

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `skill.create` | Tạo skill | Thêm kỹ năng vào catalog | CRUD |
| 2 | `skill.get` | Lấy thông tin | Xem chi tiết skill | CRUD |
| 3 | `skill.list` | Query động | Lọc theo category, type, status | CRUD |
| 4 | `skill.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `skill.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `skill.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `skill.deprecate` | Lỗi thời | Đánh dấu không còn dùng | BUSINESS_ACTION |
| 8 | `skill.merge` | Gộp | Gộp skill trùng lặp | BUSINESS_ACTION |
| 9 | `skill.linkExternal` | Liên kết ngoài | Gắn với O*NET, LinkedIn | BUSINESS_ACTION |

### 9.2 SkillCategory (Danh mục kỹ năng)

> Hierarchical taxonomy for skills

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `skillCategory.create` | Tạo danh mục | Thêm category mới | CRUD |
| 2 | `skillCategory.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `skillCategory.list` | Query động | Lọc theo parent, status | CRUD |
| 4 | `skillCategory.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `skillCategory.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `skillCategory.moveToParent` | Di chuyển | Reparent | BUSINESS_ACTION |
| 7 | `skillCategory.getTree` | Lấy cây | Lấy hierarchy | BUSINESS_ACTION |

### 9.3 Competency (Năng lực)

> Behavioral trait master data

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `competency.create` | Tạo năng lực | Thêm competency mới | CRUD |
| 2 | `competency.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `competency.list` | Query động | Lọc theo category, framework, type | CRUD |
| 4 | `competency.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `competency.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `competency.activate` | Kích hoạt | Cho phép sử dụng | BUSINESS_ACTION |
| 7 | `competency.deprecate` | Lỗi thời | Đánh dấu không còn dùng | BUSINESS_ACTION |
| 8 | `competency.setAsCore` | Đặt core | Đánh dấu là năng lực cốt lõi | BUSINESS_ACTION |
| 9 | `competency.updateIndicators` | Cập nhật indicators | Sửa đổi behavioral indicators | BUSINESS_ACTION |

### 9.4 CompetencyCategory (Danh mục năng lực)

> Hierarchical taxonomy for competencies

| # | Function | Description | Business Meaning | Type |
|---|----------|-------------|------------------|------|
| 1 | `competencyCategory.create` | Tạo danh mục | Thêm category mới | CRUD |
| 2 | `competencyCategory.get` | Lấy thông tin | Xem chi tiết | CRUD |
| 3 | `competencyCategory.list` | Query động | Lọc theo parent, framework | CRUD |
| 4 | `competencyCategory.update` | Cập nhật | Sửa đổi | CRUD |
| 5 | `competencyCategory.delete` | Xóa mềm | Vô hiệu hóa | CRUD |
| 6 | `competencyCategory.moveToParent` | Di chuyển | Reparent | BUSINESS_ACTION |
| 7 | `competencyCategory.getTree` | Lấy cây | Lấy hierarchy | BUSINESS_ACTION |

---

## Summary Statistics

### API Count by Domain

| Domain | Entities | CRUD | Business Actions | Total |
|--------|----------|------|------------------|-------|
| Person Identity | 1 | 5 | 4 | 9 |
| Employment | 5 | 25 | 35 | 60 |
| Compensation | 1 | 5 | 8 | 13 |
| Job Architecture | 8 | 40 | 19 | 59 |
| Location & Geography | 5 | 25 | 18 | 43 |
| Organization | 3 | 15 | 18 | 33 |
| Person Data | 5 | 25 | 19 | 44 |
| Position | 1 | 5 | 7 | 12 |
| Skills & Competencies | 4 | 20 | 12 | 32 |
| **TOTAL** | **33** | **165** | **140** | **305** |

### Reduction Analysis

| Metric | Original | Consolidated | Reduction |
|--------|----------|--------------|-----------|
| Total APIs | ~547 | ~305 | **44%** |
| Query Endpoints | ~160 | 33 (integrated into list) | **79%** |
| Report Endpoints | ~40 | 0 (separate module) | **100%** |

### API Type Distribution

| Type | Count | % |
|------|-------|---|
| CRUD | 165 | 54% |
| BUSINESS_ACTION | 140 | 46% |

---

## Key Use Cases

| Use Case | APIs Involved |
|----------|---------------|
| **Onboard New Hire** | `employee.hire` → `contract.create` → `contract.sign` → `compensationBasis.createFromContract` |
| **Terminate Employee** | `employee.terminate` → `workRelationship.terminate` → `workRelationship.closeSocialInsurance` |
| **Promote Employee** | `assignment.promote` → `compensationBasis.createFromPromotion` |
| **Transfer Department** | `assignment.transfer` |
| **Close Office** | `workLocation.transferAssignments` → `workLocation.close` |
| **Setup Job Family** | `taxonomyTree.create` → `jobTaxonomy.create` (hierarchy) → `job.create` → `jobTaxonomyMap.create` |
| **Register Tax Dependent** | `workerRelationship.create` → `workerRelationship.setAsDependent` |

---

*Document Status: DRAFT*  
*Last Updated: 2026-01-30*  
*Design Principle: Atomic API with Dynamic Query*
