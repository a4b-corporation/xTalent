# Period Profiles Guide

**Version**: 1.0  
**Last Updated**: 2025-12-12  
**Audience**: HR Administrators, System Configurators  
**Reading Time**: 20-25 minutes

---

## 📋 Overview

This guide explains how to configure period profiles for leave year and pay period management in the TA module. You'll learn about period types, holiday calendars, working schedules, and their integration with leave and attendance.

### What You'll Learn

- Period profile types (calendar year, fiscal year, hire anniversary, custom)
- Leave year configuration
- Pay period setup
- Holiday calendar management
- Working schedule definition
- Integration with leave and attendance
- Common configurations and best practices

### Prerequisites

- Basic understanding of HR periods and calendars
- Familiarity with [Concept Overview](./01-concept-overview.md)
- Understanding of [Leave Policy Configuration](./03-leave-policy-configuration-guide.md)

---

## 📅 Period Profile Types

### Overview

A **Period Profile** defines the time boundaries for leave accrual, balance tracking, and pay period calculations.

### Types

| Type | Start Date | Use Case | Example |
|------|------------|----------|---------|
| **CALENDAR_YEAR** | January 1 | Standard calendar year | Jan 1 - Dec 31 |
| **FISCAL_YEAR** | Company fiscal year start | Financial alignment | Apr 1 - Mar 31 |
| **HIRE_ANNIVERSARY** | Employee hire date | Individual tracking | Hire date + 1 year |
| **CUSTOM** | User-defined | Special requirements | Jul 1 - Jun 30 |

---

## 📆 Calendar Year Profile

### Configuration

```yaml
PeriodProfile:
  code: "CALENDAR_YEAR"
  name: "Calendar Year (Jan-Dec)"
  periodType: CALENDAR_YEAR
  startMonth: 1  # January
  startDay: 1
  durationMonths: 12
  isActive: true
```

### Characteristics

**Advantages**:
- ✅ Aligns with calendar
- ✅ Easy to understand
- ✅ Standard for most countries

**Disadvantages**:
- ❌ Mid-year joiners need proration
- ❌ Year-end processing rush

### Example

```yaml
# Employee joins: 2025-03-15
# Leave year: 2025-01-01 to 2025-12-31
# Allocation: 20 days (prorated from Mar 15)
# Prorated amount: 20 × (9.5/12) = 15.83 days
```

---

## 💼 Fiscal Year Profile

### Configuration

```yaml
PeriodProfile:
  code: "FISCAL_YEAR"
  name: "Fiscal Year (Apr-Mar)"
  periodType: FISCAL_YEAR
  startMonth: 4  # April
  startDay: 1
  durationMonths: 12
  isActive: true
```

### Characteristics

**Advantages**:
- ✅ Aligns with financial reporting
- ✅ Spreads year-end processing
- ✅ Better for budget planning

**Disadvantages**:
- ❌ May confuse employees
- ❌ Doesn't align with calendar

### Example

```yaml
# Fiscal year: 2025-04-01 to 2026-03-31
# Leave allocation: April 1, 2025
# Carryover processing: March 31, 2026
```

---

## 🎂 Hire Anniversary Profile

### Configuration

```yaml
PeriodProfile:
  code: "HIRE_ANNIVERSARY"
  name: "Hire Anniversary"
  periodType: HIRE_ANNIVERSARY
  # No fixed start date - uses hire date
  durationMonths: 12
  isActive: true
```

### Characteristics

**Advantages**:
- ✅ No proration needed
- ✅ Fair for all employees
- ✅ Spreads processing throughout year

**Disadvantages**:
- ❌ Complex to manage (different periods per employee)
- ❌ Difficult for reporting
- ❌ Higher administrative overhead

### Example

```yaml
# Employee A hired: 2024-03-15
# Leave year: 2025-03-15 to 2026-03-14
# Allocation: March 15, 2025

# Employee B hired: 2024-07-01
# Leave year: 2025-07-01 to 2026-06-30
# Allocation: July 1, 2025
```

---

## ⚙️ Custom Period Profile

### Configuration

```yaml
PeriodProfile:
  code: "ACADEMIC_YEAR"
  name: "Academic Year (Sep-Aug)"
  periodType: CUSTOM
  startMonth: 9  # September
  startDay: 1
  durationMonths: 12
  isActive: true
```

### Use Cases

- **Academic institutions**: Sep-Aug
- **Retail**: Feb-Jan (post-holiday)
- **Agriculture**: Seasonal cycles
- **Special projects**: Project duration

### Example

```yaml
# Academic year: 2025-09-01 to 2026-08-31
# Allocation: September 1
# Aligns with school calendar
```

---

## 💰 Pay Period Configuration

### Pay Period Types

| Type | Frequency | Periods/Year | Example |
|------|-----------|--------------|---------|
| **WEEKLY** | Every week | 52 | Mon-Sun |
| **BIWEEKLY** | Every 2 weeks | 26 | Mon-Sun (2 weeks) |
| **SEMI_MONTHLY** | Twice per month | 24 | 1st-15th, 16th-End |
| **MONTHLY** | Once per month | 12 | 1st-Last day |

