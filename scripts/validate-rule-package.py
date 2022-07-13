def is_warning(error):
    schema_path = error.schema_path.copy()
    return schema_path.pop() == "maxLength" and schema_path.pop() in ["short_name", "shared_implementation_short_name"]


# Helper function to open a package by name or name with extension.
def open_package(path):
    # Assume it is a package name when not ending with '.json'
    if not path.endswith(".json"):
        path = f"rule_packages/{path}.json"
    return open(path, 'r')


def main():
    import argparse
    import json
    from jsonschema import Draft7Validator, SchemaError

    parser = argparse.ArgumentParser(description="Rule package validator.")
    parser.add_argument('rule_package', metavar='FILE', type=open_package, nargs="+",
                        help="A rule package description requiring validation")
    parser.add_argument(
        '--schema', help="Schema used to validate rule package", default="schemas/rule-package.schema.json")

    args = parser.parse_args()

    print(f"🔵  Using schema: {args.schema}")
    with open(args.schema) as schema_file:
        schema = json.load(schema_file)

    contains_errors = False
    for rule_package_file in args.rule_package:
        print(f"🔵  Validating rule package {rule_package_file.name}")
        rule_package = json.load(rule_package_file)
        try:
            validator = Draft7Validator(schema)
            all_errors = sorted(validator.iter_errors(
                rule_package), key=lambda e: e.path)
            warnings = [error for error in all_errors if is_warning(error)]
            errors = [error for error in all_errors if not is_warning(error)]
            if len(errors) == 0:
                if len(warnings) == 0:
                    print(
                        f"🟢  Rule package {rule_package_file.name} is valid.")
                else:
                    print(
                        f"🟡  Rule package {rule_package_file.name} is valid, but has {len(warnings)} warning(s).")
                    warning_nr = 1
                    for warning in warnings:
                        print(
                            f"🟡  Warning({warning_nr}): {warning.message} [{' -> '.join(map(str,list(warning.path)))}]")
                        warning_nr += 1
            else:
                if len(warnings) == 0:
                    print(
                        f"🔴  Rule package {rule_package_file.name} failed validation with {len(errors)} error(s).")
                else:
                    print(
                        f"🔴  Rule package {rule_package_file.name} failed validation with {len(errors)} error(s) and {len(warnings)} warning(s).")
                contains_errors = True
                error_nr = 1
                for error in errors:
                    print(
                        f"🔴  Error({error_nr}): {error.message} [{' -> '.join(map(str,list(error.path)))}]")
                    error_nr += 1
                warning_nr = 1
                for warning in warnings:
                    print(
                        f"🟡  Warning({warning_nr}): {warning.message} [{' -> '.join(map(str,list(warning.path)))}]")
                    warning_nr += 1
        except SchemaError as err:
            print(f"🔴  The schema {schema_file.name} is invalid.")
            print(f"🔴  Failed with message: {err.message}.")
            contains_errors = True
            break

    return 0 if not contains_errors else 1


if __name__ == "__main__":
    from sys import exit
    exit(main())
