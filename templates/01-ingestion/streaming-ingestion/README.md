# Task — Ingest the live stream

## Goal
Handle records that flow in continuously instead of as files.

## Context
The end state is hospitals wired directly to us; data arrives as a stream. The tech lead feeds the test events.

## Scope of work
Consume streaming clinical events and land them in BigQuery continuously; understand the delivery path (direct
subscription vs a processing path).

## Inputs & names
A Pub/Sub topic/subscription the tech lead feeds.

## Target
Streamed rows landing into the tables. The streaming-landing handling is defined in Stage 02 (BigQuery); this
task's final requirement points to [Stage 02 · Streaming landing](../../02-bigquery/streaming-landing/).

## Expectation
Published events appear in BigQuery promptly and correctly, no loss or duplication.

## Output
The streaming-ingestion script(s)/config.

## Bonus
Handle late or duplicate events.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Topic: `<PLACEHOLDER>`
- Subscription: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
