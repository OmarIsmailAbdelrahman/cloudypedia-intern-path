# 3-tier-ddl

## What it is
A DDL reference/cheatsheet for the BigQuery landing/staging/mart 3-tier pattern: one small domain
(retail order events), one table per tier, each using a **different** BigQuery partition type so all
three are covered in one place, plus clustering and the cost/governance options every real table
should set. Use this as the "what does a compliant table DDL look like" reference when starting a new
BigQuery dataset -- copy the tier that matches your table and adjust columns/keys. There is no data
transform here (see `staging-transform` / `mart-model` for that); this template's "solution" is the
DDL text itself. Prerequisites: Python 3.11+, `pytest`; DuckDB (any recent version; MERGE support is
not needed here) optional, only to exercise `local/run_local.sh` -- the tests do not require it.

Tables (all in one dataset, tier encoded as a table-name prefix -- see `docs/diagram.md` for the full
naming cheatsheet and the dataset-per-tier tradeoff):

| table                 | tier    | partition type                                        | notes |
|-----------------------|---------|--------------------------------------------------------|-------|
| `landing_orders_raw`  | landing | **ingestion-time** (`PARTITION BY _PARTITIONDATE`)     | raw JSON payload, no clustering |
| `stg_orders`          | staging | **time-unit column** (`PARTITION BY DATE(order_ts)`)   | `CLUSTER BY store_id, customer_id`; `require_partition_filter`; `partition_expiration_days` |
| `mart_fct_orders`     | mart    | **integer-range** (`PARTITION BY RANGE_BUCKET(customer_id, GENERATE_ARRAY(0, 100000, 1000))`) | `CLUSTER BY store_id, order_date`; `require_partition_filter`; `labels` |

See `src/landing.sql`, `src/staging.sql`, `src/mart.sql` for the canonical BigQuery DDL (each with an
inline comment explaining why that partition type was chosen for that tier), and `docs/diagram.md`
for the tier flow + naming cheatsheet.

## Input/output contract
This template has no data transform, so "input/output" means the **DDL contract** each tier exposes
to the next, not transformed rows:
- Landing "input": raw order events as received (any shape upstream sends); stored as an opaque
  `raw_payload STRING` plus lineage columns. Shape example: `sample_data/landing_row.json`.
- Landing "output" / staging "input" (schema contract): staging parses `raw_payload` into the typed
  columns of `stg_orders` (`order_id`, `customer_id`, `store_id`, `order_ts`, `status`,
  `order_total`, `load_date`). Shape example: `sample_data/staging_row.json`.
- Staging "output" / mart "input" (schema contract): mart shapes staging rows into the analytics-ready
  `mart_fct_orders` fact (adds a surrogate key `order_sk`, `order_date`). Shape example:
  `sample_data/mart_row.json`.
- Downstream consumers of `mart_fct_orders` rely on: the column list/types above, `customer_id` as the
  `RANGE_BUCKET` partition key (filter on `customer_id` for pruning), and `store_id`/`order_date` as
  the clustering prefix (filter on `store_id` first, then `order_date`, to get pruning benefit -- see
  the prefix-rule comment in `src/staging.sql` / `src/mart.sql`).

## Run locally
`bash local/run_local.sh` -- creates the DuckDB-local mirror of all 3 tables from
`local/ddl_local.sql` (plain columns only; BigQuery-only `PARTITION BY`/`CLUSTER BY`/`OPTIONS(...)`
clauses are dropped -- see `docs/cloud_verify.md`) and prints `DESCRIBE` for each table, proving the
committed column definitions are valid SQL and match the tier schemas in `src/*.sql`. Also run
`python3 -m pytest tests -q` -- structural tests that parse `src/*.sql` and assert each tier really
uses the partition type / clustering / options claimed above (no DuckDB or `bq` required).

## Cloud-verify only
See `docs/cloud_verify.md` for the full list. Summary: real partition pruning / bytes-scanned
reduction for all three partition types, `_PARTITIONTIME`/`_PARTITIONDATE` pseudo-column population,
`require_partition_filter` enforcement, the 4,000-partition cap and ≤4,000-partitions-per-job backfill
chunking rule, `RANGE_BUCKET` overflow-bucket behavior, and GoogleSQL dialect/cost validation via
`bq query --dry-run` all require a real BigQuery project -- none are reproducible in DuckDB. **Not
executed here: this sandbox has no `bq` CLI installed**, so the `bq --dry-run` step is documented, not
run.
