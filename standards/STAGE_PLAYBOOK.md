# Stage Playbook

How every stage of the platform is built, plus the full specification of the stages that are ready. Stages
are filled in as they're designed — anything marked **TBD** below is intentionally not built yet.

## How a stage is built

Each stage has three levels:

1. **Stage overview** (`<stage>/README.md`) — the stage's **theme** (the story of what the client needs at
   this point), a **summary of the technology** it teaches, and a **list of its tasks** with a one-line
   description each.
2. **Task guide** (`<stage>/<task>/README.md`) — the **scope** of one task. It states the goal and the target;
   it does **not** hand over the steps. Sections:
   - **Goal** — one sentence: what this task achieves.
   - **Context** — where this sits in the story.
   - **Scope of work** — plain sentences describing what must be accomplished.
   - **Inputs & names** — where the data comes from and what it's called.
   - **Target** — where the result lands.
   - **Expectation** — what "correct and complete" means.
   - **Output** — the deliverable the intern produces (e.g. scripts).
   - **Bonus** — optional stretch goals.
   - **References / Additional reading** — official-doc pointers (filled per task).
   - **Config & naming** — required settings as inline placeholders (no separate `config/` folder).
3. **What the intern produces** — the **output** (for cloud-ops stages: scripts) plus their **own `docs/`**.
   The `verify` / grading test is the **tech lead's**, kept private in `mentor-docs/` — never in the scaffold.

Learned-technology labels (stage summary + per-task) are filled **after** a stage's tasks are all defined.

---

## Stage 01 — Ingestion

**Theme.** The client gave us a head start: they exported their current database and dropped that **initial
extract** into a Cloud Storage bucket. That's history — a one-time snapshot. But their systems keep running:
new records pile up, so **batches** will keep arriving, and eventually they want their hospitals wired straight
to us — a live **stream**. Your job this stage: get the data off Cloud Storage into the warehouse reliably,
understand its structure, and build ingestion that survives all three shapes — initial now, batches next,
streaming later.

**Technology (summary).** Cloud Storage · BigQuery load jobs · Pub/Sub · bash · external/BigLake tables ·
database replication. *(Per-task tech labels filled later.)*

### Task 1 — Load the initial extract into BigQuery
- **Goal.** Get the client's initial database export out of Cloud Storage and into BigQuery as tables the rest
  of the platform can build on.
- **Context.** The one-time historical snapshot the client handed us to start. Batches and streaming come in
  later tasks; here you deal only with the initial export.
- **Scope of work.** Load every table from the initial export into a BigQuery dataset, one table per source
  table, preserving the data faithfully. The load must be repeatable — running it again must not duplicate or
  corrupt anything. (Do **not** stage the data into a separate "raw" layer.)
- **Inputs & names.** The initial export sits in the client's Cloud Storage bucket under the `initial/` path,
  one folder per source table, each table split across several sharded files.
- **Target.** A BigQuery dataset holding the initial extract (exact dataset/naming coordinated with Stage 02).
- **Expectation.** Every source table present, fully loaded with correct types, row counts matching the source;
  re-running the load is safe.
- **Output.** The populated dataset, plus the script(s) you wrote under `scripts/`.
- **Bonus.** Load the tables in parallel to go faster; and make it resilient — if one table fails, skip it and
  continue the rest, reporting which failed (no whole-run abort).
- **References / Additional reading.** TBD.
- **Config & naming.** Project, source bucket, target dataset — inline placeholders.

### Task 2 — Query the extract in place (external / BigLake)
- **Goal.** Make the extract queryable from BigQuery without copying it.
- **Context.** Sometimes we want to inspect or validate the data where it sits before committing to a load.
- **Scope of work.** Define external/BigLake tables over the extract files so they can be queried with SQL, and
  understand when querying in place beats a native load.
- **Inputs & names.** The same extract files in the client's bucket.
- **Target.** External/BigLake tables in a BigQuery dataset, pointing at the files.
- **Expectation.** Each table returns the same data as the files, with nothing copied.
- **Output.** The script(s) that create the external tables.
- **Bonus.** Add a BigLake connection with metadata caching or fine-grained access.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, source bucket, dataset, connection — inline placeholders.

