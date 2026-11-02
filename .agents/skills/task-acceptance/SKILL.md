---
name: task-acceptance
description: Accepts a batch of plan Tasks that an implementation subagent (e.g. implementation-agent) reports as done — independently checks each Task's commit against its formal Task body, marks conforming Tasks `Done` on the user's behalf, and gives the user a short summary of what conformed, what deviated but still meets the plan, and what the user should check. Use whenever a subagent hands back code changes for plan Tasks (T or FT), including "agent 做完了", "驗收", "幫我看 agent 有沒有照 Task 做". Not for investigation/review subagents that only report findings, not for the user's own whole-plan or whole-branch review (use branch-review), and not for work the current session implemented itself.
---

# task-acceptance

The per-batch review the user would otherwise do by hand after an implementer finishes: **did it do what each Task says?** The goal is to save the user's time on that question, so the user only looks where a judgment is genuinely needed.

The implementer's report is a **claim, not evidence**. This skill exists because the implementer checking itself is not independent — every conclusion here must come from the repository, not from the report.

## Scope

| In scope | Out of scope |
| :--- | :--- |
| Tasks a subagent implemented and committed in this batch | Findings from investigation/review subagents (spot-check those as usual) |
| Conformance to each Task's formal body, and through it to the plan | Whole-plan / whole-branch review — the user leads that; use `branch-review` |
| Marking accepted Tasks `Done` on the user's behalf | Fixing the code — send it back to the implementer or ask the user |

Invoking this skill is the user's delegation of per-batch acceptance. If the user says they want to review a batch themselves, stop after the summary and leave statuses at `Review`.

## Inputs

Before checking, have in hand:

- The implementer's report (commit SHAs, deviations, uncertainties, changed assertions, test counts).
- The entry plan and, for every Task in the batch, its **full formal body** (Current state / Goal / Implementation Details / Validation / Test File / Affected Files), following split-document links per [Plan Document Conventions](../_shared/plan-document.md). Never accept against an index summary.
- The test baseline from before the batch, if it was recorded at dispatch.

## Checks

Scale the effort to the change: a documentation-only Task needs only checks 1, 6 and 7.

1. **Repository state** — current branch is the intended one; working tree clean; every reported SHA exists, one Task per commit, each containing its plan status change to `Review`; nothing pushed; no unreported commits in the range.
2. **Fresh build and full test run** — rebuild, then run the whole test suite (never a `--no-build`-style shortcut; the implementer's binaries may be stale). Compare counts with the baseline and with the report.
3. **Task conformance** — the core check. For each Task, read its commit's diff (production code first) against the formal body:
   - every Implementation Details item is present, in the final state of the batch;
   - nothing beyond the Task's scope was changed;
   - the Task's Validation was actually satisfied, and Test File (DoD) exists;
   - Affected Files match; any extra or missing file is explained.
4. **Changed existing assertions** — list every pre-existing test assertion the batch changed or removed. Each must trace to a behavior change the Task specifies. An unexplained change is the cheapest way to make tests pass and must not be accepted silently.
5. **Residuals** — for renames and removals the Task specifies, search that the old names are gone where they should be.
6. **Report claims** — verify each deviation and "unsure" item the implementer listed, and look for deviations it did not list.
7. **Status** — Tasks are at `Review`, never `Done`, when handed over.

## Classify each Task

| Class | Meaning | Status |
| :--- | :--- | :--- |
| **A — Conforms** | Done as the Task says; no problems found | `Done` |
| **B — Deviates, still meets the plan** | Differs from the Task's literal text, but the Task's required behavior and the plan's Req/Design still hold (e.g. an extra test helper parameter, a clearer name, an equivalent structure) | `Done` |
| **C — Needs the user** | Any deviation that changes behavior, contracts, data, or test meaning; a changed assertion without a Task-specified reason; validation not met; or anything you could not verify | stays `Review` |

When unsure between B and C, choose C. A wrong C costs the user one look; a wrong B hides a problem until the whole-plan review.

## Apply and report

1. Set A and B Tasks to `Done` in the entry plan's progress table (status column only) and commit that change with the `git-commit` skill as its own commit. Leave C Tasks at `Review`. Do not amend or squash the implementer's commits.
2. Give the user a short summary in Traditional Chinese:
   - one line per Task: class, and in a few words why;
   - for B: what differs from the Task and why it still meets the plan;
   - for C: exactly what the user should check, with `file:line`;
   - what you verified yourself (build result, test counts before → after), kept separate from anything you are relaying from the implementer's report unverified.

Keep it short. The summary replaces the user's per-batch review; it should not be longer than reading the diff would have been.
