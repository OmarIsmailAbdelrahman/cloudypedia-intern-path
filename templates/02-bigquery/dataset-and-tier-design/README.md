# Task — Dataset & Tier Design

## Goal
Define the warehouse's physical foundation — the datasets, tiers, and naming/partitioning/clustering conventions
that every other Stage 02 task builds on.

## Context & Scope
Before any load, merge, or report, the warehouse needs a deliberate structure. Every later task — the initial
load, staging, the streaming landing, the merges, the curated layer — plugs into the layout defined here, so it
should be designed intentionally rather than accreting one `bq mk` at a time.

Start from the dataset, which in BigQuery is the unit that organizes tables, pins region, and carries access
grants — making it the natural boundary between tiers. Split the warehouse into a small tiered layout: a
landing/raw tier where ingestion drops data faithfully, a staging tier where a batch or stream is inspected and
reconciled in isolation, and a curated tier of clean, trustworthy tables the rest of the platform reads from.
Tiers separate concerns: each has a distinct job, a distinct lifecycle (staging is disposable, curated is
durable), and a distinct audience, so keeping them in separate datasets contains the blast radius of a bad load
and lets you grant access per tier instead of per table. The initial load in
[Stage 01](../../01-ingestion/initial-load-to-bigquery/) defers its dataset and layout to Stage 02 — this is that
decision, and you own it.

This is physical organization, not the reporting model. The dimensional/Kimball design — facts, dimensions,
grain — is built later in Looker. Here you decide datasets, tiers, and the naming, partition, and cluster
conventions the semantic model will eventually sit on top of.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Datasets (one per tier) + location:** `<you define>` (same region as the
  `gs://internship-preperation/Dataset/` bucket)
- **Building on:** the tables landed by [Stage 01 · Initial load](../../01-ingestion/initial-load-to-bigquery/),
  plus the batch and stream tiers you are making room for.

## Output & Deliverables
- A set of datasets, one per tier, with consistent, obvious names, all pinned to the bucket's region.
- A short conventions note in `docs/` — naming, partitioning, and clustering — that a teammate could follow
  without asking you.

## Technical Constraints & Anti-Boilerplate Rules
- **Region co-location.** Every dataset must be in the same region as the source bucket; `bq load` reads from
  Cloud Storage and requires the dataset and bucket to be co-located, or the load fails outright.
- **Tiers as datasets.** Separate raw/landing, staging, and curated into distinct datasets, not one dataset with
  mixed tables.
- **Conventions, not contents.** Define the naming, partition, and cluster conventions; do not populate the
  tables — later tasks apply the conventions. Partition large tables on their natural date/time key and cluster
  on the columns that will be filtered and joined on, and be able to justify each choice.
- **Physical only.** Do not build the dimensional/reporting model here; that belongs to Looker (Stage 07).

## Bonus Objectives
- Add dataset labels and descriptions so the tiers are self-documenting, and record in your note why you chose
  each partition/cluster key.

## References
- Datasets — https://cloud.google.com/bigquery/docs/datasets
- Dataset locations — https://cloud.google.com/bigquery/docs/locations
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Clustered tables — https://cloud.google.com/bigquery/docs/clustered-tables
