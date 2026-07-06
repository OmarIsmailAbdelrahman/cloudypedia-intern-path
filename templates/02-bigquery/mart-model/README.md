# mart-model

## What it is
BigQuery silver->gold dimensional model: a small star schema built from a `stg_orders`-shaped
silver input (order line items). Produces `dim_customer` (one row per customer) and
`fct_orders_daily_by_category` (daily revenue + order count grouped by `order_date`,
`product_category`). Use this when a downstream dashboard/report needs a pre-aggregated,
`dim_`/`fct_`-named gold layer instead of querying silver directly. Prerequisites: Python 3.11+,
`pytest`; DuckDB optional (only needed to exercise the real SQL locally - the smoke tests do not
require it).

The fact table is built from ONE core SELECT (`SUM(quantity*unit_price)` as revenue,
`COUNT(DISTINCT order_id)` as order_count, `GROUP BY order_date, product_category`) exposed TWO
ways, both committed to `src/`:
- `fct_orders_daily_mv.sql` - a BigQuery **materialized view**: auto-refreshes incrementally
  server-side and serves cached results (cheap/fast reads), but has query-shape restrictions, a
  small storage cost, and can serve slightly-stale results between refreshes.
- `fct_orders_daily_view.sql` - a plain **logical view**: always exact/fresh, zero storage cost, no
  restrictions on the SELECT, but recomputes the full aggregation - full cost - on every query.

**Rule of thumb:** materialized view when the aggregate is queried often and near-real-time
staleness is fine; logical view when freshness must be exact or the query is rare. Full tradeoff
table: `docs/mv_vs_view_tradeoff.md`.

`PARTITION BY order_date` / `CLUSTER BY product_category` on `fct_orders_daily_by_category` (see
`src/ddl_bigquery.sql`) is tuned to the read pattern this template assumes: dashboards filter a date
range and group/filter by category, so date-partition pruning eliminates whole days first, then
category clustering prunes within the surviving days.

**Verified in this sandbox:** the installed DuckDB (1.2.1) does NOT support
`CREATE MATERIALIZED VIEW` (`ParserException: syntax error at or near "MATERIALIZED"`, checked
directly). BigQuery materialized views also auto-refresh incrementally server-side with no DuckDB
equivalent regardless of version. `local/run_local.py` therefore represents the materialized view
locally as a one-time `CREATE TABLE ... AS <same SELECT>` snapshot, and exercises the logical view
for real via an actual DuckDB `CREATE VIEW`. See `docs/cloud_verify.md`.

## Input/output contract
- Input: `stg_orders` (silver) rows -
  `{order_id, customer_id, order_date, product_category, quantity, unit_price}`, one row per order
  line item; an order may have multiple line items (same or different `product_category`). See
  `sample_data/stg_orders.json`.
- Output:
  - `dim_customer` - one row per `customer_id`:
    `{customer_id, first_order_date, last_order_date, lifetime_order_count, lifetime_revenue}`. See
    `sample_data/expected_dim_customer.json`.
  - `fct_orders_daily_by_category` - one row per `(order_date, product_category)`:
    `{order_date, product_category, revenue, order_count}`, identical whether read via the
    materialized view or the logical view. See
    `sample_data/expected_fct_orders_daily_by_category.json`.

## Run locally
`bash local/run_local.sh` - builds `stg_orders` from `sample_data/`, runs the real DuckDB `CREATE
VIEW` (logical-view path) and a one-time-materialized snapshot table (materialized-view stand-in)
over the identical core SELECT, asserts they match each other AND the committed gold output, prints
both result sets plus `dim_customer`, and falls back to the pure-Python reference
(`src/mart_reference.py`) if DuckDB isn't installed, so the command always succeeds.

## Cloud-verify only
See `docs/cloud_verify.md`. Summary: real materialized-view incremental refresh/staleness window,
BigQuery's enforcement of MV query-shape restrictions, real partition pruning/bytes-scanned
reduction, pseudo-columns, and GoogleSQL dialect/cost checks via `bq query --dry-run` all require a
real BigQuery project - not reproducible in DuckDB, and `bq` is not installed in this sandbox.
