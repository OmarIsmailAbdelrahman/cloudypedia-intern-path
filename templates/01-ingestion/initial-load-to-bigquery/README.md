# Task — Load the initial extract into BigQuery

## Goal
Land the client's initial data export in BigQuery — cleanly, completely, and repeatably — as the foundation
every later stage builds on.

## Context & scope
The client gave us a head start: a one-time export of their operational database, dropped as files in Cloud
Storage. It's history — a frozen snapshot — but it's also the first real data on the platform, and everything
downstream inherits whatever you land here. Move all of it into BigQuery, one table per source table, faithful
to the original: right columns, right types, nothing dropped or mangled. Make the load idempotent — running it
twice should leave the warehouse exactly as running it once. Don't invent a separate "raw" staging layer; load
straight into the dataset.

## Inputs & names
The export lives under `gs://internship-preperation/Dataset/initial/`, with one folder per source table
(`initial/<table>/`) and each table split across several sharded files (`<table>/*`). Expect roughly 31 tables
spanning the `hosp` and `icu` modules of the clinical dataset.

## Output & expectations
A BigQuery dataset in your project holding every source table, fully populated with correct types and row
counts that match the source exactly — and a load you can re-run without creating duplicates or corruption. The
dataset's name and layout are settled in Stage 02 · Dataset & tier design. You deliver the load script(s) in
`scripts/`.

## Bonus
- Load the tables in parallel to cut the total time.
- Make it fault-tolerant: if one table fails, skip it, keep going, and report which one broke — never abort the
  whole run.

## References
- Loading data from Cloud Storage — https://cloud.google.com/bigquery/docs/loading-data-cloud-storage
- Batch loading & URI wildcards — https://cloud.google.com/bigquery/docs/batch-loading-data
- `bq load` reference — https://cloud.google.com/bigquery/docs/reference/bq-cli-reference#bq_load

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/initial/`
- Target dataset: `<dataset from Stage 02>` (same region as the bucket)
