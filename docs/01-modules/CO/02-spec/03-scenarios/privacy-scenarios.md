# Data Privacy Scenarios - Core Module

**Version**: 2.0  
**Last Updated**: 2025-12-03  
**Module**: Core (CO)  
**Status**: Complete - GDPR/PDPA Compliance Workflows

---

## 📋 Overview

This document defines detailed end-to-end scenarios for data privacy and GDPR/PDPA compliance in the Core Module. Each scenario provides step-by-step workflows for data subject rights, consent management, data breach response, and privacy compliance operations.

### Scenario Categories

1. **Data Subject Access Request (DSAR)** - GDPR Article 15
2. **Data Rectification & Erasure** - GDPR Articles 16 & 17
3. **Consent Management** - GDPR Article 6
4. **Data Breach Response** - GDPR Article 33 & 34
5. **Privacy Compliance & Reporting** - GDPR Article 30

### Regulatory Framework

- **GDPR**: General Data Protection Regulation (EU)
- **PDPA**: Personal Data Protection Act (Singapore, Thailand, etc.)
- **SLA**: 30 days for most requests, 72 hours for breach notification

---

## 🔍 Scenario 1: Data Subject Access Request (DSAR)

### Overview

**Scenario**: Employee requests access to all personal data (GDPR Article 15)

**Actors**:
- Employee (Data Subject)
- Data Protection Officer (DPO)
- HR Administrator
- IT Security Team

**Preconditions**:
- Employee is authenticated
- DSAR process documented
- Data inventory exists
- Response templates ready

**Legal Basis**: GDPR Article 15 - Right to Access

**SLA**: 30 days from request

---

### Main Flow

#### Step 1: Submit Access Request

**Actor**: Employee

**Action**: Submit DSAR through employee portal

**Input Data**:
```json
{
  "request_type": "ACCESS",
  "employee_id": "emp-uuid-001",
  "request_date": "2025-01-15",
  "scope": "ALL_PERSONAL_DATA",
  "preferred_format": "JSON",
  "delivery_method": "SECURE_DOWNLOAD",
  "reason": "I want to know what personal data the company holds about me",
  "contact_email": "employee@personal-email.com"
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/access
Authorization: Bearer {employee_token}
Content-Type: application/json
```

**Business Rules Applied**:
- BR-PRI-020: Right to Access

**Expected Output**:
```json
{
  "request_id": "DSAR-2025-001",
  "request_type": "ACCESS",
  "status": "SUBMITTED",
  "submitted_date": "2025-01-15T10:00:00Z",
  "sla_deadline": "2025-02-14T23:59:59Z",
  "estimated_completion": "2025-02-10",
  "assigned_to": "DPO Team",
  "reference_number": "DSAR-2025-001"
}
```

**Data Changes**:
- `dsar_requests` table: INSERT 1 row
- `audit_logs` table: INSERT 1 row
- Notification sent to DPO

---

#### Step 2: DPO Reviews Request

**Actor**: Data Protection Officer

**Action**: Review and validate DSAR

**Validation Checks**:
1. ✅ Requester identity verified
2. ✅ Request scope is clear
3. ✅ No excessive requests (frequency check)
4. ✅ Legal basis confirmed

**API Call**:
```http
GET /api/v1/privacy/dsar/{requestId}
```

**Expected Output**:
```json
{
  "request_id": "DSAR-2025-001",
  "employee": {
    "employee_number": "EMP-000456",
    "full_name": "Nguyễn Văn An",
    "email": "an.nguyen@company.com",
    "employment_status": "ACTIVE"
  },
  "validation": {
    "identity_verified": true,
    "previous_requests_count": 0,
    "last_request_date": null,
    "is_excessive": false
  },
  "data_scope": {
    "estimated_records": 150,
    "data_categories": [
      "Personal Information",
      "Employment Records",
      "Assignment History",
      "Skill Assessments",
      "Performance Data"
    ]
  }
}
```

**Action**: Approve request
```http
POST /api/v1/privacy/dsar/{requestId}/approve
```

---

#### Step 3: System Collects Personal Data

**Actor**: System (Automated)

**Action**: Gather all personal data from all systems

**Data Collection Process**:

