# AI-Assisted Development Workflow

**Foundational principles for human–AI collaborative development. Generic and reusable — can be copied to any project.**

> **Enforcement**: These principles are operationalized by Copilot Skills in `skills/`:
> - Feature kickoff & requirements → `skills/feature-kickoff/`
> - Build verification & completion → `skills/implementation-completion/`
> - Bug investigation & diagnosis → `skills/debug-investigation/`
> - Progress tracking & document sync → `skills/status/`
>
> **Agents** in `.github/agents/` provide specialized modes (e.g., `High-Level-Big-Picture-Architect` for architectural analysis and diagram generation before implementation begins).

---

## Core Principles

### 1. Clarify Before Coding (Default Workflow)
- **ALWAYS present implementation plan** before making file edits
- Gather context first: search code, read schema, understand patterns
- Present: what was found, proposed changes, alternatives, questions
- Wait for **explicit approval** before editing files
- Exception: Simple no-risk changes (reading code, obvious bug fixes, comments/logs)
- **Agents accelerate this**: Use `High-Level-Big-Picture-Architect` for architectural analysis, diagrams, and failure mode identification before any code planning begins

### 2. Incremental Delivery Over Complete Solutions
- Deliver **smallest verifiable unit** first
- Each iteration must be **independently testable**
- Defer production patterns until core functionality verified

### 3. Explicit Over Implicit
- **Never assume context exists** - Ask about missing pieces
- State what will **NOT** be implemented in each phase
- Declare system boundaries clearly

### 4. Verification First
- Code must be **runnable/testable immediately**
- Include **exact verification commands**
- Provide **sample test data** that works

### 5. Separate "Now" from "Later"
- Implement **minimal working version** now
- Document **deferred work** in spec files as Phase ⬜ items or FR with ⬜ status
- Keep future phases visible but don't implement them until current phase is verified

### 6. Schema/Data Model Changes Require Checkpoint
- **STOP and present proposal** before implementing database schema changes
- Include SQL/schema definitions with alternatives
- Wait for **explicit approval** before generating code
- Schema changes are expensive - get them right first

---

## Phase Planning — Slicing Features Into Deliverable Units

> **Why this matters**: Depth Rules (below) tell you how deep to go within a single module. But they assume you already know *which FRs to tackle together*. When a feature has many FRs with a branching dependency graph, implementing everything at once makes verification impossible and rollback risky.

### When to slice

| Situation | Action |
|---|---|
| FR ≤ 3, linear dependency chain | Skip phase planning — apply depth rules directly |
| FR > 3 **or** dependency graph has branches | Analyse FR dependencies → cut into **Engineering Phases** |

### How to slice

1. **Draw the FR dependency graph** — which FRs depend on which.
2. **Identify natural cut points** — groups of FRs that can be deployed independently.
3. **Each phase must be**:
   - **Independently deployable** — the system works (possibly with reduced scope) after this phase alone.
   - **Backward compatible** — does not break existing behavior. If it changes existing behavior, a feature flag gates it.
   - **Independently verifiable** — has its own acceptance criteria and test steps.
4. **Document per phase**:目標 (goal), FR mapping, backward compatibility statement, rollback plan.
5. **Apply depth rules (4 steps) within each phase**, not across all FRs at once.

### Where to document

- **`FEAT-NNN-requirements.md`** — "Implementation Phases" section with FR → Phase mapping table and per-phase detail.
- **`README.md`** — Phase field in header table tracks current active phase.
- **`BACKLOG.md`** — Any deferred phase gets a row here.
- **`PHASE-{N}-PROGRESS.md`** — Created when implementation starts for a phase. Tracks per-step progress (files created/modified, build/test results, decisions). Updated after each step passes build + tests. Survives session boundaries so progress is never lost. Template: `spec/_templates/FEATURES/phase-progress-template.md`.

### Example

```
FR-1 ──┐
FR-2 ──┼──→ Phase 1: DDL Pipeline (deployable alone, no data path changes)
FR-3 ──┤
FR-6 ──┘

FR-4 ──┐
FR-5 ──┼──→ Phase 2: Dynamic Data Path (depends on Phase 1's schema cache)
FR-7 ──┤
FR-8 ──┘
```

Phase 1 ships, gets validated in SIT. Phase 2 starts only after Phase 1 is stable.

---

## Implementation Depth — Incremental Delivery Within Each Phase

> **Why this matters**: Without this constraint, AI will produce production-level code across many files in one shot — retry queues, circuit breakers, metrics, full error handling — making it impossible to verify even the basic functionality works.

### Principle: Deliver the Smallest Verifiable Unit at Each Step

Within any feature phase (e.g., "Phase 2: Debezium Kafka Signal Producer"), implementation follows this progression:

