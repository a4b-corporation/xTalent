# Cập Nhật Thiết Kế Database - Mô Hình Hierarchical 6 Cấp

> Tài liệu tóm tắt về việc chuyển đổi sang mô hình hierarchical 6 cấp cho Time & Attendance

---

## Tổng Quan

Thiết kế database đã được cập nhật để tuân thủ mô hình hierarchical 6 cấp theo tài liệu `Time_Attendance_Concept_Design.docx`.

### Mô Hình 6 Cấp

```
Level 1: TIME SEGMENT (Đơn vị nguyên tử)
    ↓
Level 2: SHIFT (Tổ hợp các segments)
    ↓
Level 3: DAY MODEL (Lịch làm việc hàng ngày)
    ↓
Level 4: PATTERN (Lịch làm việc theo chu kỳ)
    ↓
Level 5: WORK SCHEDULE RULE (Pattern + Calendar + Rotation)
    ↓
Level 6: ROSTER (Phân công thực tế)
```

---

## Chi Tiết Từng Cấp

### Level 1: TIME SEGMENT (Đơn vị nguyên tử)

**Table**: `ta.time_segment` (MỚI)

**Mục đích**: Đơn vị nhỏ nhất, nguyên tử của thời gian làm việc.

**Các loại segment**:
- `WORK` - Thời gian làm việc
- `BREAK` - Nghỉ giải lao
- `MEAL` - Nghỉ ăn
- `TRANSFER` - Di chuyển giữa các địa điểm

**Đặc điểm**:
- Có thể định nghĩa theo **relative time** (offset từ đầu ca) hoặc **absolute time** (giờ cố định)
- Có thuộc tính `is_paid` (có trả lương không)
- Có thể gắn `cost_center_code`, `job_code`, `premium_code` cho payroll

**Ví dụ**:
```sql
-- Segment 1: Work morning (relative)
INSERT INTO ta.time_segment VALUES
  (uuid, 'WORK_MORNING', 'Morning Work', 'WORK',
   0, 240, null, null, 240,  -- 0-240 min (4 hours)
   true, true, null, null, null, ...);

-- Segment 2: Lunch break (absolute)
INSERT INTO ta.time_segment VALUES
  (uuid, 'LUNCH', 'Lunch Break', 'MEAL',
   null, null, '12:00', '13:00', 60,  -- 12:00-13:00 (1 hour)
   false, true, null, null, null, ...);
```

---

### Level 2: SHIFT (Tổ hợp các segments)

**Table**: `ta.shift_def` (GIỮ TÊN, bổ sung fields)

**Mục đích**: Tổ hợp các time segments thành một ca làm việc hoàn chỉnh.

**3 loại shift**:
- `ELAPSED` - Ca cố định (fixed schedule)
- `PUNCH` - Ca linh hoạt (clock in/out)
- `FLEX` - Ca lai (hybrid)

**Thay đổi chính**:
```sql
-- Thêm fields mới
shift_type varchar(20)           -- ELAPSED | PUNCH | FLEX
reference_start_time time
reference_end_time time
total_work_hours decimal(5,2)
total_break_hours decimal(5,2)
total_paid_hours decimal(5,2)
cross_midnight boolean
grace_in_minutes int             -- Cho PUNCH type
grace_out_minutes int
rounding_interval_min int
rounding_mode varchar(20)
```

**Relationship table**: `ta.shift_segment` (MỚI)
- Liên kết shift với các segments
- Có `sequence_order` để đảm bảo thứ tự
- Có thể override properties của segment

**Ví dụ**:
```sql
-- Shift: Day Shift 8-17
INSERT INTO ta.shift_def VALUES
  (uuid, 'DAY_SHIFT', 'Day Shift 8-5', 'ELAPSED',
   '08:00', '17:00', 8.0, 1.0, 8.0, false, ...);

-- Liên kết segments
INSERT INTO ta.shift_segment VALUES
  (shift_id, work_morning_id, 1, null, null),  -- Sequence 1
  (shift_id, lunch_id, 2, null, null),         -- Sequence 2
  (shift_id, work_afternoon_id, 3, null, null); -- Sequence 3
```

