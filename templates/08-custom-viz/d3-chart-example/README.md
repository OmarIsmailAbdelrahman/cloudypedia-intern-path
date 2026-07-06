# d3-chart-example (Stage 08 Custom Visuals)

## What it is
A real D3 bar chart built on the `custom-viz-skeleton` contract: one dimension on the x-axis, one
measure as bar height, colored via a `bar_color` option. Adds the three corner cases a "toy"
skeleton doesn't need to handle: responsive resize (size read from the live container plus a
`ResizeObserver` for container-driven resizes), full DOM/SVG clearing on every render, and
cross-filter/drill click wiring (`details.crossfilterEnabled` -> `LookerCharts.Utils
.toggleCrossfilter`, else `LookerCharts.Utils.openDrillMenu` when the cell has `links`).
Prerequisites: a browser and Python 3.11+ for the smoke tests. D3 is vendored locally (see below)
so no network access is needed to preview.

## Input/output contract
- Input: `sample_data/queryResponse.json` (one dimension, one measure) and `sample_data/data.json`
  — each dimension cell additionally carries a `links` array (`{"label": ..., "url": ...}`) so the
  drill fallback has something real to open.
- Output: an SVG bar chart rendered into the host `element`, resized to fill it; clicking a bar
  either toggles a cross-filter (when `details.crossfilterEnabled`) or opens the drill menu for
  that cell's links.

## Run locally
`bash local/run_local.sh`, then open the printed `http://localhost:8000/local/preview.html` URL —
drag the chart box to resize it, and toggle the "crossfilterEnabled" checkbox to see the click
behavior change; the log panel prints every `toggleCrossfilter`/`openDrillMenu`/`done()` call. No
Looker instance and no CDN/network access needed (D3 is vendored at `local/vendor/d3.v7.min.js`).
For the smoke tests: `python -m pytest tests -q`.

## Cloud-verify only
Real cross-filtering behavior (another tile on the same dashboard actually reacting to
`toggleCrossfilter`) and real drill-menu rendering/navigation can only be confirmed against a live
Looker dashboard — this template's preview only logs the calls Looker would otherwise act on.
Registering `src/viz.js` (see `config/manifest.lkml.example`) is deferred to a supervised Looker
session.
