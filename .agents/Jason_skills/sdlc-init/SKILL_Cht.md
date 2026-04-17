---
name: sdlc-init
description: >
  使用 SDLC 技能組初始化專案。檢查 copilot-instructions.md 是否具備必要的 Skill Variables 區塊，提示缺少的值並注入，將主範本複製到 spec/_templates/，並將 sdlc_workflow.md 複製到 .github/。
  觸發關鍵字："init sdlc", "setup project", "onboard project", "bootstrap sdlc",
  "initialize development workflow"。
---

# 技能：SDLC 專案初始化 (SDLC Project Initialization)

**目的**：引導任何專案與 SDLC 技能組（`feature-kickoff`, `implementation-completion`, `debug-investigation`, `requirements-realignment`, `status`）協作。確保專案具備結構化 AI 輔助開發所需的設定與範本。

---

## 執行觸發

當使用者執行以下操作時啟用此技能：
- 說出 "init sdlc", "setup project", "onboard", "bootstrap sdlc"
- 開啟一個缺少 `copilot-instructions.md` 或其 Skill Variables 區塊的專案
- 詢問如何為新專案設定結構化開發工作流

---

## 此技能提供的內容

初始化後，每個專案將擁有：

```
project/
├── .github/
│   ├── copilot-instructions.md   ← 包含 Skill Variables 區塊
│   └── sdlc_workflow.md          ← 開發哲學與規則
└── spec/
    ├── _templates/
    │   ├── README.md
    │   ├── FEATURES/
    │   │   ├── feature-readme-template.md
    │   │   ├── requirements-template.md
    │   │   └── phase-progress-template.md
    │   └── PROCESS/
    │       └── IMPLEMENTATION_COMPLETION_REPORT_TEMPLATE.md
    ├── features/                 ← 初始為空，由 feature-kickoff 填寫
    └── BACKLOG.md                ← 初始為空的待辦清單
```

---

## 執行步驟

### 步驟 1 — 檢查現有狀態

檢查專案中是否已存在下列檔案：

```
.github/copilot-instructions.md    → 是否存在？是否有 "Skill Variables" 區塊？
.github/sdlc_workflow.md           → 是否存在？
spec/_templates/                   → 是否存在？是否包含所有 4 個範本？
spec/features/                     → 是否存在？
spec/BACKLOG.md                    → 是否存在？
```

在進行變更前向使用者回報發現。

---

### 步驟 2 — 收集專案參數

如果缺少 `copilot-instructions.md` 或缺少 Skill Variables 區塊，請向使用者詢問這些值：

| # | 參數 | 範例 | 是否必填？ |
|---|---|---|---|
| 1 | 服務名稱 (Service Name) | `PXBox.BQProxy` | 是 |
| 2 | 服務描述 (Service Description) | CDC event processor for BigQuery | 是 |
| 3 | 建置指令 (Build Command) | `dotnet build MyProject.sln` | 是 |
| 4 | 執行指令 (Run Command) | `dotnet run --project src/MyApp` | 是 |
| 5 | 原始碼根目錄 (Source Root) | `src/` | 是 |
| 6 | 規格目錄 (Spec Directory) | `spec/features/` | 是（預設：`spec/features/`） |
| 7 | 範本目錄 (Template Directory) | `spec/_templates/` | 是（預設：`spec/_templates/`） |
| 8 | 入口點 (Entry Point) | `src/MyApp/Program.cs` | 是 |
| 9 | 方案/專案檔 (Solution/Project File) | `MyProject.sln` | 是 |
| 10 | 日誌路徑 (Log Paths) | `logs/` | 選填 |
| 11 | 健康檢查 (Health Check) | `GET /health_check` | 選填 |
| 12 | CI/CD | `Drone (.drone.yml)` | 選填 |

---

### 步驟 3 — 建立或更新 copilot-instructions.md

**如果檔案不存在**：建立 `.github/copilot-instructions.md`，其基本結構包含：
- 包含專案名稱的頁首
- Skill Variables 表格（從步驟 2 填入）
- Copilot Skills 表格（指向使用者層級的技能）
- 使用者稍後可以填寫的佔位區塊

**如果檔案存在但缺少 Skill Variables**：在結尾附加 Skill Variables 區塊。

**如果檔案存在且已有 Skill Variables**：回報「已初始化」並顯示目前的值。詢問使用者是否需要更新任何內容。

