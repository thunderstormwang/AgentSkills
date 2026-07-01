# AC / TC Writing Guidelines

## AC Writing Principles

  1. **Align each AC to the source of truth** —
     - For refactor / extension work, the source is the existing code: trace the relevant code path before drafting each AC and reflect real behavior. If code has a known defect that contradicts spec, mark `⚠️ 已知缺陷：...` and keep AC describing current behavior — do not retrofit AC to match broken code.
     - For greenfield work, the source is the spec / PRD; align ACs to spec language and surface any contradictions or gaps for the user before drafting.

  2. **One concern per AC** — Don't combine multiple test concerns (e.g., mixed prices + truncation boundary + tie-break) in a single AC. Prefer more simple ACs over fewer complex ones — each AC should fail for exactly one reason.

  3. **Cover boundary values with dedicated ACs** — For every conditional branch, ask: where's the off-by-one? Common boundaries to check explicitly:
     - Equality vs strict-greater (`>= threshold` vs `> limit`)
     - Stable-sort tie-break when multiple items share the sort key
     - Rounding to zero pushing a per-item value below the minimum
     - Multi-pass allocation: residual from first pass falling into a second pass
     - Per-element floor / minimum preservation
     - Early-exit branches (e.g., `if (remainder == 0) break;`)

  4. **AC ID format: `AC-{案型}-{序號}`, not global sequential** — Adding or removing ACs in one case type must not cause renumbering across the whole document. The case-prefix also doubles as a test-class / method naming hint (e.g., `AC-滿件金-01` maps to `OrderQuantity_Money_NoCumulate_Test`).

  5. **Test observable behavior, not internal pipeline** — When describing outcomes (達標 / 跳過 / 折扣), use externally observable conditions (e.g., "首購商品 A 存在於購物車"), not internal pipeline state (e.g., "checkItems 縮減後總件數 3", "進入 CheckPromoteCondition 看到 itemQtyTotal=2"). The AC must survive internal refactors of pipeline stages, helper methods, or naming.
     - Violation example: writing 「總件數 3 ≥ 門檻 1 達標」 when `3` is the pre-pipeline count but the Handler reduces `checkItems` to 2 internally. State the observable trigger (e.g., 「首購商品 A 存在於購物車 → 達標」) instead, so the AC survives a refactor that removes or renames `checkItems`.

  6. **Rule names must mirror the spec 1:1** — When an AC describes the rule triggering a behavior, use the rule's exact name from the spec; do not collapse multiple distinct rules into a generic term. AC titles and contents must match the underlying field / rule.
     - Violation example: using 「per-product 規則」 to describe what is actually 「買一送一首購商品排除規則」 — the two have different trigger conditions and scope (per-product is cross-promotion within a group; 首購商品排除 is a single-promotion rule of 買一送一).
     - Violation example: an AC titled 「滿件滿額不適用商品排除」 when the underlying field is `IsComboShipment` (組合商品). The title should be 「組合商品（IsComboShipment）排除」.

  7. **Lift shared rules to chapter preambles** — When the same rule applies across multiple AC sections, state it once in each chapter's preamble; do not repeat the rule inside every AC's Then clause.
     - Example: 「折數型 IsCumulate flag 不讀，但 CumulateLimit > 0 仍作單筆上限截斷」 applies to 滿件折 / 滿額折 / 首購折 / 贈點百分比. Document it in each chapter's preamble once; the AC body need only reference the rule, not re-explain it.

  8. **No "📝 待釐清" placeholders inside AC sections** — AC chapters must contain only finalized, executable AC items. Handle pending items elsewhere:
     - Resolved → rewrite as a concrete rule statement
     - Unresolved → file under Pre Design Sync as a Q item
     - Future scope → move to a follow-up note in plan.md (or the relevant ticket), not the AC chapter
     - An AC chapter with `📝 待釐清` paragraphs signals incomplete work and tends to get skipped by reviewers.

  9. **State chapter-level prerequisites up front** — Each AC chapter's preamble must declare:
      - The spec / plan prerequisites assumed by the chapter (e.g., 「本章假設輸入符合 plan.md L67 前提」)
      - The forbidden-but-not-tested combinations + who enforces them (e.g., 「人工+人工 由衝突檢核擋下、系統+系統 由 plan L67 擋下」), so the reader does not mistakenly try to write tests for those.
      - Cross-references to the source-of-truth documents (e.g., 現況案型分析、新增案型分析).
      - This prevents readers from inferring that violating combinations need to be tested, and surfaces the chain of responsibility for upstream validation.

  10. **Two-layer artifact structure (high-level AC + detailed TC)** — When features have non-trivial calculation rules, split deliverables into two distinct artifacts:

      **High-level AC** (`{topic}_ac.md`): rule summary for PM / stakeholder validation. **Primary reader: PM** — plain business language; avoid class / method names, field names, and implementation jargon; replace technical terms with functional descriptions (e.g., "LINQ stable sort" → "依輸入順序取第一件"); make tie-break and sort orders explicit in natural language. **No Given/When/Then.**
      - Content: rule statements, formulas (e.g., 折扣 = totalAmount × (100 − 折數) / 100)
      - **NO** concrete values, calculation traces, per-item attribution
      - ID format: `AC-{group}-N` (e.g., `AC-現折-01`, `AC-贈點-01`)
      - 案型 heading prefix with ID (e.g., `## AC-現折-01 訂單滿件 — 現折金額`)
      - 共用 fields 抽到頂層「共用欄位定義」，分子組（共通 / 案型群組）
      - Each 案型 chapter has two mandatory sub-sections:
        - **系統欄位定義**: maps domain / Chinese field names → English system field names (e.g., 觸發上限 → `CumulateLimit`, 折扣金額 → `DiscountAmount`)
        - **核心驗收標準**: the rule statements that form the AC body (plain Chinese, no Given/When/Then)
      - Body uses plain Chinese; English field names appear only in 系統欄位定義, not inside rule statements
      - 無 emoji；公式用 plain text（如 `floor(x / y)`）
      - 檔案超過 5 章節時，加目錄（TOC）

      **Detailed TC / Spec by Example** (`{topic}_tc_{layer}.md` — 可拆多檔): **Primary reader: RD / QA / unit test writers. MUST use Given/When/Then format with concrete values. Placeholders such as `$X`, `$Y`, or "視設定而定" are forbidden — split into concrete cases instead.**
      - Content: concrete Given/When/Then with specific values, calculation traces, per-item attribution
      - **Heading format: `{MethodUnderTest}_{Scenario}_{ExpectedBehavior}`** (e.g., `Handle_MemberHasOldCard_DisablesOldCardAddsNewCardAndClearsCache`) — directly usable as a unit test method name. Add a one-line Chinese description as a blockquote (`> ...`) immediately under the heading.
      - 開頭引用對應的 AC 章節（e.g., 「對應 AC-現折-01」）
      - **術語對照**: a mapping table at the start of each TC file — domain term → system field name (e.g., 活動結果 → `DiscountPromotions`, 達標 → `IsApplied = true`). Makes the TC self-contained; an AI test author can write test code without reading the spec separately.
      - **驗收欄位對照**: a short table or list explaining the observable output structure asserted in Then clauses (e.g., 「活動結果（DiscountPromotion）：IsApplied, LackAmount, DiscountAmount」; 「各商品折扣明細（DiscountDetail）：ProductId, DiscountAmount」). Prevents tests from asserting on wrong / missing fields.

      **Cross-references**:
      - TC 檔頂部說明對應 AC 章節（AC 不需反向列出 TC 檔）
      - **規則變動時 MUST cross-check 既有 TC 是否衝突**（不要等 user 抓）

      **When to single-layer vs two-layer**:
      - 計算規則簡單、邊界 case 少 → 單層 AC 即可（Spec by Example 適度）
      - 計算規則含複雜算法、攤提、多 case → **必拆兩層**（PM 才看得懂 AC，工程師才能寫測試）

  11. **Include regression coverage for shared components** — When a feature extends or adds to shared calculation logic (e.g., `AssignPromotionDiscount` used by all case types), include a dedicated regression TC chapter that covers the shared method's existing behavior, even if the method was not modified in this feature. This prevents future refactors from silently breaking behaviors not covered by the new-feature TCs alone.
      - Position: a separate TC chapter (e.g., `## 共用邏輯回歸 — AssignPromotionDiscount`), not mixed into case-type chapters.
      - Scope: cover the observable contracts of the shared method (two-pass allocation, $1 floor, proportional attribution) — not implementation details.
      - Signal: if a shared method has zero TC coverage after a feature is shipped, treat it as a coverage gap.
