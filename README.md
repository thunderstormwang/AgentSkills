# AgentSkills

## 將 Repo 內的 skill 放到全域

在 Windows 上你可以這樣跟 AI 說：  
> 「我的作業系統是 Windows。請幫我建立一個 Junction，將全域目錄 %USERPROFILE%\.agents\skills 指向我目前 Repo 的 .agents\skills 目錄。」  

對於 Mac Book Pro(macOS)，你只需要稍微調整描述，強調路徑和 symlink 關鍵字即可。最精確的說法如下：
> 「這台是 Mac，請幫我用 ln -s 建立 Symbolic Link，將全域的 ~/.agents/skills 指向我目前 Repo 的 .agents/skills 目錄，並確保父目錄存在。」

## 將 Repo 內的 agent 放到全域

Agent 與 skill 一樣有兩層 scope：project（`<repo>\.claude\agents`）與 user（`%USERPROFILE%\.claude\agents`），同名時 project 覆蓋 user。**若只放在本 repo，agent 就只有在本 repo 內叫得出來**，所以 agents 目錄同樣要做連結。

在 Windows 上你可以這樣跟 AI 說：  
> 「我的作業系統是 Windows。請幫我建立一個 Junction，將全域目錄 %USERPROFILE%\.claude\agents 指向我目前 Repo 的 .claude\agents 目錄。」  

對於 Mac Book Pro(macOS)：
> 「這台是 Mac，請幫我用 ln -s 建立 Symbolic Link，將全域的 ~/.claude/agents 指向我目前 Repo 的 .claude/agents 目錄，並確保父目錄存在。」

> Claude Code 沒有 `/agent <name>` 或 `@<name>` 這種呼叫語法——在指令中**直接指名 agent** 就是呼叫方式（`@` 在 Claude Code 是檔案路徑補全，`/` 是 skill）。

## 將 Repo 內的 instruction 放到全域

對於 Mac Book Pro(macOS):  
> 請幫我建立一個軟連結(Symbolic Link)，將全域設定檔 ~/.claude/CLAUDE.md 指向目前目錄的 CLAUDE.md。

> 建立軟連結，讓全域 ~/.copilot/copilot-instructions.md 指向 目前 repo 的 .github/copilot-instructions.md

對於 Windows:
> 將全域路徑 $HOME\.claude\CLAUDE.md 建立一個軟連結到當前 Repo 的 CLAUDE.md。  

然後生出類似以下語法，但可能因為權限問題，需要手動在管理者模式的 power shell 下執行:  
> New-Item -ItemType SymbolicLink -Path "{$home}\.copilot\copilot-instructions.md" -Value "{RepoPath}\AgentSkills\.github\copilot-instructions.md"

> New-Item -ItemType SymbolicLink -Path "{$home}\.claude\CLAUDE.md" -Value  "{RepoPath}\GitRepositories\AgentSkills\CLAUDE.md"

## Junction / SymbolicLink / HardLink 的差異

上面兩節分別用了 Junction（目錄）與 SymbolicLink（檔案），這節說明為什麼這樣選。

首先，三者都**不是同步機制**。資料只有一份，你是透過兩個名字存取同一個東西，所以「改一邊另一邊會變」是對的，但原因不是同步，而是根本沒有「另一邊」。

### 差別在登記項裡「存的是什麼」

磁碟上有兩種東西要分開看：

- **檔案內容**存在一筆記錄裡（NTFS 叫 MFT record，Linux 叫 inode）
- 資料夾裡的**檔名**只是一筆「登記項」，裡面存著要指向誰

| | 登記項存什麼 | 適用 | 需管理者 | 目標被刪掉時 |
|---|---|---|---|---|
| **Junction** | 目標**路徑**（僅絕對路徑、僅本機） | 只有目錄 | 不用 | 連結壞掉 |
| **SymbolicLink** | 目標**路徑**（可相對、可 UNC） | 檔案 + 目錄 | 檔案要 | 連結壞掉（dangling） |
| **HardLink** | 磁碟上的**檔案本體**（MFT record） | 只有檔案、同磁碟區 | 不用 | 資料還活著 |

**HardLink** 多加的那個檔名，與原本的檔名**種類一模一樣**，作業系統看不出哪個先建立——沒有「本尊 / 分身」之分。記錄裡有**參考計數**：兩個名字時是 2，刪掉一個變 1（資料還在），變 0 才真的釋放空間。

**Symlink / Junction** 存的是一串路徑文字，**自己不含任何資料**。每次有人存取，作業系統才**當下**去解析那串路徑、再去開真正的檔案。

用鑰匙來想：

- **HardLink** = 同一個房間配了兩把鑰匙，兩把完全等價；只要還有一把，房間就保留
- **Symlink** = 一張寫著地址的便條紙。紙不是房間。房子拆了，紙還在，但照著走會找不到東西

### 什麼情況會讓連結斷掉

很多安裝器與編輯器不是原地改檔，而是**「寫暫存檔 → 改名蓋過去」**，這會產生一個全新的檔案本體。此時**被蓋掉的是哪一邊**，結果完全不同：

| 被「寫新檔 + 改名蓋過去」的是 | HardLink | Symlink / Junction |
|---|---|---|
| **目標**那一邊（如 `repo\CLAUDE.md`） | 斷 | **不斷** |
| **連結**那一邊（如 `~\.claude\CLAUDE.md`） | 斷 | 斷 |

Symlink 綁的是路徑，只要那個路徑上還有東西就通，不在乎是不是同一個檔案本體。HardLink 綁死記錄編號，新檔案 = 新記錄，所以無論哪一邊被取代都會斷。

## 參考資料

參考 Repo
- [anthropics/skills](https://github.com/anthropics/skills)
- [obra/superpowers](https://github.com/obra/superpowers)