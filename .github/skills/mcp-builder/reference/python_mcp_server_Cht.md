# Python MCP 伺服器實作指南

## 概覽

本文件提供使用 MCP Python SDK 實作 MCP 伺服器的 Python 特定最佳實踐與範例。涵蓋伺服器設定、工具註冊模式、Pydantic 輸入驗證、錯誤處理與完整工作範例。

---

## 快速參考

### 關鍵匯入
```python
from mcp.server.fastmcp import FastMCP
from pydantic import BaseModel, Field, field_validator, ConfigDict
from typing import Optional, List, Dict, Any
from enum import Enum
import httpx
```

### 伺服器初始化
```python
mcp = FastMCP("service_mcp")
```

### 工具註冊模式
```python
@mcp.tool(name="tool_name", annotations={...})
async def tool_function(params: InputModel) -> str:
    # 實作
    pass
```

---

## MCP Python SDK 與 FastMCP

官方 MCP Python SDK 提供 FastMCP，一個用於建立 MCP 伺服器的高階框架。它提供：
- 從函式簽章與文件字串自動產生描述與 inputSchema
- Pydantic 模型整合用於輸入驗證
- 使用 `@mcp.tool` 的基於裝飾器的工具註冊

**如需完整 SDK 文件，使用 WebFetch 載入：**
`https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`

## 伺服器命名慣例

Python MCP 伺服器必須遵循此命名模式：
- **格式**：`{service}_mcp`（小寫加底線）
- **範例**：`github_mcp`、`jira_mcp`、`stripe_mcp`

名稱應為：
- 一般性（不限於特定功能）
- 描述被整合的服務/API
- 易於從任務描述推斷
- 不含版本號或日期

## 工具實作

### 工具命名

使用 snake_case 的工具名稱（例如「search_users」、「create_project」、「get_channel_info」）與清晰、以動作導向的名稱。

**避免命名衝突**：包含服務背景以防止重疊：
- 使用「slack_send_message」而不是只是「send_message」
- 使用「github_create_issue」而不是只是「create_issue」
- 使用「asana_list_tasks」而不是只是「list_tasks」

### 工具結構與 FastMCP

工具使用 `@mcp.tool` 裝飾器與 Pydantic 模型用於輸入驗證進行定義：

```python
from pydantic import BaseModel, Field, ConfigDict
from mcp.server.fastmcp import FastMCP

# 初始化 MCP 伺服器
mcp = FastMCP("example_mcp")

# 定義用於輸入驗證的 Pydantic 模型
class ServiceToolInput(BaseModel):
    '''用於服務工具操作的輸入模型。'''
    model_config = ConfigDict(
        str_strip_whitespace=True,  # 自動從字串去除空白
        validate_assignment=True,    # 在指定時驗證
        extra='forbid'              # 禁止額外欄位
    )

    param1: str = Field(..., description="第一個參數描述（例如 'user123'、'project-abc'）", min_length=1, max_length=100)
    param2: Optional[int] = Field(default=None, description="具約束的可選整數參數", ge=0, le=1000)
    tags: Optional[List[str]] = Field(default_factory=list, description="要套用的標籤清單", max_items=10)

@mcp.tool(
    name="service_tool_name",
    annotations={
        "title": "Human-Readable Tool Title",
        "readOnlyHint": True,     # 工具不修改環境
        "destructiveHint": False,  # 工具不執行破壞性操作
        "idempotentHint": True,    # 重複呼叫無額外效果
        "openWorldHint": False     # 工具不與外部實體互動
    }
)
async def service_tool_name(params: ServiceToolInput) -> str:
    '''工具描述自動成為「description」欄位。

    此工具在服務上執行特定操作。使用 ServiceToolInput Pydantic 模型驗證所有輸入
    再進行處理。

    參數：
        params (ServiceToolInput)：經驗證的輸入參數，包含：
            - param1 (str)：第一個參數描述
            - param2 (Optional[int])：具預設值的可選參數
            - tags (Optional[List[str]])：標籤清單

    返回：
        str：JSON 格式的回應，包含操作結果
    '''
    # 實作此處
    pass
```

## Pydantic v2 關鍵功能

- 使用 `model_config` 而不是巢狀 `Config` 類別
- 使用 `field_validator` 而不是已棄用的 `validator`
- 使用 `model_dump()` 而不是已棄用的 `dict()`
- 驗證器需要 `@classmethod` 裝飾器
- 型別提示對驗證器方法是必需的

