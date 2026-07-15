# Task — Query the Extract In Place (External / BigLake)

## Goal
Make the initial extract queryable directly from BigQuery without moving or copying any files, and be able to
justify when querying in place is preferable to a native load.

## Context & Scope
The initial-load task copies the extract into BigQuery's managed storage. This task does the opposite: it leaves
the files in Cloud Storage and configures BigQuery to read them in place. An *external table* is a schema plus a
pointer at `gs://.../<table>/*`; querying it reads the objects directly from Cloud Storage, with nothing copied
and nothing to keep in sync. This is appropriate when profiling or sanity-checking a fresh drop before deciding
what to land, when data is queried rarely enough that a second stored copy is not justified, or when a file that
is still changing should not be frozen into a load. The trade-off to evaluate: a native load costs storage and an
up-front load job but delivers fast, columnar, partitioned scans; an external table costs nothing to create but
is slower on every query, cannot cache or cluster, and surfaces malformed rows at query time rather than load
time.

A plain external table reads Cloud Storage with the querying user's own credentials and cannot be governed by
BigQuery. A **BigLake** table routes access through a connection's service account, so access is granted through
BigQuery's own model — including row- and column-level controls — instead of direct bucket permissions, and it
adds a metadata cache that avoids re-listing objects on repeat queries. External makes the data queryable in
place; BigLake makes querying in place governable and faster.

## Inputs & Configuration
- **Project:** `<your-project-id>`
- **Source Bucket:** `gs://internship-preperation/Dataset/initial/` (one folder per table, `<table>/*`, across
  the `hosp` and `icu` modules)
- **Dataset:** `<your dataset>`
- **BigLake Connection:** `<your-connection-id>`

## Output & Deliverables
- External (and BigLake) tables in your dataset that point at the source files and return exactly their contents,
  with nothing copied into BigQuery storage — replacing a source file is reflected on the next query.
- The script(s) that create them, in `scripts/`.
- A short note in `docs/` stating, for this extract, when you would choose an external/BigLake table versus a
  native load, and why.

## Technical Constraints & Anti-Boilerplate Rules
- **No data copied.** The tables must read from Cloud Storage in place; do not load anything into managed storage.
- **Zero hardcoding.** Discover the per-table folders dynamically rather than defining each table by hand.
- **Reasoned trade-off.** The `docs/` note must justify external/BigLake versus a native load for this data, not
  merely describe the mechanics.

## Bonus Objectives
- Promote the tables to BigLake over a Cloud resource connection, then use the metadata cache and column- or
  row-level access control to serve the extract without granting anyone direct bucket access.

## References
- External tables on Cloud Storage — https://cloud.google.com/bigquery/docs/external-data-cloud-storage
- Create Cloud Storage BigLake tables — https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake
- BigLake introduction — https://cloud.google.com/bigquery/docs/biglake-intro
- Create a Cloud resource connection — https://cloud.google.com/bigquery/docs/create-cloud-resource-connection
