# Task 細節區塊格式 (Task Detail Block Format)

定義 plan 文件中個別 task 區塊的內嵌格式。適用兩種模式：
- **Mode A** —— 由 Design 生成的 T tasks
- **Mode B** —— 衍生的 FT tasks

**Mode A 的類別規則與依賴排序**（類別優先原則、SQL 檔名、API Summary…）請見 `task-guidelines.md`。

---

## 共用限制 (Shared Constraints)

- **邏輯提交粒度：** 每個 task 對應一個目的明確、可 review、可驗證的邏輯 commit。
- **無固定檔案數限制：** 依責任、行為或可獨立完成的階段拆分，而非檔案數。
    - 契約、實作與呼叫端必須同步生效時，應放在一起。列出所有受影響檔案，包含測試。
    - 不同目的可分別完成、驗證與回退時，應拆開。
    - 同一目的的改動過大時，尋找在前置任務完成後可正常運作的有意義中間階段。不要只為縮小 task 而製造不能建置或行為不完整的 commit。
- **驗證歸於該 task：** 預設將對應的測試新增/修改，以及適用的建置、測試執行或 review 檢查納入實作 task。
    - 遵循已確認策略與明確限定於 task 的使用者指示。區分不新增測試與不執行測試；兩者皆不代表不用驗證。
    - 在 `Validation` 記錄目標/指令與通過條件，或引用明確限定適用範圍的共用策略，並列出 task 特有差異。不要要求每個 task 都做所有檢查，也不要將局部例外延伸至整個 repo。
    - 同一個 task 內仍可先寫測試；不必因此另開測試先行 task 或提交失敗的測試。
    - 只有驗證本身是獨立目的（例如補既有行為的測試），或需要等待多個 task 完成（例如跨功能端到端檢查），才另開驗證 task。說明獨立拆分的原因並列出實際依賴。
- **實作程式碼歸於 Task 而非 Design：** 所有方法實體、SQL 查詢、對應/組裝邏輯及其他實作細節必須出現在 Task。Design 僅表達合約（欄位宣告、方法簽署）。

---

## 欄位 Schema

| 欄位 | 適用模式 | 說明 |
| :--- | :--- | :--- |
| **Reference** | 僅 Mode A | 此 task 實作的 Design ID（例如 `[D01]`） |
| **Current state** | 僅 Mode B | 現況 / 缺什麼（1-2 行）—— 說明為什麼需要此 FT；有適用且已確認的後續 Design 時引用它 |
| **Goal** | 僅 Mode B | 此 task 達成什麼（1-2 行） |
| **Dependency** | 兩者 | 前置 task ID 或 `None` |
| **Target** | 兩者 | `[專案名稱]` -> `[類別名稱]` -> `[方法名稱]` |
| **Implementation Details** | 兩者 | 逐步邏輯、程式碼模式或具體驗證規則 |
| **Validation** | 兩者 | 適用的檢查、目標/指令與通過條件，或限定適用範圍的共用驗證策略引用 |
| **Test File (DoD)** | 新增或修改測試的 task | 實體測試檔案路徑（例如 `src/Project.Test/xxxTest.cs`） |
| **Affected Files** | 兩者 | 完整受影響檔案清單，包含對應測試檔 |

### 欄位順序

1. **此 task 存在的理由** —— Mode A：`Reference`；Mode B：`Current state` + `Goal`
2. `Dependency`
3. `Target`（測試 task 用 `Test Target`）
4. `Implementation Details`
5. `Validation`
6. `Test File (DoD)` —— 新增或修改測試時
7. `Affected Files`

---

## Mode A —— T Task 範本

### T01 [任務名稱]
- **引用：** `[D01]`
- **依賴：** `None`
- **目標：** `[專案名稱]` -> `[類別名稱]` -> `[方法名稱]`
- **實作詳情：**
    - [步驟 1: 具體邏輯/指令]
    - [步驟 2: 具體邏輯/指令]
- **驗證：**
    - [適用檢查的目標/指令與通過條件，或限定範圍的共用策略引用]
- **測試檔案 (DoD)：** [新增或修改測試時列出路徑]
- **受影響檔案：** (列出所有受影響檔案，包含對應測試檔)

只有獨立驗證目的，或需要等待多個 task 完成的檢查，才使用獨立 task：

### T05 [測試 — 既有功能覆蓋]
- **引用：** `[D03]`
- **依賴：** `T01, T02`
- **測試目標：** `[類別名稱]`
- **實作詳情：** 為既有行為的 [Given/When/Then] 場景補上覆蓋。測試是此 task 的獨立目的。
- **驗證：** 執行 [指定測試指令]；所有指定場景必須通過。
- **測試檔案 (DoD)：** `src/PXBox.Spu.Test/Handlers/XxxHandlerTest.cs`
- **受影響檔案：** (列出所有受影響的測試相關檔案)

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
- **Validation**:
    - [適用檢查的目標/指令與通過條件，或限定範圍的共用策略引用]
- **Test File (DoD)**: [新增或修改測試時列出路徑]
- **Affected Files**: (列出所有受影響檔案，包含對應測試檔)
