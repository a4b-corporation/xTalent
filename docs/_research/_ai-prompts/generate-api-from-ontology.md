# Generate OpenAPI Specification from Ontology

## Purpose
This prompt helps AI generate comprehensive OpenAPI (Swagger) specifications from ontology and behavioural specifications.

## Context
You are an API architect creating RESTful API specifications for an HCM system. You will be given ontology definitions and behavioural specs, and you need to generate a complete OpenAPI 3.0 specification.

---

## Prompt Template

```
You are an API architect creating OpenAPI specifications for the xTalent HCM system.

I will provide you with:
1. Ontology file (YAML) - defining domain entities, attributes, relationships
2. Behavioural specification (MD) - defining business logic and validation rules

Your task is to generate a complete OpenAPI 3.0 specification that includes:

1. **Resource Endpoints**
   - CRUD operations (GET, POST, PUT, DELETE)
   - List with pagination, filtering, sorting
   - Bulk operations if needed
   - Custom actions (approve, reject, etc.)

2. **Request/Response Schemas**
   - Based on entity attributes from ontology
   - Separate schemas for Create, Update, and Read operations
   - Include all validation rules from behavioural spec

3. **Error Responses**
   - Standard HTTP error codes
   - Custom error codes from behavioural spec
   - Detailed error schema with field-level errors

4. **Query Parameters**
   - Pagination (page, pageSize)
   - Filtering (by status, date range, etc.)
   - Sorting (sortBy, sortOrder)
   - Search

5. **Security**
   - Bearer token authentication
   - Role-based access control hints

Guidelines:
- Follow REST best practices
- Use plural nouns for resources (/leave-requests, not /leave-request)
- Use HTTP verbs correctly (GET for read, POST for create, etc.)
- Include examples for all schemas
- Map validation rules from behavioural spec to schema validations
- Use appropriate HTTP status codes
- Include comprehensive error responses
- Add descriptions for all fields and endpoints

Here are the input files:

[PASTE ONTOLOGY YAML]

[PASTE BEHAVIOURAL SPEC]

Please generate the OpenAPI specification following the template in /_templates/api-spec-template.yaml
```

---

## Example Usage

### Input

**Ontology**:
```yaml
entities:
  LeaveRequest:
    attributes:
      - id: string (UUID)
      - employeeId: string (UUID)
      - leaveTypeId: string (UUID)
      - startDate: date
      - endDate: date
      - status: enum [DRAFT, PENDING, APPROVED, REJECTED]
      - reason: string (max 500)
    rules:
      - "endDate must be >= startDate"
      - "Cannot overlap with approved requests"
```

**Behavioural Spec** (excerpt):
```markdown
## Validation Rules
- startDate: Required, must be >= today
- endDate: Required, must be >= startDate
- reason: Optional, max 500 characters

## Error Codes
- INSUFFICIENT_BALANCE: When requested days > available
- OVERLAPPING_DATES: When dates overlap with approved request
```

### Expected Output

```yaml
openapi: 3.0.3
info:
  title: "Leave Request API"
  version: "1.0.0"

paths:
  /leave-requests:
    get:
      summary: "List leave requests"
      parameters:
        - name: status
          in: query
          schema:
            type: string
            enum: [DRAFT, PENDING, APPROVED, REJECTED]
      responses:
        '200':
          description: "Success"
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/LeaveRequest'
    
    post:
      summary: "Create leave request"
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LeaveRequestCreate'
      responses:
        '201':
          description: "Created"
        '400':
          description: "Validation error"
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                insufficientBalance:
                  value:
                    code: "INSUFFICIENT_BALANCE"
                    message: "You have only 3 days available"

components:
  schemas:
    LeaveRequest:
      type: object
      properties:
        id:
          type: string
          format: uuid
        employeeId:
          type: string
          format: uuid
        startDate:
          type: string
          format: date
        endDate:
          type: string
          format: date
        status:
          type: string
          enum: [DRAFT, PENDING, APPROVED, REJECTED]
        reason:
          type: string
          maxLength: 500
    
    LeaveRequestCreate:
      type: object
      required:
        - employeeId
        - leaveTypeId
        - startDate
        - endDate
      properties:
        employeeId:
          type: string
          format: uuid
        leaveTypeId:
          type: string
          format: uuid
        startDate:
          type: string
          format: date
          description: "Must be today or future date"
        endDate:
          type: string
          format: date
          description: "Must be >= startDate"
        reason:
          type: string
          maxLength: 500
```

