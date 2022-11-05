import pytest
import recategorize
from pathlib import Path
import argparse
import sys

TEST_DATA_DIR = Path(__file__).resolve().parent / 'test-data'

class TestsInputs:
    def test_invalid_codeql_config(self):
        with pytest.raises(SystemExit):
            recategorize.main(argparse.Namespace(
                coding_standards_schema_file= Path.cwd(),
                sarif_schema_file= Path.cwd(),
                coding_standards_config_file= TEST_DATA_DIR / 'invalid-coding-standards-config.yml'
            ))

    def test_valid_codeql_config(self):
        with (TEST_DATA_DIR / 'valid-sarif.json').open(mode='r') as sarif_in:
            recategorize.main(argparse.Namespace(
                coding_standards_schema_file= Path.cwd(),
                sarif_schema_file= Path.cwd(),
                coding_standards_config_file= TEST_DATA_DIR / 'valid-coding-standards-config.yml',
                sarif_in=sarif_in,
                sarif_out=sys.stdout,
                dump_json_patch=None
            ))

    def test_invalid_sarif_file(self):
        with pytest.raises(SystemExit):
            with (TEST_DATA_DIR / 'invalid-sarif.json').open(mode='r') as sarif_in:
                recategorize.main(argparse.Namespace(
                    coding_standards_schema_file= Path.cwd(),
                    sarif_schema_file= Path.cwd(),
                    coding_standards_config_file= TEST_DATA_DIR / 'valid-coding-standards-config.yml',
                    sarif_in=sarif_in
                ))
    
    def test_valid_sarif_file(self):
        with (TEST_DATA_DIR / 'valid-sarif.json').open(mode='r') as sarif_in:
            recategorize.main(argparse.Namespace(
                coding_standards_schema_file= Path.cwd(),
                sarif_schema_file= Path.cwd(),
                coding_standards_config_file= TEST_DATA_DIR / 'valid-coding-standards-config.yml',
                sarif_in=sarif_in,
                sarif_out=sys.stdout,
                dump_json_patch=None
            ))

    def test_invalid_yaml(self):
        with pytest.raises(SystemExit):
            recategorize.main(argparse.Namespace(
                coding_standards_schema_file= Path.cwd(),
                sarif_schema_file= Path.cwd(),
                coding_standards_config_file= TEST_DATA_DIR / 'invalid-yaml.yml'
            ))
    
    def test_invalid_json_for_schema(self):
        with pytest.raises(SystemExit):
            recategorize.main(argparse.Namespace(
                coding_standards_schema_file= TEST_DATA_DIR / 'invalid-json.json'
            ))

class TestUnsupportedSchemas:
    def test_unsupported_sarif_schema(self):
        with pytest.raises(SystemExit):
            recategorize.main(argparse.Namespace(
                    coding_standards_schema_file= Path.cwd(),
                    sarif_schema_file= TEST_DATA_DIR / 'unsupported-sarif-schema-2.0.0.json',
                    coding_standards_config_file= Path.cwd()
                ))
    def test_unsupported_coding_standards_config_schema(self):
        with pytest.raises(SystemExit):
            recategorize.main(argparse.Namespace(
                    coding_standards_schema_file= Path.cwd(),
                    sarif_schema_file= TEST_DATA_DIR / 'unsupported-coding-standards-schema-0.0.1.json',
                    coding_standards_config_file= Path.cwd()
                ))

class TestRecategorization:
    def test_recategorization(self, tmp_path):
        with (TEST_DATA_DIR / 'valid-sarif.json').open(mode='r') as sarif_in:
            with (tmp_path / 'sarif.json').open(mode='w') as sarif_out:
                recategorize.main(argparse.Namespace(
                    coding_standards_schema_file= Path.cwd(),
                    sarif_schema_file= Path.cwd(),
                    coding_standards_config_file= TEST_DATA_DIR / 'valid-coding-standards-config.yml',
                    sarif_in=sarif_in,
                    sarif_out=sarif_out,
                    dump_json_patch=tmp_path / 'json-patch.json'
                ))
        
        expected_patch = (TEST_DATA_DIR / 'json-patch.expected').read_text()
        actual_patch = (tmp_path / 'json-patch.json').read_text()
        assert(expected_patch == actual_patch)

        expected_sarif = (TEST_DATA_DIR / 'valid-sarif-recategorized.expected').read_text()
        actual_sarif = (tmp_path / 'sarif.json').read_text()
        assert(expected_sarif == actual_sarif)