from contextlib import redirect_stdout
from pathlib import Path
from codeqlvalidation import CodeQLValidationSummary
from error import failure
import re
import sys

script_path = Path(__file__)
# Add the shared modules to the path so we can import them.
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQLError


if __name__ == '__main__':
    failure("Error: this Python module does not support standalone execution!")


class DeviationsSummary:
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

        deviations_path = repo_root.joinpath(
            'cpp', 'common', 'src', 'codingstandards', 'cpp', 'deviations')

        queries = ['ListDeviationRecords.ql', 'InvalidDeviationRecords.ql',
                   'ListDeviationPermits.ql', 'InvalidDeviationPermits.ql']

        query_paths = map(deviations_path.joinpath, queries)

        try:
            # Cleanup database cache to prevent potential cache issue
            self.codeql_summary.codeql.cleanup(database_path, mode="brutal")
            # Get a list of deviations
            print("Running the deviation query...")
            self.codeql_summary.codeql.run_queries(
                database_path, *query_paths, no_rerun=True)

            print("Decoding deviation query results")

            def camel_to_underscore(s):
                return re.sub(
                    r'([A-Z])', lambda m: f"_{m.group(1).lower()}", s)
            for query in queries:
                if query.startswith("List"):
                    decoded_results = self.codeql_summary.codeql.decode_results(
                        database_path, deviations_path.joinpath(query), no_titles=True)
                    key = camel_to_underscore(
                        query).removeprefix('_list_').removesuffix('.ql')
                    setattr(self, key, decoded_results)
                elif query.startswith("Invalid"):
                    decoded_results = self.codeql_summary.codeql.decode_results(
                        database_path, deviations_path.joinpath(query), entities='url,string', no_titles=True)
                    key = camel_to_underscore(
                        query).removeprefix('_').removesuffix('.ql')
                    setattr(self, key, decoded_results)
                else:
                    failure(
                        f"Error: Don't know how to decode query results for {query}")
        except CodeQLError as err:
            failure("Error: Failed to run deviation query", err)


def generate_deviations_report(database_path, repo_root, output_directory):
    """Print a "deviations report"."""

    deviations_summary = DeviationsSummary(database_path, repo_root)
    deviations_report_path = output_directory.joinpath(
        "deviations_report.md")
    try:
        deviations_report_file = open(
            deviations_report_path, "w")
    except PermissionError:
        failure(
            f"Error: No permission to write to the output file located at '{deviations_report_path}'")
    else:
        with deviations_report_file:
            # Print to report file, rather than stdout
            with redirect_stdout(deviations_report_file):
                print("# Deviations report")
                print()
                print("## Overview")
                print()
                print(
                    f" - Report generated with {'supported' if deviations_summary.codeql_summary.supported_cli else 'unsupported'} CodeQL version {deviations_summary.codeql_summary.codeql.version}")
                print(
                    f" - Database path: {str(deviations_summary.database_path.resolve())}")
                number_of_deviation_records = len(
                    deviations_summary.deviation_records)
                number_of_invalid_deviation_records = len(
                    deviations_summary.invalid_deviation_records)
                print(
                    f" - { number_of_deviation_records } valid deviation records and {number_of_invalid_deviation_records} invalid deviation records found in the database")
                print(
                    f" - { len(deviations_summary.deviation_permits) } valid deviation permits and {len(deviations_summary.invalid_deviation_permits)} invalid deviation permits found in the database")
                print()
                print("## Deviation Records")
                print()
                print(
                    "| Rule ID | Query ID | Automated Scope | Scope | Justification | Background | Requirements")
                print(
                    "| --- | --- | --- | --- | --- | --- | --- |")
                for deviation_record in deviations_summary.deviation_records:
                    rule_id = deviation_record[0]
                    query_id = deviation_record[1]
                    automated_scope = deviation_record[2]
                    scope = deviation_record[3].replace('\n', '<br />')
                    justification = deviation_record[4].replace('\n', '<br />')
                    background = deviation_record[5].replace('\n', '<br />')
                    requirements = deviation_record[6].replace('\n', '<br />')
                    print(
                        f"| { rule_id } | { query_id } | { automated_scope } |  { scope } |  { justification } |  { background } |  { requirements } | ")
                print()
                print("## Invalid Deviation Records")
                print("| Path | Reason |")
                print("| --- | --- |")
                for invalid_deviation_record in deviations_summary.invalid_deviation_records:
                    location = invalid_deviation_record[1].split(':', 2)[2]
                    path, reason = map(
                        str.strip, invalid_deviation_record[2].split(':'))
                    print(f"| {path}:{location} | {reason} |")
                print()
                print("## Deviation Permits")
                print()
                print(
                    "| Permit ID | Rule ID | Query ID | Automated Scope | Scope | Justification | Background | Requirements")
                print(
                    "| --- | --- | --- | --- | --- | --- | --- | --- |")
                for deviation_permit in deviations_summary.deviation_permits:
                    permit_id = deviation_permit[0]
                    rule_id = deviation_permit[1]
                    query_id = deviation_permit[2]
                    automated_scope = deviation_permit[3]
                    scope = deviation_permit[4].replace('\n', '<br />')
                    justification = deviation_permit[5].replace('\n', '<br />')
                    background = deviation_permit[6].replace('\n', '<br />')
                    requirements = deviation_permit[7].replace('\n', '<br />')
                    print(
                        f"| { permit_id } | { rule_id } | { query_id } | { automated_scope } |  { scope } |  { justification } |  { background } |  { requirements } | ")
                print()
                print("## Invalid Deviation Permits")
                print("| Path | Reason |")
                print("| --- | --- |")
                for invalid_deviation_permit in deviations_summary.invalid_deviation_permits:
                    location = invalid_deviation_permit[1].split(':', 2)[2]
                    path, reason = map(
                        str.strip, invalid_deviation_permit[2].split(':'))
                    print(f"| {path}:{location} | {reason} |")