---

### Level 3: DAY MODEL (Lịch làm việc hàng ngày)

**Table**: `ta.day_model` (MỚI)

**Mục đích**: Định nghĩa một ngày trong lịch làm việc.

**Các loại day**:
- `WORK` - Ngày làm việc (có shift)
- `OFF` - Ngày nghỉ
- `HOLIDAY` - Ngày lễ
- `HALF_DAY` - Nửa ngày

**Đặc điểm**:
- Link đến một `shift_id` (null nếu OFF/HOLIDAY)
- Có `variant_selection_rule` để xử lý holiday classes
- Hỗ trợ half-day với `half_day_period` (MORNING/AFTERNOON)

**Ví dụ**:
```sql
-- Day Model: Work Day
INSERT INTO ta.day_model VALUES
  (uuid, 'WORK_DAY', 'Standard Work Day', 'WORK',
   day_shift_id, null, false, null, ...);

-- Day Model: Off Day
INSERT INTO ta.day_model VALUES
  (uuid, 'OFF_DAY', 'Rest Day', 'OFF',
   null, null, false, null, ...);
```

---

### Level 4: PATTERN (Lịch làm việc theo chu kỳ)

**Table**: `ta.pattern_template` (GIỮ TÊN, bổ sung fields)

**Mục đích**: Định nghĩa chu kỳ lặp lại của day models.

**Thay đổi chính**:
```sql
-- Thêm fields
cycle_length_days int            -- 7, 14, 21, 28...
rotation_type varchar(20)        -- FIXED | ROTATING
```

**Relationship table**: `ta.pattern_day` (MỚI)
- Liên kết pattern với day models
- Có `day_number` (1, 2, 3...) để xác định vị trí trong chu kỳ

**Ví dụ**:
```sql
-- Pattern: 5x8 (5 days work, 2 days off)
INSERT INTO ta.pattern_template VALUES
  (uuid, '5X8', 'Five Day Week', 'Standard 5-day work week',
   7, 'FIXED', null, ...);

-- Liên kết day models
INSERT INTO ta.pattern_day VALUES
  (pattern_id, 1, work_day_id),   -- Monday
  (pattern_id, 2, work_day_id),   -- Tuesday
  (pattern_id, 3, work_day_id),   -- Wednesday
  (pattern_id, 4, work_day_id),   -- Thursday
  (pattern_id, 5, work_day_id),   -- Friday
  (pattern_id, 6, off_day_id),    -- Saturday
  (pattern_id, 7, off_day_id);    -- Sunday
```

---

### Level 5: WORK SCHEDULE RULE

**Table**: `ta.schedule_assignment` (GIỮ TÊN, bổ sung fields)

**Mục đích**: Kết hợp pattern với calendar và rotation offset.

**Thay đổi chính**:
```sql
-- Thêm fields
code varchar(50)                 -- Unique code
name varchar(100)
holiday_calendar_id uuid         -- Link to calendar
start_reference_date date        -- Anchor point
offset_days int                  -- For rotation groups
position_id uuid                 -- Additional grouping
```

**Đặc điểm**:
- Xác định **AI** được áp dụng pattern (employee, group, position)
- Có `offset_days` để hỗ trợ rotation (Crew A, B, C...)
- Link với `holiday_calendar` để xử lý ngày lễ

**Ví dụ**:
```sql
-- Schedule Rule: Team A - 5x8 pattern
INSERT INTO ta.schedule_assignment VALUES
  (uuid, 'TEAM_A_5X8', 'Team A Standard Schedule',
   pattern_5x8_id, vn_calendar_id,
   '2025-01-01', 0,  -- Start from Jan 1, no offset
   null, team_a_id, null,  -- Apply to team A
   '2025-01-01', null, ...);

-- Schedule Rule: Team B - Same pattern, offset 7 days
INSERT INTO ta.schedule_assignment VALUES
  (uuid, 'TEAM_B_5X8', 'Team B Rotated Schedule',
   pattern_5x8_id, vn_calendar_id,
   '2025-01-01', 7,  -- Offset 7 days (rotation)
   null, team_b_id, null,
   '2025-01-01', null, ...);
```

