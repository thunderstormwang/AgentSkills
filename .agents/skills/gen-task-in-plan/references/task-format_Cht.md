# Task 細節區塊格式 (Task Detail Block Format)

定義 plan 文件中個別 task 區塊的內嵌格式。適用兩種模式：
- **Mode A** —— 由 Design 生成的 T tasks
- **Mode B** —— 衍生的 FT tasks

**Mode A 的類別規則與排序**（DB → Entity → API → Test → Impl、SQL 檔名、API Summary…）請見 `task-guidelines.md`。

---

## 共用限制 (Shared Constraints)

- **邏輯提交粒度：** 每個 task 對應一個邏輯 commit。
- **檔案限制：** 預設每個 task ≤ 3 個檔案。
    - **精神：** 每個 task 必須能獨立 review 且能乾淨 revert。
    - **允許例外：** 機械式變更（rename、enum/const 新增、跨檔同樣 pattern 的編輯），若每個檔案 diff 小（約 < 5 行）且共享同一目的，可超過 3 檔。
    - **不確定時拆細優先** —— 拆過頭可救，包太大傷 review。
- **實作程式碼歸於 Task 而非 Design：** 所有方法實體、SQL 查詢、對應/組裝邏輯及其他實作細節必須出現在 Task。Design 僅表達合約（欄位宣告、方法簽署）。

---

## 欄位 Schema

| 欄位 | 適用模式 | 說明 |
| :--- | :--- | :--- |
| **Reference** | 僅 Mode A | 此 task 實作的 Design ID（例如 `[D01]`） |
| **Current state** | 僅 Mode B | 現況 / 缺什麼（1-2 行）—— 取代 Reference 的「為什麼有此 task」角色，因為 FT 無 Design 來源 |
| **Goal** | 僅 Mode B | 此 task 達成什麼（1-2 行） |
| **Dependency** | 兩者 | 前置 task ID 或 `None` |
| **Target** | 兩者 | `[專案名稱]` -> `[類別名稱]` -> `[方法名稱]` |
| **Implementation Details** | 兩者 | 逐步邏輯、程式碼模式或具體驗證規則 |
| **Test File (DoD)** | 僅測試 task | 實體測試檔案路徑（例如 `src/Project.Test/xxxTest.cs`） |
| **Affected Files** | 兩者 | 受影響的檔案路徑清單；遵循「檔案限制」 |

### 欄位順序

1. **此 task 存在的理由** —— Mode A：`Reference`；Mode B：`Current state` + `Goal`
2. `Dependency`
3. `Target`（測試 task 用 `Test Target`）
4. `Implementation Details`
5. `Test File (DoD)` —— 僅測試 task
6. `Affected Files`

---

## Mode A —— T Task 範本

### T01 [任務名稱]
- **引用：** `[D01]`
- **依賴：** `None`
- **目標：** `[專案名稱]` -> `[類別名稱]` -> `[方法名稱]`
- **實作詳情：**
    - [步驟 1: 具體邏輯/指令]
    - [步驟 2: 具體邏輯/指令]
- **受影響檔案：** (列出所有受影響檔案；遵循「檔案限制」規則)

### T05 [測試 — 功能名稱 進入點測試]
- **引用：** `[D03]`
- **依賴：** `T01, T02`
- **測試目標：** `[類別名稱]`
- **實作詳情：** 實作涵蓋 [Given/When/Then] 場景的 API 級別整合測試。此 task 旨在產生一個失敗的測試以定義邏輯邊界。
- **測試檔案 (DoD)：** `src/PXBox.Spu.Test/Handlers/XxxHandlerTest.cs`
- **受影響檔案：** (僅限測試相關檔案；遵循「檔案限制」規則)

---

## Mode B —— FT Task 範本

### FT01 [任務名稱]
- **Current state**: {現況 / 缺什麼 —— 1-2 行}
- **Goal**: {這個 task 達成什麼 —— 1-2 行}
- **Dependency**: {前置 FT ID 或 `None`}
- **Target**: `[專案名稱]` -> `[類別名稱]` -> `[方法名稱]`
- **Implementation Details**:
    - [步驟 1: 具體邏輯/指令]
    - [步驟 2: 具體邏輯/指令]
- **Affected Files**: (列出所有受影響檔案；遵循「檔案限制」規則)
