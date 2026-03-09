---
puppeteer:
  landscape: true
  format: "A2"
---

# 🔄 ABSENCE LIFECYCLE

*(Accrual → Request → Approve → Start → Post → Close → Carry/Reset)*

## 1️⃣ Khái niệm chung

Vòng đời của một kỳ nghỉ phép trong hệ thống **Absence** được tổ chức theo chuỗi **nghiệp vụ khép kín**, đảm bảo:

* Cấp phát & ghi nhận chính xác số dư phép (Leave Balance).
* Kiểm soát hợp lý việc đăng ký và phê duyệt nghỉ.
* Tự động hóa việc trừ phép, hoàn phép, và chuyển tồn cuối kỳ.
* Giữ tính **minh bạch, audit đầy đủ, và khả năng tái tính (recalc)** bất kỳ thời điểm nào.

Mỗi giai đoạn trong chuỗi vận hành này đều được hệ thống kiểm soát bằng các **Leave Event**, **Leave Policy**, và **Leave Movement** tương ứng.

---

## 2️⃣ Tổng quan luồng vận hành

```
  ┌──────────────────────────────────────────────┐
  │      ACCRUAL / GRANT (Tích lũy / Cấp phép)  │
  └──────────────────────────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────┐
  │      REQUEST & RESERVATION (Đăng ký nghỉ)    │
  └──────────────────────────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────┐
  │      APPROVAL WORKFLOW (Phê duyệt nghỉ)      │
  └──────────────────────────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────┐
  │      START & POSTING (Thực nghỉ / Ghi sổ)    │
  └──────────────────────────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────┐
  │      CLOSE / ADJUSTMENT (Hoàn nghỉ / Chỉnh)  │
  └──────────────────────────────────────────────┘
                         │
                         ▼
  ┌──────────────────────────────────────────────┐
  │      CARRY / RESET (Chuyển / Xoá cuối kỳ)    │
  └──────────────────────────────────────────────┘
```

```mermaid
---
title: Absence Lifecycle — Employee | Manager | HR System | Scheduler
---
sequenceDiagram
    autonumber
    
    participant Emp as Employee
    participant Mgr as Manager
    participant HRS as HR System
    participant Sch as Scheduler

    %% 1) Accrual / Grant (Scheduled)
    Sch->>HRS: Trigger Event: ACCRUAL (periodic)
    HRS->>HRS: Compute accrual via Policy (eligibility, proration, rounding)
    HRS->>HRS: + LeaveMovement (ACCRUAL, +qty) → LeaveInstant
    HRS->>HRS: (Optional) Create LeaveInstantDetail (lot eff/expire)
    Note right of HRS: Available = Current - Hold (recalc)<br/>FEFO lots active

    %% 2) Request & Reservation
    Emp->>HRS: Create LeaveRequest (type, start/end, reason)
    HRS->>HRS: Validate (unit, min unit, holiday handling, overlap, team limit)
    HRS->>HRS: Check LeaveInstant (ACCOUNT: available / LIMIT: caps)
    alt Validation OK
        HRS->>HRS: Create LeaveReservation (hold_qty += req_qty)
        HRS-->>Emp: Request SUBMITTED
    else Validation Fail
        HRS-->>Emp: Reject with reason
    end

    %% 3) Approval Workflow
    HRS->>Mgr: Route for Approval (escalation rules)
    alt Manager Approves
        Mgr-->>HRS: APPROVE
        HRS-->>Emp: Status = APPROVED
    else Manager Rejects
        Mgr-->>HRS: REJECT
        HRS->>HRS: Release Reservation (hold_qty -= req_qty)
        HRS-->>Emp: Status = REJECTED
    end

    %% 4) Start & Posting (on start date)
    Sch->>HRS: Trigger Event: START_POST (daily)
    alt Request APPROVED and StartDate == Today
        HRS->>HRS: Unhold (hold_qty -= used_qty)
        HRS->>HRS: - LeaveMovement (USED, -qty) → LeaveInstant
        HRS-->>Emp: Timesheet/Leave Posted
    else Not yet / Cancelled before start
        HRS->>HRS: If cancelled → Release Reservation
    end

    %% 5) Close / Adjustment
    alt Cancel after start / Early return
        Emp->>HRS: Change Request (actual < planned)
        HRS->>HRS: + LeaveMovement (ADJUST/REVERSE, +qty)
        HRS-->>Emp: Balance restored (partial)
    else No change
        Note over HRS: Ledger immutable<br/>corrections use reversal movements
    end

    %% 6) Period Close: Carry / Reset / Expire
    Sch->>HRS: Trigger Event: PERIOD_CLOSE
    HRS->>HRS: Close checks (open holds, pending approvals)
    alt Carry Forward Allowed
        HRS->>HRS: Compute carry (cap/max)
        HRS->>HRS: + LeaveMovement (CARRY, +qty) to next period
        HRS->>HRS: (Optional) New lot with new expire
    else No Carry (Reset/Expire)
        HRS->>HRS: Mark expired lots (silent expiry)
        opt emit_expire_turnover = true
            HRS->>HRS: + LeaveMovement (EXPIRE, 0 or -qty for reporting)
        end
    end
    HRS->>HRS: Lock period (status=LOCKED)

    %% 7) Daily Snapshot (optional reporting)
    Sch->>HRS: EOD Snapshot
    HRS->>HRS: Write LeaveBalanceHistory (opening, turnover_dr/cr, closing)

    %% 8) Visibility
    HRS-->>Emp: ESS: Balances, Upcoming Leaves
    HRS-->>Mgr: MSS: Team availability / staffing limits


```

