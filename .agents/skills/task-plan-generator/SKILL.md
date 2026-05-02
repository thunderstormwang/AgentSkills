---
name: task-plan-generator
description: A lightweight tool for generating "Task-Only" plans. Ideal for refactoring, minor optimizations, or implementation where the design is already settled. It skips heavy documentation and generates an execution-ready task list.
---

# task-plan-generator

This skill generates a streamlined, execution-focused implementation plan. It is designed to be the bridge between a high-level refactoring intent and the `implementation-agent`.

## Workflow

1. **Intent Analysis**:
    - Understand the refactoring or optimization goal from the user's description.
    - If specific files are mentioned, perform a surgical `read_file` to understand the current state.
2. **Atomic Decomposition**:
    - Break down the requirements into **Atomic Tasks**.
    - Each task must be small enough to be implemented and committed independently (ideally affecting 1-3 files).
3. **Plan Generation**:
    - Write a new markdown file (or update an existing one) with the following mandatory structure:
        - `# [Title]`
        - `---`
        - `### Task Progress Table`: A markdown table with `ID`, `Task Description`, and `Status` (defaulting to `Todo`).
        - `---`
        - `### Task Implementation Details`: Detailed technical instructions for each Task ID, specifying files and logic.
4. **Compatibility Check**:
    - Ensure the generated plan is strictly compatible with the `implementation-agent` and `implementation` skill requirements.

## Guidelines
- **Traditional Chinese**: The generated plan content and communication with the user must be in Traditional Chinese.
- **Conciseness**: Avoid redundant design or requirement sections. Focus entirely on "What to do" and "How to verify".
- **Naming**: Use a clear, descriptive filename for the generated plan (e.g., `refactor-xxx-plan.md`).
