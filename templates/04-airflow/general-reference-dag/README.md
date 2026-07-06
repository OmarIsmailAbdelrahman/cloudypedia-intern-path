# general-reference-dag

## What it is
A "kitchen-sink" reference DAG (`general_reference_dag`, plus a tiny Asset
-triggered companion `general_reference_downstream`) demonstrating every
commonly-needed Airflow 3.x/Composer 3 pattern in one place, so any future DAG in
this repo can copy the relevant piece: classic operators + TaskFlow mixed, a
TaskGroup, dynamic task mapping with a fan-in, branching + a non-default trigger
rule, a deferrable sensor, Asset production *and* Asset-triggered scheduling,
XCom-by-reference throughout, typed params, retries/backoff/timeout, callbacks, a
version-guarded Deadline Alert, and every GCP operator from
`gcp-operator-patterns-library` wired as commented examples. See
`docs/pattern_catalog.md` for the full pattern -> line-in-file index.
Prerequisites: Python 3.11+ for the logic-only run; `apache-airflow` to parse/run
the real DAG.

## Input/output contract
- Input: `sample_data/shards.json` — 3 shard descriptors
  (`{"shard_id": int, "rows": int}`).
- Output: one manifest ref per shard plus a fan-in summary
  (`{"shard_count": 3, "shard_ids": [0,1,2], "total_rows": 45}`) written under
  `$REFERENCE_WORK_DIR`. Every task in the DAG passes a short path/string via
  XCom, never a payload.

## Run locally
`bash local/run_local.sh` — runs the pure dynamic-mapping/fan-in/branching logic
directly (matches the DAG's `reference_logic.py` calls exactly). Both
`general_reference_dag` and `general_reference_downstream` were confirmed to
`DagBag`-parse with **zero import errors** against real
`apache-airflow==3.0.1` + `apache-airflow-providers-google==15.1.0`. See
`docs/known_limitations.md` for two `airflow dags test` CLI-debug-harness gaps
found in this exact patch version (dynamic-mapping XCom resolution, and a
branching skip-signal handling bug) — both are documented Airflow CLI quirks,
not defects in this DAG's structure.

## Cloud-verify only
Actually executing the commented-out GCP operator examples at the bottom of the
file (they need a real GCP project — see `gcp-operator-patterns-library` for the
runnable, locally-DagBag-verified versions of each one).
