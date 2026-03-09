# Time & Absence (TA) Module - Ontology

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Purpose**: Entity definitions and data model for the TA module

---

## 📚 Documents

### Core Ontology Files

| Document | Description | Entities | Status |
|----------|-------------|----------|--------|
| [time-absence-ontology.yaml](./time-absence-ontology.yaml) | Complete TA ontology (merged) | All entities | ✅ Complete |
| [absence-ontology.yaml](./absence-ontology.yaml) | Absence Management ontology | Leave entities | ✅ Complete |
| [time-attendance-ontology.yaml](./time-attendance-ontology.yaml) | Time & Attendance ontology | Attendance entities | ✅ Complete |

### Glossary Documents

| Document | Description | Terms | Status |
|----------|-------------|-------|--------|
| [absence-glossary.md](./absence-glossary.md) | Absence Management glossary | Leave terms | ✅ Complete |
| [time-attendance-glossary.md](./time-attendance-glossary.md) | Time & Attendance glossary | Attendance terms | ✅ Complete |

### Migration Documents

| Document | Description | Status |
|----------|-------------|--------|
| [HIERARCHICAL-MODEL-MIGRATION-SUMMARY.md](./HIERARCHICAL-MODEL-MIGRATION-SUMMARY.md) | v2.0 hierarchical model migration | ✅ Complete |

---

## 🎯 Quick Start

**For Developers**: Start with [time-absence-ontology.yaml](./time-absence-ontology.yaml) - complete entity definitions

**For Business Analysts**: Read glossary documents for term definitions

**For Architects**: Review hierarchical model migration summary

---

## 📖 Entity Categories

### Absence Management Entities
- **Leave Management**: LeaveRequest, LeaveBalance, LeaveMovement
- **Leave Configuration**: LeaveType, LeavePolicy, LeaveRule
- **Leave Accrual**: AccrualRule, CarryoverRule

### Time & Attendance Entities
- **Hierarchical Scheduling** (6 levels):
  1. TimeSegment
  2. ShiftDefinition
  3. DayModel
  4. PatternTemplate
  5. ScheduleRule
  6. GeneratedRoster
- **Time Tracking**: AttendanceRecord, ClockEvent
- **Exceptions**: AttendanceException
- **Timesheets**: Timesheet, OvertimeRequest

### Shared Entities
- **Period Management**: LeaveYear, PayPeriod
- **Holiday Calendar**: HolidayCalendar, Holiday
- **Approval**: ApprovalChain, ApprovalLevel

---

## 🔗 Related Documentation

- [TA Concept Guides](../01-concept/) - Conceptual documentation
- [TA Specification](../02-spec/) - Detailed requirements and specs
- [TA Design](../03-design/) - Database and API design

---

**Maintained by**: xTalent Documentation Team
