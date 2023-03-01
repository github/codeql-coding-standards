from contextlib import redirect_stdout
from pathlib import Path
from codeqlvalidation import CodeQLValidationSummary
from error import failure
import sys

script_path = Path(__file__)
# Add the shared modules to the path so we can import them.
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQLError


if __name__ == '__main__':
    failure("Error: this Python module does not support standalone execution!")


class GuidelineRecategorizationsSummary:
    def __init__(self, database_path, repo_root):
        if isinstance(database_path, str):
            database_path = Path(database_path)
        if isinstance(repo_root, str):
            repo_root = Path(repo_root)

        self.database_path = database_path
        try:
            self.codeql_summary = CodeQLValidationSummary()
        except CodeQLError as err:
            failure("Error: Could not initialize CodeQL", err)

        guideline_recategorizations_path = repo_root.joinpath(
            'cpp', 'common', 'src', 'codingstandards', 'cpp', 'guideline_recategorizations')

        queries = ['ListGuidelineRecategorizations.ql', 'InvalidGuidelineRecategorizations.ql']

        query_paths = map(guideline_recategorizations_path.joinpath, queries)

        try:
            # Cleanup database cache to prevent potential cache issue
            self.codeql_summary.codeql.cleanup(database_path, mode="brutal")
            # Get a list of guideline recategorizations
            print("Running the guideline recategorizations queries...")
            self.codeql_summary.codeql.run_queries(
                database_path, *query_paths, no_rerun=True)

            print("Decoding guideline recategorizations queries results")

            for query in queries:
                if query.startswith("List"):
                    decoded_results = self.codeql_summary.codeql.decode_results(
                        database_path, guideline_recategorizations_path.joinpath(query), no_titles=True)
                    self.guideline_recategorizations = decoded_results
                elif query.startswith("Invalid"):
                    decoded_results = self.codeql_summary.codeql.decode_results(
                        database_path, guideline_recategorizations_path.joinpath(query), entities='url,string', no_titles=True)
                    self.invalid_guideline_recategorizations = decoded_results
                else:
                    failure(
                        f"Error: Don't know how to decode query results for {query}")
        except CodeQLError as err:
            failure("Error: Failed to run guideline recategorizations queries", err)


def generate_guideline_recategorizations_report(database_path, repo_root, output_directory):
    """Print a "guideline recategorizations report"."""

    guideline_recategorizations_summary = GuidelineRecategorizationsSummary(database_path, repo_root)
    guideline_recategorizations_report_path = output_directory.joinpath(
        "guideline_recategorizations_report.md")
    try:
        guideline_recategorizations_report_file = open(
            guideline_recategorizations_report_path, "w")
    except PermissionError:
        failure(
            f"Error: No permission to write to the output file located at '{guideline_recategorizations_report_path}'")
    else:
        with guideline_recategorizations_report_file:
            # Print to report file, rather than stdout
            with redirect_stdout(guideline_recategorizations_report_file):
                print("# Guideline recategorizations report")
                print()
                print("## Overview")
                print()
                print(
                    f" - Report generated with {'supported' if guideline_recategorizations_summary.codeql_summary.supported_cli else 'unsupported'} CodeQL version {guideline_recategorizations_summary.codeql_summary.codeql.version}")
                print(
                    f" - Database path: {str(guideline_recategorizations_summary.database_path.resolve())}")
                number_of_guideline_recategorizations = len(
                    guideline_recategorizations_summary.guideline_recategorizations)
                number_of_invalid_guideline_recategorizations = len(
                    guideline_recategorizations_summary.invalid_guideline_recategorizations)
                print(
                    f" - { number_of_guideline_recategorizations } applicable guideline recategorizations and {number_of_invalid_guideline_recategorizations} invalid guideline recategorizations found in the database")
                print()
                print("## Guideline recategorizations")
                print()
                print(
                    "| Rule ID | Category | Recategorized category")
                print(
                    "| --- | --- | --- |")
                for guideline_recategorization in guideline_recategorizations_summary.guideline_recategorizations:
                    rule_id = guideline_recategorization[0]
                    category = guideline_recategorization[1]
                    recategorized_category = guideline_recategorization[2]
                    print(
                        f"| { rule_id } | { category } | { recategorized_category } | ")
                print()
                print("## Invalid guideline recategorizations")
                print("| Path | Reason |")
                print("| --- | --- |")
                for invalid_guideline_recategorization in guideline_recategorizations_summary.invalid_guideline_recategorizations:
                    location = invalid_guideline_recategorization[1].split(':', 2)[2]
                    path, reason = map(
                        str.strip, invalid_guideline_recategorization[2].split(':'))
                    print(f"| {path}:{location} | {reason} |")
