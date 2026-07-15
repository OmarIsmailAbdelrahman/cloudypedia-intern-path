# Conventions

## Naming
- snake_case for files, datasets, columns. `dim_`/`fct_` prefixes for BigQuery marts.
- Templates live at `templates/NN-stage/<template-name>/` (NN = zero-padded stage number).

## Config & secrets
- Never commit real credentials. `config/` holds only `<PLACEHOLDER>` values and/or a `.env.example`.
- Fake secrets locally via env vars / mounted keys / ADC. The conformance checker scans for leaked secrets.

## Git & review
- One template per PR. Reviewed and approved by the tech lead against this file before merge.
- Commit after each work-unit with a full, rollback-friendly message. Don't push unless asked; branch first
  if on the default branch.

## Platform independence
- Every template must build and be validated LOCALLY. Cloud steps are optional/supervised and documented
  under the README `## Cloud-verify only` section.

## Pinned versions (2026 — verify against current docs before use)
- Apache Airflow **3.x** / Cloud Composer 3 (imports under `airflow.sdk`; Assets not Datasets; Deadline
  Alerts not SLAs; local env needs a standalone DAG processor + triggerer).
- **DuckDB ≥ 1.4** for the BigQuery local mirror (MERGE support). Validate BQ dialect with `bq query --dry-run`.
- Apache Beam Python **~2.6x**; test watermark/late-data cases with `TestStream` on the DirectRunner.
- Build Vertex AI images **`--platform linux/amd64`**; the serving contract = 4 `AIP_*` env vars + `/health` + `/predict`.
- Dataplex is shown as "Knowledge Catalog" in-console but the API/`gcloud`/IAM are unchanged — key on `dataplex`.

## Concept docs
- Each stage owner writes short concept explainers under `standards/CONCEPTS/<stage>/`.
