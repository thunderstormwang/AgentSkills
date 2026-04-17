---
name: sdlc-init
description: >
  Bootstrap a project with the SDLC skill suite. Checks whether copilot-instructions.md has
  the required Skill Variables section, prompts for missing values, injects them, copies
  master templates to spec/_templates/, and copies sdlc_workflow.md to .github/.
  Triggered by: "init sdlc", "setup project", "onboard project", "bootstrap sdlc",
  "initialize development workflow".
---

# Skill: SDLC Project Initialization

**Purpose**: Bootstrap any project to work with the SDLC skill suite (`feature-kickoff`, `implementation-completion`, `debug-investigation`, `requirements-realignment`, `status`). Ensures the project has the required configuration and templates for structured AI-assisted development.

---

## Execution Trigger

Activate this skill when the user:
- Says "init sdlc", "setup project", "onboard", "bootstrap sdlc"
- Opens a project that lacks `copilot-instructions.md` or its Skill Variables section
- Asks how to set up structured development workflow for a new project

---

## What This Skill Provides

After initialization, each project will have:

```
project/
├── .github/
│   ├── copilot-instructions.md   ← with Skill Variables section
│   └── sdlc_workflow.md          ← development philosophy & rules
└── spec/
    ├── _templates/
    │   ├── README.md
    │   ├── FEATURES/
    │   │   ├── feature-readme-template.md
    │   │   ├── requirements-template.md
    │   │   └── phase-progress-template.md
    │   └── PROCESS/
    │       └── IMPLEMENTATION_COMPLETION_REPORT_TEMPLATE.md
    ├── features/                 ← empty, filled by feature-kickoff
    └── BACKLOG.md                ← empty backlog
```

---

## Procedural Steps

### Step 1 — Check Existing State

Check which files already exist in the project:

```
.github/copilot-instructions.md    → exists? has "Skill Variables" section?
.github/sdlc_workflow.md           → exists?
spec/_templates/                   → exists? has all 4 templates?
spec/features/                     → exists?
spec/BACKLOG.md                    → exists?
```

Report findings to user before making changes.

---

### Step 2 — Gather Project Parameters

If `copilot-instructions.md` is missing or lacks a Skill Variables section, ask the user for these values:

| # | Parameter | Example | Required? |
|---|---|---|---|
| 1 | Service Name | `PXBox.BQProxy` | Yes |
| 2 | Service Description | CDC event processor for BigQuery | Yes |
| 3 | Build Command | `dotnet build MyProject.sln` | Yes |
| 4 | Run Command | `dotnet run --project src/MyApp` | Yes |
| 5 | Source Root | `src/` | Yes |
| 6 | Spec Directory | `spec/features/` | Yes (default: `spec/features/`) |
| 7 | Template Directory | `spec/_templates/` | Yes (default: `spec/_templates/`) |
| 8 | Entry Point | `src/MyApp/Program.cs` | Yes |
| 9 | Solution/Project File | `MyProject.sln` | Yes |
| 10 | Log Paths | `logs/` | Optional |
| 11 | Health Check | `GET /health_check` | Optional |
| 12 | CI/CD | `Drone (.drone.yml)` | Optional |

---

### Step 3 — Create or Update copilot-instructions.md

**If file does not exist**: Create `.github/copilot-instructions.md` with a minimal skeleton containing:
- Header with project name
- Skill Variables table (populated from Step 2)
- Copilot Skills table pointing to user-level skills
- Placeholder sections the user can fill in later

**If file exists but lacks Skill Variables**: Append the Skill Variables section at the end.

**If file exists and has Skill Variables**: Report "already initialized" and show current values. Ask if user wants to update any.

#### Skill Variables Section Format

```markdown
## Skill Variables

These values are referenced by SDLC skills in `~/.copilot/skills/`. Skills read this section to resolve project-specific details.

| Variable | Value |
|----------|-------|
| **Service Name** | {value} |
| **Service Description** | {value} |
| **Build Command** | {value} |
| **Run Command** | {value} |
| **Source Root** | {value} |
| **Spec Directory** | {value} |
| **Template Directory** | {value} |
| **Entry Point** | {value} |
| **Solution File** | {value} |
| **Log Paths** | {value} |
| **Health Check** | {value} |
| **CI/CD** | {value} |
```

#### Copilot Skills Section Format

```markdown
## Copilot Skills (Auto-Invoked SOPs)

Skills are invoked automatically based on the task type. They enforce structured processes.

| Skill | Trigger Keywords | SOP Enforced | Output |
|-------|-----------------|--------------|--------|
| **feature-kickoff** | "add feature", "implement X", "we need Y" | Verify facts → scaffold spec/ → present plan → wait for approval | Feature folder + implementation plan |
| **implementation-completion** | "done", "complete", "ready to test" | Build → assert 0 errors → create ICR | Build output + completion report |
| **debug-investigation** | "bug", "error", "broken", "not working" | Diagnose → propose fix → wait for approval → apply → verify | Structured diagnosis + fix |
| **requirements-realignment** | "requirements changed", "scope change", "plan changed" | Update requirements doc → update progress doc → add realignment log | Synced docs + realignment log entry |
| **status** | "status", "progress", "where are we" | Scan spec/ → report dashboard or sync status fields | Status dashboard or document sync report |

**Skill location**: `~/.copilot/skills/` (user-level, shared across all projects)
```

---

### Step 4 — Copy Templates

Copy the master templates from this skill's `templates/` directory to the project's `spec/_templates/`.

**For each template file**:
- If file does not exist → create it
- If file already exists → skip (do not overwrite customized templates)

Report which files were created vs skipped.

---

### Step 5 — Copy sdlc_workflow.md

Copy the master `sdlc_workflow.md` from this skill's `templates/` directory to `.github/sdlc_workflow.md`.

- If file does not exist → create it
- If file already exists → skip and inform user. Offer to show a diff if user wants.

---

### Step 6 — Create Spec Skeleton

If `spec/` doesn't exist:
- Create `spec/features/` directory
- Create `spec/BACKLOG.md` with empty table header

---

### Step 7 — Present Summary

```markdown
## SDLC Initialization Complete

### Created
- [ ] .github/copilot-instructions.md (Skill Variables injected)
- [ ] .github/sdlc_workflow.md
- [ ] spec/_templates/FEATURES/feature-readme-template.md
- [ ] spec/_templates/FEATURES/requirements-template.md
- [ ] spec/_templates/FEATURES/phase-progress-template.md
- [ ] spec/_templates/PROCESS/IMPLEMENTATION_COMPLETION_REPORT_TEMPLATE.md
- [ ] spec/BACKLOG.md

### Skipped (already exist)
- [ ] {list files that were skipped}

### Available Skills
All SDLC skills are loaded from ~/.copilot/skills/:
- feature-kickoff, implementation-completion, debug-investigation
- requirements-realignment, status

### Next Steps
- Review and customize copilot-instructions.md with project-specific sections
- Start your first feature: "add feature {name}"
```

---

## Rules

- ❌ **NEVER** overwrite existing files without explicit user approval
- ❌ **NEVER** delete existing content from copilot-instructions.md — only append
- ✅ Skip files that already exist (report as "skipped")
- ✅ Always show summary of what was created vs skipped
- ✅ If copilot-instructions.md already has Skill Variables, report "already initialized"
