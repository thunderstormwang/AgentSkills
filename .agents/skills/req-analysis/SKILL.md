---
name: req-analysis
description: Explore requirements and converge into a confirmed Req. Use when the user brings Jira descriptions, meeting or PM notes, incomplete requirements, current-state questions, hidden needs, or requirement changes and wants to clarify what the system should do. Owns exploration, RQs, and formal Req confirmation; technical solution selection belongs to technical-design, and Task generation belongs to gen-task-in-plan.
---

# Requirement Exploration and Convergence

Turn incomplete input into a trustworthy requirement baseline through
**exploration → convergence → Req confirmation**. Investigate before forcing the
discussion into a formal template. This skill owns what is needed and why;
`technical-design` owns how the confirmed requirement will be satisfied.

## Plan Entry and Workflow Boundary

Before reading, creating, or updating a plan, read
[Plan Document Conventions](../_shared/plan-document.md), resolving the path
relative to this skill directory. Keep Req's index and authoritative R/RQ
progress tables in the entry plan; its full formal body may be inline or split.
Do not draft Pre Design Sync or Design content, generate implementation tasks,
or change source code under this skill. Empty future-phase headings in the plan
outline are not permission to advance those phases.

## Working Documents and Formal Specifications

Distinguish two kinds of documents:

| Kind | Purpose | Organization |
| :--- | :--- | :--- |
| Exploration materials | Preserve source wording, investigated evidence, gaps, options, and discussion | Change-specific; no fixed format, file count, or mandatory document set |
| Formal Req | State the complete, confirmed requirement baseline | R01–R05 and progress tables |

Documents such as requirement source text, current-state investigation, and
gaps/questions are examples, not three mandatory files. Keep small discussions
in chat or existing materials; create files when requested or needed for the
agreed documentation workflow. Agree on the destination before creating a
plan when none has been specified.

Choose where exploration content belongs without asking the user to route
each discussion item: preserve original statements in source-text materials,
verified behavior and evidence in current-state investigation, and differences,
questions, options, and decisions in gaps/questions materials. Use other
documents when they better fit the topic; update existing materials rather than
creating a new file for every turn. This is content organization, not a fixed
set of required files. Small discussions may still remain in chat.

**Formal specifications must not reference exploration materials.** Req,
Pre Design Sync, and Design must contain the facts, conditions, conclusions,
and reasoning each needs. Do not use a link, file name, section pointer, or
"see the investigation" in place of that content, even as an evidence link.
Formal Req/DQ/D identifiers may reference one another; this rule does not ban
traceability between formal specifications.

Transfer the necessary understanding, not the entire investigation transcript.
Keep raw queries, source excerpts, and abandoned options in the materials.
Materials may record which formal item absorbed a conclusion, so traceability
does not make the formal specification depend on them.

## 1. Explore Before Converging

1. Preserve the user's source wording without silently rewriting its meaning.
   Distinguish source statements, verified facts, user decisions, AI hypotheses,
   and unresolved questions. A hypothesis is not a requirement.
2. Investigate discoverable facts in code, data, and existing documents before
   asking the user to restate them. Follow repository instructions and inspect
   relevant paths rather than inferring behavior from names or declarations.
   When access is unavailable, state the limitation; do not label the claim
   verified.
3. Compare the requested outcome with actual behavior. Explore terminology,
   affected users and surfaces, boundaries, exceptions, time behavior,
   compatibility, deployment obligations, and acceptance expectations when
   relevant. These are prompts for investigation, not a checklist of documents
   or an invitation to expand scope.
4. Surface potentially unstated needs as questions with their consequences.
   Ask about desired behavior and constraints; do not invent extra requirements
   or turn every technical implementation choice into a business question.
5. Record decisions and adjust understanding as discussion evolves. Preserve
   meaningful superseded conclusions in materials, but carry only the current
   confirmed understanding into formal Req.

Stay in exploration while major ambiguity prevents a coherent Req. Do not
require the user to prescribe the entire document outline in advance. Propose
a useful organization and revise it during review.

### Investigation Evidence

Flexible document format does not waive evidence requirements. Record the
following with investigated findings, whether they remain in chat or are saved
in materials, so later readers can locate the evidence and assess its age:

- **Code:** repository, file path, and actual line numbers or line ranges for
  the relevant behavior. A class/method name alone is not enough. Obtain the
  locations from the inspected source; do not invent line numbers.
- **Database queries or statistics:** database environment, query date, SQL
  or another reproducible retrieval method, and the actual parameters, filters,
  or time window used. Include the result or a sufficient statistical summary
  and what it supports; a conclusion without the retrieval method is not
  reproducible.

Keep only necessary, non-sensitive result details; do not record credentials.
If evidence or a retrieval detail is unavailable, state the limitation instead
of presenting an unsupported claim as verified.

### Requirement Questions

Use `RQ01`, `RQ02`, ... for requirement ambiguities that need human
confirmation. Track their context, behavioral options, recommendation when
appropriate, conclusion, and which R items they affect. This can begin in the
materials; do not force a formal five-item Req before it is useful.

If an answer must come from a PM, stakeholder, or external team, provide a
forwardable Given/When/Then clarification showing the difference between
options and the exact decision required. This is a clarification aid, not the
format of final Acceptance Criteria.

When converging, transfer any remaining RQ's essential context and blocking
effect into `### Req 待確認事項` inside Req. Transfer resolved conclusions into
the affected R items; a question log is not a substitute for rewriting them.

## 2. Converge into Formal Req

Draft `## Req` in the entry plan from confirmed understanding. If the body is
split, preserve its summary, formal-body links, and progress tables in the plan:

