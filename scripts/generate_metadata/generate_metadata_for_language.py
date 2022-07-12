from argparse import ArgumentParser
from jinja2 import Environment, FileSystemLoader
import os
from pathlib import Path

help_statement = """
A tool for generating the language specific RuleMetadata.qll files. This tool 
will generate a RuleMetadata.qll file in the
`<ql-language>/common/src/codingstandards/<ql-language>/exclusions/<language>` directory. 

If the files already exist:
 - The metadata of the query file will be overwritten with the new metadata
"""
# Mapping of concrete language to QL Language
ql_language_mappings = {
    "cpp": "cpp",
    "c": "cpp"
}

parser = ArgumentParser(description=help_statement)
parser.add_argument("language_name", help="the language of the package")
args = parser.parse_args()

language_name = args.language_name

if not language_name in ql_language_mappings:
    exit(f"Unsupported language '{language_name}'")
else:
    ql_language_name = ql_language_mappings[language_name]

repo_root = Path(__file__).parent.parent.parent
rule_packages_file_path = repo_root.joinpath("rule_packages")
rule_package_file_path = rule_packages_file_path.joinpath(language_name)

exclusions_path = repo_root.joinpath(ql_language_name, "common", "src", "codingstandards", ql_language_name, "exclusions", language_name)
# create the directories if they don't already exist.
os.makedirs(exclusions_path, exist_ok=True)

metdata_data_file_path = repo_root.joinpath(exclusions_path, "RuleMetadata.qll")

env = Environment(loader=FileSystemLoader(Path(__file__).parent.joinpath(
    "templates")), trim_blocks=True, lstrip_blocks=True)

packages = []


valid_package_names = [] 
# Get all of the packages, filtering out any that don't have queries
for package_file in rule_package_file_path.glob('*.json'):
    package_name = package_file.name.split('.')[0]
    valid_package_names.append(package_name)

# Get all of the packages, filtering out any that don't have queries
for package_file in exclusions_path.glob('*.qll'):
    package_name = package_file.name.split('.')[0]

    if package_name == "RuleMetadata":
        continue 

    if not package_name in valid_package_names:
        print(f"Skipping unknown possible package library {str(package_file)}")
        continue

    print(f"Reading package data for package {package_name}")
    packages.append(package_name)

packages = sorted(packages) 
metadata_template = env.get_template("rulemetadata.qll.template")

print(f"Writing out query help file to {str(metdata_data_file_path)}")

output = metadata_template.render(
    ql_language=ql_language_name, language_name=language_name, packages=packages)

with open(metdata_data_file_path, "w", newline="\n") as f:
    f.write(output)
