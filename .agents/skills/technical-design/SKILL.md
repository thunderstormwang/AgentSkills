---
name: technical-design
description: Discuss Pre Design Sync and produce Design under a confirmed Req. Use for architecture, DB, API, cache, event contracts, component responsibilities, or substantial follow-up optimization before generating tasks. Inherit confirmed requirements without restarting Req; unresolved business requirements belong to req-analysis, and Task generation belongs to gen-task-in-plan.
---

# Technical Design Under a Confirmed Req

Produce **Pre Design Sync → Design** from a confirmed requirement baseline.
Settle technical choices before specifying the design; hand off to
`gen-task-in-plan` only after user confirmation. This skill does not generate
implementation tasks or source changes.

## Plan Entry and Entry Gate

Before reading, creating, or updating a plan, read
[Plan Document Conventions](../_shared/plan-document.md), resolving the path
relative to this skill directory. Start from the entry plan and follow its
formal-body links; do not infer the full requirement from an index summary.

1. Read the formal Req, including constraints, AC, outstanding RQs, and actual
   confirmation status. Do not infer confirmation from the existence of a file
   or from having answered the last question.
2. Start Pre Design Sync only when R01–R05 are confirmed and no blocking
   requirement ambiguity remains. Otherwise hand the affected issue to
   `req-analysis`, without manufacturing the missing business rule.
3. A confirmed Req produced by another workflow is valid input. Do not require
   recreating it with `req-analysis`.
4. Keep Pre Design Sync and Design indexed in the entry plan. Their bodies may
   remain inline or use agreed split documents. For follow-ups, link the local
   design from the original plan; keep its DQ/D progress tables in that plan.
   Agree on a new body location when none has been specified.

### Follow-up Optimization

For a substantial optimization of an implemented plan, inherit its confirmed
Req and check compatibility. Do not regenerate the five R items, reconfirm the
whole Req, or reset completed phases just to begin an optimization.

Record the formal baseline reference and the relevant scope, constraints, and
AC conditions needed to understand this local design. Keep local Pre Design
Sync and Design together. An earlier task's "not in this change" is not
automatically a plan-wide prohibition; distinguish it from the original Req.
Keep accepted risks and their conditions visible rather than automatically
adding compensation or replay work.

Discuss the approach before generating FT tasks. Simple renames, comments,
and straightforward follow-ups can go directly to `gen-task-in-plan`; not
every FT needs a separate design discussion.

## Formal Documents Must Not Depend on Exploration Materials

Req, Pre Design Sync, and Design must not reference requirement source-text,
current-state investigation, gaps/questions, or other exploration materials.
Do not include links, file/section pointers, or "see the investigation" even
for evidence. Incorporate the necessary verified facts, conditions, decisions,
and reasoning directly into the formal section that needs them.

Investigate the current code for each relevant concern; Req describes business
behavior, not the current implementation structure. Materials can help locate
evidence, but recheck it when needed and do not treat old observations as
current facts. Do not paste full transcripts or raw queries into formal design.

References among formal Req, DQ, D, AC, TC, and Task items remain valid.
Dedicated formal Pre Design Sync or Design documents are also allowed; they
are part of the specification, not exploration materials. Preserve authoritative
IDs, conclusions, statuses, and the confirmation gate when splitting them.
Do not split merely to meet a line count.

## 1. Pre Design Sync

Populate `## Pre Design Sync` in the entry plan for unresolved technical choices affecting
architecture, ownership, data models, caching, contracts, or integrations.
Use one `DQ01`, `DQ02`, ... per decision. Do not produce the Design section yet.

For each DQ:

1. State the decision, relevant verified implementation facts, and constraints.
   Include enough context to understand it without reading exploration materials.
2. When there are multiple candidate solutions, provide a comparison table
   covering approach, pros/cons, change scope, and risk. State the recommended
   solution and why; do not leave the user with an unranked list.
3. Ask for the user's decision. Record the final conclusion in the detailed
   body and in the entry plan's progress table; the concise table does not replace the
   decision's necessary conditions or rationale.
4. Check the conclusion against Req and already-resolved DQs. Surface genuine
   conflicts for user resolution rather than silently choosing a winner.

Scope, desired behavior, terminology, and acceptance ambiguity belong to
Req, not DQ. Stop the affected design work and return such an issue to
`req-analysis`; resume after the corrected requirement is confirmed.

```markdown
### Pre Design Sync 進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| DQ01 | [Design decision] |  | Todo |
```

Use `Todo` / `InProgress` for unresolved decisions, `Review` for a proposed
conclusion awaiting confirmation, and `Done` for a user-confirmed conclusion.
Use `Cancel` for an explicitly cancelled item. `Pending` may pass the gate
only when explicitly non-blocking, with its exclusion or agreed condition
recorded; it cannot conceal an undecided input needed by the design.

Proceed only when all DQs are `Done`, `Cancel`, or explicitly non-blocking
`Pending`. If no unresolved technical choice exists, record why the phase has
no DQs; do not invent questions to fill a template.

