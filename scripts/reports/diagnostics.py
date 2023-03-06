from contextlib import redirect_stdout
from pathlib import Path
from codeqlvalidation import CodeQLValidationSummary
from error import failure
import sys

script_path = Path(__file__)
# Add the shared modules to the path so we can import them.
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQLError

class DiagnosticsSummary:
    def __init__(self, database_path, repo_root):
        if isinstance(database_path, str):
            database_path = Path(database_path)
        if isinstance(repo_root, str):
            repo_root = Path(repo_root)

        # Convert to absolute paths for reporting
        self.database_path = database_path.resolve()
        repo_root = repo_root.resolve()

        try:
            self.codeql_summary = CodeQLValidationSummary()
        except CodeQLError as err:
            failure("Error: Unable to retrieve CodeQL validation summary", err)

        extraction_error_query_path = Path(
            'Diagnostics', 'ExtractionErrors.ql')
        successfully_extracted_files_path = Path(
            'Diagnostics', 'SuccessfullyExtractedFiles.ql')

        queries = [

            repo_root.joinpath('cpp', 'report', 'src',
                               extraction_error_query_path),
            repo_root.joinpath('cpp', 'report', 'src',
                               successfully_extracted_files_path)
        ]

        try:
            # Cleanup database cache to prevent potential cache issue
            self.codeql_summary.codeql.cleanup(database_path, mode="brutal")
            # Run all the diagnostics over the database
            print("Running the diagnostic queries...")
            self.codeql_summary.codeql.run_queries(
                database_path, *queries, no_rerun=True)

            print("Decoding diagnostic query results")
            self.extraction_errors = self.codeql_summary.codeql.decode_results(
                database_path, queries[0], entities="string,url", no_titles=True)
            self.successfully_extracted_files = self.codeql_summary.codeql.decode_results(
                database_path, queries[1], entities="string,url", no_titles=True)
        except CodeQLError as err:
            failure("Error: Could not run diagnostic queries", err)


def generate_diagnostics_file(output_directory, diagnostics_summary):
    """Print a "database integrity report"."""
    database_integrity_report_path = output_directory.joinpath(
        "database_integrity_report.md")
    try:
        database_integrity_report_file = open(
            database_integrity_report_path, "w")
    except PermissionError:
        failure(
            "Error: No permission to write to the output file located at '{database_integrity_report_path}'")
    else:
        with database_integrity_report_file:
            # Print to report file, rather than stdout
            with redirect_stdout(database_integrity_report_file):
                print("# Database integrity report")
                print()
                print("## Overview")
                print()
                print(
                    f" - Report generated with {'supported' if diagnostics_summary.codeql_summary.supported_cli else 'unsupported'} CodeQL version {diagnostics_summary.codeql_summary.codeql.version}")
                print(
                    f" - Database path: {diagnostics_summary.database_path}")
                number_of_errors = len(diagnostics_summary.extraction_errors)
                number_of_successfully_extracted_files = len(
                    diagnostics_summary.successfully_extracted_files)
                print(f" - { number_of_errors } errors reported")
                print(
                    f" - { number_of_successfully_extracted_files } successfully analyzed files")
                print()
                print("## Extraction errors")
                print()
                print(f"| Error summary | Location | Description |")
                print(f"| ------------- | -------- | ----------- |")
                for extraction_error in diagnostics_summary.extraction_errors:
                    description = extraction_error[2].replace('\n', '<br />')
                    print(
                        f"| { extraction_error[0] } | { extraction_error[1] } | { description } | ")

                print()
                print("## Successfully extracted files")
                print()
                for successfully_extracted_file in diagnostics_summary.successfully_extracted_files:
                    print(f" - { successfully_extracted_file[0] }")
