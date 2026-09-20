---
name: agentskills-conventions
description: 使用者個人 AgentSkills repo 的編輯規範；該 repo 是全域 skills、agents 與 instruction 檔案的唯一真實來源。當使用者要求建立或修改個人 skill、agent、CLAUDE.md、Copilot instructions，或編輯 AgentSkills 內的這類檔案時使用。當連結請求明確涉及 AgentSkills 或個人 skills 時也使用。確保修改落在 repo 本體而非全域連結路徑，並在內容變更後同步繁中 `_Cht` 對照版及提交 commit。
---

# AgentSkills Repo 規範

這個 repo（`AgentSkills`）是使用者**個人** skill、agent、instruction 檔案的唯一真實來源。它跟公
司／專案的工作完全無關——遵循的是全域 CLAUDE.md 裡「`user-level and personal-project repos`」那
一分支，也就是英文內容搭配每個檔案的繁體中文 `_Cht` 對照版（見下方），而不是 `b2c-conventions`
那條中文優先的規則。

在每台機器上，使用者家目錄底下有幾個全域路徑是指向這個 repo 的**連結**，不是複本。正是這一點，才
讓「改一次，兩台電腦都能用」成立——不管是 skill、agent，還是 instruction 檔案都一樣。以下所有內
容，都是為了維持這件事成立。

## 規則 1 — 一律改 repo，不要改全域路徑

當使用者要求改「我的 skill」／「個人的 XXX skill」／「我的 XXX agent」／「我的 CLAUDE.md」／
「個人的 copilot-instructions」——某個以自己名義叫出來、沒有其他專案脈絡的 skill、agent 或
instruction 檔案，要改的檔案是**這個 repo 的複本裡的檔案**，透過下方的[連結對照表](#連結對照
表)解析出來——例如「改一下我的 git-commit skill」→ `{repo}/.agents/skills/git-commit/SKILL.md`、
「改一下我的 CLAUDE.md」→ `{repo}/.claude/CLAUDE.md`。就算使用者貼的或講的是全域路徑
（`~/.claude/skills/git-commit/SKILL.md`、`$HOME\.claude\CLAUDE.md` 等），也一樣先轉換回 repo
相對路徑，再改那一份。

**這條規則不是只適用於 skill。** 它對 agent（`.claude/agents/*.md`）跟兩份 instruction 檔案
（`CLAUDE.md`、`copilot-instructions.md`）一視同仁。不要因為 skill 是比較常見的情況，就把這條
規則的適用範圍讀窄了——一樣是改 repo、一樣查連結對照表、一樣套用規則 3 的先翻譯再 commit，四種
檔案的待遇完全相同。

**Why：** 全域路徑終究只是一個指標。它可能今天是健康的連結，也可能在還沒設定過的機器上根本不存
在，甚至——如果哪個工具是用「寫一個新的暫存檔、再改名蓋過去」的方式存檔——被一個全新的一般檔案
悄悄取代，連結就這樣斷了而不會有任何錯誤訊息（完整原理見
[`references/link-types_Cht.md`](references/link-types_Cht.md)）。repo 路徑則永遠不會是上述任
何一種狀況，它永遠是真正的檔案本體。改那裡永遠是對的，所以完全沒有理由透過全域那一側去改。

## 連結對照表

`{repo}` = 這個 repo 在目前這台機器上的複本根目錄。`{home}` = 使用者的家目錄（macOS 上是
`$HOME`/`~`，Windows 上是 `$env:USERPROFILE`）。

| 全域路徑（相對於 `{home}`） | Repo 路徑（相對於 `{repo}`） | 種類 |
|---|---|---|
| `.claude/skills` | `.agents/skills` | 目錄 |
| `.agents/skills` | `.agents/skills` | 目錄 |
| `.claude/agents` | `.claude/agents` | 目錄 |
| `.claude/CLAUDE.md` | `.claude/CLAUDE.md` | 檔案 |
| `.copilot/copilot-instructions.md` | `.github/copilot-instructions.md` | 檔案 |

