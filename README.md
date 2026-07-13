# Clinical Data Platform — Engagement Build

> A hands-on data-engineering program. You will build a real end-to-end data platform for a client,
> one stage at a time, on Google Cloud.

---

## The project

**Who we are.** We are a data-solutions consultancy. We take on large organizations with high-volume data,
where **confidentiality, professionalism, and domain understanding** are non-negotiable.

**The engagement.** A **national health authority** has contracted us to build their **ETL and reporting
infrastructure**. The authority collects clinical data from **source hospitals** and today has no unified way
to process, trust, or report on it. Our job is to stand up that platform end to end.

**What the client gave us.** To get us moving, the authority delivered a **representative extract of the data
in a Cloud Storage bucket** — real-shape hospital and ICU records (patients, admissions, ICU stays, vitals,
labs, medications, diagnoses). Two things are true of this data, and they shape everything we build:

- **It is messy.** Like all real clinical data, it carries data-quality problems — bad formats, impossible
  values, missing links, duplicates. Part of our job is to *find and handle* them, not assume clean input.
- **It is sensitive.** It is patient health information. Confidential handling and governance are a
  requirement at every stage, not an afterthought.

**Our deliverable.** A working platform that turns this raw extract into **trustworthy, query-ready reporting**
— ingestion, storage, quality, orchestration, transformation, analytics, and the reporting layer on top.

> **One thing we do *not* hand you: the reporting model.** The analytics/semantic layer is designed the way
> real practitioners do it — in a **working session with your mentor, building a Kimball bus matrix** to decide
> the business processes, grain, facts, and dimensions. That stage gives you the *method*, not the answer.
> Every other stage comes with an explicit objective for what it must deliver.

---

## How a data system looks

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

| Layer | What it is responsible for | You build it in |
|---|---|---|
| **Ingestion** | Get source data into the platform reliably | [`01-ingestion`](templates/01-ingestion/) |
| **Storage & modeling** | Land the data in the warehouse and shape it for analytics | [`02-bigquery`](templates/02-bigquery/) |
| **Quality & governance** | Profile, validate, catch bad data; govern sensitive data | [`03-dataplex`](templates/03-dataplex/) |
| **Orchestration** | Schedule and coordinate the whole pipeline | [`04-airflow`](templates/04-airflow/) |
| **Processing at scale** | Transform large volumes of data efficiently | [`05-dataflow`](templates/05-dataflow/) |
| **Machine learning** | Build and serve a predictive model on the data | [`06-vertex`](templates/06-vertex/) |
| **Reporting (BI)** | Dashboards and self-serve analytics for the client | [`07-looker`](templates/07-looker/) |
| **Custom visualization** | Bespoke views beyond what BI tools give you | [`08-custom-viz`](templates/08-custom-viz/) |

---

## The pipeline — navigation

Each stage is its own folder with a README that states the **goal**, the **tools** and **why**, **alternative
tools**, and its **task tracking**. Start at 01 and work down; each builds on the last.

| # | Stage | Tool | What you'll deliver |
|---|---|---|---|
| 01 | [Ingestion](templates/01-ingestion/) | Cloud Storage | Land the client's data extract into our platform, reliably and repeatably |
| 02 | [Storage & modeling](templates/02-bigquery/) | BigQuery | Warehouse the data and design the analytics model *(Kimball bus matrix, with mentor)* |
| 03 | [Quality & governance](templates/03-dataplex/) | Dataplex | Profile and validate the data; surface the quality issues; govern sensitive fields |
| 04 | [Orchestration](templates/04-airflow/) | Cloud Composer (Airflow) | Schedule and wire the pipeline into one coordinated run |
| 05 | [Processing at scale](templates/05-dataflow/) | Dataflow (Beam) | Process large data volumes with a scalable transform |
| 06 | [Machine learning](templates/06-vertex/) | Vertex AI | Train and serve a predictive model on the clinical data |
| 07 | [Reporting](templates/07-looker/) | Looker | Deliver the client's dashboards on the analytics model |
| 08 | [Custom visualization](templates/08-custom-viz/) | (custom) | Build a bespoke visualization the BI tool can't |

---

## Build status

Track progress here — one row per stage. (`⬜ not started · 🟡 in progress · ✅ approved by mentor`)

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

## How you'll work

- **Stage by stage.** Build in order. Don't jump ahead — each stage depends on the one before it.
- **Local-first.** Everything is designed to build and run on your machine; cloud work is supervised.
- **Confidentiality always.** Treat the data as real patient information. Governance and careful handling
  are part of the grade, not a bonus.
- **The mentor approves.** Open a pull request when a stage is done; your **mentor reviews and approves** it
  (not another intern). A stage is ✅ only after that approval.
- **Requirements can change.** Like any real engagement, the client's needs can evolve mid-project. Build for
  change, not just for today's spec.

---

## Getting started

```bash
git clone <this-repo> && cd <this-repo>
make setup            # install dev deps (Python 3.11+)
pre-commit install    # enable checks before each commit
make lint check test  # should be green
```

Then read, in order:
[`docs/INTERN_ONBOARDING.md`](docs/INTERN_ONBOARDING.md) →
[`standards/TEMPLATE_ANATOMY.md`](standards/TEMPLATE_ANATOMY.md) →
[`standards/CONVENTIONS.md`](standards/CONVENTIONS.md) →
[`CONTRIBUTING.md`](CONTRIBUTING.md), and open the worked example at
[`templates/00-reference/hello-pipeline`](templates/00-reference/hello-pipeline).

Then go to [**Stage 01 — Ingestion**](templates/01-ingestion/) and begin.
