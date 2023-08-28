import semantic_version # type: ignore
from typing import Literal

def main(args : list[str]) -> Literal[1, 0]:
    if len(args) != 2:
        print("Error: incorrect number of arguments", file=sys.stderr)
        print(f"Usage: {args[0]} <version>", file=sys.stderr)
        return 1
    
    try:
        semantic_version.Version.parse(args[1]) # type: ignore
        return 0
    except ValueError as e:
        print(f"Error: invalid version: {e}", file=sys.stderr)
        return 1
    

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))