---
name: mcp-builder
description: 高品質 MCP（模型背景協議）伺服器開發指南，讓大型語言模型能透過設計良好的工具與外部服務互動。當您要建置 MCP 伺服器來整合外部 API 或服務時使用，無論是 Python (FastMCP) 或 Node/TypeScript (MCP SDK)。
license: Complete terms in LICENSE.txt
---

# MCP 伺服器開發指南

## 概覽

建立 MCP（模型背景協議）伺服器，讓大型語言模型透過設計良好的工具與外部服務互動。MCP 伺服器的品質以其能否讓大型語言模型完成真實任務的程度衡量。

---

# 流程

## 🚀 高層級工作流程

建立高品質 MCP 伺服器涉及四個主要階段：

### 階段 1：深入研究與規劃

#### 1.1 了解現代 MCP 設計

**API 涵蓋度 vs. 工作流程工具：**
在全面 API 端點涵蓋與特定工作流程工具間取得平衡。工作流程工具對特定任務更方便，而全面涵蓋為代理提供組合操作的彈性。效能因用戶端而異——某些用戶端受益於組合基本工具的程式碼執行，而其他用戶端則較適合高階工作流程。不確定時，優先採用全面 API 涵蓋。

**工具命名與發現性：**
清晰、描述性的工具名稱幫助代理快速找到正確工具。使用一致的字首（例如 `github_create_issue`、`github_list_repos`）和以動作導向的命名。

**背景管理：**
代理受益於簡潔的工具描述與篩選/分頁結果的能力。設計返回聚焦、相關資料的工具。某些用戶端支援程式碼執行，可幫助代理有效地篩選和處理資料。

**可執行的錯誤訊息：**
錯誤訊息應透過具體建議與後續步驟引導代理朝向解決方案。

#### 1.2 研究 MCP 協議文件

**瀏覽 MCP 規範：**

從網站地圖開始尋找相關頁面：`https://modelcontextprotocol.io/sitemap.xml`

然後使用 `.md` 後綴字取得特定頁面的 Markdown 格式（例如 `https://modelcontextprotocol.io/specification/draft.md`）。

關鍵頁面要審查：
- 規範概覽與架構
- 傳輸機制（可串流 HTTP、stdio）
- 工具、資源與提示定義

#### 1.3 研究框架文件

**建議的技術棧：**
- **語言**：TypeScript（高品質 SDK 支援與多個執行環境中的好相容性，例如 MCPB。加上 AI 模型擅長產生 TypeScript 程式碼，受益於其廣泛使用、靜態型別與良好的 linting 工具）
- **傳輸**：用於遠端伺服器的可串流 HTTP，使用無狀態 JSON（更易於縮放與維護，相較於有狀態工作階段與串流回應）。用於本地伺服器的 stdio。

**載入框架文件：**

- **MCP 最佳實踐**：[📋 檢視最佳實踐](./reference/mcp_best_practices.md) - 核心指南

**對於 TypeScript（建議）：**
- **TypeScript SDK**：使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) - TypeScript 模式與範例

**對於 Python：**
- **Python SDK**：使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- [🐍 Python 指南](./reference/python_mcp_server.md) - Python 模式與範例

#### 1.4 規劃您的實作

**了解 API：**
檢查服務的 API 文件以確定關鍵端點、驗證需求與資料模型。視需要使用網頁搜尋與 WebFetch。

**工具選擇：**
優先採用全面 API 涵蓋。列出要實作的端點，從最常見的操作開始。

---

### 階段 2：實作

#### 2.1 設定專案結構

參考語言特定指南進行專案設定：
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) - 專案結構、package.json、tsconfig.json
- [🐍 Python 指南](./reference/python_mcp_server.md) - 模組組織、相依性

#### 2.2 實作核心基礎設施

建立共用公用程式：
- 具有驗證的 API 用戶端
- 錯誤處理幫手
- 回應格式化（JSON/Markdown）
- 分頁支援

#### 2.3 實作工具

對每個工具：

**輸入結構：**
- 使用 Zod（TypeScript）或 Pydantic（Python）
- 包含約束與清晰描述
- 在欄位描述中新增範例

**輸出結構：**
- 盡可能為結構化資料定義 `outputSchema`
- 在工具回應中使用 `structuredContent`（TypeScript SDK 功能）
- 協助用戶端了解與處理工具輸出

