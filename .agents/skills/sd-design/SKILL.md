---
name: sd-design
description: Professional assistant for requirement analysis (Req) and technical design (Design). Use this skill when the user provides task descriptions (Jira, meetings, or PM notes) and wants to discuss architectural choices, technical designs (DB, API, Cache), and produce a confirmed Design specification. Task generation is handled by gen-task-in-plan.
---

# sd-design

Expert system design assistant specialized in translating complex requirements into a structured design lifecycle: **Req → Pre Design Sync → Design**. Task generation is handled by **gen-task-in-plan** after Design is confirmed.

---

## Document Lifecycle

The document is produced **incrementally** in three phases. Each phase is **gated**: the next phase only begins after the user explicitly confirms the current one is complete.

**Dynamic Adjustment:** This process is non-linear. If a gap or error is discovered in a later phase, the AI will assist in tracing the root cause back to an earlier phase, applying the necessary corrections, and recursively updating all dependent downstream items to maintain consistency.

### Phase 1 — Req
Req may begin from incomplete input. Do not manufacture a complete specification from an objective or a few task bullets.

1. **Build the draft from confirmed information.**
   - Preserve the user's source wording and distinguish confirmed facts from assumptions.
   - Investigate what code and data can answer, especially Current State and requirement gaps.
   - When the investigation is substantial, keep the evidence in supporting documents such as `{ticket}_現況查核.md` or `{ticket}_落差與待確認.md`, then link them from Req.
2. **Clarify requirement gaps inside Req.**
   - Add a `### Req 待確認事項` subsection when an unknown affects scope, target behavior, constraints, or acceptance criteria.
   - Give each question an `RQ` ID (`RQ01`, `RQ02`, ...). Do not move requirement ambiguity into Pre Design Sync.
   - When the user answers an RQ, record the conclusion and immediately update every affected Req item. Remove tentative wording that the answer has resolved.
   - If the answer must come from a PM, stakeholder, or external team, provide a forwardable Given/When/Then clarification draft.
3. **Establish the Req baseline.**
   - An incomplete R item stays `Todo` or `InProgress`; set it to `Review` only when its content is complete enough for user confirmation.
   - When all blocking RQs are resolved and all five R items are ready, ask the user to confirm the complete Req. Only confirmed R items become `Done`.

When RQs exist, include a progress table for them:
```markdown
### Req 待確認事項進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| RQ01 | [需求問題] |  | Todo |
```

End the Req section with a **Req 進度表** listing each sub-item individually. Status reflects actual completeness; do not initialize every item to `Review` automatically:
```markdown
### Req 進度表
| ID | 項目 | 狀態 |
| :--- | :--- | :--- |
| R01 | Objective | Review |
| R02 | Current State | InProgress |
| R03 | Proposed Changes | InProgress |
| R04 | Constraints | Todo |
| R05 | Acceptance Criteria | Todo |
```
The statuses above are illustrative, not fixed defaults. Do not proceed to Phase 2 until all blocking RQs are resolved and all R items are `Done`.

---

### Phase 2 — Pre Design Sync
> **Gate:** Phase 1 must be Done before starting Phase 2.
> **Note:** Re-read the actual code when formulating design questions. Req describes the business baseline, not the implementation structure.

