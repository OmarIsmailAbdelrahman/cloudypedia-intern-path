# custom-operator-template

## What it is
How to build a custom Operator + Hook + Sensor, plus a deferrable Trigger, the
house way: `plugins/hooks/manifest_hook.py` (`LocalManifestHook`),
`plugins/operators/manifest_operator.py` (`ManifestProcessOperator`, idempotent),
`plugins/sensors/manifest_sensor.py` (`ManifestReadySensor`, poke or deferrable),
`plugins/triggers/manifest_trigger.py` (`ManifestReadyTrigger`, runs on the
triggerer). `dags/uses_custom_operator.py` wires the deferrable sensor into the
operator. All Airflow-facing classes are thin wrappers around
`plugins/manifest_logic.py`, which has zero Airflow imports and is what's actually
unit-tested. Prerequisites: Python 3.11+ for the logic-only run;
`apache-airflow` to exercise the real classes.

## Input/output contract
- Input: `sample_data/sample_manifest.json` (`{"status": "ready", "row_count":
  128, "keys": [...]}` ) and `sample_data/sample_manifest_not_ready.json`
  (`{"status": "pending"}`, used to test the sensor's negative case).
- Output: `<base_dir>/sample_manifest.marker.json` —
  `{"manifest_id", "checksum", "row_count", "key_count", "processed": true}`. The
  Operator's XCom value is this file's *path*, not its contents. Re-running with
  the same manifest content is a no-op (checksum match = idempotent).

## Run locally
`bash local/run_local.sh` — proves the idempotent process step end to end (and
that a second run is a true no-op) with plain Python.

## Cloud-verify only
None — this template's classes wrap the local filesystem, not a GCP API; swap
`LocalManifestHook`'s body for a real GCS/BQ-backed hook when adapting this
pattern to a real external system (see `docs/packaging.md`).
