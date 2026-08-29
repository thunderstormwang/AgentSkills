---
name: pxbox-conventions
description: Team conventions and tacit knowledge for the user's company repos — any repo whose name starts with PXBox or PXEC, case-insensitive. Covers things not derivable from the code itself, such as file-language rules and team practices. Load this the first time in a session you operate on such a repo, before writing any code, docs, instruction files, or commits in it.
---

# PXBox / PXEC Company Conventions

Applies to any repo whose name starts with `PXBox` or `PXEC` (case-insensitive).

## File language

Project-level instruction/skill files in these repos — `CLAUDE.md`, `.claude/skills/*/SKILL.md`,
`.github/copilot-instructions.md` — are written in **Traditional Chinese (繁體中文)**, not English.

Rationale: the language follows the audience, not the file's location. These repos are shared
with teammates, so their instruction files are team documentation, and English would force every
teammate to translate while reading.

This does not apply to `~/.claude/` files — those stay English per the global CLAUDE.md default.

## Git branch → environment mapping

| Branch | Environment |
| :--- | :--- |
| `main` | Prod |
| `release` | UAT |
| `develop` | SIT |

## API route prefix

Route pattern is `<prefix>/<version>/<name>`. The prefix tells you who calls the endpoint:

| Prefix | Caller |
| :--- | :--- |
| `app` | Front-end (customer-facing) screens |
| `backend` | Back-office (internal admin) screens |
| `service` | Other backend microservices |

## Database read/write split

Prod MySQL is master/replica: a main DB for writes, a secondary DB for reads. UAT and SIT each
have only a single DB (no split). The convention is EF Core against the main DB for writes,
Dapper against the secondary DB for reads.

## Redis topology

Prod Redis runs as a **cluster of 3 nodes** (hash-slot sharding). UAT and SIT each have only a
single Redis instance (no cluster, no slots). Some keys use `{...}` hash tags so related keys
land on the same slot — on UAT/SIT this has no effect, since there's no slot routing at all;
keys just live on that one instance as normal strings.
