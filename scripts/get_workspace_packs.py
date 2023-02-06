import glob
import yaml
import os

def get_workspace_packs(root):
    # Find the packs by globbing using the 'provide' patterns in the CodeQL workspace file.
    os.chdir(root)
    with open('codeql-workspace.yml') as codeql_workspace_file:
        codeql_workspace = yaml.load(codeql_workspace_file)
    packs = []
    for pattern in codeql_workspace['provide']:
        packs.extend(glob.glob(pattern, recursive=True))
    
    return packs
