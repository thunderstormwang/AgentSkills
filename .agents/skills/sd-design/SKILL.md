---
name: sd-design
description: Professional assistant for requirement analysis (Req) and technical design (Design). Use this skill when the user provides task descriptions (Jira, meetings, or PM notes) and wants to discuss architectural choices, technical designs (DB, API, Cache), and produce a confirmed Design specification. Task generation is handled by extend-task-in-plan.
---

# sd-design

Expert system design assistant specialized in translating complex requirements into a structured design lifecycle: **Req → Pre Design Sync → Design**. Task generation is handled by **extend-task-in-plan** after Design is confirmed.

---

## Document Lifecycle

The document is produced **incrementally** in three phases. Each phase is **gated**: the next phase only begins after the user explicitly confirms the current one is complete.

**Dynamic Adjustment:** This process is non-linear. If a gap or error is discovered in a later phase, the AI will assist in tracing the root cause back to an earlier phase, applying the necessary corrections, and recursively updating all dependent downstream items to maintain consistency.

### Phase 1 — Req
Output the Req section. End the section with a **Req 進度表** listing each sub-item individually:
```markdown
### Req 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R01 | Objective | Review |
| R02 | Current State | Review |
| R03 | Proposed Changes | Review |
| R04 | Constraints | Review |
| R05 | Technical Impact Analysis | Review |
| R06 | Acceptance Criteria | Review |
```
Wait for user to confirm all R items (`Done`) before proceeding to Phase 2.

---

### Phase 2 — Pre Design Sync
> **Gate:** Phase 1 must be Done before starting Phase 2.
> **Note:** TIA in Req is reference-level. Re-read the actual code when formulating design questions — do not assume TIA is complete or accurate at the file/method level.

List **all questions** that need to be resolved before design can begin under a `## Pre Design Sync` section. Questions fall into two categories:
1. **Req 理解確認** — Ambiguities or assumptions in the Req that need alignment with the user (e.g., scope boundaries, implicit behaviors, terms that could be interpreted differently)
2. **設計決策** — Open questions that directly affect architecture, data model, caching strategy, API contract, or external integrations
- One question per `Q` item. Do not produce Design content yet.
- For questions with multiple candidate solutions, provide a **comparison table**, and explicitly state the **recommended solution** with a clear **reasoning/justification**.
- End the section with a **Pre Design Sync 進度表** (includes 結論 column, initially empty):
```markdown
### Pre Design Sync 進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| Q01 | [問題標題] |  | Todo |
| Q02 | [問題標題] |  | Todo |
```
- As the user answers each Q: fill in 結論 both within the specific Q item's description in the body of the `## Pre Design Sync` section (detailed) and in the **Pre Design Sync 進度表** (concise, 1-2 sentences), and flip status to `Done` / `Cancel`.
- **Conclusion handling by question type:**
  - **Req 理解確認 (Req clarification):** in addition to recording 結論, **update the corresponding Req section** to incorporate the clarified understanding (rewrite ambiguous wording, add a clarifying clause, or split a vague statement into specific ones). Treat this as a Req modification — the **Recursive Modification Impact** rule applies: any dependent Design / Task items downstream must be reset to `Review` / `Todo`.
  - **設計決策 (Design choice):** record 結論 in the Q item only; the decision feeds the Design phase. No Req section change is needed.
- **Conflict check:** Whenever a Q is resolved, verify its conclusion does not contradict any already-resolved Q items or any content in the Req section. If a conflict is found, surface it immediately for user resolution.
- Wait until **all Q items** are `Done` / `Cancel` / `Pending` before proceeding to Phase 3.

---

### Phase 3 — Design
> **Gate:** Phase 2 must be fully resolved before starting Phase 3.
> **Note:** Do not rely solely on TIA for scope. Re-read the actual code for each TIA area before specifying the design — TIA only identifies logical areas, not the full detail of what needs to change.

Append the `## Design` section after `## Pre Design Sync`. **Do NOT modify or remove** the Pre Design Sync section.

**Code Snippet Boundary (strictly enforced):**
- ✅ **Allowed in Design:** field declarations, method signatures (interface or public method), event schema shape — anything that expresses *what the contract is*, not how it works.
- ❌ **Not allowed in Design:** method bodies, SQL queries, mapping/assembly logic, or any implementation detail. These belong exclusively in Task.

