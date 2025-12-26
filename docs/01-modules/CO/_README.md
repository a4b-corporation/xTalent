# Core HR (CO) Module

> Foundation module providing worker, organization, and position management

## 📋 Overview

The Core HR module is the foundation of xTalent, managing:
- **Workers**: Employment relationships and worker data
- **Organization Structure**: Legal entities, org units, departments
- **Jobs & Positions**: Job definitions and organizational positions
- **Assignments**: Worker assignments to positions

## 📁 Documentation Structure

```
CO/
├── 00-ontology/       # Domain entities (Worker, Position, OrgUnit, etc.)
├── 01-concept/        # What Core HR does and why
├── 02-spec/           # Detailed specifications
├── 03-design/         # Data model and system design
├── 04-api/            # API specifications
├── 05-ui/             # UI specs and mockups
├── 06-tests/          # Test scenarios
└── 07-impl-notes/     # Technical decisions
```

## 🎯 Key Features

### Worker Management
- Worker lifecycle (hire, transfer, terminate)
- Personal information management
- Employment history
- Worker status tracking

### Organization Structure
- Legal entity management
- Organizational unit hierarchy
- Department and team structure
- Cost center management

### Position Management
- Job definition and classification
- Position creation and management
- Position hierarchy
- Position status tracking

### Assignment Management
- Worker-to-position assignments
- Primary and secondary assignments
- Assignment history
- Temporary assignments and secondments

## 🔗 Integration Points

- **TA (Time & Absence)**: Provides worker and org data for leave management
- **TR (Total Rewards)**: Provides worker and position data for compensation
- **PR (Payroll)**: Provides worker and assignment data for payroll processing

## 📚 Key Entities

| Entity | Description |
|--------|-------------|
| **Person** | Individual human being |
| **Worker** | Employment relationship |
| **LegalEntity** | Legal company entity |
| **OrgUnit** | Organizational unit (department, team) |
| **Job** | Job definition/role type |
| **Position** | Specific position in org structure |
| **Assignment** | Worker assignment to position |

## 🚀 Getting Started

1. **Understand the Domain**: Read `00-ontology/` and `01-concept/`
2. **Review Specifications**: Check `02-spec/` for detailed requirements
3. **Explore API**: See `04-api/` for API documentation
4. **View UI**: Check `05-ui/` for UI specifications

## 📖 Related Documents

- [Global Ontology](../../00-global/ontology/core-domain.yaml)
- [Domain Glossary](../../00-global/glossary/domain-glossary.md)
- [SpecKit Guide](../../00-global/speckit/spec-structure.md)

---

**Module Owner**: [Team/Person]  
**Last Updated**: 2025-11-28
