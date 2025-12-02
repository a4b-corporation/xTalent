# Data Security & Privacy Guide

**Version**: 2.0  
**Last Updated**: 2025-12-02  
**Audience**: All Users, HR Administrators, Compliance Officers  
**Reading Time**: 45-55 minutes

---

## 📋 Overview

This guide explains how xTalent Core Module protects personal data and ensures compliance with global and Vietnamese data protection regulations, including GDPR, PDPA, and Vietnamese Decree 13/2023/NĐ-CP on Personal Data Protection.

### What You'll Learn
- Data classification levels and their importance
- Compliance with GDPR, PDPA, and Vietnamese regulations
- Access control and audit mechanisms
- Data subject rights (access, rectification, erasure)
- Best practices for data protection
- Real-world compliance scenarios

### Prerequisites
- Basic understanding of personal data
- Familiarity with HR data types
- Understanding of worker and employee entities

---

## 🎯 Regulatory Landscape

### Global and Vietnamese Regulations

```yaml
Applicable Regulations:

International:
  GDPR (EU):
    full_name: "General Data Protection Regulation"
    jurisdiction: "European Union"
    effective_date: 2018-05-25
    applies_to: "EU citizens' data, regardless of location"
    
  PDPA (Singapore):
    full_name: "Personal Data Protection Act"
    jurisdiction: "Singapore"
    effective_date: 2014-07-02
    applies_to: "Singapore residents' data"

Vietnam:
  Decree 13/2023/NĐ-CP:
    full_name: "Nghị định 13/2023/NĐ-CP về Bảo vệ Dữ liệu Cá nhân"
    jurisdiction: "Vietnam"
    effective_date: 2023-07-01
    applies_to: "Vietnamese citizens' data"
    level: "Equivalent to GDPR/PDPA"
    
  Law on Cybersecurity 2018:
    full_name: "Luật An ninh mạng 2018"
    jurisdiction: "Vietnam"
    effective_date: 2019-01-01
    
  Decree 85/2016/NĐ-CP:
    full_name: "Nghị định 85/2016/NĐ-CP về Bảo mật thông tin"
    jurisdiction: "Vietnam"
    effective_date: 2016-07-01
```

### Key Principles (Common Across Regulations)

```yaml
Core Principles:

1. Lawfulness, Fairness, Transparency:
   - Process data lawfully
   - Be transparent about processing
   - Inform data subjects
   
2. Purpose Limitation:
   - Collect for specific purposes
   - Don't use for other purposes
   - Document purposes clearly
   
3. Data Minimization:
   - Collect only necessary data
   - Don't collect excessive data
   - Review data needs regularly
   
4. Accuracy:
   - Keep data accurate
   - Update when needed
   - Allow corrections
   
5. Storage Limitation:
   - Don't keep data longer than needed
   - Define retention periods
   - Delete when no longer needed
   
6. Integrity and Confidentiality:
   - Protect against unauthorized access
   - Implement security measures
   - Prevent data breaches
   
7. Accountability:
   - Demonstrate compliance
   - Document processes
   - Maintain audit trails
```

---

## 📊 Data Classification Framework

### 4-Level Classification System

```yaml
Data Classification Levels:

Level 1: PUBLIC
  description: "Information that can be freely shared"
  risk_level: "Low"
  examples:
    - Worker name (public profile)
    - Job title
    - Work email
    - Office location
    - Public phone number
  access_control: "All employees"
  encryption: "Not required"
  audit: "Not required"
  
Level 2: INTERNAL
  description: "Information for internal use only"
  risk_level: "Medium"
  examples:
    - Work phone (direct line)
    - Department
    - Manager name
    - Office address
    - Work schedule
  access_control: "Same organization"
  encryption: "Recommended"
  audit: "Basic logging"
  
Level 3: CONFIDENTIAL
  description: "Sensitive business/personal data"
  risk_level: "High"
  examples:
    - Date of birth
    - Personal email
    - Personal phone
    - Home address
    - Salary
    - Performance rating
    - Disciplinary records
  access_control: "Manager + HR only"
  encryption: "Required"
  audit: "Full audit trail"
  retention: "Defined retention period"
  
Level 4: RESTRICTED
  description: "Highly sensitive personal data (PII)"
  risk_level: "Critical"
  examples:
    - National ID (CMND/CCCD)
    - Passport number
    - Social security number
    - Bank account details
    - Health data
    - Biometric data (fingerprint, face)
    - Criminal records
    - Union membership
    - Religious beliefs
  access_control: "HR only + explicit consent"
  encryption: "Required (AES-256)"
  audit: "Full audit trail with purpose"
  retention: "Strict retention policy"
  special_handling: "Requires data subject consent"
```