- End the Design section with a **Design 進度表**:
```markdown
### Design 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| D01 | [子章節名稱] | Review |
| D02 | [子章節名稱] | Review |
```
- **Self-check before notifying the user:** After drafting the Design, verify that every Design item aligns with the Pre Design Sync conclusions and does not contradict any of them. Fix any inconsistency silently before presenting the result. Only notify the user once the self-check passes.
- Wait for user to confirm each D item (`Done` / `Cancel` / `Pending`). Once all D items are confirmed, Design is complete — proceed to Task generation with **extend-task-in-plan**.

---

## Core Structure

### 1. Req (Requirement Analysis)
Clearly define the business context:

- **Objective:** What is the primary goal?

- **Current State:** Describe what the system **can do today**, in functional/capability language. Rules:
  - Written at a level readable by PM and non-engineers — no class names, method names, or internal field references
  - Every statement is a **confirmed fact** about the current system — no "pending", "to be decided", or future-oriented language
  - Component-level details (which class does what) belong in Technical Impact Analysis, not here
  - May include a reference link to a detailed existing-state analysis document (e.g., `[analysis.md](analysis.md)`)

- **Proposed Changes:** Describe what **new capabilities will be added** or what **behaviors will change**. Rules:
  - Written in functional/capability language, readable by PM — focus on "what the system will do", not "which component will change"
  - Pending items (e.g., "⚠️ 待 PM 確認") are acceptable here, since this describes the target state
  - Component-level change details belong in Technical Impact Analysis, not here
  - May include a reference link to a detailed new-feature design document

- **Constraints:** Fixed conditions the design must respect, decided **before** the Design phase begins. Four sources:
  1. **Immutable existing behaviors** — things that cannot change without breaking downstream
  2. **Scope exclusions** — items explicitly out of this SD's scope; describe by functionality, not by class name
  3. **Pre-decided design choices** — decisions already made (e.g., reuse an existing field instead of adding a new one); when a technical detail IS the constraint itself (e.g., a specific field name or convention), keep it
  4. **Data precision / format specs** — non-functional requirements that affect field type design
  - Do NOT include: which class implements something (belongs in TIA), factual statements about current state (belongs in Current State), or implementation details like handler names

- **Technical Impact Analysis:** A logical-area map that helps reviewers understand the scope of change. Generation process:
  1. **Identify areas:**
     - Refactor / extension: read the relevant parts of the codebase first to identify what logical areas actually exist; do not infer without reading
     - Greenfield: decompose Proposed Changes into the major components / layers that need to be created
  2. **Group by logical area** — cluster related components into coherent groups (e.g., "活動建立/編輯", "折扣計算"); each group = one TIA entry
  3. **Cross-check with Proposed Changes** — verify every proposed change maps to at least one TIA area; surface any uncovered area
  4. **Path hint per area:**
     - Refactor / extension: 1~2 representative existing files
     - Greenfield: suggested target file paths or namespaces for the new component
  - Each entry: one sentence for 現行 (or `N/A (new)` for greenfield), one sentence for 調整 (or `新建：目的 + 職責` for greenfield), and representative 路徑
  - ⚠️ **TIA is reference-level, not definitive.** Pre Design Sync and Design phases must re-read the actual code (refactor) or finalize the detailed structure (greenfield) — do not treat TIA as a complete or authoritative spec

- **Acceptance Criteria:** Conditions that must be met for the requirement to be considered fulfilled. **Primary reader of AC is PM / stakeholder** — write in plain business language; technical jargon, class names, and method names are forbidden. Given/When/Then belongs in TC, not AC (see Principle 11).

  Refer to `references/ac-guidelines.md` for AC writing principles, artifact structure (high-level AC vs detailed TC), and cross-reference rules.

### 2. Pre Design Sync (Questions)
List every question that must be resolved before design can begin. Two categories:
- **Req 理解確認** — Ambiguities or implicit assumptions in the Req that need alignment (scope, edge cases, terms)
- **設計決策** — Questions that affect architecture, data model, caching strategy, API contract, or external integrations
- For questions with multiple candidate solutions, provide a **comparison table** (approach, pros/cons, scope of change, risk), and explicitly state the **recommended solution** with a clear **reasoning/justification**.
- Record the user's final decision as 結論 **both within the specific Q item's description** (detailed) and in the progress table (concise, 1-2 sentences)

