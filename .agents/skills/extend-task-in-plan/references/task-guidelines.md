# Mode A — Task Ordering & Category Rules

These guidelines apply to **Mode A — Initial Task Generation** of the `extend-task-in-plan` skill. They cover ordering and category-specific rules for tasks generated from Design.

For the **task block format** (fields, templates, shared constraints), see `task-format.md`.

---

## Task Ordering (Prioritization)

When generating the Mode A Task list, always follow this order to facilitate parallel development and smooth integration:

1. **DB Schema Changes**: Always prioritize SQL script generation.
2. **Entity / Domain Changes**: Core business logic and data structures.
3. **API Skeletons & Fields**: Define Request/Response models and Controller endpoints first.
4. **API Summary**: Provide the frontend summary immediately after API contracts are defined (documentation-only task).
5. **Verification Task (Test Task)**: Create independent test tasks for entry points. Interfaces are now defined; write tests first to define expected behavior (Fail-First).
6. **Functional Implementation**: Detailed logic and optimizations, developed until tests pass.

---

## Category-specific Rules

### DB Schema Changes
- Tasks for DB changes MUST involve generating a SQL script.
- **Storage:** Save to the `sql/` folder at the project root.
- **Filename:** `PXBOX-{jira ticket no}.sql`.
- **Ticket Number:** If the Jira ticket number is unknown, ask the user for confirmation.

### API Contract Changes
- This is a **documentation-only task** (does not involve code changes).
- **Purpose:** Provide a clear, copy-pasteable summary for frontend developers.
- **Content:** Include API route, change type (Add/Edit/Delete), and specific field changes in Request/Response.
