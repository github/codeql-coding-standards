import diagnostics
import deviations
import guideline_recategorizations
from pathlib import Path
import sys
import utils

help_statement = """
Usage: {script_name} database-dir sarif-results-file output_directory

A tool for producing a number of analysis reports for the given analysis.
"""

if (len(sys.argv) == 2 and sys.argv[1] == "--help"):
    print(help_statement.format(script_name=sys.argv[0]))
    sys.exit(0)

if not len(sys.argv) == 4:
    print("Error: incorrect number of arguments", file=sys.stderr)
    print("Usage: " +
          sys.argv[0] + " database-dir sarif-results-file output_directory", file=sys.stderr)
    sys.exit(1)

repo_root = Path(__file__).parent.parent.parent

database_path = Path(sys.argv[1])
# Verify that the database exists
if not database_path.exists():
    print(
        f"Error: database { database_path } does not exist.", file=sys.stderr)
    sys.exit(1)

sarif_results_file_path = Path(sys.argv[2])
# Verify that the SARIF file exists
if not sarif_results_file_path.exists():
    print(
        f"Error: SARIF file at { sarif_results_file_path } does not exist.", file=sys.stderr)
    sys.exit(1)

output_directory = Path(sys.argv[3])
if output_directory.exists():
    print(
        f"Error: Output directory at { output_directory } already exists.", file=sys.stderr)
    sys.exit(1)

# Create the output directory
output_directory.mkdir(parents=True)

# Run some queries over the database to gather diagnostics
diagnostics_results = diagnostics.DiagnosticsSummary(database_path, repo_root)
# Generate a diagnostics result file
diagnostics.generate_diagnostics_file(output_directory, diagnostics_results)

deviations.generate_deviations_report(
    database_path, repo_root, output_directory)

guideline_recategorizations.generate_guideline_recategorizations_report(database_path, repo_root, output_directory)

# Load the SARIF file and generate a results summary
sarif_results_summary = utils.CodingStandardsResultSummary(
    sarif_results_file_path)
# Generate the GCS from the results summary
utils.generate_guideline_compliance_summary(
    output_directory, sarif_results_summary)

print(f"Wrote analysis reports to { output_directory }.", file=sys.stderr)
