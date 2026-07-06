# custom-serving-container (flagship)

## What it is
A Vertex AI custom prediction container: a FastAPI/uvicorn server that implements the exact Vertex
serving contract -- 4 `AIP_*` env vars (with sane local defaults), a `/health` route that only
returns 200 once the model has loaded, and a `/predict` route mapping `instances` -> `predictions`
1:1. Use this as the base for any custom model you want to serve behind a Vertex Endpoint instead
of a prebuilt container. Prerequisites: Docker (for the real contract check) or just Python 3.11+
for the unit tests. The web-server deps (`fastapi`, `uvicorn`) are only needed inside the built
image, not to run `tests/`.

## Input/output contract
- Env (read at startup, defaults shown): `AIP_HTTP_PORT=8080`, `AIP_HEALTH_ROUTE=/health`,
  `AIP_PREDICT_ROUTE=/predict`, `AIP_STORAGE_URI=/model` (a GCS URI in real deploys; a mounted local
  dir here).
- Model artifact: `<AIP_STORAGE_URI>/model.json` -> `{"weights":[float,...], "bias":float}`. Must
  match the layout written by `../custom-training-container`.
- `GET $AIP_HEALTH_ROUTE` -> `503 {"status":"not_ready"}` before load, `200 {"status":"healthy"}`
  after.
- `POST $AIP_PREDICT_ROUTE` body `{"instances": [[float,...], ...]}` -> `200
  {"predictions": [float, ...]}`, same length and order as `instances`. See
  `sample_data/request.json` / `sample_data/response.json` for a worked example.

## Run locally
`bash local/run_local_serve.sh` (builds the image `--platform linux/amd64`, mounts
`sample_data/model` at `/model`, runs on `$AIP_HTTP_PORT`); in another terminal,
`bash local/smoke_test.sh` builds+runs its own copy and curls both routes end to end. For the pure
unit tests (no Docker, no fastapi needed): `python -m pytest tests -q`.

## Cloud-verify only
Pushing the image to Artifact Registry, and `src/upload_and_deploy.py`'s actual
`aiplatform.Model.upload()` / `Endpoint.create()` / `endpoint.deploy()` calls -- these need a real
GCP project and are run supervised. Everything else (build, serve, health-gating, predict schema,
1.5 MB payload ceiling) is fully reproducible locally with `docker` + `curl`.
