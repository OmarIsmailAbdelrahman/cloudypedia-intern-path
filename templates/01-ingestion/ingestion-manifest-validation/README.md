# Task — Validate the ingestion (manifest)

## Goal
Prove a load is complete and correct, not silently partial.

## Context
Loads can miss a table, drop shards, or truncate — we need to catch that automatically.

## Scope of work
Check that every expected table arrived and that its row counts match what was delivered; fail loudly and name
the table that's off.

## Inputs & names
The loaded dataset plus the source files.

## Target
A pass/fail validation result.

## Expectation
Passes only when all tables are present and counts match; on mismatch it names the offender.

## Output
The validation script(s).

## Bonus
Emit a per-table expected-vs-actual summary.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
- Source bucket: `<PLACEHOLDER>`
