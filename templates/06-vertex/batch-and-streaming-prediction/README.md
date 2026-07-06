# batch-and-streaming-prediction

## What it is
The three Vertex prediction shapes on one model, and the logic to choose between them by payload
size and latency need: **online/streaming** (low-latency `/predict`, same contract as
`../custom-serving-container`), async **batch** (`BatchPredictionJob`, GCS/BQ in -> GCS/BQ out, no
per-request payload ceiling), and **large-file/large-payload handling** (chunking, GCS-referenced
instances, and the private-endpoint 10 MB path vs the public 1.5 MB path). Use this once a model is
deployed (or targeted for batch) and you need to decide/implement how callers should actually send
it data. Prerequisites: Python 3.11+ (stdlib only) for everything under `tests/` and
`local/run_local_dryrun.sh`; `google-cloud-aiplatform` only for the cloud-verify `--apply`/submit
paths.

## Input/output contract
- Online: `{"instances": [...]}` -> `{"predictions": [...]}`, 1:1 length/order, same schema as
  `../custom-serving-container`. See `sample_data/sample_input.jsonl` /
  `sample_data/sample_response.json`.
- Large payload: request bodies are chunked to stay under `PUBLIC_ENDPOINT_LIMIT_BYTES` (1.5 MB) or
  `PRIVATE_ENDPOINT_LIMIT_BYTES` (10 MB); a single oversized instance is flagged
  (`oversized_instances`) and should be sent as `{"gcsUri": "gs://..."}` instead
  (`to_gcs_reference`) rather than inlined.
- Batch: a JSON config (see `config/batch_job_config.example.json` /
  `sample_data/batch_job_config.sample.json`) with `project`, `region`, `model_resource_name`, and
  either `gcs_source`/`gcs_destination_prefix` or `bigquery_source`/`bigquery_destination_prefix` ->
  a `BatchPredictionJob` request dict (`build_batch_job_request`).
- Full decision table + corner cases: `docs/large_file_notes.md`.

## Run locally
`bash local/run_local_dryrun.sh` -- builds an online request from `sample_data/sample_input.jsonl`,
demonstrates chunking, and builds a batch-job request plan from the committed sample config, all
offline (no network, no credentials). Unit tests: `python -m pytest tests -q`.

## Cloud-verify only
`online_predict.send_request()` against a real deployed Endpoint URL, and
`batch_predict.submit_batch_job()` (a real `BatchPredictionJob`), both require a live GCP project
and are run supervised. Testing the actual private-endpoint (PSC) 10 MB path also requires a real
VPC/PSC setup. All request-building, validation, size-threshold, and chunking logic is fully
verified locally.
