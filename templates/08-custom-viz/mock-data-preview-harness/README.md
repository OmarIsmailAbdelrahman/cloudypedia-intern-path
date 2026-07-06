# mock-data-preview-harness (Stage 08 Custom Visuals)

## What it is
A reusable local preview harness for Looker Custom Visualization API v2 plugins: `src/harness.js`
stubs `window.looker.plugins.visualizations.add` and `window.LookerCharts.Utils`
(`htmlForCell`/`textForCell`/`openDrillMenu`/`toggleCrossfilter`), then fetches mock
`queryResponse.json`/`data.json` fixtures and drives any registered viz through its full
`create` -> `updateAsync(..., done)` lifecycle. `src/example-viz.js` is a trivial viz bundled just
to demonstrate the harness end to end — swap it (and the fixtures) for your own viz to preview
it instead. Use this when you want to see a viz render in a plain browser tab with **no Looker
instance, no Node/npm, and no network access**. Prerequisites: a browser and Python 3.11+
(for `python -m http.server` and the smoke tests).

## Input/output contract
- Input: `sample_data/queryResponse.json` (`fields.dimension_like`/`fields.measure_like`, each
  entry with `name`/`label`/`type`) and `sample_data/data.json` (array of row objects keyed by
  field `name`, each cell `{"value": ..., "rendered": "..."}`) — the same shapes Looker's runtime
  passes to a real viz.
- Output: the viz's DOM rendered into `#viz` in `local/index.html`; `#errors` shows any
  `addError(...)` messages; the browser console logs `done()`/`trigger(...)` calls so you can
  confirm the lifecycle completed.

## Run locally
`bash local/run_local.sh`, then open the printed `http://localhost:8000/local/index.html` URL —
no Looker instance needed. For the smoke tests: `python -m pytest tests -q`.

## Cloud-verify only
Nothing about drill/cross-filter/PDF behavior *inside a real Looker dashboard* can be proven by
this harness — `LookerCharts.Utils.openDrillMenu`/`toggleCrossfilter` are stubbed to `console.log`
here. Confirming those against a live Explore/dashboard needs a real Looker instance (see
`custom-viz-skeleton/README.md` `## Cloud-verify only` for the registration step this harness
front-runs).
