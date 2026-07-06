# gcs-batch-load

## What it is
A local, stdlib-only model of a GCS-to-BigQuery **batch load job** (the kind you get from
`bq load` or the BigQuery Jobs API `load` configuration). It exercises the corner cases that
actually bite people running this job type: explicit schema vs autodetect misdetection, the
three write dispositions, `maxBadRecords` tolerance, hive-style partition-column injection from
the source path, and wildcard (multi-file) loads. Use this template as the starting point for any
ingestion pipeline that lands files from GCS into a BigQuery table on a schedule or trigger.
Prerequisites: Python 3.11+, pytest (`pip install pytest`, or any environment that already has
it — this template's own tests need nothing else).

## Input/output contract
- Input: one or more CSV or NDJSON files under a hive-partitioned directory tree, e.g.
  `sample_data/input/dt=2026-07-01/part-0.csv`. Partition key=value directory segments are
  extracted from the path and injected as extra columns on every row from that file.
- Output: a JSON object `{"rows": [...], "schema": [...], "bad_record_count": <int>}` where
  `rows` are the merged, partition-tagged, loaded records; `schema` is the autodetected
  `[{"name": ..., "type": ...}]` list (`int`/`float`/`bool`/`string`); `bad_record_count` is how
  many malformed source rows were skipped (tolerated up to `max_bad_records`, see
  `config/config.example.yaml`). Downstream stages consume this as the stand-in for "what landed
  in the destination BigQuery table plus its resolved schema."

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Real BigQuery load-job semantics (actual job execution, `errors`/`errorResult` payloads,
  streaming buffer interactions) — this template only models the documented behavior in pure
  Python, it doesn't call BigQuery.
- Load-job daily quota limits (BigQuery caps load jobs per table/project per day) — don't
  micro-batch against a real destination table without checking current quotas.
- Avro/Parquet/ORC real-format parsing — supported by real BigQuery load jobs as
  `source_format`s, but not locally testable here since only stdlib (`csv`, `json`) is used.
  Add a `requirements.txt`-pinned parser (e.g. `pyarrow`, `fastavro`) if you want to extend this
  locally later; keep it out of `tests/`, which stays stdlib-only per this repo's conventions.
- Real GCS wildcard listing at scale (this template takes an already-resolved list of local
  paths; real `gsutil`/GCS list calls, pagination, and eventual-consistency edge cases aren't
  exercised).
- Partition/cluster DDL actually applied on a real destination table (`partition_column`,
  `cluster_columns` in config are placeholders for what you'd pass to `bq mk`/the Tables API —
  nothing here creates or alters a real table).