```json
{
  "employee_id": "emp-uuid-001",
  "data_collection": {
    "worker_data": {
      "source": "workers table",
      "fields": [
        "full_name", "preferred_name", "date_of_birth",
        "gender", "national_id", "passport_number",
        "email", "phone", "address"
      ],
      "classification": "CONFIDENTIAL/RESTRICTED"
    },
    "employment_data": {
      "source": "employees, work_relationships tables",
      "fields": [
        "employee_number", "hire_date", "employment_type",
        "contract_type", "probation_status", "termination_date"
      ],
      "classification": "CONFIDENTIAL"
    },
    "assignment_history": {
      "source": "assignments table",
      "records": 5,
      "includes": "All assignments with SCD Type 2 history"
    },
    "skill_data": {
      "source": "employee_skills, skill_assessments tables",
      "records": 12,
      "includes": "Skills, proficiency levels, assessments, endorsements"
    },
    "performance_data": {
      "source": "performance module",
      "records": 3,
      "includes": "Performance reviews, goals, feedback"
    },
    "compensation_data": {
      "source": "compensation module",
      "records": 8,
      "includes": "Salary history, bonuses, benefits"
    },
    "time_attendance": {
      "source": "time & attendance module",
      "records": 365,
      "includes": "Time entries, leave records"
    }
  }
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/{requestId}/collect-data
```

---

#### Step 4: Generate DSAR Report

**Actor**: System (Automated)

**Action**: Generate comprehensive data export

**Report Structure**:
```json
{
  "dsar_report": {
    "request_id": "DSAR-2025-001",
    "generated_date": "2025-02-08T10:00:00Z",
    "data_subject": {
      "employee_number": "EMP-000456",
      "full_name": "Nguyễn Văn An",
      "email": "an.nguyen@company.com"
    },
    "personal_data": {
      "worker_information": {
        "full_name": "Nguyễn Văn An",
        "preferred_name": "An",
        "date_of_birth": "1990-01-15",
        "gender": "Male",
        "national_id": "***********890",
        "email": "an.nguyen@company.com",
        "phone": "+84901234567",
        "address": {
          "street": "123 Nguyễn Huệ",
          "city": "Ho Chi Minh City",
          "country": "Vietnam"
        }
      },
      "employment_records": [
        {
          "employee_number": "EMP-000456",
          "hire_date": "2025-01-15",
          "employment_type": "FULL_TIME",
          "contract_type": "PERMANENT",
          "status": "ACTIVE",
          "probation_end_date": "2025-04-15"
        }
      ],
      "assignment_history": [
        {
          "assignment_number": 1,
          "job_title": "Senior Software Engineer",
          "business_unit": "Backend Engineering",
          "manager": "Trần Thị Bình",
          "start_date": "2025-01-15",
          "end_date": null,
          "status": "ACTIVE"
        }
      ],
      "skills_and_assessments": [
        {
          "skill": "Python Programming",
          "proficiency_level": "ADVANCED",
          "assessment_source": "MANAGER_ASSESSED",
          "assessment_date": "2025-01-15",
          "assessor": "Trần Thị Bình"
        }
      ]
    },
    "processing_activities": [
      {
        "purpose": "Employment Management",
        "legal_basis": "Contract",
        "data_categories": ["Personal Information", "Employment Data"],
        "retention_period": "7 years after termination"
      },
      {
        "purpose": "Performance Management",
        "legal_basis": "Legitimate Interest",
        "data_categories": ["Performance Data", "Skills"],
        "retention_period": "3 years"
      }
    ],
    "data_sources": [
      "HR System (xTalent)",
      "Payroll System",
      "Time & Attendance System",
      "Performance Management System"
    ],
    "data_recipients": [
      "HR Department",
      "Payroll Team",
      "Direct Manager",
      "Finance Department (for payroll)"
    ],
    "data_transfers": [
      {
        "recipient": "Cloud Provider (AWS)",
        "country": "Singapore",
        "safeguards": "Standard Contractual Clauses"
      }
    ]
  }
}
```

**Export Formats**:
- JSON (machine-readable)
- PDF (human-readable)
- Excel (structured data)

---

#### Step 5: DPO Reviews and Approves Report

**Actor**: DPO

**Action**: Review report for completeness and accuracy

