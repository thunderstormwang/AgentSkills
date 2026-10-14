# Plan Document Conventions

Read this document before creating, reading, splitting, or updating a plan in
`req-analysis`, `technical-design`, `gen-task-in-plan`, or `implementation`.
It defines document organization and communication about formal plan items,
not another lifecycle or confirmation gate.
The owning skill defines how its phase is discussed and confirmed.

## One Formal Entry Point

Each plan has one entry file. Use the user's specified path; if none is known,
agree on its location before creating it. Respect repository naming and
directory conventions; `{ticket}_plan.md` is an example, not a mandatory name.
If the user supplies a split document, follow its backlink to the entry plan.
Ask when the owner is missing or ambiguous; do not guess from a similar name.

Keep these top-level sections in order:

```markdown
# [Plan title]

## Req
## Pre Design Sync
## Design
## Task
## Review
## Release
```

Build the content incrementally. Future sections may be marked not started;
do not invent Req, decisions, Design, or tasks to fill the outline.
Populate existing headings when their phase begins; do not append a duplicate
section merely because an earlier skill created the outline.
Each section contains inline formal content or a useful summary and links to
its external formal bodies, plus its authoritative progress tables when items
exist. The entry plan is both a reading index and the progress overview.

## Inline or Split Content

Keep short content inline. Split a concern or section when its complexity,
comparisons, contracts, or detailed tasks make a separate document easier to
review; there is no fixed line count or mandatory split.

When splitting:

1. Move the detailed formal body to one clearly named document, normally beside
   the plan. Preserve IDs, confirmed conclusions, conditions, and meaning.
2. Leave the relevant summary, item IDs/titles, and relative links to the exact
   formal bodies in the owning plan section. For DQs include concise conclusions;
   for Design include responsibilities and key boundaries; for Task include
   purpose, formal references, and dependencies. A bare "see file" is not enough.
3. Put a backlink to the entry plan in the external document. Do not maintain
   two copies of the full body or two editable progress tables.
4. Update the body location and index together. Use one canonical detailed body
   per item; when it changes, update any affected summary in the same edit.

Example destinations include `{ticket}_req.md`, `{ticket}_pre_design_sync.md`,
`{ticket}_design.md`, `{ticket}_task.md`, `{ticket}_review.md`, and
`{ticket}_release.md`. Names and
document count are change-specific, not a required set.

## Authority, IDs, and Status

The entry plan owns the progress tables for R/RQ, DQ, D, T/FT, CR, and RL
items.
Detailed formal bodies live either inline or at the indexed location.
Read the body for the full specification and the plan table for status; an
index summary never overrides a detailed rule.

Use stable IDs. Follow-up DQ/D groups may keep their local IDs when their
document/group is explicit in the index and references. Assign FT IDs across
the parent plan's task groups, checking existing indexed bodies as well as
tables; do not create an ambiguous duplicate FT ID in a new file.

Status meanings are shared: `Todo` unstarted, `InProgress` active/incomplete,
`Review` ready for user review, `Done` user-confirmed, `Cancel` explicitly
cancelled, and `Pending` explicitly deferred. The owning skill controls the
phase gate; `Pending` is not implicit permission to bypass a blocking decision.
Implementation finishes at `Review`, not autonomous acceptance as `Done`.

When adopting an existing plan with tables in split documents, move the
affected tables to the entry plan and replace their old location with a
backlink. Preserve IDs, statuses, and conclusions; do not migrate unrelated
plans or reset completed work. Surface conflicting body/summary/status
information instead of silently choosing one version.

## Follow-up Work Remains Discoverable

The original plan stays the entry point for work under the same Req.
Index follow-up Pre Design Sync and Design within those original sections,
grouped by optimization and linked to their formal bodies. Their authoritative
DQ/D tables also remain in the original plan. Keep a local follow-up design's
Pre Design Sync and Design together without duplicating the entire Req.

Index FT bodies and their progress rows under the original `## Task`, using a
follow-up subsection when useful. A separate FT file is allowed for readability,
not required for every small task. If an existing plan uses `## Follow-up Task`,
retain it as an indexed extension of Task rather than creating a second status
owner. Reuse agreed destinations; confirm a new file location when necessary.

## Review (Trial)

Review is the **traceability ledger** for findings raised against the
implementation: what was found, how it was judged, and where it went. It does
not specify fixes; the fix lives in the FT, RQ, or D item the finding was routed
to. Its main value is recording the findings that end in *no* change, so a
later review round does not raise them again.

This section is on trial. The structure below is a starting point; adjust it
as practice shows what Review actually needs, and record those lessons here.

Record findings from every source: code review before merge (AI or human) and
issues reported during QA or UAT. Do not paste full review reports.

Candidate subsections; omit what does not apply:

| Subsection | Relevant content |
| :--- | :--- |
| Review rounds | One line per round: date, scope (commit range or Task IDs), and source (AI review, a teammate, QA, UAT) |
| Findings | One `CR01`, `CR02`, ... per finding: severity, location, a one-sentence description, disposition, and destination |
| Feedback to conventions | Optional. When a finding exists because a skill or project convention was missing or wrong, note which one should change |

Every finding takes exactly one disposition:

