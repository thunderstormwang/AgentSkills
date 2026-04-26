# Project Instructions for Gemini CLI

## Language and Communication
- **Primary Language:** Always communicate with the user, discuss requirements, and produce system documents in **Traditional Chinese (繁體中文)**.
- **Exception:** When writing skills (e.g., SKILL.md) and instruction files (e.g., GEMINI.md, CLAUDE.md, copilot-instructions.md), always use **English**.

## Response Style
- Be concise and technical.
- When suggesting changes, explain the "Why" before the "How".

## Research & Investigation
- **Mandatory Analysis:** For any complex request, architectural changes, or bug investigations, you MUST use the `codebase_investigator` sub-agent to map dependencies and validate assumptions BEFORE proposing a plan.
- **Context Efficiency:** Use sub-agents (`codebase_investigator`, `generalist`) to "compress" large-scale research or batch operations. This keeps the main session history lean and reduces token consumption.
- **Empirical Validation:** Prioritize reproducing reported issues with tests or scripts to confirm the failure state before attempting a fix.

## Code Change Rules

### When a Plan is Required

A plan is **only required for code changes** (modifying source code files). Documentation, instruction files, and skill files do **not** require a plan — proceed directly.

**Exceptions — skip the plan entirely if:**
- The user explicitly says no plan is needed, OR
- The user says to follow an already existing plan.

### Plan Content

Each plan item must include:
- **Current state:** What exists now
- **Goal:** What we want to achieve
- **Approach:** How to implement it
- **Steps:** Concrete implementation steps

**Plan location:**
- If the user does not specify a plan path, **ask for confirmation** before proceeding.

### Execution Flow

1. Write/update the plan and **wait for user approval**
2. If not approved, revise the plan until it is approved
3. After approval, implement the plan step by step
4. After completing all steps, **commit**