---

## 3️⃣ Chi tiết từng giai đoạn

---

### 🟩 1. **Accrual / Grant – Tích lũy và cấp phép**

**Mục đích:**
Tạo số dư phép (đối với loại nghỉ có mode = `ACCOUNT`), hoặc khởi tạo hạn mức (mode = `LIMIT`) cho nhân viên đủ điều kiện.

**Cơ chế:**

* Khi kỳ (Leave Period) bắt đầu, hệ thống chạy **LeaveEvent “ACCRUAL”** theo định nghĩa trong **LeaveClass**.
* Dựa vào **Policy** (ví dụ `accrual_rule_json`), hệ thống tính số giờ/ngày phép được cộng:

  ```json
  {"freq":"MONTH","hours":1.75,"basis":"WORKDAYS"}
  ```
* Hệ thống tạo **LeaveMovement** `+qty` (credit) gắn với `LeaveInstant`.
* Nếu loại nghỉ sử dụng lô cấp phát, một **LeaveInstantDetail (lot)** mới cũng được sinh ra, có `eff_date` và `expire_date` riêng (VD: phép năm 2025, hết hạn 31/03/2026).

**Kết quả:**
Nhân viên có thể thấy **Available Balance** tăng lên trong ví nghỉ của họ.

---

### 🟨 2. **Request & Reservation – Đăng ký nghỉ và giữ chỗ**

**Mục đích:**
Cho phép nhân viên đăng ký nghỉ trước, đồng thời hệ thống giữ chỗ (block quota) để tránh vượt số dư.

**Cơ chế:**

* Nhân viên gửi yêu cầu nghỉ (`LeaveRequest`) với thời gian cụ thể.
* Hệ thống xác định:

  * Loại nghỉ (`LeaveClass`)
  * Tổng thời lượng nghỉ (`qty_hours_req`)
  * Các ngày lễ cần loại trừ (theo `holiday_handling` trong `LeaveType`)
* Kiểm tra **eligibility** và **limit/policy**:

  * Nếu vượt hạn mức (`available_qty` hoặc `limit_yearly`), request bị từ chối.
* Khi hợp lệ, hệ thống tạo **LeaveReservation**:

  * `reserved_qty` được cộng vào `hold_qty` trong `LeaveInstant`.

**Kết quả:**
Quota của nhân viên tạm thời bị block, chờ phê duyệt.
Các báo cáo tổng hợp sẽ thấy “số phép đã giữ chỗ”.

---

### 🟦 3. **Approval Workflow – Phê duyệt nghỉ**

**Mục đích:**
Xác nhận việc nghỉ phép thông qua quy trình phê duyệt tự động hoặc nhiều cấp.

**Cơ chế:**

* Khi request được nộp, workflow tự động xác định cấp phê duyệt (`escalation_level`).
* Quản lý (team lead / director) duyệt hoặc từ chối.
* Khi **Approved**, trạng thái `LeaveRequest.status_code` → `APPROVED`.
* Reservation (`hold_qty`) vẫn được giữ cho đến ngày bắt đầu nghỉ.

