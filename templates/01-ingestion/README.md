# Stage 01 — Ingestion

Get the client's clinical data off Cloud Storage and into the warehouse — the initial extract now, recurring
batches next, a live stream later.

**Teaches:** Cloud Storage · BigQuery load jobs · Pub/Sub · bash · external/BigLake tables · database replication.

**Tasks**
1. Load the initial extract into BigQuery
2. Query the extract in place (external / BigLake)
3. Validate the ingestion (manifest)
4. Ingest the recurring batches (incremental)
5. Ingest the live stream
6. Replicate a source database

**Full scope of each task** — the theme and every task's detail — is in
[Stage 01 of the Stage Playbook](../../standards/STAGE_PLAYBOOK.md). Read the
[Intern Guide](../../docs/INTERN_ONBOARDING.md) before you start, and work the tasks in dependency order.
