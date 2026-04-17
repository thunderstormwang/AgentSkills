---
name: debug-investigation
description: >
  Collaborative debugging SOP. Triggered when user reports a bug, error, unexpected behavior,
  or broken functionality. Enforces structured diagnosis before any code change: present
  diagnosis block → propose fix with risk → wait for explicit approval → apply → verify.
  Keywords: bug, error, broken, not working, wrong data, exception, failing, issue, problem.
---

# Skill: Debug Investigation

**Purpose**: Ensure every bug fix starts with a structured, evidence-based diagnosis and explicit user approval — preventing blind code changes that introduce new problems.

> **Project-specific details** (log paths, build commands, directory conventions) come from `copilot-instructions.md`, which is always in context.

---

## Execution Trigger

Activate this skill when the user:
- Reports a bug, error, or exception
- Says something is "not working", "broken", "wrong", or "unexpected"
- Pastes an error message, stack trace, or log output
- Reports data that looks incorrect
- Asks "why is X happening?"

---



## Procedural Steps

### Step 1 — Gather Evidence First
Before forming any hypothesis, collect:

- Check recent logs (use project-specific log location from `copilot-instructions.md`)
- Find the relevant source files
- Read the specific area of code mentioned in the error

Read the relevant source files. Understand what the code is supposed to do before diagnosing what it is doing wrong.

---
### Step 1 — Gather Evidence First (exhaustive project scan)
Before forming any hypothesis, run an exhaustive, project-wide evidence collection so the investigation covers every related code path and integration point. At minimum, complete the checklist below and record every inspected file/path in the `INVESTIGATION_REPORT.md`.

- Logs & reproduction
  - Tail recent logs: `tail -n 500 [LOG_PATH]` and grep for error/exception terms.
  - Capture exact reproduction steps, request payloads, timestamps, and any environment variables.

- Project-wide code search (use these commands from repo root)
  - Search controllers/routes: `rg --line-number "\[Route|Controller" src/`
  - Search MediatR handlers and CQRS: `rg --line-number "IRequestHandler|Handler" src/`
  - Search integration events & topics: `rg --line-number "IntegrationEvent|PXB2C.Cdc|CreateTopicOption" src/`
  - Search Kafka/consumer/publisher points: `rg --line-number "Kafka|SubscribeCdc|AddKafka|EventBus" src/`
  - Search BigQuery and merge logic: `rg --line-number "BigQueryWrapper|MergeRowsAsync|MERGE" src/`
  - Search data models / DTOs / EF Core: `rg --line-number "class .*Model|DbSet<|EntityTypeBuilder" src/`
  - Search config & appsettings: `rg --line-number "MySqlConnection|BigQuerySettings|KafkaSetting|CentralControl" src/` and inspect `Program.cs`.
  - Search for exception handling & logging calls: `rg --line-number "Log(Error|Warning|Information)" src/`
  - Search tests: `rg --line-number "\b[Test|Fact|Theory]\b" || true`

- Call-graph / usage checks for affected symbols
  - Given an affected symbol (method/class/property), run `rg --line-number "<SymbolName>"` to find all callers and related files.
  - Record the set of callers and the chain (caller → callee) in the report.

- Infrastructure & deployment files
  - Inspect `Program.cs` DI wiring and `AddKafka()` registrations.
  - Check `src/*/Dockerfile`, `appsettings*.json`, `nlog.*.config`, and any k8s manifests if present.

- Data / persistence
  - Find DB schema mappings and migrations (EF Core migrations or SQL files). `rg --line-number "Migration|HasColumnType|ToTable\(" src/`
  - Confirm whether the failing flow touches BigQuery, MySQL, or Redis; inspect the integration wrapper code.

- Runtime & environment checks
  - Confirm environment variables, connection strings, and feature flags used by the failing environment.

- Quick sanity tests
  - Build the solution locally: `dotnet build PXBox.BQProxy.Service.sln` and capture errors.
  - Run targeted unit/integration tests that cover the failing area if available.

Checklist rules
- For every file or symbol inspected, add a one-line note to `INVESTIGATION_REPORT.md` (path:reason:quick-find). Example: `src/PXBox.BQProxy.Infrastructure/BigQueryWrapper.cs:checked MergeRowsAsync handling of deletes`.
- Do not assume a single file; follow callers and DI wiring until you reach the root integration points (Kafka consumer, BigQuery wrapper, DB context, external APIs).
- If the failing behavior spans multiple services (e.g., Kafka → handler → BigQuery), list the full trace: `topic -> handler -> wrapper -> BigQuery table`.

---

## Mode Selection (重要)

After gathering the initial evidence, ask the user which mode they prefer for the rest of the investigation:

- **A — 病急亂投醫 (Quick Fix)**: prioritize a fast, pragmatic fix or workaround. Bypass some diagnostic steps to attempt a targeted patch immediately. Useful when uptime or quick recovery is more important than a full root-cause investigation.
- **B — 根因優先 (Root-Cause First)**: perform the full structured investigation before any code changes. This is the default and safest mode.

When the user does not explicitly choose, default to **B — 根因優先**.

Record the chosen mode in the `INVESTIGATION_REPORT.md` (if used) under a `Mode:` field.

---

### (moved) Report prompt

The prompt and report template were merged into Step 2 (Diagnosis). See Step 2 below for the `INVESTIGATION_REPORT.md` flow and template.

---

### Step 2 — Present Diagnosis Block

Always use this format — never skip straight to the fix:

```
DIAGNOSIS:
Problem:  [One specific sentence — what is wrong]
Evidence: [Log line / code snippet with file:line reference]
Location: [Exact file and line number where root cause lives]
Impact:   [What is broken for the user / system as a result]
```

