#!/bin/bash

# Script for generating a draft release for the CodeQL Coding Standards repository, for the given branch.

set -o errexit
set -o nounset

BRANCH="$1"
VERSION="$2"

if [[ ! $BRANCH == rc/* ]]; then
   echo "$BRANCH is not an rc branch of the form rc/<version>"
   exit 1
fi

if [ -z "$VERSION" ]; then
  VERSION="${BRANCH#rc/}"
  echo "Version not set explicitly; auto-detecting $VERSION."
fi

COMMIT_SHA="$(git rev-parse $BRANCH)"

echo "Creating draft release for $VERSION from $BRANCH at commit $COMMIT_SHA."

echo "Identifying code-scanning-pack-gen.yml"
CODE_SCANNING_PACK_GEN_RUN_ID=$(gh api -X GET repos/github/codeql-coding-standards/actions/workflows/code-scanning-pack-gen.yml/runs -F branch="$BRANCH" -F event="push" -F conclusion="success" --jq "first(.workflow_runs.[] | select(.head_sha==\"$COMMIT_SHA\") | .id)")
if [ -z "$CODE_SCANNING_PACK_GEN_RUN_ID" ]; then
  echo "No successful run of the code-scanning-pack-gen.yml file for $COMMIT_SHA on branch $BRANCH."
  exit 1
fi

# Create a temp directory to store the artifacts in
TEMP_DIR="$(mktemp -d)"

echo "Identified code-scanning-pack-gen.yml run id: $CODE_SCANNING_PACK_GEN_RUN_ID"

echo "Fetching Code Scanning pack"
CODE_SCANNING_ARTIFACT_NAME="code-scanning-cpp-query-pack.zip"
CODE_SCANNING_VERSIONED_ARTIFACT_NAME="code-scanning-cpp-query-pack-$VERSION.zip"
gh run download $CODE_SCANNING_PACK_GEN_RUN_ID -n "$CODE_SCANNING_ARTIFACT_NAME"
mv "$CODE_SCANNING_ARTIFACT_NAME" "$TEMP_DIR/$CODE_SCANNING_VERSIONED_ARTIFACT_NAME"

echo "Generating release notes."
python3 scripts/release/generate_release_notes.py > "$TEMP_DIR/release_notes_$VERSION.md"
python3 scripts/release/create_supported_rules_list.py > "$TEMP_DIR/supported_rules_list_$VERSION.md"
python3 scripts/release/create_supported_rules_list.py --csv > "$TEMP_DIR/supported_rules_list_$VERSION.csv"

echo "Copy Docs to Artifact Directory"
cp docs/user_manual.md "$TEMP_DIR/user_manual_$VERSION.md"

echo "Generating Checksums"
sha256sum $TEMP_DIR/* > "$TEMP_DIR/checksums.txt"

gh release create "v$VERSION" -d --target "$BRANCH" -F "$TEMP_DIR/release_notes_$VERSION.md" -t "v$VERSION" "$TEMP_DIR/$CODE_SCANNING_VERSIONED_ARTIFACT_NAME" "$TEMP_DIR/supported_rules_list_$VERSION.md" "$TEMP_DIR/checksums.txt" "$TEMP_DIR/supported_rules_list_$VERSION.csv" "$TEMP_DIR/user_manual_$VERSION.md"

curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $INTEGRATION_TESTING_ACCESS_TOKEN" \
  https://api.github.com/repos/coding-standards-integration-testing/integration-testing-production/actions/workflows/$WORKFLOW_ID/dispatches \
  -d '{"ref":"refs/heads/main", "inputs": { "release_version_tag":"'"$VERSION"'", "codeql_analysis_threads":"'"$CODEQL_ANALYSIS_THREADS"'", "aws_ec2_instance_type":"'"$AWS_EC2_INSTANCE_TYPE"'" }}'
