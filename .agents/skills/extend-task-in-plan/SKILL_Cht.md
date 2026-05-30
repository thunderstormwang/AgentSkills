---
name: extend-task-in-plan
description: "plan 文件的 Task 生成工具。Mode A —— 在所有 Design 項目確認後生成初始 Task 列表（sd-design 的延續）。Mode B —— 在驗證不違反 plan 原始 Req 後，附加衍生 task。當 Design 完成且使用者想進行 Task 生成時觸發 Mode A；當使用者要求在已建立的 plan 加入後續工作（補測試 / refactor / typo fix / 改風格 / 樣式調整 / 補欄位 / 補例外處理）時觸發 Mode B。不確定是否觸發 Mode B 時，傾向觸發本 skill；它的核心價值是 Req 違反檢查，跳過的話會無聲失效。"
---

> **注意**：本檔為 `SKILL.md` 的繁體中文對照參考，**非執行用檔案**。skill router 實際載入的是英文版 `SKILL.md`；本檔僅供閱讀理解。兩者內容需保持同步。

# extend-task-in-plan

本 skill 管理 plan 文件內的 **Task 生成**，分為兩種模式：

- **Mode A — 初始 Task 生成**：在所有 Design 項目確認後觸發。讀取 Design 段落，拆解為有引用來源的原子級可實作任務。
- **Mode B — 衍生 Task 附加**：當使用者想在既有 plan 加入精修、清理或後續工作時觸發。附加前先做 Req 違反檢查。

Mode B 的關鍵不變量：新 task 必須服務於 plan 的原始目的，不可引入新的範疇。

---

## 何時使用

**Mode A** —— 當：

- 「Design 完成，生 Task」/ 「Phase 4」/ 「幫我從 Design 生成 Task」
- 在 sd-design 走完後，所有 D 項目皆為 Done

**Mode B** —— 當：

- 「在 `{plan-name}` 加一個 task 做 `{X}`」
- 「`{plan}` 補一個 task 來 `{refactor / 補測試 / 改風格 / 修 typo}`」
- 「依 `{plan}` 衍生一個 task」
- 「`{plan}` 我想再加 task `{X}`」
- "Add a task to `{plan}` for `{X}`"

## 何時不要使用

- **從零開始的新 plan** → 用 `sd-design` 或手寫
- **跨 plan / 新功能範疇** → 用 `sd-design`
- **修改既有 task**（非新增） → 直接 `Edit` plan 檔
- **沒有母 plan 的獨立 task** → 手寫

---

## Mode A — 初始 Task 生成

### Step 1 — 確認目標 plan

- 若使用者指定了 plan 路徑，直接使用
- 若只給 plan 名稱，搜尋可能位置（`docs/`、repo 根目錄等）
- 若模糊或找不到，先詢問使用者再繼續

### Step 2 — 確認 Design 已完成

- 定位 plan 內的 **Design 進度表**
- 所有 D 項目必須為 `Done` / `Cancel` / `Pending` 才能繼續
- 若仍有 `Review` / `Todo` 項目，通知使用者並等待確認

### Step 3 — 讀取並理解 Design

- 完整讀取所有 Design 子章節（D01、D02……）
- 不可僅依賴 TIA —— 此階段 Design 段落是權威規格
- 對 Design 有引用但未完整說明的區域，需重新讀實際程式碼

### Step 4 — 生成 Task 列表

依 `references/task-guidelines.md` 的順序（位於 `.agents/skills/extend-task-in-plan/references/task-guidelines.md`）：

1. **DB Schema 變更** —— SQL script task 優先
2. **Entity / Domain 變更** —— 核心業務結構
3. **API 合約變更** —— Request/Response model task
4. **API Summary** —— API 合約後立即附上的純文件 task
5. **Test Task** —— 獨立測試任務（Fail-First，置於實作之前）
6. **功能實作** —— 詳細邏輯，開發至測試通過

