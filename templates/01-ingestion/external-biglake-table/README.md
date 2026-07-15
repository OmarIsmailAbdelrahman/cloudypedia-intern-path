# Task — Query the extract in place (external / BigLake)

## Goal
Make the extract queryable straight from BigQuery — without moving or copying a single file.

## Context & scope
Before committing to a full load, it's often smarter to look at the data where it already sits. BigQuery can
read files in Cloud Storage in place through external (and BigLake) tables, so you can profile and sanity-check
the extract with plain SQL. Stand those tables up over the initial files, and get a feel for when reading in
place is the right call versus loading natively.

## Inputs & names
The same sharded files under `gs://internship-preperation/Dataset/initial/<table>/*`.

## Output & expectations
External/BigLake tables in your dataset that point at the files and return exactly what's in them — with
nothing copied into BigQuery storage. You deliver the script(s) that create them.

## Bonus
- Back the tables with a BigLake connection to add metadata caching or fine-grained access control.

## References
- External tables on Cloud Storage — https://cloud.google.com/bigquery/docs/external-data-cloud-storage
- Create Cloud Storage BigLake tables — https://cloud.google.com/bigquery/docs/create-cloud-storage-table-biglake
- BigLake introduction — https://cloud.google.com/bigquery/docs/biglake-intro

## Config & naming
- Project: `<your-project-id>`
- Source bucket: `gs://internship-preperation/Dataset/initial/`
- Dataset: `<your dataset>`
- BigLake connection: `<your-connection-id>`
