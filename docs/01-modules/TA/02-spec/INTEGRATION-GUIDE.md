# Integration Guide - Time & Absence Module

**Version**: 2.0  
**Last Updated**: 2025-12-15  
**Module**: Time & Absence (TA)  
**Audience**: Development Team

---

## Purpose

This guide provides developers with everything needed to implement the TA module, including architecture overview, key design decisions, integration points, and testing strategy.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Key Design Decisions](#key-design-decisions)
3. [Integration Points](#integration-points)
4. [Implementation Checklist](#implementation-checklist)
5. [Testing Requirements](#testing-requirements)
6. [Deployment Guide](#deployment-guide)

---

# Architecture Overview

## Module Structure

```
TA Module
├── Absence Management
│   ├── Leave Requests
│   ├── Leave Balances
│   ├── Leave Accrual
│   └── Leave Policies
├── Time & Attendance
│   ├── Shift Scheduling (6-level hierarchy)
│   ├── Time Tracking
│   ├── Attendance Exceptions
│   ├── Timesheets
│   └── Overtime Management
└── Shared Components
    ├── Period Profiles
    ├── Holiday Calendar
    └── Approval Workflows
```

## Technology Stack

**Backend**:
- Language: Node.js (TypeScript) or Java (Spring Boot)
- Framework: Express.js or Spring Boot
- Database: PostgreSQL 14+
- Cache: Redis
- Message Queue: RabbitMQ or Kafka

**Frontend**:
- Framework: React or Angular
- State Management: Redux or NgRx
- UI Library: Material-UI or Ant Design

**Infrastructure**:
- Container: Docker
- Orchestration: Kubernetes
- Cloud: AWS or Azure
- CI/CD: GitHub Actions or GitLab CI

---

# Key Design Decisions

## 1. Leave Balance Ledger Pattern

**Decision**: Use double-entry ledger for leave balances

**Rationale**:
- Immutable audit trail
- Easy to trace balance changes
- Supports reversals and corrections

**Implementation**:
- `LeaveBalance` table stores current balance (derived)
- `LeaveMovement` table stores all transactions (source of truth)
- Balance is calculated from movements

---

## 2. Hierarchical Scheduling Model

**Decision**: 6-level hierarchy for shift scheduling

**Levels**:
1. Time Segment (atomic building block)
2. Shift Definition (composed of segments)
3. Day Model (shift for a day)
4. Pattern Template (repeating cycle)
5. Schedule Rule (assignment to employees)
6. Generated Roster (materialized schedule)

**Rationale**:
- Flexibility for complex schedules
- Reusability of components
- Clear separation of concerns

---

## 3. Event-Driven Architecture

**Decision**: Use events for cross-module communication

**Events**:
- `leave.request.approved` → Payroll
- `timesheet.approved` → Payroll
- `attendance.exception.created` → Manager notification

**Rationale**:
- Loose coupling between modules
- Asynchronous processing
- Scalability

---

## 4. Hybrid Eligibility Model

**Decision**: Support both EligibilityProfile (Core) and inline criteria

**Rationale**:
- Flexibility for simple and complex rules
- Reusability via profiles
- Quick setup via inline criteria

---

# Integration Points

## Core Module Integration

**API Endpoints**:
```
GET /api/v1/core/workers/{id}
GET /api/v1/core/workers
POST /api/v1/core/eligibility/check
```

**Authentication**: OAuth 2.0 Bearer Token

**Error Handling**:
- Cache worker data locally (TTL: 1 hour)
- Retry with exponential backoff (3 attempts)
- Fallback to cached data if Core is down

**Implementation**:
```typescript
class CoreClient {
  async getWorker(id: string): Promise<Worker> {
    const cached = await cache.get(`worker:${id}`);
    if (cached) return cached;
    
    try {
      const worker = await api.get(`/core/workers/${id}`);
      await cache.set(`worker:${id}`, worker, 3600);
      return worker;
    } catch (error) {
      if (cached) return cached; // Fallback
      throw error;
    }
  }
}
```

---

## Payroll Module Integration

**Event Publishing**:
```typescript
class LeaveService {
  async approveLeaveRequest(id: string) {
    // Approve logic
    
    // Publish event
    await eventBus.publish({
      eventType: 'leave.request.approved',
      data: {
        employeeId: request.employeeId,
        leaveTypeId: request.leaveTypeId,
        startDate: request.startDate,
        endDate: request.endDate,
        workingDays: request.workingDays,
        isPaid: leaveType.isPaid
      }
    });
  }
}
```

**Event Subscription** (Payroll side):
```typescript
eventBus.subscribe('leave.request.approved', async (event) => {
  if (!event.data.isPaid) {
    await payrollService.deductLeave(event.data);
  }
});
```

---

## Time Clock Integration

**Webhook Endpoint**:
```typescript
@Post('/api/v1/ta/webhooks/clock-events')
@UseGuards(ApiKeyGuard)
async handleClockEvent(@Body() payload: ClockEventPayload) {
  // Validate payload
  // Map biometricId to employeeId
  // Process clock in/out
  // Return confirmation
}
```

**Idempotency**:
```typescript
const eventId = payload.eventId;
const existing = await db.findOne({ eventId });
if (existing) {
  return { status: 'already_processed' };
}
```

---

# Implementation Checklist

## Phase 1: Database Setup

- [ ] Create database schema
- [ ] Set up migrations (Flyway or Liquibase)
- [ ] Create indexes for performance
- [ ] Set up row-level security (RLS)
- [ ] Configure database backups

**Key Tables**:
- `leave_requests`
- `leave_balances`
- `leave_movements`
- `attendance_records`
- `generated_roster`
- `time_segments`
- `shift_definitions`

---

## Phase 2: API Endpoints

### Leave Management APIs
- [ ] POST /api/v1/ta/leave-requests
- [ ] POST /api/v1/ta/leave-requests/{id}/submit
- [ ] POST /api/v1/ta/leave-requests/{id}/approve
- [ ] POST /api/v1/ta/leave-requests/{id}/reject
- [ ] GET /api/v1/ta/leave-balances
- [ ] POST /api/v1/ta/leave-balances/adjust

### Attendance APIs
- [ ] POST /api/v1/ta/attendance/clock-in
- [ ] POST /api/v1/ta/attendance/clock-out
- [ ] POST /api/v1/ta/attendance/manual-entry
- [ ] GET /api/v1/ta/attendance/records

### Scheduling APIs
- [ ] GET /api/v1/ta/roster
- [ ] POST /api/v1/ta/roster/generate
- [ ] POST /api/v1/ta/roster/overrides

### Timesheet APIs
- [ ] GET /api/v1/ta/timesheets/{id}
- [ ] POST /api/v1/ta/timesheets/{id}/submit
- [ ] POST /api/v1/ta/timesheets/{id}/approve

---

## Phase 3: Business Rules

- [ ] BR-ABS-001: Calculate Available Balance
- [ ] BR-ABS-002: Sufficient Balance Check
- [ ] BR-ABS-003: Advance Notice Requirement
- [ ] BR-ABS-010: No Overlapping Requests
- [ ] BR-ATT-H50: Roster Generation Formula
- [ ] BR-ATT-002: Grace Period Application
- [ ] BR-ATT-003: Time Rounding
- [ ] BR-ATT-010: Late In Detection
- [ ] BR-COMMON-001: Calculate Working Days

---

## Phase 4: Event Handlers

- [ ] leave.request.approved → Notify Payroll
- [ ] timesheet.approved → Send to Payroll
- [ ] attendance.exception.created → Notify Manager
- [ ] leave.allocation.completed → Notify Employees

---

## Phase 5: Security Implementation

- [ ] OAuth 2.0 authentication
- [ ] Role-based access control (RBAC)
- [ ] Permission checks on all endpoints
- [ ] Data encryption (at rest and in transit)
- [ ] Audit logging
- [ ] Rate limiting
- [ ] Input validation

---

# Testing Requirements

## Unit Tests

**Coverage Target**: 80%

**Key Areas**:
- Business rule validation
- Balance calculations
- Date calculations
- Roster generation algorithm

**Example**:
```typescript
describe('BR-ABS-001: Calculate Available Balance', () => {
  it('should calculate correct available balance', () => {
    const balance = calculateAvailableBalance({
      totalAllocated: 20,
      carryover: 5,
      adjusted: 2,
      used: 8,
      pending: 3,
      expired: 1
    });
    expect(balance).toBe(15);
  });
});
```

---

## Integration Tests

**Coverage**: All API endpoints

**Test Cases**:
- Happy path
- Error cases
- Edge cases
- Permission checks

**Example**:
```typescript
describe('POST /api/v1/ta/leave-requests', () => {
  it('should create leave request with valid data', async () => {
    const response = await request(app)
      .post('/api/v1/ta/leave-requests')
      .set('Authorization', `Bearer ${token}`)
      .send({
        leaveTypeId: 'uuid',
        startDate: '2025-12-20',
        endDate: '2025-12-22'
      });
    
    expect(response.status).toBe(201);
    expect(response.body.data.id).toBeDefined();
  });
  
  it('should reject request with insufficient balance', async () => {
    const response = await request(app)
      .post('/api/v1/ta/leave-requests')
      .set('Authorization', `Bearer ${token}`)
      .send({
        leaveTypeId: 'uuid',
        startDate: '2025-12-20',
        endDate: '2026-01-20' // 30 days
      });
    
    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('INSUFFICIENT_BALANCE');
  });
});
```

---

## End-to-End Tests

**Scenarios**:
1. Employee requests leave → Manager approves → Balance updated
2. Employee clocks in → Clocks out → Timesheet generated → Manager approves
3. Roster generated → Employee views schedule → Manager overrides shift

**Tools**: Cypress, Playwright, or Selenium

---

## Performance Tests

**Load Testing**:
- 1000 concurrent users
- 10,000 requests/minute
- Response time < 500ms (P95)

**Tools**: JMeter, k6, or Artillery

---

# Deployment Guide

## Environment Setup

**Development**:
- Local database
- Mock external services
- Debug logging enabled

**Staging**:
- Shared database
- Real external services (test accounts)
- Info logging

**Production**:
- Production database (multi-region)
- Real external services
- Error logging only
- Monitoring enabled

---

## Database Migration

**Tool**: Flyway or Liquibase

**Process**:
1. Create migration script
2. Test in development
3. Review migration
4. Apply to staging
5. Verify staging
6. Apply to production
7. Verify production

**Rollback Plan**: Always have rollback script ready

---

## Deployment Steps

1. **Pre-Deployment**:
   - Run all tests
   - Create database backup
   - Notify users of maintenance window

2. **Deployment**:
   - Deploy database migrations
   - Deploy backend services (blue-green)
   - Deploy frontend (CDN cache invalidation)
   - Verify health checks

3. **Post-Deployment**:
   - Smoke tests
   - Monitor error rates
   - Monitor performance metrics
   - Notify users of completion

---

## Monitoring

**Metrics**:
- API response time
- Error rate
- Database query time
- Queue depth
- Cache hit rate

**Alerts**:
- Error rate > 1%
- Response time > 1s (P99)
- Database connections > 80%
- Queue depth > 1000

**Tools**: Prometheus, Grafana, Datadog, or New Relic

---

## Document Status

**Status**: Complete  
**Last Updated**: 2025-12-15  
**Target Audience**: Development Team

**Next Steps**:
1. Review with tech lead
2. Set up development environment
3. Begin Phase 1 implementation