Task 限制：
- 每個 task = 一個邏輯 commit
- 預設 ≤ 3 個檔案（機械式修改可超出）
- 每個 task 必須包含 **Reference** 欄位，指向它所實作的 Design ID

**通知使用者前的自我檢查：**
- 每個非取消的 Design 項目都被 ≥ 1 個 Task 覆蓋
- 每個 Task 都引用有效的 Design ID
- Task 的內容不得與 Design 任何內容衝突
- 依賴關係無循環且正確
自行修正任何遺漏後再呈現。通過自我檢查後才通知使用者。

### Step 5 — 附加 `## Task` 章節

附加在 `## Design` 之後。**請勿修改之前的章節。**

以 **Task 進度表**結尾：

```markdown
### Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| T01 | [Task 名稱] | D01 | None | Todo |
| T02 | [Task 名稱] | D01, D02 | T01 | Todo |
```

### Step 6 — 確認回報

向使用者回報：
- 生成的 Task 總數與 ID 範圍
- 被修改的 plan 檔路徑

---

## Mode B — 衍生 Task 附加

### Step 1 — 確認目標 plan

- 若使用者指定了 plan 路徑，直接使用
- 若只給 plan 名稱，搜尋可能位置（`docs/`、repo 根目錄等）
- 若模糊或找不到，先詢問使用者再繼續

### Step 2 — 讀取 plan 的需求 / 意圖

定位並摘要 plan 的意圖段落。常見的段落名稱：

- `Req` / `Requirement` / `需求`
- `Background` / `背景`
- `Goal` / `目標`
- `執行策略` / `Strategy`
- 檔案開頭的 `>` 引言區塊

用 1-2 句向使用者重述 plan 的意圖。**這定義了新 task 必須遵守的邊界。**

### Step 3 — 對照邊界分類新 task

**判斷準則**：問「這個 task 改變的是 plan 交付的 *what*（什麼），還是只改變達成它的 *how*（怎麼做）？」改變 *what*（不同結果、新功能、修改規格）→ 違反。改變 *how*（更好的測試、更乾淨的程式碼、相同結果）→ 相容。若答案取決於對未來狀態的假設（例如「測試可能會失敗而迫使改動 prod」），視為模糊並提交使用者判斷。

分成三類：

**A. 相容（Compatible）** —— 精修 / 擴充而不改變 plan 交付的內容：
- 為已實作的功能補一個缺漏的測試
- 不改行為、為對齊風格 / SOLID 的內部 refactor
- 改名、註解清理、格式調整
- 在不改變測試內容的前提下，把測試在層級間搬移（Service ↔ Handler）
- 修正測試屬性 / docstring 的 typo
- 為測試分類加上 Trait / Category 屬性

**B. 違反（Violates）** —— 引入超出 plan 意圖的範疇：
- 改變測試的預期值（改變規格）
- 新增業務規則或行為
- 修改超出 plan 允許範圍的生產碼
- 觸及 plan 範圍外的檔案 / 領域

**C. 模糊（Ambiguous）** —— 分類取決於對未來狀態的假設，或落在邊界上：
- 為一個 prod 行為不明的邊界 case 補測試（可能迫使改 prod → 會變成違反）
- 改名一個對外的公開 API（可能在 plan 範圍內，也可能不在）
- 優化某個可能跨越 plan 邊界的東西（例如在「只動測試」的 plan 裡做一個會碰到生產碼的效能調整）
- 模式對齊，可能被解讀成風格美化（相容）或設計變更（違反）

### Step 4 — 依分類分支處理

**若相容（A）** → 進入 Step 5。

**若違反（B）** → 先不要寫任何檔案。把衝突浮現出來：

- 引用被違反的具體 Req / Background 段落
- 解釋為何新 task 違反它
- 提供兩個選項：
  - **(a)** 為此範疇開一個新 plan 檔（並建議合適的檔名）
  - **(b)** 明確修改原 plan 的 Req 以涵蓋此範疇（由使用者核可在原 plan 內擴張範圍）

等使用者決定後再繼續。

