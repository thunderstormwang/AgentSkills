# Task Detail Block Format

Defines the inline format used for individual task blocks within a plan document. Applies to both:
- **Mode A** — T tasks generated from Design
- **Mode B** — FT tasks added as derivative work

For **Mode A category rules and dependency-based ordering** (category priorities, SQL filename, API Summary, …), see `task-guidelines.md`.

---

## Shared Constraints

- **Logical commit granularity:** Each task corresponds to one logical commit with a clear purpose that can be reviewed and verified.
- **No fixed file-count limit:** Split by responsibilities, behaviors, or independently complete stages, not by file count.
    - Keep contracts, implementations, and callers together when they must take effect together. List all affected files, including tests.
    - Split distinct purposes when they can be completed, verified, and reverted separately.
    - For a large change with one purpose, look for meaningful intermediate stages that work after their prerequisites are complete. Do not create unbuildable or behaviorally incomplete commits merely to shrink a task.
- **Validation belongs to the task:** Include the corresponding test additions/updates and applicable build, test execution, or review checks in the implementation task by default.
    - Follow the confirmed strategy and explicit task-scoped user instructions. Distinguish not adding tests from not running tests; neither means no validation.
    - Record targets/commands and pass criteria in `Validation`, or reference a shared strategy with explicit applicability and any task-specific differences. Do not impose every check on every task or extend a scoped exception to the whole repo.
    - Tests may still be written first within the same task; this does not require a separate test-first task or a failing-test commit.
    - Create a separate verification task only when verification is itself an independent purpose (e.g., adding tests for existing behavior) or requires multiple tasks to be completed (e.g., cross-feature end-to-end checks). Explain why it is separate and list its actual dependencies.
- **Implementation code belongs in Task, not Design:** All method bodies, SQL queries, mapping/assembly logic, and other implementation details MUST appear in Task. Design only expresses contracts (field declarations, method signatures).

---

## Field Schema

| Field | Modes | Description |
| :--- | :--- | :--- |
| **Reference** | Mode A only | The Design ID(s) this task implements (e.g., `[D01]`) |
| **Current state** | Mode B only | What exists now / what's missing (1-2 lines) — explains why the FT is needed; cite an applicable confirmed follow-up Design when one exists |
| **Goal** | Mode B only | What this task achieves (1-2 lines) |
| **Dependency** | Both | Prerequisite task ID(s), or `None` |
| **Target** | Both | `[Project Name]` -> `[Class Name]` -> `[Method Name]` |
| **Implementation Details** | Both | Step-by-step logic, code patterns, or specific validation rules |
| **Validation** | Both | Applicable checks, targets/commands, and pass criteria, or a scoped reference to a shared validation strategy |
| **Test File (DoD)** | Tasks adding or modifying tests | Physical test file path(s) (e.g., `src/Project.Test/xxxTest.cs`) |
| **Affected Files** | Both | Complete list of affected file paths, including corresponding test files |

### Field Ordering

1. **Why the task exists** — Mode A: `Reference`; Mode B: `Current state` + `Goal`
2. `Dependency`
3. `Target` (or `Test Target` for test tasks)
4. `Implementation Details`
5. `Validation`
6. `Test File (DoD)` — when adding or modifying tests
7. `Affected Files`

---

## Mode A — T Task Template

### T01 [Task Name]
- **Reference:** `[D01]`
- **Dependency:** `None`
- **Target:** `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details:**
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
- **Validation:**
    - [Applicable checks with targets/commands and pass criteria, or a scoped shared-strategy reference]
- **Test File (DoD):** [Path(s), when adding or modifying tests]
- **Affected Files:** (List all affected files, including corresponding test files)

Use a separate task only for an independent verification purpose or checks that require multiple tasks to be completed:

### T05 [Test — Existing Feature Coverage]
- **Reference:** `[D03]`
- **Dependency:** `T01, T02`
- **Test Target:** `[Class Name]`
- **Implementation Details:** Add coverage for [Given/When/Then] scenarios of existing behavior. Testing is this task's independent purpose.
- **Validation:** Run [targeted test command]; all specified scenarios must pass.
- **Test File (DoD):** `src/PXBox.Spu.Test/Handlers/XxxHandlerTest.cs`
- **Affected Files:** (List all affected test-related files)

---

## Mode B — FT Task Template

### FT01 [Task Name]
- **Current state**: {what exists / what's missing — 1-2 lines}
- **Goal**: {what this task achieves — 1-2 lines}
- **Dependency**: {prerequisite FT ID or `None`}
- **Target**: `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details**:
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
- **Validation**:
    - [Applicable checks with targets/commands and pass criteria, or a scoped shared-strategy reference]
- **Test File (DoD)**: [Path(s), when adding or modifying tests]
- **Affected Files**: (List all affected files, including corresponding test files)