#### Skill Variables 區塊格式

```markdown
## Skill Variables

這些值由 `~/.copilot/skills/` 中的 SDLC 技能引用。技能讀取此區塊以解析專案特定的細節。

| Variable | Value |
|----------|-------|
| **Service Name** | {value} |
| **Service Description** | {value} |
| **Build Command** | {value} |
| **Run Command** | {value} |
| **Source Root** | {value} |
| **Spec Directory** | {value} |
| **Template Directory** | {value} |
| **Entry Point** | {value} |
| **Solution File** | {value} |
| **Log Paths** | {value} |
| **Health Check** | {value} |
| **CI/CD** | {value} |
```

#### Copilot Skills 區塊格式

```markdown
## Copilot Skills (自動調用的 SOP)

技能根據任務類型自動調用。它們強制執行結構化流程。

| Skill | 觸發關鍵字 | 強制執行的 SOP | 輸出 |
|-------|-----------------|--------------|--------|
| **feature-kickoff** | "add feature", "implement X", "we need Y" | 驗證事實 → 建立 spec/ 鷹架 → 提出計畫 → 等待核准 | 功能資料夾 + 實作計畫 |
| **implementation-completion** | "done", "complete", "ready to test" | 建置 → 斷言 0 錯誤 → 建立 ICR | 建置輸出 + 完成報告 |
| **debug-investigation** | "bug", "error", "broken", "not working" | 診斷 → 提出修復方案 → 等待核准 → 套用 → 驗證 | 結構化診斷 + 修復 |
| **requirements-realignment** | "requirements changed", "scope change", "plan changed" | 更新需求文件 → 更新進度文件 → 新增調整記錄 | 同步後的文件 + 調整記錄項目 |
| **status** | "status", "progress", "where are we" | 掃描 spec/ → 回報儀表板或同步狀態欄位 | 狀態儀表板或文件同步報告 |

**技能位置**：`~/.copilot/skills/`（使用者層級，跨所有專案共用）
```

---

### 步驟 4 — 複製範本

將此技能 `templates/` 目錄中的主範本複製到專案的 `spec/_templates/`。

**對於每個範本檔案**：
- 如果檔案不存在 → 建立它
- 如果檔案已存在 → 跳過（不要覆寫自定義範本）

回報哪些檔案已建立與哪些檔案被跳過。

---

### 步驟 5 — 複製 sdlc_workflow.md

將此技能 `templates/` 目錄中的主 `sdlc_workflow.md` 複製到 `.github/sdlc_workflow.md`。

- 如果檔案不存在 → 建立它
- 如果檔案已存在 → 跳過並通知使用者。如果使用者需要，可以提供差異比對 (diff)。

---

### 步驟 6 — 建立 Spec 鷹架 (Skeleton)

如果 `spec/` 不存在：
- 建立 `spec/features/` 目錄
- 建立包含空白表格頁首的 `spec/BACKLOG.md`

---

### 步驟 7 — 呈現總結

```markdown
## SDLC 初始化完成

### 已建立
- [ ] .github/copilot-instructions.md (已注入 Skill Variables)
- [ ] .github/sdlc_workflow.md
- [ ] spec/_templates/FEATURES/feature-readme-template.md
- [ ] spec/_templates/FEATURES/requirements-template.md
- [ ] spec/_templates/FEATURES/phase-progress-template.md
- [ ] spec/_templates/PROCESS/IMPLEMENTATION_COMPLETION_REPORT_TEMPLATE.md
- [ ] spec/BACKLOG.md

### 已跳過 (已存在)
- [ ] {列出被跳過的檔案}

### 可用技能
所有 SDLC 技能均從 ~/.copilot/skills/ 載入：
- feature-kickoff, implementation-completion, debug-investigation
- requirements-realignment, status

### 下一步
- 使用專案特定的區塊檢閱並自定義 copilot-instructions.md
- 開始您的第一個功能："add feature {名稱}"
```

---

## 規則

- ❌ **絕不**在未經使用者明確核准的情況下覆寫現有檔案
- ❌ **絕不**從 copilot-instructions.md 刪除現有內容 —— 僅能附加
- ✅ 跳過已存在的檔案（回報為「已跳過」）
- ✅ 始終顯示已建立與已跳過內容的總結
- ✅ 如果 copilot-instructions.md 已有 Skill Variables，則回報「已初始化」