After presenting the `DIAGNOSIS` block, ask the user whether to create an investigation record for this session:

```
Would you like me to create an Investigation Report for this investigation?
An `INVESTIGATION_REPORT.md` will be created in the feature folder (spec/features/NNN/)
and updated throughout the debug session — capturing findings, fixes, and verification results.

→ yes / no
```

If yes: create `spec/features/NNN/INVESTIGATION_REPORT.md` using the structure below.
If no: proceed without creating the file.

**Investigation report structure**:
```markdown
# Investigation Report: [Bug Description]

**Feature**: FEAT-NNN
**Date**: YYYY-MM-DD
**Environment**: [UAT / SIT / Prod]
**Mode**: [A — Quick Fix / B — Root-Cause First]

## Bug Description
[One paragraph — what was reported]

## Diagnosis (initial)
[Populate with the DIAGNOSIS block created in Step 2]

## Investigation Findings
[Populated during Steps 3–4]

## Root Cause
[Populated once identified in Step 4]

## Fix Applied
[Populated after Step 6]

## Verification
[Populated after Step 7]

## Outcome
[ ] Bug resolved  [ ] Partially resolved  [ ] Escalated
```

Update the report after each relevant step. The final document becomes a permanent record of the debug session.

---

### Step 3 — If Root Cause Unclear, Present Investigation Checklist

When the cause is not yet certain, provide a layered investigation plan:

```
INVESTIGATION CHECKLIST:

□ LAYER 1: [e.g., API Response / External Service]
  □ Check: [Exact command/query to run]
  □ Expected: [What success looks like]
  □ Red flag: [What indicates the problem is here]

□ LAYER 2: [e.g., Data Mapping / Business Logic]
  □ Check: [Exact command/query to run]
  □ Expected: [What success looks like]
  □ Red flag: [What indicates the problem is here]

□ LAYER 3: [e.g., Frontend / UI Layer]
  □ Check: [How to inspect in browser / what to grep]
  □ Expected: [What success looks like]
  □ Red flag: [What indicates the problem is here]

Start with LAYER 1. Report findings before proceeding.
```

---

### Step 4 — Propose Fix Block

Once root cause is identified, present:

```
PROPOSED FIX:
Change: [What to modify — one specific change]
From:   [Current code/behavior]
To:     [Fixed code/behavior]
Why:    [Technical explanation of why this resolves the root cause]
Risk:   [Any potential side effects or regressions to watch for]
```

---

### Step 5 — Wait for Approval (mode-aware)

Always confirm intent before making non-trivial changes.

If mode **B — 根因優先**: always ask explicitly before editing files (the `NEXT STEPS` checklist below).

If mode **A — 病急亂投醫**: require an explicit quick-fix consent such as `QUICK_FIX: please apply the patch now` or a short approval message. The agent will then apply a minimal, targeted change and clearly flag the risk.

```
NEXT STEPS:
□ Proceed with the fix above?
□ Investigate another layer first?
□ Try an alternative approach?

Your call: proceed / investigate more / suggest alternative?
```

DO NOT edit files until the user gives the appropriate approval for the selected mode.

---

### Step 6 — Apply the Fix

After approval:
1. Make the single targeted change as described in the Proposed Fix block
2. Do not refactor surrounding code unless directly related to the bug
3. Do not "improve" code style in the same diff — keep the fix minimal and reviewable

---

### Step 7 — Verify

After applying:
1. Run the project's build command (see `copilot-instructions.md` for exact command)
2. Perform targeted verification relevant to the bug type

Report the result in this format:
```
VERIFICATION:
Build:    ✅ 0 errors
Test:     [What was checked and what it showed]
Status:   ✅ Bug resolved / ⚠️ Partially resolved (note remaining issue) / ❌ Still failing
```

---

### Step 8 — Update Feature Status (if bug-linked)

If the bug is linked to a tracked feature in `spec/features/`, update that feature's `README.md`:
- **Bug confirmed and still unresolved / blocking progress**: Set `Status` = 🔴 Blocked, Updated = today
- **Bug resolved and it was blocking**: Restore `Status` = 🔵 In Progress, Updated = today
- **Bug resolved but was not blocking a feature**: No feature status change needed

---

## Rules

- ❌ **NEVER** edit files before presenting a diagnosis
- ❌ **NEVER** paste a fix without explaining the root cause
- ❌ **NEVER** make multiple unrelated changes in a single bug fix
- ✅ Keep fixes minimal — touch only what is broken
- ✅ If the investigation reveals a deeper architectural problem, flag it separately; fix only the immediate bug now
- ✅ Teach the cause: briefly explain why this bug happened so the pattern can be recognized next time

---

## Teaching Format (Optional — for architectural bugs)

When the bug reveals a structural pattern worth learning:

```
CONCEPT: [Topic Name]

WHAT:            [Simple definition]
WHY IT MATTERS:  [How this explains the current bug]
APPLIES HERE:    [Specific connection to the code/bug at hand]
NEXT TIME:       [Pattern to watch for in future]
```

---

## Diagnostic Commands Reference

> **Note**: The commands below are generic patterns. Refer to `copilot-instructions.md` for project-specific paths and tools.

| Scenario | Generic Approach |
|---|---|
| Check app logs | `tail -200 [LOG_PATH] \| grep -i "error\|exception"` |
| Find file in project | `find . -name "*.ext" \| xargs grep -l "[ClassName]"` |
| Find route definition | Grep for route attributes in controller/router files |
| Check data model | Grep for class/interface definitions in model files |
| Find UI error | Grep for `console.error`, `catch`, error handlers in view files |
| Build and check errors | Run project build command, pipe to `grep -E "error\|warning"` |
