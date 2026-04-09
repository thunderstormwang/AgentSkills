---
name: skill-creator
description: 建立新技能、修改與改進既有技能，並衡量技能效能。當使用者想從頭建立技能、編輯或優化既有技能、執行評測以測試技能、使用基準測試分析技能效能差異，或優化技能描述以提高觸發準確度時使用。
---

# 技能建立器

一個用來建立新技能並迭代改進它們的技能。

整體上，建立技能的流程大致如下：

- 決定你希望技能做什麼，以及大致的實作方式
- 撰寫技能草稿
- 建立幾個測試提示並使用 claude-with-access-to-the-skill 執行
- 協助使用者從質性與量化兩方面評估結果
  - 在執行期間可先草擬量化評測（如果還沒有的話），如果已有評測則可以直接使用或視需要修改。然後向使用者解釋這些評測
  - 使用 `eval-viewer/generate_review.py` 腳本向使用者展示結果並讓他們查看量化指標
- 根據使用者的回饋重寫技能（以及從量化基準中發現的任何重大缺陷）
- 重複上述步驟直到滿意
- 擴充測試集並以更大尺度重試

在使用此技能時的工作是判斷使用者目前處於此流程的哪一個階段，然後協助他們向前推進。例如，使用者可能說「我想為 X 做一個技能」，你可以協助釐清需求、撰寫草稿、設計測試案例、執行提示，並持續迭代。

如果使用者已經有技能草稿，你可以直接進入評測/迭代階段。

當然，流程可以彈性處理；如果使用者說「我不需要跑大量評測，只想先試試看」，也可以採取較輕量的做法。

完成技能之後（順序可彈性），可以執行描述優化腳本來提高觸發率。

好嗎？

## 與使用者溝通

技能建立器會被各種程度的使用者使用。請根據對話中的語境提示決定用詞與說明的深度。一般建議：

- 對於「evaluation」與「benchmark」等詞彙可視情況使用而不一定要翻譯
- 對於 "JSON" 與 "assertion" 等術語，若不確定使用者是否熟悉，請簡短說明

若不確定，可簡短解釋術語並確認使用者是否了解。

---

## 建立技能

### 捕捉意圖

先了解使用者的意圖。若對話已包含一個可轉成技能的工作流程（例如使用者說「把這個變成技能」），先從對話歷史中擷取工具、步驟順序、修正紀錄、輸入/輸出格式等資訊。詢問缺口並在繼續前讓使用者確認。

你需問的問題範例：
1. 這個技能應該讓 Claude 能做什麼？
2. 什麼情境下應該觸發此技能？（使用者語句或上下文）
3. 預期輸出格式為何？
4. 是否需要建立測試案例來驗證？（對於可客觀驗證的技能建議建立測試案例）

### 訪談與研究

主動詢問邊界情況、輸入/輸出格式、範例檔案、成功標準與相依性。除非必要，先不要寫測試提示，直到這些細節釐清。若需要做研究（例如查找相似技能或最佳做法），可並行使用子代理進行搜尋，並帶回具體上下文以減少使用者負擔。

### 撰寫 SKILL.md

根據使用者訪談填入下列要素：

- **name**：技能識別
- **description**：何時觸發、此技能做什麼。這是觸發機制的主要內容——應同時包含「何時使用」與「此技能能做什麼」。把「何時使用」資訊放在 description 中，而不是放在正文。
- **compatibility**：必要工具、相依套件（選填）
- **其餘技能內容**

### 技能撰寫指南

#### 技能結構

```
skill-name/
├── SKILL.md (必要)
│   ├── YAML frontmatter (name, description 必要)
│   └── Markdown 指示
└── Bundled Resources (選填)
    ├── scripts/    - 可執行腳本
    ├── references/ - 上下文文件
    └── assets/     - 輸出用的模板、圖示、字型
```

#### 漸進式揭露

技能有三層載入系統：
1. **Metadata**（name + description）— 總是載入（約 100 字以內）
2. **SKILL.md 本文**— 在技能觸發時載入（理想 < 500 行）
3. **綁定資源**— 視需要載入（腳本可執行而無需全部載入）

