"""Validate a template folder against standards/TEMPLATE_ANATOMY.md."""
from __future__ import annotations

import re
import sys
from pathlib import Path

# Two flavors. A folder with a `src/` dir is a legacy "code" template (old anatomy);
# anything else is the new "cloud-ops" task folder (scope README + scripts + docs).
REQUIRED_FILES = ["README.md", "DONE.md"]

REQUIRED_DIRS_CODE = ["src", "local", "sample_data", "config", "tests", "docs"]
REQUIRED_SECTIONS_CODE = [
    "## What it is",
    "## Input/output contract",
    "## Run locally",
    "## Cloud-verify only",
]

REQUIRED_DIRS_OPS = ["scripts", "docs"]
REQUIRED_SECTIONS_OPS = [
    "## Goal",
    "## Scope of work",
    "## Output",
]
SECRET_PATTERNS = [
    # Generic PEM-style key block header -- already covers RSA/EC/OPENSSH/ENCRYPTED/PGP variants
    # (e.g. "-----BEGIN RSA PRIVATE KEY-----", "-----BEGIN OPENSSH PRIVATE KEY-----") since
    # `[A-Z ]*` matches any of those prefixes before "PRIVATE KEY-----".
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"AIza[0-9A-Za-z_\-]{35}"),
    # AWS access key ID (high-signal, fixed-format -- not prone to matching placeholders).
    re.compile(r"AKIA[0-9A-Z]{16}"),
]


def check_template(path) -> list[str]:
    path = Path(path)
    violations: list[str] = []

    # Flavor: legacy "code" template if it has a src/ dir, else new "cloud-ops" task.
    if (path / "src").is_dir():
        required_dirs, required_sections = REQUIRED_DIRS_CODE, REQUIRED_SECTIONS_CODE
    else:
        required_dirs, required_sections = REQUIRED_DIRS_OPS, REQUIRED_SECTIONS_OPS

    for d in required_dirs:
        if not (path / d).is_dir():
            violations.append(f"missing required directory: {d}/")
    for f in REQUIRED_FILES:
        if not (path / f).is_file():
            violations.append(f"missing required file: {f}")

    readme = path / "README.md"
    if readme.is_file():
        text = readme.read_text(encoding="utf-8", errors="ignore").lower()
        for section in required_sections:
            if section.lower() not in text:
                violations.append(f"README.md missing section: {section}")

    for file in path.rglob("*"):
        if not file.is_file():
            continue
        content = file.read_text(encoding="utf-8", errors="ignore")
        for pat in SECRET_PATTERNS:
            if pat.search(content):
                rel = file.relative_to(path)
                violations.append(f"possible secret in {rel} (matched /{pat.pattern}/)")

    return violations


def main(argv: list[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else argv
    if not argv:
        print("usage: check_template.py <template_dir> [<template_dir> ...]")
        return 2

    any_failed = False
    for target in argv:
        violations = check_template(target)
        if violations:
            any_failed = True
            print(f"FAIL {target}")
            for v in violations:
                print(f"  - {v}")
        else:
            print(f"OK   {target}")
    return 1 if any_failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
