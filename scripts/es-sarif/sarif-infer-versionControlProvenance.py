#!/usr/bin/env python3
"""
SARIF Version Control Provenance Inference Script

This script processes SARIF files and infers the versionControlProvenance.repositoryUri
field for each run based on the file naming convention: <language>-<framework>_<org>_<repo>.sarif

The script reads a list of SARIF file paths from a text file (similar to the indexing script)
and modifies each SARIF file in-place to add the inferred versionControlProvenance information.

Usage:
    python sarif-infer-versionControlProvenance.py <sarif_files_list.txt>

File Naming Convention:
    Files should follow the pattern: <language>-<framework>_<org>_<repo>.sarif
    Examples:
        - c-cert_nasa_fprime.sarif -> https://github.com/nasa/fprime
        - cpp-misra_bitcoin_bitcoin.sarif -> https://github.com/bitcoin/bitcoin
        - c-misra_curl_curl.sarif -> https://github.com/curl/curl

Notes:
    - This is a pre-indexing step to ensure versionControlProvenance is present
    - Only repositoryUri is inferred; revisionId and branch cannot be derived from filename
    - Files are modified in-place; consider backing up before running
    - Files already containing versionControlProvenance are skipped unless they lack repositoryUri
"""

import sys
import os
import json
import re
from pathlib import Path


def parse_filename_for_repo_info(filename):
    """
    Parse a SARIF filename to extract organization and repository information.
    
    Expected filename pattern: <language>-<framework>_<org>_<repo>.sarif
    Files conforming to our naming scheme have exactly 2 underscores.
    
    Examples:
        c-cert_nasa_fprime.sarif -> ('nasa', 'fprime')
        cpp-misra_bitcoin_bitcoin.sarif -> ('bitcoin', 'bitcoin')
        c-misra_curl_curl.sarif -> ('curl', 'curl')
    
    Args:
        filename: The SARIF filename (without path)
    
    Returns:
        Tuple of (org, repo) if successful, None otherwise
    """
    # Remove .sarif extension
    name_without_ext = filename
    if name_without_ext.endswith('.sarif'):
        name_without_ext = name_without_ext[:-6]
    
    # Count underscores - should be exactly 2 for conforming files
    underscore_count = name_without_ext.count('_')
    if underscore_count != 2:
        return None
    
    # Split by underscore: <language-framework>_<org>_<repo>
    # The value between underscores is org, value after last underscore is repo
    first_underscore = name_without_ext.index('_')
    last_underscore = name_without_ext.rindex('_')
    
    org = name_without_ext[first_underscore + 1:last_underscore]
    repo = name_without_ext[last_underscore + 1:]
    
    if org and repo:
        return (org, repo)
    
    return None


def infer_repository_uri(org, repo):
    """
    Construct a GitHub repository URI from organization and repository names.
    
    Args:
        org: GitHub organization name
        repo: GitHub repository name
    
    Returns:
        Full GitHub repository URI
    """
    return f"https://github.com/{org}/{repo}"


def process_sarif_file(sarif_path):
    """
    Process a single SARIF file to add inferred versionControlProvenance.
    
    Args:
        sarif_path: Path to the SARIF file
    
    Returns:
        Tuple of (success: bool, message: str)
    """
    try:
        # Read the SARIF file
        with open(sarif_path, 'r', encoding='utf-8') as f:
            sarif_data = json.load(f)
        
        # Extract filename for parsing
        filename = Path(sarif_path).name
        
        # Parse filename to get org and repo
        repo_info = parse_filename_for_repo_info(filename)
        if not repo_info:
            return (False, f"Could not parse repository info from filename: {filename}")
        
        org, repo = repo_info
        repository_uri = infer_repository_uri(org, repo)
        
        # Track whether we modified anything
        modified = False
        
        # Process each run in the SARIF file
        if 'runs' not in sarif_data or not isinstance(sarif_data['runs'], list):
            return (False, "SARIF file does not contain valid 'runs' array")
        
        for run_index, run in enumerate(sarif_data['runs']):
            # Check if versionControlProvenance already exists
            if 'versionControlProvenance' not in run:
                # Create new versionControlProvenance array
                run['versionControlProvenance'] = [
                    {
                        "repositoryUri": repository_uri
                    }
                ]
                modified = True
            else:
                # Check if it's an array
                if not isinstance(run['versionControlProvenance'], list):
                    return (False, f"Run {run_index} has invalid versionControlProvenance (not an array)")
                
                # Check if any entry already has repositoryUri set
                has_repository_uri = False
                for vcp in run['versionControlProvenance']:
                    if 'repositoryUri' in vcp and vcp['repositoryUri']:
                        has_repository_uri = True
                        break
                
                # If no repositoryUri found, add one
                if not has_repository_uri:
                    if len(run['versionControlProvenance']) == 0:
                        # Empty array, add new entry
                        run['versionControlProvenance'].append({
                            "repositoryUri": repository_uri
                        })
                    else:
                        # Array has entries but no repositoryUri, add to first entry
                        run['versionControlProvenance'][0]['repositoryUri'] = repository_uri
                    modified = True
        
        # Write back to file if modified
        if modified:
            with open(sarif_path, 'w', encoding='utf-8') as f:
                json.dump(sarif_data, f, indent=2)
            return (True, f"Added repositoryUri: {repository_uri}")
        else:
            return (True, f"Already has repositoryUri (skipped)")
    
    except json.JSONDecodeError as e:
        return (False, f"JSON decode error: {e}")
    except Exception as e:
        return (False, f"Error processing file: {e}")


