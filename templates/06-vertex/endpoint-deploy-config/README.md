# endpoint-deploy-config

## What it is
Authoring + validation for the Model Registry upload -> Endpoint create -> Endpoint deploy flow:
`DedicatedResources` (machine type, min/max replica autoscaling), traffic split / canary, and
dedicated-vs-shared / private endpoint options. The config is a plain JSON file; a pure-Python
builder (`src/deploy_plan.py`) validates it and shapes it into the exact request dicts
`google-cloud-aiplatform` expects, so the whole plan is checkable locally without any GCP
credentials. `src/deploy.py --apply` is the thin, supervised layer that actually calls the SDK.
Use this once you have a Model artifact (e.g. from `../custom-training-container` +
`../custom-serving-container`) and want to stand up (or update) its Endpoint. Prerequisites: Python
3.11+ for the local dry-run/tests; `google-cloud-aiplatform` only for `--apply`.

## Input/output contract
- Input: a JSON config (see `config/deploy_config.example.json` for the placeholder shape,
  `sample_data/deploy_config.sample.json` for a filled dummy example) with keys: `project`,
  `region`, `model_display_name`, `endpoint_display_name`, `serving_container_image_uri`,
  `artifact_uri`, `serving_container_health_route`, `serving_container_predict_route`,
  `serving_container_ports`, `machine_type`, `min_replica_count`, `max_replica_count`,
  `traffic_split` (must sum to 100), optional `autoscaling_metric`/`autoscaling_target`,
  `accelerator_type`/`accelerator_count`, `private_endpoint`.
- Output: a plan dict `{"model_upload": {...}, "endpoint_deploy": {...}}` matching the
  `aiplatform.Model.upload()` / `aiplatform.Endpoint.deploy()` keyword arguments. See
  `sample_data/expected_plan.json`.

## Run locally
`bash local/run_local.sh` -- builds the plan from `sample_data/deploy_config.sample.json` and diffs
it against `sample_data/expected_plan.json`. Unit tests: `python -m pytest tests -q` (validation
rules, `DedicatedResources` shaping, traffic-split checks, non-`linux/amd64` image rejection).

## Cloud-verify only
`python src/deploy.py --config <cfg> --apply` performs the real `Model.upload()` ->
`Endpoint.create()` -> `endpoint.deploy()` calls against a live GCP project -- requires
`google-cloud-aiplatform` installed and ADC/service-account credentials, run supervised. Everything
else (config validation, request shaping, traffic-split arithmetic) is verified locally with zero
GCP dependency.