---

### Level 6: ROSTER (Phân công thực tế)

**Table**: `ta.generated_roster` (GIỮ TÊN, bổ sung fields)

**Mục đích**: Materialized view - Kết quả cuối cùng của việc generate lịch.

**Thay đổi chính**:
```sql
-- Thêm fields để tracking nguồn gốc
schedule_rule_id uuid            -- From schedule_assignment
pattern_id uuid                  -- From pattern_template
day_model_id uuid                -- From day_model
shift_id uuid                    -- From shift_def (via day_model)
is_override boolean              -- Override flag
status_code varchar(20)          -- SCHEDULED | CONFIRMED | COMPLETED
```

**Đặc điểm**:
- Một row cho mỗi employee mỗi ngày
- Tracking đầy đủ lineage (từ rule → pattern → day model → shift)
- Hỗ trợ override qua `ta.schedule_override`
- Hỗ trợ holiday handling

**Ví dụ**:
```sql
-- Generated roster for Employee A on 2025-01-06 (Monday)
INSERT INTO ta.generated_roster VALUES
  (employee_a_id, '2025-01-06',
   team_a_rule_id, pattern_5x8_id, work_day_id, day_shift_id,
   null, false,  -- No override
   false, null,  -- Not a holiday
   'SCHEDULED', ...);

-- Generated roster for Employee A on 2025-01-11 (Saturday)
INSERT INTO ta.generated_roster VALUES
  (employee_a_id, '2025-01-11',
   team_a_rule_id, pattern_5x8_id, off_day_id, null,
   null, false,
   false, null,
   'SCHEDULED', ...);
```

---

## Lợi Ích Của Mô Hình Hierarchical

### 1. Flexibility (Linh hoạt)
- Xây dựng lịch phức tạp từ các đơn vị đơn giản
- Hỗ trợ mọi loại lịch: 24/7, rotating, flex, split shift

### 2. Reusability (Tái sử dụng)
- Một segment có thể dùng trong nhiều shifts
- Một shift có thể dùng trong nhiều day models
- Một day model có thể dùng trong nhiều patterns

### 3. Maintainability (Dễ bảo trì)
- Thay đổi segment → tự động ảnh hưởng tất cả shifts sử dụng nó
- Thay đổi shift → tự động ảnh hưởng tất cả day models
- Centralized management

### 4. Scalability (Mở rộng)
- Hỗ trợ unlimited complexity
- Dễ dàng thêm loại segment/shift/pattern mới
- Performance tốt với proper indexing

### 5. Auditability (Kiểm toán)
- Lineage rõ ràng từ roster ngược về segment
- Tracking đầy đủ nguồn gốc của mỗi assignment
- Dễ dàng debug và troubleshoot

---

## So Sánh Với Thiết Kế Cũ

### Thiết Kế Cũ (Flat Model)
```
shift_def (all-in-one)
    ↓
generated_roster
```

**Vấn đề**:
- Không linh hoạt
- Khó tái sử dụng
- Phức tạp khi có nhiều loại lịch
- Khó maintain

### Thiết Kế Mới (Hierarchical Model)
```
time_segment → shift_def → day_model → pattern → schedule_rule → roster
```

**Ưu điểm**:
- Rất linh hoạt
- Tái sử dụng cao
- Dễ mở rộng
- Dễ maintain
- Clear separation of concerns

---

## Migration Plan

### Phase 1: Tạo Tables Mới
```sql
CREATE TABLE ta.time_segment (...);
CREATE TABLE ta.shift_segment (...);
CREATE TABLE ta.day_model (...);
CREATE TABLE ta.pattern_day (...);
```

### Phase 2: Migrate Dữ Liệu Hiện Tại

**Bước 1**: Tạo default segments
```sql
-- Work segment (8 hours)
INSERT INTO ta.time_segment VALUES
  (uuid, 'WORK_8H', 'Standard 8 Hour Work', 'WORK',
   0, 480, null, null, 480, true, true, ...);

-- Lunch break (1 hour)
INSERT INTO ta.time_segment VALUES
  (uuid, 'LUNCH_1H', 'Lunch Break', 'MEAL',
   240, 300, null, null, 60, false, true, ...);
```

