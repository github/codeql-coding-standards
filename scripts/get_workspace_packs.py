import glob
import json
import os

def get_workspace_packs(root):
    # Find the packs by globbing using the 'provide' patterns in the manifest.
    os.chdir(root)
    with open('.codeqlmanifest.json') as manifest_file:
        manifest = json.load(manifest_file)
    packs = []
    for pattern in manifest['provide']:
        packs.extend(glob.glob(pattern, recursive=True))

    return packs
