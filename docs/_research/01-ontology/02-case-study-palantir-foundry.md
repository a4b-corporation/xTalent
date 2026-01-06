# Part 2: Case Study - Palantir Foundry (THE HOW)

Tài liệu này đi sâu vào kỹ thuật (Technical Deep Dive) về cách **Palantir Foundry** hiện thực hóa khái niệm Ontology. Đây là phần "HOW" - họ đã làm điều đó như thế nào.

## 1. Kiến trúc tổng quan: The Foundry Trinity

Palantir Foundry xây dựng Ontology xoay quanh 3 khái niệm cốt lõi (Trinity): **Object**, **Link**, và **Action**.

### 1.1 Object & Object Types (Backing Datasets)
Trong Foundry, một **Object Type** (ví dụ: `Aircraft`) được định nghĩa bằng cách map (ánh xạ) từ một **Backing Dataset** (thường là Spark/Parquet dataset đã được làm sạch).

*   **Primary Key:** Mỗi Object phải có một UID duy nhất.
*   **Title Property:** Một thuộc tính hiển thị (human-readable name).
*   **Properties Mapping:**
    *   Column `a_c_model` -> Property `Model`.
    *   Column `mfg_dt` -> Property `Manufacture Date`.

> **The "Write-back" Mechanism:** Điểm đặc biệt của Foundry là các Objects được đánh chỉ mục (indexed) vào một cơ sở dữ liệu chuyên dụng (thường là sự kết hợp của Search Index như Elasticsearch và Graph Database) để phục vụ truy vấn cực nhanh, tách biệt khỏi lớp lưu trữ dữ liệu lớn (Spark/Hadoop).

### 1.2 Links (Graph Traversal & Search Around)
Palantir không dùng `JOIN` bảng mỗi khi truy vấn. Họ định nghĩa **Link Types** trước.
Khi người dùng hoặc ứng dụng cần tìm dữ liệu liên quan, họ sử dụng tính năng gọi là **"Search Around"**.

*   Ví dụ: Từ `Aircraft` object -> Search Around -> `Flight` objects (tìm các chuyến bay của máy bay này) -> Search Around -> `Passenger` objects (tìm hành khách trên các chuyến đó).
*   **Kỹ thuật:** Việc này thực chất là duyệt đồ thị (Graph Traversal), hiệu năng cao hơn nhiều so với việc join nhiều bảng SQL lớn cùng lúc.

### 1.3 Actions (The Kinetic Layer)
Đây là thành phần quan trọng nhất biến Ontology từ "Read-only Catalog" thành "Operating System".
**Action Type** định nghĩa cách thay đổi dữ liệu.

Các thành phần của một Action:
1.  **Parameters:** Đầu vào (ví dụ: `New Status`, `Assignee ID`, `Comment`).
2.  **Logic (Functions):** Đoạn mã (thường là **TypeScript** hoặc **Java**) chạy server-side để thực thi logic.
    *   Ví dụ: *Khi đổi trạng thái Aircraft sang "Maintenance", tự động hủy các chuyến bay trong 24h tới.*
3.  **Side Effects (Write-back):**
    *   Hệ thống sẽ ghi một event vào "Write-back Dataset".
    *   Dataset này ngay lập tức được merge vào Ontology.
    *   **Kết quả:** User thấy trạng thái cập nhật **ngay lập tức** (Real-time reactivity) mà không cần chờ ETL pipeline chạy lại vào cuối ngày.

## 2. Dynamic Layer: Applications (Workshop)

Palantir giải quyết bài toán phát triển ứng dụng bằng công cụ **Workshop**.
Thay vì viết SQL query trong code Frontend, Workshop bind (gắn) trực tiếp vào Ontology.

*   **Object Set:** Khái niệm cốt lõi của UI. Một màn hình không load "dữ liệu", mà load một "Object Set" (Tập hợp các Objects).
    *   Ví dụ: `Active Employees in Sales Dept`.
*   **Widget Binding:**
    *   Table Widget: Bind vào `Employee Object Set`.
    *   Detail Widget: Bind vào `Selected Employee`.
    *   Button: Bind vào `Action: Promote Employee`.

**Cơ chế này giúp:**
*   **Decoupling:** Nếu DB bên dưới đổi tên cột, chỉ cần sửa mapping ở lớp Ontology. Ứng dụng (Workshop) không hề bị lỗi (break).
*   **Reusability:** Action `Promote Employee` được viết 1 lần, có thể gắn vào nút bấm ở 10 ứng dụng khác nhau.

## 3. The Feature: "Time Travel" & Provenance

Do Foundry xây dựng Ontology trên nền tảng Big Data (Spark), nó hỗ trợ tính năng **Provenance** (Dòng chảy dữ liệu).
*   Bạn có thể xem lại trạng thái của một Object tại bất kỳ thời điểm nào trong quá khứ.
*   Bạn có thể truy vết (trace) xem Property `Maintenance Status` của chiếc máy bay này đã bị thay đổi bởi **Action** nào, do **User** nào thực hiện, vào **lúc** nào.

## Tóm tắt kỹ thuật
Palantir Foundry đã xây dựng một lớp **Middleware** (Ontology Service) cực mạnh:
1.  **Ingest:** Hút dữ liệu từ mọi nơi vào Data Lake.
2.  **Model:** Định nghĩa Object/Link.
3.  **Index:** Đẩy dữ liệu vào Index tốc độ cao (Search/Graph).
4.  **Act:** Cung cấp API (Actions) để ghi nhận thay đổi (Write-back) và đồng bộ ngược lại Data Lake.
