import shutil
import sys
from pathlib import Path

TOOLS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(TOOLS))
from check_template import check_template, main  # noqa: E402


def make_valid_template(root: Path) -> Path:
    for d in ["src", "local", "sample_data", "config", "tests", "docs"]:
        (root / d).mkdir(parents=True, exist_ok=True)
    (root / "README.md").write_text(
        "## What it is\nx\n"
        "## Input/output contract\nx\n"
        "## Run locally\nx\n"
        "## Cloud-verify only\nx\n",
        encoding="utf-8",
    )
    (root / "DONE.md").write_text("- [x] done\n", encoding="utf-8")
    return root


def test_valid_template_has_no_violations(tmp_path):
    make_valid_template(tmp_path)
    assert check_template(tmp_path) == []


def test_missing_directory_flagged(tmp_path):
    make_valid_template(tmp_path)
    shutil.rmtree(tmp_path / "tests")
    violations = check_template(tmp_path)
    assert any("tests/" in v for v in violations)


def test_missing_file_flagged(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "DONE.md").unlink()
    violations = check_template(tmp_path)
    assert any("DONE.md" in v for v in violations)


def test_missing_readme_section_flagged(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "README.md").write_text("## What it is\nonly this\n", encoding="utf-8")
    violations = check_template(tmp_path)
    assert any("Cloud-verify only" in v for v in violations)


def test_secret_detected(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "config" / "leak.txt").write_text("AIza" + "B" * 35 + "\n", encoding="utf-8")
    violations = check_template(tmp_path)
    assert any("possible secret" in v for v in violations)


def test_aws_access_key_secret_detected(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "config" / "leak.txt").write_text("AKIAIOSFODNN7EXAMPLE\n", encoding="utf-8")
    violations = check_template(tmp_path)
    assert any("possible secret" in v for v in violations)


def test_secret_scan_has_no_false_positive_on_placeholders(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "config" / "config.example.yaml").write_text(
        "api_key: <PLACEHOLDER>\n"
        "db_password: sample_password\n"
        "aws_access_key_id: ${AWS_ACCESS_KEY_ID}\n"
        "gcp_api_key: ${GCP_API_KEY}\n",
        encoding="utf-8",
    )
    violations = check_template(tmp_path)
    assert not any("possible secret" in v for v in violations)


def test_main_returns_zero_on_valid(tmp_path):
    make_valid_template(tmp_path)
    assert main([str(tmp_path)]) == 0


def test_main_returns_one_on_invalid(tmp_path):
    make_valid_template(tmp_path)
    (tmp_path / "README.md").write_text("nope\n", encoding="utf-8")
    assert main([str(tmp_path)]) == 1


def test_main_usage_error_without_args():
    assert main([]) == 2