**Bước 2**: Migrate shifts
```sql
-- Migrate existing shift_def to new structure
UPDATE ta.shift_def SET
  shift_type = 'ELAPSED',
  reference_start_time = start_time,
  reference_end_time = end_time,
  total_work_hours = duration_hours,
  total_break_hours = break_duration_hours,
  ...;

-- Create shift_segment links
INSERT INTO ta.shift_segment
SELECT shift_id, segment_id, sequence
FROM (existing shift data);
```

**Bước 3**: Tạo day models
```sql
-- Work day
INSERT INTO ta.day_model VALUES
  (uuid, 'WORK_DAY', 'Work Day', 'WORK', shift_id, ...);

-- Off day
INSERT INTO ta.day_model VALUES
  (uuid, 'OFF_DAY', 'Off Day', 'OFF', null, ...);
```

**Bước 4**: Migrate patterns
```sql
-- Update pattern_template
UPDATE ta.pattern_template SET
  cycle_length_days = 7,
  rotation_type = 'FIXED';

-- Create pattern_day links
INSERT INTO ta.pattern_day
SELECT pattern_id, day_number, day_model_id
FROM (existing pattern data);
```

**Bước 5**: Update schedule_assignment
```sql
ALTER TABLE ta.schedule_assignment ADD COLUMN
  code varchar(50),
  name varchar(100),
  holiday_calendar_id uuid,
  start_reference_date date,
  offset_days int DEFAULT 0,
  position_id uuid;
```

**Bước 6**: Regenerate roster
```sql
-- Xóa roster cũ
DELETE FROM ta.generated_roster WHERE work_date >= CURRENT_DATE;

-- Generate lại từ schedule rules
CALL generate_roster_from_rules(
  start_date => CURRENT_DATE,
  end_date => CURRENT_DATE + INTERVAL '90 days'
);
```

### Phase 3: Testing
- Test roster generation với các scenarios khác nhau
- Verify data integrity
- Performance testing

### Phase 4: Cleanup
- Drop old columns không dùng nữa
- Add constraints
- Optimize indexes

---

## Ví Dụ Thực Tế

### Scenario: 24/7 Rotating Shift

**Yêu cầu**: 3 crews (A, B, C) xoay vòng 3 ca (Day, Evening, Night), mỗi crew làm 7 ngày rồi nghỉ 7 ngày.

**Thiết kế**:

1. **Segments**:
```sql
-- Day shift segments
work_day_morning, work_day_afternoon

-- Evening shift segments
work_evening_1, work_evening_2

-- Night shift segments
work_night_1, work_night_2
```

2. **Shifts**:
```sql
-- Day: 08:00-16:00
-- Evening: 16:00-00:00
-- Night: 00:00-08:00
```

3. **Day Models**:
```sql
day_shift_day, evening_shift_day, night_shift_day, off_day
```

4. **Pattern** (21-day cycle):
```sql
-- Days 1-7: Day shift
-- Days 8-14: Off
-- Days 15-21: Evening shift
-- (Then repeats with Night shift in next cycle)
```

5. **Schedule Rules**:
```sql
-- Crew A: offset = 0
-- Crew B: offset = 7
-- Crew C: offset = 14
```

6. **Result**: 
- Crew A: Day shift week 1, Off week 2, Evening week 3
- Crew B: Off week 1, Evening week 2, Night week 3
- Crew C: Evening week 1, Night week 2, Day week 3

---

## Tài Liệu Liên Quan

- [Time_Attendance_Concept_Design.docx](../01-concept/) - Tài liệu concept gốc
- [TA-database-design-v5.dbml](./TA-database-design-v5.dbml) - File DBML chi tiết
- [Ontology](../00-ontology/) - Domain model
- [Behaviour Specs](../02-spec/) - Business logic

---

**Phê duyệt**

| Vai trò | Tên | Chữ ký | Ngày |
|---------|-----|--------|------|
| Database Architect | | | |
| Tech Lead | | | |
| Product Owner | | | |
