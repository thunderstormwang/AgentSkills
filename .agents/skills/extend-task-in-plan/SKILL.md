---
name: extend-task-in-plan
description: "Task generation for plan documents. Mode A — generates the initial Task list after all Design items are confirmed (continuation from sd-design). Mode B — appends a derivative task after verifying it doesn't violate the plan's original Req. Trigger Mode A when Design is Done and user wants to proceed to Task generation; trigger Mode B when user asks to add follow-up work (補測試 / refactor / typo fix / 改風格 / 樣式調整 / 補欄位 / 補例外處理) to an established plan. When in doubt about triggering Mode B, prefer this skill; its core value is the Req-violation check, which silently degrades if skipped."
---

# extend-task-in-plan

This skill manages **Task generation** within a plan document. It operates in two modes:

- **Mode A — Initial Task Generation**: Triggered after all Design items are confirmed. Reads the Design section and breaks it down into atomic, implementable tasks referenced to their Design source.
- **Mode B — Derivative Task Addition**: Triggered when the user wants to add refinement, cleanup, or follow-up work to an existing plan. Performs a Req-violation check before appending.

The key invariant for Mode B: the new task must serve the plan's original purpose, not introduce new scope.

---

## When to Use

**Mode A** — triggered when:

- 「Design 完成，生 Task」/ 「Phase 4」/ 「幫我從 Design 生成 Task」
- Continuing from sd-design after all D items are Done

**Mode B** — triggered when:

- 「在 `{plan-name}` 加一個 task 做 `{X}`」
- 「`{plan}` 補一個 task 來 `{refactor / 補測試 / 改風格 / 修 typo}`」
- 「依 `{plan}` 衍生一個 task」
- 「`{plan}` 我想再加 task `{X}`」
- "Add a task to `{plan}` for `{X}`"

## When NOT to Use

- **New plan from scratch** → use `sd-design` or write manually
- **Cross-plan / new-feature scope** → use `sd-design`
- **Modifying existing tasks** (not adding) → direct `Edit` on the plan file
- **Standalone task without a parent plan** → write manually

---

## Mode A — Initial Task Generation

### Step 1 — Identify the plan

- If the user specifies the plan path, use it directly
- If only a plan name is given, search likely locations (`docs/`, repo root, etc.)
- If ambiguous or no match, ask the user before proceeding

### Step 2 — Verify Design is complete

- Locate the **Design 進度表** in the plan
- All D items must be `Done` / `Cancel` / `Pending` before proceeding
- If any items are still `Review` / `Todo`, notify the user and wait for confirmation

### Step 3 — Read and internalize Design

- Read all Design sub-sections (D01, D02, ...) in full
- Do NOT rely solely on TIA for scope — the Design section is the authoritative spec at this stage
- Re-read actual code for any area that Design references but doesn't fully specify

### Step 4 — Generate Task list

Follow the ordering from `references/task-guidelines.md` (located at `.agents/skills/extend-task-in-plan/references/task-guidelines.md`):

1. **DB Schema changes** — SQL script tasks first
2. **Entity / Domain changes** — core business structures
3. **API Contract changes** — Request/Response model tasks
4. **API Summary** — documentation-only task immediately after API contracts
5. **Test Tasks** — independent test tasks (Fail-First, placed before implementation)
6. **Functional Implementation** — detailed logic, developed until tests pass

Task constraints:
- Each task = one logical commit
- Default ≤ 3 files per task (mechanical edits may span more)
- Each task MUST include a **Reference** field pointing to the Design ID(s) it implements

**Self-check before notifying the user:**
- Every non-Cancelled Design item is covered by ≥ 1 Task
- Every Task references a valid Design ID
- No Task content contradicts any Design content
- Dependencies are acyclic and correct
Fix any gaps silently before presenting. Only notify the user once the self-check passes.

### Step 5 — Append `## Task` section

Append after `## Design`. **Do NOT modify prior sections.**

End with **Task 進度表**:

```markdown
### Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| T01 | [Task 名稱] | D01 | None | Todo |
| T02 | [Task 名稱] | D01, D02 | T01 | Todo |
```

### Step 6 — Confirm

Report back to the user:
- Total tasks generated and their IDs
- Plan file path that was modified

---

## Mode B — Derivative Task Addition

### Step 1 — Identify the target plan

- If the user specifies the plan path, use it directly
- If only a plan name is given, search likely locations (`docs/`, repo root, etc.)
- If ambiguous or no match, ask the user before proceeding

### Step 2 — Read the plan's requirement / intent

Locate and summarize the plan's intent section. Common section names:

- `Req` / `Requirement` / `需求`
- `Background` / `背景`
- `Goal` / `目標`
- `執行策略` / `Strategy`
- The opening `>` blockquote at the file top

Restate the plan's intent in 1-2 sentences for the user. **This defines the boundary the new task must respect.**

### Step 3 — Classify the new task against the boundary

**Heuristic**: ask "does this task change *what* the plan delivers, or just *how* it's achieved?" Changing *what* (different outcome, new feature, modified spec) → violates. Changing *how* (better tests, cleaner code, same outcome) → compatible. When the answer depends on assumptions about future state (e.g. "the test might fail and force a prod change"), treat as ambiguous and surface to the user.

