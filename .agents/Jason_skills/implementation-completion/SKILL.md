---
name: implementation-completion
description: >
  Mandatory completion gate before declaring any code done. Run the project build command, assert
  0 compilation errors, create an Implementation Completion Report (ICR) in spec/features/NNN/,
  and deliver with build output as evidence. NEVER tell the user "code is ready" without running
  this skill first. Keywords: done, complete, finished, ready for review, ready to test, delivered.
---

# Skill: Implementation Completion Gate

**Purpose**: Enforce a mandatory build-verify → document → deliver sequence so code is never claimed complete without evidence of successful compilation and a traceable completion record.

> **Project-specific details** (build commands, project structure, solution file) come from `copilot-instructions.md`, which is always in context.

---

## Execution Trigger

Activate this skill when:
- All planned code changes for a feature or fix have been made
- About to tell the user "code is complete", "ready to test", or "done"
- Finishing a multi-phase implementation (4+ files changed)
- After resolving build errors and wanting to confirm clean state

---

## Procedural Steps

### Step 1 — Identify Affected Projects
Determine which projects/modules were touched by the current changes.

> **Refer to `copilot-instructions.md`** for the project's build command mapping (e.g., which command to run for which layer/module).

When in doubt, build the full project/solution.

---

### Step 2 — Run Build
Run the project's build command and capture the output.

Look for the summary indicating success:
```
Build succeeded.
    0 Error(s)
    N Warning(s)
```

(Exact format varies by language/toolchain — look for the equivalent success indicator.)

---

### Step 3 — Assert 0 Errors

**If build FAILS:**
- ❌ Do NOT proceed to ICR
- ❌ Do NOT tell user code is ready
- Fix compilation errors first
- Re-run Step 2
- Repeat until 0 errors confirmed

**If build SUCCEEDS:**
- ✅ Proceed to Step 4
- Warnings are acceptable — note them in the ICR

---

### Step 4 — Determine Feature Folder
```bash
ls spec/features/ | sort
```
Identify the `NNN-{feature-name}` folder for the current feature being completed.

---

### Step 5 — Create Implementation Completion Report (ICR)

Use the ICR template from `spec/_templates/PROCESS/` and fill in:

**Required fields:**
- Date (today)
- Feature name & one-line description
- Status: `✅ CODE COMPLETE & VERIFIED COMPILABLE`
- Build result: `0 compilation errors | N warnings`
- Executive Summary (2-3 sentences)
- Each implementation phase with: files changed, what changed, status
- Files Modified Summary table
- Build Verification section — paste actual build output
- Architectural Patterns Followed
- Testing Recommendations
- Deployment Checklist

**Save to:** `spec/features/NNN-{feature-name}/IMPLEMENTATION_COMPLETION_REPORT.md`

---

### Step 6 — Deliver with Build Evidence

Structure the delivery message as:

```markdown
✅ Code implementation complete. Verified:

**Build**: [build command used]
**Result**: Build succeeded — 0 errors, N warnings

**Files Modified** (N total):
- `Path/To/File1` — [what changed]
- `Path/To/File2` — [what changed]

**ICR**: `spec/features/NNN-{feature}/IMPLEMENTATION_COMPLETION_REPORT.md`

Ready for code review and testing.
```

---

### Step 7 — Update Feature Status

After delivering, update `spec/features/NNN-{feature-name}/README.md`:
- If awaiting code review or testing: Set `Status` = 🟣 Review
- If fully verified and accepted by the user: Set `Status` = ✅ Complete
- Set `Updated` = today's date

---

## Rules

- ❌ **NEVER** say "code is complete" or "ready to test" without build-succeeded output
- ❌ **NEVER** proceed to ICR if compilation errors exist — fix first
- ❌ **NEVER** skip ICR for multi-file implementations (4+ files)
- ❌ **NEVER** create a standalone testing guide file (e.g. `UAT_TESTING_GUIDE.md`, `TESTING_GUIDE.md`) — testing guidance belongs as the "Testing Recommendations" section **inside the ICR**, not as a separate file
- ❌ **NEVER** place any completion artifact under `docs/` — all output goes to `spec/features/NNN-{feature}/`
- ❌ **NEVER** include SSH, `kubectl exec`, `kubectl logs`, or `curl` health-check commands in testing guidance — UAT pods have no external IP and no shell access
- ✅ Warnings are acceptable — document them in the ICR Known Limitations section
- ✅ For single-file hotfixes < 4 files, ICR is optional but build verification is still mandatory
- ✅ Always paste the actual build summary line in the delivery message
- ✅ **Observability in testing guidance** — use Grafana stack only:
  - Logs → Grafana → Loki → Explore (LogQL)
  - Metrics → Grafana → Mimir → Explore (PromQL)
  - Traces → Grafana → Tempo

---

## Delivery Status Reference

| Build State | Action |
|---|---|
| ✅ 0 errors | Create ICR → Deliver |
| ⚠️ 0 errors, N warnings | Create ICR → Note warnings → Deliver |
| 🔴 N errors | Fix errors → Re-run build → Do not deliver yet |

---

## Example Good Delivery Message

```
✅ Code implementation complete. Verified:

Build: [project build command]
Result: Build succeeded — 0 errors, 2 warnings

Files Modified (4 total):
- src/services/UserService.ts — Added session tracking method
- src/routes/users.ts — Added /api/users/sessions endpoint
- src/models/Session.ts — New session data model
- src/views/dashboard.html — Wired up sessions chart

ICR: spec/features/005-user-session-metrics/IMPLEMENTATION_COMPLETION_REPORT.md

Ready for code review and testing.
```

## Example BAD Delivery Messages (Never Do These)

```
✗ I've implemented the changes.                    ← No build verification
✗ The code should compile correctly.               ← Assumption, not evidence
✗ Ready to test (the logic looks right to me).     ← No build run = not ready
```