---

## Variations

### For a Single Resource
```
Generate OpenAPI specification for the {ResourceName} resource based on:

Ontology:
[PASTE ENTITY DEFINITION]

Behavioural Spec:
[PASTE RELEVANT SECTIONS]

Include:
- All CRUD operations
- Pagination for list endpoint
- Filtering by {field1}, {field2}
- Custom action: {actionName}
```

### For Custom Actions
```
Add a custom action endpoint to the existing API spec:

Action: {ActionName}
Entity: {EntityName}
HTTP Method: {POST | PUT | PATCH}
Path: /api/{module}/{resources}/{id}/{action}

Business Logic:
[DESCRIBE WHAT THE ACTION DOES]

Request Body:
[DESCRIBE REQUIRED FIELDS]

Success Response:
[DESCRIBE RESPONSE]

Error Cases:
[LIST POSSIBLE ERRORS]
```

### For Bulk Operations
```
Add bulk operation endpoints for {ResourceName}:

1. Bulk Create: POST /api/{resources}/bulk
2. Bulk Update: PUT /api/{resources}/bulk
3. Bulk Delete: DELETE /api/{resources}/bulk

Requirements:
- Accept array of items
- Return array of results with success/failure per item
- Limit: max {N} items per request
- Transaction: {all-or-nothing | partial-success}
```

---

## Tips for Better Results

### DO ✅
- Provide complete ontology with all attributes and types
- Include all validation rules from behavioural spec
- Specify custom error codes and messages
- Mention any custom actions (approve, reject, etc.)
- Indicate which fields are required vs optional
- Specify relationships that should be included/expanded

### DON'T ❌
- Expect AI to invent validation rules not in specs
- Forget to specify authentication requirements
- Leave out error handling details
- Mix multiple resources in one request (do one at a time)

---

## Follow-up Prompts

After initial generation, you can refine:

```
"Add filtering by date range (startDate, endDate) to the list endpoint"

"Include examples for all error responses"

"Add a custom action endpoint for approving leave requests:
 POST /api/leave-requests/{id}/approve"

"Generate request/response examples for the create endpoint"

"Add bulk operations for creating multiple leave requests"

"Include field descriptions for all schema properties"
```

---

## Quality Checklist

Generated API spec should:
- [ ] Follow REST conventions (plural resources, correct HTTP verbs)
- [ ] Include all CRUD operations
- [ ] Have pagination on list endpoints
- [ ] Include filtering and sorting parameters
- [ ] Map all entity attributes to schema properties
- [ ] Include all validation rules as schema constraints
- [ ] Define all error codes from behavioural spec
- [ ] Have examples for requests and responses
- [ ] Include authentication/authorization
- [ ] Use appropriate HTTP status codes
- [ ] Have clear descriptions for all endpoints and fields

---

## Integration with Other Prompts

**Before this prompt**:
1. Generate ontology
2. Generate behavioural spec

**After this prompt**:
1. Generate UI from API spec
2. Generate tests from API spec
3. Generate implementation code

---

## Related Prompts
- [Generate Concept from Ontology](./generate-concept-from-ontology.md)
- [Generate UI from Spec](./generate-ui-from-spec.md)
- [Generate Tests from Scenarios](./generate-tests-from-scenarios.md)
- [Generate Code from API Spec](./generate-code-from-api.md)
