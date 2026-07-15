# Task — Query the extract in place (external / BigLake)

## Goal
Make the extract queryable straight from BigQuery — without moving or copying a single file.

## Context & scope
The sibling task loads the extract into BigQuery's own storage. This one does the opposite: it leaves every file
exactly where the client dropped it and teaches BigQuery to read it in place. An *external table* is just a
schema plus a pointer at `gs://.../<table>/*` — query it and BigQuery reads the objects straight from Cloud
Storage, nothing copied, nothing to keep in sync. That's the right call when you want to profile or sanity-check
a fresh drop before deciding what's worth landing, when the data is touched rarely enough that paying to store a
second copy makes no sense, or when a file still changing under you shouldn't be frozen into a load. The trade
you're learning to weigh: a native load costs storage and an up-front load job but gives you fast, columnar,
partitioned scans; an external table costs nothing to stand up but pays for it on every query — reading raw
files off GCS is slower, it can't cache or cluster, and a malformed row surfaces at query time instead of load
time. Stand these tables up over the initial files, query them, and you'll feel exactly where that line sits.

A plain external table is anonymous — it reads GCS with your own credentials and BigQuery can't govern it. A
**BigLake** table closes that gap: it routes access through a connection's service account, so you grant rows and
columns through BigQuery's own access model instead of handing users raw bucket permissions, and it adds a
metadata cache so repeat queries stop re-listing thousands of objects. That's the difference to understand here —
external gets you querying in place; BigLake makes querying in place governable and faster.

## Inputs & names
The same sharded files under `gs://internship-preperation/Dataset/initial/<table>/*` — one folder per source
table across the `hosp` and `icu` modules.

## Output & expectations
External (and BigLake) tables in your dataset that point at the files and return exactly what's in them, with
nothing copied into BigQuery storage — drop or replace a source file and the table reflects it on the next query.
You deliver the script(s) that create them, and you should be able to say, for this extract, where you'd reach
for one of these versus a native load and why.

## Bonus
- Promote the tables to BigLake over a Cloud resource connection, then use the metadata cache and column- or
  row-level access control to serve the extract without granting anyone direct bucket access.

## References
- External tables on Cloud Storage — https://cloud.google.com/bigquery/docs/external-data-cloud-storage
- Create Cloud Storage BigLake tables — https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake
- BigLake introduction — https://cloud.google.com/bigquery/docs/biglake-intro
- Create a Cloud resource connection — https://cloud.google.com/bigquery/docs/create-cloud-resource-connection

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/initial/`
- Dataset: `<your dataset>`
- BigLake connection: `<your-connection-id>`
