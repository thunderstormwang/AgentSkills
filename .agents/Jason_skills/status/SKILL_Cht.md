---
name: status
description: >
  專案狀態儀表板與文件同步工具。包含兩種模式：
  (1) `status` — 顯示服務摘要、活動中的功能、進度、阻礙因素與後續步驟。
  (2) `update_status` — 掃描所有 spec/features/ 文件，並同步每個狀態欄位以符合實際進度，修復過時資料。強制執行下方定義的「狀態慣例」。
  關鍵字：status, progress, where are we, what's next, update status, sync status, dashboard。
---

# 技能：專案狀態與文件同步 (Project Status & Document Sync)

**目的**：提供單一指令的專案狀態儀表板，並保持所有開發文件為最新狀態 —— 消除會誤導開發者的過時狀態欄位。

---

## 執行觸發

當使用者執行以下操作時啟用此技能：
- 詢問狀態 ("status", "where are we", "what's next", "progress")
- 要求更新或同步文件 ("update_status", "sync status", "update all docs")
- 詢問專案中正在發生什麼事

---

## 狀態慣例 (所有 spec/ 文件皆強制執行)

所有位於 `spec/features/` 下的文件「必須」使用以下標準化的欄位與值。

### 功能狀態 (Feature Status，位於 README.md 的標頭表格)

| 狀態 (Status) | 表情符號 | 意義 |
|--------|-------|---------|
| Planning | 🟡 | 需求收集、架構決策待定 |
| Blocked | 🔴 | 無法繼續 —— 需要依賴項或決策 |
| In Progress | 🔵 | 進行中的活動實作工作 |
| Review | 🟣 | 代碼已完成，等待審閱或測試 |
| Complete | ✅ | 已交付且經驗證 |
| Abandoned | ⚫ | 已取消或被取代 |

README.md 中的格式：
```markdown
| **Status** | 🔵 In Progress |
| **Phase** | Phase 1: Manual Offset Commit |
| **Updated** | YYYY-MM-DD |
```

### 需求狀態 (Requirement Status，位於需求文件表格)

| 符號 | 意義 |
|--------|---------|
| ⬜ | 尚未開始 |
| 🔲 | 已阻礙 / 等待依賴項 |
| 🔧 | 進行中 |
| ✅ | 已實作 |
| ❌ | 捨棄 / 不做了 |
| ⏸️ | 已延後 —— 追蹤於 Backlog 中，而非捨棄 |

### 架構決策狀態 (Architectural Decision Status)

| 符號 | 意義 |
|--------|---------|
| ❓ | 尚未決定 |
| ✅ | 已決定 |
| 🔄 | 重新檢視中 |

格式：在每個 AD 標題後方加入內嵌狀態：
```markdown
### AD-1: [決策標題] ❓
```

### TBD 項目狀態

| 符號 | 意義 |
|--------|---------|
| ❓ | 尚未回答 |
| ✅ | 已解決 |
| ❌ | 不再相關 |

格式：
```markdown
1. **TBD-1** ❓：[開放性問題描述] — ...
```

### 階段狀態 (Phase Status)

| 符號 | 意義 |
|--------|---------|
| ⬜ | 尚未開始 |
| 🔵 | 進行中 (Active) |
| ✅ | 完成 |
| 🔴 | 已阻礙 |
| ⏸️ | 已延後 —— 移至 Backlog |

需求文件中的格式：
```markdown
### Phase 1: Manual Offset Commit 🔵
```

---

## 模式 1：`status` — 唯讀儀表板

### 執行步驟

1. **服務摘要**：閱讀 `copilot-instructions.md` 以了解服務目的。輸出一句話。

2. **活動中功能**：掃描 `spec/features/*/README.md` 中所有的功能資料夾。
   - 從每個 README.md 標頭表格中解析 Status、Phase 與 Updated 欄位。
   - 列出功能，並依照狀態優先權排序：🔴 Blocked → 🔵 In Progress → 🟡 Planning → 🟣 Review → ✅ Complete。

3. **針對每個活動中功能**（不含 ✅ Complete 或 ⚫ Abandoned）：
   - 解析 `FEAT-NNN-requirements.md`：
     - 按狀態（⬜/🔧/✅/❌/🔲）統計需求數量
     - 識別目前的活動階段
     - 列出開放的 TBD (僅 ❓)
     - 列出未決定的 AD (僅 ❓)
   - 檢查 `IMPLEMENTATION_COMPLETION_REPORT.md` 是否存在 → 表示階段已完成。

4. **待辦清單 (Backlog)**：若 `spec/BACKLOG.md` 存在，讀取並列出所有 ⏸️ Deferred 項目（位於 "Deferred Items" 下方的表格）。
   - 輸出每一行：ID, 項目摘要, 來源功能, 優先級。
   - 跳過項目欄位為 `—` 的行。

5. **阻礙因素 (Blockers)**：收集所有功能中所有 🔴 與 🔲 項目。

6. **Git 上下文**（可選，當可用時）：
   - 目前分支：`git branch --show-current`
   - 未提交的變更：`git status --short | head -10`
   - 最後一次提交：`git log --oneline -1`

