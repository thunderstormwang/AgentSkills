---
name: gen-task-in-plan
description: "plan 文件的 Task 生成工具。Mode A —— 在 technical-design 確認後生成初始任務。Mode B —— 在驗證符合原始 Req 後附加衍生任務。Design 已確認且使用者想生成任務，或在既有 plan 要求測試、重構、修 typo、風格調整、欄位或例外處理等後續工作時使用。新增或變更需求屬於 req-analysis；尚未定案的較大技術選擇屬於 technical-design。"
---

> **注意**：本檔為 `SKILL.md` 的繁體中文對照參考，**非執行用檔案**。skill router 實際載入的是英文版 `SKILL.md`；本檔僅供閱讀理解。兩者內容需保持同步。

# gen-task-in-plan

本 skill 管理 plan 文件內的 **Task 生成**，分為兩種模式：

- **Mode A — 初始 Task 生成**：在所有 Design 項目確認後觸發。讀取 Design 段落，拆解為有引用來源的原子級可實作任務。
- **Mode B — 衍生 Task 附加**：當使用者想在既有 plan 加入精修、清理或後續工作時觸發。附加前先做 Req 違反檢查。

Mode B 的關鍵不變量：新 task 必須服務於 plan 的原始目的，不可引入新的範疇。

讀取或更新 plan 前，先閱讀
[Plan 文件規範](../_shared/plan-document.md)，
路徑相對於此 skill 目錄解析。
從入口 plan 開始，沿正式正文連結讀取；
即使正文拆分，權威 T／FT 進度表也保留在入口。

---

## 何時使用

**Mode A** —— 當：

- 「Design 完成，生 Task」/ 「Phase 4」/ 「幫我從 Design 生成 Task」
- 在 technical-design 走完後，適用的 D 項目皆已確認

**Mode B** —— 當：

- 「在 `{plan-name}` 加一個 task 做 `{X}`」
- 「`{plan}` 補一個 task 來 `{refactor / 補測試 / 改風格 / 修 typo}`」
- 「依 `{plan}` 衍生一個 task」
- 「`{plan}` 我想再加 task `{X}`」
- "Add a task to `{plan}` for `{X}`"

## 何時不要使用

- **從零開始的新 plan** → 用 `req-analysis`，再用 `technical-design`
- **跨 plan / 新功能範疇** → 用 `req-analysis` 確認範圍，再用 `technical-design`
- **尚有未定案技術選擇的較大優化** → 生成 FT 任務前先用 `technical-design`
- **修改既有 task**（非新增） → 直接 `Edit` plan 檔
- **沒有母 plan 的獨立 task** → 手寫

---

## Mode A — 初始 Task 生成

### Step 1 — 確認目標 plan

- 若使用者指定了 plan 路徑，直接使用
- 若只給 plan 名稱，搜尋可能位置（`docs/`、repo 根目錄等）
- 若模糊或找不到，先詢問使用者再繼續
- 提供拆分文件時，先沿回連找到入口 plan，再讀 gate 或更新狀態

### Step 2 — 確認 Design 已完成

- 定位 plan 內的 **Design 進度表**
- 適用 D 項目必須為 `Done`、明確 `Cancel`，或已記錄條件且明確非阻塞的 `Pending`
- 必要項目仍為 `Review`／`Todo`／`InProgress`，或 `Pending` 未有非阻塞約定時，通知使用者並等待確認

### Step 3 — 讀取並理解 Design

- 完整讀取所有適用 Design 子章節（D01、D02……），沿 plan 的外部正式正文連結讀取
- 不可僅依賴 TIA —— 此階段 Design 段落是權威規格
- 對 Design 有引用但未完整說明的區域，需重新讀實際程式碼
- 讀取已確認的驗證策略，以及明確限定於這些 task 的使用者指示。生成 Task 時須承接，不以衝突的預設取代。

### Step 4 — 生成 Task 列表

依下列兩份 reference：
- **Task 區塊格式**：見 `references/task-format.md`（Mode A 範本 + 共用限制：每個 task 一個邏輯 commit、無固定檔案數限制、每個 task 包含驗證、實作碼歸 Task）
- **排序與類別規則**：見 `references/task-guidelines.md`（依實際依賴排序；類別優先原則、SQL 檔名、API Summary 純文件 task）

**Mode A 專屬規則：**
- 每個 Task 必須包含 **Reference** 欄位，指向它所實作的 Design ID。