（`.claude/skills` 和 `.agents/skills` 兩個都指向 repo 裡同一個資料夾——一個是 Claude Code 自己
的 skill 路徑，另一個是其他 agent 工具會去看的通用路徑。兩個都要保留。）

（針對 agent 另外補充：它跟 skill 一樣有 project／user 兩層 scope——同名時 project
（`<repo>/.claude/agents`）覆蓋 user（`~/.claude/agents`）——這正是為什麼一個只存在於這個 repo
自己 `.claude/agents` 裡的 agent，只有在這個 repo 內才叫得出來，也是為什麼這個路徑同樣需要連
結。另外，Claude Code 沒有 `/agent <name>` 或 `@<name>` 這種呼叫語法——在指令中直接指名 agent
就是呼叫方式；`@` 在 Claude Code 是檔案路徑補全，`/` 才是 skill。）

（這兩者之間有一個已知且接受的不對稱——而且不是出自一開始就想清楚的設計。`.agents/skills` 當
初設計時，是以為**所有** AI 工具（包含 Claude Code）都會從那一個通用路徑讀 skill；結果發現
Claude Code 其實不吃這條路徑，只好在原本就打算給其他工具用的鏡射連結（`~/.agents/skills`）之
外，另外多建一條 Claude 專用的連結（`~/.claude/skills`）——這兩條連結現在都是必要的，沒有一條
是多餘的。`.claude/agents` 則完全不是什麼跨工具的決定：當初設定它的時候，根本只用 Claude
Code，壓根沒考慮過其他工具的路徑——它只是剛好就落在 Claude Code 自己原生的 project-scope 路
徑上，這就是為什麼 agent 不需要像 skill 那樣多補一條連結，也是為什麼 session 的主要工作目錄只
要是這個 repo 本身，不靠任何全域連結就能找到它，連全新一台機器也一樣。這是真實存在的行為差異，
不是 bug：project 依名稱覆蓋 user，所以不管哪一種情況都不會出現重複列出或衝突的風險。目前刻意
維持現狀、不往任何一個方向去「理順」——AI 工具這個生態變動太快，很可能不久後又要重新考慮一次，
現在花力氣去講究並不划算。）

（針對 `CLAUDE.md` 另外補充：跟 skill、agent 不一樣，Claude Code 的 memory 檔案是跨 scope
**疊加**的，不是靠覆蓋規則二選一——project memory 跟 user memory 是兩個各自獨立追蹤的來源，
而且**兩者都會載入**，這點由 `/memory` 得到證實：它會把「User instruction」跟「Project
instruction」兩筆並列顯示。這裡並沒有像 agent 那樣依解析後的真實路徑去重。這份檔案原本放在
repo 根目錄，後來搬到 `.claude/CLAUDE.md`，純粹是為了跟這個 repo 其他 Claude 專用的檔案
（`.claude/agents/`）放在一起——**不是**為了修掉重複載入。不要跟下面「跨 repo 工作」那節的結論
搞混：那一節講的是用 `/add-dir` 加進來的**另一個** repo，它的 `.claude/CLAUDE.md` 已確認**不
會**自動載入。但當 `.claude/CLAUDE.md` 是 session 自己的主要工作目錄底下那一份時，情況不同——
已經拿其他 repo 實測驗證過，它一樣會被自動當成 project memory 載入，效果跟放在根目錄的
`CLAUDE.md` 一樣。所以這份檔案現在還是會被載入兩次，跟搬家前一模一樣，只是 project 那一側的路
徑換了而已。真正能消除重複的做法，是換一個 Claude Code 根本不會辨識成 project memory 的檔
名——但那樣會犧牲掉這個 repo 的 agent 現在享有的同一種好處（見上文）：不用連結也能用。只有當這
個取捨開始看起來划算時，才值得重新考慮。）

### 在目前這台機器上找出 `{repo}`

複本位置每台機器不一樣（Windows 跟 Mac 的使用者名稱／磁碟機都不同）。依下列順序解析——每一步都
是上一步答不出來時的備援：

