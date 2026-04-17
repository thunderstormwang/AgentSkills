---
name: status
description: >
  Project status dashboard and document sync tool. Two modes:
  (1) `status` — show service summary, active features, progress, blockers, and next steps.
  (2) `update_status` — scan all spec/features/ docs and sync every status field to match
  actual progress, fixing stale data. Enforces the Status Convention defined below.
  Keywords: status, progress, where are we, what's next, update status, sync status, dashboard.
---

# Skill: Project Status & Document Sync

**Purpose**: Provide a single-command project status dashboard and keep all development documents up-to-date — eliminating stale status fields that mislead developers.

---

## Execution Trigger

Activate this skill when the user:
- Asks for status ("status", "where are we", "what's next", "progress")
- Asks to update or sync documents ("update_status", "sync status", "update all docs")
- Asks what's going on in the project

---

## Status Convention (MANDATORY for all spec/ documents)

All documents under `spec/features/` MUST use the following standardized fields and values.

### Feature Status (README.md header table)

| Status | Emoji | Meaning |
|--------|-------|---------|
| Planning | 🟡 | Requirements gathering, architecture decisions pending |
| Blocked | 🔴 | Cannot proceed — dependency or decision needed |
| In Progress | 🔵 | Active implementation work underway |
| Review | 🟣 | Code complete, awaiting review or testing |
| Complete | ✅ | Delivered and verified |
| Abandoned | ⚫ | Cancelled or superseded |

Format in README.md:
```markdown
| **Status** | 🔵 In Progress |
| **Phase** | Phase 1: Manual Offset Commit |
| **Updated** | YYYY-MM-DD |
```

### Requirement Status (requirements .md tables)

| Symbol | Meaning |
|--------|---------|
| ⬜ | Not started |
| 🔲 | Blocked / waiting on dependency |
| 🔧 | In progress |
| ✅ | Implemented |
| ❌ | Dropped / won't do |
| ⏸️ | Deferred — tracked in backlog, not dropped |

### Architectural Decision Status

| Symbol | Meaning |
|--------|---------|
| ❓ | Undecided |
| ✅ | Decided |
| 🔄 | Revisiting |

Format: Add status inline to each AD heading:
```markdown
### AD-1: [Decision Title] ❓
```

### TBD Item Status

| Symbol | Meaning |
|--------|---------|
| ❓ | Unanswered |
| ✅ | Resolved |
| ❌ | No longer relevant |

Format:
```markdown
1. **TBD-1** ❓: [Open question description] — ...
```

### Phase Status

| Symbol | Meaning |
|--------|---------|
| ⬜ | Not started |
| 🔵 | Active |
| ✅ | Complete |
| 🔴 | Blocked |
| ⏸️ | Deferred — moved to backlog |

Format in requirements:
```markdown
### Phase 1: Manual Offset Commit 🔵
```

---

## Mode 1: `status` — Read-Only Dashboard

### Procedure

1. **Service Summary**: Read `copilot-instructions.md` for service purpose. Output one sentence.

2. **Active Features**: Scan `spec/features/*/README.md` for all feature folders.
   - Parse the Status, Phase, and Updated fields from each README.md header table.
   - List features sorted by status priority: 🔴 Blocked → 🔵 In Progress → 🟡 Planning → 🟣 Review → ✅ Complete.

3. **For each active feature** (not ✅ Complete or ⚫ Abandoned):
   - Parse `FEAT-NNN-requirements.md`:
     - Count requirements by status (⬜/🔧/✅/❌/🔲)
     - Identify current active phase
     - List open TBDs (❓ only)
     - List undecided ADs (❓ only)
   - Check `IMPLEMENTATION_COMPLETION_REPORT.md` existence → indicates phase completion.

4. **Backlog**: If `spec/BACKLOG.md` exists, read and list all ⏸️ Deferred items (the table under "Deferred Items").
   - Output each row: ID, Item summary, Source feature, Priority.
   - Skip rows where the item column is `—`.

5. **Blockers**: Collect all 🔴 and 🔲 items across all features.

6. **Git Context** (optional, when available):
   - Current branch: `git branch --show-current`
   - Uncommitted changes: `git status --short | head -10`
   - Last commit: `git log --oneline -1`

