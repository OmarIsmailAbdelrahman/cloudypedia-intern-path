# Task — Streaming landing

## Goal
Give the live stream a first stop in BigQuery — a landing table built for continuous, messy arrivals.

## Context & scope
Streamed events don't arrive neatly: they can be duplicated, out of order, or late. Before they can be trusted,
they need a landing table designed for that reality — buffering, ordering, and de-duplication. This is what
[Stage 01 · Streaming ingestion](../../01-ingestion/streaming-ingestion/) writes into.

## Inputs & names
Streamed rows arriving from Stage 01's streaming task.

## Output & expectations
A landing table where streamed events settle correctly, with duplicates and late arrivals handled rather than
trusted blindly. You deliver the script(s) that define it.

## Bonus
- Add a scheduled step that compacts and de-duplicates the landing table into the main tables.

## References
- BigQuery Storage Write API — https://cloud.google.com/bigquery/docs/write-api
- Pub/Sub BigQuery subscription — https://cloud.google.com/pubsub/docs/bigquery
- Ingestion-time partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables#ingestion_time

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<you define>`
- Landing table: `<you define>`
