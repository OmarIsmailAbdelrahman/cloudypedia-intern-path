# dataflow-streaming-template (FLAGSHIP)

## What it is
The Stage 05 flagship: a real Apache Beam Python streaming pipeline --
`Pub/Sub -> parse/validate (DLQ) -> event-time windowing+triggers -> stateful
dedup (watermark GC timer) -> side-input enrichment -> BigQuery Storage Write
API (failed_rows DLQ) | fake local sink`. It exists to make every windowing/
trigger/lateness/accumulation/stateful corner case in the design spec
concrete, testable, and *wrong on purpose in the cases that are supposed to
be wrong* (see `docs/watermark_and_lateness.md`). Use this as the starting
point for any streaming Beam job that windows event-time data and writes to
BigQuery. Prerequisites: Python 3.10+; `pip install -r requirements.txt`
(apache-beam[gcp]) to actually run it (not required to run the smoke tests).

Every window/trigger/lateness/accumulation combination is a named entry in
`src/window_configs.py:WINDOW_CASES` -- the single source of truth used by
both the pipeline (`--window_case=<name>`) and the tests.

## Input/output contract
- Input: Pub/Sub messages whose body is JSON with `event_id` (string),
  `user_id` (string), `amount` (number >= 0), `event_ts` (unix seconds). See
  `sample_data/input_events.jsonl` (local-run format: one
  `{"add_at_watermark": N, "raw": "<message body>"}` per line, replayed
  through a `TestStream`).
- Side input: `sample_data/user_lookup.json`, `{user_id: {"tier": ...}}`.
- Output (`sink=fake`, local): one JSON object per line at
  `out/streaming_output.jsonl`, each `{event_id, user_id, amount, event_ts,
  tier}`. DLQ rows (parse/validation failures) at `out/dlq.jsonl`, each
  `{"failed_row": ..., "error_message": ...}`. See
  `sample_data/expected_streaming_output.jsonl` / `expected_dlq.jsonl` for the
  exact committed sample output of `local/run_teststream_demo.py`.
- Output (`sink=bigquery`, cloud-verify only): a BigQuery table matching
  `src/sinks.py:BQ_TABLE_SCHEMA`, written via `STORAGE_WRITE_API`, with
  `failed_rows_with_errors` routed to the same DLQ path.

## Run locally
```
pip install -r requirements.txt
bash local/run_local.sh
```
Runs `local/run_teststream_demo.py`: a `TestStream` replay of
`sample_data/input_events.jsonl` (including a duplicate event, a bad-JSON
row, an invalid row, and a late/out-of-order batch) through the exact same
`ParseAndValidateFn` -> windowing/trigger -> `StatefulDedupFn` ->
`EnrichWithSideInputFn` chain that `src/pipeline.py` wires to real Pub/Sub +
BigQuery in production, on DirectRunner, writing to `out/`. No GCP
credentials, no network.

To try it against an emulated Pub/Sub transport instead of `TestStream`, see
`local/publish_test_msgs.py` (opt-in, requires `gcloud beta emulators
pubsub`).

Smoke tests (no apache-beam required): `python -m pytest tests -q`.
Wherever apache-beam IS installed, `tests/test_teststream_cases.py` also runs
18 real `TestStream`+DirectRunner cases covering all 4 window types, all 6
trigger variants, the `allowed_lateness=0` drop trap, the "unsafe trigger"
trap, both accumulation modes with the double-count reproduced for real, the
stateful dedup + GC timer, and the side-input join.

## Cloud-verify only
- `sink=bigquery`: real `WriteToBigQuery(method=STORAGE_WRITE_API)` (needs
  the Storage Write API's external Java expansion service -- not runnable on
  a bare DirectRunner) with the `failed_rows` DLQ branch actually landing
  rows in BigQuery/GCS.
- Real Pub/Sub end-to-end (`ReadFromPubSub` against a live subscription).
- `src/flex/build_flex_template.sh`: `docker build`/`push` + `gcloud dataflow
  flex-template build/run` against a real project/Artifact Registry/GCS
  bucket.
- Autoscaling, drain, update (`--transform_name_mapping`), and snapshot on a
  real running job -- see `docs/watermark_and_lateness.md` for what to expect
  from each.
