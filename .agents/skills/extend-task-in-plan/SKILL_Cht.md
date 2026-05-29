---
name: extend-task-in-plan
description: "在既有 plan 上附加一個衍生 task，附加前先驗證它不違反 plan 原本的 Req。當使用者要求在已建立的 plan 上加入後續工作（補測試 / refactor / typo fix / 改風格 / 樣式調整 / 補欄位 / 補例外處理）時觸發。典型說法 —— 「在 {plan} 加 task / 補 task / 衍生 task / 順手改 / 順便加」。不確定是否該觸發時，傾向觸發本 skill；它的核心價值是 Req 違反檢查，跳過的話會無聲失效。"
---

> **注意**：本檔為 `SKILL.md` 的繁體中文對照參考，**非執行用檔案**。skill router 實際載入的是英文版 `SKILL.md`；本檔僅供閱讀理解。兩者內容需保持同步。

# extend-task-in-plan

本 skill 在既有的 plan 文件上加入一個**衍生 task**。它設計給**實作完一版後的精修情境** —— 補測試、調整成偏好的程式風格、改善 SOLID 合規性、或清理工作 —— **且不改變 plan 原本的需求**。

關鍵不變量：新 task 必須服務於 plan 的原始目的，不可引入新的範疇。

## 何時使用

當使用者要求在既有 plan 加 task 時觸發。典型說法：

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

## 工作流程

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
- 改名一個對外的公開 API（可能在 plan 範圍內，也可能不在 —— 取決於 plan）
- 優化某個可能跨越 plan 邊界的東西（例如在「只動測試」的 plan 裡做一個會碰到生產碼的效能調整）
- 模式對齊，可能被解讀成風格美化（相容）或設計變更（違反）

### Step 4 — 依分類分支處理

**若相容（A）** → 進入 Step 5。

**若違反（B）** → 先不要寫任何檔案。無聲附加會擴張 plan 的範疇，違背本 skill 的目的。把衝突浮現出來：

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

### Step 5 — 附加 task

在相容分類之後（或使用者選了選項 (b)）：

#### 5a. 在 `Task Implementation Details` 下附加一個細節區塊

使用以下結構：

```markdown
### {Next-ID} — {Short Title}

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
- **Dependency**: {前置 Task ID 或 `—`}
```

ID 慣例：沿用 plan 既有的模式（例如前面是 `R1`–`R9` 就用 `R10`；前面是 `T1`–`T14` 就用 `T15`）。

#### 5b. 在 `Task Progress Table`（plan 末尾）附加一列

附加一列，欄位為 `ID | Task Description | Status | Dependency`。Status 預設 `Todo`。

若 plan 既有表格有額外欄位（例如 `引用`），沿用既有 schema，不要強加新結構。

### Step 6 — 確認回報

向使用者回報：

- 新 Task ID
- 一行摘要
- 被修改的 plan 檔路徑
- Status 設為 `Todo`，待實作

## 輸出慣例

- **繁體中文**：plan 內容維持繁體中文，與既有 plan 語言一致。對使用者的訊息也用繁體中文。
- **沿用既有風格**：若 plan 在既有 task 間有一致的格式 / 用詞，跟著走。
- **冪等（Idempotent）**：若已存在範疇相似的 task，先詢問使用者再決定是否重複建立。
- **不改程式碼**：本 skill 只編輯 plan 文件。程式碼實作之後交給 `implementation` skill 或 `implementation-agent`。
- **每次呼叫一個 task（v1）**：若使用者一次要求多個 task，依序處理並逐一確認。未來版本可能支援批次。

## 範例

### 範例 1 — 相容 task

**使用者**：「在 `task_refactor.md` 加一個 task 把 `OrderQuantity.cs` 的 `[Trait("PromotionCondition", "OrderPrice")]` typo 改成 `"OrderQuantity"`」

**Skill**：
1. 讀 `docs/pxbox-26324_task_refactor.md` Background 段
2. 辨識意圖：「測試重組，零行為變更，零生產碼動到」
3. 分類為 **相容**（typo 修正、只動測試檔屬性、無行為變更）
4. 附加新 task `R10`（R9 之後的下一個 ID），含 Current state / Goal / Steps
5. 在 Task Progress Table 附加 `R10` 列，`Status = Todo`、`Dependency = —`
6. 回報：「✅ 已加入 R10 — 修正 `OrderQuantity.cs` 的 Trait typo」

### 範例 2 — 違反 task

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

### 範例 3 — 模糊 task

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
