---
name: git-commit
description: 使用符合 Conventional Commits 規範的格式建立 Commit 訊息，支援最多 3 行的內文描述。當使用者要求提交變更、撰寫 Commit 訊息，或需要協助建立具備意義的變更描述與 Ticket 引用時，請使用此技能。
---

# Git Commit 助手技能

此技能用於建立符合 Conventional Commits 規範且結構良好的 Git Commit 訊息。

## 格式 (Format)

**Header (單行標題)：**
```
<type>[optional scope]: <description> #<jira ticket no>
```

**Body (選填，最多 3 行)：**
- 當需要額外的背景資訊或細節時使用。
- 最多 3 行。
- 若標題已足以描述變更，則可省略。

若未提供 Jira Ticket 編號，請省略 `#<jira ticket no>` 部分。

## 支援的類型 (Allowed Types)
- **feat**: 新增功能
- **fix**: 修復錯誤
- **docs**: 僅文件變更
- **style**: 不影響程式碼意義的變更（空白字元、格式化等）
- **refactor**: 既非修復錯誤也非新增功能的程式碼變更
- **perf**: 提升效能的程式碼變更
- **test**: 新增缺失的測試或修正現有的測試
- **chore**: 對建置流程或輔助工具/函式庫（如文件生成）的變更

## 頁腳標記 (Trailers)

頁腳標記是位於 Commit 訊息末尾（內文或標題之後）的鍵值對。

### 強制標記
- **Co-authored-by**: 自動加入所有 Commit；無論內文是否為空皆須存在。
  - 依「你目前運行的 AI agent 產品家族」（從自身的 system prompt / 執行身份得知）選擇對應的標記值。**一個品牌共用一個 trailer**，不分介面（CLI、桌面 app、Web、IDE 擴充）。模型 ID 內嵌在 name 的括號內（GitHub 仍以 email 歸戶 co-author，括號不影響歸戶）：
    | Agent 產品家族 | 涵蓋介面範例 | Trailer |
    |---|---|---|
    | Claude / Claude Code | Claude Code CLI、桌面 app、claude.ai/code Web、VS Code / JetBrains 擴充 | `Co-authored-by: Claude (<exact-model-id>) <noreply@anthropic.com>` |
    | Gemini | Gemini CLI、Gemini Code Assist（VS Code / JetBrains）、Android Studio 整合、Gemini app、Workspace | `Co-authored-by: Gemini (<exact-model-id>) <gemini-cli@google.com>` |
    | GitHub Copilot | Copilot CLI（`gh copilot`）、Copilot Chat（VS Code / JetBrains / Visual Studio）、Copilot Workspace、github.com 上的 Copilot、Copilot for Xcode | `Co-authored-by: Copilot (<exact-model-id>) <223556219+Copilot@users.noreply.github.com>` |
    | 無法判斷 | — | `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>` |
  - 以「agent 產品家族」為準，而非底層模型或介面。例如 Claude 模型若是透過 Copilot CLI 執行，應使用 Copilot 的 trailer。
  - **解析 `<exact-model-id>`**：取自你自身的執行身份 / system prompt（你目前運行的模型）。使用乾淨的 model family ID — 例如 `claude-opus-4-7` — 並去除任何 context 變體後綴（如 `[1m]`）。若品牌已知但無法判斷確切 model ID，則括號內填 `(Unknown)`（例如 `Co-authored-by: Claude (Unknown) <noreply@anthropic.com>`）。若連 agent 品牌都無法判斷，則用 `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>`。

### 選填標記
- **BREAKING CHANGE**: 用於標示破壞性變更或重大版本影響。
  - 適用時機：API 簽章更動、資料庫綱要破壞性變更、重大版本升級、設定格式變更、移除公開方法/屬性。
  - 格式：
    ```
    BREAKING CHANGE: <破壞性變更的描述>
    <若有需要，提供詳細說明>
    ```
  - 若有多項破壞性變更，可多次出現。
  - 應遵循 Conventional Commits 規範。

## 使用說明 (Instructions)

AI 必須遵循以下 **「雙源合成流程 (Dual-Source Synthesis Flow)」** 來生成 Commit 訊息：