---

### Weekly Pay Period

```yaml
PayPeriod:
  periodType: WEEKLY
  startDayOfWeek: MONDAY
  endDayOfWeek: SUNDAY
  
# Example periods:
# Period 1: 2025-01-06 to 2025-01-12
# Period 2: 2025-01-13 to 2025-01-19
# Period 3: 2025-01-20 to 2025-01-26
```

---

### Biweekly Pay Period

```yaml
PayPeriod:
  periodType: BIWEEKLY
  startDayOfWeek: MONDAY
  anchorDate: "2025-01-06"  # First Monday of year
  
# Example periods:
# Period 1: 2025-01-06 to 2025-01-19 (2 weeks)
# Period 2: 2025-01-20 to 2025-02-02 (2 weeks)
```

---

### Semi-Monthly Pay Period

```yaml
PayPeriod:
  periodType: SEMI_MONTHLY
  firstPeriodEndDay: 15
  secondPeriodEndDay: LAST_DAY
  
# Example periods:
# Period 1: 2025-01-01 to 2025-01-15
# Period 2: 2025-01-16 to 2025-01-31
# Period 3: 2025-02-01 to 2025-02-15
# Period 4: 2025-02-16 to 2025-02-28
```

---

### Monthly Pay Period

```yaml
PayPeriod:
  periodType: MONTHLY
  startDay: 1
  endDay: LAST_DAY
  
# Example periods:
# Period 1: 2025-01-01 to 2025-01-31
# Period 2: 2025-02-01 to 2025-02-28
# Period 3: 2025-03-01 to 2025-03-31
```

---

## 🎉 Holiday Calendar Management

### Holiday Calendar Structure

```yaml
HolidayCalendar:
  code: "VN_2025"
  name: "Vietnam Holidays 2025"
  country: "VN"
  year: 2025
  isActive: true
```

### Holiday Definition

```yaml
Holiday:
  calendarId: "VN_2025"
  code: "TET_2025"
  name: "Tết Nguyên Đán 2025"
  holidayDate: "2025-01-29"
  holidayClass: CLASS_A  # Full day off
  isRecurring: true
  recurrenceRule: "LUNAR_CALENDAR"  # Lunar New Year
  observedDate: "2025-01-29"  # May differ if falls on weekend
```

### Holiday Classes

| Class | Description | Typical Treatment | Example |
|-------|-------------|-------------------|---------|
| **CLASS_A** | Major public holiday | Full day off, paid | National Day |
| **CLASS_B** | Minor public holiday | Half day or optional | Local festival |
| **CLASS_C** | Observance | Work day, may celebrate | Cultural event |

---

### Multi-Day Holidays

```yaml
# Tết Holiday (5 days)
Holiday:
  code: "TET_2025"
  name: "Tết Nguyên Đán 2025"
  startDate: "2025-01-29"
  endDate: "2025-02-02"
  totalDays: 5
  holidayClass: CLASS_A
```

---

### Weekend Substitution

```yaml
# Holiday falls on Saturday
Holiday:
  holidayDate: "2025-05-03"  # Saturday
  observedDate: "2025-05-05"  # Observed on Monday
  isSubstituted: true
  substitutionRule: NEXT_WORKING_DAY
```

---

## 🗓️ Working Schedule Definition

### Standard Work Week

```yaml
WorkingSchedule:
  code: "5DAY_WEEK"
  name: "5-Day Work Week"
  
  workingDays:
    - MONDAY
    - TUESDAY
    - WEDNESDAY
    - THURSDAY
    - FRIDAY
  
  nonWorkingDays:
    - SATURDAY
    - SUNDAY
  
  standardWorkHours: 8.0
  standardWorkDaysPerWeek: 5
```

---

### 6-Day Work Week

```yaml
WorkingSchedule:
  code: "6DAY_WEEK"
  name: "6-Day Work Week"
  
  workingDays:
    - MONDAY
    - TUESDAY
    - WEDNESDAY
    - THURSDAY
    - FRIDAY
    - SATURDAY
  
  nonWorkingDays:
    - SUNDAY
  
  standardWorkHours: 8.0
  standardWorkDaysPerWeek: 6
```

---

### Flexible Work Week

```yaml
WorkingSchedule:
  code: "FLEX_WEEK"
  name: "Flexible Work Week"
  
  # Core days (mandatory)
  coreDays:
    - TUESDAY
    - WEDNESDAY
    - THURSDAY
  
  # Optional days
  optionalDays:
    - MONDAY
    - FRIDAY
  
  minimumWorkDaysPerWeek: 4
  standardWorkHours: 8.0
```

---

## 🔗 Integration with Leave and Attendance

### Leave Year Integration

```yaml
# Leave balance tied to period profile
LeaveBalance:
  workerId: "EMP_001"
  leaveTypeId: "ANNUAL"
  periodProfileId: "CALENDAR_YEAR"
  periodYear: 2025
  periodStartDate: "2025-01-01"
  periodEndDate: "2025-12-31"
  
  # Allocation based on period
  totalAllocated: 20.0
```

