from semantic_version import Version # type: ignore
from subprocess import run
from typing import List, Literal, TYPE_CHECKING
from sys import stderr

if TYPE_CHECKING:
    from argparse import Namespace

def get_merge_base_of_ref() -> str:
    cp = run(["git", "merge-base", "HEAD", "origin/main"], capture_output=True, text=True)
    if cp.returncode != 0:
        raise RuntimeError(f"Failed to get merge base with reason '{cp.stderr.strip()}'")
    return cp.stdout.strip()

def get_release_branches_containing(commit: str) -> List[Version]:
    cp = run(["git", "branch", "--list", "rc/*", "--contains", commit], capture_output=True, text=True)
    if cp.returncode != 0:
        raise RuntimeError("Failed to get branches containing commit")
    release_versions: List[Version] = []
    for version in [b.strip() for b in cp.stdout.splitlines()]:
        try:
            if version.startswith("rc/"):
                version = version[3:]
                release_versions.append(Version(version))
        except ValueError:
            print(f"Warning: Skipping invalid version string: {version}", file=stderr)

    return release_versions

def main(args: 'Namespace') -> Literal[0,1]:
    try:
        merge_base = get_merge_base_of_ref()
        release_versions = get_release_branches_containing(merge_base)
        if len(release_versions) == 0:
            print(f"Info: No release branches found containing merge base {merge_base}", file=stderr)
            print("false")
            return 0

        for version in release_versions:
            if version.next_patch() == Version(args.version):
                print("true")
                return 0
            
        print("false")
        return 0
    except RuntimeError as e:
        print(f"Error: {e}", file=stderr)
        return 1
    
if __name__ == '__main__':
    from sys import stderr, exit
    import argparse

    parser = argparse.ArgumentParser(description="Check if a version is a hotfix release")
    parser.add_argument("version", help="The version string to compare against the base branches")
    exit(main(parser.parse_args()))