### Task 3 — Validate the ingestion (manifest)
- **Goal.** Prove a load is complete and correct, not silently partial.
- **Context.** Loads can miss a table, drop shards, or truncate — we need to catch that automatically.
- **Scope of work.** Check that every expected table arrived and that its row counts match what was delivered;
  fail loudly and name the table that's off.
- **Inputs & names.** The loaded dataset plus the source files.
- **Target.** A pass/fail validation result.
- **Expectation.** Passes only when all tables are present and counts match; on mismatch it names the offender.
- **Output.** The validation script(s).
- **Bonus.** Emit a per-table expected-vs-actual summary.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, dataset, source bucket — inline placeholders.

### Task 4 — Ingest the recurring batches (incremental)
- **Goal.** Add the batch drops that arrive after the initial load, without duplicating data.
- **Context.** After the first snapshot the client keeps sending new batches; each must be merged into what's
  already there.
- **Scope of work.** Load a new batch incrementally and idempotently — new records added, no duplicates,
  existing data intact.
- **Inputs & names.** Batch extract files in the client's bucket under the `batch/` path, same per-table shape.
- **Target.** The same tables extended with batch rows. **This needs a staging dataset — defined in Stage 02
  (BigQuery); this task's final requirement points to that task.**
- **Expectation.** Tables hold initial + batch with no duplicates; re-running a batch is safe.
- **Output.** The batch-ingestion script(s).
- **Bonus.** Parallel + skip-on-failure (as Task 1).
- **References / Additional reading.** TBD.
- **Config & naming.** Project, source bucket, dataset, staging dataset — inline placeholders.

### Task 5 — Ingest the live stream
- **Goal.** Handle records that flow in continuously instead of as files.
- **Context.** The end state is hospitals wired directly to us; data arrives as a stream. *(The tech lead feeds
  the test events.)*
- **Scope of work.** Consume streaming clinical events and land them in BigQuery continuously; understand the
  delivery path (direct subscription vs a processing path).
- **Inputs & names.** A Pub/Sub topic/subscription the tech lead feeds.
- **Target.** Streamed rows landing into the tables. **The streaming-landing handling is defined in Stage 02
  (BigQuery); this task's final requirement points to that task.**
- **Expectation.** Published events appear in BigQuery promptly and correctly, no loss or duplication.
- **Output.** The streaming-ingestion script(s)/config.
- **Bonus.** Handle late or duplicate events.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, topic, subscription, dataset — inline placeholders.

### Task 6 — Replicate a source database
- **Goal.** Bring a live source-hospital SQL database into the platform.
- **Context.** Not every source is files — some are operational databases that must be replicated continuously.
- **Scope of work.** Set up replication from a source SQL database into BigQuery so changes flow through;
  understand change-data-capture vs full copy.
- **Inputs & names.** A source SQL database. **Connection details (username / password / host-ip) are provided
  by the tech lead — left blank for now.**
- **Target.** Replicated tables in BigQuery.
- **Expectation.** Source rows and changes appear in BigQuery and keep up.
- **Output.** The replication setup script(s)/config.
- **Bonus.** Capture changes via CDC rather than full reloads.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, dataset, source DB connection (`<TBD by tech lead>`) — inline placeholders.

---

## Stage 02 — BigQuery (Storage & modeling)

**Theme.** Ingestion lands data; now we make BigQuery a proper warehouse. We define the datasets and how data
is organized, give the recurring **batches** a place to land and reconcile, give the **stream** a place to
settle, and keep everything correct and duplicate-free as it updates. *(The dimensional/reporting model itself
is designed and implemented later in Looker — not here.)*

**Technology (summary).** BigQuery datasets · partitioning & clustering · staging patterns · `MERGE` / SCD ·
streaming inserts. *(Per-task tech labels filled later.)*

### Task 1 — Dataset & tier design
- **Goal.** Define the BigQuery datasets the platform uses and the conventions for them.
- **Context.** Every later task needs a clear place to write; this is where the initial-extract dataset from
  Stage 01 is actually defined.
- **Scope of work.** Design the datasets (including where the initial extract lands), plus naming, partitioning,
  and clustering conventions the platform will follow.
