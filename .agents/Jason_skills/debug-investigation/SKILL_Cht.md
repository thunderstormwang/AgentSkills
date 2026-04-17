---
name: debug-investigation
description: >
  協作除錯 SOP。當使用者回報錯誤、異常、非預期行為或功能損壞時觸發。在任何代碼變更前強制執行結構化診斷：呈現診斷區塊 → 提出包含風險評估的修復方案 → 等待明確核准 → 套用 → 驗證。
  關鍵字：bug, error, broken, not working, wrong data, exception, failing, issue, problem。
---

# 技能：除錯調查 (Debug Investigation)

**目的**：確保每一次錯誤修復都始於結構化、有證據支持的診斷，並獲得使用者的明確核准 —— 避免盲目的代碼變更引入新問題。

> **專案特定細節**（日誌路徑、建置指令、目錄慣例）來自於 `copilot-instructions.md`，該檔案始終存在於上下文（Context）中。

---

## 執行觸發

當使用者執行以下操作時啟用此技能：
- 回報 bug、錯誤（error）或異常（exception）
- 表示某些功能 "not working"、"broken"、"wrong" 或 "unexpected"
- 貼上錯誤訊息、堆疊追蹤（stack trace）或日誌輸出
- 回報看起來不正確的資料
- 詢問「為什麼會發生 X？」

---

## 執行步驟

### 步驟 1 — 優先收集證據
在形成任何假設之前，先收集：

- 檢查近期日誌（使用 `copilot-instructions.md` 中的專案特定日誌位置）
- 尋找相關的原始碼檔案
- 閱讀錯誤訊息中提到的特定代碼區域

閱讀相關的原始碼檔案。在診斷代碼哪裡出錯之前，先理解代碼原本「應該」做什麼。

---
### 步驟 1 — 優先收集證據 (詳盡的專案掃描)
在形成任何假設之前，執行詳盡且全專案範圍的證據收集，以確保調查涵蓋所有相關的代碼路徑與整合點。至少應完成下方的清單，並將每個檢查過的檔案/路徑記錄在 `INVESTIGATION_REPORT.md` 中。

- 日誌與重現
  - 檢視近期日誌末尾：`tail -n 500 [LOG_PATH]` 並過濾 error/exception 等字眼。
  - 擷取精確的重現步驟、請求負載 (payload)、時間戳記以及任何環境變數。

- 全專案範圍代碼搜尋 (在 repo 根目錄執行這些指令)
  - 搜尋 controllers/routes：`rg --line-number "\[Route|Controller" src/`
  - 搜尋 MediatR handlers 與 CQRS：`rg --line-number "IRequestHandler|Handler" src/`
  - 搜尋整合事件 (integration events) 與 topics：`rg --line-number "IntegrationEvent|PXB2C.Cdc|CreateTopicOption" src/`
  - 搜尋 Kafka/消費者/生產者 進入點：`rg --line-number "Kafka|SubscribeCdc|AddKafka|EventBus" src/`
  - 搜尋 BigQuery 與合併邏輯：`rg --line-number "BigQueryWrapper|MergeRowsAsync|MERGE" src/`
  - 搜尋資料模型 / DTOs / EF Core：`rg --line-number "class .*Model|DbSet<|EntityTypeBuilder" src/`
  - 搜尋配置與 appsettings：`rg --line-number "MySqlConnection|BigQuerySettings|KafkaSetting|CentralControl" src/` 並檢查 `Program.cs`。
  - 搜尋異常處理與日誌調用：`rg --line-number "Log(Error|Warning|Information)" src/`
  - 搜尋測試：`rg --line-number "\b[Test|Fact|Theory]\b" || true`

- 針對受影響符號的調用圖 (Call-graph) / 使用情況檢查
  - 給定一個受影響的符號（方法/類別/屬性），執行 `rg --line-number "<SymbolName>"` 以找出所有調用者與相關檔案。
  - 在報告中記錄調用者集合與鏈條 (調用者 → 被調用者)。

- 基礎設施與部署檔案
  - 檢查 `Program.cs` 的 DI 註冊與 `AddKafka()` 註冊。
  - 檢查 `src/*/Dockerfile`、`appsettings*.json`、`nlog.*.config` 以及任何現有的 k8s manifest。

- 資料 / 持久化
  - 尋找資料庫 Schema 映射與遷移 (EF Core migrations 或 SQL 檔案)。`rg --line-number "Migration|HasColumnType|ToTable\(" src/`
  - 確認發生錯誤的流程是否觸及 BigQuery、MySQL 或 Redis；檢查整合封裝 (wrapper) 代碼。