1. **解析既有的連結。** 如果連結對照表裡任何一列在這台機器上已經是活的連結，就順著它走：
   macOS/Linux 用 `readlink -f ~/.claude/CLAUDE.md`，Windows 用
   `(Get-Item "$env:USERPROFILE\.claude\CLAUDE.md").Target`——拿到結果後，把那一列在對照表裡
   對應的 repo 相對路徑後綴（`.claude/CLAUDE.md`、`.agents/skills` 等）去掉，剩下的就是
   `{repo}`。這個
   方法不需要任何事先設定，而且永遠是最新的，因為連結不可能指向一個過期的位置卻不出錯——它要嘛
   指向現在的位置，要嘛就是明顯斷掉的連結。
2. **Memory。** 如果這台機器上還沒有任何連結（第一次在這裡跑這個 skill），就查 memory 有沒有
   之前 session 記下來的這台機器的路徑。
3. **目前的工作目錄。** 如果 memory 也沒有，且目前的工作目錄看起來就是這個 repo（含有
   `.agents/skills` 以及內容跟這份檔案所屬 repo 相符的 `.claude/CLAUDE.md`），就用工作目錄。
4. **問使用者一次**，問完之後存進 memory，這樣之後在這台機器上——第 1 步依然沒有連結可以解析的
   情況——就不用再問一次。Memory 是每台機器各自獨立的（它存在 `~/.claude/` 底下，而這個位置從來
   不是被連結的路徑之一），所以不會有跨機器互相覆蓋的問題。

## 規則 2 — 連結檢查與修復流程，僅限使用者點名這個 repo 時

觸發語句：使用者的請求必須明確跟*這個 repo*（或整體講的「個人 skill/agent」）綁在一起，不能只
是抽象地講「連結」——例如「建立與 AgentSkills repo 的連結」、「檢查與 AgentSkills repo 的連
結」、「AgentSkills 的連結有沒有建好」、「幫我建 AgentSkills 的連結」、「個人 skill 沒同步到這
台電腦」。單純的「建立連結」／「連結有沒有建好」／「幫我建連結」，如果完全沒有提到 AgentSkills
或使用者的個人 skill，就太籠統了，不能當成這個觸發條件——那可能是指任何不相干的連結（某個專案
的捷徑、給其他工具用的 symlink 等），要反問使用者指的是什麼，而不是自行假設是這個流程。一旦確
定是這個觸發條件，就不要反問使用者要檢查哪些連結——一律把整份對照表都跑一遍。

1. 判斷目前的作業系統（用情境裡已有的環境資訊，或不確定時用 `uname`／`$env:OS`）。
2. 依上方方法判斷 `{repo}`。
3. 針對連結對照表的每一列，算出全域路徑與 repo 路徑各自的絕對路徑，然後檢查全域路徑的狀態：
   - **不存在** → 建立它（見下方指令）。回報 `🔧 created`。
   - **是連結，且已經指向正確的 repo 路徑** → 不用做任何事。回報 `✅ ok`。
   - **是連結，但指向別的地方**（例如舊複本位置留下的過期路徑）→ 重新連結。這個動作安全且可逆
     （連結路徑本身不會存放任何內容），所以不用先問，直接做。回報 `🔁 relinked`。
   - **是真正的檔案或目錄，不是連結** → **停下來，不要動它。** 裡面可能存著真實內容，重新連結
     會把它刪掉。回報 `⚠️ conflict`，並詢問使用者要怎麼處理。
4. 最後印出一張總結表（路徑 → 狀態）；不要每一列都用一段散文描述。

這個動作只會影響 session 目前所在的這台機器。同樣的檢查，之後在另一台機器上再次觸發這個 skill
時，會獨立再跑一次。

### 指令

**macOS / Linux**（目錄與檔案指令相同）：
```sh
mkdir -p "$(dirname "<global-path>")"
ln -s "<repo-path>" "<global-path>"
```

