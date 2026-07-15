# Task — Replicate a Source Database (CDC)

## Goal
Mirror one of the client's live operational SQL databases into BigQuery and keep the mirror continuously in sync
as the source changes — an initial backfill of existing rows followed by ongoing change data capture.

## Context & Scope
Earlier ingestion tasks started from files the client delivered — the initial export, the recurring batches, the
stream. This task has no file drop: the client runs a live operational SQL database behind their applications,
and it changes continuously as rows are inserted, updated, and deleted. The objective is to replicate that
database into BigQuery and keep it current, so the platform reflects the source as it changes rather than at a
single frozen moment.

The "stay in sync" requirement rules out periodic full re-exports: a full reload of a live OLTP system is
expensive, grows heavier over time, is always stale between runs, and adds read load to a database the client
needs for production. The correct pattern is **change data capture (CDC)**: read the database's own change log
and apply only the inserts, updates, and deletes that occurred since the last position.

Use **Datastream**, Google's serverless managed CDC service: point it at the source database and at BigQuery, and
it streams changes continuously with no pipeline to write, no cluster to run, and no scheduler to fire. A
hand-built equivalent would require owning connection management, checkpoint/offset tracking, backfill,
schema-drift handling, and delete handling; Datastream manages these, which is why it is the appropriate tool
here.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Dataset:** `<your dataset>`
- **Source DB host/IP:** `<db-host>`
- **Source DB username:** `<db-user>`
- **Source DB password:** `<db-password>`
- **Note:** the source connection details are provided by the tech lead later and are left blank for now; wire
  them in when you receive them.

## Output & Deliverables
- Replicated BigQuery tables that track the source and stay current — an initial backfill of existing rows
  followed by continuous CDC that applies later inserts, updates, and deletes automatically.
- The replication setup (the Datastream stream and connection configuration).
- Verification that a change made on the source lands in BigQuery without you re-running anything.

## Technical Constraints & Anti-Boilerplate Rules
- **Read-only against the source.** Replication must not write back to the source database or add meaningful
  load; treat the source as strictly read-only.
- **Continuous, not snapshot.** Correctness means the mirror converges on the source and keeps converging; there
  is no truncate-and-replace here.
- **Handle the full change set.** Inserts, updates, and deletes must all propagate; a mirror that only appends is
  incorrect.

## Bonus Objectives
- Handle deletes on the source so removed rows do not linger in the BigQuery copy.
- Handle a source schema change (a new or altered column) and document how the stream reacts.

## References
- Datastream overview — https://cloud.google.com/datastream/docs/overview
- Replicate to BigQuery (Datastream) — https://cloud.google.com/datastream/docs/quickstart-replication-to-bigquery
- BigQuery destination — https://cloud.google.com/datastream/docs/destination-bigquery
- CDC behaviour — https://cloud.google.com/datastream/docs/behavior-overview