**Review Checklist**:
- [ ] All personal data included
- [ ] Data sources documented
- [ ] Processing purposes listed
- [ ] Legal basis specified
- [ ] Recipients identified
- [ ] Retention periods stated
- [ ] No sensitive data of others included
- [ ] Report is clear and understandable

**API Call**:
```http
POST /api/v1/privacy/dsar/{requestId}/approve-report
```

---

#### Step 6: Deliver Report to Employee

**Actor**: System (Automated)

**Action**: Securely deliver report to employee

**Delivery Methods**:
1. **Secure Download Link** (preferred)
   - Encrypted link valid for 7 days
   - Requires authentication
   - Download tracked

2. **Email** (encrypted)
   - Password-protected ZIP
   - Password sent separately

3. **Physical Copy** (if requested)
   - Printed and sealed
   - Requires ID verification

**Notification**:
```json
{
  "to": "employee@personal-email.com",
  "subject": "Your Data Access Request - DSAR-2025-001",
  "body": "Your data access request has been completed. Please use the secure link below to download your personal data report. Link expires: 2025-02-15.",
  "secure_link": "https://privacy.company.com/dsar/download/DSAR-2025-001?token=...",
  "expiry": "2025-02-15T23:59:59Z"
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/{requestId}/deliver
```

---

#### Step 7: Close Request

**Actor**: DPO

**Action**: Mark request as completed

**Final Status**:
```json
{
  "request_id": "DSAR-2025-001",
  "status": "COMPLETED",
  "submitted_date": "2025-01-15",
  "completed_date": "2025-02-08",
  "processing_days": 24,
  "sla_met": true,
  "delivered_via": "SECURE_DOWNLOAD",
  "employee_notified": true
}
```

---

### Postconditions

**System State**:
- ✅ DSAR request completed within SLA (24 days < 30 days)
- ✅ All personal data collected and exported
- ✅ Report delivered securely
- ✅ Complete audit trail maintained
- ✅ Employee rights fulfilled

**Data Summary**:
- DSAR Requests: +1 (COMPLETED)
- Data Export: 1 comprehensive report
- Audit Logs: +7
- Notifications: +3

---

## ✏️ Scenario 2: Data Rectification Request (GDPR Article 16)

### Overview

**Scenario**: Employee requests correction of inaccurate personal data

**Actors**:
- Employee
- DPO
- HR Administrator

**Legal Basis**: GDPR Article 16 - Right to Rectification

**SLA**: 30 days

---

### Main Flow

#### Step 1: Submit Rectification Request

**Actor**: Employee

**Action**: Request data correction

**Input Data**:
```json
{
  "request_type": "RECTIFICATION",
  "employee_id": "emp-uuid-001",
  "request_date": "2025-02-01",
  "fields_to_correct": [
    {
      "field": "phone",
      "current_value": "+84901234567",
      "requested_value": "+84909876543",
      "reason": "Phone number changed"
    },
    {
      "field": "address.street",
      "current_value": "123 Nguyễn Huệ",
      "requested_value": "456 Lê Lợi",
      "reason": "Moved to new address"
    }
  ],
  "supporting_documents": ["new-phone-bill.pdf", "utility-bill.pdf"]
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/rectification
```

**Business Rules Applied**:
- BR-PRI-021: Right to Rectification

**Expected Output**:
```json
{
  "request_id": "RECT-2025-001",
  "status": "PENDING_REVIEW",
  "submitted_date": "2025-02-01T14:00:00Z",
  "sla_deadline": "2025-03-03T23:59:59Z",
  "fields_count": 2
}
```

---

#### Step 2: HR Reviews Request

**Actor**: HR Administrator

**Action**: Verify and approve corrections

**Review Process**:
1. Verify supporting documents
2. Check if fields can be self-updated
3. Approve or request additional info

**For phone and address** (low-risk fields):
```http
POST /api/v1/privacy/dsar/{requestId}/approve
{
  "approved_fields": ["phone", "address.street"],
  "comments": "Documents verified. Approved for update."
}
```

**For sensitive fields** (e.g., date_of_birth, national_id):
```json
{
  "status": "REQUIRES_ADDITIONAL_VERIFICATION",
  "required_documents": [
    "Government-issued ID",
    "Birth certificate"
  ]
}
```

