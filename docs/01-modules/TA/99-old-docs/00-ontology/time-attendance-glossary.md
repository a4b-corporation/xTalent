# Time & Attendance - Domain Glossary

> Comprehensive glossary of terms used in the Time & Attendance sub-module (Hierarchical Model v2.0)

---

## Hierarchical Architecture Overview

Time & Attendance sử dụng **mô hình phân cấp 6 tầng** để xây dựng lịch làm việc phức tạp từ các thành phần đơn giản:

```
Level 1: Time Segment (đơn vị nguyên tử)
    ↓
Level 2: Shift Definition (tổ hợp segments)
    ↓
Level 3: Day Model (lịch hàng ngày)
    ↓
Level 4: Pattern Template (chu kỳ lặp lại)
    ↓
Level 5: Work Schedule Rule (quy tắc phân công)
    ↓
Level 6: Generated Roster (lịch thực tế)
```

---

## LEVEL 1: Time Segment (Đơn vị Nguyên Tử)

### Time Segment
**Định nghĩa**: Đơn vị nhỏ nhất, không thể chia nhỏ hơn của thời gian làm việc. Là "khối xây dựng" cơ bản để tạo nên ca làm việc.

**Các loại**:
- **WORK**: Thời gian làm việc (có trả lương)
- **BREAK**: Nghỉ giải lao ngắn (thường không trả lương)
- **MEAL**: Nghỉ ăn (không trả lương)
- **TRANSFER**: Di chuyển giữa các địa điểm làm việc

**Cách định nghĩa thời gian**:
- **Relative (Tương đối)**: Offset từ đầu ca (ví dụ: 0-240 phút = 4 giờ đầu ca)
- **Absolute (Tuyệt đối)**: Giờ cố định (ví dụ: 12:00-13:00)

**Ví dụ**:
- "Work Morning": 0-240 phút từ đầu ca (4 giờ, relative)
- "Lunch Break": 12:00-13:00 (1 giờ, absolute)
- "Work Afternoon": 240-480 phút từ đầu ca (4 giờ, relative)

**Thuộc tính quan trọng**:
- `isPaid`: Có trả lương không
- `isMandatory`: Có bắt buộc không
- `costCenterCode`: Mã trung tâm chi phí (cho kế toán)
- `premiumCode`: Mã phụ cấp (ca đêm, nguy hiểm...)

---

## LEVEL 2: Shift Definition (Định Nghĩa Ca)

### Shift Definition
**Định nghĩa**: Tổ hợp có thứ tự của các Time Segments tạo thành một ca làm việc hoàn chỉnh.

**3 loại Shift**:

#### ELAPSED Shift
- **Đặc điểm**: Lịch cố định, segments định nghĩa chính xác thời gian
- **Sử dụng**: Nhân viên văn phòng, ca hành chính
- **Ví dụ**: Ca 8-5 với giờ nghỉ trưa cố định

#### PUNCH Shift
- **Đặc điểm**: Linh hoạt, dựa trên clock in/out thực tế
- **Có**: Grace period (cho phép đi muộn), Rounding rules (làm tròn)
- **Sử dụng**: Công nhân sản xuất, nhân viên bán lẻ
- **Ví dụ**: Ca linh hoạt, chấm công vào/ra, tính lương theo giờ thực tế

#### FLEX Shift
- **Đặc điểm**: Lai giữa ELAPSED và PUNCH
- **Có**: Core hours (giờ bắt buộc) + Flexible start/end
- **Sử dụng**: Văn phòng hiện đại, flexible working
- **Ví dụ**: Bắt buộc có mặt 10:00-15:00, linh hoạt trước/sau

**Ví dụ Shift Definition**:
```
Day Shift (ELAPSED):
  - Work Morning (4h)
  - Lunch Break (1h, unpaid)
  - Work Afternoon (4h)
  Total: 8h work, 1h break
```

**Thuộc tính quan trọng**:
- `shiftType`: ELAPSED | PUNCH | FLEX
- `totalWorkHours`: Tổng giờ làm việc
- `totalBreakHours`: Tổng giờ nghỉ
- `totalPaidHours`: Tổng giờ được trả lương
- `crossMidnight`: Ca có qua đêm không
- `graceInMinutes`: Grace period cho clock-in (PUNCH type)
- `roundingIntervalMinutes`: Khoảng làm tròn (PUNCH type)

