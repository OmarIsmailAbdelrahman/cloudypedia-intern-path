# dataflow-batch-template

## What it is
A real Apache Beam Python **batch** pipeline: bounded read (a local ndjson
file standing in for `gs://.../*.jsonl`) -> parse/validate (tagged-output
DLQ) -> `CoGroupByKey` join against a small customers dimension -> hot-key-
safe `CombinePerKey(sum).with_hot_key_fanout(...)` region totals ->
`beam.Reshuffle()` to break fusion before a deliberately-expensive
per-element step -> `WriteToBigQuery(method=FILE_LOADS)` | fake local sink.
It exists to make the batch-specific corner cases in the design spec
concrete and testable: `FILE_LOADS` gives NO per-row write errors (contrast
with the streaming flagship's `STORAGE_WRITE_API` `failed_rows`), hot keys on
a `CombinePerKey`, `Reshuffle` to break fusion, and idempotent batch re-runs
(`WRITE_TRUNCATE` vs `WRITE_APPEND`). Use this as the starting point for any
batch Beam job that joins a bounded source against a dimension table and
writes the result to BigQuery. Prerequisites: Python 3.10+; `pip install -r
requirements.txt` (apache-beam[gcp]) to actually run it (not required to run
the smoke tests).

See the sibling `templates/05-dataflow/dataflow-streaming-template/`
(flagship) for the streaming/windowing/triggers/watermark side of Stage 05;
this template intentionally reuses its file layout and DLQ/sink patterns so
the two are easy to compare directly (`docs/file_loads_vs_storage_write_api.md`
is written specifically to be read alongside that flagship's
`docs/watermark_and_lateness.md`).

## Input/output contract
- Input: a bounded ndjson file, one order JSON object per line --
  `{order_id: str, customer_id: str, amount: number >= 0, region: str}`. See
  `sample_data/orders.jsonl` (includes a bad-JSON line and two validation
  failures, on purpose, to exercise the DLQ). In production:
  `--orders_path=gs://<bucket>/orders/*.jsonl` (the same `ReadFromText` call
  already understands `gs://` via `apache-beam[gcp]`'s GCS filesystem plugin),
  or swap in `beam.io.ReadFromBigQuery` if the source is itself a BigQuery
  table.
- Dimension input: `sample_data/customers.json`,
  `{customer_id: {"name": ..., "segment": ...}}`, joined via `CoGroupByKey`
  (not a broadcast side input -- see `src/dofns.py::JoinOrdersWithCustomerFn`
  for why). A `customer_id` present in `orders.jsonl` but absent from
  `customers.json` is a join MISS, not a validation failure: the order is
  kept with `customer_name`/`segment` set to `"unknown"`.
- Output (`sink=fake`, local): one JSON object per line at
  `out/orders_output.jsonl`, each order plus `customer_name`, `segment`,
  `normalized_amount`. DLQ rows (parse/validation failures) at
  `out/orders_dlq.jsonl`, each `{"failed_row": ..., "error_message": ...}`.
  A local reporting side-output, `out/region_totals.jsonl`, each
  `{"region": ..., "total_amount": ...}` -- the hot-key `CombinePerKey` demo.
  See `sample_data/expected_output.jsonl` / `expected_dlq.jsonl` /
  `expected_region_totals.jsonl` for the exact committed sample output of
  `local/run_local.sh`.
- Output (`sink=bigquery`, cloud-verify only): a BigQuery table matching
  `src/sinks.py:BQ_ORDERS_SCHEMA`, written via `FILE_LOADS` with
  `write_disposition=WRITE_TRUNCATE` (see
  `docs/file_loads_vs_storage_write_api.md` for why `WRITE_TRUNCATE`, not
  `WRITE_APPEND`). **`FILE_LOADS` gives no per-row errors** -- there is no
  DLQ branch downstream of this sink, unlike the streaming flagship's
  `STORAGE_WRITE_API` sink, which returns a real `failed_rows` PCollection.
  This template's only DLQ is upstream, in the validation ParDo.

## Run locally
```
pip install -r requirements.txt
bash local/run_local.sh
```
Runs `src/pipeline.py` on DirectRunner against the committed `sample_data/`:
`ReadFromText` -> `ParseAndValidateOrderFn` (tagged DLQ output) ->
`CoGroupByKey` join -> `Reshuffle` -> `ExpensiveNormalizeFn` -> fake sink, plus
the hot-key region-totals branch. No GCP credentials, no network, writes to
`out/`.

Smoke tests (no apache-beam required): `python3 -m pytest tests -q`.
Wherever apache-beam IS installed, `tests/test_pipeline_beam.py` also runs
real DirectRunner cases covering: the validation ParDo's tagged DLQ output,
the `CoGroupByKey` join (including a join-miss case), the hot-key
`CombinePerKey(sum).with_hot_key_fanout(...)` aggregation (checked against a
plain, non-fanned `CombinePerKey` to prove the fanout doesn't change the
result), and `Reshuffle` (checked to leave the data unchanged -- same
elements, just redistributed).

## Cloud-verify only
- `sink=bigquery`: real `WriteToBigQuery(method=FILE_LOADS)`. Runnable on
  DirectRunner in principle, but exercising the real BigQuery load-job path
  (and confirming a job-level load failure, since there is no per-row
  failure to check) needs a real GCP project/dataset -- not covered by the
  local smoke tests.
- `src/flex/build_flex_template.sh`: `docker build`/`push` + `gcloud dataflow
  flex-template build/run` against a real project/Artifact Registry/GCS
  bucket.
- Confirming `WRITE_TRUNCATE`'s idempotent-re-run behavior against a real
  BigQuery table across two consecutive real job runs (statically documented
  and pure-Python reasoned about in `docs/file_loads_vs_storage_write_api.md`,
  not executed against real BigQuery here).
