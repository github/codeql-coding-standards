#!/usr/bin/env python3
"""
SARIF Results Elasticsearch Indexer

This script creates a fresh Elasticsearch index and indexes individual SARIF results
from multiple SARIF files into it. Each result from runs[].results[] becomes a
separate document in the Elasticsearch index, allowing for granular querying and
analysis of code scanning findings.

The script reads a list of SARIF file paths from a text file and bulk indexes all
results into a single Elasticsearch index. Each result document includes:
- All original SARIF result fields (ruleId, message, locations, etc.)
- Derived fields (ruleGroup, ruleLanguage) parsed from ruleId
- versionControlProvenance from run, OR derived from filename pattern
- repositoryUri (flattened from versionControlProvenance for easier querying)
- Source file tracking metadata

Repository URI Derivation from Filename:
If versionControlProvenance is missing or lacks repositoryUri, it will be derived
from SARIF filenames matching: [<lang>-<framework>_]<org>_<repo>[_<id>].sarif
Example: "cpp-misra_nasa_fprime_18795.sarif" -> "https://github.com/nasa/fprime"

This approach keeps documents minimal by indexing ONLY the result objects to avoid
Elasticsearch size limits. Tool info and automation details are NOT included.

Usage:
    python index-sarif-results-in-elasticsearch.py <sarif_files_list.txt> <elasticsearch_index_name>

Environment Variables:
    ES_LOCAL_URL          - Elasticsearch host URL (default: http://localhost:9200)
    ES_LOCAL_API_KEY      - API key for authentication (optional, enables API key auth)
    ES_LOCAL_USERNAME     - Username for basic authentication (optional)
    ES_LOCAL_PASSWORD     - Password for basic authentication (optional)
    ES_BULK_DELAY         - Delay in seconds between bulk indexing chunks (default: 1)

Requirements:
    - Python 3.11+
    - elasticsearch (pip install elasticsearch)
    - Elasticsearch instance accessible at configured host
"""

import sys
import json
import os
import time
from pathlib import Path
from elasticsearch import Elasticsearch, helpers
from elasticsearch.exceptions import ConnectionError, RequestError


