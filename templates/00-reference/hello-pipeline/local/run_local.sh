#!/usr/bin/env bash
# Run the reference pipeline locally on the committed sample input.
set -euo pipefail
cd "$(dirname "$0")/.."
python src/pipeline.py < sample_data/input.json
