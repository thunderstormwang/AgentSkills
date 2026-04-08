# Node/TypeScript MCP 伺服器實作指南

## 概覽

本文件提供使用 MCP TypeScript SDK 實作 MCP 伺服器的 Node/TypeScript 特定最佳實踐與範例。涵蓋專案結構、伺服器設定、工具註冊模式、Zod 輸入驗證、錯誤處理與完整工作範例。

---

## 快速參考

### 關鍵匯入
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import express from "express";
import { z } from "zod";
```

### 伺服器初始化
```typescript
const server = new McpServer({
  name: "service-mcp-server",
  version: "1.0.0"
});
```

### 工具註冊模式
```typescript
server.registerTool(
  "tool_name",
  {
    title: "Tool Display Name",
    description: "What the tool does",
    inputSchema: { param: z.string() },
    outputSchema: { result: z.string() }
  },
  async ({ param }) => {
    const output = { result: `Processed: ${param}` };
    return {
      content: [{ type: "text", text: JSON.stringify(output) }],
      structuredContent: output // 結構化資料的現代模式
    };
  }
);
```

---

## MCP TypeScript SDK

官方 MCP TypeScript SDK 提供：
- 伺服器初始化的 `McpServer` 類別
- 工具註冊的 `registerTool` 方法
- 執行時輸入驗證的 Zod 結構整合
- 型別安全工具處理實作

**重要 - 僅使用現代 API：**
- **要使用**：`server.registerTool()`、`server.registerResource()`、`server.registerPrompt()`
- **不要使用**：已棄用 API，例如 `server.tool()`、`server.setRequestHandler(ListToolsRequestSchema, ...)`或手動處理器註冊
- `register*` 方法提供更好的型別安全、自動結構處理且是建議的方法

詳細資訊參考參考中的 MCP SDK 文件。

## 伺服器命名慣例

Node/TypeScript MCP 伺服器必須遵循此命名模式：
- **格式**：`{service}-mcp-server`（小寫加連字號）
- **範例**：`github-mcp-server`、`jira-mcp-server`、`stripe-mcp-server`

名稱應為：
- 一般性（不限於特定功能）
- 描述被整合的服務/API
- 易於從任務描述推斷
- 不含版本號或日期

## 專案結構

為 Node/TypeScript MCP 伺服器建立以下結構：

```
{service}-mcp-server/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts          # 具 McpServer 初始化的主進入點
│   ├── types.ts          # TypeScript 型別定義與介面
│   ├── tools/            # 工具實作（每個領域一個檔案）
│   ├── services/         # API 用戶端與共用公用程式
│   ├── schemas/          # Zod 驗證結構
│   └── constants.ts      # 共用常數（API_URL、CHARACTER_LIMIT 等）
└── dist/                 # 內置 JavaScript 檔案（進入點：dist/index.js）
```

## 工具實作

### 工具命名

使用 snake_case 的工具名稱（例如「search_users」、「create_project」、「get_channel_info」）與清晰、以動作導向的名稱。

**避免命名衝突**：包含服務背景以防止重疊：
- 使用「slack_send_message」而不是只是「send_message」
- 使用「github_create_issue」而不是只是「create_issue」
- 使用「asana_list_tasks」而不是只是「list_tasks」

### 工具結構

工具使用 `registerTool` 方法註冊，含以下需求：
- 使用 Zod 結構進行執行時輸入驗證與型別安全
- 必須明確提供 `description` 欄位 - JSDoc 註解不會自動擷取
- 明確提供 `title`、`description`、`inputSchema` 與 `annotations`
- `inputSchema` 必須是 Zod 結構物件（不是 JSON 結構）
- 明確為所有參數與返回值型別

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const server = new McpServer({
  name: "example-mcp",
  version: "1.0.0"
});

// 用於輸入驗證的 Zod 結構
const UserSearchInputSchema = z.object({
  query: z.string()
    .min(2, "查詢至少 2 個字元")
    .max(200, "查詢不超過 200 個字元")
    .describe("針對名稱/電子郵件進行比對的搜尋字串"),
  limit: z.number()
    .int()
    .min(1)
    .max(100)
    .default(20)
    .describe("傳回的最大結果"),
  offset: z.number()
    .int()
    .min(0)
    .default(0)
    .describe("用於分頁要跳過的結果數"),
  response_format: z.nativeEnum(ResponseFormat)
    .default(ResponseFormat.MARKDOWN)
    .describe("輸出格式：'markdown' 供人類閱讀或 'json' 供機器閱讀")
}).strict();

// 從 Zod 結構定義型別
type UserSearchInput = z.infer<typeof UserSearchInputSchema>;

server.registerTool(
  "example_search_users",
  {
    title: "搜尋 Example 使用者",
    description: `在 Example 系統中按名稱、電子郵件或團隊搜尋使用者。

在 Example 平台中搜尋所有使用者設定檔，支援部分相符與各種搜尋篩選。
它不會建立或修改使用者，只搜尋現有使用者。

參數：
  - query (string)：針對名稱/電子郵件進行比對的搜尋字串
  - limit (number)：傳回的最大結果，介於 1-100 之間（預設：20）
  - offset (number)：用於分頁要跳過的結果數（預設：0）
  - response_format ('markdown' | 'json')：輸出格式（預設：'markdown'）

返回：
  對於 JSON 格式：具結構的資料，含結構：
  {
    "total": number,           // 找到的相符總數
    "count": number,           // 此回應中的結果數
    "offset": number,          // 目前分頁位移
    "users": [
      {
        "id": string,          // 使用者 ID（例如「U123456789」）
        "name": string,        // 全名（例如「John Doe」）
        "email": string,       // 電子郵件地址
        "team": string,        // 團隊名稱（可選）
        "active": boolean      // 使用者是否活躍
      }
    ],
    "has_more": boolean,       // 是否有更多結果可用
    "next_offset": number      // 下一頁的位移（若 has_more 為真）
  }

