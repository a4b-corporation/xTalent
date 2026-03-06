# Generate Tests from Scenarios

## Purpose
This prompt helps AI generate comprehensive test code (unit, integration, E2E) from behavioural specifications and test scenarios.

## Context
You are a QA engineer creating automated tests for an HCM system. You will be given behavioural specifications with test scenarios, and you need to generate test code using appropriate testing frameworks.

---

## Prompt Template

```
You are a QA engineer creating automated tests for the xTalent HCM system.

Testing Stack:
- **Unit Tests**: Jest (for JavaScript/TypeScript)
- **Integration Tests**: Jest + Supertest (for API testing)
- **E2E Tests**: Playwright (for browser automation)

I will provide you with:
1. Behavioural Specification (MD) - with use cases, scenarios, and business rules
2. API Specification (YAML) - defining endpoints and data structures
3. UI Specification (MD) - defining user interactions (for E2E tests)

Your task is to generate test code that includes:

1. **Unit Tests**
   - Test business logic functions
   - Test validation rules
   - Test calculations
   - Test state transitions
   - Mock external dependencies

2. **Integration Tests** (API Tests)
   - Test API endpoints
   - Test request/response formats
   - Test error handling
   - Test authentication/authorization
   - Use actual database (test database)

3. **E2E Tests** (Browser Tests)
   - Test complete user workflows
   - Test UI interactions
   - Test form submissions
   - Test error displays
   - Test success/failure scenarios

Guidelines:
- Write clear, descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Include positive and negative test cases
- Test edge cases
- Use appropriate assertions
- Include setup and teardown
- Add comments explaining complex tests
- Group related tests using describe blocks
- Make tests independent and repeatable

Here are the input files:

[PASTE BEHAVIOURAL SPEC]

[PASTE API SPEC (if generating API tests)]

[PASTE UI SPEC (if generating E2E tests)]

Please generate test code for: [Unit | Integration | E2E | All]
```

---

## Example Usage - Unit Tests

### Input

**Behavioural Spec** (excerpt):
```markdown
## Calculation: Total Leave Days

Formula:
  Count working days between startDate and endDate
  Exclude weekends and public holidays

Business Rules:
- BR-001: If startDate > endDate, return 0
- BR-002: If startDate = endDate, return 1
- BR-003: Exclude Saturdays and Sundays
- BR-004: Exclude public holidays from provided list

Test Scenarios:
1. Normal case: Mon-Fri (5 days) = 5 days
2. With weekend: Fri-Mon (4 days) = 2 days (Sat, Sun excluded)
3. With holiday: Mon-Wed with Tue holiday = 2 days
4. Invalid: endDate < startDate = 0 days
```

### Expected Output

```typescript
// calculateLeaveDays.test.ts
import { calculateLeaveDays } from './calculateLeaveDays';

describe('calculateLeaveDays', () => {
  describe('Normal cases', () => {
    it('should calculate 5 days for Mon-Fri with no holidays', () => {
      // Arrange
      const startDate = new Date('2025-02-03'); // Monday
      const endDate = new Date('2025-02-07');   // Friday
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(5);
    });
    
    it('should return 1 day when startDate equals endDate', () => {
      // Arrange
      const startDate = new Date('2025-02-03'); // Monday
      const endDate = new Date('2025-02-03');   // Same Monday
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(1);
    });
  });
  
  describe('Weekend handling', () => {
    it('should exclude weekends from calculation', () => {
      // Arrange
      const startDate = new Date('2025-02-07'); // Friday
      const endDate = new Date('2025-02-10');   // Monday
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(2); // Friday and Monday only
    });
    
    it('should return 0 for weekend-only period', () => {
      // Arrange
      const startDate = new Date('2025-02-08'); // Saturday
      const endDate = new Date('2025-02-09');   // Sunday
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(0);
    });
  });
  
  describe('Public holiday handling', () => {
    it('should exclude public holidays from calculation', () => {
      // Arrange
      const startDate = new Date('2025-02-03'); // Monday
      const endDate = new Date('2025-02-05');   // Wednesday
      const publicHolidays = [
        new Date('2025-02-04') // Tuesday is holiday
      ];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(2); // Monday and Wednesday only
    });
  });
  
  describe('Edge cases', () => {
    it('should return 0 when endDate is before startDate', () => {
      // Arrange
      const startDate = new Date('2025-02-07');
      const endDate = new Date('2025-02-03');
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(0);
    });
    
    it('should handle empty public holidays array', () => {
      // Arrange
      const startDate = new Date('2025-02-03');
      const endDate = new Date('2025-02-05');
      const publicHolidays: Date[] = [];
      
      // Act
      const result = calculateLeaveDays(startDate, endDate, publicHolidays);
      
      // Assert
      expect(result).toBe(3);
    });
  });
});
```

