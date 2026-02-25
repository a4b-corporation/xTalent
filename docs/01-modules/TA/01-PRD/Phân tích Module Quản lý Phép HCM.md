# **Báo cáo Phân tích Kiến trúc Hướng Đối tượng và Thiết kế Context Bound cho Hệ thống Quản lý Phép Nhân sự (HCM)**

## **1\. Tổng quan Điều hành và Triết lý Kiến trúc**

Trong bối cảnh phát triển của các hệ thống Quản trị Vốn nhân lực (Human Capital Management \- HCM), sự chuyển dịch từ kiến trúc nguyên khối (monolithic) dựa trên tính năng sang kiến trúc vi dịch vụ (microservices) dựa trên tên miền dữ liệu (Domain-Driven Design \- DDD) đang trở thành tiêu chuẩn vàng cho các doanh nghiệp quy mô lớn. Báo cáo này trình bày một phân tích chuyên sâu về việc tái cấu trúc Module Quản lý Phép (Leave Management) thông qua lăng kính của "Đối tượng Quản lý" (Managed Objects) thay vì "Quy trình Nghiệp vụ" (Business Processes).

Mục tiêu cốt lõi của báo cáo này là định nghĩa các Bounded Contexts (Miền dữ liệu giới hạn) hoàn toàn độc lập, giao tiếp thông qua các API hướng dữ liệu (Data-Centric APIs) và tuân thủ nghiêm ngặt các nguyên lý của Palantir Ontology.1 Cách tiếp cận này loại bỏ sự phụ thuộc chéo về quy trình, cho phép mỗi Context phát triển, mở rộng và bảo trì riêng biệt mà không làm gián đoạn toàn bộ hệ sinh thái.

Chúng ta sẽ không xây dựng các API theo hướng hành động (Action-based RPC) như approveLeaveRequest hay calculateBalance. Thay vào đó, hệ thống sẽ phơi bày các "Ontology Objects" thông qua các API truy vấn động (Dynamic Query APIs) giàu ngữ nghĩa, cho phép người tiêu dùng (Client Applications) tự do kết hợp dữ liệu thông qua các liên kết (Links) và bộ lọc (Filters) đa chiều.3

Báo cáo được chia thành 5 Bounded Contexts chính:

1. **Workforce Context (Miền Nhân lực):** Quản lý đối tượng "Con người" và các thuộc tính phái sinh.  
2. **Chronology Context (Miền Thời gian):** Quản lý cấu trúc thời gian, lịch làm việc và chu kỳ.  
3. **Governance Context (Miền Chính sách):** Quản lý các quy tắc, điều kiện và định nghĩa loại phép.  
4. **Fiscal Context (Miền Sổ cái/Tài chính):** Quản lý số dư, giao dịch và tính toàn vẹn dữ liệu (Immutable Ledger).  
5. **Kinetic Context (Miền Vận động/Quy trình):** Quản lý trạng thái của các yêu cầu và sự kiện thay đổi.

## ---

**2\. Nguyên lý Thiết kế API và Định nghĩa Ontology**

Trước khi đi sâu vào từng Context, cần thiết lập nền tảng kỹ thuật cho cơ chế giao tiếp giữa chúng. Theo yêu cầu, các API không được thiết kế riêng cho từng hành động (action-specific) mà phải là các API truy vấn tổng quát, mạnh mẽ.

### **2.1. Tiêu chuẩn API Hướng Đối tượng (Object-Centric API Standard)**

Mỗi Bounded Context sẽ cung cấp một tập hợp các endpoints xoay quanh các Entity Objects của nó. API phải hỗ trợ đầy đủ các tính năng sau để đảm bảo tính linh hoạt tối đa cho phía Client (người sử dụng hoặc hệ thống khác):

1. **Dynamic Filtering (Lọc Động):** API cho phép lọc trên *bất kỳ* thuộc tính nào của đối tượng, hỗ trợ các toán tử logic phức tạp (AND, OR, NOT, IN, CONTAINS).4 Điều này loại bỏ nhu cầu tạo ra vô số endpoint như getActiveEmployees hay getEmployeesByDepartment.  
2. **Pagination (Phân trang):** Bắt buộc đối với mọi endpoint trả về danh sách (Object Sets). Sử dụng cơ chế cursor-based hoặc offset-based để đảm bảo hiệu năng khi xử lý hàng triệu bản ghi.5  
3. **Field Selection & Expansion (Chọn trường và Mở rộng):** Client có thể chỉ định chính xác các trường cần trả về (select=id,name) và yêu cầu mở rộng các đối tượng liên kết (expand=manager, department) trong một lần gọi duy nhất.7  
4. **Link Traversal (Duyệt Liên kết):** API phải cho phép truy cập các đối tượng liên quan thông qua các định nghĩa Link Types trong Ontology mà không cần Client phải hiểu cấu trúc khóa ngoại (Foreign Key) bên dưới.9

