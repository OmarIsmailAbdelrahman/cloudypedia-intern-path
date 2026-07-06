# Intern Onboarding

Welcome. You'll be building **reusable templates** for a GCP data-engineering pipeline while you work
through the Professional Data Engineer course. This page gets you productive in ~30 minutes.

## 1. What you're building

A **template** = the structure of a real solution + a working example you can run on your laptop + docs on
how to use it. You own a **stage** (one tool — e.g. Dataflow, BigQuery, Vertex) and become the team's
go-to person for it. You build the *local* version; touching real GCP happens later, only under supervision.

## 2. Set up (once)

```bash
git clone <repo-url> && cd cloudypedia-intern-path
make setup            # Python 3.11+ dev deps
pre-commit install    # runs lint + conformance before each commit
make lint check test  # confirm everything is green on your machine
```

> **What's `make`?** A tiny command-line shortcut runner (GNU Make) — not a library, not something we build.
> `make setup` just runs `pip install -r requirements-dev.txt`, `make check` runs the conformance checker,
> etc. It's pre-installed on macOS/Linux; on Windows use WSL or Git Bash. See the README's "About `make`"
> section for the exact command behind each shortcut — you can always run those directly instead.

Read, in order: this page → `standards/TEMPLATE_ANATOMY.md` → `standards/CONVENTIONS.md` →
`CONTRIBUTING.md`. Then study the worked example:
```bash
cd templates/00-reference/hello-pipeline
bash local/run_local.sh          # see it run
python -m pytest tests -q         # see its smoke test
cat README.md DONE.md             # see the required docs
```

## 3. The anatomy every template must have

```
templates/NN-stage/<your-template>/
  README.md      # 4 required sections: What it is · Input/output contract · Run locally · Cloud-verify only
  src/           # the actual solution (code / SQL / DAG / Dockerfile / LookML / JS)
  local/         # a one-command local runner (emulator / DirectRunner / docker / script)
  sample_data/   # committed sample INPUT and OUTPUT
  config/        # <PLACEHOLDER> values ONLY — never a real key or password
  tests/         # a smoke test that runs locally and asserts real behaviour
  docs/          # a short note / diagram
  DONE.md        # the definition-of-done checklist
```
`python tools/check_template.py templates/NN-stage/<your-template>` must print `OK`.

## 4. Your build loop (per template)

1. **Pick your issue** (one per template) — it lists the *modes/methods* and *corner cases* your template
   must handle (your mentor prepares this brief). Also read this template's own `README.md` (the target)
   and its `TODO.md`.
2. **Branch:** `git checkout -b feat/NN-stage-<template-name>`.
3. **Build** to the anatomy. Copy the reference template's shape, and read
   `standards/TEMPLATE_ANATOMY.md` + `standards/CONVENTIONS.md` for the rules.
4. **Make it real, but local.** Use emulators / DirectRunner / DuckDB / docker+curl / mock JSON — whatever
   your stage's `## Cloud-verify only` note says can't run locally, leave for a supervised session.
5. **Write a smoke test that asserts behaviour** (not just "the file exists"). Put the pure logic in a
   function and test it.
6. **Green up:** `make lint check test` must pass.
7. **Open a PR** (one template). Fill the checklist. A *different* intern reviews it.
8. **Merge** (squash), then tick your row on the README status board.

## 5. Concept docs (part of the job)

For your stage, write a 1–2 page explainer under `standards/CONCEPTS/<stage>/` for the general ideas the
team should share (e.g. watermarks & late data, symmetric aggregates, SCD types, the Vertex serving
contract). Documenting the concept is half the point of the internship.

## 6. Hard rules (don't break these)

- **It runs locally, or it isn't done.** Never make a task depend on cloud access.
- **Never commit secrets.** No real keys, tokens, passwords, or service-account JSON. `config/` is
  placeholders only. `.gitignore` and the checker help, but *you* are the last line of defence.
- **Don't touch the GCP console without supervision.** Ask first — always.
- **One template per PR**, reviewed by someone else, CI green before merge.

## 7. Stuck?

Re-read your stage's spec section and the sibling templates. Ask your mentor early — a 10-minute question
beats a day lost. Open a `bug` issue if something in the shared tooling is wrong.