**Kết quả:**
Yêu cầu nghỉ được xác nhận, chuẩn bị cho việc ghi nhận chính thức khi đến thời điểm nghỉ thực tế.

---

### 🟧 4. **Start & Posting – Nghỉ thực tế và ghi sổ**

**Mục đích:**
Khi đến ngày bắt đầu nghỉ, hệ thống chính thức trừ phép và ghi sổ ledger.

**Cơ chế:**

* Vào ngày `start_dt` của request, **LeaveEvent “START_POST”** được trigger.
* Hệ thống:

  1. **Giảm `hold_qty`** trên LeaveInstant (unblock reservation).
  2. **Tạo LeaveMovement** `-qty` (debit) để trừ phép chính thức.
  3. Nếu nghỉ nhiều ngày, movement có thể được chia theo từng `LeavePeriod` hoặc từng ngày (tuỳ config).
* Nếu loại nghỉ là `LIMIT`, movement vẫn được ghi để trừ vào hạn mức (`used_ytd`, `used_mtd`).

**Kết quả:**
Số dư khả dụng giảm đi; lịch sử giao dịch (`LeaveMovement`) có dòng ghi nhận “USED”.

---

### 🟥 5. **Close / Adjustment – Hoàn nghỉ hoặc điều chỉnh**

**Mục đích:**
Ghi nhận các trường hợp nhân viên hủy, thay đổi, hoặc nghỉ ít hơn dự kiến.

**Cơ chế:**

* Nếu request bị hủy trước ngày nghỉ:

  * Xoá `LeaveReservation`, **hoàn lại hold_qty**.
* Nếu nhân viên quay lại sớm:

  * Tạo **LeaveMovement reversal** `+qty` để cộng lại phần chưa nghỉ.
* Nếu có sai lệch (VD: tính sai số ngày), admin có thể thực hiện **Manual Adjustment** (bảng `leave_movement` thêm dòng `event_code='ADJUST'`).

**Kết quả:**
Ledger phản ánh chính xác lịch sử nghỉ thực tế; số dư hiện hành được cập nhật tương ứng.

---

### 🟩 6. **Carry / Reset – Kết thúc kỳ và xử lý tồn**

**Mục đích:**
Khi kỳ (Leave Period) kết thúc, hệ thống xử lý số dư tồn, carry sang kỳ mới hoặc reset.

**Cơ chế:**

* Khi **LeavePeriod.status = CLOSED**, job tự động chạy **LeaveEvent “CARRY” hoặc “RESET”**:

  * Nếu class cho phép chuyển phép (`carry_rule_json`):

    * Tính số ngày được carry (ví dụ tối đa 5 ngày).
    * Tạo `LeaveMovement +qty` ở kỳ mới và **LeaveInstantDetail (lot)** mới.
  * Nếu không được chuyển:

    * Đánh dấu các lô (lot) hết hạn.
    * Nếu `emit_expire_turnover = true`, tạo movement EXPIRE (reporting purpose).
* Hệ thống khóa kỳ (`status=LOCKED`) để tránh post ngược.

**Kết quả:**
Số dư kỳ cũ được chốt, các dòng carryover hoặc expire được ghi rõ trong ledger.
Toàn bộ LeaveInstant được duy trì xuyên kỳ, không cần khởi tạo lại.

---

## 4️⃣ Dòng dữ liệu (Data Flow Summary)

| Giai đoạn                 | Event                      | Loại movement | Ảnh hưởng đến số dư    | Bảng chính                               |
| ------------------------- | -------------------------- | ------------- | ---------------------- | ---------------------------------------- |
| **Accrual / Grant**       | `ACCRUAL`                  | `+qty`        | Tăng số dư khả dụng    | `leave_movement`, `leave_instant_detail` |
| **Request / Reservation** | `REQUEST_HOLD`             | (no qty)      | Block quota (hold_qty) | `leave_reservation`, `leave_instant`     |
| **Approval**              | `APPROVE`                  | (no qty)      | Giữ nguyên quota       | `leave_request`                          |
| **Start / Post**          | `START_POST`               | `-qty`        | Giảm số dư thực tế     | `leave_movement`                         |
| **Close / Adjustment**    | `ADJUST`, `REVERSE`        | `±qty`        | Điều chỉnh tăng/giảm   | `leave_movement`                         |
| **Carry / Reset**         | `CARRY`, `EXPIRE`, `RESET` | `±qty`        | Kết chuyển / hết hạn   | `leave_movement`, `leave_instant_detail` |

