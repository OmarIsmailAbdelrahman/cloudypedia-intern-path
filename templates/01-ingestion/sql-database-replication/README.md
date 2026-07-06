# sql-database-replication

## What it is
Replicates a SQL Server (MSSQL) source database into the GCP landing zone via
two complementary methods: (1) **batch extract** — JDBC/query-based
incremental extraction using a high-watermark column (e.g. `updated_at`) so
each run only pulls new/changed rows since the last watermark, and (2)
**streaming CDC** — a simulated change-log poller consuming an ordered log of
insert/update/delete events (each tagged with an LSN for ordering and
idempotent replay) and applying them onto a materialized target table,
handling idempotent replay and schema drift. Use this template as the
starting point for any "replicate an OLTP SQL Server table into GCS/BigQuery"
ingestion pipeline. Prerequisites: Python 3.11+; Docker only if you want to
exercise the Cloud-verify local-MSSQL path (not required to run this
template's tests).

## Input/output contract
- Batch extract input: `sample_data/input_batch.json` — a JSON array of row
  dicts, each with an `id`, an `updated_at` ISO8601 watermark
  (`2026-07-01T00:00:00Z` form), and arbitrary other columns.
  Output: `sample_data/output_batch.json` —
  `{"watermark_in": ..., "new_rows": [...], "new_watermark": ...}` for one
  concrete `extract_since_watermark()` call starting from `watermark_in =
  "2026-07-01T00:00:00Z"`.
- CDC input: `sample_data/input_cdc.json` —
  `{"last_lsn": N, "events": [{"lsn": int, "op": "insert"|"update"|"delete",
  "pk": ..., "data": {...}}, ...]}`.
  Output: `sample_data/output_cdc.json` — `{"state": {<pk>: <row dict>, ...},
  "new_lsn": N}` after applying all of `input_cdc.json`'s events.
- Downstream stages consume `new_rows` (batch) / `state` (CDC materialized
  view) as newly-landed rows ready for the next pipeline stage.

## Run locally
`bash local/run_local.sh`

(Runs both `src/batch_extract.py` and `src/cdc_stream.py` over the committed
sample_data inputs and prints both JSON results. Smoke test:
`python3 -m pytest tests -q`.)

## Cloud-verify only
- Running a real SQL Server instance in Docker (`local/docker-compose.yml`)
  seeded with `src/sql/seed.sql`, end to end.
- Real Datastream (or Debezium) CDC capture and delivery from a live SQL
  Server transaction log (`src/setup_datastream.sh`) — this template only
  simulates the change-log *shape* (`sample_data/input_cdc.json`), it does
  not connect to a real source.
- Real JDBC connectivity to SQL Server (driver install, network/firewall,
  auth) for `src/batch_extract.py`'s production counterpart.
- Real schema-drift behavior against a live source (an actual `ALTER TABLE
  ADD/DROP COLUMN` propagating through a live CDC feed) — this template only
  proves the merge logic against hand-authored drift scenarios in
  `tests/test_replication.py`.
