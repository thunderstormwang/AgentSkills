---
name: implementation
description: Executes specific implementation tasks defined in a plan document (e.g., plan.md). Use this skill when the user specifies which Task IDs to implement. It handles code changes, validation, automatic git commits, and updates the task status in the plan document.
---

# implementation

A specialized engine for the autonomous execution of development tasks. It transforms high-level plan items into verified code changes with atomic, pre-authorized commits.

## Workflow (The Atomic Execution Loop)

For each assigned Task ID, the skill MUST follow this sequence:

1. **Context & Status Initialization**:
    - **Status Change**: Update the "Status" of the Task in the plan's task progress table to `InProgress`. **Do not commit this change yet.**
    - **Auto-Style Injection**: Immediately call `activate_skill("coding-style")` to load relevant standards for the project's technology stack.
2. **Implementation (Act)**:
    - Apply code changes strictly following the "Implementation Details" and "Approach" in the plan.
    - Maintain architectural integrity as defined in the loaded coding styles.
3. **Verification (Validate)**:
    - **Build Check**: Execute the project's build command. The system **MUST NOT** have build errors.
    - **TDD Logic**:
        - If the Task is for **"Writing Tests"**: Validation succeeds if the code builds, even if tests fail (Red state).
        - If the Task is for **"Implementation"**: Validation succeeds only if the code builds AND relevant tests pass (Green state).
    - **Self-Correction**: If validation fails unexpectedly, attempt to diagnose and fix the error within the current loop.
4. **Halt Condition (Fail-Safe)**:
    - STOP ALL subsequent tasks and notify the user immediately if:
        - A build error persists after a repair attempt.
        - The plan refers to files, classes, or methods that do not exist in the codebase.
        - New dependencies are required but not authorized in the plan.
        - A single Task affects more than 9 files (Atomic design safety threshold).
5. **Atomic Commit (Finalize)**:
    - **Status Finalization**: Update the Task status in the plan from `InProgress` to `Review`.
    - **Single Commit**: Stage both the **Code Changes** and the **Plan Update** (Status: Review).
    - **Commit Message**: Use `git-commit` to generate a message following Conventional Commits.
        - **Requirement**: The Header MUST include the Task ID (e.g., `feat(auth): (T1) implement login logic`).
    - **No Confirmation**: Execute the commit **without asking for permission**, as this workflow is pre-authorized.
6. **Iteration**:
    - Repeat from Step 1 for the next Task ID until all assigned tasks are complete or a Halt Condition is met.

## Guidelines
- **Traditional Chinese**: Communicate with the user in Traditional Chinese.
- **Atomicity**: One Task ID = One Commit. The commit MUST contain the task status update to `Review`.
- **Minimal Intervention**: Aim for full autonomy; only request user intervention when the Fail-Safe conditions are met.
