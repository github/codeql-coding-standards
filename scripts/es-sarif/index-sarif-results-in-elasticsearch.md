# SARIF Files Elasticsearch Indexer

This script creates a fresh Elasticsearch index and indexes SARIF 2.1.0 results from multiple SARIF files into it.

## Requirements

- Python 3.11+
- SARIF files conforming to version 2.1.0 specification (such as those produced by `gh mrva`)
- Accessible URLs for running instances of Elasticsearch (aka "es") and Kibana (e.g. via `Quick Setup` below)

## Usage

```bash
python index-sarif-results-in-elasticsearch.py <sarif_files_list.txt> <elasticsearch_index_name>
```

## Input File Format

The SARIF files list should be a plain text file with one relative file path per line:

```text
output_misra-c-and-cpp-default_top-1000/solvespace/solvespace/solvespace_solvespace_18606.sarif
output_misra-c-and-cpp-default_top-1000/solvespace/solvespace/solvespace_solvespace_18607.sarif
# Comments starting with # are ignored
```

**Note**: Paths are resolved relative to the directory containing the list file.

## Quick Setup

1. **Set up Python environment:**

```bash
## Change to the directory that contains this document
cd scripts/es-sarif
bash setup-venv.sh
source .venv/bin/activate
```

1. **Set up Elasticsearch and Kibana with Docker:**

```bash
curl -fsSL https://elastic.co/start-local | sh
```

1. **Run the indexer:**

```bash
## from the `scripts/es-sarif` directory
python index-sarif-results-in-elasticsearch.py mrva/sessions/sarif-files.txt codeql-coding-standards-misra-sarif
```

The `elastic-start-local` setup provides:

- Elasticsearch at `http://localhost:9200`
- Kibana at `http://localhost:5601`
- API key stored in `elastic-start-local/.env` as `ES_LOCAL_API_KEY`

## Example Queries

Search for high-severity results:

```json
GET /codeql-coding-standards-misra-sarif/_search
{
  "query": { "term": { "level": "error" } }
}
```

Find results for a specific rule:

```json
GET /codeql-coding-standards-misra-sarif/_search  
{
  "query": { "term": { "ruleId": "CERT-C-MSC30-C" } }
}
```

## Managing Elasticsearch Services

Control the Docker services:

```bash
cd elastic-start-local
./start.sh     # Start services  
./stop.sh      # Stop services
./uninstall.sh # Remove everything (deletes all data)
```
