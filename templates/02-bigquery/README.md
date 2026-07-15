# Stage 02 — BigQuery (Storage & modeling)

Make BigQuery a proper warehouse for what ingestion lands: define the datasets, give the batches and the
stream a place to settle, and keep everything correct and duplicate-free as it updates. *(The dimensional
reporting model itself is built later, in Looker.)*

**Teaches:** BigQuery datasets · partitioning & clustering · staging patterns · `MERGE` / SCD · streaming inserts.

**Tasks**
1. Dataset & tier design
2. Staging dataset  *(needed by Stage 01, Task 4)*
3. Streaming landing  *(needed by Stage 01, Task 5)*
4. SCD / upsert MERGE
5. Curated / transform layer
6. Query cookbook

**Full scope of each task** is in
[Stage 02 of the Stage Playbook](../../standards/STAGE_PLAYBOOK.md). Read the
[Intern Guide](../../docs/INTERN_ONBOARDING.md) before you start.