**通知使用者前的自我檢查：**
- 每個納入本次工作的已確認 Design 項目都被 ≥ 1 個 Task 覆蓋；不為明確取消或暫緩範圍建立任務
- 每個 Task 都引用有效的 Design ID
- Task 的內容不得與 Design 任何內容衝突
- 依賴關係無循環且正確
- 每個 task 都是完整的改動，而不是只為減少檔案數而拆出的片段
- 每個 task 都包含符合已確認策略的 `Validation`；獨立驗證 task 須有獨立目的，或需要等待多個 task 完成
自行修正任何遺漏後再呈現。通過自我檢查後才通知使用者。

### Step 5 — 填入 `## Task` 章節

在入口 plan 的 `## Design` 之後填入既有 `## Task`，
僅在不存在時建立。**請勿修改之前的決策。**
正文可讀時留在檔案內，或使用已約定的拆分 Task 文件，
在此保留摘要與正式正文連結。
下列表格永遠留在入口 plan，不放在外部正文。

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
正式 Req／AC 正文拆分時，分類前先閱讀；
入口摘要或開頭引言不能代替其完整限制。

### Step 3 — 對照邊界分類新 task

分類前，先追查每項相關限制的來源與適用範圍：

| 先前決定 | 意義 | 新 task 的處理方式 |
| :--- | :--- | :--- |
| 原始 Req / 整份 plan 的限制 | 仍適用的必要行為或明確禁止事項 | 須遵守；牴觸的 task 必須經 Step 4 決定範圍變更 |
| 前次 task 的「本次不做」排除 | 該 task 的邊界，而非永久禁止 | 保留前次 task 不變；依原始 Req 評估新提出的工作 |
| 已接受風險 | 在記錄的條件下明確接受 | 保留決定與條件；不自動增加風險緩解 task |

- 使用者可能刻意分階段處理，或在前次改動後才決定進一步優化。新指示不會只因前次 task 排除該工作就構成矛盾，也不必要求使用者解釋為何改變想法。
- 依原始 Req 重新評估新指示，不只看前次 task 的排除項目或受影響檔案清單。這不代表授權未提出的工作，也不代表可默默修改 Req。
- 若限制的適用範圍不清楚，應提出這項模糊之處，不把局部排除當成整份 plan 的限制。
- 只有新證據或本次改動改變已接受風險的後果或接受條件時，才重新討論。說明改變之處；不要把未變的已接受風險重新當成阻擋條件，或自動增加補償、重播或 offset 調整 task。

**判斷準則**：問「這個 task 改變的是 plan 交付的 *what*（什麼），還是只改變達成它的 *how*（怎麼做）？」改變 *what*（不同結果、新功能、修改規格）→ 違反。改變 *how*（更好的測試、更乾淨的程式碼、相同結果）→ 相容。若答案取決於對未來狀態的假設（例如「測試可能會失敗而迫使改動 prod」），視為模糊並提交使用者判斷。

分成三類：

**A. 相容（Compatible）** —— 精修 / 擴充而不改變 plan 交付的內容：
- 為已實作的功能補一個缺漏的測試
- 不改行為、為對齊風格 / SOLID 的內部 refactor
- 改名、註解清理、格式調整
- 在不改變測試內容的前提下，把測試在層級間搬移（Service ↔ Handler）
- 修正測試屬性 / docstring 的 typo
- 為測試分類加上 Trait / Category 屬性
- 新提出、前次 task 暫緩的內部優化，前提是仍符合原始 Req

**B. 違反（Violates）** —— 引入超出 plan 意圖的範疇：
- 改變測試的預期值（改變規格）
- 新增業務規則或行為
- 修改超出 plan 允許範圍的生產碼
- 觸及原始 Req 或整份 plan 限制明確排除的檔案 / 領域，而不只是前次 task 未列出的部分

**C. 模糊（Ambiguous）** —— 分類取決於對未來狀態的假設，或落在邊界上：
- 為一個 prod 行為不明的邊界 case 補測試（可能迫使改 prod → 會變成違反）
- 改名一個對外的公開 API（可能在 plan 範圍內，也可能不在）
- 優化某個可能跨越 plan 邊界的東西（例如在「只動測試」的 plan 裡做一個會碰到生產碼的效能調整）
- 模式對齊，可能被解讀成風格美化（相容）或設計變更（違反）

### Step 4 — 依分類分支處理

**若相容（A）** → 直接的工作進入 Step 5。
要求的優化尚有較大的未定案設計選擇時，
先在已確認 Req 下使用 `technical-design`，Design 確認後再回來。

**若違反（B）** → 先不要寫任何檔案。把衝突浮現出來：

