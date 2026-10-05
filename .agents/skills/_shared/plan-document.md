# Plan Document Conventions

Read this document before creating, reading, splitting, or updating a plan in
`req-analysis`, `technical-design`, `gen-task-in-plan`, or `implementation`.
It defines document organization, not another lifecycle or confirmation gate.
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
`{ticket}_design.md`, and `{ticket}_task.md`. Names and document count are
change-specific, not a required set.

## Authority, IDs, and Status

The entry plan owns the progress tables for R/RQ, DQ, D, and T/FT items.
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

`_shared` is a resource directory, not a skill: it has no `SKILL.md` and does
not load automatically. Each consuming skill must explicitly require this read.