### Shift Segment
**Định nghĩa**: Liên kết giữa Shift Definition và Time Segment, có thứ tự.

**Mục đích**: Xác định segment nào được dùng trong shift, theo thứ tự nào.

**Ví dụ**:
```
Day Shift:
  1. Work Morning (sequence 1)
  2. Lunch (sequence 2)
  3. Work Afternoon (sequence 3)
```

---

## LEVEL 3: Day Model (Mô Hình Ngày)

### Day Model
**Định nghĩa**: Template cho một ngày trong lịch làm việc. Xác định ngày đó là loại gì và dùng shift nào.

**Các loại ngày**:
- **WORK**: Ngày làm việc (có shift)
- **OFF**: Ngày nghỉ (không có shift)
- **HOLIDAY**: Ngày lễ (không có shift)
- **HALF_DAY**: Nửa ngày làm việc

**Ví dụ**:
- "Standard Work Day" → sử dụng "Day Shift"
- "Weekend Day" → loại OFF, không có shift
- "Public Holiday" → loại HOLIDAY, không có shift
- "Saturday Half Day" → loại HALF_DAY, sử dụng "Morning Shift"

**Thuộc tính quan trọng**:
- `dayType`: WORK | OFF | HOLIDAY | HALF_DAY
- `shiftId`: Link đến Shift Definition (null nếu OFF/HOLIDAY)
- `variantSelectionRule`: Quy tắc chọn shift variant (cho holiday class)
- `halfDayPeriod`: MORNING | AFTERNOON (nếu là HALF_DAY)

---

## LEVEL 4: Pattern Template (Mẫu Chu Kỳ)

### Pattern Template
**Định nghĩa**: Chu kỳ lặp lại của các Day Models. Định nghĩa "pattern" làm việc.

**Các pattern phổ biến**:

#### 5x8 (Five Day Week)
- **Cycle**: 7 ngày
- **Pattern**: [Work, Work, Work, Work, Work, Off, Off]
- **Sử dụng**: Văn phòng hành chính

#### 4on-4off
- **Cycle**: 8 ngày
- **Pattern**: [Work, Work, Work, Work, Off, Off, Off, Off]
- **Sử dụng**: Sản xuất liên tục

#### 14/14 Rotation
- **Cycle**: 28 ngày
- **Pattern**: 14 ngày work, 14 ngày off
- **Sử dụng**: Dầu khí, hàng hải

**Ví dụ chi tiết**:
```
Pattern "5x8":
  Cycle length: 7 days
  Day 1: Standard Work Day (Monday)
  Day 2: Standard Work Day (Tuesday)
  Day 3: Standard Work Day (Wednesday)
  Day 4: Standard Work Day (Thursday)
  Day 5: Standard Work Day (Friday)
  Day 6: Weekend Day (Saturday)
  Day 7: Weekend Day (Sunday)
```

**Thuộc tính quan trọng**:
- `cycleLengthDays`: Số ngày trong chu kỳ (7, 14, 21, 28...)
- `rotationType`: FIXED | ROTATING

### Pattern Day
**Định nghĩa**: Liên kết giữa Pattern Template và Day Model, xác định ngày nào trong chu kỳ dùng day model nào.

---

## LEVEL 5: Work Schedule Rule (Quy Tắc Lịch Làm Việc)

### Schedule Assignment (Work Schedule Rule)
**Định nghĩa**: Kết hợp Pattern với Calendar và Rotation offset để xác định **AI** được áp dụng pattern **NÀO**.

**Các thành phần**:
- **Pattern**: Chọn pattern template nào
- **Calendar**: Link đến holiday calendar
- **Start Reference Date**: Ngày neo (anchor) để bắt đầu pattern
- **Offset Days**: Offset cho rotation (Crew A=0, B=7, C=14...)
- **Assignment**: Gán cho employee/group/position

**Ví dụ**:
```
Schedule Rule "Team A - 5x8":
  - Pattern: 5x8
  - Calendar: VN Holidays
  - Start Date: 2025-01-01 (Monday)
  - Offset: 0 days
  - Assigned to: Team A (all members)
```

**Rotation Offset**:
- **Crew A**: offset = 0 → bắt đầu từ ngày 1 của pattern
- **Crew B**: offset = 7 → bắt đầu từ ngày 8 của pattern
- **Crew C**: offset = 14 → bắt đầu từ ngày 15 của pattern