```python
from pydantic import BaseModel, Field, field_validator, ConfigDict

class CreateUserInput(BaseModel):
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True
    )

    name: str = Field(..., description="使用者全名", min_length=1, max_length=100)
    email: str = Field(..., description="使用者電子郵件地址", pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    age: int = Field(..., description="使用者年齡", ge=0, le=150)

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("電子郵件不能為空")
        return v.lower()
```

## 回應格式選項

支援多個輸出格式以提供彈性：

```python
from enum import Enum

class ResponseFormat(str, Enum):
    '''工具回應的輸出格式。'''
    MARKDOWN = "markdown"
    JSON = "json"

class UserSearchInput(BaseModel):
    query: str = Field(..., description="搜尋查詢")
    response_format: ResponseFormat = Field(
        default=ResponseFormat.MARKDOWN,
        description="輸出格式：'markdown' 以供人類閱讀或 'json' 以供機器閱讀"
    )
```

**Markdown 格式**：
- 使用標題、清單與格式以提供清晰度
- 將時間戳記轉換為人類可讀格式（例如「2024-01-15 10:30:00 UTC」而不是紀元）
- 與括號中的 ID 顯示顯示名稱（例如「@john.doe (U123456)」）
- 省略冗長中繼資料（例如只顯示一個設定檔圖片 URL，而不是所有尺寸）
- 邏輯分組相關資訊

**JSON 格式**：
- 返回適合程式化處理的完整、結構化資料
- 包含所有可用欄位與中繼資料
- 使用一致的欄位名稱與型別

## 分頁實作

對於列出資源的工具：

```python
class ListInput(BaseModel):
    limit: Optional[int] = Field(default=20, description="傳回的最大結果", ge=1, le=100)
    offset: Optional[int] = Field(default=0, description="要跳過的結果數用於分頁", ge=0)

async def list_items(params: ListInput) -> str:
    # 使用分頁進行 API 要求
    data = await api_request(limit=params.limit, offset=params.offset)

    # 返回分頁資訊
    response = {
        "total": data["total"],
        "count": len(data["items"]),
        "offset": params.offset,
        "items": data["items"],
        "has_more": data["total"] > params.offset + len(data["items"]),
        "next_offset": params.offset + len(data["items"]) if data["total"] > params.offset + len(data["items"]) else None
    }
    return json.dumps(response, indent=2)
```

## 錯誤處理

提供清晰、可執行的錯誤訊息：

```python
def _handle_api_error(e: Exception) -> str:
    '''跨所有工具的一致錯誤格式化。'''
    if isinstance(e, httpx.HTTPStatusError):
        if e.response.status_code == 404:
            return "錯誤：找不到資源。請檢查 ID 是否正確。"
        elif e.response.status_code == 403:
            return "錯誤：許可被拒。您無法存取此資源。"
        elif e.response.status_code == 429:
            return "錯誤：超出速率限制。提出更多要求前請稍候。"
        return f"錯誤：API 要求失敗，狀態 {e.response.status_code}"
    elif isinstance(e, httpx.TimeoutException):
        return "錯誤：要求逾時。請重試。"
    return f"錯誤：發生未預期的錯誤：{type(e).__name__}"
```

## 共用公用程式

將常見功能擷取到可重用函式中：

```python
# 共用 API 要求函式
async def _make_api_request(endpoint: str, method: str = "GET", **kwargs) -> dict:
    '''所有 API 呼叫的可重用函式。'''
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method,
            f"{API_BASE_URL}/{endpoint}",
            timeout=30.0,
            **kwargs
        )
        response.raise_for_status()
        return response.json()
```

## Async/Await 最佳實踐

始終針對網路要求與 I/O 操作使用 async/await：

```python
# 良好：Async 網路要求
async def fetch_data(resource_id: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_URL}/resource/{resource_id}")
        response.raise_for_status()
        return response.json()

# 不好：同步要求
def fetch_data(resource_id: str) -> dict:
    response = requests.get(f"{API_URL}/resource/{resource_id}")  # 封鎖
    return response.json()
```

## 型別提示

始終使用型別提示：

```python
from typing import Optional, List, Dict, Any

async def get_user(user_id: str) -> Dict[str, Any]:
    data = await fetch_user(user_id)
    return {"id": data["id"], "name": data["name"]}
```

## 工具文件字串

每個工具必須具有全面的文件字串與明確的型別資訊：

