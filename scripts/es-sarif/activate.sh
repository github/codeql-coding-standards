#!/bin/bash
# Convenience script to activate the SARIF Elasticsearch Indexer environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Run setup.sh first."
    exit 1
fi

echo "Activating SARIF Elasticsearch Indexer environment..."
echo "Python version: $($VENV_DIR/bin/python --version)"
echo "To deactivate, run: deactivate"
echo

# Start a new shell with the virtual environment activated
exec bash --rcfile <(echo "source $VENV_DIR/bin/activate; PS1='(es-sarif) \u@\h:\w\$ '")