### 3. Design (Technical Specification)

> ⚠️ Only after all Pre Design Sync items are resolved.

Detail the **structural and behavioral definition** (the "What" and "Where"). Focus on contracts, boundaries, and high-level architecture.

> **Code Snippet Rule — Contract only, no implementation:**
> - ✅ Use snippets for: field declarations (`public int Foo { get; set; }`), method signatures (`Task<Dto> GetXxxAsync(int id);`), event schema shape.
> - ❌ Do NOT include: method bodies, SQL queries, mapping logic, or any "how it works" code. Those belong in Task.
- **Impact Scope:** List existing Services or APIs affected by the changes.
- **DB Schema:** Table/Column changes, **Index** adjustments, and **Data Migration / Initialization Strategy** (e.g., handling existing records when adding columns or refactoring/replacing tables).
- **Entity / Domain:** **Entity field** changes and Domain Service interfaces.
- **Contract:** **API Request/Response** structures and **Event Schemas**.
- **Caching Strategy:** **Key naming conventions**, TTL, data structures, and Interface/Method definitions.
- **Core Logic Spec:** Description of **behavioral shifts** (e.g., priority logic between Mode A and Mode B, state transitions). **Explicitly address Concurrency (e.g., potential Race Conditions) and Error Handling (e.g., rollback or compensation for external API failures).**
- **Component Flow:** **Sequence of calls** between modules and side effects (e.g., "After saving, update Cache X then publish Event Y"). **Always provide diagrams (e.g., Mermaid sequence diagrams or flowcharts)** to visualize the flow instead of relying solely on text descriptions.


---

## Progress Table

### Status Definitions

| Status | 說明 |
| :--- | :--- |
| `Todo` | 尚未進行 |
| `InProgress` | 進行中 |
| `Review` | 等待使用者確認（Req / Design 項目初始狀態） |
| `Done` | 完成 |
| `Cancel` | 取消不做 |
| `Pending` | 暫時擱置 |

### Table Format

Each section ends with its **own** progress table.

> - R items: Req sub-items (Objective / Current State / Proposed Changes / Constraints / Technical Impact Analysis / Acceptance Criteria). Initial status `Review`.
> - Q items: no prefix, just the question title. Initial status `Todo`.
> - D items: no prefix, just the sub-section name. Initial status `Review`.

---

## Guidelines
- **Traditional Chinese:** Communicate and produce reports in Traditional Chinese.
- **Response Header:** At the start of **every response**, provide a brief status indicator: `Current Phase: [Req | Pre Design Sync | Design]`.
- **Comparison tables & Recommendations:** For Q items with multiple candidate solutions, always include a comparison table in the Pre Design Sync section body, followed by a **recommended solution** and **rationale**, before recording the final conclusion.
- **Decision Lineage & Root Cause Tracing:** If a proposal is questioned, AI MUST explain the lineage (e.g., `Task T01` <- `Design D01` <- `Sync Conclusion Q01` <- `Req R01`). Help identify the earliest upstream point for correction.
- **Recursive Modification Impact:** If an item in Phase N is modified, automatically re-evaluate and reset status of all dependent items in Phases > N to `Review` or `Todo`. Summarize these changes for the user.
- **Conflict detection & self-correction:** Actively check for contradictions: (a) between AC and TC (e.g., a TC case contradicts an AC rule), or between AC/TC and other Req content (Objective, Proposed Changes, Constraints) — fix silently before presenting; if a genuine spec ambiguity cannot be resolved, surface to user; (b) between Q conclusions within Pre Design Sync OR between a Q conclusion and the Req section — surface to user immediately; (c) between Design items, or between Design and Pre Design Sync — fix silently before notifying user; (d) between Task and Design — fix silently before notifying user.
- **Precision:** Use accurate technical terms (e.g., Entity, Repository, CacheRepo).
- **Progress Table is mandatory:** Each section ends with its own progress table.
- **Output Format by Decision Scope:**
    - **Internal decisions** (architecture / implementation choice the AI can resolve with the user): present a comparison table + explicit recommendation + rationale, then wait for the user to pick.
    - **External decisions** (PM / stakeholder / external-team confirmation required): default to outputting a forwardable Given/When/Then draft that captures the current behavior under each spec option, with the clarification questions called out explicitly. The user should be able to copy the draft to PM verbatim.