**若模糊（C）** → 先不要寫任何檔案。把模糊處浮現出來：

- 說明兩種可能的詮釋（一種導向相容、一種導向違反）
- 解釋每種詮釋各自依賴的假設
- 讓使用者選擇：(a) 在明確假設下採相容詮釋直接加，(b) 視為違反並選擇開新 plan / 修改 Req

等使用者決定後再繼續。

### Step 5 — 寫入衍生 task 檔案

Mode B 的 task 一律寫入**獨立的衍生檔案**，而不是原始 plan。這讓原始 plan 在接近 ~1000 行時仍保持可讀性。

#### 5a. 決定衍生 task 檔案路徑

1. **擷取 Jira ticket 前綴**：從原始 plan 檔名去掉 `_plan.md` 尾綴：
   - `docs/pxbox-26324_plan.md` → ticket 前綴：`pxbox-26324`
2. **搜尋**同一目錄內是否有 `{ticket-prefix}_ft_*.md` 檔案。
3. **若找到現有 FT 檔案** —— 列出後詢問使用者：附加到現有檔案，還是建立新檔？
4. **若無 FT 檔案（或使用者選擇建立新檔）** —— 詢問使用者 `{XXX}` 標籤：
   - 預設建議 `01`
   - 使用者可改用描述性名稱（例如 `refactor`）
   - 最終路徑：`{同一目錄}/{ticket-prefix}_ft_{XXX}.md`

#### 5b. 若衍生檔案不存在 —— 建立它

以此標題寫入檔案（使用指向原始 plan 的相對路徑）：

```markdown
# Follow-up Tasks

> 本檔案為 [{原始 plan 檔名}](./{原始 plan 檔名}) 的衍生任務清單。
```

#### 5c. 指派下一個 FT ID

Mode B 的 task ID 一律使用 `FT` 前綴（例如 `FT01`、`FT02`），不論原始 plan 採用何種 ID 模式。查看衍生檔案中現有的 Follow-up Task 進度表，取最大 `FT` 編號；若無，從 `FT01` 開始。

#### 5d. 在衍生檔案末尾附加 task 細節區塊

```markdown
### FT{NN} — {Short Title}

- **Current state**: {現況 / 缺什麼 —— 1-2 行}
- **Goal**: {這個 task 達成什麼 —— 1-2 行}
- **Approach**: {如何實作 —— 2-4 行或條列}
- **Steps**:
  1. {步驟 1}
  2. {步驟 2}
  ...
- **Affected Files**:
  - `{path 1}`
  - `{path 2}`
- **Dependency**: {前置 FT ID 或 `—`}
```

#### 5e. 在衍生檔案的 Follow-up Task 進度表中附加一列

若進度表尚不存在，在最後一個 task 區塊之後新增：

```markdown
### Follow-up Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| FT01 | [Task 名稱] | — | — | Todo |
```

若進度表已存在，附加新的一列。

#### 5f. 維護原始 plan 的 `## Follow-up Task` 章節

- 若章節不存在：在 `## Task` 之後附加
- 若存在但當前 FT 檔尚未列出：補上引用行
- 若存在且 FT 檔已列出（附加到既有檔案）：不需更動

章節格式：

```markdown
## Follow-up Task

> 衍生任務清單：
> - [{ticket-prefix}_ft_01.md](./{ticket-prefix}_ft_01.md)
> - [{ticket-prefix}_ft_refactor.md](./{ticket-prefix}_ft_refactor.md)
```

### Step 6 — 確認回報

向使用者回報：

- 新 Task ID（`FT{NN}`）
- 一行摘要
- 寫入的衍生檔案路徑
- 原始 plan 的 `## Follow-up Task` 章節是新建立還是已存在
- Status 設為 `Todo`，待實作

---

## 輸出慣例

