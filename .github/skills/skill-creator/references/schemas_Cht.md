# JSON Schemas

本文件定義 skill-creator 使用的 JSON 結構與範例。

---

## evals.json

定義技能的評測（evals）。位於技能目錄的 `evals/evals.json`。

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's example prompt",
      "expected_output": "Description of expected result",
      "files": ["evals/files/sample1.pdf"],
      "expectations": [
        "The output includes X",
        "The skill used script Y"
      ]
    }
  ]
}
```

**欄位說明:**
- `skill_name`: 與技能 frontmatter 中的 name 相符
- `evals[].id`: 唯一整數識別碼
- `evals[].prompt`: 要執行的任務描述
- `evals[].expected_output`: 可讀性描述的成功條件
- `evals[].files`: 可選，輸入檔路徑（相對於技能根目錄）
- `evals[].expectations`: 可驗證的陳述清單

---

## history.json

追蹤 Improve 模式下的版本演進，位於工作區根目錄。

```json
{
  "started_at": "2026-01-15T10:30:00Z",
  "skill_name": "pdf",
  "current_best": "v2",
  "iterations": [
    {
      "version": "v0",
      "parent": null,
      "expectation_pass_rate": 0.65,
      "grading_result": "baseline",
      "is_current_best": false
    }
  ]
}
```

**欄位說明:**
- `started_at`: 改良開始時間（ISO 時間字串）
- `skill_name`: 被改良的技能名稱
- `current_best`: 目前表現最好的版本識別
- `iterations[]`: 各版本的摘要（父版本、pass rate、分數、是否為目前最佳）

---

## grading.json

Grader 代理的輸出，位於 `<run-dir>/grading.json`。

```json
{
  "expectations": [
    {
      "text": "The output includes the name 'John Smith'",
      "passed": true,
      "evidence": "Found in transcript Step 3: 'Extracted names: John Smith, Sarah Johnson'"
    }
  ],
  "summary": {
    "passed": 2,
    "failed": 1,
    "total": 3,
    "pass_rate": 0.67
  }
}
```

**欄位說明:**
- `expectations[]`: 經評分的期望與證據
- `summary`: 聚合通過/失敗統計
- `execution_metrics`: 執行工具呼叫與輸出大小（若可用）
- `timing`: 執行時間（若可用）
- `claims`: 從輸出中擷取並驗證的主張
- `user_notes_summary`: 執行者註記
- `eval_feedback`: 對評測本身的改善建議（若有）

---

## metrics.json

執行者（executor）輸出的度量，位於 `<run-dir>/outputs/metrics.json`。

```json
{
  "tool_calls": {
    "Read": 5,
    "Write": 2,
    "Bash": 8
  },
  "total_tool_calls": 18,
  "total_steps": 6,
  "files_created": ["filled_form.pdf", "field_values.json"],
  "errors_encountered": 0,
  "output_chars": 12450,
  "transcript_chars": 3200
}
```

**欄位說明:**
- `tool_calls`: 各工具類型的呼叫次數
- `total_tool_calls`: 所有工具呼叫總和
- `files_created`: 輸出的檔案清單
- `output_chars`: 輸出檔案總字元數（近似 token）

---

## timing.json

執行的牆鐘時間資訊，位於 `<run-dir>/timing.json`。

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3,
  "executor_start": "2026-01-15T10:30:00Z",
  "executor_end": "2026-01-15T10:32:45Z"
}
```

**注意:** 當子代理完成時會在通知中提供 `total_tokens` 與 `duration_ms`，請即時儲存，否則無法回復。

---

## benchmark.json

Benchmark 模式的輸出，位於 `benchmarks/<timestamp>/benchmark.json`。包含 metadata、每次執行的 runs 清單、以及 run_summary 等統計資訊。請參考原始範例以確保欄位名稱與結構正確。

---

## comparison.json

盲評比較器的輸出，位於 `<grading-dir>/comparison-N.json`。範例格式包含 `winner`, `reasoning`, `rubric`, `output_quality`, `expectation_results` 等欄位。

---

## analysis.json

事後分析器（post-hoc analyzer）的輸出，位於 `<grading-dir>/analysis.json`。包含比較摘要、勝方強項、敗方弱點、指令遵循分數與改善建議等。

---

以上 schemas 是 viewer 與相關腳本依賴的精確結構。手動建立或修改這些 JSON 時，請參考這裡的欄位說明以避免欄位名稱錯誤導致檢視器顯示空值或錯誤。
