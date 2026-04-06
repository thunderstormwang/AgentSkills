---
name: git-commit-formatter-v3
description: Formats git commit messages according to Conventional Commits specification with Jira integration and confirmation workflow.
---

# Git Commit Formatter Skill

## Purpose
Format git commit messages according to Conventional Commits specification with project-specific requirements (Traditional Chinese descriptions, Jira ticket integration, and user confirmation workflow).

## Scope
This skill handles:
- Commit message structure and validation
- Type/scope classification
- Jira ticket linking
- User confirmation before commit execution
- Breaking change handling

---

## Commit Message Format

### Header (Required)
```
<type>(<scope>): <description> [#<jira-ticket>]
```

**Rules:**
- `<type>`: Commit type (see Allowed Types below)
- `<scope>`: Optional, specific component/file affected (lowercase, no spaces)
- `<description>`: Concise description in **Traditional Chinese**, imperative mood (e.g., "新增功能" not "已新增功能"), max 72 characters
- `#<jira-ticket>`: Optional, Jira ticket reference (e.g., #26739)

### Body (Optional)
- Explain **what** and **why**, not **how**
- Wrap at 100 characters per line
- Use bullet points for clarity if needed
- Separate from header with blank line

### Footer (Optional)
- For issue references or breaking changes
- Format: `<key>: <value>`
- Example: `Closes #123` or `BREAKING CHANGE: description of breaking change`

---

## Allowed Types

| Type | Description | Example |
|------|-------------|---------|
| **feat** | A new feature | `feat(auth): 實作 Google 登入` |
| **fix** | A bug fix | `fix(coupon): 修正折扣計算錯誤` |
| **docs** | Documentation only changes | `docs(readme): 更新安裝指引` |
| **style** | Code style (whitespace, formatting, etc.) | `style(core): 統一縮進規則` |
| **refactor** | Code refactoring (no feature/bug change) | `refactor(api): 提取公共函數` |
| **perf** | Performance improvement | `perf(cache): 優化查詢效率` |
| **test** | Add/correct tests | `test(auth): 補充登入流程測試` |
| **chore** | Build, tools, dependencies | `chore(deps): 升級 React 至 18.0` |

---

## Processing Instructions

### Step 1: Analyze the Changes
- Determine the primary `type` based on what changed
- Identify the `scope` if applicable (specific component, module, or subsystem)
- Assess if breaking changes are introduced

### Step 2: Draft the Description
- Use **Traditional Chinese**
- Imperative mood: "新增" not "已新增", "修正" not "已修正"
- Keep it concise (max 72 characters)
- Be specific about what changed

### Step 3: Handle Jira Ticket
- **If user provides a ticket number** (e.g., `26739`): Append `#26739` to the description
- **If no number provided**: Ask the user for it before proceeding
- **If user explicitly says not needed**: Omit the ticket number

### Step 4: Add Breaking Changes (if applicable)
- If the change breaks existing APIs or behavior:
  ```
  BREAKING CHANGE: description of what broke and how to migrate
  ```

### Step 5: Propose and Confirm
- **MUST show the complete proposed commit message to the user for approval**
- Do NOT execute `git commit` until user explicitly confirms
- This applies regardless of how direct the user's instruction is ("commit", "幫我 commit", "commit 吧")
- If user requests changes, iterate until satisfied

### Step 6: Execute the Commit
- Run `git commit -m "<message>"` only after user confirmation
- Include the Co-authored-by trailer as specified in environment

---

## Examples

### Simple Feature
```
feat(auth): 實作 Google 登入 #26739
```

### Bug Fix (No Jira Ticket)
```
fix(coupon): 修正折扣計算錯誤
```

### With Body and Breaking Change
```
feat(api): 重構用戶 API 響應格式 #27100

- 移除了 deprecated 字段 `user_id`
- 新增 `uuid` 字段作為主鍵
- 調整響應結構以更好支持嵌套資源

BREAKING CHANGE: 用戶 API 響應格式已更改，舊客戶端需更新解析邏輯
```

### Documentation Update
```
docs(contributing): 補充 conventional commit 指南
```

### Performance Optimization
```
perf(database): 優化用戶查詢 N+1 問題 #26999
```

---

## Workflow Checklist

- [ ] Type identified and valid
- [ ] Scope specified (if applicable)
- [ ] Description in Traditional Chinese, imperative mood
- [ ] Description <= 72 characters
- [ ] Jira ticket handled appropriately (added, requested, or omitted)
- [ ] Breaking changes documented in footer (if applicable)
- [ ] Proposed message shown to user
- [ ] User confirmation received
- [ ] Commit executed successfully

---

## Notes for Implementation

1. **Always clarify Jira ticket requirement** - Don't assume. If unclear, ask the user.
2. **Confirmation is mandatory** - Even for seemingly direct commit requests, always show the proposed message first.
3. **Traditional Chinese + English mix** - Type/scope in English, description in Traditional Chinese.
4. **Validate before executing** - Check format compliance before running `git commit`.
5. **Be helpful** - Suggest scope if obvious (e.g., for file-specific changes).

---

## Related Standards

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git commit best practices](https://chris.beams.io/posts/git-commit/)
- Jira ticket linking conventions
