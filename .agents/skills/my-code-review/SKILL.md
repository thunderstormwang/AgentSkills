---
name: my-code-review
description: Performs structured, multi-agent code review of a whole feature branch against its base (main). If the branch has a plan document (Req / Pre Design Sync / Design / Task) it reviews against the plan too; if not, it reviews from the code alone. Use this skill whenever the user wants a branch / feature reviewed — before merge, "check what I changed", correctness / intent / maintainability — even if they don't mention a plan or explicitly say "review". Sources the change via git diff (not gh), so it works on any host (GitHub, Gitea, self-hosted).
---

# my-code-review

A structured code review engine that validates implementation against a plan document. It works top-down from intent to detail, ensuring the implementation not only matches the plan but is also correct, safe, and maintainable.

---

## Core Principle

> **The plan is the entry point, not the finish line.**

Matching the Task checklist only tells you *what was done*. The real review validates *whether it was done correctly and well*. Use the plan to orient yourself, then read the actual code to find what the plan cannot tell you.

---

## Workflow

You always review a **whole feature branch against its base**, with multi-agent fan-out. The only variable is whether the branch has a plan: with a plan you review against it too (Layers 0–2); without one you review from code alone (Layers 3–6).

1. **Source the change (git, not a PR host).** `git diff <base>...HEAD` (three-dot; base defaults to `origin/main`, fall back to `main`). Works on any host (GitHub, Gitea, self-hosted). Review committed work, not uncommitted local tinkering.
2. **Detect a plan.** Discover a plan / feature doc in the repo (e.g. a `plan.md` / feature doc under `docs/`) — don't hardcode a path.
   - **Plan found → plan-based review:** all layers apply, including the plan layers (0–2).
   - **No plan → code-only review:** skip Layers 0–2; rely on Layers 3–6 and infer Design intent from the code and commit messages.
3. **Load Layer 0 once, in the orchestrator (plan only).** Read the plan top-down yourself *before* fanning out — especially Pre Design Sync (deliberate decisions are not bugs). Pass the relevant Task / Design excerpts down to each subagent rather than having all of them re-read and re-interpret the whole plan.
4. **Fan out — read-only subagents.** A finished branch can touch 100+ files; don't review it in one pass. Cluster the changed files by directory / layer / aggregate and spawn one read-only review subagent per cluster (cap ~5–6; batch if more). Each subagent:
   - loads any project coding-convention / architecture skill covering its slice — that skill is the single source of those conventions, so do not restate them here;
   - applies Layers 1–6 to its slice (Layers 1–2 only when a plan exists);
   - reads enough surrounding context to reason — **not diff-only**, which is what misses the deep concurrency / data-flow bugs;
   - adversarially self-checks each finding, and returns `file:line` + concrete failure scenario + confidence (HIGH/MED/LOW).
5. **Synthesize.** Dedupe into one report and verify every MED+/🔴 finding against the code yourself before presenting.
6. **Cost guard.** If the diff is very large, report its size first (files / rough token estimate) and confirm before fanning out.

---

## Review Layers

Execute review in this order. Each layer builds on the previous.

### Layer 0 — Context Loading (Before Reviewing Anything) — *plan-based review only*

> Skip this and Layers 1–2 entirely when the branch has no plan. When it does, the orchestrator does this once before fan-out (see Workflow).

Read the plan document top-down **before touching any code**:

1. **Req** — Understand *why* this change exists. What problem is being solved?
2. **Pre Design Sync** — Understand *why the design was made this way*. Every Q conclusion is a deliberate decision. Do not flag deliberate decisions as bugs.
3. **Design** — Understand *what the structure and contracts should look like*.
4. **Task** — Use as the checklist of expected changes.

> ⚠️ Skipping Pre Design Sync is the most common cause of false positives in code review. A design choice that looks "wrong" often has a documented reason in Pre Design Sync.

---

### Layer 1 — Completeness (Task vs Implementation) — *plan-based review only*

For each Task item, verify:
- The expected files exist and were modified
- New classes / methods / fields are present with correct signatures
- Dependencies added/removed match the plan
- Callers updated where the plan requires (e.g., method signature changes)

> This is the checklist layer. It is necessary but not sufficient.

---

### Layer 2 — Intent Alignment (Design & Req vs Implementation) — *plan-based review only*

Go beyond the Task checklist:

- Does the implementation satisfy the **Req Acceptance Criteria**, regardless of whether it follows the exact Task steps?
- If the implementation deviates from the Task (e.g., two classes merged into one), evaluate against the **Design intent**, not the Task literal description.
- Ask: *Does this achieve what the Design was trying to achieve?*

