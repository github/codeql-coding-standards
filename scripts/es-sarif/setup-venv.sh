#!/bin/bash
# Setup script for SARIF analysis environment (MRVA + Elasticsearch indexing)

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

echo "SARIF Analysis Environment Setup"
echo "================================"
echo "Setting up Python virtual environment in: $VENV_DIR"
echo

# Check Python 3.11 availability
if ! command -v python3.11 &> /dev/null; then
    echo "Error: Python 3.11 is required but not found"
    echo "Please install Python 3.11 first"
    exit 1
fi

python_version=$(python3.11 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "Python version: $python_version"

# Create virtual environment
echo "Creating virtual environment with Python 3.11..."
python3.11 -m venv "$VENV_DIR"

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install -r "$SCRIPT_DIR/requirements.txt"

# Verify installation
echo
echo "Verifying installation..."
python -c "import elasticsearch; print(f'✓ Elasticsearch client version: {elasticsearch.__version__}')"

echo
echo "✓ Setup complete!"
echo
echo "Source the python virtual environment within scripts/es-sarif:"
echo "  source .venv/bin/activate"
echo
echo "To run MRVA for a query suite:"
echo "  python run-gh-mrva-for-query-suite.py --query-suite codeql/misra-cpp-coding-standards@2.50.0 --output-base-dir ./mrva --session-prefix t1-misra-cpp-default --language cpp --repository-list top_1000"
echo
echo "To run the indexer:"
echo "  python index-sarif-results-in-elasticsearch.py ../../mrva/sessions/sarif-files.txt sarif_results_2024"
echo
echo "To deactivate the virtual environment:"
echo "  deactivate"