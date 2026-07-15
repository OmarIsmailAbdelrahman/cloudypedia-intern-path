# Stage 01 — Ingestion

Get the client's clinical data off Cloud Storage and into the warehouse — the initial extract now, recurring
batches next, a live stream later.

**Teaches:** Cloud Storage · BigQuery load jobs · Pub/Sub · bash · external/BigLake tables · database replication.

**Tasks** — each folder holds its full scope:
1. [Load the initial extract into BigQuery](initial-load-to-bigquery/)
2. [Query the extract in place (external / BigLake)](external-biglake-table/)
3. [Validate the ingestion (manifest)](ingestion-manifest-validation/)
4. [Ingest the recurring batches (incremental)](batch-incremental-ingestion/)
5. [Ingest the live stream](streaming-ingestion/)
6. [Replicate a source database](source-database-replication/)

Read the [Intern Guide](../../docs/INTERN_ONBOARDING.md) before you start, and work the tasks in dependency
order. How a stage is built: [Stage Playbook](../../standards/STAGE_PLAYBOOK.md).
