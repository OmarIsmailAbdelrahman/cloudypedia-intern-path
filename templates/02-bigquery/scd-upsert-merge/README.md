# Task — SCD / upsert MERGE

## Goal
Fold staged data into the main tables idempotently, with no duplicates.

## Context
Batches and updates must reconcile cleanly; some data changes over time (slowly-changing).

## Scope of work
Use `MERGE` to upsert staging into the main tables, and handle slowly-changing-dimension cases.

## Inputs & names
The staging dataset (from the staging-dataset task).

## Target
The reconciled main tables.

## Expectation
Re-running a merge is safe; no duplicates; history handled where required.

## Output
The merge script(s).

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Datasets: `<PLACEHOLDER>`
