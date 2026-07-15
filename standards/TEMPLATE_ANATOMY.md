# Task anatomy

Every task is a self-contained folder under `<stage>/<task-name>/`. This is the target shape.

> **Migration note:** the conformance checker (`tools/check_template.py`) is being updated to this new anatomy
> (dropping `config/`, adding the scope README + `scripts/` output). Until that lands, some older folders still
> carry the previous shape. See `standards/STAGE_PLAYBOOK.md` for how a stage/task is specified.

```
<stage>/<task-name>/
  README.md      # the SCOPE (given to the intern) — sections below
  scripts/       # the intern's OUTPUT: the script(s) that do the work (cloud-ops stages)
  docs/          # the intern fills this: what they did, steps, screenshots, decisions
  DONE.md        # the definition-of-done checklist
```

- **No `config/` folder.** Required settings and naming are stated **inline** in the README's *Config & naming*
  section, as `<PLACEHOLDER>` values — never real secrets.
- **`verify` / grading tests are the tech lead's**, kept private in `mentor-docs/`. They are **not** part of the
  intern scaffold.
- Stages that produce real local code (later stages) may also carry `src/`, `local/`, `sample_data/`, `tests/`
  — declared per stage in the playbook.

## Required `README.md` sections (the scope)
- `## Goal` — one sentence: what this task achieves.
- `## Context` — where it sits in the stage's story.
- `## Scope of work` — plain sentences describing what must be accomplished (no step-by-step walkthrough).
- `## Inputs & names` — where the data comes from and what it's called.
- `## Target` — where the result lands.
- `## Expectation` — what "correct and complete" means.
- `## Output` — the deliverable the intern produces.
- `## Config & naming` — required settings as inline placeholders.
- *(Optional)* `## Bonus`, `## References / Additional reading`.

## Required `DONE.md` checklist
- [ ] The task's stated output exists and works on the intern's own GCP project.
- [ ] `scripts/` committed (the deliverable).
- [ ] `docs/` written — the intern's own steps, screenshots, and decisions.
- [ ] No data or secrets committed; sensitive data stayed inside the project.
- [ ] Reviewed and approved by the tech lead via PR.
