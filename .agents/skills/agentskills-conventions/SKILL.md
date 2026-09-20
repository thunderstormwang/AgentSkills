---
name: agentskills-conventions
description: Conventions for the user's personal AgentSkills repo — the canonical source that gets exposed on each of the user's machines (Windows at work, Mac at home) as global Claude Code skills/agents/instructions via a symlink (macOS) or Junction/Symlink (Windows). Load this whenever the user asks to edit their own personal skill, agent, or instruction file — "改我的 skill" / "個人 skill" / "改一下我的 XXX skill", "我的 XXX agent", "改我的 CLAUDE.md" / "個人的 copilot-instructions" (edit target is always this repo, never the linked global copy — applies equally to skills, agents, and instruction files, not just skills). Also load it when the user explicitly names this repo alongside a link request — "建立與 AgentSkills repo 的連結", "檢查與 AgentSkills repo 的連結", "AgentSkills 的連結有沒有建好", "幫我建 AgentSkills 的連結" — a bare "建立連結" / "檢查連結" with no mention of AgentSkills or the user's personal skills is too generic to be this trigger. Also load it right after editing any SKILL.md / agent .md / CLAUDE.md / copilot-instructions.md in this repo, since it drives the required Traditional-Chinese `_Cht` sync and the commit.
---

# AgentSkills Repo Conventions

This repo (`AgentSkills`) is the single source of truth for the user's **personal** skills,
agents, and instruction files. Nothing about it is company/project work — it follows the
`user-level and personal-project repos` branch of the global CLAUDE.md, i.e. English content
with a Traditional-Chinese `_Cht` sibling per file (see below), not the `b2c-conventions`
Chinese-first rule.

On each machine, a handful of global paths under the user's home directory are **links** into
this repo, not copies. That's what makes "edit once, works on both computers" possible — for a
skill, an agent, or an instruction file alike. Everything below exists to keep that true.

## Rule 1 — always edit the repo, never the global path

