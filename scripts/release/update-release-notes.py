from __future__ import annotations # This enables postponed evaluation of type annotations. Required for typing.TYPE_CHECKING. See https://peps.python.org/pep-0563/
from typing import TYPE_CHECKING
import subprocess
from pathlib import Path

if TYPE_CHECKING:
    from argparse import Namespace

def generate_release_note(previous_release_tag: str) -> str:
    script_path = Path(__file__).parent / "generate_release_notes.py"
    cp = subprocess.run(["python", str(script_path), previous_release_tag], capture_output=True)

    if cp.returncode != 0:
        raise Exception(f"Error generating release notes: {cp.stderr.decode('utf-8')}")

    return cp.stdout.decode("utf-8")

def main(args: Namespace) -> int:
    from github import Github, Auth
    import semantic_version # type: ignore
    import re
    import sys
    from functools import cmp_to_key

    repo = Github(auth=Auth.Token(args.github_token)).get_repo(args.repo)

    pull_candidates = [pr for pr in repo.get_pulls(state="open") if pr.head.sha == args.head_sha]
    if len(pull_candidates) != 1:
        print(f"Error: expected exactly one PR for SHA {args.head_sha}, but found {len(pull_candidates)}", file=sys.stderr)
        return 1
    
    pull_request = pull_candidates[0]

    if pull_request.state != "open":
        print(f"Error: PR for version {args.version} is not open", file=sys.stderr)
        return 1
    
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

    releases = repo.get_releases()
    candidate_releases= [release for release in releases if release.tag_name == f"v{release_version}"]
    if len(candidate_releases) != 1:
        print(f"Error: expected exactly one release with tag v{release_version}, but found {len(candidate_releases)}", file=sys.stderr)
        return 1
    release = candidate_releases[0]

    # All the releases that are not draft and have a valid semantic version tag
    previous_releases = [release for release in releases if semantic_version.validate(release.tag_name[1:]) and not release.draft] # type: ignore
    if len(previous_releases) == 0:
        print(f"Error: no previous releases found", file=sys.stderr)
        return 1
    # Sort them based on their semantic version tags.
    previous_releases.sort(key=cmp_to_key(lambda a,b: semantic_version.compare(a.tag_name[1:], b.tag_name[1:])), reverse=True) # type: ignore
    previous_release = previous_releases[0].tag_name
    print(f"Using previous release: {previous_release}")

    release_notes = generate_release_note(previous_release)

    release.update_release(name=release.title, message=release_notes, draft=release.draft, prerelease=release.prerelease, tag_name=release.tag_name)
    return 0

if __name__ == '__main__':
    import argparse
    from sys import exit

    parser = argparse.ArgumentParser()
    parser.add_argument('--head-sha', help="The head SHA of the release PR for which we update it's corresponding release", required=True)
    parser.add_argument('--repo', help="The owner and repository name. For example, 'octocat/Hello-World'. Used when testing this script on a fork", required=True, default="github/codeql-coding-standards")
    parser.add_argument('--github-token', help="The GitHub token to use to update the release", required=True)
    args = parser.parse_args()
    exit(main(args))