---

## 5️⃣ Chu kỳ tự động (Automation)

Hệ thống hỗ trợ tự động hóa các hoạt động định kỳ thông qua **LeaveEventRun**:

| Tần suất   | Tác vụ              | Event      | Diễn giải                                   |
| ---------- | ------------------- | ---------- | ------------------------------------------- |
| Hàng tháng | Tích lũy phép       | `ACCRUAL`  | Cộng phép tháng                             |
| Cuối năm   | Chuyển phép còn lại | `CARRY`    | Tạo lô mới cho năm sau                      |
| Cuối kỳ    | Xoá phép hết hạn    | `EXPIRE`   | Đánh dấu hoặc tạo turnover                  |
| Cuối ngày  | Snapshot            | `SNAPSHOT` | Ghi lại balance vào `leave_balance_history` |

---

## 6️⃣ Mối liên hệ giữa nghiệp vụ và hệ thống

| Nghiệp vụ thực tế | Thực thể vận hành                              | Giải thích             |
| ----------------- | ---------------------------------------------- | ---------------------- |
| Cấp phép năm      | `LeaveEventDef.ACCRUAL` → `LeaveMovement +qty` | Tự động cộng phép      |
| Đăng ký nghỉ      | `LeaveRequest` + `LeaveReservation`            | Giữ quota chờ duyệt    |
| Phê duyệt nghỉ    | Workflow / `status_code`                       | Kiểm soát cấp duyệt    |
| Nghỉ thực tế      | `LeaveMovement -qty`                           | Trừ số dư thật         |
| Hoàn phép         | `LeaveMovement +qty`                           | Cộng lại khi huỷ       |
| Hết hạn phép      | `LeaveInstantDetail.expire_date`               | FEFO silent expiry     |
| Chuyển phép       | `LeaveEventDef.CARRY`                          | Movement chuyển lô mới |
| Reset phép        | `LeaveEventDef.RESET`                          | Xoá số dư cũ cuối kỳ   |

---

## 7️⃣ Lợi ích vận hành

| Khía cạnh               | Lợi ích nổi bật                                                            |
| ----------------------- | -------------------------------------------------------------------------- |
| **Tự động hóa**         | Giảm thao tác thủ công, job định kỳ tự động thực hiện accrual/carry/reset. |
| **Tính minh bạch**      | Mọi thay đổi đều lưu trace trong ledger (LeaveMovement).                   |
| **Phù hợp đa quốc gia** | Có dimension BU/LE/Country, holiday calendar riêng.                        |
| **Kiểm soát linh hoạt** | Hỗ trợ cả loại phép cấp phát (ACCOUNT) và hạn mức (LIMIT).                 |
| **Tái tính dễ dàng**    | Hệ thống có thể recalculation theo period hoặc per-employee.               |
| **Báo cáo rõ ràng**     | Balance history giúp phân tích open/turnover/close từng ngày.              |

---

## 8️⃣ Tổng kết

Mô hình **Absence Lifecycle** trong hệ thống xTalent:

* Phản ánh đúng bản chất kế toán nghỉ phép (accrual – usage – expiration).
* Tách biệt giữa **sự kiện (Event)**, **chính sách (Policy)** và **sổ cái (Movement)**.
* Linh hoạt mở rộng cho các quy tắc riêng của từng doanh nghiệp, quốc gia, hoặc loại phép.
* Giữ **dấu vết đầy đủ** và **an toàn dữ liệu cao**, sẵn sàng cho audit hoặc phân tích chuyên sâu.

