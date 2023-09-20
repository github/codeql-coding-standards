from __future__ import annotations # This enables postponed evaluation of type annotations. Required for typing.TYPE_CHECKING. See https://peps.python.org/pep-0563/
from typing import TYPE_CHECKING, List, Union, cast, Dict, Any
import shutil
from tempfile import TemporaryDirectory
import subprocess
import re
from pathlib import Path
import sys
import semantic_version # type: ignore
import requests
import yaml

if TYPE_CHECKING:
    from github import WorkflowRun, Repository
    

script_path = Path(__file__).resolve()
root_path = script_path.parent.parent.parent

def monkey_patch_github() -> None:
    from github import Repository, PaginatedList, CheckRun

    class MyRepository(Repository.Repository):
        def get_check_runs(self: Repository.Repository, ref: str, **kwargs: str) -> PaginatedList.PaginatedList[CheckRun.CheckRun]:
            assert isinstance(ref, str), ref

            return PaginatedList.PaginatedList(
                CheckRun.CheckRun,
                self._requester,
                f"{self.url}/commits/{ref}/check-runs",
                firstParams=None,
                list_item="check_runs")
    
    Repository.Repository = MyRepository

    from github import WorkflowRun, Artifact
    class MyWorkflowRun(WorkflowRun.WorkflowRun):
        def download_logs(self, path: Path) -> None:
            """
            Download the logs for this workflow and store them in the directory specified by path.

            This method tries to minimize the dependency on the internal workings of the class Requester by using
            requests directly. Ideally we would like to monkey patch __rawRequest to deal with 302 redirects, but
            that didn't work out because it would fail to call other private methods with an AttributeError for an unknown reason.
            """
            url = f"{self.url}/logs"
            headers = {
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": "2022-11-28"
            }
            if self._requester._Requester__auth is not None: # type: ignore
                headers["Authorization"] = f"{self._requester._Requester__auth.token_type} {self._requester._Requester__auth.token}" # type: ignore
            headers["User-Agent"] = self._requester._Requester__userAgent # type: ignore
           
            resp = requests.get(url, headers=headers, allow_redirects=True)

            if resp.status_code != 200:
                raise Exception(f"Unable to download logs: {resp.status_code} {resp.reason}")

            with (path / f"{self.name}-{self.head_sha}-{self.run_number}.zip").open("wb") as f:
                f.write(resp.content)

        def download_artifacts(self, path: Path) -> None:
            for artifact in self.get_artifacts(): # type: ignore
                artifact = cast(Artifact.Artifact, artifact)
                headers = {
                    "Accept": "application/vnd.github+json",
                    "X-GitHub-Api-Version": "2022-11-28"
                }
                if self._requester._Requester__auth is not None: # type: ignore
                    headers["Authorization"] = f"{self._requester._Requester__auth.token_type} {self._requester._Requester__auth.token}" # type: ignore
                headers["User-Agent"] = self._requester._Requester__userAgent # type: ignore
            
                resp = requests.get(artifact.archive_download_url, headers=headers, allow_redirects=True)

                if resp.status_code != 200:
                    raise Exception(f"Unable to download artifact ${artifact.name}. Received status code {resp.status_code} {resp.reason}")

                with (path / f"{artifact.name}.zip").open("wb") as f:
                    f.write(resp.content)

        def download_artifact(self, name: str, path: Path) -> None:
            candidates: List[Artifact.Artifact] = [artifact for artifact in self.get_artifacts() if artifact.name == name] # type: ignore
            if len(candidates) == 0:
                raise Exception(f"Unable to find artifact {name}")
            assert(len(candidates) == 1)

            artifact = candidates[0]
            headers = {
                    "Accept": "application/vnd.github+json",
                    "X-GitHub-Api-Version": "2022-11-28"
            }
            if self._requester._Requester__auth is not None: # type: ignore
                headers["Authorization"] = f"{self._requester._Requester__auth.token_type} {self._requester._Requester__auth.token}" # type: ignore
            headers["User-Agent"] = self._requester._Requester__userAgent # type: ignore
        
            resp = requests.get(artifact.archive_download_url, headers=headers, allow_redirects=True)

            if resp.status_code != 200:
                raise Exception(f"Unable to download artifact ${artifact.name}. Received status code {resp.status_code} {resp.reason}")

            with (path / f"{artifact.name}.zip").open("wb") as f:
                f.write(resp.content)
        

    WorkflowRun.WorkflowRun = MyWorkflowRun

