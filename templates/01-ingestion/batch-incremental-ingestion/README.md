# Task — Ingest Recurring Batches (Incremental)

## Goal
Fold each newly arriving batch into the existing warehouse tables — updating changed rows and inserting new
ones — without ever double-counting or overwriting rows that are already correct, and run it on a schedule.

## Context & Scope
The initial export was a one-time snapshot; the client continues to deliver operational data as recurring
batches, and each must be integrated with what is already loaded. This differs fundamentally from the initial
load: that task *replaced* the whole table (idempotent by truncation), which is not viable here because the
target already holds history that must be preserved. Each batch must instead be reconciled against the existing
rows — insert the new rows, update the changed ones, leave the rest untouched — idempotently, so that replaying
an already-applied batch yields the same row count.

Implement this self-contained, without depending on later stages: land each incoming batch with `bq load` into a
**transient load table** in your dataset (e.g. `<table>__load`, truncated and refilled each run), then run a
single `MERGE` from that load table into the target, keyed on the natural key. Loading into a throwaway table
first isolates the raw batch so a malformed file cannot partially write the target, and gives `MERGE` a clean
set-based source. A single `WHEN MATCHED THEN UPDATE` / `WHEN NOT MATCHED THEN INSERT` pass is idempotent by
construction. Partition the target on a natural date/time column so each `MERGE` prunes to the affected
partitions instead of rewriting the whole table.

Then run it unattended: the simplest managed option is a **Cloud Run job** that executes your script, triggered
by **Cloud Scheduler** on a cron. A Cloud Run job runs to completion and exits, which fits a batch that fires,
loads, merges, and stops. (A dedicated staging dataset and a full orchestrator with dependencies and retries are
later refinements, not requirements here.)

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Source Bucket:** `gs://internship-preperation/Dataset/batch/` (same per-table sharded shape as the initial
  export, `<table>/*`)
- **Target Dataset:** `<your dataset>` (the tables produced by the initial-load task)
- **Transient Load Table:** `<table>__load` (in the same dataset)

## Output & Deliverables
- Target tables holding the initial data plus every batch merged in — no duplicates, and identical row counts
  whether a given batch is applied once or replayed.
- The batch-ingestion script(s) in `scripts/`: the `bq load` into the transient load table and the `MERGE` into
  the target, per table.
- A scheduled trigger (Cloud Run job invoked by Cloud Scheduler) that runs the load unattended on a cadence.

## Technical Constraints & Anti-Boilerplate Rules
- **Idempotency is required.** Replaying a batch that was already applied must not change the row count. Achieve
  this with a natural-key `MERGE`, not by appending.
- **No truncate-and-replace.** The target holds history; reconcile row by row. Do not reload the whole table as
  the initial-load task did.
- **Zero hardcoding.** Discover table names dynamically from the source structure; do not write one load/merge
  pair per table by hand.
- **Partition-pruned merges.** Partition the target on its natural date/time key so each `MERGE` touches only the
  affected partitions rather than rewriting the table.
- **Fault tolerance.** If one table fails, log it and continue with the rest; never abort the entire batch for a
  single failure.

## Bonus Objectives
- Reuse the parallel-load and skip-on-failure approach from the initial-load task.
- Handle a batch that redelivers rows from a previous batch (overlapping keys) so the `MERGE` still lands at the
  correct row count.

## References
- Batch loading data (`bq load`, `WRITE_TRUNCATE` for the load table) — https://cloud.google.com/bigquery/docs/batch-loading-data
- `MERGE` statement — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax#merge_statement
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Cloud Run jobs — https://cloud.google.com/run/docs/create-jobs
- Trigger a Cloud Run job on a schedule with Cloud Scheduler — https://cloud.google.com/run/docs/execute/jobs-on-schedule
