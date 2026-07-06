# staging-transform

## What it is
BigQuery bronze->silver staging transform: cleans a raw `landing_events` table (e-commerce
clickstream/order-line events, everything landed as STRING) into a typed, deduplicated `stg_events`
table. Covers both a **full-refresh** path (`CREATE OR REPLACE TABLE ... AS SELECT`, simple and
always correct, expensive at scale) and an **incremental/high-watermark** path (`MERGE` bounded by
`event_ts > @watermark`, cheap at scale but needs a reliable watermark and still needs the same
`SAFE_CAST`/dedup discipline). Use this template as the reference shape for any bronze->silver
cleaning step in the 3-tier model. Prerequisites: Python 3.11+, `pytest`; DuckDB (any version — this
template's SQL doesn't need `MERGE INTO` support, only `QUALIFY`/`TRY_CAST`/window functions) is
optional, only needed to exercise the DuckDB-adapted SQL — the smoke tests do not require it.

Handles the corner cases every bronze->silver transform must handle:
1. **`SAFE_CAST`, not `CAST`** — `landing_events.amount`/`event_ts` are raw STRING (typical of an
   ingestion layer with no schema enforcement). One malformed value (e.g. `amount = "not_a_number"`)
   would fail an entire job under a bare `CAST`; `SAFE_CAST` turns just that value into `NULL` and
   lets every other row load.
2. **Source dedup** — `landing_events` can carry >1 raw row per `event_id` (retries, at-least-once
   delivery). `QUALIFY ROW_NUMBER() OVER (PARTITION BY event_id ORDER BY event_ts DESC) = 1` picks
   the latest version before it reaches anything downstream — same discipline as the MERGE
   non-deterministic-match corner case in `scd-upsert-merge`.
3. **No `SELECT *`** — every column is named explicitly in both `src/full_refresh.sql` and
   `src/incremental.sql`, to avoid the `SELECT *` cost trap ($6.25/TiB, billed by columns actually
   read) and to keep the silver contract stable if bronze grows new columns.
4. **High-watermark incremental** — `src/incremental.sql` only reads/writes
   `landing_events` rows with `event_ts > @watermark`, applying the same `SAFE_CAST`+`QUALIFY`
   cleaning to that slice, then `MERGE`s it into `stg_events` instead of rebuilding the whole table.
   Documented tradeoff (see `docs/diagram.md`): incremental is cheaper but silently misses rows that
   arrive *late* with an `event_ts` older than the current watermark.

## Input/output contract
- Input: `landing_events` rows — `{event_id, customer_id, event_type, amount, event_ts}`, all
  STRING, one or more raw rows per `event_id` per batch. See
  `sample_data/input_landing_batch1.json` / `input_landing_batch2.json`.
- Output: `stg_events` — one row per `event_id`, `amount` typed `NUMERIC` (NULL if malformed),
  `event_ts` typed `TIMESTAMP`, always the latest raw row per `event_id`.
  - `sample_data/output_full_refresh.json` — result of `full_refresh.sql` over batch1 alone.
  - `sample_data/output_incremental.json` — result of `incremental.sql` merging batch2 into the
    full-refresh state above (this is also what a full rebuild over batch1+batch2 combined would
    produce — see `tests/test_transform_reference.py`).

## Run locally
`bash local/run_local.sh` — loads batch1 and runs the full-refresh transform, then loads batch2 and
runs the incremental transform on top, printing both resulting `stg_events` states. Tries a DuckDB
execution of the DuckDB-adapted SQL first (`local/*_duckdb.sql`); falls back to the pure-Python
reference (`src/transform_reference.py`) on any exception, so the command always succeeds.

## Cloud-verify only
See `docs/cloud_verify.md`. Summary: GoogleSQL dialect/type checking via `bq query --dry-run`, real
bytes-scanned cost comparison of the explicit-column queries vs. a `SELECT *` rewrite, and true
incremental-at-scale savings against a production-sized `landing_events` all require a real BigQuery
project/`bq` CLI — not reproducible in DuckDB or with this template's small sample data.