如果 SKILL.md 快接近 500 行，考慮再做分層並在文件中清楚指引模型去哪裡查看後續內容。

**撰寫要點：**
- 將 SKILL.md 控制在 500 行以內；若需要更長內容，將大型參考檔拆出並在 SKILL.md 中提供導引
- 明確引用並說明何時需要讀取參考檔
- 對超過 300 行的大型參考檔，提供目錄

#### 原則：避免驚訝

技能內容不得包含惡意程式碼或任何可能危害系統安全的內容。技能描述應忠實反映用途，不要製作誤導性或用於未授權存取的技能。

#### 撰寫風格

使用祈使句撰寫指示。若需定義輸出格式，可如下示例：

```markdown
## Report structure
ALWAYS use this exact template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

範例模式也很有用：

```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### 撰寫風格建議

解釋為何要這麼做，避免使用過度強硬的 MUST。說明背後的原因，讓模型能夠理解目的並做出更靈活的判斷。

### 測試案例

草擬 2–3 個真實的測試提示（使用者可能真的會說的話），並與使用者討論：「以下是我建議要嘗試的測試案例，是否合適？」

將測試案例儲存到 `evals/evals.json`。初期可以只放提示（prompt），稍後再補入 assertions。

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "Description of expected result",
      "files": []
    }
  ]
}
```

詳情請參閱 `references/schemas.md`。

## 執行與評估測試案例

這個章節描述一個連續流程——不要中途停止，也不要使用 `/skill-test` 或其他測試技能代替本流程。

把結果放在 `<skill-name>-workspace/` 作為技能目錄的鄰居。在 workspace 中以 iteration 組織結果（`iteration-1/`, `iteration-2/`），每次迭代下再以測試案例目錄（`eval-0/`, `eval-1/`）分類。

### 第 1 步：同一回合產生所有執行（with-skill 與 baseline）

對每個測試案例，同一回合啟動兩個子代理：一個帶技能（with_skill）、一個不帶（baseline）。這很重要：不要先跑有技能版本再回頭跑 baseline，要同時啟動以讓它們大致同時完成。

**With-skill 執行：**
```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what the user cares about — e.g., "the .docx file", "the final CSV">
```

**Baseline 執行**（依情境而定）：
- 若是建立新技能：baseline 為沒有技能（no skill）
- 若是改良現有技能：baseline 為舊版本，請先備份原始技能再指向舊版本

為每個測試案例寫一個 `eval_metadata.json`（`assertions` 初期可留空）。

```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

### 第 2 步：執行期間草擬 assertions

不要只是等結果——在執行過程中草擬量化 assertion。好的 assertions 是客觀可驗證的，並且在檢視基準檢視器時能清楚表達它們檢查的內容。主觀類型（例如寫作風格）通常用質性評估，不必強制用 assertion。

更新 `eval_metadata.json` 與 `evals/evals.json`，並向使用者說明在檢視器中會看到哪些資訊（質性輸出 + 量化基準）。

### 第 3 步：當執行完成時，擷取時間資料

當每個子代理完成時，你會收到包含 `total_tokens` 與 `duration_ms` 的通知。請立刻把這些資料寫入本次執行的 `timing.json`：

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

這些資料只會在通知中出現一次，請即時處理。

### 第 4 步：評分、彙整並啟動檢視器

所有執行完成後：

1. **對每次執行評分** — 啟動 grader 子代理（或內聯評分），參考 `agents/grader.md`，並把結果存成 `grading.json`。`grading.json` 內的 expectations 欄位必須使用 `text`, `passed`, `evidence` 等欄位。

2. **彙整成 benchmark** — 使用 skill-creator 目錄下的聚合腳本：

```bash
python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
```

此腳本會產生 `benchmark.json` 與 `benchmark.md`，包含各設定的 pass_rate、時間與 token 數的平均與標準差。

3. **做分析師檢視** — 檢視基準資料並提出聚合指標可能隱藏的模式（參考 `agents/analyzer.md`）。

4. **啟動檢視器**：

```bash
nohup python <skill-creator-path>/eval-viewer/generate_review.py \
  <workspace>/iteration-N \
  --skill-name "my-skill" \
  --benchmark <workspace>/iteration-N/benchmark.json \
  > /dev/null 2>&1 &
VIEWER_PID=$!
```

