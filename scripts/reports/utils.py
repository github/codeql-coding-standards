from collections import defaultdict, namedtuple
from contextlib import redirect_stdout
import json
from pathlib import Path
import re
import sys

REPO_ROOT = Path(__file__).parent.parent.parent
SUPPORTED_CODEQL_CONFIG_FILE = REPO_ROOT.joinpath(
    'supported_codeql_configs.json')


def split_rule_id(rule_id):
    """Splits the rule_id into the rule_type and rule_number"""
    return tuple(int(x) if x.isdigit() else x for x in filter(len, filter(None, re.split("(\d+)|-", rule_id))))


def load_supported_environments():
    """Return a list of supported environments for the current Coding Standards release."""
    try:
        supported_codeql_configs_file = SUPPORTED_CODEQL_CONFIG_FILE.open('r')
    except PermissionError:
        print("Error: No permission to read the supported_codeql_configs.json file located at 'supported_codeql_configs.json'.", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(
            f"Error: Could not find the file {str(SUPPORTED_CODEQL_CONFIG_FILE)} expected to contain the supported CodeQL configurations.", file=sys.stderr)
        sys.exit(1)
    else:
        with supported_codeql_configs_file:
            supported_codeql_configs = json.load(supported_codeql_configs_file)
            return supported_codeql_configs['supported_environment']


def load_sarif(sarif_results_file_path):
    """Read the SARIF file at sarif_results_file_path and return a dict containing the loaded file."""
    # Read SARIF, process results, produce markdown report
    print(f"Loading SARIF file...", file=sys.stderr)
    try:
        sarif_results_file = open(sarif_results_file_path, "r")
    except PermissionError:
        print("Error: No permission to read the SARIF results file located at '" +
              str(sarif_results_file_path) + "'", file=sys.stderr)
        sys.exit(1)
    else:
        with sarif_results_file:
            sarif_results_json = json.load(sarif_results_file)
    print(f"SARIF file loaded", file=sys.stderr)
    return sarif_results_json

    # TODO Warn if using a results file from a different version of the Coding Standards pack


class CodingStandardsResultSummary:
    def __init__(self, sarif_results_file_path):
        """Create a results summary from the given SARIF path"""
        sarif_results_json = load_sarif(sarif_results_file_path)
        number_of_runs = len(sarif_results_json["runs"])
        if not number_of_runs == 1:
            print(
                f"Error: Expected a single SARIF run, but found { number_of_runs } runs.", file=sys.stderr)
            sys.exit(1)
        run = sarif_results_json["runs"][0]

        # Identify the Coding Standard version numbers used
        tool = run["tool"]
        driver = tool["driver"]
        self.codeql_cli_version = driver["semanticVersion"]
        # Validate that this is, indeed, a CodeQL file
        if not driver["name"] == "CodeQL":
            print(
                f"Error: SARIF file is not produced by CodeQL (toolName { driver['name'] }", file=sys.stderr)
            sys.exit(1)

        extensions = tool["extensions"]

        self.coding_standard_relevant_packs = []
        coding_standard_name_endings = ["cpp-coding-standards", "c-coding-standards", "codeql/cpp-all"]
        for extension in extensions:
            for ending in coding_standard_name_endings:
                if extension["name"].endswith(ending):
                    self.coding_standard_relevant_packs.append(extension)

        # Count the results per SARIF rule ID
        sarif_rule_result_count = defaultdict(int)
        # Count the deviations per SARIF rule ID
        sarif_rule_deviation_count = defaultdict(int)
        results = run["results"]
        for result in results:
            sarif_rule_id = result["ruleId"]
            if "suppressions" in result and len(result['suppressions']) != 0:
                sarif_rule_deviation_count[sarif_rule_id] += 1
            else:
                sarif_rule_result_count[sarif_rule_id] += 1

        # The number of guidelines violated for each obligation level
        self.guidelines_violated_by_obligation = defaultdict(int)
        self.guidelines_compliant_by_obligation = defaultdict(int)

        # The number of violation and deviations results per guideline
        self.guideline_violation_count = {}
        self.guideline_obligation_level = {}
        self.guideline_deviation_count = {}

        obligation_level_re = re.compile(
            "^external/([^/]+)/obligation/([^/]+)$")
        id_re = re.compile("^external/([^/]+)/id/([^/]+)$")
        rules = driver["rules"]
        for rule in rules:
            sarif_rule_id = rule["id"]
            # Process the tags to determine rule id, standard name and obligation level
            obligation_level = None
            standard_short_name = None
            standard_rule_id = None
            for tag in rule["properties"]["tags"]:
                obligation_level_result = obligation_level_re.search(tag)
                if obligation_level_result:
                    obligation_level = obligation_level_result.group(2)
                    # Remap CERT "rule" obligations to "required", by default.
                    # CERT doesn't provide obligation levels, so we have to make a choice about how to handle this
                    # case. We choose to default to the MISRA Compliance category of 'required', but, unlike MISRA
                    # or AUTOSAR 'required' rules, we should permit re-categorization to 'advisory' or even
                    # 'disapplied'.
                    if obligation_level == "rule":
                        obligation_level = "required"
                id_result = id_re.search(tag)
                if id_result:
                    standard_short_name = id_result.group(1)
                    standard_rule_id = id_result.group(2)

            if standard_rule_id:
                if not obligation_level:
                    print(
                        f"WARNING: Rule { rule['id'] } does not have an obligation level.", file=sys.stderr)
                elif sarif_rule_result_count[sarif_rule_id] > 0:
                    # Add to the violated obligation count
                    self.guidelines_violated_by_obligation[obligation_level] += 1
                else:
                    # Otherwise add to the compliant obligation count
                    self.guidelines_compliant_by_obligation[obligation_level] += 1
                # Add to counts for the rule
                self.guideline_violation_count.setdefault(
                    standard_short_name, defaultdict(int))
                self.guideline_violation_count[standard_short_name][
                    standard_rule_id] += sarif_rule_result_count[sarif_rule_id]
                # Store the obligation level for each guideline
                self.guideline_obligation_level.setdefault(
                    standard_short_name, {})
                if standard_rule_id in self.guideline_obligation_level[standard_short_name]:
                    if not self.guideline_obligation_level[standard_short_name][standard_rule_id] == obligation_level:
                        print(
                            f"WARNING: Rule { rule['id'] } specifies a conflicting obligation level of { obligation_level }, was previously specified as { guideline_obligation_level[standard_short_name][standard_rule_id] }.")
                else:
                    self.guideline_obligation_level[standard_short_name][standard_rule_id] = obligation_level
                # Add deviation counts for the rule
                self.guideline_deviation_count.setdefault(
                    standard_short_name, defaultdict(int))
                self.guideline_deviation_count[standard_short_name][
                    standard_rule_id] += sarif_rule_deviation_count[sarif_rule_id]


def generate_guideline_compliance_summary(output_directory, results_summary):
    """Print "guideline compliance summary", as described by the MISRA Compliance 2020 document."""
    guideline_compliance_summary_path = output_directory.joinpath(
        "guideline_compliance_summary.md")
    try:
        guideline_compliance_summary_file = open(
            guideline_compliance_summary_path, "w")
    except PermissionError:
        print("Error: No permission to write to the output file located at '" +
              str(guideline_compliance_summary_path) + "'", file=sys.stderr)
        sys.exit(1)
    else:
        with guideline_compliance_summary_file:
            # Print to gcs file file, rather than stdout
            with redirect_stdout(guideline_compliance_summary_file):
                print("# Guideline Compliance Summary")
                print()
                print("## Overview")
                print()
                total_guidelines_violated = sum(
                    results_summary.guidelines_violated_by_obligation.values())
                print(
                    "**Result**: " + ("Not compliant" if total_guidelines_violated > 0 else "Compliant"))
                standard_pretty_name = {
                    "cert": "CERT C++ 2016", "autosar": "AUTOSAR C++  R22-11, R21-11, R20-11, R19-11 and R19-03"}
                print("**Coding Standards applied**: " + ", ".join([standard_pretty_name[standard_short_name]
                      for standard_short_name in results_summary.guideline_violation_count.keys()]))

                packs = ", ".join(
                    [f"{ pack['name'] }: { pack['semanticVersion'] }" for pack in results_summary.coding_standard_relevant_packs])
                print(
                    f"**Tool version:** CodeQL CLI { results_summary.codeql_cli_version }")
                print(f"**CodeQL packs used:** { packs }")
                if total_guidelines_violated > 0:
                    print("**Violations by obligation level**:")
                    for obligation_level, count in results_summary.guidelines_violated_by_obligation.items():
                        print(
                            f" - { count } { obligation_level} guidelines violated")
                print()
                print("## Guidelines")
                print()
                print("| Standard | Guideline | MISRA Category | Compliance |")
                print("| -------- | --------- | -------------- | ---------- |")
                for standard_short_name in results_summary.guideline_violation_count.keys():
                    for guideline in sorted(results_summary.guideline_violation_count[standard_short_name].keys(), key=split_rule_id):
                        violation_count = results_summary.guideline_violation_count[
                            standard_short_name][guideline]
                        deviation_count = results_summary.guideline_deviation_count[
                            standard_short_name][guideline]
                        if deviation_count > 0:
                            compliance = f"{violation_count} violation(s) and {deviation_count} deviation(s)" if violation_count > 0 else f"Compliant with {deviation_count} deviation(s)"
                        else:
                            compliance = f"{violation_count} violation(s)" if violation_count > 0 else "Compliant"
                        print(
                            f"| { standard_pretty_name[standard_short_name] } | { guideline.upper() } | { results_summary.guideline_obligation_level[standard_short_name][guideline].capitalize() } | { compliance } |")
