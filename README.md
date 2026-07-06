# Data Engineering Starter-Kit

A **local-first library of reusable GCP data-engineering templates**, built and used by data-engineering
interns alongside the Google **Professional Data Engineer** certificate path. Each template is a
self-contained folder holding a working solution's *structure* + a *runnable local example* + *docs* — so
future projects start from a battle-tested pattern instead of a blank page.

**New here? Read in this order:** [`docs/INTERN_ONBOARDING.md`](docs/INTERN_ONBOARDING.md) →
[`standards/TEMPLATE_ANATOMY.md`](standards/TEMPLATE_ANATOMY.md) →
[`standards/CONVENTIONS.md`](standards/CONVENTIONS.md) →
[`CONTRIBUTING.md`](CONTRIBUTING.md) → the [`templates/00-reference/hello-pipeline`](templates/00-reference/hello-pipeline) example.

---

## Quick start

```bash
git clone <this-repo> && cd cloudypedia-intern-path
make setup            # install dev deps (Python 3.11+)
pre-commit install    # enable ruff + template-conformance checks before each commit
make lint check test  # everything should be green
```

> **`make`?** It's just a task-runner shortcut (see "About `make`" below) — every `make X` maps to a plain
> command you can also run directly. It is **not** part of what you build; it only saves typing.

Then open the reference template to learn the shape every template follows:
```bash
cd templates/00-reference/hello-pipeline && bash local/run_local.sh && python -m pytest tests -q
```

## Verify locally (the gates every template must pass)

| `make` command | Runs | What it checks |
|----------------|------|----------------|
| `make setup` | `pip install -r requirements-dev.txt` | install dev dependencies |
| `make lint`  | `ruff check .` | style/quality — strict on `tools/`, relaxed on illustrative `templates/` |
| `make check` | `python tools/check_template.py templates/*/*/` | every template conforms to the anatomy + has no committed secrets |
| `make test`  | `pytest` over tooling + every template's `tests/` | tooling + the reference example; each template's tests run once you add them |

A single template: `cd templates/<NN-stage>/<template> && python -m pytest tests -q`.

## About `make`

`make` is a tiny, decades-old command-line **task runner** (GNU Make) — not a library, not something this
project ships. The `Makefile` in the repo root just defines named shortcuts (`setup`, `lint`, `check`,
`test`) so nobody has to memorise the long commands. It's pre-installed on macOS and Linux; on Windows use
WSL or Git Bash. **You never need `make`** — the table above shows the exact command each target runs, so
`make check` and `python tools/check_template.py templates/*/*/` are identical.

## Repository structure

```
├── README.md               ← you are here (the front door)
├── CONTRIBUTING.md         ← branching, commits, PR flow, Definition of Done
├── CODEOWNERS              ← review routing (REPLACE the @handles with real usernames)
├── Makefile · ruff.toml · requirements-dev.txt · .pre-commit-config.yaml
├── .github/                ← CI workflow + PR / issue templates
├── standards/              ← the shared contract every template obeys
│   ├── TEMPLATE_ANATOMY.md ·  CONVENTIONS.md ·  CONCEPTS/  (per-stage concept explainers)
├── tools/                  ← check_template.py (the conformance gate) + its tests
├── templates/              ← the deliverable: 8 stages × their templates (see task tracker)
└── docs/
    └── INTERN_ONBOARDING.md ← how to get started
```

Each `templates/NN-stage/<template>/` folder follows the same anatomy: `README.md` (with **What it is /
Input-output contract / Run locally / Cloud-verify only**), `src/`, `local/`, `sample_data/`, `config/`
(placeholders only — **never real secrets**), `tests/`, `docs/`, `DONE.md`.

## Ownership & tracking

Each intern owns a stage and becomes the team's go-to person for that tool. Work is tracked as GitHub
issues — one per template, using the *new-template* issue form — labelled per stage and grouped into a
milestone per round. The board below is the at-a-glance progress view.

## Status board / task tracker

Tick a box when a template is **built and passing local checks** (`make check` + its smoke test), committed
on a merged PR. Your mentor's review and the optional cloud-verify happen on each PR and in supervised GCP
sessions. `*` = the stage's flagship (build it first). Items marked
_(stretch)_ are the backlog — pull them once a stage's core set is done.

