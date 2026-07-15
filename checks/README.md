# Acceptance checks (`checks/`)

Automated, intern-side acceptance tests — one per task, mirroring the `templates/` tree:

```
checks/<stage>/<task>.sh        e.g. checks/01-ingestion/initial-load-to-bigquery.sh
templates/<stage>/<task>/       the matching task the intern works in
```

## How it runs
When an intern pushes work under `templates/**`, the **`cloud-verify`** workflow
(`.github/workflows/cloud-verify.yml`) detects which task folder changed and runs the matching
`checks/<stage>/<task>.sh` against **the intern's own GCP project** (authenticated by the
service-account key they set up — see [`docs/CI_CLOUD_TESTING.md`](../docs/CI_CLOUD_TESTING.md)).
Pass/fail shows up in the Actions tab and on the PR. If a task has no check file yet, the workflow
skips it cleanly.

## What a good check looks like
- **Self-verifying, not hard-coded.** Prefer comparing the intern's result *against the source of
  truth* (e.g. count the source files in GCS and diff against their loaded table) over baking in
  "expected" numbers. This keeps the private grading key out of the repo and stays correct if the
  data changes. The reference check `checks/01-ingestion/initial-load-to-bigquery.sh` does exactly
  this with an ephemeral BigQuery external table.
- **Enforces the task README's stated criteria** — nothing more. The check tests the `## Output &
  expectations` of its task; it does not smuggle in new requirements.
- **Fails loudly and specifically.** One clear message per failing table/criterion, non-zero exit.
- **Reads config from env** (`GCP_PROJECT_ID`, `GCP_DATASET`, …) set by the workflow from the
  intern's fork secrets. No project ids or secrets in the script.

## Ownership
These files are the **tech lead's** (see `CODEOWNERS` — every change needs Code Owner approval).
Interns don't edit their own grader; they make it pass by doing the task.

## Coverage
Checks fit tasks that leave **verifiable cloud state** — BigQuery / GCS / Dataplex / Vertex
(Stages 01, 02, 03, 06). Tasks whose deliverable is proven locally instead — Airflow DAGs
(DirectRunner/`dags test`), Beam pipelines (DirectRunner + TestStream), LookML (LAMS lint),
custom viz (mock-data browser harness) — are covered by their own local checks, not this workflow.
