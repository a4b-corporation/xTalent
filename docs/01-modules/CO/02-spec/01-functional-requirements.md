# Core Module - Functional Requirements

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Module**: Core (CO)  
**Status**: Draft

---

## 📋 Overview

This document defines all functional requirements for the xTalent Core Module. Requirements are organized by feature area and follow the format:

```
FR-[CODE]-NNN: [Requirement Title]
  Priority: HIGH/MEDIUM/LOW
  User Story: As a [role], I want [action] so that [benefit]
  Acceptance Criteria: Given/When/Then format
```

**Total Requirements**: ~400 FRs across 15 features

---

## 📊 Requirements Summary

| Feature Area | FR Range | Count | Priority |
|--------------|----------|-------|----------|
| Code List & Configuration | FR-CFG-001 to 040 | 40 | CRITICAL |
| Worker Management | FR-WRK-001 to 025 | 25 | HIGH |
| Work Relationship | FR-WR-001 to 030 | 30 | HIGH |
| Employee Management | FR-EMP-001 to 025 | 25 | HIGH |
| Assignment Management | FR-ASG-001 to 045 | 45 | HIGH |
| Basic Reporting | FR-RPT-001 to 020 | 20 | MEDIUM |
| Business Unit | FR-BU-001 to 035 | 35 | MEDIUM |
| Job Taxonomy | FR-TAX-001 to 030 | 30 | MEDIUM |
| Job Profile | FR-PRF-001 to 030 | 30 | MEDIUM |
| Position Management | FR-POS-001 to 035 | 35 | MEDIUM |
| Matrix Reporting | FR-MTX-001 to 025 | 25 | MEDIUM |
| Skill Catalog | FR-SKL-001 to 025 | 25 | LOW |
| Skill Assessment | FR-ASS-001 to 030 | 30 | LOW |
| Career Paths | FR-CAR-001 to 025 | 25 | LOW |
| Data Privacy | FR-PRI-001 to 030 | 30 | MEDIUM |

**Total**: ~450 Functional Requirements

---

## 🔧 Phase 0: Foundation

### Code List & Configuration Management (FR-CFG)

#### FR-CFG-001: Create Code List Group

**Priority**: CRITICAL

**User Story**:
```
As an HR Admin
I want to create a new code list group
So that I can organize related code values
```

**Description**:
System shall allow authorized users to create new code list groups with a unique group code and description.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I submit a new code list group with valid data
- Then the group is created with a unique group code
- And the group is available for adding code values
- And an audit log entry is created

**Dependencies**: None

**Business Rules**: BR-CFG-001, BR-CFG-002

**Related Entities**: CodeList

---

#### FR-CFG-002: Add Code Value to Group

**Priority**: CRITICAL

**User Story**:
```
As an HR Admin
I want to add code values to a group
So that users can select from predefined values
```

**Description**:
System shall allow adding code values to existing code list groups with localization support.

**Acceptance Criteria**:
- Given a code list group exists
- When I add a code value with code, display_en, display_local
- Then the code value is added to the group
- And the code is unique within the group
- And both English and local language displays are stored
- And sort order can be specified

**Dependencies**: FR-CFG-001

**Business Rules**: BR-CFG-001, BR-CFG-005

**Related Entities**: CodeList

---

#### FR-CFG-003: Update Code Value

**Priority**: CRITICAL

**User Story**:
```
As an HR Admin
I want to update code value display text
So that I can correct errors or improve clarity
```

**Description**:
System shall allow updating code value display text and metadata using SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a code value exists
- When I update the display text or metadata
- Then a new version is created (SCD Type 2)
- And the old version is marked as historical
- And the new version becomes current
- And effective dates are set correctly

**Dependencies**: FR-CFG-002

**Business Rules**: BR-CFG-004

**Related Entities**: CodeList

---

#### FR-CFG-004: Deactivate Code Value

**Priority**: CRITICAL

**User Story**:
```
As an HR Admin
I want to deactivate obsolete code values
So that they don't appear in dropdowns for new records
```

**Description**:
System shall allow deactivating code values while preserving them for historical records.

**Acceptance Criteria**:
- Given a code value exists and is active
- When I deactivate the code value
- Then is_current_flag is set to false
- And effective_end_date is set to today
- And the code no longer appears in dropdowns
- And existing records using this code are not affected
- And historical reports can still use this code

**Dependencies**: FR-CFG-002

**Business Rules**: BR-CFG-003, BR-CFG-004

**Related Entities**: CodeList

---

#### FR-CFG-005: Localize Code Values

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to provide translations for code values
So that users see values in their preferred language
```

**Description**:
System shall support multi-language display for code values.

**Acceptance Criteria**:
- Given a code value exists
- When I provide display_en and display_local
- Then both values are stored
- And users see the appropriate language based on their preference
- And at least one language display is required

**Dependencies**: FR-CFG-002

**Business Rules**: BR-CFG-005

**Related Entities**: CodeList

---

#### FR-CFG-010: Manage Currencies

**Priority**: HIGH

**User Story**:
```
As a System Admin
I want to manage currency master data
So that we support multi-currency payroll
```

**Description**:
System shall allow managing currencies following ISO-4217 standard.

**Acceptance Criteria**:
- Given I am a System Admin
- When I add a currency with code, name, symbol, decimal_digits
- Then the currency is created
- And the code follows ISO-4217 (3 characters)
- And decimal_digits determines rounding rules
- And the currency is available for payroll configuration

**Dependencies**: None

**Business Rules**: BR-CFG-010

**Related Entities**: Currency

---

#### FR-CFG-011: Manage Timezones

**Priority**: HIGH

**User Story**:
```
As a System Admin
I want to manage timezone master data
So that we support global workforce
```

**Description**:
System shall allow managing timezones following IANA standard.

**Acceptance Criteria**:
- Given I am a System Admin
- When I add a timezone with tzid, offset_hours, abbreviation
- Then the timezone is created
- And the tzid follows IANA format (e.g., Asia/Ho_Chi_Minh)
- And UTC offset is stored
- And the timezone is available for location configuration

**Dependencies**: None

**Business Rules**: BR-CFG-011

**Related Entities**: TimeZone

---

#### FR-CFG-015: Manage Countries

**Priority**: MEDIUM

**User Story**:
```
As a System Admin
I want to manage country master data
So that we can track employee locations and nationalities
```

**Description**:
System shall allow managing country master data with ISO codes.

**Acceptance Criteria**:
- Given I am a System Admin
- When I add a country with code, name, currency, timezone
- Then the country is created
- And the code follows ISO-3166 (2 or 3 characters)
- And default currency and timezone can be set
- And the country is available for address and nationality

**Dependencies**: FR-CFG-010, FR-CFG-011

**Business Rules**: None

**Related Entities**: Country

---

#### FR-CFG-020: Search and Filter Code Lists

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter code lists
So that I can find specific codes quickly
```

**Description**:
System shall provide search and filter capabilities for code lists.

**Acceptance Criteria**:
- Given code lists exist
- When I search by group code, code, or display text
- Then matching results are returned
- And I can filter by active/inactive status
- And I can filter by group
- And results are paginated

**Dependencies**: FR-CFG-001, FR-CFG-002

**Business Rules**: None

**Related Entities**: CodeList

---

#### FR-CFG-025: Export Code Lists

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to export code lists to Excel
So that I can review and backup configuration
```

**Description**:
System shall allow exporting code lists to Excel format.

**Acceptance Criteria**:
- Given code lists exist
- When I request export
- Then an Excel file is generated
- And all code groups and values are included
- And both English and local language displays are exported
- And metadata is included
- And the file can be downloaded

**Dependencies**: FR-CFG-001, FR-CFG-002

**Business Rules**: None

**Related Entities**: CodeList

---

#### FR-CFG-026: Import Code Lists

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to import code lists from Excel
So that I can bulk load configuration data
```

**Description**:
System shall allow importing code lists from Excel format.

**Acceptance Criteria**:
- Given I have an Excel file with code lists
- When I upload the file
- Then the system validates the format
- And validates uniqueness constraints
- And creates/updates code values
- And provides a summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-CFG-001, FR-CFG-002

**Business Rules**: BR-CFG-001, BR-CFG-002

**Related Entities**: CodeList

---

#### FR-CFG-030: Code List Versioning

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track code list changes over time
So that I can see historical values
```

**Description**:
System shall implement SCD Type 2 versioning for code list changes.

**Acceptance Criteria**:
- Given a code value exists
- When I make changes to the code value
- Then a new version is created
- And effective_start_date is set to today
- And previous version's effective_end_date is set to yesterday
- And is_current_flag is updated accordingly
- And all versions are retained

**Dependencies**: FR-CFG-002, FR-CFG-003

**Business Rules**: BR-CFG-004

**Related Entities**: CodeList

---

#### FR-CFG-035: Seed Initial Code Lists

**Priority**: CRITICAL

**User Story**:
```
As a System Admin
I want to seed initial code lists during system setup
So that the system is ready to use
```

**Description**:
System shall provide seed data scripts for all standard code list groups.

**Acceptance Criteria**:
- Given the system is being set up
- When I run the seed data script
- Then all standard code groups are created
- And all standard code values are added
- And Vietnamese translations are included
- And common currencies are added (VND, USD, EUR, SGD)
- And common timezones are added
- And countries are added
- And the system is ready for use

**Dependencies**: FR-CFG-001, FR-CFG-002, FR-CFG-010, FR-CFG-011

**Business Rules**: None

**Related Entities**: CodeList, Currency, TimeZone, Country

---

#### FR-CFG-036: Code List Dropdown Component

**Priority**: HIGH

**User Story**:
```
As a Developer
I want a reusable dropdown component for code lists
So that all forms use consistent code list values
```

**Description**:
System shall provide a reusable UI component that reads from code lists for dropdowns.

**Acceptance Criteria**:
- Given a code list group exists
- When I use the dropdown component with group code
- Then active code values are loaded
- And values are displayed in the user's language
- And values are sorted by sort_order
- And inactive codes are excluded
- And the component is reusable across all forms

**Dependencies**: FR-CFG-002

**Business Rules**: BR-CFG-003, BR-CFG-015

**Related Entities**: CodeList

---

#### FR-CFG-037: Code List Caching

**Priority**: MEDIUM

**User Story**:
```
As a System Admin
I want code lists to be cached
So that performance is optimized
```

**Description**:
System shall implement caching strategy for frequently accessed code lists.

**Acceptance Criteria**:
- Given code lists are accessed frequently
- When code lists are requested
- Then cached values are returned if available
- And cache is invalidated when code lists change
- And cache TTL is configurable
- And performance is improved

**Dependencies**: FR-CFG-002

**Business Rules**: None

**Related Entities**: CodeList

---

#### FR-CFG-038: Code List Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to see code list change history
So that I can track configuration changes
```

**Description**:
System shall maintain audit trail for all code list changes.

**Acceptance Criteria**:
- Given code list changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded
- And previous values are retained

**Dependencies**: FR-CFG-003, FR-CFG-030

**Business Rules**: None

**Related Entities**: CodeList, AuditLog

---

#### FR-CFG-039: Code List Validation Rules

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define validation rules for code values
So that data entry is validated
```

**Description**:
System shall allow defining validation rules in code list metadata.

**Acceptance Criteria**:
- Given a code value exists
- When I add validation rules to metadata
- Then rules are stored in metadata field (JSONB)
- And rules can include regex, min/max, required fields
- And rules are enforced during data entry
- And validation errors are displayed

**Dependencies**: FR-CFG-002

**Business Rules**: None

**Related Entities**: CodeList

---

#### FR-CFG-040: Code List UI Customization

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to customize code list display
So that codes are visually distinct
```

**Description**:
System shall allow customizing code list display with colors and icons.

**Acceptance Criteria**:
- Given a code value exists
- When I add color and icon to metadata
- Then color and icon are stored
- And UI displays codes with custom colors
- And UI displays codes with custom icons
- And customization enhances user experience

**Dependencies**: FR-CFG-002

**Business Rules**: None

**Related Entities**: CodeList

---

## 👤 Phase 1: Core Employment

### Worker Management (FR-WRK)

#### FR-WRK-001: Create Worker Record

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create a worker record
So that I can track person identity
```

**Description**:
System shall allow creating worker records with personal information and proper data classification.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I submit worker creation form with valid data
- Then a new worker record is created
- And a unique worker ID is generated
- And data classification is enforced (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED)
- And RESTRICTED data is encrypted (AES-256)
- And an audit log entry is created
- And the worker is available for work relationship creation

**Dependencies**: FR-CFG-002 (for GENDER, MARITAL_STATUS, etc.)

**Business Rules**: BR-WRK-001, BR-WRK-002, BR-WRK-004

**Related Entities**: Worker

**API Endpoints**: POST /api/v1/workers

---

#### FR-WRK-002: Update Worker Information

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update worker information
So that data stays accurate
```

**Description**:
System shall allow updating worker information with SCD Type 2 versioning for significant changes.

**Acceptance Criteria**:
- Given a worker exists
- When I update worker information
- Then changes are saved
- And SCD Type 2 is applied for name, DOB changes
- And data classification is enforced
- And RESTRICTED data remains encrypted
- And audit log is created
- And previous versions are retained

**Dependencies**: FR-WRK-001

**Business Rules**: BR-WRK-001, BR-WRK-004

**Related Entities**: Worker

**API Endpoints**: PUT /api/v1/workers/{id}, PATCH /api/v1/workers/{id}

---

#### FR-WRK-003: View Worker Details

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to view worker details
So that I can verify information
```

**Description**:
System shall allow viewing worker details with appropriate data access controls.

**Acceptance Criteria**:
- Given a worker exists
- When I request worker details
- Then worker information is displayed
- And data classification is respected
- And RESTRICTED data is masked for unauthorized users
- And RESTRICTED data is decrypted for authorized users
- And audit log is created for RESTRICTED data access

**Dependencies**: FR-WRK-001

**Business Rules**: BR-WRK-004, BR-WRK-010

**Related Entities**: Worker

**API Endpoints**: GET /api/v1/workers/{id}

---

#### FR-WRK-004: Manage Worker Addresses

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage worker addresses
So that we can contact workers
```

**Description**:
System shall allow managing multiple addresses per worker (home, mailing, emergency).

**Acceptance Criteria**:
- Given a worker exists
- When I add an address
- Then the address is linked to the worker
- And address type is specified (HOME, MAILING, EMERGENCY)
- And one address can be marked as primary
- And address data is classified as CONFIDENTIAL
- And historical addresses are retained

**Dependencies**: FR-WRK-001, FR-CFG-002 (for address types)

**Business Rules**: BR-WRK-005

**Related Entities**: Worker, WorkerAddress

**API Endpoints**: POST /api/v1/workers/{id}/addresses

---

#### FR-WRK-005: Manage Worker Contacts

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage worker contact information
So that we can reach workers
```

**Description**:
System shall allow managing multiple contact methods per worker (phone, email, emergency contact).

**Acceptance Criteria**:
- Given a worker exists
- When I add contact information
- Then the contact is linked to the worker
- And contact type is specified (PHONE, EMAIL, EMERGENCY)
- And one contact per type can be marked as primary
- And contact data is classified appropriately
- And historical contacts are retained

**Dependencies**: FR-WRK-001, FR-CFG-002 (for contact types)

**Business Rules**: BR-WRK-006

**Related Entities**: Worker, WorkerContact

**API Endpoints**: POST /api/v1/workers/{id}/contacts

---

#### FR-WRK-010: Data Classification Enforcement

**Priority**: CRITICAL

**User Story**:
```
As a DPO
I want to enforce data classification
So that we comply with privacy laws
```

**Description**:
System shall enforce data classification at field level for worker data.

**Acceptance Criteria**:
- Given worker data exists
- When data is accessed or modified
- Then classification rules are enforced
- And PUBLIC data is accessible to all
- And INTERNAL data is accessible to same organization
- And CONFIDENTIAL data is accessible to manager + HR
- And RESTRICTED data is accessible to HR only with purpose
- And access is logged according to classification

**Dependencies**: FR-WRK-001, FR-CFG-002 (for DATA_CLASSIFICATION)

**Business Rules**: BR-WRK-004

**Related Entities**: Worker

---

#### FR-WRK-015: Consent Management

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to manage worker consents
So that we process data lawfully
```

**Description**:
System shall allow managing consents for processing sensitive worker data.

**Acceptance Criteria**:
- Given a worker exists
- When I request consent for biometric/health data
- Then a consent record is created
- And consent type is specified
- And purpose is documented
- And legal basis is recorded
- And worker can give/withdraw consent
- And consent status is tracked
- And processing is blocked without consent

**Dependencies**: FR-WRK-001, FR-CFG-002 (for CONSENT_TYPE)

**Business Rules**: BR-WRK-010

**Related Entities**: Worker, Consent

**API Endpoints**: POST /api/v1/workers/{id}/consents

---

#### FR-WRK-020: Worker Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter workers
So that I can find specific workers quickly
```

**Description**:
System shall provide search and filter capabilities for workers.

**Acceptance Criteria**:
- Given workers exist
- When I search by name, ID, or other criteria
- Then matching results are returned
- And I can filter by gender, marital status, etc.
- And I can filter by active/inactive status
- And results are paginated
- And data classification is respected in results

**Dependencies**: FR-WRK-001

**Business Rules**: BR-WRK-004

**Related Entities**: Worker

**API Endpoints**: GET /api/v1/workers

---

**[Continue with remaining FR-WRK requirements: FR-WRK-021 to FR-WRK-025]**

---

### Work Relationship Management (FR-WR)

#### FR-WR-001: Create Work Relationship

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create a work relationship
So that I can track employment
```

**Description**:
System shall allow creating work relationships between workers and the organization.

**Acceptance Criteria**:
- Given a worker exists
- When I create a work relationship
- Then the relationship is created
- And relationship type is specified (EMPLOYEE, CONTRACTOR, etc.)
- And legal entity is specified
- And start date is set
- And end date is optional (open-ended)
- And status is set to ACTIVE
- And the relationship is available for employee/assignment creation

**Dependencies**: FR-WRK-001, FR-CFG-002 (for WORK_RELATIONSHIP_TYPE)

**Business Rules**: BR-WR-001, BR-WR-002

**Related Entities**: Worker, WorkRelationship

**API Endpoints**: POST /api/v1/work-relationships

---

#### FR-WR-002: Update Work Relationship

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update work relationship details
So that information stays current
```

**Description**:
System shall allow updating work relationship information.

**Acceptance Criteria**:
- Given a work relationship exists
- When I update relationship details
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-002, BR-WR-003

**Related Entities**: WorkRelationship

**API Endpoints**: PUT /api/v1/work-relationships/{id}

---

#### FR-WR-003: Terminate Work Relationship

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to terminate a work relationship
So that we can process resignations/terminations
```

**Description**:
System shall allow terminating work relationships with proper reason tracking.

**Acceptance Criteria**:
- Given an active work relationship exists
- When I terminate the relationship
- Then end date is set
- And termination reason is required
- And status is set to TERMINATED
- And related employee record is ended
- And related assignments are ended
- And audit log is created

**Dependencies**: FR-WR-001, FR-CFG-002 (for TERMINATION_REASON)

**Business Rules**: BR-WR-003, BR-WR-010

**Related Entities**: WorkRelationship

**API Endpoints**: POST /api/v1/work-relationships/{id}/terminate

---

#### FR-WR-005: Support Multiple Concurrent Relationships

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to support multiple concurrent relationships
So that a worker can be both employee and contractor
```

**Description**:
System shall allow a worker to have multiple active work relationships simultaneously.

**Acceptance Criteria**:
- Given a worker exists
- When I create a second work relationship
- Then both relationships can be active
- And only one EMPLOYEE relationship is allowed
- And multiple CONTRACTOR relationships are allowed
- And each relationship is independent

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-004, BR-WR-005

**Related Entities**: Worker, WorkRelationship

---

#### FR-WR-010: Handle Rehires

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to handle rehires
So that we preserve employment history
```

**Description**:
System shall support rehiring workers with preserved history.

