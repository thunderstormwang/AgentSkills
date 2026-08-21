---
name: git-commit
description: 使用符合 Conventional Commits 規範的格式建立 Commit 訊息，支援最多 5 行的內文描述。當使用者要求提交變更、撰寫 Commit 訊息，或需要協助建立具備意義的變更描述與 Ticket 引用時，請使用此技能。當改寫歷史（squash、rebase、amend、fixup、reword）且必須為產生的 Commit 組出訊息時，亦請使用此技能。
---

# Git Commit 助手技能

此技能用於建立符合 Conventional Commits 規範且結構良好的 Git Commit 訊息。

## 格式 (Format)

**Header (單行標題)：**
```
<type>[optional scope]: <description> #<jira ticket no>
```

**Body (選填，最多 5 行)：**
- 當需要額外的背景資訊或細節時使用。
- 最多 5 行。
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
    - 當在改寫歷史（squash / rebase / amend）時，唯一真相改為**範圍淨差異 (net range diff)** — 詳見 [歷史改寫](#歷史改寫-squash--rebase--amend)。
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
    - 最多 5 行，每行應簡潔且具備意義。
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
11. **先提交，再回報 — 不要事前徵求核准。**
    - 訊息組完後立即執行 `git commit`，不要停下來詢問「要提交這個嗎？」。
    - 流程必須為：**組出訊息 → 提交 → 顯示實際提交的訊息給使用者**。
    - 提交後務必完整顯示 Commit 訊息（標題、內文、頁腳標記），讓使用者可以檢視被記錄的內容。
    - 唯一允許在提交前詢問的是 Jira Ticket 編號（步驟 6）與 BREAKING CHANGE 確認（步驟 9）。
12. **依要求修訂 (Amend)**：
    - 若使用者在看到已提交的訊息後要求任何文字調整，請使用 `git commit --amend` 修訂，而非另建新的 Commit。
    - 不要主動修訂；僅在使用者明確要求變更時才執行。
    - 除非使用者明確要求，否則嚴禁修訂已推送 (pushed) 的 Commit。
    - 修訂完成後，請再次顯示更新後的訊息。

## 歷史改寫 (Squash / Rebase / Amend)

當多個 Commit 被壓縮為一個時，產生的訊息必須描述**最終淨結果 (net end state)**，而非抵達該結果的過程。一旦 squash 完成，中間反覆修改的過程在提交樹中已不再可見；描述這些過程會使訊息與 `git show` 實際顯示的內容互相矛盾。

1.  **唯一真相是被改寫範圍的淨差異，而非舊的 Commit 訊息。**
    - **在開始改寫之前就先解析出基準點並取得淨差異。** 一旦 interactive rebase 進行中，`HEAD` 會停在 detached 的半套用狀態；而 rebase 完成後，舊的基準點已無法從 `HEAD` 追溯 — 在這兩個時機點計算出的範圍都是錯的。
    - 每種操作的淨差異都不同，`--amend` 甚至根本沒有「範圍」：

      | 操作 | 應讀取的淨差異 |
      |---|---|
      | 壓縮 (squash / fixup) N 個 Commit | `git diff <被壓縮最早 Commit 的父節點>..HEAD` |
      | 將分支 rebase 到 `<target>` | **先**解析 `git merge-base <branch> <target>`，再執行 `git diff <該 sha>..<branch>` |
      | `--amend` | `git diff HEAD~1..HEAD` **再加上** `git diff --cached` — 其淨效果為「原 Commit 的差異」結合「**已暫存**的內容」。未暫存的變更不會被 amend 進去，因此必須排除 `git diff`；僅當該次 amend 會帶 `-a` 執行時才納入 |

    - 僅依據該差異組出訊息。
2.  **舊的 Commit 訊息要最後才讀，甚至可以不讀。**
    - 先僅憑淨差異草擬完所有內文行。之後才可讀取 `git log <base>..HEAD`，且僅用於補回某項變更的*原因*，也僅能用來改寫「已經存在的行」— 絕不可據此新增任何一行。
    - 在草擬前先去讀舊標題，正是內文帶有「過程感」的直接原因：那些舊標題本身就是過程，而改寫它們是最省力的路徑。不要提早打開它們。
    - **嚴禁**將舊訊息複製、串接或列點寫進新的內文。
3.  **淨效果測試 (net-effect test)** — 寫下每一行內文前都要套用：
    - 一位只針對這個 Commit 執行 `git show` 的讀者，能否看到這行所聲稱的變更？若否，刪除該行。
    - 在範圍內被加入、之後又被移除的程式碼 → **兩者皆不提**。它不存在於淨差異中。
    - 在範圍內被反覆更動的數值/命名/做法 → 僅陳述**最終**的版本。
    - 在範圍內被引入又被修正的 Bug → 該 Bug 與其修正皆不提。
4.  **禁止出現的內文內容。** 真正的規則是步驟 3 的淨效果測試；下列項目只是「未通過該測試」的可辨識症狀，並非窮舉的黑名單。改用其他措辭避開這些字眼、但仍在描述已被取代的步驟，同樣禁止。
    - 自我指涉或描述過程的用詞：「修正前一版…」、「調整上述…」、「改回…」、「再次修正…」、「依 review 意見調整…」，以及任何同義說法。
    - 逐一列舉被壓縮的 Commit（「包含 3 個 commit：…」），或將它們的標題保留為內文行。
    - 任何目的僅在描述「之後已被取代的步驟」的行。
5.  **標題應反映整個範圍的目的**，而非第一個或最後一個 Commit 的標題。請從淨差異重新推導 `type` 與 `scope` — 一連串用來打磨新功能的 `fix` Commit，整體應為 `feat` 而非 `fix`。
6.  **頁腳標記**：每個不同身份僅保留**一個** `Co-authored-by:` — 請將自被壓縮 Commit 繼承而來的重複項去除，而非層層堆疊。僅當破壞性變更仍存在於淨差異中時，才保留 `BREAKING CHANGE:` 頁腳。
7.  **改寫已推送的歷史須先明確確認**：若範圍內任何 Commit 已被推送，改寫前必須先詢問使用者。此規則將步驟 12 的限制延伸至 squash 與 rebase — 它們的破壞性高於 `--amend`。
8.  **改寫完成後必須顯示產生的訊息** — 與步驟 11 對一般 Commit 的要求相同。使用者必須看到「實際被記錄下來的內容」，而非「原本打算寫的內容」。
    - 從 git 讀回來並原文顯示，含頁腳標記：單一壓縮結果用 `git log -1 --format=%B`；若 rebase 改寫了多個 Commit，則用 `git log <target>..HEAD --format=%B`。
    - 多個 Commit 的讀回，範圍必須以**改寫後**的基準點界定（`<target>`，或 `ORIG_HEAD`），絕不可用步驟 1 解析出的基準點。rebase 之後那個舊基準點已不再是 `HEAD` 的祖先，因此 `<舊基準點>..HEAD` 會以集合差的方式解析，連 target 自身的 Commit 一併列出 — 那些訊息並非本次改寫所撰寫。
    - **嚴禁在未顯示訊息的情況下回報改寫已完成。** 訊息可能被無聲截斷、停留在編輯器的樣板狀態、或原封不動地沿用舊 Commit 的內容 — 這些狀況除非讀回來，否則完全看不出來。

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

**範例 6：壓縮 4 個 Commit — 僅呈現最終淨結果**

淨差異（`git diff <base>..HEAD`）— 內文唯一的合法來源：
```
CacheService.cs   + 以 IDistributedCache 封裝 Redis 讀寫，TTL 以毫秒表示
appsettings.json  + Redis:ConnectTimeout = 30s
```
其中完全不存在 TTL 的 Bug、10 秒這個數值、以及 debug log — 它們在範圍內被引入後又互相抵銷掉了。

被壓縮的 Commit（`git log <base>..HEAD` — 僅在草擬完成「之後」才讀，用於補「為什麼」）：
```
feat(cache): 新增 Redis 快取層
fix(cache): 修正 TTL 單位錯誤
refactor(cache): timeout 由 10 秒改為 30 秒
fix(cache): 移除誤加的 debug log
```

❌ 錯誤 — 把那四個舊標題直接當成內文行，與 `git show` 內容矛盾：
```
feat(cache): 新增 Redis 快取層 #26739

新增 Redis 快取層。
修正 TTL 單位錯誤。
timeout 由 10 秒改為 30 秒。
移除誤加的 debug log。
```
TTL 的 Bug、10 秒這個數值、以及 debug log，全都不存在於淨差異中 — 讀者無法找到其中任何一項。

✅ 正確 — 每一行都可回溯到上方淨差異的某一行：
```
feat(cache): 新增 Redis 快取層 #26739

以 IDistributedCache 封裝 Redis 讀寫，TTL 以毫秒為單位設定。
Redis 連線 timeout 設為 30 秒。

Co-authored-by: Claude (claude-opus-5) <noreply@anthropic.com>
```