7. **Output Format**:

```markdown
## 📊 Project Status — {Service Name}

**Service**: {one-line description}
**Branch**: `{branch}` | Last commit: `{hash} {message}`

### Active Features

#### FEAT-001: {name} 🔵 In Progress
- **Phase**: Phase 1: Manual Offset Commit 🔵
- **Requirements**: 3/10 ✅ | 2/10 🔧 | 5/10 ⬜
- **Open TBDs**: TBD-1, TBD-2, TBD-3
- **Undecided ADs**: AD-1, AD-3
- **Next Step**: {inferred from first ⬜ requirement or first active phase}
- **Updated**: {date from README}

### ⚠️ Blockers
- {List any 🔴 / 🔲 items with their source document}

### � Backlog
- B-001: {item summary} | Source: {feature} | Priority: {priority}
- *(empty if no deferred items)*

### �🔍 Staleness Check
- {List any document where Updated date is > 7 days old}
- {List any document where status fields appear inconsistent}
```

---

## Mode 2: `update_status` — Document Sync

### Procedure

1. **Scan all feature folders**: `ls spec/features/*/`

2. **For each feature**, read and validate:
   - `README.md` — header table has Status, Phase, Updated fields
   - `FEAT-NNN-requirements.md` — all status symbols are from the convention
   - Check for `IMPLEMENTATION_COMPLETION_REPORT.md` presence

3. **Check `spec/BACKLOG.md`**: If it exists, read and list all ⏸️ Deferred items. Ask if any should be re-activated (moved back to a feature phase) or marked completed.

4. **Ask the user** for each feature:
   Present current status and ask what needs updating. Example:
   ```
   FEAT-001: CDC Retry & Resend
   Current: 🟡 Planning | Phase: N/A | Updated: 2026-03-11
   
   What is the current status?
   a) 🟡 Planning (no change)
   b) 🔵 In Progress — which phase?
   c) 🔴 Blocked — what's blocking?
   d) Other
   ```

5. **For requirement items**: Ask user to confirm changes for any items the user mentions. Don't force review of every single item unless user requests "full audit".

6. **Update all documents atomically**:
   - Set `Updated` date to today
   - Set Status, Phase to user's answers
   - Update requirement status symbols as confirmed
   - Update AD/TBD status if user resolved any
   - If a phase is deferred: set phase symbol to ⏸️, add row to `spec/BACKLOG.md`, set feature Status to ✅ Complete if all other phases are done

7. **Report what changed**:
   ```markdown
   ## 📝 Status Update Summary
   
   | Document | Field | Old | New |
   |----------|-------|-----|-----|
   | FEAT-001 README | Status | 🟡 Planning | 🔵 In Progress |
   | FEAT-001 README | Phase | N/A | Phase 1: Manual Offset Commit |
   | FEAT-001 Requirements | FR-01 | ⬜ | 🔧 |
   ```

---

## Quick Update Shorthand

Users can use shorthand to skip the interactive flow:

```
update_status FEAT-001 status=in-progress phase="Phase 1" FR-01=done TBD-1=resolved
```

Mapping: `done` → ✅, `wip` → 🔧, `blocked` → 🔲, `dropped` → ❌, `resolved` → ✅, `deferred` → ⏸️

---

## Rules

- ❌ **NEVER** guess status — always read from documents or ask the user
- ❌ **NEVER** leave `Updated` date stale after modifying a document
- ✅ Always set `Updated` to today's date when modifying any status field
- ✅ Flag documents where `Updated` is > 7 days behind current date as potentially stale
- ✅ When `update_status` completes, run `status` to show the result
- ✅ Use the **Status Convention** symbols only — no freeform status text

---

## Integration with Other Skills

| Skill | When status should update |
|-------|--------------------------|
| **feature-kickoff** | After scaffold: set Status = 🟡 Planning, Updated = today |
| **implementation-completion** | After ICR: set Status = 🟣 Review or ✅ Complete, Updated = today |
| **debug-investigation** | If bug blocks a feature: set relevant feature Status = 🔴 Blocked |

> These transitions are now enforced in each skill's procedural steps — `feature-kickoff` (Step 5), `implementation-completion` (Step 7), and `debug-investigation` (Step 8).
