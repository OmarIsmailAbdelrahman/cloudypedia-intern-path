# Task — Ingest the recurring batches (incremental)

## Goal
Keep the warehouse current as new data arrives — folding in each batch without ever double-counting.

## Context & scope
The initial export was a one-off; real operations don't stop. The client keeps sending batches, and each one
has to join what's already loaded without creating duplicates or disturbing existing rows. Build ingestion
that takes a new batch and merges it in idempotently — safe to re-run, safe to replay.

## Inputs & names
Batch files under `gs://internship-preperation/Dataset/batch/<table>/*`, in the same per-table sharded shape as
the initial export.

## Output & expectations
Tables that hold the initial data plus every batch, with no duplicates and no damage when a batch is re-run.
Doing this cleanly needs a place to stage and reconcile, which lives in Stage 02 — so this task's final
requirement points to [Stage 02 · Staging dataset](../../02-bigquery/staging-dataset/) and
[Stage 02 · SCD / upsert MERGE](../../02-bigquery/scd-upsert-merge/). You deliver the batch-ingestion
script(s).

## Bonus
- Reuse the parallel-load and skip-on-failure approach from the initial-load task.

## References
- Batch loading (`WRITE_APPEND`) — https://cloud.google.com/bigquery/docs/batch-loading-data
- `MERGE` for idempotent upserts — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax#merge_statement
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/batch/`
- Dataset: `<your dataset>`
- Staging dataset: `<staging dataset from Stage 02>`