class ReleaseLayout:
    def __init__(self, specification: Path, skip_checks: bool = False) -> None:
        self.specification = specification
        self.artifacts = []
        self.skip_checks = skip_checks

    def make(self, directory: Path, workflow_runs: List[WorkflowRun.WorkflowRun]) -> None:
        spec = yaml.safe_load(self.specification.read_text())
        artifacts : List[ReleaseArtifact] = []
        for artifact, action_specs in spec["layout"].items():
            actions : List[Union[WorkflowArtifactAction, WorkflowLogAction, ShellAction, FileAction]] = []
            for action_spec in action_specs:
                assert(len(action_spec) == 1)
                action_type, action_args = action_spec.popitem()
                if action_type == "workflow-log":
                    actions.append(WorkflowLogAction(workflow_runs, **cast(Dict[str, Any], action_args)))
                elif action_type == "workflow-artifact":
                    actions.append(WorkflowArtifactAction(workflow_runs, **cast(Dict[str, Any], action_args)))
                elif action_type == "shell":
                    actions.append(ShellAction(action_args))
                elif action_type == "file":
                    actions.append(FileAction(action_args))
                else:
                    raise Exception(f"Unknown action type {action_type}")
            
            artifacts.append(ReleaseArtifact(artifact, actions, self.skip_checks))

        for artifact in artifacts:
            artifact.make(directory)

class WorkflowLogAction():

    def __init__(self, workflow_runs: List[WorkflowRun.WorkflowRun], **kwargs: str) -> None:
        self.workflow_runs = workflow_runs
        self.kwargs: dict[str, str] = kwargs
        self.temp_workdir = TemporaryDirectory()

    def run(self) -> List[Path]:
        workflow_runs = self.workflow_runs
        if "name" in self.kwargs:
            workflow_runs = [workflow_run for workflow_run in self.workflow_runs if re.match(self.kwargs["name"], workflow_run.name)]
        if "not-name" in self.kwargs:
            workflow_runs = [workflow_run for workflow_run in self.workflow_runs if not re.match(self.kwargs["not-name"], workflow_run.name)]
        print(f"Downloading the logs for {len(workflow_runs)} workflow runs")
        for workflow_run in workflow_runs:
            print(f"Downloading logs for {workflow_run.name}")
            workflow_run.download_logs(Path(self.temp_workdir.name)) # type: ignore
        return list(map(Path, Path(self.temp_workdir.name).glob("**/*")))
    
class WorkflowArtifactAction():

    def __init__(self, workflow_runs: List[WorkflowRun.WorkflowRun], **kwargs: str) -> None:
        self.workflow_runs = workflow_runs
        self.kwargs: dict[str, str] = kwargs
        self.temp_workdir = TemporaryDirectory()

    def run(self) -> List[Path]:
        workflow_runs = self.workflow_runs
        if "name" in self.kwargs:
            workflow_runs = [workflow_run for workflow_run in self.workflow_runs if re.match(self.kwargs["name"], workflow_run.name)]
        if "not-name" in self.kwargs:
            workflow_runs = [workflow_run for workflow_run in self.workflow_runs if not re.match(self.kwargs["not-name"], workflow_run.name)]
        print(f"Downloading the artifacts for {len(workflow_runs)} workflow runs")
        for workflow_run in workflow_runs:
            if "artifact" in self.kwargs:
                print(f"Downloading artifact {self.kwargs['artifact']} for {workflow_run.name} to {self.temp_workdir.name}")
                workflow_run.download_artifact(self.kwargs["artifact"], Path(self.temp_workdir.name)) # type: ignore
            else:
                print(f"Downloading artifacts for {workflow_run.name} to {self.temp_workdir.name}")
                workflow_run.download_artifacts(Path(self.temp_workdir.name)) # type: ignore
        return list(map(Path, Path(self.temp_workdir.name).glob("**/*")))
    
