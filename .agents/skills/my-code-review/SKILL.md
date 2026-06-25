---
name: my-code-review
description: Performs structured code review against a plan document (Req / Pre Design Sync / Design / Task). Use this skill when the user wants to review an implementation against a plan to verify correctness, intent alignment, and code quality.
---

# my-code-review

A structured code review engine that validates implementation against a plan document. It works top-down from intent to detail, ensuring the implementation not only matches the plan but is also correct, safe, and maintainable.

---

## Core Principle

> **The plan is the entry point, not the finish line.**

Matching the Task checklist only tells you *what was done*. The real review validates *whether it was done correctly and well*. Use the plan to orient yourself, then read the actual code to find what the plan cannot tell you.

---

## Review Layers

Execute review in this order. Each layer builds on the previous.

### Layer 0 — Context Loading (Before Reviewing Anything)

Read the plan document top-down **before touching any code**:

1. **Req** — Understand *why* this change exists. What problem is being solved?
2. **Pre Design Sync** — Understand *why the design was made this way*. Every Q conclusion is a deliberate decision. Do not flag deliberate decisions as bugs.
3. **Design** — Understand *what the structure and contracts should look like*.
4. **Task** — Use as the checklist of expected changes.

> ⚠️ Skipping Pre Design Sync is the most common cause of false positives in code review. A design choice that looks "wrong" often has a documented reason in Pre Design Sync.

---

### Layer 1 — Completeness (Task vs Implementation)

For each Task item, verify:
- The expected files exist and were modified
- New classes / methods / fields are present with correct signatures
- Dependencies added/removed match the plan
- Callers updated where the plan requires (e.g., method signature changes)

> This is the checklist layer. It is necessary but not sufficient.

---

### Layer 2 — Intent Alignment (Design & Req vs Implementation)

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

### Per-Task Summary

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
