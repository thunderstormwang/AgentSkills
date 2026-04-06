---
name: git-commit-formatter
description: Formats git commit messages according to Conventional Commits specification. Use this when the user asks to commit changes or write a commit message.
---

Git Commit Formatter Skill

When writing a git commit message, you MUST follow the Conventional Commits specification.

Format
`<type>[optional scope]: <description> #<jira ticket no>`

If no Jira ticket number is provided, omit the `#<jira ticket no>` part.

Allowed Types
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **chore**: Changes to the build process or auxiliary tools and libraries such as documentation generation

Instructions
1. Analyze the changes to determine the primary `type`.
2. Identify the `scope` if applicable (e.g., specific component or file).
3. Write a concise `description` in **Traditional Chinese** using imperative mood (e.g., "新增功能" not "已新增功能"). The `type` and `scope` remain in English.
4. If there are breaking changes, add a footer starting with `BREAKING CHANGE:`.
5. **Jira ticket number handling:**
   - If the user provides a number (e.g., `26739`), append `#26739` at the end of the description.
   - If no Jira ticket number is provided, **ask the user for it before proceeding**.
   - If the user explicitly says this commit does not need a Jira ticket, omit it.
6. **Always show the proposed commit message to the user for approval BEFORE executing the git commit command. Do NOT run git commit until the user explicitly confirms.**
   - This rule applies unconditionally — even if the user says "commit", "幫我 commit", "commit 吧", or any other direct commit instruction.
   - The required flow is always: **propose message → wait for confirmation → then commit**.
   - Never skip the confirmation step, regardless of how direct the user's instruction is.

Example
`feat(auth): 實作 Google 登入 #26739`
`fix(coupon): 修正折扣計算錯誤`  ← (no Jira ticket, user confirmed not needed)