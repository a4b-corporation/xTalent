# Thuật ngữ Cơ sở vật chất (Facility Glossary)

## Tổng quan

Bảng thuật ngữ này định nghĩa các thực thể về cơ sở vật chất và địa điểm làm việc được sử dụng trong hệ thống xTalent HCM. Các thực thể Facility hỗ trợ quản lý địa điểm vật lý, theo dõi địa điểm làm việc và quy hoạch không gian.

---

## Các thực thể (Entities)

### Place (Địa điểm)

**Định nghĩa:** Địa điểm địa lý chung hoặc điểm quan tâm (point of interest) có thể được tham chiếu cho nhiều mục đích khác nhau (cuộc họp, sự kiện, cơ sở vật chất).

**Mục đích:**
- Định nghĩa các địa điểm địa lý chung
- Hỗ trợ các dịch vụ dựa trên vị trí
- Cho phép tìm kiếm và khám phá dựa trên địa điểm
- Cung cấp nền tảng cho các địa điểm làm việc (work locations)

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã địa điểm |
| `name` | string(150) | Không | Tên địa điểm |
| `place_type` | enum | Không | BUILDING (Tòa nhà), CAMPUS (Khuôn viên), FLOOR (Tầng), ROOM (Phòng), OUTDOOR (Ngoài trời), VIRTUAL (Ảo) |
| `country_id` | UUID | Không | Tham chiếu quốc gia |
| `admin_area_id` | UUID | Không | Tham chiếu khu vực hành chính |
| `address_line1` | string(255) | Không | Dòng địa chỉ 1 |
| `address_line2` | string(255) | Không | Dòng địa chỉ 2 |
| `postal_code` | string(20) | Không | Mã bưu chính |
| `latitude` | decimal(9,6) | Không | Vĩ độ địa lý |
| `longitude` | decimal(9,6) | Không | Kinh độ địa lý |
| `timezone_id` | UUID | Không | Tham chiếu múi giờ |
| `description` | text | Không | Mô tả địa điểm |
| `metadata` | jsonb | Không | Các thuộc tính bổ sung của địa điểm |
| `is_active` | boolean | Có | Trạng thái hoạt động (mặc định: true) |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại địa điểm (Place Types):**

| Loại | Mô tả | Ví dụ |
|------|-------|-------|
| `BUILDING` | Tòa nhà vật lý | Tòa nhà văn phòng, Nhà máy |
| `CAMPUS` | Khuôn viên với nhiều tòa nhà | Khuôn viên công ty |
| `FLOOR` | Tầng trong tòa nhà | Tầng 5 |
| `ROOM` | Phòng hoặc không gian | Phòng họp, Văn phòng |
| `OUTDOOR` | Địa điểm ngoài trời | Bãi đậu xe, Vườn |
| `VIRTUAL` | Địa điểm ảo | Hội nghị truyền hình, Làm việc từ xa |

**Cấu trúc Metadata:**
```json
{
  "building_info": {
    "building_name": "VNG Tower",
    "total_floors": 15,
    "year_built": 2015,
    "building_class": "A"
  },
  "accessibility": {
    "wheelchair_accessible": true,
    "elevator_available": true,
    "parking_available": true
  },
  "amenities": [
    "Cafeteria",
    "Gym",
    "Prayer room",
    "Lactation room"
  ],
  "security": {
    "access_control": "CARD_READER",
    "security_desk": true,
    "cctv": true
  },
  "contact": {
    "facility_manager": "worker_fm_001",
    "phone": "+84 24 7300 8855",
    "email": "facility@vng.com.vn"
  }
}
```

**Mối quan hệ:**
- **Tham chiếu đến** `Country`
- **Tham chiếu đến** `AdminArea`
- **Tham chiếu đến** `TimeZone`
- **Có nhiều** `Location` (các vị trí tại địa điểm này)
- **Có nhiều** `WorkLocation` (các địa điểm làm việc)

**Quy tắc nghiệp vụ:**
- Mã địa điểm phải là duy nhất
- Tọa độ nên chính xác để phục vụ bản đồ
- Múi giờ phải khớp với vị trí địa lý
- Sử dụng SCD Type 2 để theo dõi lịch sử

**Ví dụ:**

