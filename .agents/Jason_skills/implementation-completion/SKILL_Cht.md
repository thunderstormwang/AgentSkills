---
name: implementation-completion
description: >
  在宣告任何代碼完成之前的強制性完成關卡。執行專案建置指令，斷言 0 個編譯錯誤，在 spec/features/NNN/ 中建立實作完成報告 (ICR)，並交付建置輸出作為證據。在執行此技能之前，絕不向使用者告知「代碼已就緒」。
  關鍵字：done, complete, finished, ready for review, ready to test, delivered。
---

# 技能：實作完成關卡 (Implementation Completion Gate)

**目的**：強制執行「建置驗證 → 文件化 → 交付」的序列，確保在沒有成功編譯證據與可追蹤的完成記錄之前，絕不聲稱代碼已完成。

> **專案特定細節**（建置指令、專案結構、方案檔案）來自於 `copilot-instructions.md`，該檔案始終存在於上下文（Context）中。

---

## 執行觸發

當發生以下情況時啟用此技能：
- 一項功能或修復的所有計畫代碼變更皆已完成
- 準備告知使用者「代碼已完成」、「可以測試」或「完成」
- 完成一個多階段的實作（變更了 4 個以上的檔案）
- 在解決建置錯誤後，想要確認狀態是否乾淨

---

## 執行步驟

### 步驟 1 — 識別受影響的專案
確定目前的變更觸及了哪些專案/模組。

> **請參閱 `copilot-instructions.md`** 以獲得專案的建置指令映射（例如，針對哪個層級/模組應執行哪個指令）。

若有疑慮，請建置完整的專案/方案 (Solution)。

---

### 步驟 2 — 執行建置
執行專案的建置指令並擷取輸出。

尋找表示成功的摘要：
```
Build succeeded.
    0 Error(s)
    N Warning(s)
```

（精確格式依語言/工具鏈而異 —— 尋找等效的成功指標。）

---

### 步驟 3 — 斷言 0 個錯誤

**若建置失敗：**
- ❌ 不得繼續進行 ICR
- ❌ 不得告知使用者代碼已就緒
- 先修復編譯錯誤
- 重新執行步驟 2
- 重複執行直到確認 0 個錯誤

**若建置成功：**
- ✅ 繼續進行步驟 4
- 警告 (Warning) 是可以接受的 —— 請在 ICR 中註明它們

---

### 步驟 4 — 確定功能資料夾
```bash
ls spec/features/ | sort
```
識別目前正在完成的功能所屬的 `NNN-{feature-name}` 資料夾。

---

### 步驟 5 — 建立實作完成報告 (ICR)

使用 `spec/_templates/PROCESS/` 中的 ICR 範本並填寫：

**必要欄位：**
- 日期（今天）
- 功能名稱與簡短的一行描述
- 狀態：`✅ CODE COMPLETE & VERIFIED COMPILABLE`
- 建置結果：`0 compilation errors | N warnings`
- 執行摘要 (Executive Summary)（2-3 個句子）
- 每個實作階段包含：變更的檔案、變更了什麼、狀態
- 修改檔案摘要表 (Files Modified Summary)
- 建置驗證區塊 (Build Verification) — 貼上實際的建置輸出
- 遵循的架構模式 (Architectural Patterns Followed)
- 測試建議 (Testing Recommendations)
- 部署檢查清單 (Deployment Checklist)

**儲存至：** `spec/features/NNN-{feature-name}/IMPLEMENTATION_COMPLETION_REPORT.md`

---

### 步驟 6 — 交付建置證據

將交付訊息結構化如下：

```markdown
✅ 代碼實作完成。已驗證：

**建置**：[使用的建置指令]
**結果**：建置成功 — 0 個錯誤, N 個警告

**修改的檔案**（共 N 個）：
- `路徑/到/檔案1` — [變更了什麼]
- `路徑/到/檔案2` — [變更了什麼]

**ICR**：`spec/features/NNN-{feature}/IMPLEMENTATION_COMPLETION_REPORT.md`

已準備好進行代碼審閱 (Code Review) 與測試。
```

---

### 步驟 7 — 更新功能狀態

交付後，更新 `spec/features/NNN-{feature-name}/README.md`：
- 若正在等待代碼審閱或測試：設定 `Status` = 🟣 Review
- 若已完全驗證且被使用者接受：設定 `Status` = ✅ Complete
- 設定 `Updated` = 今天日期

---

## 規則

- ❌ **絕不**在沒有「建置成功」輸出的情況下說出「代碼已完成」或「可以測試」
- ❌ **絕不**在存在編譯錯誤時繼續進行 ICR —— 請先修復
- ❌ **絕不**跳過多檔案實作（4 個以上檔案）的 ICR
- ❌ **絕不**建立獨立的測試指南檔案（例如 `UAT_TESTING_GUIDE.md`, `TESTING_GUIDE.md`） —— 測試指引應作為 ICR 內部的「測試建議」區塊，而非獨立檔案
- ❌ **絕不**將任何完成產出物放在 `docs/` 下 —— 所有輸出皆存放在 `spec/features/NNN-{feature}/`
- ❌ **絕不**在測試指引中包含 SSH, `kubectl exec`, `kubectl logs` 或 `curl` 健康檢查指令 —— UAT pod 沒有外部 IP 且沒有 shell 存取權限
- ✅ 警告 (Warning) 是可以接受的 —— 請在 ICR 的「已知限制」區塊中記錄它們
- ✅ 對於少於 4 個檔案的單一檔案熱修復 (Hotfix)，ICR 是選填的，但建置驗證仍為強制性
- ✅ 始終在交付訊息中貼上實際的建置摘要行
- ✅ **測試指引中的觀測能力 (Observability)** — 僅使用 Grafana 技術棧：
  - 日誌 (Logs) → Grafana → Loki → Explore (LogQL)
  - 指標 (Metrics) → Grafana → Mimir → Explore (PromQL)
  - 追蹤 (Traces) → Grafana → Tempo

---

## 交付狀態參考

| 建置狀態 | 動作 |
|---|---|
| ✅ 0 個錯誤 | 建立 ICR → 交付 |
| ⚠️ 0 個錯誤, N 個警告 | 建立 ICR → 註明警告 → 交付 |
| 🔴 N 個錯誤 | 修復錯誤 → 重新執行建置 → 暫不交付 |

---

## 良好的交付訊息範例

```
✅ 代碼實作完成。已驗證：

建置：[專案建置指令]
結果：建置成功 — 0 個錯誤, 2 個警告

修改的檔案（共 4 個）：
- src/services/UserService.ts — 新增了會話追蹤方法
- src/routes/users.ts — 新增了 /api/users/sessions 端點
- src/models/Session.ts — 新的會話資料模型
- src/views/dashboard.html — 接通了會話圖表

ICR：spec/features/005-user-session-metrics/IMPLEMENTATION_COMPLETION_REPORT.md

已準備好進行代碼審閱與測試。
```

## 糟糕的交付訊息範例 (絕不這樣做)

```
✗ 我已經實作了變更。                   ← 無建置驗證
✗ 代碼應該可以正確編譯。               ← 是假設而非證據
✗ 可以測試了（邏輯在我看來是正確的）。   ← 未執行建置 = 尚未準備好
```