- 執行階段與環境檢查
  - 確認發生錯誤的環境所使用的環境變數、連線字串與功能開關 (feature flags)。

- 快速健全性測試 (Sanity tests)
  - 在本地建置方案：`dotnet build PXBox.BQProxy.Service.sln` 並擷取錯誤。
  - 執行涵蓋發生錯誤區域的特定單元/整合測試（若有）。

檢查清單規則
- 對於每個檢查過的檔案或符號，在 `INVESTIGATION_REPORT.md` 中新增一行註解 (路徑:原因:快速查找)。範例：`src/PXBox.BQProxy.Infrastructure/BigQueryWrapper.cs:檢查了 MergeRowsAsync 對於刪除的處理`。
- 不要假設只有單一檔案；跟隨調用者與 DI 註冊，直到觸及根整合點 (Kafka 消費者, BigQuery 封裝器, 資料庫上下文, 外部 API)。
- 如果錯誤行為橫跨多個服務 (例如 Kafka → handler → BigQuery)，請列出完整追蹤：`topic -> handler -> wrapper -> BigQuery table`。

---

## 模式選擇 (重要)

在收集完初步證據後，詢問使用者接下來的調查希望使用哪種模式：

- **A — 病急亂投醫 (Quick Fix)**：優先考慮快速、務實的修復或變通方案 (workaround)。跳過部分診斷步驟，立即嘗試針對性補丁。適用於當系統上線時間或快速恢復比完整的根因調查更重要時。
- **B — 根因優先 (Root-Cause First)**：在進行任何代碼變更之前，執行完整的結構化調查。這是預設且最安全的模式。

當使用者未明確選擇時，預設為 **B — 根因優先**。

將選擇的模式記錄在 `INVESTIGATION_REPORT.md`（若有使用）的 `Mode:` 欄位中。

---

### (已移動) 報告提示

提示與報告範本已合併至步驟 2 (診斷)。關於 `INVESTIGATION_REPORT.md` 的流程與範本，請參閱下方的步驟 2。

---

### 步驟 2 — 呈現診斷區塊

始終使用此格式 —— 絕不跳過診斷直接進行修復：

```
DIAGNOSIS:
Problem:  [簡潔的一句話 — 哪裡出錯了]
Evidence: [日誌行 / 包含 檔案:行號 參考的代碼片段]
Location: [根因所在的精確檔案與行號]
Impact:   [這對使用者 / 系統造成的損壞結果]
```

在呈現 `DIAGNOSIS` 區塊後，詢問使用者是否為此對話建立調查記錄：

```
您是否希望我為此調查建立「調查報告」(Investigation Report)？
這會在功能資料夾 (spec/features/NNN/) 中建立一個 `INVESTIGATION_REPORT.md`，
並在整個除錯過程中持續更新 —— 擷取發現、修復方案與驗證結果。

→ 是 / 否
```

如果選擇「是」：使用以下結構建立 `spec/features/NNN/INVESTIGATION_REPORT.md`。
如果選擇「否」：繼續進行而不建立檔案。

**調查報告結構**：
```markdown
# 調查報告：[Bug 描述]

**功能 (Feature)**：FEAT-NNN
**日期**：YYYY-MM-DD
**環境**：[UAT / SIT / Prod]
**模式**：[A — 病急亂投醫 / B — 根因優先]

## Bug 描述
[一個段落 — 使用者回報了什麼]

## 診斷 (初步)
[填入步驟 2 中建立的 DIAGNOSIS 區塊]

## 調查發現
[在步驟 3–4 過程中填入]

## 根因 (Root Cause)
[在步驟 4 確定後填入]

## 套用的修復方案
[在步驟 6 之後填入]

## 驗證
[在步驟 7 之後填入]

## 結果
[ ] Bug 已解決  [ ] 部分解決  [ ] 已向上呈報
```

在每個相關步驟後更新報告。最終文件將成為該次除錯對話的永久記錄。

---

### 步驟 3 — 若根因不明，呈現調查檢查清單

當原因尚未確定時，提供分層的調查計畫：

```
調查檢查清單 (INVESTIGATION CHECKLIST)：

□ 第 1 層：[例如：API 回應 / 外部服務]
  □ 檢查：[欲執行的精確指令/查詢]
  □ 預期：[成功的樣子]
  □ 警示 (Red flag)：[指出問題出在此處的徵兆]

□ 第 2 層：[例如：資料映射 / 業務邏輯]
  □ 檢查：[欲執行的精確指令/查詢]
  □ 預期：[成功的樣子]
  □ 警示 (Red flag)：[指出問題出在此處的徵兆]

□ 第 3 層：[例如：前端 / UI 層]
  □ 檢查：[如何在瀏覽器中檢查 / 欲 grep 的關鍵字]
  □ 預期：[成功的樣子]
  □ 警示 (Red flag)：[指出問題出在此處的徵兆]

從「第 1 層」開始。在繼續之前先回報發現。
```

