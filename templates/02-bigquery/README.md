# Stage 02 — BigQuery (Storage & modeling)

Make BigQuery a proper warehouse for what ingestion lands: define the datasets, give the batches and the
stream a place to settle, and keep everything correct and duplicate-free as it updates. *(The dimensional
reporting model itself is built later, in Looker.)*

**Teaches:** BigQuery datasets · partitioning & clustering · staging patterns · `MERGE` / SCD · streaming inserts.

**Tasks** — each folder holds its full scope:
1. [Dataset & tier design](dataset-and-tier-design/)
2. [Staging dataset](staging-dataset/)  *(needed by Stage 01 · batch ingestion)*
3. [Streaming landing](streaming-landing/)  *(needed by Stage 01 · streaming ingestion)*
4. [SCD / upsert MERGE](scd-upsert-merge/)
5. [Curated / transform layer](curated-transform-layer/)
6. [Query cookbook](query-cookbook/)

Read the [Intern Guide](../../docs/INTERN_ONBOARDING.md) before you start. How a stage is built:
[Stage Playbook](../../standards/STAGE_PLAYBOOK.md).
