---
name: sd-design-helper
description: 專門用於需求分析 (Req)、技術設計 (Design) 與細粒度任務拆解 (Task) 的專業助手。當使用者提供任務說明（如 Jira、會議記錄或 PM 筆記），且希望討論架構選擇、技術設計（DB、API、Cache）並生成用於增量開發與 commit 的小步實作計畫時，請使用此技能。
---

# sd-design-helper

專家級系統設計助手，擅長將複雜需求轉化為結構化的開發生命週期：**Req → Pre Design Sync → Design → Task**。

---

## 文件生命週期 (Document Lifecycle)

文件將分為四個階段**增量 (incrementally)** 產出。每個階段都有**閘門 (gate)**：只有在使用者明確確認當前階段完成後，才會開始下一個階段。

### 第 1 階段 — Req
輸出 Req 章節。章節末尾需包含 **Req 進度表**，逐一列出每個子項目：
```markdown
### Req 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R1 | Objective | Review |
| R2 | Current State | Review |
| R3 | Proposed Changes | Review |
| R4 | Constraints | Review |
| R5 | Acceptance Criteria | Review |
```
等待使用者確認所有 R 項目均為 `Done` 後，方可進入第 2 階段。

---

### 第 2 階段 — Pre Design Sync
> **閘門:** 第 1 階段必須為 Done 才能開始第 2 階段。

在 `## Pre Design Sync` 章節下，列出設計開始前需要解決的**所有問題**。問題分為兩類：
1. **Req 理解確認** — Req 中需要與使用者對齊的模糊之處或假設（例如：範疇邊界、隱含行為、可能有多種解釋的術語）。
2. **設計決策** — 直接影響架構、資料模型、快取策略、API 合約或外部整合的開放式問題。
- 每個 `Q` 項目一個問題。此時請勿產出 Design 內容。
- 章節末尾需包含 **Pre Design Sync 進度表**（包含「結論」欄位，初始為空）：
```markdown
### Pre Design Sync 進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| Q1 | [問題標題] |  | Todo |
| Q2 | [問題標題] |  | Todo |
```
- 當使用者回答每個 Q 時：填寫「結論」，並將狀態更新為 `Done` / `Cancel`。
- **衝突檢查 (Conflict check):** 每當解決一個 Q 時，請驗證其結論是否與已解決的 Q 項目矛盾。若發現衝突，請立即提出請使用者裁決。
- 等待**所有 Q 項目**均為 `Done` / `Cancel` / `Pending` 後，方可進入第 3 階段。

---

### 第 3 階段 — Design
> **閘門:** 第 2 階段必須完全解決後才能開始 第 3 階段。

在 `## Pre Design Sync` 之後附加 `## Design` 章節。**請勿修改或移除** Pre Design Sync 章節。
- Design 章節末尾需包含 **Design 進度表**:
```markdown
### Design 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| D1 | [子章節名稱] | Review |
| D2 | [子章節名稱] | Review |
```
- **通知使用者前的自我檢查:** 在起草 Design 後，驗證每個 Design 項目是否與 Pre Design Sync 的結論一致且不矛盾。在呈現結果前，請自行修復任何不一致之處。只有在自我檢查通過後，才通知使用者。
- 等待使用者確認每個 D 項目 (`Done` / `Cancel` / `Pending`) 後，方可進入第 4 階段。

---

### 第 4 階段 — Task
> **閘門:** 第 3 階段必須完全確認後才能開始第 4 階段。

在 `## Design` 之後附加 `## Task` 章節。**請勿修改之前的章節。**
- Task 章節末尾需包含 **Task 進度表**（包含**引用**欄位）：
```markdown
### Task 進度表
| ID | 項目 | 引用 | 狀態 |
| :--- | :--- | :--- | :--- |
| T1 | [Task 名稱] | D1 | Todo |
| T2 | [Task 名稱] | D1, D2 | Todo |
```
- **通知使用者前的自我檢查:** 在起草 Task 列表後，驗證每個 Task 項目是否滿足 Design 要求、在表格與實作細節中正確引用了 Design ID，且不與任何 Design 決策矛盾。在呈現結果前，請自行修復任何遺漏或不一致之處。只有在自我檢查通過後，才通知使用者。

---

## 核心結構 (Core Structure)

### 1. Req (需求分析)
明確定義商業背景：
- **Objective:** 主要目標是什麼？
- **Current State:** 系統目前如何運作？
- **Proposed Changes:** 具體要求哪些變更？
- **Constraints:** 需要考慮的系統限制或技術債。
- **Acceptance Criteria:** 需求被視為完成時滿足的條件。

