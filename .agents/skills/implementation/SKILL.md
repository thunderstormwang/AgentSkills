---
name: implementation
description: Executes specific implementation tasks defined in a plan document (e.g., plan.md). Use this skill when the user specifies which Task IDs to implement. It handles code changes, validation, automatic git commits, and updates the task status in the plan document.
---

# implementation

A specialized engine for the autonomous execution of development tasks. It transforms high-level plan items into verified code changes with atomic, pre-authorized commits.

## Plan Entry and Task Bodies

Before reading or updating a plan, read
[Plan Document Conventions](../_shared/plan-document.md), resolving the path
relative to this skill directory. Start from the entry plan, or follow a supplied
split document's backlink to it. Read each assigned Task's full body, dependencies,
applicable formal contracts/design, and `Validation`; do not implement from an
index summary. Keep authoritative task status in the entry plan, not split bodies.
Resolve missing or contradictory specifications before changing source code.

## Workflow (The Atomic Execution Loop)

For each assigned Task ID, the skill MUST follow this sequence:

1. **Context & Status Initialization**:
    - **Readiness**: Verify assigned task scope and that prerequisite work is implemented and validated. Do not silently add tasks or bypass a blocking dependency.
    - **Status Change**: Update the "Status" of the Task in the plan's task progress table to `InProgress`. **Do not commit this change yet.**
    - **Auto-Style Injection**: Immediately call `activate_skill("coding-style")` to load relevant standards for the project's technology stack.
2. **Implementation (Act)**:
    - Apply code changes strictly following the assigned formal Task body's "Implementation Details" and applicable design.
    - Maintain architectural integrity as defined in the loaded coding styles.
3. **Verification (Validate)**:
    - **Task Validation**: Execute the checks and pass criteria in the task's `Validation`, including its scoped shared-strategy references. Distinguish not adding tests from not running tests; preserve explicitly agreed exceptions and alternatives.
    - **Build Check**: Source changes must pass the applicable build; run relevant tests when included in the confirmed strategy. Documentation-only work does not require an unrelated build.
    - **Missing Strategy**: If validation is unspecified or conflicts with the formal design, resolve it before treating implementation as verified. Do not replace it with an incompatible default.
    - **No Implicit Red Acceptance**: A task named "Writing Tests" does not authorize committing failing tests. A deliberately failing intermediate result requires an explicit task-level strategy and agreed pass criteria.
    - **Self-Correction**: If validation fails unexpectedly, attempt to diagnose and fix the error within the current loop.
4. **Halt Condition (Fail-Safe)**:
    - STOP ALL subsequent tasks and notify the user immediately if:
        - A build error persists after a repair attempt.
        - Required existing files, classes, or methods cannot be found, or a required formal body cannot be read. Explicitly planned new files/symbols are not missing prerequisites.
        - The task's required validation cannot be completed or its pass criteria remain unmet.
5. **Atomic Commit (Finalize)**:
    - **Status Finalization**: Update the Task status in the plan from `InProgress` to `Review`.
    - **Single Commit**: Stage both the **Code Changes** and the **Plan Update** (Status: Review).
    - **Split Documents**: Include changed formal Task bodies or affected index summaries in the same commit; do not add a duplicate status table to an external body.
    - **Commit Message**: Use `git-commit` to generate a message following Conventional Commits.
        - **Requirement**: The Header MUST include the Task ID (e.g., `feat(auth): (T1) implement login logic`).
    - **No Confirmation**: Execute the commit **without asking for permission**, as this workflow is pre-authorized.
6. **Iteration**:
    - Repeat from Step 1 for the next Task ID until all assigned tasks are complete or a Halt Condition is met.

## Guidelines
- **Traditional Chinese**: Communicate with the user in Traditional Chinese.
- **Atomicity**: One Task ID = One Commit. The commit MUST contain the task status update to `Review`.
- **Acceptance**: Only the user marks reviewed tasks `Done`; implementation completion is not acceptance.
- **Minimal Intervention**: Aim for full autonomy; only request user intervention when the Fail-Safe conditions are met.