| Đặc tả API | Mô tả Kỹ thuật | Ví dụ Request (RESTful style) |
| :---- | :---- | :---- |
| **Endpoint Cơ sở** | Truy cập vào tập hợp đối tượng (Object Set) | GET /api/v1/ontology/objects/{objectType} |
| **Filter** | Truy vấn động đa điều kiện | ?filter=(status eq 'Active' AND tenure ge 5\) OR role in |
| **Link Traversal** | Lấy đối tượng liên kết (Search Around) | GET /api/v1/ontology/objects/Employee/{id}/links/assignedSchedule |
| **Action Application** | Thực thi thay đổi trạng thái (Writeback) | POST /api/v1/ontology/actions/apply (Payload chứa ActionType và Parameters) |

### **2.2. Phân loại Entity Object và Value Object**

Tuân theo tiêu chuẩn của Palantir Ontology và DDD 1:

* **Entity Object (Đối tượng Thực thể):** Là các đối tượng có định danh duy nhất (Identity), có vòng đời (Lifecycle) độc lập và thay đổi trạng thái theo thời gian. Ví dụ: Employee, AbsenceRequest.  
* **Value Object (Đối tượng Giá trị):** Là các đối tượng không có định danh riêng biệt, được xác định bởi giá trị của các thuộc tính, và thường là bất biến (Immutable). Ví dụ: DateRange, MoneyAmount, Address.

## ---

**3\. Bounded Context 1: Workforce Context (Miền Quản lý Nhân lực)**

**Đối tượng Quản lý Chính:** Employee (Nhân viên).

Miền này đóng vai trò là "Source of Truth" (Nguồn sự thật) cho dữ liệu về con người. Nó hoàn toàn không biết về số dư phép hay lịch nghỉ lễ. Nhiệm vụ duy nhất của nó là cung cấp một biểu diễn kỹ thuật số chính xác nhất về nhân sự để các miền khác tiêu thụ.

### **3.1. Entity Object: Employee**

Trong mô hình Ontology, Employee là trung tâm của đồ thị dữ liệu. Tuy nhiên, thay vì chỉ lưu trữ các trường dữ liệu tĩnh (như Tên, Ngày sinh), đối tượng này cần phơi bày các **Derived Properties** (Thuộc tính phái sinh) được tính toán sẵn hoặc cập nhật theo thời gian thực để hỗ trợ logic nghiệp vụ của các miền khác.11

#### **Cấu trúc Dữ liệu và Thuộc tính (Properties)**

| Tên Thuộc tính | Loại Dữ liệu | Mô tả & Ý nghĩa Nghiệp vụ | Nguồn gốc / Ghi chú |
| :---- | :---- | :---- | :---- |
| primaryKey | UUID | Định danh bất biến toàn cục. | System Generated |
| employmentStatus | Enum | Active, Suspended, Terminated, Furloughed. | Core HRIS |
| seniorityDate | Date | Ngày bắt đầu tính thâm niên (khác với Hire Date nếu có sáp nhập/mua lại). | Dùng cho AccrualRule |
| derivedTenure | Decimal | Số năm thâm niên tính đến thời điểm hiện tại (ví dụ: 5.4 năm). | **Derived Factor** 12 |
| derivedAge | Integer | Tuổi hiện tại của nhân viên. | **Derived Factor** |
| costCenterId | String | Liên kết đến hệ thống tài chính (nhưng không chứa logic tài chính). | Org Structure |
| isUnionMember | Boolean | Cờ đánh dấu thành viên công đoàn (ảnh hưởng đến Eligibility). | Labor Relations |
| jobProfileId | String | Liên kết đến chức danh/ngạch bậc. | Job Architecture |

**Phân tích Chi tiết:** Việc đưa derivedTenure và derivedAge vào làm thuộc tính trực tiếp của Object là một quyết định kiến trúc quan trọng. Trong các hệ thống cũ, các module khác (như Governance) phải tự tính toán (Today \- HireDate). Điều này tạo ra sự lặp lại logic và rủi ro sai sót. Bằng cách để Workforce Context chịu trách nhiệm về "dữ liệu thực tế" này, chúng ta đóng gói sự phức tạp của việc tính toán thâm niên (ví dụ: trừ đi thời gian nghỉ không lương) bên trong Workforce Context.12

### **3.2. Value Objects liên quan**

* **JobAssignment:** Mô tả chi tiết vị trí công việc tại một thời điểm. Mặc dù có thể thay đổi, nhưng trong ngữ cảnh truy vấn phép, nó thường được coi là một snapshot gắn liền với Employee.

