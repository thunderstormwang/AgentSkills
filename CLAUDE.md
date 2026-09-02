# Project Instructions

## Language and Communication

- **Primary Language:** Always communicate with the user and produce system documents in **Traditional Chinese (繁體中文)**.

### Skill and Instruction Files

Default (user-level and personal-project repos): **English** — these files are read only by the
user and the AI, so there's no audience to write for in Chinese.

**Trigger rule:** the first time in a session you operate on a repo whose name starts with `PXBox`
or `PXEC` (case-insensitive), load the `pxbox-conventions` skill before writing any code, docs,
instruction files, or commits in it. That skill overrides the file-language default above for
such repos, and holds further team conventions and tacit knowledge as they're added.

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

## Multi-Repo Work

A requirement often spans several repos while the session runs in only one of them.

**Trigger rule:** the first time in a session you discuss, inspect, or design against a repo
other than the primary working directory, **Read that repo's `.claude/CLAUDE.md` first** —
even when the current task looks unlikely to need it. That file holds exactly the tacit
knowledge that cannot be inferred from the code, so reading it late means having already
reasoned from wrong assumptions.

What `/add-dir` does and does not do (verified 2026-09-02):

| | Behavior |
|---|---|
| File tools (Read / Edit / Write / Glob / Grep) | Gain access to the added directory |
| That repo's `.claude/skills/` | **Loaded**, listed under a `Project` source in `/context` |
| That repo's `.claude/CLAUDE.md` | **NOT loaded** — hence the trigger rule above |
| Primary working directory | Still exactly one |
| Where added dirs are listed | `/permissions` — session-only state, written to no settings file |

Add a directory only when files in it must actually be **written**; read-only exploration
needs none.

**CodeGraph across repos:** `codegraph explore` resolves by the shell's cwd, so
`cd <other repo> && codegraph explore "<query>"` queries that repo's index and auto-syncs it
on the way. The `UserPromptSubmit` prompt-hook only ever covers the primary repo, so context
for other repos never arrives on its own — go fetch it.

**Plans stay one per repo, each committed inside its own repo.** The plan for the repo the
work starts in carries a short 對外契約 section — contract shape and deployment order only,
no Task items — and that section is the input when the other repos' sessions begin, so the
requirement never has to be re-explained from scratch.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