- **繁體中文**：plan 內容維持繁體中文，與既有 plan 語言一致。對使用者的訊息也用繁體中文。
- **沿用既有風格**：若 plan 在既有 task 間有一致的格式 / 用詞，跟著走。
- **冪等（Idempotent）**：若已存在範疇相似的 task，先詢問使用者再決定是否重複建立。
- **不改程式碼**：本 skill 只編輯 plan 文件。程式碼實作之後交給 `implementation` skill 或 `implementation-agent`。
- **Mode B — 每次呼叫一個 task（v1）**：若使用者一次要求多個 task，依序處理並逐一確認。

---

## 範例

### 範例 1 — Mode A：生成初始 Task 列表

**使用者**：「Design 都確認了，幫我生 Task」

**Skill**：
1. 讀 plan 的 Design 進度表 —— 所有 D01–D06 皆為 `Done`
2. 完整讀取 D01–D06 內容
3. 依 task 順序（DB → Entity → API → Test → Implementation）生成 T01–T18
4. 附加 `## Task` 章節與 Task 進度表
5. 回報：「✅ 已生成 18 個 Task (T01–T18)，進度表已附於 Design 之後」

---

### 範例 2 — Mode B：相容 task

**使用者**：「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**：
1. 讀 `docs/pxbox-26324_task_refactor.md` Background 段
2. 辨識意圖：「測試重組，零行為變更，零生產碼動到」
3. 分類為 **相容**（typo 修正、只動測試檔屬性、無行為變更）
4. 找不到現有 `pxbox-26324_ft_*.md`，詢問使用者 `{XXX}` 標籤；使用者確認 `01` → 建立 `docs/pxbox-26324_ft_01.md` 並寫入引用原始 plan 的標題
5. 在 `docs/pxbox-26324_ft_01.md` 附加 `FT01` task 細節區塊
6. 在衍生檔案的 Follow-up Task 進度表附加 `FT01` 列
7. 在原始 plan 附加 `## Follow-up Task` 章節，引用 `pxbox-26324_ft_01.md`
8. 回報：「✅ 已加入 FT01 — 修正 `OrderQuantity.cs` 的 Trait typo（寫入 docs/pxbox-26324_ft_01.md）」

### 範例 3 — Mode B：違反 task

**使用者**：「在 `task_refactor.md` 加一個 task 改 `CalculateDiscountService` 加新功能 X」

**Skill**：
1. 讀 `docs/pxbox-26324_task_refactor.md` Background 段
2. 辨識意圖：「測試重組，**零行為變更**，**生產碼完全不動**」
3. 判斷準則檢查：「plan 交付什麼？」= 測試結構重組。新 task 改 prod 加新功能 = 改變 *what* → **違反**
4. 把衝突浮現出來（不寫檔）：

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

5. 等使用者決定。不修改任何檔案。

### 範例 4 — Mode B：模糊 task

**使用者**：「在 `task_refactor.md` 加一個 task：對 `CheckPromoteCondition` 補一個測試覆蓋 `null` 輸入的邊界 case」

**Skill**：
1. 讀 `docs/pxbox-26324_task_refactor.md` Background 段
2. 辨識意圖：「測試重組，零行為變更，零生產碼動到」
3. 判斷準則檢查：補測試本身屬於改變 *how*（相容），但 `null` case 是否會曝出 prod 沒處理（迫使後續修 prod）取決於 prod 現況 —— 依賴假設 → **模糊**
4. 把模糊處浮現出來（不寫檔）：

   > ⚠️ 這個 task 在邊界上：
   >
   > - **若 `CheckPromoteCondition` 對 `null` 已有處理** → 新測試只是補覆蓋，相容，可加入 `task_refactor.md`
   > - **若 prod 未處理 `null`** → 測試會紅，後續需修 prod，這會違反「零生產碼動到」
   >
   > 兩種處理方式：
   > - **(a)** 假設 prod 已處理 — 直接加 task，若實作測試紅再回頭討論
   > - **(b)** 預期 prod 未處理 — 開新 plan 涵蓋「補測試 + 修 prod」，把這個 task 放新 plan
   >
   > 你怎麼判斷？

5. 等使用者決定。不修改任何檔案。