---

### 步驟 4 — 提出修復區塊

一旦確定根因，呈現：

```
PROPOSED FIX:
Change: [欲修改內容 — 一個具體的變更]
From:   [目前的代碼/行為]
To:     [修復後的代碼/行為]
Why:    [為什麼這能解決根因的技術解釋]
Risk:   [任何需要留意的潛在副作用或回歸風險]
```

---

### 步驟 5 — 等待核准 (模式感知)

在進行非微不足道的變更前，始終確認意圖。

如果模式為 **B — 根因優先**：在編輯檔案前，務必明確詢問（下方的「後續步驟」清單）。

如果模式為 **A — 病急亂投醫**：需要明確的快速修復授權，例如 `QUICK_FIX: please apply the patch now` 或簡短的核准訊息。代理人（Agent）隨後會套用最小、針對性的變更，並清楚標註風險。

```
後續步驟 (NEXT STEPS)：
□ 執行上述修復方案？
□ 先調查另一層？
□ 嘗試替代方案？

您的決定：執行 / 進一步調查 / 建議替代方案？
```

在使用者針對所選模式給予適當核准前，**不得**編輯檔案。

---

### 步驟 6 — 套用修復方案

獲得核准後：
1. 依照「提出修復區塊」中的描述，進行單一、針對性的變更。
2. 除非與 bug 直接相關，否則不要重構周圍代碼。
3. 不要在同一次異動中「改進」代碼風格 —— 保持修復內容最小化且易於審閱。

---

### 步驟 7 — 驗證

套用後：
1. 執行專案的建置指令（參見 `copilot-instructions.md` 以獲得精確指令）。
2. 執行與該 bug 類型相關的針對性驗證。

使用此格式回報結果：
```
VERIFICATION:
Build:    ✅ 0 個錯誤
Test:     [檢查了什麼以及結果為何]
Status:   ✅ Bug 已解決 / ⚠️ 部分解決 (註明剩餘問題) / ❌ 仍失敗
```

---

### 步驟 8 — 更新功能狀態 (若有關聯)

如果 bug 與 `spec/features/` 中追蹤的功能相關聯，請更新該功能的 `README.md`：
- **Bug 已確認且尚未解決 / 阻礙進度**：設定 `Status` = 🔴 Blocked, Updated = 今天
- **Bug 已解決且原本處於阻礙狀態**：恢復 `Status` = 🔵 In Progress, Updated = 今天
- **Bug 已解決但原本未阻礙功能**：不需要變更功能狀態

---

## 規則

- ❌ **絕不**在呈現診斷之前編輯檔案
- ❌ **絕不**在未解釋根因的情況下貼上修復方案
- ❌ **絕不**在單次 bug 修復中進行多個無關的變更
- ✅ 保持修復內容最小化 —— 僅觸及損壞的部分
- ✅ 如果調查揭示了更深層的架構問題，請分開標註；現在僅修復眼前的 bug
- ✅ 教導原因：簡短解釋為什麼會發生此 bug，以便下次能識別此模式

---

## 教學格式 (選填 — 針對架構型 bug)

當 bug 揭示了值得學習的結構化模式時：

```
CONCEPT: [主題名稱]

內容 (WHAT)：           [簡單定義]
重要性 (WHY IT MATTERS)：[這如何解釋目前的 bug]
應用於此 (APPLIES HERE)：[與眼前的代碼/bug 的具體關聯]
下次注意 (NEXT TIME)：   [未來需要留意的模式]
```

---

## 診斷指令參考

> **注意**：下方的指令為通用模式。請參閱 `copilot-instructions.md` 以獲得專案特定的路徑與工具。

| 情境 | 通用做法 |
|---|---|
| 檢查應用程式日誌 | `tail -200 [LOG_PATH] \| grep -i "error\|exception"` |
| 在專案中尋找檔案 | `find . -name "*.ext" \| xargs grep -l "[ClassName]"` |
| 尋找 route 定義 | 在 controller/router 檔案中搜尋 route 屬性 |
| 檢查資料模型 | 在 model 檔案中搜尋 class/interface 定義 |
| 尋找 UI 錯誤 | 在 view 檔案中搜尋 `console.error`, `catch`, error handlers |
| 建置並檢查錯誤 | 執行專案建置指令，並透過管道傳送至 `grep -E "error\|warning"` |
