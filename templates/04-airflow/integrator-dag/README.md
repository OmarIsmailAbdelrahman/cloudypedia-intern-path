# integrator-dag (flagship)

## What it is
The single DAG (`pipeline_integrator`) that orchestrates every stage of the starter
kit end to end: ingestion -> ETL -> warehouse -> quality -> ML -> BI. With
`USE_STUBS=true` (the default) each stage is a `@task_group` whose stub reads a
sibling stage's *committed sample output* from `sample_data/` and passes only a
reference (a manifest path) downstream via XCom — so the whole DAG is provably
green with zero GCP credentials. Use it as the template for any new multi-stage
orchestration DAG, and read `docs/swap_for_real.md` when it's time to point a stage
at the real Google operator. Prerequisites: Python 3.11+ for the stub-only run;
`apache-airflow[google]` (see `requirements.txt`) only if you want to run it inside
real Airflow via `templates/04-airflow/local-airflow-dev-env`.

## Input/output contract
- Input: this template's own `sample_data/` — one committed sample output per
  sibling stage (`01_ingestion_raw_events.jsonl`, `05_etl_curated_orders.csv`,
  `02_warehouse_bq_load_result.json`, `03_quality_dq_scan_result.json`,
  `06_ml_model_metadata.json`, `07_bi_looker_refresh_status.json`).
- Output: one `<stage>.manifest.json` reference per stage under
  `$INTEGRATOR_WORK_DIR` (default `local/_run_output/`), each `{"stage", "upstream_ref",
  ...small summary fields}` — never the full rows/table/model. The DAG's XCom values
  are exactly these manifest paths.

## Run locally
`bash local/run_local.sh` — runs the full stub chain (ingestion -> etl -> warehouse
-> quality -> ml -> bi) as plain Python, no Airflow install required. To prove it
green *inside* Airflow: bring up `templates/04-airflow/local-airflow-dev-env`, copy
`src/*.py` into its `dags/` folder, and run
`airflow dags test pipeline_integrator 2026-01-01` (validated against real Airflow
3.0.1 + `apache-airflow-providers-google` while building this template).

## Cloud-verify only
Setting `USE_STUBS=false` swaps every stub for a real Google operator (GCS/BigQuery
land, Dataflow Flex Template, BigQuery MERGE, Dataplex DQ scan, Vertex AI custom
training, Looker PDT build) — see `docs/swap_for_real.md` for the full mapping and
the connections each one needs. That path requires a sandbox GCP project and is not
exercised by this repo's tests.
