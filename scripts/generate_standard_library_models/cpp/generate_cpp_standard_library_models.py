import json
from pathlib import Path
import yaml

generate_modules_home = Path(__file__).resolve().parent
common_codingstandards_ext_output = generate_modules_home.parent.parent.joinpath(
    'cpp', 'common', 'src', 'ext','stdcpp14.generated.names.model.yml')

queries = ["libraryTypeModel", "libraryFunctionModel", "libraryObjectModel", "libraryMemberVariableModel"]
def load_spec(spec_file):
    with spec_file.open() as f:
        return json.load(f)

yaml_output = {
    "extensions" : []
}

for query in queries:
    yaml_output["extensions"].append({
        "addsTo": {
            "pack" : "codeql/common-cpp-coding-standards",
            "extensible" : query
        },
        "data" : load_spec(generate_modules_home.joinpath(f"{query}.json"))["#select"]["tuples"]
    
    })

with open(common_codingstandards_ext_output, 'w') as file:
    yaml.dump(yaml_output, file, default_flow_style=None, width=3000)