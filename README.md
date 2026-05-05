# AgentSkills

## 將 Repo 內的 skill 放到全域

在 Windows 上你可以這樣跟 AI 說：  
> 「我的作業系統是 Windows。請幫我建立一個 Junction，將全域目錄 %USERPROFILE%\.agents\skills 指向我目前 Repo 的 .agents\skills 目錄。」  

對於 Mac Book Pro(macOS)，你只需要稍微調整描述，強調路徑和 symlink 關鍵字即可。最精確的說法如下：
> 「這台是 Mac，請幫我用 ln -s 建立 Symbolic Link，將全域的 ~/.agents/skills 指向我目前 Repo 的 .agents/skills 目錄，並確保父目錄存在。」

## 將 Repo 內的 instruction 放到全域

對於 Mac Book Pro(macOS):  
> 請幫我建立一個軟連結(Symbolic Link)，將全域設定檔 ~/.gemini/gemini.md 連結到目前目錄的 GEMINI.md。

對於 Windows:
> 將全域路徑 $HOME\.gemini\gemini.md 建立一個軟連結到當前 Repo 的 GEMINI.md。  

## 參考資料

參考 Repo
- [anthropics/skills](https://github.com/anthropics/skills)
- [obra/superpowers](https://github.com/obra/superpowers)