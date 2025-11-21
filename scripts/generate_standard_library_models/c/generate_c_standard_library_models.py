from argparse import ArgumentParser
from pathlib import Path
import re
import yaml

help_statement = """
A tool for generating models-as-data file for a specified C Standard Library.

The input file should contain the list of APIs copied from Appendix B of the C Standard Library document.

The output file will be a models-as-data file that can be used to extend the codeql/common-cpp-coding-standards pack.
"""

parser = ArgumentParser(description=help_statement)

parser.add_argument(
    "standard", help="the C Standard Library version the model is being generated for (e.g. C99, C11)")

parser.add_argument(
    "input_file", help="the input file containing the list of APIs copied from Appendix B of the C Standard Library document")

args = parser.parse_args()

input_file = args.input_file
standard = args.standard

# Extract the header name from a header line
header_regex = re.compile(r".*<(.+)>")
# Extract return signature, function name and parameter signature from a function line
function_regex = re.compile(r"(?P<return_signature>.+ \(?\*?)(?P<function_name>[^\s\(\)]+)(?P<parameter_signature>\(([^\(]|\([^\)]*\))+\))(?P<trailing_return>\)\(.*\))?;.*")
# Extract macro name and parameter signature from a function-like-macro line
function_like_macro_regex = re.compile(r"(?P<macro_name>[^\s]+)(?P<macro_parameters>\(.+\))")
# Extract the prefix/postfix for a macro containing a `N` size replacement
macro_size_replace_regex = re.compile(r"^(.*(?:(?i:int)|(?i:fast)|(?i:least)|PRI[diouxX]|SCN[diouxX]))N(.*)$")
# 
is_macro_regex = re.compile(r"^$")

def map_size_vars(name):
    """
    Given a name, return a list of names with the size variables replaced with 8, 16, 32, 64.
    """
    match = macro_size_replace_regex.match(name)
    if match:
        # intn, leastn, fastn PRI*N, SCN*N need the "N" replaced with 8, 16, 32, 64
        print("Note: found size variable " + name + "; split into " + match.group(1) + " and " + match.group(2))
        return [match.group(1) + str(size) + match.group(2) for size in ["8", "16", "32", "64"]]
    else:
        return [name]

lines = []
with open(input_file, 'r') as file:
    lines = file.readlines()

rows = []
# The lines representing functions may include line breaks after the comma, so combine them
accumulated_line = ""
for line in lines:
    accumulated_line += line.strip()
    if not accumulated_line.endswith(",") and not accumulated_line.endswith("("):
      rows.append(accumulated_line.replace("#define ",""))
      accumulated_line = ""

# Parse the rows into lists of functions, macros, objects and types
current_header = ""
functions = []
macros = []
objects = []
types = []
for row in rows:
    if row.startswith("B."):
        # Find the header name in angle brackets
        match = header_regex.match(row)
        if match:
            current_header = match.group(1)
            print("Note: found header " + current_header)
        else:
            print("Error: Could not match header " + row)
    elif "(" in row:
        match = function_regex.match(row)
        if match:
          # This is a function
          components = match.groupdict()
          if "trailing_return" in components and components["trailing_return"]:
              # Function returns a function pointer, reconstruct from leading and trailing components
              return_type = components["return_signature"] + components["function_name"] + components["trailing_return"]
          else:
              # Otherwise a non-function return type
              return_type = components["return_signature"].strip()
          functions.append([
                # standard
                standard,
                # header
                current_header,
                # namespace: C Standard, so implied to have no namespace
                "",
                # declaring type: C Standard, so implied to have no declaring type
                "",
                # name
                components["function_name"],
                return_type,
                components["parameter_signature"],
                # linkage: C Standard specifies that all library functions have external linkage
                "external"
            ])
        else:
            # This is a function-like macro
            match = function_like_macro_regex.match(row)
            if match:
                components = match.groupdict()
                macros.append([
                    # standard
                    standard,
                    # header
                    current_header,
                    # name
                    components["macro_name"],
                    # type: this is a macro so has no type
                    components["macro_parameters"]
                ])
            else:
                print("Error: Could not match function-like signature " + row)
    elif row.startswith("#pragma"):
          # Ignore pragmas
          print("Note: skipping pragma " + row)
    else:
        # Replace "_ _" with "__" (typographical error when copying the standard)
        # Replace "struct " with "struct-" (to avoid splitting on the space)
        for name in row.replace("_ _", "__").replace("struct ","struct-").split(" "):
            for mapped_name in map_size_vars(name):
                if mapped_name.endswith("_t") or mapped_name == "FILE" or mapped_name.startswith("struct-") or mapped_name.startswith("atomic_"):
                    # This is a known C type
                    types.append([
                        # standard
                        standard,
                        # header
                        current_header,
                        # namespace: C Standard, so implied to have no namespace
                        "",
                        # name
                        mapped_name.replace("struct-","struct "),
                    ])
                else:
                    if mapped_name == "NDEBUG":
                        # Ignore NDEBUG
                        print("Note: skipping NDEBUG, not part of a header")
                        continue

                    # Assume anything remaining is a macro
                    macros.append([
                        # standard
                        standard,
                        # header
                        current_header,
                        # name
                        mapped_name,
                        # parameters - no parameters, not a function-like macro
                        ""
                    ])

# Construct the models-as-data representation
yaml_output = {
    "extensions" : [
        {
          "addsTo": {
            "pack" : "codeql/common-cpp-coding-standards",
            "extensible" : "libraryMacroModel"
          },
          "data" : macros
        },
                {
          "addsTo": {
            "pack" : "codeql/common-cpp-coding-standards",
            "extensible" : "libraryObjectModel"
          },
          "data" : objects
        },
        {
          "addsTo": {
            "pack" : "codeql/common-cpp-coding-standards",
            "extensible" : "libraryTypeModel"
          },
          "data" : types
        },
        {
          "addsTo": {
            "pack" : "codeql/common-cpp-coding-standards",
            "extensible" : "libraryFunctionModel"
          },
          "data" : functions
        }
    ]
}

generate_standard_library_home = Path(__file__).resolve().parent
root = generate_standard_library_home.parent.parent.parent
common_codingstandards_ext_output = root.joinpath('cpp', 'common', 'src', 'ext',f"std{ standard.lower() }.generated.names.model.yml")

# Write the models-as-data file to YAML
with open(common_codingstandards_ext_output, 'w') as file:
    yaml.dump(yaml_output, file, default_flow_style=None, width=3000)
    print("Wrote models-as-data file to " + str(common_codingstandards_ext_output) + " for " + standard + " C Standard Library.")