**Acceptance Criteria**:
- Given a worker with terminated relationship exists
- When I create a new work relationship for the same worker
- Then a new relationship is created
- And previous relationship history is preserved
- And original hire date is tracked
- And seniority calculation includes all periods
- And the worker is marked as rehire

**Dependencies**: FR-WR-001, FR-WR-003

**Business Rules**: BR-WR-015

**Related Entities**: Worker, WorkRelationship

---

### Work Relationship Management (FR-WR) - Continued

#### FR-WR-011: Work Relationship Status Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage work relationship status
So that I can track relationship lifecycle
```

**Description**:
System shall allow managing work relationship status (ACTIVE, SUSPENDED, TERMINATED).

**Acceptance Criteria**:
- Given a work relationship exists
- When I change status
- Then status is updated
- And effective date is set
- And status history is retained (SCD Type 2)
- And related employee/assignment status is updated
- And audit log is created

**Dependencies**: FR-WR-001, FR-CFG-002 (for status codes)

**Business Rules**: BR-WR-020

**Related Entities**: WorkRelationship

**API Endpoints**: PUT /api/v1/work-relationships/{id}/status

---

#### FR-WR-012: Work Relationship Suspension

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to suspend a work relationship
So that I can handle leave of absence
```

**Description**:
System shall allow suspending work relationships temporarily.

**Acceptance Criteria**:
- Given an active work relationship exists
- When I suspend the relationship
- Then status is set to SUSPENDED
- And suspension start date is set
- And suspension end date is optional
- And related assignments are suspended
- And the relationship can be reactivated

**Dependencies**: FR-WR-001, FR-WR-011

**Business Rules**: BR-WR-021

**Related Entities**: WorkRelationship

**API Endpoints**: POST /api/v1/work-relationships/{id}/suspend

---

#### FR-WR-013: Work Relationship Reactivation

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to reactivate a suspended relationship
So that employee can return to work
```

**Description**:
System shall allow reactivating suspended work relationships.

**Acceptance Criteria**:
- Given a suspended work relationship exists
- When I reactivate the relationship
- Then status is set to ACTIVE
- And suspension end date is set
- And related assignments are reactivated
- And audit log is created

**Dependencies**: FR-WR-012

**Business Rules**: BR-WR-022

**Related Entities**: WorkRelationship

**API Endpoints**: POST /api/v1/work-relationships/{id}/reactivate

---

#### FR-WR-015: Contractor to Employee Conversion

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to convert a contractor to employee
So that we can transition workers
```

**Description**:
System shall support converting contractor relationships to employee relationships.

**Acceptance Criteria**:
- Given a CONTRACTOR work relationship exists
- When I convert to EMPLOYEE
- Then current relationship is ended
- And new EMPLOYEE relationship is created
- And conversion date is set
- And employee record is created
- And assignment is transferred
- And seniority is calculated from original start date
- And audit log is created

**Dependencies**: FR-WR-001, FR-WR-003, FR-EMP-001

**Business Rules**: BR-WR-025

**Related Entities**: WorkRelationship, Employee

**API Endpoints**: POST /api/v1/work-relationships/{id}/convert-to-employee

---

#### FR-WR-016: Work Relationship History View

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to view work relationship history
So that I can see all employment periods
```

**Description**:
System shall provide a view of all work relationship history for a worker.

**Acceptance Criteria**:
- Given a worker has multiple work relationships
- When I view relationship history
- Then all relationships are displayed
- And relationships are sorted by start date
- And current and historical relationships are shown
- And status changes are visible
- And gaps between relationships are identified

**Dependencies**: FR-WR-001

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: GET /api/v1/workers/{workerId}/work-relationships

---

#### FR-WR-017: Work Relationship Document Attachment

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to attach documents to work relationships
So that I can store contracts and agreements
```

**Description**:
System shall allow attaching documents to work relationships.

**Acceptance Criteria**:
- Given a work relationship exists
- When I attach a document
- Then the document is linked to the relationship
- And document type is specified (CONTRACT, AGREEMENT, etc.)
- And document is stored securely
- And document can be downloaded
- And document access is controlled

**Dependencies**: FR-WR-001, FR-CFG-002 (for DOCUMENT_TYPE)

**Business Rules**: None

**Related Entities**: WorkRelationship, Document

**API Endpoints**: POST /api/v1/work-relationships/{id}/documents

---

#### FR-WR-018: Work Relationship Notifications

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to receive notifications for relationship events
So that I can take timely action
```

**Description**:
System shall send notifications for work relationship events.

**Acceptance Criteria**:
- Given a work relationship event occurs
- When the event is triggered
- Then notifications are sent to relevant parties
- And notification types include: hire, termination, conversion
- And notifications can be email or in-app
- And notification preferences can be configured

**Dependencies**: FR-WR-001, FR-WR-003, FR-WR-015

**Business Rules**: None

**Related Entities**: WorkRelationship

---

#### FR-WR-020: Work Relationship Reporting

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view work relationship reports
So that I can analyze workforce composition
```

**Description**:
System shall provide reports on work relationships.

**Acceptance Criteria**:
- Given work relationships exist
- When I request a report
- Then report shows relationship counts by type
- And report shows active vs terminated relationships
- And report shows conversion trends
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-WR-001

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: GET /api/v1/reports/work-relationships

---

#### FR-WR-021: Work Relationship Legal Entity Tracking

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to track legal entity for work relationships
So that we comply with local employment laws
```

**Description**:
System shall track which legal entity employs the worker for each work relationship.

**Acceptance Criteria**:
- Given a work relationship is created
- When I specify legal entity
- Then legal entity is linked to work relationship
- And legal entity determines applicable labor laws
- And legal entity determines payroll processing
- And legal entity is required for all relationships
- And legal entity cannot be changed (create new relationship instead)

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-030

**Related Entities**: WorkRelationship, LegalEntity

**API Endpoints**: POST /api/v1/work-relationships (with legal_entity_id)

---

#### FR-WR-022: Work Relationship Contract Terms

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track contract terms for work relationships
So that we manage contract renewals
```

**Description**:
System shall allow tracking contract terms and renewal dates for work relationships.

**Acceptance Criteria**:
- Given a work relationship exists
- When I add contract terms
- Then contract type is specified (PERMANENT, FIXED_TERM, etc.)
- And contract start and end dates are set
- And contract renewal date is tracked
- And notifications are sent before contract expiry
- And contract history is retained

**Dependencies**: FR-WR-001, FR-CFG-002 (for CONTRACT_TYPE)

**Business Rules**: BR-WR-031

**Related Entities**: WorkRelationship

---

#### FR-WR-023: Work Relationship Probation Tracking

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track probation periods for work relationships
So that we can evaluate new hires
```

**Description**:
System shall track probation periods at work relationship level.

**Acceptance Criteria**:
- Given a work relationship is created
- When I specify probation period
- Then probation end date is calculated
- And probation status is tracked
- And notifications are sent before probation end
- And probation can be extended
- And probation can be confirmed
- And probation history is retained

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-032

**Related Entities**: WorkRelationship

---

#### FR-WR-024: Work Relationship Work Schedule

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to assign work schedules to relationships
So that we track working hours
```

**Description**:
System shall allow assigning work schedules to work relationships.

**Acceptance Criteria**:
- Given a work relationship exists
- When I assign a work schedule
- Then schedule is linked to relationship
- And standard hours per week are set
- And work days are specified
- And schedule can change over time (SCD Type 2)
- And schedule is used for time & attendance

**Dependencies**: FR-WR-001

**Business Rules**: None

**Related Entities**: WorkRelationship, WorkSchedule

**API Endpoints**: POST /api/v1/work-relationships/{id}/work-schedule

---

#### FR-WR-025: Work Relationship Compensation Link

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to link compensation to work relationships
So that we track salary history
```

**Description**:
System shall link compensation records to work relationships.

**Acceptance Criteria**:
- Given a work relationship exists
- When compensation is set
- Then compensation is linked to relationship
- And compensation effective date aligns with relationship start
- And compensation changes are tracked over time
- And compensation history is retained
- And currency is specified

**Dependencies**: FR-WR-001

**Business Rules**: None

**Related Entities**: WorkRelationship, Compensation

**API Endpoints**: GET /api/v1/work-relationships/{id}/compensation

---

#### FR-WR-026: Work Relationship Benefits Eligibility

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to track benefits eligibility for work relationships
So that we know who qualifies for benefits
```

**Description**:
System shall track benefits eligibility based on work relationship type and duration.

**Acceptance Criteria**:
- Given a work relationship exists
- When I check benefits eligibility
- Then system calculates eligibility based on type
- And system calculates eligibility based on duration
- And eligible benefits are listed
- And eligibility rules can be configured
- And eligibility changes are tracked

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-035

**Related Entities**: WorkRelationship, BenefitPlan

**API Endpoints**: GET /api/v1/work-relationships/{id}/benefits-eligibility

---

#### FR-WR-027: Work Relationship Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export work relationship data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting work relationship data to Excel.

**Acceptance Criteria**:
- Given work relationships exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And worker, employee details are included
- And relationship history is included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-WR-001

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: GET /api/v1/work-relationships/export

---

#### FR-WR-028: Work Relationship Bulk Operations

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to perform bulk operations on work relationships
So that I can update multiple records efficiently
```

**Description**:
System shall support bulk operations for work relationship updates.

**Acceptance Criteria**:
- Given multiple work relationships exist
- When I select relationships and perform bulk operation
- Then operation is applied to all selected relationships
- And validation is performed for each relationship
- And results summary is provided (success/errors)
- And audit log is created for each change

**Dependencies**: FR-WR-001, FR-WR-002

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: POST /api/v1/work-relationships/bulk-update

---

#### FR-WR-029: Work Relationship Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want work relationships to be validated
So that data integrity is maintained
```

**Description**:
System shall enforce validation rules for work relationship creation and updates.

**Acceptance Criteria**:
- Given I create or update a work relationship
- When I submit the form
- Then all validation rules are checked
- And worker must exist
- And relationship type must be valid
- And legal entity must be specified
- And start date must be valid
- And end date must be after start date if specified
- And only one active EMPLOYEE relationship per worker
- And multiple CONTRACTOR relationships allowed
- And validation errors are displayed clearly

**Dependencies**: FR-WR-001

**Business Rules**: BR-WR-001, BR-WR-002, BR-WR-004, BR-WR-005

**Related Entities**: WorkRelationship

---

#### FR-WR-030: Work Relationship Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to view work relationship audit trail
So that I can track all changes
```

**Description**:
System shall maintain complete audit trail for all work relationship changes.

**Acceptance Criteria**:
- Given work relationship changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-WR-001, FR-WR-002, FR-WR-003

**Business Rules**: None

**Related Entities**: WorkRelationship, AuditLog

**API Endpoints**: GET /api/v1/work-relationships/{id}/audit-trail

---

### Basic Reporting (FR-RPT)

#### FR-RPT-001: Headcount Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view current headcount
So that I can track workforce size
```

**Description**:
System shall provide current headcount report.

**Acceptance Criteria**:
- Given employees exist
- When I request headcount report
- Then report shows total headcount
- And report shows headcount by employment type
- And report shows FTE count
- And report shows active vs inactive
- And report can be filtered by date
- And report can be exported

**Dependencies**: FR-EMP-001

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/headcount

---

#### FR-RPT-002: Employee List Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view employee list
So that I can see all employees
```

**Description**:
System shall provide comprehensive employee list report.

**Acceptance Criteria**:
- Given employees exist
- When I request employee list
- Then all employees are listed
- And employee details are shown (name, job, department, manager)
- And list can be filtered by multiple criteria
- And list can be sorted
- And list is paginated
- And list can be exported to Excel

**Dependencies**: FR-EMP-001

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/employee-list

---

#### FR-RPT-003: Org Chart Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view org chart
So that I can see reporting structure
```

**Description**:
System shall provide visual org chart report.

**Acceptance Criteria**:
- Given employees with managers exist
- When I request org chart
- Then org chart is displayed
- And reporting relationships are shown
- And chart can be expanded/collapsed
- And employee details are shown on hover
- And chart can be filtered by business unit
- And chart can be exported as image or PDF

**Dependencies**: FR-MTX-001

**Business Rules**: None

**Related Entities**: Employee, Assignment

**API Endpoints**: GET /api/v1/reports/org-chart

---

#### FR-RPT-004: Headcount by Department

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view headcount by department
So that I can analyze department sizes
```

**Description**:
System shall provide headcount breakdown by business unit/department.

**Acceptance Criteria**:
- Given employees assigned to business units exist
- When I request headcount by department
- Then report shows headcount per department
- And report shows FTE per department
- And report shows percentage distribution
- And report can be visualized as chart
- And report can be exported

**Dependencies**: FR-BU-001, FR-ASG-001

**Business Rules**: None

**Related Entities**: BusinessUnit, Assignment

**API Endpoints**: GET /api/v1/reports/headcount-by-department

---

#### FR-RPT-005: Headcount by Job

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view headcount by job
So that I can analyze job distribution
```

**Description**:
System shall provide headcount breakdown by job.

**Acceptance Criteria**:
- Given employees assigned to jobs exist
- When I request headcount by job
- Then report shows headcount per job
- And report shows job families
- And report shows percentage distribution
- And report can be visualized as chart
- And report can be exported

**Dependencies**: FR-TAX-005, FR-ASG-001

**Business Rules**: None

**Related Entities**: Job, Assignment

**API Endpoints**: GET /api/v1/reports/headcount-by-job

---

#### FR-RPT-006: Headcount by Location

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view headcount by location
So that I can analyze geographic distribution
```

**Description**:
System shall provide headcount breakdown by location.

**Acceptance Criteria**:
- Given employees with locations exist
- When I request headcount by location
- Then report shows headcount per location
- And report shows country/city breakdown
- And report shows percentage distribution
- And report can be visualized on map
- And report can be exported

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment, Location

**API Endpoints**: GET /api/v1/reports/headcount-by-location

---

#### FR-RPT-007: Headcount by Manager

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view headcount by manager
So that I can analyze span of control
```

**Description**:
System shall provide headcount breakdown by manager.

**Acceptance Criteria**:
- Given employees with managers exist
- When I request headcount by manager
- Then report shows direct reports per manager
- And report shows span of control
- And report identifies managers with too many/few reports
- And report can be exported

**Dependencies**: FR-MTX-006

**Business Rules**: None

**Related Entities**: Employee, Assignment

**API Endpoints**: GET /api/v1/reports/headcount-by-manager

---

#### FR-RPT-008: Headcount Trend Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view headcount trends
So that I can see workforce growth
```

**Description**:
System shall provide headcount trend analysis over time.

**Acceptance Criteria**:
- Given historical employee data exists
- When I request headcount trend
- Then report shows headcount over time
- And report shows month-over-month changes
- And report shows year-over-year changes
- And report can be visualized as line chart
- And report can be filtered by department
- And report can be exported

**Dependencies**: FR-EMP-001

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/headcount-trend

---

#### FR-RPT-009: New Hires Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view new hires
So that I can track recruitment
```

**Description**:
System shall provide new hires report.

**Acceptance Criteria**:
- Given employees with hire dates exist
- When I request new hires report
- Then report shows employees hired in period
- And report shows hire date
- And report shows department and job
- And report shows hiring source
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-EMP-001

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/new-hires

---

#### FR-RPT-010: Terminations Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view terminations
So that I can track attrition
```

**Description**:
System shall provide terminations report.

**Acceptance Criteria**:
- Given terminated employees exist
- When I request terminations report
- Then report shows employees terminated in period
- And report shows termination date and reason
- And report shows department and job
- And report shows voluntary vs involuntary
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-EMP-010

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/terminations

---

#### FR-RPT-011: Turnover Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view turnover rates
So that I can analyze retention
```

**Description**:
System shall provide turnover rate analysis.

**Acceptance Criteria**:
- Given employee hire and termination data exists
- When I request turnover report
- Then report shows turnover rate
- And report shows voluntary vs involuntary turnover
- And report shows turnover by department
- And report shows turnover by job
- And report shows turnover trends
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-EMP-001, FR-EMP-010

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/turnover

---

#### FR-RPT-012: Vacancy Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view vacant positions
So that I can plan recruitment
```

**Description**:
System shall provide vacancy report for position-based staffing.

**Acceptance Criteria**:
- Given positions exist
- When I request vacancy report
- Then report shows all vacant positions
- And report shows vacancy duration
- And report shows department and job
- And report shows critical vacancies
- And report can be filtered by business unit
- And report can be exported

**Dependencies**: FR-POS-016

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: GET /api/v1/reports/vacancies

---

#### FR-RPT-013: Assignment Report

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view assignment details
So that I can track employee assignments
```

**Description**:
System shall provide comprehensive assignment report.

**Acceptance Criteria**:
- Given assignments exist
- When I request assignment report
- Then report shows all assignments
- And report shows assignment details (job, department, manager)
- And report shows assignment type (primary, concurrent)
- And report shows FTE allocation
- And report can be filtered by multiple criteria
- And report can be exported

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reports/assignments

---

#### FR-RPT-014: Transfer Report

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view transfers
So that I can track internal mobility
```

**Description**:
System shall provide transfer report.

**Acceptance Criteria**:
- Given transfers exist
- When I request transfer report
- Then report shows all transfers in period
- And report shows from/to departments
- And report shows transfer date and reason
- And report shows transfer type (lateral, promotion, demotion)
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-ASG-015

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reports/transfers

---

#### FR-RPT-015: Promotion Report

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view promotions
So that I can track career progression
```

**Description**:
System shall provide promotion report.

**Acceptance Criteria**:
- Given promotions exist
- When I request promotion report
- Then report shows all promotions in period
- And report shows from/to jobs
- And report shows promotion date
- And report shows department
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-ASG-016

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reports/promotions

---

#### FR-RPT-016: Seniority Report

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view employee seniority
So that I can analyze tenure
```

**Description**:
System shall provide seniority/tenure analysis report.

**Acceptance Criteria**:
- Given employees with hire dates exist
- When I request seniority report
- Then report shows years of service per employee
- And report shows seniority distribution
- And report shows average tenure
- And report shows tenure by department
- And report can be filtered by criteria
- And report can be exported

**Dependencies**: FR-EMP-001

**Business Rules**: None

**Related Entities**: Employee

**API Endpoints**: GET /api/v1/reports/seniority

---

#### FR-RPT-017: Probation Report

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view probation status
So that I can track new hire progress
```

**Description**:
System shall provide probation status report.

**Acceptance Criteria**:
- Given employees on probation exist
- When I request probation report
- Then report shows employees on probation
- And report shows probation end dates
- And report shows upcoming probation reviews
- And report shows overdue confirmations
- And report can be filtered by department
- And report can be exported

**Dependencies**: FR-WR-023

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: GET /api/v1/reports/probation

---

#### FR-RPT-018: Contract Expiry Report

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view expiring contracts
So that I can plan renewals
```

**Description**:
System shall provide contract expiry report.

**Acceptance Criteria**:
- Given employees with contract end dates exist
- When I request contract expiry report
- Then report shows contracts expiring in period
- And report shows contract end dates
- And report shows employee and contract details
- And report highlights critical expirations
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-WR-022

**Business Rules**: None

**Related Entities**: WorkRelationship

**API Endpoints**: GET /api/v1/reports/contract-expiry

---

#### FR-RPT-019: Custom Report Builder

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to build custom reports
So that I can analyze specific metrics
```

**Description**:
System shall provide custom report builder functionality.

**Acceptance Criteria**:
- Given I am an HR Manager
- When I use report builder
- Then I can select data fields
- And I can apply filters
- And I can group and aggregate data
- And I can sort results
- And I can save report templates
- And I can schedule reports
- And reports can be exported

**Dependencies**: All FR-RPT requirements

**Business Rules**: None

**Related Entities**: All entities

**API Endpoints**: POST /api/v1/reports/custom

---

