# Task — Streaming landing

## Goal
Give the live stream a place to settle in BigQuery.

## Context
Required by [Stage 01 · Streaming ingestion](../../01-ingestion/streaming-ingestion/). Streamed rows need a
landing table with sane handling.

## Scope of work
Define the landing table/handling for streamed events (buffering, ordering, dedup).

## Inputs & names
Streamed rows from Stage 01's streaming task.

## Target
A streaming landing table.

## Expectation
Streamed events settle correctly; duplicates and late events are handled.

## Output
The script(s) that define the landing.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
- Landing table: `<PLACEHOLDER>`