```yaml
# Tòa nhà
id: place_vng_tower
code: VNG_TOWER
name: "VNG Tower"
place_type: BUILDING
country_id: country_vn_001
admin_area_id: admin_vn_hanoi
address_line1: "182 Le Dai Hanh Street"
address_line2: "Hai Ba Trung District"
postal_code: "100000"
latitude: 21.013715
longitude: 105.846411
timezone_id: tz_asia_hcm
metadata:
  building_info:
    total_floors: 15
    year_built: 2015

# Địa điểm ảo
id: place_remote
code: REMOTE
name: "Remote Work"
place_type: VIRTUAL
description: "Virtual location for remote workers"
```

---

### Location (Vị trí)

**Định nghĩa:** Vị trí cụ thể bên trong hoặc liên quan đến một địa điểm (Place), cung cấp khả năng theo dõi vị trí chi tiết hơn.

**Mục đích:**
- Định nghĩa các vị trí cụ thể bên trong các địa điểm
- Hỗ trợ quản lý không gian chi tiết
- Cho phép kiểm soát truy cập dựa trên vị trí
- Theo dõi sức chứa và công suất sử dụng của vị trí

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã vị trí |
| `name` | string(150) | Không | Tên vị trí |
| `place_id` | UUID | Có | Tham chiếu địa điểm (Place) |
| `parent_location_id` | UUID | Không | Vị trí cha (cho phân cấp) |
| `location_type` | enum | Không | OFFICE, MEETING_ROOM, WORKSPACE, COMMON_AREA, STORAGE |
| `floor_number` | string(10) | Không | Số tầng |
| `room_number` | string(20) | Không | Số phòng |
| `capacity` | integer | Không | Sức chứa tối đa (người) |
| `area_sqm` | decimal(10,2) | Không | Diện tích tính bằng mét vuông |
| `description` | text | Không | Mô tả vị trí |
| `metadata` | jsonb | Không | Các thuộc tính bổ sung của vị trí |
| `is_active` | boolean | Có | Trạng thái hoạt động |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các loại vị trí (Location Types):**

| Loại | Mô tả |
|------|-------|
| `OFFICE` | Văn phòng cá nhân hoặc chia sẻ |
| `MEETING_ROOM` | Phòng họp hoặc hội nghị |
| `WORKSPACE` | Không gian làm việc mở, bàn làm việc linh hoạt (hot desk) |
| `COMMON_AREA` | Nhà ăn, sảnh, phòng nghỉ |
| `STORAGE` | Phòng kho, lưu trữ |
| `FACILITY` | Phòng tập gym, phòng cầu nguyện, phòng vắt sữa |

**Cấu trúc Metadata:**
```json
{
  "room_features": {
    "seating_capacity": 10,
    "has_projector": true,
    "has_whiteboard": true,
    "has_video_conference": true,
    "equipment": ["TV Screen", "Conference Phone"]
  },
  "booking": {
    "is_bookable": true,
    "booking_system_id": "ROOM_5F_CONF_A",
    "advance_booking_days": 30,
    "max_booking_hours": 4
  },
  "assignment": {
    "assigned_to_department": "bu_engineering",
    "assigned_workers": ["worker_001", "worker_002"],
    "assignment_type": "DEDICATED"
  },
  "maintenance": {
    "last_inspection": "2025-11-15",
    "next_inspection": "2026-05-15",
    "maintenance_schedule": "QUARTERLY"
  }
}
```

**Mối quan hệ:**
- **Thuộc về** `Place`
- **Thuộc về** `Location` (vị trí cha)
- **Có nhiều** `Location` (vị trí con)
- **Có nhiều** `WorkLocation` (các gán địa điểm làm việc)

**Quy tắc nghiệp vụ:**
- Mã vị trí phải là duy nhất trong một địa điểm (Place)
- Sức chứa không được vượt quá sức chứa của địa điểm
- Hỗ trợ phân cấp cha-con
- Sử dụng SCD Type 2 để theo dõi lịch sử

**Ví dụ:**

```yaml
# Phòng họp
id: loc_5f_conf_a
code: 5F_CONF_A
name: "5th Floor Conference Room A"
place_id: place_vng_tower
location_type: MEETING_ROOM
floor_number: "5"
room_number: "5A"
capacity: 10
area_sqm: 25.0
metadata:
  room_features:
    seating_capacity: 10
    has_video_conference: true
  booking:
    is_bookable: true

# Không gian làm việc mở
id: loc_3f_workspace
code: 3F_WORKSPACE
name: "3rd Floor Open Workspace"
place_id: place_vng_tower
location_type: WORKSPACE
floor_number: "3"
capacity: 50
area_sqm: 200.0
metadata:
  workspace_type: "HOT_DESK"
  desk_count: 50
```