| Disposition | When | Destination |
| :--- | :--- | :--- |
| Fix | The implementation diverges from its Task, Design, or Req | A new FT |
| Correct specification | The Req, DQ, or Design itself is wrong or incomplete | A new RQ through Backward Correction, then new T items |
| Deliberate | A Pre Design Sync or Design decision already covers it | Cite the DQ/D ID; status `Cancel` |
| Accepted risk | Known and deliberately not addressed | State the condition; add a Release post-release item when it needs monitoring |
| Pre-existing | Already present on the base branch and outside this change's scope | Note the owner or follow-up ticket; status `Pending` |

A finding routed to Correct specification follows the owning skill's Backward
Correction; recording it here does not update the formal baseline.

Before a new review round, read the existing findings. Do not raise again a
finding already judged Deliberate, Accepted risk, or Pre-existing unless the
code or its premise has changed since.

Severity uses 🔴 Bug (incorrect behavior or data), 🟡 Risk (correct today but
fragile), and 🟢 Minor (quality with no functional impact). A finding is `Done`
when its destination item is `Done`, or when the user confirms its judgment.

```markdown
### Review 進度表
| ID | 發現 | 來源 | 嚴重度 | 處置 | 去處 | 狀態 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| CR01 | [Finding] | AI review | 🔴 | Correct specification | RQ18, T23 | Done |
```

## Release (Trial)

Release holds the **execution side** of shipping: what to do, in what order,
and how to confirm each step is done in each environment. Constraints that
must hold — deployment ordering, coexistence of old and new versions, data
preparation, transition mechanisms — stay in Req and Design (Deployment /
Transition); Release cites them by ID instead of repeating their rationale.
Operational procedures such as switch commands or manual rebuild triggers
belong here, not in a D item.

This section is on trial. The structure below is a starting point; adjust it
as practice shows what Release actually needs, and record those lessons here.

Build it incrementally rather than at the end. Add an item whenever a phase
creates a deployment obligation: a Req constraint, a Design ordering rule, or
a Task/FT that changes a cache key, a schema, or requires a rebuild. Review it
for completeness before merging for release.

Candidate subsections; omit what does not apply:

| Subsection | Relevant content |
| :--- | :--- |
| Preconditions | Release dependencies on other repos or tickets, DDL and data-migration scripts and their order, configuration values per environment, external resources |
| Operations | Commands and manual triggers used during release (switches, rebuilds, cache invalidation), each with how to confirm it actually completed — not merely that the call returned |
| Steps | Ordered steps per environment, each with its formal source and a completion condition; environment-specific checks |
| Rollback | What to do when data or code turns out wrong. If rollback has not been reasoned through, say so explicitly rather than implying it is safe |
| Post-release follow-up | Monitoring, re-evaluating deferred tasks, removal of transition measures, and work that belongs to another ticket |

Use `RL01`, `RL02`, ... for items that need tracking. Each item is completed
per environment, so the progress table has one status column per environment;
use the repository's actual environments. Use `—` where an item does not apply:

```markdown
### Release 進度表
| ID | 項目 | SIT | UAT | PROD |
| :--- | :--- | :--- | :--- | :--- |
| RL01 | [Release item] | Todo | Todo | Todo |
```

Release is a checklist that supports judgment, not a script to follow
blindly. Verification steps may stay coarse (for example, a spot check) when
the team does not prescribe specific test data.

## Reading, Updating, and Handoff

- Start with the entry plan and follow relevant formal-body links. For design,
  read the full applicable Req/AC and DQ bodies; for task generation, read the
  full relevant Design; for implementation, read the assigned Task, dependencies,
  referenced contracts/design, and Validation. Do not work from summaries alone.
- Resolve skill resource links relative to the skill directory, and project
  document links relative to their containing document, not the shell's cwd.
- If a required body or link is missing, unreadable, or contradictory, state the
  problem and resolve it before advancing the affected work. Do not substitute
  exploration materials or a guessed specification.
- Formal Req, Pre Design Sync, and Design must not reference exploration
  materials. Transfer needed facts and decisions into their own formal bodies.
  Links to external formal bodies are allowed; these are not exploration files.
- Hand off the entry plan path, relevant IDs, and body locations. Update status
  only in the entry plan, keeping affected body/summary edits together. An
  implementation commit includes its code/document changes and plan status.

## Decision Explanations and Change Reporting

When the user questions a proposal, explain its decision lineage rather than
merely saying "the design requires it." Follow the relevant formal sources,
for example `T01 ← D02 ← DQ03 ← R04/AC`, and state which requirement or confirmed
decision led to the proposal and why. Distinguish fixed requirements, confirmed
technical choices, and new AI recommendations. Use only actual items; do not
invent a full chain or rationale that was never recorded. If the source is
missing or ambiguous, say so and identify what needs clarification.
Keep the explanation self-contained; do not require exploration materials to
understand the decision.

When proposing or applying an upstream correction, report the original and
revised conclusion, the reason for the change, and the affected formal IDs.
Identify which DQs, Design items, TC, or tasks need revision or reconfirmation
and why, including any status changes and the gate to resume from. Preserve
unrelated completed work; do not silently reset a whole phase or alter several
downstream items without explaining the impact. This report does not replace
the owning skill's required user confirmation.

Briefly identify the current phase when switching phases, presenting a phase
for review, or returning upstream for correction. Distinguish requirement
exploration, convergence, and Req review where useful, as well as Pre Design
Sync, Design, Task generation, or implementation. A short natural-language
statement is sufficient; ordinary same-phase questions do not need a repeated
`Current Phase` header or any fixed prefix.

`_shared` is a resource directory, not a skill: it has no `SKILL.md` and does
not load automatically. Each consuming skill must explicitly require this read.
