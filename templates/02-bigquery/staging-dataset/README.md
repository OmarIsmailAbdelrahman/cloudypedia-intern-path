# Task — Staging dataset

## Goal
Give arriving batches a dedicated place to land and be reconciled before they ever touch the curated tables the
client reports on.

## Context & scope
Back in Stage 01, the batch-incremental task got the job done the self-contained way: it landed each batch in a
throwaway `<table>__load` table sitting right next to the target, in the same dataset, then merged from it. That
works, but it's the quick version — the dirty, in-flight batch lives in the same dataset as your trusted data,
shares its access rules, and clutters it with transient tables. This task is the cleaner pattern that replaces
it: a **dedicated staging dataset** — a reusable landing and reconcile zone kept separate from curated data.

Make it a *dataset*, not just a stray load table, on purpose. A dataset is the unit BigQuery gives you for
isolation and lifecycle: dirty or half-loaded batches stay walled off from the curated tables, so a bad file can
never half-write the tables people query; you can grant staging its own access controls, so the people and
service accounts that write raw batches aren't the same ones trusted against curated data; and you can set a
dataset-wide default expiration so transient tables clean themselves up instead of accumulating cost. Because
it's a dataset and not a one-off table, every ingest task — this batch flow, and later ones — lands in the same
place with the same conventions instead of each inventing its own scratch table. That reuse and that lifecycle
control are the whole reason pros stage in a separate dataset rather than merging straight into curated tables.

Your scope is the staging zone itself: define the dataset, and define how a batch is placed into it — loaded in,
ready to be reconciled — leaving the curated tables untouched until the merge runs. What you're learning here is
the staging/landing-layer pattern: a clean seam between "data has arrived" and "data is trusted," which is where
every serious warehouse draws the line.

Keep the boundaries clear. The *reconcile* step — the `MERGE` that folds staged rows into the curated tables and
handles slowly-changing history — is its own task ([SCD / upsert MERGE](../scd-upsert-merge/)); staging just
holds the delta so that merge has a clean, isolated source to read from. The broader naming, partitioning, and
tier conventions for the curated side belong to [Dataset & tier design](../dataset-and-tier-design/). This task
is only the staging zone and getting a batch into it.

## Inputs & names
Batch data arriving from Stage 01, under `gs://internship-preperation/Dataset/batch/<table>/*` — the same batches
the [Stage 01 · Batch incremental ingestion](../../01-ingestion/batch-incremental-ingestion/) task currently
lands in a transient load table.

## Output & expectations
A dedicated staging dataset, separate from your curated data, where an incoming batch can be loaded and sit ready
to reconcile without altering the curated tables — with staging's own access boundary and a lifecycle that keeps
transient tables from piling up. You deliver the script(s) that create the staging dataset and load a batch into
it. The intern should be able to say why this beats the Stage-01 in-dataset load table: isolation of in-flight
data, independent access and retention, safe re-runs, and one clean seam for the merge to read from.

## Bonus
- Give the staging dataset a default table expiration (or set it per staging table) so old batches age out
  automatically and don't sit around costing storage.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Update dataset properties (default table expiration) — https://cloud.google.com/bigquery/docs/updating-datasets
- Managing tables (expiration) — https://cloud.google.com/bigquery/docs/managing-tables
- Batch loading data — https://cloud.google.com/bigquery/docs/batch-loading-data
- Controlling access to datasets — https://cloud.google.com/bigquery/docs/control-access-to-resources-iam

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/batch/`
- Staging dataset: `<you define>` (same region as the bucket and your curated datasets)