List all unresolved **design decisions** under a `## Pre Design Sync` section. These questions directly affect architecture, data model, caching strategy, API contract, internal component structure, or external integrations.
- Do not use Pre Design Sync to complete requirement understanding. Scope boundaries, intended behavior, terminology, and acceptance expectations must already have been resolved as RQs in Phase 1.
- If code investigation exposes a new requirement ambiguity, stop the design discussion, add or reopen the corresponding RQ and Req items, resolve and reconfirm Req, then resume Pre Design Sync. This is backward correction, not a normal Pre Design Sync question.
- One question per `DQ` item (`DQ01`, `DQ02`, ...). Do not produce Design content yet.
- For questions with multiple candidate solutions, provide a **comparison table**, and explicitly state the **recommended solution** with a clear **reasoning/justification**.
- **Pre Design Sync artifact routing:**
  - Keep the main plan's `## Pre Design Sync` section as the authoritative index for DQ IDs, concise conclusions, statuses, and the Phase 2 gate.
  - When numerous DQs, investigation evidence, comparison tables, or discussion history would make the main plan difficult to navigate, move the detailed DQ bodies into `{ticket}_pre_design_sync.md` in the same directory.
  - In the main plan, retain every DQ ID and title, its concise conclusion and status, and a link to the supporting document. In the supporting document, preserve the same DQ IDs and record each question's context, evidence, options, recommendation, discussion, and detailed conclusion.
  - The supporting document is not a separate lifecycle phase. Do not split merely to reduce line count; split when it improves readability while preserving decision lineage.
- End the section with a **Pre Design Sync 進度表** (includes 結論 column, initially empty):
```markdown
### Pre Design Sync 進度表
| ID | 項目 | 結論 | 狀態 |
| :--- | :--- | :--- | :--- |
| DQ01 | [問題標題] |  | Todo |
| DQ02 | [問題標題] |  | Todo |
```
- As the user answers each DQ: fill in 結論 both within the specific DQ item's detailed body (in the main plan or the supporting document) and in the main plan's **Pre Design Sync 進度表** (concise, 1-2 sentences), and flip status to `Done` / `Cancel`.
- **Conflict check:** Whenever a DQ is resolved, verify its conclusion does not contradict any already-resolved DQ items or any content in the Req section. If a conflict is found, surface it immediately for user resolution.
- Wait until **all DQ items** are `Done` / `Cancel` / `Pending` before proceeding to Phase 3.

---

### Phase 3 — Design
> **Gate:** Phase 2 must be fully resolved before starting Phase 3.
> **Note:** Re-read the actual code for each design concern before specifying the design. Do not infer implementation structure from Req alone.

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
- Wait for user to confirm each D item (`Done` / `Cancel` / `Pending`). Once all D items are confirmed, Design is complete — proceed to Task generation with **gen-task-in-plan**.

---

## Core Structure

### 1. Req (Requirement Analysis)
Clearly define the business context:

- **Objective:** What is the primary goal?

- **Current State:** Describe what the system **can do today**, in functional/capability language. Rules:
  - Written at a level readable by PM and non-engineers — no class names, method names, or internal field references
  - Every statement is a **confirmed fact** about the current system — no "pending", "to be decided", or future-oriented language
  - Keep component-level investigation details in a supporting existing-state document or the later Design section, not here
  - May include a reference link to a detailed existing-state analysis document (e.g., `[analysis.md](analysis.md)`)

- **Proposed Changes:** Describe what **new capabilities will be added** or what **behaviors will change**. Rules:
  - Written in functional/capability language, readable by PM — focus on "what the system will do", not "which component will change"
  - Pending items (e.g., "⚠️ 待 PM 確認") are acceptable here, since this describes the target state
  - Component-level change details belong in Design, not here
  - May include a reference link to a detailed new-feature design document

- **Constraints:** Fixed conditions the design must respect, decided **before** the Design phase begins. Four sources:
  1. **Immutable existing behaviors** — things that cannot change without breaking downstream
  2. **Scope exclusions** — items explicitly out of this SD's scope; describe by functionality, not by class name
  3. **Pre-decided design choices** — decisions already made (e.g., reuse an existing field instead of adding a new one); when a technical detail IS the constraint itself (e.g., a specific field name or convention), keep it
  4. **Data precision / format specs** — non-functional requirements that affect field type design
  - Do NOT include: which class implements something (belongs in Design), factual statements about current state (belongs in Current State), or implementation details like handler names

