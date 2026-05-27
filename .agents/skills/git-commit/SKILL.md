---
name: git-commit
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
- **Co-authored-by**: Automatically added to all commits. Always present, even if body is empty.
  - Select the trailer value based on which AI agent product family you are running as (known from your own system prompt / runtime identity). One trailer per brand, regardless of surface (CLI, desktop, web, IDE extension). The exact model ID is embedded in parentheses inside the name part (GitHub still attributes the co-author by email, so the parenthetical does not break attribution):
    | Agent product family | Example surfaces | Trailer |
    |---|---|---|
    | Claude / Claude Code | Claude Code CLI, desktop app, claude.ai/code web, VS Code / JetBrains extension | `Co-authored-by: Claude (<exact-model-id>) <noreply@anthropic.com>` |
    | Gemini | Gemini CLI, Gemini Code Assist (VS Code / JetBrains), Android Studio integration, Gemini app, Workspace | `Co-authored-by: Gemini (<exact-model-id>) <gemini-cli@google.com>` |
    | GitHub Copilot | Copilot CLI (`gh copilot`), Copilot Chat (VS Code / JetBrains / Visual Studio), Copilot Workspace, Copilot on github.com, Copilot for Xcode | `Co-authored-by: Copilot (<exact-model-id>) <223556219+Copilot@users.noreply.github.com>` |
    | Unknown / cannot determine | — | `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>` |
  - Identify by the agent product family, not the underlying model or surface. E.g., if a Claude model is invoked inside Copilot CLI, use the Copilot trailer.
  - **Resolving `<exact-model-id>`**: take it from your own runtime identity / system prompt (the model you are currently running as). Use the clean model family ID — e.g. `claude-opus-4-7` — and strip any context-variant suffix such as `[1m]`. If the brand is known but the exact model ID cannot be determined, use `(Unknown)` as the model part (e.g. `Co-authored-by: Claude (Unknown) <noreply@anthropic.com>`). If the agent brand itself cannot be determined, use `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>`.

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

AI must follow this **Dual-Source Synthesis Flow** to generate the commit message:

1.  **Verify Physical Changes (Source of Truth)**: ALWAYS run `git status` and `git diff` first. This establishes the absolute reality of what changed (files, methods, logic).
2.  **Contextualize Intent**: Refer to recent conversations or planned tasks (e.g., T[x]) to understand "Why" these changes were made.
3.  **Analyze the changes to determine the primary `type`**: Based on the synthesis of intent and diff.
4.  **Identify the `scope` if applicable** (e.g., specific component or file).
5.  **Write a concise `description` in Traditional Chinese** using imperative mood (e.g., "新增功能" not "已新增功能"). The `type` and `scope` remain in English.
6.  **Jira ticket number handling**:
    - If the user provides a number (e.g., `26739`), append `#26739` at the end of the header.
    - If no Jira ticket number is provided, **ask the user for it before proceeding**.
    - If the user explicitly says this commit does not need a Jira ticket, omit it.
7.  **Compose the header (required)**: Single line following `<type>[optional scope]: <description> #<jira ticket no>` format. The header should reflect the primary intent.
8.  **Compose the body (optional)**:
    - **Synthesis Rule**: The body MUST accurately describe the physical changes found in `git diff`.
    - If `git diff` contains logic or refinements NOT mentioned in the conversation/task, AI MUST technically summarize these additional changes in the body.
    - **Prohibition**: NEVER output a message that purely follows the task description but contradicts the actual `git diff`.
    - Maximum of 3 lines. Each line should be concise and meaningful.
9.  **Breaking Changes Detection**:
    - Detect if changes involve:
        * API signature removal or modification
        * Database schema breaking changes
        * Dependency major version upgrade
        * Configuration format changes
        * Public method/property removal
    - If breaking changes detected, suggest adding `BREAKING CHANGE:` footer
    - Offer user confirmation before inclusion
10. **Handle trailers**:
    - If breaking changes exist, add `BREAKING CHANGE: <description>` footer (see Trailers section).
    - Always append a `Co-authored-by:` trailer. Choose the value based on which AI agent product family you are running as (Claude / Gemini / Copilot) — one trailer per brand regardless of surface — per the mapping in Required Trailers above. Embed your resolved `<exact-model-id>` in the name parentheses (clean family ID, no context-variant suffix). If the brand is known but the model ID is not, use `(Unknown)` as the model part; if the agent brand cannot be determined, use `Co-authored-by: Unknown (Unknown) <noreply@unknown.local>`.
11. **Always show the proposed commit message to the user for approval BEFORE executing the git commit command. Do NOT run git commit until the user explicitly confirms.**
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