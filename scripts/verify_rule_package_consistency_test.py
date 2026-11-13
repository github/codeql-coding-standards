import csv
import json
from pathlib import Path
import shutil
import subprocess
import sys

import pytest


@pytest.mark.parametrize("standard,tags,valid", [
    ("MISRA-C-2012", ["external/misra/c/2012/third-edition-first-revision"], True),
    ("MISRA-C-2012", ["external/misra/c/2012/amendment4"], True),
    ("MISRA-C-2025", ["external/misra/c/2025"], True),
    ("MISRA-C-2025", ["external/misra/c/2025/amendment1"], True),
    ("MISRA-C-2012", ["external/misra/c/2025"], False),
    ("MISRA-C-2025", ["external/misra/c/2012/amendment4"], False),
    ("MISRA-C-2012", ["external/misra/c/2012"], False),
    ("MISRA-C-2025", ["external/misra/c/20250"], False),
    ("MISRA-C-2012", ["external/misra/c/audit"], False),
    ("MISRA-C-2012", ["external/misra/c/strict"], False),
    ("MISRA-C-2025", ["external/misra/c/audit"], False),
    ("MISRA-C-2025", ["external/misra/c/strict"], False),
    ("MISRA-C-2025", ["correctness"], False),
])
def test_misra_c_requires_a_matching_edition_tag(tmp_path, standard, tags, valid):
    script_directory = tmp_path / "scripts"
    script_directory.mkdir()
    script = script_directory / "verify_rule_package_consistency.py"
    shutil.copyfile(Path(__file__).parent / script.name, script)
    with (tmp_path / "rules.csv").open("w", newline="") as output:
        writer = csv.writer(output)
        writer.writerow(["language", "standard", "rule_id", "supportable", "obligation",
                         "enforcement", "targets", "title", "similar", "package", "difficulty"])
        writer.writerow(["c", standard, "RULE-1-1", "Yes", "Required", "Automated",
                         "", "Fixture", "", "Fixture", "Easy"])
    package_directory = tmp_path / "rule_packages" / "c"
    package_directory.mkdir(parents=True)
    (package_directory / "Fixture.json").write_text(json.dumps({
        standard: {
            "RULE-1-1": {
                "queries": [{"short_name": "Fixture", "tags": tags}],
            },
        },
    }))
    result = subprocess.run(
        [sys.executable, str(script), "c"],
        capture_output=True,
        text=True,
    )
    assert result.returncode == (0 if valid else 1), result.stdout + result.stderr
    if not valid:
        assert "missing" in result.stdout