- **Acceptance Criteria:** Conditions that must be met for the requirement to be considered fulfilled. **Primary reader of AC is PM / stakeholder** — write in plain business language; technical jargon, class names, and method names are forbidden. Given/When/Then belongs in TC, not AC (see Principle 11).

  Refer to `references/ac-guidelines.md` for AC writing principles, artifact structure (high-level AC vs detailed TC), and cross-reference rules.

#### Req Clarification

When the supplied information cannot support a complete and trustworthy Req, keep the uncertainty in Phase 1:
- Investigate questions answerable from code, data, or existing documents instead of asking the user to restate discoverable facts.
- Create one `RQ` item per requirement ambiguity that needs human confirmation.
- State which R items each RQ blocks or may change.
- After resolution, record the conclusion and rewrite the affected R items so the Req contains the final understanding rather than a history of uncertainty.
- Do not advance to Pre Design Sync while a blocking RQ remains unresolved. A `Pending` RQ may remain only when it is explicitly non-blocking and its exclusion or assumption is recorded in Req.

### 2. Pre Design Sync (Questions)
List every **design decision** that must be resolved before design can begin. These questions affect architecture, data model, caching strategy, API contract, internal component structure, or external integrations.
- Requirement ambiguities do not belong here. If one is discovered, return it to Req as an `RQ`, update the affected R items, and reconfirm the Req baseline before continuing.
- For questions with multiple candidate solutions, provide a **comparison table** (approach, pros/cons, scope of change, risk), and explicitly state the **recommended solution** with a clear **reasoning/justification**.
- Record the user's final decision as 結論 **both within the specific DQ item's detailed body** (in the main plan or supporting document) and in the main plan's progress table (concise, 1-2 sentences)
- Apply the Phase 2 artifact-routing rule when detailed DQ content would overwhelm the main plan; the main plan remains the authoritative index and gate.

### 3. Design (Technical Specification)

> ⚠️ Only after all Pre Design Sync items are resolved.

Detail the **structural and behavioral definition** (the "What" and "Where"). Focus on contracts, boundaries, and high-level architecture.

> **Code Snippet Rule — Contract only, no implementation:**
> - ✅ Use snippets for: field declarations (`public int Foo { get; set; }`), method signatures (`Task<Dto> GetXxxAsync(int id);`), event schema shape.
> - ❌ Do NOT include: method bodies, SQL queries, mapping logic, or any "how it works" code. Those belong in Task.

**Design artifact routing:**
- Keep the main plan as the authoritative summary of confirmed design decisions.
- When one design concern needs substantial detail — such as a dependency diagram, several collaborating services/classes, responsibility reassignment, method relocation/removal, or a long file-impact list — move that detail into a dedicated document named `{ticket}_{service}_類別結構設計.md`.
- In the main plan, retain only the affected components, one-sentence responsibilities, key boundaries, and a link to the dedicated document. The dedicated document is supporting detail, not a new lifecycle phase; its conclusion remains represented by the corresponding `D` item in the main plan.
- Keep ownership and dependency decisions in **Internal Component Structure**. Keep behavioral rules, ordering, early returns, state transitions, concurrency, and failure handling in **Core Logic Spec**. Cross-reference instead of duplicating either side.

