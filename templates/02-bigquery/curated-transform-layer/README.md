# Task — Curated / transform layer

## Goal
Turn landed data into clean, trustworthy tables the rest of the platform can rely on.

## Context & scope
What ingestion leaves behind is faithful but raw — inconsistent types, quirks, source-shaped naming.
Downstream stages and reporting need better than that. Shape the landed tables into a curated layer that's
typed, cleaned, and conformed. The dimensional model comes later, in Looker; here you're building the solid
physical tables underneath it.

## Inputs & names
The main tables (initial load plus reconciled batches and stream).

## Output & expectations
A curated dataset of analytics-ready tables — consistent, well-typed, and documented. You deliver the transform
script(s) (SQL / `CREATE TABLE AS`).

## Bonus
- Make the transforms incremental — rebuild only what changed instead of the whole layer.

## References
- Data definition language (`CREATE TABLE AS`) — https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language
- Scheduling queries — https://cloud.google.com/bigquery/docs/scheduling-queries
- Working with tables — https://cloud.google.com/bigquery/docs/tables

## Config & naming
- Project: `<your-project-id>`
- Datasets (main + curated): `<you define>`
