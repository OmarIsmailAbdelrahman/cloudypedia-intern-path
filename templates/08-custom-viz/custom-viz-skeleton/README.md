# custom-viz-skeleton (FLAGSHIP — Stage 08 Custom Visuals)

## What it is
The minimal, correct shape of a Looker Custom Visualization API v2 plugin: `looker.plugins
.visualizations.add({ id, label, options, create, updateAsync })`. It validates `queryResponse
.fields` before touching `data`, renders cells via `LookerCharts.Utils.htmlForCell`, and calls
`done()` on every code path (including error paths). Use this as the starting point for any new
custom viz; every other template in `08-custom-viz/` builds on this shape. Prerequisites: a
browser, and Python 3.11+ for the smoke tests (no Node/npm required to develop or test this
template — see `package.json` for the optional bundling note).

## Input/output contract
- Input: two Looker-shaped JSON fixtures in `sample_data/`:
  - `queryResponse.json` — `{"fields": {"dimension_like": [...], "measure_like": [...], ...}}`,
    each field object having at least `name`/`label`/`type`.
  - `data.json` — an array of row objects keyed by field `name`, each cell shaped
    `{"value": ..., "rendered": "..."}` (the same shape Looker passes at runtime).
- Output: DOM rendered into the host `element` (a `<ul>` of dimension: measure rows, bar-colored
  by the `bar_color` option) — no return value; Looker communicates completion via `done()` and
  errors via `this.addError(...)`.

## Run locally
`bash local/run_local.sh`, then open the printed `http://localhost:8000/local/preview.html` URL
in a browser — no Looker instance needed. For the smoke tests: `python -m pytest tests -q`.

## Cloud-verify only
Registering `src/viz.js` in a real Looker project's `manifest.lkml` (see
`config/manifest.lkml.example`), confirming it renders against a live Explore, and exercising
drill/cross-filter/PDF export against real dashboard data. None of that is required to develop
or validate this template locally.