**Thuộc tính quan trọng**:
- `patternId`: Pattern template sử dụng
- `holidayCalendarId`: Calendar để check ngày lễ
- `startReferenceDate`: Ngày anchor
- `offsetDays`: Offset cho rotation
- `employeeId / employeeGroupId / positionId`: Gán cho ai

---

## LEVEL 6: Generated Roster (Lịch Thực Tế)

### Generated Roster
**Định nghĩa**: Kết quả cuối cùng - lịch làm việc thực tế cho từng nhân viên từng ngày. Được generate tự động từ Schedule Rules.

**Đặc điểm**:
- **Materialized View**: Lưu trữ kết quả đã tính toán
- **One row per employee per day**: Một dòng cho mỗi nhân viên mỗi ngày
- **Full Lineage**: Tracking đầy đủ nguồn gốc (rule → pattern → day → shift)

**Ví dụ**:
```
Employee: Nguyễn Văn A
Date: 2025-01-06 (Monday)
Schedule Rule: Team A - 5x8
Pattern: 5x8
Day Model: Standard Work Day
Shift: Day Shift (08:00-17:00)
Status: SCHEDULED
```

**Thuộc tính quan trọng**:
- `employeeId`: Nhân viên
- `workDate`: Ngày làm việc
- `scheduleRuleId`: Rule đã generate (lineage)
- `patternId`: Pattern đã dùng (lineage)
- `dayModelId`: Day model đã dùng (lineage)
- `shiftId`: Shift được gán (null nếu OFF/HOLIDAY)
- `isOverride`: Có bị override không
- `isHoliday`: Có phải ngày lễ không
- `statusCode`: SCHEDULED | CONFIRMED | COMPLETED | CANCELLED

### Schedule Override
**Định nghĩa**: Thay đổi ad-hoc đối với lịch đã generate. Override có ưu tiên cao hơn pattern-based schedule.

**Ví dụ**:
- Manager yêu cầu nhân viên A làm thêm thứ 7 (thường là OFF)
- Nhân viên B được nghỉ thứ 3 (thường là WORK)

---

## Attendance Entities

### Attendance Record
**Định nghĩa**: Bản ghi chấm công hàng ngày của nhân viên, ghi nhận thời gian thực tế so với lịch trình.

**Các thành phần**:
- **Clock In**: Thời gian bắt đầu làm việc thực tế
- **Clock Out**: Thời gian kết thúc làm việc thực tế
- **Actual Hours**: Tổng giờ làm việc thực tế
- **Status**: Trạng thái (Present, Absent, Late, etc.)

**Ví dụ**:
- "Ngày 01/12: Scheduled 08:00-17:00, Actual 08:05-17:10 (Late 5 mins)"

---

### Timesheet Entry
**Định nghĩa**: Chi tiết thời gian làm việc được phân bổ cho các dự án, tác vụ hoặc loại công việc cụ thể.

**Mục đích**: Theo dõi chi phí dự án và tính lương chi tiết (đặc biệt cho hourly workers).

**Ví dụ**:
- "4 giờ làm việc cho Project A (Billable)"
- "2 giờ họp team (Non-billable)"
- "2 giờ training"

---

### Time Exception
**Định nghĩa**: Các sai lệch so với lịch làm việc chuẩn hoặc quy định chấm công.

**Các loại phổ biến**:
- **LATE_IN**: Đi muộn
- **EARLY_OUT**: Về sớm
- **MISSING_PUNCH**: Quên chấm công (vào hoặc ra)
- **UNAUTHORIZED_ABSENCE**: Vắng mặt không phép
- **LONG_BREAK**: Nghỉ quá giờ quy định

**Quy trình xử lý**:
- Hệ thống tự động flag exception
- Manager review và approve (excuse) hoặc confirm violation

---

## Overtime Entities

### Overtime Rule
**Định nghĩa**: Quy tắc xác định khi nào giờ làm việc được tính là làm thêm giờ và hệ số lương áp dụng.

**Các loại**:
- **DAILY**: Vượt quá X giờ/ngày (ví dụ: > 8 giờ)
- **WEEKLY**: Vượt quá X giờ/tuần (ví dụ: > 40 giờ)
- **HOLIDAY**: Làm việc vào ngày lễ
- **REST_DAY**: Làm việc vào ngày nghỉ

**Ví dụ**:
- "Daily OT: > 8 giờ tính hệ số 1.5"
- "Holiday OT: Tính hệ số 3.0"

