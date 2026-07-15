# Clinical Data Platform — Engagement Build
---

## Engagement Overview

We are a data-solutions consultancy. Large organizations bring us their highest-volume, most sensitive data
problems — the ones where confidentiality, professionalism, and deep domain understanding are non-negotiable —
and trust us to deliver production-grade systems end to end.

Our current engagement is with a national health authority. The authority collects data from a network of
source hospitals but has no unified way to process, trust, or report on it, and it has contracted us to design
and build that platform: the full ETL and reporting infrastructure that turns scattered source data into a
single, governed, query-ready foundation for analytics. To get us started, the client delivered a
representative extract to a Cloud Storage bucket for us to work against.

Our deliverable is a working platform that carries this data from raw source all the way to trustworthy
reporting — ingestion, storage, quality, orchestration, transformation, analytics, and the reporting layer on
top. Each stage below is one part of that platform; its objective, tools, and tasks are described in the stage
itself.

---

## Reference Architecture

Before the tools, the shape. Almost every data platform is the same handful of layers — data flows left to
right, with two concerns running underneath the whole thing:

```
  SOURCES ─▶ INGESTION ─▶ STORAGE ─▶ PROCESSING ─▶ ANALYTICS ─▶ REPORTING
                             │            │            │
                        ┌────┴────────────┴────────────┴────┐
                        │  QUALITY & GOVERNANCE (trust)      │
                        │  ORCHESTRATION (coordination)      │
                        └────────────────────────────────────┘
```

| Layer | What it is responsible for |
|---|---|
| **Ingestion** | Get source data into the platform reliably |
| **Storage & modeling** | Land the data in the warehouse and shape it for analytics |
| **Quality & governance** | Profile, validate, and catch bad data; govern sensitive data |
| **Orchestration** | Schedule and coordinate the whole pipeline |
| **Processing at scale** | Transform large volumes of data efficiently |
| **Machine learning** | Build and serve a predictive model on the data |
| **Reporting (BI)** | Dashboards and self-serve analytics for the client |
| **Custom visualization** | Bespoke views beyond what standard BI tools provide |

---

## Pipeline Stages

Each stage has a folder with an overview, and is fully specified in the
[Stage Playbook](standards/STAGE_PLAYBOOK.md). Work them in dependency order — not everything is strictly
sequential (see the rules) — starting with Ingestion.

| # | Stage | Tool | What you'll deliver |
|---|---|---|---|
| 01 | [Ingestion](templates/01-ingestion/) | Cloud Storage | Land the client's data extract into our platform, reliably and repeatably |
| 02 | [Storage & modeling](templates/02-bigquery/) | BigQuery | Warehouse the client's data and shape it for analytics |
| 03 | [Quality & governance](templates/03-dataplex/) | Dataplex | Profile and validate the data; surface the quality issues; govern sensitive fields |
| 04 | [Orchestration](templates/04-airflow/) | Cloud Composer (Airflow) | Schedule and wire the pipeline into one coordinated run |
| 05 | [Processing at scale](templates/05-dataflow/) | Dataflow (Beam) | Process large data volumes with a scalable transform |
| 06 | [Machine learning](templates/06-vertex/) | Vertex AI | Train and serve a predictive model on the clinical data |
| 07 | [Reporting](templates/07-looker/) | Looker | Deliver the client's dashboards on the analytics model |
| 08 | [Custom visualization](templates/08-custom-viz/) | (custom) | Build a bespoke visualization the BI tool can't |

---

## Build Status

Track progress here — one row per stage. (`⬜ not started · 🟡 in progress · ✅ approved by the tech lead`)

| Stage | Status |
|---|---|
| 01 — Ingestion | ⬜ |
| 02 — Storage & modeling | ⬜ |
| 03 — Quality & governance | ⬜ |
| 04 — Orchestration | ⬜ |
| 05 — Processing at scale | ⬜ |
| 06 — Machine learning | ⬜ |
| 07 — Reporting | ⬜ |
| 08 — Custom visualization | ⬜ |

---

## Rules of Engagement

These are not guidelines — they are the terms of the program.
- **Cloud costs money — check before you spin up.** Before using any cloud resource, read its instructions and
  follow the steps exactly, and **always calculate the cost first**. Never provision anything you have not
  costed and been cleared to run.
- **No AI, at any step.** AI tools may not be used in any part of this work: not for designing, building,
  writing, or debugging, and **not for searching or research**. Do the thinking and the work yourself — that
  is the entire point of the program.
- **Communicate — stages are shared and interdependent.** Several people may work on different parts of the
  same stage, and those parts depend on one another. Coordinate continuously, agree on interfaces early, and
  do not treat your part as finished until the pieces that depend on it are unblocked.
- **Confidentiality always.** Treat every record as real patient health information. Keep the data inside the
  sanctioned environment and never commit data or secrets to the repository.
- **Follow the dependency order.** The stages form a pipeline, not a strict 1-to-8 line — some must be built
  before others, but not all are sequential. Before you start a piece, know what it depends on.
- **The tech lead approves.** Open a pull request when a part is done; the **project's tech lead reviews and
  approves** it (not another intern). A stage is ✅ only after that approval.
---

## Getting Started

```bash
git clone <this-repo> && cd cloudypedia-intern-path
```

New here? Start with the **[Intern Guide](docs/INTERN_ONBOARDING.md)** — it covers setup, the rules, how the
stages fit together, and how you'll work. Then go to [**Stage 01 — Ingestion**](templates/01-ingestion/) and begin.

---

## Data & Attribution

The dataset used throughout this program is adapted from **MIMIC-IV (v3.1)** — the *Medical Information Mart
for Intensive Care*, a large, de-identified database of hospital and ICU records curated by the MIT Laboratory
for Computational Physiology and distributed through PhysioNet. It has been sampled and adapted for this
engagement so that it stands in for the client's extract.

MIMIC-IV is released under the **PhysioNet Credentialed Health Data License**. Treat it as sensitive data, use
it only for this program, and cite it in any work derived from it:

> Johnson, A., Bulgarelli, L., Pollard, T., Gow, B., Moody, B., Horng, S., Celi, L. A., & Mark, R. (2024).
> MIMIC-IV (version 3.1). PhysioNet. https://doi.org/10.13026/kpb9-mt58
>
> Johnson, A. E. W., Bulgarelli, L., Shen, L., et al. (2023). MIMIC-IV, a freely accessible electronic health
> record dataset. *Scientific Data*, 10, 1. https://doi.org/10.1038/s41597-022-01899-x
