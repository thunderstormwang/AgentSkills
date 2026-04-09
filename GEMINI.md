# Project Instructions for Gemini CLI

## Language and Communication
- **Primary Language:** Always communicate with the user, discuss requirements, and produce system documents in **Traditional Chinese (繁體中文)**.
- **Exception:** When writing skills (e.g., SKILL.md) and instruction files (e.g., copilot-instructions.md), always use **English**.

## Response Style
- Be concise and technical.
- When suggesting changes, explain the "Why" before the "How".

## Research & Investigation
- **Mandatory Analysis:** For any complex request, architectural changes, or bug investigations, you MUST use the `codebase_investigator` sub-agent to map dependencies and validate assumptions BEFORE proposing a plan.
- **Context Efficiency:** Use sub-agents (`codebase_investigator`, `generalist`) to "compress" large-scale research or batch operations. This keeps the main session history lean and reduces token consumption.
- **Empirical Validation:** Prioritize reproducing reported issues with tests or scripts to confirm the failure state before attempting a fix.

## Code Change Rules

### Plan Required Before Code Changes

When the user requests code modifications, you **must write a plan first** before making any changes.

This rule applies unconditionally — even if the task involves investigation or research steps before the actual code change. As long as the final outcome includes modifying code, a plan must be written and confirmed first.

**Plan content for each item must include:**
- **Current state:** What exists now
- **Goal:** What we want to achieve
- **Approach:** How to implement it
- **Status:** Pending / In Progress / Code Review / Done

**Status definitions:**
- **Pending:** Not yet started
- **In Progress:** Currently being implemented
- **Code Review:** Implementation complete, committed, waiting for user review
- **Done:** User confirmed, task complete

**Plan location:**
- If the user does not specify a plan path, **ask for confirmation** before proceeding.
- If the user explicitly states this change does not need a plan, display the plan content on screen instead of writing to a file.

**Execution flow:**
1. Write/update the plan and wait for user confirmation
2. After confirmation, execute tasks **one by one in order**
3. After each task, **commit and wait for user confirmation** before proceeding to the next task