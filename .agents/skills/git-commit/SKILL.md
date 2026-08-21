---
name: git-commit
description: Create and format git commit messages following Conventional Commits, with a wrapped body of an opening paragraph plus up to 5 bulleted items. Use this when the user asks to commit changes, write a commit message, or needs help structuring commits with meaningful descriptions and ticket references. Also use when rewriting history — squash, rebase, amend, fixup, reword — and a message for the resulting commit must be composed.
---

# Git Commit Helper Skill

A skill for creating well-structured git commit messages following Conventional Commits specification.

## Format

**Header (single line):**
```
<type>[optional scope]: <description> #<jira ticket no>
```
- Aim for 50 display columns, 72 at the absolute most. Never wrap the header.
- The ticket number appears **only** in the trailing `#<no>`. Do not also embed it
  in the description (`feat(refund): PXBOX-27492 … #27492` repeats itself).

**Body (optional):**
```
<opening paragraph: what changed and why, in aggregate>
                                      ← blank line
- <item>
- <item, whose continuation lines are
  indented two spaces>
- <item>
                                      ← blank line
<closing line: verification facts>
```
- **Up to 5 items**, counted as bullets — not as lines. A bullet wrapped over
  three lines is still one item.
- The opening paragraph and the closing line do not count toward the 5.
- **Wrap every line at 72 display columns.** A CJK character occupies 2 columns,
  so a Traditional Chinese line holds roughly 36 characters.
- **Blank lines** separate the opening paragraph, the bullet block, and the
  closing line. Do **not** put blank lines between the bullets themselves.
- **One idea per item.** If a bullet needs `；`, `——`, or `，故` to join two
  independent statements, it is two items — split it, or drop the weaker half.
