import argparse
import os
import subprocess
import get_workspace_packs

parser = argparse.ArgumentParser(description="Install CodeQL library pack dependencies.")
parser.add_argument('--mode', required=False, choices=['use-lock', 'update', 'verify', 'no-lock'], default="use-lock", help="Installation mode, identical to the `--mode` argument to `codeql pack install`")
parser.add_argument('--codeql', required=False, default='codeql', help="Path to the `codeql` executable.")
args = parser.parse_args()

# Find the root of the repo
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

packs = get_workspace_packs.get_workspace_packs(root)

# Find the CodeQL packs in the repo. This can also return packs outside of the repo, if those packs
# are installed in a sibling directory to the CLI.
for pack in packs:
    pack_path = os.path.join(root, pack)
    # Run `codeql pack install` to install dependencies.
    command = [args.codeql, 'pack', 'install', '--allow-prerelease', '--mode', args.mode, pack_path]
    print(f'Running `{" ".join(command)}`')
    subprocess.check_call(command)
