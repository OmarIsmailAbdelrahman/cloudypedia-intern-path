# Template anatomy

Every template is a self-contained folder under `templates/NN-stage/<template-name>/` with this shape.
`tools/check_template.py` enforces the required parts.

```
templates/NN-stage/<template-name>/
  README.md          # required sections below
  src/               # the actual solution (code, SQL, DAG, LookML, Dockerfiles…)
  local/             # local run harness: emulator / docker-compose / run script
  sample_data/       # committed mock INPUTS and sample OUTPUTS
  config/            # config with <PLACEHOLDER> values only — NO secrets
  tests/             # a smoke test proving it runs locally
  docs/              # diagram + deeper notes
  DONE.md            # the definition-of-done checklist
```

## Required `README.md` sections (exact headers)
- `## What it is` — one paragraph: what it does, when to use it, prerequisites.
- `## Input/output contract` — the shape of inputs consumed and outputs produced (what downstream stages rely on).
- `## Run locally` — the single command to run it from a clean checkout.
- `## Cloud-verify only` — what CANNOT be proven locally and needs a supervised GCP step (may say "none").

## Required `DONE.md` checklist
- [ ] Runs locally from a clean checkout with one command.
- [ ] Sample input AND output committed to `sample_data/`.
- [ ] Smoke test passes locally.
- [ ] README complete with all four required sections.
- [ ] `config/` has no secrets (only `<PLACEHOLDER>` / `.env.example`).
- [ ] Reviewed and approved by your mentor via PR.
- [ ] (Optional) Cloud-verify step logged, if platform access was available.
