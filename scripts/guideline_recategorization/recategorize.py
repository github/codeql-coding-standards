import argparse
import sys
from dataclasses import asdict, dataclass
from typing import Any, Generator, Iterator, List, Mapping, Optional, TextIO, TypedDict, Union, cast
from pathlib import Path
import jsonschema
import json
from jsonpath_ng import jsonpath
import jsonpath_ng.ext
import jsonpointer
import yaml
import yaml.parser
import re
import jsonpatch
from functools import reduce

CODING_STANDARDS_SCHEMA_ID = 'https://raw.githubusercontent.com/github/codeql-coding-standards/main/schemas/coding-standards-schema-1.0.0.json'
SARIF_SCHEMA_ID = 'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json'

script_path = Path(__file__).resolve()
root_path = script_path.parent.parent.parent

@dataclass(frozen=True)
class GuidelineRecategorization():
    """
    This is a class to represent a guideline recategorization as specified in a
    `coding-standard.yml` configuration. 
    """
    rule_id: str
    category: str

class JsonPatch(TypedDict):
    """
    This is a class that represents a JSON Patch as specified in
    https://datatracker.ietf.org/doc/html/rfc6902/.
    """
    op: str
    path: str
    value: str

def json_path_to_pointer(path: Union[str,  jsonpath.JSONPath], subject: Mapping[str, Any]) -> Iterator[jsonpointer.JsonPointer]:
    """ Convert a JSON Path to, possible multiple, JSON Pointers"""
    if isinstance(path, str):
        path = jsonpath_ng.ext.parse(path)
    
    # Convert a resolved JSON Path to Pointer through the following steps:
    # 1. Replace the indexing expression `.[i].` with it's pointer equivalent `/i` with `i` being a positive integer.
    translate_indexing = lambda path:  re.sub(r'\.\[(\d+)\]', '.\\1', path)
    # 2. Split the path in to paths
    split_into_parts = lambda path: path.split('.')
    # 3. Convert the paths into a JSON pointer.
    convert_to_pointer = jsonpointer.JsonPointer.from_parts

    def apply(a, f):
        return f(a)
    path_to_pointer = lambda p: reduce(apply, [str, translate_indexing, split_into_parts, convert_to_pointer], p)

    return map(path_to_pointer,  [match.full_path for match in cast(jsonpath.JSONPath, path).find(subject)])

def recategorization_to_json_path_for_rule(recategorization: GuidelineRecategorization) -> str:
    """
    Compute a JSON path to the rule specified in the guideline recategorization.
    To remain composable the path is returned as a string.
    """
    return f'$.runs[?(@.tool.driver.name="CodeQL")].tool.driver.rules[?(@.properties.tags[*]=~"external/[^/]+/id/{recategorization.rule_id.lower()}")]'

def recategorization_to_json_path_for_category(recategorization: GuidelineRecategorization) -> str:
    """
    Compute a JSON path to the rule's category tag specified in the guideline recategorization.
    To remain composable the path is returned as a string.
    """
    return f'{recategorization_to_json_path_for_rule(recategorization)}.properties.tags[?(@=~"external/[^/]+/obligation/")]'

def generate_json_patches_for_recategorization(recategorization: GuidelineRecategorization, subject: dict) -> Iterator[JsonPatch]:
    """
    Compute as set of JSON patches to apply the recategorization to the subject Sarif file.
    """
    def to_jsonpatch(pointer:jsonpointer.JsonPointer) -> Iterator[JsonPatch]:
        obligation_tag = cast(str, pointer.get(subject))
        _, standard, _, category = obligation_tag.split('/')
        yield JsonPatch(
                op = 'replace',
                path = pointer.path,
                value = f'external/{standard}/obligation/{recategorization.category}')
        yield JsonPatch(op = 'add', path = pointer.path, value = f'external/{standard}/original-obligation/{category}')
    return (patch for pointer in json_path_to_pointer(recategorization_to_json_path_for_category(recategorization), subject) for patch in to_jsonpatch(pointer))
      

def get_guideline_recategorizations(coding_standards_config: Mapping[str, Any]) -> Generator[GuidelineRecategorization, None, None]:
    """
    Return the guideline recategorizations for a given Coding Standards configuration.
    """
    for spec in coding_standards_config['guideline-recategorizations']:
        yield GuidelineRecategorization(spec['rule-id'], spec['category'])

