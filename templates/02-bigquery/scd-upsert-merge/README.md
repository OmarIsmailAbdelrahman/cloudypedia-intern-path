# scd-upsert-merge (flagship)

## What it is
BigQuery SCD Type 1 (overwrite) and SCD Type 2 (full history) upserts via `MERGE`, driven off a
daily staging feed. Use this when a dimension needs either "latest values only" (SCD1) or "track
every change over time" (SCD2). Prerequisites: Python 3.11+, `pytest`; DuckDB >= 1.4 optional (only
needed to exercise the DuckDB-adapted SQL — the smoke tests do not require it).

Handles two BigQuery MERGE corner cases every SCD template must handle:
1. **Source dedup** — raw `stg_customers` can carry >1 row per `customer_id` per load (late
   corrections). `QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) = 1`
   picks the latest before the MERGE ever sees it — otherwise a non-deterministic match is a runtime
   error in BigQuery.
2. **Target partition pruning** — the `ON` clause is bounded by a rolling `load_date`/`eff_start_date`
   window (`>= DATE_SUB(@load_date, INTERVAL 3 DAY)`) so MERGE doesn't full-scan the whole target
   table (the "MERGE full-scan trap").

SCD2 is a two-phase "close-then-insert": Phase 1 (`MERGE`) closes out the current row for any
customer whose tracked attributes changed; Phase 2 (`INSERT`) opens a fresh current row for every
customer left without one (both brand-new customers and ones just closed).

## Input/output contract
- Input: `stg_customers` rows — `{customer_id, name, email, region, tier, updated_at, load_date}`,
  one or more raw rows per `customer_id` per `load_date`. See `sample_data/input_day1.json` /
  `input_day2.json`.
- Output:
  - `mart_dim_customers_scd1` — one row per `customer_id`, always current values. See
    `sample_data/output_scd1_day2.json`.
  - `mart_dim_customers_scd2` — one or more rows per `customer_id` (`is_current` + closed history),
    `eff_start_date`/`eff_end_date`/`row_hash` tracked. See `sample_data/output_scd2_day2.json`.

## Run locally
`bash local/run_local.sh` — loads day-1 then day-2 sample data and prints the final SCD1/SCD2
state. Tries a DuckDB (>=1.4) execution of the real MERGE dialect first (`local/*_duckdb.sql`);
falls back to the pure-Python reference (`src/scd_reference.py`) if DuckDB isn't installed or
predates MERGE support, so the command always succeeds.

## Cloud-verify only
See `docs/cloud_verify.md`. Summary: real partition pruning / bytes-scanned reduction,
`require_partition_filter` enforcement, streaming-buffer DML lockout, and GoogleSQL dialect/cost
checks via `bq query --dry-run` all require a real BigQuery project — not reproducible in DuckDB.
