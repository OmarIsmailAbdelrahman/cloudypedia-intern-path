# Task — Load the initial extract into BigQuery

## Goal
Get the client's initial database export out of Cloud Storage and into BigQuery as tables the rest of the
platform can build on.

## Context
This is the one-time historical snapshot the client handed us to start. Batches and streaming come in later
tasks — here you deal only with the initial export.

## Scope of work
Load every table from the initial export into a BigQuery dataset, one table per source table, preserving the
data faithfully. The load must be repeatable — running it again must not duplicate or corrupt anything. Do not
stage the data into a separate "raw" layer.

## Inputs & names
The initial export sits in the client's Cloud Storage bucket under the `initial/` path, one folder per source
table, each table split across several sharded files.

## Target
A BigQuery dataset holding the initial extract (exact dataset/naming coordinated with Stage 02).

## Expectation
Every source table present, fully loaded with correct types, row counts matching the source; re-running the
load is safe.

## Output
The populated dataset, plus the script(s) you write under `scripts/`.

## Bonus
Load the tables in parallel to go faster; and make it resilient — if one table fails, skip it and continue the
rest, reporting which failed (no whole-run abort).

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Source bucket: `<PLACEHOLDER>`
- Target dataset: `<PLACEHOLDER>`