| ID | Item | Content |
| :--- | :--- | :--- |
| R01 | Objective | The business goal and why the change is needed |
| R02 | Current State | Verified current capabilities and behavior |
| R03 | Proposed Changes | Target capabilities, changed behavior, and relevant exceptions |
| R04 | Constraints | Immutable behavior, scope exclusions, pre-decided choices, precision/format, and other fixed conditions |
| R05 | Acceptance Criteria | Observable conditions for accepting the result |

Write Objective, Current State, Proposed Changes, and AC in functional
language readable by PMs and non-engineers. Keep class/method names and
implementation plans out of them. A technical detail belongs in Constraints
when it is itself a confirmed fixed condition, not merely a possible solution.
Design choices discovered during exploration remain candidates for the design
phase unless explicitly decided as constraints.

Current State contains verified present behavior, not future intentions or
unresolved guesses. Distinguish a known defect from the intended rule; do not
silently turn the defect into a preservation requirement. Ask whether the
change must preserve or correct it when that affects scope.

### Acceptance Criteria

- Ground each AC in verified behavior and the agreed target. For refactors or
  extensions, trace the relevant existing code path before drafting; for new
  features, check the supplied requirement/specification. Surface gaps and
  contradictions instead of silently reconciling them. Known defects are not
  automatically requirements to preserve.
- Use plain business-language rule statements, not implementation steps or
  Given/When/Then test scripts. Preserve exact business terminology.
  Describe observable triggers and outcomes, not intermediate pipeline state;
  an AC should survive renaming or refactoring internal helpers.
- Match rule names in AC titles and bodies to the confirmed requirement.
  Do not collapse distinct rules into a generic label: a first-purchase product
  exclusion is not interchangeable with a per-product promotion rule.
- Give each AC one concern and an ID such as `AC-{group}-01`; avoid global
  renumbering when an unrelated group changes.
- Cover observable boundaries, equality, ordering/tie-breaks, time transitions,
  exclusions, and failure outcomes where they affect the requirement.
  For calculations, include dedicated concerns for rounding to zero, per-item
  minimums, residual allocation, and early completion when relevant. Express
  the business effect rather than the implementation branch.
- State shared prerequisites and rules once in the relevant section.
  Include their substance; do not point back to exploration materials.
  Identify invalid or excluded combinations and who enforces their exclusion,
  so readers do not assume every forbidden combination needs a new test.
- Keep unresolved rules in RQs, not placeholders inside final AC.
- Separate business acceptance rules from detailed test cases, concrete test
  data, calculation traces, and assertions. Detailed TC belongs to the design
  workflow when tests are part of the validation strategy.
- For complex rules, a dedicated formal AC document is allowed. It is part of
  Req, not exploration material; retain R05 as its authoritative entry point.

For a multi-case formal AC document, organize chapters by business case and
include AC IDs in headings. Put common term definitions at the top. If system
field mappings are useful, isolate them in a dictionary subsection rather than
using English field names in business-rule prose. Keep core rules readable
without implementation jargon; explain ordering/tie-breaks in natural language.
Use plain-text formulas without emoji, and add a table of contents when the
document has more than five chapters. Concrete calculation traces and per-item
attribution belong to TC, not the PM-facing rules.

When an acceptance rule changes, identify affected existing TC and hand off
their consistency check to `technical-design`. Updating Req alone must not
leave contradictory tests unnoticed; this does not authorize new test scope.

### Convergence Check

Before presenting Req for confirmation, check that every material finding
affecting requirements is incorporated, explicitly excluded, or recorded as a
remaining RQ. Do not lose a condition during summarization.

Read the formal Req without opening materials: can a reader determine scope,
terms, current behavior, target rules, exceptions, constraints, and acceptance
conditions? Rewrite missing content into Req. Remove material references,
resolved tentative wording, and contradictions between RQ conclusions and R
items.

## 3. Confirm and Hand Off

End the entry plan's Req section with its own progress table, even when the
detailed formal body is in a separate document:

```markdown
### Req 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R01 | Objective | Review |
| R02 | Current State | Review |
| R03 | Proposed Changes | Review |
| R04 | Constraints | Review |
| R05 | Acceptance Criteria | Review |
```

These statuses illustrate a ready draft, not defaults. Use `Todo` for
unstarted content, `InProgress` for incomplete content, `Review` when ready for
confirmation, and `Done` only after user confirmation.

When RQs remain, include a separate table:

```markdown
### Req 待確認事項進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| RQ01 | [Requirement question] |  | Todo |
```

Do not finish Req while a blocking RQ remains unresolved. `Pending` is allowed
only for an explicitly non-blocking item whose exclusion or agreed condition
is stated in Req; `Cancel` records an explicitly cancelled question.

Ask the user to confirm the complete Req when all five R items are ready.
Present the draft and wait; producing it does not establish confirmation.
If review reveals missing needs or changes, return to the relevant exploration
and clarification, rewrite affected formal Req content, and await confirmation
again.
After confirmation, hand off the formal Req location and its confirmed scope,
constraints, and AC to `technical-design`. Exploration materials are not a
required handoff input. Do not start design merely because the last RQ was
answered.

## Backward Correction

If design later exposes a genuine scope, behavior, constraint, or acceptance
ambiguity, clarify the affected Req items here. Do not restart the entire
requirement lifecycle for a local issue.

Record the new conclusion in formal Req and re-evaluate affected formal DQs,
Design items, TC, and tasks. Reset only dependent items requiring reconfirmation
to `Review` or `Todo`, explain the impact, and resume from the corrected gate.
Materials may retain the history, but changing them alone never updates the
formal baseline.

Communicate and produce project documents in Traditional Chinese.