---

#### Step 3: Apply Corrections

**Actor**: System (Automated)

**Action**: Update personal data

**Data Changes**:
```json
{
  "employee_id": "emp-uuid-001",
  "updates": [
    {
      "field": "phone",
      "old_value": "+84901234567",
      "new_value": "+84909876543",
      "updated_by": "DSAR-RECT-2025-001",
      "updated_at": "2025-02-02T10:00:00Z"
    },
    {
      "field": "address.street",
      "old_value": "123 Nguyễn Huệ",
      "new_value": "456 Lê Lợi",
      "updated_by": "DSAR-RECT-2025-001",
      "updated_at": "2025-02-02T10:00:00Z"
    }
  ]
}
```

**SCD Type 2**: Previous values retained in history

---

#### Step 4: Notify Employee

**Actor**: System

**Action**: Confirm rectification completed

**Notification**:
```json
{
  "to": "employee@personal-email.com",
  "subject": "Data Rectification Completed - RECT-2025-001",
  "body": "Your data rectification request has been completed. The following fields have been updated: phone, address.",
  "updated_fields": 2,
  "completion_date": "2025-02-02"
}
```

---

### Postconditions

**System State**:
- ✅ Personal data corrected
- ✅ History preserved (SCD Type 2)
- ✅ Employee notified
- ✅ Audit trail complete

---

## 🗑️ Scenario 3: Data Erasure Request (Right to be Forgotten)

### Overview

**Scenario**: Former employee requests data deletion (GDPR Article 17)

**Actors**:
- Former Employee
- DPO
- Legal Team
- IT Administrator

**Legal Basis**: GDPR Article 17 - Right to Erasure

**SLA**: 30 days

**Complexity**: HIGH (legal review required)

---

### Main Flow

#### Step 1: Submit Erasure Request

**Actor**: Former Employee

**Action**: Request data deletion

**Input Data**:
```json
{
  "request_type": "ERASURE",
  "employee_id": "emp-uuid-terminated",
  "request_date": "2025-03-01",
  "reason": "NO_LONGER_EMPLOYED",
  "scope": "ALL_PERSONAL_DATA",
  "employment_end_date": "2024-12-31"
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/erasure
```

**Business Rules Applied**:
- BR-PRI-022: Right to Erasure

---

#### Step 2: Legal Review

**Actor**: DPO + Legal Team

**Action**: Assess legal obligations for retention

**Legal Retention Check**:
```json
{
  "request_id": "ERAS-2025-001",
  "legal_review": {
    "employment_records": {
      "retention_required": true,
      "legal_basis": "Labor Law - 7 years retention",
      "retention_until": "2031-12-31",
      "can_delete": false,
      "alternative": "ANONYMIZE"
    },
    "payroll_records": {
      "retention_required": true,
      "legal_basis": "Tax Law - 10 years retention",
      "retention_until": "2034-12-31",
      "can_delete": false,
      "alternative": "ANONYMIZE"
    },
    "performance_reviews": {
      "retention_required": false,
      "can_delete": true,
      "deletion_date": "2025-03-15"
    },
    "skill_assessments": {
      "retention_required": false,
      "can_delete": true,
      "deletion_date": "2025-03-15"
    },
    "personal_contact_info": {
      "retention_required": false,
      "can_delete": true,
      "deletion_date": "2025-03-15"
    }
  },
  "decision": "PARTIAL_ERASURE_WITH_ANONYMIZATION"
}
```

---

#### Step 3: Execute Erasure Plan

**Actor**: System (Automated)

**Action**: Delete or anonymize data based on legal review