---

## Example Usage - Integration Tests (API)

### Input

**API Spec** (excerpt):
```yaml
paths:
  /leave-requests:
    post:
      requestBody:
        required: true
        content:
          application/json:
            schema:
              properties:
                leaveTypeId: { type: string, format: uuid }
                startDate: { type: string, format: date }
                endDate: { type: string, format: date }
      responses:
        '201':
          description: Created
        '400':
          description: Validation error
```

**Behavioural Spec** (excerpt):
```markdown
Error Scenarios:
- INSUFFICIENT_BALANCE: When requested days > available
- OVERLAPPING_DATES: When dates overlap with approved request
- INVALID_DATE_RANGE: When endDate < startDate
```

### Expected Output

```typescript
// leaveRequest.integration.test.ts
import request from 'supertest';
import { app } from '../app';
import { setupTestDatabase, teardownTestDatabase } from '../test-utils';

describe('POST /api/leave-requests', () => {
  let authToken: string;
  let employeeId: string;
  let leaveTypeId: string;
  
  beforeAll(async () => {
    await setupTestDatabase();
    
    // Create test employee and get auth token
    const authResponse = await request(app)
      .post('/api/auth/login')
      .send({ username: 'test.employee', password: 'password' });
    
    authToken = authResponse.body.token;
    employeeId = authResponse.body.user.id;
    
    // Create test leave type
    const leaveTypeResponse = await request(app)
      .post('/api/leave-types')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        code: 'ANNUAL',
        name: 'Annual Leave',
        maxDaysPerYear: 20
      });
    
    leaveTypeId = leaveTypeResponse.body.id;
    
    // Create leave balance for employee
    await request(app)
      .post('/api/leave-balances')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        employeeId,
        leaveTypeId,
        year: 2025,
        totalAllocated: 20
      });
  });
  
  afterAll(async () => {
    await teardownTestDatabase();
  });
  
  describe('Success cases', () => {
    it('should create leave request with valid data', async () => {
      // Arrange
      const requestData = {
        employeeId,
        leaveTypeId,
        startDate: '2025-03-01',
        endDate: '2025-03-05',
        reason: 'Family vacation'
      };
      
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(requestData);
      
      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        id: expect.any(String),
        employeeId,
        leaveTypeId,
        startDate: '2025-03-01',
        endDate: '2025-03-05',
        status: 'PENDING',
        reason: 'Family vacation'
      });
      expect(response.headers.location).toMatch(/\/api\/leave-requests\/.+/);
    });
  });
  
  describe('Validation errors', () => {
    it('should return 400 when required fields are missing', async () => {
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send({});
      
      // Assert
      expect(response.status).toBe(400);
      expect(response.body.code).toBe('VALIDATION_ERROR');
      expect(response.body.errors).toEqual(
        expect.arrayContaining([
          expect.objectContaining({ field: 'leaveTypeId' }),
          expect.objectContaining({ field: 'startDate' }),
          expect.objectContaining({ field: 'endDate' })
        ])
      );
    });
    
    it('should return 400 when endDate is before startDate', async () => {
      // Arrange
      const requestData = {
        employeeId,
        leaveTypeId,
        startDate: '2025-03-10',
        endDate: '2025-03-05'
      };
      
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(requestData);
      
      // Assert
      expect(response.status).toBe(400);
      expect(response.body.code).toBe('INVALID_DATE_RANGE');
      expect(response.body.message).toContain('End date must be after or equal to start date');
    });
  });
  
  describe('Business rule violations', () => {
    it('should return 400 when insufficient leave balance', async () => {
      // Arrange - Request more days than available
      const requestData = {
        employeeId,
        leaveTypeId,
        startDate: '2025-04-01',
        endDate: '2025-04-30' // 30 days, but only 20 available
      };
      
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(requestData);
      
      // Assert
      expect(response.status).toBe(400);
      expect(response.body.code).toBe('INSUFFICIENT_BALANCE');
      expect(response.body.message).toMatch(/You have \d+ days available but requested \d+ days/);
    });
    
    it('should return 400 when dates overlap with approved request', async () => {
      // Arrange - Create an approved request first
      await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          employeeId,
          leaveTypeId,
          startDate: '2025-05-10',
          endDate: '2025-05-15'
        });
      
      // Try to create overlapping request
      const requestData = {
        employeeId,
        leaveTypeId,
        startDate: '2025-05-12',
        endDate: '2025-05-17'
      };
      
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .set('Authorization', `Bearer ${authToken}`)
        .send(requestData);
      
      // Assert
      expect(response.status).toBe(400);
      expect(response.body.code).toBe('OVERLAPPING_DATES');
    });
  });
  
  describe('Authentication', () => {
    it('should return 401 when no auth token provided', async () => {
      // Act
      const response = await request(app)
        .post('/api/leave-requests')
        .send({
          employeeId,
          leaveTypeId,
          startDate: '2025-06-01',
          endDate: '2025-06-05'
        });
      
      // Assert
      expect(response.status).toBe(401);
    });
  });
});
```