範例：
  - 使用時機：「找尋所有行銷團隊成員」-> params 搭配 query="team:marketing"
  - 使用時機：「搜尋 John 的帳戶」-> params 搭配 query="john"
  - 不要使用時機：您需要建立使用者（使用 example_create_user）

錯誤處理：
  - 若要求過多會傳回「錯誤：超出速率限制」(429 狀態)
  - 若搜尋傳回空白會傳回「找不到相符『<查詢>』的使用者」`,
    inputSchema: UserSearchInputSchema,
    annotations: {
      readOnlyHint: true,
      destructiveHint: false,
      idempotentHint: true,
      openWorldHint: true
    }
  },
  async (params: UserSearchInput) => {
    try {
      // 輸入驗證由 Zod 結構處理
      // 使用經驗證參數進行 API 要求
      const data = await makeApiRequest<any>(
        "users/search",
        "GET",
        undefined,
        {
          q: params.query,
          limit: params.limit,
          offset: params.offset
        }
      );

      const users = data.users || [];
      const total = data.total || 0;

      if (!users.length) {
        return {
          content: [{
            type: "text",
            text: `找不到相符『${params.query}』的使用者`
          }]
        };
      }

      // 準備結構化輸出
      const output = {
        total,
        count: users.length,
        offset: params.offset,
        users: users.map((user: any) => ({
          id: user.id,
          name: user.name,
          email: user.email,
          ...(user.team ? { team: user.team } : {}),
          active: user.active ?? true
        })),
        has_more: total > params.offset + users.length,
        ...(total > params.offset + users.length ? {
          next_offset: params.offset + users.length
        } : {})
      };

      // 根據要求的格式格式化文字表示
      let textContent: string;
      if (params.response_format === ResponseFormat.MARKDOWN) {
        const lines = [`# 使用者搜尋結果：『${params.query}』`, "",
          `找到 ${total} 個使用者（顯示 ${users.length}）`, ""];
        for (const user of users) {
          lines.push(`## ${user.name} (${user.id})`);
          lines.push(`- **電子郵件**：${user.email}`);
          if (user.team) lines.push(`- **團隊**：${user.team}`);
          lines.push("");
        }
        textContent = lines.join("\n");
      } else {
        textContent = JSON.stringify(output, null, 2);
      }

      return {
        content: [{ type: "text", text: textContent }],
        structuredContent: output // 結構化資料的現代模式
      };
    } catch (error) {
      return {
        content: [{
          type: "text",
          text: handleApiError(error)
        }]
      };
    }
  }
);
```

## 品質檢查清單

在最終化 Node/TypeScript MCP 伺服器實作之前，確保：

### 策略設計
- [ ] 工具啟用完整工作流程，而不只是 API 端點包裝函式
- [ ] 工具名稱反映自然工作細分
- [ ] 回應格式優化代理背景效率
- [ ] 適當位置使用人類可讀識別碼
- [ ] 錯誤訊息引導代理朝向正確使用方式

### 實作品質
- [ ] 聚焦實作：實作最重要與最有價值的工具
- [ ] 所有工具使用 `registerTool` 與完整設定註冊
- [ ] 所有工具包含 `title`、`description`、`inputSchema` 與 `annotations`
- [ ] 註解正確設定（readOnlyHint、destructiveHint、idempotentHint、openWorldHint）
- [ ] 所有工具使用 Zod 結構進行執行時輸入驗證與 `.strict()` 強化
- [ ] 所有 Zod 結構具有適當約束與描述性錯誤訊息
- [ ] 所有工具都有含明確輸入/輸出型別的全面描述
- [ ] 描述包含傳回值範例與完整結構文件

### TypeScript 品質
- [ ] 為所有資料結構定義 TypeScript 介面
- [ ] 在 tsconfig.json 中啟用 Strict TypeScript
- [ ] 不使用 `any` 型別 - 使用 `unknown` 或適當型別
- [ ] 所有 async 函式具有明確 Promise<T> 返回型別
- [ ] 錯誤處理使用適當型別防衛（例如 `axios.isAxiosError`、`z.ZodError`）

### 進階功能（適用時）
- [ ] 適當資料端點已註冊資源
- [ ] 適當的傳輸已設定（stdio 或可串流 HTTP）
- [ ] 為動態伺服器功能實作通知

### 專案設定
- [ ] Package.json 包含所有必要相依性
- [ ] 建置腳本在 dist/ 目錄中產生有效 JavaScript
- [ ] 主進入點正確設定為 dist/index.js
- [ ] 伺服器名稱遵循格式：`{service}-mcp-server`
- [ ] tsconfig.json 正確設定，含嚴格模式

### 程式碼品質
- [ ] 分頁在適用處正確實作
- [ ] 大型回應檢查 CHARACTER_LIMIT 常數且截斷含清晰訊息
- [ ] 為潛在大型結果集提供篩選選項
- [ ] 所有網路操作可正確處理逾時與連線錯誤
- [ ] 常見功能擷取到可重用函式中
- [ ] 返回型別在類似操作中是一致的

### 測試與建置
- [ ] `npm run build` 成功完成，無錯誤
- [ ] dist/index.js 已建立且可執行
- [ ] 伺服器執行：`node dist/index.js --help`
- [ ] 所有匯入正確解析
- [ ] 樣本工具呼叫如預期運作

（本指南其他完整部分的繁體中文翻譯會以類似方式繼續...）
