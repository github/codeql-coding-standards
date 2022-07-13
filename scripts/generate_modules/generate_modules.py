from bs4 import BeautifulSoup
import requests
import re
from functools import reduce
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader
from sys import exit

generate_modules_home = Path(__file__).resolve().parent
common_codingstandards_home = generate_modules_home.parent.parent.joinpath(
    'cpp', 'common', 'src', 'codingstandards', 'cpp')
env = Environment(
    loader=FileSystemLoader(generate_modules_home.joinpath('templates')),
    trim_blocks=True,
    lstrip_blocks=True
)

modules = [
    {
        "name": "Naming",
        "sources": [
            {
                "name": "macros",
                "file": "cxx14-stdlib-macros.json"
            },
            {
                "name": "objects",
                "file": "cxx14-stdlib-objects.json"
            },
            {
                "name": "functions",
                "file": "cxx14-stdlib-functions.json"
            }
        ]
    }
]


def load_spec(spec_file):
    with spec_file.open() as f:
        return json.load(f)


for module in modules:
    print(f"Generating module {module['name']}")
    sources = {source["name"]: load_spec(generate_modules_home.joinpath(source["file"]))[
        "#select"]["tuples"] for source in module['sources']}
    template = env.get_template(f"{module['name']}.qll.template")
    template.stream(sources).dump(
        str(common_codingstandards_home.joinpath(f"{module['name']}.qll")))
print("Done")
