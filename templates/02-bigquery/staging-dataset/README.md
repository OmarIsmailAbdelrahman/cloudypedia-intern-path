# Task — Staging Dataset

## Goal
Provide a dedicated dataset where arriving batches land and are reconciled in isolation before they ever reach
the curated tables the client reports on.

## Context & Scope
In Stage 01, the batch-incremental task landed each batch in a throwaway `<table>__load` table in the same
dataset as the target, then merged from it. That works, but it keeps the in-flight batch beside trusted data,
under the same access rules, and clutters the dataset with transient tables. This task replaces that with a
**dedicated staging dataset**: a reusable landing-and-reconcile zone kept separate from curated data.

Make it a *dataset*, not a stray load table, deliberately. A dataset is BigQuery's unit of isolation and
lifecycle: half-loaded batches stay walled off from the curated tables, so a bad file can never partially write
data people query; staging can carry its own access controls, so the accounts that write raw batches are not the
ones trusted against curated data; and a dataset-wide default expiration lets transient tables clean themselves
up instead of accumulating cost. Because it is a dataset, every ingest task lands in the same place with the same
conventions rather than inventing its own scratch table.

Your scope is the staging zone itself: define the dataset, and define how a batch is placed into it — loaded in,
ready to reconcile — leaving the curated tables untouched until the merge runs. The *reconcile* step (the `MERGE`
that folds staged rows into the curated tables, including slowly-changing history) is its own task
([SCD / upsert MERGE](../scd-upsert-merge/)); the broader naming, partitioning, and tier conventions belong to
[Dataset & tier design](../dataset-and-tier-design/).

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Source Bucket:** `gs://internship-preperation/Dataset/batch/` (the same batches the
  [Stage 01 · Batch incremental ingestion](../../01-ingestion/batch-incremental-ingestion/) task lands in a
  transient load table)
- **Staging Dataset:** `<you define>` (same region as the bucket and your curated datasets)

## Output & Deliverables
- A dedicated staging dataset, separate from your curated data, where an incoming batch is loaded and sits ready
  to reconcile without altering the curated tables — with staging's own access boundary and a lifecycle that
  keeps transient tables from piling up.
- The script(s) that create the staging dataset and load a batch into it, in `scripts/`.
- A `docs/` note stating why this improves on the Stage 01 in-dataset load table: isolation of in-flight data,
  independent access and retention, safe re-runs, and one clean seam for the merge to read from.

## Technical Constraints & Anti-Boilerplate Rules
- **Dataset, not a stray table.** Staging must be its own dataset with its own access boundary — not transient
  tables sitting inside the curated dataset.
- **Curated untouched.** Loading a batch into staging must not alter any curated table; reconciliation happens in
  a later task.
- **Reusable convention.** Every batch lands in staging the same way; do not invent a per-table scratch scheme.

## Bonus Objectives
- Give the staging dataset a default table expiration (or set it per staging table) so old batches age out
  automatically instead of sitting around costing storage.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Update dataset properties (default table expiration) — https://cloud.google.com/bigquery/docs/updating-datasets
- Managing tables (expiration) — https://cloud.google.com/bigquery/docs/managing-tables
- Batch loading data — https://cloud.google.com/bigquery/docs/batch-loading-data
- Controlling access to datasets — https://cloud.google.com/bigquery/docs/control-access-to-resources-iam