When the user asks to change "my skill" / "個人的 XXX skill" / "我的 XXX agent" / "我的
CLAUDE.md" / "個人的 copilot-instructions" — a skill, agent, or instruction file named as their
own, with no other project's context — the file to edit is **inside this repo's clone**,
resolved via the [Link Manifest](#link-manifest) below — e.g. "改一下我的 git-commit skill" →
`{repo}/.agents/skills/git-commit/SKILL.md`, "改一下我的 CLAUDE.md" →
`{repo}/.claude/CLAUDE.md`. This
holds even if the user pastes or names a global path instead
(`~/.claude/skills/git-commit/SKILL.md`, `$HOME\.claude\CLAUDE.md`, …) — translate it back to
the repo-relative path first, then edit that.

**This rule is not skill-specific.** It applies identically to agents (`.claude/agents/*.md`)
and to the two instruction files (`CLAUDE.md`, `copilot-instructions.md`). Don't let "skill"
being the more frequent case narrow the reading — the same edit-the-repo rule, the same Link
Manifest, and Rule 3's translate-then-commit apply to all four kinds of file the same way.

**Why:** a global path is only ever a pointer. It can be a healthy link today, missing on a
machine that hasn't been set up yet, or — if some tool ever saves by "write a new temp file,
then rename over the target" — silently replaced by a brand-new plain file, which severs the
link without any error (see [`references/link-types.md`](references/link-types.md) for the full
mechanics of why). The repo path is never any of those things; it's always the real file.
Editing there is correct unconditionally, so there's never a reason to edit through the global
side.

## Link manifest

`{repo}` = this repo's clone root on the current machine. `{home}` = the user's home directory
(`$HOME`/`~` on macOS, `$env:USERPROFILE` on Windows).

| Global path (under `{home}`) | Repo path (under `{repo}`) | Kind |
|---|---|---|
| `.claude/skills` | `.agents/skills` | dir |
| `.agents/skills` | `.agents/skills` | dir |
| `.claude/agents` | `.claude/agents` | dir |
| `.claude/CLAUDE.md` | `.claude/CLAUDE.md` | file |
| `.copilot/copilot-instructions.md` | `.github/copilot-instructions.md` | file |

(`.claude/skills` and `.agents/skills` both point at the same repo folder — one is Claude
Code's own skill path, the other is the generic path other agent tools look at. Keep both.)

(On agents specifically: they have the same project-vs-user scope split as skills — project
(`<repo>/.claude/agents`) overrides user (`~/.claude/agents`) on a name clash — which is exactly
why an agent that only exists in this repo's own `.claude/agents` is callable only from inside
this repo, and why that path needs linking too. Also, Claude Code has no `/agent <name>` or
`@<name>` call syntax — naming an agent directly in the prompt is how you invoke it; `@` does
file-path completion in Claude Code, `/` is a skill.)

(A known, accepted asymmetry between the two — and not the product of a clean original design.
`.agents/skills` was set up on the assumption that *every* AI tool, Claude Code included, would
read skills from that one generic path; it turned out Claude Code doesn't, so a second,
Claude-specific link (`~/.claude/skills`) had to be added on top of the mirror link that was
already planned for other tools (`~/.agents/skills`) — both are load-bearing today, neither is
redundant. `.claude/agents`, by contrast, was never a multi-tool decision at all: at the time it
was set up, only Claude Code was in use, so no other tool's path was ever considered — it simply
happens to already sit at Claude Code's own native project-scope path, which is why agents don't
need the same workaround skills do, and why a session whose primary directory is this repo finds
them with no global link at all, on any machine, even a brand-new one. This is a genuine
difference in behaviour, not a bug: project overrides user by name, so neither case risks a
duplicate listing or a conflict. Left as-is for now rather than untangled in either
direction — the AI tool landscape moves fast enough that this could well need revisiting again
soon anyway, so it's not worth over-engineering today.)

(On `CLAUDE.md` specifically: unlike skills and agents, Claude Code's memory files are additive
across scopes, not selected by an override rule — project memory and user memory are two
separate tracked sources and **both** get loaded, confirmed by `/memory` listing a "User
instruction" entry and a "Project instruction" entry side by side. There is no dedup by resolved
real path here the way there seems to be for agents. This file used to live at the repo root and
was moved to `.claude/CLAUDE.md` purely to group it with this repo's other Claude-specific files
(`.claude/agents/`) — **not** to fix the duplication. Don't confuse this with the Multi-Repo Work
section's finding below: that one is about a *different* repo added via `/add-dir`, whose
`.claude/CLAUDE.md` is confirmed NOT auto-loaded. When `.claude/CLAUDE.md` sits inside the
session's own primary working directory instead, it's confirmed (by testing against other repos)
to be auto-loaded as project memory the same as a root `CLAUDE.md` would be — so this file still
loads twice today, exactly as before the move, just from a different project-side path. The only
way to actually stop the duplication would be a filename Claude Code doesn't recognize as project
memory at all, which trades away the same no-link-needed fallback this repo's own agents enjoy
(see above) — worth revisiting only if that trade starts to look worthwhile.)

### Finding `{repo}` on the current machine

The clone location differs per machine (different username/drive on Windows vs. Mac). Resolve it
in this order — each step is a fallback for when the one above can't answer:

1. **Resolve an existing link.** If any Link Manifest row is already a live link on this
   machine, follow it: `readlink -f ~/.claude/CLAUDE.md` (macOS/Linux) or
   `(Get-Item "$env:USERPROFILE\.claude\CLAUDE.md").Target` (Windows) — then strip the manifest
   row's repo-relative suffix (`.claude/CLAUDE.md`, `.agents/skills`, …) off the result to get
   `{repo}`.
   This needs no prior setup and is always current, since a link can't point at a stale
   location without simply being a broken link (visibly so).
2. **Memory.** If no link exists yet on this machine (first run of this skill here), check
   memory for a note recording this machine's path from a previous session.
3. **Current working directory.** If memory has nothing either, use the cwd when it looks like
   this repo (contains `.agents/skills` and a `.claude/CLAUDE.md` whose content matches this
   file's repo).
4. **Ask once**, then save the answer to memory so a future session on this machine — one that
   still has no links to resolve from step 1 — doesn't need to ask again. Memory is local per
   machine (it lives under `~/.claude/`, which is never itself one of the linked paths), so
   there's no cross-machine collision.

## Rule 2 — link check-and-repair workflow, only when the user names this repo

Trigger phrases: the user must tie the request to *this repo* (or "個人 skill/agent"
collectively), not just say "連結" in the abstract — e.g. "建立與 AgentSkills repo 的連結",
"檢查與 AgentSkills repo 的連結", "AgentSkills 的連結有沒有建好", "幫我建 AgentSkills 的連結",
"個人 skill 沒同步到這台電腦". A bare "建立連結" / "連結有沒有建好" / "幫我建連結" with nothing
tying it to AgentSkills or the user's personal skills is too generic to be this trigger — it
could mean any unrelated link (a project shortcut, a symlink for some other tool, …) — so ask
what they mean instead of assuming it's this workflow. Once it is clearly this trigger, do not
ask the user which links to check — always run the full manifest.

1. Determine the current OS (from the environment info already in context, or `uname`/`$env:OS`
   if unclear).
2. Determine `{repo}` per above.
3. For each Link Manifest row, compute the absolute global path and absolute repo path, then
   inspect the global path:
   - **Missing** → create it (see commands below). Report `🔧 created`.
   - **Is a link, and already points at the right repo path** → nothing to do. Report `✅ ok`.
   - **Is a link, but points somewhere else** (e.g. a stale path from an old clone location) →
     relink it. This is safe and reversible (no content lives at a link path), so do it without
     asking. Report `🔁 relinked`.
   - **Is a real file or directory, not a link** → **stop, do not touch it.** It may hold real
     content that a relink would delete. Report `⚠️ conflict` and ask the user how to proceed.
4. Print one summary table (path → status) at the end; don't narrate each row as prose.

This only ever touches the machine the session is running on. The same check simply runs again,
independently, the next time this skill triggers on the other machine.

### Commands

**macOS / Linux** (same command for dirs and files):
```sh
mkdir -p "$(dirname "<global-path>")"
ln -s "<repo-path>" "<global-path>"
```

**Windows — directory** (Junction, no admin needed):
```powershell
New-Item -ItemType Directory -Force -Path (Split-Path "<global-path>") | Out-Null
New-Item -ItemType Junction -Path "<global-path>" -Target "<repo-path>"
```

**Windows — file** (Symlink; needs an elevated/admin PowerShell, or Developer Mode enabled):
```powershell
New-Item -ItemType Directory -Force -Path (Split-Path "<global-path>") | Out-Null
New-Item -ItemType SymbolicLink -Path "<global-path>" -Target "<repo-path>"
```
If PowerShell refuses for lack of privilege, the `cmd.exe` equivalent from an elevated prompt
also works: `mklink "<global-path>" "<repo-path>"` (add `/J` for a directory Junction instead,
which does not need elevation).

To relink (row 3 above): remove the existing link first (`rm "<global-path>"` /
`Remove-Item "<global-path>"` — safe, it only deletes the pointer, never the target), then run
the create command again.

## Rule 3 — after any content change: translate, then commit

This repo keeps every instruction/skill `.md` file paired with a `_Cht` sibling
(`{name}_Cht.{ext}`, next to the original — e.g. `SKILL.md` → `SKILL_Cht.md`,
`.claude/CLAUDE.md` → `.claude/CLAUDE_Cht.md`). Translation rule (this used to be delegated to a
separate
`file-translator` skill; that skill only ever existed to serve this rule and nothing else, so
it's inlined here instead of kept as its own skill):

- Word-for-word Traditional Chinese, with precise and natural grammar — never modify the
  English original while producing the translation.
- Keep Markdown formatting identical to the original: headers, lists, tables, links, code
  fences, etc.
- When a technical term has no good Traditional Chinese equivalent, keep the English term as-is
  or add it in parentheses.
- Output path is always `{dir}/{name}_Cht.{ext}`, next to the source; overwrite the `_Cht` file
  if it already exists.
- For a `SKILL.md`, this includes its **YAML frontmatter's `description` field** — translate
  that too, not just the body; it's easy to carry it over verbatim by mistake since it sits
  above the Markdown content, but the same fully-translated rule applies to it.
- **Keep `description` on one physical line, however long** — every `description` in this repo
  is a single unwrapped line, unlike the body prose below it. Manually wrapping it like a
  paragraph produces a multi-line plain YAML scalar that some frontmatter parsers (VS Code's
  included) reject outright ("Implicit keys need to be on a single line"), breaking the skill's
  preview with no content change otherwise needed to fix it — just rejoin it into one line.
  Relatedly, avoid an unquoted ASCII `": "` (colon + space) inside the description text itself —
  it reads as a YAML mapping indicator and breaks the same way ("Nested mappings are not allowed
  in compact mappings"); use `—` instead, matching every other description in this repo. A
  full-width `：` is a different character and is safe.

Whenever a `SKILL.md`, a `references/*.md`, a `.claude/agents/*.md`, `.claude/CLAUDE.md`, or
`.github/copilot-instructions.md` is created or edited in this repo:

1. **Regenerate its `_Cht` sibling immediately**, in the same turn as the content edit — do this
   unprompted, it's a standing repo convention, not something to wait for the user to ask again.
   Never edit a `_Cht` file directly; it's always derived from the English original.
2. **Commit in this repo** using the `git-commit` skill's flow (load that skill before composing
   the message, exactly as for any other commit). Skill/doc changes need no plan or pre-approval
   under this repo's own `CLAUDE.md` — go straight from translation to commit.