---

### WorkLocation (Địa điểm làm việc)

**Định nghĩa:** Gán địa điểm làm việc liên kết nhân viên với các địa điểm vật lý hoặc ảo chính hoặc phụ của họ. Hỗ trợ các mô hình làm việc kết hợp (hybrid).

**Mục đích:**
- Gán nhân viên vào các địa điểm làm việc
- Hỗ trợ các mô hình làm việc kết hợp (hybrid) và từ xa (remote)
- Theo dõi số lượng nhân sự theo địa điểm
- Cho phép báo cáo và tuân thủ dựa trên địa điểm

**Các thuộc tính chính:**

| Thuộc tính | Kiểu dữ liệu | Bắt buộc | Mô tả |
|------------|--------------|----------|-------|
| `id` | UUID | Có | Định danh duy nhất |
| `code` | string(50) | Có | Mã địa điểm làm việc |
| `name` | string(150) | Không | Tên địa điểm làm việc |
| `location_id` | UUID | Không | Tham chiếu vị trí vật lý (null nếu làm từ xa) |
| `place_id` | UUID | Không | Tham chiếu địa điểm (Place) (phi chuẩn hóa) |
| `work_model` | enum | Có | ONSITE, REMOTE, HYBRID |
| `is_primary` | boolean | Có | Cờ địa điểm làm việc chính |
| `description` | text | Không | Mô tả địa điểm làm việc |
| `metadata` | jsonb | Không | Chi tiết mô hình làm việc, chính sách |
| `is_active` | boolean | Có | Trạng thái hoạt động |
| `effective_start_date` | date | Có | Ngày bắt đầu hiệu lực |
| `effective_end_date` | date | Không | Ngày kết thúc hiệu lực |
| `is_current_flag` | boolean | Có | Cờ chỉ định bản ghi hiện tại |

**Các mô hình làm việc (Work Models):**

| Mô hình | Mô tả | Yêu cầu địa điểm |
|---------|-------|------------------|
| `ONSITE` | Làm việc tại văn phòng toàn thời gian | Có |
| `REMOTE` | Làm việc từ xa toàn thời gian | Không (có thể là ảo) |
| `HYBRID` | Kết hợp làm việc tại văn phòng và từ xa | Có (địa điểm chính) |
| `FLEXIBLE` | Lựa chọn địa điểm linh hoạt | Tùy chọn |

**Cấu trúc Metadata:**
```json
{
  "work_model_details": {
    "onsite_days_per_week": 3,
    "required_onsite_days": ["MONDAY", "WEDNESDAY", "FRIDAY"],
    "flexible_days": ["TUESDAY", "THURSDAY"],
    "core_hours": "10:00-15:00"
  },
  "remote_work_policy": {
    "policy_code": "HYBRID_POLICY_2025",
    "approval_required": false,
    "equipment_provided": true,
    "internet_allowance": 500000
  },
  "location_preferences": {
    "preferred_desk_type": "STANDING_DESK",
    "preferred_floor": "3",
    "parking_required": true,
    "parking_spot": "P3-A-015"
  },
  "compliance": {
    "tax_jurisdiction": "Hanoi",
    "labor_law_jurisdiction": "Vietnam",
    "data_residency": "Vietnam"
  }
}
```

**Mối quan hệ:**
- **Tham chiếu đến** `Location` (tùy chọn)
- **Tham chiếu đến** `Place` (phi chuẩn hóa)
- **Được tham chiếu bởi** `Assignment` (gán nhân viên)
- **Được tham chiếu bởi** `Position` (vị trí công việc)

**Quy tắc nghiệp vụ:**
- Mã địa điểm làm việc phải là duy nhất
- Địa điểm làm việc từ xa có thể không có tham chiếu vị trí vật lý
- Mô hình Hybrid yêu cầu địa điểm chính
- Sử dụng SCD Type 2 để theo dõi lịch sử
- Một địa điểm làm việc chính cho mỗi nhân viên

**Ví dụ:**