---

### Overtime Request
**Định nghĩa**: Yêu cầu làm thêm giờ cần được phê duyệt trước khi thực hiện (Pre-approval).

**Mục đích**: Kiểm soát chi phí làm thêm giờ.

**Ví dụ**:
- "Xin làm thêm 2 giờ ngày thứ 6 để hoàn thành dự án X"

---

### Overtime Calculation
**Định nghĩa**: Kết quả tính toán tổng giờ làm thêm trong kỳ, phân loại theo các hệ số (1.5, 2.0, 3.0).

**Ví dụ**:
- "Kỳ lương tháng 12: 10 giờ OT 1.5x, 5 giờ OT 2.0x"

---

## Key Concepts

### Clock In / Clock Out
**Định nghĩa**: Hành động ghi nhận thời gian bắt đầu và kết thúc phiên làm việc.
- Có thể thực hiện qua: Máy chấm công (Biometric), Mobile App (GPS), Web Portal.

### Grace Period
**Định nghĩa**: Khoảng thời gian cho phép đi muộn hoặc về sớm mà không bị tính là vi phạm (Exception).
- **Ví dụ**: Ca bắt đầu 08:00, Grace period 5 phút → Check-in 08:05 vẫn tính là đúng giờ (On Time).

### Rounding Rule (Time)
**Định nghĩa**: Quy tắc làm tròn thời gian chấm công để tính lương.
- **Ví dụ**: Làm tròn đến 15 phút gần nhất. 08:07 → 08:00, 08:08 → 08:15.

### Shift Differential
**Định nghĩa**: Phụ cấp làm việc theo ca (thường là ca đêm hoặc ca kíp).
- **Ví dụ**: Làm việc từ 22:00 - 06:00 được phụ cấp thêm 30% lương cơ bản.

### Split Shift
**Định nghĩa**: Ca làm việc bị chia tách thành 2 hoặc nhiều phần trong ngày với khoảng nghỉ dài ở giữa.
- **Ví dụ**: Sáng 10:00-14:00, Nghỉ, Tối 18:00-22:00 (ngành nhà hàng/khách sạn).

### Cycle Length
**Định nghĩa**: Số ngày trong chu kỳ pattern trước khi lặp lại.
- **Ví dụ**: Pattern 5x8 có cycle length = 7 ngày.

### Rotation Offset
**Định nghĩa**: Số ngày offset để xoay ca cho các crews khác nhau.
- **Ví dụ**: Crew A offset=0, Crew B offset=7, Crew C offset=14 → rotation 24/7.

### Lineage Tracking
**Định nghĩa**: Theo dõi nguồn gốc của roster entry từ rule → pattern → day model → shift.
- **Mục đích**: Audit trail, troubleshooting, understanding why employee has specific shift.

---

## Abbreviations

| Abbreviation | Full Term | Meaning |
|--------------|-----------|---------|
| **T&A** | Time & Attendance | Chấm công & Thời gian |
| **OT** | Overtime | Làm thêm giờ |
| **WFM** | Workforce Management | Quản lý lực lượng lao động |
| **Roster** | Roster/Schedule | Lịch phân ca |
| **TOIL** | Time Off In Lieu | Nghỉ bù (đổi giờ OT thành giờ nghỉ) |
| **ELAPSED** | Elapsed Time Shift | Ca làm việc theo thời gian cố định |
| **PUNCH** | Punch Clock Shift | Ca làm việc linh hoạt theo chấm công |
| **FLEX** | Flexible Shift | Ca làm việc lai (core hours + flexible) |

---

## Related Documents

- [Time & Attendance Ontology](./time-attendance-ontology.yaml) - Complete entity definitions (v2.0)
- [Absence Glossary](./absence-glossary.md) - Absence terms
- [TA Module Summary](./TA-MODULE-SUMMARY.yaml) - Module overview
- [Concept Overview](../01-concept/01-concept-overview.md) - High-level concepts
- [Database Design](../03-design/TA-database-design-v5.dbml) - Database schema

---

**Version**: 2.0  
**Last Updated**: 2025-12-01  
**Architecture**: 6-Level Hierarchical Model  
**Maintained By**: xTalent Documentation Team

**Version History**:
- v2.0 (2025-12-01): Updated to hierarchical 6-level model
- v1.0 (2025-12-01): Initial version with flat model