### Vietnamese-Specific Considerations

```yaml
Vietnam Decree 13/2023/NĐ-CP:

Special Categories (Dữ liệu nhạy cảm):
  - Political views (Quan điểm chính trị)
  - Religious beliefs (Tín ngưỡng, tôn giáo)
  - Health data (Dữ liệu sức khỏe)
  - Biometric data (Dữ liệu sinh trắc học)
  - Genetic data (Dữ liệu di truyền)
  - Sexual orientation (Xu hướng tình dục)
  - Criminal records (Tiền án, tiền sự)
  - Location data (Dữ liệu vị trí)
  
  Classification: RESTRICTED
  Consent Required: YES (explicit, informed)
  Processing Basis: Legal obligation or explicit consent
  
Vietnamese Personal Identifiers:
  CMND (Chứng minh nhân dân):
    classification: RESTRICTED
    format: "9 or 12 digits"
    
  CCCD (Căn cước công dân):
    classification: RESTRICTED
    format: "12 digits"
    
  Mã số thuế (Tax ID):
    classification: CONFIDENTIAL
    format: "10 digits"
    
  Số BHXH (Social Insurance Number):
    classification: RESTRICTED
    format: "10 digits"
```

---

## 🔐 Data Classification Implementation

### Worker Entity with Classification

```yaml
Worker:
  id: WORKER-001
  
  # PUBLIC Data
  full_name: "Nguyễn Văn An"
    data_classification: PUBLIC
    access_level: ALL_EMPLOYEES
    
  preferred_name: "An"
    data_classification: PUBLIC
    
  job_title: "Senior Backend Engineer"
    data_classification: PUBLIC
    
  work_email: "an.nguyen@company.com"
    data_classification: PUBLIC
    
  # INTERNAL Data
  work_phone: "+84-28-1234-5678"
    data_classification: INTERNAL
    access_level: SAME_ORGANIZATION
    
  department: "Engineering"
    data_classification: INTERNAL
    
  office_location: "HCM Office - Building A"
    data_classification: INTERNAL
    
  # CONFIDENTIAL Data
  date_of_birth: "1990-05-15"
    data_classification: CONFIDENTIAL
    access_level: MANAGER_HR_ONLY
    encryption: REQUIRED
    
  personal_email: "an.nguyen.personal@gmail.com"
    data_classification: CONFIDENTIAL
    
  personal_phone: "+84-90-123-4567"
    data_classification: CONFIDENTIAL
    
  home_address: "123 Nguyễn Huệ, Q1, TPHCM"
    data_classification: CONFIDENTIAL
    
  # RESTRICTED Data (Vietnamese PII)
  national_id: "001234567890"  # CCCD
    data_classification: RESTRICTED
    access_level: HR_ONLY_WITH_CONSENT
    encryption: AES_256
    consent_required: true
    consent_id: CONSENT-001
    purpose: "Employment verification, tax reporting"
    legal_basis: "Labor Code Article 16"
    
  tax_id: "0123456789"  # Mã số thuế
    data_classification: RESTRICTED
    encryption: AES_256
    
  social_insurance_number: "1234567890"  # Số BHXH
    data_classification: RESTRICTED
    encryption: AES_256
    legal_basis: "Social Insurance Law"
    
  bank_account:
    account_number: "1234567890"
    bank_name: "Vietcombank"
    data_classification: RESTRICTED
    encryption: AES_256
    purpose: "Salary payment"
    
  biometric_data:
    fingerprint_hash: "[encrypted]"
    face_template: "[encrypted]"
    data_classification: RESTRICTED
    encryption: AES_256
    consent_required: true
    consent_id: CONSENT-002
    purpose: "Access control, attendance tracking"
    legal_basis: "Explicit consent"
    retention_period: "Employment duration + 1 year"
```

