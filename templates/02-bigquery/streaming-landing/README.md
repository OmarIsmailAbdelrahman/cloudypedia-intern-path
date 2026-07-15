# Task — Streaming landing

## Goal
Design the proper home in BigQuery for a never-ending feed: a landing table shaped for continuous, at-least-once
arrivals, and a clean read over it that downstream work can trust.

## Context & scope
Back in Stage 01 you wired the stream into BigQuery and proved it flows — messages leaving Pub/Sub and appearing
as rows, one per event. That table did its job, but it was deliberately plain: an append target stood up just to
show nothing gets lost. It isn't yet *modelled*. This is the better way. Here you design the streaming landing
properly — how a raw, messy feed is shaped so the rest of the platform can query it without wrestling the raw
arrivals every time.

Keep the table **append-only**. Streaming delivery is at-least-once, and appends are the write pattern that
matches it: every arrival is captured, writers are never blocked waiting on a lock or a read-modify-write, and
the feed can run flat-out without one row's correction stalling the next. You don't try to fix duplicates or
lateness *on write* — you let them land and resolve them on read. That's the whole trade: cheap, continuous,
loss-free capture now; correctness pushed to a place that can afford it.

Give the table a **time partition** — by ingestion time, or by an event-time column if the payload carries a
trustworthy one. Two reasons, both concrete on a feed that never stops. Queries against a landing table almost
always want a recent slice ("last hour", "today"), and partitioning lets BigQuery prune to just those partitions
instead of scanning the growing whole. And an unbounded feed grows without limit, so you need partitions to
**expire** cheaply — set a partition expiration and old data ages out on its own, no delete jobs, no runaway
storage bill. Clustering on the natural key (patient, admission, source table) on top of that keeps the dedup
read below fast.

Then expose a **clean read**: a view — or a scheduled query writing a compacted table — that resolves the
at-least-once duplicates to one row per key. The standard shape is "latest wins": partition by the business key,
order by event time (or ingest time), keep the newest, drop the rest (a `QUALIFY ROW_NUMBER()` read, or a
periodic `MERGE`/rebuild if you want the deduped result materialized). A view costs nothing to keep current and
always reflects the newest arrivals; a scheduled table trades a little freshness for cheaper repeated reads. Pick
for how the data gets consumed and say why.

What you learn is how to turn a raw stream into query-ready data with nothing but BigQuery — partitioning for
pruning and expiry, and read-time deduplication as the answer to at-least-once delivery — no stream-processing
engine required. (When windowed, stateful stream processing genuinely earns its keep, that's Stage 05's job, not
a dependency here.)

## Inputs & names
The append-only landing table the Stage 01 streaming task feeds
([Stage 01 · Streaming ingestion](../../01-ingestion/streaming-ingestion/)) — rows arriving continuously from the
Pub/Sub BigQuery subscription, one per message, raw and unreshaped, from the `stream/` split of the clinical
extract. You're redesigning that table's model and building the read over it; confirm the current table and
message shape with the tech lead.

## Output & expectations
A partitioned, append-only landing table with an expiration that keeps it from growing forever, plus a
query-ready object over it — a view or a scheduled deduplicated table — that returns one row per key with
duplicates and out-of-order arrivals resolved rather than trusted blindly. Prove it: let the generator run,
publish a deliberate duplicate, and show the raw table holds both copies while the clean read shows one, correct
row. You deliver the scripts that define the table, the partitioning/expiration, and the dedup read.

Keep the edges clear. This is stream-specific shaping — a clean read over one continuously-arriving landing
table. It is *not* the full curated model (typing, conforming, and cleaning every table for reporting is the
[curated / transform layer](../curated-transform-layer/)), and it is *not* the batch reconcile path
([staging dataset](../staging-dataset/) → [SCD / upsert MERGE](../scd-upsert-merge/)), which reconciles bounded
file batches into the main tables. Your deduped stream read is one of the inputs those later layers draw on, not
a replacement for them.

## Bonus
- Materialize the clean read on a schedule (compact the deduped result into a physical table) and compare its
  read cost and freshness against the plain view — decide which the downstream consumers actually want.
- Handle late arrivals honestly: pick a dedup window (how long you'll wait for a straggler before considering a
  key settled) and show what your read does with an event that lands well after the ones around it.

## References
- BigQuery Storage Write API — https://cloud.google.com/bigquery/docs/write-api
- Pub/Sub BigQuery subscriptions — https://cloud.google.com/pubsub/docs/bigquery
- Introduction to partitioned tables — https://cloud.google.com/bigquery/docs/partitioned-tables
- Managing partitioned tables (partition expiration) — https://cloud.google.com/bigquery/docs/managing-partitioned-tables
- `QUALIFY` clause and window functions — https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax#qualify_clause
- Introduction to views — https://cloud.google.com/bigquery/docs/views-intro
- Scheduling queries — https://cloud.google.com/bigquery/docs/scheduling-queries

## Config & naming
- Project: `<your-project-id>`
- Dataset: `<you define>`
- Landing table: `<you define>` (append-only, time-partitioned)
- Clean read (view or scheduled table): `<you define>`
