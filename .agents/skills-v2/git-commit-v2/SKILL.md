---
name: git-commit-v2
description: Create and format git commit messages following Conventional Commits with up to 3-line body. Use this when the user asks to commit changes, write a commit message, or needs help structuring commits with meaningful descriptions and ticket references.
---

# Git Commit Helper Skill

A skill for creating well-structured git commit messages following Conventional Commits specification.

## Format

**Header (single line):**
```
<type>[optional scope]: <description> #<jira ticket no>
```

**Body (optional, max 3 lines):**
- Use when additional context or details are needed
- Maximum of 3 lines
- Omit if the header alone sufficiently describes the change

If no Jira ticket number is provided, omit the `#<jira ticket no>` part.

## Allowed Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

## Trailers

Trailers are key-value pairs placed at the end of the commit message footer (after body or header).

### Required Trailers
- **Co-authored-by**: Automatically added to all commits
  - Format: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`
  - This identifies Copilot's contribution per GitHub conventions
  - Always present in commit message, even if body is empty

### Optional Trailers
- **BREAKING CHANGE**: Used to indicate breaking changes or major version impacts
  - Add when: API signature changes, database schema breaking changes, major version upgrades, configuration format changes, public method/property removal
  - Format:
    ```
    BREAKING CHANGE: <description of breaking change>
    <detailed explanation if needed>
    ```
  - Can appear multiple times if there are multiple breaking changes
  - Should follow the Conventional Commits specification

## Instructions
1. Analyze the changes to determine the primary `type`.
2. Identify the `scope` if applicable (e.g., specific component or file).
3. Write a concise `description` in **Traditional Chinese** using imperative mood (e.g., "新增功能" not "已新增功能"). The `type` and `scope` remain in English.
4. **Jira ticket number handling:**
   - If the user provides a number (e.g., `26739`), append `#26739` at the end of the header.
   - If no Jira ticket number is provided, **ask the user for it before proceeding**.
   - If the user explicitly says this commit does not need a Jira ticket, omit it.
5. **Compose the header (required):** Single line following `<type>[optional scope]: <description> #<jira ticket no>` format.
6. **Compose the body (optional):** If more context is needed:
   - Add up to 3 lines of explanation
   - Each line should be concise and meaningful
   - Omit if the header sufficiently describes the change
7. **Breaking Changes Detection:**
   - Detect if changes involve:
     * API signature removal or modification
     * Database schema breaking changes
     * Dependency major version upgrade
     * Configuration format changes
     * Public method/property removal
   - If breaking changes detected, suggest adding `BREAKING CHANGE:` footer
   - Offer user confirmation before inclusion
8. **Handle trailers:**
   - If breaking changes exist, add `BREAKING CHANGE: <description>` footer (see Trailers section)
   - Always append `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` trailer to all commits
9. **Always show the proposed commit message to the user for approval BEFORE executing the git commit command. Do NOT run git commit until the user explicitly confirms.**
   - This rule applies unconditionally — even if the user says "commit", "幫我 commit", "commit 吧", or any other direct commit instruction.
   - The required flow is always: **propose message → wait for confirmation → then commit**.
   - Never skip the confirmation step, regardless of how direct the user's instruction is.

## Examples

**Example 1: Header + 3-line body with Jira ticket**
```
feat(auth): 實作 Google 登入 #26739

新增 OAuth 2.0 認證流程。
整合 Google Identity 服務。
支援自動帳號建立。
```

**Example 2: Header only, no Jira ticket (user confirmed not needed)**
```
fix(coupon): 修正折扣計算錯誤
```

**Example 3: Header with 1-line body**
```
refactor(api): 優化 API 響應時間 #25841

改用快取層減少資料庫查詢。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Example 4: With BREAKING CHANGE footer**
```
feat(auth)!: 移除舊版 token 認證方式 #26739

新增 OAuth 2.0 認證流程。
保留向後兼容層 (deprecated)。

BREAKING CHANGE: Legacy token authentication has been removed.
Migrate to OAuth 2.0 using the new authentication endpoint.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Example 5: Standard fix with all trailers**
```
fix(payment): 修正支付流程逾時錯誤 #28451

調整 timeout 設置為 30 秒。
改進錯誤訊息提示。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```