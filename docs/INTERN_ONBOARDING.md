# Intern Guide

Read the root [`README.md`](../README.md) first — it has the engagement and the **Rules of Engagement** (the
terms of the program). This guide doesn't repeat them; it's how you actually **work**: your cloud access, the
build loop, and where the stages are.

## How the program is laid out

```
root README        → project overview + the rules
this Intern Guide  → your cloud access + how you work
Stage Playbook     → how a stage is built, and each stage's tasks   (standards/STAGE_PLAYBOOK.md)
stage folder       → a stage's overview + its task folders          (templates/<stage>/)
task folder        → one task: its scope (README) · your scripts · your docs
```

You work **one task at a time**, inside a stage.

## Your Google Cloud access

You run real cloud work on **your own project**, on free credit:

1. Use a **personal Gmail** or a **company Gmail** — but **not** the shared/company email you were given for
   communications.
2. Create a **new Google Cloud project** under that account. New accounts get roughly **$300–400 of free
   credit for ~3 months** — enough for the whole internship.
3. The tech lead makes the **shared source data** (the client's Cloud Storage bucket) reachable from your
   project, so you can read it.

> **Do not enable billing or upgrade the project.** Free credit only. If you hit a wall, ask the tech lead —
> do not add a card. And again: **do not use the shared email** for your own project.

## How you'll work (the loop)

1. **Pick your task** and open its guide. It gives you the **scope** — the goal, the inputs, the target, and
   what "done" looks like. It does **not** hand you the steps; working out the *how* (including any console
   clicks) is the job.
2. **Branch** off `main`: `feat/<NN-stage>-<task-name>`.
3. **Do the work** on your own GCP project. Research from **official documentation** (no AI).
4. **Produce the output** the task asks for — for the ingestion stage that's **scripts** (`gcloud`/`bq`/
   `gsutil` in bash), committed under the task's `scripts/`.
5. **Write your own `docs/`** — what you did, the commands/console steps you took, screenshots, and the
   decisions you made. Nobody hands you this.
6. **Open a PR** (one task). The **tech lead** reviews and approves.
7. **Merge**, then tick your row on the README status board.

## What a task folder looks like

```
<stage>/<task>/
  README.md   # the scope (given to you): goal · context · scope · inputs · target · expectation · output · config
  scripts/    # YOUR deliverable — the script(s) that do the work
  docs/       # YOU fill this: what you did, steps, screenshots, decisions
  DONE.md     # the definition-of-done checklist
```

You are given the `README.md` scope. You produce `scripts/` and `docs/`.

## Where the stages are

Every stage is specified in the **[Stage Playbook](../standards/STAGE_PLAYBOOK.md)** — read your stage's
section for its theme and each task's scope, then work in its folder under `templates/<stage>/`. Stages
**01 (Ingestion)** and **02 (BigQuery)** are ready; the rest are being written.

Start at [**Stage 01 — Ingestion**](../templates/01-ingestion/).

## Definition of done (per task)

- The task's stated output exists and works on your project.
- `scripts/` committed; `docs/` written (your steps + decisions).
- No data or secrets committed; sensitive data stayed inside your project.
- Reviewed and approved by the tech lead via PR.

## Stuck?

Re-read the task scope and the official docs for the tool. Ask the tech lead early — a 10-minute question
beats a lost day. Open a `bug` issue if something in the shared repo/tooling is wrong.
