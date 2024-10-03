import json
import requests
from typing import Optional, Dict, List, Tuple
from semantic_version import Version
from pathlib import Path
import yaml

SCRIPT_PATH = Path(__file__)
CODING_STANDARDS_ROOT = SCRIPT_PATH.parent.parent.parent
SUPPORTED_VERSIONS_PATH = CODING_STANDARDS_ROOT / "supported_codeql_configs.json"

def get_compatible_stdlib(version: Version) -> Optional[Tuple[str, str]]:
    tag = f"codeql-cli/v{version}"
    response = requests.get(f"https://raw.githubusercontent.com/github/codeql/{tag}/cpp/ql/lib/qlpack.yml")

    if response.status_code == 200:
        # Parse the qlpack.yml returned in the response as a yaml file to read the version property
        qlpack = yaml.safe_load(response.text)
        if qlpack is not None and "version" in qlpack:
            return (tag, qlpack["version"])
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
        compatible_stdlib_return = get_compatible_stdlib(parsed_cli_version)
        if compatible_stdlib_return is None:
            print(f"Unable to find compatible standard library for: {parsed_cli_version}")
            exit(1)
        compatible_bundle = get_compatible_bundle(parsed_cli_version, github_token)
        if compatible_bundle is None:
            print(f"Unable to find compatible bundle for: {parsed_cli_version}")
            exit(1)

        compatible_stdlib_tag, compatible_stdlib_version = compatible_stdlib_return

        with SUPPORTED_VERSIONS_PATH.open("r") as f:
            supported_versions = json.load(f)

        supported_envs: List[Dict[str, str]] = supported_versions["supported_environment"]
        if len(supported_envs) != 1:
            print("Expected exactly one supported environment, cannot upgrade!")
            exit(1)
        supported_env = supported_envs[0]
        supported_env["codeql_cli"] = str(parsed_cli_version)
        supported_env["codeql_cli_bundle"] = compatible_bundle
        supported_env["codeql_standard_library"] = compatible_stdlib_tag

        with SUPPORTED_VERSIONS_PATH.open("w") as f:
            json.dump(supported_versions, f, indent=2)

        # Find every qlpack.yml file in the repository
        qlpack_files = list(CODING_STANDARDS_ROOT.rglob("qlpack.yml"))
        # Filter out any files that are in a hidden directory
        qlpack_files = [f for f in qlpack_files if not any(part for part in f.parts if part.startswith("."))]

        # Update the "codeql/cpp-all" entries in the "dependencies" property in every qlpack.yml file
        updated_qlpacks = []
        for qlpack_file in qlpack_files:
            with qlpack_file.open("r") as f:
                qlpack = yaml.safe_load(f)
            print("Updating dependencies in " + str(qlpack_file))
            if "codeql/cpp-all" in qlpack["dependencies"]:
                qlpack["dependencies"]["codeql/cpp-all"] = compatible_stdlib_version
                with qlpack_file.open("w") as f:
                    yaml.safe_dump(qlpack, f, sort_keys=False)
                updated_qlpacks.append(qlpack_file.parent)

        # Call CodeQL to update the lock files by running codeql pack upgrade
        # Note: we need to do this after updating all the qlpack files,
        #       otherwise we may get dependency resolution errors
        for qlpack in updated_qlpacks:
            print("Updating lock files for " + str(qlpack))
            os.system(f"codeql pack upgrade {qlpack}")


    except ValueError as e:
        print(e)
        exit(1)

if __name__ == '__main__':
    import sys
    import argparse
    import os

    parser = argparse.ArgumentParser(description='Upgrade CodeQL dependencies')

    parser.add_argument('--cli-version', type=str, required=True, help='CodeQL CLI version')
    parser.add_argument('--github-auth-stdin', action='store_true', help='Authenticate to the GitHub API by providing a GitHub token via standard input.')

    args = parser.parse_args()
    if args.github_auth_stdin:
        token = sys.stdin.read()
    else:
        if "GITHUB_TOKEN" not in os.environ:
            print("GITHUB_TOKEN environment variable not set")
            exit(1)
        token = os.environ["GITHUB_TOKEN"]

    main(args.cli_version, token)