## 9️⃣ Phục lục
### 9.1 Data Flow quá trình config và sử dụng Absence
```plantuml
@startuml Absence_Data_Flow_Comprehensive

skinparam ActivityBackgroundColor #E8F5E9
skinparam ActivityBorderColor #2E7D32
skinparam ActivityFontSize 11
skinparam ArrowColor #1976D2
skinparam PartitionBackgroundColor #FFF9C4
skinparam PartitionBorderColor #F57F17

title Absence Module - Data Flow & Lifecycle (xTalent HR)

|#FFF3E0|Configuration Layer|
start

:🔧 **Setup LeaveType**
--
Define: unit, is_paid, 
quota_based, holiday_handling;

:📋 **Define LeavePolicy**
--
Accrual rules, Carry rules,
Limit rules, Proration rules;

:📅 **Setup HolidayCalendar**
--
Country holidays, working days;

:👥 **Setup TeamLeaveLimit**
--
Concurrent leave caps;

|#E8F5E9|Operational Layer|

:🏷️ **Create LeaveClass**
--
Mode: ACCOUNT or LIMIT
Period profile, Eligibility rules
Link to Policy & EventDef;
note right
  **ACCOUNT mode**: balance-based
  **LIMIT mode**: cap-based (YTD/MTD)
end note

:👤 **Instantiate LeaveInstant**
--
Per Employee + LeaveClass
State: ACTIVE/SUSPENDED/CLOSED
Fields: current_qty, hold_qty, available_qty;

:📦 **Create LeaveInstantDetail (lots)**
--
Lot management with expiry dates
Priority: FEFO (First Expire First Out);

|#F3E5F5|Event & Automation Layer|

fork
  :⏰ **ACCRUAL Event**
  (Scheduled - monthly/yearly);
  
  :🔄 **EventRun executes**
  --
  Compute eligibility, proration
  Apply policy rules;
  
  :➕ **Generate LeaveMovement**
  --
  event_code: ACCRUAL
  qty_delta: +N (credit)
  Create new lot in Detail;
  
  :💰 **Update LeaveInstant**
  --
  current_qty += N
  available_qty recalc;
  
fork again
  :📝 **Employee creates LeaveRequest**;
  
  :✅ **Validation checks**
  --
  - HolidayCalendar
  - TeamLeaveLimit
  - Overlap policy
  - Min unit compliance;
  
  if (Validation OK?) then (yes)
    :🔒 **Create LeaveReservation**
    --
    hold_qty += requested_qty
    available_qty -= requested_qty;
    
    :📤 **Route to Manager**
    (Approval workflow);
    
    if (Manager Decision?) then (APPROVE)
      :✔️ **Status = APPROVED**;
      
      :⏳ **Wait for start_date**;
      
      |Event & Automation Layer|
      :⏰ **START_POST Event**
      (Daily trigger on start_date);
      
      :🔓 **Unhold Reservation**
      --
      hold_qty -= used_qty;
      
      :➖ **Generate LeaveMovement**
      --
      event_code: USED
      qty_delta: -N (debit)
      Consume lots via FEFO;
      note right
        **FEFO Consumption:**
        Deduct from lots 
        closest to expire_date
      end note
      
      :📉 **Update LeaveInstant**
      --
      current_qty -= N
      available_qty recalc;
      
      :📊 **Post to Timesheet**;
      
    else (REJECT)
      :❌ **Status = REJECTED**;
      
      :🔓 **Release Reservation**
      --
      hold_qty -= requested_qty
      available_qty += requested_qty;
    endif
    
  else (no)
    :⛔ **Reject with reason**;
  endif
  
fork again
  :🔄 **Employee cancels/adjusts**
  (After start but before end);
  
  :➕ **Generate LeaveMovement**
  --
  event_code: ADJUST/REVERSE
  qty_delta: +M (credit back);
  
  :💰 **Update LeaveInstant**
  --
  current_qty += M (partial restore);
  
end fork

|#E3F2FD|Period Close Layer|

:📆 **LeavePeriod → CLOSING**
(End of month/quarter/year);

:🔍 **Pre-close validation**
--
Check open holds
Check pending approvals;

if (Close checks OK?) then (yes)
  
  fork
    if (Carry forward allowed?) then (yes)
      :📤 **CARRY Event**
      --
      Compute carry amount (cap/max)
      Apply carry policy rules;
      
      :➕ **Generate LeaveMovement**
      --
      event_code: CARRY
      qty_delta: +C to next period
      Create new lot with new expire;
      
    else (no - Reset policy)
      :🗑️ **RESET Event**
      --
      Mark expired lots
      Silent expiry (no movement);
      
      if (emit_expire_turnover?) then (yes)
        :➖ **Generate LeaveMovement**
        --
        event_code: EXPIRE
        qty_delta: -E or 0 (for report);
      endif
    endif
  
  fork again
    :🔒 **Lock period**
    --
    status_code: LOCKED
    Prevent further changes;
    
  end fork
  
endif

|#ECEFF1|Reporting & Audit Layer|

:📸 **EOD Snapshot Job**
(Daily - optional);

:📊 **Create LeaveBalanceHistory**
--
snapshot_date: TODAY
opening_qty
turnover_dr (all debits)
turnover_cr (all credits)
closing_qty;
note right
  **Daily Snapshot Formula:**
  closing = opening + turnover_cr - turnover_dr
  
  Enables point-in-time audit
  and balance reconciliation
end note

fork
  :👁️ **ESS Portal**
  (Employee Self-Service);
  
  :Display:
  - Current balance
  - Pending requests
  - Upcoming leaves
  - Movement history;
  
fork again
  :👔 **MSS Portal**
  (Manager Self-Service);
  
  :Display:
  - Team availability
  - Pending approvals
  - Team leave calendar
  - Staffing limit status;
  
fork again
  :📈 **HR Analytics**;
  
  :Reports:
  - Accrual trends
  - Usage patterns
  - Carry forward analysis
  - Expiry forecasting;
  
end fork

stop

legend right
  **Data Flow Symbols:**
  ⏰ = Scheduled Event
  📝 = Manual Action
  ✅ = Validation Gate
  ➕➖ = Movement (±qty)
  💰 = Balance Update
  🔒🔓 = Lock/Unlock Quota
  📦 = Lot Management
  📊 = Reporting
  
  **Key Concepts:**
  • **Movement-based Ledger**: All changes via ±qty
  • **Event-driven**: Automation via EventDef/EventRun
  • **Policy-driven**: Behavior configured via Policy
  • **FEFO**: First Expire First Out consumption
  • **Immutable**: Movements never edited, only reversed
  • **Multi-period**: Accounts persist across periods
endlegend

@enduml
```
### 9.2 Sơ đồ bổ sung: Entity Relationship với Data Lineage



