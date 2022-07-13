from argparse import ArgumentParser
import csv
from jinja2 import Environment, FileSystemLoader
import json
import os
from pathlib import Path
import re
import sys


help_statement = """
A tool for generating query related files, given a package description in JSON format.

The JSON file at <repo_root>/rule_packages/<package_name>.json is loaded, and for each
entry in the `queries` array for each rule, we generate the following:
 - Query file in <language>/<standard>/src/rules/<rule_id>/<short_name>.ql
 - Query help file in <language>/<standard>/src/rules/<ruleid>/<short_name>.qhelp
 - Implementation section in <language>/<standard>/src/rules/<rule_id>/<short_name>-implementation.xml
 - Test reference in <language>/<standard>/test/<rule_id>/<short_name>.qlref
 - Test file in <language>/<standard>/test/<rule_id>/test.cpp

If the files already exist:
 - The metadata of the query file will be overwritten with the new metadata
 - The query help file will be overwritten entirely
 - The implementation section will not be overwritten or modified.
 - The test reference will be overwritten.
 - The file file will not be overwritten or modified.

This generator does not directly support the modification of the query short_name. To
modify a query short name, first rename the relevant files manually, then re-run this
script, ensuring that the package description has also been updated.
"""

parser = ArgumentParser(description=help_statement)
parser.add_argument(
    "-a",
    "--anonymise",
    action="store_true",
    dest="anonymise",
    default=False,
    help="create anonymized versions of the queries, without identifying rule information",
)
parser.add_argument(
    "package_name", help="the name of the package to generate query files for")

args = parser.parse_args()

package_name = args.package_name
repo_root = Path(__file__).parent.parent.parent
rule_packages_file_path = repo_root.joinpath("rule_packages")
rule_package_file_path = rule_packages_file_path.joinpath(
    package_name + ".json")
env = Environment(loader=FileSystemLoader(Path(__file__).parent.joinpath(
    "templates")), trim_blocks=True, lstrip_blocks=True)


def split_camel_case(short_name):
    """Split a camel case string to a list."""
    matches = re.finditer(
        ".+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)", short_name)
    return [m.group(0) for m in matches]


def standard_tag(standard_short_name, key, value):
    """Create a CodeQL tag for the given standard and property name"""
    return (
        "external/"
        + standard_short_name
        + "/"
        + key.replace("_", "-").replace(" ", "-").lower()
        + (("/" + value.replace("_", "-").replace(" ", "-").lower()) if value else "")
    )


def description_line_break(description):
    """Split the description into a list of lines of no more than 84 characters"""
    if len(description) < 85:
        return [description]
    else:
        description_line = description[0:85]
        # Reports the last space, or -1
        last_space = description_line.rfind(" ")
        # If last space is -1, then we lose the extra character as required
        description_line = description_line[0:last_space]
        # Use recursion to calculate the lines in the tail of the string
        return [description_line] + description_line_break(description[(len(description_line) + 1):])


def write_template(template, args, package_name, file):
    """Render the template with the given args, and write it to the file using \n newlines."""
    output = template.render(args, package_name=package_name)
    with open(file, "w", newline="\n") as f:
        f.write(output)


def write_exclusion_template(template, args, packagename, file):
    """Render the template with the given args, and write it to the file using \n newlines."""
    output = template.render(data=args, package_name=packagename)

    with open(file, "w", newline="\n") as f:
        f.write(output)


try:
    rule_package_file = open(rule_package_file_path, "r")
except PermissionError:
    print("Error: No permission to read the rule package file located at '" +
          str(rule_package_file_path) + "'")
    sys.exit(1)
