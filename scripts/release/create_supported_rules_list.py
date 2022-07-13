import os
from pathlib import Path
import sys
import json
from utils import *

help_statement = """
Usage: {script_name}

A tool for producing a canonical list of rules supported by the Coding Standards queries.

When run without any arguments, the script iterates through each of the rule package description
files stored in the `rule_packages` directory, and identifies which rules are supported by one or
more queries.

This script needs to be run with the codeql-coding-standards git repository as the current working
directory.
"""

if (len(sys.argv) == 2 and sys.argv[1] == "--help"):
    print(help_statement.format(script_name=sys.argv[0]))
    sys.exit(0)

if len(sys.argv) > 2:
    print("Error: incorrect number of arguments", file=sys.stderr)
    print("Usage: " + sys.argv[0] + " [--csv]", file=sys.stderr)
    sys.exit(1)

is_csv = len(sys.argv) == 2 and sys.argv[1] == "--csv"

repo_root = Path(__file__).parent.parent.parent

rules_covered = {"AUTOSAR" : {}, "CERT-C++" : {}, "MISRA-C-2012" : {}, "CERT-C" : {}}

# Iterate over rule packages
for language_name in ["cpp", "c"]:
    rule_packages_file_path = repo_root.joinpath('rule_packages', language_name)
    for rule_package_file_name in os.listdir(rule_packages_file_path):
        try:
            rule_package_file = open(rule_packages_file_path.joinpath(rule_package_file_name), "r")
        except PermissionError:
            print("Error: No permission to read the rule package file located at '" + str(rule_package_file_name) + "'")
            sys.exit(1)
        else:
            with rule_package_file:
                package_definition = json.load(rule_package_file)
                for standard_name, rules in package_definition.items():
                    for rule_id, rule_details in rules.items():
                        # If we have at least one query specified
                        if len(rule_details["queries"]) > 0:
                            rules_covered[standard_name][rule_id] = get_query_short_names(rule_details)


if is_csv:
    print(f"Coding Standard,Rule ID,Queries")
    for standard_name, rules_with_queries in rules_covered.items():
        if len(rules_with_queries) > 0:
            for rule_id, queries in sorted(
                    rules_with_queries.items(),
                    key=lambda rule_with_query: split_rule_id(rule_with_query[0])):
                query_list = ".ql;".join(queries) + ".ql"
                print(f"{standard_name},{rule_id},{query_list}")
else:
    # Print markdown file
    print("# CodeQL Coding Standards: supported rules")

    for standard_name, rules_with_queries in rules_covered.items():
        if len(rules_with_queries) > 0:
            print(f"## {standard_name}")
            print(
                f"The CodeQL Coding Standards release `{get_standard_version(standard_name)}` supports the following {standard_name} rules:")
            print("| Rule | Queries |")
            print("| ----- | -------- |")
            for rule_id, queries in sorted(
                    rules_with_queries.items(),
                    key=lambda rule_with_query: split_rule_id(rule_with_query[0])):
                query_list = ".ql`<br/> `".join(queries) + ".ql"
                print(f"| {rule_id} | `{query_list}` |")