#### FR-RPT-020: Report Scheduling and Distribution

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to schedule reports
So that they are delivered automatically
```

**Description**:
System shall support report scheduling and automated distribution.

**Acceptance Criteria**:
- Given a report exists
- When I schedule the report
- Then schedule is created (daily, weekly, monthly)
- And report is generated automatically
- And report is distributed to recipients
- And distribution can be via email or portal
- And schedule can be modified or cancelled
- And schedule history is tracked

**Dependencies**: All FR-RPT requirements

**Business Rules**: None

**Related Entities**: All entities

**API Endpoints**: POST /api/v1/reports/schedules

---

---

### Employee Management (FR-EMP)

#### FR-EMP-001: Create Employee Record

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create an employee record
So that I can track employment details
```

**Description**:
System shall allow creating employee records for EMPLOYEE-type work relationships.

**Acceptance Criteria**:
- Given a work relationship of type EMPLOYEE exists
- When I create an employee record
- Then the employee record is created
- And employee number is generated or specified
- And hire date equals work relationship start date
- And probation period is set
- And probation end date is calculated
- And employment status is set to ACTIVE
- And the employee is available for assignment

**Dependencies**: FR-WR-001, FR-CFG-002 (for EMPLOYEE_STATUS)

**Business Rules**: BR-EMP-001, BR-EMP-002, BR-EMP-003, BR-EMP-004

**Related Entities**: WorkRelationship, Employee

**API Endpoints**: POST /api/v1/employees

---

#### FR-EMP-002: Generate Employee Number

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to generate unique employee numbers
So that each employee has a unique identifier
```

**Description**:
System shall auto-generate unique employee numbers following configured format.

**Acceptance Criteria**:
- Given employee number format is configured
- When I create an employee without specifying number
- Then employee number is auto-generated
- And the number is unique
- And the number follows the configured format
- And the number is sequential or year-based as configured

**Dependencies**: FR-EMP-001

**Business Rules**: BR-EMP-002

**Related Entities**: Employee

**API Endpoints**: POST /api/v1/employees/generate-employee-number

---

**[Continue with all remaining functional requirements for all 15 features...]**

---

### Assignment Management (FR-ASG)

#### FR-ASG-001: Create Assignment

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create an assignment
So that employees have jobs and reporting relationships
```

**Description**:
System shall allow creating assignments linking employees to jobs/positions and business units.

**Acceptance Criteria**:
- Given an employee or work relationship exists
- When I create an assignment
- Then the assignment is created
- And either position OR job is specified (based on staffing model)
- And business unit is required
- And solid line manager is required
- And assignment start date is set
- And assignment status is set to ACTIVE
- And assignment reason is documented
- And FTE is specified (default 1.0)
- And the assignment is the employee's primary assignment

**Dependencies**: FR-EMP-001, FR-WR-001, FR-CFG-002 (for ASSIGNMENT_REASON)

**Business Rules**: BR-ASG-001, BR-ASG-002, BR-ASG-003, BR-ASG-004

**Related Entities**: Assignment, Employee, WorkRelationship, Job, Position, BusinessUnit

**API Endpoints**: POST /api/v1/assignments

---

#### FR-ASG-002: Update Assignment

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update assignment details
So that information stays current
```

**Description**:
System shall allow updating assignment information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given an assignment exists
- When I update assignment details
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-015

**Related Entities**: Assignment

**API Endpoints**: PUT /api/v1/assignments/{id}

---

#### FR-ASG-003: End Assignment

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to end an assignment
So that we can process transfers and terminations
```

**Description**:
System shall allow ending assignments with proper reason tracking.

**Acceptance Criteria**:
- Given an active assignment exists
- When I end the assignment
- Then end date is set
- And end reason is required
- And status is set to ENDED
- And audit log is created
- And employee can have a new assignment created

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-015

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/{id}/end

---

#### FR-ASG-005: Position-Based Staffing

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to assign employees to positions
So that we control headcount through budgeted positions
```

**Description**:
System shall support position-based staffing model where employees are assigned to pre-approved positions.

**Acceptance Criteria**:
- Given a position exists and is vacant
- When I create an assignment
- Then position is linked to assignment
- And job is derived from position
- And business unit is derived from position
- And position status changes to FILLED
- And position incumbent count is updated
- And assignment is validated against position budget

**Dependencies**: FR-ASG-001, FR-POS-001

**Business Rules**: BR-ASG-002, BR-POS-004

**Related Entities**: Assignment, Position, Job

**API Endpoints**: POST /api/v1/assignments (with position_id)

---

#### FR-ASG-006: Job-Based Staffing

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to assign employees directly to jobs
So that we have flexibility without position constraints
```

**Description**:
System shall support job-based staffing model where employees are assigned directly to jobs without positions.

**Acceptance Criteria**:
- Given a job exists
- When I create an assignment
- Then job is linked to assignment
- And position is null
- And business unit is specified manually
- And no position budget validation occurs
- And assignment is more flexible

**Dependencies**: FR-ASG-001, FR-TAX-005

**Business Rules**: BR-ASG-002

**Related Entities**: Assignment, Job

**API Endpoints**: POST /api/v1/assignments (with job_id, no position_id)

---

#### FR-ASG-010: Assign Solid Line Manager

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to assign solid line managers
So that reporting relationships are clear
```

**Description**:
System shall allow assigning solid line (primary) managers to assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I assign a solid line manager
- Then manager assignment is created
- And manager must be an active employee
- And only one solid line manager per assignment
- And solid line manager has approval authority
- And reporting chain is updated

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-004, BR-MTX-001

**Related Entities**: Assignment, Employee

**API Endpoints**: POST /api/v1/assignments/{id}/solid-line-manager

---

#### FR-ASG-011: Assign Dotted Line Manager

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to assign dotted line managers
So that we can model matrix organizations
```

**Description**:
System shall allow assigning dotted line (secondary) managers to assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I assign a dotted line manager
- Then manager assignment is created
- And manager must be an active employee
- And multiple dotted line managers are allowed
- And dotted line manager has coordination role only
- And time allocation can be specified

**Dependencies**: FR-ASG-001, FR-ASG-010

**Business Rules**: BR-MTX-002

**Related Entities**: Assignment, Employee

**API Endpoints**: POST /api/v1/assignments/{id}/dotted-line-manager

---

#### FR-ASG-015: Process Transfer

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to process employee transfers
So that employees can move between departments
```

**Description**:
System shall support employee transfers between business units or jobs.

**Acceptance Criteria**:
- Given an employee has an active assignment
- When I process a transfer
- Then current assignment is ended
- And new assignment is created
- And transfer date is set
- And transfer reason is documented
- And new business unit/job is specified
- And new manager is assigned
- And employee number is preserved
- And seniority is preserved
- And audit log is created

**Dependencies**: FR-ASG-001, FR-ASG-003

**Business Rules**: BR-ASG-015, BR-ASG-020

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/transfer

---

#### FR-ASG-016: Process Promotion

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to process employee promotions
So that we can advance careers
```

**Description**:
System shall support employee promotions to higher-level jobs.

**Acceptance Criteria**:
- Given an employee has an active assignment
- When I process a promotion
- Then current assignment is ended
- And new assignment is created
- And promotion date is set
- And promotion reason is documented
- And new job is at higher level
- And new salary may be updated
- And employee number is preserved
- And seniority is preserved
- And audit log is created

**Dependencies**: FR-ASG-001, FR-ASG-003, FR-TAX-005

**Business Rules**: BR-ASG-015, BR-ASG-020

**Related Entities**: Assignment, Job, JobLevel

**API Endpoints**: POST /api/v1/assignments/promote

---

#### FR-ASG-017: Process Demotion

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to process employee demotions
So that we can handle performance issues
```

**Description**:
System shall support employee demotions to lower-level jobs.

**Acceptance Criteria**:
- Given an employee has an active assignment
- When I process a demotion
- Then current assignment is ended
- And new assignment is created
- And demotion date is set
- And demotion reason is required and documented
- And new job is at lower level
- And salary may be adjusted
- And audit log is created

**Dependencies**: FR-ASG-001, FR-ASG-003

**Business Rules**: BR-ASG-015

**Related Entities**: Assignment, Job, JobLevel

**API Endpoints**: POST /api/v1/assignments/demote

---

#### FR-ASG-020: Multiple Concurrent Assignments

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to support multiple concurrent assignments
So that employees can work across multiple roles
```

**Description**:
System shall allow employees to have multiple active assignments simultaneously.

**Acceptance Criteria**:
- Given an employee has an active assignment
- When I create a second assignment
- Then both assignments can be active
- And one assignment is marked as primary
- And FTE sum across all assignments is validated
- And each assignment has its own manager
- And each assignment has its own business unit
- And time allocation is tracked

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-005, BR-ASG-010

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments (with is_primary flag)

---

#### FR-ASG-021: FTE Validation

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to validate FTE across assignments
So that employees don't exceed 100% allocation
```

**Description**:
System shall validate that total FTE across all active assignments does not exceed 1.0.

**Acceptance Criteria**:
- Given an employee has one or more assignments
- When I create or update an assignment
- Then system calculates total FTE
- And total FTE must not exceed 1.0
- And validation error is shown if exceeded
- And assignment cannot be saved if validation fails

**Dependencies**: FR-ASG-001, FR-ASG-020

**Business Rules**: BR-ASG-010

**Related Entities**: Assignment

---

#### FR-ASG-022: Assignment Status Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage assignment status
So that I can track assignment lifecycle
```

**Description**:
System shall allow managing assignment status (ACTIVE, SUSPENDED, ENDED).

**Acceptance Criteria**:
- Given an assignment exists
- When I change status
- Then status is updated
- And effective date is set
- And status history is retained (SCD Type 2)
- And audit log is created

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-025

**Related Entities**: Assignment

**API Endpoints**: PUT /api/v1/assignments/{id}/status

---

#### FR-ASG-023: Suspend Assignment

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to suspend assignments
So that we can handle temporary leaves
```

**Description**:
System shall allow suspending assignments temporarily.

**Acceptance Criteria**:
- Given an active assignment exists
- When I suspend the assignment
- Then status is set to SUSPENDED
- And suspension start date is set
- And suspension end date is optional
- And assignment can be reactivated
- And manager relationships are preserved

**Dependencies**: FR-ASG-001, FR-ASG-022

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/{id}/suspend

---

#### FR-ASG-024: Reactivate Assignment

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to reactivate suspended assignments
So that employees can return to work
```

**Description**:
System shall allow reactivating suspended assignments.

**Acceptance Criteria**:
- Given a suspended assignment exists
- When I reactivate the assignment
- Then status is set to ACTIVE
- And suspension end date is set
- And audit log is created

**Dependencies**: FR-ASG-023

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/{id}/reactivate

---

#### FR-ASG-025: Track Assignment History

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to view assignment history
So that I can see career progression
```

**Description**:
System shall provide a view of all assignment history for an employee.

**Acceptance Criteria**:
- Given an employee has multiple assignments
- When I view assignment history
- Then all assignments are displayed
- And assignments are sorted by start date
- And current and historical assignments are shown
- And transfers and promotions are highlighted
- And gaps between assignments are identified

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/employees/{employeeId}/assignments

---

#### FR-ASG-026: Calculate Reporting Chain

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to view my reporting chain
So that I know my management hierarchy
```

**Description**:
System shall calculate and display the reporting chain for an employee.

**Acceptance Criteria**:
- Given an employee has an assignment with manager
- When I request reporting chain
- Then chain is calculated recursively
- And all levels up to CEO are shown
- And only solid line managers are included
- And chain is displayed in hierarchical format

**Dependencies**: FR-ASG-010

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/assignments/{id}/reporting-chain

---

#### FR-ASG-027: View Direct Reports

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to view my direct reports
So that I can manage my team
```

**Description**:
System shall allow managers to view their direct reports (solid line).

**Acceptance Criteria**:
- Given I am a manager
- When I request my direct reports
- Then all employees with me as solid line manager are shown
- And only active assignments are included
- And employee details are displayed
- And list can be filtered and sorted

**Dependencies**: FR-ASG-010

**Business Rules**: BR-MTX-003

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/managers/{managerId}/direct-reports

---

#### FR-ASG-028: View Dotted Line Reports

**Priority**: LOW

**User Story**:
```
As a Manager
I want to view my dotted line reports
So that I can coordinate work
```

**Description**:
System shall allow managers to view their dotted line reports.

**Acceptance Criteria**:
- Given I am a manager
- When I request my dotted line reports
- Then all employees with me as dotted line manager are shown
- And only active assignments are included
- And time allocation is displayed
- And list can be filtered and sorted

**Dependencies**: FR-ASG-011

**Business Rules**: BR-MTX-004

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/managers/{managerId}/dotted-line-reports

---

#### FR-ASG-029: Assignment Time Allocation

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track time allocation across assignments
So that we manage matrix organizations effectively
```

**Description**:
System shall track time allocation percentage for each assignment and manager relationship.

**Acceptance Criteria**:
- Given an employee has multiple assignments or managers
- When I specify time allocation
- Then allocation percentage is stored
- And total allocation across all assignments equals 100%
- And allocation per manager is tracked
- And allocation can be updated over time

**Dependencies**: FR-ASG-020, FR-ASG-011

**Business Rules**: BR-MTX-005

**Related Entities**: Assignment

**API Endpoints**: PUT /api/v1/assignments/{id}/time-allocation

---

#### FR-ASG-030: Assignment Approval Workflow

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want assignment changes to require approval
So that we control organizational changes
```

**Description**:
System shall support approval workflow for assignment changes (transfers, promotions).

**Acceptance Criteria**:
- Given an assignment change is initiated
- When I submit for approval
- Then approval request is created
- And approvers are notified
- And approvers can approve/reject
- And approved changes are applied
- And rejected changes are discarded
- And audit trail is maintained

**Dependencies**: FR-ASG-015, FR-ASG-016

**Business Rules**: None

**Related Entities**: Assignment, ApprovalRequest

**API Endpoints**: POST /api/v1/assignments/{id}/submit-for-approval

---

#### FR-ASG-031: Assignment Notifications

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to receive notifications for assignment events
So that I can take timely action
```

**Description**:
System shall send notifications for assignment events.

**Acceptance Criteria**:
- Given an assignment event occurs
- When the event is triggered
- Then notifications are sent to relevant parties
- And notification types include: new assignment, transfer, promotion, end
- And notifications can be email or in-app
- And notification preferences can be configured

**Dependencies**: FR-ASG-001, FR-ASG-015, FR-ASG-016

**Business Rules**: None

**Related Entities**: Assignment

---

#### FR-ASG-032: Assignment Document Attachment

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to attach documents to assignments
So that I can store offer letters and agreements
```

**Description**:
System shall allow attaching documents to assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I attach a document
- Then the document is linked to the assignment
- And document type is specified
- And document is stored securely
- And document can be downloaded
- And document access is controlled

**Dependencies**: FR-ASG-001, FR-CFG-002 (for DOCUMENT_TYPE)

**Business Rules**: None

**Related Entities**: Assignment, Document

**API Endpoints**: POST /api/v1/assignments/{id}/documents

---

#### FR-ASG-033: Assignment Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter assignments
So that I can find specific assignments quickly
```

**Description**:
System shall provide search and filter capabilities for assignments.

**Acceptance Criteria**:
- Given assignments exist
- When I search by employee, job, business unit, or manager
- Then matching results are returned
- And I can filter by status (ACTIVE, SUSPENDED, ENDED)
- And I can filter by assignment type (primary, secondary)
- And I can filter by date range
- And results are paginated
- And results can be sorted

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/assignments

---

#### FR-ASG-034: Assignment Bulk Operations

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to perform bulk operations on assignments
So that I can update multiple records efficiently
```

**Description**:
System shall support bulk operations for assignment updates.

**Acceptance Criteria**:
- Given multiple assignments exist
- When I select assignments and perform bulk operation
- Then operation is applied to all selected assignments
- And validation is performed for each assignment
- And results summary is provided (success/errors)
- And audit log is created for each change

**Dependencies**: FR-ASG-001, FR-ASG-002

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/bulk-update

---

#### FR-ASG-035: Assignment Data Export

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to export assignment data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting assignment data to Excel.

**Acceptance Criteria**:
- Given assignments exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And employee, job, business unit details are included
- And manager information is included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/assignments/export

---

#### FR-ASG-036: Assignment Bulk Import

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to bulk import assignments
So that I can onboard multiple hires efficiently
```

**Description**:
System shall support bulk importing assignments from Excel.

**Acceptance Criteria**:
- Given I have an Excel file with assignment data
- When I upload the file
- Then system validates all records
- And creates assignments
- And provides summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-ASG-001, FR-EMP-001

**Business Rules**: BR-ASG-001, BR-ASG-002, BR-ASG-004

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/bulk-import

---

#### FR-ASG-037: Assignment Effective Dating

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to schedule future-dated assignments
So that I can plan ahead
```

**Description**:
System shall support future-dated assignments with effective dating.

**Acceptance Criteria**:
- Given I create an assignment
- When I set a future start date
- Then assignment is created but not active
- And assignment becomes active on start date
- And notifications are sent on start date
- And current assignment ends on day before new start date

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-015

**Related Entities**: Assignment

---

#### FR-ASG-038: Assignment Cancellation

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to cancel future-dated assignments
So that I can handle plan changes
```

**Description**:
System shall allow canceling future-dated assignments before they become active.

**Acceptance Criteria**:
- Given a future-dated assignment exists
- When I cancel the assignment
- Then assignment status is set to CANCELLED
- And assignment never becomes active
- And cancellation reason is documented
- And audit log is created

**Dependencies**: FR-ASG-037

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: POST /api/v1/assignments/{id}/cancel

---

#### FR-ASG-039: Assignment Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want assignments to be validated
So that data integrity is maintained
```

**Description**:
System shall enforce validation rules for assignment creation and updates.

**Acceptance Criteria**:
- Given I create or update an assignment
- When I submit the form
- Then all validation rules are checked
- And employee/work relationship must be active
- And job or position must be specified (not both for position-based)
- And business unit must be specified
- And solid line manager must be specified
- And FTE must be between 0 and 1
- And start date must be valid
- And end date must be after start date if specified
- And validation errors are displayed clearly

**Dependencies**: FR-ASG-001

**Business Rules**: BR-ASG-001, BR-ASG-002, BR-ASG-003, BR-ASG-004, BR-ASG-010

**Related Entities**: Assignment

---

#### FR-ASG-040: Assignment Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view assignment reports
So that I can analyze workforce distribution
```

**Description**:
System shall provide assignment reports and analytics.

**Acceptance Criteria**:
- Given assignments exist
- When I request a report
- Then report shows assignment counts by business unit
- And report shows assignment counts by job
- And report shows assignment counts by manager
- And report shows transfers and promotions
- And report shows FTE utilization
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reports/assignments

---

#### FR-ASG-041: Org Chart Generation

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to view org charts
So that I can see team structure
```

**Description**:
System shall generate organizational charts based on assignment reporting relationships.

**Acceptance Criteria**:
- Given assignments with manager relationships exist
- When I request an org chart
- Then chart is generated showing hierarchy
- And solid line reporting is displayed
- And dotted line reporting can be toggled
- And chart can be filtered by business unit
- And chart can be exported as image or PDF
- And chart is interactive (click to expand/collapse)

**Dependencies**: FR-ASG-010, FR-ASG-011

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/org-chart

---

#### FR-ASG-042: Assignment Succession Planning

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to identify successors for key positions
So that we can plan for turnover
```

**Description**:
System shall support identifying potential successors for assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I identify successors
- Then successor candidates are linked to assignment
- And readiness level is specified (READY_NOW, 1_YEAR, 2_YEARS)
- And development needs are documented
- And succession plan is tracked
- And successors can be reviewed periodically

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: POST /api/v1/assignments/{id}/successors

---

#### FR-ASG-043: Assignment Cost Center Tracking

**Priority**: MEDIUM

**User Story**:
```
As a Finance Manager
I want to track cost centers for assignments
So that we can allocate costs correctly
```

