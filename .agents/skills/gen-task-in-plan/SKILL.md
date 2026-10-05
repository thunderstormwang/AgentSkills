---
name: gen-task-in-plan
description: "Task generation for plan documents. Mode A — generates initial tasks after technical-design is confirmed. Mode B — appends derivative tasks after verifying they respect the original Req. Use when Design is confirmed and the user wants tasks, or requests follow-up work such as tests, refactoring, typo fixes, style adjustments, fields, or error handling under an existing plan. New or changed requirements belong to req-analysis; substantial unsettled technical choices belong to technical-design."
---

# gen-task-in-plan

This skill manages **Task generation** within a plan document. It operates in two modes:

- **Mode A — Initial Task Generation**: Triggered after all Design items are confirmed. Reads the Design section and breaks it down into atomic, implementable tasks referenced to their Design source.
- **Mode B — Derivative Task Addition**: Triggered when the user wants to add refinement, cleanup, or follow-up work to an existing plan. Performs a Req-violation check before appending.

The key invariant for Mode B: the new task must serve the plan's original purpose, not introduce new scope.

Before reading or updating a plan, read
[Plan Document Conventions](../_shared/plan-document.md), resolving the path
relative to this skill directory. Start from the entry plan, follow formal-body
links, and keep authoritative T/FT progress tables there even when bodies split.

---

## When to Use

**Mode A** — triggered when:

- 「Design 完成，生 Task」/ 「Phase 4」/ 「幫我從 Design 生成 Task」
- Continuing from technical-design after the applicable D items are confirmed

**Mode B** — triggered when:

- 「在 `{plan-name}` 加一個 task 做 `{X}`」
- 「`{plan}` 補一個 task 來 `{refactor / 補測試 / 改風格 / 修 typo}`」
- 「依 `{plan}` 衍生一個 task」
- 「`{plan}` 我想再加 task `{X}`」
- "Add a task to `{plan}` for `{X}`"

## When NOT to Use

- **New plan from scratch** → use `req-analysis`, then `technical-design`
- **Cross-plan / new-feature scope** → use `req-analysis` to confirm scope, then `technical-design`
- **Substantial optimization with unsettled technical choices** → use `technical-design` before generating FT tasks
- **Modifying existing tasks** (not adding) → direct `Edit` on the plan file
- **Standalone task without a parent plan** → write manually

---

## Mode A — Initial Task Generation

### Step 1 — Identify the plan

- If the user specifies the plan path, use it directly
- If only a plan name is given, search likely locations (`docs/`, repo root, etc.)
- If ambiguous or no match, ask the user before proceeding
- If given a split document, follow its backlink to the entry plan before reading gates or updating status

### Step 2 — Verify Design is complete

- Locate the **Design 進度表** in the plan
- Applicable D items must be `Done`, explicitly `Cancel`, or explicitly non-blocking `Pending` with recorded conditions
- If any required items are `Review` / `Todo` / `InProgress`, or `Pending` without a non-blocking agreement, notify the user and wait for confirmation

### Step 3 — Read and internalize Design

- Read all applicable Design sub-sections (D01, D02, ...) in full, following the plan's external formal-body links
- Do NOT rely solely on TIA for scope — the Design section is the authoritative spec at this stage
- Re-read actual code for any area that Design references but doesn't fully specify
- Read the confirmed validation strategy and any explicit user instructions scoped to these tasks. Carry them into Task generation; do not replace them with a conflicting default.

### Step 4 — Generate Task list

Follow:
- **Task block format** from `references/task-format.md` (Mode A template + shared constraints: one logical commit per task, no fixed file-count limit, validation included in each task, implementation code belongs here)
- **Ordering & category rules** from `references/task-guidelines.md` (actual dependencies determine order; category priorities, SQL filename, documentation-only API Summary)

**Mode A-specific rule:**
- Each Task MUST include a **Reference** field pointing to the Design ID(s) it implements.

