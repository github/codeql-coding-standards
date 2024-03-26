from semantic_version import Version
import argparse

parser = argparse.ArgumentParser(description='Prints the next release version')
parser.add_argument('-c', '--component', default="minor", help='The component to increment (major, minor, patch)')
parser.add_argument('-p', '--pre-release', nargs='*', help='The pre-release label(s) (e.g. alpha, dev). Multiple labels can be specified so separate the options and the version using `--`!')
parser.add_argument('-b', '--build', nargs='*', help='The build identifier(s). Multiple identifiers can be specified so separate the options and the version using `--`!')
parser.add_argument('current_version', type=Version, help='The current version')

if __name__ == "__main__":
    args = parser.parse_args()
    version : Version = args.current_version
    next_version = None
    if args.component== "major":
        next_version = version.next_major()
    elif args.component == "minor":
        next_version = version.next_minor()
    elif args.component == "patch":
        next_version = version.next_patch()
    else:
        raise ValueError(f"Invalid release type: {args.release_type}")

    if args.pre_release:
        next_version.prerelease = args.pre_release
    if args.build:
        next_version.build = args.build
    
    print(next_version)