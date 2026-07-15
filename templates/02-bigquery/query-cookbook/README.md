# Task — Query cookbook

## Goal
Capture the warehouse's good habits as reusable, cost-aware queries.

## Context & scope
Everyone will query this data, and BigQuery rewards — and punishes — how you do it. Build a small, documented
library of query patterns over the curated data that show the team how to work efficiently: pruning
partitions, keeping cost down, and using window functions well.

## Inputs & names
The curated dataset (from [Curated / transform layer](../curated-transform-layer/)).

## Output & expectations
A cookbook of queries in `scripts/` that run correctly, stay cost-aware, and are documented well enough for the
team to reuse.

## Bonus
- Annotate each query with its dry-run cost (bytes scanned) so readers see the price before they run it.

## References
- Controlling costs — https://cloud.google.com/bigquery/docs/best-practices-costs
- Query performance — https://cloud.google.com/bigquery/docs/best-practices-performance-overview
- Window functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls

## Config & naming
- Project: `<your-project-id>`
- Dataset (curated): `<you define>`
