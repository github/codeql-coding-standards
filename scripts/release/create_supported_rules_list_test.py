import csv
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys

import pytest


LEGACY_EDITION = "external/misra/c/2012/third-edition-first-revision"
CURRENT_EDITION = "external/misra/c/2025"
LEGACY_VARIANT = "external/misra/legacy"


def supported_rules(tmp_path, packages):
    script_directory = tmp_path / "scripts" / "release"
    script_directory.mkdir(parents=True)
    for name in ("create_supported_rules_list.py", "utils.py"):
        shutil.copyfile(Path(__file__).parent / name, script_directory / name)
    for language in ("c", "cpp"):
        (tmp_path / "rule_packages" / language).mkdir(parents=True)
    (tmp_path / "rule_packages" / "c" / "Fixture.json").write_text(json.dumps(packages))
    result = subprocess.run(
        [sys.executable, str(script_directory / "create_supported_rules_list.py"), "--csv"],
        check=True,
        capture_output=True,
        text=True,
    )
    return {
        (row["Coding Standard"], row["Rule ID"]): row["Queries"]
        for row in csv.DictReader(io.StringIO(result.stdout))
    }


@pytest.mark.parametrize("tags", [[LEGACY_EDITION], [LEGACY_EDITION, CURRENT_EDITION]])
def test_unchanged_rules_are_supported_in_both_editions(tmp_path, tags):
    packages = {
        "MISRA-C-2012": {
            rule: {"queries": [{"short_name": name, "tags": tags}]}
            for rule, name in (
                ("RULE-17-3", "FunctionDeclaredImplicitly"),
                ("RULE-17-5", "ArrayFunctionArgumentNumberOfElements"),
                ("RULE-21-8", "TerminationFunctionsOfStdlibhUsed"),
            )
        }
    }
    rows = supported_rules(tmp_path, packages)
    for rule, details in packages["MISRA-C-2012"].items():
        expected = details["queries"][0]["short_name"] + ".ql"
        assert rows["MISRA-C-2012", rule] == expected
        assert rows["MISRA-C-2025", rule] == expected


def test_edition_specific_variants_do_not_overwrite_each_other(tmp_path):
    rows = supported_rules(tmp_path, {
        "MISRA-C-2012": {
            "RULE-15-5": {"queries": [{
                "short_name": "FunctionReturnCondition",
                "tags": [LEGACY_EDITION, LEGACY_VARIANT],
            }]},
        },
        "MISRA-C-2025": {
            "RULE-15-5": {"queries": [{
                "short_name": "SinglePointOfExit",
                "tags": [CURRENT_EDITION, "external/misra/default-disabled"],
            }]},
        },
    })
    assert rows["MISRA-C-2012", "RULE-15-5"] == "FunctionReturnCondition.ql"
    assert rows["MISRA-C-2025", "RULE-15-5"] == "SinglePointOfExit.ql"


def test_applicability_is_filtered_per_query(tmp_path):
    rows = supported_rules(tmp_path, {
        "MISRA-C-2012": {
            "RULE-1-1": {"queries": [
                {"short_name": "Legacy", "tags": [LEGACY_EDITION, LEGACY_VARIANT]},
                {"short_name": "Current", "tags": [LEGACY_EDITION, CURRENT_EDITION]},
            ]},
        },
    })
    assert rows["MISRA-C-2012", "RULE-1-1"] == "Legacy.ql;Current.ql"
    assert rows["MISRA-C-2025", "RULE-1-1"] == "Current.ql"


def test_renumbered_and_new_rules_do_not_leak_into_older_editions(tmp_path):
    rows = supported_rules(tmp_path, {
        "MISRA-C-2012": {
            "RULE-21-1": {"queries": [{
                "short_name": "LegacyReservedMacro",
                "tags": [LEGACY_EDITION, LEGACY_VARIANT],
            }]},
        },
        "MISRA-C-2025": {
            rule: {"queries": [{"short_name": name, "tags": [CURRENT_EDITION]}]}
            for rule, name in (
                ("RULE-20-15", "ReservedMacroName"),
                ("RULE-8-18", "DefinitionsInHeader"),
            )
        },
    })
    assert ("MISRA-C-2025", "RULE-21-1") not in rows
    assert ("MISRA-C-2012", "RULE-20-15") not in rows
    assert ("MISRA-C-2012", "RULE-8-18") not in rows
    assert rows["MISRA-C-2025", "RULE-20-15"] == "ReservedMacroName.ql"


def test_other_standards_are_unchanged(tmp_path):
    rows = supported_rules(tmp_path, {
        "CERT-C": {
            "EXP01-C": {"queries": [{"short_name": "Example", "tags": ["correctness"]}]},
        },
    })
    assert rows == {("CERT-C", "EXP01-C"): "Example.ql"}