**Deletion Process**:
```json
{
  "employee_id": "emp-uuid-terminated",
  "erasure_plan": {
    "to_delete": [
      {
        "data_category": "Personal Contact Information",
        "fields": ["email", "phone", "address"],
        "action": "DELETE",
        "tables": ["workers"]
      },
      {
        "data_category": "Performance Reviews",
        "action": "DELETE",
        "tables": ["performance_reviews", "performance_goals"]
      },
      {
        "data_category": "Skill Assessments",
        "action": "DELETE",
        "tables": ["employee_skills", "skill_assessments"]
      }
    ],
    "to_anonymize": [
      {
        "data_category": "Employment Records",
        "fields": ["full_name", "national_id", "date_of_birth"],
        "action": "ANONYMIZE",
        "method": "PSEUDONYMIZATION",
        "tables": ["employees", "work_relationships"],
        "retention_reason": "Legal requirement - 7 years"
      },
      {
        "data_category": "Payroll Records",
        "fields": ["bank_account", "tax_id"],
        "action": "ANONYMIZE",
        "method": "ENCRYPTION_WITH_KEY_DESTRUCTION",
        "tables": ["payroll_history"],
        "retention_reason": "Tax law - 10 years"
      }
    ]
  }
}
```

**Anonymization Example**:
```json
{
  "before": {
    "full_name": "Nguyễn Văn An",
    "national_id": "001234567890",
    "email": "an.nguyen@company.com"
  },
  "after": {
    "full_name": "ANONYMIZED_USER_12345",
    "national_id": "***REDACTED***",
    "email": "deleted@anonymized.local"
  }
}
```

**API Call**:
```http
POST /api/v1/privacy/dsar/{requestId}/execute-erasure
```

---

#### Step 4: Verify Erasure

**Actor**: DPO

**Action**: Verify data deleted/anonymized

**Verification Report**:
```json
{
  "request_id": "ERAS-2025-001",
  "verification": {
    "deleted_records": {
      "workers": 0,
      "performance_reviews": 3,
      "skill_assessments": 12,
      "total": 15
    },
    "anonymized_records": {
      "employees": 1,
      "work_relationships": 1,
      "payroll_history": 24,
      "total": 26
    },
    "retained_records": {
      "reason": "Legal retention requirement",
      "anonymized": true,
      "retention_until": "2034-12-31"
    },
    "verification_date": "2025-03-15",
    "verified_by": "DPO"
  }
}
```

---

#### Step 5: Notify Former Employee

**Actor**: System

**Action**: Confirm erasure completed

**Notification**:
```json
{
  "to": "former-employee@personal-email.com",
  "subject": "Data Erasure Request Completed - ERAS-2025-001",
  "body": "Your data erasure request has been completed. Personal data has been deleted where legally permissible. Some records have been anonymized due to legal retention requirements (employment and payroll records - 7-10 years as required by law).",
  "deleted_categories": [
    "Personal Contact Information",
    "Performance Reviews",
    "Skill Assessments"
  ],
  "anonymized_categories": [
    "Employment Records (retained until 2031-12-31)",
    "Payroll Records (retained until 2034-12-31)"
  ]
}
```

---

### Postconditions

**System State**:
- ✅ Personal data deleted (15 records)
- ✅ Legal retention data anonymized (26 records)
- ✅ Audit trail maintained
- ✅ Former employee notified
- ✅ GDPR compliance maintained

---

## 🔒 Scenario 4: Data Breach Response

### Overview

**Scenario**: Unauthorized access to employee personal data detected

**Actors**:
- IT Security Team
- DPO
- CISO (Chief Information Security Officer)
- Affected Employees
- Supervisory Authority

**Legal Basis**: GDPR Article 33 & 34 - Breach Notification

**SLA**: 72 hours to notify supervisory authority

**Severity**: HIGH

---

### Main Flow

#### Step 1: Breach Detection

**Actor**: IT Security Team

**Action**: Detect and confirm data breach

**Breach Details**:
```json
{
  "breach_id": "BREACH-2025-001",
  "detection_date": "2025-04-01T03:15:00Z",
  "breach_type": "UNAUTHORIZED_ACCESS",
  "affected_system": "HR Database",
  "detection_method": "AUTOMATED_ALERT",
  "severity": "HIGH",
  "initial_assessment": {
    "affected_records_estimate": 150,
    "data_categories": [
      "Personal Information",
      "Employment Data",
      "Salary Information"
    ],
    "breach_vector": "SQL Injection vulnerability",
    "attacker_ip": "203.0.113.45",
    "access_duration": "2 hours"
  }
}
```

**API Call**:
```http
POST /api/v1/privacy/breaches
```

**Business Rules Applied**:
- BR-PRI-040: Data Breach Detection
- BR-PRI-041: Breach Notification

