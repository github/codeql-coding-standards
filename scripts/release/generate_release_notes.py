import os
from pathlib import Path
import re
import sys
from git import Repo
import json
from utils import *

help_statement="""
Usage: {script_name} [previous-release-tag]

A tool for producing release notes that summarise the changes since the last or specified release.

When run without any arguments, the script first queries the repository to determine the tag
representing the latest release according to semantic versioning. If the `previous-release-tag` is
provided, then that is validated as a semantic version tag and used instead.

Given a tag, the script will use git to compare the currently checked out commit (not the current
working state) against the selected tag, to identify the following files:
 - New rule package description files
 - Modified rule package description files
 - New files in the `change-note` directory

These files are processed to produce:
 - A list of rules with newly added queries.
 - A list of changes specified in the change notes.

This then combined with the supported_codeql_configs.json file, at the root of the repository, to
produce a fully populate release note.

This script needs to be run with the codeql-coding-standards git repository as the current working
directory.
"""

if (len(sys.argv) == 2 and sys.argv[1] == "--help"):
  print(help_statement.format(script_name=sys.argv[0]))
  sys.exit(0)

if len(sys.argv) > 2:
  print("Error: incorrect number of arguments", file=sys.stderr)
  print("Usage: " + sys.argv[0] + " [previous-release-tag]", file=sys.stderr)
  sys.exit(1)


def transform_legacy_rule_path(p):
  """
  We need to account for these files which have been moved since CPP coding
  standards. Essentially if there is no language stem it is by default a cpp
  file, which should be found in the cpp directory.
  """
  if not (p.startswith("rule_packages/c") or p.startswith("rule_packages/cpp")):
    return p.replace("rule_packages/", "rule_packages/cpp/")
  else:
    return p 

# Initialise codeql-coding-standards repository object
repo_root = Path(__file__).parent.parent.parent
repo = Repo(repo_root)

semver_tags = [str(tag_ref)[1:] for tag_ref in repo.tags if is_semver_tag_ref(str(tag_ref))]
if len(semver_tags) == 0:
  print("Error: No tags matching v<semver> found.", file=sys.stderr)
  sys.exit(1)

if len(sys.argv) == 2:
  previous_release_tag = sys.argv[1][1:]
  if not previous_release_tag in semver_tags:
    print("Error: The tag " + previous_release_tag + " does not appear in the list of semver tags from the repository: v" + ", v".join(semver_tags), file=sys.stderr)
    sys.exit(1)
else:
  # Note: this sorting doesn't correctly respect pre-release text
  semver_tags.sort(reverse=True, key=lambda s: list(map(int, s.split('.'))))
  previous_release_tag = semver_tags[0]
  print("Automatically selecting " + previous_release_tag + " as the latest release.", file=sys.stderr)

# Compare the latest commit to the previous release tag
head_commit = repo.head.commit
latest_release_commit = repo.commit("v" + previous_release_tag)
diff_from_last_release = latest_release_commit.diff(head_commit)

# Store a mapping from standard -> rules with new queries -> new queries for those rules
new_rules = {"AUTOSAR" : {}, "CERT-C++" : {}, "MISRA-C-2012" : {}, "CERT-C" : {}}
# Store the text of the newly added change notes
change_notes = []
# Store the names of the rule packages with new queries
new_rule_packages = []

# Iterate through added files
for diff_added in diff_from_last_release.iter_change_type('A'):
  added_file = diff_added.a_path
  # Identify new rule packages in this release
  if added_file.startswith("rule_packages/"):
    try:
      rule_package_file = open(added_file, "r")
    except PermissionError:
      print("Error: No permission to read the rule package file located at '" + str(added_file) + "'")
      sys.exit(1)
    else:
      new_rule_packages.append(Path(added_file).stem)
      with rule_package_file:
        package_definition = json.load(rule_package_file)
        for standard_name, rules in package_definition.items():
          for rule_id, rule_details in rules.items():
            # If we have at least one query specified
            if len(rule_details["queries"]) > 0:
              new_rules[standard_name][rule_id] = get_query_short_names(rule_details)
  # Identify new change notes for this release
  if re.match("change_notes/.*.md$", added_file):
    try:
      change_note_file = open(added_file, "r")
    except PermissionError:
      print("Error: No permission to read the change notes file located at '" + str(added_file) + "'")
      sys.exit(1)
    else:
      with change_note_file:
        change_notes.append(change_note_file.read())

