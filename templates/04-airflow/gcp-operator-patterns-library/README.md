# gcp-operator-patterns-library

## What it is
A copy-paste reference library: one file per Google operator family under
`src/patterns/`, each showing the **sync** and **deferrable** construction of that
operator (plus connection setup notes) as a small, self-contained, non-scheduled
reference DAG (`schedule=None`). Covers `BigQueryInsertJobOperator`,
`GCSToBigQueryOperator`, `DataflowStartFlexTemplateOperator`,
`DataprocSubmitJobOperator`, the Dataplex DQ scan chain
(`DataplexRunDataQualityScanOperator` + `DataplexDataQualityJobStatusSensor`),
Pub/Sub publish + pull, a Vertex AI custom-container training job, and a Looker
PDT build/poll bonus. Use it when wiring a new Google operator into any DAG in
this repo. Prerequisites: Python 3.11+ to smoke-test; `apache-airflow[google]`
(see `requirements.txt`) to actually run one of these DAGs.

## Input/output contract
- Input: none (these are reference constructions, not a data pipeline) — every
  parameter is a `<PLACEHOLDER_*>` value or the shared demo dataset
  (`<project>/warehouse/fct_orders_daily`) used across this stage's templates.
- Output: `sample_data/pattern_index.json` is the index of every file/operator/
  sync-task-id/deferrable-task-id pair — the thing a smoke test (and a human
  skimming for "which file has the Dataproc pattern") checks against.

## Run locally
`bash local/run_local.sh` (`ast.parse`s every file — no Airflow needed) or
`python -m pytest tests -q` (adds a bonus DagBag import-error check, auto-skipped
if `apache-airflow` isn't installed). Verified in this sandbox against real
`apache-airflow==3.0.1` + `apache-airflow-providers-google==15.1.0`: all 8 files
build with zero `DagBag` import errors.

## Cloud-verify only
Actually executing any of these tasks against a real GCP project/Looker instance
(they all use `<PLACEHOLDER_*>` project/region/bucket/model values here).
