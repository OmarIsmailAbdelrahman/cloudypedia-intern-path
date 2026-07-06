# feature-survey (living doc)

## What it is
A short, structured catalog (`src/feature_survey.yaml`) of Dataplex / Knowledge Catalog features
that are NOT yet templated elsewhere in Stage 03 -- business glossary, data insights, data
documentation, auto DQ recommendations, data classification, the legacy Spark "Data Quality
Tasks" (do-not-use), catalog search, metadata import, and the lineage graph viewer -- each with a
one-line "what it's for" plus a `should_template: yes|maybe|no` verdict and rationale. A small
stdlib validator/summarizer (`local/check_survey.py`) keeps the doc well-formed and surfaces the
current "should-template: yes" shortlist so coverage gaps stay visible instead of buried in prose.
Use/update this whenever you touch a Dataplex feature that doesn't have a core template yet.
Prerequisites: Python 3.10+, PyYAML.

## Input/output contract
- Input: `src/feature_survey.yaml` (list of `{name, what_its_for, should_template, rationale}`
  records) and `sample_data/invalid_feature_survey.yaml` (a deliberately broken fixture used only
  by the smoke test to prove the validator catches real problems).
- Output: `local/check_survey.py` prints `FAIL` + violations (non-zero exit) if the doc is
  malformed, otherwise a JSON summary `{"total_features", "counts_by_should_template",
  "yes_candidates"}`. `sample_data/expected_summary.json` is the committed expected summary for
  the current survey.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
None -- this template is a pure local doc/data catalog with a stdlib validator; it makes no GCP
calls. (The features it *catalogs* are of course cloud features, but cataloging them requires no
cloud access.)