**Description**:
System shall allow tracking cost center allocation for assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I assign cost center
- Then cost center is linked to assignment
- And cost center can be different from business unit
- And cost allocation percentage can be specified
- And multiple cost centers can be assigned
- And total allocation must equal 100%

**Dependencies**: FR-ASG-001

**Business Rules**: None

**Related Entities**: Assignment, CostCenter

**API Endpoints**: POST /api/v1/assignments/{id}/cost-centers

---

#### FR-ASG-044: Assignment Location Tracking

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track work locations for assignments
So that we manage remote and office workers
```

**Description**:
System shall allow tracking work location for assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I specify work location
- Then location is linked to assignment
- And location type is specified (OFFICE, REMOTE, HYBRID, FIELD)
- And primary office location is set
- And remote work percentage can be specified
- And location changes are tracked over time

**Dependencies**: FR-ASG-001, FR-CFG-002 (for LOCATION_TYPE)

**Business Rules**: None

**Related Entities**: Assignment, Location

**API Endpoints**: POST /api/v1/assignments/{id}/location

---

#### FR-ASG-045: Assignment Compensation Link

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to link compensation to assignments
So that salary changes follow job changes
```

**Description**:
System shall link compensation records to assignments for tracking.

**Acceptance Criteria**:
- Given an assignment exists
- When compensation is set
- Then compensation is linked to assignment
- And compensation effective date aligns with assignment start
- And compensation changes with promotions/transfers
- And compensation history is tracked per assignment
- And salary range for job is validated

**Dependencies**: FR-ASG-001, FR-ASG-016

**Business Rules**: None

**Related Entities**: Assignment, Compensation

**API Endpoints**: GET /api/v1/assignments/{id}/compensation

---

## 🏢 Phase 2: Organization & Jobs

### Business Unit Management (FR-BU)

#### FR-BU-001: Create Business Unit

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create business units
So that we can organize the company structure
```

**Description**:
System shall allow creating business units (operational or supervisory organizations).

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a business unit
- Then business unit is created
- And unit type is specified (OPERATIONAL, SUPERVISORY)
- And unit code is unique
- And unit name is provided
- And parent unit can be specified (for hierarchy)
- And effective dates are set
- And the unit is available for assignments

**Dependencies**: FR-CFG-002 (for UNIT_TYPE)

**Business Rules**: BR-BU-001, BR-BU-002

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units

---

#### FR-BU-002: Update Business Unit

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update business unit information
So that org structure stays current
```

**Description**:
System shall allow updating business unit information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a business unit exists
- When I update unit information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-010

**Related Entities**: BusinessUnit

**API Endpoints**: PUT /api/v1/business-units/{id}

---

#### FR-BU-003: Deactivate Business Unit

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to deactivate business units
So that we can handle reorganizations
```

**Description**:
System shall allow deactivating business units while preserving history.

**Acceptance Criteria**:
- Given an active business unit exists
- When I deactivate the unit
- Then effective end date is set
- And is_current_flag is set to false
- And unit no longer appears in active lists
- And existing assignments are not affected
- And historical data is preserved
- And unit cannot have new assignments

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-015

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units/{id}/deactivate

---

#### FR-BU-005: Operational Organization

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create operational organizations
So that we can track cost centers and business functions
```

**Description**:
System shall support operational organizations for business structure.

**Acceptance Criteria**:
- Given I create a business unit
- When I set type to OPERATIONAL
- Then unit represents a business function
- And unit can have cost center
- And unit can have budget
- And unit can have multiple supervisory orgs
- And unit is used for reporting and analytics

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-002

**Related Entities**: BusinessUnit

---

#### FR-BU-006: Supervisory Organization

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create supervisory organizations
So that we can track management hierarchies
```

**Description**:
System shall support supervisory organizations for management structure.

**Acceptance Criteria**:
- Given I create a business unit
- When I set type to SUPERVISORY
- Then unit represents a management group
- And unit has a manager
- And unit is used for reporting relationships
- And unit can span multiple operational orgs
- And unit is used for approval workflows

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-003

**Related Entities**: BusinessUnit

---

#### FR-BU-010: Business Unit Hierarchy

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to build business unit hierarchies
So that we can model org structure
```

**Description**:
System shall support hierarchical relationships between business units.

**Acceptance Criteria**:
- Given business units exist
- When I set parent unit
- Then parent-child relationship is created
- And hierarchy is validated (no cycles)
- And hierarchy depth is tracked
- And hierarchy path is calculated
- And hierarchy can be traversed up and down
- And hierarchy changes are tracked (SCD Type 2)

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-020

**Related Entities**: BusinessUnit

**API Endpoints**: PUT /api/v1/business-units/{id}/parent

---

#### FR-BU-011: Calculate Hierarchy Path

**Priority**: MEDIUM

**User Story**:
```
As a Developer
I want hierarchy paths calculated automatically
So that queries are efficient
```

**Description**:
System shall automatically calculate and store hierarchy paths for business units.

**Acceptance Criteria**:
- Given a business unit has a parent
- When hierarchy is saved
- Then hierarchy path is calculated
- And path includes all ancestor IDs
- And path is stored for efficient queries
- And path is updated when hierarchy changes
- And path format is consistent (e.g., /1/5/12/)

**Dependencies**: FR-BU-010

**Business Rules**: None

**Related Entities**: BusinessUnit

---

#### FR-BU-015: Business Unit Manager Assignment

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to assign managers to business units
So that we know who leads each unit
```

**Description**:
System shall allow assigning managers to business units.

**Acceptance Criteria**:
- Given a business unit exists
- When I assign a manager
- Then manager is linked to unit
- And manager must be an active employee
- And manager effective dates are set
- And manager history is retained
- And manager can change over time

**Dependencies**: FR-BU-001, FR-EMP-001

**Business Rules**: BR-BU-025

**Related Entities**: BusinessUnit, Employee

**API Endpoints**: POST /api/v1/business-units/{id}/manager

---

#### FR-BU-016: Business Unit Location

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to assign locations to business units
So that we track where units operate
```

**Description**:
System shall allow assigning locations to business units.

**Acceptance Criteria**:
- Given a business unit exists
- When I assign a location
- Then location is linked to unit
- And primary location can be specified
- And multiple locations are allowed
- And location history is retained

**Dependencies**: FR-BU-001

**Business Rules**: None

**Related Entities**: BusinessUnit, Location

**API Endpoints**: POST /api/v1/business-units/{id}/locations

---

#### FR-BU-020: Business Unit Cost Center

**Priority**: MEDIUM

**User Story**:
```
As a Finance Manager
I want to link cost centers to business units
So that we can track costs
```

**Description**:
System shall allow linking cost centers to business units.

**Acceptance Criteria**:
- Given a business unit exists
- When I assign a cost center
- Then cost center is linked to unit
- And cost center code is unique
- And cost center is used for expense allocation
- And cost center can change over time
- And cost center history is retained

**Dependencies**: FR-BU-001

**Business Rules**: None

**Related Entities**: BusinessUnit, CostCenter

**API Endpoints**: POST /api/v1/business-units/{id}/cost-center

---

#### FR-BU-021: Business Unit Tags

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to tag business units
So that we can categorize and filter units
```

**Description**:
System shall allow tagging business units with custom attributes.

**Acceptance Criteria**:
- Given a business unit exists
- When I add tags
- Then tags are linked to unit
- And tag type is specified (e.g., REGION, FUNCTION, DIVISION)
- And multiple tags are allowed
- And tags can be used for filtering
- And tags can be used for reporting

**Dependencies**: FR-BU-001, FR-CFG-002 (for tag types)

**Business Rules**: None

**Related Entities**: BusinessUnit, Tag

**API Endpoints**: POST /api/v1/business-units/{id}/tags

---

#### FR-BU-025: View Business Unit Hierarchy Tree

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view the org hierarchy tree
So that I can see the structure
```

**Description**:
System shall provide a tree view of business unit hierarchy.

**Acceptance Criteria**:
- Given business units with hierarchy exist
- When I request hierarchy tree
- Then tree is displayed
- And tree shows parent-child relationships
- And tree can be expanded/collapsed
- And tree shows unit details (name, manager, headcount)
- And tree can be filtered by unit type
- And tree can be exported

**Dependencies**: FR-BU-010

**Business Rules**: None

**Related Entities**: BusinessUnit

**API Endpoints**: GET /api/v1/business-units/hierarchy-tree

---

#### FR-BU-026: Business Unit Headcount

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view headcount by business unit
So that I can track staffing levels
```

**Description**:
System shall calculate and display headcount for each business unit.

**Acceptance Criteria**:
- Given assignments exist
- When I view business unit
- Then headcount is calculated
- And headcount includes all active assignments
- And headcount can be by FTE or headcount
- And headcount includes direct and indirect reports
- And headcount is updated in real-time

**Dependencies**: FR-BU-001, FR-ASG-001

**Business Rules**: None

**Related Entities**: BusinessUnit, Assignment

**API Endpoints**: GET /api/v1/business-units/{id}/headcount

---

#### FR-BU-027: Business Unit Reorganization

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to reorganize business units
So that we can adapt to business changes
```

**Description**:
System shall support business unit reorganizations with effective dating.

**Acceptance Criteria**:
- Given business units exist
- When I reorganize units
- Then new structure is created with future effective date
- And old structure remains until effective date
- And assignments can be moved to new units
- And employees can be transferred
- And reorganization is tracked in history
- And reports can show before/after structure

**Dependencies**: FR-BU-001, FR-BU-010

**Business Rules**: BR-BU-030

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units/reorganize

---

#### FR-BU-028: Business Unit Merge

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to merge business units
So that we can consolidate organizations
```

**Description**:
System shall support merging business units.

**Acceptance Criteria**:
- Given two or more business units exist
- When I merge units
- Then I select the primary unit
- And secondary units are deactivated
- And assignments are transferred to primary unit
- And employees are transferred
- And merge is tracked in history
- And merge can be effective-dated

**Dependencies**: FR-BU-001, FR-BU-003

**Business Rules**: BR-BU-031

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units/merge

---

#### FR-BU-029: Business Unit Split

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to split business units
So that we can divide large organizations
```

**Description**:
System shall support splitting business units into multiple units.

**Acceptance Criteria**:
- Given a business unit exists
- When I split the unit
- Then new units are created
- And assignments are distributed to new units
- And employees are transferred
- And original unit can be deactivated or retained
- And split is tracked in history
- And split can be effective-dated

**Dependencies**: FR-BU-001, FR-BU-003

**Business Rules**: BR-BU-032

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units/split

---

#### FR-BU-030: Business Unit Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter business units
So that I can find units quickly
```

**Description**:
System shall provide search and filter capabilities for business units.

**Acceptance Criteria**:
- Given business units exist
- When I search by code, name, or manager
- Then matching results are returned
- And I can filter by unit type (OPERATIONAL, SUPERVISORY)
- And I can filter by active/inactive status
- And I can filter by location
- And I can filter by tags
- And results are paginated
- And results can be sorted

**Dependencies**: FR-BU-001

**Business Rules**: None

**Related Entities**: BusinessUnit

**API Endpoints**: GET /api/v1/business-units

---

#### FR-BU-031: Business Unit Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export business unit data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting business unit data to Excel.

**Acceptance Criteria**:
- Given business units exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And hierarchy is represented
- And manager information is included
- And headcount is included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-BU-001

**Business Rules**: None

**Related Entities**: BusinessUnit

**API Endpoints**: GET /api/v1/business-units/export

---

#### FR-BU-032: Business Unit Bulk Import

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to bulk import business units
So that I can set up org structure efficiently
```

**Description**:
System shall support bulk importing business units from Excel.

**Acceptance Criteria**:
- Given I have an Excel file with business unit data
- When I upload the file
- Then system validates all records
- And creates business units
- And creates hierarchy relationships
- And provides summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-BU-001, FR-BU-010

**Business Rules**: BR-BU-001, BR-BU-002, BR-BU-020

**Related Entities**: BusinessUnit

**API Endpoints**: POST /api/v1/business-units/bulk-import

---

#### FR-BU-033: Business Unit Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want business units to be validated
So that data integrity is maintained
```

**Description**:
System shall enforce validation rules for business unit creation and updates.

**Acceptance Criteria**:
- Given I create or update a business unit
- When I submit the form
- Then all validation rules are checked
- And unit code must be unique
- And unit name is required
- And unit type must be valid
- And parent unit must exist if specified
- And hierarchy must not create cycles
- And effective dates must be valid
- And validation errors are displayed clearly

**Dependencies**: FR-BU-001

**Business Rules**: BR-BU-001, BR-BU-002, BR-BU-020

**Related Entities**: BusinessUnit

---

#### FR-BU-034: Business Unit Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to view business unit audit trail
So that I can track org changes
```

**Description**:
System shall maintain complete audit trail for all business unit changes.

**Acceptance Criteria**:
- Given business unit changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-BU-001, FR-BU-002

**Business Rules**: None

**Related Entities**: BusinessUnit, AuditLog

**API Endpoints**: GET /api/v1/business-units/{id}/audit-trail

---

#### FR-BU-035: Business Unit Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view business unit reports
So that I can analyze org structure
```

**Description**:
System shall provide business unit reports and analytics.

**Acceptance Criteria**:
- Given business units exist
- When I request a report
- Then report shows unit counts by type
- And report shows hierarchy depth distribution
- And report shows headcount by unit
- And report shows manager coverage
- And report shows inactive units
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-BU-001

**Business Rules**: None

**Related Entities**: BusinessUnit

**API Endpoints**: GET /api/v1/reports/business-units

---

### Job Taxonomy Management (FR-TAX)

#### FR-TAX-001: Create Taxonomy Tree

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create taxonomy trees
So that we can organize jobs in different ways
```

**Description**:
System shall allow creating multiple taxonomy trees for organizing jobs.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a taxonomy tree
- Then tree is created
- And tree code is unique
- And tree name is provided
- And tree purpose is documented (e.g., FUNCTIONAL, GEOGRAPHIC, PRODUCT)
- And tree is available for job classification
- And multiple trees can coexist

**Dependencies**: None

**Business Rules**: BR-TAX-001

**Related Entities**: TaxonomyTree

**API Endpoints**: POST /api/v1/taxonomy-trees

---

#### FR-TAX-002: Create Job Taxonomy

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create job taxonomies
So that we can classify jobs hierarchically
```

**Description**:
System shall allow creating job taxonomies (job families, job groups) within taxonomy trees.

**Acceptance Criteria**:
- Given a taxonomy tree exists
- When I create a job taxonomy
- Then taxonomy is created
- And taxonomy code is unique within tree
- And taxonomy name is provided
- And parent taxonomy can be specified (for hierarchy)
- And taxonomy level is calculated
- And taxonomy is linked to tree
- And effective dates are set

**Dependencies**: FR-TAX-001

**Business Rules**: BR-TAX-002, BR-TAX-003

**Related Entities**: JobTaxonomy, TaxonomyTree

**API Endpoints**: POST /api/v1/job-taxonomies

---

#### FR-TAX-003: Update Job Taxonomy

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to update job taxonomy information
So that classifications stay current
```

**Description**:
System shall allow updating job taxonomy information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a job taxonomy exists
- When I update taxonomy information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated

**Dependencies**: FR-TAX-002

**Business Rules**: BR-TAX-010

**Related Entities**: JobTaxonomy

**API Endpoints**: PUT /api/v1/job-taxonomies/{id}

---

#### FR-TAX-005: Create Job

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create jobs
So that we can define work to be done
```

**Description**:
System shall allow creating jobs within job taxonomies.

**Acceptance Criteria**:
- Given a job taxonomy exists
- When I create a job
- Then job is created
- And job code is unique
- And job title is provided
- And job is linked to taxonomy (job family)
- And job level can be specified
- And job grade can be specified
- And effective dates are set
- And the job is available for assignments

**Dependencies**: FR-TAX-002, FR-CFG-002 (for JOB_LEVEL, JOB_GRADE)

**Business Rules**: BR-TAX-005

**Related Entities**: Job, JobTaxonomy, JobLevel, JobGrade

**API Endpoints**: POST /api/v1/jobs

---

#### FR-TAX-006: Update Job

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update job information
So that job definitions stay current
```

**Description**:
System shall allow updating job information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a job exists
- When I update job information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated
- And assignments using this job are not affected

**Dependencies**: FR-TAX-005

**Business Rules**: BR-TAX-010

**Related Entities**: Job

**API Endpoints**: PUT /api/v1/jobs/{id}

---

#### FR-TAX-007: Deactivate Job

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to deactivate jobs
So that they can't be used for new assignments
```

**Description**:
System shall allow deactivating jobs while preserving history.

**Acceptance Criteria**:
- Given an active job exists
- When I deactivate the job
- Then effective end date is set
- And is_current_flag is set to false
- And job no longer appears in active lists
- And existing assignments are not affected
- And historical data is preserved
- And job cannot be used for new assignments

**Dependencies**: FR-TAX-005

**Business Rules**: BR-TAX-015

**Related Entities**: Job

**API Endpoints**: POST /api/v1/jobs/{id}/deactivate

---

#### FR-TAX-010: Job Taxonomy Hierarchy

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to build job taxonomy hierarchies
So that we can organize jobs in families
```

**Description**:
System shall support hierarchical relationships between job taxonomies.

**Acceptance Criteria**:
- Given job taxonomies exist
- When I set parent taxonomy
- Then parent-child relationship is created
- And hierarchy is validated (no cycles)
- And hierarchy depth is tracked
- And hierarchy path is calculated
- And hierarchy can be traversed up and down
- And hierarchy changes are tracked (SCD Type 2)

**Dependencies**: FR-TAX-002

**Business Rules**: BR-TAX-020

**Related Entities**: JobTaxonomy

**API Endpoints**: PUT /api/v1/job-taxonomies/{id}/parent

---

#### FR-TAX-011: Multi-Tree Job Classification

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to classify jobs in multiple trees
So that we can view jobs from different perspectives
```

**Description**:
System shall allow classifying a job in multiple taxonomy trees simultaneously.

**Acceptance Criteria**:
- Given a job exists
- When I classify the job
- Then job can belong to multiple taxonomies
- And each classification is in a different tree
- And primary classification can be specified
- And classifications can change over time
- And classification history is retained

**Dependencies**: FR-TAX-001, FR-TAX-002, FR-TAX-005

**Business Rules**: BR-TAX-025

**Related Entities**: Job, JobTaxonomy, TaxonomyTree

**API Endpoints**: POST /api/v1/jobs/{id}/classifications

---

#### FR-TAX-015: Job Level Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage job levels
So that we can define career progression
```

**Description**:
System shall allow managing job levels (e.g., ENTRY, JUNIOR, MID, SENIOR, LEAD).

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a job level
- Then level is created
- And level code is unique
- And level name is provided
- And level rank is specified (for ordering)
- And level is available for job assignment
- And level can be used for compensation bands

**Dependencies**: None

**Business Rules**: BR-TAX-030

**Related Entities**: JobLevel

**API Endpoints**: POST /api/v1/job-levels

---

#### FR-TAX-016: Job Grade Management

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to manage job grades
So that we can define compensation levels
```

**Description**:
System shall allow managing job grades for compensation structure.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a job grade
- Then grade is created
- And grade code is unique
- And grade name is provided
- And grade rank is specified (for ordering)
- And salary range can be linked
- And grade is available for job assignment

**Dependencies**: None

**Business Rules**: BR-TAX-031

**Related Entities**: JobGrade

**API Endpoints**: POST /api/v1/job-grades

---

#### FR-TAX-020: Job Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter jobs
So that I can find jobs quickly
```

**Description**:
System shall provide search and filter capabilities for jobs.

**Acceptance Criteria**:
- Given jobs exist
- When I search by code, title, or taxonomy
- Then matching results are returned
- And I can filter by job family
- And I can filter by job level
- And I can filter by job grade
- And I can filter by active/inactive status
- And results are paginated
- And results can be sorted

**Dependencies**: FR-TAX-005

**Business Rules**: None

**Related Entities**: Job

**API Endpoints**: GET /api/v1/jobs

---