- **Inputs & names.** The tables landed by Stage 01.
- **Target.** The defined BigQuery datasets + documented conventions.
- **Expectation.** Datasets exist with consistent naming; partition/cluster choices justified.
- **Output.** The script(s) that create the datasets and any conventions doc.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, dataset names — inline placeholders.

### Task 2 — Staging dataset
- **Goal.** Give incoming batches a landing area before they're reconciled into the main tables.
- **Context.** **Required by Stage 01 Task 4.** Batches can't be appended blindly — they land in staging first.
- **Scope of work.** Define the staging dataset and how a batch is placed there prior to merge.
- **Inputs & names.** Batch data from Stage 01 Task 4.
- **Target.** A staging dataset.
- **Expectation.** A batch can be staged and is ready to reconcile without touching the main tables yet.
- **Output.** The script(s) that define/populate staging.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, staging dataset — inline placeholders.

### Task 3 — Streaming landing
- **Goal.** Give the live stream a place to settle in BigQuery.
- **Context.** **Required by Stage 01 Task 5.** Streamed rows need a landing table with sane handling.
- **Scope of work.** Define the landing table/handling for streamed events (buffering, ordering, dedup).
- **Inputs & names.** Streamed rows from Stage 01 Task 5.
- **Target.** A streaming landing table.
- **Expectation.** Streamed events settle correctly; duplicates/late events handled.
- **Output.** The script(s) that define the landing.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, dataset, landing table — inline placeholders.

### Task 4 — SCD / upsert MERGE
- **Goal.** Fold staged data into the main tables idempotently, with no duplicates.
- **Context.** Batches and updates must reconcile cleanly; some data changes over time (slowly-changing).
- **Scope of work.** Use `MERGE` to upsert staging → main tables, and handle slowly-changing-dimension cases.
- **Inputs & names.** Staging dataset (Task 2).
- **Target.** The reconciled main tables.
- **Expectation.** Re-running a merge is safe; no duplicates; history handled where required.
- **Output.** The merge script(s).
- **References / Additional reading.** TBD.
- **Config & naming.** Project, datasets — inline placeholders.

### Task 5 — Curated / transform layer
- **Goal.** Shape the landed data into clean, analytics-ready tables.
- **Context.** Downstream stages and reporting need tidy, typed, consistent tables — not raw dumps.
- **Scope of work.** Transform the landed tables into a curated layer (typing, cleaning, conforming) that later
  stages build on. (The dimensional model is Looker's job; here it's the physical curated tables.)
- **Inputs & names.** The main tables.
- **Target.** A curated dataset of analytics-ready tables.
- **Expectation.** Curated tables are consistent, typed, and documented.
- **Output.** The transform script(s).
- **References / Additional reading.** TBD.
- **Config & naming.** Project, datasets — inline placeholders.

### Task 6 — Query cookbook
- **Goal.** Build a set of reusable, cost-aware query patterns for the warehouse.
- **Context.** The team should share good BigQuery habits (partition pruning, cost control, windowing).
- **Scope of work.** Produce a small library of documented query patterns against the curated data.
- **Inputs & names.** The curated dataset.
- **Target.** A cookbook of queries.
- **Expectation.** Queries run, are cost-aware, and are documented for reuse.
- **Output.** The query files.
- **References / Additional reading.** TBD.
- **Config & naming.** Project, datasets — inline placeholders.

---

## Stage 03 — Quality & governance (Dataplex)
> **TBD — filled after Stages 01 & 02 are fully implemented.**

## Stage 04 — Orchestration (Airflow / Composer)
> **TBD — filled after Stages 01 & 02 are fully implemented.**

## Stage 05 — Processing at scale (Dataflow / Beam)
> **TBD — filled after Stages 01 & 02 are fully implemented.**

## Stage 06 — Machine learning (Vertex AI)
> **TBD — filled after Stages 01 & 02 are fully implemented.**

## Stage 07 — Reporting (Looker)
> **TBD — filled after Stages 01 & 02 are fully implemented.** *(Owns the dimensional/semantic model design.)*

## Stage 08 — Custom visualization
> **TBD — filled after Stages 01 & 02 are fully implemented.**
