"""Reference pipeline: aggregate sample rows into counts per category."""
from __future__ import annotations

from collections import Counter


def transform(rows: list[dict]) -> dict:
    counts = Counter(row["category"] for row in rows)
    return {"counts_by_category": dict(sorted(counts.items()))}


if __name__ == "__main__":
    import json
    import sys

    data = json.load(sys.stdin)
    json.dump(transform(data), sys.stdout, indent=2)
    sys.stdout.write("\n")
