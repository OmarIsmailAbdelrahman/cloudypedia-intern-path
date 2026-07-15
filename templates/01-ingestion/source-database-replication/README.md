# Task — Replicate a source database

## Goal
Bring one of the client's live operational databases onto the platform — and keep it in sync as it changes,
not just copy it once.

## Context & scope
Every ingestion task so far started from files the client handed us — the initial export, the recurring
batches, the stream. This one is different at the source: there is no file drop. The client runs a live
operational SQL database behind their applications, and it never stops changing — rows are inserted, updated,
and deleted while you work. Your job is to mirror that database into BigQuery and keep the mirror current, so
the platform reflects the source as it moves rather than as it looked at one frozen moment.

That "keeps up as it changes" requirement is the whole point, and it's what rules out the obvious approach.
You could dump the database and reload it on a timer, but a full re-export of a live OLTP system is expensive,
gets heavier as the data grows, and is always stale between runs — and it puts read load on a database the
client needs for real work. The right pattern is **change data capture (CDC)**: instead of re-reading the
whole table, you read the database's own change log and apply only the inserts, updates, and deletes that have
happened since the last position. That is how you keep a warehouse in sync with a live source cheaply and
continuously, and learning it is the point of the task.

Reach for **Datastream** to do it. Datastream is Google's serverless, managed CDC service: you point it at the
source database and at BigQuery, and it streams changes continuously with no pipeline to write, no cluster to
run, and no scheduler to fire — it handles the ongoing capture-and-apply loop for you. A hand-rolled
equivalent (poll the source, diff, reconcile) means owning connection management, checkpoint/offset tracking,
backfill, schema drift, and delete handling yourself; Datastream absorbs all of that, which is exactly why it
is the right weight here. What you walk away understanding is CDC as a concept and Datastream as the managed
way to keep a warehouse continuously in step with a live relational source.

## Inputs & names
A live source SQL database that the client operates. Its connection details — host/IP, username, password —
are provided by the tech lead later and are left blank for now; wire them in when you receive them. You do not
control the source, so treat it as read-only: replication must not write back to it or add meaningful load.

## Output & expectations
Replicated tables in BigQuery that track the source and stay current as it changes — an initial backfill of
existing rows followed by continuous CDC so later inserts, updates, and deletes flow through on their own.
Verify it actually keeps up: a change made on the source should land in BigQuery without you re-running
anything. Because this is a live delta stream and not a frozen snapshot, the contrast with the initial-load
task is deliberate — there is no truncate-and-replace here; correctness means the mirror converges on the
source and keeps converging. You deliver the replication setup (the Datastream stream and connection config).

## Bonus
- Handle deletes on the source so removed rows don't linger in the BigQuery copy.
- Handle a source schema change (a new or altered column) and note how the stream reacts.

## References
- Datastream overview — https://cloud.google.com/datastream/docs/overview
- Replicate to BigQuery (Datastream) — https://cloud.google.com/datastream/docs/quickstart-replication-to-bigquery
- BigQuery destination — https://cloud.google.com/datastream/docs/destination-bigquery
- CDC behaviour — https://cloud.google.com/datastream/docs/behavior-overview

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<your dataset>`
- Source DB host/ip: `<db-host>`
- Source DB username: `<db-user>`
- Source DB password: `<db-password>`