**Self-check before notifying the user:**
- Every confirmed Design item included in this work is covered by ≥ 1 Task; do not create tasks for explicitly cancelled or deferred scope
- Every Task references a valid Design ID
- No Task content contradicts any Design content
- Dependencies are acyclic and correct
- Each task is a coherent change, not a fragment split merely to reduce file count
- Each task includes `Validation` matching the confirmed strategy; separate verification tasks have an independent purpose or require multiple tasks to be completed
Fix any gaps silently before presenting. Only notify the user once the self-check passes.

### Step 5 — Populate `## Task` section

Populate the existing `## Task` after `## Design` in the entry plan, creating
it only if absent. **Do NOT modify prior decisions.**
Keep bodies inline when readable, or use an agreed split Task document with
summaries and formal-body links retained here. The following table always stays
in the entry plan, not in the external body.

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
If formal Req/AC bodies are split, read them before classification; the entry
summary or opening blockquote is not a substitute for their full constraints.

### Step 3 — Classify the new task against the boundary

Before classifying, trace each relevant restriction to its source and applicability:

| Prior decision | Meaning | Handling a new task |
| :--- | :--- | :--- |
| Original Req / plan-wide constraint | A required behavior or an explicit prohibition that still applies | Respect it; a conflicting task requires the Step 4 scope-change decision |
| Earlier task's "not in this task" exclusion | A boundary for that task, not a permanent prohibition | Keep the earlier task unchanged; assess the newly requested work against the original Req |
| Accepted risk | A conscious acceptance under recorded conditions | Preserve the decision and conditions; do not automatically add mitigation tasks |

- Users may deliberately stage work or decide on further improvements after an earlier change. A new explicit request is not a contradiction merely because an earlier task excluded it, and the user need not justify changing their mind.
- Reassess the new request against the original Req, not solely an earlier task's exclusions or affected-file list. This does not authorize unsolicited work or silently amend the Req.
- If a restriction's applicability is unclear, surface that ambiguity rather than treating a local exclusion as a plan-wide constraint.
- Revisit an accepted risk only when new evidence or the proposed change alters its consequences or acceptance conditions. Explain what changed; do not turn an unchanged accepted risk back into a blocker or an automatic compensation, replay, or offset-adjustment task.

**Heuristic**: ask "does this task change *what* the plan delivers, or just *how* it's achieved?" Changing *what* (different outcome, new feature, modified spec) → violates. Changing *how* (better tests, cleaner code, same outcome) → compatible. When the answer depends on assumptions about future state (e.g. "the test might fail and force a prod change"), treat as ambiguous and surface to the user.

Classify as one of three buckets:

**A. Compatible** — refines / extends without changing what the plan delivers:
- Add a missing test for an already-implemented feature
- Internal refactor to match style / SOLID without changing behavior
- Rename, comment cleanup, formatting
- Move a test between layers (Service ↔ Handler) without changing what is tested
- Fix typo in test attribute / docstring
- Add a Trait / Category attribute for test classification
- Newly requested internal improvements that an earlier task deferred, provided they still satisfy the original Req

**B. Violates** — introduces scope beyond the plan's intent:
- Changes a test's expected value (changes spec)
- Adds a new business rule or behavior
- Modifies production code beyond what the plan permits
- Touches files / domains explicitly excluded by the original Req or a plan-wide constraint, not merely omitted from an earlier task

**C. Ambiguous** — classification depends on assumptions about future state, or sits on the boundary:
- Test added for an edge case where prod behavior is unclear (might force prod change → would violate)
- Rename a public-facing API (might be in plan scope, might not — depends on plan)
- Optimize something that might cross plan boundary (e.g. perf tweak that touches production code allowed by "test-only" plan)
- Pattern alignment that could be interpreted as either style polish (compatible) or design change (violates)

### Step 4 — Branch on classification