---

#### Step 2: Immediate Containment

**Actor**: IT Security Team

**Action**: Contain breach and prevent further access

**Containment Actions**:
```json
{
  "breach_id": "BREACH-2025-001",
  "containment_actions": [
    {
      "action": "BLOCK_IP_ADDRESS",
      "target": "203.0.113.45",
      "timestamp": "2025-04-01T03:20:00Z",
      "status": "COMPLETED"
    },
    {
      "action": "PATCH_VULNERABILITY",
      "target": "SQL Injection - Employee Search",
      "timestamp": "2025-04-01T04:00:00Z",
      "status": "COMPLETED"
    },
    {
      "action": "FORCE_PASSWORD_RESET",
      "target": "All affected employees",
      "timestamp": "2025-04-01T05:00:00Z",
      "status": "IN_PROGRESS"
    },
    {
      "action": "ENABLE_MFA",
      "target": "All HR system users",
      "timestamp": "2025-04-01T06:00:00Z",
      "status": "PLANNED"
    }
  ]
}
```

---

#### Step 3: Breach Assessment

**Actor**: DPO + CISO

**Action**: Assess breach severity and impact

**Assessment**:
```json
{
  "breach_id": "BREACH-2025-001",
  "assessment": {
    "affected_individuals": 150,
    "data_categories_compromised": [
      {
        "category": "Personal Information",
        "fields": ["full_name", "email", "phone"],
        "classification": "CONFIDENTIAL",
        "risk_level": "MEDIUM"
      },
      {
        "category": "Employment Data",
        "fields": ["employee_number", "job_title", "department"],
        "classification": "INTERNAL",
        "risk_level": "LOW"
      },
      {
        "category": "Salary Information",
        "fields": ["base_salary", "bonus"],
        "classification": "RESTRICTED",
        "risk_level": "HIGH"
      }
    ],
    "risk_assessment": {
      "likelihood_of_harm": "HIGH",
      "severity_of_harm": "HIGH",
      "overall_risk": "HIGH",
      "requires_authority_notification": true,
      "requires_individual_notification": true
    },
    "notification_deadline": "2025-04-04T03:15:00Z"
  }
}
```

---

#### Step 4: Notify Supervisory Authority (Within 72 Hours)

**Actor**: DPO

**Action**: Notify data protection authority

**Notification to Authority**:
```json
{
  "breach_id": "BREACH-2025-001",
  "authority_notification": {
    "authority": "Personal Data Protection Commission (PDPC)",
    "notification_date": "2025-04-02T10:00:00Z",
    "hours_since_detection": 31,
    "sla_met": true,
    "notification_content": {
      "nature_of_breach": "Unauthorized access via SQL injection vulnerability",
      "categories_of_data": [
        "Names, email addresses, phone numbers",
        "Employee numbers, job titles",
        "Salary information"
      ],
      "approximate_number_affected": 150,
      "likely_consequences": "Risk of identity theft, financial fraud, privacy violation",
      "measures_taken": [
        "Vulnerability patched",
        "Attacker IP blocked",
        "Forced password reset",
        "MFA implementation in progress"
      ],
      "contact_person": {
        "name": "Data Protection Officer",
        "email": "dpo@company.com",
        "phone": "+65-1234-5678"
      }
    }
  }
}
```

**API Call**:
```http
POST /api/v1/privacy/breaches/{breachId}/notify-authority
```

---

#### Step 5: Notify Affected Individuals

**Actor**: DPO

**Action**: Notify all affected employees

**Individual Notification**:
```json
{
  "breach_id": "BREACH-2025-001",
  "individual_notifications": {
    "total_affected": 150,
    "notification_method": "EMAIL",
    "notification_date": "2025-04-02T14:00:00Z",
    "notification_content": {
      "subject": "Important: Data Breach Notification",
      "body": "We are writing to inform you of a data security incident that may have affected your personal information...",
      "data_compromised": [
        "Full name",
        "Email address",
        "Phone number",
        "Salary information"
      ],
      "actions_taken": [
        "Vulnerability has been patched",
        "Unauthorized access has been blocked",
        "Security measures have been enhanced"
      ],
      "recommended_actions": [
        "Change your password immediately",
        "Enable multi-factor authentication",
        "Monitor your accounts for suspicious activity",
        "Be alert for phishing attempts"
      ],
      "support_contact": {
        "email": "security-incident@company.com",
        "phone": "+65-1234-5678",
        "hours": "24/7"
      }
    }
  }
}
```

