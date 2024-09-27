from collections import defaultdict
import csv
import os
from pathlib import Path
import sys
import json

help_statement = """
Usage: {script_name}

A script which detects invalid entries in amendments.csv.
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
amendments_file_path = repo_root.joinpath('amendments.csv')
language_name = sys.argv[1]

failed = False

rules_from_csv = {}
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
            rule_id = rule[2]

            # only validate rules for the specified language 
            if not language == language_name:
                continue 

            rule_dict = {
                "standard": rule[1],
                "rule_id": rule_id,
                "supportable": rule[3]
            }
            rules_from_csv[rule_id] = rule_dict

print(f"Found {len(rules_from_csv)} rules.")
print(f"Verifying amendments")

seen_amendments = set()
try:
    amendments_file = open(amendments_file_path, "r")
except PermissionError:
    print("Error: No permission to read the amendments file located at '" + str(amendments_file_path) + "'")
    sys.exit(1)
else:
    with amendments_file:
        amendments_reader = csv.reader(amendments_file)
        # Skip header row
        next(amendments_reader, None)
        for amendment in amendments_reader:
            language = amendment[0]

            # only validate rules for the specified language 
            if not language == language_name:
                continue 

            if len(amendment) != 8:
                print(f"🔴 Error: amendment {amendment} has wrong number of fields")
                failed = True
                continue

            standard = amendment[1]
            amendment_name = amendment[2]
            rule_id = amendment[3]
            supportable = amendment[4]
            implemented = amendment[6]
            amendment_id = f"{rule_id}-{amendment_name}"

            if not rule_id in rules_from_csv:
                print(f"🔴 Error: Amendment {amendment_id} references rule {rule_id}, not found in rules.csv")
                failed = True
                continue

            rule = rules_from_csv[rule_id]

            if rule["standard"] != standard:
                print(f"🟡 Invalid: {amendment_id} has a different standard than the {rule_id} in rules.csv")
                print(f"   '{standard}' vs '{rule['standard']}'")
                failed = True

            if supportable not in {"Yes", "No"}:
                print(f"🟡 Invalid: {amendment_id} 'supportable' field should be 'Yes' or 'No'.")
                print(f"   got '{supportable}'")
                failed = True

            if rule["supportable"] != supportable:
                print(f"🟡 Invalid: {amendment_id} supportable does not match rules.csv supportable.")
                print(f"   '{supportable}' vs '{rule['supportable']}'")
                failed = True

            if implemented not in {"Yes", "No"}:
                print(f"🟡 Invalid: {amendment_id} 'implemented' field should be 'Yes' or 'No'.")
                print(f"   got '{implemented}'")
                failed = True

            if amendment_id in seen_amendments:
                print(f"🔴 Error: {amendment_id} has duplicate entries")
                failed = True

            seen_amendments.add(amendment_id)

print(f"Checked {len(seen_amendments)} amendments.")

if failed:
    print("❌ FAILED: Validity issues found in amendments.csv!")
    sys.exit(1)
else:
    print("✅ PASSED: No validity issues found in amendments.csv! 🎉")
