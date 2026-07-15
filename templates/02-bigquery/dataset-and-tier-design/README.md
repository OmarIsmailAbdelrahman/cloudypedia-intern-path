# Task — Dataset & tier design

## Goal
Lay the warehouse's foundation — the datasets, tiers, and conventions every other Stage-02 task will build on.

## Context & scope
Before anyone loads, merges, or reports, the warehouse needs a shape. This is where you decide it. Every later
task — the initial load, staging, the streaming landing, the merges, the curated layer — plugs into the map you
draw here, so draw it deliberately rather than letting it accrete one `bq mk` at a time.

Start from the dataset, because in BigQuery the dataset is the unit that matters: it's how you organize tables,
it's where region is pinned, and it's the level access is granted at. That makes datasets the natural seam
between tiers. Split the warehouse into a small tiered layout — a landing/raw tier where ingestion drops data
faithfully, a staging tier where a batch or stream can be inspected and reconciled in isolation, and a
curated tier of clean, trustworthy tables the rest of the platform reads from. Tiers earn their keep by
separating concerns: each has a different job, a different lifecycle (staging is disposable, curated is
durable), and a different audience, so keeping them in distinct datasets contains the blast radius of a bad
load and lets you grant access per tier instead of per table. The initial load from
[Stage 01](../../01-ingestion/initial-load-to-bigquery/) says its dataset and layout are "settled in Stage 02" —
this is that decision, and you own it. The later Stage-02 tasks ([staging](../staging-dataset/),
[streaming landing](../streaming-landing/), [curated](../curated-transform-layer/)) each fill in one tier;
your job here is the map and the conventions, not the contents.

This is physical organization, not the reporting model. The dimensional/Kimball design — facts, dimensions,
grain — comes much later in Looker. Don't build it here; here you're deciding datasets, tiers, and the naming,
partition, and cluster conventions the semantic model will eventually sit on top of.

## Inputs & names
The tables landed by [Stage 01 · Initial load](../../01-ingestion/initial-load-to-bigquery/), plus the batch
and stream tiers you're making room for. Keep every dataset in the same region as the
`gs://internship-preperation/Dataset/` bucket.

## Output & expectations
A set of datasets that exist with consistent, obvious names, one per tier, all pinned to the bucket's region —
and a short conventions note in `docs/` that a teammate could follow without asking you. Region matters and
isn't a free choice: `bq load` reads from Cloud Storage and requires the dataset and the bucket to be
co-located, so a mismatch fails the load outright — match the bucket and every later ingestion task just works.

Settle the partition and cluster conventions too, and be able to justify them. Partitioning splits a table by a
column (or ingestion time) so a filtered query scans only the partitions it needs; clustering sorts data within
each partition so BigQuery can skip blocks that can't match. Both cut bytes scanned, which in BigQuery is what
you pay for and what determines how fast a query returns — so a sensible default (partition large tables on
their natural date/time key, cluster on the columns you'll filter and join on) is a cost and performance
decision, not decoration. You're setting the convention here, not tuning every table; later tasks apply it.

## Bonus
- Add dataset labels and descriptions so the tiers are self-documenting, and record in your note why you chose
  each partition/cluster key.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Dataset locations — https://cloud.google.com/bigquery/docs/locations
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Clustered tables — https://cloud.google.com/bigquery/docs/clustered-tables

## Config & naming
- Project: `<your-project-id>`
- Dataset names (one per tier) + location: `<you define>` (same region as the bucket)
