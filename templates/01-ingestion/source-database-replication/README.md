# Task — Replicate a source database

## Goal
Bring a live operational database onto the platform — and keep it in sync.

## Context & scope
Not every source hands us files. Some are running SQL databases we're expected to mirror continuously, so that
changes on the source show up on the platform. Set up replication from a source database into BigQuery, and
understand when continuous change-data-capture beats periodic full copies.

## Inputs & names
A source SQL database. Its connection details — host/ip, username, password — come from the tech lead and are
left blank for now.

## Output & expectations
Replicated tables in BigQuery that track the source and keep up as it changes. You deliver the replication
setup script(s) and config.

## Bonus
- Drive it with change-data-capture rather than repeated full reloads.

## References
- Datastream overview — https://cloud.google.com/datastream/docs/overview
- Replicate to BigQuery (Datastream) — https://cloud.google.com/datastream/docs/quickstart-replication-to-bigquery
- CDC behaviour — https://cloud.google.com/datastream/docs/behavior-overview

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<your dataset>`
- Source DB host/ip: `<TBD by tech lead>`
- Source DB username: `<TBD by tech lead>`
- Source DB password: `<TBD by tech lead>`