---

## 🔒 Access Control Matrix

### Role-Based Access Control (RBAC)

```yaml
Access Control Rules:

# Employee (Self)
Role: EMPLOYEE_SELF
  can_view:
    - All own data (PUBLIC, INTERNAL, CONFIDENTIAL, RESTRICTED)
  can_edit:
    - Contact information (with approval)
    - Emergency contacts
    - Bank account (with verification)
  cannot_edit:
    - National ID, Tax ID (immutable)
    - Employment history
    - Salary, performance data
  audit: All access logged

# Manager (Direct Reports)
Role: MANAGER
  can_view:
    PUBLIC: ✅ All employees
    INTERNAL: ✅ All employees
    CONFIDENTIAL: ✅ Direct reports only
      - Date of birth
      - Contact information
      - Salary (if authorized)
      - Performance data
    RESTRICTED: ❌ No access
  cannot_view:
    - National ID
    - Biometric data
    - Health data
    - Bank account details
  audit: All access logged with purpose

# HR Administrator
Role: HR_ADMIN
  can_view:
    PUBLIC: ✅ All employees
    INTERNAL: ✅ All employees
    CONFIDENTIAL: ✅ All employees
    RESTRICTED: ✅ All employees (with purpose)
  can_edit:
    - All data (with approval workflow)
  must_provide:
    - Purpose for accessing RESTRICTED data
    - Business justification
  audit: Full audit trail with purpose logging

# HR Viewer (Limited)
Role: HR_VIEWER
  can_view:
    PUBLIC: ✅ All employees
    INTERNAL: ✅ All employees
    CONFIDENTIAL: ✅ Limited fields
      - Date of birth
      - Contact information
    RESTRICTED: ❌ No access
  cannot_edit: Any data
  audit: All access logged

# Payroll Administrator
Role: PAYROLL_ADMIN
  can_view:
    PUBLIC: ✅ All employees
    INTERNAL: ✅ All employees
    CONFIDENTIAL: ✅ Payroll-related only
      - Salary
      - Bank account
      - Tax ID
    RESTRICTED: ✅ Payroll-related only
      - National ID (for tax reporting)
      - Social Insurance Number
      - Bank account details
  purpose: "Payroll processing, tax reporting"
  legal_basis: "Labor Code, Tax Law"
  audit: Full audit trail

# System Administrator
Role: SYSTEM_ADMIN
  can_view:
    - Encrypted data only (cannot decrypt)
    - System logs
    - Audit trails
  cannot_view:
    - Decrypted RESTRICTED data
  special_access:
    - Database administration
    - Backup/restore
    - System maintenance
  audit: All actions logged
  
# External Auditor (Temporary)
Role: EXTERNAL_AUDITOR
  can_view:
    - Anonymized data only
    - Aggregated reports
  cannot_view:
    - Individual PII
    - RESTRICTED data
  access_duration: "Limited to audit period"
  audit: Full audit trail
```

---

## 📝 Consent Management

### Consent Framework