```python
async def search_users(params: UserSearchInput) -> str:
    '''
    在 Example 系統中按名稱、電子郵件或團隊搜尋使用者。

    此工具在 Example 平台中搜尋所有使用者設定檔，
    支援部分相符與各種搜尋篩選。它不會
    建立或修改使用者，只搜尋現有使用者。

    參數：
        params (UserSearchInput)：經驗證的輸入參數，包含：
            - query (str)：針對名稱/電子郵件進行比對的搜尋字串（例如「john」、「@example.com」、「team:marketing」）
            - limit (Optional[int])：傳回的最大結果，介於 1-100 之間（預設：20）
            - offset (Optional[int])：要跳過的結果數以進行分頁（預設：0）

    返回：
        str：JSON 格式字串，包含具以下結構的搜尋結果：

        成功回應：
        {
            "total": int,           # 找到的相符總數
            "count": int,           # 此回應中的結果數
            "offset": int,          # 目前分頁位移
            "users": [
                {
                    "id": str,      # 使用者 ID（例如「U123456789」）
                    "name": str,    # 全名（例如「John Doe」）
                    "email": str,   # 電子郵件地址（例如「john@example.com」）
                    "team": str     # 團隊名稱（例如「Marketing」）- 可選
                }
            ]
        }

        錯誤回應：
        「錯誤：<錯誤訊息>」或「找不到相符『<查詢>』的使用者」

    範例：
        - 使用時機：「找尋所有行銷團隊成員」-> params 搭配 query="team:marketing"
        - 使用時機：「搜尋 John 的帳戶」-> params 搭配 query="john"
        - 不要使用時機：您需要建立使用者（使用 example_create_user）
        - 不要使用時機：您有使用者 ID 並需要完整詳細資訊（使用 example_get_user）

    錯誤處理：
        - 輸入驗證錯誤由 Pydantic 模型處理
        - 若要求過多會傳回「錯誤：超出速率限制」(429 狀態)
        - 若 API 金鑰無效會傳回「錯誤：API 驗證無效」(401 狀態)
        - 傳回格式化結果清單或「找不到相符『查詢』的使用者」
    '''
```

## 完整範例

以下為完整 Python MCP 伺服器範例：

```python
#!/usr/bin/env python3
'''
Example Service 的 MCP 伺服器。

此伺服器提供與 Example API 互動的工具，包括使用者搜尋、
專案管理與資料匯出功能。
'''

from typing import Optional, List, Dict, Any
from enum import Enum
import httpx
from pydantic import BaseModel, Field, field_validator, ConfigDict
from mcp.server.fastmcp import FastMCP

# 初始化 MCP 伺服器
mcp = FastMCP("example_mcp")

# 常數
API_BASE_URL = "https://api.example.com/v1"

# Enum
class ResponseFormat(str, Enum):
    '''工具回應的輸出格式。'''
    MARKDOWN = "markdown"
    JSON = "json"

# 輸入驗證的 Pydantic 模型
class UserSearchInput(BaseModel):
    '''使用者搜尋操作的輸入模型。'''
    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_assignment=True
    )

    query: str = Field(..., description="針對名稱/電子郵件進行比對的搜尋字串", min_length=2, max_length=200)
    limit: Optional[int] = Field(default=20, description="傳回的最大結果", ge=1, le=100)
    offset: Optional[int] = Field(default=0, description="用於分頁要跳過的結果數", ge=0)
    response_format: ResponseFormat = Field(default=ResponseFormat.MARKDOWN, description="輸出格式")

    @field_validator('query')
    @classmethod
    def validate_query(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("查詢不能為空或僅限空白")
        return v.strip()

# 共用公用程式函式
async def _make_api_request(endpoint: str, method: str = "GET", **kwargs) -> dict:
    '''所有 API 呼叫的可重用函式。'''
    async with httpx.AsyncClient() as client:
        response = await client.request(
            method,
            f"{API_BASE_URL}/{endpoint}",
            timeout=30.0,
            **kwargs
        )
        response.raise_for_status()
        return response.json()

def _handle_api_error(e: Exception) -> str:
    '''跨所有工具的一致錯誤格式化。'''
    if isinstance(e, httpx.HTTPStatusError):
        if e.response.status_code == 404:
            return "錯誤：找不到資源。請檢查 ID 是否正確。"
        elif e.response.status_code == 403:
            return "錯誤：許可被拒。您無法存取此資源。"
        elif e.response.status_code == 429:
            return "錯誤：超出速率限制。提出更多要求前請稍候。"
        return f"錯誤：API 要求失敗，狀態 {e.response.status_code}"
    elif isinstance(e, httpx.TimeoutException):
        return "錯誤：要求逾時。請重試。"
    return f"錯誤：發生未預期的錯誤：{type(e).__name__}"

# 工具定義
@mcp.tool(
    name="example_search_users",
    annotations={
        "title": "搜尋 Example 使用者",
        "readOnlyHint": True,
        "destructiveHint": False,
        "idempotentHint": True,
        "openWorldHint": True
    }
)
async def example_search_users(params: UserSearchInput) -> str:
    '''在 Example 系統中按名稱、電子郵件或團隊搜尋使用者。

    [如上所示的完整文件字串]
    '''
    try:
        # 使用經驗證的參數進行 API 要求
        data = await _make_api_request(
            "users/search",
            params={
                "q": params.query,
                "limit": params.limit,
                "offset": params.offset
            }
        )

        users = data.get("users", [])
        total = data.get("total", 0)

        if not users:
            return f"找不到相符『{params.query}』的使用者"

        # 根據要求的格式格式化回應
        if params.response_format == ResponseFormat.MARKDOWN:
            lines = [f"# 使用者搜尋結果：『{params.query}』", ""]
            lines.append(f"找到 {total} 個使用者（顯示 {len(users)}）")
            lines.append("")

            for user in users:
                lines.append(f"## {user['name']} ({user['id']})")
                lines.append(f"- **電子郵件**：{user['email']}")
                if user.get('team'):
                    lines.append(f"- **團隊**：{user['team']}")
                lines.append("")

            return "\n".join(lines)

        else:
            # 機器可讀 JSON 格式
            import json
            response = {
                "total": total,
                "count": len(users),
                "offset": params.offset,
                "users": users
            }
            return json.dumps(response, indent=2)

    except Exception as e:
        return _handle_api_error(e)

if __name__ == "__main__":
    mcp.run()
```