- 引用被違反的具體 Req / Background 段落
- 解釋為何新 task 違反它
- 提供兩個選項：
  - **(a)** 為此範疇開一個新 plan 檔（並建議合適的檔名）
  - **(b)** 明確修改原 plan 的 Req 以涵蓋此範疇（由使用者核可在原 plan 內擴張範圍）

等使用者決定後再繼續。
決定涉及需求變更時，交給 `req-analysis` 確認正式 Req，
再由 `technical-design` 處理適用設計決策；
只有範圍變更許可，不代表已有已確認的實作規格。

**若模糊（C）** → 先不要寫任何檔案。把模糊處浮現出來：

- 說明兩種可能的詮釋（一種導向相容、一種導向違反）
- 解釋每種詮釋各自依賴的假設
- 讓使用者選擇：(a) 在明確假設下採相容詮釋直接加，(b) 視為違反並選擇開新 plan / 修改 Req

等使用者決定後再繼續。

### Step 5 — 寫入衍生任務與 plan 索引

小型 FT 正文留在入口 plan 的 Task 章節內。
細節較大或使用者選擇時，使用獨立衍生檔案。
不論哪種方式，權威 FT 進度表都保留在入口 plan。

**Task 區塊格式：** 使用 `references/task-format.md` 的 **Mode B 範本**。共用限制適用（每個 task 一個邏輯 commit、無固定檔案數限制、每個 task 包含驗證）。撰寫前須讀取已確認的驗證策略，以及明確限定於新 task 的使用者指示。

**Mode B 專屬規則：**
- 一次呼叫可生成**多個有依賴關係的 FT task**（例如 FT01 更新契約及呼叫端，FT02 新增依賴該契約的行為；兩者各自包含驗證），透過 `Dependency` 欄位表達順序。
- **無預設類別順序** —— 後續工作太多樣化無法預先排序（補測試 / 改文件 / 純改生產碼…）。與 Mode A 相同，由實際依賴決定順序；AI 向使用者說明建議順序。

#### 5a. 決定正文位置

1. 重用已約定的內嵌或外部位置。拆分時，**擷取 Jira ticket 前綴**：從原始 plan 檔名去掉 `_plan.md` 尾綴：
   - `docs/pxbox-26324_plan.md` → ticket 前綴：`pxbox-26324`
2. 拆分時，**搜尋**同一目錄內是否有 `{ticket-prefix}_ft_*.md` 檔案。
3. **若找到現有 FT 檔案且尚未約定位置** —— 詢問內嵌附加、使用現有檔案，或建立新檔。
4. **選擇新的外部正文時** —— 尚未指定 `{XXX}` 標籤才詢問：
   - 預設建議 `01`
   - 使用者可改用描述性名稱（例如 `refactor`）
   - 最終路徑：`{同一目錄}/{ticket-prefix}_ft_{XXX}.md`
   - 原始名稱不符合範例模式時，確認適合的前綴，不要虛構 ticket。

#### 5b. 使用新的外部正文時 —— 建立它

以此標題寫入檔案（使用指向原始 plan 的相對路徑）：

```markdown
# Follow-up Tasks

> 本檔案為 [{原始 plan 檔名}](./{原始 plan 檔名}) 的衍生任務清單。
```

#### 5c. 指派下一個 FT ID

Mode B 的 task ID 一律使用 `FT` 前綴（例如 `FT01`、`FT02`），不論原始 plan 採用何種 ID 模式。查看入口 plan 下所有 FT 表格與索引正文，取最大編號；若無，從 `FT01` 開始。不要在每個拆分檔案重新編號。

#### 5d. 在選定正文位置附加 task 細節區塊

使用 `references/task-format.md` 的 **Mode B 範本**。欄位順序：`Current state` → `Goal` → `Dependency` → `Target` → `Implementation Details` → `Validation` → `Test File (DoD)`（新增或修改測試時）→ `Affected Files`。

若先前排除項目或已接受風險與本次工作有關，應以 `Current state` / `Goal` 及實作詳情說明先前暫緩的內容、新提出的工作，以及仍適用的接受條件。引用既有決定，不改寫前次 task，也不重複長篇討論歷程。

#### 5e. 在入口 plan 的 Follow-up Task 進度表中附加一列

若進度表尚不存在，放在入口 plan 的 Task 後續工作子章節，
或既有的 Follow-up Task 索引延伸內：

```markdown
### Follow-up Task 進度表
| ID | 項目 | 引用 | 依賴 | 狀態 |
| :--- | :--- | :--- | :--- | :--- |
| FT01 | [Task 名稱] | — | — | Todo |
```

若進度表已存在，附加新的一列。
外部正文不要複製表格；依共用規則遷移受影響的舊表格。

#### 5f. 維護原始 plan 的 Task 索引