### 00 — reference
- [x] hello-pipeline

### 01 — Ingestion
- [ ] pubsub-streaming-pull *
- [ ] synthetic-event-generator
- [ ] gcs-batch-load
- [ ] pubsub-to-bigquery-subscription
- [ ] external-biglake-table
- [ ] sql-database-replication
- [ ] concept doc → `standards/CONCEPTS/01-ingestion/`
- [ ] pubsub-push _(stretch)_
- [ ] pubsub-schema _(stretch)_
- [ ] pubsub-storage-write-api _(stretch)_
- [ ] pubsub-to-gcs-subscription _(stretch)_
- [ ] bq-data-transfer-autoload _(stretch)_

### 02 — BigQuery
- [ ] scd-upsert-merge *
- [ ] 3-tier-ddl
- [ ] staging-transform
- [ ] mart-model
- [ ] query-cookbook
- [ ] concept doc → `standards/CONCEPTS/02-bigquery/`
- [ ] table-lifecycle _(stretch)_
- [ ] cost-and-tuning _(stretch)_

### 03 — Dataplex
- [ ] dq-ruleset-local-validator *
- [ ] lake-zone-asset-discovery
- [ ] profiling-config
- [ ] catalog-tagging-lineage
- [ ] access-control-and-security
- [ ] feature-survey
- [ ] concept doc → `standards/CONCEPTS/03-dataplex/`
- [ ] lineage (split out) _(stretch)_
- [ ] business-glossary _(stretch)_
- [ ] data-insights _(stretch)_

### 04 — Airflow
- [ ] integrator-dag *
- [ ] local-airflow-dev-env
- [ ] dag-authoring-skeleton
- [ ] gcp-operator-patterns-library
- [ ] custom-operator-template
- [ ] general-reference-dag
- [ ] concept doc → `standards/CONCEPTS/04-airflow/`
- [ ] scheduling-and-assets _(stretch)_
- [ ] connections-secrets-reliability _(stretch)_

### 05 — Dataflow
- [ ] dataflow-streaming-template *
- [ ] dataflow-batch-template
- [ ] dataflow-custom-container
- [ ] gcp-connectors-reference
- [ ] concept doc → `standards/CONCEPTS/05-dataflow/`
- [ ] storage-write-api-variants _(stretch)_
- [ ] parameterized-pipeline _(stretch)_
- [ ] extra-sinks _(stretch)_

### 06 — Vertex
- [ ] custom-serving-container *
- [ ] custom-training-container
- [ ] endpoint-deploy-config
- [ ] batch-and-streaming-prediction
- [ ] concept doc → `standards/CONCEPTS/06-vertex/`
- [ ] custom-prediction-routines (CPR) _(stretch)_
- [ ] hyperparameter-tuning-job _(stretch)_
- [ ] ab-traffic-split _(stretch)_

### 07 — Looker
- [ ] relational-to-dimensional-conversion-guide *
- [ ] project-skeleton
- [ ] view-from-bq-table
- [ ] explore-and-joins
- [ ] concept doc → `standards/CONCEPTS/07-looker/`
- [ ] derived-tables-and-pdts _(stretch)_
- [ ] governance-and-refinements _(stretch)_

### 08 — Custom viz
- [ ] custom-viz-skeleton *
- [ ] mock-data-preview-harness
- [ ] options-config
- [ ] d3-chart-example
- [ ] concept doc → `standards/CONCEPTS/08-custom-viz/`
- [ ] standalone-bq-viz _(stretch)_
- [ ] extension-framework-starter _(stretch)_

## Golden rules (full detail in CONTRIBUTING.md)

1. **It must run locally.** No task depends on cloud access; real-GCP steps are optional/supervised and
   live under each README's `## Cloud-verify only`.
2. **Never commit secrets.** `config/` holds `<PLACEHOLDER>`s only; the checker scans for leaks.
3. **One template per PR**, green CI (`make lint check test`), reviewed and approved by your mentor.
4. **Conform to the anatomy** — `make check` must pass before you open a PR.