- **Impact Scope:** List existing Services or APIs affected by the changes.
- **DB Schema:** Table/Column changes, **Index** adjustments, and **Data Migration / Initialization Strategy** (e.g., handling existing records when adding columns or refactoring/replacing tables).
- **Domain Model:** Entity / Value Object / Enum changes, relationships, and domain invariants. Do not put service interfaces, class responsibilities, dependency direction, or orchestration here. Omit this item when no domain-model change exists.
- **Contract:** **API Request/Response** structures and **Event Schemas**.
- **Caching Strategy:** **Key naming conventions**, TTL, data structures, and Interface/Method definitions.
- **Core Logic Spec:** Description of **behavioral shifts** (e.g., priority logic between Mode A and Mode B, state transitions). **Explicitly address Concurrency (e.g., potential Race Conditions) and Error Handling (e.g., rollback or compensation for external API failures).**
- **Internal Component Structure:** Internal service/class responsibilities, dependency direction, public or interface method signatures, DI boundaries, and existing methods or responsibilities that move or disappear. Domain Services belong here because this item answers **which component owns the behavior**, while Core Logic Spec answers **how the behavior must work**. Use the dedicated class-structure document rule above when this item would dominate the main plan.
- **Component Flow:** **Sequence of calls** between modules and side effects (e.g., "After saving, update Cache X then publish Event Y"). **Always provide diagrams (e.g., Mermaid sequence diagrams or flowcharts)** to visualize the flow instead of relying solely on text descriptions.
- **Test Plan:** Identify what needs to be tested and where. Rules:
  - TC details go in a **separate `{ticket}_tc.md` file** in the same directory as the plan — never inline in the plan.
  - The Test Plan section contains: test target, test framework, new test file path, and a link to the TC file (`[{ticket}_tc.md]({ticket}_tc.md)`).
  - AC in Req does **NOT** reference the TC file. The Test Plan section in Design is the sole entry point to the TC file.
  - Omit this section only if the change has no new or modified testable logic (e.g., pure documentation, config-only changes).

  Refer to `references/ac-guidelines.md` for TC writing principles (Given/When/Then format, ID format, terminology mapping, and cross-reference rules).


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

> - R items: Req sub-items (Objective / Current State / Proposed Changes / Constraints / Acceptance Criteria). They begin as `Todo` / `InProgress` / `Review` according to actual completeness; only user-confirmed items become `Done`.
> - RQ items: requirement clarification questions inside Req. Initial status `Todo`.
> - DQ items: design decisions inside Pre Design Sync. Initial status `Todo`.
> - D items: no prefix, just the sub-section name. Initial status `Review`.

---

## Guidelines
- **Traditional Chinese:** Communicate and produce reports in Traditional Chinese.
- **Response Header:** At the start of **every response**, provide a brief status indicator: `Current Phase: [Req | Pre Design Sync | Design]`.
- **Comparison tables & Recommendations:** For internal design-decision DQ items with multiple candidate solutions, always include a comparison table in the Pre Design Sync section body, followed by a **recommended solution** and **rationale**, before recording the final conclusion.
- **Decision Lineage & Root Cause Tracing:** If a proposal is questioned, AI MUST explain the lineage (e.g., `Task T01` <- `Design D01` <- `Sync Conclusion DQ01` <- `Req R03` <- `RQ02`). Help identify the earliest upstream point for correction.
- **Recursive Modification Impact:** If an item in Phase N is modified, automatically re-evaluate and reset status of all dependent items in Phases > N to `Review` or `Todo`. Summarize these changes for the user.
- **Conflict detection & self-correction:** Actively check for contradictions: (a) between RQ conclusions and Req content, or between AC and other Req content — surface genuine requirement conflicts to the user and update every affected R item after resolution; (b) between AC and TC — fix silently before presenting unless a genuine specification ambiguity requires an RQ; (c) between DQ conclusions within Pre Design Sync OR between a DQ conclusion and the confirmed Req — surface to user immediately; (d) between Design items, or between Design and Pre Design Sync — fix silently before notifying user; (e) between Task and Design — fix silently before notifying user.
- **Precision:** Use accurate technical terms (e.g., Entity, Repository, CacheRepo).
- **Progress Table is mandatory:** Each section ends with its own progress table.
- **Output Format by Decision Scope:**
    - **Requirement clarification (RQ):** if confirmation must come from a PM, stakeholder, or external team, default to a forwardable Given/When/Then draft showing the behavioral difference between options and the exact point requiring confirmation.
    - **Internal design decisions (DQ):** present a comparison table + explicit recommendation + rationale, then wait for the user to pick.