---

## Example Usage - E2E Tests (Playwright)

### Input

**UI Spec** (excerpt):
```markdown
Screen: Leave Request Form

User Flow:
1. Navigate to /leave-requests/new
2. Select leave type from dropdown
3. Enter start date
4. Enter end date
5. See total days calculated automatically
6. Enter reason (optional)
7. Click Submit
8. See success message
9. Redirect to leave requests list
```

### Expected Output

```typescript
// leaveRequest.e2e.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Leave Request Creation', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('[name="username"]', 'test.employee');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });
  
  test('should create leave request successfully', async ({ page }) => {
    // Navigate to leave request form
    await page.goto('/leave-requests/new');
    
    // Wait for form to load
    await expect(page.locator('h1')).toHaveText('Create Leave Request');
    
    // Select leave type
    await page.click('sl-select[name="leaveTypeId"]');
    await page.click('sl-option:has-text("Annual Leave")');
    
    // Enter start date
    await page.fill('[name="startDate"]', '2025-03-01');
    
    // Enter end date
    await page.fill('[name="endDate"]', '2025-03-05');
    
    // Verify total days is calculated
    await expect(page.locator('[name="totalDays"]')).toHaveValue('5');
    
    // Enter reason
    await page.fill('[name="reason"]', 'Family vacation');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Wait for success message
    await expect(page.locator('sl-alert[variant="success"]')).toBeVisible();
    await expect(page.locator('sl-alert[variant="success"]')).toContainText('Leave request submitted successfully');
    
    // Verify redirect to list
    await expect(page).toHaveURL('/leave-requests');
    
    // Verify new request appears in list
    await expect(page.locator('table')).toContainText('2025-03-01');
    await expect(page.locator('table')).toContainText('PENDING');
  });
  
  test('should show error when insufficient balance', async ({ page }) => {
    // Navigate to form
    await page.goto('/leave-requests/new');
    
    // Select leave type
    await page.click('sl-select[name="leaveTypeId"]');
    await page.click('sl-option:has-text("Annual Leave")');
    
    // Request more days than available (assume 3 days available)
    await page.fill('[name="startDate"]', '2025-04-01');
    await page.fill('[name="endDate"]', '2025-04-10'); // 10 days
    
    // Submit
    await page.click('button[type="submit"]');
    
    // Verify error message
    await expect(page.locator('sl-alert[variant="danger"]')).toBeVisible();
    await expect(page.locator('#error-message')).toContainText('Insufficient leave balance');
    
    // Verify still on form page
    await expect(page).toHaveURL('/leave-requests/new');
  });
  
  test('should validate required fields', async ({ page }) => {
    // Navigate to form
    await page.goto('/leave-requests/new');
    
    // Try to submit without filling fields
    await page.click('button[type="submit"]');
    
    // Verify validation errors
    await expect(page.locator('sl-select[name="leaveTypeId"]')).toHaveAttribute('data-invalid', '');
    await expect(page.locator('[name="startDate"]')).toHaveAttribute('data-invalid', '');
    await expect(page.locator('[name="endDate"]')).toHaveAttribute('data-invalid', '');
  });
  
  test('should calculate total days automatically', async ({ page }) => {
    // Navigate to form
    await page.goto('/leave-requests/new');
    
    // Enter dates
    await page.fill('[name="startDate"]', '2025-03-03'); // Monday
    await page.fill('[name="endDate"]', '2025-03-07');   // Friday
    
    // Verify calculation
    await expect(page.locator('[name="totalDays"]')).toHaveValue('5');
    
    // Change end date
    await page.fill('[name="endDate"]', '2025-03-10'); // Next Monday
    
    // Verify recalculation (should be 6 working days)
    await expect(page.locator('[name="totalDays"]')).toHaveValue('6');
  });
});
```