```yaml
Consent Types:

1. Employment Consent (Mandatory):
   purpose: "Process employment data for HR purposes"
   legal_basis: "Contract necessity (Labor Code)"
   data_categories:
     - Name, contact information
     - Employment history
     - Job performance
   consent_required: NO (contractual necessity)
   
2. National ID Processing (Mandatory):
   purpose: "Verify identity, tax reporting"
   legal_basis: "Legal obligation (Tax Law, Labor Code)"
   data_categories:
     - National ID (CCCD/CMND)
     - Tax ID
   consent_required: NO (legal obligation)
   
3. Biometric Data (Optional):
   purpose: "Access control, attendance tracking"
   legal_basis: "Explicit consent"
   data_categories:
     - Fingerprint
     - Face recognition
   consent_required: YES (explicit consent)
   consent_withdrawal: "Can withdraw anytime"
   consequence_of_withdrawal: "Manual attendance tracking"
   
4. Health Data (Optional):
   purpose: "Health insurance, medical leave"
   legal_basis: "Explicit consent"
   data_categories:
     - Health records
     - Medical certificates
   consent_required: YES (explicit consent)
   sensitive_category: YES
   
5. Background Check (Optional):
   purpose: "Employment screening"
   legal_basis: "Explicit consent"
   data_categories:
     - Criminal records
     - Education verification
   consent_required: YES (explicit consent)
   retention: "Recruitment period + 1 year"
```

### Consent Record Example

```yaml
Consent Record:
  id: CONSENT-001
  worker_id: WORKER-001
  
  consent_type: BIOMETRIC_DATA
  purpose: "Access control and attendance tracking"
  
  data_categories:
    - Fingerprint template
    - Face recognition template
  
  legal_basis: "Explicit consent (Decree 13/2023/NĐ-CP Article 10)"
  
  consent_given:
    date: 2024-01-15T10:30:00+07:00
    method: "Electronic signature"
    ip_address: "192.168.1.100"
    user_agent: "Chrome 120.0"
    
  consent_text: |
    Tôi đồng ý cho [Công ty] thu thập và xử lý dữ liệu sinh trắc học 
    (vân tay, khuôn mặt) của tôi cho mục đích kiểm soát ra vào và 
    chấm công. Tôi hiểu rằng tôi có thể rút lại sự đồng ý này bất kỳ 
    lúc nào.
    
    I consent to [Company] collecting and processing my biometric data
    (fingerprint, face) for access control and attendance tracking.
    I understand I can withdraw this consent at any time.
  
  retention_period: "Employment duration + 1 year"
  
  withdrawal_rights:
    can_withdraw: true
    withdrawal_method: "Email to hr@company.com or HR portal"
    consequence: "Manual attendance tracking will be used"
  
  status: ACTIVE
  
  audit_trail:
    - timestamp: 2024-01-15T10:30:00+07:00
      action: CONSENT_GIVEN
      user: WORKER-001
      ip: "192.168.1.100"
```

---

## 🔍 Audit Trail System

### Audit Log Structure

```yaml
Audit Log Entry:
  id: AUDIT-12345
  timestamp: 2024-06-15T14:30:00+07:00
  
  # Who
  user_id: HR-ADMIN-001
  user_name: "Trần Thị Bình"
  user_role: HR_ADMIN
  ip_address: "192.168.1.50"
  user_agent: "Chrome 120.0"
  
  # What
  action: VIEW_RESTRICTED_DATA
  entity_type: WORKER
  entity_id: WORKER-001
  
  # Which data
  data_accessed:
    - field: national_id
      classification: RESTRICTED
      value_accessed: "[masked]"
    - field: social_insurance_number
      classification: RESTRICTED
      value_accessed: "[masked]"
  
  # Why
  purpose: "Process social insurance claim"
  business_justification: "Employee submitted SI claim form #12345"
  legal_basis: "Social Insurance Law Article 25"
  
  # Result
  access_granted: true
  access_reason: "Authorized HR Admin with valid purpose"
  
  # Compliance
  gdpr_lawful_basis: "Legal obligation"
  vietnam_legal_basis: "Decree 13/2023/NĐ-CP Article 8"
  
  # Retention
  retention_period: "7 years (legal requirement)"
```

### Audit Requirements by Classification

```yaml
Audit Requirements:

PUBLIC Data:
  audit_required: NO
  logging: "Optional"
  
INTERNAL Data:
  audit_required: YES
  logging: "Basic (who, when, what)"
  retention: "1 year"
  
CONFIDENTIAL Data:
  audit_required: YES
  logging: "Detailed (who, when, what, why)"
  retention: "3 years"
  review_frequency: "Quarterly"
  
RESTRICTED Data:
  audit_required: YES (mandatory)
  logging: "Full (who, when, what, why, legal basis)"
  retention: "7 years (Vietnam legal requirement)"
  review_frequency: "Monthly"
  alerts:
    - Unusual access patterns
    - Access outside business hours
    - Bulk data access
    - Export to external systems
  reporting:
    - Monthly access reports
    - Quarterly compliance reports
    - Annual audit reports
```

