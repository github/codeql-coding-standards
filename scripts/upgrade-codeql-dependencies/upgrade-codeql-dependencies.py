import json
import requests
from typing import Optional, Dict, List
from semantic_version import Version
from pathlib import Path

SCRIPT_PATH = Path(__file__)
SUPPORTED_VERSIONS_PATH = SCRIPT_PATH.parent.parent.parent / "supported_codeql_configs.json"

def get_compatible_stdlib(version: Version) -> Optional[str]:
    tag = f"codeql-cli/v{version}"
    response = requests.get(f"https://raw.githubusercontent.com/github/codeql/{tag}/cpp/ql/lib/qlpack.yml")

    if response.status_code == 200:
        return tag
    return None
    
def get_compatible_bundle(version: Version, token: str) -> Optional[str]:
    tag = f"codeql-bundle-v{version}"
    response = requests.get(f"https://api.github.com/repos/github/codeql-action/releases/tags/{tag}", headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28"
    })

    if response.status_code == 200:
        return tag
    return None

def main(cli_version : str, github_token: str) -> None:
    try:
        parsed_cli_version = Version(cli_version)
        compatible_stdlib = get_compatible_stdlib(parsed_cli_version)
        if compatible_stdlib is None:
            print(f"Unable to find compatible standard library for: {parsed_cli_version}")
            exit(1)
        compatible_bundle = get_compatible_bundle(parsed_cli_version, github_token)
        if compatible_bundle is None:
            print(f"Unable to find compatible bundle for: {parsed_cli_version}")
            exit(1)

        with SUPPORTED_VERSIONS_PATH.open("r") as f:
            supported_versions = json.load(f)
        with SUPPORTED_VERSIONS_PATH.open("w") as f:
            supported_envs: List[Dict[str, str]] = supported_versions["supported_environment"]
            if len(supported_envs) != 1:
                print("Expected exactly one supported environment, cannot upgrade!")
                exit(1)
            supported_env = supported_envs[0]
            supported_env["codeql_cli"] = str(parsed_cli_version)
            supported_env["codeql_cli_bundle"] = compatible_bundle
            supported_env["codeql_standard_library"] = compatible_stdlib

            json.dump(supported_versions, f, indent=2)
    except ValueError as e:
        print(e)
        exit(1)

if __name__ == '__main__':
    import sys
    import argparse
    import os

    parser = argparse.ArgumentParser(description='Upgrade CodeQL dependencies')

    parser.add_argument('--cli-version', type=str, required=True, help='CodeQL CLI version')
    parser.add_argument('--github-auth-stdin', action='store_true', help='CodeQL bundle version')

    args = parser.parse_args()
    if args.github_auth_stdin:
        token = sys.stdin.read()
    else:
        if "GITHUB_TOKEN" not in os.environ:
            print("GITHUB_TOKEN environment variable not set")
            exit(1)
        token = os.environ["GITHUB_TOKEN"]

    main(args.cli_version, token)



