# Project Instructions

## Language and Communication

- **Primary Language:** Always communicate with the user and produce system documents in **Traditional Chinese (繁體中文)**.
- **Exception:** Skill files (e.g., `SKILL.md`) and instruction files (e.g., `CLAUDE.md`, `copilot-instructions.md`) must be written in **English**.

## Response Style

- Be concise and technical.
- When suggesting changes, explain the **"Why"** before the **"How"**.

## Code Change Workflow

### When a Plan Is Required

A plan is **only required for source code changes**. Documentation, instruction files, and skill files do **not** require a plan — proceed directly.

**Skip the plan entirely if:**
- The user explicitly says no plan is needed, or
- The user says to follow an already existing plan.

### Plan Format

Each plan item must include:

- **Current state:** What exists now
- **Goal:** What we want to achieve
- **Approach:** How to implement it
- **Steps:** Concrete implementation steps

Ask the user where to save the plan file if no path is specified.

### Execution Flow

1. Write or update the plan, then **wait for user approval**.
2. If not approved, revise until approved.
3. Implement the plan step by step.
4. After all steps are complete, **commit the changes**.

## Git Commit

- **Always** use the `git-commit` skill when committing.
- **Never** run `git commit` directly via Bash.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
