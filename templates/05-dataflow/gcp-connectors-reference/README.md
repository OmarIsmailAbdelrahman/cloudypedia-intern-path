# gcp-connectors-reference

## What it is
A reusable read/write snippet library covering every relevant Beam GCP
connector: Pub/Sub (+ Pub/Sub Lite), BigQuery (all three write methods),
GCS, Bigtable, Spanner, Datastore/Firestore-in-Datastore-mode, and a generic
JDBC source (the Beam-side counterpart to Stage 01's
`templates/01-ingestion/sql-database-replication`). Unlike the Stage 05
flagship (`dataflow-streaming-template`, one end-to-end pipeline), this
template is a *reference*: one small, focused module per connector under
`src/`, each with real, importable `apache_beam` code (not pseudocode) and a
docstring covering that connector's key corner case. Use this as a
copy-from library when wiring a new connector into a pipeline -- check
`docs/connectors_overview.md` first for the corner case and whether it's
locally runnable before copying. Prerequisites: Python 3.10+;
`pip install -r requirements.txt` (apache-beam[gcp]) to actually import/run
these (not required to run the pure-Python static tests).

## Input/output contract
- No single input/output shape -- each connector module defines its own.
  The one connector exercised end-to-end locally, GCS text, reads/writes
  plain lines of text: input `sample_data/gcs_text_input.txt` (comma-separated
  `order_id,amount,status`, one row per line), output an identical set of
  lines written via `gcs_connector.write_to_gcs_text` under `out/`.
- `sample_data/bigquery_table_schema.json` / `bigquery_sample_rows.json`:
  the schema and sample rows the BigQuery snippets are built to accept.
- `config/config.example.yaml`: one `<PLACEHOLDER>` block per connector
  (project, dataset/table, subscription/topic, Bigtable instance/table,
  Spanner instance/database, JDBC url, Datastore namespace) -- copy to
  `config.yaml` and fill in for a real (cloud-verify) run.

## Run locally
```
pip install -r requirements.txt
bash local/run_local.sh
```
Runs `local/run_gcs_demo.py`: actually round-trips
`sample_data/gcs_text_input.txt` through `gcs_connector.write_to_gcs_text` /
`read_from_gcs_text` on DirectRunner (no GCP credentials, no network), then
CONSTRUCTS (never `.run()`s) every connector that needs a live GCP service,
printing which constructed cleanly and which hit a documented environment
gap (see below).

Tests (no apache-beam required for the static half):
```
python -m pytest tests -q
```
`tests/test_connectors_static.py` is pure stdlib + pytest and always runs.
`tests/test_connectors_beam.py` is guarded by `pytest.importorskip` and,
wherever apache_beam IS installed (as it is in this dev sandbox), actually
imports every connector module and either runs a real assertion (GCS text
round trip via `assert_that`/`equal_to`) or construct-tests the PTransform
object -- gracefully skipping (not failing) the specific write paths that
hit a real, verified environment gap in this exact sandbox: **34 passed, 4
skipped** here. See `docs/connectors_overview.md` for the full per-connector
locally-runnable/construct-only/doc-only breakdown, and `DONE.md` for the
verification-level summary.

## Cloud-verify only
- Real Pub/Sub end-to-end (`ReadFromPubSub`/`WriteToPubSub` against a live
  subscription/topic) -- constructs cleanly here, not run against real
  infrastructure.
- Pub/Sub Lite (`ReadFromPubSubLite`/`WriteToPubSubLite`) -- see
  `docs/pubsub_lite_notes.md`; not even importable in this sandbox
  (`google-cloud-pubsublite` missing).
- BigQuery `FILE_LOADS`/`STREAMING_INSERTS`/`STORAGE_WRITE_API` writes --
  code is correct per the installed apache_beam 2.65.0 API, but
  `WriteToBigQuery.__init__` cannot even be constructed in this sandbox
  (`google-apitools` missing); see `src/bigquery_connector.py`.
  `ReadFromBigQuery` DOES construct here and is construct-tested.
- Bigtable reads (`ReadFromBigtable`) -- unconditionally requires a Java
  cross-language expansion service in this Beam version; no JRE in this
  sandbox. `WriteToBigTable` does not have this requirement and IS
  construct-tested here.
- Spanner (`ReadFromSpanner`/`WriteToSpanner`) against a live
  instance/database -- constructs cleanly here, not run against real
  infrastructure.
- JDBC (`ReadFromJdbc`/`WriteToJdbc`) -- cross-language, needs Docker/Java +
  a live database + driver jar to actually run; constructs cleanly here
  without Java (expansion service starts lazily on pipeline-apply).
- Datastore/Firestore-in-Datastore-mode (`ReadFromDatastore`/
  `WriteToDatastore`) -- not even importable in this sandbox
  (`google-cloud-datastore` missing); see `src/datastore_connector.py`.
