# options-config (Stage 08 Custom Visuals)

## What it is
A worked Looker Custom Visualization v2 config-panel example: static options covering the common
display types (`select`, `color`, `range`, plus `section`/`order` grouping) and one dynamic option
(`sort_measure`) built at render time from `queryResponse.fields.measure_like` and registered via
`this.trigger('registerOptions', ...)`. Use this as the reference for building a viz whose config
panel needs to react to what's actually in the query, not just a fixed schema. Prerequisites: a
browser and Python 3.11+ for the smoke tests.

## Input/output contract
- Input: `sample_data/queryResponse.json` with **two** measures (`order_items.total_sales`,
  `order_items.count`) so the dynamic `sort_measure` option has more than one real choice to
  offer, plus `sample_data/data.json` with matching rows.
- Output: DOM rendered into the host `element` -- a titled, sorted list of dimension: measure
  rows, styled per the static options (bar color / font size) and ordered per `sort_direction` +
  the dynamically chosen `sort_measure`.

## Run locally
`bash local/run_local.sh`, then open the printed `http://localhost:8000/local/preview.html` URL —
it includes a hand-rolled control panel so you can change every option (static and dynamic) live,
with no Looker instance needed. For the smoke tests: `python -m pytest tests -q`.

## Cloud-verify only
The actual Looker-generated config panel UI (section headers, select/color/range widgets,
live re-registration behavior when `registerOptions` fires) can only be seen against a real Looker
instance — `local/preview.html`'s panel is a hand-rolled stand-in wired to the same `config`
object, not Looker's real renderer. Registering `src/viz.js` (see `config/manifest.lkml.example`)
is deferred to a supervised Looker session.
