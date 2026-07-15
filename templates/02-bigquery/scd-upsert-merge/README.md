# Task — SCD / Upsert MERGE

## Goal
Reconcile staged rows into the main dimension tables so every batch lands cleanly and repeatably, and, where a
record's history matters, preserve past versions instead of overwriting them.

## Context & Scope
Staging holds what just arrived; the main tables hold the trusted record. Folding one into the other is exactly
where duplicates appear and history is quietly lost. Stage 01's
[batch-incremental task](../../01-ingestion/batch-incremental-ingestion/) used a single natural-key `MERGE`
(`WHEN MATCHED THEN UPDATE` / `WHEN NOT MATCHED THEN INSERT`) to keep the warehouse current without
double-counting; use `MERGE` again here, for the same reasons — it settles inserts, updates, and deletes against
a set-based source in one atomic statement, and replaying an already-applied batch matches every row and changes
nothing. This task builds on that merge and on the [Staging dataset](../staging-dataset/) it reads from.

What the batch task left implicit is *what an update does to the row it overwrites*. Overwriting in place is
Slowly Changing Dimension **Type 1**: the new value wins, the old value is gone, and the table shows only the
latest state. That is correct where the past does not matter. But some dimensions describe attributes that
genuinely change over time — a patient's recorded attributes, a care unit's details, the meaning behind a lab or
diagnosis reference code — and for those, losing the old value is a data-loss defect. A clinical warehouse must
be able to answer what a record looked like on the day an admission occurred; a two-year-old encounter cannot be
reinterpreted through today's reference data. This point-in-time requirement is non-negotiable for health data.

**Type 2** preserves that history: instead of overwriting, a change closes the current row and opens a new one,
each version carrying an effective timestamp, an expiry timestamp, and a current-record flag, so the table holds
the full timeline and a point-in-time question resolves to exactly one version. The cost is real — more rows, a
surrogate key per version, and a more careful `MERGE` (the standard approach routes a changed row through both an
expire-old-version arm and an insert-new-version arm). The design decision is explicit and per-dimension: Type 1
where simplicity wins and history is worthless, Type 2 where auditability justifies the extra machinery.

Stay on the mechanics of *one dimension's* upsert and history. This is not the place to design the full
dimensional model — conformed dimensions, the bus matrix, and the star schema for reporting come later in Looker.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Datasets (staging + main):** `<you define>` — the [Staging dataset](../staging-dataset/) holding freshly
  landed batches, and the main dimension tables they reconcile into.
- **SCD2 tracking columns:** `<effective_ts>`, `<expiry_ts>`, `<is_current>` (you name them)
- **Dimension choice:** pick at least one dimension whose attributes change over time for the Type 2 treatment
  (patient attributes or a reference/lookup dimension such as item or code descriptions are natural candidates);
  simpler dimensions can stay Type 1.

## Output & Deliverables
- Merge script(s) in `scripts/` that reconcile staged rows into the main dimension tables with no duplicates and
  no damage on re-run — identical row counts whether a batch is applied once or replayed.
- At least one dimension maintained as SCD Type 2: correct effective/expiry timestamps, a current-record flag,
  and exactly one current row per natural key, such that a point-in-time query returns the version that was live
  at any past instant. Type 1 dimensions overwrite in place.
- A `docs/` note stating, per dimension, whether you chose Type 1 or Type 2 and why.

## Technical Constraints & Anti-Boilerplate Rules
- **Idempotent MERGE.** Replaying an already-applied batch must not change row counts or create duplicates.
- **No history loss on SCD2.** A change must close the prior version and open a new one; never overwrite a Type 2
  row in place.
- **One current row per key.** SCD2 dimensions must have exactly one row flagged current per natural key at any
  time.
- **Deliberate, documented choice.** Type 1 vs Type 2 is decided per dimension and justified in `docs/`, not
  applied uniformly by default.
- **Time travel is not modeled history.** BigQuery time travel is a short operational safety net over a fixed
  recent window; do not rely on it to reconstruct the clinical past — that is what SCD2 rows are for.

## Bonus Objectives
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
