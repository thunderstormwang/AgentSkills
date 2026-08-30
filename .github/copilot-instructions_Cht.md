# Copilot 全域指令

## 語言與溝通
- **主要語言：** 與使用者溝通、討論需求、產出系統文件時，一律使用**繁體中文**。

### Skill 與 Instruction 檔案

預設（使用者層級與個人專案 repo）：使用**英文**——這些檔案只供使用者與 AI 讀取，因此沒有需要使用中文的讀者。

**觸發規則：** 每個 session 第一次操作名稱以 `PXBox` 或 `PXEC` 開頭（不分大小寫）的 repo 時，必須先載入 `pxbox-conventions` skill，才能撰寫程式碼、文件、instruction 檔案或進行 commit。該 skill 會覆寫上述檔案語言預設，並收錄後續新增的團隊慣例與隱性知識。

**若無法判斷 repo 是否屬於公司專案，撰寫前必須先詢問**——事後切換語言代表必須重寫整份檔案。

## 回應風格
- 簡潔且技術性。
- 建議變更時，先解釋「為什麼」，再說明「怎麼做」。

## 程式碼變更規則

### 何時需要提計畫

**只有原始碼變更**才需要提計畫。文件、instruction 檔案與 skill 檔案**不需要**提計畫，可直接修改並 commit，無須事先詢問。

這只免除計畫認可步驟，不免除 `git-commit` skill；commit 仍須遵循該 skill 的流程。歷史重寫（squash／rebase／amend）無論是否只涉及文件，都必須取得明確確認。

**以下情況可跳過計畫：**
- 使用者明確表示不需要計畫，或
- 使用者表示依照已存在的計畫執行。

### 計畫內容

每個計畫項目必須包含：
- **現狀：** 目前的狀態
- **目標：** 想要達成的目的
- **方法：** 如何實作
- **步驟：** 具體的實作步驟

若使用者未指定計畫檔路徑，須先詢問儲存位置。

### 執行流程

1. 撰寫或更新計畫，然後**等待使用者認可**。
2. 若未通過，持續修正直到認可。
3. 依計畫逐步實作。
4. 完成所有步驟後，**commit 變更**。

## Git Commit

**觸發規則：** 任何會建立或變更 commit message 的操作，都必須在執行前載入 `git-commit` skill。判斷依據是操作結果，而非命令名稱；不要自行判斷某項操作是否「算是 commit」。

- 執行下列任一操作前，**必須先載入 skill**：`git commit`（包含或不包含 `--amend`）、任何形式的 `git rebase`（`-i`、`--autosquash`、會開啟編輯器的 `--continue`）、`git merge --squash`、`git cherry-pick`、`git revert`、`git filter-branch`，以及任何帶有 `-m`、`-F`、`--fixup`、`--squash`、`--reuse-message` 或 `--reedit-message` 的 Git 命令。
- **有疑慮時，視為會撰寫 message 並載入 skill。** 多載入一次沒有成本；漏載入則會產生必須重寫的 message。
- **禁止**直接透過 Bash 執行 `git commit`。這涵蓋所有不經 skill 提供 message 的方式：`-m`、`-F -`、heredoc、`--no-edit` 與 `GIT_EDITOR=true`。
- **禁止預先編寫 message，再尋找命令將其提交。** 唯一允許的 commit 流程是 skill 所定義的「確認 diff → 撰寫 message → commit → 顯示已提交的 message」。先寫好 message 再載入 skill 背書，違反此規則。
- 重寫歷史另有 message 規則；進行 squash／rebase／amend 時，必須閱讀 skill 的「History Rewriting」章節，不可視為選讀背景資訊。

<!-- CODEGRAPH_START -->
## CodeGraph

若 repo 根目錄存在 `.codegraph/`，表示已建立 CodeGraph 索引；需要理解或定位程式碼時，應在 grep／find 或直接讀檔前優先使用 CodeGraph：

- **MCP 工具**（若可用）：`codegraph_explore` 通常可透過一次呼叫回答大多數程式碼問題，回傳相關 symbol 的逐字原始碼與彼此間的呼叫路徑，包含 grep 無法追蹤的動態分派。查詢時可指定檔案或 symbol，以讀取含行號的現行原始碼；若結果列出但延後載入某項內容，則透過工具搜尋以名稱載入。
- **Shell**（一律可用）：`codegraph explore "<symbol names or question>"` 會輸出相同結果。

若根目錄不存在 `.codegraph/`，完全略過 CodeGraph；是否建立索引由使用者決定。
<!-- CODEGRAPH_END -->
