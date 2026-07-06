# view-from-bq-table

## What it is
The single-purpose worked example of turning ONE BigQuery mart table into ONE
correct LookML view -- the building block the other Stage 07 templates (e.g.
`explore-and-joins`) assemble into stars/explores. It demonstrates every
field-authoring pattern an intern needs for a first view: plain dimensions, a
`dimension_group { type: time }`, a `dimension_group { type: duration }`
(elapsed time between two timestamps), the full measure-type family
(unfiltered canonical `count`, a filtered count, `sum`, `average`,
`count_distinct`), always declaring `primary_key: yes` even when the view is
not (yet) joined to anything, `value_format_name`, and using `${TABLE}`
consistently instead of repeating the raw table name. Use this as the
starting template any time you're modeling a single new mart table. This
template intentionally has no join/explore -- see `explore-and-joins` for
that. Prerequisites: Python 3.11+, `pytest` (no Looker instance, no LAMS
install, no BigQuery connection).

## Input/output contract
- Input: one BigQuery mart table's schema -- `sample_data/schema.sql` (DDL,
  documentation only) + `sample_data/fct_orders.csv` (sample rows) for
  `analytics.mart.fct_orders` (grain: one row per order).
- Output: one lint-clean `src/fct_orders.view.lkml`, checked locally by
  `local/lkml_checker.py` (no views missing `primary_key`, no joins missing
  `relationship`, no ambiguous unfiltered `count` measures).

## Run locally
`bash local/run_local.sh` then `python -m pytest tests -q`

## Cloud-verify only
- Binding the real Looker connection to `analytics.mart.fct_orders`.
- Confirming `dimension_group { type: duration }` actually renders the
  `fulfillment_hours` / `fulfillment_days` measures correctly in Explore.
- Confirming `value_format_name: usd` renders as expected (currency
  formatting) in the Looker UI.
