# Task — Query Cookbook

## Goal
Demonstrate that the curated warehouse is usable in practice — a small, documented library of analytical queries
that answer real clinical questions correctly and cost-efficiently, and that establish the patterns worth
copying.

## Context & Scope
The curated layer exists; now it must be queried well. Analysts, engineers, and the Looker reporting model will
all read this data, and the first queries written tend to become the ones everyone copies — so the patterns set
here matter beyond their own answers. This is the closing Stage 02 task; unlike the
[curated / transform layer](../curated-transform-layer/), which *builds* tables, this task creates no new tables.
It reads the existing ones, well.

"Well" means correct and cost-aware at once. BigQuery bills by bytes scanned, not rows returned, so a `SELECT *`
over an unfiltered fact table reads every byte in it, every run. The most effective lever is *partition pruning*:
filter on the partitioning column (a date or timestamp) so the engine skips whole partitions, paired with
*cluster-aware filters* on the clustered columns so it narrows further within each partition — the same answer
for a fraction of the bytes. Writing filters the physical layout can exploit is the core skill of this task, and
where the earlier partitioning and clustering decisions finally pay off.

The cookbook should demonstrate a concrete spread of patterns, each earning its place on a real clinical
question:

- **Partition-pruned, cluster-aware filtering** — the baseline every query sits on: restrict to a time window
  and the clustered keys so you scan the least data possible.
- **Window functions** — `ROW_NUMBER`/`RANK` to deduplicate to the latest record per patient or encounter, and
  running or ranked metrics (running totals, latest-value-per-group, ordering events within an admission) that a
  plain `GROUP BY` cannot express.
- **Approximate aggregation** — `APPROX_COUNT_DISTINCT` and related functions for cardinality questions ("how
  many distinct patients / lab codes") where an exact count would scan and shuffle far more for precision nobody
  needs; knowing *when* the approximation is acceptable is the point.
- **Joins across the curated tables** written so they still prune, so a multi-table analytical query does not
  quietly become a full scan of both sides.

Throughout, treat `bq query --dry-run` (or the console's query validator) as a reflex: it estimates the bytes a
query *would* scan without running it, so the price is visible before it is paid and an accidental full scan is
caught early.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Dataset (curated):** `<you define>` — the typed, cleaned, partitioned-and-clustered tables from the
  [curated / transform layer](../curated-transform-layer/); query them as they stand.

## Output & Deliverables
- A cookbook of queries in `scripts/`, each runnable against the curated dataset, correct, and clearly the
  cheapest sensible way to get its answer.
- Coverage of the patterns above — a query is done only when its filters prune the partitions they can and lean
  on the clustered columns, not when it merely returns the right rows.
- Documentation for each query (what it answers, what it assumes, why it is written that way) so a teammate can
  reuse it without asking you.

## Technical Constraints & Anti-Boilerplate Rules
- **Prune, always.** Every query must filter on the partitioning column and, where relevant, the clustered
  columns; no unfiltered scans of fact tables.
- **No `SELECT *` on large tables.** Select only the columns needed; `SELECT *` over a fact table scans every
  byte.
- **Cost proven, not assumed.** Validate each query's estimated bytes scanned with `--dry-run` before running it.
- **Read-only.** Query the curated tables as they stand; do not reshape or reload them.

## Bonus Objectives
- Annotate each query with its dry-run cost (estimated bytes scanned) so readers see the price before they run
  it — and, where you optimized a query, show the before/after bytes so the saving is visible.

## References
- Controlling costs & estimating bytes scanned — https://cloud.google.com/bigquery/docs/best-practices-costs
- Estimate and control query costs (dry run) — https://cloud.google.com/bigquery/docs/estimate-costs
- Query optimization / performance best practices — https://cloud.google.com/bigquery/docs/best-practices-performance-overview
- Query partitioned & clustered tables (pruning) — https://cloud.google.com/bigquery/docs/querying-partitioned-tables
- Window (analytic) functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls
- Approximate aggregate functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/approximate_aggregate_functions