**工具描述：**
- 功能的簡潔摘要
- 參數描述
- 返回型別結構

**實作：**
- 用於 I/O 操作的 Async/await
- 具有可執行訊息的適當錯誤處理
- 支援適用處分頁
- 使用現代 SDK 時返回文字內容與結構化資料

**註解：**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false
- `openWorldHint`: true/false

---

### 階段 3：審查與測試

#### 3.1 程式碼品質

審查：
- 無重複程式碼（DRY 原則）
- 一致的錯誤處理
- 完整型別涵蓋
- 清晰的工具描述

#### 3.2 建置與測試

**TypeScript：**
- 執行 `npm run build` 驗證編譯
- 使用 MCP Inspector 測試：`npx @modelcontextprotocol/inspector`

**Python：**
- 驗證語法：`python -m py_compile your_server.py`
- 使用 MCP Inspector 測試

參考語言特定指南以取得詳細測試方法與品質檢查清單。

---

### 階段 4：建立評測

實作 MCP 伺服器後，建立全面評測以測試其有效性。

**載入 [✅ 評測指南](./reference/evaluation.md) 以獲得完整評測指南。**

#### 4.1 了解評測目的

使用評測測試 LLM 是否能有效使用您的 MCP 伺服器來回答真實、複雜的問題。

#### 4.2 建立 10 個評測問題

為建立有效評測，遵循評測指南中列出的流程：

1. **工具檢查**：列出可用工具並了解其能力
2. **內容探索**：使用唯讀操作探索可用資料
3. **問題產生**：建立 10 個複雜、真實的問題
4. **答案驗證**：自己解決每個問題以驗證答案

#### 4.3 評測需求

確保每個問題是：
- **獨立**：不依賴於其他問題的答案
- **唯讀**：僅需非破壞性操作
- **複雜**：需要多個工具呼叫與深入探索
- **真實**：基於真實使用案例
- **可驗證**：單一、清晰的答案可透過字串比較驗證
- **穩定**：答案不會隨時間改變

#### 4.4 輸出格式

建立具有以下結構的 XML 檔案：

```xml
<evaluation>
  <qa_pair>
    <question>找尋關於具動物代號的 AI 模型發行的討論。某個模型需要特定的安全指定，使用 ASL-X 格式。被命名為有斑點野生貓科的模型需決定的數字 X 是多少？</question>
    <answer>3</answer>
  </qa_pair>
<!-- 更多 qa_pair... -->
</evaluation>
```

---

# 參考檔

## 📚 文件庫

在開發期間視需要載入這些資源：

### 核心 MCP 文件（首先載入）
- **MCP 協議**：從 `https://modelcontextprotocol.io/sitemap.xml` 的網站地圖開始，然後使用 `.md` 後綴字取得特定頁面
- [📋 MCP 最佳實踐](./reference/mcp_best_practices.md) - 通用 MCP 指南，包括：
  - 伺服器與工具命名慣例
  - 回應格式指南（JSON vs Markdown）
  - 分頁最佳實踐
  - 傳輸選擇（可串流 HTTP vs stdio）
  - 安全性與錯誤處理標準

### SDK 文件（在階段 1/2 期間載入）
- **Python SDK**：從 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md` 取得
- **TypeScript SDK**：從 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md` 取得

### 語言特定實作指南（在階段 2 期間載入）
- [🐍 Python 實作指南](./reference/python_mcp_server.md) - 完整 Python/FastMCP 指南，包括：
  - 伺服器初始化模式
  - Pydantic 模型範例
  - 工具註冊與 `@mcp.tool`
  - 完整工作範例
  - 品質檢查清單

- [⚡ TypeScript 實作指南](./reference/node_mcp_server.md) - 完整 TypeScript 指南，包括：
  - 專案結構
  - Zod 結構模式
  - 工具註冊與 `server.registerTool`
  - 完整工作範例
  - 品質檢查清單

### 評測指南（在階段 4 期間載入）
- [✅ 評測指南](./reference/evaluation.md) - 完整評測建立指南，包括：
  - 問題建立指南
  - 答案驗證策略
  - XML 格式規範
  - 範例問題與答案
  - 使用提供的腳本執行評測
