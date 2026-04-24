---
name: implementation-completion
description: Executes specific implementation tasks defined in a plan document (e.g., plan.md). Use this skill when the user specifies which Task IDs to implement. It handles code changes, validation, automatic git commits, and updates the task status in the plan document.
---

# implementation-completion

A specialized skill for executing development tasks derived from a structured plan. It focuses on reliable implementation, validation, and maintaining the plan's progress.

## Workflow

1. **Task Identification**: Only execute the specific Task IDs (e.g., T1, T2) explicitly requested by the user.
2. **Impact Assessment**:
    *   Check how many files will be modified by the requested tasks.
    *   If the total number of affected files exceeds **9**, you MUST ask the user for confirmation before proceeding, explaining that this is to avoid overly large commits and difficult reviews.
3. **Implementation & Validation**:
    *   Apply code changes as described in the task's "Implementation Details".
    *   **Stability**: Ensure the system is in a buildable state. **No Build Errors** are allowed.
    *   **Verification**: Run relevant unit tests or verification steps if specified.
4. **Automatic Commit**:
    *   After successful implementation and validation, perform a git commit immediately.
    *   **Commit Message**: Follow the Conventional Commits format as specified in the `git-commit-helper` skill.
    *   **Authorization**: Perform the commit **without asking for further permission** as the user has pre-authorized this workflow.
5. **Status Update**:
    *   Update the "Status" column in the **Task progress table** of the plan document to `Review`.
    *   **Strict Constraint**: You are only allowed to modify the "Status" values. Any other modifications to the plan content require explicit user consent.
6. **Reporting**: Inform the user that the task(s) are completed and committed.

## Guidelines
- **Traditional Chinese**: Communicate with the user in Traditional Chinese.
- **Precision**: Adhere strictly to the "Implementation Details" provided in the task.
- **Failure Handling**: If a task cannot be completed due to technical constraints or logic contradictions, stop immediately and report the issue to the user. Do not attempt to guess or bypass errors.
