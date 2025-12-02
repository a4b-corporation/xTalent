# Hướng dẫn Kỹ thuật: SCD Type 2 Implementation

**Phiên bản**: 1.0  
**Ngày cập nhật**: 2025-12-02  
**Module**: Core (CO)  
**Đối tượng**: Developers, Business Analysts (BA), Quality Control (QC)

---

## 1. Giới thiệu về SCD Type 2

**SCD Type 2 (Slowly Changing Dimension Type 2)** là kỹ thuật thiết kế cơ sở dữ liệu nhằm theo dõi lịch sử thay đổi của dữ liệu theo thời gian. Thay vì ghi đè dữ liệu cũ (như Type 1), hệ thống sẽ tạo ra một dòng dữ liệu mới mỗi khi có thay đổi, giữ lại dòng cũ làm lịch sử.

Trong hệ thống HR xTalent, SCD Type 2 là **bắt buộc** đối với các entity quan trọng như `Worker`, `Assignment`, `Position`, `Organization Unit` để đảm bảo:
- Truy vết toàn bộ lịch sử thay đổi (Audit trail).
- Báo cáo tại bất kỳ thời điểm nào trong quá khứ (Point-in-time reporting).
- Xử lý các thay đổi trong tương lai (Future-dated changes).

---

## 2. Mô hình Dữ liệu Mở rộng (Extended Model)

Chúng ta sử dụng mô hình SCD Type 2 mở rộng với 3 trường thông tin cốt lõi:

| Tên trường | Kiểu dữ liệu | Ý nghĩa |
|------------|--------------|---------|
| `effective_start_date` | Date/DateTime | Ngày bắt đầu hiệu lực của bản ghi này. |
| `effective_end_date` | Date/DateTime | Ngày kết thúc hiệu lực. Nếu là bản ghi hiện tại, giá trị thường là `NULL` hoặc `9999-12-31`. |
| `is_current_flag` | Boolean | Cờ đánh dấu bản ghi hiện tại (mới nhất) để truy vấn nhanh. |

### Cấu trúc bảng ví dụ (Worker)

| row_id (PK) | worker_id (Business Key) | name | effective_start_date | effective_end_date | is_current_flag |
|-------------|--------------------------|------|----------------------|--------------------|-----------------|
| 101 | W001 | Nguyen Van A | 2023-01-01 | 2023-12-31 | false |
| 102 | W001 | Nguyen Van A | 2024-01-01 | NULL | true |

*Lưu ý: `row_id` là Surrogate Key (khóa đại diện) duy nhất cho mỗi dòng, còn `worker_id` là Business Key (khóa nghiệp vụ) không đổi cho một nhân viên.*

### Giải pháp Kiến trúc: Master-History Pattern (Advanced)

Để giải quyết vấn đề **Foreign Key Constraint** (không thể trỏ FK tới cột không unique), ta áp dụng mô hình tách bảng:

1.  **Bảng Master (Identity)**: Chứa ID bất biến (`UUID`) và Mã (`Code`). Đây là đích đến của FK từ các bảng con.
2.  **Bảng History (State)**: Chứa dữ liệu thay đổi và các cột SCD2. Link ngược về Master.

---

## 3. Các Thao tác Dữ liệu (CRUD Operations)

### 3.1. INSERT (Tạo mới)
Khi tạo một đối tượng mới chưa từng tồn tại.

**Hành động:**
1.  Insert dòng mới.
2.  `effective_start_date` = Ngày hiệu lực (thường là ngày tạo hoặc ngày user chọn).
3.  `effective_end_date` = NULL (hoặc Max Date).
4.  `is_current_flag` = `true`.

### 3.2. UPDATE (Cập nhật thông tin)

Có 2 loại update: **Historical Change** (Thay đổi có tính lịch sử) và **Correction** (Sửa sai).

#### A. Historical Change (Ví dụ: Thăng chức, Tăng lương)
User muốn lưu lại lịch sử cũ và áp dụng giá trị mới từ một ngày cụ thể.