def load_env_file(env_file_path):
    """Load environment variables from a .env file."""
    if not os.path.exists(env_file_path):
        return

    with open(env_file_path, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                # Handle variable substitution
                if "${" in value and "}" in value:
                    # Simple variable substitution for ${VAR} patterns
                    import re

                    def replace_var(match):
                        var_name = match.group(1)
                        return os.environ.get(var_name, match.group(0))

                    value = re.sub(r"\$\{([^}]+)\}", replace_var, value)
                os.environ[key] = value


# --- Configuration ---
DEFAULT_ELASTIC_HOST = "http://localhost:9200"
SARIF_VERSION = "2.1.0"

# Elasticsearch mapping optimized for SARIF result documents
# Minimal mapping - only results with versionControlProvenance enrichment
SARIF_MAPPING = {
    "mappings": {
        "dynamic": True,  # Allow dynamic field mapping for any unmapped fields
        "properties": {
            # Core SARIF result fields
            "ruleId": {"type": "keyword"},
            "ruleIndex": {"type": "integer"},
            "kind": {"type": "keyword"},
            "level": {"type": "keyword"},
            # Derived fields from ruleId parsing
            "ruleGroup": {"type": "keyword"},
            "ruleLanguage": {"type": "keyword"},
            # Message object
            "message": {
                "properties": {
                    "text": {"type": "text"},
                    "markdown": {"type": "text"},
                    "id": {"type": "keyword"},
                    "arguments": {"type": "keyword"},
                }
            },
            # Locations array - each result can have multiple locations
            "locations": {
                "type": "nested",
                "properties": {
                    "id": {"type": "integer"},
                    "physicalLocation": {
                        "properties": {
                            "artifactLocation": {
                                "properties": {
                                    "uri": {"type": "keyword"},
                                    "uriBaseId": {"type": "keyword"},
                                    "index": {"type": "integer"},
                                }
                            },
                            "region": {
                                "properties": {
                                    "startLine": {"type": "integer"},
                                    "startColumn": {"type": "integer"},
                                    "endLine": {"type": "integer"},
                                    "endColumn": {"type": "integer"},
                                    "charOffset": {"type": "integer"},
                                    "charLength": {"type": "integer"},
                                    "byteOffset": {"type": "integer"},
                                    "byteLength": {"type": "integer"},
                                }
                            },
                            "contextRegion": {
                                "properties": {
                                    "startLine": {"type": "integer"},
                                    "endLine": {"type": "integer"},
                                    "snippet": {"properties": {"text": {"type": "text"}}},
                                }
                            },
                        }
                    },
                    "logicalLocations": {
                        "type": "nested",
                        "properties": {
                            "name": {"type": "keyword"},
                            "fullyQualifiedName": {"type": "keyword"},
                            "decoratedName": {"type": "keyword"},
                            "kind": {"type": "keyword"},
                        },
                    },
                },
            },
            # Rule reference
            "rule": {"properties": {"id": {"type": "keyword"}, "index": {"type": "integer"}}},
            # Fingerprints for deduplication
            "partialFingerprints": {"type": "object"},
            "fingerprints": {"type": "object"},
            # Analysis and classification
            "analysisTarget": {
                "properties": {
                    "uri": {"type": "keyword"},
                    "uriBaseId": {"type": "keyword"},
                    "index": {"type": "integer"},
                }
            },
            "guid": {"type": "keyword"},
            "correlationGuid": {"type": "keyword"},
            "occurrenceCount": {"type": "integer"},
            "rank": {"type": "float"},
            "baselineState": {"type": "keyword"},
            # ONLY versionControlProvenance from run-level (minimal enrichment)
            "versionControlProvenance": {
                "type": "nested",
                "properties": {
                    "repositoryUri": {"type": "keyword"},
                    "revisionId": {"type": "keyword"},
                    "branch": {"type": "keyword"},
                    "revisionTag": {"type": "keyword"},
                },
            },
            # Flattened repositoryUri for easier querying (extracted from versionControlProvenance)
            "repositoryUri": {"type": "keyword"},
            # Metadata for tracking source SARIF file
            "_sarif_source": {
                "properties": {
                    "file_path": {"type": "keyword"},
                    "file_name": {"type": "keyword"},
                    "indexed_at": {"type": "date"},
                }
            },
        }
    },
    "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "analysis": {"analyzer": {"sarif_text": {"type": "standard", "stopwords": "_none_"}}},
    },
}
def create_elasticsearch_client(host, api_key=None, username=None, password=None):
    """Create Elasticsearch client with optional API key or basic authentication."""
    if api_key and api_key.strip():
        return Elasticsearch(
            hosts=[host],
            api_key=api_key.strip(),
            verify_certs=False,  # For local development
            ssl_show_warn=False,
        )
    elif username and password:
        return Elasticsearch(
            hosts=[host],
            basic_auth=(username, password),
            verify_certs=False,  # For local development
            ssl_show_warn=False,
        )
    else:
        return Elasticsearch(hosts=[host])


def validate_elasticsearch_connection(es_client, host):
    """Test connection to Elasticsearch server."""
    try:
        if not es_client.ping():
            print("Error: Could not connect to Elasticsearch. Please check your host and port.")
            return False
        print(f"✓ Connected to Elasticsearch at {host}")
        return True
    except ConnectionError:
        print(f"Error: Could not connect to Elasticsearch at {host}")
        print("Please ensure Elasticsearch is running and accessible.")
        return False


def validate_index_name(es_client, index_name):
    """Validate that the index doesn't already exist."""
    if es_client.indices.exists(index=index_name):
        print(f"Error: Index '{index_name}' already exists.")
        print(
            "This script requires a fresh index. Please choose a different name or delete the existing index."
        )
        return False
    print(f"✓ Index name '{index_name}' is available")
    return True


def create_index_with_mapping(es_client, index_name):
    """Create the Elasticsearch index with SARIF 2.1.0 mapping."""
    try:
        es_client.indices.create(index=index_name, body=SARIF_MAPPING)
        print(f"✓ Created index '{index_name}' with SARIF 2.1.0 mapping")
        return True
    except RequestError as e:
        print(f"Error creating index: {e}")
        return False


def read_sarif_files_list(list_file_path):
    """Read the list of SARIF files from the specified text file."""
    list_file = Path(list_file_path)
    if not list_file.exists():
        print(f"Error: SARIF files list not found at {list_file_path}")
        return None

    base_dir = list_file.parent
    sarif_files = []

    with open(list_file, "r") as f:
        for line_num, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            # Resolve relative paths relative to the list file
            sarif_path = base_dir / line
            if not sarif_path.exists():
                print(f"Warning: SARIF file not found: {sarif_path} (line {line_num})")
                continue

            if not sarif_path.suffix.lower() == ".sarif":
                print(
                    f"Warning: File does not have .sarif extension: {sarif_path} (line {line_num})"
                )
                continue

            sarif_files.append(sarif_path)

    print(f"✓ Found {len(sarif_files)} valid SARIF files to process")
    return sarif_files


