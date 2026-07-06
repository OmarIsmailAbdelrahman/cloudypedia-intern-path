# query-cookbook

## What it is
A curated, growing library of reusable BigQuery scripts. Each entry under `src/cookbook/` is a
standalone `.sql` file with a fixed doc header (`purpose` / `params` / `when to use` / `BQ-only?`
/ `sample output`) followed by a parameterized body — the team's shared query history. Use this
when you'd otherwise be re-writing (or hunting Slack history for) a scripting/time-travel/
MERGE/backfill/DQ-probe/cost query someone on the team already solved. Prerequisites: Python
3.11+, `pytest`; DuckDB (>= 1.4 for MERGE support, per `standards/CONVENTIONS.md`) optional —
only the `merge/` entry needs it, and everything degrades gracefully without it. `bq` CLI is
optional and only used for `bq query --dry-run` cloud-verification (not installed in this repo's
dev sandbox).

### Index

| name | category | purpose | BQ-only? |
|---|---|---|---|
| `dynamic_table_row_count.sql` | scripting | run a `COUNT(*)` against a table name only known at run time, via `DECLARE`/`SET`/`EXECUTE IMMEDIATE` | yes |
| `row_count_delta.sql` | time_travel | row count now vs N hours ago (`FOR SYSTEM_TIME AS OF`) and the delta | yes |
| `generic_upsert.sql` | merge | generic parameterized MERGE/upsert: source dedup (`QUALIFY ROW_NUMBER()`) + target partition predicate | no (needs DuckDB >= 1.4) |
| `chunked_partition_backfill.sql` | backfill | backfill + dedup in bounded date-range chunks, staying under the 4,000-partitions-per-job cap | yes |
| `table_health_probe.sql` | dq_probes | null-rate / duplicate-key / freshness-lag monitoring probes for one table | no |
| `select_star_vs_columns_and_partition_filter.sql` | cost_pruning | `SELECT *` vs explicit columns, filtered vs unfiltered — the `$6.25/TiB` billed-by-columns cost trap | no (cost estimate itself needs `bq --dry-run`) |

Add a new script by dropping a `.sql` file (with the same 5-field doc header) under
`src/cookbook/<category>/` and adding a row here — `tests/test_cookbook.py` fails the build if a
script isn't listed in this table, or if the table lists a script that no longer exists. See
`docs/diagram.md` for how the cookbook is organized and expected to grow.

## Input/output contract
- Input: each script documents its own params in its doc header (e.g. `dataset`, `table_name`,
  `time_difference`, `key_column`). Scripting/time-travel/backfill entries bind params via
  `DECLARE ... DEFAULT` (edit the default or bind at call time); MERGE/cost_pruning entries bind
  via `@named` query parameters.
- Output: each script's doc header documents a literal `sample output` (columns + example values).
  For `dq_probes/table_health_probe.sql` specifically, the committed
  `sample_data/dq_events.csv` input and `sample_data/dq_probe_expected.json` expected output are
  exact and checked by both `local/run_local.py` and `tests/test_cookbook.py`.

## Run locally
`bash local/run_local.sh` — runs `src/cookbook/dq_probes/table_health_probe.sql`'s logic (via
DuckDB, adapted in `local/dq_probe_duckdb.sql`, or the pure-Python reference in
`local/dq_reference.py` if DuckDB isn't installed) against `sample_data/dq_events.csv`, and prints
the result compared against `sample_data/dq_probe_expected.json`. It also attempts
`src/cookbook/merge/generic_upsert.sql` (adapted in `local/generic_upsert_duckdb.sql`) against
`sample_data/orders_stg.json`, which needs DuckDB >= 1.4 (MERGE support); if the installed DuckDB
predates that, it prints a clear "not runnable in this environment, see docs/cloud_verify.md"
message rather than failing. For every other entry (scripting, time-travel, backfill,
cost_pruning) it prints a pointer to `docs/cloud_verify.md` — those are inherently BigQuery-only
or only meaningful against real BigQuery cost estimation, and this command always exits 0.

## Cloud-verify only
See `docs/cloud_verify.md` for the full breakdown. Summary: `scripting/`, `time_travel/`, and
`backfill/` entries use `EXECUTE IMMEDIATE`/`FOR SYSTEM_TIME AS OF`/scripting `FOR` loops that
have no DuckDB equivalent at all; `merge/generic_upsert.sql` needs DuckDB >= 1.4 for `MERGE INTO`
(not available in this sandbox, so it's cloud-verify only *here*); `cost_pruning/` is plain SQL
but its entire point (bytes billed at BigQuery's on-demand rate, partition pruning) has no local
equivalent. `bq query --dry-run` is the intended gate for GoogleSQL dialect/type-checking and
bytes-scanned cost estimation on every script in this cookbook — not installed in this sandbox,
documented only.