else:
    with rule_package_file:
        package_definition = json.load(rule_package_file)

        # Initialize exclusion
        exclusion_query = []

        # Check query standard name is unique before proceeding
        query_names = []
        for standard_name, rules in package_definition.items():
            for rule_id, rule_details in rules.items():
                for query in rule_details["queries"]:
                    query_names.append(query["short_name"])
        if len(query_names) > len(set(query_names)):
            print(
                "Error: " + "Duplicate query name detected, each query must have a unique query name.")
            sys.exit(1)

        for standard_name, rules in package_definition.items():

            # Identify the short name for the standard, used for directory and tag names
            standard_short_name = standard_name.split("-")[0].lower()
            # Only support CPP for now
            standard_dir = repo_root.joinpath(
                "cpp").joinpath(standard_short_name)
            # Identify common src and test packs
            common_dir = repo_root.joinpath("cpp").joinpath("common")
            common_src_pack_dir = common_dir.joinpath("src")
            common_test_pack_dir = common_dir.joinpath("test")
            # Identify the source pack for this standard
            src_pack_dir = standard_dir.joinpath("src")
            for rule_id, rule_details in rules.items():
                # Identify and create the directories required for this rule
                rule_src_dir = src_pack_dir.joinpath("rules").joinpath(rule_id)
                rule_src_dir.mkdir(exist_ok=True, parents=True)
                test_src_dir = standard_dir.joinpath(
                    "test/rules").joinpath(rule_id)
                test_src_dir.mkdir(exist_ok=True, parents=True)
                # Build list of tags for this rule to apply to each query
                rule_query_tags = []
                for key, value in rule_details["properties"].items():
                    if isinstance(value, list):
                        for v in value:
                            rule_query_tags.append(
                                standard_tag(standard_short_name, key, v))
                    else:
                        rule_query_tags.append(standard_tag(
                            standard_short_name, key, value))

                for query in rule_details["queries"]:

                    # Add rule properties to the query dict, ready for template generation
                    query["standard_name"] = standard_name
                    query["standard_short_name"] = standard_short_name
                    query["rule_id"] = rule_id
                    query["rule_title"] = rule_details["title"]
                    query["tags"].extend(rule_query_tags)
                    query["anonymise"] = args.anonymise
                    query["shortname_camelcase"] = query["short_name"][0].lower(
                    ) + query["short_name"][1:]
                    # short id generated from short name
                    query["short_id"] = "-".join([c.lower()
                                                 for c in split_camel_case(query["short_name"])])
                    # set up model for exclusions
                    exclusion_model = {}
                    exclusion_model["queryid"] = "cpp/" + \
                        standard_short_name + "/" + query["short_id"]
                    exclusion_model["ruleid"] = rule_id
                    exclusion_model["queryname"] = query["short_name"]
                    exclusion_model["queryname_camelcase"] = query["short_name"][0].lower(
                    ) + query["short_name"][1:]
                    # add query to each dict
                    exclusion_query.append(exclusion_model)

                    if not "kind" in query:
                        # default to problem if not specified
                        query["kind"] = "problem"
                    # separate description into multiple lines
                    query["description"] = description_line_break(
                        query["description"] if "description" in query else query["rule_title"])

                    # Anonymise properties, if required
                    if args.anonymise:
                        query["rule_title"] = query["short_name"]
                        query["description"] = [query["short_name"]
                                                ] if args.anonymise else query["description"]
                        query["name"] = query["short_name"]

                    # Path to query file we want to generate or modify
                    query_path = rule_src_dir.joinpath(
                        query["short_name"] + ".ql")
                    if not query_path.exists():
                        # Doesn't already exist, generate full template, including imports and select
                        if len(query["short_name"]) > 50:
                            print(
                                "Error: " + query["short_name"] + " has more than 50 characters. Query name should be less than 50 characters. ")
                            sys.exit(1)
                        print(rule_id + ": Writing out query file to " +
                              str(query_path))
                        query_template = env.get_template("query.ql.template")
                        write_template(query_template, query,
                                       package_name, query_path)
                    else:
                        # Query file does already exist, so we only re-write the metadata
                        print(
                            rule_id + ": Re-writing metadata for query file at " + str(query_path))
                        query_metadata_template = env.get_template(
                            "query.metadata.template")
                        # Generate the new metadata
                        new_metadata = query_metadata_template.render(**query)
                        with open(query_path, "r+", newline="\n") as query_file:
                            # Read the existing query file contents
                            existing_contents = query_file.read()
                            # Move cursor back to the start of the file, so we can write later
                            query_file.seek(0)
                            # Confirm that the query file is valid
                            if not existing_contents.startswith("/**"):
                                print("Error: " + " cannot modify the metadata for query file at " + str(
                                    query_path) + " - does not start with /**.")
                                sys.exit(1)
                            pos_of_comment_end = existing_contents.find("*/")
                            if pos_of_comment_end == -1:
                                print("Error: " + " cannot modify the metadata for query file at " + str(
                                    query_path) + " - does not include a */.")
                                sys.exit(1)

                            # Write the new contents to the query file
                            new_contents = new_metadata + \
                                existing_contents[pos_of_comment_end + 2:]
                            # Write the new contents to the file
                            query_file.writelines(new_contents)
                            # Ensure any trailing old data is deleted
                            query_file.truncate()

                    # Add some metadata for each supported standard
                    if standard_name == "CERT-C++":
                        query["standard_title"] = "CERT-C++"
                        query["standard_url"] = "https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682"
                    elif standard_name == "AUTOSAR":
                        query["standard_title"] = "AUTOSAR: Guidelines for the use of the C++14 language in critical and safety-related systems"
                        query[
                            "standard_url"
                        ] = "https://www.autosar.org/fileadmin/user_upload/standards/adaptive/19-11/AUTOSAR_RS_CPP14Guidelines.pdf"

                    # Add qhelp file, overwriting if already present, since it's completely generated
                    qhelp_template = env.get_template("template.qhelp")
                    qhelp_path = rule_src_dir.joinpath(
                        query["short_name"] + ".qhelp")
                    print(
                        rule_id + ": Writing out query help file to " + str(qhelp_path))
                    write_template(qhelp_template, query,
                                   package_name, qhelp_path)

                    # Add qhelp implementation file placeholder, if it doesn't exist
                    qhelp_impl_template = env.get_template(
                        "template-implementation.qhelp")
                    qhelp_impl_path = rule_src_dir.joinpath(
                        query["short_name"] + "-implementation.qhelp")
                    if not qhelp_impl_path.exists():
                        write_template(qhelp_impl_template, query,
                                       package_name, qhelp_impl_path)

                    # Add qhelp standard file placeholder, if it doesn't exist
                    qhelp_std_template = env.get_template(
                        "template-standard.qhelp")
                    qhelp_std_path = rule_src_dir.joinpath(
                        query["short_name"] + "-standard.qhelp")
                    if not qhelp_std_path.exists():
                        write_template(qhelp_std_template, query,
                                       package_name, qhelp_std_path)

                    if "shared_implementation_short_name" in query:
                        # This query uses a shared implementation, so generate the appropriate files
                        # Note: this will be called for each
                        shared_impl_dir_name = query["shared_implementation_short_name"].lower(
                        )

                        # Generate shared implementation library
                        shared_impl_dir = common_src_pack_dir.joinpath(
                            "codingstandards", "cpp", "rules", shared_impl_dir_name)
                        shared_impl_dir.mkdir(exist_ok=True, parents=True)
                        shared_impl_query_library_path = shared_impl_dir.joinpath(
                            query["shared_implementation_short_name"] + ".qll")
                        if not shared_impl_query_library_path.exists():
                            if len(query["short_name"]) > 50:
                                print(
                                    "Error: " + query["short_name"] + " has more than 50 characters. Query name should be less than 50 characters. ")
                                sys.exit(1)
                            shared_library_template = env.get_template(
                                "shared_library.ql.template")
                            print(rule_id + ": Writing out shared implementation file to " +
                                  str(shared_impl_query_library_path))
                            write_template(
                                shared_library_template, query, package_name, shared_impl_query_library_path)
                        else:
                            print(rule_id + ": Skipping writing shared implementation file to " +
                                  str(shared_impl_query_library_path))

                        # Generate shared implementation test directory
                        shared_impl_test_dir = common_test_pack_dir.joinpath(
                            "rules", shared_impl_dir_name)
                        shared_impl_test_dir.mkdir(exist_ok=True, parents=True)

                        # Generate test query file
                        shared_impl_test_query_path = shared_impl_test_dir.joinpath(
                            query["shared_implementation_short_name"] + ".ql")
                        with open(shared_impl_test_query_path, "w", newline="\n") as f:
                            f.write("// GENERATED FILE - DO NOT MODIFY\n")
                            f.write(
                                "import "
                                + str(shared_impl_query_library_path.relative_to(common_src_pack_dir).with_suffix(''))
                                .replace("\\", "/")
                                .replace("/", ".")
                                + "\n"
                            )

                        # Create an empty test file, if one doesn't already exist
                        shared_impl_test_dir.joinpath("test.cpp").touch()

                        # Add an empty expected results file - this makes it possible to see the results the
                        # first time you run the test in VS Code
                        expected_results_file = shared_impl_test_dir.joinpath(
                            query["shared_implementation_short_name"] + ".expected")
                        if not expected_results_file.exists():
                            with open(expected_results_file, "w", newline="\n") as f:
                                f.write(
                                    "No expected results have yet been specified")

                        # Add a testref file for this query, that refers to the shared library
                        test_ref_file = test_src_dir.joinpath(
                            query["short_name"] + ".testref")
                        with open(test_ref_file, "w", newline="\n") as f:
                            f.write(str(shared_impl_test_query_path.relative_to(
                                repo_root)).replace("\\", "/"))
                    else:
                        # Add qlref test file
                        print(
                            rule_id + ": Writing out query test files to " + str(test_src_dir))
                        with open(test_src_dir.joinpath(query["short_name"] + ".qlref"), "w", newline="\n") as f:
                            f.write(str(query_path.relative_to(
                                src_pack_dir)).replace("\\", "/"))

                        # Create an empty test file, if one doesn't already exist
                        test_src_dir.joinpath("test.cpp").touch()

                        # Add an empty expected results file - this makes it possible to see the results the
                        # first time you run the test in VS Code
                        expected_results_file = test_src_dir.joinpath(
                            query["short_name"] + ".expected")
                        if not expected_results_file.exists():
                            with open(expected_results_file, "w", newline="\n") as f:
                                f.write(
                                    "No expected results have yet been specified")

        # Exclusions
        exclusions_template = env.get_template("exclusions.qll.template")
        common_exclusions_dir = common_src_pack_dir.joinpath(
            "codingstandards", "cpp", "exclusions")
        # assign package and sanitize
        package_name = package_name.replace("-", "")
        package_name = package_name[:1].upper() + package_name[1:]
        exclusion_library_file = common_exclusions_dir.joinpath(
            package_name + ".qll")
        # write exclusions file
        print(package_name + ": Writing out exclusions file to " +
              str(exclusion_library_file))
        write_exclusion_template(
            exclusions_template, exclusion_query, package_name, exclusion_library_file)
