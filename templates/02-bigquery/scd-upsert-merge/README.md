# Task — SCD / upsert MERGE

## Goal
Reconcile staged data into the main tables — cleanly, repeatably, and without duplicates.

## Context & scope
Staging holds what's new; the main tables hold the truth. Bringing one into the other is exactly where
duplicates and lost history creep in. Use `MERGE` to upsert staged rows into the main tables, and handle the
cases where a record changes over time (slowly-changing dimensions) instead of silently overwriting it.

## Inputs & names
The staging dataset (from [Staging dataset](../staging-dataset/)).

## Output & expectations
Main tables that reflect every reconciled batch with no duplicates, stay safe to re-run, and preserve history
wherever it matters. You deliver the merge script(s).

## Bonus
- Support slowly-changing-dimension **type 2** (keep history rows), not just overwrite-in-place.

## References
- `MERGE` statement — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax#merge_statement
- Using DML — https://cloud.google.com/bigquery/docs/data-manipulation-language
- Change data capture with BigQuery — https://cloud.google.com/bigquery/docs/change-data-capture

## Config & naming
- Project: `<your-project-id>`
- Datasets (staging + main): `<you define>`
