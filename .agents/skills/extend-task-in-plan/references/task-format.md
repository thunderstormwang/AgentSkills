# Task Detail Block Format

Defines the inline format used for individual task blocks within a plan document. Applies to both:
- **Mode A** — T tasks generated from Design
- **Mode B** — FT tasks added as derivative work

For **Mode A category rules and ordering** (DB → Entity → API → Test → Impl, SQL filename, API Summary, …), see `task-guidelines.md`.

---

## Shared Constraints

- **Logical commit granularity:** Each task corresponds to one logical commit.
- **File limit:** Default ≤ 3 files per task.
    - **Spirit:** Each task must be reviewable independently and revertible cleanly.
    - **Allowed exception:** Mechanical edits (rename, enum/const addition, identical pattern across files) may span more files when each per-file diff is small (~< 5 lines) and shares one purpose.
    - **When in doubt, split smaller** — over-splitting is cheap, over-bundling hurts review.
- **Implementation code belongs in Task, not Design:** All method bodies, SQL queries, mapping/assembly logic, and other implementation details MUST appear in Task. Design only expresses contracts (field declarations, method signatures).

---

## Field Schema

| Field | Modes | Description |
| :--- | :--- | :--- |
| **Reference** | Mode A only | The Design ID(s) this task implements (e.g., `[D01]`) |
| **Current state** | Mode B only | What exists now / what's missing (1-2 lines) — replaces Reference's "why" role since FT has no Design source |
| **Goal** | Mode B only | What this task achieves (1-2 lines) |
| **Dependency** | Both | Prerequisite task ID(s), or `None` |
| **Target** | Both | `[Project Name]` -> `[Class Name]` -> `[Method Name]` |
| **Implementation Details** | Both | Step-by-step logic, code patterns, or specific validation rules |
| **Test File (DoD)** | Test tasks only | Physical test file path (e.g., `src/Project.Test/xxxTest.cs`) |
| **Affected Files** | Both | List of affected file paths; respect the File Limit |

### Field Ordering

1. **Why the task exists** — Mode A: `Reference`; Mode B: `Current state` + `Goal`
2. `Dependency`
3. `Target` (or `Test Target` for test tasks)
4. `Implementation Details`
5. `Test File (DoD)` — test tasks only
6. `Affected Files`

---

## Mode A — T Task Template

### T01 [Task Name]
- **Reference:** `[D01]`
- **Dependency:** `None`
- **Target:** `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details:**
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
- **Affected Files:** (List all affected files; respect the File Limit rule)

### T05 [Test — Feature Name Entry Point Test]
- **Reference:** `[D03]`
- **Dependency:** `T01, T02`
- **Test Target:** `[Class Name]`
- **Implementation Details:** Implement API-level integration test covering [Given/When/Then] scenarios. Aim to produce a failing test to define logical boundaries.
- **Test File (DoD):** `src/PXBox.Spu.Test/Handlers/XxxHandlerTest.cs`
- **Affected Files:** (Test-related files only; respect the File Limit rule)

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
- **Affected Files**: (List all affected files; respect the File Limit rule)