```plantuml
@startuml Absence_Entity_Lineage

!define CONFIGCOLOR #FFF3E0
!define ENTITYCOLOR #E8F5E9
!define EVENTCOLOR #F3E5F5
!define TRANSCOLOR #E3F2FD

skinparam rectangle {
  BackgroundColor<<config>> CONFIGCOLOR
  BackgroundColor<<entity>> ENTITYCOLOR
  BackgroundColor<<event>> EVENTCOLOR
  BackgroundColor<<trans>> TRANSCOLOR
  BorderColor #424242
  FontSize 10
}

skinparam arrow {
  Color #1976D2
  FontSize 9
}

title Absence Module - Entity Relationship & Data Lineage

' Configuration Entities
rectangle "==LeaveType\n----\n+ leave_type_id\nunit, is_paid\nquota_based\nholiday_handling" as LT <<config>>

rectangle "==LeavePolicy\n----\n+ leave_policy_id\npolicy_kind\nrules_json\nproration, rounding" as LP <<config>>

rectangle "==HolidayCalendar\n----\n+ calendar_id\ncountry_code\nholiday_dates" as HC <<config>>

rectangle "==TeamLeaveLimit\n----\n+ team_limit_id\nteam_id\nconcurrent_max" as TLL <<config>>

' Operational Entities
rectangle "==LeaveClass\n----\n+ leave_class_id\nmode (ACCOUNT/LIMIT)\nperiod_profile\neligibility_json\nemit_expire_turnover" as LC <<entity>>

rectangle "==LeaveInstant\n----\n+ leave_instant_id\nemployee_id\n**current_qty**\n**hold_qty**\n**available_qty**\nstate_code" as LI <<entity>>

rectangle "==LeaveInstantDetail\n----\n+ detail_id\nlot_kind\nlot_qty, used_qty\neff_date, **expire_date**\n**priority (FEFO)**" as LID <<entity>>

rectangle "==LeavePeriod\n----\n+ period_id\nperiod_kind\nstart_date, end_date\n**status_code**\nparent_period_id" as LP_Period <<entity>>

' Event Entities
rectangle "==LeaveEventDef\n----\n+ event_def_id\n**event_code**\ntrigger_type\nfrequency" as LED <<event>>

rectangle "==LeaveEventRun\n----\n+ event_run_id\nrun_date\nstatus_code\n**idempotency_key**\naffected_count" as LER <<event>>

' Transaction Entities
rectangle "==LeaveMovement\n----\n+ movement_id\nevent_code\n**qty_delta (±)**\neffective_date\nexpire_date\n**idempotency_key**" as LM <<trans>>

rectangle "==LeaveRequest\n----\n+ leave_request_id\nemployee_id\nstart_dt, end_dt\nqty_hours_req\n**status_code**\napproval_workflow_id" as LR <<trans>>

rectangle "==LeaveReservation\n----\n+ reservation_id\n**reserved_qty**\nhold_start_date\nhold_end_date\nstatus_code" as LRes <<trans>>

rectangle "==LeaveBalanceHistory\n----\n+ history_id\nsnapshot_date\nopening_qty\n**turnover_dr/cr**\nclosing_qty" as LBH <<trans>>

' Configuration → Operational Flow
LT -down-> LC : "1. defines\n(type properties)"
LP -down-> LC : "2. applies rules\n(accrual, carry, limit)"
LP -down-> LED : "governs behavior"
HC -down-> LR : "validates holidays"
TLL -down-> LR : "validates team caps"

' Operational Flow
LC -down-> LI : "3. instantiates\n(per employee)"
LI -down-> LID : "4. creates lots\n(with expiry)"
LP_Period -down-> LER : "triggers events\n(on period boundary)"

' Event → Movement Flow
LED -right-> LER : "5. executes as\n(scheduled/triggered)"
LER -down-> LM : "6. generates\n(±qty movements)"

' Movement → Instant Flow
LM -up-> LI : "7. updates balance\n(current_qty ± delta)"
LM -left-> LID : "8. consumes lots\n(FEFO priority)"

' Request Flow
LR -up-> LI : "9. checks balance\n(available_qty)"
LR -down-> LRes : "10. creates hold\n(hold_qty += req)"
LRes -up-> LI : "blocks quota\n(available -= hold)"
LR -left-> LM : "11. posts as USED\n(on start_date)"

' Snapshot Flow
LI -down-> LBH : "12. daily snapshot\n(EOD job)"
LM -down-> LBH : "aggregates turnover\n(dr/cr)"

' Annotations
note right of LI
  **Central Account**
  • Multi-period persistence
  • Formula: available = current - hold
  • Updated by movements only
end note

note bottom of LM
  **Immutable Ledger**
  • All changes are ±qty movements
  • Corrections via REVERSE movement
  • Event-driven creation:
    - ACCRUAL (+)
    - USED (-)
    - CARRY (+)
    - ADJUST/REVERSE (±)
    - EXPIRE (- or 0)
end note

note right of LID
  **Lot Management**
  • FEFO consumption
  • Silent expiry by default
  • Optional expire movement
  • Tracks grant/carry/bonus
end note

note bottom of LER
  **Idempotent Events**
  • Prevents duplicate runs
  • Audit trail with affected_count
  • Supports retry/reconciliation
end note

note bottom of LBH
  **Daily Snapshot**
  • Point-in-time balance
  • Formula: 
    closing = opening 
            + turnover_cr 
            - turnover_dr
  • Enables audit & reconciliation
end note

@enduml
```