7. **輸出格式**：

```markdown
## 📊 專案狀態 — {服務名稱}

**服務**：{一行描述}
**分支**：`{branch}` | 最後提交：`{hash} {message}`

### 活動中功能 (Active Features)

#### FEAT-001: {名稱} 🔵 In Progress
- **階段**：Phase 1: Manual Offset Commit 🔵
- **需求**：3/10 ✅ | 2/10 🔧 | 5/10 ⬜
- **開放 TBD**：TBD-1, TBD-2, TBD-3
- **未決定 AD**：AD-1, AD-3
- **下一步**：{從第一個 ⬜ 需求或第一個活動階段推論}
- **更新日期**：{README 中的日期}

### ⚠️ 阻礙因素 (Blockers)
- {列出任何 🔴 / 🔲 項目及其來源文件}

### 📋 待辦清單 (Backlog)
- B-001: {項目摘要} | 來源: {功能} | 優先級: {優先級}
- *(若無延後項目則為空)*

### 🔍 過時檢查 (Staleness Check)
- {列出任何 Updated 日期早於 7 天前的檔案}
- {列出任何狀態欄位顯示不一致的檔案}
```

---

## 模式 2：`update_status` — 文件同步

### 執行步驟

1. **掃描所有功能資料夾**：`ls spec/features/*/`

2. **針對每個功能**，讀取並驗證：
   - `README.md` — 標頭表格包含 Status, Phase, Updated 欄位
   - `FEAT-NNN-requirements.md` — 所有狀態符號皆符合慣例
   - 檢查 `IMPLEMENTATION_COMPLETION_REPORT.md` 是否存在

3. **檢查 `spec/BACKLOG.md`**：若檔案存在，讀取並列出所有 ⏸️ Deferred 項目。詢問使用者是否有任何項目應重新啟用（移回功能階段）或標記為已完成。

4. **詢問使用者**（針對每個功能）：
   呈現目前狀態並詢問需要更新什麼。範例：
   ```
   FEAT-001: CDC Retry & Resend
   目前：🟡 Planning | 階段：N/A | 更新日期：2026-03-11
   
   目前的狀態為何？
   a) 🟡 Planning (不變)
   b) 🔵 In Progress — 哪個階段？
   c) 🔴 Blocked — 阻礙因素是什麼？
   d) 其他
   ```

5. **針對需求項目**：針對使用者提到的任何項目，詢問使用者以確認變更。除非使用者要求「完整審核」，否則不要強制審核每一個項目。

6. **原子化更新所有文件**：
   - 將 `Updated` 日期設定為今天
   - 根據使用者回答設定 Status、Phase
   - 依照確認更新需求狀態符號
   - 若使用者解決了任何 AD/TBD，則更新其狀態
   - 若某個階段被延後：設定階段符號為 ⏸️，在 `spec/BACKLOG.md` 中新增一行，若所有其他階段皆已完成，則將功能 Status 設定為 ✅ Complete

7. **報告變更內容**：
   ```markdown
   ## 📝 狀態更新總結
   
   | 文件 | 欄位 | 舊值 | 新值 |
   |----------|-------|-----|-----|
   | FEAT-001 README | Status | 🟡 Planning | 🔵 In Progress |
   | FEAT-001 README | Phase | N/A | Phase 1: Manual Offset Commit |
   | FEAT-001 Requirements | FR-01 | ⬜ | 🔧 |
   ```

---

## 快速更新速記 (Quick Update Shorthand)

使用者可以使用速記來跳過互動流程：

```
update_status FEAT-001 status=in-progress phase="Phase 1" FR-01=done TBD-1=resolved
```

映射方式：`done` → ✅, `wip` → 🔧, `blocked` → 🔲, `dropped` → ❌, `resolved` → ✅, `deferred` → ⏸️

---

## 規則

- ❌ **絕不**猜測狀態 —— 始終從文件中讀取或詢問使用者
- ❌ **絕不**在修改文件後讓 `Updated` 日期處於過時狀態
- ✅ 在修改任何狀態欄位時，始終將 `Updated` 設定為今天日期
- ✅ 將 `Updated` 晚於目前日期 7 天以上的檔案標記為潛在的過時檔案
- ✅ 當 `update_status` 完成後，執行 `status` 以顯示結果
- ✅ 僅使用「狀態慣例」符號 —— 不得使用自由格式的狀態文本

---

## 與其他技能的整合

| 技能 | 狀態應更新的時機 |
|-------|--------------------------|
| **feature-kickoff** | 建立鷹架後：設定 Status = 🟡 Planning, Updated = 今天 |
| **implementation-completion** | 建立 ICR 後：設定 Status = 🟣 Review 或 ✅ Complete, Updated = 今天 |
| **debug-investigation** | 若 bug 阻礙了功能：設定相關功能 Status = 🔴 Blocked |

> 這些轉換現在已在每個技能的執行步驟中強制執行 —— `feature-kickoff` (步驟 5), `implementation-completion` (步驟 7), 以及 `debug-investigation` (步驟 8)。
--- End of content ---