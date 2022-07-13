from argparse import ArgumentParser
import csv
from jinja2 import Environment, FileSystemLoader
import json
import os
from pathlib import Path
import re
import sys
import subprocess
from coding_standards_utils import *

#
# PS Oneliner for regenerating a language:
# Get-ChildItem .\rule_packages\cpp\*.json | ForEach-Object { python .\scripts\generate_rules\generate_package_files.py cpp $_.BaseName }
#

help_statement = """
A tool for generating query related files, given a package description in JSON format.

The JSON file at <repo_root>/rule_packages/<language_name>/<package_name>.json is loaded, and for each
entry in the `queries` array for each rule, we generate the following:
 - Query file in <language>/<standard>/src/rules/<rule_id>/<short_name>.ql
 - Query help file in <language>/<standard>/src/rules/<ruleid>/<short_name>.qhelp
 - Implementation section in <language>/<standard>/src/rules/<rule_id>/<short_name>-implementation.xml
 - Test reference in <language>/<standard>/test/<rule_id>/<short_name>.qlref
 - Test file in <language>/<standard>/test/<rule_id>/test.<language_extension>

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
########################################################
# Configuration Data
########################################################
ql_language_mappings = {
    "cpp": "cpp",
    "c": "cpp"
}

standard_metadata = {
    "CERT-C++" : {
        "standard_title" : "CERT-C++",
        "standard_url"   : "https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682"
    },
    "AUTOSAR" : {
        "standard_title" : "AUTOSAR: Guidelines for the use of the C++14 language in critical and safety-related systems",
        "standard_url"   : "https://www.autosar.org/fileadmin/user_upload/standards/adaptive/19-11/AUTOSAR_RS_CPP14Guidelines.pdf"
    },
    "CERT-C" : {
        "standard_title" : "CERT-C",
        "standard_url"   : "https://wiki.sei.cmu.edu/confluence/display/c"
    },
    "MISRA-C-2012" : {
        "standard_title" : "MISRA-C:2012 Guidelines for the use of the C language in critical systems",
        "standard_url"   : "https://www.misra.org.uk/"
    }
}

parser = ArgumentParser(description=help_statement)
parser.add_argument(
    "-a",
    "--anonymise",
    action="store_true",
    dest="anonymise",
    default=False,
    help="create anonymized versions of the queries, without identifying rule information",
)
parser.add_argument("language_name", help="the language of the package")
parser.add_argument(
    "package_name", help="the name of the package to generate query files for")
########################################################


args = parser.parse_args()
language_name = args.language_name.lower()
package_name = args.package_name

# validate langauge 
if not language_name in ql_language_mappings:
    exit(f"Unsupported language '{language_name}'")
else:
    ql_language_name = ql_language_mappings[language_name]

# set up some basic paths 
repo_root = Path(__file__).parent.parent.parent
rule_packages_file_path = repo_root.joinpath("rule_packages")
rule_package_file_path = rule_packages_file_path.joinpath(
    language_name, package_name + ".json")
env = Environment(loader=FileSystemLoader(Path(__file__).parent.joinpath(
    "templates")), trim_blocks=True, lstrip_blocks=True)




def write_shared_implementation(package_name, rule_id, query, language_name, ql_language_name, common_src_pack_dir, common_test_pack_dir):

    shared_impl_dir_name = query["shared_implementation_short_name"].lower()

    shared_impl_dir = common_src_pack_dir.joinpath(
        "codingstandards", 
        ql_language_name, 
        "rules", 
        shared_impl_dir_name
    )

    shared_impl_dir.mkdir(exist_ok=True, parents=True)
    shared_impl_query_library_path = shared_impl_dir.joinpath(
        query["shared_implementation_short_name"] + ".qll")

    #
    # Write out the implementation. Implementations are
    # always stored in the `ql_langauge_name` directory. 
    #
    if not shared_impl_query_library_path.exists():
        
        if len(query["short_name"]) > 50:
            exit(f"Error: {query['short_name']} has more than 50 characters.")
        
        shared_library_template = env.get_template(
            "shared_library.ql.template"
            )

        print(f"{rule_id}: Writing out shared implementation file to {str(shared_impl_query_library_path)}")
        
        write_template(
            shared_library_template, 
            query, 
            package_name, 
            shared_impl_query_library_path
            )
    else:
        print(f"{rule_id}: Skipping writing shared implementation file to {str(shared_impl_query_library_path)}")

    # Write out the test. Test are always stored under the `language_name`
    # directory. 
    shared_impl_test_dir = common_test_pack_dir.joinpath(
        "rules", 
        shared_impl_dir_name
    )

    shared_impl_test_dir.mkdir(exist_ok=True, parents=True)

    # Generate test query file
    shared_impl_test_query_path = shared_impl_test_dir.joinpath(
        f"{query['shared_implementation_short_name']}.ql"
    )
    
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
    shared_impl_test_dir.joinpath(
        "test." + language_name).touch()

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


def write_non_shared_testfiles(query, language_name, query_path, test_src_dir, src_pack_dir):
        # Add qlref test file
    print(
        rule_id + ": Writing out query test files to " + str(test_src_dir))
    with open(test_src_dir.joinpath(query["short_name"] + ".qlref"), "w", newline="\n") as f:
        f.write(str(query_path.relative_to(
            src_pack_dir)).replace("\\", "/"))

    # Create an empty test file, if one doesn't already exist
    test_src_dir.joinpath(f"test.{language_name}").touch()

    # Add an empty expected results file - this makes it possible to see the results the
    # first time you run the test in VS Code
    expected_results_file = test_src_dir.joinpath(
        f"{query['short_name']}.expected"
    )
     
    if not expected_results_file.exists():
        with open(expected_results_file, "w", newline="\n") as f:
            f.write(
                "No expected results have yet been specified")


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
            # Currently assumes that language_name is also the subdirectory name
            standard_dir = repo_root.joinpath(
                language_name).joinpath(standard_short_name)
            # Identify common src and test packs
            common_dir = repo_root.joinpath(
                ql_language_name).joinpath("common")
            common_src_pack_dir = common_dir.joinpath("src")
            # The language specific files always live under the commons for that
            # language 
            common_test_pack_dir = repo_root.joinpath(language_name, "common", "test")
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

                for q in rule_details["queries"]:

                    # extract metadata and model
                    query, exclusion_model = extract_metadata_from_query(
                        rule_id,
                        rule_details["title"],
                        q,
                        rule_query_tags,
                        language_name,
                        ql_language_name,
                        standard_name,
                        standard_short_name,
                        standard_metadata,
                        args.anonymise
                    )
                    # add query to each dict
                    exclusion_query.append(exclusion_model)

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
                        write_shared_implementation(package_name, rule_id, query, language_name, ql_language_name, common_src_pack_dir, common_test_pack_dir)
                    else:
                        write_non_shared_testfiles(query, language_name, query_path, test_src_dir, src_pack_dir)
        # Exclusions
        exclusions_template = env.get_template("exclusions.qll.template")
        common_exclusions_dir = common_src_pack_dir.joinpath(
            "codingstandards", 
            ql_language_name, 
            "exclusions")
        # assign package and sanitize
        package_name = package_name.replace("-", "")
        package_name = package_name[:1].upper() + package_name[1:]
        exclusion_library_file = common_exclusions_dir.joinpath(language_name,
                                                                package_name + ".qll")
        # write exclusions file
        print(package_name + ": Writing out exclusions file to " +
              str(exclusion_library_file))

        os.makedirs(common_exclusions_dir.joinpath(
            language_name), exist_ok=True)

        write_exclusion_template(exclusions_template, exclusion_query,
                                 package_name, language_name, exclusion_library_file)


# After updating these files, the metadata should be regenerated
print("==========================================================")
print(f"Regenerating RuleMetadata.qll for {language_name.upper()}")
print("==========================================================")

repo_root = Path(__file__).parent.parent.parent
update_metadata_path = repo_root.joinpath(
    "scripts", "generate_metadata", "generate_metadata_for_language.py")
subprocess.run(["python", update_metadata_path, language_name])