### **3.3. API Strategy cho Workforce Context**

API của Workforce Context không cung cấp các hàm nghiệp vụ như checkEligibility. Thay vào đó, nó cung cấp khả năng **"Search Around"** (Tìm kiếm xung quanh) mạnh mẽ.

* **Scenario:** Module Governance muốn biết "Tất cả nhân viên có thâm niên trên 5 năm tại London".  
* **Query API:**  
  HTTP  
  GET /api/workforce/objects/Employee?filter=derivedTenure gt 5 AND location.city eq 'London'

* **Link Traversal:** Để lấy thông tin quản lý trực tiếp (Manager) mà không cần gọi API riêng:  
  HTTP  
  GET /api/workforce/objects/Employee/{id}?expand=reportsTo

  Thuộc tính reportsTo là một Link Type (Quan hệ) nối Employee với Employee khác (Self-referential link).

## ---

**4\. Bounded Context 2: Chronology Context (Miền Quản lý Thời gian)**

**Đối tượng Quản lý Chính:** WorkSchedule (Lịch làm việc), HolidayCalendar (Lịch nghỉ lễ), TimeVariant (Biến thể thời gian).

Đây là miền quản lý "bàn cờ thời gian" của doanh nghiệp. Nó định nghĩa "Khi nào" là thời gian làm việc và "Khi nào" là thời gian nghỉ, hoàn toàn độc lập với việc "Ai" đang làm việc đó. Context này giải quyết bài toán phức tạp về việc quy đổi thời gian thực tế sang đơn vị tính toán (giờ/ngày công).

### **4.1. Entity Object: WorkSchedule**

WorkSchedule không chỉ là danh sách các ngày trong tuần. Nó phải hỗ trợ các mô hình phức tạp như Ca kíp xoay vòng (Rotational Shifts), Tuần chẵn/lẻ, và Lịch làm việc linh hoạt (Flex-time).14

#### **Cấu trúc Dữ liệu**

| Tên Thuộc tính | Loại Dữ liệu | Mô tả |
| :---- | :---- | :---- |
| scheduleCode | String | Mã định danh lịch (ví dụ: "STD-40H-MON-FRI"). |
| cycleLength | Integer | Độ dài chu kỳ (ví dụ: 7 ngày, 14 ngày, 28 ngày). |
| patternDefinition | JSON Struct | Định nghĩa cấu trúc lặp (ví dụ: Day 1: 8h, Day 2: 8h...). |
| validFrom | Date | Ngày bắt đầu hiệu lực của mẫu lịch này. |

### **4.2. Entity Object: CalendarDay & PublicHoliday**

Để tách biệt logic nghỉ lễ khỏi lịch làm việc (vì một lịch làm việc có thể áp dụng cho nhiều quốc gia có ngày lễ khác nhau), chúng ta sử dụng đối tượng HolidayCalendar.16

* **HolidayCalendar:** Là một container chứa danh sách các ngày nghỉ lễ (PublicHoliday).  
* **PublicHoliday:** Entity đại diện cho một ngày lễ cụ thể (ví dụ: Tết Nguyên Đán 2024).  
  * Thuộc tính: date, name, holidayClass (Full day, Half day).

### **4.3. Entity Object: TimeVariant (Shift Model)**

Đây là đối tượng định nghĩa chi tiết một "Ngày làm việc".18

* Thuộc tính: startTime, endTime, breakDuration, coreHours, isWorkingDay.

### **4.4. Dịch vụ Quy đổi Thời gian (Time Resolution Service)**

Mặc dù chúng ta ưu tiên Object API, nhưng Chronology Context cần cung cấp một API tính toán đặc biệt (dưới dạng Function Object hoặc Computed Property) để trả lời câu hỏi: "Khoảng thời gian từ ngày A đến ngày B tương đương bao nhiêu giờ làm việc?".

* **API Query (Mô phỏng):** Client không gọi hàm RPC calculateHours. Thay vào đó, Client truy vấn vào một "Virtual Object" hoặc sử dụng tính năng "Function-backed Object" của Palantir.19  
  * Giả sử có một Virtual Object là TimeSpanEvaluation.  
  * Client tạo (trong bộ nhớ) hoặc truy vấn đối tượng này với input parameters.  
  * API trả về kết quả đã tính toán dựa trên WorkSchedule và HolidayCalendar.

Việc này cực kỳ quan trọng vì nếu ngày 25/12 là ngày lễ, thì việc xin nghỉ từ 24/12 đến 26/12 chỉ tiêu tốn 16 giờ (nếu làm 8h/ngày) chứ không phải 24 giờ. Logic này phải nằm hoàn toàn trong Chronology Context.21