def read_sarif_files_list(list_file_path):
    """
    Read the list of SARIF files from the specified text file.
    
    Args:
        list_file_path: Path to the text file containing SARIF file paths
    
    Returns:
        List of absolute paths to SARIF files
    """
    list_file = Path(list_file_path)
    if not list_file.exists():
        print(f"Error: File list '{list_file_path}' does not exist.")
        return []
    
    base_dir = list_file.parent
    sarif_files = []
    
    with open(list_file, 'r') as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#'):
                continue
            
            # Resolve relative paths
            if not os.path.isabs(line):
                sarif_path = base_dir / line
            else:
                sarif_path = Path(line)
            
            # Check if file exists
            if not sarif_path.exists():
                print(f"Warning: File not found (line {line_num}): {line}")
                continue
            
            # Check if it's a .sarif file
            if not sarif_path.suffix == '.sarif':
                print(f"Warning: Not a .sarif file (line {line_num}): {line}")
                continue
            
            sarif_files.append(sarif_path)
    
    return sarif_files


def main():
    if len(sys.argv) != 2:
        print("SARIF Version Control Provenance Inference Script")
        print("=" * 50)
        print()
        print("Usage:")
        print(f"  python {sys.argv[0]} <sarif_files_list.txt>")
        print()
        print("Description:")
        print("  Infers and adds versionControlProvenance.repositoryUri to SARIF files")
        print("  based on the filename pattern: <language>-<framework>_<org>_<repo>.sarif")
        print()
        print("Example:")
        print(f"  python {sys.argv[0]} sarif-files_results-1.txt")
        print()
        print("Note:")
        print("  Files are modified in-place. Consider backing up before running.")
        sys.exit(1)
    
    sarif_files_list = sys.argv[1]
    
    print("SARIF Version Control Provenance Inference Script")
    print("=" * 50)
    print(f"SARIF files list: {sarif_files_list}")
    print()
    
    # Read and validate SARIF files list
    sarif_files = read_sarif_files_list(sarif_files_list)
    if not sarif_files:
        print("Error: No valid SARIF files found in the list.")
        sys.exit(1)
    
    print(f"Found {len(sarif_files)} SARIF files to process")
    print()
    
    # Process each file
    success_count = 0
    skip_count = 0
    error_count = 0
    
    for sarif_file in sarif_files:
        filename = sarif_file.name
        success, message = process_sarif_file(sarif_file)
        
        if success:
            if "skipped" in message.lower():
                skip_count += 1
                print(f"  [SKIP] {filename}: {message}")
            else:
                success_count += 1
                print(f"  [OK]   {filename}: {message}")
        else:
            error_count += 1
            print(f"  [ERROR] {filename}: {message}")
    
    # Summary
    print()
    print("=" * 50)
    print("Processing Summary:")
    print(f"  Total files:     {len(sarif_files)}")
    print(f"  Modified:        {success_count}")
    print(f"  Skipped:         {skip_count}")
    print(f"  Errors:          {error_count}")
    print()
    
    if error_count > 0:
        print(f"⚠️  {error_count} file(s) had errors. Please review the output above.")
        sys.exit(1)
    else:
        print(f"✓ Successfully processed all files!")
        sys.exit(0)


if __name__ == "__main__":
    main()
