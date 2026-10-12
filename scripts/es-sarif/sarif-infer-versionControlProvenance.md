# sarif-infer-versionControlProvenance.py

Pre-indexing script that infers `versionControlProvenance.repositoryUri` from SARIF filenames.

## Usage

```bash
python sarif-infer-versionControlProvenance.py <sarif_files_list.txt>
```

## Purpose

Ensures SARIF files have `versionControlProvenance.repositoryUri` set before indexing into Elasticsearch. This is required for the indexing script to properly enrich results with repository information.

## File Naming Convention

Files must follow the pattern: `<language>-<framework>_<org>_<repo>.sarif`

Examples:

- `c-cert_nasa_fprime.sarif` → `https://github.com/nasa/fprime`
- `cpp-misra_bitcoin_bitcoin.sarif` → `https://github.com/bitcoin/bitcoin`
- `c-misra_zeromq_libzmq.sarif` → `https://github.com/zeromq/libzmq`

Files with exactly 2 underscores are processed; others are skipped with an error.

## Behavior

- **Modifies files in-place** - consider backing up first
- Skips files that already have `repositoryUri` set
- Only infers `repositoryUri` (not `revisionId` or `branch`)
- Adds to first run in each SARIF file

## Example

```bash
# Process all files in the list
python sarif-infer-versionControlProvenance.py mrva/sarif-files_results-1.txt

# Output:
#   [OK]   c-cert_nasa_fprime.sarif: Added repositoryUri: https://github.com/nasa/fprime
#   [SKIP] cpp-cert_nasa_fprime.sarif: Already has repositoryUri (skipped)
```
