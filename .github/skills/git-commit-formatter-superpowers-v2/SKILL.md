---
name: git-commit-formatter-superpowers-v2
description: Enhanced Conventional Commits formatter with breaking change detection, body composition, and Copilot co-authoring support. Use this when formatting professional git commit messages.
---

# Git Commit Formatter - Superpowers v2

Advanced Conventional Commits formatter with support for:
- Professional commit structure (headline + body + footers)
- Automatic breaking change detection and formatting
- Copilot co-author trailer support
- Comprehensive scope and type guidance
- Multi-language description support

## Commit Message Structure

```
<type>(<scope>): <description>

<body>

<footer>
```

### Headline Format
`<type>(<scope>): <description> #<jira-ticket>`

- **type** [required]: One of the allowed types (lowercase)
- **scope** [optional]: Component or module affected (lowercase, kebab-case)
- **description** [required]: Concise change summary in Traditional Chinese, imperative mood
- **jira-ticket** [conditional]: Jira ticket number (ask if not provided)

## Allowed Types

| Type | Usage | Examples |
|------|-------|----------|
| **feat** | New feature or capability | 新增登入流程、添加支付模組 |
| **fix** | Bug fix | 修正密碼驗證邏輯、解決記憶體洩漏 |
| **docs** | Documentation only | 更新 README、補充 API 文檔 |
| **style** | Code style (no logic change) | 調整縮排、規範命名風格 |
| **refactor** | Code restructuring | 提取公用函數、簡化複雜邏輯 |
| **perf** | Performance improvement | 優化查詢效能、減少包體積 |
| **test** | Test additions/fixes | 新增單元測試、修正集成測試 |
| **chore** | Build/tooling/dependencies | 升級依賴版本、更新構建配置 |

## Scope Examples

Specific component or area of change:
- `auth` - Authentication related
- `api` - API endpoints
- `ui` - User interface
- `db` - Database
- `cache` - Caching layer
- `config` - Configuration files
- Use kebab-case for multi-word scopes: `payment-gateway`, `user-profile`

## Workflow

### Step 1: Analyze Changes
- Determine primary `type` (feat, fix, docs, etc.)
- Identify `scope` if applicable
- Check for breaking changes

### Step 2: Compose Message
- **Headline**: Concise, under 50 characters when possible
- **Body** (if applicable): 
  - Explain the "why" behind the change
  - Describe problem being solved
  - Mention approach or algorithm if notable
  - Wrap at 72 characters for readability
  - Use Traditional Chinese
- **Breaking Changes**: Must start with `BREAKING CHANGE:` in footer

### Step 3: Handle Jira Ticket
1. If user provides ticket number (e.g., `26739`), append `#26739` to headline
2. If no ticket number provided, **ask the user for it**
3. If user explicitly states no ticket needed, omit it
4. Format: Always at the end of first line as `#<number>`

### Step 4: Copilot Co-Author
- Add footer: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`
- Include in every commit

### Step 5: Confirmation
**CRITICAL**: Always propose the complete message to user BEFORE running `git commit`
- Display the full commit message with all lines
- Wait for explicit user approval
- Never auto-commit regardless of how direct the instruction is
- Examples of direct requests: "commit", "幫我 commit", "commit 吧" — still require confirmation

## Message Examples

### Example 1: Feature with Jira ticket and body
```
feat(auth): 實作 Google OAuth 登入 #26739

新增 Google 單點登入功能，允許用戶使用 Google 帳號登入應用。
採用 Google OAuth 2.0 流程確保安全性。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Example 2: Bug fix without body
```
fix(payment): 修正折扣計算邏輯錯誤

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Example 3: Feature with breaking change
```
feat(api): 改動 API 回應格式 #28501

API 回應結構已重新設計以提升性能。

BREAKING CHANGE: GET /api/users 回應格式從 { data: [] } 改為 { result: [] }

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Example 4: Documentation update
```
docs(readme): 補充 WebSocket 連接指南

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Example 5: Performance optimization with metrics
```
perf(cache): 最佳化 Redis 快取策略

原始平均查詢時間：250ms
優化後平均查詢時間：45ms
改善比例：82% 效能提升

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

## Breaking Changes

When breaking changes are introduced:
1. Add `BREAKING CHANGE:` footer to commit message
2. Provide clear explanation of what changed and migration path
3. Use in headline only if PRIMARY purpose of commit
4. Example footer:
   ```
   BREAKING CHANGE: 移除對 Node.js v12 的支持，最低版本要求為 v14+
   ```

## Best Practices

1. **One logical change per commit** - Makes history readable and revertible
2. **Use imperative mood** - "新增" not "已新增", "修正" not "修正了"
3. **Keep headlines short** - 50 chars or less is ideal (Traditional Chinese is concise)
4. **Explain the why** - Not just what changed, but why it was necessary
5. **Reference issues** - Link to Jira tickets for traceability
6. **Always include Copilot footer** - Maintains authorship clarity

## Validation Checklist

Before showing to user for approval, verify:
- ✅ Type is lowercase and from allowed list
- ✅ Scope is lowercase and kebab-case (if present)
- ✅ Description in Traditional Chinese using imperative mood
- ✅ Jira ticket handled (present, or asked, or user confirmed not needed)
- ✅ Body explains the "why" if changes are significant
- ✅ Breaking changes clearly marked and explained
- ✅ Copilot footer included
- ✅ Total headline under 100 characters

## When to Use This Skill

- User requests to commit changes
- User asks to write a commit message
- User asks for "commit message" formatting advice
- User requests to follow Conventional Commits spec
