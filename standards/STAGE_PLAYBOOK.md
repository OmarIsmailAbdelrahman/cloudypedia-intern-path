# Stage Playbook

How every stage of the platform is built. This is the **method** — the shape each stage and task follows. The
actual content lives in the stages themselves (see the index at the bottom): a stage's story and task list are
in its folder README; each task's full scope is in that task's own README.

## The three levels

1. **Stage overview** (`templates/<stage>/README.md`) — the stage's **theme** (what the client needs at this
   point), a **summary of the technology** it teaches, and its **task list** (each linking to a task folder).
2. **Task guide** (`templates/<stage>/<task>/README.md`) — the **scope** of one task. It states the goal and
   the target; it does **not** hand over the steps. Required sections:
   - `## Goal` — one sentence: what this task achieves.
   - `## Context & scope` — where it sits in the story + (plain sentences) what must be accomplished.
   - `## Inputs & names` — where the data comes from and what it's called.
   - `## Output & expectations` — where the result lands, what "correct and complete" means, and the deliverable.
   - `## Config & naming` — required settings as inline `<PLACEHOLDER>` values (no `config/` folder).
   - *(optional)* `## Bonus`, `## References`.
3. **What the intern produces** — the **output** (for cloud-ops stages: scripts under `scripts/`) plus their
   **own `docs/`**. The `verify` / grading test is the **tech lead's**, kept private in `mentor-docs/` — never
   in the scaffold.

## The task folder

```
templates/<stage>/<task>/
  README.md    # the scope (given)             scripts/   # the intern's output
  docs/        # the intern's own write-up      DONE.md    # definition of done
```

Learned-technology labels (stage summary + per-task) are filled once a stage's tasks are all defined.

## Stage index

| # | Stage | Status |
|---|-------|--------|
| 01 | [Ingestion](../templates/01-ingestion/) | **Ready** |
| 02 | [BigQuery — storage & modeling](../templates/02-bigquery/) | **Ready** |
| 03 | Quality & governance (Dataplex) | TBD — after 01 & 02 |
| 04 | Orchestration (Airflow / Composer) | TBD — after 01 & 02 |
| 05 | Processing at scale (Dataflow / Beam) | TBD — after 01 & 02 |
| 06 | Machine learning (Vertex AI) | TBD — after 01 & 02 |
| 07 | Reporting (Looker) — owns the dimensional model | TBD — after 01 & 02 |
| 08 | Custom visualization | TBD — after 01 & 02 |
