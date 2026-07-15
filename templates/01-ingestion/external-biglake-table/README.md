# Task — Query the extract in place (external / BigLake)

## Goal
Make the extract queryable from BigQuery without copying it.

## Context
Sometimes we want to inspect or validate the data where it sits before committing to a load.

## Scope of work
Define external/BigLake tables over the extract files so they can be queried with SQL, and understand when
querying in place beats a native load.

## Inputs & names
The same extract files in the client's Cloud Storage bucket.

## Target
External/BigLake tables in a BigQuery dataset, pointing at the files.

## Expectation
Each table returns the same data as the files, with nothing copied.

## Output
The script(s) that create the external tables.

## Bonus
Add a BigLake connection with metadata caching or fine-grained access.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Source bucket: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
- Connection: `<PLACEHOLDER>`