---

## **5\. Bounded Context 3: Governance Context (Miền Quản trị Chính sách)**

**Đối tượng Quản lý Chính:** AbsencePlan (Gói phép), EligibilityProfile (Hồ sơ điều kiện), AccrualRule (Quy tắc tích lũy).

Đây là "Bộ não" pháp lý của hệ thống. Nó định nghĩa các quy tắc chơi (Rules of Engagement). Nó không giữ số dư của nhân viên, nhưng nó quyết định ai được hưởng cái gì và tích lũy bao nhiêu.

### **5.1. Entity Object: AbsencePlan**

Đại diện cho một loại quyền lợi nghỉ phép (ví dụ: "Phép năm 2024", "Nghỉ ốm hưởng lương", "Nghỉ thai sản").

#### **Cấu trúc Dữ liệu**

| Tên Thuộc tính | Loại Dữ liệu | Mô tả |
| :---- | :---- | :---- |
| planId | String | Mã định danh (ví dụ: "VAC-US-2024"). |
| planType | Enum | Accrual (Tích lũy), Front-loaded (Cấp trước), Rolling (Cuốn chiếu). 22 |
| uom | Enum | Hours, Days, Calendar Days. |
| allowNegative | Boolean | Có cho phép ứng trước phép (âm số dư) không? |
| carryoverLimit | Decimal | Số lượng tối đa được chuyển sang kỳ sau. |

### **5.2. Entity Object: EligibilityProfile**

Để hệ thống linh hoạt, các điều kiện hưởng phép không được hard-code trong code (if/else) mà phải được mô hình hóa thành Dữ liệu (Configuration as Data).23

* **Cấu trúc:** Chứa một tập hợp các Criteria (Tiêu chí).  
* **Ví dụ Tiêu chí:**  
  * criteriaField: "derivedTenure"  
  * operator: "GE" (Greater or Equal)  
  * value: 0.5 (Nửa năm)  
  * logicalGroup: "BasicQualification"

Khi Client (ví dụ: UI) cần biết "Nhân viên A có được xem Phép năm không?", Client sẽ truy vấn API của Governance Context, truyền vào ID nhân viên. Governance Context sẽ dùng EligibilityProfile để đối chiếu với dữ liệu từ Workforce Context (qua API) và trả về kết quả.

### **5.3. Entity Object: AccrualRule**

Định nghĩa cách tính toán số lượng phép được thêm vào tài khoản. Trong các hệ thống hiện đại như Workday hay SAP, quy tắc này rất phức tạp (theo thâm niên, theo vùng miền, theo cấp bậc).25

* **Palantir Function Integration:** AccrualRule có thể liên kết với một Function ID trong hệ thống. Khi cần chạy tính toán (Run Accrual), hệ thống sẽ load Rule Object, lấy Function ID và thực thi logic tương ứng. Điều này cho phép thay đổi logic tính toán mà không cần redeploy toàn bộ ứng dụng, chỉ cần update Function hoặc trỏ Rule sang Function mới.27

## ---

**6\. Bounded Context 4: Fiscal Context (Miền Tài chính/Sổ cái)**

**Đối tượng Quản lý Chính:** TimeAccount (Tài khoản thời gian), LedgerEntry (Bút toán), Snapshot.

Đây là miền quan trọng nhất để đảm bảo tính toàn vẹn dữ liệu. Nó coi "Thời gian" như "Tiền tệ". Kiến trúc ở đây phải tuân thủ nguyên tắc **Immutable Ledger** (Sổ cái bất biến) và **Double-Entry Bookkeeping** (Ghi sổ kép) để đảm bảo khả năng kiểm toán tuyệt đối.28

### **6.1. Entity Object: TimeAccount**

Tương đương với một tài khoản ngân hàng cho thời gian. Mỗi nhân viên có thể có nhiều TimeAccount (1 cho Phép năm, 1 cho Nghỉ ốm, v.v.).

* **Links:**  
  * owner: Link to Employee (Workforce Context).  
  * plan: Link to AbsencePlan (Governance Context).

### **6.2. Entity Object: LedgerEntry (Transaction)**

Mọi thay đổi về số dư (cộng thêm phép, trừ ngày nghỉ, điều chỉnh) đều phải được ghi nhận là một dòng trong LedgerEntry. **Tuyệt đối không bao giờ cập nhật (UPDATE) hay xóa (DELETE) một dòng đã ghi.**

#### **Cấu trúc Dữ liệu**

