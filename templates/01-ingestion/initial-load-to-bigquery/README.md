# Task — Load the Initial Extract into BigQuery

## Goal
Ingest the client's initial 31-table data export from Cloud Storage into BigQuery. This must be a clean,
schema-accurate, and fully idempotent load that serves as the uncorrupted foundation for every downstream
transformation.

## Context & Scope
The client gave us a head start: a one-time, frozen snapshot of their operational database, dropped as files in
Cloud Storage. Expect roughly 31 tables spanning the `hosp` and `icu` modules of their clinical dataset. It's
history, but it's also the first real data on the platform — everything downstream inherits whatever you land
here, so preserve the exact fidelity of the source: correct columns, strict data types, identical row counts.

Move the entire snapshot into BigQuery, one BigQuery table per source folder. Load directly into the target
dataset — do **not** build an intermediary "raw" staging area. Reach for BigQuery's own load jobs (`bq load`):
they're serverless, read the sharded files straight out of Cloud Storage through a single URI wildcard, and can
autodetect the schema — exactly the right weight for a one-shot bulk move, with no pipeline to stand up and no
cluster to manage.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Source Bucket:** `gs://internship-preperation/Dataset/initial/`
- **Target Dataset:** `<a dataset you create>` (must be in the **same region** as the bucket)
- **Structure:** one folder per table (`initial/<table>/`); each folder holds sharded files for that table
  (`<table>/*`).
- **File Format:** CSV, sharded, with a header row on each shard.

## Output & Deliverables
- A fully populated BigQuery dataset matching the source files exactly — one table per source folder, correct
  types, row counts identical to the source.
- The execution script(s) delivered in the `scripts/` directory.

Give the dataset an obvious name for the loaded tables; you'll formalize dataset and tier design in Stage 02, but
nothing here should wait on that.

## Technical Constraints & Anti-Boilerplate Rules
- **Idempotency is required.** Running your script twice must leave the warehouse in the exact same state as
  running it once. Prevent duplication — the cleanest path here is to *replace* the whole table on every run
  (hint: `WRITE_TRUNCATE` or the `--replace` flag). You can overwrite wholesale because you own the entire
  table; this is a frozen snapshot, not a delta. (A recurring batch carries only new rows and must merge instead
  — that's a later task; don't reach for it here.)
- **Zero hardcoding.** Do not write 31 separate load commands. Your script must dynamically discover the table
  names by reading the GCS directory structure.
- **Fault tolerance.** If one table fails to load (e.g. a schema mismatch), catch the exception, log the failure,
  and continue loading the rest. Never abort the entire batch for a single failure.

## Bonus Objectives
- Execute the table loads asynchronously / in parallel to drastically cut total execution time.

## References
- Loading data from Cloud Storage — https://cloud.google.com/bigquery/docs/loading-data-cloud-storage
- Batch loading & URI wildcards — https://cloud.google.com/bigquery/docs/batch-loading-data
- `bq load` reference — https://cloud.google.com/bigquery/docs/reference/bq-cli-reference#bq_load
- Schema auto-detection — https://cloud.google.com/bigquery/docs/schema-detect
