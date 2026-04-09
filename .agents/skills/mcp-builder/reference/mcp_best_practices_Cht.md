# MCP 伺服器最佳實踐

## 快速參考

### 伺服器命名
- **Python**：`{service}_mcp`（例如 `slack_mcp`）
- **Node/TypeScript**：`{service}-mcp-server`（例如 `slack-mcp-server`）

### 工具命名
- 使用 snake_case 搭配服務字首
- 格式：`{service}_{action}_{resource}`
- 範例：`slack_send_message`、`github_create_issue`

### 回應格式
- 支援 JSON 與 Markdown 格式
- JSON 用於程式化處理
- Markdown 用於人類可讀性

### 分頁
- 始終尊重 `limit` 參數
- 傳回 `has_more`、`next_offset`、`total_count`
- 預設為 20-50 項目

### 傳輸
- **可串流 HTTP**：用於遠端伺服器、多用戶端情境
- **stdio**：用於本地整合、命令列工具
- 避免 SSE（已棄用，偏好可串流 HTTP）

---

## 伺服器命名慣例

遵循這些標準化命名模式：

**Python**：使用格式 `{service}_mcp`（小寫加底線）
- 範例：`slack_mcp`、`github_mcp`、`jira_mcp`

**Node/TypeScript**：使用格式 `{service}-mcp-server`（小寫加連字號）
- 範例：`slack-mcp-server`、`github-mcp-server`、`jira-mcp-server`

名稱應為一般、描述被整合的服務、易於從任務描述推斷且無版本號。

---

## 工具命名與設計

### 工具命名

1. **使用 snake_case**：`search_users`、`create_project`、`get_channel_info`
2. **包含服務字首**：預期您的 MCP 伺服器可能與其他 MCP 伺服器一起使用
   - 使用 `slack_send_message` 而不是只是 `send_message`
   - 使用 `github_create_issue` 而不是只是 `create_issue`
3. **以動作導向**：以動詞開始（get、list、search、create 等）
4. **具體**：避免可能與其他伺服器衝突的通用名稱

### 工具設計

- 工具描述必須狹隘且明確地描述功能
- 描述必須精確符合實際功能
- 提供工具註解（readOnlyHint、destructiveHint、idempotentHint、openWorldHint）
- 讓工具操作聚焦且原子性

---

## 回應格式

返回資料的所有工具應支援多個格式：

### JSON 格式（`response_format="json"`）
- 機器可讀結構化資料
- 包含所有可用欄位與中繼資料
- 一致的欄位名稱與型別
- 用於程式化處理

### Markdown 格式（`response_format="markdown"`，通常為預設）
- 人類可讀格式化文字
- 使用標題、清單與格式以提供清晰度
- 將時間戳記轉換為人類可讀格式
- 與括號中的 ID 顯示顯示名稱
- 省略冗長中繼資料

---

## 分頁

對於列出資源的工具：

- **始終尊重 `limit` 參數**
- **實作分頁**：使用位移或基於游標的分頁
- **傳回分頁中繼資料**：包含 `has_more`、`next_offset`/`next_cursor`、`total_count`
- **絕不載入所有結果到記憶體**：特別是對於大型資料集
- **預設為合理限制**：通常為 20-50 項目

範例分頁回應：
```json
{
  "total": 150,
  "count": 20,
  "offset": 0,
  "items": [...],
  "has_more": true,
  "next_offset": 20
}
```

---

## 傳輸選項

### 可串流 HTTP

**最適合**：遠端伺服器、網路服務、多用戶端情境

**特性**：
- 雙向 HTTP 通訊
- 支援多個同時用戶端
- 可部署為網路服務
- 啟用伺服器對用戶端通知

**使用時機**：
- 同時提供多個用戶端
- 部署為雲端服務
- 與網頁應用整合

### stdio

**最適合**：本地整合、命令列工具

**特性**：
- 標準輸入/輸出串流通訊
- 設定簡單，無需網路設定
- 作為用戶端的子程序執行

**使用時機**：
- 為本地開發環境建置工具
- 與桌面應用整合
- 單一使用者、單一工作階段情境

**注意**：stdio 伺服器不應登入到 stdout（用 stderr 以進行記錄）

### 傳輸選擇

| 標準 | stdio | 可串流 HTTP |
|------|-------|------------|
| **部署** | 本地 | 遠端 |
| **用戶端** | 單一 | 多個 |
| **複雜度** | 低 | 中等 |
| **即時性** | 無 | 是 |

---

## 安全性最佳實踐

### 驗證與授權

**OAuth 2.1**：
- 使用來自認可機構的安全 OAuth 2.1 憑證
- 驗證存取權杖再進行要求
- 僅接受特意用於您伺服器的權杖

**API 金鑰**：
- 在環境變數中儲存 API 金鑰，絕不在程式碼中
- 在伺服器啟動時驗證金鑰
- 驗證失敗時提供清晰的錯誤訊息

### 輸入驗證

- 清淨檔案路徑以防止目錄遍歷
- 驗證 URL 與外部識別碼
- 檢查參數大小與範圍
- 防止系統呼叫中的命令注入
- 為所有輸入使用結構驗證（Pydantic/Zod）

### 錯誤處理

- 不要向用戶端暴露內部錯誤
- 在伺服器端記錄安全相關的錯誤
- 提供有幫助但不洩漏的錯誤訊息
- 錯誤後清理資源

### DNS 重新繫結保護

對於在本地執行的可串流 HTTP 伺服器：
- 啟用 DNS 重新繫結保護
- 驗證所有傳入連線的 `Origin` 標題
- 綁定到 `127.0.0.1` 而不是 `0.0.0.0`

---

## 工具註解

提供註解以協助用戶端了解工具行為：

| 註解 | 型別 | 預設 | 描述 |
|------|------|--------|------|
| `readOnlyHint` | boolean | false | 工具不修改其環境 |
| `destructiveHint` | boolean | true | 工具可能執行破壞性更新 |
| `idempotentHint` | boolean | false | 使用相同參數重複呼叫無額外效果 |
| `openWorldHint` | boolean | true | 工具與外部實體互動 |

**重要**：註解是提示，不是安全保證。用戶端不應僅根據註解做出安全決策。

---

## 錯誤處理

- 使用標準 JSON-RPC 錯誤程式碼
- 在結果物件中報告工具錯誤（不是協議層級錯誤）
- 提供具體建議的下一步驟的有幫助、具體的錯誤訊息
- 不暴露內部實作細節
- 正確清理錯誤上的資源

範例錯誤處理：
```typescript
try {
  const result = performOperation();
  return { content: [{ type: "text", text: result }] };
} catch (error) {
  return {
    isError: true,
    content: [{
      type: "text",
      text: `錯誤：${error.message}。嘗試使用 filter='active_only' 來減少結果。`
    }]
  };
}
```

---

## 測試需求

全面測試應涵蓋：

- **功能測試**：驗證與有效/無效輸入的正確執行
- **整合測試**：測試與外部系統的互動
- **安全性測試**：驗證驗證、輸入清淨、速率限制
- **效能測試**：檢查負載下的行為、逾時
- **錯誤處理**：確保適當的錯誤報告與清理

---

## 文件需求

- 提供所有工具與功能的清晰文件
- 包含工作範例（每個主要功能至少 3 個）
- 記錄安全考量
- 指定必要許可與存取等級
- 記錄速率限制與效能特性
