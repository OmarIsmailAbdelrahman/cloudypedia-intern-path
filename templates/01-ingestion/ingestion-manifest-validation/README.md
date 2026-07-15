# Task — Validate the ingestion (manifest)

## Goal
Turn "the load looks fine" into proof — a check that fails loudly the moment ingestion is incomplete.

## Context & scope
A load can quietly go wrong: a table missing, a shard skipped, a file truncated. You can't eyeball 31 tables
after every run, so build the check that does it for you — confirming every expected table arrived and that
each one's row count matches what was delivered, and calling out by name anything that doesn't add up.

## Inputs & names
The loaded dataset in your project, plus the source files under
`gs://internship-preperation/Dataset/initial/<table>/`.

## Output & expectations
A validation that passes only when every table is present and every count matches, and on any mismatch names
the offending table instead of failing vaguely. You deliver the validation script(s).

## Bonus
- Print a per-table expected-vs-actual summary so a failure is diagnosable at a glance.

## References
- `INFORMATION_SCHEMA.TABLES` — https://cloud.google.com/bigquery/docs/information-schema-tables
- Table storage metadata — https://cloud.google.com/bigquery/docs/information-schema-table-storage
- List objects with `gcloud storage ls` — https://cloud.google.com/sdk/gcloud/reference/storage/ls

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<your dataset>`
- Source bucket: `gs://internship-preperation/Dataset/initial/`
