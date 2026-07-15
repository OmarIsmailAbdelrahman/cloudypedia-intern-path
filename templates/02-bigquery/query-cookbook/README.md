# Task — Query cookbook

## Goal
Prove the curated warehouse is actually usable: a small, documented library of analytical queries that answer
real clinical questions correctly *and* cheaply, and that show the team the habits worth copying.

## Context & scope
The curated layer exists; now someone has to query it. Analysts, engineers, and the reporting model in Looker
will all lean on this data, and the queries they write first tend to become the queries everyone copies — so
the patterns you set down here matter beyond your own answers. This is the closing Stage-02 task, and unlike the
[curated / transform layer](../curated-transform-layer/) — which *builds* tables — you're not creating any new
tables here. You're reading the ones that exist, well.

"Well" means two things at once: correct, and cost-aware. BigQuery bills by bytes scanned, not by rows returned
or time spent, so a query that looks harmless can be expensive — a `SELECT *` over an unfiltered fact table
reads every byte in it, every run. The single most effective lever is *partition pruning*: filter on the
partitioning column (a date or timestamp) so the engine skips whole partitions instead of scanning the table,
and pair it with *cluster-aware filters* that hit the clustered columns so it can narrow further within each
partition. Same answer, a fraction of the bytes. Learning to write filters that the physical layout can exploit
is the core skill of this task — it's where the partitioning and clustering decisions from earlier Stage-02
tasks finally pay off.

The cookbook should demonstrate a concrete spread of patterns, each earning its place on a real clinical
question:

- **Partition-pruned, cluster-aware filtering** — the baseline for every query: restrict to a time window and
  the clustered keys so you scan the least data possible. This is the cost habit everything else sits on.
- **Window functions** — `ROW_NUMBER`/`RANK` to deduplicate to the latest record per patient or encounter,
  and running or ranked metrics (running totals, latest-value-per-group, ordering events within an admission)
  that a plain `GROUP BY` can't express. These are the workhorse analytical patterns on event data like this.
- **Approximate aggregation** — `APPROX_COUNT_DISTINCT` and friends for cardinality questions ("how many
  distinct patients / lab codes") where an exact count would scan and shuffle far more for precision nobody
  needs. It's the cheap-at-scale answer, and knowing *when* the approximation is acceptable is the point.
- **Joins across the curated tables** done in a way that still prunes — so a multi-table analytical query
  doesn't quietly become a full scan of both sides.

Throughout, treat `bq query --dry-run` (or the console's query validator) as a reflex: it estimates the bytes a
query *would* scan without running it, so you can see the price before you pay it and catch an accidental full
scan before it costs anything. Building that check into how you write queries — not just how you review them —
is a large part of what this task teaches. What you walk away with is the ability to write analytical SQL on a
real warehouse that is both right and economical, and to *prove* it's economical before you hit run.

## Inputs & names
The curated dataset from [Curated / transform layer](../curated-transform-layer/) — the typed, cleaned,
partitioned-and-clustered tables. You query these as they stand; you don't reshape or reload them.

## Output & expectations
A cookbook of queries in `scripts/`, each one runnable against the curated dataset, correct, and clearly the
cheapest sensible way to get its answer. Cover the patterns above — a query is only "done" when its filters
prune the partitions they can and lean on the clustered columns, not when it merely returns the right rows.
Document each query well enough that a teammate can reuse it without asking you: what question it answers, what
it assumes, and why it's written the way it is. Together the set should read as the team's reference for
querying this warehouse well.

## Bonus
- Annotate each query with its dry-run cost (estimated bytes scanned) so readers see the price before they run
  it — and, where you optimized a query, show the before/after bytes so the saving is visible.

## References
- Controlling costs & estimating bytes scanned — https://cloud.google.com/bigquery/docs/best-practices-costs
- Estimate and control query costs (dry run) — https://cloud.google.com/bigquery/docs/estimate-costs
- Query optimization / performance best practices — https://cloud.google.com/bigquery/docs/best-practices-performance-overview
- Query partitioned & clustered tables (pruning) — https://cloud.google.com/bigquery/docs/querying-partitioned-tables
- Window (analytic) functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/window-function-calls
- Approximate aggregate functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/approximate_aggregate_functions

## Config & naming
- Project: `<your-project-id>`
- Dataset (curated): `<you define>`
