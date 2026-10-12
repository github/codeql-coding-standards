# MRVA Query Suite Runner

This script automates the execution of Multi-Repository Vulnerability Analysis (MRVA) sessions for all queries in a CodeQL query suite. It manages the complete lifecycle: submission, monitoring, and downloading results.

## Features

- **Automated Query Resolution**: Uses CodeQL CLI to resolve all queries in a suite
- **Concurrent Session Management**: Submits and monitors multiple MRVA sessions simultaneously  
- **State Persistence**: Saves progress to resume interrupted runs
- **Status Monitoring**: Periodically checks session status and downloads completed results
- **Error Handling**: Robust error handling with detailed logging

## Prerequisites

1. **GitHub CLI with MRVA extension**:

   ```bash
   gh extension install github/gh-mrva
   ```

2. **CodeQL CLI**: Must be available in your PATH

   ```bash
   codeql --version
   ```

3. **Authentication**: GitHub CLI must be authenticated with appropriate permissions

## Usage

### Basic Usage

```bash
python run-gh-mrva-for-query-suite.py \
  --query-suite codeql/misra-cpp-coding-standards@2.50.0 \
  --output-base-dir ./mrva/sessions \
  --session-prefix t1-misra-cpp-default \
  --language cpp \
  --repository-list cpp_top_1000
```

### With Custom Concurrency

```bash
python run-gh-mrva-for-query-suite.py \
  --query-suite codeql/misra-c-coding-standards@2.50.0 \
  --output-base-dir ./mrva/sessions \
  --session-prefix t1-misra-c-default \
  --language c \
  --repository-list cpp_top_1000 \
  --max-concurrent 10 \
  --check-interval 600
```

## Arguments

### Required Arguments

- `--query-suite`: CodeQL query suite to analyze (e.g., `codeql/misra-cpp-coding-standards@2.50.0`)
- `--output-base-dir`: Base directory for output files and session state
- `--session-prefix`: Prefix for MRVA session names (e.g., `t1-misra-cpp-default`)
- `--language`: Programming language (`cpp`, `c`, `java`, `javascript`, `python`, `go`, `csharp`)
- `--repository-list`: Repository list for MRVA analysis (e.g., `top_1000`)

### Optional Arguments

- `--max-concurrent`: Maximum concurrent MRVA sessions (default: 20)
- `--check-interval`: Status check interval in seconds (default: 300)

## Output Structure

The script creates the following output structure:

```text
<output-base-dir>/
├── <session-prefix>_state.json     # Session state and progress
└── sessions/                       # Downloaded SARIF results
    ├── <session-prefix>-query1/
    │   ├── owner1_repo1_12345.sarif
    │   ├── owner2_repo2_12346.sarif
    │   └── ...
    ├── <session-prefix>-query2/
    │   ├── owner1_repo1_12347.sarif
    │   └── ...
    └── ...
```

## State Management

The script maintains a state file (`<session-prefix>_state.json`) that tracks:

- Query resolution and session mapping
- Submission timestamps
- Current status of each session
- Completion timestamps
- Download locations
- Error messages

This allows the script to be safely interrupted and resumed.

## Session Naming Convention

MRVA sessions are named using the pattern:

```text
<session-prefix>-<sanitized-query-name>
```

For example:

- Query: `cpp/misra/function-like-macros-defined.ql`
- Session: `t1-misra-cpp-default-function-like-macros-defined`

## Workflow

1. **Query Resolution**: Resolves all `.ql` files in the specified query suite
2. **Initial Submission**: Submits up to `max-concurrent` sessions
3. **Monitoring Loop**:
   - Check status of active sessions every `check-interval` seconds
   - Download results for completed sessions
   - Submit new sessions when capacity is available
   - Continue until all queries are processed
4. **Completion**: Provides final summary of results

## Status Tracking

Sessions progress through these states:

- `not_started`: Session not yet submitted
- `submitted`: Session submitted to MRVA
- `in_progress`: Session is running
- `completed`: Session finished successfully
- `failed`: Session encountered an error

## Integration with Elasticsearch

After running this script, you can index the SARIF results into Elasticsearch using the companion script:

```bash
# Create a file list of all SARIF files
find ./mrva/sessions -name "*.sarif" > results/misra/sarif-files.txt

# Index results into Elasticsearch
python index-sarif-results-in-elasticsearch.py results/misra/sarif-files.txt misra-mrva-results-top-1000-repos
```

## Error Handling

- **Network Issues**: Retries status checks and downloads
- **API Rate Limits**: Respects GitHub API limits with appropriate delays
- **Partial Failures**: Continues processing other sessions if individual sessions fail
- **Interruption**: Saves state and allows for clean resumption

## Monitoring

The script provides real-time status updates:

```text
Status: {'submitted': 5, 'in_progress': 10, 'completed': 25, 'failed': 1} | Active: 15 | Remaining: 12
Waiting 300 seconds before next check...
```

## Troubleshooting

### Common Issues

1. **MRVA Extension Not Found**:

   ```bash
   gh extension install github/gh-mrva
   ```

2. **CodeQL Not in PATH**:

   ```bash
   export PATH="/path/to/codeql:$PATH"
   ```

3. **Authentication Issues**:

   ```bash
   gh auth login
   ```

4. **Session Limits**: Reduce `--max-concurrent` if hitting API limits

### Logs and Debugging

- Session state is saved in `<session-prefix>_state.json`
- Check GitHub CLI logs: `gh mrva list --json`
- Verify query resolution: `codeql resolve queries -- <query-suite>`
