# Task — Staging dataset

## Goal
Give incoming batches a landing area before they're reconciled into the main tables.

## Context
Required by [Stage 01 · Batch incremental ingestion](../../01-ingestion/batch-incremental-ingestion/). Batches
can't be appended blindly — they land in staging first.

## Scope of work
Define the staging dataset and how a batch is placed there prior to merge.

## Inputs & names
Batch data from Stage 01's batch-ingestion task.

## Target
A staging dataset.

## Expectation
A batch can be staged and is ready to reconcile without touching the main tables yet.

## Output
The script(s) that define/populate staging.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Staging dataset: `<PLACEHOLDER>`
