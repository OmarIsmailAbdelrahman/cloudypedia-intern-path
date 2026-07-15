# Task — Streaming Landing

## Goal
Design the proper BigQuery home for a never-ending feed: an append-only, time-partitioned landing table shaped
for at-least-once arrivals, and a clean deduplicated read over it that downstream work can trust.

## Context & Scope
In Stage 01 you wired the stream into BigQuery and proved it flows — messages leaving Pub/Sub and appearing as
rows, one per event. That table did its job, but it was deliberately plain: an append target stood up to prove
nothing is lost. It is not yet *modeled*. Here you design the streaming landing properly, so the rest of the
platform can query the feed without wrestling the raw arrivals every time.

Keep the table **append-only**. At-least-once delivery is matched by appends: every arrival is captured, writers
are never blocked on a lock or a read-modify-write, and the feed runs at full rate without one row's correction
stalling the next. Duplicates and lateness are resolved on read, not on write.

Give the table a **time partition** — by ingestion time, or by an event-time column if the payload carries a
trustworthy one. Queries against a landing table almost always want a recent slice ("last hour", "today"), and
partitioning lets BigQuery prune to just those partitions; an unbounded feed grows without limit, so partition
**expiration** lets old data age out cheaply, with no delete jobs and no runaway storage bill. Cluster on the
natural key (patient, admission, source table) to keep the dedup read fast.

Then expose a **clean read**: a view — or a scheduled query writing a compacted table — that resolves the
at-least-once duplicates to one row per key. The standard shape is "latest wins": partition by the business key,
order by event time (or ingest time), keep the newest (a `QUALIFY ROW_NUMBER()` read, or a periodic
`MERGE`/rebuild if you materialize it). A view stays current at no maintenance cost; a scheduled table trades a
little freshness for cheaper repeated reads. Choose for how the data is consumed and justify it.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Dataset:** `<you define>`
- **Landing Table:** `<you define>` (append-only, time-partitioned) — the table the
  [Stage 01 · Streaming ingestion](../../01-ingestion/streaming-ingestion/) task feeds, one row per Pub/Sub
  message, raw, from the `stream/` split; confirm the current table and message shape with the tech lead.
- **Clean Read (view or scheduled table):** `<you define>`

## Output & Deliverables
- A partitioned, append-only landing table with an expiration that keeps it from growing forever.
- A query-ready object over it — a view or a scheduled deduplicated table — that returns one row per key with
  duplicates and out-of-order arrivals resolved rather than trusted blindly.
- The scripts that define the table, the partitioning/expiration, and the dedup read, in `scripts/`.
- A demonstration: let the generator run, publish a deliberate duplicate, and show the raw table holds both
  copies while the clean read shows one correct row.

## Technical Constraints & Anti-Boilerplate Rules
- **Append-only landing.** Do not deduplicate or reshape on write; capture every arrival.
- **Resolve on read.** Duplicates and out-of-order/late arrivals are corrected by the clean read, not by
  write-time logic.
- **Bounded growth.** The landing table must have partition expiration; an unbounded feed cannot grow forever.
- **Time-partitioned.** Partition by ingestion time or a trustworthy event-time column so recent-slice queries
  prune.
- **Justified read choice.** State whether the clean read is a view or a scheduled table and why, based on how it
  is consumed.

## Bonus Objectives
- Materialize the clean read on a schedule (compact the deduped result into a physical table) and compare its
  read cost and freshness against the plain view.
- Handle late arrivals honestly: pick a dedup window (how long you wait for a straggler before a key is settled)
  and show what your read does with an event that lands well after the ones around it.

## References
- BigQuery Storage Write API — https://cloud.google.com/bigquery/docs/write-api
- Pub/Sub BigQuery subscriptions — https://cloud.google.com/pubsub/docs/bigquery
- Introduction to partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Managing partitioned tables (partition expiration) — https://cloud.google.com/bigquery/docs/managing-partitioned-tables
- `QUALIFY` clause and window functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#qualify_clause
- Introduction to views — https://cloud.google.com/bigquery/docs/views-intro
- Scheduling queries — https://cloud.google.com/bigquery/docs/scheduling-queries