| Tên Thuộc tính | Loại Dữ liệu | Mô tả |
| :---- | :---- | :---- |
| entryId | UUID | Khóa chính. |
| transactionType | Enum | ACCRUAL (Tích lũy), TAKEN (Sử dụng), ADJ (Điều chỉnh), PAYOUT (Thanh toán). |
| amount | Decimal | Số lượng (Dương cho cộng, Âm cho trừ). |
| effectiveDate | Date | Ngày giao dịch có hiệu lực nghiệp vụ. |
| postingDate | Timestamp | Thời điểm ghi nhận vào hệ thống (Audit trail). |
| referenceId | String | Link tới AbsenceRequest hoặc AccrualRun (Kinetic Context). |
| isVoided | Boolean | Đánh dấu nếu dòng này đã bị hủy (nhưng vẫn tồn tại). |

### **6.3. Chiến lược Xử lý Thay đổi Hồi tố (Retroactive Changes)**

Một trong những thách thức lớn nhất của HCM là "Retroactive Changes" (Thay đổi quá khứ). Ví dụ: Nhân viên đã nghỉ tháng trước, nhưng hôm nay Admin mới phát hiện sai sót và muốn sửa loại phép.30

**Giải pháp Kiến trúc:**

Hệ thống Fiscal Context không cho phép sửa đổi LedgerEntry cũ. Thay vào đó, nó tạo ra các **Offsetting Entries** (Bút toán bù trừ).

* *Kịch bản:* Ngày 1/1, ghi nhận nghỉ 8h (Entry A). Ngày 10/1, phát hiện sai, thực tế chỉ nghỉ 4h.  
* *Xử lý:*  
  1. Tạo Entry B (Type: CORRECTION, Amount: \+8h) để hủy bỏ tác động của Entry A.  
  2. Tạo Entry C (Type: TAKEN, Amount: \-4h) để ghi nhận giá trị đúng.  
* **Truy vấn Số dư:** Số dư tại bất kỳ thời điểm nào \= SUM(amount) của tất cả các Entry có effectiveDate \<= queryDate.

### **6.4. API cho Fiscal Context**

API ở đây cần hỗ trợ truy vấn số dư tại một thời điểm trong quá khứ ("Time Travel" query).

* **Query:** GET /api/fiscal/objects/TimeAccount/{id}/balance?asOfDate=2023-12-31  
* **Logic:** Hệ thống Fiscal sẽ tự động tổng hợp các LedgerEntry tính đến ngày đó để trả về kết quả chính xác, phục vụ cho báo cáo tài chính cuối năm hoặc quyết toán nghỉ việc.32

## ---

**7\. Bounded Context 5: Kinetic Context (Miền Vận động/Quy trình)**

**Đối tượng Quản lý Chính:** AbsenceRequest (Yêu cầu nghỉ), AbsenceCase (Hồ sơ nghỉ dài hạn), WorkflowAction.

Đây là miền duy nhất biết về "Quy trình". Nó đóng vai trò nhạc trưởng (Orchestrator), kết nối các miền tĩnh (Workforce, Governance) và miền giao dịch (Fiscal) để thực hiện các nghiệp vụ của người dùng.

### **7.1. Entity Object: AbsenceRequest**

Đại diện cho ý định (intent) của nhân viên.

#### **Cấu trúc Dữ liệu**

| Tên Thuộc tính | Loại Dữ liệu | Mô tả |
| :---- | :---- | :---- |
| requestId | UUID | Khóa chính. |
| requester | Link | Link to Employee. |
| status | Enum | DRAFT, SUBMITTED, APPROVED, REJECTED, CANCELLED. |
| period | DateRange | Từ ngày \- Đến ngày. |
| resolvedDuration | Decimal | Số lượng (giờ/ngày) đã được tính toán bởi Chronology Context. |
| approvalChain | JSON | Snapshot của quy trình phê duyệt. |

### **7.2. Entity Object: AbsenceCase (Intermittent Leave)**

Đối với các trường hợp nghỉ dài hạn hoặc ngắt quãng (như nghỉ thai sản, FMLA tại Mỹ, nghỉ ốm dài ngày), một AbsenceRequest đơn lẻ là không đủ. Chúng ta cần đối tượng AbsenceCase để gom nhóm nhiều Request lại với nhau.33

* **Ví dụ:** Một nhân viên được duyệt nghỉ FMLA 12 tuần, nhưng họ nghỉ rải rác mỗi tuần 2 ngày. AbsenceCase sẽ theo dõi tổng hạn mức (12 tuần), còn các AbsenceRequest con sẽ trừ dần vào hạn mức đó.

### **7.3. Cơ chế Action và Webhook (Writeback)**

Trong Palantir Ontology, người dùng tương tác thông qua **Actions**.2 Kinetic Context sẽ định nghĩa các Actions này.

