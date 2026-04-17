# FEAT-{NNN} Phase {N}: {Phase Name} — Progress

**Feature**: FEAT-{NNN} {Feature Name}
**Phase**: {N}
**Status**: 🔵 In Progress | ✅ Complete
**Started**: YYYY-MM-DD
**Updated**: YYYY-MM-DD

---

## Phase Goal

{One sentence — what this phase delivers when all 4 steps are done.}

## FR Scope

| FR | Description | Status |
|---|---|---|
| FR-N | {title} | ⬜ / 🔧 / ✅ |

---

## Step Progress

### Step 1 — Core Behavior ⬜

**Completed**: YYYY-MM-DD
**Build**: {0 errors | N errors}
**Tests**: {N/N passing}

#### Files Created

| File | Role |
|---|---|
| `path/to/file.cs` | {one-line purpose} |

#### Files Modified

| File | Change |
|---|---|
| `path/to/file.cs` | {what changed} |

#### Key Decisions

- {Any non-trivial implementation choice made during this step}

#### Verification

```
dotnet build → 0 errors
dotnet test → N/N passing
```

---

### Step 2 — Integration ⬜

*(Same structure as Step 1)*

---

### Step 3 — Resilience ⬜

*(Same structure as Step 1)*

---

### Step 4 — Observability ⬜

*(Same structure as Step 1)*

---

## Rollback Plan

{How to undo this phase if needed — e.g., "Remove DDL topic subscription from Program.cs; no data path changes."}

## Notes

{Anything useful for the next session — gotchas encountered, open questions raised during implementation, things to watch for.}
