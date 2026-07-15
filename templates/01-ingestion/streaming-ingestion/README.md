# Task — Ingest the live stream

## Goal
Take data the moment it's produced — a continuous feed instead of a file drop.

## Context & scope
The client's endgame is hospitals wired straight to us, sending records as they happen. To stand in for that,
the tech lead publishes the `stream/` split to a Pub/Sub topic. Consume that stream and land it in BigQuery
continuously, and weigh the delivery paths against each other — a direct Pub/Sub-to-BigQuery subscription
versus routing through a processing step.

## Inputs & names
A Pub/Sub topic and subscription the tech lead feeds (the source is the `stream/` split of the extract).

## Output & expectations
Events flowing into BigQuery promptly and correctly — nothing lost, nothing duplicated. The landing table
itself is defined in Stage 02, so this task's final requirement points to
[Stage 02 · Streaming landing](../../02-bigquery/streaming-landing/). You deliver the streaming-ingestion
script(s) and config.

## Bonus
- Handle late-arriving and duplicate events gracefully.

## References
- Pub/Sub BigQuery subscription — https://cloud.google.com/pubsub/docs/bigquery
- BigQuery Storage Write API — https://cloud.google.com/bigquery/docs/write-api
- Pull subscriptions — https://cloud.google.com/pubsub/docs/pull

## Config & naming
- Project: `<your-project-id>`
- Topic: `<topic from tech lead>`
- Subscription: `<your-subscription-id>`
- Dataset: `<your dataset>`