#### FR-TAX-021: View Taxonomy Tree

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view taxonomy trees
So that I can see job organization
```

**Description**:
System shall provide a tree view of job taxonomy hierarchy.

**Acceptance Criteria**:
- Given job taxonomies with hierarchy exist
- When I request taxonomy tree
- Then tree is displayed
- And tree shows parent-child relationships
- And tree can be expanded/collapsed
- And tree shows job count per taxonomy
- And tree can be filtered by tree type
- And tree can be exported

**Dependencies**: FR-TAX-010

**Business Rules**: None

**Related Entities**: JobTaxonomy, TaxonomyTree

**API Endpoints**: GET /api/v1/taxonomy-trees/{id}/hierarchy

---

#### FR-TAX-022: Job Catalog View

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to view the job catalog
So that I can explore career opportunities
```

**Description**:
System shall provide a public job catalog view.

**Acceptance Criteria**:
- Given active jobs exist
- When I view job catalog
- Then all active jobs are displayed
- And jobs are organized by family
- And job details are shown (title, level, grade)
- And job descriptions are shown
- And catalog can be filtered and searched
- And catalog is accessible to all employees

**Dependencies**: FR-TAX-005

**Business Rules**: None

**Related Entities**: Job, JobTaxonomy

**API Endpoints**: GET /api/v1/jobs/catalog

---

#### FR-TAX-023: Job Comparison

**Priority**: LOW

**User Story**:
```
As an Employee
I want to compare jobs
So that I can understand differences
```

**Description**:
System shall allow comparing multiple jobs side-by-side.

**Acceptance Criteria**:
- Given multiple jobs exist
- When I select jobs to compare
- Then comparison view is displayed
- And job attributes are shown side-by-side
- And differences are highlighted
- And comparison can include up to 5 jobs
- And comparison can be exported

**Dependencies**: FR-TAX-005

**Business Rules**: None

**Related Entities**: Job

**API Endpoints**: GET /api/v1/jobs/compare

---

#### FR-TAX-024: Job Reclassification

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to reclassify jobs
So that we can reorganize job structure
```

**Description**:
System shall support reclassifying jobs to different taxonomies.

**Acceptance Criteria**:
- Given a job exists
- When I reclassify the job
- Then job is moved to new taxonomy
- And reclassification date is set
- And old classification is retained in history
- And assignments using this job are updated
- And reclassification is tracked in audit log

**Dependencies**: FR-TAX-005, FR-TAX-002

**Business Rules**: BR-TAX-035

**Related Entities**: Job, JobTaxonomy

**API Endpoints**: POST /api/v1/jobs/{id}/reclassify

---

#### FR-TAX-025: Job Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export job data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting job data to Excel.

**Acceptance Criteria**:
- Given jobs exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And taxonomy information is included
- And level and grade are included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-TAX-005

**Business Rules**: None

**Related Entities**: Job

**API Endpoints**: GET /api/v1/jobs/export

---

#### FR-TAX-026: Job Bulk Import

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to bulk import jobs
So that I can set up job catalog efficiently
```

**Description**:
System shall support bulk importing jobs from Excel.

**Acceptance Criteria**:
- Given I have an Excel file with job data
- When I upload the file
- Then system validates all records
- And creates jobs
- And links jobs to taxonomies
- And provides summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-TAX-005, FR-TAX-002

**Business Rules**: BR-TAX-005

**Related Entities**: Job, JobTaxonomy

**API Endpoints**: POST /api/v1/jobs/bulk-import

---

#### FR-TAX-027: Job Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want jobs to be validated
So that data integrity is maintained
```

**Description**:
System shall enforce validation rules for job creation and updates.

**Acceptance Criteria**:
- Given I create or update a job
- When I submit the form
- Then all validation rules are checked
- And job code must be unique
- And job title is required
- And job taxonomy must exist
- And job level must be valid if specified
- And job grade must be valid if specified
- And effective dates must be valid
- And validation errors are displayed clearly

**Dependencies**: FR-TAX-005

**Business Rules**: BR-TAX-005

**Related Entities**: Job

---

#### FR-TAX-028: Job Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to view job audit trail
So that I can track job changes
```

**Description**:
System shall maintain complete audit trail for all job changes.

**Acceptance Criteria**:
- Given job changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-TAX-005, FR-TAX-006

**Business Rules**: None

**Related Entities**: Job, AuditLog

**API Endpoints**: GET /api/v1/jobs/{id}/audit-trail

---

#### FR-TAX-029: Job Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view job reports
So that I can analyze job structure
```

**Description**:
System shall provide job reports and analytics.

**Acceptance Criteria**:
- Given jobs exist
- When I request a report
- Then report shows job counts by family
- And report shows job counts by level
- And report shows job counts by grade
- And report shows active vs inactive jobs
- And report shows jobs without assignments
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-TAX-005

**Business Rules**: None

**Related Entities**: Job

**API Endpoints**: GET /api/v1/reports/jobs

---

#### FR-TAX-030: Job Assignment Count

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to see how many people are in each job
So that I can track job utilization
```

**Description**:
System shall calculate and display assignment count for each job.

**Acceptance Criteria**:
- Given assignments exist
- When I view a job
- Then assignment count is calculated
- And count includes all active assignments
- And count can be by FTE or headcount
- And count is updated in real-time
- And count history can be viewed

**Dependencies**: FR-TAX-005, FR-ASG-001

**Business Rules**: None

**Related Entities**: Job, Assignment

**API Endpoints**: GET /api/v1/jobs/{id}/assignment-count

---

### Job Profile Management (FR-PRF)

#### FR-PRF-001: Create Job Profile

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create job profiles
So that we can define job requirements and expectations
```

**Description**:
System shall allow creating comprehensive job profiles for jobs.

**Acceptance Criteria**:
- Given a job exists
- When I create a job profile
- Then profile is created
- And profile is linked to job
- And job description can be provided
- And job purpose can be specified
- And key responsibilities can be listed
- And effective dates are set
- And profile can be versioned (SCD Type 2)

**Dependencies**: FR-TAX-005

**Business Rules**: BR-PRF-001

**Related Entities**: JobProfile, Job

**API Endpoints**: POST /api/v1/job-profiles

---

#### FR-PRF-002: Update Job Profile

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update job profiles
So that job definitions stay current
```

**Description**:
System shall allow updating job profiles with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a job profile exists
- When I update profile information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated

**Dependencies**: FR-PRF-001

**Business Rules**: BR-PRF-010

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}

---

#### FR-PRF-003: Job Description Management

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to manage job descriptions
So that employees understand job expectations
```

**Description**:
System shall allow managing detailed job descriptions.

**Acceptance Criteria**:
- Given a job profile exists
- When I add job description
- Then description is saved
- And description supports rich text formatting
- And description can be in multiple languages
- And description can include sections (purpose, responsibilities, requirements)
- And description can be exported to PDF
- And description history is retained

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}/description

---

#### FR-PRF-005: Define Job Responsibilities

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define job responsibilities
So that employees know what they're accountable for
```

**Description**:
System shall allow defining key responsibilities for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add responsibilities
- Then responsibilities are listed
- And each responsibility has description
- And responsibilities can be prioritized
- And percentage of time can be specified
- And responsibilities can be reordered
- And responsibilities history is retained

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: POST /api/v1/job-profiles/{id}/responsibilities

---

#### FR-PRF-006: Define Required Skills

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to define required skills for jobs
So that we can match candidates and identify gaps
```

**Description**:
System shall allow defining required skills for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add required skills
- Then skills are linked to profile
- And skill proficiency level is specified (BEGINNER to EXPERT)
- And skills can be marked as required or preferred
- And skills can be categorized (TECHNICAL, FUNCTIONAL, SOFT_SKILL)
- And skill requirements can change over time
- And skill requirements history is retained

**Dependencies**: FR-PRF-001, FR-SKL-001

**Business Rules**: BR-PRF-020

**Related Entities**: JobProfile, Skill

**API Endpoints**: POST /api/v1/job-profiles/{id}/skills

---

#### FR-PRF-007: Define Required Competencies

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define required competencies for jobs
So that we can assess behavioral fit
```

**Description**:
System shall allow defining required competencies for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add required competencies
- Then competencies are linked to profile
- And competency level is specified
- And competencies can be marked as required or preferred
- And competency requirements can change over time
- And competency requirements history is retained

**Dependencies**: FR-PRF-001

**Business Rules**: BR-PRF-021

**Related Entities**: JobProfile, Competency

**API Endpoints**: POST /api/v1/job-profiles/{id}/competencies

---

#### FR-PRF-010: Define Education Requirements

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define education requirements
So that we can screen candidates
```

**Description**:
System shall allow defining education requirements for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add education requirements
- Then requirements are saved
- And minimum education level is specified (HIGH_SCHOOL, BACHELOR, MASTER, etc.)
- And preferred education level can be specified
- And field of study can be specified
- And certifications can be listed
- And requirements can be marked as required or preferred

**Dependencies**: FR-PRF-001, FR-CFG-002 (for EDUCATION_LEVEL)

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}/education-requirements

---

#### FR-PRF-011: Define Experience Requirements

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define experience requirements
So that we can assess candidate qualifications
```

**Description**:
System shall allow defining experience requirements for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add experience requirements
- Then requirements are saved
- And minimum years of experience is specified
- And preferred years of experience can be specified
- And type of experience can be specified (INDUSTRY, FUNCTIONAL, TECHNICAL)
- And specific experience areas can be listed
- And requirements can be marked as required or preferred

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}/experience-requirements

---

#### FR-PRF-015: Define Physical Requirements

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to define physical requirements
So that we comply with accessibility laws
```

**Description**:
System shall allow defining physical requirements for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add physical requirements
- Then requirements are saved
- And physical demands are specified (SEDENTARY, LIGHT, MEDIUM, HEAVY)
- And specific physical activities are listed
- And work environment is described
- And accommodations can be noted

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}/physical-requirements

---

#### FR-PRF-016: Define Working Conditions

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to define working conditions
So that candidates know what to expect
```

**Description**:
System shall allow defining working conditions for job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I add working conditions
- Then conditions are saved
- And work location type is specified (OFFICE, REMOTE, HYBRID, FIELD)
- And travel requirements are specified (percentage)
- And work schedule is described (STANDARD, SHIFT, FLEXIBLE)
- And overtime expectations are noted
- And special conditions are documented

**Dependencies**: FR-PRF-001, FR-CFG-002 (for LOCATION_TYPE)

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: PUT /api/v1/job-profiles/{id}/working-conditions

---

#### FR-PRF-020: Job Profile Approval Workflow

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want job profiles to require approval
So that we maintain quality standards
```

**Description**:
System shall support approval workflow for job profile creation and updates.

**Acceptance Criteria**:
- Given a job profile is created or updated
- When I submit for approval
- Then approval request is created
- And approvers are notified
- And approvers can approve/reject
- And approved profiles become active
- And rejected profiles remain in draft
- And audit trail is maintained

**Dependencies**: FR-PRF-001, FR-PRF-002

**Business Rules**: None

**Related Entities**: JobProfile, ApprovalRequest

**API Endpoints**: POST /api/v1/job-profiles/{id}/submit-for-approval

---

#### FR-PRF-021: Job Profile Templates

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to create job profile templates
So that we can standardize profiles
```

**Description**:
System shall allow creating and using job profile templates.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a template
- Then template is saved
- And template includes standard sections
- And template can be used to create new profiles
- And template can be customized per job
- And templates can be shared across organization

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: POST /api/v1/job-profile-templates

---

#### FR-PRF-022: Clone Job Profile

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to clone job profiles
So that I can create similar profiles quickly
```

**Description**:
System shall allow cloning existing job profiles.

**Acceptance Criteria**:
- Given a job profile exists
- When I clone the profile
- Then new profile is created
- And all sections are copied
- And new profile can be edited
- And new profile is linked to different job
- And clone relationship is tracked

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: POST /api/v1/job-profiles/{id}/clone

---

#### FR-PRF-023: Job Profile Comparison

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to compare job profiles
So that I can understand differences
```

**Description**:
System shall allow comparing multiple job profiles side-by-side.

**Acceptance Criteria**:
- Given multiple job profiles exist
- When I select profiles to compare
- Then comparison view is displayed
- And all sections are shown side-by-side
- And differences are highlighted
- And comparison can include up to 5 profiles
- And comparison can be exported

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: GET /api/v1/job-profiles/compare

---

#### FR-PRF-024: Job Profile Publishing

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to publish job profiles
So that employees can view them
```

**Description**:
System shall allow publishing job profiles for employee access.

**Acceptance Criteria**:
- Given an approved job profile exists
- When I publish the profile
- Then profile becomes publicly accessible
- And profile appears in job catalog
- And employees can view profile
- And profile can be unpublished
- And publish history is tracked

**Dependencies**: FR-PRF-001, FR-PRF-020

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: POST /api/v1/job-profiles/{id}/publish

---

#### FR-PRF-025: Job Profile Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter job profiles
So that I can find profiles quickly
```

**Description**:
System shall provide search and filter capabilities for job profiles.

**Acceptance Criteria**:
- Given job profiles exist
- When I search by job, skills, or keywords
- Then matching results are returned
- And I can filter by job family
- And I can filter by required skills
- And I can filter by education level
- And I can filter by approval status
- And results are paginated
- And results can be sorted

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: GET /api/v1/job-profiles

---

#### FR-PRF-026: Job Profile Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export job profiles
So that I can share them externally
```

**Description**:
System shall allow exporting job profiles to various formats.

**Acceptance Criteria**:
- Given job profiles exist
- When I request export
- Then profile can be exported to PDF
- And profile can be exported to Word
- And profile can be exported to Excel
- And export includes all sections
- And export is formatted professionally
- And export is audited

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: GET /api/v1/job-profiles/{id}/export

---

#### FR-PRF-027: Job Profile Bulk Operations

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to perform bulk operations on job profiles
So that I can update multiple profiles efficiently
```

**Description**:
System shall support bulk operations for job profile updates.

**Acceptance Criteria**:
- Given multiple job profiles exist
- When I select profiles and perform bulk operation
- Then operation is applied to all selected profiles
- And validation is performed for each profile
- And results summary is provided (success/errors)
- And audit log is created for each change

**Dependencies**: FR-PRF-001, FR-PRF-002

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: POST /api/v1/job-profiles/bulk-update

---

#### FR-PRF-028: Job Profile Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want job profiles to be validated
So that data quality is maintained
```

**Description**:
System shall enforce validation rules for job profile creation and updates.

**Acceptance Criteria**:
- Given I create or update a job profile
- When I submit the form
- Then all validation rules are checked
- And job must exist
- And job description is required
- And at least one responsibility is required
- And skill proficiency levels are valid
- And education levels are valid
- And effective dates are valid
- And validation errors are displayed clearly

**Dependencies**: FR-PRF-001

**Business Rules**: BR-PRF-001

**Related Entities**: JobProfile

---

#### FR-PRF-029: Job Profile Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to view job profile audit trail
So that I can track profile changes
```

**Description**:
System shall maintain complete audit trail for all job profile changes.

**Acceptance Criteria**:
- Given job profile changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-PRF-001, FR-PRF-002

**Business Rules**: None

**Related Entities**: JobProfile, AuditLog

**API Endpoints**: GET /api/v1/job-profiles/{id}/audit-trail

---

#### FR-PRF-030: Job Profile Analytics

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view job profile analytics
So that I can analyze skill requirements
```

**Description**:
System shall provide analytics on job profiles.

**Acceptance Criteria**:
- Given job profiles exist
- When I request analytics
- Then report shows most common skills required
- And report shows most common competencies
- And report shows education level distribution
- And report shows experience requirements
- And report shows profiles without required sections
- And report can be filtered by job family
- And report can be exported

**Dependencies**: FR-PRF-001

**Business Rules**: None

**Related Entities**: JobProfile

**API Endpoints**: GET /api/v1/reports/job-profiles

---

### Position Management (FR-POS)

#### FR-POS-001: Create Position

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to create positions
So that we can control headcount through approved positions
```

**Description**:
System shall allow creating positions for position-based staffing model.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a position
- Then position is created
- And position code is unique
- And position title is provided
- And job is linked to position
- And business unit is linked to position
- And position status is set to VACANT
- And effective dates are set
- And the position is available for assignments

**Dependencies**: FR-TAX-005, FR-BU-001

**Business Rules**: BR-POS-001, BR-POS-002

**Related Entities**: Position, Job, BusinessUnit

**API Endpoints**: POST /api/v1/positions

---

#### FR-POS-002: Update Position

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to update position information
So that position details stay current
```

**Description**:
System shall allow updating position information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a position exists
- When I update position information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated
- And assignments using this position are not affected

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-010

**Related Entities**: Position

**API Endpoints**: PUT /api/v1/positions/{id}

---

#### FR-POS-003: Deactivate Position

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to deactivate positions
So that they can't be used for new assignments
```

**Description**:
System shall allow deactivating positions while preserving history.

**Acceptance Criteria**:
- Given an active position exists
- When I deactivate the position
- Then effective end date is set
- And is_current_flag is set to false
- And position status is set to ELIMINATED
- And position no longer appears in active lists
- And existing assignments are not affected
- And historical data is preserved
- And position cannot be used for new assignments

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-015

**Related Entities**: Position

**API Endpoints**: POST /api/v1/positions/{id}/deactivate

---

#### FR-POS-005: Position Status Management

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to manage position status
So that we can track position lifecycle
```

**Description**:
System shall allow managing position status (VACANT, FILLED, FROZEN, ELIMINATED).

**Acceptance Criteria**:
- Given a position exists
- When I change status
- Then status is updated
- And effective date is set
- And status history is retained (SCD Type 2)
- And status change reason is documented
- And audit log is created
- And FROZEN positions cannot be filled
- And ELIMINATED positions are deactivated

**Dependencies**: FR-POS-001, FR-CFG-002 (for POSITION_STATUS)

**Business Rules**: BR-POS-020

**Related Entities**: Position

**API Endpoints**: PUT /api/v1/positions/{id}/status

---

#### FR-POS-006: Freeze Position

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to freeze positions
So that we can temporarily stop hiring
```

**Description**:
System shall allow freezing positions to prevent new assignments.

**Acceptance Criteria**:
- Given an active position exists
- When I freeze the position
- Then status is set to FROZEN
- And freeze reason is documented
- And freeze date is set
- And position cannot be filled
- And existing assignment is not affected
- And position can be unfrozen later

**Dependencies**: FR-POS-001, FR-POS-005

**Business Rules**: BR-POS-021

**Related Entities**: Position

**API Endpoints**: POST /api/v1/positions/{id}/freeze

---

#### FR-POS-007: Unfreeze Position

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to unfreeze positions
So that we can resume hiring
```

**Description**:
System shall allow unfreezing frozen positions.

**Acceptance Criteria**:
- Given a frozen position exists
- When I unfreeze the position
- Then status is set to VACANT or FILLED (based on incumbent)
- And unfreeze date is set
- And position can be filled again
- And audit log is created

**Dependencies**: FR-POS-006

**Business Rules**: BR-POS-022

**Related Entities**: Position

**API Endpoints**: POST /api/v1/positions/{id}/unfreeze

---

#### FR-POS-010: Position Budgeting

**Priority**: HIGH

**User Story**:
```
As a Finance Manager
I want to budget positions
So that we can control headcount costs
```

**Description**:
System shall allow budgeting positions with salary ranges and headcount limits.

**Acceptance Criteria**:
- Given a position exists
- When I set budget
- Then budget is linked to position
- And salary range is specified (min, max)
- And currency is specified
- And budget year is set
- And budget can be approved/rejected
- And budget history is retained

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-030

**Related Entities**: Position, PositionBudget

**API Endpoints**: POST /api/v1/positions/{id}/budget

---

#### FR-POS-011: Position Headcount Limit

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to set headcount limits for positions
So that we can control multiple incumbents
```

**Description**:
System shall allow setting headcount limits for positions.

**Acceptance Criteria**:
- Given a position exists
- When I set headcount limit
- Then limit is saved
- And default limit is 1
- And limit can be > 1 for shared positions
- And system validates against limit when creating assignments
- And current incumbent count is tracked
- And limit can change over time

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-031