**If compatible (A)** → proceed to Step 5 for straightforward work. If the
requested optimization has substantial unsettled design choices, first use
`technical-design` under the confirmed Req and return after Design confirmation.

**If violates (B)** → Don't write to any file yet. Surface the conflict:

- Quote the specific Req / Background statement being violated
- Explain why the new task violates it
- Offer two options:
  - **(a)** Open a new plan file for this scope (recommend an appropriate name)
  - **(b)** Explicitly amend the original plan's Req to include this scope (user approves scope expansion in-plan)

Wait for the user's decision before proceeding.
If the decision changes requirements, hand off to `req-analysis` for formal
Req confirmation, then `technical-design` for applicable design decisions;
scope-change permission alone is not a confirmed implementation specification.

**If ambiguous (C)** → Don't write to any file yet. Surface the ambiguity:

- State the two possible interpretations (one leading to compatible, one to violation)
- Explain the assumption each interpretation depends on
- Offer the user to either (a) commit to the compatible interpretation with explicit assumption, (b) treat as violation and choose new plan / amend Req

Wait for the user's decision before proceeding.

### Step 5 — Write the follow-up tasks and plan index

Keep small FT bodies inline under the entry plan's Task section. Use a separate
follow-up file when the detail is large or the user selects one. In either case,
keep the authoritative FT progress table in the entry plan.

**Task block format:** Use the **Mode B template** in `references/task-format.md`. Shared constraints apply (one logical commit per task, no fixed file-count limit, validation included in each task). Read the confirmed validation strategy and any explicit user instructions scoped to the new tasks before writing them.

**Mode B-specific rules:**
- One invocation may generate **multiple FT tasks** with dependencies (e.g., FT01 updates a contract and its callers, FT02 adds dependent behavior; both include their own validation). Express ordering via the `Dependency` field.
- **No preset category order** — follow-up work is too varied to pre-order (補測試 / 改文件 / 純改生產碼…). As in Mode A, actual dependencies determine order; the AI surfaces the proposed order to the user.

#### 5a. Determine the body location

1. Reuse the agreed inline or external destination. If splitting, **extract the jira ticket prefix** by stripping `_plan.md` from the original plan filename:
   - `docs/pxbox-26324_plan.md` → ticket prefix: `pxbox-26324`
2. When splitting, **search** the same directory for existing `{ticket-prefix}_ft_*.md` files.
3. **If existing FT files are found and no destination is agreed** — ask whether to append inline, use an existing file, or create a new one.
4. **If a new external body is selected** — ask for the `{XXX}` label unless already specified:
   - Suggest `01` as the default
   - User may provide a descriptive label instead (e.g., `refactor`)
   - Final path: `{same-directory}/{ticket-prefix}_ft_{XXX}.md`
   - If the original name does not follow the example pattern, agree on a suitable prefix rather than inventing a ticket.

#### 5b. If using a new external body — create it

Write the file with this header (use a relative path back to the original plan):

```markdown
# Follow-up Tasks

> 本檔案為 [{original-plan-filename}](./{original-plan-filename}) 的衍生任務清單。
```

#### 5c. Assign the next FT ID

Mode B IDs always use the `FT` prefix (e.g., `FT01`, `FT02`), regardless of the original plan's ID pattern. Check all FT tables and indexed bodies under the entry plan for the highest number; if none exists, start at `FT01`. Do not restart numbering for each split file.

#### 5d. Append the task detail block to the chosen body location

Use the **Mode B template** from `references/task-format.md`. Field order: `Current state` → `Goal` → `Dependency` → `Target` → `Implementation Details` → `Validation` → `Test File (DoD)` (when adding or modifying tests) → `Affected Files`.

When prior exclusions or accepted risks are relevant, use `Current state` / `Goal` and the implementation details to identify what was deferred, what is newly requested, and which acceptance conditions remain applicable. Reference existing decisions rather than rewriting earlier tasks or duplicating a long discussion history.

#### 5e. Append a row to the Follow-up Task 進度表 in the entry plan

