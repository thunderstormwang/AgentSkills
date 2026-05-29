# Task Phase Guidelines

These guidelines apply strictly to **Phase 4 — Task** of the `sd-design` development lifecycle. The primary goal is to produce high-quality, actionable tasks that can be executed independently.

---

## Task Structure & Constraints

- **Logical Commit Granularity:** Each task should ideally correspond to one logical commit.
- **File Limit:** Default ≤ 3 files per task.
    - **Spirit:** Each task must be reviewable independently and revertible cleanly.
    - **Allowed exception:** Mechanical edits (rename, enum/const addition, identical pattern across files) may span more files when each per-file diff is small (~< 5 lines) and shares one purpose.
    - **When in doubt, split smaller** — over-splitting is cheap, over-bundling hurts review.
- **Implementation Code Belongs Here:** All method bodies, SQL queries, mapping/assembly logic, and other implementation details MUST appear in Task, not in Design. Design only expresses contracts (field declarations, method signatures).
- **DB Schema Changes:** Tasks for DB changes MUST involve generating a SQL script.
    - **Storage:** Save to the `sql/` folder at the project root.
    - **Filename:** `PXBOX-{jira ticket no}.sql`.
    - **Ticket Number:** If the Jira ticket number is unknown, ask the user for confirmation.
- **API Contract Changes:** This is a **documentation-only task** (does not involve code changes). Its purpose is to provide a clear, **copy-pasteable summary** for frontend developers.
    - **Content:** Include API route, change type (Add/Edit/Delete), and specific field changes in Request/Response.

---

## Task Ordering (Prioritization)

When generating the Task list, always follow this order to facilitate parallel development and smooth integration:

1.  **DB Schema Changes**: Always prioritize SQL script generation.
2.  **Entity / Domain Changes**: Core business logic and data structures.
3.  **API Skeletons & Fields**: Define Request/Response models and Controller endpoints first.
4.  **API Summary**: Provide the frontend summary immediately after API contracts are defined (Documentation-only task).
5.  **Verification Task (Test Task)**: Create independent test tasks for entry points. Interfaces are now defined; write tests first to define expected behavior (Fail-First).
6.  **Functional Implementation**: Detailed logic and optimizations, developed until tests pass.

---

## Content Requirements

Each task must be detailed enough to be implemented without referring back to the Design section. It MUST include:

- **Reference:** The Design ID(s) this task implements.
- **Dependency (Mandatory):** List the Task ID(s) that must be completed before this task (e.g., `[Dep: T1, T2]`). Use `None` if there are no dependencies.
- **Target Project:** The name of the project/assembly.
- **Component:** Specific Class name.
- **Methods:** Names of the methods to be created or modified.
- **Logic Details:** Step-by-step logic, code patterns, or specific validation rules.
- **Test File (DoD - Test Tasks Only):** MUST specify the physical test file path (e.g., `src/Project.Test/xxxTest.cs`).

---

## Format Example

### T1: [Task Name]
- **Reference:** `[D1]`
- **Dependency:** `None`
- **Target:** `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details:**
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
- **Affected Files:** (List all affected files; respect the File Limit rule above)

### T5: Test — [Feature Name] Entry Point Test
- **Reference:** `[D3]`
- **Dependency:** `T1, T2`
- **Test Target:** `[Class Name]`
- **Implementation Details:** Implement API-level integration test covering [Given/When/Then] scenarios. This task aims to produce a failing test to define logical boundaries.
- **Test File (DoD):** `src/PXBox.Spu.Test/Handlers/XxxHandlerTest.cs`
- **Affected Files:** (Test-related files only; respect the File Limit rule above)
