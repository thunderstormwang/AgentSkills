# 專案指引

## 語言與溝通

- **主要語言：** 所有與使用者的溝通及系統文件的產出，一律使用**繁體中文**。

### 技能與指令檔案

預設（使用者層級與個人專案 repo）：**英文** — 這些檔案只有使用者與 AI 會讀，沒有需要以中文
撰寫的讀者。

**觸發規則：** 在某個 session 中首次操作名稱以 `PXBox` 或 `PXEC` 開頭（不分大小寫）的 repo 時，
須先載入 `pxbox-conventions` skill，才可在其中撰寫任何程式碼、文件、指令檔或 commit。該 skill
會覆寫上述的檔案語言預設，並隨著陸續補充，收納更多團隊慣例與默會知識。

**無法判斷某個 repo 是否屬於公司專案時，先詢問再撰寫** — 事後改變語言等同整份重寫。

## 回應風格

- 簡潔且技術性。
- 建議變更時，先說明**「為什麼」**，再說明**「如何做」**。

## 程式碼變更工作流程

### 何時需要計畫

計畫**僅在原始碼變更時才需要**。文件、指令檔案與技能檔案**不需要**計畫——直接修改並 commit，不必事先詢問。

此處豁免的是核准步驟，而非 `git-commit` skill——commit 本身仍須遵循該 skill 的流程。改寫歷史（squash / rebase / amend）一律需要明確確認，文件也不例外。

**以下情況跳過計畫：**
- 使用者明確表示不需要計畫，或
- 使用者表示依照既有計畫執行。

### 計畫格式

每個計畫項目必須包含：

- **現況：** 目前的狀態
- **目標：** 希望達成的結果
- **方法：** 實作方式
- **步驟：** 具體的實作步驟

若使用者未指定計畫檔案路徑，請先詢問確認。

### 執行流程

1. 撰寫或更新計畫，然後**等待使用者核准**。
2. 若未獲核准，修訂計畫直至核准為止。
3. 逐步實作計畫。
4. 所有步驟完成後，**提交變更（commit）**。

## Git Commit

**觸發規則：** 若某項操作將會「產生或變更 commit 訊息」，則必須在該操作執行**之前**先載入
`git-commit` skill。觸發依據是「結果」而非「指令名稱」— 不要去推敲這個操作「算不算提交」。

- **先載入 skill**，才可執行以下任一指令：`git commit`（含或不含 `--amend`）、任何形式的
  `git rebase`（`-i`、`--autosquash`、會開啟編輯器的 `--continue`）、`git merge --squash`、
  `git cherry-pick`、`git revert`、`git filter-branch`，或任何帶有 `-m`、`-F`、`--fixup`、
  `--squash`、`--reuse-message`、`--reedit-message` 參數的 git 指令。
- **有疑慮時，一律假設會產出訊息並載入 skill。** 多載一次的成本為零；漏載的成本是訊息要重寫。
- **禁止**直接透過 Bash 執行 `git commit`。這涵蓋所有繞過 skill 提供訊息的方式：`-m`、`-F -`、
  heredoc、`--no-edit`、`GIT_EDITOR=true`。
- **禁止先自行組好訊息，再去找指令把它送進去。** skill 的流程（驗證差異 → 組出訊息 → 提交 →
  顯示已提交的訊息）是通往 commit 的唯一路徑。先組好訊息、事後才叫 skill 來蓋章，違反本規則。
- 改寫歷史有專屬的訊息規則 — skill 的「歷史改寫」章節對 squash / rebase / amend 屬強制閱讀，
  不是選讀的背景資訊。

## 跨 Repo 工作

一項需求常橫跨數個 repo，而 session 只會跑在其中一個裡面。

**觸發規則：** 在某個 session 中首次討論、檢視或針對「非主要工作目錄」的 repo 進行設計時，
**須先讀取該 repo 的 `.claude/CLAUDE.md`** — 即使當下的任務看起來用不到也一樣。該檔案所承載
的，正是無法從程式碼推導出來的默會知識，太晚讀等於已經先用錯誤的假設推理過一輪。

`/add-dir` 做得到與做不到的事（2026-09-02 實測）：

| | 行為 |
|---|---|
| 檔案工具（Read / Edit / Write / Glob / Grep） | 取得該加入目錄的存取權 |
| 該 repo 的 `.claude/skills/` | **會載入**，在 `/context` 中以 `Project` 來源列出 |
| 該 repo 的 `.claude/CLAUDE.md` | **不會載入** — 故有上述觸發規則 |
| 主要工作目錄 | 仍然只有一個 |
| 加入的目錄在哪裡看得到 | `/permissions` — 僅存在於該 session，不會寫入任何設定檔 |

只有在確實需要**寫入**該目錄中的檔案時才加入目錄；唯讀的探索不需要加。

**跨 repo 使用 CodeGraph：** `codegraph explore` 依 shell 的 cwd 解析，因此
`cd <其他 repo> && codegraph explore "<query>"` 會查詢該 repo 的索引，並在過程中自動同步。
`UserPromptSubmit` 這個 prompt-hook 永遠只涵蓋主要 repo，所以其他 repo 的上下文不會自己出現
— 得自己去取。

**計畫維持一個 repo 一份，各自 commit 在自己的 repo 裡。** 工作起始的那個 repo，其計畫會帶一
節簡短的「對外契約」— 只寫契約形狀與部署順序，不含 Task 項目 — 而該節就是其他 repo 的 session
開始時的輸入，如此需求便不必從頭重新解釋一遍。

<!-- CODEGRAPH_START -->
## CodeGraph

在已由 CodeGraph 建立索引的儲存庫中（repo 根目錄存在 `.codegraph/` 目錄），當你需要理解或定位程式碼時，請**優先**使用它，而非 grep/find 或直接讀取檔案：

- **MCP 工具**（可用時）：`codegraph_explore` 一次呼叫即可回答大多數程式碼問題——包含相關符號的逐字原始碼，以及它們之間的呼叫路徑，甚至涵蓋 grep 無法追蹤的動態分派（dynamic-dispatch）跳轉。在查詢中指名檔案或符號，即可讀取其當前帶行號的原始碼。若它已列出但處於延遲載入狀態，請透過 tool search 以名稱載入。
- **Shell**（一律可用）：`codegraph explore "<symbol names or question>"` 會輸出相同內容。

若不存在 `.codegraph/` 目錄，請完全略過 CodeGraph——是否建立索引由使用者決定。
<!-- CODEGRAPH_END -->
