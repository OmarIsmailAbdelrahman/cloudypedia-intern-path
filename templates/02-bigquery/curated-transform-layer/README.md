# Task — Curated / transform layer

## Goal
Turn the landed, reconciled raw tables into a curated layer of clean, well-typed, conformed tables the rest of
the platform can trust — built in SQL, in the warehouse.

## Context & scope
What ingestion and the merge leave behind is faithful but raw: source-shaped column names, inconsistent or
string-typed fields, coded values nobody outside the source system can read, and all the quirks of an
operational clinical database. Faithful is exactly what you wanted from ingestion — but it's not what the team
should report on. This task is the seam where raw becomes trustworthy: shape those tables into a **curated tier**
of clean, typed, conformed, analysis-ready tables, and hand the platform something it can build on without
re-cleaning it every time.

Give the curated tables their own tier for the same reason every serious warehouse does: to separate *trusted,
business-ready* data from the *raw and in-flight* data behind it. Raw and staging can be messy, half-loaded, or
mid-reconcile; curated is the promise that what's here is clean and stable. Keeping that promise in a distinct
tier means consumers — the cookbook, and later the reporting model — read from one place they can rely on, and a
bad load upstream can't quietly poison it. (The datasets and naming for that tier are already drawn in
[Dataset & tier design](../dataset-and-tier-design/); here you're filling the curated tier with contents, not
inventing the map.)

Do the transform in SQL, in BigQuery — this is the **T of ELT**. The data already lives in the warehouse and so
does the compute, so you clean and conform it *in place* rather than pulling it out to some external engine,
transforming, and loading it back. There's no Spark cluster to stand up, no pipeline to babysit; a `SELECT` with
the right casts, `CASE`s, and joins is the transform, and BigQuery runs it serverlessly against data it already
holds. That's the whole appeal of ELT over ETL here, and learning to express cleaning-and-conforming as
warehouse SQL is the point of the task.

Materialize the results as tables (`CREATE TABLE AS SELECT`) rather than leaving them as views, and know why. A
view re-runs its whole transform on *every* read — every scan, cast, and join paid again each time someone
queries it — which is wasteful for curated data that's read constantly by the cookbook and, later, by reporting.
A materialized table pays the transform cost once, at build time, and every downstream read is then a cheap scan
of clean storage. That's a deliberate cost/performance trade for repeated reads: you spend storage and a
scheduled rebuild to stop re-computing the same clean-up over and over. (BigQuery's *materialized views* are a
middle ground — an auto-maintained cache of a query — but they carry real constraints on the SQL they support;
reach for them only where they clearly fit, and default to materialized tables for the general curation here.)

Carry the partition and cluster conventions through. These curated tables are the ones people actually query, so
this is where partitioning on the natural date/time key and clustering on the columns you filter and join on
actually earns its keep — pruning bytes scanned on exactly the reads that matter. Apply the conventions settled
in tier design; don't re-derive them.

Keep the boundaries clean. Staging is the landing zone and the merge that reconciles batches into the main
tables are earlier, separate tasks — curated *reads from* the reconciled main tables, it doesn't do the
reconcile. The ad-hoc, cost-aware query patterns over this layer are the [Query cookbook](../query-cookbook/),
not this task. And this is emphatically **not** the dimensional/Kimball model — facts, dimensions, and grain are
built much later in Looker (Stage 07). Here you're building the solid, clean physical tables the semantic model
will eventually sit on top of, not the semantic model itself. (Scheduling the rebuild so this layer refreshes on
its own is fine to lean on as a bonus, but orchestrating these transforms into a managed pipeline is a later
stage's job — don't build that here.)

## Inputs & names
The main tables — the initial load ([Stage 01](../../01-ingestion/initial-load-to-bigquery/)) plus the reconciled
batches and stream that the merge and streaming-landing tasks fold into them. You read those; you write a new
curated dataset alongside them, in the tiered layout from [Dataset & tier design](../dataset-and-tier-design/).

## Output & expectations
A curated dataset of analytics-ready tables — consistently named, correctly typed, conformed, and documented well
enough that a teammate can trust and use them without re-cleaning. You deliver the transform script(s) (SQL /
`CREATE TABLE AS SELECT`), and the curated tables carry the partition/cluster conventions through from tier
design. The intern should be able to say *why* these are materialized tables and not views — repeated reads make
paying the transform once, at build time, the cheaper and faster choice — and *why* the cleaning happens in
warehouse SQL rather than an external engine: the data and compute are already here, so ELT beats standing up a
separate transform tier.

## Bonus
- Make the transforms incremental — rebuild only the partitions or rows that changed instead of the whole layer —
  and schedule the rebuild so the curated tier refreshes on its own.

## References
- Data definition language (`CREATE TABLE AS SELECT`) — https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language
- Data manipulation language (DML) — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax
- Scheduling queries — https://cloud.google.com/bigquery/docs/scheduling-queries
- Introduction to materialized views — https://cloud.google.com/bigquery/docs/materialized-views-intro
- Partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Clustered tables — https://cloud.google.com/bigquery/docs/clustered-tables

## Config & naming
- Project: `<your-project-id>`
- Datasets (main source + curated target): `<you define>`
