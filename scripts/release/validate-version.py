import semantic_version # type: ignore
from typing import Literal, TYPE_CHECKING
from subprocess import run

if TYPE_CHECKING:
    from argparse import Namespace

def get_release_version_of_ref() -> semantic_version.Version:
    cp = run(["git", "rev-parse", "--abbrev-ref", "HEAD"], capture_output=True, text=True)
    if cp.returncode != 0:
        raise RuntimeError("Failed to get current branch name")
    branch_name = cp.stdout.strip()
    ns, version_str = branch_name.split("/")
    if ns != "rc":
        raise RuntimeError("Not on a release branch!")
    
    try:
        return semantic_version.Version(version_str) # type: ignore
    except ValueError as e:
        raise RuntimeError(f"Invalid version string: {e}")
    
def main(args :'Namespace') -> Literal[1, 0]:
    try:
        release_version = semantic_version.Version(args.version) # type: ignore
        if args.hotfix:
            branch_release_version = get_release_version_of_ref()
            expected_version = branch_release_version.next_patch()
            if release_version != expected_version:
                print(f"Error: Hotfix version `{release_version}` does not iterate on {branch_release_version}. Expected `{expected_version}`. ", file=stderr)
                return 1
        return 0
    except ValueError as e:
        print(f"Error: invalid version: {e}", file=stderr)
        return 1
    except RuntimeError as e:
        print(f"Error: {e}", file=stderr)
        return 1

if __name__ == '__main__':
    from sys import stderr, exit
    import argparse

    parser = argparse.ArgumentParser(description="Validate a version string")
    parser.add_argument("version", help="The version string to validate")
    parser.add_argument('--hotfix', action='store_true', help="Whether the release is to hotfix an existing release.")

    exit(main(parser.parse_args()))