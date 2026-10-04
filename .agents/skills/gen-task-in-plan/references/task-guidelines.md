# Mode A — Task Ordering & Category Rules

These guidelines apply to **Mode A — Initial Task Generation** of the `gen-task-in-plan` skill. They cover ordering and category-specific rules for tasks generated from Design.

For the **task block format** (fields, templates, shared constraints), see `task-format.md`.

---

## Task Ordering (Prioritization)

Order tasks by actual prerequisites. Use these category priorities where applicable, not as mandatory separate tasks or a fixed pipeline. Keep a coherent contract/implementation change and its validation together when they must take effect together:

1. **DB Schema Changes**: Prioritize SQL script generation when later changes depend on the schema.
2. **Entity / Domain Changes**: Core business logic and data structures.
3. **API Skeletons & Fields**: Define Request/Response models and Controller endpoints first.
4. **API Summary**: Provide the frontend summary immediately after API contracts are defined (documentation-only task).
5. **Functional Implementation with Validation**: Include the corresponding test additions/updates and applicable checks in each implementation task, following the confirmed strategy.

Writing tests first may happen within the implementation task; it does not require an independent Verification Task. Create a separate verification task only for an independent verification purpose or checks that require multiple tasks to be completed, and record its actual dependencies. See `task-format.md` for the shared validation rules.

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
