from argparse import ArgumentParser
import json
from jinja2 import Environment, FileSystemLoader
import requests
from requests.exceptions import HTTPError
from pathlib import Path
import os
import sys

help_statement = """
A tool for generating HTML files for the markdown files in this repository.

This conversion works by calling the GitHub API for converting a markdown file passed as an
argument to the call. This is then rendered into a HTML template with a stylesheet, and written to
the given output directory.
"""

parser = ArgumentParser(description=help_statement)
parser.add_argument("output_directory",
                    help="the directory where the html files should be written")

args = parser.parse_args()
output_directory = Path(args.output_directory)

if os.path.exists(output_directory):
    print("Error: output directory '" + str(output_directory) + "' exists.")
    sys.exit(1)

output_directory.mkdir(parents=True)

repo_root = Path(__file__).parent.parent.parent

env = Environment(loader=FileSystemLoader(Path(__file__).parent.joinpath(
    "templates")), trim_blocks=True, lstrip_blocks=True)


def load_file(file):
    with open(file, 'r', errors='ignore') as f:
        return f.read()


def generate_html(markdown_file, html_output_file):
    """
    Load the given Markdown file in GFM, and produce a HTML representation at the `html_output_file`.
    """
    text = load_file(markdown_file)
    try:
        # Use the GitHub API to convert a GFM file to HTML
        data = json.dumps({'text': text, 'mode': 'gfm'},
                          ensure_ascii=False).encode('utf-8')
        response = requests.post("https://api.github.com/markdown",
                                 data=data, headers={'Accept': 'application/vnd.github.v3+json'})

        # Throw an exception for a non 2XX status code
        response.raise_for_status()

        # Ensure the directory exists for the output file
        html_output_file.parent.mkdir(exist_ok=True, parents=True)

        # The HTML returned by GitHub is just the body. Render it within a HTML template that includes
        # a stylesheet and html/head/body tags.
        html_output = env.get_template("rendered_markdown.html.template").render(
            markdown_body=response.text, title=markdown_file.name)
        # Write the HTML page to the output file
        with open(html_output_file, "w", newline="\n") as f:
            f.write(html_output)
    except HTTPError as http_err:
        print("Error: could not process markdown file '" +
              str(markdown_file) + "'.")
        print(f'HTTP error occurred: {http_err}')
    except Exception as err:
        print("Error: could not process markdown file '" +
              str(markdown_file) + "'.")
        print(f'Other error occurred: {err}')


# Convert each of the relevant markdown files in turn
for markdown_file in ["docs/development_handbook.md", "docs/user_manual.md", "docs/iso_26262_tool_qualification.md", ".github/pull_request_template.md"]:
    output_file = Path(markdown_file)
    if output_file.parts[0][0] == '.':
        output_file = Path(output_file.parts[0][1:]).joinpath(
            *output_file.parts[1:])
    generate_html(repo_root.joinpath(markdown_file),
                  output_directory.joinpath(output_file).with_suffix(".html"))