**Related Entities**: Position

**API Endpoints**: PUT /api/v1/positions/{id}/headcount-limit

---

#### FR-POS-015: Track Position Incumbents

**Priority**: HIGH

**User Story**:
```
As an HR Manager
I want to track position incumbents
So that I know who fills each position
```

**Description**:
System shall track current and historical incumbents for each position.

**Acceptance Criteria**:
- Given a position exists
- When an assignment is created for the position
- Then incumbent is linked to position
- And incumbent count is updated
- And position status changes to FILLED
- And incumbent history is retained
- And multiple incumbents are allowed if headcount limit > 1

**Dependencies**: FR-POS-001, FR-ASG-005

**Business Rules**: BR-POS-004

**Related Entities**: Position, Assignment

**API Endpoints**: GET /api/v1/positions/{id}/incumbents

---

#### FR-POS-016: Vacancy Tracking

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to track position vacancies
So that we can plan recruitment
```

**Description**:
System shall track and report position vacancies.

**Acceptance Criteria**:
- Given positions exist
- When I view vacancies
- Then all VACANT positions are listed
- And vacancy duration is calculated
- And positions can be filtered by business unit
- And positions can be filtered by job
- And vacancy report can be exported
- And critical vacancies are highlighted

**Dependencies**: FR-POS-001, FR-POS-005

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: GET /api/v1/positions/vacancies

---

#### FR-POS-020: Position Approval Workflow

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want position creation to require approval
So that we control headcount growth
```

**Description**:
System shall support approval workflow for position creation.

**Acceptance Criteria**:
- Given a position is created
- When I submit for approval
- Then approval request is created
- And approvers are notified
- And approvers can approve/reject
- And approved positions become active
- And rejected positions are deleted or remain in draft
- And audit trail is maintained

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position, ApprovalRequest

**API Endpoints**: POST /api/v1/positions/{id}/submit-for-approval

---

#### FR-POS-021: Position Requisition

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to request new positions
So that I can grow my team
```

**Description**:
System shall allow managers to request new positions through requisition process.

**Acceptance Criteria**:
- Given I am a manager
- When I create a position requisition
- Then requisition is created
- And business justification is required
- And job and business unit are specified
- And salary range is proposed
- And requisition goes through approval workflow
- And approved requisitions create positions
- And rejected requisitions are archived

**Dependencies**: FR-POS-001, FR-POS-020

**Business Rules**: None

**Related Entities**: Position, PositionRequisition

**API Endpoints**: POST /api/v1/position-requisitions

---

#### FR-POS-025: Position Hierarchy

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to define position hierarchies
So that we can model reporting structure
```

**Description**:
System shall allow defining hierarchical relationships between positions.

**Acceptance Criteria**:
- Given positions exist
- When I set supervisor position
- Then supervisor-subordinate relationship is created
- And hierarchy is validated (no cycles)
- And hierarchy can be traversed
- And hierarchy changes are tracked (SCD Type 2)
- And org chart can be generated from position hierarchy

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-040

**Related Entities**: Position

**API Endpoints**: PUT /api/v1/positions/{id}/supervisor

---

#### FR-POS-026: Position Location

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to assign locations to positions
So that we track where positions are based
```

**Description**:
System shall allow assigning locations to positions.

**Acceptance Criteria**:
- Given a position exists
- When I assign a location
- Then location is linked to position
- And location can be office, remote, or hybrid
- And primary location is specified
- And location can change over time
- And location history is retained

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position, Location

**API Endpoints**: POST /api/v1/positions/{id}/location

---

#### FR-POS-027: Position Cost Center

**Priority**: MEDIUM

**User Story**:
```
As a Finance Manager
I want to assign cost centers to positions
So that we can allocate costs correctly
```

**Description**:
System shall allow assigning cost centers to positions.

**Acceptance Criteria**:
- Given a position exists
- When I assign a cost center
- Then cost center is linked to position
- And cost center can be different from business unit
- And cost center is used for expense allocation
- And cost center can change over time
- And cost center history is retained

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position, CostCenter

**API Endpoints**: POST /api/v1/positions/{id}/cost-center

---

#### FR-POS-028: Position Cloning

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to clone positions
So that I can create similar positions quickly
```

**Description**:
System shall allow cloning existing positions.

**Acceptance Criteria**:
- Given a position exists
- When I clone the position
- Then new position is created
- And all attributes are copied
- And new position code is generated
- And new position can be edited
- And clone relationship is tracked

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: POST /api/v1/positions/{id}/clone

---

#### FR-POS-029: Position Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search and filter positions
So that I can find positions quickly
```

**Description**:
System shall provide search and filter capabilities for positions.

**Acceptance Criteria**:
- Given positions exist
- When I search by code, title, job, or business unit
- Then matching results are returned
- And I can filter by status (VACANT, FILLED, FROZEN, ELIMINATED)
- And I can filter by job
- And I can filter by business unit
- And I can filter by location
- And results are paginated
- And results can be sorted

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: GET /api/v1/positions

---

#### FR-POS-030: Position Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export position data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting position data to Excel.

**Acceptance Criteria**:
- Given positions exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And job and business unit details are included
- And incumbent information is included
- And budget information is included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: GET /api/v1/positions/export

---

#### FR-POS-031: Position Bulk Import

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to bulk import positions
So that I can set up position structure efficiently
```

**Description**:
System shall support bulk importing positions from Excel.

**Acceptance Criteria**:
- Given I have an Excel file with position data
- When I upload the file
- Then system validates all records
- And creates positions
- And links positions to jobs and business units
- And provides summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-POS-001, FR-TAX-005, FR-BU-001

**Business Rules**: BR-POS-001, BR-POS-002

**Related Entities**: Position

**API Endpoints**: POST /api/v1/positions/bulk-import

---

#### FR-POS-032: Position Validation Rules

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want positions to be validated
So that data integrity is maintained
```

**Description**:
System shall enforce validation rules for position creation and updates.

**Acceptance Criteria**:
- Given I create or update a position
- When I submit the form
- Then all validation rules are checked
- And position code must be unique
- And position title is required
- And job must exist
- And business unit must exist
- And status must be valid
- And headcount limit must be >= 1
- And effective dates must be valid
- And validation errors are displayed clearly

**Dependencies**: FR-POS-001

**Business Rules**: BR-POS-001, BR-POS-002

**Related Entities**: Position

---

#### FR-POS-033: Position Audit Trail

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to view position audit trail
So that I can track position changes
```

**Description**:
System shall maintain complete audit trail for all position changes.

**Acceptance Criteria**:
- Given position changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-POS-001, FR-POS-002

**Business Rules**: None

**Related Entities**: Position, AuditLog

**API Endpoints**: GET /api/v1/positions/{id}/audit-trail

---

#### FR-POS-034: Position Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view position reports
So that I can analyze position structure
```

**Description**:
System shall provide position reports and analytics.

**Acceptance Criteria**:
- Given positions exist
- When I request a report
- Then report shows position counts by status
- And report shows position counts by business unit
- And report shows position counts by job
- And report shows vacancy rate
- And report shows budget vs actual
- And report shows positions without incumbents
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position

**API Endpoints**: GET /api/v1/reports/positions

---

#### FR-POS-035: Position Succession Planning

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to identify successors for positions
So that we can plan for turnover
```

**Description**:
System shall support identifying potential successors for positions.

**Acceptance Criteria**:
- Given a position exists
- When I identify successors
- Then successor candidates are linked to position
- And readiness level is specified (READY_NOW, 1_YEAR, 2_YEARS)
- And development needs are documented
- And succession plan is tracked
- And successors can be reviewed periodically

**Dependencies**: FR-POS-001

**Business Rules**: None

**Related Entities**: Position, Employee

**API Endpoints**: POST /api/v1/positions/{id}/successors

---

### Matrix Reporting Management (FR-MTX)

#### FR-MTX-001: Define Solid Line Manager

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to define solid line managers
So that we can establish primary reporting relationships
```

**Description**:
System shall allow defining solid line (primary) managers for assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I assign a solid line manager
- Then manager is linked to assignment
- And manager must be an active employee
- And only one solid line manager per assignment
- And solid line manager has approval authority
- And reporting chain is calculated
- And manager relationship is effective-dated

**Dependencies**: FR-ASG-010

**Business Rules**: BR-MTX-001, BR-ASG-004

**Related Entities**: Assignment, Employee

**API Endpoints**: POST /api/v1/assignments/{id}/solid-line-manager

---

#### FR-MTX-002: Define Dotted Line Manager

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define dotted line managers
So that we can model matrix organizations
```

**Description**:
System shall allow defining dotted line (secondary) managers for assignments.

**Acceptance Criteria**:
- Given an assignment exists
- When I assign a dotted line manager
- Then manager is linked to assignment
- And manager must be an active employee
- And multiple dotted line managers are allowed
- And dotted line manager has coordination role only
- And time allocation percentage can be specified
- And manager relationship is effective-dated

**Dependencies**: FR-ASG-011, FR-MTX-001

**Business Rules**: BR-MTX-002

**Related Entities**: Assignment, Employee

**API Endpoints**: POST /api/v1/assignments/{id}/dotted-line-manager

---

#### FR-MTX-003: Manager Time Allocation

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to specify time allocation across managers
So that we can track matrix workload
```

**Description**:
System shall allow specifying time allocation percentage for each manager relationship.

**Acceptance Criteria**:
- Given an employee has multiple managers
- When I specify time allocation
- Then allocation percentage is saved
- And solid line manager has primary allocation
- And dotted line managers have secondary allocations
- And total allocation across all managers equals 100%
- And allocation can change over time
- And allocation history is retained

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: BR-MTX-005

**Related Entities**: Assignment

**API Endpoints**: PUT /api/v1/assignments/{id}/manager-allocation

---

#### FR-MTX-005: View Reporting Chain

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to view my reporting chain
So that I know my management hierarchy
```

**Description**:
System shall calculate and display the reporting chain for an employee.

**Acceptance Criteria**:
- Given an employee has a solid line manager
- When I request reporting chain
- Then chain is calculated recursively
- And all levels up to CEO are shown
- And only solid line managers are included
- And chain is displayed in hierarchical format
- And chain can be exported

**Dependencies**: FR-MTX-001, FR-ASG-026

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/employees/{id}/reporting-chain

---

#### FR-MTX-006: View Direct Reports

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to view my direct reports
So that I can manage my team
```

**Description**:
System shall allow managers to view their direct reports (solid line).

**Acceptance Criteria**:
- Given I am a manager
- When I request my direct reports
- Then all employees with me as solid line manager are shown
- And only active assignments are included
- And employee details are displayed
- And list can be filtered and sorted
- And headcount is calculated

**Dependencies**: FR-MTX-001, FR-ASG-027

**Business Rules**: BR-MTX-003

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/managers/{id}/direct-reports

---

#### FR-MTX-007: View Dotted Line Reports

**Priority**: LOW

**User Story**:
```
As a Manager
I want to view my dotted line reports
So that I can coordinate work
```

**Description**:
System shall allow managers to view their dotted line reports.

**Acceptance Criteria**:
- Given I am a manager
- When I request my dotted line reports
- Then all employees with me as dotted line manager are shown
- And only active assignments are included
- And time allocation is displayed
- And list can be filtered and sorted

**Dependencies**: FR-MTX-002, FR-ASG-028

**Business Rules**: BR-MTX-004

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/managers/{id}/dotted-line-reports

---

#### FR-MTX-010: Matrix Organization View

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view matrix organization structure
So that I can see dual reporting relationships
```

**Description**:
System shall provide a matrix view of organizational structure.

**Acceptance Criteria**:
- Given employees have solid and dotted line managers
- When I request matrix view
- Then matrix structure is displayed
- And solid line relationships are shown
- And dotted line relationships are shown
- And time allocations are displayed
- And view can be filtered by business unit
- And view can be exported

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/org-structure/matrix-view

---

#### FR-MTX-011: Dual Reporting Validation

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to validate dual reporting relationships
So that we prevent conflicts
```

**Description**:
System shall validate dual reporting relationships to prevent conflicts.

**Acceptance Criteria**:
- Given an employee has managers assigned
- When I save manager relationships
- Then system validates relationships
- And solid line manager is required
- And employee cannot report to themselves
- And circular reporting is prevented
- And manager must be active employee
- And validation errors are displayed

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: BR-MTX-010

**Related Entities**: Assignment

---

#### FR-MTX-015: Manager Change History

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to track manager change history
So that we can see reporting relationship changes
```

**Description**:
System shall track complete history of manager changes.

**Acceptance Criteria**:
- Given manager relationships change over time
- When I view manager history
- Then all changes are displayed
- And effective dates are shown
- And both solid and dotted line changes are tracked
- And who made the change is recorded
- And change reason is documented
- And history can be exported

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: None

**Related Entities**: Assignment, AuditLog

**API Endpoints**: GET /api/v1/assignments/{id}/manager-history

---

#### FR-MTX-016: Manager Approval Authority

**Priority**: MEDIUM

**User Story**:
```
As a System Admin
I want to define manager approval authority
So that we know who can approve what
```

**Description**:
System shall define approval authority based on manager type.

**Acceptance Criteria**:
- Given manager relationships exist
- When approval is required
- Then solid line manager has primary approval authority
- And dotted line manager has coordination role only
- And approval rules can be configured
- And approval delegation is supported
- And approval authority is effective-dated

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: BR-MTX-015

**Related Entities**: Assignment

---

#### FR-MTX-020: Team Hierarchy View

**Priority**: LOW

**User Story**:
```
As a Manager
I want to view my team hierarchy
So that I can see my entire organization
```

**Description**:
System shall provide a hierarchical view of manager's team.

**Acceptance Criteria**:
- Given I am a manager
- When I request team hierarchy
- Then my direct reports are shown
- And their direct reports are shown (recursive)
- And hierarchy can be expanded/collapsed
- And employee details are displayed
- And headcount at each level is shown
- And view can be exported

**Dependencies**: FR-MTX-001, FR-MTX-006

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/managers/{id}/team-hierarchy

---

#### FR-MTX-021: Span of Control Analysis

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to analyze span of control
So that we can optimize org structure
```

**Description**:
System shall provide span of control analysis for managers.

**Acceptance Criteria**:
- Given managers have direct reports
- When I request span of control analysis
- Then report shows direct report count per manager
- And report shows average span of control
- And report shows managers with too many/few reports
- And report can be filtered by business unit
- And report can be filtered by job level
- And report can be exported

**Dependencies**: FR-MTX-006

**Business Rules**: None

**Related Entities**: Assignment, Employee

**API Endpoints**: GET /api/v1/reports/span-of-control

---

#### FR-MTX-022: Manager Workload Analysis

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to analyze manager workload
So that we can balance responsibilities
```

**Description**:
System shall provide manager workload analysis.

**Acceptance Criteria**:
- Given managers have solid and dotted line reports
- When I request workload analysis
- Then report shows total reports per manager
- And report separates solid vs dotted line
- And report shows time allocation percentages
- And report identifies overloaded managers
- And report can be filtered by business unit
- And report can be exported

**Dependencies**: FR-MTX-006, FR-MTX-007, FR-MTX-003

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reports/manager-workload

---

#### FR-MTX-023: Reporting Relationship Search

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to search reporting relationships
So that I can find specific manager-employee pairs
```

**Description**:
System shall provide search capabilities for reporting relationships.

**Acceptance Criteria**:
- Given reporting relationships exist
- When I search by employee or manager
- Then matching relationships are returned
- And I can filter by relationship type (solid, dotted)
- And I can filter by business unit
- And I can filter by effective date
- And results are paginated
- And results can be sorted

**Dependencies**: FR-MTX-001, FR-MTX-002

**Business Rules**: None

**Related Entities**: Assignment

**API Endpoints**: GET /api/v1/reporting-relationships

---

#### FR-MTX-024: Manager Delegation

**Priority**: LOW

**User Story**:
```
As a Manager
I want to delegate my authority temporarily
So that work continues when I'm absent
```

**Description**:
System shall support temporary delegation of manager authority.

**Acceptance Criteria**:
- Given I am a manager
- When I delegate authority
- Then delegate is assigned
- And delegation period is specified
- And delegation scope can be limited
- And delegate has temporary approval authority
- And delegation can be revoked
- And delegation history is tracked

**Dependencies**: FR-MTX-001

**Business Rules**: None

**Related Entities**: Assignment, ManagerDelegation

**API Endpoints**: POST /api/v1/managers/{id}/delegate

---

#### FR-MTX-025: Reporting Relationship Audit

**Priority**: MEDIUM

**User Story**:
```
As an Auditor
I want to audit reporting relationships
So that we can ensure compliance
```

**Description**:
System shall provide audit capabilities for reporting relationships.

**Acceptance Criteria**:
- Given reporting relationships exist
- When I request audit report
- Then report shows all manager changes
- And report shows who made changes
- And report shows when changes were made
- And report shows change reasons
- And report identifies potential issues (circular reporting, etc.)
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-MTX-001, FR-MTX-002, FR-MTX-015

**Business Rules**: None

**Related Entities**: Assignment, AuditLog

**API Endpoints**: GET /api/v1/reports/reporting-relationship-audit

---

---

### Skill Catalog Management (FR-SKL)

#### FR-SKL-001: Create Skill

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to create skills
So that we can track employee capabilities
```

**Description**:
System shall allow creating skills in the skill catalog.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a skill
- Then skill is created
- And skill code is unique
- And skill name is provided
- And skill description can be added
- And skill category is specified (TECHNICAL, FUNCTIONAL, SOFT_SKILL)
- And effective dates are set
- And the skill is available for assignment

**Dependencies**: FR-CFG-002 (for SKILL_CATEGORY)

**Business Rules**: BR-SKL-001

**Related Entities**: Skill

**API Endpoints**: POST /api/v1/skills

---

#### FR-SKL-002: Update Skill

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to update skill information
So that skill definitions stay current
```

**Description**:
System shall allow updating skill information with SCD Type 2 versioning.

**Acceptance Criteria**:
- Given a skill exists
- When I update skill information
- Then changes are saved
- And SCD Type 2 is applied for significant changes
- And audit log is created
- And previous versions are retained
- And effective dates are updated

**Dependencies**: FR-SKL-001

**Business Rules**: BR-SKL-010

**Related Entities**: Skill

**API Endpoints**: PUT /api/v1/skills/{id}

---

#### FR-SKL-003: Deactivate Skill

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to deactivate obsolete skills
So that they don't appear in active lists
```

**Description**:
System shall allow deactivating skills while preserving history.

**Acceptance Criteria**:
- Given an active skill exists
- When I deactivate the skill
- Then effective end date is set
- And is_current_flag is set to false
- And skill no longer appears in active lists
- And existing skill assignments are not affected
- And historical data is preserved

**Dependencies**: FR-SKL-001

**Business Rules**: BR-SKL-015

**Related Entities**: Skill

**API Endpoints**: POST /api/v1/skills/{id}/deactivate

---

#### FR-SKL-005: Define Skill Categories

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to categorize skills
So that we can organize the skill catalog
```

**Description**:
System shall allow categorizing skills (TECHNICAL, FUNCTIONAL, SOFT_SKILL, LEADERSHIP, etc.).

**Acceptance Criteria**:
- Given a skill exists
- When I assign category
- Then category is saved
- And skills can be filtered by category
- And multiple categories can be assigned
- And category can change over time
- And category history is retained

**Dependencies**: FR-SKL-001, FR-CFG-002

**Business Rules**: None

**Related Entities**: Skill

---

#### FR-SKL-006: Define Proficiency Levels

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to define proficiency levels
So that we can assess skill mastery
```

**Description**:
System shall allow defining proficiency levels for skills (BEGINNER, INTERMEDIATE, ADVANCED, EXPERT).

**Acceptance Criteria**:
- Given the system is configured
- When I define proficiency levels
- Then levels are created
- And level code is unique
- And level name is provided
- And level rank is specified (for ordering)
- And levels are available for skill assessment
- And standard levels are: BEGINNER, INTERMEDIATE, ADVANCED, EXPERT