### 9.3 Sơ đồ bổ sung: Swimlane - Lifecycle Flow

Để thể hiện rõ hơn luồng vận hành qua các actor [1][3][4]:

```plantuml
@startuml Absence_Lifecycle_Swimlane

|#E3F2FD|Scheduler (System)|
start
:⏰ **Monthly/Yearly Trigger**
ACCRUAL Event;

|#F3E5F5|Event Engine|
:Execute EventRun
with idempotency;

:Apply LeavePolicy rules:
- Eligibility check
- Proration calculation
- Rounding rules;

|#E3F2FD|Ledger (Movement)|
:➕ Create Movement
event_code: ACCRUAL
qty_delta: +N;

|#E8F5E9|Account (Instant)|
:Update LeaveInstant
current_qty += N
available_qty recalc;

:Create new lot in Detail
with expire_date;
note right
  **Accrual Complete**
  Employee now has
  available balance
end note

|#FFF9C4|Employee (ESS)|
:📝 Submit LeaveRequest
start_dt, end_dt, qty;

|#E8F5E9|Account (Instant)|
:Validate request:
- Available balance?
- Min unit OK?
- Overlap check
- Holiday handling;

if (Validation OK?) then (yes)
  :🔒 Create Reservation
  hold_qty += requested_qty;
  
  |#FFE082|Manager (MSS)|
  :Review request
  Check team availability
  Check staffing limits;
  
  if (Decision?) then (APPROVE ✅)
    |#E3F2FD|Ledger (Movement)|
    :Status = APPROVED
    Wait for start_date;
    
    |#E3F2FD|Scheduler (System)|
    :⏰ **Daily Trigger**
    START_POST Event
    (on start_date);
    
    |#F3E5F5|Event Engine|
    :Process approved requests
    with start_date = today;
    
    |#E3F2FD|Ledger (Movement)|
    :➖ Create Movement
    event_code: USED
    qty_delta: -N;
    
    |#E8F5E9|Account (Instant)|
    :🔓 Unhold reservation
    hold_qty -= N;
    
    :Consume lots via FEFO
    (expire_date ASC);
    
    :Update LeaveInstant
    current_qty -= N;
    
    :📊 Post to Timesheet;
    
  else (REJECT ❌)
    |#E8F5E9|Account (Instant)|
    :🔓 Release Reservation
    hold_qty -= requested_qty
    available_qty restored;
  endif
  
else (no ⛔)
  |#FFF9C4|Employee (ESS)|
  :Show error message
  with validation reason;
  stop
endif

|#FFF9C4|Employee (ESS)|
if (Change after start?) then (yes - cancel/adjust)
  :Submit change request
  actual_days < planned_days;
  
  |#E3F2FD|Ledger (Movement)|
  :➕ Create Movement
  event_code: ADJUST
  qty_delta: +M (credit back);
  
  |#E8F5E9|Account (Instant)|
  :Update LeaveInstant
  current_qty += M
  (partial restore);
endif

|#E3F2FD|Scheduler (System)|
:⏰ **Period Close Trigger**
(End of year/month);

|#F3E5F5|Event Engine|
:Execute PERIOD_CLOSE
EventRun;

:Validation checks:
- Open holds?
- Pending approvals?;

if (Carry forward allowed?) then (yes 📤)
  :Apply carry policy:
  - Compute cap/max
  - Apply proration;
  
  |#E3F2FD|Ledger (Movement)|
  :➕ Create Movement
  event_code: CARRY
  qty_delta: +C to next period;
  
  |#E8F5E9|Account (Instant)|
  :Create new lot in Detail
  for next period
  with new expire_date;
  
else (no - Reset/Expire 🗑️)
  |#E8F5E9|Account (Instant)|
  :Mark expired lots
  (silent expiry);
  
  if (emit_expire_turnover?) then (yes)
    |#E3F2FD|Ledger (Movement)|
    :➖ Create Movement
    event_code: EXPIRE
    qty_delta: -E or 0
    (for reporting);
  endif
endif

|#F3E5F5|Event Engine|
:🔒 Lock period
status = LOCKED;

|#E3F2FD|Scheduler (System)|
:⏰ **EOD Snapshot Job**
(Daily - optional);

|#ECEFF1|Reporting (History)|
:Aggregate all movements:
- turnover_dr (debits)
- turnover_cr (credits);

:📸 Create LeaveBalanceHistory
snapshot_date: TODAY
opening + cr - dr = closing;

fork
  |#FFF9C4|Employee (ESS)|
  :View dashboard:
  - Current balance
  - Pending requests
  - Upcoming leaves;
  
fork again
  |#FFE082|Manager (MSS)|
  :View team dashboard:
  - Team availability
  - Pending approvals
  - Staffing status;
  
fork again
  |#ECEFF1|Reporting (History)|
  :📈 Generate HR Analytics:
  - Accrual trends
  - Usage patterns
  - Expiry forecasts;
  
end fork

stop

legend right
  **Swimlane Actors:**
  🟦 Scheduler = System triggers (time-based)
  🟪 Event Engine = Policy execution & automation
  🟦 Ledger = Movement creation (±qty)
  🟩 Account = Balance tracking & lot management
  🟨 Employee = ESS self-service actions
  🟧 Manager = MSS approval & oversight
  ⬜ Reporting = Audit & analytics
  
  **Data Flow:**
  ➕ Credit movement (increase balance)
  ➖ Debit movement (decrease balance)
  🔒 Lock/Hold quota
  🔓 Unlock/Release quota
  📊 Post to external system
  📸 Snapshot for audit
endlegend

@enduml
```