## 品質檢查清單

在最終化 Python MCP 伺服器實作之前，確保：

### 策略設計
- [ ] 工具啟用完整工作流程，而不只是 API 端點包裝函式
- [ ] 工具名稱反映自然工作細分
- [ ] 回應格式優化代理背景效率
- [ ] 適當位置使用人類可讀識別碼
- [ ] 錯誤訊息引導代理朝向正確使用方式

### 實作品質
- [ ] 聚焦實作：實作最重要與最有價值的工具
- [ ] 所有工具都有描述性名稱與文件
- [ ] 返回型別在類似操作中是一致的
- [ ] 為所有外部呼叫實作錯誤處理
- [ ] 伺服器名稱遵循格式：`{service}_mcp`
- [ ] 所有網路操作使用 async/await
- [ ] 常見功能擷取到可重用函式中
- [ ] 錯誤訊息清晰、可執行且教育性質
- [ ] 輸出經過適當驗證與格式化

### 工具設定
- [ ] 所有工具在裝飾器中實作「name」與「annotations」
- [ ] 註解正確設定（readOnlyHint、destructiveHint、idempotentHint、openWorldHint）
- [ ] 所有工具使用 Pydantic BaseModel 進行輸入驗證與 Field() 定義
- [ ] 所有 Pydantic Field 具有明確型別、包含約束的描述
- [ ] 所有工具都有全面文件字串與明確的輸入/輸出型別
- [ ] 文件字串針對 dict/JSON 返回包含完整結構
- [ ] Pydantic 模型處理輸入驗證（無需手動驗證）

### 進階功能（適用時）
- [ ] 背景注入用於記錄、進度或誘發
- [ ] 資源為適當資料端點註冊
- [ ] 為持續連線實作壽命管理
- [ ] 結構化輸出型別已使用（TypedDict、Pydantic 模型）
- [ ] 適當的傳輸已設定（stdio 或可串流 HTTP）

### 程式碼品質
- [ ] 檔案包含適當匯入，包括 Pydantic 匯入
- [ ] 分頁在適用處正確實作
- [ ] 為潛在大型結果集提供篩選選項
- [ ] 所有 async 函式透過 `async def` 正確定義
- [ ] HTTP 用戶端使用遵循 async 模式與適當背景管理員
- [ ] 型別提示在整個程式碼中使用
- [ ] 常數在模組層級以大寫定義

### 測試
- [ ] 伺服器成功執行：`python your_server.py --help`
- [ ] 所有匯入正確解析
- [ ] 樣本工具呼叫如預期運作
- [ ] 錯誤情況可正確處理
