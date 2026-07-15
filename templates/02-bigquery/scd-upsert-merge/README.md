# Task — SCD / upsert MERGE

## Goal
Reconcile staged rows into the main dimension tables so every batch lands cleanly and repeatably — and, where
the record's past matters, keep its history instead of overwriting it away.

## Context & scope
Staging holds what just arrived; the main tables hold the truth. Folding one into the other is exactly where
duplicates creep in and history quietly disappears. You've already met the tool that fixes the first problem:
[Stage 01 · Batch incremental ingestion](../../01-ingestion/batch-incremental-ingestion/) used a single
`MERGE` — keyed on the natural key, `WHEN MATCHED THEN UPDATE` / `WHEN NOT MATCHED THEN INSERT` — to keep the
warehouse current without double-counting. Reach for `MERGE` again here, and for the same reasons: it settles
inserts, updates, and deletes against a set-based source in one atomic statement, and replaying a batch you
already applied matches every row and changes nothing, so it's idempotent by construction. This task builds
straight on that merge and on the [Staging dataset](../staging-dataset/) it reads from.

What the batch task glossed over is *what an update does to the row it overwrites*. Overwriting in place is
Slowly Changing Dimension **Type 1**: the new value wins, the old value is gone, and the table only ever shows
the latest state. That's fine — correct, even — for a dimension where the past doesn't matter. But some
dimensions describe things that genuinely change over time: a patient's recorded attributes, a care unit's
details, the human-readable meaning behind a lab or diagnosis reference code. For those, "the old value is
gone" is a data-loss bug wearing a merge's clothes. In a clinical warehouse you have to be able to answer *what
did this record look like on the day that admission happened* — you cannot re-interpret a two-year-old encounter
through today's version of the reference data. That reconstruct-the-past requirement is the whole reason
auditable warehouses exist, and it's non-negotiable for health data.

**Type 2** is how a dimension keeps that history. Instead of overwriting, a change closes the current row and
opens a new one: each version carries an effective timestamp, an expiry timestamp, and a current-record flag,
so the table holds the full timeline and a point-in-time question resolves to exactly one version. The cost is
real — more rows, a surrogate key per version, and a more careful `MERGE` (the classic trick is to route a
changed row through both an update-the-old-version arm and an insert-the-new-version arm). So the design
decision is explicit and per-dimension: SCD1 where simplicity wins and history is worthless, SCD2 where
auditability is worth the extra machinery. Making that call deliberately, and implementing both, is the point
of this task.

Stay on the mechanics of *one dimension's* upsert and history. This is not the place to design the full
dimensional model — the conformed dimensions, the bus matrix, the star schema for reporting all come later in
Looker. Here you're proving you can maintain a single dimension table correctly over time.

## Inputs & names
The [Staging dataset](../staging-dataset/) holding freshly landed batches, and the main dimension tables they
reconcile into. Pick at least one dimension whose attributes actually change over time to carry the Type 2
treatment (patient attributes or a reference/lookup dimension such as item or code descriptions are natural
candidates); simpler dimensions can stay Type 1.

## Output & expectations
Merge script(s) that reconcile staged rows into the main dimension tables with no duplicates and no damage on
re-run — identical row counts whether a batch is applied once or replayed. At least one dimension keeps full
history as SCD Type 2: correct effective/expiry timestamps, a current-record flag, and exactly one current row
per natural key, such that a point-in-time query returns the version that was live at any past instant. Type 1
dimensions overwrite in place. You deliver the merge script(s) in `scripts/`, and your `docs/` should state,
per dimension, whether you chose Type 1 or Type 2 and why. What you walk away with is dimensional history
management — the core discipline that makes a warehouse trustworthy rather than merely current.

Note that BigQuery's time travel lets you query a table as of a recent moment, but it's a short operational
safety net (a fixed recent window), not a substitute for modeled history: it can't answer questions older than
its window and it isn't part of your analytical schema. Reconstructing the clinical past is a job for SCD2 rows,
not for time travel.

## Bonus
- Handle deletes: when a source stops sending a key, close its current SCD2 row (expire it, clear the current
  flag) instead of leaving a stale record marked current.
- Write the point-in-time query that reconstructs a chosen dimension as it stood on an arbitrary past date, and
  confirm it returns exactly one row per key.
- Apply the Type 2 pattern across more than one dimension and factor the merge into a reusable, parameterized
  shape rather than copy-pasting per table.

## References
- `MERGE` statement — https://cloud.google.com/bigquery/docs/reference/standard-sql/dml-syntax#merge_statement
- Using data manipulation language (DML) — https://cloud.google.com/bigquery/docs/data-manipulation-language
- Stream table updates with change data capture — https://cloud.google.com/bigquery/docs/change-data-capture
- Time travel (querying historical data) — https://cloud.google.com/bigquery/docs/access-historical-data

## Config & naming
- Project: `<your-project-id>`
- Datasets (staging + main): `<you define>`
- SCD2 tracking columns: `<effective_ts>`, `<expiry_ts>`, `<is_current>` (you name them)
