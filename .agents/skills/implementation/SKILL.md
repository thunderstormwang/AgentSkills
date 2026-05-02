---
name: implementation
description: Executes specific implementation tasks defined in a plan document (e.g., plan.md). Use this skill when the user specifies which Task IDs to implement. It handles code changes, validation, automatic git commits, and updates the task status in the plan document.
---

# implementation

A specialized engine for the autonomous execution of development tasks. It transforms high-level plan items into verified code changes with atomic commits.

## Workflow (The Atomic Execution Loop)

For each assigned Task ID, the skill MUST follow this strict sequence:

1. **Context Initialization**:
    - Identify the target files and technology stack (e.g., C#, Python, TypeScript).
    - **Auto-Style Injection**: Immediately call `activate_skill("coding-style")` to load relevant standards for the detected stack. DO NOT skip this step.
2. **Implementation (Act)**:
    - Apply surgical code changes strictly following the "Implementation Details" and "Approach" in the plan.
    - Maintain architectural integrity as defined in the loaded coding styles.
3. **Verification (Validate)**:
    - **Build Check**: Execute the project's build command (e.g., `dotnet build`, `npm run build`). The system MUST be in a buildable state.
    - **Test Check**: Run specific unit tests or verification scripts mentioned in the plan.
    - **Self-Correction**: If validation fails, attempt to diagnose and fix the error within the current loop.
4. **Halt Condition (Fail-Safe)**:
    - STOP ALL subsequent tasks and notify the user immediately if:
        - A build error persists after a repair attempt.
        - A critical logic contradiction is discovered in the plan.
        - A single Task affects more than 9 files (Safety threshold for atomic design).
5. **Atomic Commit (Finalize)**:
    - Perform a git commit **only after** successful validation.
    - **Dual-Source Synthesis**: Call `git-commit` to generate a message that synthesizes the **Plan Intent** (from the task description) with the **Physical Reality** (from `git diff`).
    - **Authorization**: Execute the commit without further confirmation (Pre-authorized by the agent workflow).
6. **Progress Tracking**:
    - Update the "Status" column in the plan's task table to `Review`.
    - If it's the first task in a batch, you may set it to `InProgress` during execution.

## Guidelines
- **Traditional Chinese**: Communicate with the user in Traditional Chinese.
- **Atomicity**: One Task ID = One Commit. Never combine multiple tasks into a single commit.
- **Dependency Awareness**: Tasks must be executed in the order defined in the plan to respect logical dependencies.
- **Minimal Intervention**: Aim for full autonomy; only request user intervention when the Fail-Safe conditions are met.