def parse_rule_id(rule_id):
    """
    Parse a ruleId to extract ruleGroup and ruleLanguage.

    Examples:
    - "cpp/misra/function-like-macros-defined" -> ruleGroup="cpp/misra", ruleLanguage="cpp"
    - "c/misra/cast-between-pointer-to-object-and-non-int-arithmetic-type" -> ruleGroup="c/misra", ruleLanguage="c"
    - "py/baseline/expected-extracted-files" -> ruleGroup="py/baseline", ruleLanguage="py"
    """
    if not rule_id:
        return None, None

    parts = rule_id.split("/")
    if len(parts) < 2:
        return None, None

    # First part is the language
    rule_language = parts[0]

    # Rule group is language + first category (e.g., "cpp/misra", "py/baseline")
    if len(parts) >= 2:
        rule_group = f"{parts[0]}/{parts[1]}"
    else:
        rule_group = rule_language

    return rule_group, rule_language


def parse_repository_uri_from_filename(filename):
    """
    Parse repository URI from SARIF filename following the pattern:
    [<lang>-<framework>_]<org>_<repo>[_<id>].sarif
    
    Examples:
    - "nasa_fprime_18795.sarif" -> "https://github.com/nasa/fprime"
    - "cpp-misra_nasa_fprime_18795.sarif" -> "https://github.com/nasa/fprime"
    - "tmux_tmux.sarif" -> "https://github.com/tmux/tmux"
    
    Returns:
        str or None: The repository URI if parsing succeeds, None otherwise
    """
    # Remove .sarif extension
    name = filename.replace('.sarif', '')
    
    # Split by underscore
    parts = name.split('_')
    
    # Need at least org_repo (2 parts)
    if len(parts) < 2:
        return None
    
    # Check if first part contains a hyphen (lang-framework pattern)
    if '-' in parts[0]:
        # Pattern: lang-framework_org_repo[_id]
        # Skip the lang-framework prefix
        if len(parts) < 3:
            return None
        org = parts[1]
        repo = parts[2]
    else:
        # Pattern: org_repo[_id]
        org = parts[0]
        repo = parts[1]
    
    return f"https://github.com/{org}/{repo}"


def sarif_results_generator(sarif_files, index_name):
    """
    Generator that yields Elasticsearch bulk actions for individual SARIF results.

    For each SARIF file:
    1. Processes each run in runs[]
    2. Extracts each result from runs[].results[]
    3. Creates a separate Elasticsearch document per result
    4. Adds derived fields (ruleGroup, ruleLanguage) from ruleId parsing
    5. Enriches with versionControlProvenance from run, or derives repositoryUri from filename
    6. Adds source file tracking metadata

    Filename Pattern for Repository URI Derivation:
    - [<lang>-<framework>_]<org>_<repo>[_<id>].sarif
    - Examples: "nasa_fprime_18795.sarif" -> "https://github.com/nasa/fprime"
    - Examples: "cpp-misra_tmux_tmux.sarif" -> "https://github.com/tmux/tmux"

    This approach keeps document sizes minimal by ONLY indexing the result objects
    themselves plus minimal enrichment data, avoiding the overhead of tool info,
    automation details, and other run-level data.
    """
    from datetime import datetime

    indexed_at = datetime.utcnow().isoformat()

    total_results = 0

    for sarif_file in sarif_files:
        print(f"Processing {sarif_file.name}...")
        
        # Parse repository URI from filename
        repo_uri_from_filename = parse_repository_uri_from_filename(sarif_file.name)
        if repo_uri_from_filename:
            print(f"  → Derived repository URI: {repo_uri_from_filename}")

        try:
            with open(sarif_file, "r", encoding="utf-8") as f:
                sarif_data = json.load(f)

            # Validate SARIF version
            if sarif_data.get("version") != SARIF_VERSION:
                print(
                    f"Warning: {sarif_file.name} has version {sarif_data.get('version')}, expected {SARIF_VERSION}"
                )

            # Extract metadata from the SARIF file
            runs = sarif_data.get("runs", [])
            if not runs:
                print(f"Warning: No runs found in {sarif_file.name}")
                continue

            file_results_count = 0
            for run_index, run in enumerate(runs):
                results = run.get("results", [])
                if not results:
                    print(f"Warning: No results found in run {run_index} of {sarif_file.name}")
                    continue

                file_results_count += len(results)

                # Extract ONLY versionControlProvenance from run (minimal enrichment)
                version_control_provenance = run.get("versionControlProvenance", [])
                
                # If no versionControlProvenance in run, create from filename
                if not version_control_provenance and repo_uri_from_filename:
                    version_control_provenance = [{
                        "repositoryUri": repo_uri_from_filename
                    }]
                # If versionControlProvenance exists but missing repositoryUri, add it from filename
                elif version_control_provenance and repo_uri_from_filename:
                    # Check if repositoryUri is missing from the first entry
                    if not version_control_provenance[0].get("repositoryUri"):
                        version_control_provenance[0]["repositoryUri"] = repo_uri_from_filename

                for result_index, result in enumerate(results):
                    # Create a document that includes ONLY the result fields
                    document = dict(result)  # Copy all result fields

                    # Add derived fields from ruleId parsing
                    rule_id = document.get("ruleId")
                    if rule_id:
                        rule_group, rule_language = parse_rule_id(rule_id)
                        if rule_group:
                            document["ruleGroup"] = rule_group
                        if rule_language:
                            document["ruleLanguage"] = rule_language

                    # Add ONLY versionControlProvenance (not tool, automationDetails, etc.)
                    if version_control_provenance:
                        document["versionControlProvenance"] = version_control_provenance
                        # Also add flattened repositoryUri for easier querying
                        if version_control_provenance[0].get("repositoryUri"):
                            document["repositoryUri"] = version_control_provenance[0]["repositoryUri"]

                    # Add source file metadata
                    document["_sarif_source"] = {
                        "file_path": str(sarif_file),
                        "file_name": sarif_file.name,
                        "indexed_at": indexed_at,
                    }

                    yield {
                        "_index": index_name,
                        "_source": document,
                    }

                    total_results += 1

            print(f"  → Found {file_results_count} results in {sarif_file.name}")

        except FileNotFoundError:
            print(f"Error: SARIF file not found: {sarif_file}")
            continue
        except json.JSONDecodeError as e:
            print(f"Error: Could not decode JSON from {sarif_file}: {e}")
            continue
        except Exception as e:
            print(f"Error processing {sarif_file}: {e}")
            continue

    print(
        f"✓ Prepared {total_results} individual results for indexing from {len(sarif_files)} SARIF files"
    )


