# catalog-tagging-lineage

## What it is
A custom Dataplex Catalog Aspect Type (`src/aspect_type.json`), two Aspect instances attached to
the `orders` entry (`src/aspects.json`, one table-level and one column-level via `path`), and a
custom OpenLineage `RunEvent` (`src/openlineage_event.json`) recording the
GCS-to-BigQuery-external-table lineage edge from `../lake-zone-asset-discovery`. All three are
schema-validated locally in pure Python/stdlib. Use this to author governance tags and a lineage
event and catch structural mistakes before ever calling the Dataplex Catalog or lineage APIs.
Prerequisites: Python 3.10+ (no third-party dependencies at all -- everything here is JSON +
stdlib).

## Input/output contract
- Input: `src/aspect_type.json` (the Aspect Type schema), `src/aspects.json` (Aspect instances),
  `src/openlineage_event.json` (the lineage event); `sample_data/invalid_aspect.json` and
  `sample_data/invalid_openlineage_event.json` are deliberately-broken fixtures used to prove the
  validators actually catch problems.
- Output: `local/validate_aspects.py` prints a JSON list of `{"entry", "path", "violations"}` per
  aspect (empty `violations` = valid); `local/validate_openlineage.py` prints `OK` or `FAIL` plus
  a violation list. `sample_data/expected_aspects_validation.json` is the committed expected
  output for the valid aspects.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Actually creating the Aspect Type and attaching Aspects via the Dataplex Catalog API.
- POSTing `src/openlineage_event.json` to a real lineage-ingestion endpoint and confirming it
  appears in the lineage graph (latency is documented as 30 min - 24 h, with partial
  column-level detail).
- Confirming Dataplex's automatic BigQuery-job lineage capture (this template only covers the
  custom-event path, not the auto-BQ-lineage path).
- Catalog **search** over the created entries/aspects.
