# hello-pipeline (reference template)

## What it is
The canonical reference template. It shows the folder anatomy every template follows and the
read-sample-input / assert-sample-output test pattern. Prerequisites: Python 3.11+.

## Input/output contract
- Input: `sample_data/input.json` — a JSON array of `{"category": <string>}` rows.
- Output: `{"counts_by_category": {<category>: <count>, ...}}` (categories sorted).

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
None — this template is fully local by design.
