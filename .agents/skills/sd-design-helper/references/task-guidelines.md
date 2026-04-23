# Task Phase Guidelines

These guidelines apply strictly to **Phase 4 — Task** of the `sd-design-helper` development lifecycle.

---

## Task Constraints

- **File Limit:** Each task must not modify more than **3 files**.
- **DB Schema Changes:** If the Design includes DB changes, a specific Task MUST be created to generate the SQL script.
    - **Storage:** The script must be saved in the `sql/` folder at the project root.
    - **Filename:** `PXBOX-{jira ticket no}.sql`.
    - **Jira Ticket:** If the Jira ticket number is unknown, the agent MUST ask the user for confirmation.
    - **Execution:** Note that the script will be manually executed by a human in various environments.
- **API Contract Changes:** If the Design includes changes to API Request/Response, a specific Task MUST be created to generate a summary for frontend developers to facilitate Swagger lookups.
    - **Content:** The summary must include the API route, the type of change (Add/Edit/Delete API), and specific field changes (Add/Edit/Delete fields in Request/Response).
    - **Delivery:** This summary will be provided directly in the task description for the user to copy-paste.
- **Task Progression:** Always implement basic functionality first, followed by optimizations.

---

## Content Requirements

Each task must be detailed enough for a developer to implement without referring back to the Design. It MUST include:

- **Reference:** The Design ID(s) this task implements (e.g., `[Ref: D1]`).
- **Target Project:** The name of the project/assembly.
- **Component:** Specific Class name (e.g., Handler, Controller, Service).
- **Methods:** Names of the methods to be created or modified.
- **Logic Details:** Step-by-step logic, code patterns, or specific validation rules.
- **Unit Tests:** Every logic change must be verified by unit tests. Unit tests and production code changes can be in the same task or separated into distinct tasks (e.g., T1 for production code, T2 for unit test) to maintain the 3-file limit.

---

## Format Example

Use a structured list instead of a table for better readability:

### T1: [Task Name]
- **Reference:** `[D1]`
- **Target:** `[Project Name]` -> `[Class Name]` -> `[Method Name]`
- **Implementation Details:**
    - [Step 1: Specific logic/instruction]
    - [Step 2: Specific logic/instruction]
    - [Unit Test: Describe the test case to be added/updated]
- **Affected Files:** (List up to 3 files)
