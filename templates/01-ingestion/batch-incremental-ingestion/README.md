# Task — Ingest the recurring batches (incremental)

## Goal
Keep the warehouse current as new batches arrive — folding each one into a table that keeps growing, without
ever double-counting or clobbering rows that are already correct.

## Context & scope
The initial export was a one-off; real operations don't stop. The client keeps sending batches, and each one
has to join what's already loaded. This is where the skill diverges from the initial load: that task REPLACED
the whole table, so re-running it was idempotent by truncation. You can't do that here — the table already
holds history you must keep, so a batch has to be reconciled row by row against what's there: insert the rows
that are new, update the ones that changed, leave the rest untouched. Build ingestion that does exactly that,
idempotently — safe to re-run, safe to replay a batch you already applied, with the same row count either way.

The self-contained way to do this cleanly, without pulling in later stages: land each incoming batch with
`bq load` into a **transient load table** in your dataset (its own table, e.g. `<table>__load`, truncated and
refilled each run), then run a single `MERGE` from that load table into the target keyed on the natural key.
Loading into a throwaway table first keeps the raw batch isolated so a bad file can't half-write the target,
and gives `MERGE` a clean set-based source to reconcile against in one atomic statement. `MERGE` is the point
of the task: one `WHEN MATCHED ... THEN UPDATE` / `WHEN NOT MATCHED ... THEN INSERT` pass is idempotent by
construction — replaying the same batch matches every row and changes nothing, so there is no double-count on
replay. Partition the target on a natural date/time column so each `MERGE` prunes to the affected partitions
instead of rewriting the whole table — cheaper every time a batch lands, which matters because this runs
forever. Drop the load table when you're done, or overwrite it on the next run. You keep everything in one
dataset; a dedicated staging dataset is a later refinement, not a requirement here.

## Inputs & names
Batch files under `gs://internship-preperation/Dataset/batch/<table>/*`, in the same per-table sharded shape as
the initial export.

## Output & expectations
Tables that hold the initial data plus every batch merged in — no duplicates, no damage when a batch is
re-run, and identical row counts whether a given batch was applied once or twice. You deliver the
batch-ingestion script(s): the `bq load` into the transient load table plus the `MERGE` into the target,
per table.

Then make it run unattended on a cadence. The simplest managed way, with no standing infrastructure to babysit,
is a **Cloud Run job** that executes your script, triggered by **Cloud Scheduler** on a cron. A Cloud Run job
runs to completion and exits (unlike a service that stays up waiting for requests), which is the right shape
for a batch that fires, loads, merges, and stops; Cloud Scheduler is a plain managed cron that invokes it on
schedule so nobody has to launch it by hand. What you learn here is the pair of skills every ingestion
pipeline needs: incremental upsert ingestion, and running a job on a schedule. (A full orchestrator with
dependencies and retries is a better fit once pipelines get complex — that's a later stage, not this one.)

## Bonus
- Reuse the parallel-load and skip-on-failure approach from the initial-load task.
- Handle a batch that redelivers rows from a previous batch (overlapping keys) — the `MERGE` should still land
  at the correct row count.

## References
- Batch loading data (`bq load`, `WRITE_TRUNCATE` for the load table) — https://cloud.google.com/bigquery/docs/batch-loading-data
- `MERGE` statement — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax#merge_statement
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Cloud Run jobs — https://cloud.google.com/run/docs/create-jobs
- Trigger a Cloud Run job on a schedule with Cloud Scheduler — https://cloud.google.com/run/docs/execute/jobs-on-schedule

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/batch/`
- Dataset: `<your dataset>`
- Transient load table: `<table>__load` (in the same dataset)