- Drop the parts that carry no weight: with a single item, write the paragraph
  alone and omit the bullets; omit the body entirely when the header suffices.

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
    - Follow the body shape defined in [Format](#format): opening paragraph → up to 5 bullets → closing line, every line wrapped at 72 display columns.
    - **The 5-item cap limits content, not density.** It must never be satisfied by packing several statements into one long bullet — that is the failure it exists to prevent. If the change genuinely has more than 5 points, promote the shared theme into the opening paragraph and keep only the 5 that a reviewer could not infer from the diff; if it still does not fit, the commit is doing too much and should be split.
    - The closing line carries verification facts only — build result, test counts, base branch. Omit it when there is nothing to verify.
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

1.  **Source of truth is the net diff of the rewritten range, NOT the old messages.**
    - **Resolve the base and capture the net diff BEFORE the rewrite starts.** Once an interactive rebase is in flight, `HEAD` is detached at a partially-applied state, and once it finishes the old base is no longer reachable from `HEAD` — a range computed at either moment is wrong.
    - Each operation has a different net diff. `--amend` has no range at all:

      | Operation | Net diff to read |
      |---|---|
      | Squash / fixup of N commits | `git diff <parent-of-earliest-collapsed-commit>..HEAD` |
      | Rebase a branch onto `<target>` | resolve `git merge-base <branch> <target>` **first**, then `git diff <that-sha>..<branch>` |
      | `--amend` | `git diff HEAD~1..HEAD` **plus** `git diff --cached` — the net effect is the existing commit's diff combined with what is **staged**. Unstaged changes are NOT amended in, so `git diff` must be excluded; include it only when the amend will run with `-a` |

    - Compose the message from that diff only.
2.  **Read the old commit messages LAST, if at all.**
    - Draft every body item from the diff first. Only then may `git log <base>..HEAD` be read, only to recover *why* a change was made, and only to reword an item that already exists — never to add one.
    - Reading the old headers before drafting is the direct cause of process-flavoured bodies: the headers *are* the process, and paraphrasing them is the path of least resistance. Do not open them early.
    - NEVER copy, concatenate, or bullet-list the old messages into the new body.
3.  **The net-effect test** — apply to every body item before writing it:
    - Would a reader who runs `git show` on this single commit see the change this item claims? If no, delete the item.
    - Code added and later removed within the range → mention **neither**. It is not in the net diff.
    - A value/name/approach changed repeatedly within the range → state only the **final** value.
    - A bug introduced and fixed within the range → mention neither the bug nor its fix.
4.  **Prohibited body content.** The net-effect test in step 3 is the actual rule; the items below are recognisable symptoms of failing it, not an exhaustive blacklist. A rephrasing that avoids these exact words but still describes a superseded step is equally prohibited.
    - Self-referential or process wording: "修正前一版…", "調整上述…", "改回…", "再次修正…", "依 review 意見調整…", or any equivalent.
    - Enumerating the collapsed commits ("包含 3 個 commit：…") or preserving their headers as bullets.
    - Any item whose only purpose is describing a step that was later superseded.
5.  **Header reflects the whole range's purpose**, not the first or last commit's header. Re-derive `type` and `scope` from the net diff — a range of `fix` commits refining a new feature is a `feat`, not a `fix`.
6.  **Trailers**: keep exactly one `Co-authored-by:` per distinct identity — deduplicate the ones inherited from the collapsed commits rather than stacking them. Keep a `BREAKING CHANGE:` footer only if the breaking change still exists in the net diff.
7.  **Pushed history requires explicit confirmation**: if any commit in the range has already been pushed, ask the user before rewriting. This extends step 12's rule to squash and rebase, which are more destructive than `--amend`.
8.  **Show the resulting message once the rewrite completes** — the same obligation step 11 imposes on a normal commit. The user must see what was actually recorded, not what was intended.
    - Read it back from git and display it verbatim, including trailers: `git log -1 --format=%B` for a single collapsed commit, or `git log <target>..HEAD --format=%B` when a rebase rewrote several.
    - For the multi-commit readback, bound the range by the **post-rewrite** base (`<target>`, or `ORIG_HEAD`), never by the base resolved in step 1. After a rebase that old base is no longer an ancestor of `HEAD`, so `<old-base>..HEAD` resolves as a set difference and also lists the target's own commits — messages this rewrite never authored.
    - Never report a rewrite as finished without showing the message. A message can be silently truncated, left as the editor's template, or inherited unchanged from the old commit — none of which is visible unless it is read back.

## Examples

**Example 1: The full shape — paragraph, bullets, closing line**
```
test(payment): code review 衍生任務與 Q05 定案 #27492

補強兩處測試的防呆與可讀性，並結案 Q05；僅動測試檔，
生產碼零 diff。

- FT01 補上第三方退款 mock，讓守衛回歸時以斷言失敗，
  而非 NullReferenceException 加 18 秒重試。
- FT02 抽離 Get_Payment_Created_With_ChargeType，消除
  5 引數呼叫靜默綁到 nonDeductionAmount 的歧義。
- Q05 定案：訂單服務不需為 3282 調整，自動重送只認 3270。

建置 0 錯誤、測試 239 通過。

Co-authored-by: Claude (claude-opus-5) <noreply@anthropic.com>
```

**Example 2: Header only, no Jira ticket (user confirmed not needed)**
```
fix(coupon): 修正折扣計算錯誤
```

**Example 3: Single item — paragraph alone, no bullets**
```
refactor(api): 優化 API 響應時間 #25841

改用快取層減少資料庫查詢，命中時不再往 DB 取價。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Example 4: With BREAKING CHANGE footer**
```
feat(auth)!: 移除舊版 token 認證方式 #26739

改用 OAuth 2.0 為唯一認證入口，舊版 token 端點下線。

- 新增授權碼流程與 refresh token 輪替。
- 保留向後兼容層並標記 deprecated，下一個主版本移除。

BREAKING CHANGE: Legacy token authentication has been removed.
Migrate to OAuth 2.0 using the new authentication endpoint.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Example 5: One idea per item — splitting a packed bullet**

❌ WRONG — one bullet, three statements welded together:
```
fix(payment): 修正支付流程逾時錯誤 #28451

- 調整 timeout 設置為 30 秒；改進錯誤訊息提示——原本逾時會回傳空白訊息故前端無法判斷，另補上重試計數。
```
The line runs past 72 display columns, and `；`, `——`, `故` are each welding
a separate point onto it.

✅ CORRECT — one idea per bullet, each wrapped:
```
fix(payment): 修正支付流程逾時錯誤 #28451

拉長金流閘道的等待上限並補齊逾時後的可觀測性。

- timeout 由 10 秒調整為 30 秒。
- 逾時改回傳明確錯誤訊息，前端不再收到空白 body。
- 補上重試計數，供 slow-log 判斷是否為閘道端壅塞。

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Example 6: Squashing 4 commits — net end state only**

The net diff (`git diff <base>..HEAD`) — the only valid source for the body:
```
CacheService.cs   + Redis get/set wrapped behind IDistributedCache, TTL expressed in milliseconds
appsettings.json  + Redis:ConnectTimeout = 30s
```
No TTL bug, no 10-second value and no debug log appear anywhere in it — they were introduced and cancelled out inside the range.

Collapsed commits (`git log <base>..HEAD` — read only AFTER drafting, for "why" context):
```
feat(cache): 新增 Redis 快取層
fix(cache): 修正 TTL 單位錯誤
refactor(cache): timeout 由 10 秒改為 30 秒
fix(cache): 移除誤加的 debug log
```

❌ WRONG — reuses those four headers as bullets, contradicts `git show`:
```
feat(cache): 新增 Redis 快取層 #26739

- 新增 Redis 快取層。
- 修正 TTL 單位錯誤。
- timeout 由 10 秒改為 30 秒。
- 移除誤加的 debug log。
```
The TTL bug, the 10-second value, and the debug log never exist in the net diff — a reader cannot find any of them.

✅ CORRECT — every item traceable to a line of the net diff above:
```
feat(cache): 新增 Redis 快取層 #26739

為商品價格查詢加入分散式快取，減少尖峰時段的 DB 讀取。

- 以 IDistributedCache 封裝 Redis 讀寫，TTL 以毫秒為單位設定。
- Redis 連線 timeout 設為 30 秒。

Co-authored-by: Claude (claude-opus-5) <noreply@anthropic.com>
```