# Iterate through changed files
for diff_changed in diff_from_last_release.iter_change_type('M'):
  changed_file = diff_changed.a_path

  # Identify rule packages which have changed
  if changed_file.startswith("rule_packages/"):
    try:
      rule_package_file = open(transform_legacy_rule_path(changed_file), "r")
    except PermissionError:
      print("Error: No permission to read the rule package file located at '" + str(changed_file) + "'")
      sys.exit(1)
    else:
      # This rule package is modified, so read in the rule package description as it was in the previous tag
      previous_file_contents = repo.git.show("v" + previous_release_tag + ":" + changed_file)
      previous_package_definition = json.loads(previous_file_contents)
      # Now iterate over each rule in the new version of the rule package file
      with rule_package_file:
        package_definition = json.load(rule_package_file)
        # Track whether any new queries were added
        new_query_added = False
        for standard_name, rules in package_definition.items():
          for rule_id, rule_details in rules.items():
            try:
              # Identify the query `short_name`s previously associated with this rule_id
              existing_short_names = get_query_short_names(previous_package_definition[standard_name][rule_id])
            except KeyError:
              existing_short_names = [] # ignore the key error, as it means the rule id didn't previously exist
            # Identify the query `short_name`s now associated with this rule_id
            modified_short_names = get_query_short_names(rule_details)
            # Identify which queries have been added in this modification
            # Note, we don't identify _modified_ or _deleted_ queries here, because they require a change note
            added_query_names = set(modified_short_names).difference(set(existing_short_names))
            # If at least one query has been added, include this rule and query in `new_rules`
            if len(added_query_names) > 0:
              new_rules[standard_name][rule_id] = added_query_names
              new_query_added = True
        if new_query_added:
          # Add this rule package to the list if a new query was added for it
          new_rule_packages.append(Path(changed_file).stem)

# Determine our supported environments
supported_environments = []
try:
  supported_codeql_configs_file = open('supported_codeql_configs.json', "r")
except PermissionError:
  print("Error: No permission to read the supported_codeql_configs.json file located at 'supported_codeql_configs.json'")
  sys.exit(1)
else:
  with supported_codeql_configs_file:
    supported_codeql_configs = json.load(supported_codeql_configs_file)
    supported_environments = supported_codeql_configs['supported_environment']

# Find the supported standard libraries that match LGTM tags
lgtm_supported_versions = filter(lambda v: re.match("(lgtm\/)?v1\\.[0-9][0-9]?\\.[0-9][0-9]?", v), map(lambda e: e["codeql_standard_library"], supported_environments))

# Print the release notes to stdout

# Print a summary
print("# Release summary")
if len(new_rule_packages) > 0:
  print(" - New queries added for the following rule packages: " + ", ".join(new_rule_packages))
else:
  print(" - No new queries were added for this release")
if len(change_notes) > 0:
  print(" - The following changes have been made for this release:")
  for change_note in change_notes:
    for change_note_line in change_note.splitlines():
      print("  " + change_note_line)

# Print out "supported versions" statements
print("## Supported versions")
if len(list(lgtm_supported_versions)):
  print(" - The LGTM pack is supported on LGTM versions: `" + "`, ".join(lgtm_supported_versions) + "`.")
else:
  print(" - The LGTM pack is not supported on any released version of LGTM without support from GitHub Professional Services.")
print(" - The Code Scanning pack is supported when:")
for supported_environment in supported_environments:
  if "ghes" in supported_environment:
    print("   - Using the default version of the GitHub CodeQL Action shipped with GitHub Enterprise Server " + supported_environment["ghes"] + ".")
  print("   - Using the CodeQL CLI version `" + supported_environment["codeql_cli"] + "` in conjunction with a copy of the CodeQL standard library for C++ (`github/codeql`) set to the tag `" + supported_environment["codeql_standard_library"] + "`.")
  if "codeql_cli_bundle" in supported_environment:
    print("   - Using the CodeQL Action or CodeQL runner with the [" + supported_environment["codeql_cli_bundle"] + "](https://github.com/github/codeql-action/releases/tag/" + supported_environment["codeql_cli_bundle"] + ").")

# Print the "Appendix" which includes a complete list of all newly added queries
for standard_name, rules_with_new_queries in new_rules.items():
  if len(rules_with_new_queries) > 0:
    print("## Appendix: " + standard_name + " new queries")
    print("New queries added to cover the following rules:")
    for rule_id, queries in sorted(rules_with_new_queries.items(), key=lambda rule_with_new_query: split_rule_id(rule_with_new_query[0])):
      print("- " + rule_id + " - `" + ".ql`, `".join(queries) + ".ql`")
