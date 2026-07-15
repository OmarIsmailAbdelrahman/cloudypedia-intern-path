# Task — Validate the ingestion (manifest)

## Goal
Turn "the load looks fine" into proof — a manifest check that fails loudly the moment a delivery arrives
incomplete or a load drops something on the floor.

## Context & scope
Clinical data arrives as a handoff, and a handoff is a contract: a known set of tables, each split into a known
number of shards, each file non-empty, each table carrying the columns you agreed on. Any of those can silently
break — a table's folder never shows up, one shard fails to transfer, a file lands at zero bytes, a column gets
renamed upstream. You can't eyeball 31 tables after every run, and in a regulated handoff you can't fix what you
never noticed was missing: a dropped lab table doesn't error, it just quietly narrows every cohort built on top
of it downstream. So write down what a complete, correct delivery looks like — a manifest of expected tables,
their shard counts, and their agreed columns — and build the check that holds each run against it.

This is delivery-completeness and contract validation, not statistical data quality. You are asking "did
everything we were promised arrive, and did the load preserve it?" — presence, shard counts, non-empty files,
column shape — not "are the values plausible?" (nulls, ranges, distributions, duplicates), which is its own
stage later. Keep this one lightweight and structural.

The tools follow from that. A **manifest file** you author (a small JSON/CSV/YAML listing expected tables, shard
counts, and columns) is the contract you diff reality against — the artifact that makes "complete" checkable
instead of a feeling. **`gcloud storage ls`** (with a long/size listing) is the cheapest way to confirm each
expected table's folder is present, count its shards against the manifest, and catch any zero-byte file —
without reading a row. On the loaded side, **`INFORMATION_SCHEMA.TABLES`** confirms every expected table
actually exists in the dataset, **`INFORMATION_SCHEMA.COLUMNS`** confirms each carries the agreed columns and
types so a rename or dropped field surfaces, and **`INFORMATION_SCHEMA.TABLE_STORAGE`** reports row counts as
metadata — so you get a per-table count to reconcile without paying to scan the tables. What you learn is the
habit that separates a reliable ingestion from a hopeful one: encode the contract, then let a check enforce it.

## Inputs & names
The loaded dataset in your project, the source files under `gs://internship-preperation/Dataset/initial/<table>/`,
and the manifest of expectations you author to describe a complete delivery.

## Output & expectations
A manifest that captures what a good delivery looks like, and a validation that passes only when reality matches
it — every expected table present, every shard accounted for, no empty files, the agreed columns in place, and
per-table row counts reconciled. On any mismatch it fails loudly and names the offending table and the specific
gap (missing, short a shard, empty file, wrong columns) rather than failing vaguely — because a check you can't
act on is barely better than no check. You deliver the manifest and the validation script(s).

## Bonus
- Print a per-table expected-vs-actual summary so a failure is diagnosable at a glance.
- Validate the delivery against the manifest at the Cloud Storage layer *before* loading, so a bad handoff is
  caught at the door instead of after it's in the warehouse.

## References
- `INFORMATION_SCHEMA.TABLES` — https://cloud.google.com/bigquery/docs/information-schema-tables
- `INFORMATION_SCHEMA.COLUMNS` — https://cloud.google.com/bigquery/docs/information-schema-columns
- Table storage metadata (row counts) — https://cloud.google.com/bigquery/docs/information-schema-table-storage
- List objects with `gcloud storage ls` — https://cloud.google.com/sdk/gcloud/reference/storage/ls

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<your dataset>`
- Source bucket: `gs://internship-preperation/Dataset/initial/`