---

## Variations

### For Specific Test Type
```
Generate [Unit | Integration | E2E] tests for {FeatureName}

Focus on:
- {Aspect 1}
- {Aspect 2}

Include test cases for:
- {Scenario 1}
- {Scenario 2}
```

### For Specific Scenario
```
Generate tests for this specific scenario:

Scenario: {Name}
Given: {Preconditions}
When: {Actions}
Then: {Expected results}

Generate: [Unit | Integration | E2E] test
```

### For Error Cases
```
Generate tests for all error scenarios in the behavioural spec:

Error Codes:
- {CODE_1}: {Description}
- {CODE_2}: {Description}

For each error, test:
- Trigger condition
- Error response format
- Error message
- HTTP status code
```

---

## Tips for Better Results

### DO ✅
- Provide complete behavioural spec with scenarios
- Include all business rules and validation rules
- Specify expected error codes and messages
- Mention edge cases to test
- Indicate which type of tests to generate
- Provide API/UI specs for integration/E2E tests

### DON'T ❌
- Expect AI to invent test scenarios not in specs
- Forget to specify test framework preferences
- Leave out setup/teardown requirements
- Mix different types of tests in one request

---

## Follow-up Prompts

```
"Add more edge case tests for date validation"

"Add tests for concurrent request scenarios"

"Add performance tests for list endpoint with 1000 items"

"Add accessibility tests for the form"

"Add visual regression tests using Playwright"

"Add tests for error message display"
```

---

## Quality Checklist

Generated tests should:
- [ ] Have clear, descriptive test names
- [ ] Follow AAA pattern (Arrange, Act, Assert)
- [ ] Include positive and negative cases
- [ ] Test edge cases
- [ ] Be independent and repeatable
- [ ] Have proper setup and teardown
- [ ] Use appropriate assertions
- [ ] Include comments for complex logic
- [ ] Group related tests
- [ ] Cover all scenarios from spec

---

## Related Prompts
- [Generate Concept from Ontology](./generate-concept-from-ontology.md)
- [Generate API from Ontology](./generate-api-from-ontology.md)
- [Generate UI from Spec](./generate-ui-from-spec.md)