---

### Pay Period Integration

```yaml
# Timesheet tied to pay period
TimesheetEntry:
  workerId: "EMP_001"
  payPeriodId: "2025_P01"
  periodStartDate: "2025-01-01"
  periodEndDate: "2025-01-15"
  
  # Hours calculated for this period
  totalWorkedHours: 80.0
  totalPaidHours: 80.0
```

---

### Holiday Integration

```yaml
# Generated roster respects holidays
GeneratedRoster:
  workerId: "EMP_001"
  rosterDate: "2025-01-29"  # Tết holiday
  
  # System checks holiday calendar
  isHoliday: true
  holidayId: "TET_2025"
  
  # No work scheduled
  shiftDefinitionId: null
  plannedWorkHours: 0.0
```

---

## 🎯 Common Configurations

### Configuration 1: Standard Office (Vietnam)

```yaml
# Period Profile
PeriodProfile:
  periodType: CALENDAR_YEAR
  startMonth: 1
  startDay: 1

# Pay Period
PayPeriod:
  periodType: MONTHLY
  startDay: 1
  endDay: LAST_DAY

# Working Schedule
WorkingSchedule:
  code: "VN_STANDARD"
  workingDays: [MON, TUE, WED, THU, FRI]
  nonWorkingDays: [SAT, SUN]
  standardWorkHours: 8.0

# Holiday Calendar
HolidayCalendar:
  country: "VN"
  year: 2025
  holidays:
    - Tết (5 days)
    - Hung Kings' Day
    - Reunification Day
    - Labor Day
    - National Day
```

---

### Configuration 2: Retail (US)

```yaml
# Period Profile (Fiscal year)
PeriodProfile:
  periodType: FISCAL_YEAR
  startMonth: 2  # February (post-holiday)
  startDay: 1

# Pay Period (Biweekly)
PayPeriod:
  periodType: BIWEEKLY
  startDayOfWeek: SUNDAY
  anchorDate: "2025-02-02"

# Working Schedule (7-day operation)
WorkingSchedule:
  code: "RETAIL_24_7"
  # No fixed working days (shift-based)
  operatesSevenDays: true
  standardWorkHours: 8.0

# Holiday Calendar (Limited holidays)
HolidayCalendar:
  country: "US"
  year: 2025
  holidays:
    - New Year's Day
    - Memorial Day
    - Independence Day
    - Labor Day
    - Thanksgiving
    - Christmas
```

---

### Configuration 3: Academic Institution

```yaml
# Period Profile (Academic year)
PeriodProfile:
  periodType: CUSTOM
  startMonth: 9  # September
  startDay: 1
  durationMonths: 12

# Pay Period (Monthly)
PayPeriod:
  periodType: MONTHLY
  startDay: 1
  endDay: LAST_DAY

# Working Schedule (Academic calendar)
WorkingSchedule:
  code: "ACADEMIC"
  workingDays: [MON, TUE, WED, THU, FRI]
  nonWorkingDays: [SAT, SUN]
  
  # Special periods
  specialPeriods:
    - name: "Summer Break"
      startDate: "2025-06-15"
      endDate: "2025-08-31"
    - name: "Winter Break"
      startDate: "2025-12-20"
      endDate: "2026-01-05"

# Holiday Calendar (Academic holidays)
HolidayCalendar:
  code: "ACADEMIC_2025"
  holidays:
    - Fall Break
    - Thanksgiving Break
    - Winter Break
    - Spring Break
    - Summer Break
```

---

## ✅ Best Practices

### 1. Period Profile Selection

✅ **DO**:
- Choose period type that aligns with business
- Consider employee understanding
- Plan for year-end processing
- Document period boundaries clearly

❌ **DON'T**:
- Change period type frequently
- Use complex custom periods without reason
- Forget to communicate changes to employees

---

### 2. Holiday Calendar Management

✅ **DO**:
- Update calendar annually
- Include all public holidays
- Handle weekend substitutions
- Communicate holiday schedule early

❌ **DON'T**:
- Forget to publish next year's calendar
- Miss regional holidays
- Ignore weekend substitution rules

---

### 3. Pay Period Configuration

✅ **DO**:
- Align with payroll system
- Keep consistent period length
- Set clear cutoff times
- Test period calculations

❌ **DON'T**:
- Change pay period frequency without notice
- Create irregular periods
- Forget leap year handling

---

## 📚 Related Guides

- [Concept Overview](./01-concept-overview.md) - Module overview
- [Leave Policy Configuration](./03-leave-policy-configuration-guide.md) - Policy setup
- [Leave Balance Ledger](./04-leave-balance-ledger-guide.md) - Balance tracking
- [Shift Scheduling](./05-shift-scheduling-guide.md) - Roster generation

---

**Document Version**: 1.0  
**Created**: 2025-12-12  
**Last Review**: 2025-12-12  
**Author**: xTalent Documentation Team