**API Call**:
```http
POST /api/v1/privacy/breaches/{breachId}/notify-individuals
```

---

#### Step 6: Remediation and Documentation

**Actor**: IT Security + DPO

**Action**: Complete remediation and document lessons learned

**Remediation Report**:
```json
{
  "breach_id": "BREACH-2025-001",
  "remediation": {
    "completed_actions": [
      "SQL injection vulnerability patched",
      "Input validation enhanced",
      "Database access controls tightened",
      "MFA enabled for all HR system users",
      "Security training scheduled for all staff"
    ],
    "preventive_measures": [
      "Regular security audits scheduled",
      "Penetration testing quarterly",
      "Code review process enhanced",
      "Security awareness training mandatory"
    ],
    "lessons_learned": [
      "Need for automated vulnerability scanning",
      "Importance of input validation",
      "Value of defense in depth"
    ],
    "closure_date": "2025-04-15",
    "total_cost": "$50,000",
    "status": "CLOSED"
  }
}
```

---

### Postconditions

**System State**:
- ✅ Breach contained within 1 hour
- ✅ Authority notified within 31 hours (< 72 hours SLA)
- ✅ 150 individuals notified
- ✅ Vulnerability patched
- ✅ Security enhanced
- ✅ Complete documentation maintained
- ✅ GDPR compliance maintained

**Timeline**:
- Detection: 2025-04-01 03:15
- Containment: 2025-04-01 04:00 (45 minutes)
- Authority Notification: 2025-04-02 10:00 (31 hours)
- Individual Notification: 2025-04-02 14:00 (35 hours)
- Remediation Complete: 2025-04-15 (14 days)

---

## 📊 Scenario 5: Privacy Compliance Reporting

### Overview

**Scenario**: Generate quarterly privacy compliance report

**Actors**:
- DPO
- Senior Management
- Audit Team

**Legal Basis**: GDPR Article 30 - Records of Processing Activities

**Frequency**: Quarterly

---

### Main Flow

#### Step 1: Generate Compliance Report

**Actor**: DPO

**Action**: Generate comprehensive privacy compliance report

**API Call**:
```http
GET /api/v1/reports/privacy-compliance?period=Q1-2025
```

**Expected Output**:
```json
{
  "report_period": "Q1 2025",
  "generated_date": "2025-04-01",
  "summary": {
    "data_classification_coverage": 100,
    "consent_compliance": 98.5,
    "retention_compliance": 97.2,
    "dsar_completion_rate": 100,
    "breach_count": 1,
    "audit_log_coverage": 100
  },
  "dsar_statistics": {
    "total_requests": 25,
    "by_type": {
      "ACCESS": 15,
      "RECTIFICATION": 7,
      "ERASURE": 2,
      "PORTABILITY": 1
    },
    "completed_within_sla": 25,
    "average_processing_days": 18,
    "sla_compliance_rate": 100
  },
  "consent_management": {
    "total_consents": 1500,
    "granted": 1478,
    "denied": 22,
    "withdrawn": 5,
    "expired": 10,
    "consent_rate": 98.5
  },
  "data_retention": {
    "records_reviewed": 5000,
    "records_deleted": 120,
    "records_anonymized": 50,
    "retention_violations": 15,
    "compliance_rate": 97.2
  },
  "data_breaches": {
    "total_breaches": 1,
    "severity": {
      "HIGH": 1,
      "MEDIUM": 0,
      "LOW": 0
    },
    "authority_notifications": 1,
    "individual_notifications": 150,
    "average_containment_time": "45 minutes"
  },
  "audit_logs": {
    "total_logs": 1500000,
    "access_logs": 1200000,
    "modification_logs": 250000,
    "deletion_logs": 50000,
    "coverage": 100
  }
}
```

---

#### Step 2: Data Processing Register

**Actor**: DPO

**Action**: Maintain register of processing activities (GDPR Article 30)

