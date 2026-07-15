# Task — Staging dataset

## Goal
Give arriving batches a safe place to land before they touch the real tables.

## Context & scope
Batches can't be appended blind — you need somewhere to put a fresh batch, inspect it, and reconcile it before
it reaches the main tables. Define that staging area and how a batch is placed into it ahead of the merge. It's
the landing spot [Stage 01 · Batch incremental ingestion](../../01-ingestion/batch-incremental-ingestion/)
writes to.

## Inputs & names
Batch data arriving from Stage 01 (`gs://internship-preperation/Dataset/batch/`).

## Output & expectations
A staging dataset where a batch can sit, ready to reconcile, without yet altering the main tables. You deliver
the script(s) that define and populate staging.

## Bonus
- Give staging tables an automatic expiration so old batches clean themselves up and don't cost storage.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Managing tables — https://cloud.google.com/bigquery/docs/managing-tables
- Batch loading — https://cloud.google.com/bigquery/docs/batch-loading-data

## Config & naming
- Project: `<your-project-id>`
- Staging dataset: `<you define>`