**Dependencies**: None

**Business Rules**: BR-SKL-020

**Related Entities**: SkillProficiencyLevel

**API Endpoints**: POST /api/v1/skill-proficiency-levels

---

#### FR-SKL-010: Skill Taxonomy

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to organize skills in taxonomies
So that we can group related skills
```

**Description**:
System shall allow organizing skills in hierarchical taxonomies.

**Acceptance Criteria**:
- Given skills exist
- When I create skill taxonomy
- Then taxonomy is created
- And skills can be grouped under taxonomy
- And taxonomy can have parent taxonomy (hierarchy)
- And taxonomy hierarchy is validated (no cycles)
- And taxonomy can change over time

**Dependencies**: FR-SKL-001

**Business Rules**: BR-SKL-025

**Related Entities**: Skill, SkillTaxonomy

**API Endpoints**: POST /api/v1/skill-taxonomies

---

#### FR-SKL-011: Skill Synonyms

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to define skill synonyms
So that we can find skills by different names
```

**Description**:
System shall allow defining synonyms for skills.

**Acceptance Criteria**:
- Given a skill exists
- When I add synonyms
- Then synonyms are saved
- And skills can be searched by synonyms
- And synonyms are displayed
- And synonyms can be added/removed

**Dependencies**: FR-SKL-001

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: POST /api/v1/skills/{id}/synonyms

---

#### FR-SKL-015: Skill Search and Filter

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to search skills
So that I can find skills to learn
```

**Description**:
System shall provide search and filter capabilities for skills.

**Acceptance Criteria**:
- Given skills exist
- When I search by name, code, or category
- Then matching results are returned
- And I can filter by category
- And I can filter by taxonomy
- And I can filter by active/inactive status
- And results are paginated
- And results can be sorted

**Dependencies**: FR-SKL-001

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: GET /api/v1/skills

---

#### FR-SKL-016: Skill Catalog View

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to browse the skill catalog
So that I can explore available skills
```

**Description**:
System shall provide a browsable skill catalog.

**Acceptance Criteria**:
- Given active skills exist
- When I view skill catalog
- Then all active skills are displayed
- And skills are organized by category
- And skills are organized by taxonomy
- And skill details are shown
- And catalog can be filtered and searched
- And catalog is accessible to all employees

**Dependencies**: FR-SKL-001

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: GET /api/v1/skills/catalog

---

#### FR-SKL-020: Skill Data Export

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to export skill data
So that I can analyze in Excel
```

**Description**:
System shall allow exporting skill data to Excel.

**Acceptance Criteria**:
- Given skills exist
- When I request export
- Then Excel file is generated
- And all visible fields are included
- And category and taxonomy are included
- And file can be downloaded
- And export is audited

**Dependencies**: FR-SKL-001

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: GET /api/v1/skills/export

---

#### FR-SKL-021: Skill Bulk Import

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to bulk import skills
So that I can set up skill catalog efficiently
```

**Description**:
System shall support bulk importing skills from Excel.

**Acceptance Criteria**:
- Given I have an Excel file with skill data
- When I upload the file
- Then system validates all records
- And creates skills
- And links skills to taxonomies
- And provides summary report (success/errors)
- And rolls back on critical errors

**Dependencies**: FR-SKL-001

**Business Rules**: BR-SKL-001

**Related Entities**: Skill

**API Endpoints**: POST /api/v1/skills/bulk-import

---

#### FR-SKL-022: Skill Validation Rules

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want skills to be validated
So that data quality is maintained
```

**Description**:
System shall enforce validation rules for skill creation and updates.

**Acceptance Criteria**:
- Given I create or update a skill
- When I submit the form
- Then all validation rules are checked
- And skill code must be unique
- And skill name is required
- And category must be valid
- And effective dates must be valid
- And validation errors are displayed clearly

**Dependencies**: FR-SKL-001

**Business Rules**: BR-SKL-001

**Related Entities**: Skill

---

#### FR-SKL-023: Skill Audit Trail

**Priority**: LOW

**User Story**:
```
As an Auditor
I want to view skill audit trail
So that I can track skill changes
```

**Description**:
System shall maintain complete audit trail for all skill changes.

**Acceptance Criteria**:
- Given skill changes occur
- When I view audit trail
- Then all changes are logged
- And who made the change is recorded
- And when the change was made is recorded
- And what was changed is recorded (before/after values)
- And previous versions are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-SKL-001, FR-SKL-002

**Business Rules**: None

**Related Entities**: Skill, AuditLog

**API Endpoints**: GET /api/v1/skills/{id}/audit-trail

---

#### FR-SKL-024: Skill Usage Analytics

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view skill usage analytics
So that I can identify skill trends
```

**Description**:
System shall provide analytics on skill usage.

**Acceptance Criteria**:
- Given skills are assigned to employees
- When I request analytics
- Then report shows most common skills
- And report shows skill gaps
- And report shows skills by category
- And report shows skills by department
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-SKL-001

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: GET /api/v1/reports/skill-usage

---

#### FR-SKL-025: Trending Skills

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to identify trending skills
So that we can plan training
```

**Description**:
System shall identify trending skills based on usage and demand.

**Acceptance Criteria**:
- Given skill data exists over time
- When I request trending skills
- Then report shows skills with increasing demand
- And report shows emerging skills
- And report shows declining skills
- And trends are calculated over configurable period
- And report can be exported

**Dependencies**: FR-SKL-001, FR-SKL-024

**Business Rules**: None

**Related Entities**: Skill

**API Endpoints**: GET /api/v1/reports/trending-skills

---

### Skill Assessment Management (FR-ASS)

#### FR-ASS-001: Assign Skills to Employee

**Priority**: HIGH

**User Story**:
```
As an HR Admin
I want to assign skills to employees
So that we can track employee capabilities
```

**Description**:
System shall allow assigning skills to employees with proficiency levels.

**Acceptance Criteria**:
- Given an employee and skill exist
- When I assign skill to employee
- Then skill is linked to employee
- And proficiency level is specified (BEGINNER to EXPERT)
- And effective date is set
- And skill source is documented (SELF_ASSESSED, MANAGER_ASSESSED, CERTIFIED)
- And skill assignment is tracked in history

**Dependencies**: FR-SKL-001, FR-EMP-001

**Business Rules**: BR-ASS-001

**Related Entities**: EmployeeSkill, Employee, Skill

**API Endpoints**: POST /api/v1/employees/{id}/skills

---

#### FR-ASS-002: Update Employee Skill Proficiency

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to update employee skill proficiency
So that we track skill development
```

**Description**:
System shall allow updating employee skill proficiency levels.

**Acceptance Criteria**:
- Given an employee has a skill assigned
- When I update proficiency level
- Then new proficiency is saved
- And effective date is set
- And previous proficiency is retained (SCD Type 2)
- And proficiency change is tracked
- And audit log is created

**Dependencies**: FR-ASS-001

**Business Rules**: BR-ASS-010

**Related Entities**: EmployeeSkill

**API Endpoints**: PUT /api/v1/employees/{id}/skills/{skillId}

---

#### FR-ASS-003: Remove Employee Skill

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to remove obsolete skills from employees
So that skill profiles stay current
```

**Description**:
System shall allow removing skills from employee profiles.

**Acceptance Criteria**:
- Given an employee has a skill assigned
- When I remove the skill
- Then skill assignment is ended
- And end date is set
- And skill is no longer active
- And historical data is preserved
- And audit log is created

**Dependencies**: FR-ASS-001

**Business Rules**: None

**Related Entities**: EmployeeSkill

**API Endpoints**: DELETE /api/v1/employees/{id}/skills/{skillId}

---

#### FR-ASS-005: Self-Assessment

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to self-assess my skills
So that I can document my capabilities
```

**Description**:
System shall allow employees to self-assess their skills.

**Acceptance Criteria**:
- Given I am an employee
- When I self-assess a skill
- Then skill is assigned to me
- And proficiency level is specified
- And source is marked as SELF_ASSESSED
- And assessment date is recorded
- And self-assessment can be reviewed by manager
- And self-assessment may require approval

**Dependencies**: FR-ASS-001

**Business Rules**: BR-ASS-015

**Related Entities**: EmployeeSkill

**API Endpoints**: POST /api/v1/employees/me/skills/self-assess

---

#### FR-ASS-006: Manager Assessment

**Priority**: HIGH

**User Story**:
```
As a Manager
I want to assess my team's skills
So that we have accurate skill profiles
```

**Description**:
System shall allow managers to assess employee skills.

**Acceptance Criteria**:
- Given I am a manager
- When I assess an employee's skill
- Then skill is assigned to employee
- And proficiency level is specified
- And source is marked as MANAGER_ASSESSED
- And assessment date is recorded
- And assessment comments can be added
- And employee is notified

**Dependencies**: FR-ASS-001, FR-MTX-006

**Business Rules**: BR-ASS-016

**Related Entities**: EmployeeSkill

**API Endpoints**: POST /api/v1/employees/{id}/skills/manager-assess

---

#### FR-ASS-010: Skill Gap Analysis

**Priority**: HIGH

**User Story**:
```
As a Manager
I want to identify skill gaps
So that we can plan training
```

**Description**:
System shall provide skill gap analysis comparing employee skills to job requirements.

**Acceptance Criteria**:
- Given an employee has a job assignment
- When I request skill gap analysis
- Then required skills from job profile are listed
- And employee's current skills are compared
- And gaps are identified (missing skills or lower proficiency)
- And gap severity is calculated
- And development recommendations are provided
- And analysis can be exported

**Dependencies**: FR-ASS-001, FR-PRF-006

**Business Rules**: BR-ASS-020

**Related Entities**: EmployeeSkill, JobProfile

**API Endpoints**: GET /api/v1/employees/{id}/skill-gaps

---

#### FR-ASS-011: Team Skill Matrix

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to view team skill matrix
So that I can see team capabilities
```

**Description**:
System shall provide a skill matrix view for teams.

**Acceptance Criteria**:
- Given I am a manager with direct reports
- When I request team skill matrix
- Then matrix shows employees vs skills
- And proficiency levels are displayed
- And skill coverage is calculated
- And skill gaps are highlighted
- And matrix can be filtered by skill category
- And matrix can be exported

**Dependencies**: FR-ASS-001, FR-MTX-006

**Business Rules**: None

**Related Entities**: EmployeeSkill, Employee

**API Endpoints**: GET /api/v1/managers/{id}/team-skill-matrix

---

#### FR-ASS-015: Skill Endorsement

**Priority**: LOW

**User Story**:
```
As an Employee
I want to endorse colleague's skills
So that we can validate capabilities
```

**Description**:
System shall allow employees to endorse colleague's skills.

**Acceptance Criteria**:
- Given an employee has a skill
- When I endorse the skill
- Then endorsement is recorded
- And endorser is tracked
- And endorsement date is recorded
- And endorsement comment can be added
- And endorsement count is displayed
- And employee is notified

**Dependencies**: FR-ASS-001

**Business Rules**: BR-ASS-025

**Related Entities**: EmployeeSkill, SkillEndorsement

**API Endpoints**: POST /api/v1/employees/{id}/skills/{skillId}/endorse

---

#### FR-ASS-016: Skill Certification

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to record skill certifications
So that we track formal qualifications
```

**Description**:
System shall allow recording skill certifications.

**Acceptance Criteria**:
- Given an employee has a skill
- When I add certification
- Then certification is linked to skill
- And certification name is recorded
- And issuing organization is recorded
- And issue date and expiry date are set
- And certification number can be stored
- And certification document can be attached
- And source is marked as CERTIFIED

**Dependencies**: FR-ASS-001

**Business Rules**: BR-ASS-026

**Related Entities**: EmployeeSkill, SkillCertification

**API Endpoints**: POST /api/v1/employees/{id}/skills/{skillId}/certification

---

#### FR-ASS-020: Skill Development Plan

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to create skill development plans
So that employees can improve skills
```

**Description**:
System shall allow creating skill development plans for employees.

**Acceptance Criteria**:
- Given skill gaps are identified
- When I create development plan
- Then plan is created
- And target skills are specified
- And target proficiency levels are set
- And development activities are listed
- And timeline is defined
- And plan can be reviewed periodically
- And plan progress is tracked

**Dependencies**: FR-ASS-010

**Business Rules**: None

**Related Entities**: SkillDevelopmentPlan, Employee

**API Endpoints**: POST /api/v1/employees/{id}/skill-development-plan

---

#### FR-ASS-021: Track Development Progress

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to track my skill development progress
So that I can see my improvement
```

**Description**:
System shall track progress on skill development plans.

**Acceptance Criteria**:
- Given a development plan exists
- When I update progress
- Then progress is recorded
- And completion percentage is calculated
- And milestones are tracked
- And progress comments can be added
- And progress history is retained
- And manager is notified

**Dependencies**: FR-ASS-020

**Business Rules**: None

**Related Entities**: SkillDevelopmentPlan

**API Endpoints**: PUT /api/v1/skill-development-plans/{id}/progress

---

#### FR-ASS-025: Skill Assessment History

**Priority**: LOW

**User Story**:
```
As an Employee
I want to view my skill assessment history
So that I can see my development over time
```

**Description**:
System shall provide skill assessment history for employees.

**Acceptance Criteria**:
- Given an employee has skill assessments
- When I view history
- Then all assessments are displayed
- And assessment dates are shown
- And proficiency changes are highlighted
- And assessors are identified
- And history can be filtered by skill
- And history can be exported

**Dependencies**: FR-ASS-001, FR-ASS-002

**Business Rules**: None

**Related Entities**: EmployeeSkill

**API Endpoints**: GET /api/v1/employees/{id}/skill-history

---

#### FR-ASS-026: Skill Search by Proficiency

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to find employees by skill and proficiency
So that we can staff projects
```

**Description**:
System shall allow searching employees by skills and proficiency levels.

**Acceptance Criteria**:
- Given employees have skills assigned
- When I search by skill and proficiency
- Then matching employees are returned
- And I can specify minimum proficiency level
- And I can search for multiple skills
- And I can filter by business unit
- And I can filter by availability
- And results are ranked by proficiency
- And results can be exported

**Dependencies**: FR-ASS-001

**Business Rules**: None

**Related Entities**: EmployeeSkill, Employee

**API Endpoints**: GET /api/v1/employees/search-by-skill

---

#### FR-ASS-027: Skill Demand Analysis

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to analyze skill demand
So that we can plan recruitment and training
```

**Description**:
System shall provide skill demand analysis.

**Acceptance Criteria**:
- Given job profiles have skill requirements
- When I request demand analysis
- Then report shows required skills across all jobs
- And report shows current skill supply (employees)
- And report shows skill shortages
- And report shows skill surpluses
- And report can be filtered by business unit
- And report can be exported

**Dependencies**: FR-ASS-001, FR-PRF-006

**Business Rules**: None

**Related Entities**: EmployeeSkill, JobProfile

**API Endpoints**: GET /api/v1/reports/skill-demand

---

#### FR-ASS-028: Skill Assessment Validation

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want skill assessments to be validated
So that data quality is maintained
```

**Description**:
System shall enforce validation rules for skill assessments.

**Acceptance Criteria**:
- Given I assess an employee's skill
- When I submit the assessment
- Then all validation rules are checked
- And skill must exist
- And employee must exist
- And proficiency level must be valid
- And effective date must be valid
- And source must be specified
- And validation errors are displayed clearly

**Dependencies**: FR-ASS-001

**Business Rules**: BR-ASS-001

**Related Entities**: EmployeeSkill

---

#### FR-ASS-029: Skill Assessment Audit Trail

**Priority**: LOW

**User Story**:
```
As an Auditor
I want to view skill assessment audit trail
So that I can track assessment changes
```

**Description**:
System shall maintain complete audit trail for all skill assessments.

**Acceptance Criteria**:
- Given skill assessments occur
- When I view audit trail
- Then all assessments are logged
- And who made the assessment is recorded
- And when the assessment was made is recorded
- And what was assessed is recorded (before/after values)
- And previous assessments are retained
- And audit trail can be filtered and searched
- And audit trail can be exported

**Dependencies**: FR-ASS-001, FR-ASS-002

**Business Rules**: None

**Related Entities**: EmployeeSkill, AuditLog

**API Endpoints**: GET /api/v1/employees/{id}/skills/audit-trail

---

#### FR-ASS-030: Skill Assessment Reporting

**Priority**: MEDIUM

**User Story**:
```
As an HR Manager
I want to view skill assessment reports
So that I can analyze workforce capabilities
```

**Description**:
System shall provide comprehensive skill assessment reports.

**Acceptance Criteria**:
- Given skill assessments exist
- When I request a report
- Then report shows skill distribution by proficiency
- And report shows skill coverage by department
- And report shows assessment sources (self, manager, certified)
- And report shows skill gaps
- And report shows development plan progress
- And report can be filtered by date range
- And report can be exported

**Dependencies**: FR-ASS-001

**Business Rules**: None

**Related Entities**: EmployeeSkill

**API Endpoints**: GET /api/v1/reports/skill-assessments

---

### Career Paths Management (FR-CAR)

#### FR-CAR-001: Define Career Ladder

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define career ladders
So that employees can see career progression paths
```

**Description**:
System shall allow defining career ladders for different career tracks.

**Acceptance Criteria**:
- Given I am an HR Admin
- When I create a career ladder
- Then ladder is created
- And ladder name is provided
- And ladder type is specified (MANAGEMENT, TECHNICAL, SPECIALIST, EXECUTIVE)
- And ladder description is added
- And ladder is available for career path definition
- And effective dates are set

**Dependencies**: FR-CFG-002 (for CAREER_TRACK)

**Business Rules**: BR-CAR-001

**Related Entities**: CareerLadder

**API Endpoints**: POST /api/v1/career-ladders

---

#### FR-CAR-002: Define Career Level

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define career levels within ladders
So that we can structure career progression
```

**Description**:
System shall allow defining career levels within career ladders.

**Acceptance Criteria**:
- Given a career ladder exists
- When I create a career level
- Then level is created
- And level is linked to ladder
- And level name is provided (e.g., Junior, Mid, Senior, Lead, Principal)
- And level rank is specified (for ordering)
- And level description is added
- And typical job titles are listed
- And level requirements can be specified

**Dependencies**: FR-CAR-001

**Business Rules**: BR-CAR-002

**Related Entities**: CareerLevel, CareerLadder

**API Endpoints**: POST /api/v1/career-levels

---

#### FR-CAR-003: Link Jobs to Career Levels

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to link jobs to career levels
So that employees know job progression
```

**Description**:
System shall allow linking jobs to career levels.

**Acceptance Criteria**:
- Given a career level and job exist
- When I link job to level
- Then job is associated with level
- And job appears in career path
- And multiple jobs can be at same level
- And job can be in multiple career paths
- And link can be effective-dated

**Dependencies**: FR-CAR-002, FR-TAX-005

**Business Rules**: None

**Related Entities**: CareerLevel, Job

**API Endpoints**: POST /api/v1/career-levels/{id}/jobs

---

#### FR-CAR-005: Define Career Path

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define career paths
So that employees can see progression options
```

**Description**:
System shall allow defining career paths showing progression from one level to another.

**Acceptance Criteria**:
- Given career levels exist
- When I create a career path
- Then path is created
- And starting level is specified
- And target level is specified
- And path type is specified (VERTICAL, LATERAL, CROSS_FUNCTIONAL)
- And typical duration is estimated
- And path requirements are listed
- And path can be visualized

**Dependencies**: FR-CAR-002

**Business Rules**: BR-CAR-010

**Related Entities**: CareerPath, CareerLevel

**API Endpoints**: POST /api/v1/career-paths

---

#### FR-CAR-006: Define Path Requirements

**Priority**: MEDIUM

**User Story**:
```
As an HR Admin
I want to define requirements for career progression
So that employees know what's needed to advance
```

**Description**:
System shall allow defining requirements for career paths.

**Acceptance Criteria**:
- Given a career path exists
- When I add requirements
- Then requirements are saved
- And required skills are specified
- And required competencies are specified
- And required experience (years) is specified
- And required education level is specified
- And required certifications are listed
- And requirements can be marked as required or preferred

**Dependencies**: FR-CAR-005

**Business Rules**: None

**Related Entities**: CareerPath

**API Endpoints**: POST /api/v1/career-paths/{id}/requirements

---

#### FR-CAR-010: View Employee Career Path

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to view my career path options
So that I can plan my career development
```

