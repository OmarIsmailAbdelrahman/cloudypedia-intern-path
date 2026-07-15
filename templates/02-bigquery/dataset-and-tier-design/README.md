# Task — Dataset & tier design

## Goal
Lay the warehouse's foundation — the datasets and conventions every other task will build on.

## Context & scope
Before anyone loads, merges, or reports, the warehouse needs structure. Decide the datasets the platform will
use — including where the initial extract from Stage 01 actually lands — and set the conventions that keep it
coherent: naming, partitioning, and clustering. Choices here ripple through every later stage, so make them
deliberately rather than by default.

## Inputs & names
The tables landed by [Stage 01 · Initial load](../../01-ingestion/initial-load-to-bigquery/). Keep the datasets
in the same region as the `gs://internship-preperation/Dataset/` bucket.

## Output & expectations
Datasets that exist with consistent names, partition and cluster choices you can justify, and a location that
matches the bucket so loads work. You deliver the creation script(s) and a short conventions note in `docs/`.

## Bonus
- Add dataset labels and descriptions, and record why you chose each partition/cluster key as a short note.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Clustered tables — https://cloud.google.com/bigquery/docs/clustered-tables
- Dataset locations — https://cloud.google.com/bigquery/docs/locations

## Config & naming
- Project: `<your-project-id>`
- Dataset names + location: `<you define>`
