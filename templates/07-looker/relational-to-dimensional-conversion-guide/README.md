# relational-to-dimensional-conversion-guide (flagship)

## What it is
The flagship Stage 07 template: how to convert a 3NF/normalized schema into
a star schema in LookML, and why. It pairs a worked, intentionally-broken
`src/before/` (LookML authored directly on normalized tables) with a fixed
`src/after/` (a proper fact + conformed dimensions star), using the
order-items example (grain = one row per order line item). Use this when
starting LookML modeling on a new normalized source, or when reviewing an
existing model for fan-out/chasm-trap risk. Prerequisites: Python 3.11+,
`pytest` (no Looker instance, no LAMS install, no BigQuery connection).

Read `docs/mapping-table.md` first (3NF column -> star artifact), then
`docs/grain-checklist.md`, `docs/scd2-validity-date-join.md`, and
`docs/chasm-trap-avoidance.md`.

## Input/output contract
- Input: a normalized (3NF) source schema — `sample_data/before/schema.sql`
  (BigQuery DDL, documentation only) + `sample_data/before/*.csv` (sample
  rows for `customers`, `products`, `orders`, `order_items`).
- Output: a star mart schema — `sample_data/after/schema.sql` +
  `sample_data/after/*.csv` (sample rows for `fct_order_items`,
  `dim_customers` [SCD-2], `dim_products`, `dim_date`) — and the LookML that
  models it: `src/before/*.view.lkml` + `orders_3nf.explore.lkml` (the
  broken naive model) vs. `src/after/*.view.lkml` + `order_items.explore.lkml`
  (the fixed star). Downstream: any BI consumer of a Looker Explore expects
  the `after/` shape — one fact grain, conformed dimensions, symmetric
  aggregates intact.

## Run locally
`bash local/run_local.sh`
(then `cd` here and `python -m pytest tests -q` — see Verify below)

## Cloud-verify only
- LookML Validator / real parse-check of the `.lkml` files (this template
  only proves the specific correctness rules in `local/lkml_checker.py`, not
  full LookML syntax validity).
- The actual symmetric-aggregate SQL Looker generates for `after/`'s
  measures, and confirming the `before/` bug reproduces a wrong number
  against a live BigQuery connection (SQL Runner).
- Row-count-before/after-join verification against the real
  `analytics.mart.*` tables (the grain-checklist item that needs a live
  warehouse).
- PDT builds — not applicable here (no derived tables in this template).
