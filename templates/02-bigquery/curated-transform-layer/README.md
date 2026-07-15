# Task — Curated / Transform Layer

## Goal
Transform the landed, reconciled raw tables into a curated tier of clean, well-typed, conformed, analysis-ready
tables — built in warehouse SQL — that the rest of the platform can trust.

## Context & Scope
Ingestion and the merge leave data that is faithful but raw: source-shaped column names, inconsistent or
string-typed fields, coded values unreadable outside the source system, and the quirks of an operational clinical
database. Faithfulness is what ingestion should deliver, but it is not what the team should report on. This task
is the seam where raw becomes trustworthy: shape those tables into a **curated tier** of clean, typed, conformed,
analysis-ready tables the platform can build on without re-cleaning them every time.

Give the curated tables their own tier to separate *trusted, business-ready* data from the *raw and in-flight*
data behind it. Raw and staging may be messy, half-loaded, or mid-reconcile; curated is the guarantee that its
contents are clean and stable, so consumers — the cookbook, and later the reporting model — read from one
reliable place, and an upstream bad load cannot quietly corrupt it. The datasets and naming for this tier are
defined in [Dataset & tier design](../dataset-and-tier-design/); here you fill the curated tier with contents.

Do the transform in SQL, in BigQuery — the **T of ELT**. The data and the compute already live in the warehouse,
so clean and conform it *in place* rather than extracting to an external engine, transforming, and loading back.
A `SELECT` with the right casts, `CASE`s, and joins is the transform, run serverlessly against data BigQuery
already holds.

Materialize the results as tables (`CREATE TABLE AS SELECT`) rather than views, and know why. A view re-runs its
whole transform on *every* read, which is wasteful for curated data read constantly by the cookbook and
reporting; a materialized table pays the transform cost once, at build time, after which every downstream read is
a cheap scan of clean storage. (BigQuery *materialized views* are a middle ground — an auto-maintained cache —
but carry real constraints on the SQL they support; use them only where they clearly fit, and default to
materialized tables here.)

Carry the partition and cluster conventions through from tier design; do not re-derive them. Keep the boundaries
clean: curated *reads from* the reconciled main tables, it does not perform the reconcile; the ad-hoc query
patterns over this layer are the [Query cookbook](../query-cookbook/); and this is **not** the
dimensional/Kimball model, which is built later in Looker (Stage 07).

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Datasets (main source + curated target):** `<you define>` — read the main tables (the initial load from
  [Stage 01](../../01-ingestion/initial-load-to-bigquery/) plus the reconciled batches and stream); write a new
  curated dataset in the tiered layout from [Dataset & tier design](../dataset-and-tier-design/).

## Output & Deliverables
- A curated dataset of analytics-ready tables — consistently named, correctly typed, conformed, and documented
  well enough that a teammate can trust and use them without re-cleaning.
- The transform script(s) (SQL / `CREATE TABLE AS SELECT`) in `scripts/`, with the curated tables carrying the
  partition/cluster conventions through from tier design.
- A `docs/` note stating why these are materialized tables and not views, and why the cleaning happens in
  warehouse SQL (ELT) rather than an external engine.

## Technical Constraints & Anti-Boilerplate Rules
- **Materialized, not views.** Curated tables must be materialized (`CREATE TABLE AS SELECT`); do not leave the
  curated layer as views re-computed on every read.
- **Transform in-warehouse (ELT).** Clean and conform in BigQuery SQL; do not extract to an external engine and
  load back.
- **Read only reconciled tables.** Curated reads the reconciled main tables; it does not perform ingestion or the
  merge.
- **Apply conventions, do not re-derive.** Use the naming, partition, and cluster conventions settled in tier
  design.
- **Not the dimensional model.** Do not build facts, dimensions, or grain here; that is Looker (Stage 07).

## Bonus Objectives
- Make the transforms incremental — rebuild only the partitions or rows that changed instead of the whole layer —
  and schedule the rebuild so the curated tier refreshes on its own.

## References
- Data definition language (`CREATE TABLE AS SELECT`) — https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language
- Data manipulation language (DML) — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax
- Scheduling queries — https://cloud.google.com/bigquery/docs/scheduling-queries
- Introduction to materialized views — https://cloud.google.com/bigquery/docs/materialized-views-intro
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Clustered tables — https://cloud.google.com/bigquery/docs/clustered-tables