### Before Step 1 — Create Phase Progress Document
When starting implementation for a phase, create `spec/features/NNN-{slug}/PHASE-{N}-PROGRESS.md` from `spec/_templates/FEATURES/phase-progress-template.md`. This document is updated after each step passes build + test verification.

### Step 1 — Core Behavior (Observable)
- Implement the **single core action** (e.g., produce a Kafka message)
- Must be **independently verifiable** (e.g., see the message in Kafka topic)
- ✅ Hardcoded values in a dedicated config class are OK
- ✅ Structured logging to confirm behavior
- ❌ No error handling beyond log-and-continue
- ❌ No integration with upstream/downstream yet

### Step 2 — Integration (Connected)
- Wire into the actual call site (e.g., inject into handler failure path)
- Verify **end-to-end** trigger works (e.g., merge failure → signal produced)
- ✅ Real configuration from config files
- ✅ DI registration
- ❌ No defensive coding for edge cases yet

### Step 3 — Resilience (Hardened)
- Add error handling for the integration boundary
- Handle failures gracefully (e.g., signal produce failure → log, don't crash)
- ✅ Validation at system boundaries
- ✅ Fallback for external dependency failure

### Step 4 — Observability (Monitored)
- Prometheus counters, NLog alerts, dashboard config
- Only after core + integration + resilience are verified

> **Rule**: Each step must be **approved and verified** before proceeding to the next. Never combine steps.
>
> **Rule**: After each step passes build + tests, update `PHASE-{N}-PROGRESS.md` with files created/modified, verification results, and any decisions made. This is mandatory — it ensures progress survives session boundaries.

---

## Error Handling Depth

Error handling follows the same incremental depth — start minimal, add layers after verifying core behavior:

| Step | Error Handling | Example |
|------|---------------|---------|
| Step 1 (Observable) | `try/catch → log → continue` | Signal produce fails → log error, return |
| Step 2 (Connected) | + propagation decisions | Signal fails → should handler still return `true`? |
| Step 3 (Hardened) | + typed exceptions, fallbacks | Kafka unreachable → fallback to log-only mode |
| Step 4 (Monitored) | + metrics, alerts | `bqproxy_cdc_signal_error_total` counter |

> For **project-specific** error handling patterns (middleware, exception types), refer to `copilot-instructions.md`.

---

## Deferred Work Tracking

Work that exists in the plan but isn't being implemented now is tracked in **spec documents**, not in code comments:

| Mechanism | Where | Example |
|-----------|-------|---------|
| Phase ⬜ status | `FEAT-NNN-requirements.md` | `### Phase 3: Monitoring & Alerting ⬜` |
| FR/NFR ⬜ status | Requirements table | `FR-08 \| Prometheus counter \| Should \| ⬜` |
| TBD ❓ | Questions section | `TBD-5 ❓: Delete events — handle or ignore?` |
| AD ❓ | Architecture Decisions | `AD-6: Delete Events ❓` |

Avoid `// TODO-PRODUCTION:` comments in code — they drift and get ignored. Spec documents are the single source of truth for what's deferred.

---

## Common Patterns to Follow

### Always Use These Patterns
1. **Dependency Injection**: Inject all dependencies via constructor
2. **Async/Await**: All I/O operations async
3. **Structured Logging**: Use parameter placeholders in log statements
4. **Configuration**: Use config files, not hardcoding
5. **Single Responsibility**: One class = one reason to change

> For **project-specific** patterns (naming, indentation, logging, global usings), refer to `copilot-instructions.md`.

### Defer These Until the Right Step
1. **Retry Logic**: Step 3 (Resilience) — after core + integration verified
2. **Circuit Breakers**: Only when a real availability problem is observed
3. **Comprehensive Validation**: Step 3 — start with null checks in Step 2
4. **Unit Tests**: After the implementation is stable
5. **Performance Optimization**: Make it work first, optimize later

---

## Quick Reference

### Before Any Implementation
1. ✅ Architectural analysis (HLBPA agent or equivalent) — diagrams, failure modes, TBDs
2. ✅ Feature kickoff — spec files scaffolded, requirements documented with phases
3. ✅ Spec approved — ADs decided, TBDs resolved for current phase
4. ✅ Then implement **one step at a time** within the phase

### Readability Checklist (Always Verify):
- [ ] Each component has ONE clear responsibility
- [ ] Interfaces are focused (no bloated interfaces)
- [ ] Main orchestrator is separate from implementations
- [ ] Logging uses structured parameters
- [ ] All dependencies are injected
- [ ] No component exceeds ~250 lines
- [ ] Naming is clear and self-documenting

### What to Avoid:
- ❌ Assuming context exists — search code first
- ❌ Creating monolithic god classes (900-line classes)
- ❌ Mixing business logic with persistence
- ❌ Hardcoding configuration values
- ❌ Implicit dependencies (tight coupling)
- ❌ Implementing multiple steps in one delivery
- ❌ Adding abstractions prematurely
- ❌ Implementing patterns not in the current phase scope
- ❌ Coding without verification steps

### Remember:
> **Smallest verifiable unit** > Complete solution
> **Spec files** > Code comments for tracking deferred work
> **Readable, focused components** > Monolithic convenience

---

## Example: Monolith ❌ vs. Focused Components ✅

### ❌ ANTI-PATTERN - Monolithic Implementation (900 lines)
```
// PROBLEM: Single class doing everything
class DataProcessor
    - Fetch data from API (200 lines)
    - Transform and enrich (200 lines)
    - Detect anomalies (200 lines)
    - Create incidents (150 lines)
    - Send notifications (150 lines)

Issues:
- Hard to test individual concerns
- Hard to reuse transformation logic elsewhere
- Hard to understand (900 lines!)
- One change breaks multiple concerns
- Violates Single Responsibility Principle
```

### ✅ PATTERN - Focused Components
```
// Interfaces (consolidated, organized)
interface DataFetcher: fetch(source) → data
interface DataTransformer: transform(data) → enriched_data
interface AnomalyDetector: detect(data) → boolean
interface IncidentCreator: create(data) → incident
interface NotificationSender: send(incident) → void

// Implementations (each ~100-150 lines)
class APIDataFetcher(config): DataFetcher
  - ONLY fetches from API
  - Handles API retries/errors
  
class DataTransformer(rules): DataTransformer
  - ONLY transforms data
  - Pure logic, no side effects
  
class StatisticalAnomalyDetector(threshold): AnomalyDetector
  - ONLY detects anomalies
  - Returns boolean
  
class IncidentCreator(repo): IncidentCreator
  - ONLY persists incidents
  - Database operations
  
// Orchestrator (clear data flow, ~80 lines)
class DataProcessingOrchestrator
    def process(source):
        data = fetcher.fetch(source)              // Step 1: Fetch
        enriched = transformer.transform(data)    // Step 2: Transform
        if detector.detect(enriched):             // Step 3: Detect
            incident = creator.create(enriched)   // Step 4: Create
            sender.send(incident)                 // Step 5: Notify
```

**Benefits:**
- ✅ Each component testable independently
- ✅ Easy to understand each responsibility
- ✅ Reusable components
- ✅ Changes to one concern don't affect others
- ✅ Clear data flow visible in orchestrator
- ✅ Highly readable and maintainable
- ✅ Respects Single Responsibility Principle
- ✅ Supports Dependency Inversion Principle

---

## Read Before Writing (Mandatory)

**Critical Practice**: When implementing new code that should follow existing patterns, always examine working examples in the codebase first. Never assume:
- Data structure paths (e.g., `data.property` vs `data.summary.property`)
- Naming conventions for similar functionality
- Response object hierarchies
- Variable scoping and assignment patterns

**Why**: The answer is almost always already in the codebase — you just need to find the existing working code first.

**Investigation Pattern**:
1. Search for existing code using the same data source or similar feature
2. Grep for related field names to find working access patterns
3. Read the working code in full context
4. Apply the exact same pattern to new code

> The cheapest bug to fix is the one you never introduce. Reading first prevents assumption-based errors.

---

## Requirements Realignment — Handling Mid-Implementation Changes

> **Operationalized by**: `skills/requirements-realignment/`

Implementation often reveals that design assumptions were wrong, scope needs to shift, or a new requirement emerges. When this happens, **all planning documents must be updated before continuing to code**.

### The Pattern

```
Implementation reveals problem → Discuss options → User selects approach
    → 1) Update requirements doc (WHAT to build)
    → 2) Update progress/plan doc (HOW we're tracking it)
    → 3) Add Realignment Log entry (WHY the plan changed)
    → 4) Resume implementation
```

### When to Trigger

- A new FR is needed that wasn't in the original requirements
- User selects a different approach than originally planned
- An architectural decision changes the scope of existing FRs
- Implementation testing reveals a design gap

### Rules

- **Both** requirements doc and progress doc must be updated — updating only one creates split-brain
- A **Realignment Log** entry in `PHASE-N-PROGRESS.md` preserves the audit trail
- Never continue coding on stale plans — the cost of a 5-minute doc update is far less than implementing the wrong thing

### Realignment Log Format

```markdown
| Date | Trigger | Changes |
|---|---|---|
| YYYY-MM-DD | [What caused the change] | [Summary of doc updates] |
```

---

## Build Verification Before Delivery (Mandatory)

**CRITICAL**: Code is NOT complete until it compiles/builds successfully. Before claiming a task is done:

1. Run the project's build command on affected project(s)
2. Verify **0 compilation errors** (warnings are acceptable)
3. Confirm build completes successfully

**Verification Checklist**:
- ✅ Run build on affected project(s)
- ✅ Verify **0 errors** (warnings acceptable)
- ✅ Confirm build succeeds
- ❌ NEVER claim code is complete if build fails
- ❌ NEVER tell user "code is ready" without verifying compilation

**Delivery Status Reference**:

| Build State | Action |
|---|---|
| ✅ 0 errors | Create completion report → Deliver |
| ⚠️ 0 errors, N warnings | Deliver, note warnings |
| 🔴 N errors | Fix first → Re-build → Do not deliver |

**Good Completion Message**:
```
✅ Code implementation complete. Verified:
- Build succeeded — 0 errors, N warnings
- [N] files modified
- Ready for code review and testing
```

**Bad Completion Messages** (never do these):
```
✗ I've implemented the changes.                    ← No build verification
✗ The code should compile correctly.               ← Assumption, not evidence
✗ Ready to test (the logic looks right to me).     ← No build run = not ready
```

---

## Documentation Accuracy Rules (Mandatory)

**Principle**: Documentation must reflect reality. Inaccurate docs are worse than no docs.

### Verify Against Code, Not Memory
- ❌ **NEVER** make up or guess names, routes, or class names
- ✅ **ALWAYS** read the actual source code to confirm facts
- ✅ **ALWAYS** cite file + line number for every factual claim

### Truth Source Rule

| Information Type | Truth Source | DON'T Use |
|---|---|---|
| Page/component names | Source code constants or config | Translation, guessing |
| API routes | Controller/router attributes in code | Memory, similar patterns |
| Class/type names | Actual class definitions | API docs (may be stale) |
| Data structure | Actual model/DAO definitions | Sample responses |
| Navigation/menus | Layout/template files | User descriptions |

### When in Doubt
1. Read the source code first
2. Search for exact strings
3. Ask the user if still unclear
4. **NEVER make up information**

### Requirement Verification
Every factual claim in a requirement must be code-verified before implementation:
- ✅ File existence: Verify referenced files actually exist
- ✅ Routes/endpoints: Verify they match actual code attributes (cite file:line)
- ✅ Data sources: Verify what a page/component actually calls (search the source)
- ✅ Names: Read from source constants, never translate or guess

> **Golden Rule**: If you cannot cite the source file and line number for a factual claim, treat it as an assumption, not a fact.

---

## Implementation Completion Reports (ICR)

### Purpose
A structured artifact created at the end of a multi-phase feature implementation:
- **Final checkpoint**: Verify all code is complete and builds cleanly
- **Deployment guide**: Checklist for review, testing, and rollout
- **Handoff document**: Clear status for QA, product, and ops teams
- **Historical record**: Documents decisions, trade-offs, and lessons learned

### When to Create
- ✅ Multi-phase implementations (4+ files or multiple layers)
- ✅ Architecture decisions were made (Option A selected over B/C)
- ✅ Build verified with 0 errors
- ✅ End of feature development (before testing/staging)

### Required Sections
```markdown
# Feature: {Name} - Implementation Completion Report

**Date**: YYYY-MM-DD
**Status**: ✅ CODE COMPLETE & VERIFIED COMPILABLE
**Build**: 0 compilation errors

## Executive Summary
- What was implemented (2-3 sentences)
- Key decision and rationale

## Implementation Phases
### Phase N: {Layer/Component Name}
- Files modified/created
- What changed
- Status: ✅ Complete

## Files Modified Summary
| File | Purpose | Status |

## Build Verification
- Command run and output

## Testing Recommendations
- How to validate each phase

## Known Limitations & Trade-offs

## Deployment Checklist
- Pre/during/post deployment steps

## Summary Statistics
- Files modified, errors: 0, breaking changes: 0
```

### Location Convention
Store in your project's feature documentation folder, e.g.:
`spec/features/{ID}-{name}/IMPLEMENTATION_COMPLETION_REPORT.md`

---

## Documentation Hygiene (Mandatory)

### Production vs Working Documents

**Production Documents** (actively used, live in a known location like `.github/`):
- Coding guidelines, architecture knowledge, agent/skill definitions
- Only modify with intention — these are referenced daily

**Working/Analysis Documents** (temporary, created during conversations):
- Investigation notes, planning drafts, consolidation maps
- **RULE**: Store in ONE organized archive location, not scattered across the workspace
- **Naming**: Use date + topic: `2025-12-10-consolidation-docs/`
- Never put temporary analysis docs alongside production docs

### Rules
- ❌ Don't create multiple summary/guide/reference docs without explicit request
- ❌ Don't scatter working docs across `.github/`, workspace root, or random folders
- ✅ Keep production docs in their designated folder
- ✅ Archive working docs in a single `_archive/` location with clear naming
- ✅ Ask user before creating new documentation files

---

**Last Updated**: 2026-03-17
**Usage**: Copy this file to new projects as baseline coding philosophy