* **Action:** SubmitLeaveRequest  
* **Logic Thực thi (Backend):**  
  1. **Validate:** Gọi API Workforce (Check Status), API Governance (Check Eligibility), API Fiscal (Check Balance).  
  2. **Calculate:** Gọi API Chronology để tính resolvedDuration.  
  3. **Persist:** Lưu AbsenceRequest với trạng thái PENDING.  
  4. **Side Effect:** Nếu Auto-Approve, kích hoạt Webhook gọi sang Fiscal Context để ghi LedgerEntry.

## ---

**8\. Chiến lược Tích hợp và Làm giàu Truy vấn (Query Enrichment)**

Theo yêu cầu, người sử dụng sẽ tự động kết hợp các API để làm giàu thông tin. Điều này dựa trên khả năng của các Link Types trong Ontology.

### **8.1. Mô hình "Lazy Loading" thông qua Links**

Khi Client truy vấn danh sách AbsenceRequest từ Kinetic Context, API trả về JSON chứa các đường dẫn (HATEOAS links) tới các đối tượng liên quan thay vì nhúng toàn bộ dữ liệu (embedding).

JSON

{  
  "objectType": "AbsenceRequest",  
  "id": "req\_12345",  
  "properties": {  
    "status": "APPROVED",  
    "startDate": "2024-05-01"  
  },  
  "links": {  
    "requester": "/api/workforce/objects/Employee/emp\_999",  
    "plan": "/api/governance/objects/AbsencePlan/plan\_vacation"  
  }  
}

Client, nếu cần hiển thị tên nhân viên, sẽ thực hiện gọi tiếp link requester. Nếu Client thông minh (ví dụ Palantir Workshop), nó có thể dùng tính năng expand hoặc Object Set để fetch dữ liệu hàng loạt, tối ưu hóa hiệu năng.36

### **8.2. Cross-Context Search (Tìm kiếm Xuyên Context)**

Sử dụng khả năng của Ontology để thực hiện các truy vấn phức tạp mà không cần join database vật lý.

* **Bài toán:** "Tìm tất cả các AbsenceRequest của nhân viên thuộc phòng IT".  
* **Giải pháp:**  
  1. Tạo Object Set các nhân viên phòng IT từ Workforce Context (Department \== 'IT').  
  2. Sử dụng tính năng **Search Around** (Duyệt qua Link) để tìm tất cả AbsenceRequest được liên kết với tập hợp nhân viên này.37  
  3. Kết quả trả về là một Object Set các Request, hoàn toàn tách biệt về mặt lưu trữ nhưng được liên kết về mặt ngữ nghĩa.

## ---

**9\. Kết luận**

Việc tái cấu trúc Module Quản lý Phép theo kiến trúc Bounded Context dựa trên Đối tượng Quản lý (Managed Objects) mang lại sự linh hoạt vượt trội so với các hệ thống truyền thống. Bằng cách tách biệt rõ ràng giữa **Con người** (Workforce), **Thời gian** (Chronology), **Luật lệ** (Governance), **Tài chính** (Fiscal) và **Quy trình** (Kinetic), chúng ta tạo ra một hệ thống có khả năng mở rộng vô hạn, dễ dàng thích ứng với các thay đổi pháp lý phức tạp và tích hợp mượt mà với các nền tảng dữ liệu hiện đại như Palantir Foundry. Các API được thiết kế theo hướng Dynamic Query và Ontology-based đảm bảo rằng hệ thống không bị "cứng hóa" bởi các quy trình nghiệp vụ cụ thể, mà trở thành một nền tảng dữ liệu sống động, sẵn sàng cho mọi nhu cầu khai thác trong tương lai.

#### **Nguồn trích dẫn**

