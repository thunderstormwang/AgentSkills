---
name: git-commit-helper
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
7. **If there are breaking changes**, add a footer starting with `BREAKING CHANGE:`.
8. **Always show the proposed commit message to the user for approval BEFORE executing the git commit command. Do NOT run git commit until the user explicitly confirms.**
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
```