If the table does not exist yet, add it under Task's follow-up subsection in the
entry plan, or in an existing indexed Follow-up Task extension:

```markdown
### Follow-up Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| FT01 | [Task 名稱] | — | — | Todo |
```

If it already exists, append a new row. Do not duplicate the table in the
external body; migrate an affected legacy table according to the shared rules.

#### 5f. Keep the original plan's Task index up to date

- Keep FT summaries, dependencies, progress rows, and external-body links under `## Task`
- Retain an existing `## Follow-up Task` as an indexed Task extension
- For an external body, link the relevant task headings and keep its backlink to the entry plan

Section format:

```markdown
### Follow-up Tasks

> 衍生任務清單：
> - FT01 [Task purpose](./{ticket-prefix}_ft_01.md#ft01-task-purpose) — Dependency: None
```

### Step 6 — Confirm

Report back to the user:

- New Task IDs (e.g., `FT01`, or a range like `FT01`–`FT03` when multiple)
- 1-line summary per task
- Entry plan path and the inline or external body location that was written to
- Task index and authoritative FT progress table updated in the entry plan
- Status set to `Todo` for all new tasks pending implementation

---

## Output Conventions

- **Traditional Chinese**: Plan content stays in Traditional Chinese, matching the existing plan's language. User-facing messages also in Traditional Chinese.
- **Match existing style**: If the plan has consistent formatting / wording across existing tasks, follow them.
- **Idempotent**: If a task with similar scope already exists, ask the user before duplicating.
- **No code changes**: This skill only edits plan documents. Code implementation is handled by `implementation`, or `implementation-agent` when explicitly requested.
- **Mode B — Multiple tasks allowed**: One invocation may add several FT tasks with dependencies. Each task must individually pass the Step 3 classification.
- **Both modes — Granularity and validation self-check**: Follow the shared rules in `references/task-format.md`. Every task must have a clear purpose, a complete affected-file list, and a `Validation` field. Keep implementation and its corresponding validation together by default; do not force a separate test task. Fix inconsistencies before presenting.

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
3. Generates T01–T18 ordered by actual dependencies, with each implementation task including its corresponding validation
4. Appends `## Task` section with all tasks and Task 進度表
5. Reports: 「✅ 已生成 18 個 Task (T01–T18)，進度表已附於 Design 之後」

---

### Example 2 — Mode B: Compatible task

**User**: 「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**:
1. Reads `docs/pxbox-26324_task_refactor.md` Background section
2. Identifies intent: 「測試重組，零行為變更，零生產碼動到」
3. Classifies as **Compatible** (typo fix, only test file attribute, no behavior change)
4. User chooses a separate FT body and confirms label `01` → creates `docs/pxbox-26324_ft_01.md` with a backlink to the original plan
5. Appends `FT01` task detail block to `docs/pxbox-26324_ft_01.md`
6. Appends `FT01` row to Follow-up Task 進度表 in the original plan, not the external body
7. Updates the original plan's Task index with FT01's purpose and body link
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

### Example 5 — Earlier task scope is not a permanent prohibition

**User**: 「前次只改快取、不改事件處理。現在我想合併事件接收；原始 Req 的業務規則與 API 契約維持不變。部署可能漏掉舊 Scopes 的風險已接受，不做補償。」

**Skill**:
1. Re-reads the original Req and checks the proposed event change against it.
2. Identifies "do not change event handling" as the earlier task's local scope, not an original Req prohibition.
3. If the change satisfies the original Req, classifies it as compatible and adds a newly requested follow-up task without rewriting the earlier task or requiring a new Req merely because priorities changed.
4. References the accepted deployment risk and its conditions; does not automatically add replay or offset-adjustment work. Raises the issue again only if new evidence changes those conditions or consequences.
5. If the original Req instead explicitly requires two independent subscriptions, follows Step 4 to obtain a scope-change decision before writing the task.
