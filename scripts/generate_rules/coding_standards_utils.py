import re

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


def write_exclusion_template(template, args, packagename, language_name, file):
    """Render the template with the given args, and write it to the file using \n newlines."""
    output = template.render(
        data=args, package_name=packagename, language_name=language_name)

    with open(file, "w", newline="\n") as f:
        f.write(output)

def extract_metadata_from_query(rule_id, title, q, rule_query_tags, language_name, ql_language_name, standard_name, standard_short_name, standard_metadata, anonymise):

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
