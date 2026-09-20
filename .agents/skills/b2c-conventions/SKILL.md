---
name: b2c-conventions
description: Team conventions and tacit knowledge for the user's B2C e-commerce system — any repo whose name starts with `PXBox` or `PXEC` (the system's two project-name lineages, case-insensitive), or whenever B2C itself — the user's department/system, as distinct from B2E or 3PL — comes up in conversation, even outside such a repo. Covers things not derivable from the code itself — file-language rules, team practices, and the PXEC-to-PXBox history. Load this the first time in a session such a repo is touched or B2C is discussed, before writing any code, docs, instruction files, or commits.
---

# B2C Conventions

Applies to any repo whose name starts with `PXBox` or `PXEC` (case-insensitive), and to any
discussion of B2C — the user's department and system — even when the session isn't currently
inside such a repo.

## File language

Project-level instruction/skill files in these repos — `CLAUDE.md`, `.claude/skills/*/SKILL.md`,
`.github/copilot-instructions.md` — are written in **Traditional Chinese (繁體中文)**, not English.

Rationale: the language follows the audience, not the file's location. These repos are shared
with teammates, so their instruction files are team documentation, and English would force every
teammate to translate while reading.

This does not apply to `~/.claude/` files — those stay English per the global CLAUDE.md default.

## Company and system context

全聯 is the parent company of 全電商, an e-commerce platform comprising three systems owned by
separate departments:

- **B2C** — The user's department; its system uses a microservice architecture.
- **B2E**
- **3PL**

Other 全聯 units and systems work with 全電商 but are not part of it:

- **PXPay** — Payment service provider.
- **全支付** — Payment service provider.
- **資訊部** — Responsible for accounting, member data, and the intermediary database.

## History: PXEC → PXBox, and the B2C/B2E/3PL split

The e-commerce platform originally consisted of `PXEC`-prefixed projects, also a microservice
architecture. While `PXEC` was still under active development, a separate `PXBox`-prefixed
project line was started in parallel — likewise microservices, but simpler and faster to ship.

To speed up development, `PXEC` development was later halted, and its responsibilities were
split three ways — B2C, B2E, 3PL — each handled differently:

- **B2C** was handed entirely to the `PXBox` project line, which is why `PXBox` is the system
  the user's department (B2C) actually runs today.
- **B2E** and **3PL** were each built from scratch by two other, separate teams.

So `PXBox` and `PXEC` are not two versions of the same thing — they're two separate project
lineages from the same original platform, and only `PXBox` continues, carrying B2C's share of
what `PXEC` used to own.

## Deployment environment mapping

Environment variable values are case-sensitive; use the exact lowercase values shown.

| Environment | Branch | environment variable value |
| :--- | :--- | :--- |
| Prod | `main` | `prod` |
| UAT | `release` | `uat` |
| SIT | `develop` | `sit` |

## API route prefix

Route pattern is `<prefix>/<version>/<service name>/<name>`, where `<service name>` is the
microservice that owns the endpoint. The prefix tells you who calls the endpoint:

| Prefix | Caller |
| :--- | :--- |
| `app` | Front-end (customer-facing) screens |
| `backend` | Back-office (internal admin) screens |
| `service` | Other backend microservices |

`<service name>` usually comes from the project name `PXBox.<Name>.Service`, with `<Name>`
lowercased and word-separated by underscores:

| Project | `<service name>` |
| :--- | :--- |
| `PXBox.Spu.Service` | `spu` |
| `PXBox.Coupon.Service` | `coupon` |
| `PXBox.ShoppingCart.Service` | `shopping_cart` |
| `PXBox.MarketingOperate.Service` | `marketing_operate` |

## API HTTP methods

Expose API endpoints using only `GET` and `POST`. Use `GET` for read-only operations and `POST`
for operations that create, update, delete, or otherwise change state. Do not introduce `PUT`,
`PATCH`, or `DELETE` endpoints.

## Database read/write split

Prod MySQL is master/replica: a main DB for writes, a secondary DB for reads. UAT and SIT each
have only a single DB (no split). The convention is EF Core against the main DB for writes,
Dapper against the secondary DB for reads.

## Redis topology

Prod Redis runs as a **cluster of 3 nodes** (hash-slot sharding). UAT and SIT each have only a
single Redis instance (no cluster, no slots). Some keys use `{...}` hash tags so related keys
land on the same slot — on UAT/SIT this has no effect, since there's no slot routing at all;
keys just live on that one instance as normal strings.

## Invoice issuance: per sub-order → per parent order

Originally invoices were issued **per sub-order**: an order split into N sub-orders produced N
invoices. The tax authority warned that this misrepresented the transaction — the customer paid
once but received several invoices. In mid-January 2014 the system switched to issuing **per
parent order**: one payment, one invoice.

- `PXBox.Invoice.Service` is deprecated; `PXBox.InvoiceUnifier.Service` replaces it.
- The per-sub-order path was fully removed **only at order creation**, so no newly created order
  can ever reach it again. Everywhere else the per-sub-order logic is still in the codebase and
  still runs.

So when reading code that issues or handles invoices per sub-order: it is live code, not dead
code, but it is only reachable for orders created before the switch. Do not treat it as the
current behaviour, and do not assume it is unreachable either.
