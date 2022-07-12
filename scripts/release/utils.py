import re
import yaml

def get_query_short_names(rule_dict):
  """Gets a list of the query "short_name" properties for the given rule"""
  return map(lambda x: x["short_name"], rule_dict["queries"])

semver_regex = r'^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

def is_semver_tag_ref(tag_ref):
  """Determines if tag_ref is a semver tag."""
  tag_name = str(tag_ref)
  return tag_name.startswith("v") and re.search(semver_regex, tag_name[1:])

def split_rule_id(rule_id):
  """Splits the rule_id into the rule_type and rule_number"""
  return tuple(int(x) if x.isdigit() else x for x in filter(len,filter(None,re.split("(\d+)|-", rule_id))))

def get_standard_version(standard):
  """Gets the qlpack version for the given standard."""
  qlpack_path = "cpp/" + standard.split("-")[0].lower() + "/src/qlpack.yml"
  with open(qlpack_path, 'r') as qlpack_file:
    try:
        qlpack = yaml.safe_load(qlpack_file)
        return qlpack["version"]
    except yaml.YAMLError as exc:
        print("Error: Problem reading qlpack file located at '" + str(qlpack_path) + "'")
        sys.exit(1)