1.  **驗證實體變更 (唯一真相)**：務必**先執行** `git status` 與 `git diff`。這建立了變更內容（檔案、方法、邏輯）的絕對現實。
2.  **對齊對話意圖**：參考最近的對話或計畫任務（如 T[x]），以理解「為什麼」進行這些變更。
3.  **分析變更以決定主要類型 (`type`)**：根據意圖與實體差異的綜合分析。
4.  **識別範圍 (`scope`)**：若適用（例如特定組件或檔案）。
5.  **撰寫簡潔的描述 (`description`)**：使用**繁體中文**並採用祈使句動詞（例如使用「新增功能」而非「已新增功能」）。類型 (`type`) 與範圍 (`scope`) 保持英文。
6.  **Jira Ticket 編號處理**：
    - 若使用者提供編號（如 `26739`），請在標題末尾加上 `#26739`。
    - 若未提供編號，請在繼續前**先詢問使用者**。
    - 若使用者明確表示不需要 Ticket 編號，則省略之。
7.  **撰寫標題 (強制項目)**：單行，遵循 `<type>[optional scope]: <description> #<jira ticket no>` 格式。標題應反映主要的開發意圖。
8.  **撰寫內文 (選填項目)**：
    - **合成準則 (Synthesis Rule)**：內文必須精確描述在 `git diff` 中發現的物理變更。
    - 若 `git diff` 包含對話或任務中未提到的邏輯或優化，AI **必須**在內文中技術性地摘要這些額外變更。
    - **禁令**：嚴禁產出僅遵循任務描述但與實際 `git diff` 內容矛盾的訊息。
    - 最多 3 行，每行應簡潔且具備意義。
9.  **破壞性變更偵測**：
    - 偵測變更是否涉及：
        * 移除或修改 API 簽章
        * 資料庫綱要破壞性變更
        * 相依套件重大版本升級
        * 設定格式變更
        * 移除公開方法/屬性
    - 若偵測到破壞性變更，提議加入 `BREAKING CHANGE:` 頁腳。
    - 加入前請先徵詢使用者確認。
10. **處理頁腳標記**：
    - 若存在破壞性變更，加入 `BREAKING CHANGE: <描述>` 頁腳。
    - 所有 Commit 皆須附加 `Co-authored-by:` 頁腳，依「你目前運行的 AI agent 產品家族」（Claude / Gemini / Copilot）選擇對應值 — 一個品牌共用一個 trailer，不分介面（對照表見上方「強制標記」）。並將解析出的 `<exact-model-id>` 內嵌在 name 括號內（乾淨 family ID，不帶 context 變體後綴）。若品牌已知但 model ID 未知，括號內填 `(Unknown)`；若連 agent 品牌都無法判斷，則用 `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>`。
11. **在執行 Git Commit 指令前，務必將提議的訊息呈現給使用者核准。在使用者明確確認前，嚴禁執行 Git Commit。**
    - 無論使用者說「commit」、「幫我 commit」或任何直接指令，此規則皆無條件適用。
    - 流程必須始終為：**提議訊息 → 等待確認 → 執行提交**。
    - 嚴禁跳過確認步驟。

## 範例 (Examples)

**範例 1：含 Jira Ticket 的標題 + 3 行內文**
```
feat(auth): 實作 Google 登入 #26739

新增 OAuth 2.0 認證流程。
整合 Google Identity 服務。
支援自動帳號建立。
```

**範例 2：僅標題，無 Jira Ticket（使用者確認不需要）**
```
fix(coupon): 修正折扣計算錯誤
```

**範例 3：含 1 行內文的標題**
```
refactor(api): 優化 API 響應時間 #25841

改用快取層減少資料庫查詢。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**範例 4：含 BREAKING CHANGE 頁腳**
```
feat(auth)!: 移除舊版 token 認證方式 #26739

新增 OAuth 2.0 認證流程。
保留向後相容層 (deprecated)。

BREAKING CHANGE: 舊版 token 認證方式已被移除。
請改用新的認證端點配合 OAuth 2.0。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**範例 5：含所有頁腳標記的標準修復**
```
fix(payment): 修正支付流程逾時錯誤 #28451

調整 timeout 設置為 30 秒。
改進錯誤訊息提示。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```