---

## 👤 Data Subject Rights

### Rights Under GDPR, PDPA, and Vietnamese Law

```yaml
Data Subject Rights:

1. Right to Access (Quyền truy cập):
   description: "Access personal data held by organization"
   timeline: "30 days (Vietnam), 1 month (GDPR)"
   implementation:
     - Self-service portal
     - Download personal data
     - Request via email/form
   
2. Right to Rectification (Quyền sửa đổi):
   description: "Correct inaccurate data"
   timeline: "30 days"
   implementation:
     - Self-service updates (contact info)
     - Request form for other data
     - Manager/HR approval workflow
   
3. Right to Erasure (Quyền xóa):
   description: "Delete personal data ('right to be forgotten')"
   timeline: "30 days"
   conditions:
     - No longer needed for purpose
     - Consent withdrawn
     - Unlawful processing
   exceptions:
     - Legal obligation (tax records: 10 years)
     - Employment records (Vietnam: 50 years for some)
     - Litigation hold
   implementation:
     - Soft delete (mark as deleted)
     - Hard delete after retention period
   
4. Right to Restriction (Quyền hạn chế):
   description: "Limit processing of data"
   timeline: "Immediate"
   scenarios:
     - Accuracy disputed
     - Unlawful processing
     - Pending legal claim
   
5. Right to Data Portability (Quyền chuyển dữ liệu):
   description: "Receive data in structured format"
   timeline: "30 days"
   format: "JSON, CSV, PDF"
   implementation:
     - Export function
     - Structured data format
   
6. Right to Object (Quyền phản đối):
   description: "Object to processing"
   timeline: "Immediate review"
   scenarios:
     - Direct marketing
     - Automated decision-making
   
7. Right to Withdraw Consent (Quyền rút lại đồng ý):
   description: "Withdraw consent anytime"
   timeline: "Immediate"
   implementation:
     - Self-service withdrawal
     - Email/form request
   consequence: "Processing stops (if consent-based)"
```

### Data Subject Request Workflow

```yaml
Data Subject Access Request (DSAR):

Step 1: Request Submission
  channels:
    - Self-service portal
    - Email: privacy@company.com
    - Written form
  
  required_information:
    - Full name
    - Employee ID (if applicable)
    - Identity verification
    - Type of request
    - Specific data requested (if applicable)

Step 2: Identity Verification
  methods:
    - Employee ID + password
    - National ID verification
    - Two-factor authentication
  
  timeline: 2 business days

Step 3: Request Processing
  timeline: 30 days (can extend to 60 days if complex)
  
  actions:
    - Gather requested data
    - Redact third-party data
    - Prepare response
    - Legal review (if needed)

Step 4: Response Delivery
  format:
    - Secure portal download
    - Encrypted email
    - Physical mail (if requested)
  
  content:
    - All personal data held
    - Processing purposes
    - Data recipients
    - Retention periods
    - Data subject rights

Step 5: Follow-up
  - Confirm receipt
  - Address questions
  - Process any additional requests
```

---

## 🛡️ Data Protection Measures

### Technical Safeguards