**Processing Register**:
```json
{
  "processing_activities": [
    {
      "activity_id": "PA-001",
      "activity_name": "Employee Recruitment and Onboarding",
      "purpose": "To recruit and onboard new employees",
      "legal_basis": "Contract",
      "data_categories": [
        "Personal identification data",
        "Contact information",
        "Education and qualifications",
        "Work history"
      ],
      "data_subjects": "Job applicants, new employees",
      "recipients": [
        "HR Department",
        "Hiring Managers",
        "Background check providers"
      ],
      "retention_period": "7 years after employment ends",
      "security_measures": [
        "Encryption at rest and in transit",
        "Access control (RBAC)",
        "Audit logging",
        "Regular backups"
      ],
      "data_transfers": [
        {
          "recipient": "Background Check Provider",
          "country": "Singapore",
          "safeguards": "Standard Contractual Clauses"
        }
      ]
    },
    {
      "activity_id": "PA-002",
      "activity_name": "Performance Management",
      "purpose": "To manage employee performance and development",
      "legal_basis": "Legitimate Interest",
      "data_categories": [
        "Performance ratings",
        "Goals and objectives",
        "Feedback and comments",
        "Development plans"
      ],
      "data_subjects": "Active employees",
      "recipients": [
        "HR Department",
        "Direct managers",
        "Senior management"
      ],
      "retention_period": "3 years after performance review",
      "security_measures": [
        "Encryption",
        "Access control",
        "Audit logging"
      ]
    }
  ]
}
```

---

### Postconditions

**System State**:
- ✅ Compliance report generated
- ✅ Processing register updated
- ✅ DSAR statistics tracked
- ✅ Breach incidents documented
- ✅ Ready for audit

---

## 📊 Scenario Summary

### Scenarios Covered

| Scenario | Complexity | Actors | SLA | GDPR Article |
|----------|------------|--------|-----|--------------|
| **DSAR (Access)** | High | 4 | 30 days | Article 15 |
| **Data Rectification** | Medium | 3 | 30 days | Article 16 |
| **Data Erasure** | High | 4 | 30 days | Article 17 |
| **Breach Response** | High | 5 | 72 hours | Articles 33 & 34 |
| **Compliance Reporting** | Medium | 3 | Quarterly | Article 30 |

### Key Operations Covered

**DSAR Operations**:
- ✅ Access request (Article 15)
- ✅ Rectification request (Article 16)
- ✅ Erasure request (Article 17)
- ✅ Portability request (Article 20)
- ✅ SLA tracking (30 days)
- ✅ Secure delivery

**Consent Management**:
- ✅ Consent collection
- ✅ Consent withdrawal
- ✅ Consent tracking
- ✅ Purpose limitation

**Breach Management**:
- ✅ Detection and containment
- ✅ Risk assessment
- ✅ Authority notification (72 hours)
- ✅ Individual notification
- ✅ Remediation

**Compliance**:
- ✅ Processing register (Article 30)
- ✅ Compliance reporting
- ✅ Audit trails
- ✅ Retention policies

---

## 🎯 Privacy Compliance Metrics

### Key Performance Indicators

**DSAR Metrics**:
- DSAR completion rate: 100%
- Average processing time: 18 days
- SLA compliance: 100%
- Employee satisfaction: 95%

**Breach Metrics**:
- Breach count: 1 (Q1 2025)
- Average containment time: 45 minutes
- Authority notification: 31 hours (< 72 hours)
- Individual notification: 35 hours

**Compliance Metrics**:
- Data classification coverage: 100%
- Consent compliance: 98.5%
- Retention compliance: 97.2%
- Audit log coverage: 100%

---

## 🔗 Related Documentation

- [Functional Requirements](../01-functional-requirements.md) - Privacy FRs
- [Business Rules](../04-business-rules.md) - BR-PRI rules
- [API Specification](../02-api-specification.md) - Privacy APIs
- [Data Classification Guide](../../01-concept/09-data-privacy-guide.md) - Concepts

---

**Document Version**: 2.0  
**Created**: 2025-12-03  
**Scenarios**: 5 detailed privacy compliance workflows  
**Maintained By**: Product Team + DPO + Legal Team  
**Status**: Complete - GDPR/PDPA Compliant