class ShellAction():
    def __init__(self, command: str) -> None:
        self.command = command.strip()
        self.temp_workdir = TemporaryDirectory()

    def run(self) -> List[Path]:
        concrete_command = re.sub(pattern=r"\${{\s*coding-standards\.root\s*}}", repl=str(root_path), string=self.command)
        subprocess.run(concrete_command, cwd=self.temp_workdir.name, check=True, shell=True)
        return list(map(Path, Path(self.temp_workdir.name).glob("**/*")))
        
class FileAction():
    def __init__(self, path: Path) -> None:
        self.path = path

    def run(self) -> List[Path]:
        return [self.path]

class ReleaseArtifact():
    def __init__(self, name: str, actions: List[Union[WorkflowLogAction, WorkflowArtifactAction, ShellAction, FileAction]], allow_no_files: bool = False) -> None:
        self.name = Path(name)
        self.actions = actions
        self.allow_no_files = allow_no_files

    def make(self, directory: Path) -> Path:
        files: list[Path] = [file for action in self.actions for file in action.run()]
        if len(files) == 0:
            if not self.allow_no_files:
                raise Exception(f"Artifact {self.name} has no associated files!")
        elif len(files) == 1:
            shutil.copy(files[0], directory / self.name)
            return directory / self.name
        else:
            extension = "".join(self.name.suffixes)[1:]
            if not extension in ["zip", "tar", "tar.gz", "tar.bz2", "tar.xz"]:
                raise Exception(f"Artifact {self.name} is not a support archive file, but has multiple files associated with it!")
            
            ext_format_map = {    
                "zip": "zip",
                "tar": "tar",
                "tar.gz": "gztar",
                "tar.bz2": "bztar",
                "tar.xz": "xztar"
            }

            with TemporaryDirectory() as temp_dir:
                temp_dir_path = Path(temp_dir)
                for file in files:
                    shutil.copy(file, temp_dir_path / file.name)
            
                return Path(shutil.make_archive(str(directory / self.name.with_suffix("")), ext_format_map[extension], root_dir=temp_dir_path))

