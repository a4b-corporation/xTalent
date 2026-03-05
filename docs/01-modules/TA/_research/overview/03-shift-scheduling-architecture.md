# TA Module — Kiến trúc Lịch làm việc (Shift Scheduling)

**Phiên bản**: 1.0 · **Cập nhật**: 2026-03-05  
**Đối tượng**: HR Administrator, Workforce Planner, Manager, Product

---

## Tổng quan

Đây là **differentiator kiến trúc quan trọng nhất** của TA module trong xTalent. Thay vì tạo lịch trực tiếp cho từng nhân viên từng tuần (flat model như hầu hết hệ thống HCM truyền thống), xTalent dùng **6-Level Hierarchical Model** — xây lịch từ các building block nhỏ, tái sử dụng được, compose lên dần.

**Kết quả**: Một lần cấu hình, tự động generate roster cho toàn bộ tổ chức — kể cả những pattern phức tạp như 24/7 rotating shifts hay offshore 14/14.

---

## 6-Level Hierarchical Model

```
Level 1: TimeSegment          ← Atomic unit (WORK, BREAK, MEAL, TRANSFER)
     ↓ compose
Level 2: ShiftDefinition      ← Combination of segments = 1 shift
     ↓ link
Level 3: DayModel             ← What happens on 1 day (WORK / OFF / HOLIDAY)
     ↓ sequence
Level 4: PatternTemplate      ← Repeating cycle of days (5x8, 4on-4off, 14/14)
     ↓ configure
Level 5: WorkScheduleRule     ← Pattern + Calendar + Rotation Offset → WHO gets WHICH
     ↓ generate
Level 6: GeneratedRoster      ← Materialized: 1 row per employee per day
```

---

## Level 1: Time Segment — Atomic Building Block

**Time Segment** là đơn vị nhỏ nhất của thời gian làm việc:

| Loại | Ý nghĩa | Có trả lương? |
|------|---------|:------------:|
| `WORK` | Thời gian làm việc productive | ✅ |
| `BREAK` | Nghỉ giải lao ngắn | ❌ |
| `MEAL` | Bữa ăn | ❌ |
| `TRANSFER` | Di chuyển giữa các địa điểm | ✅ |

**Hai cách định nghĩa timing**:
- **Relative** (offset từ giờ bắt đầu ca): `0–240 phút = Work Morning`
- **Absolute** (giờ cố định): `12:00–13:00 = Lunch Break`

---

## Level 2: Shift Definition — Composition of Segments

**ShiftDefinition** kết hợp các segments thành một ca làm việc hoàn chỉnh.

**3 loại Shift**:

| Loại | Cách hoạt động | Phù hợp với |
|------|---------------|------------|
| `ELAPSED` | Cố định theo thời gian tuyệt đối | Văn phòng hành chính, sản xuất |
| `PUNCH` | Linh hoạt — tính dựa trên giờ clock in/out thực tế, có grace period | Retail, warehouse |
| `FLEX` | Core hours cố định + giờ vào/ra linh hoạt trong range | Tech companies, creative |

**Ví dụ Day Shift (ELAPSED)**:
```
Day Shift = Work Morning (0→240 min)
           + Lunch Break (240→300 min, unpaid)
           + Work Afternoon (300→480 min)
Total paid: 8 hours
```

---

## Level 3: Day Model — Daily Schedule Template

**DayModel** định nghĩa điều gì xảy ra trong một ngày:

| Day Type | Ý nghĩa | Shift? |
|----------|---------|:------:|
| `WORK` | Ngày làm việc | ✅ (link to ShiftDefinition) |
| `OFF` | Ngày nghỉ | ❌ |
| `HOLIDAY` | Ngày lễ/nghỉ phép công ty | ❌ |
| `HALF_DAY` | Làm việc nửa ngày | ✅ (half duration) |

---

## Level 4: Pattern Template — Repeating Cycle

**PatternTemplate** định nghĩa một chu kỳ lặp lại của các day models:

| Pattern | Chu kỳ | Cấu trúc | Phù hợp với |
|---------|:------:|---------|------------|
| **5x8** | 7 ngày | Work×5 + Off×2 | Văn phòng hành chính |
| **4on-4off** | 8 ngày | Work×4 + Off×4 | Bệnh viện, security |
| **2-2-3** | 7 ngày | Work×2 + Off×2 + Work×3 | Retail, call center |
| **3-shift rotation** | 21 ngày | Day×7 + Off×7 + Evening×7 | Sản xuất 24/7 |
| **14/14 offshore** | 28 ngày | Work×14 + Off×14 | Oil & gas, offshore |

---

## Level 5: Work Schedule Rule — Assignment + Configuration

**WorkScheduleRule** là bước quan trọng kết nối pattern với những nhân viên cụ thể:

```yaml
WorkScheduleRule:
  pattern: "5x8 Standard"
  holidayCalendar: "Vietnam Public Holidays"
  startReferenceDate: "2025-01-01"  # Anchor point cho cycle
  rotationOffsetDays: 0              # 0=Team A, 7=Team B, 14=Team C
  assignedTo:
    - teamId: "engineering-team-a"
  effectiveDate: "2025-01-01"
  expiryDate: null  # ongoing
```

