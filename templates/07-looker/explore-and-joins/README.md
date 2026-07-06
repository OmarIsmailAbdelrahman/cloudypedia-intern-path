# explore-and-joins

## What it is
How to assemble a star (one fact + conformed dimensions) into a LookML
`explore:`, covering all 4 join types (`left_outer`/`inner`/`full_outer`/
`cross`) and all 4 relationships (`many_to_one`/`one_to_one`/`one_to_many`/
`many_to_many`), symmetric-aggregate safety, and a documented chasm-trap
example with its recommended fix. Use this once you already have views for
your fact and dimensions (see `view-from-bq-table`) and need to wire them
into an explore correctly. Prerequisites: Python 3.11+, `pytest` (no Looker
instance, no LAMS install needed).

Start with `docs/join-types-and-relationships.md` (the reference matrix),
then `docs/chasm-trap-example.md` (the worked bug + fix).

## Input/output contract
- Input: a BQ mart schema — `sample_data/schema.sql` + per-table CSVs
  (`orders`, `fct_order_items`, `order_returns`, `fct_order_returns_by_order`,
  `order_item_extras`, `dim_customers`, `dim_products`, `dim_date`,
  `products_tags`).
- Output: `src/views/*.view.lkml` (one view per mart table) +
  `src/explores/*.explore.lkml` (9 explores, each demonstrating a specific
  join-type/relationship combination or the chasm-trap bug/fix — see
  `docs/join-types-and-relationships.md` for the full map). Downstream: any
  Looker Explore or BI dashboard consuming these fields expects the safe
  (non-chasm-trap) explores' row/measure shapes.

## Run locally
`bash local/run_local.sh`
(then `python -m pytest tests -q` — see Verify below)

## Cloud-verify only
- The actual SQL Looker generates for each join type/relationship
  combination, and confirming the chasm-trap row-count inflation
  (3 x 2 = 6 rows for order O1) against a live BigQuery connection.
- LookML Validator full parse-check (this template's checker proves a
  specific, narrow set of rules — see `local/lkml_checker.py` — not full
  LookML syntax validity).
- Confirming `products_tags_discouraged`'s many_to_many fan-out on both
  sides in the real generated SQL, and the `cross`-join row multiplication
  for `pivot_by_period_type`.
