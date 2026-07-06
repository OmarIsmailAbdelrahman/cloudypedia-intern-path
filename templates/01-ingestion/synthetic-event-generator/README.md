# synthetic-event-generator

## What it is
A shared utility that produces schema-conformant, deterministic "JSON/Avro-ish" events
for the other Stage 01 ingestion templates. It supports a configurable count, a small set
of `ordering_keys` (each with its own strictly-increasing sequence, mirroring Pub/Sub
ordering-key semantics), deliberately-injected poison records (invalid JSON, and valid
JSON missing a required field) for exercising dead-letter paths, and a file-drop mode
that splits the same event set into fixed-size NDJSON files for the batch-load templates.
Use it whenever a downstream template needs realistic input without a live Pub/Sub topic
or GCS bucket. Prerequisites: Python 3.11+ (uses only the standard library).

## Input/output contract
- Input: a JSON config object (`sample_data/input.json`): `count`, `ordering_keys`
  (list[str]), `event_type`, `poison_every` (0 disables), `seed`, `rate_per_second`
  (documentation only), `batch_size` (0 = single NDJSON stream; >0 = file-drop mode).
- Output (stream mode): NDJSON on stdout / `sample_data/output.ndjson` -- one line per
  event or poison record. Good-event schema:
  `{message_id, event_id, ordering_key, event_type, event_ts, seq, payload}` (all
  required except `payload`).
- Output (file-drop mode): `out/file_drop/part-XXXX.ndjson` batch files of `batch_size`
  lines each, same schema.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
None for the generator itself -- it is pure Python and fully local. Publishing its output
to a *real* Pub/Sub topic (and observing real ordering/exactly-once behavior) is covered
by the `pubsub-streaming-pull` template's Cloud-verify section, not here.
