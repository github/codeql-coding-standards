import pytest
from pathlib import Path
import sys
from guideline_recategorizations import generate_guideline_recategorizations_report
from deviations import generate_deviations_report

script_path = Path(__file__)
# Add the shared modules to the path so we can import them.
sys.path.append(str(script_path.parent.parent / 'shared'))
from codeql import CodeQL, CodeQLError

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
SCRIPTS_DIR = REPO_ROOT / 'scripts'
TEST_DATA_DIR = Path(__file__).resolve().parent / 'test-data'

def test_guideline_recategorizations_report(tmp_path):

    db_path = tmp_path / 'test-db'
    src_root = TEST_DATA_DIR / 'guideline-recategorizations'
    codeql = CodeQL()

    compile_src_command = "clang -fsyntax-only test.cpp"
    index_coding_standards_config_command = f"python3 {SCRIPTS_DIR}/configuration/process_coding_standards_config.py"

    try:
        codeql.create_database(src_root, 'cpp', db_path, compile_src_command, index_coding_standards_config_command)
    except CodeQLError as err:
        print(err.stdout)
        print(err.stderr)
        raise err

    generate_guideline_recategorizations_report(db_path, REPO_ROOT, tmp_path)

    expected = (TEST_DATA_DIR / 'guideline-recategorizations' / 'guideline_recategorizations_report.md.expected').read_text()
    expected = expected.replace("$codeql-version$", codeql.version).replace("$database-path$", str(db_path))
    actual = (tmp_path / "guideline_recategorizations_report.md").read_text()

    assert(expected == actual)

def test_deviations_report(tmp_path):

    db_path = tmp_path / 'test-db'
    src_root = TEST_DATA_DIR / 'deviations'
    codeql = CodeQL()

    compile_src_command = "clang -fsyntax-only test.cpp"
    index_coding_standards_config_command = f"python3 {SCRIPTS_DIR}/configuration/process_coding_standards_config.py"

    try:
        codeql.create_database(src_root, 'cpp', db_path, compile_src_command, index_coding_standards_config_command)
    except CodeQLError as err:
        print(err.stdout)
        print(err.stderr)
        raise err

    generate_deviations_report(db_path, REPO_ROOT, tmp_path)

    expected = (TEST_DATA_DIR / 'deviations' / 'deviations_report.md.expected').read_text()
    expected = expected.replace("$codeql-version$", codeql.version).replace("$database-path$", str(db_path))
    actual = (tmp_path / "deviations_report.md").read_text()

    assert(expected == actual)