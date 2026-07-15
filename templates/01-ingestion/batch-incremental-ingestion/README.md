# Task — Ingest the recurring batches (incremental)

## Goal
Add the batch drops that arrive after the initial load, without duplicating data.

## Context
After the first snapshot the client keeps sending new batches; each must be merged into what's already there.

## Scope of work
Load a new batch incrementally and idempotently — new records added, no duplicates, existing data intact.

## Inputs & names
Batch extract files in the client's Cloud Storage bucket under the `batch/` path, same per-table shape as the
initial export.

## Target
The same tables extended with batch rows. This needs a staging dataset — defined in Stage 02 (BigQuery); this
task's final requirement points to [Stage 02 · Staging dataset](../../02-bigquery/staging-dataset/).

## Expectation
Tables hold initial + batch with no duplicates; re-running a batch is safe.

## Output
The batch-ingestion script(s).

## Bonus
Parallel load + skip-on-failure (as in the initial-load task).

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Source bucket: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
- Staging dataset: `<PLACEHOLDER>`
