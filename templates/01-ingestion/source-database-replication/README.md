# Task — Replicate a source database

## Goal
Bring a live source-hospital SQL database into the platform.

## Context
Not every source is files — some are operational databases that must be replicated continuously.

## Scope of work
Set up replication from a source SQL database into BigQuery so changes flow through; understand
change-data-capture vs full copy.

## Inputs & names
A source SQL database. Connection details (username / password / host-ip) are provided by the tech lead — left
blank for now.

## Target
Replicated tables in BigQuery.

## Expectation
Source rows and changes appear in BigQuery and keep up.

## Output
The replication setup script(s)/config.

## Bonus
Capture changes via CDC rather than full reloads.

## References / Additional reading
TBD.

## Config & naming
- Project: `<PLACEHOLDER>`
- Dataset: `<PLACEHOLDER>`
- Source DB host/ip: `<TBD by tech lead>`
- Source DB username: `<TBD by tech lead>`
- Source DB password: `<TBD by tech lead>`
