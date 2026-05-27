---
name: extend-task-in-plan
description: Append a derivative task to an existing plan, after verifying it doesn't violate the plan's original Req. Trigger when the user asks to add follow-up work (補測試 / refactor / typo fix / 改風格 / 樣式調整 / 補欄位 / 補例外處理) to an established plan — typical phrasings: 「在 {plan} 加 task / 補 task / 衍生 task / 順手改 / 順便加」. When in doubt about triggering, prefer this skill — its core value is the Req-violation check, which silently degrades if skipped.
---

# extend-task-in-plan

This skill adds a **derivative task** to an existing plan document. It is designed for **post-implementation refinement scenarios** — adding tests, refactoring to match style preferences, improving SOLID compliance, or cleanup work — **without changing the plan's original requirements**.

The key invariant: the new task must serve the plan's original purpose, not introduce new scope.

## When to Use

Trigger when the user asks to add a task to an existing plan. Typical phrasings:

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

## Workflow

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

**If violates (B)** → Don't write to any file yet. Silently appending would expand the plan's scope, which defeats the skill's purpose. Surface the conflict:

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

### Step 5 — Append the task

After compatible classification (or user chose option (b)):

#### 5a. Append a detail block under `Task Implementation Details`

Use this structure:

```markdown
### {Next-ID} — {Short Title}

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
- **Dependency**: {prerequisite Task ID or `—`}
```

ID convention: follow the plan's existing pattern (e.g., `R10` if previous tasks are `R1`–`R9`; `T15` if `T1`–`T14`).

#### 5b. Append a row to the `Task Progress Table` (at the end of the plan)

Append a row with columns: `ID | Task Description | Status | Dependency`. Default Status to `Todo`.

If the plan's existing table has additional columns (e.g., `引用`), match the existing schema rather than imposing a new one.

### Step 6 — Confirm

Report back to the user:

- New Task ID
- 1-line summary
- Plan file path that was modified
- Status set to `Todo` pending implementation

## Output Conventions

- **Traditional Chinese**: Plan content stays in Traditional Chinese, matching the existing plan's language. User-facing messages also in Traditional Chinese.
- **Match existing style**: If the plan has consistent formatting / wording across existing tasks, follow them.
- **Idempotent**: If a task with similar scope already exists, ask the user before duplicating.
- **No code changes**: This skill only edits the plan document. Code implementation is delegated to `implementation` skill or `implementation-agent` later.
- **One task per invocation (v1)**: If the user requests multiple tasks, handle them sequentially and confirm each. Future versions may batch.

## Examples

### Example 1 — Compatible task

**User**: 「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**:
1. Reads `docs/pxbox-26324_task_refactor.md` Background section
2. Identifies intent: 「測試重組，零行為變更，零生產碼動到」
3. Classifies as **Compatible** (typo fix, only test file attribute, no behavior change)
4. Appends new task `R10` (next ID after R9) with Current state / Goal / Steps
5. Appends `R10` row to Task Progress Table with `Status = Todo`, `Dependency = —`
6. Reports: 「✅ 已加入 R10 — 修正 `OrderQuantity.cs` 的 Trait typo」

### Example 2 — Violating task

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

### Example 3 — Ambiguous task

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
