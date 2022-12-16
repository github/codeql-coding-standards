import utils
import sys
from pathlib import Path

script_path = Path(__file__)
# Add the shared modules to the path so we can import them.
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQL


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
