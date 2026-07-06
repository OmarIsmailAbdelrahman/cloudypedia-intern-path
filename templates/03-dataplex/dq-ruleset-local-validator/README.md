# dq-ruleset-local-validator (flagship)

## What it is
A Dataplex AutoDQ `DataQualitySpec` (`src/dq_spec.yaml`) with at least one rule of each of the 9
`DataQualityRule` types, plus a pure-Python (stdlib) rule engine (`local/validator.py`) that
executes the 6 rule types which map cleanly onto local logic -- `nonNullExpectation`,
`rangeExpectation`, `setExpectation`, `regexExpectation`, `uniquenessExpectation`,
`statisticRangeExpectation` -- against committed sample rows. Use this as the starting point for
any new AutoDQ ruleset: author rules here first, run them locally for a fast fail/fix loop, then
hand the same YAML to `gcloud dataplex datascans create data-quality` for the real scan. The
console labels this product "Knowledge Catalog" but the API/`gcloud`/IAM surface is unchanged --
still keyed on `dataplex`. Prerequisites: Python 3.10+, PyYAML (only used to parse the YAML spec;
the rule engine itself has zero third-party dependencies -- no Great Expectations, no pandas, no
DuckDB).

## Input/output contract
- Input: `src/dq_spec.yaml` (the `DataQualitySpec`, real Dataplex artifact shape) and
  `sample_data/rows.json` (a JSON array of row dicts mirroring a BigQuery `orders` table).
- Output: a JSON report (`{"overall_status", "rules": [...], "cloud_verify_only": [...]}`) --
  one record per locally-executed rule with `evaluated`/`passed`/`pass_ratio`/`threshold`/`status`
  (row-level) or `duplicate_count`/`computed_value`/`status` (aggregate), plus a
  `cloud_verify_only` list of the 3 GoogleSQL rules that were never executed. Downstream stages
  (e.g. an orchestrator gate) should treat `overall_status == "FAIL"` as a hard stop and additionally
  surface `cloud_verify_only` so a human confirms those 3 rules in the real scan.

## Run locally
`bash local/run_local.sh` (prints the JSON report to stdout; exits 1 because the committed sample
data has 4 planted rule violations on purpose -- see `sample_data/expected_report.json`).

## Cloud-verify only
- The 3 GoogleSQL rule types (`rowConditionExpectation`, `tableConditionExpectation`,
  `sqlAssertion`) are never executed locally -- see `docs/parity-note.md` for the full mapping and
  why (no local BigQuery-flavored SQL engine here by design).
- Confirming the actual AutoDQ scan runs against a real BigQuery table (this template only proves
  the rule *arithmetic*, not the live Dataplex scan job, `postScanActions.bigqueryExport`, or the
  catalog scorecard).
- Incremental-scan semantics (`docs/threshold-and-null-semantics.md`): this template models a
  full-table scan only; incremental watermark/back-dated-row and within-increment-uniqueness
  behavior needs a real scan to observe.
