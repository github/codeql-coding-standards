import subprocess
import json
from json.decoder import JSONDecodeError
from sys import stderr
import tempfile
import utils
import yaml
import csv
from pathlib import Path


class CodeQLError(Exception):
    def __init__(self, reason, stdout=None, stderr=None, returncode=None):
        self.reason = reason
        self.stdout = stdout
        self.stderr = stderr
        self.returncode = returncode

    def __str__(self):
        return repr(self.reason)


class CodeQL():
    def __init__(self):
        codeql_result = subprocess.run(
            ["codeql", "version", "--format=json"], capture_output=True)
        if not codeql_result.returncode == 0:
            raise CodeQLError('CodeQL is not available on PATH!',
                              returncode=codeql_result.returncode)

        codeql_output = codeql_result.stdout.decode('utf-8')

        try:
            codeql_version_info = json.loads(codeql_output)
            self.version = codeql_version_info['version']
        except JSONDecodeError as e:
            raise CodeQLError(
                f"Failed to retrieve codeql version information with error: {e.msg}")

    def __build_command_options(self, **options):
        command_options = []
        for key, value in options.items():
            command_options.append(f"--{key.replace('_', '-')}")
            if not isinstance(value, bool):
                command_options.append(str(value))
        return command_options

    def cleanup(self, database_path, mode="normal"):
        if isinstance(database_path, str):
            database_path = Path(database_path)

        if not database_path.exists():
            raise CodeQLError(f"Database '{database_path}' not found!")

        supported_modes = ["brutal", "normal", "light"]
        if not mode in supported_modes:
            raise CodeQLError(
                f"Invalid cleanup mode {mode}, expecting one of {' '.join(supported_modes)}")

        result = subprocess.run(
            ["codeql", "database", "cleanup", "--mode", mode, str(database_path)], capture_output=True)
        if not result.returncode == 0:
            raise CodeQLError(
                f"Unable to cleanup database {database_path}", stdout=result.stdout, stderr=result.stderr, returncode=result.returncode)

    def run_queries(self, database_path, *queries, **options):
        if isinstance(database_path, str):
            database_path = Path(database_path)
        database_path = database_path.resolve()

        command_options = self.__build_command_options(**options)

        command = ["codeql", "database", "run-queries"] + command_options
        command.append(str(database_path))
        command.extend(map(str, queries))

        for query in queries:
            if isinstance(query, str):
                query = Path(query)

            if not query.exists():
                raise CodeQLError(f"{query} not found!")

        codeql_result = subprocess.run(command, capture_output=True)
        if not codeql_result.returncode == 0:
            raise CodeQLError(
                f"Unable to run queries: {','.join((map(str, queries)))}!", stdout=codeql_result.stdout, stderr=codeql_result.stderr, returncode=codeql_result.returncode)

    def resolve_qlpack_path(self, query):
        if isinstance(query, str):
            query = Path(query)

        for parent in Path(query).parents:
            qlpack = parent.joinpath('qlpack.yml')
            if qlpack.exists():
                return qlpack
        raise CodeQLError(f"Unable to find QL pack for {query}")

    def get_qlpack(self, qlpack_path):
        if qlpack_path.name != 'qlpack.yml':
            raise CodeQLError(
                f"Invalid QLPack path: {qlpack_path}, it is not ending with 'qlpack.yml'!")
        with qlpack_path.open() as f:
            return yaml.safe_load(f)

    def decode_results(self, database_path, query_path, **options):
        if isinstance(database_path, str):
            database_path = Path(database_path)
        if isinstance(query_path, str):
            query_path = Path(query_path)

        qlpack_path = self.resolve_qlpack_path(query_path)
        qlpack = self.get_qlpack(qlpack_path)
        relative_query_path = query_path.relative_to(qlpack_path.parent)
        bqrs_path = database_path.joinpath("results", qlpack['name'], relative_query_path).with_suffix(
            ".bqrs")

        command = ["codeql", "bqrs", "decode"]
        options['format'] = 'csv'

        with tempfile.TemporaryDirectory() as temp_name:
            temp_file = Path(temp_name).joinpath(
                Path(query_path).with_suffix('.tmp').name)

            options['output'] = str(temp_file)
            command_options = self.__build_command_options(**options)

            command.extend(command_options)
            command.append(str(bqrs_path))

            result = subprocess.run(command, capture_output=True)
            if not result.returncode == 0:
                raise CodeQLError(
                    f"Could not read the output of the query {query_path}", stdout=result.stdout, stderr=result.stderr, returncode=result.returncode)
            with open(temp_file) as tmp:
                return list(csv.reader(tmp))


class CodeQLValidationSummary():
    def __init__(self):
        """Validate that a compatible version of the CodeQL CLI is on the path."""

        self.codeql = CodeQL()

        # Determine our supported environments
        supported_environments = utils.load_supported_environments()

        self.supported_cli = False
        for supported_environment in supported_environments:
            if supported_environment["codeql_cli"] == self.codeql.version:
                self.supported_cli = True
