# custom-training-container

## What it is
A Vertex AI CustomJob trainer container: reads a numeric feature-table CSV (the shape produced by
Stage 02's mart model -- one row per entity, feature columns + a label column), fits a small linear
model with argparse-configurable hyperparameters, and writes the artifact to `AIP_MODEL_DIR` in the
exact layout `../custom-serving-container` expects to load. Use this as the trainer half of the
train -> serve pair; swap `read_training_csv`/`fit_linear_regression` for your real model without
touching the env-var/artifact-layout plumbing. Prerequisites: Python 3.11+ (stdlib only) or Docker
for the containerized run.

## Input/output contract
- Input: a CSV with numeric feature columns + one label column (default column name `label`); see
  `sample_data/training_data.csv`.
- Hyperparameters: `--learning-rate` (default 0.02), `--epochs` (default 3000), `--l2` (default
  0.0), `--label-column` (default `label`).
- Output: `<AIP_MODEL_DIR>/model.json` -> `{"weights": [float,...], "bias": float,
  "feature_names": [...]}`. See `sample_data/expected_model.json` for the artifact the committed
  sample dataset trains to.
- `AIP_MODEL_DIR` defaults to `./out` locally; in Vertex it is a GCS URI, FUSE-mounted so the same
  filesystem write works unmodified.

## Run locally
`bash local/run_local_train.sh` (builds the image `--platform linux/amd64`, runs it, writes
`./out/model.json`). Without Docker: `python src/train.py` from the template root writes the same
artifact to `./out/model.json` directly. Unit tests (no Docker needed): `python -m pytest tests -q`.

## Cloud-verify only
Pushing the image to Artifact Registry and submitting it as a real Vertex `CustomJob` (with
`AIP_MODEL_DIR` pointed at a GCS URI) is a supervised cloud step. The training logic, argument
parsing, CSV loading, and artifact layout are all fully verified locally.