```yaml
Encryption:
  At Rest:
    RESTRICTED data: AES-256
    CONFIDENTIAL data: AES-256
    Database: Transparent Data Encryption (TDE)
    Backups: Encrypted
    
  In Transit:
    Protocol: TLS 1.3
    Certificate: Valid SSL/TLS certificate
    API calls: HTTPS only
    
  Key Management:
    Storage: Hardware Security Module (HSM)
    Rotation: Every 90 days
    Access: Restricted to security team

Access Control:
  Authentication:
    - Multi-factor authentication (MFA)
    - Strong password policy
    - Session timeout: 30 minutes
    
  Authorization:
    - Role-based access control (RBAC)
    - Principle of least privilege
    - Regular access reviews
    
  Network Security:
    - Firewall rules
    - VPN for remote access
    - IP whitelisting

Data Masking:
  Display Masking:
    National ID: "001234****90"
    Phone: "+84-90-***-**67"
    Email: "an.***@gmail.com"
    
  Export Masking:
    - Full masking for non-authorized users
    - Partial masking for authorized users
    - No masking for data subject (self)

Anonymization:
  Techniques:
    - Pseudonymization (reversible)
    - Anonymization (irreversible)
    - Aggregation
    - Data suppression
    
  Use Cases:
    - Analytics and reporting
    - External audits
    - Research purposes
```

### Organizational Safeguards

```yaml
Policies and Procedures:
  - Data Protection Policy
  - Privacy Policy
  - Data Retention Policy
  - Incident Response Plan
  - Breach Notification Procedure
  
Training:
  - Annual privacy training (all employees)
  - Specialized training (HR, IT)
  - New hire orientation
  - Regular refreshers

Data Protection Officer (DPO):
  role: "Oversee data protection compliance"
  responsibilities:
    - Monitor compliance
    - Conduct privacy impact assessments
    - Handle data subject requests
    - Liaise with authorities
  contact: dpo@company.com

Privacy Impact Assessment (PIA):
  when_required:
    - New HR system
    - New data processing activity
    - High-risk processing
    - Biometric data collection
  
  process:
    1. Identify data processing activities
    2. Assess necessity and proportionality
    3. Identify risks
    4. Mitigation measures
    5. Document and review

Data Processing Agreements:
  with_vendors:
    - Cloud providers
    - Payroll processors
    - Background check providers
  
  requirements:
    - GDPR/PDPA compliant
    - Data processing terms
    - Security requirements
    - Breach notification
    - Data deletion on termination
```

---

## 🚨 Data Breach Response

### Breach Response Plan

```yaml
Data Breach Response:

Phase 1: Detection and Containment (0-24 hours)
  actions:
    - Detect breach (automated alerts, reports)
    - Contain breach (isolate systems)
    - Preserve evidence
    - Notify security team
    - Activate incident response team
  
  team:
    - DPO (Data Protection Officer)
    - IT Security
    - Legal
    - HR
    - Communications

Phase 2: Assessment (24-72 hours)
  actions:
    - Assess scope (how many records)
    - Identify data types (classification levels)
    - Determine cause
    - Assess risk to individuals
    - Document findings
  
  risk_assessment:
    - Number of individuals affected
    - Data sensitivity (RESTRICTED > CONFIDENTIAL)
    - Potential harm
    - Likelihood of misuse

Phase 3: Notification (72 hours)
  regulatory_notification:
    Vietnam:
      authority: "Ministry of Public Security"
      timeline: "72 hours from discovery"
      threshold: "Affects rights of data subjects"
      
    GDPR:
      authority: "Supervisory Authority"
      timeline: "72 hours from discovery"
      threshold: "Risk to rights and freedoms"
      
    PDPA:
      authority: "Personal Data Protection Commission"
      timeline: "As soon as practicable"
      threshold: "Significant harm or impact"
  
  individual_notification:
    timeline: "Without undue delay"
    method: "Email, portal notification, letter"
    content:
      - Nature of breach
      - Data affected
      - Potential consequences
      - Mitigation measures
      - Contact information
      - Rights and remedies

Phase 4: Remediation (Ongoing)
  actions:
    - Fix vulnerabilities
    - Enhance security measures
    - Update policies
    - Additional training
    - Monitor for further issues

Phase 5: Review and Lessons Learned
  actions:
    - Post-incident review
    - Document lessons learned
    - Update incident response plan
    - Implement improvements
```

### Breach Notification Template