Classify as one of three buckets:

**A. Compatible** — refines / extends without changing what the plan delivers:
- Add a missing test for an already-implemented feature
- Internal refactor to match style / SOLID without changing behavior
- Rename, comment cleanup, formatting
- Move a test between layers (Service ↔ Handler) without changing what is tested
- Fix typo in test attribute / docstring
- Add a Trait / Category attribute for test classification

**B. Violates** — introduces scope beyond the plan's intent:
- Changes a test's expected value (changes spec)
- Adds a new business rule or behavior
- Modifies production code beyond what the plan permits
- Touches files / domains not in the plan's stated scope

**C. Ambiguous** — classification depends on assumptions about future state, or sits on the boundary:
- Test added for an edge case where prod behavior is unclear (might force prod change → would violate)
- Rename a public-facing API (might be in plan scope, might not — depends on plan)
- Optimize something that might cross plan boundary (e.g. perf tweak that touches production code allowed by "test-only" plan)
- Pattern alignment that could be interpreted as either style polish (compatible) or design change (violates)

### Step 4 — Branch on classification

**If compatible (A)** → proceed to Step 5.

**If violates (B)** → Don't write to any file yet. Surface the conflict:

- Quote the specific Req / Background statement being violated
- Explain why the new task violates it
- Offer two options:
  - **(a)** Open a new plan file for this scope (recommend an appropriate name)
  - **(b)** Explicitly amend the original plan's Req to include this scope (user approves scope expansion in-plan)

Wait for the user's decision before proceeding.

**If ambiguous (C)** → Don't write to any file yet. Surface the ambiguity:

- State the two possible interpretations (one leading to compatible, one to violation)
- Explain the assumption each interpretation depends on
- Offer the user to either (a) commit to the compatible interpretation with explicit assumption, (b) treat as violation and choose new plan / amend Req

Wait for the user's decision before proceeding.

### Step 5 — Write to the follow-up task file

Mode B tasks are always written to a **separate follow-up file**, not the original plan. This keeps the original plan readable as it approaches ~1000 lines.

**Task constraints (same as Mode A):**
- Each task = one logical commit
- Default ≤ 3 files per task (mechanical edits may span more)
- One invocation may generate **multiple FT tasks** with dependencies (e.g., FT01 = test task, FT02 = implementation with `Dependency: FT01`). Express ordering via the `Dependency` field.

#### 5a. Determine the follow-up file path

1. **Extract the jira ticket prefix** by stripping `_plan.md` from the original plan filename:
   - `docs/pxbox-26324_plan.md` → ticket prefix: `pxbox-26324`
2. **Search** the same directory for existing `{ticket-prefix}_ft_*.md` files.
3. **If existing FT files are found** — list them and ask the user: append to an existing file, or create a new one?
4. **If no FT files exist (or user chooses to create a new file)** — ask the user for the `{XXX}` label:
   - Suggest `01` as the default
   - User may provide a descriptive label instead (e.g., `refactor`)
   - Final path: `{same-directory}/{ticket-prefix}_ft_{XXX}.md`

#### 5b. If the follow-up file does not exist — create it

Write the file with this header (use a relative path back to the original plan):

```markdown
# Follow-up Tasks

> 本檔案為 [{original-plan-filename}](./{original-plan-filename}) 的衍生任務清單。
```

#### 5c. Assign the next FT ID

Mode B IDs always use the `FT` prefix (e.g., `FT01`, `FT02`), regardless of the original plan's ID pattern. Check the existing Follow-up Task 進度表 in the follow-up file for the highest `FT` number; if none exists, start at `FT01`.

#### 5d. Append the task detail block to the follow-up file

```markdown
### FT01 [Task Name]

- **Current state**: {what exists / what's missing — 1-2 lines}
- **Goal**: {what this task achieves — 1-2 lines}
- **Approach**: {how to implement — 2-4 lines or bullet list}
- **Steps**:
  1. {step 1}
  2. {step 2}
  ...
- **Affected Files**:
  - `{path 1}`
  - `{path 2}`
- **Dependency**: {prerequisite FT ID or `—`}
```

#### 5e. Append a row to the Follow-up Task 進度表 in the follow-up file

If the table does not exist yet, add it after the last task block:

```markdown
### Follow-up Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| FT01 | [Task 名稱] | — | — | Todo |
```

If it already exists, append a new row.

#### 5f. Keep the original plan's `## Follow-up Task` section up to date

- If the section does not exist: append it after `## Task`
- If it exists but the current FT file is not yet listed: add a reference line for it
- If it exists and the current FT file is already listed (appending to existing): no change

Section format:

```markdown
## Follow-up Task

> 衍生任務清單：
> - [{ticket-prefix}_ft_01.md](./{ticket-prefix}_ft_01.md)
> - [{ticket-prefix}_ft_refactor.md](./{ticket-prefix}_ft_refactor.md)
```

### Step 6 — Confirm

Report back to the user:

