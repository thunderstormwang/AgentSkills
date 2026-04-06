---
name: git-commit-formatter-anthropics
description: Enhanced Conventional Commit formatter tailored for Traditional Chinese descriptions and safer commit flow.
---

Git Commit Formatter (Anthropics)

Purpose
- Provide an improved, user-friendly Conventional Commits formatter that:
  - Keeps types/scope in English, descriptions in Traditional Chinese (imperative mood).
  - Tries to infer Jira ticket when possible but always confirms with the user.
  - Enforces a safe, auditable commit flow (propose → confirm → commit).

Format
- <type>[optional scope]: <description> [#JIRA]
  - type: one of feat, fix, docs, style, refactor, perf, test, chore
  - scope: short, lowercase noun (e.g., auth, api)
  - description: Traditional Chinese, imperative mood, <=72 chars preferred
  - #JIRA: optional; if present append as ` #12345`

Rules & Behaviour
1. Primary type detection: analyze staged changes and choose the primary type representing the user-facing intent.
2. Scope guidance: include the most specific logical component changed. Omit if unclear.
3. Description language: MUST be Traditional Chinese, imperative mood (e.g., “修正 X 問題”，not “已修正 X”) — keep it concise.
4. Jira handling (improved):
   - If a Jira/issue ID is provided by the user or found in branch name (e.g., feature/ABC-1234), suggest it.
   - If none found, ask the user only once whether they want to add a ticket. If user declines, proceed without one.
   - If user provides only a URL, extract the ticket number when possible.
5. Breaking changes: if present, include a footer line starting with `BREAKING CHANGE:` followed by a brief explanation in Traditional Chinese.
6. Commit message body: include a short (wrap ~72 chars) body in Traditional Chinese when additional context is needed. Separate subject and body with a blank line.
7. Length limits: subject <=72 chars recommended; body lines wrap at 72 chars.
8. Safety/flow:
   - Always show the proposed full commit message to the user and list staged files.
   - Wait for explicit user approval (clear affirmative) before running `git commit`.
   - If the user instructs to amend, or to create multiple commits, follow explicit instructions and re-confirm each commit message.

Examples
- feat(auth): 新增 Google 登入 #26739
- fix(coupon): 修正折扣計算錯誤
- docs: 更新 API 文件，補上會員建立範例
- perf(db): 減少 N+1 查詢，提高列表效能
- refactor(cache): 重構快取邏輯，拆分責任
- feat(ui): 調整深色主題樣式
- fix(api): 修正使用者資料回傳順序

Notes for integrators
- Do NOT auto-run `git commit` without confirmation. The skill must always propose then wait.
- Prefer suggesting a ticket when one can be inferred, but require user confirmation to attach it.
- When writing code that calls this skill, present staged files to the user along with the proposed message.

Changelog
- 1.0.0: Initial Anthropics-enhanced copy with improved Jira inference, clearer scope rules, and stricter safety flow.
