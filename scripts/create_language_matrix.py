import json
import os
from pathlib import Path

config_file_path = Path(__file__).parent.parent.joinpath('supported_codeql_configs.json')

with open(config_file_path, "r") as config_file:
    json_data = json.load(config_file)

    matrix = []
    
    # foreach language, merge in the existing metadata
    for e in json_data["supported_language"]:
        for c in json_data["supported_environment"]:
            #print(f"lang={e}, env={c}")
            data = e 
            data.update(c) 
            matrix.append(data)

    print(json.dumps(matrix))


