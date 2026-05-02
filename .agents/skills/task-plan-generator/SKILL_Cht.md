---
name: task-plan-generator
description: 專門用於產生「純任務型計畫」的輕量化工具。適用於重構、小規模優化或實作邏輯已定案的場景。跳過冗長的設計文件，直接產出可執行的任務清單。
---

# task-plan-generator

此技能旨在產生精簡、以執行為核心的實作計畫。它是高階重構意圖與 `implementation-agent` 之間的橋樑。

## 工作流程 (Workflow)

1. **意圖分析 (Intent Analysis)**：
    - 從使用者的描述中理解重構或優化的目標。
    - 若提到特定檔案，進行精確的 `read_file` 以理解代碼現況。
2. **原子化拆解 (Atomic Decomposition)**：
    - 將需求拆解為**原子化任務 (Atomic Tasks)**。
    - 每個任務必須足夠小，以便獨立實作與提交（理想情況下影響 1-3 個檔案）。
3. **計畫產生 (Plan Generation)**：
    - 建立或更新一個 Markdown 檔案，且必須包含以下結構：
        - `# [標題]`
        - `---`
        - `### Task 進度表`：包含 `ID`、`項目`、`狀態`（預設為 `Todo`）的表格。
        - `---`
        - `### Task 實作細節`：針對每個 Task ID 的詳細技術指令，註明檔案路徑與邏輯。
4. **相容性檢查 (Compatibility Check)**：
    - 確保產出的計畫完全符合 `implementation-agent` 與 `implementation` 技能的執行規範。

## 指導方針 (Guidelines)
- **繁體中文**：產出的計畫內容與使用者溝通必須使用繁體中文。
- **簡潔性**：避免冗餘的需求分析或設計章節，完全專注於「做什麼」與「如何驗證」。
- **命名規範**：為產出的計畫檔案使用清晰的描述性名稱（例如：`refactor-xxx-plan.md`）。
