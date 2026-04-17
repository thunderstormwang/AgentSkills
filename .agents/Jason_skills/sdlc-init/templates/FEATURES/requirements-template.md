# Feature Requirements Template

**Feature Name**: [Feature Name]  
**Status**: 🔵 Planned | 🟡 In Development | 🟢 Production  
**Document ID**: REQ-[FEATURE_CODE]-[NNN]  
**Created**: YYYY-MM-DD  
**Last Updated**: YYYY-MM-DD  
**Author**: [Name]

## Overview

Brief 2-3 sentence description of what this feature does and why it exists.

## Business Context

### Problem Statement
What problem are we solving? What pain point does this address?

### Business Goals
- Goal 1: Measurable outcome
- Goal 2: Expected impact
- Goal 3: Success criteria

### Target Users
- Primary: Who will use this feature?
- Secondary: Who else benefits?

## Functional Requirements

### FR-1: [Requirement Title]
**Priority**: High | Medium | Low  
**Status**: Not Started | In Progress | Completed

**Description**: Clear description of what the system must do.

**Acceptance Criteria**:
- [ ] Criterion 1 - Specific, measurable condition
- [ ] Criterion 2 - Testable outcome
- [ ] Criterion 3 - Observable behavior

**Business Rules**:
1. Rule 1: Specific constraint or logic
2. Rule 2: Validation requirement
3. Rule 3: Processing rule

**Example Scenarios**:
```
Given [initial context]
When [action is taken]
Then [expected outcome]
```

---

### FR-2: [Requirement Title]
*(Repeat structure above for each functional requirement)*

## Non-Functional Requirements

### Performance
- **Response Time**: Target latency (e.g., < 200ms p95)
- **Throughput**: Expected load (e.g., 1000 requests/sec)
- **Scalability**: Growth expectations

### Reliability
- **Availability**: Uptime target (e.g., 99.9%)
- **Error Rate**: Acceptable failure rate (e.g., < 0.1%)
- **Recovery**: RTO/RPO targets

### Security
- **Authentication**: Required authentication method
- **Authorization**: Access control requirements
- **Data Protection**: Encryption, PII handling

### Maintainability
- **Logging**: What needs to be logged
- **Monitoring**: Key metrics to track
- **Testing**: Coverage requirements

### Compliance
- List any regulatory or compliance requirements
- Data retention policies
- Audit requirements

## User Stories

### US-1: [User Story Title]
**As a** [type of user]  
**I want** [goal/desire]  
**So that** [benefit/value]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

---

### US-2: [User Story Title]
*(Repeat for additional user stories)*

## Data Requirements

### Data Model
Describe key data entities and relationships:
- **Entity 1**: Fields, validations, relationships
- **Entity 2**: Data structure, constraints

### Data Sources
- Source 1: Where data comes from, format
- Source 2: Integration points

### Data Volume
- Expected data volume per day/month
- Growth projections
- Retention requirements

## Integration Requirements

### Upstream Dependencies
| System | Interface | Data | SLA |
|--------|-----------|------|-----|
| System A | Message Broker | Events | Real-time |
| System B | REST API | User Data | < 100ms |

### Downstream Consumers
| System | Interface | Data | SLA |
|--------|-----------|------|-----|
| System C | Message Broker | Notifications | Async |
| System D | Webhook | Alerts | < 5min |

## UI/UX Requirements

*(If applicable)*

### Wireframes
[Link to wireframes or embed images]

### User Flows
[Link to user flow diagrams]

### Accessibility
- WCAG compliance level
- Keyboard navigation requirements
- Screen reader support

## Implementation Phases

> Skip this section if FR ≤ 3 with linear dependencies — apply depth rules directly.
> See `sdlc_workflow.md` "Phase Planning" for when and how to slice.

### FR → Phase Mapping

| FR | Description | Phase |
|---|---|---|
| FR-1 | [Requirement title] | Phase 1 |
| FR-2 | [Requirement title] | Phase 1 |
| FR-N | [Requirement title] | Phase 2 |

### Phase 1: [Phase Name]（[FR list]）

**Goal**: [One sentence — what is independently deployable after this phase]
**Backward Compatibility**: [Does this change existing behavior? Feature flag?]
**Rollback Plan**: [How to undo if problems arise]

| Step | Name | What to do | Acceptance |
|---|---|---|---|
| 1 | Core Behavior | [scope] | [how to verify] |
| 2 | Integration | [scope] | [how to verify] |
| 3 | Resilience | [scope] | [how to verify] |
| 4 | Observability | [scope] | [how to verify] |

### Phase 2: [Phase Name]（[FR list]）

**Goal**: [One sentence]
**Prerequisites**: [Which phase(s) must be complete]
**Backward Compatibility**: [Statement]
**Rollback Plan**: [Strategy]

*(Repeat depth steps table)*

---

## Out of Scope

Explicitly list what is NOT included in this feature:
- Item 1: What we're not doing and why
- Item 2: Future consideration
- Item 3: Alternative approach not chosen

## Constraints & Assumptions

### Technical Constraints
- Constraint 1: Technology limitation
- Constraint 2: Infrastructure limitation

### Business Constraints
- Budget limitations
- Timeline constraints
- Resource availability

### Assumptions
- Assumption 1: What we're assuming is true
- Assumption 2: Dependencies we expect to be met

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Risk 1 | High/Med/Low | High/Med/Low | How to mitigate |
| Risk 2 | High/Med/Low | High/Med/Low | Mitigation strategy |

## Success Metrics

### Key Performance Indicators (KPIs)
- **Metric 1**: Target value, measurement method
- **Metric 2**: Baseline, goal, tracking
- **Metric 3**: Success criteria

### Monitoring & Reporting
- Dashboard requirements
- Report frequency
- Alert thresholds

## Dependencies

### Technical Dependencies
- [ ] Dependency 1: What needs to be ready before we can start
- [ ] Dependency 2: External system availability

### Process Dependencies
- [ ] Design approval needed by [date]
- [ ] Security review required
- [ ] Legal/compliance sign-off

## Timeline

| Phase | Deliverable | Target Date | Owner |
|-------|-------------|-------------|-------|
| Analysis | Requirements finalized | YYYY-MM-DD | [Name] |
| Design | Design document | YYYY-MM-DD | [Name] |
| Development | Feature complete | YYYY-MM-DD | [Name] |
| Testing | QA sign-off | YYYY-MM-DD | [Name] |
| Deployment | Production release | YYYY-MM-DD | [Name] |

## References

- [Related Requirements Document](link)
- [Design Document](link)
- [API Specifications](link)
- [External Resources](link)

## Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | | | |
| Tech Lead | | | |
| Business Stakeholder | | | |

## Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| YYYY-MM-DD | 1.0 | Initial draft | [Name] |
| YYYY-MM-DD | 1.1 | Added FR-3 | [Name] |

---

**Template Version**: 1.0  
**Last Updated**: 2025-11-26