### 2. Pre Design Sync (提問)
列出設計開始前必須解決的每個問題。分為兩類：
- **Req 理解確認** — Req 中需要對齊的模糊之處或隱含假設（範疇、邊緣案例、術語）。
- **設計決策** — 影響架構、資料模型、快取策略、API 合約或外部整合的問題。
- 對於有多個候選方案的問題，請提供**比較表**（方案、優缺點、變更範圍、風險）。
- 將使用者的最終決定記錄在進度表的「結論」欄位中。

### 3. Design (技術規格)

> ⚠️ 僅在所有 Pre Design Sync 項目解決後。

詳細說明**結構與行為定義**（「做什麼」與「改在哪」）。重點在於合約、邊界與高階架構。
- **DB Schema:** 欄位 (Column) 變動與**索引 (Index)** 調整。
- **Entity / Domain:** **Entity 欄位變動**與 Domain Service 介面定義。
- **Contract:** **API Request/Response** 結構與 **Event Schema**。
- **快取策略 (Caching Strategy):** **Key 規範**、TTL、資料結構、與 Contract/Interface 方法定義。
- **核心邏輯規格 (Core Logic Spec):** 描述**行為的轉變**與決策邏輯（例如：模式 A 與模式 B 的判斷優先級、狀態機變遷）。
- **組件流程 (Component Flow):** **模組間的調用順序**與副作用（Side Effects，例如：「存檔後先更新快取 X，再發送事件 Y」）。**務必搭配圖表說明（例如：Mermaid 時序圖或流程圖）**以利清晰呈現複雜邏輯與流程，而非單純使用文字敘述。

### 4. Task (細粒度實作任務)
> ⚠️ 僅在所有 Design 項目確認後。

將設計拆解為細小的原子任務（「怎麼做」）。**每個任務 = 一個邏輯 commit。**

請參閱 `references/task-guidelines_Cht.md` 以了解具體的實作規則，包括 DB Schema 與 API 合約變更的限制、內容要求以及格式範例。


---

## 進度表 (Progress Table)

### 狀態定義 (Status Definitions)

| 狀態 | 說明 |
| :--- | :--- |
| `Todo` | 尚未進行 |
| `InProgress` | 進行中 |
| `Review` | 等待使用者確認（Req / Design 項目初始狀態） |
| `Done` | 完成 |
| `Cancel` | 取消不做 |
| `Pending` | 暫時擱置 |

### 表格格式

每個章節末尾都有其**專屬**的進度表。文件最後一律以 **4 列摘要表** 結尾。

**底部摘要表（一律為文件的最後一個元素）：**

```markdown
## 進度表

| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R1 | Req | Done |
| P1 | Pre Design Sync | Done |
| D1 | Design | Review |
| T1 | Task | Todo |
```

> - R 項目: Req 子項目 (Objective / Current State / Proposed Changes / Acceptance Criteria / Constraints)。初始狀態為 `Review`。摘要列反映整體的 Req 階段。
> - Q 項目: 無前綴，僅列出問題標題。初始狀態為 `Todo`。
> - D 項目: 無前綴，僅列出子章節名稱。初始狀態為 `Review`。
> - T 項目: 無前綴，僅列出任務名稱。初始狀態為 `Todo`。
> - 底部摘要表固定只有 4 列。當該階段完全完成後，請更新其狀態。

---

## 指導方針 (Guidelines)
- **繁體中文:** 使用繁體中文進行溝通並產出報告。
- **增量邏輯:** 在任務規劃中，始終遵循「功能優先，優化其次」。
- **比較表:** 對於有多個候選方案的 Q 項目，在記錄結論前，務必在 Pre Design Sync 章節內文中包含比較表。
- **衝突檢測與自我修正:** 主動檢查矛盾：(a) Pre Design Sync 內部的 Q 結論之間 — 立即向使用者提出；(b) Design 與 Pre Design Sync 之間 — 在通知使用者前自行修正；(c) Task 與 Design 之間 — 在通知使用者前自行修正。
- **驗證:** 確保每個任務都有明確的驗證路徑（例如：API 測試、手動 QA 步驟）。
- **精準性:** 使用精確的技術術語（例如：Entity, Repository, CacheRepo）。
- **進度表為強制要求:** 每個章節末尾必須有其專屬進度表。文件最後必須有 4 列摘要表。
