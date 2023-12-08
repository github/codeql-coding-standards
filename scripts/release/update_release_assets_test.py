from pathlib import Path
from tempfile import TemporaryDirectory
import yaml
from update_release_assets import ReleaseLayout

SCRIPT_PATH = Path(__file__)
TEST_DIR = SCRIPT_PATH.parent / 'test-data'

def test_release_layout():
    spec = TEST_DIR / 'release-layout.yml'
    release_layout = ReleaseLayout(spec)
    with TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir) 
        release_layout.make(tmp_path, [])

        for artifact in yaml.safe_load(spec.read_text())['layout'].keys():
            artifact_path = tmp_path / artifact
            assert artifact_path.is_file()

            if artifact == "hello-world.txt":
                content = artifact_path.read_text()
                assert content == "hello world!\n"
            if artifact == "checksums.txt":
                content = artifact_path.read_text()
                # The hash of the hello-world.txt is deterministic, so we can assert it here. 
                assert "ecf701f727d9e2d77c4aa49ac6fbbcc997278aca010bddeeb961c10cf54d435a  hello-world.txt" in content
                # The has of the hello-world.zip is not deterministic, so we can't assert its hash.
                assert "hello-world.zip" in content


