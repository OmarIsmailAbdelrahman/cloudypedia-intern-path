# access-control-and-security

## What it is
The governance/access layer: column-level security (taxonomy -> policy tag -> column + masking
rule, `src/column_security.yaml`), row-level security (BigQuery row access policies,
`src/row_security.yaml`), and principal groups + IAM/Dataplex role grants
(`src/groups_and_iam.yaml`). A pure-Python (stdlib) decision-table engine
(`local/decision_table.py`) computes, per principal, which rows are visible and which columns are
masked/unmasked -- so you can answer "what does user X actually see in `orders`?" without a live
BigQuery table. Prerequisites: Python 3.10+, PyYAML.

## Input/output contract
- Input: `src/column_security.yaml`, `src/row_security.yaml`, `src/groups_and_iam.yaml` (the
  three governance specs) and `sample_data/rows.json` (5 sample `orders` rows) +
  `sample_data/test_principals.json` (3 test principals, one per group, with the region context
  `dave` needs for his row filter).
- Output: a JSON decision table, one record per principal: `{"principal", "principal_groups",
  "applicable_row_policies", "unmasked_policy_tags", "visible_row_ids", "rows": [...masked or
  unmasked rows the principal can see...]}`. `sample_data/expected_decision_table.json` is the
  committed expected output for all three test principals.

## Run locally
`bash local/run_local.sh`

## Cloud-verify only
- Actually applying the taxonomy/policy tags, row access policies, and IAM/Dataplex role grants
  to a real BigQuery table and Dataplex lake/zone.
- Testing as a restricted principal against the live table (masked-vs-unmasked query, row-filtered
  query) -- this template only proves the *decision logic*, not the live enforcement.
- Any `filter_using` row-policy expression not in `local/decision_table.py`'s
  `KNOWN_ROW_FILTERS` registry (arbitrary BigQuery SQL row filters are not locally evaluated --
  see `docs/decision-table-notes.md`).
- Creating the actual Cloud Identity groups and adding members.
