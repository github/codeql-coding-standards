import argparse
import os
from pathlib import Path
import subprocess
import sys
import xml.etree.ElementTree as ET
from xml.dom import minidom
import yaml


def convert_yaml_dict_to_xml(data, output_file):
    # Create an arbitrary root element - required for XML, but not in YAML
    root = ET.Element("codingstandards")
    # Add a generated comment
    comment = ET.Comment(
        "GENERATED: DO NOT MODIFY. Changes should be made to coding-standards.yml instead.")
    root.append(comment)
    # Process the yaml data
    process_item(root, data)
    # Write out the file to pretty printed XML
    xmlstr = minidom.parseString(ET.tostring(root)).toprettyxml(indent="   ")
    with open(output_file, "w") as f:
        f.write(xmlstr)


def process_item(parent, item):
    if item == None:
        return
    assert(isinstance(item, dict))
    for (key, value) in item.items():
        if isinstance(value, dict):
            child = ET.SubElement(parent, key)
            process_item(child, value)
        elif isinstance(value, list):
            listContainer = ET.SubElement(parent, key)
            for li_value in value:
                child = ET.SubElement(listContainer, key + "-entry")
                if is_literal(li_value):
                    child.text = encode_literal(li_value)
                else:
                    process_item(child, li_value)
        else:
            child = ET.SubElement(parent, key)
            child.text = encode_literal(value)


def is_literal(value):
    if isinstance(value, dict):
        return False
    if isinstance(value, list):
        return False
    return True


def encode_literal(value):
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return value


def convert_yaml_file_to_xml(yaml_file):
    with yaml_file.open() as f:
        data = yaml.safe_load(f)
    convert_yaml_dict_to_xml(data, yaml_file.with_suffix(".xml"))


def main():
    parser = argparse.ArgumentParser(
        prog='process_coding_standards_config'
    )
    parser.add_argument(
        '--working-dir',
        help='The directory in which the CodeQL index command should be executed, which is typically the source root.',
        required=False,
        type=Path,
        # Default to the current working directory if one is not specified,
        # because we expect the codeql database create to be executed in the source root.
        default=Path()
    )
    parser.add_argument(
        '--save-temps',
        action='store_true',
        help='Save the intermediate XML files in the same location as their Yaml source.'
    )
    parser.add_argument(
        '--skip-indexing',
        action='store_true',
        help='Skip indexing the configurations and only convert them to XML. Should be used with --save-temps.'
    )
    args = parser.parse_args()

    if not args.skip_indexing:
        # Verify that we're running within a CodeQL database creation step
        codeql_dist = os.getenv("CODEQL_DIST")
        codeql_extractor_cpp_wip_database = os.getenv(
            "CODEQL_EXTRACTOR_CPP_WIP_DATABASE")
        if not codeql_dist or not codeql_extractor_cpp_wip_database:
            print(
                f"No active CodeQL database build started. Please run this command either before or after your regular build command.",
                file=sys.stderr)
            sys.exit(1)

        if not args.working_dir.exists():
            print(
                f"The specified working directory '{args.working_dir}'' does not exist.", file=sys.stderr)
            sys.exit(1)

    # Find all coding standards deviations files, and convert them in place to coding-standards.xml
    for config_file_name in ['coding-standards.yml', 'coding-standards.yaml']:
      for path in args.working_dir.rglob(config_file_name):
        convert_yaml_file_to_xml(path)

    if not args.skip_indexing:
        # Index the newly generated XML files
        subprocess.run([f"{codeql_dist}/codeql", "database", "index-files", "--include", "**/coding-standards.xml",
                        "--size-limit", "10m", "--working-dir", args.working_dir, "--language", "xml",
                        f"{codeql_extractor_cpp_wip_database}"])

    if not args.save_temps:
        for path in args.working_dir.rglob('coding-standards.xml'):
            path.unlink()


if __name__ == '__main__':
    main()
