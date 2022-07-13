from collections import defaultdict
import csv
import json
import os
from pathlib import Path
import re
import sys

help_statement ="""
Usage: {script_name} <language> <package_name>

A tool for generating a rule package description, in JSON format.

The rules.csv file at the root of this repository is processed, and rules with a matching
language and package name are processed and used to generate a "rule package description"
file in the 'rule_packages' directory, using the name of the package.

The file will contain a JSON dictionary for each standard where the key is the rule ID and
the value is a dictionary describing the rule metadata. The dictionary will also contain a
list of query dictionaries, with a single auto-generated entry.

The generated file should be reviewed, and updated to:
  1. Add additional query entries as required
  2. Confirm that the following auto-generated properties are appropriate:")
      - 'precision'
      - 'short_name'
      - 'severity'
  3. Add additional 'tags' as required, particularly 'security' or 'correctness'.

If the file already exists, it will not be overwritten.

Arguments:
 <language> - the programming language of the package (currently 'cpp' or 'c')
 <package_name> - the name of the package to generate a package file for.
"""

if len(sys.argv) == 1 or (len(sys.argv) == 2 and sys.argv[1] == "--help"):
  print(help_statement.format(script_name=sys.argv[0]))
  sys.exit(0)

language_name = sys.argv[1]
package_name = sys.argv[2]
repo_root = Path(__file__).parent.parent.parent
rules_file_path = repo_root.joinpath('rules.csv')
rule_packages_file_path = repo_root.joinpath('rule_packages', language_name)
if not os.path.isdir(rule_packages_file_path):
  os.mkdir(rule_packages_file_path)
rule_package_file_path = rule_packages_file_path.joinpath(package_name + ".json")

def generate_short_name(title):
  """Generate a short, camel-case string from a rule title, suitable for a file name or id."""
  # Only consider the first sentence
  first_sentence = title.split(". ")[0]
  # Replace some common strings with text more suitable for a short name
  replacements = [
    ("C++ ", ""),
    ("std::", ""),
    ("_", " "),
    ("-", " "),
    ("&&", "and"),
    ("&&", "or"),
    (" shall not be ", " "),
    (" shall not ", " "),
    (" shall be ", " not "),
    (" as a ", " as "),
    (" as an ", " as "),
    (" in a ", " in "),
    (" in an ", " in "),
    (" as the ", " as ")
  ]
  for replacement in replacements:
    first_sentence = first_sentence.replace(replacement[0], replacement[1])
  # Remove any other characters not suitable for a short name
  only_safe_chars = re.sub(r"[^a-zA-Z ]*", "", first_sentence)
  # Remove anything after an "if", to keep it short
  only_first_part = only_safe_chars.split(" if ")[0]
  components = only_first_part.split(" ")
  if re.match(r"^(an|a|the)",components[0].lower(), re.IGNORECASE):
    # Remove "if", "an" and "a" if they occur at the start of the sentence
    del components[0]
  # Convert to CamelCase and join without spaces
  return "".join([x.title() for x in components])

try:
  rules_file = open(rules_file_path, "r")
except PermissionError:
  print("Error: No permission to read the rules file located at '" + str(rules_file_path) + "'")
  sys.exit(1)
else:
  package_description = defaultdict(dict)
  with rules_file:
    rules_reader = csv.reader(rules_file)
    # Skip header row
    next(rules_reader, None)
    for rule in rules_reader:
      language = rule[0]
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
      # Find all rules in the given language and package
      if language == language_name and package == package_name:
        if not queryable == "Yes":
          print("Error: " + standard + " " + rule_id + " is marked as part of package " + package_name + " but is not marked as queryable.")
          sys.exit(1)

        # Add the AUTOSAR obligation, enforcement and allocated target as query properties.
        properties = {}
        if obligation_level:
          properties["obligation"] = obligation_level.lower()
        if enforcement_level:
          properties["enforcement"] = enforcement_level.lower()
        if allocated_targets:
          properties["allocated-target"] = [target.strip(' ').lower() for target in allocated_targets.split("/")]
        if difficulty == "Audit":
          properties["audit"] = ""

        # Default to a severity of error, unless the obligation level is considered "advisory"
        severity = "error"
        if obligation_level == "advisory":
          severity = "warning"

        # Default to a precision of very-high, but reduce it if the difficulty is marked as Hard or Very Hard
        precision = "very-high"
        if difficulty == "Very Hard":
          precision = "medium"
        elif difficulty == "Hard":
          precision = "high"

        # Default assumption is that we use the rule title as the query name
        query_name = rule_title
        description = ""
        if ". " in query_name:
          # This is probably a multi-sentence title, so use only the first sentence as
          # the name, and include the full text in the description
          query_name = query_name.split(". ")[0]
          description = rule_title
        if len(query_name) > 100:
          # Long query names are not good, truncate to 100 on a space boundary
          # Take one more character, so we can check whether it's a space
          query_name_shorter = query_name[0:101]
          # Reports the last space, or -1
          last_space = query_name_shorter.rfind(" ")
          # If last space is -1, then we lose the extra character as required
          query_name = query_name_shorter[0:last_space]
          description = rule_title
        # Query names should never end in a dot
        query_name = query_name.rstrip(".")

        package_description[standard][rule_id] = {
          "title" : rule_title,
          "properties" : properties,
          "queries" : [
            {
              "short_name" : generate_short_name(rule_title),
              "name" : query_name,
              "precision" : precision,
              "severity" : severity,
              "description" : description,
              "kind" : "problem",
              "tags" : []
            }
          ]
        }
  
  if not package_description:
    print("Error: No rules found for package '" + package_name + "'")
    sys.exit(1)

  if rule_package_file_path.exists():
    print("Error: Rule package file already exists at '" + str(rule_package_file_path) + "'.")
    sys.exit(1)

  try:
    rule_package_file = open(rule_package_file_path, "w")
  except PermissionError:
    print("Error: No permission to write the package rules file located at '" + str(rule_package_file_path) + "'")
    sys.exit(1)
  else:
    with rule_package_file:
      json.dump(package_description, rule_package_file, indent=2, sort_keys=True)
      print("Rule package file generated at " + str(rule_package_file_path) + ".")
      print("")
      print("A default query has been generated for each for each rule. Please review each rule in the generated JSON file and:")
      print(" (1) Add additional queries as required")
      print(" (2) Confirm that the following auto-generated properties are appropriate:")
      print("    - 'camel_name'.")
      print("    - 'precision'.")
      print("    - 'query_name'.")
      print("    - 'severity'.")
      print(" (3) Add additional 'tags' as required, particularly 'security' or 'correctness'.")