def load_schema(path: Path, defaultname: str) -> Optional[Mapping[str, Any]]:
    def resolve_path(path : Path) -> Optional[Path]:
        if path.is_file():
            return path
        
        if path.is_dir():
            if (path / defaultname).is_file():
                return (path / defaultname)
            
            if (path / 'schemas' / defaultname).is_file():
                return (path / 'schemas' / defaultname)
            
            if path.parent != path:
                return resolve_path(path.parent)
            else: 
                return None
    resolved_schema_path = resolve_path(path.resolve())
    if resolved_schema_path:
        with resolved_schema_path.open(mode='r') as fp:
            try:
                return json.load(fp)
            except json.decoder.JSONDecodeError as e:
                print_failure(f"Failed to load schema with error \"{e.msg}\" at {resolved_schema_path}:{e.lineno}:{e.colno}!")
    else:
        return None

def load_config(path: Path) -> Optional[Mapping[str, Any]]:
    if path.is_file():
        with path.open('r') as fp:
            try:
                return yaml.safe_load(fp)
            except yaml.parser.ParserError as e:
                print_failure(f"Failed to load config with error \"{e.problem}\" at {path}:{e.problem_mark.line}:{e.problem_mark.column}!")
    else:
        return None

def validate_against_schema(schema:  Mapping[str, Any], instance: Mapping[str, Any]) -> None:
    jsonschema.validate(schema=schema, instance=instance)

def print_warning(*values):
    print(*values, file=sys.stderr)

def print_failure(*values):
    print(*values, file=sys.stderr)
    exit(1)

def main(args: argparse.Namespace):
    coding_standards_schema = load_schema(args.coding_standards_schema_file, 'coding-standards-schema-1.0.0.json')
    if not coding_standards_schema:
        print_failure("Failed to load Coding Standards schema!")

    if not '$id' in coding_standards_schema:
        print_failure(f"Missing id for Coding Standards schema: '{args.coding_standards_schema_file}'")

    if coding_standards_schema['$id'] != CODING_STANDARDS_SCHEMA_ID:
        print_failure(f"Unexpected id for Coding Standards schema, expecting '{CODING_STANDARDS_SCHEMA_ID}'!")

    sarif_schema = load_schema(args.sarif_schema_file, 'sarif-schema-2.1.0.json')
    if not sarif_schema:
        print(f"Failed to load Sarif schema: '{args.sarif_schema_file}'!", file=sys.stderr)
        sys.exit(1)
    sarif_schema = cast(Mapping[str, Any], sarif_schema)

    if not '$id' in sarif_schema:
        print_failure(f"Missing id for Sarif schema: '{args.sarif_schema_file}'")

    if sarif_schema['$id'] != SARIF_SCHEMA_ID:
        print_failure(f"Unexpected id for Sarif schema: '{args.sarif_schema_file}, expecting '{SARIF_SCHEMA_ID}'!")

    coding_standards_config = load_config(args.coding_standards_config_file)
    if not coding_standards_schema:
        print(f"Failed to load Coding Standards configuration file: {args.coding_standards_config_file}!", file=sys.stderr)
        sys.exit(1)

    coding_standards_config = cast(Mapping[str, Any], coding_standards_config)
    try:
        validate_against_schema(coding_standards_schema, coding_standards_config)
    except jsonschema.ValidationError as e:
        print(f"Failed to validate the Coding Standards configuration file: {args.coding_standards_config_file} with the message: '{e.message}'!", file=sys.stderr)
        sys.exit(1)

    sarif = json.load(args.sarif_in)
    try:
        validate_against_schema(sarif_schema, sarif)
    except jsonschema.ValidationError as e:
        print(f"Failed to validate the provided Sarif with the message: '{e.message}'!", file=sys.stderr)
        sys.exit(1)

    recategorizations = get_guideline_recategorizations(coding_standards_config)
    patch = jsonpatch.JsonPatch([patch for r in recategorizations for patch in generate_json_patches_for_recategorization(r, sarif)])
    if args.dump_json_patch != None:
        dump_json_patch = Path(args.dump_json_patch)
        if dump_json_patch.is_dir():
            dump_json_patch /= 'json-patch.json'
        
        if not dump_json_patch.exists():
            dump_json_patch.write_text(patch.to_string())
        else:
            print_warning(f"Skipping dumping of JSON patch to file {dump_json_patch} because it already exists!")

    patched_sarif = patch.apply(sarif)
    validate_against_schema(sarif_schema, patched_sarif)
    
    json.dump(patched_sarif, args.sarif_out)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Apply a guideline re-categorization specification to a Sarif results file.')
    parser.add_argument('--coding-standards-schema-file', type=Path, default=Path.cwd())
    parser.add_argument('--sarif-schema-file', type=Path, default=Path.cwd())
    parser.add_argument('--dump-json-patch', type=Path)
    parser.add_argument('coding_standards_config_file', type=Path)
    parser.add_argument('sarif_in', nargs='?', type=argparse.FileType('r'), default=sys.stdin)
    parser.add_argument('sarif_out', nargs='?', type=argparse.FileType('w'), default=sys.stdout)
    
    main(parser.parse_args())