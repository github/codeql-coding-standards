import re
from typing import Type, Dict, List, Optional, TextIO, Generator, Union, Pattern
from jinja2 import Template
from pathlib import Path
from dataclasses import dataclass
import marko
from marko.md_renderer import MarkdownRenderer
import tempfile
import sys

# Add the shared module to the path
script_path = Path(__file__)
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQL, CodeQLError
from markdown_helpers import HeadingFormatUpdateSpec, update_help_file, HeadingDiffUpdateSpec

# Global holding an instance of CodeQL that can be shared too prevent repeated instantiation costs.
codeql = None

def split_camel_case(short_name : str) -> List[str]:
    """Split a camel case string to a list."""
    matches = re.finditer(
        ".+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)", short_name)
    return [m.group(0) for m in matches]


def standard_tag(standard_short_name : str, key : str, value: Optional[str]) -> str:
    """Create a CodeQL tag for the given standard and property name"""
    return (
        "external/"
        + standard_short_name
        + "/"
        + key.replace("_", "-").replace(" ", "-").lower()
        + (("/" + value.replace("_", "-").replace(" ", "-").lower()) if value else "")
    )


def description_line_break(description : str) -> List[str]:
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


def write_template(template: Type[Template], args: Dict[str, str], package_name: str, file: Type[Path]) -> None:
    """Render the template with the given args, and write it to the file using \n newlines."""
    with open(file, "w", newline="\n") as f:
        render_template(template, args, package_name, f)


def render_template(template: Type[Template], args: Dict[str, str], package_name: str, file: TextIO) -> None:
    output = template.render(args, package_name=package_name)
    file.write(output)

def write_exclusion_template(template: Type[Template], args: Dict[str, str], package_name: str, language_name: str, file: TextIO):
    """Render the template with the given args, and write it to the file using \n newlines."""
    output = template.render(
        data=args, package_name=package_name, language_name=language_name)

    with open(file, "w", newline="\n") as f:
        f.write(output)

    global codeql
    if codeql == None:
        codeql = CodeQL()
    # Format the generated exclusion file because we don't want to handle this in the template.
    # The format relies on the length of the package name.
    codeql.format(file)

def extract_metadata_from_query(rule_id, title, rule_category, q, rule_query_tags, language_name, ql_language_name, standard_name, standard_short_name, standard_metadata, anonymise):

    metadata = q.copy()

    # Add rule properties to the query dict, ready for template generation
    metadata["standard_name"] = standard_name
    metadata["standard_short_name"] = standard_short_name
    metadata["rule_id"] = rule_id
    metadata["rule_title"] = title
    metadata["tags"].extend(rule_query_tags)
    metadata["language_name"] = language_name
    metadata["ql_language_name"] = ql_language_name

    metadata["shortname_camelcase"] = metadata["short_name"][0].lower(
    ) + metadata["short_name"][1:]

    # short id generated from short name
    metadata["short_id"] = "-".join([c.lower()
                                    for c in split_camel_case(metadata["short_name"])])
    # set up model for exclusions
    exclusion_model = {}
    # queryid currently assumes c or c++ queries
    exclusion_model["queryid"] = f"{language_name}/{standard_short_name}/{metadata['short_id']}"
    exclusion_model["ruleid"] = rule_id
    exclusion_model["queryname"] = metadata["short_name"]
    exclusion_model["queryname_camelcase"] = metadata["short_name"][0].lower(
    ) + metadata["short_name"][1:]
    exclusion_model["category"] = rule_category

    if not "kind" in metadata:
        # default to problem if not specified
        metadata["kind"] = "problem"
    # separate description into multiple lines
    metadata["description"] = description_line_break(
        metadata["description"] if "description" in metadata else metadata["rule_title"])

    # Anonymise properties, if required
    if anonymise:
        metadata["rule_title"] = metadata["short_name"]
        metadata["description"] = [metadata["short_name"]
                                   ] if anonymise else metadata["description"]
        metadata["name"] = metadata["short_name"]

    if not standard_name in standard_metadata:
        exit(f"Unsupported standard '{standard_name}'")

    metadata.update(standard_metadata[standard_name])

    return metadata, exclusion_model

def write_query_help_file(help_dir: Type[Path], env: any, query: any, package_name: str, rule_id: str, standard_name: str) -> None:
    # Add Markdown help file, partially overwriting elements that are automatically generated.
    help_path = help_dir.joinpath(
        query["short_name"] + ".md")
    help_template = env.get_template(f"{standard_name.lower()}-help.md.template")

    if not help_path.exists():
        print(
            rule_id + ": Writing out query help file to " + str(help_path))
        write_template(help_template, query,
                        package_name, help_path)
    else:
        print(rule_id + ": Updating query help file at " + str(help_path))

        with tempfile.TemporaryFile(mode="r+", suffix="md") as updated_help_fd:
            render_template(
                help_template, query, package_name, updated_help_fd)

            updated_help_fd.seek(0)
            md = marko.Markdown(renderer=MarkdownRenderer)
            updated_help = md.parse(updated_help_fd.read())

            with help_path.open(mode="r+") as existing_help_fd:
                existing_help = md.parse(
                    existing_help_fd.read())
                updates = [HeadingDiffUpdateSpec("Implementation notes", updated_help),
                                           HeadingDiffUpdateSpec(
                                               "References", updated_help),
                                           HeadingDiffUpdateSpec(re.compile(
                                               f"^{rule_id}\\s*:"), updated_help),
                                           HeadingFormatUpdateSpec()
                                           ]
                update_help_file(existing_help, updates)
                existing_help_fd.seek(0)
                existing_help_fd.truncate(0)
                existing_help_fd.write(
                    md.render(existing_help))