# Task — Validate the Ingestion with a Manifest

## Goal
Build a manifest-driven validation that verifies each ingested delivery is complete and structurally correct,
and fails with a clear, actionable error the moment a table, shard, file, or column is missing or altered.

## Context & Scope
A data handoff is a contract: a known set of tables, each split into a known number of shards, each file
non-empty, each table carrying an agreed set of columns. Any of these can break without raising an error — a
table folder fails to arrive, a shard fails to transfer, a file lands at zero bytes, or a column is renamed
upstream. At 31 tables per delivery this cannot be verified by manual inspection, and in a regulated clinical
handoff an undetected omission (for example, a dropped lab table) silently narrows every downstream cohort built
on top of it.

Define what a complete, correct delivery looks like as an explicit **manifest** — the expected tables, their
shard counts, and their agreed columns — then implement a check that validates each run against it.

This task covers **delivery completeness and contract validation**, not statistical data quality. It answers
"did everything we were promised arrive, and did the load preserve it?" — table presence, shard counts,
non-empty files, and column shape. Value-level quality (nulls, ranges, distributions, duplicates) is a separate,
later stage. Keep this check lightweight and structural.

Use the appropriate tool for each layer: a **manifest file** you author (JSON/CSV/YAML listing expected tables,
shard counts, and columns) as the contract; **`gcloud storage ls`** with a size listing to confirm each expected
folder is present, count its shards, and detect zero-byte files without reading any rows; and BigQuery's
`INFORMATION_SCHEMA` on the loaded side — **`TABLES`** to confirm each expected table exists, **`COLUMNS`** to
confirm the agreed columns and types, and **`TABLE_STORAGE`** to read per-table row counts as metadata without
scanning the tables.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Source Bucket:** `gs://internship-preperation/Dataset/initial/` (one folder per table, `<table>/*` shards)
- **Loaded Dataset:** `<your dataset>` (the output of the initial-load task)
- **Manifest:** authored by you — the expected tables, shard counts, and columns that define a complete delivery.

## Output & Deliverables
- A **manifest** capturing the expected shape of a complete delivery.
- A **validation script** that passes only when reality matches the manifest — every expected table present,
  every shard accounted for, no empty files, the agreed columns in place, and per-table row counts reconciled.
- Both the manifest and the validation script(s) delivered in the `scripts/` directory.

## Technical Constraints & Anti-Boilerplate Rules
- **Manifest-driven, not hardcoded.** Expectations live in the manifest file, not in the script logic. Adding or
  removing a table from the contract must be a manifest edit, never a code change.
- **Actionable failures.** On any mismatch the check must exit non-zero and name the offending table and the
  specific gap — missing table, short shard count, empty file, or wrong columns — not fail with a generic error.
- **Read-free structural checks.** Verify presence, shard counts, and column shape from listings and
  `INFORMATION_SCHEMA` metadata. Do not scan table contents to establish structural completeness.
- **Scope discipline.** Validate structure and completeness only. Do not assert on value distributions, nulls, or
  ranges — that belongs to the data-quality stage.

## Bonus Objectives
- Print a per-table expected-vs-actual summary so a failure is diagnosable at a glance.
- Validate the delivery against the manifest at the Cloud Storage layer *before* loading, so a bad handoff is
  caught at ingestion rather than after it reaches the warehouse.

## References
- `INFORMATION_SCHEMA.TABLES` — https://cloud.google.com/bigquery/docs/information-schema-tables
- `INFORMATION_SCHEMA.COLUMNS` — https://cloud.google.com/bigquery/docs/information-schema-columns
- Table storage metadata (row counts) — https://cloud.google.com/bigquery/docs/information-schema-table-storage
- List objects with `gcloud storage ls` — https://cloud.google.com/sdk/gcloud/reference/storage/ls