```yaml
# Địa điểm làm việc tại chỗ (Onsite)
id: wl_vng_tower_eng
code: VNG_TOWER_ENG
name: "VNG Tower - Engineering"
location_id: loc_3f_workspace
place_id: place_vng_tower
work_model: ONSITE
is_primary: true
metadata:
  department: "Engineering"
  desk_assignment: "HOT_DESK"

# Địa điểm làm việc kết hợp (Hybrid)
id: wl_hybrid_hanoi
code: HYBRID_HANOI
name: "Hybrid - Hanoi Office"
location_id: loc_3f_workspace
place_id: place_vng_tower
work_model: HYBRID
is_primary: true
metadata:
  work_model_details:
    onsite_days_per_week: 3
    required_onsite_days: ["MON", "WED", "FRI"]

# Địa điểm làm việc từ xa (Remote)
id: wl_remote_vietnam
code: REMOTE_VN
name: "Remote - Vietnam"
location_id: null
place_id: place_remote
work_model: REMOTE
is_primary: true
metadata:
  remote_work_policy:
    policy_code: "REMOTE_POLICY_2025"
    equipment_provided: true
```

---

## Các mô hình địa điểm làm việc (Work Location Models)

### Mô hình Tại chỗ (Onsite Model)

**Mô tả:** Làm việc tại văn phòng toàn thời gian theo truyền thống.

**Đặc điểm:**
- Địa điểm văn phòng cố định
- Bàn làm việc hoặc không gian làm việc được chỉ định
- Giờ làm việc văn phòng tiêu chuẩn
- Truy cập đầy đủ các tiện ích văn phòng

**Ví dụ:**
```
Employee → WorkLocation (ONSITE) → Location (Office) → Place (Building)
```

### Mô hình Từ xa (Remote Model)

**Mô tả:** Làm việc toàn thời gian tại nhà hoặc địa điểm từ xa.

**Đặc điểm:**
- Không có địa điểm văn phòng cố định
- Thiết lập văn phòng tại nhà
- Giờ làm việc linh hoạt (thường là vậy)
- Công cụ cộng tác ảo

**Ví dụ:**
```
Employee → WorkLocation (REMOTE) → Place (VIRTUAL)
```

### Mô hình Kết hợp (Hybrid Model)

**Mô tả:** Kết hợp giữa làm việc tại chỗ và từ xa.

**Đặc điểm:**
- Địa điểm văn phòng chính
- Các ngày làm việc tại chỗ theo lịch trình
- Các ngày làm việc từ xa linh hoạt
- Bàn làm việc linh hoạt (hot desk) hoặc không gian làm việc chia sẻ

**Ví dụ:**
```
Employee → WorkLocation (HYBRID) → Location (Hot Desk) → Place (Building)
         → Remote days per policy
```

---

## Các trường hợp sử dụng (Use Cases)

### Quản lý không gian (Space Management)
- Theo dõi mức độ sử dụng không gian văn phòng
- Lập kế hoạch sắp xếp chỗ ngồi
- Quản lý đặt bàn làm việc linh hoạt (hot desk)
- Tối ưu hóa phân bổ không gian

### Quản lý làm việc kết hợp (Hybrid Work Management)
- Định nghĩa các chính sách làm việc kết hợp
- Lên lịch các ngày làm việc tại chỗ
- Theo dõi tuân thủ địa điểm
- Hỗ trợ sắp xếp làm việc linh hoạt

### Tuân thủ & Báo cáo (Compliance & Reporting)
- Theo dõi địa điểm làm việc cho mục đích thuế
- Báo cáo số lượng nhân sự theo địa điểm
- Đảm bảo tuân thủ luật lao động
- Hỗ trợ các yêu cầu về cư trú dữ liệu

### Quy hoạch cơ sở vật chất (Facility Planning)
- Dự báo nhu cầu không gian
- Lập kế hoạch mở rộng hoặc hợp nhất văn phòng
- Tối ưu hóa chi phí cơ sở vật chất
- Hỗ trợ các quyết định về bất động sản

### Trải nghiệm nhân viên (Employee Experience)
- Cho phép tùy chọn địa điểm
- Hỗ trợ cân bằng công việc - cuộc sống
- Cung cấp các dịch vụ dựa trên địa điểm
- Tạo điều kiện cộng tác

---

## Các thực hành tốt nhất (Best Practices)

### Quản lý dữ liệu địa điểm

