---
name: requirements-realignment
description: >
  Requirements realignment SOP. Triggered when implementation reveals that existing requirements
  or plans need adjustment — a new FR is needed, a design assumption changed, scope shifted, or
  an approach was replaced. Enforces structured document sync before continuing implementation:
  update requirements doc → update progress/plan doc → add realignment log entry → resume coding.
  Keywords: requirements changed, scope change, new requirement, design changed, approach changed,
  plan changed, need to update requirements, realignment, re-plan.
---

# Skill: Requirements Realignment

**Purpose**: When implementation reveals that requirements or plans need adjustment, ensure all planning documents are updated **before** continuing to code. Prevents stale docs from causing downstream confusion, missed scope, or incorrect implementation.

> **Project-specific details** (spec directory, feature folder conventions, build commands) come from `copilot-instructions.md`, which is always in context.

---

## Execution Trigger

Activate this skill when:
- Implementation reveals a design assumption was wrong or incomplete
- User selects a new approach / alternative solution during implementation
- A new FR is needed that wasn't in the original requirements
- Scope of an existing FR changes materially (new acceptance criteria, different behavior)
- An architectural decision (AD/Q) is made that changes the plan
- User says "update the requirements", "the plan changed", "we need to adjust scope"
- Agent detects that code changes no longer match the documented plan

---

## Core Principle

```
Implementation reveals problem → Discuss options → User selects approach
    → 1) Update requirements doc (WHAT to build)
    → 2) Update progress/plan doc (HOW we're tracking it)
    → 3) Resume implementation
```

**Both (1) and (2) must be completed before resuming implementation.** Updating only one creates a split-brain where requirements say one thing and the progress tracker says another.

---

## Procedural Steps

### Step 1 — Identify What Changed

Summarize the delta concisely:

| Question | Answer |
|---|---|
| What triggered the change? | (e.g., "runtime testing revealed schema topic only had registered tables") |
| What was the old assumption? | (e.g., "schema topic only needs tables with active handlers") |
| What is the new decision? | (e.g., "schema topic must cover all MySQL tables for future handler onboarding") |
| Which FRs are affected? | (e.g., "new FR-9 added; FR-6 payload format changed") |
| Which documents need updating? | (always: requirements doc + progress doc; optionally: README, BACKLOG) |

---

### Step 2 — Update Requirements Document

Open the feature's requirements document (e.g., `FEAT-NNN-requirements.md`) and apply changes:

| Change Type | Where to Update |
|---|---|
| New FR | Add FR section with full AC, priority, description |
| Modified FR | Update existing FR's AC, description, or scope |
| New Decision (Q/AD) | Add row to Decisions table with rationale |
| Architecture / data flow change | Update diagrams and flow descriptions |
| Phase mapping change | Update FR→Phase mapping table |
| Payload / schema change | Update message format / data model sections |

**Update the `Updated` date** in the document header.

---

### Step 3 — Update Progress / Plan Document

Open the phase progress document (e.g., `PHASE-N-PROGRESS.md`) and apply changes:

| Change Type | Where to Update |
|---|---|
| New FR in scope | Add to FR Scope table (with ⬜ status) |
| New step needed | Insert step (e.g., Step 3a) with planned scope |
| Existing step scope changed | Update the step's planned or completed description |
| Observability / metrics changed | Update Step 4 planned scope |
| Rollback plan affected | Update Rollback Plan section |

**Update the `Updated` date** in the document header.

---

### Step 4 — Add Realignment Log Entry

Append to the **Realignment Log** section in the progress document. Create the section if it doesn't exist.

Format:

```markdown
## Realignment Log

| Date | Trigger | Changes |
|---|---|---|
| YYYY-MM-DD | [What caused the change] | [Summary of doc updates made] |
```

This creates an audit trail of why the plan evolved, which is invaluable for retrospectives and onboarding.

---

### Step 5 — Present Summary to User

Before resuming implementation, present a concise delta summary:

```markdown
**Realignment complete.** Updated:
- Requirements doc: [list of changes]
- Progress doc: [list of changes]
- Realignment log: [entry added]

Ready to continue with [next step/FR].
```

---

## Rules

- ❌ **NEVER** continue implementing after a scope/design change without updating docs first
- ❌ **NEVER** update only the requirements doc — progress doc must also be synced
- ❌ **NEVER** update only the progress doc — requirements doc is the source of truth for WHAT
- ✅ Both docs updated = safe to resume coding
- ✅ Realignment log entry = audit trail preserved
- ✅ If user says `[SKIP DOCS]`, note the debt explicitly in a comment but still create the realignment log entry

---

## Anti-Patterns

| Anti-Pattern | Why It's Bad | Correct Action |
|---|---|---|
| "I'll update docs later" | Docs drift; next session has stale context | Update now, before next code edit |
| Update requirements but not progress | Progress tracker shows wrong scope/steps | Always update both |
| Update progress but not requirements | Requirements doc becomes outdated for new readers | Always update both |
| No realignment log | No audit trail of why the plan changed | Always add log entry |
| Implement first, document later | Risk of building on stale assumptions | Docs first, code second |

---

## Output Checklist

Before resuming implementation after a realignment:

- [ ] Requirements doc updated with new/changed FRs, decisions, or architecture
- [ ] Requirements doc `Updated` date is today
- [ ] Progress doc updated with new/changed FR scope, steps, or rollback plan
- [ ] Progress doc `Updated` date is today
- [ ] Realignment Log entry added with date, trigger, and changes
- [ ] User presented with delta summary
- [ ] Ready to resume implementation