**Windows — 目錄**（Junction，不需要系統管理員權限）：
```powershell
New-Item -ItemType Directory -Force -Path (Split-Path "<global-path>") | Out-Null
New-Item -ItemType Junction -Path "<global-path>" -Target "<repo-path>"
```

**Windows — 檔案**（Symlink；需要提升權限的 PowerShell，或開啟開發人員模式）：
```powershell
New-Item -ItemType Directory -Force -Path (Split-Path "<global-path>") | Out-Null
New-Item -ItemType SymbolicLink -Path "<global-path>" -Target "<repo-path>"
```
若 PowerShell 因權限不足拒絕執行，改用提升權限之 `cmd.exe` 下對應的指令一樣可行：
`mklink "<global-path>" "<repo-path>"`（若要建目錄 Junction 則加上 `/J`，這個不需要提升權限）。

要重新連結（上面第 3 點）：先移除既有連結（`rm "<global-path>"` /
`Remove-Item "<global-path>"`——安全，這只會刪掉指標本身，絕不會刪到目標），再重新執行一次建立
指令。

## 規則 3 — 任何內容變更之後：先翻譯，再 commit

這個 repo 讓每一份 instruction／skill 的 `.md` 檔都配有一份 `_Cht` 對照版
（`{name}_Cht.{ext}`，放在原檔旁邊——例如 `SKILL.md` → `SKILL_Cht.md`、
`.claude/CLAUDE.md` → `.claude/CLAUDE_Cht.md`）。翻譯規則（這件事以前委外給獨立的
`file-translator` skill 處
理；那個 skill 從頭到尾就只服務這一條規則，沒別的用途，所以直接把規則內嵌在這裡，不再另外維護
一個獨立 skill）：

- 逐字對應的繁體中文，文法精確自然——絕對不要在產生翻譯的過程中改動英文原文。
- Markdown 格式要跟原文一致：標題、清單、表格、連結、程式碼區塊等皆同。
- 技術詞彙如果沒有合適的繁體中文對應詞，就保留英文原文，或用括號附註英文。
- 輸出路徑一律是原檔旁邊的 `{dir}/{name}_Cht.{ext}`；`_Cht` 檔案已存在時直接覆蓋。
- 對 `SKILL.md` 來說，這也包含它 YAML frontmatter 裡的 **`description` 欄位**——這個欄位也要
  翻，不是只翻本文；因為它在 Markdown 內容的上方，很容易一不小心就原封不動照抄過去，但「完整翻
  譯」這條規則同樣適用於它。
- **`description` 不管多長都要維持單一實體行**——這個 repo 裡每一份 `description` 都是沒有換
  行的一整行，跟它下方會手動折行的本文不一樣。像本文那樣手動折成好幾行，會產生一個跨多行的
  plain YAML scalar，有些 frontmatter parser（包括 VS Code 的）會直接拒絕（「Implicit keys
  need to be on a single line」），導致 skill 的 preview 壞掉，內容其實沒有錯，只要重新併回一
  行就好。另外，description 內文裡也要避免出現沒加引號的半形「`: `」（冒號＋空白）——它會被
  當成 YAML 的 mapping 指示符，同樣會壞掉（「Nested mappings are not allowed in compact
  mappings」）；改用「—」，跟這個 repo 其他 description 的寫法一致。全形的「：」是不同的字
  元，用它是安全的。

只要在這個 repo 裡新增或修改了 `SKILL.md`、`references/*.md`、`.claude/agents/*.md`、
`.claude/CLAUDE.md`，或 `.github/copilot-instructions.md`：

1. **同一個回合內立刻重新產生對應的 `_Cht` 對照版**——不用等使用者再要求一次，這是這個 repo 既
   有的標準做法。絕對不要直接編輯 `_Cht` 檔案；它永遠是從英文原文衍生出來的。
2. **在這個 repo 裡 commit**，走 `git-commit` skill 的流程（跟其他任何 commit 一樣，動作前先載
   入該 skill）。依照這個 repo 自己的 `CLAUDE.md`，skill／文件類的變更不需要計畫或事先核准——翻
   譯完直接進到 commit 即可。
