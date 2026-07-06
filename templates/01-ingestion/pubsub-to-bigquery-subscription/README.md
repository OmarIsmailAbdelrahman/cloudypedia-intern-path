# pubsub-to-bigquery-subscription

## What it is
Models Pub/Sub's no-code "BigQuery subscription" export type: Pub/Sub writes
messages directly into a BigQuery table with **no subscriber code running**.
Use this template when a topic's payloads should land in BigQuery with
minimal latency and no Dataflow/Cloud Run pipeline to operate. Because there
is no application code in the data path, the "solution" here is entirely
declarative: (a) config validation for the subscription's export settings
(`src/config_validator.py`), and (b) the dedup logic a downstream BigQuery
view must run over the at-least-once exported table (`src/dedup.py`,
`src/sql/dedup_view.sql`). Prerequisites: Python 3.11+; a live GCP project
only for the cloud-verify steps below.

## Input/output contract
- **Config input**: a dict (see `config/config.example.yaml`,
  `sample_data/config_valid.json`, `sample_data/config_invalid.json`) with
  `topic`, `bigquery_table`, exactly one of `use_topic_schema` /
  `use_table_schema` / `raw` set true, `write_metadata` (bool),
  `dead_letter_topic` (mandatory, non-empty), and optional
  `max_delivery_attempts` (int >= 5).
  `validate_export_config(config) -> list[str]` returns human-readable error
  strings, empty list means valid (see `sample_data/config_invalid_errors.json`
  for the committed expected errors of the invalid sample).
- **Row input**: `sample_data/input.ndjson`, one JSON object per line — the
  shape of a row as BigQuery would receive it from the export: `subscription_name`
  (string), `message_id` (string), `publish_time` (RFC3339 string), `data`
  (the message payload, encoded here as a **JSON string**, matching how a
  `raw`-mode export writes the payload column), `attributes` (JSON object).
  Includes a `message_id` appearing twice with different `publish_time`,
  simulating an at-least-once redelivery duplicate.
- **Row output**: `dedup_rows(rows) -> list[dict]` returns one row per distinct
  `message_id` (keeping the earliest `publish_time`), sorted by
  `(publish_time, message_id)`. Committed expected result:
  `sample_data/output.json`. `src/sql/dedup_view.sql` is the equivalent
  BigQuery view SQL for running the same dedup against the real exported
  table.

## Run locally
`bash local/run_local.sh`

(runs `src/dedup.py` over `sample_data/input.ndjson` and prints JSON matching
`sample_data/output.json`; run `python3 -m pytest tests` for the full smoke
test including `config_validator`).

## Cloud-verify only
Cannot be proven locally — these require a supervised GCP step:
- Real Pub/Sub at-least-once delivery/duplication behavior (this template's
  `input.ndjson` duplicate row is a hand-built simulation, not an observed
  redelivery).
- The BigQuery subscription service actually enforcing `use_topic_schema` /
  `use_table_schema` (rejecting payloads that don't match the schema) versus
  `raw` mode's lack of validation.
- Real dead-letter-topic forwarding after `max_delivery_attempts` failed
  write attempts.
- Running `src/sql/dedup_view.sql` against a live BigQuery dataset containing
  the actual exported table.