1. Palantir Foundry Ontology, truy cập vào tháng 2 11, 2026, [https://www.palantir.com/explore/platforms/foundry/ontology/](https://www.palantir.com/explore/platforms/foundry/ontology/)  
2. Palantir Ontology, truy cập vào tháng 2 11, 2026, [https://www.palantir.com/platforms/ontology/](https://www.palantir.com/platforms/ontology/)  
3. Web API Design Best Practices \- Azure Architecture Center \- Microsoft Learn, truy cập vào tháng 2 11, 2026, [https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)  
4. REST API Design: Filtering, Sorting, and Pagination | Moesif Blog, truy cập vào tháng 2 11, 2026, [https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/](https://www.moesif.com/blog/technical/api-design/REST-API-Design-Filtering-Sorting-and-Pagination/)  
5. API pagination best practices \- Stack Overflow, truy cập vào tháng 2 11, 2026, [https://stackoverflow.com/questions/13872273/api-pagination-best-practices](https://stackoverflow.com/questions/13872273/api-pagination-best-practices)  
6. API Design Basics: Pagination, truy cập vào tháng 2 11, 2026, [https://apisyouwonthate.com/blog/api-design-basics-pagination/](https://apisyouwonthate.com/blog/api-design-basics-pagination/)  
7. REST API for Oracle Fusion Cloud HCM \- Get all flow patterns, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-flowpatternslov-get.html](https://docs.oracle.com/en/cloud/saas/human-resources/farws/op-flowpatternslov-get.html)  
8. REST API for Sales and Fusion Service in Oracle Fusion Cloud Customer Experience \- Get all dynamic link patterns, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/sales/faaps/op-dynamiclinkpatterns-get.html](https://docs.oracle.com/en/cloud/saas/sales/faaps/op-dynamiclinkpatterns-get.html)  
9. API: Objects and links \- Functions \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/functions/api-objects-links/](https://palantir.com/docs/foundry/functions/api-objects-links/)  
10. Tactical Design Patterns in DDD: Modeling Complex Domains Effectively \- DEV Community, truy cập vào tháng 2 11, 2026, [https://dev.to/ruben\_alapont/tactical-design-patterns-in-ddd-modeling-complex-domains-effectively-393n](https://dev.to/ruben_alapont/tactical-design-patterns-in-ddd-modeling-complex-domains-effectively-393n)  
11. Create Derived Factors and Eligibility Profiles \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faaac/create-derived-factors-and-eligibility-profiles.html](https://docs.oracle.com/en/cloud/saas/human-resources/faaac/create-derived-factors-and-eligibility-profiles.html)  
12. Eligibility Profiles \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/eligibility-profiles.html](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/eligibility-profiles.html)  
13. Derived Factors and Eligibility Profile in Absence Management Module \- Medium, truy cập vào tháng 2 11, 2026, [https://medium.com/@futureprooftrainings/derived-factors-and-eligibility-profile-in-absence-management-module-02477f66ebce](https://medium.com/@futureprooftrainings/derived-factors-and-eligibility-profile-in-absence-management-module-02477f66ebce)  
14. Check If Retroactive Changes Allowed in Period \- SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/docs/successfactors-time-tracking/implementing-time-management-in-sap-successfactors-083e8bcccdbc40249f82a5e4b1efcfdc/check-if-retroactive-changes-allowed-in-period?version=2505](https://help.sap.com/docs/successfactors-time-tracking/implementing-time-management-in-sap-successfactors-083e8bcccdbc40249f82a5e4b1efcfdc/check-if-retroactive-changes-allowed-in-period?version=2505)  
15. Ontology primitives \- Dynamic Scheduling \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/dynamic-scheduling/scheduling-ontology-primitives/](https://palantir.com/docs/foundry/dynamic-scheduling/scheduling-ontology-primitives/)  
16. Time Management in SAP SuccessFactors Employee Central, truy cập vào tháng 2 11, 2026, [https://blog.sap-press.com/time-management-in-sap-successfactors-employee-central](https://blog.sap-press.com/time-management-in-sap-successfactors-employee-central)  
17. Federal Holidays \- Work Schedules and Pay \- OPM, truy cập vào tháng 2 11, 2026, [https://www.opm.gov/policy-data-oversight/pay-leave/pay-administration/fact-sheets/holidays-work-schedules-and-pay/](https://www.opm.gov/policy-data-oversight/pay-leave/pay-administration/fact-sheets/holidays-work-schedules-and-pay/)  
18. Understanding Immutable Ledger Technology: A Beginner's Guide | by Ben Reamico, truy cập vào tháng 2 11, 2026, [https://medium.com/@benreamico/understanding-immutable-ledger-technology-a-beginners-guide-848dbe634aed](https://medium.com/@benreamico/understanding-immutable-ledger-technology-a-beginners-guide-848dbe634aed)  
19. Models in the Ontology \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/ontology/models/](https://palantir.com/docs/foundry/ontology/models/)  
20. Optimize performance \- Functions • TypeScript v1 \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/functions/optimize-performance/](https://palantir.com/docs/foundry/functions/optimize-performance/)  
21. Creating Custom Calendars for Accurate Working Day Calculation in Power BI, truy cập vào tháng 2 11, 2026, [https://community.fabric.microsoft.com/t5/Power-BI-Community-Blog/Creating-Custom-Calendars-for-Accurate-Working-Day-Calculation/ba-p/3717288](https://community.fabric.microsoft.com/t5/Power-BI-Community-Blog/Creating-Custom-Calendars-for-Accurate-Working-Day-Calculation/ba-p/3717288)  
22. Workday Absence Management, truy cập vào tháng 2 11, 2026, [https://www.workday.com/content/dam/web/en-us/documents/datasheets/workday-absence-management-datasheet-en-us.pdf](https://www.workday.com/content/dam/web/en-us/documents/datasheets/workday-absence-management-datasheet-en-us.pdf)  
23. How You Configure Eligibility for an Absence Plan \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-configure-eligibility-for-an-absence-plan.html](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-configure-eligibility-for-an-absence-plan.html)  
24. How You Configure Eligibility for Absence Plans \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-configure-eligibility-for-absence-plans.html](https://docs.oracle.com/en/cloud/saas/human-resources/faiam/how-you-configure-eligibility-for-absence-plans.html)  
25. NEED HELP VACATION PLAN\! : r/workday \- Reddit, truy cập vào tháng 2 11, 2026, [https://www.reddit.com/r/workday/comments/1kwafjl/need\_help\_vacation\_plan/](https://www.reddit.com/r/workday/comments/1kwafjl/need_help_vacation_plan/)  
26. Time Account Types | SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/docs/successfactors-employee-central/manage-time-off-test-script/time-account-types](https://help.sap.com/docs/successfactors-employee-central/manage-time-off-test-script/time-account-types)  
27. Dynamic Scheduling • Getting started \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/dynamic-scheduling/scheduling-getting-started/](https://palantir.com/docs/foundry/dynamic-scheduling/scheduling-getting-started/)  
28. Immutable Ledger at Scale: Solving Double-Spend in Distributed Payment Systems, truy cập vào tháng 2 11, 2026, [https://systemdrd.com/newsletters/ledger-system-design-scale/](https://systemdrd.com/newsletters/ledger-system-design-scale/)  
29. Designing high-performance financial ledgers with Temporal, truy cập vào tháng 2 11, 2026, [https://temporal.io/blog/designing-high-performance-financial-ledgers-with-temporal](https://temporal.io/blog/designing-high-performance-financial-ledgers-with-temporal)  
30. Retroactive Processing of Elements \- Oracle Help Center, truy cập vào tháng 2 11, 2026, [https://docs.oracle.com/en/cloud/saas/human-resources/facpe/retroactive-processing-of-Elements.html](https://docs.oracle.com/en/cloud/saas/human-resources/facpe/retroactive-processing-of-Elements.html)  
31. Retroactive Payroll Processing: Test Script \- SAP Help Portal, truy cập vào tháng 2 11, 2026, [https://help.sap.com/doc/533181c99bdb4b588b56a53c5aec01b9/2311/en-US/Retroactive\_Payroll\_Processing\_Test\_Script\_10F.pdf](https://help.sap.com/doc/533181c99bdb4b588b56a53c5aec01b9/2311/en-US/Retroactive_Payroll_Processing_Test_Script_10F.pdf)  
32. Best Practices for Balance Initialization: A Structured Approach | fusionhcmcoe, truy cập vào tháng 2 11, 2026, [https://blogs.oracle.com/fusionhcmcoe/best-practices-for-balance-initialization-a-structured-approach](https://blogs.oracle.com/fusionhcmcoe/best-practices-for-balance-initialization-a-structured-approach)  
33. Workday Absence Management Datasheet, truy cập vào tháng 2 11, 2026, [https://www.workday.com/content/dam/web/uk/documents/datasheets/workday-absence-management-datasheet.pdf](https://www.workday.com/content/dam/web/uk/documents/datasheets/workday-absence-management-datasheet.pdf)  
34. Understanding Time Off and Leave of Absence | Human Resources | UW–Madison, truy cập vào tháng 2 11, 2026, [https://hr.wisc.edu/hr-guides/for-employees/understanding-time-off-and-leave-of-absence/](https://hr.wisc.edu/hr-guides/for-employees/understanding-time-off-and-leave-of-absence/)  
35. Action types • Side effects • Set up a webhook \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/action-types/set-up-webhook/](https://palantir.com/docs/foundry/action-types/set-up-webhook/)  
36. API: Object sets \- Functions \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/functions/api-object-sets/](https://palantir.com/docs/foundry/functions/api-object-sets/)  
37. Integrate data for the map • Search Arounds for the map \- Palantir, truy cập vào tháng 2 11, 2026, [https://palantir.com/docs/foundry/map/integrate-searcharounds/](https://palantir.com/docs/foundry/map/integrate-searcharounds/)  
38. How to access linked objects through typescript functions for Workshop?, truy cập vào tháng 2 11, 2026, [https://community.palantir.com/t/how-to-access-linked-objects-through-typescript-functions-for-workshop/1007](https://community.palantir.com/t/how-to-access-linked-objects-through-typescript-functions-for-workshop/1007)