**Rotation Offset** — chìa khóa cho 24/7 coverage:
```
Pattern (21-day): [Day×7 · Off×7 · Evening×7]

Crew A: offset=0  → Week 1: Day shift
Crew B: offset=7  → Week 1: Off
Crew C: offset=14 → Week 1: Evening shift

Week 2: Crew A=Off, Crew B=Evening, Crew C=Day (automatic)
Week 3: Crew A=Evening, Crew B=Day, Crew C=Off (automatic)
```

---

## Level 6: Generated Roster — Materialized Schedule

**GeneratedRoster** là kết quả cuối cùng — **1 record cho mỗi nhân viên × mỗi ngày**:

```
Employee A · 2025-01-06 (Monday):
  └── Rule: "Team A 5x8"
       └── Pattern day 0 → DayModel: "Standard Work Day"
            └── ShiftDef: "Day Shift 08:00-17:00"
                 └── Status: SCHEDULED
                      └── Holiday check: Not a holiday → WORK day
```

**Full lineage tracking**: Mỗi roster entry biết chính xác nó đến từ rule nào → pattern nào → day model nào → shift nào. Điều này cần thiết cho:
- Audit và traceability
- Debug khi schedule sai
- Impact analysis khi thay đổi shift definition

### Override System

Manager có thể tạo **ScheduleOverride** cho trường hợp cá biệt:
- Nhân viên A làm thêm thứ 7 (thường nghỉ)
- Nhân viên B nghỉ bù thứ 3 (thường làm)

Override luôn có priority cao hơn Generated Roster, nhưng original plan được giữ nguyên cho audit.

---

## Roster Generation Algorithm

```
For each employee:
  Find applicable WorkScheduleRule (by assignment + effective date)
  For each date in range:
    cycleDay = (date - startReferenceDate + offsetDays) % cycleLengthDays
    dayModel  = Pattern.days[cycleDay]
    shift     = dayModel.shiftDefinition

    if date in holidayCalendar → override to HOLIDAY
    if manualOverride exists  → apply override
    else                      → use generated shift

    Create GeneratedRoster entry (1 per employee per day)
```

---

## Ví dụ thực tế: Nhà máy sản xuất 24/7

**Yêu cầu**: 3 dây chuyền, mỗi dây chuyền cần phủ 24/7, xoay ca mỗi tuần.

**Setup (1 lần, tái sử dụng mãi)**:

```
Step 1 — Segments:
  • Work 8h (productive time)
  • Short break 30min (paid)

Step 2 — Shifts:
  • Day Shift:     08:00–16:00
  • Evening Shift: 16:00–00:00
  • Night Shift:   00:00–08:00

Step 3 — Day Models:
  • DayShiftDay, EveningShiftDay, NightShiftDay, OffDay

Step 4 — Pattern (21-day cycle):
  Days 1–7:  Day Shift × 7
  Days 8–14: Off × 7
  Days 15–21: Evening Shift × 7

Step 5 — Rules:
  • Line A Rule: Pattern + offset=0
  • Line B Rule: Pattern + offset=7
  • Line C Rule: Pattern + offset=14

Step 6 → System generates roster automatically for all 3 lines
```

**Kết quả**:
- Tuần 1: Line A=Day, Line B=Off, Line C=Evening
- Tuần 2: Line A=Off, Line B=Evening, Line C=Night
- Tuần 3: Line A=Evening, Line B=Night, Line C=Day
- Tuần 4: Return to Tuần 1 (21-day cycle)

---

## Tại sao không dùng flat model?

| Flat Model (traditional) | 6-Level Hierarchical (xTalent) |
|--------------------------|-------------------------------|
| Tạo lịch thủ công từng tuần | Cấu hình 1 lần, auto-generate |
| Copy-paste khi thêm nhân viên mới | Assign vào rule, roster tự sinh |
| Thay đổi shift → phải update từng người | Thay đổi ShiftDefinition → tất cả roster update |
| Không handle rotating crews tốt | Rotation offset native support |
| Không có audit trail | Full lineage từng roster entry |
| Không scale với quy mô lớn | Generate hàng nghìn employees |

---

## Entities chính

| Entity | Vai trò |
|--------|---------|
| **TimeSegment** | Atomic time unit (WORK, BREAK, MEAL, TRANSFER) |
| **ShiftDefinition** | Combination of segments forming a complete shift |
| **DayModel** | Daily schedule template (WORK/OFF/HOLIDAY/HALF_DAY) |
| **PatternTemplate** | Repeating cycle of day models |
| **WorkScheduleRule** | Pattern + calendar + rotation = assignment config |
| **GeneratedRoster** | Materialized 1-per-employee-per-day schedule |
| **ScheduleOverride** | Ad-hoc changes overriding generated roster |

---

*Nguồn: tổng hợp từ `05-shift-scheduling-guide.md` và `02-conceptual-guide.md` (Workflow 3)*  
*← [02 Absence](./02-absence-management.md) · [04 Attendance →](./04-attendance-timesheet.md)*
