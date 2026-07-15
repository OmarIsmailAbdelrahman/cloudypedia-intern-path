# Task — Ingest the live stream

## Goal
Take data the moment it's produced — a continuous feed instead of a file drop — and land it in BigQuery as it
arrives.

## Context & scope
The initial and batch loads were both *bounded*: a fixed set of files sitting in Cloud Storage, complete before
you touched them, loaded once and finished. This is the opposite. The client's endgame is hospitals wired
straight to us, emitting records as events happen — a feed that never ends, that you can never call "done." To
stand in for that, the tech lead runs a synthetic event generator that publishes the `stream/` split of the
extract to a Pub/Sub topic. You don't build the generator; you consume the topic it feeds.

An unbounded feed changes the rules. There's no final file to reconcile against, so you can't wait for
completeness — you commit each record as it lands. Delivery is *at-least-once*, so the same event can show up
twice. Events can arrive *out of order*, and some arrive *late*, well after the moment they describe. That is
why you don't reach for a load job here: a load job wants a finite input and a clean boundary, and this stream
gives you neither.

So the shape is a durable buffer feeding a plain append target. **Pub/Sub** is that buffer — it decouples the
producer from you, absorbs bursts, and holds messages durably until they're acknowledged, so nothing is lost
if the consumer stalls. From the topic, the simplest path into BigQuery is a **Pub/Sub BigQuery subscription**:
a subscription type that writes messages straight into a BigQuery table with *no pipeline code for you to run
or maintain* — Pub/Sub does the delivery, you just point it at a table. The table it writes to is a **landing
table**: append-only, raw arrivals, one row per message, no reshaping. Appending (not merging) is deliberate —
it keeps ingestion cheap and continuous, and it means duplicates and late events are *captured* rather than
silently dropped, left for a later curated layer to resolve.

What you're learning is the streaming mental model itself: unbounded vs. bounded, at-least-once delivery and
the duplicates it implies, out-of-order and late arrival, and why continuous ingestion favors a buffer plus an
append landing table over the load-job thinking of the earlier tasks.

## Inputs & names
A Pub/Sub topic the tech lead's generator feeds (the source is the `stream/` split of the extract, the same
clinical tables you already loaded). You create your own subscription against that topic. Ask the tech lead for
the topic name and the message shape.

## Output & expectations
Messages flowing from the topic into a BigQuery landing table continuously, one row per event, with the pipeline
staying healthy under a feed that never stops. Because delivery is at-least-once, expect duplicates to land —
that's correct behavior, not a bug to eliminate at this stage; your job is that nothing is *lost* and every
arrival is captured. Prove it runs: publish or let the generator publish, and watch rows appear in the landing
table without you running anything by hand.

Stand up the whole path yourself — topic subscription, the append-only landing table, and the config that wires
them — so this task is complete on its own. You deliver the subscription and table definitions and any setup
script. (A properly *curated* streaming table — typed, deduplicated, query-friendly — is a Stage 02 concern, and
heavier stream processing with windowing comes later in Stage 05; neither is required here.)

## Bonus
- Inspect the duplicates and late arrivals the stream produces and describe how you'd reconcile them downstream
  (dedup key, event-time ordering) — no need to build it here.
- Route messages that fail to write (schema mismatch, bad payload) to a dead-letter topic so a single bad event
  can't stall the feed.

## References
- Pub/Sub BigQuery subscriptions — https://cloud.google.com/pubsub/docs/bigquery
- Choosing a subscription type — https://cloud.google.com/pubsub/docs/subscription-overview
- Streaming vs. batch ingestion into BigQuery — https://cloud.google.com/bigquery/docs/loading-data
- Handling message failures (dead-letter topics) — https://cloud.google.com/pubsub/docs/handling-failures

## Config & naming
- Project: `<your-project-id>`
- Topic: `<topic from tech lead>`
- Subscription: `<your-subscription-id>`
- Dataset: `<your dataset>`
- Landing table: `<your landing table>` (append-only)
