# dag-authoring-skeleton

## What it is
The house-style TaskFlow DAG to copy when starting any new DAG in this repo:
`default_args` (retries + exponential backoff + timeout), `catchup=False`,
`pendulum` start_date, typed/validated `params`, and a `TaskGroup` around a
multi-step sub-pipeline. `docs/house_style_checklist.md` is the checklist form of
this README. Prerequisites: Python 3.11+ for the logic-only run;
`apache-airflow` only if running it inside real Airflow.

## Input/output contract
- Input: `sample_data/input_rows.json` — 4 rows, `{"id": int, "amount": float}`.
- Output: `sample_data/expected_summary.json` —
  `{"valid_count": int, "dropped_count": int, "total_amount": float}`, after
  dropping rows at or below `params.min_amount` (default `0.0`).

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
None — this template is fully local by design (it has no GCP operators; see
`gcp-operator-patterns-library` for those).