**Description**:
System shall show employees their available career paths.

**Acceptance Criteria**:
- Given I am an employee with a job
- When I view my career paths
- Then available paths from my current level are shown
- And vertical progression paths are displayed
- And lateral movement options are shown
- And cross-functional opportunities are listed
- And path requirements are displayed
- And my current progress is shown
- And paths can be filtered by career track

**Dependencies**: FR-CAR-005, FR-ASG-001

**Business Rules**: None

**Related Entities**: CareerPath, Employee

**API Endpoints**: GET /api/v1/employees/me/career-paths

---

#### FR-CAR-011: Career Readiness Assessment

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to assess my readiness for next level
So that I know what gaps to address
```

**Description**:
System shall assess employee readiness for career progression.

**Acceptance Criteria**:
- Given I select a target career path
- When I request readiness assessment
- Then my skills are compared to requirements
- And my competencies are compared to requirements
- And my experience is compared to requirements
- And gaps are identified
- And readiness score is calculated
- And development recommendations are provided
- And assessment can be exported

**Dependencies**: FR-CAR-010, FR-ASS-010

**Business Rules**: BR-CAR-015

**Related Entities**: CareerPath, Employee

**API Endpoints**: GET /api/v1/employees/me/career-readiness/{pathId}

---

#### FR-CAR-015: Career Milestones

**Priority**: LOW

**User Story**:
```
As an HR Admin
I want to define career milestones
So that employees can track progress
```

**Description**:
System shall allow defining milestones along career paths.

**Acceptance Criteria**:
- Given a career path exists
- When I add milestones
- Then milestones are created
- And milestone name is provided
- And milestone description is added
- And milestone criteria are specified
- And milestone sequence is defined
- And milestones can be tracked

**Dependencies**: FR-CAR-005

**Business Rules**: None

**Related Entities**: CareerPath, CareerMilestone

**API Endpoints**: POST /api/v1/career-paths/{id}/milestones

---

#### FR-CAR-016: Track Career Progress

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to track my career progress
So that I can see my advancement
```

**Description**:
System shall track employee progress along career paths.

**Acceptance Criteria**:
- Given I have a career path
- When I view progress
- Then completed milestones are shown
- And pending milestones are displayed
- And progress percentage is calculated
- And timeline is visualized
- And achievements are highlighted
- And progress history is retained

**Dependencies**: FR-CAR-015

**Business Rules**: None

**Related Entities**: Employee, CareerMilestone

**API Endpoints**: GET /api/v1/employees/me/career-progress

---

#### FR-CAR-020: Career Development Plan

**Priority**: MEDIUM

**User Story**:
```
As a Manager
I want to create career development plans
So that employees can advance their careers
```

**Description**:
System shall allow creating career development plans for employees.

**Acceptance Criteria**:
- Given an employee and target career path exist
- When I create development plan
- Then plan is created
- And target role is specified
- And target timeline is set
- And development activities are listed
- And skill development is linked
- And plan can be reviewed periodically
- And plan progress is tracked

**Dependencies**: FR-CAR-010, FR-ASS-020

**Business Rules**: None

**Related Entities**: CareerDevelopmentPlan, Employee

**API Endpoints**: POST /api/v1/employees/{id}/career-development-plan

---

#### FR-CAR-021: Career Conversations

**Priority**: LOW

**User Story**:
```
As a Manager
I want to document career conversations
So that we track career discussions
```

**Description**:
System shall allow documenting career conversations with employees.

**Acceptance Criteria**:
- Given I am a manager
- When I document a career conversation
- Then conversation is recorded
- And conversation date is set
- And discussion topics are documented
- And career aspirations are captured
- And action items are listed
- And follow-up date can be set
- And conversation history is retained

**Dependencies**: FR-CAR-010

**Business Rules**: None

**Related Entities**: CareerConversation, Employee

**API Endpoints**: POST /api/v1/employees/{id}/career-conversations

---

#### FR-CAR-022: Succession Planning Integration

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to link career paths to succession planning
So that we identify future leaders
```

**Description**:
System shall integrate career paths with succession planning.

**Acceptance Criteria**:
- Given career paths and succession plans exist
- When I view succession candidates
- Then candidates' career paths are shown
- And readiness for target role is assessed
- And development needs are identified
- And career progression timeline is estimated
- And succession plan is linked to career plan

**Dependencies**: FR-CAR-010, FR-ASG-042

**Business Rules**: None

**Related Entities**: CareerPath, Employee

**API Endpoints**: GET /api/v1/succession-planning/career-paths

---

#### FR-CAR-023: Career Path Visualization

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to visualize career paths
So that I can see progression options clearly
```

**Description**:
System shall provide visual representation of career paths.

**Acceptance Criteria**:
- Given career paths exist
- When I request visualization
- Then paths are displayed graphically
- And current position is highlighted
- And possible next steps are shown
- And path requirements are displayed on hover
- And visualization can be filtered by career track
- And visualization can be exported

**Dependencies**: FR-CAR-005

**Business Rules**: None

**Related Entities**: CareerPath

**API Endpoints**: GET /api/v1/career-paths/visualization

---

#### FR-CAR-024: Career Path Search

**Priority**: LOW

**User Story**:
```
As an Employee
I want to search career paths
So that I can explore options
```

**Description**:
System shall provide search capabilities for career paths.

**Acceptance Criteria**:
- Given career paths exist
- When I search by job, skill, or career track
- Then matching paths are returned
- And I can filter by career track
- And I can filter by required skills
- And I can filter by duration
- And results are paginated
- And results can be sorted

**Dependencies**: FR-CAR-005

**Business Rules**: None

**Related Entities**: CareerPath

**API Endpoints**: GET /api/v1/career-paths/search

---

#### FR-CAR-025: Career Path Analytics

**Priority**: LOW

**User Story**:
```
As an HR Manager
I want to view career path analytics
So that I can analyze career progression trends
```

**Description**:
System shall provide analytics on career paths and progression.

**Acceptance Criteria**:
- Given career paths and employee data exist
- When I request analytics
- Then report shows most common career paths
- And report shows average progression time
- And report shows career path completion rates
- And report shows career track distribution
- And report shows retention by career track
- And report can be filtered by business unit
- And report can be exported

**Dependencies**: FR-CAR-005

**Business Rules**: None

**Related Entities**: CareerPath, Employee

**API Endpoints**: GET /api/v1/reports/career-paths

---

### Data Privacy & Security Management (FR-PRI)

#### FR-PRI-001: Data Classification

**Priority**: HIGH

**User Story**:
```
As a DPO
I want to classify data by sensitivity
So that we can apply appropriate protection
```

**Description**:
System shall enforce data classification at field level (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED).

**Acceptance Criteria**:
- Given data fields exist
- When data is stored or accessed
- Then classification is enforced
- And PUBLIC data is accessible to all
- And INTERNAL data is accessible to same organization
- And CONFIDENTIAL data is accessible to manager + HR
- And RESTRICTED data is accessible to HR only with purpose
- And classification is documented in data dictionary

**Dependencies**: FR-WRK-010

**Business Rules**: BR-WRK-004, BR-PRI-001

**Related Entities**: All entities with personal data

**API Endpoints**: N/A (system-wide enforcement)

---

#### FR-PRI-002: Data Encryption

**Priority**: HIGH

**User Story**:
```
As a Security Admin
I want RESTRICTED data to be encrypted
So that we protect sensitive information
```

**Description**:
System shall encrypt RESTRICTED data at rest and in transit using AES-256.

**Acceptance Criteria**:
- Given RESTRICTED data exists
- When data is stored
- Then data is encrypted using AES-256
- And encryption keys are managed securely
- And data is decrypted only for authorized access
- And encryption is transparent to authorized users
- And encryption audit trail is maintained

**Dependencies**: FR-PRI-001

**Business Rules**: BR-PRI-002

**Related Entities**: Worker, Employee (RESTRICTED fields)

---

#### FR-PRI-003: Consent Management

**Priority**: HIGH

**User Story**:
```
As a DPO
I want to manage data processing consent
So that we comply with GDPR/PDPA
```

**Description**:
System shall manage employee consent for data processing.

**Acceptance Criteria**:
- Given an employee exists
- When consent is required
- Then consent request is presented
- And consent purpose is clearly stated
- And consent can be granted or denied
- And consent can be withdrawn
- And consent history is tracked
- And consent expiry is enforced

**Dependencies**: None

**Business Rules**: BR-PRI-010

**Related Entities**: Employee, DataConsent

**API Endpoints**: POST /api/v1/employees/{id}/consent

---

#### FR-PRI-005: Purpose Limitation

**Priority**: HIGH

**User Story**:
```
As a DPO
I want to enforce purpose limitation
So that data is used only for stated purposes
```

**Description**:
System shall enforce that data is used only for documented purposes.

**Acceptance Criteria**:
- Given data access is requested
- When purpose is not specified
- Then access is denied
- And purpose must be from approved list
- And purpose is logged
- And data usage is audited against purpose
- And violations are reported

**Dependencies**: FR-PRI-003

**Business Rules**: BR-PRI-011

**Related Entities**: All entities with personal data

---

#### FR-PRI-006: Data Minimization

**Priority**: MEDIUM

**User Story**:
```
As a DPO
I want to enforce data minimization
So that we collect only necessary data
```

**Description**:
System shall enforce data minimization principles.

**Acceptance Criteria**:
- Given data collection forms exist
- When data is collected
- Then only required fields are mandatory
- And optional fields are clearly marked
- And justification for data collection is documented
- And unnecessary data is not collected
- And data collection is reviewed periodically

**Dependencies**: None

**Business Rules**: BR-PRI-012

**Related Entities**: All entities with personal data

---

#### FR-PRI-010: Right to Access

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to access my personal data
So that I can verify what data is held
```

**Description**:
System shall allow employees to access their personal data (GDPR Article 15).

**Acceptance Criteria**:
- Given I am an employee
- When I request my personal data
- Then all my data is provided
- And data is provided in readable format
- And data includes all processing activities
- And data includes data sources
- And data includes data recipients
- And request is fulfilled within 30 days
- And access is logged

**Dependencies**: None

**Business Rules**: BR-PRI-020

**Related Entities**: Employee, Worker

**API Endpoints**: GET /api/v1/employees/me/personal-data

---

#### FR-PRI-011: Right to Rectification

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to correct my personal data
So that inaccurate data is fixed
```

**Description**:
System shall allow employees to request data rectification (GDPR Article 16).

**Acceptance Criteria**:
- Given I am an employee
- When I request data correction
- Then correction request is created
- And request is reviewed by HR
- And approved corrections are applied
- And rejected requests are explained
- And request is fulfilled within 30 days
- And rectification is logged

**Dependencies**: FR-PRI-010

**Business Rules**: BR-PRI-021

**Related Entities**: Employee, Worker

**API Endpoints**: POST /api/v1/employees/me/rectification-request

---

#### FR-PRI-012: Right to Erasure

**Priority**: HIGH

**User Story**:
```
As an Employee
I want to request data deletion
So that my data is removed when no longer needed
```

**Description**:
System shall support right to erasure / right to be forgotten (GDPR Article 17).

**Acceptance Criteria**:
- Given I am an employee
- When I request data deletion
- Then deletion request is created
- And legal basis for retention is checked
- And data is deleted if no legal basis exists
- And data is anonymized if deletion not possible
- And request is fulfilled within 30 days
- And deletion is logged
- And employee is notified

**Dependencies**: FR-PRI-010

**Business Rules**: BR-PRI-022

**Related Entities**: Employee, Worker

**API Endpoints**: POST /api/v1/employees/me/erasure-request

---

#### FR-PRI-015: Data Retention Policy

**Priority**: HIGH

**User Story**:
```
As a DPO
I want to enforce data retention policies
So that data is not kept longer than necessary
```

**Description**:
System shall enforce data retention policies based on legal requirements.

**Acceptance Criteria**:
- Given retention policies are defined
- When data reaches retention limit
- Then data is flagged for review
- And data is deleted or anonymized
- And deletion is logged
- And retention periods vary by data type
- And legal holds override retention
- And retention compliance is reported

**Dependencies**: None

**Business Rules**: BR-PRI-030

**Related Entities**: All entities with personal data

---

#### FR-PRI-016: Data Anonymization

**Priority**: MEDIUM

**User Story**:
```
As a DPO
I want to anonymize data
So that we can use data without privacy concerns
```

**Description**:
System shall support data anonymization for analytics and reporting.

**Acceptance Criteria**:
- Given personal data exists
- When anonymization is requested
- Then personally identifiable information is removed
- And data cannot be re-identified
- And anonymized data can be used for analytics
- And anonymization is irreversible
- And anonymization is logged

**Dependencies**: None

**Business Rules**: BR-PRI-031

**Related Entities**: All entities with personal data

**API Endpoints**: POST /api/v1/data/anonymize

---

#### FR-PRI-020: Data Breach Detection

**Priority**: HIGH

**User Story**:
```
As a Security Admin
I want to detect data breaches
So that we can respond quickly
```

**Description**:
System shall detect and alert on potential data breaches.

**Acceptance Criteria**:
- Given data access occurs
- When unusual access patterns are detected
- Then security alerts are triggered
- And suspicious activities are logged
- And security team is notified
- And access can be blocked
- And breach investigation is initiated

**Dependencies**: None

**Business Rules**: BR-PRI-040

**Related Entities**: All entities with personal data

---

#### FR-PRI-021: Breach Notification

**Priority**: HIGH

**User Story**:
```
As a DPO
I want to notify authorities of data breaches
So that we comply with GDPR/PDPA
```

**Description**:
System shall support data breach notification process.

**Acceptance Criteria**:
- Given a data breach is confirmed
- When breach affects personal data
- Then breach is documented
- And supervisory authority is notified within 72 hours
- And affected individuals are notified
- And breach details are recorded
- And remediation actions are tracked
- And breach report is generated

**Dependencies**: FR-PRI-020

**Business Rules**: BR-PRI-041

**Related Entities**: DataBreach

**API Endpoints**: POST /api/v1/data-breaches

---

#### FR-PRI-025: Access Control

**Priority**: HIGH

**User Story**:
```
As a Security Admin
I want to control data access
So that only authorized users can access data
```

**Description**:
System shall enforce role-based access control (RBAC) for personal data.

**Acceptance Criteria**:
- Given users have roles
- When data access is requested
- Then role permissions are checked
- And access is granted or denied
- And access is logged
- And least privilege principle is enforced
- And access can be reviewed periodically

**Dependencies**: FR-PRI-001

**Business Rules**: BR-PRI-050

**Related Entities**: All entities with personal data

---

#### FR-PRI-026: Audit Logging

**Priority**: HIGH

**User Story**:
```
As an Auditor
I want comprehensive audit logs
So that we can track all data access
```

**Description**:
System shall maintain comprehensive audit logs for all personal data access.

**Acceptance Criteria**:
- Given data access occurs
- When any personal data is accessed
- Then access is logged
- And who accessed data is recorded
- And when access occurred is recorded
- And what data was accessed is recorded
- And purpose of access is recorded
- And logs are tamper-proof
- And logs are retained per policy

**Dependencies**: None

**Business Rules**: BR-PRI-051

**Related Entities**: AuditLog

**API Endpoints**: GET /api/v1/audit-logs

---

#### FR-PRI-027: Data Portability

**Priority**: MEDIUM

**User Story**:
```
As an Employee
I want to export my data
So that I can transfer it to another system
```

**Description**:
System shall support data portability (GDPR Article 20).

**Acceptance Criteria**:
- Given I am an employee
- When I request data export
- Then my data is exported
- And data is in machine-readable format (JSON, CSV)
- And data includes all personal data
- And export is provided within 30 days
- And export is logged

**Dependencies**: FR-PRI-010

**Business Rules**: BR-PRI-060

**Related Entities**: Employee, Worker

**API Endpoints**: GET /api/v1/employees/me/export

---

#### FR-PRI-028: Privacy Impact Assessment

**Priority**: LOW

**User Story**:
```
As a DPO
I want to conduct privacy impact assessments
So that we identify privacy risks
```

**Description**:
System shall support privacy impact assessments (PIA/DPIA).

**Acceptance Criteria**:
- Given new data processing is planned
- When PIA is conducted
- Then privacy risks are identified
- And risk severity is assessed
- And mitigation measures are documented
- And PIA is reviewed by DPO
- And PIA results are stored
- And PIA is updated periodically

**Dependencies**: None

**Business Rules**: None

**Related Entities**: PrivacyImpactAssessment

**API Endpoints**: POST /api/v1/privacy-impact-assessments

---

#### FR-PRI-029: Data Processing Register

**Priority**: MEDIUM

**User Story**:
```
As a DPO
I want to maintain data processing register
So that we document all processing activities
```

**Description**:
System shall maintain register of data processing activities (GDPR Article 30).

**Acceptance Criteria**:
- Given data processing occurs
- When processing activity is registered
- Then processing purpose is documented
- And data categories are listed
- And data subjects are identified
- And recipients are documented
- And retention periods are specified
- And security measures are described
- And register is available for audit

**Dependencies**: None

**Business Rules**: BR-PRI-070

**Related Entities**: DataProcessingActivity

**API Endpoints**: POST /api/v1/data-processing-register

---

#### FR-PRI-030: Privacy Compliance Reporting

**Priority**: MEDIUM

**User Story**:
```
As a DPO
I want privacy compliance reports
So that we can demonstrate compliance
```

**Description**:
System shall provide comprehensive privacy compliance reports.

**Acceptance Criteria**:
- Given privacy controls are in place
- When compliance report is requested
- Then report shows data classification coverage
- And report shows consent status
- And report shows data retention compliance
- And report shows access requests handled
- And report shows breaches (if any)
- And report shows audit log summary
- And report can be filtered by date range
- And report can be exported

**Dependencies**: All FR-PRI requirements

**Business Rules**: None

**Related Entities**: All entities with personal data

**API Endpoints**: GET /api/v1/reports/privacy-compliance

---

## 📊 Requirements Traceability Matrix

| Feature | Total FRs | HIGH | MEDIUM | LOW | Status |
|---------|-----------|------|--------|-----|--------|
| Code List | 40 | 30 | 10 | 0 | ✅ Defined |
| Worker | 25 | 20 | 5 | 0 | ✅ Defined |
| Work Relationship | 30 | 25 | 5 | 0 | 🔄 In Progress |
| Employee | 25 | 20 | 5 | 0 | 📝 Planned |
| Assignment | 45 | 35 | 10 | 0 | 📝 Planned |
| Reporting | 20 | 5 | 15 | 0 | 📝 Planned |
| Business Unit | 35 | 10 | 25 | 0 | 📝 Planned |
| Job Taxonomy | 30 | 10 | 20 | 0 | 📝 Planned |
| Job Profile | 30 | 10 | 20 | 0 | 📝 Planned |
| Position | 35 | 10 | 25 | 0 | 📝 Planned |
| Matrix Reporting | 25 | 10 | 15 | 0 | 📝 Planned |
| Skill Catalog | 25 | 5 | 15 | 5 | 📝 Planned |
| Skill Assessment | 30 | 10 | 15 | 5 | 📝 Planned |
| Career Paths | 25 | 5 | 15 | 5 | 📝 Planned |
| Data Privacy | 30 | 20 | 10 | 0 | 📝 Planned |

---

**Document Version**: 1.0 (Partial - First 50 FRs)  
**Created**: 2025-12-02  
**Status**: In Progress - This is a partial document showing the structure and first ~50 requirements. Full document will contain all ~450 FRs.
