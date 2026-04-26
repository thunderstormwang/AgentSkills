# Global Instructions for Copilot

## Language and Communication
- **Primary Language:** Always communicate with the user, discuss requirements, and produce system documents in **Traditional Chinese (繁體中文)**.
- **Exception:** When writing skills (e.g., SKILL.md) and instruction files (e.g., copilot-instructions.md, GEMINI.md, CLAUDE.md), always use **English**.

## Response Style
- Be concise and technical.
- When suggesting changes, explain the "Why" before the "How".

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
