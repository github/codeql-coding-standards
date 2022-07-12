from collections import defaultdict
import csv
import os
from pathlib import Path
import sys
import json

help_statement = """
Usage: {script_name}

A script which reports consistency issues between the rules.csv and rule package json files.
"""

if (len(sys.argv) == 2 and sys.argv[1] == "--help"):
    print(help_statement.format(script_name=sys.argv[0]))
    sys.exit(0)

if not len(sys.argv) == 2:
    print("Error: incorrect number of arguments", file=sys.stderr)
    print("Usage: " + sys.argv[0] + " [--help]", file=sys.stderr)
    sys.exit(1)

repo_root = Path(__file__).parent.parent
rules_file_path = repo_root.joinpath('rules.csv')
language_name = sys.argv[1]

failed = False

package_rules_from_csv = defaultdict(set)
count = 0
try:
    rules_file = open(rules_file_path, "r")
except PermissionError:
    print("Error: No permission to read the rules file located at '" + str(rules_file_path) + "'")
    sys.exit(1)
else:
    with rules_file:
        rules_reader = csv.reader(rules_file)
        # Skip header row
        next(rules_reader, None)
        for rule in rules_reader:
            language = rule[0]

            # only validate rules for the specified language 
            if not language == language_name:
                continue 

            standard = rule[1]
            rule_id = rule[2]
            queryable = rule[3]
            obligation_level = rule[4]
            enforcement_level = rule[5]
            allocated_targets = rule[6]
            rule_title = rule[7]
            similar_query = rule[8]
            package = rule[9]
            difficulty = rule[10]
            # If the rule is associated with a package
            if package:
                if not queryable == "Yes":
                    print(
                        f"ERROR: {standard} {rule_id} is included as part of package {package} but is not marked as queryable.")
                    failed = True
                else:
                    package_rules_from_csv[package].add(rule_id)
                    count += 1

print(f"Found {count} implementable rules, verifying.")

rule_packages_file_path = repo_root.joinpath('rule_packages', language_name)

# Iterate over rule packages, verifying the contents
for rule_package_file_name in os.listdir(rule_packages_file_path):
    try:
            rule_package_file = open(rule_packages_file_path.joinpath(rule_package_file_name), "r")
    except PermissionError:
        print("Error: No permission to read the rule package file located at '" + str(rule_package_file_name) + "'")
        sys.exit(1)
    else:
        with rule_package_file:
            package_definition = json.load(rule_package_file)
            package_name = Path(rule_package_file_name).stem
            package_json_rule_ids = set()
            for standard_name, rules in package_definition.items():
                for rule_id, rule_details in rules.items():
                    package_json_rule_ids.add(rule_id)

                    standard_short_name = standard_name.split("-")[0].lower()
                    standard_dir = repo_root.joinpath(language_name).joinpath(standard_short_name)
                    
                    # Identify the source pack for this standard
                    src_pack_dir = standard_dir.joinpath("src")
                    # Identify the rule src dir
                    rule_src_dir = src_pack_dir.joinpath("rules").joinpath(rule_id)

                    if len(rule_details["queries"]) == 0 and rule_id in package_rules_from_csv[package_name] and rule_src_dir.exists():
                        print(f" - ERROR: Rule {rule_id} missing metadata from {package_name}.json.")
                        failed = True
                    if not rule_id in package_rules_from_csv[package_name]:
                        print(
                            f" - ERROR: Rule {rule_id} included in {package_name}.json but not marked as queryable in rules.csv.")
                        failed = True
            rules_csv_rule_ids = package_rules_from_csv[package_name]

            json_missing_rules = rules_csv_rule_ids.difference(package_json_rule_ids)
            if json_missing_rules:
                print(
                    f" - ERROR: Package file {package_name}.json is missing rule records for the following rules: { json_missing_rules }.")
                failed = True
if failed:
    print("ERROR: Consistency issues found")
    sys.exit(1)
else:
    print("No consistency issues found")
