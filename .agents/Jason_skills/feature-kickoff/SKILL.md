---
name: feature-kickoff
description: >
  Full feature kickoff SOP. Use when user requests a new feature, enhancement, requirement, or any
  multi-file change. Enforces systematic context gathering, code-verified requirement analysis,
  feature folder scaffolding, and plan presentation before any implementation edits.
  Keywords: new feature, add feature, implement, requirement, enhancement, refactor, we need.
---

# Skill: Feature Kickoff & Analysis Planning

**Purpose**: Ensure every feature starts with verified facts, a clear plan, and explicit user approval — before any implementation file is touched.

> **Project-specific details** (build commands, verification commands, naming conventions) come from `copilot-instructions.md`, which is always in context.

---

## Execution Trigger

Activate this skill automatically when the user:
- Requests a new feature or enhancement ("add X", "implement Y", "we need Z")
- Provides a requirement or specification to implement
- Asks for a refactor that spans more than 1 file
- Says something like "start working on feature N"

---

## Procedural Steps

### Step 1 — Parse the Request
Extract from the user's message:
- **Feature name / slug** (for folder naming, e.g., `user-session-metrics`)
- **Affected areas** (which pages, controllers, APIs, or layers are involved)
- **Scope signal** (small tweak vs. multi-layer change)

---

### Step 2 — Context Discovery
Search the codebase to understand the current state. Use project-appropriate search commands:

- Find affected source files (pages, components, controllers)
- Find API route definitions
- Find service interfaces and data contracts
- Find relevant data models / DTOs

> **Refer to `copilot-instructions.md`** for project-specific search commands and directory conventions.

Run searches in parallel when possible.

---

### Step 3 — Code Verification Checklist (MANDATORY)

**Every factual claim must be verified against source code before presenting the plan.**
For each claimed fact, record the source file + line number.

| Fact Type | How to Verify | Required Evidence |
|---|---|---|
| File exists | Search project for filename | Absolute path confirmed |
| API route | Grep controller/router for route attributes | `FileName:LineNumber` |
| Page/component calls endpoint | Grep source for API URL patterns | `FileName:LineNumber` |
| Component name | Read source constant or config | Exact string from code |
| Data model & properties | Read actual class/interface definition | Class name + key properties |

**Red Flags — stop and verify before proceeding:**
- ❌ Documentation says one thing, code shows another
- ❌ Any assumption not backed by a code line number
- ❌ Names translated/guessed instead of read from source
- ❌ Route strings copied from docs without confirming in code

---

### Step 4 — Determine Feature Sequence Number
```bash
ls spec/features/ | sort
```
Take the next available 3-digit number (e.g., if `004-security-fix` exists, next is `005`).

---

### Step 5 — Scaffold Feature Folder
Create the feature folder and seed it with populated templates:

```
spec/features/NNN-{slug}/
├── README.md                  ← from feature-readme-template.md
├── FEAT-NNN-requirements.md   ← from requirements-template.md
└── PHASE-{N}-PROGRESS.md      ← created later when implementation starts (from phase-progress-template.md)
```

> **Note**: `PHASE-{N}-PROGRESS.md` is NOT created during kickoff — it is created when implementation begins for that phase. One file per phase.

Populate with what is already known from Steps 1–3. Leave placeholders for decisions still pending.

After creating the files, **set the initial status in `README.md`**:
- Set `Status` = 🟡 Planning
- Set `Updated` = today's date

---

### Step 6 — Draft Implementation Plan
Structure the plan as:

```markdown
## Context Found
- [Files discovered with paths]
- [Existing patterns in use (with file:line citations)]
- [Current API routes & data models confirmed]

## Proposed Implementation
- [Files to modify — with rationale]
- [Files to create — with rationale]
- [Approach and architectural pattern to follow]

## Phase Analysis (if FR > 3 or dependency graph branches)
- [FR dependency graph — which FRs depend on which]
- [Proposed phase split — which FRs group into each phase]
- [Per phase: goal, backward compatibility, rollback plan]
- [If FR ≤ 3 and linear: state "Single phase — depth rules apply directly"]

## Schema / Data Model Changes (if applicable)
- [Database/schema changes needed]
- [Alternatives considered]
- [Migration strategy]

## Questions / Decisions Needed
- [Options for user to choose]
- [Trade-offs to resolve before coding]

## Verification Plan
- [Build command for the project]
- [Functional test steps]
- [Expected outputs]
```

---

### Step 7 — Present Plan & Wait for Approval

Present the plan to the user. **Do NOT edit any implementation file until the user explicitly approves.**

State clearly:
- What IS in scope for this plan
- What is NOT in scope (deferred to later phases)
- Any open questions that need answers before coding starts

---

## Rules

- ❌ **NEVER** edit implementation files before approval
- ❌ **NEVER** state a fact (file path, route, component name, data model) without code evidence
- ❌ **NEVER** guess or translate names — always read from source
- ✅ Present the scaffolded feature folder path as part of the plan output
- ✅ If user provides `[JUST DO IT]` or `[SKIP CLARIFY]`, proceed directly to implementation but still run verification checks silently

---

## Output Checklist (Before Presenting Plan)

- [ ] Feature folder `spec/features/NNN-{slug}/` created
- [ ] `README.md` Status = 🟡 Planning, Updated = today
- [ ] Every file path cited exists (confirmed by file search)
- [ ] Every API route cited matches an actual code attribute
- [ ] Every component/page name is from source code, not guessed
- [ ] At least one verification command included in the plan
- [ ] Scope boundary stated (what is NOT being implemented now)