```yaml
Breach Notification (Vietnamese):

Subject: THÔNG BÁO QUAN TRỌNG - Vi phạm dữ liệu cá nhân

Kính gửi [Tên nhân viên],

Chúng tôi xin thông báo rằng đã xảy ra sự cố vi phạm dữ liệu cá nhân 
có thể ảnh hưởng đến thông tin cá nhân của bạn.

1. Sự cố xảy ra:
   Ngày: [Date]
   Mô tả: [Description]

2. Dữ liệu bị ảnh hưởng:
   - [List of data types]

3. Hành động chúng tôi đã thực hiện:
   - [Containment measures]
   - [Security enhancements]

4. Hành động bạn nên thực hiện:
   - [Recommended actions]

5. Quyền lợi của bạn:
   - Quyền truy cập dữ liệu
   - Quyền sửa đổi
   - Quyền khiếu nại

Liên hệ: dpo@company.com | +84-28-xxxx-xxxx

Trân trọng,
[Company Name]
```

---

## ✅ Compliance Checklist

### GDPR Compliance

```yaml
GDPR Compliance Checklist:

Legal Basis:
  ☑ Identify lawful basis for processing
  ☑ Document processing purposes
  ☑ Obtain consent where required
  ☑ Implement consent management

Data Subject Rights:
  ☑ Right to access (SAR process)
  ☑ Right to rectification
  ☑ Right to erasure
  ☑ Right to restriction
  ☑ Right to data portability
  ☑ Right to object

Security:
  ☑ Encryption (at rest and in transit)
  ☑ Access controls (RBAC)
  ☑ Audit logging
  ☑ Regular security assessments

Accountability:
  ☑ Data Protection Officer appointed
  ☑ Privacy policies published
  ☑ Data processing records maintained
  ☑ Privacy impact assessments conducted
  ☑ Data processing agreements with vendors

Breach Management:
  ☑ Breach detection mechanisms
  ☑ Incident response plan
  ☑ 72-hour notification process
  ☑ Breach register maintained
```

### Vietnamese Decree 13/2023/NĐ-CP Compliance

```yaml
Vietnam Compliance Checklist:

Nghị định 13/2023/NĐ-CP:

Cơ sở pháp lý (Legal Basis):
  ☑ Xác định cơ sở pháp lý xử lý dữ liệu
  ☑ Ghi nhận mục đích xử lý
  ☑ Xin đồng ý khi cần thiết (dữ liệu nhạy cảm)
  ☑ Thông báo cho chủ thể dữ liệu

Quyền của chủ thể dữ liệu:
  ☑ Quyền truy cập dữ liệu
  ☑ Quyền sửa đổi, bổ sung
  ☑ Quyền xóa dữ liệu
  ☑ Quyền rút lại đồng ý
  ☑ Quyền khiếu nại

Bảo mật:
  ☑ Mã hóa dữ liệu nhạy cảm
  ☑ Kiểm soát truy cập
  ☑ Ghi nhận nhật ký truy cập
  ☑ Đánh giá bảo mật định kỳ

Lưu trữ dữ liệu:
  ☑ Lưu trữ tại Việt Nam (nếu yêu cầu)
  ☑ Thời hạn lưu trữ xác định
  ☑ Xóa dữ liệu khi hết thời hạn

Thông báo vi phạm:
  ☑ Quy trình phát hiện vi phạm
  ☑ Thông báo Bộ Công an trong 72 giờ
  ☑ Thông báo chủ thể dữ liệu
  ☑ Ghi nhận sổ vi phạm

Người chịu trách nhiệm:
  ☑ Chỉ định người phụ trách bảo vệ dữ liệu
  ☑ Công bố chính sách bảo mật
  ☑ Đào tạo nhân viên
  ☑ Báo cáo tuân thủ định kỳ
```

---

## 📊 Data Retention Policies

### Retention Periods (Vietnam)

