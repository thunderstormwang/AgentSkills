---
name: knowledge-layout
description: The three-tier layout for a project repo's tacit knowledge — CLAUDE.md holds obligations and a one-line index, a domain skill opens with a sub-index and carries the "why", docs/ holds the depth. Load this when deciding where a newly-learned fact belongs, when reshaping an existing skill or CLAUDE.md into this shape, or when the user says things like "整理 skill", "這個知識該放哪", "CLAUDE.md 太長了", "要不要開新 skill". Covers the loading mechanics that make the tiers behave differently, the writing rule for each tier, and the anti-patterns (one skill per fact, pure index skill, content in CLAUDE.md). Not about authoring a skill's frontmatter or running evals — that is skill-creator's job.
---

# Repo Knowledge Layout

Where a piece of tacit knowledge — "why is this code written this way" — belongs in a project
repo, and how to shape each tier so it is actually found at the right moment.

## The three tiers

```
CLAUDE.md          one line per domain → points at that domain's skill or doc
  └ domain skill   opens with a sub-index table → points into docs/
      └ docs/      the depth
```

| Tier | When it loads | What belongs there | Fixed cost |
| :--- | :--- | :--- | :--- |
| `CLAUDE.md` | **Always** | Obligations and the index | Every line, every session |
| `.claude/skills/*` | Description always; **body on demand** | One mechanism/subsystem's "read before you touch this" | The description only |
| `docs/*.md` | **Only when something names it** | Depth, history, tables, walkthroughs | None |

## The mechanics that make them differ

These are the load-bearing facts; every rule below follows from them.

- **`CLAUDE.md` is always in context**, wrapped as a standing user instruction. It has
  *obligating* force — it can say "read this even if the user didn't ask".
- **A skill's `description` is also always in context**, but framed as a catalog entry. It has
  *summoning* force only: it decides whether the skill fires, not whether the reader feels
  bound. Imperatives in a description ("務必", "一律") do not raise its hit rate — it is
  matched semantically, not obeyed.
- **A skill's body costs nothing until it fires.** So prefer few, thick skills over many thin
  ones: N skills means N descriptions competing for the same match, and near-duplicate
  descriptions degrade each other's triggering.
- **`docs/*.md` is invisible by default.** Nothing announces it. It is reachable only via a
  `CLAUDE.md` index line, a skill that names it, or an explicit `ls`/`grep`. Its worst failure
  is not cost — it is never being found at all.
- **A hook (`UserPromptSubmit`) beats all three** when something must never be missed: it
  injects unconditionally and does not depend on the model's judgement. It pays full cost every
  turn, so reserve it for the very few.

## What to write in each tier

**`CLAUDE.md` — obligations and index, never content.**
One line per entry, stating *when to read it*, not what it contains. The sentence that only
this tier can carry is **"even if the user does not say so"**. Keep entries to domains, not
documents: this tier should grow with the number of domains (slow), not the number of files.

> Good: "覺得某段程式邏輯莫名其妙、或不確定某分支還會不會被走到時先查這篇"
> Weak: "主題知識庫，處理相關領域前值得先查" — gives no trigger signal

**A skill's `description` — trigger signals, not duties.**
Fill it with the concrete nouns that will actually appear in a prompt or in the code being
touched: class names, field names, endpoint names, symptom phrases ("某銀行看不到", "退點算
錯"). State what it does *not* cover, to keep it from stealing neighbouring skills' triggers.

**`docs/` filenames — the filename is the description.**
It is all that is visible from an `ls`. `TapPay請款退款時間序知識庫.md` is findable;
`notes.md` effectively does not exist.

## Routing a new piece of knowledge

1. **Is there a concrete code boundary — "you must know this before touching X"?**
   No (pure history, why a constant is that number, which branch is dead code) →
   append a few lines to the repo's decisions/dead-code log (`docs/歷史決策與死碼地圖.md` or
   equivalent). Done.
2. **Yes — does an existing skill already cover that code?**
   Yes → **add a section to it. Do not open a new skill.** Most facts land here.
3. **Neither** → only now open a new skill, scoped to *a subsystem*, not *a fact*, so it has
   room to absorb the next five findings on the same topic.

## Shape of a domain skill

- **Opens with a sub-index** — a "your question → read which file" table — then pushes depth
  into `docs/`. This is what lets the domain grow without touching `CLAUDE.md`.
- **Body records *why*, not *what*.** What the code does is readable from the code; why it was
  written that way is not. Prefer the reason, the policy origin, the constraint that was
  negotiated with a third party, the bug that was hit in UAT.
- **Anchor with class/method/field names, never line numbers.** Line numbers rot on the next
  edit; names survive and are greppable. Verify every name still exists before committing.
- **Mark unverified rationale as unverified** rather than inventing intent.

## Anti-patterns

| Anti-pattern | Why it fails |
| :--- | :--- |
| One skill per fact | Descriptions are a fixed cost and compete; many similar ones mis-trigger |
| A pure "index skill" | An index must fire *before* the topic is known; a skill fires only *after* a description matches, so it arrives too late or never |
| Content (not an index line) in `CLAUDE.md` | Index lines are cheap; prose is what makes it bloat. When it gets long, move the prose out and keep the index |
| Imperatives stuffed into a `description` | Does not raise hit rate; the obligation belongs in `CLAUDE.md` |
| A doc with a vague filename | Unreachable in practice |

## Reshaping an existing skill into this form

1. Split the body into *why* (keep) and *what the code does* (delete — it is in the code).
2. Move long reference material into `docs/`, leave a sub-index table at the top of the skill.
3. Rewrite the `description` as trigger signals; add a "not applicable to …" clause.
4. Replace any line numbers with class/method names; grep-verify each name.
5. Ensure `CLAUDE.md` has exactly one line for the domain, phrased as *when to read*.
6. Record anything with no code boundary in the decisions/dead-code log instead.

## Collecting what is still only in people's heads

- Do not schedule "write documentation" — it does not happen. Attach capture to work that
  already occurs: a code review question, the end of a production investigation, a new joiner's
  question.
- Keep the intake threshold at two or three lines — an append-only log, no structure required.
  Promote a topic to a skill only once it has accumulated several entries *and* a clear code
  boundary.
- Let the AI be the scribe: the person talks, the AI verifies against the code and writes it up.
  Requiring a person to write the Markdown themselves is usually what kills the capture.
  Verification matters — recollections are often subtly wrong about field counts, names, and
  which side computes what.