## 2. Design

Populate `## Design` in the entry plan after Pre Design Sync without removing or overwriting its
decisions. Define structural and behavioral contracts: what changes, where
responsibilities belong, and which ordering/invariants must hold.

Propose useful sections from the confirmed decisions and actual change.
The user need not prescribe the full outline first. Add, remove, or revise
sections during review; the following topics are candidates, not mandatory
deliverables. Omission must not hide a relevant contract, concurrency,
failure-handling, or validation concern.

| Candidate topic | Relevant content |
| :--- | :--- |
| Impact Scope | Affected services, APIs, and existing behavior |
| DB Schema | Tables, columns, precision, indexes, existing-data migration and initialization |
| Domain Model | Entities, value objects, enums, relationships, and invariants |
| Contracts | API request/response, event shapes, compatibility, and consumers |
| Caching Strategy | Keys, data structures, TTL, consistency, interfaces, and invalidation |
| Internal Component Structure | Responsibilities, dependencies, DI boundaries, signatures, relocated or removed behavior |
| Core Logic Spec | Behavioral rules, precedence, early returns, ordering, state transitions, concurrency, and failure handling |
| Component Flow | Useful call/side-effect sequencing, optionally with diagrams |
| Deployment / Transition | Required deployment order, coexistence, data preparation, and accepted transition risks |
| Validation Strategy | Applicable build, test, review, and agreed scoped exceptions or alternatives |
| Test Plan | Test targets, framework, files, and a formal TC entry point when tests are added or changed |

Keep ownership and dependency decisions in Internal Component Structure;
keep behavioral rules in Core Logic Spec. Cross-reference formal items instead
of duplicating either side. Domain Model is not a bucket for all service
interfaces or orchestration.

Component Flow diagrams are useful when they clarify sequencing or
collaboration, not mandatory for every design. Removing one in this discussion
does not forbid a diagram in a later change.

**Contract-only snippets:** field declarations, method signatures, and event
shapes are allowed. Method bodies, executable SQL queries, and mapping/assembly
code belong to Task, not Design. Specify migration scope and required effects
in prose without writing its implementation SQL.

### Validation Strategy and Test Plan

Propose suitable validation and record the confirmed strategy.
Distinguish "do not add tests" from "do not run tests"; keep each exception
limited to the authorized work and retain applicable alternatives. Never
interpret either as no validation or as a repository-wide waiver.

When adding or modifying tests, place detailed TC in a separate formal
`{ticket}_tc.md` or appropriate layer-specific TC file. Design's Test Plan
contains the target, framework, test file paths, and TC link. Req AC does not
need a reverse TC link.

TC guidance:

- Reference the corresponding formal AC IDs and use concrete Given/When/Then
  values. Avoid `$X`, "depends on configuration", or unspecified expected
  outputs; split into concrete cases.
- Use headings such as `{MethodUnderTest}_{Scenario}_{ExpectedBehavior}` and
  a one-line Traditional-Chinese description beneath each.
- Include terminology and observable-output field mappings so test authors
  can identify the correct assertions.
- Cover relevant boundaries, failure paths, ordering, and existing shared
  behavior affected by the change, not just the new happy path.
- Check TC against confirmed AC and Design. Fix transcription inconsistencies;
  return genuine specification ambiguity to Req instead of inventing a rule.

When no test additions/changes are applicable or they are explicitly excluded,
omit unnecessary Test Plan/TC artifacts but retain Validation Strategy.

### Design Confirmation

Use `D01`, `D02`, ... for the actual design sections and end the entry plan's
Design section with this table, even when the bodies are split:

```markdown
### Design 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| D01 | [Design section] | Review |
```

Use `Todo` / `InProgress` for incomplete sections, `Review` when ready for
confirmation, and `Done` only after user confirmation. `Cancel` and `Pending`
have the same explicit, non-blocking meaning as in Pre Design Sync.

Before presenting, check Design against Req, DQ conclusions, other D items,
and TC. Correct transcription errors before notification. Surface substantive
conflicts and choices requiring the user's decision; do not silently change
a confirmed decision.

## 3. Handoff and Backward Correction

After every D item is confirmed or explicitly non-blocking/cancelled, hand off
to `gen-task-in-plan`: Mode A for initial tasks, Mode B for follow-ups.
Provide the entry plan and formal Req/design body locations, applicable DQ/D IDs, dependencies,
constraints, accepted risk conditions, and validation strategy. Do not generate
tasks before this gate or require exploration materials to implement them.

If an upstream conclusion changes, trace the earliest formal source:
`Task ← D ← DQ ← Req/AC`. Correct it and re-evaluate dependent items.
Reset only affected items requiring reconfirmation to `Review` or `Todo`;
do not reset unrelated completed work. Updating exploration materials alone
never updates a formal decision.

Communicate and produce project documents in Traditional Chinese.
