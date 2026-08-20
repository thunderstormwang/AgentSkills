---
name: git-commit
description: Create and format git commit messages following Conventional Commits with up to 5-line body. Use this when the user asks to commit changes, write a commit message, or needs help structuring commits with meaningful descriptions and ticket references. Also use when rewriting history — squash, rebase, amend, fixup, reword — and a message for the resulting commit must be composed.
---

# Git Commit Helper Skill

A skill for creating well-structured git commit messages following Conventional Commits specification.

## Format

**Header (single line):**
```
<type>[optional scope]: <description> #<jira ticket no>
```

**Body (optional, max 5 lines):**
- Use when additional context or details are needed
- Maximum of 5 lines
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
    - When rewriting history (squash / rebase / amend), the source of truth is the **net range diff** instead — see [History Rewriting](#history-rewriting-squash--rebase--amend).
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
    - Maximum of 5 lines. Each line should be concise and meaningful.
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
11. **Commit first, then report — do NOT ask for approval beforehand.**
    - Once the message is composed, run `git commit` immediately. Do not pause to ask "shall I commit this?".
    - The required flow is: **compose message → commit → show the exact committed message to the user**.
    - After committing, always display the full commit message (header, body, trailers) so the user can review what was recorded.
    - The only pre-commit question allowed is the Jira ticket number (step 6) and BREAKING CHANGE confirmation (step 9).
12. **Amend on request**:
    - If the user asks for any wording change after seeing the committed message, revise it with `git commit --amend` instead of creating a new commit.
    - Do not amend proactively; only when the user explicitly asks for a change.
    - Never amend a commit that has already been pushed unless the user explicitly asks for it.
    - After amending, show the updated message again.

## History Rewriting (Squash / Rebase / Amend)

When several commits collapse into one, the resulting message must describe the **net end state**, not the path taken to reach it. Once squashed, the intermediate back-and-forth is no longer visible in the tree — describing it makes the message contradict what `git show` actually displays.

1.  **Source of truth is the net range diff, NOT the old messages.**
    - Determine the base: the parent of the earliest commit being collapsed (`<base>`). For a rebase onto a branch, use `git merge-base HEAD <target-branch>`.
    - Run `git diff <base>..HEAD` and compose the message from **that diff only**.
    - `git log <base>..HEAD` may be read for *intent* context ("why") only. NEVER copy, concatenate, or bullet-list the old commit messages into the new body.
2.  **The net-effect test** — apply to every body line before writing it:
    - Would a reader who runs `git show` on this single commit see the change this line claims? If no, delete the line.
    - Code added and later removed within the range → mention **neither**. It is not in the net diff.
    - A value/name/approach changed repeatedly within the range → state only the **final** value.
    - A bug introduced and fixed within the range → mention neither the bug nor its fix.
3.  **Prohibited body content**:
    - Self-referential or process wording: "修正前一版…", "調整上述…", "改回…", "再次修正…", "依 review 意見調整…".
    - Enumerating the collapsed commits ("包含 3 個 commit：…") or preserving their headers as body lines.
    - Any line whose only purpose is describing a step that was later superseded.
4.  **Header reflects the whole range's purpose**, not the first or last commit's header. Re-derive `type` and `scope` from the net diff — a range of `fix` commits refining a new feature is a `feat`, not a `fix`.
5.  **Trailers**: keep exactly one `Co-authored-by:` per distinct identity — deduplicate the ones inherited from the collapsed commits rather than stacking them. Keep a `BREAKING CHANGE:` footer only if the breaking change still exists in the net diff.
6.  **Pushed history requires explicit confirmation**: if any commit in the range has already been pushed, ask the user before rewriting. This extends step 12's rule to squash and rebase, which are more destructive than `--amend`.

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

**Example 6: Squashing 4 commits — net end state only**

Collapsed commits (`git log <base>..HEAD`):
```
feat(cache): 新增 Redis 快取層
fix(cache): 修正 TTL 單位錯誤
refactor(cache): timeout 由 10 秒改為 30 秒
fix(cache): 移除誤加的 debug log
```

❌ WRONG — preserves the intermediate process, contradicts `git show`:
```
feat(cache): 新增 Redis 快取層 #26739

新增 Redis 快取層。
修正 TTL 單位錯誤。
timeout 由 10 秒改為 30 秒。
移除誤加的 debug log。
```
The TTL bug, the 10-second value, and the debug log never exist in the net diff — a reader cannot find any of them.

✅ CORRECT — describes only what the net diff contains:
```
feat(cache): 新增 Redis 快取層 #26739

以 IMemoryCache 介面封裝讀寫，TTL 以毫秒為單位設定。
連線 timeout 設為 30 秒。

Co-authored-by: Claude (claude-opus-5) <noreply@anthropic.com>
```