對於非互動/無顯示的環境，可使用 `--static <output_path>` 產生 HTML 檔案而不啟動伺服器。

5. **告知使用者**：例如「已在瀏覽器開啟檢視器，Outputs 與 Benchmark 頁籤分別顯示質性輸出與量化統計。完成後請回來告訴我。」

### 使用者在檢視器中看到的內容

- **Outputs**：每個測試案例一次顯示一個
  - Prompt
  - Output（可內嵌呈現檔案）
  - Previous Output（若為第二次以上迭代）
  - Formal Grades（若有評分）
  - Feedback 文本框（自動儲存）

- **Benchmark**：顯示每個設定的 pass rates、時間與 token 使用量，並有每個 eval 的細項與分析師觀察。

使用者完成後按「Submit All Reviews」，會下載 `feedback.json`。

### 第 5 步：讀取使用者回饋

當使用者完成回饋，讀取 `feedback.json` 並聚焦在有具體問題的測試案例。空白回饋代表使用者覺得沒問題。

---

## 改善技能（Iteration）

當你有回饋後就是改進技能的重點階段：

### 改善思考方式

1. **從回饋概括抽象化**：不要只針對範例微調，應思考如何讓技能在不同情境下泛化
2. **讓 prompt 精簡**：移除沒產出價值的步驟，檢視執行記錄來找出浪費時間的部分
3. **解釋原因**：多用「為何這樣做」來幫助模型理解目的，而不是硬性規則
4. **尋找重複工作**：若多個執行都產生相同的 helper script，將它打包到 `scripts/` 中

### 迭代流程

每次改進後：
1. 把修改應用到技能
2. 重新跑所有測試（含 baseline）到新 iteration
3. 用 `--previous-workspace` 比較前後差異
4. 等使用者檢視並回饋
5. 重複直到滿意或無進展

---

## 進階：盲評比較

若需嚴格比較兩個版本（例如「新版本真的比較好嗎？」），可使用盲評流程。參考 `agents/comparator.md` 與 `agents/analyzer.md`。

---

## 描述優化

SKILL.md 的 description 欄位是 Claude 判斷是否使用技能的主要依據。優化描述能顯著改變觸發率。

### 第 1 步：產生觸發測試查詢

建立 20 個測試查詢（should-trigger 與 should-not-trigger 各 8–10），以 JSON 儲存：

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

查詢要具代表性且具細節（檔名、欄位名稱、場景等），不要用過於抽象的句子。

### 第 2 步：與使用者審查

把測試集呈現給使用者（HTML 模板），讓他們調整。具體做法請參考 SKILL.md 原文。

### 第 3 步：執行優化迴圈

可使用 `run_loop.py` 自動化迴圈，會做 train/test 切分並嘗試多次迭代，最後回傳 `best_description`。

### 第 4 步：套用結果

把 `best_description` 更新回 SKILL.md 的 frontmatter，並向使用者展示前後差異與分數。

---

## 打包與呈現（若有 present_files 工具）

如可存取 `present_files`，可執行：

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

產生 `.skill` 檔後告知使用者路徑供下載安裝。

---

## Claude.ai 專用指引

若在 Claude.ai 平台（無子代理），請採簡化流程：
- 逐個測試案例執行（無法並行）
- 跳過 baseline 執行
- 直接在對話中呈現結果並取得回饋
- 跳過自動化的量化基準（因為缺乏子代理）

其他細節請參見原文。

---

## Cowork 特定指引

Cowork 環境支援子代理但通常無圖形顯示；請使用 `--static` 產生靜態 HTML 檢視器，並確保使用者可下載 `feedback.json`。

---

## 參考檔

- `agents/grader.md`
- `agents/comparator.md`
- `agents/analyzer.md`
- `references/schemas.md`

---

重申核心迴圈：

- 釐清技能目的
- 撰寫或編輯技能
- 執行測試提示
- 與使用者一起檢視輸出並建立 `benchmark.json`，使用 `eval-viewer/generate_review.py` 幫助檢視
- 重複直到滿意

祝好運！