> A deviation from Task that satisfies Design intent and Req is **not a bug**. A deviation that breaks Design intent **is a bug even if the Task checklist passes**.

---

### Layer 3 — Correctness (Read the Actual Code)

Verify the implementation logic itself, independent of the plan:

#### Null & Edge Case Safety
- Are all nullable return values guarded at the call site?
- What happens on cache miss? Is the fallback behavior correct and intentional?
- What happens when a collection is empty?

#### Type Consistency
- Are types consistent between layers (e.g., DTO stores `int`, handler compares with `int`, not enum)?
- Are enum-to-int conversions explicit and correct?

#### SQL / Query Correctness (if applicable)
- Are JOIN conditions correct?
- Do column aliases match the mapping class field names?
- Are soft-deleted or inactive records correctly filtered?

#### Dependency & DI
- Are new dependencies registered in the DI container?
- Are circular dependencies introduced?

---

### Layer 4 — Impact Tracing (What Else Changed)

Changed code has ripple effects. For every change, trace outward:

| Changed Item | What to Check |
| :--- | :--- |
| Method signature changed | All callers updated? |
| New constructor parameter | DI registration updated? |
| Base class behavior relied upon | What does the base class actually do with edge inputs (e.g., `null`)? |
| Cache write path changed | What happens if data written is `null`? |
| New event published | All consumers handle the new shape? |

---

### Layer 5 — Observability

- Are important failure paths logged?
- Is a cache miss silent or logged with a warning?
- Is there a way to detect when this code path produces an unexpected result in production?

> Silent fallbacks are especially dangerous: the system appears to work but returns wrong data.

---

### Layer 6 — Code Smell

Check for quality issues beyond correctness:

| Smell | Signal |
| :--- | :--- |
| Method too long | One method doing too many things |
| Duplicated logic | Same logic in two places (this is often the **Req motivation**) |
| Wrong abstraction level | Handler assembling SQL; Cache knowing Job schedules |
| Too many constructor dependencies | > 5–6 is a signal |
| Inconsistency with existing patterns | New code diverges from how the rest of the codebase handles the same concern |

> Distinguish between **newly introduced smells** (must flag) and **pre-existing smells** (note but do not block).

---

## Output Format

Organize by **Task** when the branch has a plan; organize by **area / file cluster** when it has none. Either way, end with the Final Summary Table and keep the severity scheme below.

### Per-Task Summary (plan-based review)

For each Task ID, output one block:

```
### ✅ T1 — [Task Name]
[One sentence confirming what was verified and that it passes.]

### ⚠️ T3 — [Task Name]
[One sentence summary.]

#### Issue 1 — [Short title]
**Severity:** 🔴 Bug / 🟡 Risk / 🟢 Minor
**Location:** `path/to/file.cs` line N
**Description:** [What is wrong and why it matters]
**Suggestion:** [Concrete fix or recommendation]
```

### Changes with no owning Task / no plan

A finished branch usually contains changes with no owning Task — review-driven fixes, follow-up refactors, tidy-ups — and a branch with no plan is entirely this case. Do **not** skip them for lack of a Task. Group them by area (`Non-Task changes`, or by file cluster when there is no plan at all) and review each on Layers 3–6 (correctness, impact tracing, observability, smell), plus Design intent where a plan exists. Flag anything that changes observable behavior versus main, so it is a conscious decision rather than a silent drift.

### Severity Definitions

| Level | Meaning |
| :--- | :--- |
| 🔴 Bug | Incorrect behavior, data loss, or wrong result in production |
| 🟡 Risk | Correct today, but fragile or will silently fail under edge cases |
| 🟢 Minor | Code quality, observability, or consistency issue with no immediate functional impact |

### Final Summary Table

End with a table across all Tasks:

```markdown
| Task | 狀態 | 備註 |
| :--- | :--- | :--- |
| T1 | ✅ | 正確 |
| T2 | ✅ | 正確 |
| T3 | ⚠️ | null guard 缺失（🟡） |
| T4 | ✅ | 正確 |
| T5 | ⚠️ | 無 logger，cache miss 靜默 fallback（🟡） |
```

---

## Guidelines

- **Traditional Chinese**: Communicate with the user in Traditional Chinese.
- **Pre Design Sync first**: Always read Pre Design Sync before reporting any finding. A documented design decision is not a bug.
- **Intent over literal**: Evaluate against Design intent and Req, not just Task steps. A deviation that preserves intent is acceptable.
- **Trace impact outward**: A changed line is the starting point, not the end. Always ask what else could be affected.
- **Distinguish new vs pre-existing issues**: Clearly state whether a finding is introduced by this change or was already present.
- **No style commentary**: Do not flag formatting, naming conventions, or style preferences unless they violate a documented standard or cause genuine confusion.
