# Contributing

## One-time setup
```bash
make setup          # install dev deps
pre-commit install  # enable ruff + conformance gate before each commit
```

## Workflow
1. **Branch** off `main`: `feat/<NN-stage>-<template-name>` (e.g. `feat/01-ingestion-pubsub-streaming-pull`).
   Concept docs: `docs/<NN-stage>-<topic>`.
2. **Build** the template against `standards/TEMPLATE_ANATOMY.md`; keep it self-contained.
3. **Verify locally:** `make lint check test` must be green.
4. **Commit** using Conventional Commits (`feat: · fix: · docs: · chore: · test: · refactor:`), one focused
   commit per logical change.
5. **Open a PR** (one template per PR). Fill the checklist. CI must pass, then your **mentor** reviews and approves it.
6. **Squash-merge** into `main`, then delete the branch. Update the status board in the root `README.md`.

## Definition of done (per template)
Mirror the template's `DONE.md`: runs locally with one command · sample input+output committed · smoke test
passes · README has all four required sections · no secrets in `config/` · approved by your mentor.

## Branch protection (repo admin sets on GitHub)
Require: PR before merge · CI passing · ≥1 approving review · dismiss stale approvals · linear history ·
no direct pushes to `main`.
