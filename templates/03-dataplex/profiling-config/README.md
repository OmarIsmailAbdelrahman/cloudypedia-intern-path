# profiling-config

## What it is
A Dataplex `DataProfileSpec` (`src/profile_spec.yaml`) plus a pandas-free, pure-stdlib local
profiler (`local/profiler.py`) that computes null%, distinct%, and min/max per column against
sample data. Use this after `../lake-zone-asset-discovery` publishes a BigQuery table and before
authoring DQ rules in `../dq-ruleset-local-validator` -- profiling output is exactly the input a
human (or a future `profile_to_dq.py`) uses to pick sensible thresholds and set values.
Prerequisites: Python 3.10+, PyYAML.

## Input/output contract
- Input: `src/profile_spec.yaml` (`DataProfileSpec`, real Dataplex artifact shape --
  `includeFields`/`excludeFields`/`postScanActions`) and `sample_data/rows.json` (JSON array of
  row dicts, the same `orders` shape used across Stage 03 templates).
- Output: JSON `{"row_count": <int>, "columns": [{"column", "count", "null_count", "null_pct",
  "distinct_count", "distinct_pct", "min_value", "max_value"}, ...]}` -- one record per included
  column, in `includeFields.fieldNames` order minus anything in `excludeFields`.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Running the real profiling `DataScan` against a live BigQuery table (this mirror only proves
  the null%/distinct%/min-max arithmetic on committed sample data, not the actual scan job).
- `samplingPercent` behavior below 100% (the local profiler always reads the full committed
  sample; real sampling is a server-side BigQuery TABLESAMPLE-style operation).
- The full stat set Dataplex computes beyond null%/distinct%/min-max (mean, stddev, quartiles,
  top-N histogram) and the profiling result's appearance in the catalog scorecard.
