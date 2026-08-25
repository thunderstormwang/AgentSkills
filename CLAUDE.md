# Project Instructions

## Language and Communication

- **Primary Language:** Always communicate with the user and produce system documents in **Traditional Chinese (繁體中文)**.

### Skill and Instruction Files

The language depends on **who reads the file**, not on its filename:

| Scope | Examples | Language |
| :--- | :--- | :--- |
| **User-level** (`~/.claude/`) | `CLAUDE.md`, `skills/*/SKILL.md` | **English** — read only by the user and the AI |
| **Project-level — company projects** (repo name starts with `PXBox` or `PXEC`, case-insensitive) | `CLAUDE.md`, `.claude/skills/*/SKILL.md`, `.github/copilot-instructions.md` | **Traditional Chinese** — teammates read these |
| **Project-level — personal projects** (any other repo, e.g. `AgentSkills`) | same files as above | **English** — no audience beyond the user and the AI |

Rationale: the language follows the audience, not the file's location. Company repos are shared with
teammates, so their instruction files are team documentation and English forces every teammate to
translate while reading. Personal repos have no such audience, even though the files are committed.

**When it is unclear whether a repo counts as a company project, ask before writing** — switching language later means rewriting the whole file.

## Response Style

- Be concise and technical.
- When suggesting changes, explain the **"Why"** before the **"How"**.

## Code Change Workflow

### When a Plan Is Required

A plan is **only required for source code changes**. Documentation, instruction files, and skill files do **not** require a plan — make the change and commit it directly, without asking first.

This waives the approval step, not the `git-commit` skill — that skill's flow still governs the commit itself. History rewriting (squash / rebase / amend) always needs explicit confirmation, documentation included.

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

**Trigger rule:** if an operation will create or change a commit message, the `git-commit` skill
must be loaded **before** the operation runs. The trigger is the outcome, not the command name — do
not reason about whether the operation "counts as committing".

- **Load the skill first** before running any of: `git commit` (with or without `--amend`),
  `git rebase` in any form (`-i`, `--autosquash`, `--continue` that opens an editor),
  `git merge --squash`, `git cherry-pick`, `git revert`, `git filter-branch`, or any git command
  carrying `-m`, `-F`, `--fixup`, `--squash`, `--reuse-message`, or `--reedit-message`.
- **When in doubt, assume a message will be authored and load the skill.** The cost of loading it
  unnecessarily is nil; the cost of skipping it is a message that has to be rewritten.
- **Never** run `git commit` directly via Bash. This covers every way of supplying the message
  without the skill: `-m`, `-F -`, heredocs, `--no-edit`, and `GIT_EDITOR=true`.
- **Never pre-compose a message and then look for a command to feed it to.** The skill's flow
  (verify the diff → compose → commit → show the committed message) is the only path to a commit.
  Composing first and invoking the skill afterwards to rubber-stamp the result violates this rule.
- Rewriting history has its own message rules — the skill's History Rewriting section is mandatory
  reading for squash / rebase / amend, not optional background.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
