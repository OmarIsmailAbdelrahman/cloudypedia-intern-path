# local-airflow-dev-env

## What it is
A pinned Airflow 3.x docker-compose stack for local development: postgres +
`airflow-apiserver` (webserver/API) + `airflow-scheduler` + `airflow-dag-processor`
+ `airflow-triggerer` — the full set Composer 3 actually runs, so
`deferrable=True` operators/sensors and live DAG-code reloads both work exactly
like production. Includes an `airflow standalone` fallback for machines without
Docker, and a `composer-local-dev` pointer for when you need an image-exact match
to a real Composer environment. Prerequisites: Docker + Docker Compose v2 for the
full stack; a local `apache-airflow` install (see `requirements.txt`) for the
standalone fallback.

## Input/output contract
- Input: `src/dags/` (mounted read-only-in-spirit into the containers) — this
  template ships one proof DAG, `dev_env_healthcheck`, that exercises every
  service including the triggerer via a deferrable sensor.
- Output: `airflow dags test dev_env_healthcheck <date>` (or a UI-triggered run)
  produces `<HEALTHCHECK_WORK_DIR>/heartbeat.json` — `{"dag_id", "run_id",
  "status": "ok"}` — proving the DAG processor parsed the file, the scheduler/
  triggerer ran its tasks, and postgres held the run state.

## Run locally
`bash local/run_local.sh` — brings up the full compose stack if Docker is
available, otherwise falls back to `make -C local standalone` (validated in this
sandbox, which has no Docker: `airflow standalone`-equivalent parsing/execution
was confirmed via `airflow dags test` against a scratch `AIRFLOW_HOME` — see
`templates/04-airflow/integrator-dag/DONE.md` for the transcript). Once up:
`http://localhost:8080` (UI/API), then `airflow dags test dev_env_healthcheck
2026-01-01` or trigger it from the UI.

## Cloud-verify only
Matching this stack image-for-image against a real Composer 3 environment
(`composer-local-dev`, see `docs/notes.md`) and deploying `src/dags/*.py` by
copying them to the Composer environment's GCS `dags/` bucket — both require a
real Composer environment and are not exercised locally.
