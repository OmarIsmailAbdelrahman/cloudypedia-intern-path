# pubsub-streaming-pull (FLAGSHIP)

## What it is
A StreamingPull subscriber implemented against an in-memory "subscription" so
every corner case is unit-testable without a network or emulator: flow
control (caps concurrent outstanding/leased messages), ack/nack with
redelivery, a dead-letter queue after `max_delivery_attempts`, an ordering-key
toggle that preserves per-key delivery order even across nacks, an
exactly-once toggle that dedups redelivered/duplicate `message_id`s, and
idempotent processing (upsert keyed by business `event_id`, safe to call
twice). Use this as the reference subscriber pattern for any at-least-once
Pub/Sub consumer. Feed it with `synthetic-event-generator` output. Pair with
`pubsub-to-bigquery-subscription` when you don't need custom processing code.
Prerequisites: Python 3.11+ (stdlib only).

## Input/output contract
- Input: NDJSON at `sample_data/input.ndjson`, one publish envelope per line:
  `{message_id, ordering_key, event_id, event_type, seq, ...}`. A line missing
  `event_id`/`ordering_key`/`event_type` is treated as poison.
- Output: a JSON summary (`sample_data/output.json`):
  `{acked: [message_id...], dead_lettered: [message_id...],
  processed_order: [message_id...], duplicate_count: int,
  max_outstanding_seen: int, stored_event_ids: [event_id...]}`.
  `stored_event_ids` is the idempotent-store contents downstream stages would
  land.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Real StreamingPull network behavior (framing, keepalives) against a live
  subscription.
- **Exactly-once delivery** as an actual service guarantee (this template only
  simulates client-side dedup logic; the emulator and this simulator do not
  prove the server-side guarantee).
- **Ordering-key guarantees** under real regional publish/subscribe and
  `resume_publish()` after a publish failure.
- Real ack-deadline timers and lease-extension (`modify_ack_deadline`) under
  actual processing latency.
- DLT IAM wiring (the subscription's service account needs
  `roles/pubsub.publisher` on the dead-letter topic) and forwarding under load.
- Seek / replay and retention behavior (affects *all* subscribers on a
  subscription, not just this one).
- Pub/Sub schema (Avro/Protobuf) validation and revision compatibility checks.