1. **Mã hóa địa lý chính xác:**
   - Duy trì tọa độ chính xác
   - Xác minh địa chỉ thường xuyên
   - Cập nhật thông tin múi giờ
   - Giữ thông tin liên hệ cập nhật

2. **Quản lý phân cấp:**
   - Sử dụng phân cấp địa điểm - vị trí (place-location)
   - Hỗ trợ cấu trúc đa cấp
   - Cho phép kế thừa địa điểm
   - Duy trì mối quan hệ cha-con

3. **Lập kế hoạch năng lực:**
   - Theo dõi năng lực thực tế so với kế hoạch
   - Giám sát tỷ lệ lấp đầy
   - Lập kế hoạch cho sự tăng trưởng
   - Tối ưu hóa sử dụng không gian

### Triển khai làm việc kết hợp

1. **Chính sách rõ ràng:**
   - Định nghĩa các tùy chọn mô hình làm việc
   - Đặt kỳ vọng cho các ngày làm việc tại chỗ
   - Truyền đạt chính sách rõ ràng
   - Đánh giá chính sách thường xuyên

2. **Hỗ trợ công nghệ:**
   - Cung cấp các công cụ cộng tác
   - Kích hoạt hệ thống đặt bàn làm việc
   - Hỗ trợ truy cập từ xa
   - Đảm bảo tuân thủ bảo mật

3. **Tính linh hoạt:**
   - Cho phép tùy chọn địa điểm
   - Hỗ trợ linh hoạt lịch trình
   - Cho phép thay đổi địa điểm
   - Đáp ứng các nhu cầu đặc biệt

---

## Điểm tích hợp (Integration Points)

### Các mô-đun nội bộ

| Mô-đun | Sử dụng |
|--------|---------|
| **Core** | Gán nhân viên, Vị trí công việc |
| **Time & Attendance** | Geofencing chấm công, Theo dõi vị trí |
| **Payroll** | Khu vực thuế, Trả lương theo địa điểm |
| **Facilities** | Đặt chỗ không gian, Theo dõi bảo trì |

### Các hệ thống bên ngoài

| Hệ thống | Mục đích |
|----------|----------|
| **Building Management** | Kiểm soát truy cập, An ninh |
| **Desk Booking** | Đặt bàn làm việc linh hoạt |
| **Mapping Services** | Mã hóa địa lý, Chỉ đường |
| **Real Estate** | Quản lý thuê, Quy hoạch không gian |

---

## Chỉ số & KPIs (Metrics & KPIs)

### Sử dụng không gian

- **Tỷ lệ lấp đầy:** % không gian được sử dụng
- **Sử dụng bàn làm việc:** % bàn làm việc được sử dụng hàng ngày
- **Sử dụng phòng họp:** Số giờ được đặt so với số giờ có sẵn
- **Chi phí mỗi chỗ ngồi:** Tổng chi phí cơ sở vật chất / số chỗ ngồi

### Làm việc kết hợp

- **Đi làm tại chỗ:** % nhân viên tại chỗ hàng ngày
- **Tỷ lệ làm việc từ xa:** % lực lượng lao động làm từ xa
- **Áp dụng Hybrid:** % sử dụng mô hình kết hợp
- **Tuân thủ chính sách:** % tuân thủ yêu cầu ngày làm việc tại chỗ

### Quản lý cơ sở vật chất

- **Không gian mỗi nhân viên:** M2 mỗi nhân viên
- **Chi phí cơ sở vật chất:** Chi phí mỗi nhân viên mỗi tháng
- **Phản hồi bảo trì:** Thời gian giải quyết vấn đề
- **Sự hài lòng của nhân viên:** Điểm hài lòng về cơ sở vật chất

---

## Lịch sử phiên bản (Version History)

| Phiên bản | Ngày | Thay đổi |
|-----------|------|----------|
| 2.0 | 2025-12-01 | Thêm hỗ trợ làm việc kết hợp, các mô hình làm việc |
| 1.0 | 2025-11-01 | Ontology cơ sở vật chất ban đầu |

---

## Tài liệu tham khảo (References)

- **Tiêu chuẩn Quản lý Cơ sở vật chất:** Các thực hành tốt nhất trong ngành
- **Mô hình Làm việc Kết hợp:** Các chiến lược nơi làm việc hiện đại
- **Quy hoạch Không gian:** Thiết kế và sử dụng văn phòng
