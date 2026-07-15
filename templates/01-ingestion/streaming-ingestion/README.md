# Task — Ingest the Live Stream

## Goal
Consume a continuous, unbounded event feed from Pub/Sub and land each record in BigQuery as it arrives, with no
message lost.

## Context & Scope
The initial and batch loads were *bounded*: a fixed set of files, complete before processing, loaded once. This
task is unbounded. The client's target state is hospitals emitting records as events occur — a feed that never
completes. To stand in for that, the tech lead runs a synthetic event generator that publishes the `stream/`
split of the extract to a Pub/Sub topic. You consume the topic; you do not build the generator.

An unbounded feed changes the rules. There is no final file to reconcile against, so each record is committed as
it lands. Delivery is *at-least-once*, so the same event can arrive more than once; events can arrive *out of
order*; and some arrive *late*, well after the moment they describe. A load job — which expects a finite input
and a clean boundary — is therefore the wrong tool.

The appropriate shape is a durable buffer feeding an append target. **Pub/Sub** is the buffer: it decouples the
producer, absorbs bursts, and holds messages durably until they are acknowledged. The simplest path from the
topic into BigQuery is a **Pub/Sub BigQuery subscription**, which writes messages directly into a BigQuery table
with no pipeline code to run or maintain. It writes to a **landing table**: append-only, raw arrivals, one row
per message, no reshaping. Appending rather than merging keeps ingestion cheap and continuous, and it captures
duplicates and late events rather than dropping them, leaving resolution to a later curated layer.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Topic:** `<topic from tech lead>` (fed by the generator from the `stream/` split; ask the tech lead for the
  topic name and message shape)
- **Subscription:** `<your-subscription-id>`
- **Dataset:** `<your dataset>`
- **Landing Table:** `<your landing table>` (append-only)

## Output & Deliverables
- Messages flowing continuously from the topic into a BigQuery landing table, one row per event, with the
  pipeline staying healthy under a feed that never stops.
- The subscription and table definitions and any setup script, in `scripts/`.
- A demonstration that rows appear in the landing table as the generator publishes, with no manual step.

## Technical Constraints & Anti-Boilerplate Rules
- **No loss.** Every arrival must be captured; nothing may be dropped.
- **Append-only landing.** One row per message, raw and unreshaped. Do not deduplicate, merge, or reshape on
  write.
- **Duplicates are expected, not bugs.** At-least-once delivery means duplicates will land; that is correct at
  this stage and is resolved downstream, not eliminated here.
- **Self-contained path.** Stand up the topic subscription, the landing table, and the wiring yourself; do not
  depend on Stage 02 or Stage 05.

## Bonus Objectives
- Inspect the duplicates and late arrivals the stream produces and describe how you would reconcile them
  downstream (dedup key, event-time ordering) — no need to build it here.
- Route messages that fail to write (schema mismatch, bad payload) to a dead-letter topic so a single bad event
  cannot stall the feed.

## References
- Pub/Sub BigQuery subscriptions — https://cloud.google.com/pubsub/docs/bigquery
- Choosing a subscription type — https://cloud.google.com/pubsub/docs/subscription-overview
- Streaming vs. batch ingestion into BigQuery — https://cloud.google.com/bigquery/docs/loading-data
- Handling message failures (dead-letter topics) — https://cloud.google.com/pubsub/docs/handling-failures
