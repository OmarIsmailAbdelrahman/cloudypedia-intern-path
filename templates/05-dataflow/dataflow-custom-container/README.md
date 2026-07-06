# dataflow-custom-container

## What it is
A CORE template for the *mechanics* of a custom Dataflow SDK worker
container image -- not a new pipeline's business logic (the
`dataflow-streaming-template` flagship covers that). Use this when a batch
or streaming Beam job needs one of: a native/system library that
`--requirements_file` can't install (`apt-get`, not `pip`), a private/
internal package that isn't on public PyPI, or dependency versions pinned
exactly so they can't silently drift. It shows: the Dockerfile structure
Beam's docs prescribe for custom containers, a real (tiny) "private
package" actually installed into the image from a local path, a local
`docker build` + DirectRunner run, `--sdk_container_image` wiring for a
bare DataflowRunner launch, and Flex Template integration. Prerequisites:
Python 3.10+, `pip install -r requirements.txt` (apache-beam[gcp]) to run
the pipeline logic; Docker only if you want to actually build the image.

## Input/output contract
- Input: a plain text file, one record per line, blank lines allowed (they
  are dropped). See `sample_data/input.txt`.
- Transform: each non-blank line is passed through `vendored_pkg.shout()`
  (a stand-in "private package" function: uppercase + `"!!!"`) via
  `src/transform_logic.process_line`, wired into Beam by
  `src/pipeline_smoke.ShoutFn`.
- Output: one shouted line per input line (blank lines dropped) at
  `out/output` (local run) or the `--output` path (Dataflow run). See
  `sample_data/expected_output.txt` for the exact committed sample output of
  `local/run_local.sh` against `sample_data/input.txt`.
- Container image contract: `docker build -f src/Dockerfile -t <tag> .`
  (run from THIS template's root, not from `src/`) produces an image with
  `vendored_pkg` and `apache_beam` both importable -- see
  `local/build_container.sh`'s post-build sanity checks.

## Run locally
```
pip install -r requirements.txt
bash local/run_local.sh
```
Runs `src/pipeline_smoke.py` directly with plain `python3` on DirectRunner:
reads `sample_data/input.txt`, applies the vendored-package transform, and
writes `out/output`. No Docker, no GCP credentials, no network -- this
proves the *pipeline logic* (including that the vendored "private package"
import actually works) is correct.

Separately, `bash local/build_container.sh` (requires Docker) builds the
custom SDK container image for real and sanity-checks that `vendored_pkg`
and `apache_beam` are both importable inside it -- this proves the
*container image* builds, independent of running the pipeline against real
data.

Smoke tests (no apache-beam or Docker required):
`python -m pytest tests -q`. Wherever apache-beam IS installed,
`tests/test_pipeline_direct_runner.py` also runs the real transform chain
against the DirectRunner and asserts on real output (not a mutated
outer-scope list -- see that file's docstring for why).

## Cloud-verify only
- `local/build_container.sh` only builds and locally sanity-checks the
  image; pushing it to Artifact Registry and referencing it from a real
  Dataflow job (`--sdk_container_image`, `src/run_on_dataflow.py`) needs a
  real GCP project and is not run here.
- `src/flex/build_flex_template.sh`: `docker build`/`push` of both the
  worker and launcher images, plus `gcloud dataflow flex-template
  build`/`run` against a real project/Artifact Registry/GCS bucket -- see
  `docs/diagram.md` for why the worker (`src/Dockerfile`) and launcher
  (`src/flex/Dockerfile`) are two separate images, and how
  `sdk_container_image` is wired in as a Flex Template runtime parameter.
- Autoscaling, worker startup time with a heavier custom image, and any
  actual Dataflow job execution -- none of this can be observed without a
  real running job.