def main(args: 'argparse.Namespace') -> int:
    monkey_patch_github()

    import github
    from github import CheckRun

    repos: Dict[str, Repository.Repository] = {}
    if len(args.github_token) == 1:
        repos[args.repo] = github.Github(auth=github.Auth.Token(args.github_token[0])).get_repo(args.repo)
    else:
        for token in args.github_token:
            nwo, token = token.split(":")
            repos[nwo] = github.Github(auth=github.Auth.Token(token)).get_repo(nwo)

    repo = repos[args.repo]

    pull_candidates = [pr for pr in repo.get_pulls(state="open") if pr.head.sha == args.head_sha]
    if len(pull_candidates) != 1:
        print(f"Error: expected exactly one PR for SHA {args.head_sha}, but found {len(pull_candidates)}", file=sys.stderr)
        return 1
    
    pull_request = pull_candidates[0]

    if pull_request.state != "open":
        print(f"Error: PR {pull_request.url} is not open", file=sys.stderr)
        return 1
    
    print(f"Found PR {pull_request.url} based on {pull_request.base.ref}")

    rc_branch_regex = r"^rc/(?P<version>.*)$"
    rc_branch_match = re.match(rc_branch_regex, pull_request.base.ref)
    if not rc_branch_match:
        print(f"Error: PR {pull_request.url} is not based on a release candidate branch", file=sys.stderr)
        return 1

    release_version = rc_branch_match.group("version")

    try:
        semantic_version.Version.parse(release_version) # type: ignore
    except ValueError as e:
        print(f"Error: invalid version {release_version} use by release branch. Reason {e}", file=sys.stderr)
        return 1

    print(f"Looking for release with tag v{release_version} associated with the PR's base ref {pull_request.base.ref}")
    all_releases = repo.get_releases()
    for release in all_releases:
        print(f"Found release {release.title} with tag {release.tag_name}")
    releases = [release for release in all_releases if release.tag_name == f"v{release_version}"]
    if len(releases) != 1:
        print(f"Error: expected exactly one release for {release_version}, but found {len(releases)}", file=sys.stderr)
        return 1
    release = releases[0]

    print(f"Collecting workflow runs for ref {args.head_sha}")
    check_runs: List[CheckRun.CheckRun] = repo.get_check_runs(args.head_sha) # type: ignore

    action_workflow_run_url_regex = r"^https://(?P<github_url>[^/]+)/(?P<owner>[^/]+)/(?P<repo>[^/]+)/actions/runs/(?P<run_id>\d+)$"
    action_workflow_job_run_url_regex = r"^https://(?P<github_url>[^/]+)/(?P<owner>[^/]+)/(?P<repo>[^/]+)/actions/runs/(?P<run_id>\d+)/job/(?P<job_id>\d+)$"
    
    workflow_runs: List[WorkflowRun.WorkflowRun] = []
    for check_run in check_runs: # type: ignore
        check_run = cast(CheckRun.CheckRun, check_run)
        if check_run.status != "completed" or check_run.conclusion == "skipped":
            continue
        job_run_match = re.match(action_workflow_job_run_url_regex, check_run.details_url)
        if job_run_match:
            workflow_run = repo.get_workflow_run(int(job_run_match.group("run_id")))
            workflow_runs.append(workflow_run)
        else:
            run_match = re.match(action_workflow_run_url_regex, check_run.external_id)
            if run_match:
                #print(f"External workflow on {run_match.group('owner')} {run_match.group('repo')} with id {run_match.group('run_id')}")
                workflow_run = repos[f"{run_match.group('owner')}/{run_match.group('repo')}"].get_workflow_run(int(run_match.group("run_id")))
                workflow_runs.append(workflow_run)
            else:
                print(f"Unable to handle checkrun {check_run.name} with id {check_run.id} with {check_run.details_url}")
                return 1
    
    print("Filtering workflow runs to only include the latest run for each workflow.")
    workflow_runs_per_id: Dict[int, WorkflowRun.WorkflowRun] = {}
    for workflow_run in workflow_runs:
        if not workflow_run.id in workflow_runs_per_id:
            workflow_runs_per_id[workflow_run.id] = workflow_run
        else:
            latest_run = workflow_runs_per_id[workflow_run.id]
            if latest_run.run_number < workflow_run.run_number:
                workflow_runs_per_id[workflow_run.id] = workflow_run
    latests_workflow_runs = list(workflow_runs_per_id.values())

    if not args.skip_checks:
        print(f"Checking that all workflow runs for ref {args.head_sha} succeeded")
        for workflow_run in latests_workflow_runs:
            if workflow_run.status != "completed":
                print(f"Error: workflow run {workflow_run.name} with id {workflow_run.id} is not completed", file=sys.stderr)
                return 1
            # Consider success or skipped as success
            if workflow_run.conclusion == "failure":
                print(f"Error: workflow run {workflow_run.name} with id {workflow_run.id} failed", file=sys.stderr)
                return 1

    with TemporaryDirectory() as temp_dir:
        print(f"Using temporary directory {temp_dir}")
        try:
            ReleaseLayout(Path(args.layout), args.skip_checks).make(Path(temp_dir), latests_workflow_runs)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            return 1

        print("Deleting existing assets")
        for asset in release.assets:
            asset.delete_asset()

        print("Uploading new assets from generated release layout")
        for file in Path(temp_dir).glob("**/*"):
            print(f"Uploading {file}")
            release.upload_asset(str(file))

    return 0

if __name__ == '__main__':
    import argparse
    from sys import exit

    parser = argparse.ArgumentParser()
    parser.add_argument('--head-sha', help="The head SHA of the release PR for which we update it's corresponding release", required=True)
    parser.add_argument('--repo', help="The owner and repository name. For example, 'octocat/Hello-World'. Used when testing this script on a fork", required=True, default="github/codeql-coding-standards")
    parser.add_argument('--github-token', help="The github token to use for the release PR", required=True, nargs="+")
    parser.add_argument('--layout', help="The layout to use for the release", required=True)
    parser.add_argument('--skip-checks', help="Skip the checks that ensure that the workflow runs succeeded", action="store_true")
    args = parser.parse_args()
    exit(main(args))