- New Task IDs (e.g., `FT01`, or a range like `FT01`–`FT03` when multiple)
- 1-line summary per task
- Follow-up file path that was written to
- Whether the original plan's `## Follow-up Task` section was created or already existed
- Status set to `Todo` for all new tasks pending implementation

---

## Output Conventions

- **Traditional Chinese**: Plan content stays in Traditional Chinese, matching the existing plan's language. User-facing messages also in Traditional Chinese.
- **Match existing style**: If the plan has consistent formatting / wording across existing tasks, follow them.
- **Idempotent**: If a task with similar scope already exists, ask the user before duplicating.
- **No code changes**: This skill only edits the plan document. Code implementation is delegated to `implementation` skill or `implementation-agent` later.
- **Mode B — Multiple tasks allowed**: One invocation may add several FT tasks with dependencies. Each task must individually pass the Step 3 classification.

---

## Progress Table

### Status Definitions

| Status | 說明 |
| :--- | :--- |
| `Todo` | 尚未進行 |
| `InProgress` | 進行中 |
| `Review` | 等待使用者確認（Req / Design 項目初始狀態） |
| `Done` | 完成 |
| `Cancel` | 取消不做 |
| `Pending` | 暫時擱置 |

T items and FT items both use the same status values. Initial status for all generated tasks is `Todo`.

---

## Examples

### Example 1 — Mode A: Generate initial Task list

**User**: 「Design 都確認了，幫我生 Task」

**Skill**:
1. Reads the plan's Design 進度表 — all D01–D06 are `Done`
2. Reads D01–D06 content in full
3. Generates T01–T18 following task ordering (DB → Entity → API → Test → Implementation)
4. Appends `## Task` section with all tasks and Task 進度表
5. Reports: 「✅ 已生成 18 個 Task (T01–T18)，進度表已附於 Design 之後」

---

### Example 2 — Mode B: Compatible task

**User**: 「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**:
1. Reads `docs/pxbox-26324_task_refactor.md` Background section
2. Identifies intent: 「測試重組，零行為變更，零生產碼動到」
3. Classifies as **Compatible** (typo fix, only test file attribute, no behavior change)
4. No existing `pxbox-26324_ft_*.md` found — asks user for `{XXX}` label; user confirms `01` → creates `docs/pxbox-26324_ft_01.md` with header referencing original plan
5. Appends `FT01` task detail block to `docs/pxbox-26324_ft_01.md`
6. Appends `FT01` row to Follow-up Task 進度表 in follow-up file
7. Appends `## Follow-up Task` section to original plan, referencing `pxbox-26324_ft_01.md`
8. Reports: 「✅ 已加入 FT01 — 修正 `OrderQuantity.cs` 的 Trait typo（寫入 docs/pxbox-26324_ft_01.md）」

### Example 3 — Mode B: Violating task

**User**: 「在 `task_refactor.md` 加一個 task 改 `CalculateDiscountService` 加新功能 X」

**Skill**:
1. Reads `docs/pxbox-26324_task_refactor.md` Background section
2. Identifies intent: 「測試重組，**零行為變更**，**生產碼完全不動**」
3. Heuristic check: 「what does the plan deliver?」 = 測試結構重組。新 task 改 prod 加新功能 = 改變 *what* → **Violates**
4. Surfaces the conflict (no file written):

   > ⚠️ 這個 task 違反 `task_refactor.md` 的原 Req：
   >
   > > 「測試重組，零行為變更，零生產碼動到」
   >
   > 新增「改 `CalculateDiscountService` 加新功能 X」會動生產碼且加新功能。建議：
   >
   > - **(a)** 開新 plan `docs/feature-x.md`（將新功能 X 視為獨立需求）
   > - **(b)** 修改 `task_refactor.md` 的 Background 段，把範圍擴張到「允許動生產碼 + 加新功能 X」
   >
   > 請選擇？

5. Waits for user decision. Does not modify any file.

### Example 4 — Mode B: Ambiguous task

**User**: 「在 `task_refactor.md` 加一個 task：對 `CheckPromoteCondition` 補一個測試覆蓋 `null` 輸入的邊界 case」

**Skill**:
1. Reads `docs/pxbox-26324_task_refactor.md` Background section
2. Identifies intent: 「測試重組，零行為變更，零生產碼動到」
3. Heuristic check: 補測試本身屬於改變 *how* (compatible)，但 `null` case 是否會曝出 prod 沒處理（迫使後續修 prod）取決於 prod 現況 — assumption-dependent → **Ambiguous**
4. Surfaces the ambiguity (no file written):

   > ⚠️ 這個 task 在邊界上：
   >
   > - **若 `CheckPromoteCondition` 對 `null` 已有處理** → 新測試只是補覆蓋，compatible，可加入 `task_refactor.md`
   > - **若 prod 未處理 `null`** → 測試會紅，後續需修 prod，這會違反「零生產碼動到」
   >
   > 兩種處理方式：
   > - **(a)** 假設 prod 已處理 — 直接加 task，若實作測試紅再回頭討論
   > - **(b)** 預期 prod 未處理 — 開新 plan 涵蓋「補測試 + 修 prod」，把這個 task 放新 plan
   >
   > 你怎麼判斷？

5. Waits for user decision. Does not modify any file.
