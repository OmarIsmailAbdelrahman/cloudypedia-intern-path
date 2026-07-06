import json
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE))
from src.pipeline import transform  # noqa: E402


def test_transform_matches_committed_sample_output():
    rows = json.loads((BASE / "sample_data" / "input.json").read_text(encoding="utf-8"))
    expected = json.loads((BASE / "sample_data" / "output.json").read_text(encoding="utf-8"))
    assert transform(rows) == expected