**Hành động:**
1.  **Bước 1 (Đóng dòng cũ):** Tìm dòng đang active (`is_current_flag = true`).
    -   Update `effective_end_date` = (Ngày hiệu lực mới - 1 ngày/giây).
    -   Update `is_current_flag` = `false`.
2.  **Bước 2 (Tạo dòng mới):** Insert dòng mới với thông tin mới.
    -   `effective_start_date` = Ngày hiệu lực mới.
    -   `effective_end_date` = NULL.
    -   `is_current_flag` = `true`.

#### B. Correction (Ví dụ: Sửa lỗi chính tả tên)
User muốn sửa lỗi sai, không cần lưu lại lịch sử "sai".

**Hành động:**
-   Update trực tiếp vào dòng hiện tại (`is_current_flag = true`).
-   Không thay đổi `effective_start_date` hay `effective_end_date`.

### 3.3. DELETE (Xóa)

#### A. Logical Delete (Kết thúc hiệu lực)
Ví dụ: Nhân viên nghỉ việc, Phòng ban giải thể.

**Hành động:**
-   Update dòng hiện tại:
    -   `effective_end_date` = Ngày kết thúc (Termination Date).
    -   `is_current_flag` = `false`.
-   Không insert dòng mới.

#### B. Physical Delete (Xóa hẳn)
Chỉ dùng khi tạo nhầm dữ liệu rác. Xóa dòng khỏi database.

---

## 4. Chiến lược Quan hệ & Versioning (Advanced)

Đây là phần phức tạp nhất. Chúng ta sử dụng **Mô hình Master-History** để giải quyết các bài toán liên kết và versioning.

### 4.1. Nguyên tắc Liên kết (Linking Strategy)

> **Quy tắc Vàng:** Child Table luôn trỏ Foreign Key tới **Master ID** (Immutable ID) của Parent, KHÔNG trỏ tới **History Row ID**.

**Tại sao?**
-   Nếu Child trỏ tới `History Row ID`: Khi Parent có version mới (Row ID mới), ta phải update/copy toàn bộ các dòng Child sang ID mới -> Gây "Write Amplification" (ghi thừa thãi) và phức tạp hóa logic.
-   Nếu Child trỏ tới `Master ID`: Parent thay đổi version thoải mái, Child vẫn giữ nguyên liên kết vì Master ID không đổi.

### 4.2. Các Chiến lược Versioning (Parent-Child)

Khi dữ liệu thay đổi, ta cần quyết định xem có cần tạo version mới cho Parent hay không.

#### Chiến lược A: Loose Coupling (Liên kết lỏng) - *Khuyên dùng*
*Áp dụng: Worker - Address, Dept - Employee, Worker - Skill*

-   **Cơ chế:** Parent và Child có vòng đời (lifecycle) độc lập.
-   **Kịch bản 1: Parent thay đổi** (ví dụ: Đổi tên Worker)
    -   Tạo dòng mới trong `Worker_History`.
    -   Child (`Address`) vẫn trỏ về `Worker_Master_ID`.
    -   -> **Không cần làm gì với Child.** Hệ thống tự hiểu Child thuộc về "Worker này" bất kể version nào.
-   **Kịch bản 2: Child thay đổi** (ví dụ: Sửa địa chỉ)
    -   Update/Insert bảng `Address`.
    -   -> **Parent KHÔNG tăng version.** Việc sửa địa chỉ không làm thay đổi bản chất của Worker.

#### Chiến lược B: Tight Coupling (Liên kết chặt)
*Áp dụng: Invoice - InvoiceLine, Contract - ContractTerm (khi cần snapshot)*

-   **Cơ chế:** Child là một phần cấu thành không thể tách rời của một version cụ thể.
-   **Kịch bản:** Nếu sửa `ContractTerm`, về mặt pháp lý là `Contract` đã thay đổi.
-   **Xử lý:**
    -   Tạo version mới cho Parent (`Contract`).
    -   **Copy toàn bộ** Child sang version mới (nếu link theo History ID) hoặc đánh dấu versioning trên cả Child.
    -   *Lưu ý: Chỉ dùng khi bắt buộc phải snapshot toàn bộ trạng thái document.*