- FT 摘要、依賴、進度列與外部正文連結保留在 `## Task` 下
- 既有 `## Follow-up Task` 保留為 Task 索引延伸
- 外部正文連到相關任務標題，並保留回到入口 plan 的連結

章節格式：

```markdown
### Follow-up Tasks

> 衍生任務清單：
> - FT01 [任務目的](./{ticket-prefix}_ft_01.md#ft01-task-purpose) — Dependency: None
```

### Step 6 — 確認回報

向使用者回報：

- 新 Task ID（例如 `FT01`，多個時可寫範圍如 `FT01`–`FT03`）
- 每個 task 一行摘要
- 入口 plan 路徑與寫入的內嵌或外部正文位置
- 已在入口 plan 更新 Task 索引與權威 FT 進度表
- 所有新 task 的 Status 設為 `Todo`，待實作

---

## 輸出慣例

- **繁體中文**：plan 內容維持繁體中文，與既有 plan 語言一致。對使用者的訊息也用繁體中文。
- **沿用既有風格**：若 plan 在既有 task 間有一致的格式 / 用詞，跟著走。
- **冪等（Idempotent）**：若已存在範疇相似的 task，先詢問使用者再決定是否重複建立。
- **不改程式碼**：本 skill 只編輯 plan 文件。程式碼實作由 `implementation` 處理，明確要求時才使用 `implementation-agent`。
- **Mode B — 允許一次新增多個 task**：一次呼叫可加入多個有依賴關係的 FT task。每個 task 都必須個別通過 Step 3 的分類檢查。
- **兩種模式 — 粒度與驗證自查**：遵循 `references/task-format.md` 的共用規則。每個 task 都須有明確目的、完整受影響檔案清單及 `Validation` 欄位。預設將實作與對應驗證放在一起，不強制另開測試 task。呈現前先修正不一致之處。

---

## 進度表 (Progress Table)

### 狀態定義

| 狀態 | 說明 |
| :--- | :--- |
| `Todo` | 尚未進行 |
| `InProgress` | 進行中 |
| `Review` | 等待使用者確認（Req / Design 項目初始狀態） |
| `Done` | 完成 |
| `Cancel` | 取消不做 |
| `Pending` | 暫時擱置 |

T 項目與 FT 項目使用相同的狀態值。所有生成 task 的初始狀態為 `Todo`。

---

## 範例

### 範例 1 — Mode A：生成初始 Task 列表

**使用者**：「Design 都確認了，幫我生 Task」

**Skill**：
1. 讀 plan 的 Design 進度表 —— 所有 D01–D06 皆為 `Done`
2. 完整讀取 D01–D06 內容
3. 依實際依賴排序生成 T01–T18，每個實作 task 都包含對應驗證
4. 附加 `## Task` 章節與 Task 進度表
5. 回報：「✅ 已生成 18 個 Task (T01–T18)，進度表已附於 Design 之後」

---

### 範例 2 — Mode B：相容 task

**使用者**：「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**：
1. 讀 `docs/pxbox-26324_task_refactor.md` Background 段
2. 辨識意圖：「測試重組，零行為變更，零生產碼動到」
3. 分類為 **相容**（typo 修正、只動測試檔屬性、無行為變更）
4. 使用者選擇獨立 FT 正文並確認標籤 `01` → 建立 `docs/pxbox-26324_ft_01.md`，附回到原始 plan 的連結
5. 在 `docs/pxbox-26324_ft_01.md` 附加 `FT01` task 細節區塊
6. 在原始 plan 的 Follow-up Task 進度表附加 `FT01` 列，不是在外部正文
7. 更新原始 plan 的 Task 索引，包含 FT01 目的與正文連結
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

### 範例 5 — 前次 task 的範圍不是永久禁止

**使用者**：「前次只改快取、不改事件處理。現在我想合併事件接收；原始 Req 的業務規則與 API 契約維持不變。部署可能漏掉舊 Scopes 的風險已接受，不做補償。」

**Skill**：
1. 重新讀取原始 Req，檢查事件改動是否符合。
2. 辨識「不改事件處理」是前次 task 的局部範圍，而非原始 Req 的禁止事項。
3. 若改動符合原始 Req，就判定相容並新增這次提出的衍生 task，不改寫前次 task，也不只因優先順序改變就要求新增 Req。
4. 引用已接受的部署風險與條件，不自動增加重播或 offset 調整工作。只有新證據改變條件或後果時，才再次提出。
5. 若原始 Req 其實明確要求兩個獨立訂閱，則依 Step 4 取得範圍變更決定後，才寫入 task。
