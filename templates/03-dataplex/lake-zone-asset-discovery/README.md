# lake-zone-asset-discovery

## What it is
A Dataplex Lake -> Zone(RAW/CURATED) -> Asset hierarchy (`src/lake.yaml`) plus a pure-Python
simulator of the mandatory Discovery step that turns raw GCS files into a queryable BigQuery
external table. Use this as the bootstrap template before authoring any DataScan (see
`../dq-ruleset-local-validator`): a scan needs a BigQuery `dataSourceEntity`, and this template is
where that entity comes from. Prerequisites: Python 3.10+, PyYAML.

## Input/output contract
- Input: `src/lake.yaml` (Lake/Zone/Asset declaration) + `sample_data/gcs_listing.json` (mock GCS
  object listing for the RAW zone's bucket asset) + `sample_data/orders_raw_sample.csv` (one
  sample file, used for schema inference).
- Output: `local/validate_hierarchy.py` prints structural violations (empty = valid);
  `local/discover.py` prints the discovered/skipped object lists and the BigQuery external-table
  descriptor (`published_table`) that Discovery would create -- this is what a DataScan must
  target, per `docs/gcs-to-bq-scan-flow.md`.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Actually running Dataplex Discovery against a real GCS bucket and confirming it publishes the
  BigQuery external table with the schema this template only infers locally.
- Actually creating the Lake/Zone/Asset resources via `gcloud dataplex lakes/zones/assets create`.
- Running a real `DataScan` against the published table (see `../dq-ruleset-local-validator`).