def index_sarif_files(sarif_files, index_name, host, api_key=None, username=None, password=None, bulk_delay=1):
    """
    Connect to Elasticsearch and bulk index all SARIF results with progress logging.
    
    Args:
        sarif_files: List of SARIF file paths to index
        index_name: Name of the Elasticsearch index to create
        host: Elasticsearch host URL
        api_key: Optional API key for authentication
        username: Optional username for basic auth
        password: Optional password for basic auth
        bulk_delay: Delay in seconds between bulk indexing chunks (default: 1)
    """
    es_client = create_elasticsearch_client(host, api_key, username, password)

    # Validate connection
    if not validate_elasticsearch_connection(es_client, host):
        return False

    # Validate index name
    if not validate_index_name(es_client, index_name):
        return False

    # Create index with mapping
    if not create_index_with_mapping(es_client, index_name):
        return False

    print(f"Indexing results from {len(sarif_files)} SARIF files...")
    if bulk_delay > 0:
        print(f"Bulk delay: {bulk_delay} second(s) between chunks")
    print()

    try:
        # Track progress during bulk indexing
        documents_indexed = 0
        last_progress_update = 0
        progress_interval = 100  # Update every 100 documents
        chunks_processed = 0

        def progress_callback(success, info):
            """Callback to track progress during bulk indexing."""
            nonlocal documents_indexed, last_progress_update, chunks_processed
            documents_indexed += 1
            
            # Print progress updates periodically
            if documents_indexed - last_progress_update >= progress_interval:
                print(f"  → Indexed {documents_indexed} documents so far...")
                last_progress_update = documents_indexed
            
            if not success:
                print(f"  ✗ Failed to index document: {info}")

        # Use bulk helper to index all documents with progress tracking
        print("Starting bulk indexing...")
        for success, info in helpers.streaming_bulk(
            es_client,
            sarif_results_generator(sarif_files, index_name),
            chunk_size=500,
            request_timeout=60,
            raise_on_error=False,
        ):
            progress_callback(success, info)
            
            # Check if we just completed a chunk and should sleep
            # streaming_bulk yields one result per document, so we track chunks
            if documents_indexed > 0 and documents_indexed % 500 == 0:
                chunks_processed += 1
                if bulk_delay > 0:
                    print(f"  → Sleeping {bulk_delay}s after chunk {chunks_processed}...")
                    time.sleep(bulk_delay)

        print(f"  → Indexed {documents_indexed} documents (final)")
        print()
        print("-" * 50)
        print(f"✓ Bulk indexing complete")
        print(f"✓ Total documents indexed: {documents_indexed}")
        if chunks_processed > 0:
            print(f"✓ Total chunks processed: {chunks_processed}")

        # Get final index stats to verify
        stats = es_client.indices.stats(index=index_name)
        doc_count = stats["indices"][index_name]["total"]["docs"]["count"]
        print(f"✓ Final document count in index: {doc_count}")
        
        if doc_count != documents_indexed:
            print(f"⚠ Warning: Document count mismatch (indexed: {documents_indexed}, in index: {doc_count})")

        return True

    except Exception as e:
        print(f"Error during bulk indexing: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    if len(sys.argv) != 3:
        print(f"Usage: python {sys.argv[0]} <sarif_files_list.txt> <elasticsearch_index_name>")
        print()
        print("Arguments:")
        print(
            "  sarif_files_list.txt    - Text file containing relative paths to SARIF files (one per line)"
        )
        print("  elasticsearch_index_name - Name for the new Elasticsearch index to create")
        print()
        print("Environment Variables:")
        print("  ES_LOCAL_URL            - Elasticsearch host URL (default: http://localhost:9200)")
        print("  ES_LOCAL_API_KEY        - API key for authentication (optional)")
        print("  ES_LOCAL_USERNAME       - Username for basic authentication (optional)")
        print("  ES_LOCAL_PASSWORD       - Password for basic authentication (optional)")
        print("  ES_BULK_DELAY           - Delay in seconds between bulk chunks (default: 1)")
        print()
        print("Example:")
        print(f"  python {sys.argv[0]} sarif-files.txt sarif_results_2024")
        print("  ES_LOCAL_URL=https://my-cluster.elastic.co:9243 \\")
        print("  ES_LOCAL_API_KEY=your_api_key \\")
        print("  ES_BULK_DELAY=1 \\")
        print(f"  python {sys.argv[0]} sarif-files.txt sarif_results_2024")
        sys.exit(1)

    sarif_files_list = sys.argv[1]
    index_name = sys.argv[2]

    # Load environment variables from .env file if it exists
    script_dir = Path(__file__).parent
    env_file = script_dir / "elastic-start-local" / ".env"
    load_env_file(env_file)

    # Get configuration from environment variables
    elastic_host = os.getenv("ES_LOCAL_URL", DEFAULT_ELASTIC_HOST)
    elastic_api_key = os.getenv("ES_LOCAL_API_KEY")
    elastic_username = os.getenv("ES_LOCAL_USERNAME")
    elastic_password = os.getenv("ES_LOCAL_PASSWORD")
    bulk_delay = float(os.getenv("ES_BULK_DELAY", "1"))

    # Handle variable substitution in ES_LOCAL_URL if needed
    if elastic_host and "${ES_LOCAL_PORT}" in elastic_host:
        es_local_port = os.getenv("ES_LOCAL_PORT", "9200")
        elastic_host = elastic_host.replace("${ES_LOCAL_PORT}", es_local_port)

    # Treat empty string or literal "None" as None for API key
    if elastic_api_key == "" or elastic_api_key == "None":
        elastic_api_key = None
    
    # Treat empty strings as None for username/password
    if elastic_username == "" or elastic_username == "None":
        elastic_username = None
    if elastic_password == "" or elastic_password == "None":
        elastic_password = None

    # Determine authentication method
    auth_method = "None"
    if elastic_api_key:
        auth_method = "API Key"
    elif elastic_username and elastic_password:
        auth_method = "Basic Auth (Username/Password)"
    
    print(f"SARIF Files Elasticsearch Indexer")
    print(f"==================================")
    print(f"SARIF files list: {sarif_files_list}")
    print(f"Elasticsearch index: {index_name}")
    print(f"Elasticsearch host: {elastic_host}")
    print(f"Authentication: {auth_method}")
    if bulk_delay > 0:
        print(f"Bulk delay: {bulk_delay} second(s) between chunks")
    print()

    # Read and validate SARIF files list
    sarif_files = read_sarif_files_list(sarif_files_list)
    if not sarif_files:
        print("No valid SARIF files found. Exiting.")
        sys.exit(1)

    # Index the files
    if index_sarif_files(sarif_files, index_name, elastic_host, elastic_api_key, elastic_username, elastic_password, bulk_delay):
        print(f"\n✓ Successfully created and populated index '{index_name}'")
        print(f"You can now query the index using Elasticsearch APIs or Kibana.")
        sys.exit(0)
    else:
        print(f"\n✗ Failed to create or populate index '{index_name}'")
        sys.exit(1)


if __name__ == "__main__":
    main()
