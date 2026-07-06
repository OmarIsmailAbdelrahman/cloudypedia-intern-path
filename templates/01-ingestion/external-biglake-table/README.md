# external-biglake-table

## What it is
A decision-support and DDL-generation toolkit for BigQuery's "query GCS data in place"
patterns. BigQuery can read data sitting in GCS without loading it via **external tables**
(no fine-grained IAM, no caching, DDL-only) or **BigLake tables** (external data wrapped
behind a BigLake connection, adding IAM-based fine-grained access control on the underlying
files and optional metadata caching for near-native performance). This template encodes,
as testable code, the central decision every engineer must make for a given access
pattern: **load natively into BigQuery** vs. **read in place** via a plain external table
vs. **read in place** via a BigLake table. Use it when designing a new BigQuery table over
GCS data and you need to justify (and later re-derive) which of the three strategies fits.
Prerequisites: Python 3.11+, `pytest` (for running the tests only — the library code itself
is stdlib-only).

## Input/output contract
- **Decision engine** (`src/decision.py::recommend_access_pattern`)
  - Input: a scenario `dict` with fields `query_frequency` (`"ad_hoc"` | `"frequent_bi"` |
    `"near_realtime"`), `needs_row_level_security` (bool), `needs_dml` (bool),
    `data_freshness_requirement_seconds` (int or `null`), `file_count` (int).
  - Output: one of the strings `"load_to_bigquery"`, `"external_table"`, `"biglake_table"`.
  - `sample_data/input.json`: a JSON array of named scenarios with the fields above.
  - `sample_data/output.json`: a JSON object keyed by each scenario's `"name"`, mapping to
    the expected `recommend_access_pattern` result — computed by actually running the code.
- **DDL generation** (`src/ddl.py`)
  - `generate_external_table_ddl(config)` / `generate_biglake_table_ddl(config)` take a
    config `dict` (see `config/config.example.yaml` for the exact keys) and return a
    `CREATE EXTERNAL TABLE ...` DDL string with the config's real values substituted in.
  - `validate_metadata_cache_config(config)` returns a list of error strings (empty = valid)
    for `metadata_cache_mode` / `max_staleness` problems.
- See `docs/diagram.md` for the full decision rule table and caching notes.

## Run locally
`bash local/run_local.sh` — runs the decision engine over `sample_data/input.json` and
prints JSON matching `sample_data/output.json`. Run tests with `python3 -m pytest tests`.

## Cloud-verify only
The following cannot be proven locally and need a supervised GCP step:
- Actually creating a BigLake connection and wiring its service account into IAM
  (fine-grained row-level / column-level access on real GCS objects).
- Observing real metadata cache refresh behavior and timing (`AUTOMATIC` refresh cadence,
  `MANUAL` refresh via `BQ.REFRESH_EXTERNAL_METADATA_CACHE`) against a live table.
- Query performance comparisons (external table vs. BigLake-cached vs. natively loaded)
  against a live GCS bucket with representative file counts/sizes.
- Actually running the generated DDL and querying the resulting external/BigLake table
  against live data in a real project.