```yaml
Data Retention (Vietnam Labor Law & Tax Law):

Employment Records:
  Employment contracts: 50 years (from termination)
  Labor books (Sổ lao động): Permanent
  Salary records: 10 years
  Social insurance records: Permanent
  Personal income tax: 10 years
  Timesheets: 3 years
  Leave records: 3 years

Recruitment:
  Applications (hired): 3 years
  Applications (not hired): 1 year
  Interview notes: 1 year
  Background checks: 1 year

Performance:
  Performance reviews: 5 years
  Disciplinary records: 5 years
  Training records: 5 years

Termination:
  Termination documents: 50 years
  Exit interviews: 3 years
  Final settlements: 10 years

Audit Logs:
  RESTRICTED data access: 7 years
  CONFIDENTIAL data access: 3 years
  INTERNAL data access: 1 year
```

### Retention Implementation

```yaml
Retention Policy Implementation:

Automatic Deletion:
  trigger: "Retention period expired"
  process:
    1. Identify records past retention
    2. Legal hold check
    3. Soft delete (mark for deletion)
    4. Review period (30 days)
    5. Hard delete (permanent)
    6. Audit log entry

Legal Hold:
  scenarios:
    - Active litigation
    - Government investigation
    - Audit in progress
  
  process:
    - Flag records with legal hold
    - Prevent deletion
    - Notify legal team
    - Release hold when cleared

Archival:
  long_term_retention:
    - Move to archive storage
    - Compress and encrypt
    - Reduced access (legal/audit only)
    - Cost-effective storage
```

---

## 🎓 Best Practices

### For HR Administrators

```yaml
Best Practices:

1. Data Minimization:
   ✅ Collect only necessary data
   ✅ Review data collection forms annually
   ✅ Remove unnecessary fields
   ❌ Don't collect "nice to have" data

2. Access Control:
   ✅ Follow principle of least privilege
   ✅ Review access rights quarterly
   ✅ Remove access when role changes
   ❌ Don't share login credentials

3. Purpose Limitation:
   ✅ Document purpose for data access
   ✅ Use data only for stated purpose
   ✅ Get consent for new purposes
   ❌ Don't use data for other purposes

4. Data Quality:
   ✅ Keep data accurate and up-to-date
   ✅ Verify data periodically
   ✅ Allow employees to update data
   ❌ Don't keep outdated data

5. Training:
   ✅ Complete annual privacy training
   ✅ Stay updated on regulations
   ✅ Report incidents immediately
   ❌ Don't ignore privacy concerns
```

### For Employees

```yaml
Employee Responsibilities:

1. Protect Your Data:
   ✅ Use strong passwords
   ✅ Enable MFA
   ✅ Don't share credentials
   ✅ Log out when done

2. Report Issues:
   ✅ Report suspected breaches
   ✅ Report unauthorized access
   ✅ Report lost devices
   ⏱️ Report immediately (within 24 hours)

3. Exercise Your Rights:
   ✅ Review your data annually
   ✅ Update inaccurate data
   ✅ Request data deletion when leaving
   ✅ Withdraw consent if desired

4. Be Aware:
   ✅ Know what data is collected
   ✅ Know how data is used
   ✅ Know your rights
   ✅ Know who to contact (DPO)
```

---

## 📚 Related Resources

### Vietnamese Regulations

```yaml
Key Vietnamese Laws:

1. Nghị định 13/2023/NĐ-CP:
   url: "https://thuvienphapluat.vn/van-ban/Cong-nghe-thong-tin/Nghi-dinh-13-2023-ND-CP-bao-ve-du-lieu-ca-nhan-542241.aspx"
   
2. Luật An ninh mạng 2018:
   url: "https://thuvienphapluat.vn/van-ban/Cong-nghe-thong-tin/Luat-An-ninh-mang-2018-351416.aspx"
   
3. Bộ Luật Lao động 2019:
   url: "https://thuvienphapluat.vn/van-ban/Lao-dong-Tien-luong/Bo-Luat-lao-dong-2019-333670.aspx"

Contact:
  Data Protection Officer: dpo@company.com
  Privacy Questions: privacy@company.com
  Breach Reports: security@company.com
  Emergency: +84-28-xxxx-xxxx
```

---

**Document Version**: 1.0  
**Created**: 2025-12-02  
**Last Review**: 2025-12-02  
**Compliance Status**: GDPR + PDPA + Vietnam Decree 13/2023/NĐ-CP
