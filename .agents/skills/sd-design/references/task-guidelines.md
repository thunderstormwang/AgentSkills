# Task Phase Guidelines

These guidelines apply strictly to **Phase 4 — Task** of the `sd-design-helper` development lifecycle. The primary goal is to produce high-quality, actionable tasks that can be executed independently.

---

## Task Structure & Constraints

- **Logical Commit Granularity:** Each task should ideally correspond to one logical commit.
- **File Limit:** Each task should not target more than **3 files** to ensure clarity and maintainability.
- **DB Schema Changes:** Tasks for DB changes MUST involve generating a SQL script.
    - **Storage:** Save to the `sql/` folder at the project root.
    - **Filename:** `PXBOX-{jira ticket no}.sql`.
    - **Ticket Number:** If the Jira ticket number is unknown, ask the user for confirmation.
- **API Contract Changes:** Tasks for API changes MUST include a summary for frontend developers.
    - **Content:** Include API route, change type (Add/Edit/Delete), and specific field changes in Request/Response.

---

## Task Ordering (Prioritization)

When generating the Task list, always follow this order to facilitate parallel development and smooth integration:

1.  **DB Schema Changes**: Always prioritize SQL script generation.
2.  **Entity / Domain Changes**: Core business logic and data structures.
3.  **API Skeletons & Fields**: Define Request/Response models and Controller endpoints first (placeholder logic is allowed).
4.  **API Summary**: Provide the frontend summary immediately after API contracts are defined.
5.  **Functional Implementation**: Detailed logic and optimizations.

---

## Content Requirements

Each task must be detailed enough to be implemented without referring back to the Design section. It MUST include:

- **Reference:** The Design ID(s) this task implements (e.g., `[Ref: D1]`).
- **Target Project:** The name of the project/assembly.
- **Component:** Specific Class name (e.g., Handler, Controller, Service).
- **Methods:** Names of the methods to be created or modified.
- **Logic Details:** Step-by-step logic, code patterns, or specific validation rules.
- **Unit Tests:** Description of the test cases to be added or updated.

---

## Format Example

### T1: [Task Name]
- **Reference:** `[D1]`
- **Target:** `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details:**
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
    - [Unit Test: Describe the test case to be added/updated]
- **Affected Files:** (List up to 3 files)
