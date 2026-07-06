# project-skeleton

## What it is
The canonical LookML project layout to copy when starting any new Looker
project: a `manifest.lkml`, one model file, a `datagroups.lkml`, and
views/explores split into `views/` and `explores/` folders. Use this as the
starting point for a new project (not the star-schema conversion itself --
see the flagship `relational-to-dimensional-conversion-guide` for that --
and not the join-type/relationship survey -- see the sibling
`explore-and-joins` for that). Prerequisites: Python 3.11+, `pytest` (no
Looker instance, no LAMS install, no BigQuery connection).

Read `docs/layout.md` first for the folder-by-folder breakdown and naming
convention.

## Input/output contract
- Input: a BigQuery mart schema like the one Stage 02 produces --
  `sample_data/schema.sql` (documentation-only DDL) + `sample_data/*.csv`
  (sample rows for `fct_order_items` and `dim_date`).
- Output: a lint-clean, minimal LookML project skeleton -- `src/manifest.lkml`,
  `src/datagroups.lkml`, `src/order_items.model.lkml`,
  `src/views/*.view.lkml`, `src/explores/*.explore.lkml` -- that other
  templates or a real project can extend by adding more views/explores under
  the same folders, without changing the model or manifest.

## Run locally
`bash local/run_local.sh`
(then `cd` here and `python -m pytest tests -q` -- see Verify below)

## Cloud-verify only
- Binding the real BigQuery connection via Admin > Connections (the
  `constant: CONNECTION_NAME` placeholder in `manifest.lkml` only becomes a
  live connection there).
- The LAMS ruleset commented out in `manifest.lkml` -- running
  `npx @looker/look-at-me-sideways` for real K/F/T/E/H/W rule coverage
  beyond the three rules `local/lkml_checker.py` checks.
- The `datagroup: nightly_refresh` `sql_trigger` actually firing PDT/cache
  invalidation -- needs a live connection to run the trigger SQL.
