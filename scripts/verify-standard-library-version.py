import argparse
import json
import os
import subprocess
import yaml
import get_workspace_packs

def get_codeql_packs(codeql_repo, codeql):
    command = [codeql, 'resolve', 'qlpacks', '--additional-packs', codeql_repo, '--format', 'json']
    print(f'Running `{" ".join(command)}`')
    packs_json = subprocess.check_output(command)
    print(packs_json)
    packs = json.loads(packs_json)
    return packs

parser = argparse.ArgumentParser(description='Ensure that CodeQL library pack dependency versions match the supported configuration.')
parser.add_argument('--codeql-repo', required=True, help='Path to checkout of `github/codeql` repo at desired branch.')
parser.add_argument('--mode', required=False, choices=['verify', 'update'], default='verify', help="`verify` to fail on mismatch; `update` to change `qlpack.lock.yml` files to use new version.")
parser.add_argument('--codeql', required=False, default='codeql', help='Path to the `codeql` executable.')
args = parser.parse_args()

# Find the root of the repo
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Get the packs for the repo's workspace.
workspace_packs = get_workspace_packs.get_workspace_packs(root)

# Get the packs from the `codeql` repo checkout.
codeql_packs = get_codeql_packs(args.codeql_repo, args.codeql)

failed = False
for pack in workspace_packs:
    pack_path = os.path.join(root, pack)

    print(f"Scanning dependencies of '{pack_path}'...")

    # Read our pack's configuration file.
    with open(pack_path) as pack_file:
        pack_yaml = yaml.safe_load(pack_file)
    
    updated = False
    if 'dependencies' in pack_yaml:
        dependencies = pack_yaml['dependencies']
        for ref_name in dependencies:
            ref_version = dependencies[ref_name]
            if ref_name in codeql_packs:
                # Found this reference in the `codeql` repo. The version of the reference should match
                # the version of that pack in the `codeql` repo.
                lib_path = codeql_packs[ref_name][0]
                lib_path = os.path.join(lib_path, 'qlpack.yml')
                with open(lib_path) as lib_file:
                    lib_yaml = yaml.safe_load(lib_file)
                lib_version = lib_yaml['version']
                if ref_version != lib_version:
                    print(f"Mismatched versions for '{ref_name}', referenced from '{pack_path}'. " +
                        f"referenced version is '{ref_version}', but should be '{lib_version}'.")
                    if args.mode == 'verify':
                        failed = True # Report an error at the end.
                    else:
                        pack_yaml['dependencies'][ref_name] = lib_version
                        updated = True # Update our pack in-place.
    
    if updated:
        print(f"Updating '{pack_path}'...")
        with open(pack_path, 'w', newline='\n') as pack_file: # Always use LF even on Windows
            yaml.safe_dump(pack_yaml, pack_file, sort_keys=False)

exit(1 if failed else 0)
