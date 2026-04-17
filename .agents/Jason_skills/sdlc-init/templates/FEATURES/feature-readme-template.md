# Feature [NNN]: [Feature Name]

> **Sequence**: [NNN]  
> **Status**: [🟢 Production | 🟡 In Development | 🔵 Planned]  
> **Last Updated**: [YYYY-MM-DD]

## Overview
[1-2 sentence description of what this feature does and why it matters]

## 📖 Table of Contents

1. [Document Trail](#-document-trail) - Requirements, design, and implementation links
2. [Key Features](#key-features) - What this feature accomplishes
3. [Key Components](#-key-components) - Services, models, and database elements
4. [Technical Decisions](#technical-decisions) - Architecture patterns and choices
5. [Implementation Status](#implementation-status) - What's been delivered
6. [Deployment Info](#-deployment-info) - Release dates and configuration
7. [Testing & Verification](#-testing--verification) - How to validate the feature
8. [Known Issues](#-known-issues--resolutions) - Problems and solutions
9. [Related Features](#related-features) - Connected systems and dependencies

---

## 📋 Document Trail

### 1. 📋 Requirements Analysis
- [YYYYMMDD Requirements](./YYYYMMDD_requirements.md) - Complete functional and non-functional requirements

### 2. 🏗️ System Design
- [YYYYMMDD System Design](./YYYYMMDD_system-design.md) - High-level architecture and component design
- Related ADRs: [List relevant architecture decisions]

### 3. 💻 Detailed Design & Implementation
- [YYYYMMDD Implementation Guide](./YYYYMMDD_implementation-guide.md) - Code patterns and detailed implementation
- [YYYYMMDD Implementation Summary](./YYYYMMDD_implementation-summary.md) - Completion notes and achievements

### 4. 🐛 Bug Fixes & Improvements (if applicable)
- [YYYYMMDD Issue Description](./YYYYMMDD_fix-description.md) - Problem analysis and resolution

---

## Key Features

- **Feature 1**: [Description and impact]
- **Feature 2**: [Description and impact]
- **Feature 3**: [Description and impact]
- **Feature N**: [Additional capabilities]

---

## 📦 Key Components

### Core Services
- `PrimaryService.cs` - [Main responsibility and workflow]
- `SecondaryService.cs` - [Supporting responsibility]

### Domain Model
- `AggregateRoot` - [Business entity and its role]
- `ChildEntity` - [Supporting entity]

### Database Tables
- `table_name` - [Purpose and key columns]
- `related_table` - [Relationship and purpose]

### API Endpoints
- `GET /api/endpoint` - [Purpose]
- `POST /api/endpoint` - [Purpose]

---

## Technical Decisions

### Architecture Patterns
- **Pattern Name**: [Description and rationale]
- **Design Principle**: [SOLID principle or pattern applied]

### Key Technologies
- [Technology]: [Why chosen for this feature]

### Related Architecture Records
- [ADR-XXX: Decision Name](../../architecture/decisions/XXX-decision.md)

---

## Implementation Status

### Completed (✅)
- [ ] Requirement 1 fulfilled
- [ ] Component 1 implemented
- [ ] Testing completed
- [ ] Deployed to production

### In Progress (🔄)
- [ ] Enhancement 1 in development
- [ ] Component update underway

### Planned (📋)
- [ ] Future enhancement 1
- [ ] Performance optimization

---

## 🚀 Deployment Info

**Production Deployment**: [Date - YYYY-MM-DD]  
**Version**: [X.X.X]  
**Environment**: [dev | staging | production]

### Configuration
```json
{
  "FeatureName": {
    "setting1": "value",
    "setting2": 123,
    "enableFeature": true
  }
}
```

### Dependencies
- Service A (required)
- Service B (optional, graceful fallback)

---

## 🧪 Testing & Verification

### Test Coverage
- ✅ Unit tests: [Scope and coverage %]
- ✅ Integration tests: [Scope and coverage %]
- ✅ Manual testing: [Test scenarios]

### How to Test
1. [Step 1 with example command or data]
2. [Step 2 with expected outcome]
3. [Step 3 with verification]

### Sample Test Data
```json
{
  "example": "data for testing"
}
```

---

## 📊 Metrics & Monitoring

### Key Metrics
- **Metric 1**: [What it measures and target]
- **Metric 2**: [What it measures and target]

### Alerts & Thresholds
- Alert when [condition]
- Warning when [threshold]

### Dashboards
- [Dashboard name] - [What it shows] *(link if available)*

---

## 🐛 Known Issues & Resolutions

### Issue 1: [Title]
- **Status**: ✅ RESOLVED | 🔄 IN PROGRESS | ⚠️ KNOWN LIMITATION
- **Description**: [What went wrong]
- **Root Cause**: [Why it happened]
- **Resolution**: [How it was fixed or workaround]
- **Reference**: [Link to related documentation]

---

## Related Features

| # | Feature | Status | Relationship |
|---|---------|--------|--------------|
| 001 | [Feature Name] | 🟢 Production | [Provides data / Consumes data / Integrated with] |
| 002 | [Feature Name] | 🟡 In Development | [Relationship] |

---

## Quick Links
- [Back to Documentation Index](../../README.md)
- [View All Templates](../../_templates/README.md)
- [Architecture Decisions](../../architecture/decisions/README.md)

---

**Contributing**: See [Code Delivery Template](../../_templates/PROCESS/code-delivery-template.md) for how to document changes to this feature.
