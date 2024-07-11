from semantic_version import Version # type: ignore
from subprocess import run
from typing import List, Literal, TYPE_CHECKING
from sys import stderr

if TYPE_CHECKING:
    from argparse import Namespace

def main(args: 'Namespace') -> Literal[0,1]:
    try:
        version = Version(args.version)
        if version.patch > 0:
            print("true")
        else:
            print("false")
        return 0
    except ValueError:
        print(f"Invalid version string: {args.version}", file=stderr)
        return 1
    
if __name__ == '__main__':
    from sys import stderr, exit
    import argparse

    parser = argparse.ArgumentParser(description="Check if a version is a hotfix release")
    parser.add_argument("version", help="The version string to compare against the base branches")
    exit(main(parser.parse_args()))