### 4.3. Các Case Cụ thể

#### Case 1: Link SCD2 ↔ SCD2 (Ví dụ: Assignment ↔ Position)
Cả 2 đều có lịch sử.
-   **Thiết kế:** `Assignment` chứa `position_master_id`.
-   **Truy vấn:** Join `Assignment_History` với `Position_History` qua `master_id` VÀ điều kiện thời gian:
    ```sql
    ON a.position_master_id = p.master_id 
    AND a.effective_start_date BETWEEN p.start_date AND p.end_date
    ```

#### Case 2: Parent (SCD2) - Child (Non-SCD2)
Ví dụ: `Worker` (SCD2) có danh sách `Document` (Non-SCD2).
-   **Thiết kế:** `Document` trỏ về `worker_master_id`.
-   **Hành vi:** Khi Worker đổi version, Document tự động "đi theo" version mới nhất.

#### Case 3: Parent - Child (1-1)
Ví dụ: `Worker` ↔ `WorkerProfile`.
-   **Giải pháp:** Tách thành 2 bảng SCD2 riêng biệt (`Worker_History`, `Profile_History`) cùng link vào `Worker_Master`.
-   Khi update Profile -> Chỉ tăng version bảng Profile. Bảng Worker giữ nguyên. Tiết kiệm dung lượng lưu trữ.

---

## 5. Các Kịch bản Đặc biệt (Edge Cases)

### 5.1. Future Dated Updates (Thay đổi trong tương lai)
User set ngày hiệu lực là tháng sau.
-   Insert dòng mới với `effective_start_date` = Future Date.
-   `is_current_flag` = `false` (vì chưa đến ngày).
-   Dòng hiện tại vẫn giữ `is_current_flag` = `true`, nhưng `effective_end_date` phải được update để khớp với ngày start của dòng tương lai.
-   **Job chạy đêm:** Cần job quét hàng ngày để switch `is_current_flag` khi đến ngày hiệu lực.

### 5.2. Retroactive Updates (Sửa đổi quá khứ)
User quên nhập liệu, giờ muốn bổ sung một thay đổi đã xảy ra tháng trước.
-   Đây là case khó nhất. Cần phải:
    1.  Tìm bản ghi bao trùm khoảng thời gian đó.
    2.  Cắt bản ghi đó thành 2 phần (trước và sau thay đổi).
    3.  Chèn bản ghi mới vào giữa.
    4.  Sắp xếp lại chuỗi thời gian (chaining) để đảm bảo tính liên tục.

---

## 6. Checklist cho Dev/BA/QC

### Cho Developer
- [ ] Luôn dùng `is_current_flag = true` cho các query lấy dữ liệu hiện tại.
- [ ] Khi Insert/Update, luôn đảm bảo tính liên tục của chuỗi thời gian (End Date cũ = Start Date mới - 1 đơn vị).
- [ ] Xử lý transaction cẩn thận để tránh dữ liệu rác (orphan versions).

### Cho BA
- [ ] Xác định rõ entity nào cần SCD2, entity nào không (để tránh phức tạp hóa hệ thống).
- [ ] Định nghĩa rõ quy tắc "Correction" vs "Historical Change" cho từng trường dữ liệu.

### Cho QC
- [ ] Test case: Update thông tin với ngày hiệu lực là hôm nay.
- [ ] Test case: Update thông tin với ngày hiệu lực trong tương lai.
- [ ] Test case: Update thông tin với ngày hiệu lực trong quá khứ (Retroactive).
- [ ] Test case: Verify `is_current_flag` luôn chỉ có 1 dòng là true cho mỗi Business Key.
- [ ] Test case: Verify khoảng thời gian không bị trùng lặp (Overlap) hoặc đứt quãng (Gap).
