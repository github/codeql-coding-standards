#!/usr/bin/env python3
"""
github/codeql-coding-standards:scripts/es-sarif/run-gh-mrva-for-query-suite.py

MRVA = Multi-Repository Vulnerability Analysis => scale one CodeQL query to many (1000s of) repos.

This script creates a MRVA session for each query in a given query suite and manages
the execution lifecycle including submission, monitoring, and downloading of results.
The script uses a pipeline-based approach where each query is processed asynchronously
through its complete lifecycle: submit -> monitor -> download -> copy results.

This script expects that the `mrva` extension has already been installed for the
`gh` CLI tool, such that `gh mrva` commands can be executed.

Usage:
    python run-gh-mrva-for-query-suite.py --query-suite <suite> --output-base-dir <dir> [options]

Requirements:
    - GitHub CLI with mrva extension installed
    - CodeQL CLI available in PATH
    - Python 3.11+
"""

import sys
import json
import os
import argparse
import subprocess
import time
import re
import threading
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from enum import Enum


class PipelineState(Enum):
    """States in the MRVA processing pipeline."""

    NOT_STARTED = "not_started"
    SUBMITTING = "submitting"
    SUBMITTED = "submitted"
    MONITORING = "monitoring"
    COMPLETED = "completed"
    DOWNLOADING = "downloading"
    DOWNLOADED = "downloaded"
    COPYING = "copying"
    FINISHED = "finished"
    FAILED = "failed"


@dataclass
class MRVAPipeline:
    """Represents the processing pipeline for a single query."""

    query_path: str
    session_name: str
    language: str
    state: PipelineState = PipelineState.NOT_STARTED
    submitted_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    downloaded_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
    error_message: Optional[str] = None
    run_count: int = 0
    succeeded_runs: int = 0
    failed_runs: int = 0

    def to_dict(self) -> Dict:
        """Convert pipeline to dictionary for JSON serialization."""
        return {
            "query_path": self.query_path,
            "session_name": self.session_name,
            "language": self.language,
            "state": self.state.value,
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "downloaded_at": self.downloaded_at.isoformat() if self.downloaded_at else None,
            "finished_at": self.finished_at.isoformat() if self.finished_at else None,
            "error_message": self.error_message,
            "run_count": self.run_count,
            "succeeded_runs": self.succeeded_runs,
            "failed_runs": self.failed_runs,
        }

    @classmethod
    def from_dict(cls, data: Dict) -> "MRVAPipeline":
        """Create pipeline from dictionary."""
        pipeline = cls(
            query_path=data["query_path"],
            session_name=data["session_name"],
            language=data["language"],
            state=PipelineState(data["state"]),
        )
        pipeline.submitted_at = (
            datetime.fromisoformat(data["submitted_at"]) if data.get("submitted_at") else None
        )
        pipeline.completed_at = (
            datetime.fromisoformat(data["completed_at"]) if data.get("completed_at") else None
        )
        pipeline.downloaded_at = (
            datetime.fromisoformat(data["downloaded_at"]) if data.get("downloaded_at") else None
        )
        pipeline.finished_at = (
            datetime.fromisoformat(data["finished_at"]) if data.get("finished_at") else None
        )
        pipeline.error_message = data.get("error_message")
        pipeline.run_count = data.get("run_count", 0)
        pipeline.succeeded_runs = data.get("succeeded_runs", 0)
        pipeline.failed_runs = data.get("failed_runs", 0)
        return pipeline


class MRVAManager:
    """Manages MRVA pipelines for a query suite using concurrent processing."""

    def __init__(
        self,
        query_suite: str,
        output_base_dir: Path,
        session_prefix: str,
        language: str,
        repository_list: str,
        max_concurrent: int = 20,
        check_interval: int = 300,
        dry_run: bool = False,
    ):
        self.query_suite = query_suite
        self.output_base_dir = output_base_dir
        self.session_prefix = session_prefix
        self.language = language
        self.repository_list = repository_list
        self.max_concurrent = max_concurrent
        self.check_interval = check_interval
        self.dry_run = dry_run

        # Directories
        self.sessions_dir = output_base_dir / "sessions"
        self.status_dir = output_base_dir / "sessions" / "status"
        self.results_dir = output_base_dir / "results" / session_prefix
        self.state_file = output_base_dir / f"{session_prefix}_state.json"
        self.sarif_list_file = self.results_dir / "sarif-files.txt"

        # Pipeline tracking
        self.pipelines: Dict[str, MRVAPipeline] = {}
        self.pipelines_lock = threading.Lock()

        # Create directories (only in non-dry-run mode)
        if not self.dry_run:
            self.sessions_dir.mkdir(parents=True, exist_ok=True)
            self.status_dir.mkdir(parents=True, exist_ok=True)
            self.results_dir.mkdir(parents=True, exist_ok=True)

        # Load existing state if available (both modes)
        self._load_state()

    def _load_state(self):
        """Load existing pipeline state from file."""
        if self.state_file.exists():
            try:
                with open(self.state_file, "r") as f:
                    state_data = json.load(f)

                for pipeline_data in state_data.get("pipelines", []):
                    pipeline = MRVAPipeline.from_dict(pipeline_data)
                    self.pipelines[pipeline.session_name] = pipeline

                print(f"✓ Loaded state for {len(self.pipelines)} pipelines from {self.state_file}")
            except Exception as e:
                print(f"Warning: Could not load state file: {e}")

    def _save_state(self):
        """Save current pipeline state to file."""
        # Don't save state in dry-run mode to avoid creating directories
        if self.dry_run:
            return

        state_data = {
            "query_suite": self.query_suite,
            "session_prefix": self.session_prefix,
            "language": self.language,
            "repository_list": self.repository_list,
            "updated_at": datetime.utcnow().isoformat(),
            "pipelines": [p.to_dict() for p in self.pipelines.values()],
        }

        # Ensure parent directory exists
        self.state_file.parent.mkdir(parents=True, exist_ok=True)

        with open(self.state_file, "w") as f:
            json.dump(state_data, f, indent=2)

    def resolve_queries(self) -> List[str]:
        """Resolve query files from the query suite using CodeQL CLI."""
        print(f"Resolving queries from suite: {self.query_suite}")

        try:
            result = subprocess.run(
                ["codeql", "resolve", "queries", "--", self.query_suite],
                capture_output=True,
                text=True,
                check=True,
            )

            query_paths = []
            for line in result.stdout.strip().split("\n"):
                line = line.strip()
                if line and line.endswith(".ql"):
                    query_paths.append(line)

            print(f"✓ Found {len(query_paths)} queries in suite")
            return query_paths

        except subprocess.CalledProcessError as e:
            print(f"Error resolving queries: {e}")
            print(f"STDOUT: {e.stdout}")
            print(f"STDERR: {e.stderr}")
            sys.exit(1)

    def _generate_session_name(self, query_path: str) -> str:
        """Generate a session name from query path."""
        query_name = Path(query_path).stem
        sanitized = re.sub(r"[^a-zA-Z0-9\-_]", "-", query_name)
        return f"{self.session_prefix}-{sanitized}"

    def get_existing_sessions(self) -> Dict[str, Dict]:
        """Get existing MRVA sessions from gh mrva list."""
        # Save list output to file for performance and debugging
        list_file = self.sessions_dir / "mrva-sessions-list.json"

        try:
            result = subprocess.run(
                ["gh", "mrva", "list", "--json"], capture_output=True, text=True, check=True
            )

            # Save output to file (only if not in dry-run to avoid creating directories)
            if not self.dry_run:
                list_file.write_text(result.stdout)

            sessions_data = json.loads(result.stdout)
            sessions_by_name = {}

            for session in sessions_data:
                session_name = session.get("name", "")
                if session_name.startswith(self.session_prefix):
                    sessions_by_name[session_name] = session

            return sessions_by_name

        except subprocess.CalledProcessError as e:
            print(f"Warning: Could not list existing sessions: {e}")
            return {}
        except json.JSONDecodeError as e:
            print(f"Warning: Could not parse session list: {e}")
            return {}

    def get_session_status(self, session_name: str) -> Optional[Dict]:
        """Get detailed status for a specific session."""
        # Save status output to file for performance and debugging (only in non-dry-run)
        status_file = self.status_dir / f"{session_name}_status.json"

        try:
            result = subprocess.run(
                ["gh", "mrva", "status", "--json", "--session", session_name],
                capture_output=True,
                text=True,
                check=True,
            )

            # Save output to file (only if not in dry-run to avoid creating directories)
            if not self.dry_run:
                status_file.write_text(result.stdout)

            status_data = json.loads(result.stdout)
            if status_data and len(status_data) > 0:
                return status_data[0]
            return None

        except subprocess.CalledProcessError:
            return None
        except json.JSONDecodeError:
            return None

    def check_downloads_exist(self, session_name: str) -> Tuple[bool, List[str]]:
        """Check if downloads already exist for a session."""
        session_dir = self.sessions_dir / session_name

        if not session_dir.exists():
            return False, []

        # Look for SARIF files
        sarif_files = list(session_dir.glob("*.sarif"))
        return len(sarif_files) > 0, [str(f) for f in sarif_files]

    def submit_session(self, pipeline: MRVAPipeline) -> bool:
        """Submit a new MRVA session."""
        try:
            cmd = [
                "gh",
                "mrva",
                "submit",
                "--language",
                self.language,
                "--session",
                pipeline.session_name,
                "--list",
                self.repository_list,
                "--query",
                pipeline.query_path,
            ]

            if self.dry_run:
                # In dry run, just mark as submitted without printing per-session details
                pipeline.state = PipelineState.SUBMITTED
                pipeline.submitted_at = datetime.utcnow()
                return True

            result = subprocess.run(cmd, capture_output=True, text=True, check=True)

            pipeline.state = PipelineState.SUBMITTED
            pipeline.submitted_at = datetime.utcnow()
            return True

        except subprocess.CalledProcessError as e:
            pipeline.state = PipelineState.FAILED
            pipeline.error_message = f"Submit failed: {e.stderr if e.stderr else str(e)}"
            return False

    def monitor_session(self, pipeline: MRVAPipeline) -> bool:
        """Monitor a session until it completes."""
        pipeline.state = PipelineState.MONITORING

        # In dry-run, just check status once and return without waiting
        if self.dry_run:
            session_status = self.get_session_status(pipeline.session_name)

            if not session_status:
                # Session doesn't exist yet, would need to be submitted
                pipeline.state = PipelineState.NOT_STARTED
                pipeline.error_message = "Session does not exist (would need to be submitted)"
                return False

            status = session_status.get("status", "").lower()
            runs = session_status.get("runs", [])

            pipeline.run_count = len(runs)
            pipeline.succeeded_runs = len([r for r in runs if r.get("status") == "succeeded"])
            pipeline.failed_runs = len([r for r in runs if r.get("status") == "failed"])
            in_progress = len([r for r in runs if r.get("status") in ["pending", "in_progress"]])

            if status in ["completed", "succeeded"] and in_progress == 0:
                pipeline.state = PipelineState.COMPLETED
                pipeline.completed_at = datetime.utcnow()
                return True
            elif status == "failed":
                pipeline.state = PipelineState.FAILED
                pipeline.error_message = f"MRVA session failed (status: {status})"
                return False
            else:
                # Still in progress
                pipeline.state = PipelineState.SUBMITTED
                pipeline.error_message = (
                    f"Session still in progress (status: {status}, runs: {pipeline.run_count})"
                )
                return False

        # Non-dry-run mode: actually monitor until completion
        while True:
            session_status = self.get_session_status(pipeline.session_name)

            if not session_status:
                time.sleep(self.check_interval)
                continue

            status = session_status.get("status", "").lower()
            runs = session_status.get("runs", [])

            # Count run statuses
            pipeline.run_count = len(runs)
            pipeline.succeeded_runs = len([r for r in runs if r.get("status") == "succeeded"])
            pipeline.failed_runs = len([r for r in runs if r.get("status") == "failed"])
            in_progress = len([r for r in runs if r.get("status") in ["pending", "in_progress"]])

            if status in ["completed", "succeeded"] and in_progress == 0:
                pipeline.state = PipelineState.COMPLETED
                pipeline.completed_at = datetime.utcnow()
                return True
            elif status == "failed":
                pipeline.state = PipelineState.FAILED
                pipeline.error_message = "Session failed"
                return False

            time.sleep(self.check_interval)

    def download_session(self, pipeline: MRVAPipeline) -> bool:
        """Download results for a completed session."""
        pipeline.state = PipelineState.DOWNLOADING

        session_dir = self.sessions_dir / pipeline.session_name

        # Only create directory in non-dry-run mode
        if not self.dry_run:
            session_dir.mkdir(parents=True, exist_ok=True)

        # In dry-run, just mark as would-be-downloaded
        if self.dry_run:
            pipeline.state = PipelineState.DOWNLOADED
            pipeline.downloaded_at = datetime.utcnow()
            return True

        try:
            # Download all results for the session at once
            cmd = [
                "gh",
                "mrva",
                "download",
                "--session",
                pipeline.session_name,
                "--output-dir",
                str(session_dir),
            ]

            subprocess.run(cmd, capture_output=True, text=True, check=True)

            pipeline.state = PipelineState.DOWNLOADED
            pipeline.downloaded_at = datetime.utcnow()
            return True

        except subprocess.CalledProcessError as e:
            pipeline.state = PipelineState.FAILED
            pipeline.error_message = f"Download failed: {e.stderr if e.stderr else str(e)}"
            return False

    def copy_results(self, pipeline: MRVAPipeline) -> bool:
        """Copy downloaded SARIF files to results directory and update sarif-files.txt."""
        pipeline.state = PipelineState.COPYING

        session_dir = self.sessions_dir / pipeline.session_name

        # In dry-run, skip the actual file operations
        if self.dry_run:
            pipeline.state = PipelineState.FINISHED
            pipeline.finished_at = datetime.utcnow()
            return True

        if not session_dir.exists():
            pipeline.state = PipelineState.FAILED
            pipeline.error_message = "Session directory does not exist"
            return False

        # Find all SARIF files in session directory
        sarif_files = list(session_dir.glob("*.sarif"))

        if not sarif_files:
            # No SARIF files to copy (could be zero results)
            pipeline.state = PipelineState.FINISHED
            pipeline.finished_at = datetime.utcnow()
            return True

        try:
            copied_files = []

            for sarif_file in sarif_files:
                # Parse filename to extract org/repo info
                # Expected format: <org>_<repo>_<runId>.sarif
                filename = sarif_file.name
                parts = filename.replace(".sarif", "").split("_")

                if len(parts) >= 3:
                    org = parts[0]
                    repo = "_".join(parts[1:-1])  # Handle repo names with underscores

                    # Create destination directory
                    dest_dir = self.results_dir / org / repo
                    dest_dir.mkdir(parents=True, exist_ok=True)

                    # Copy file
                    dest_file = dest_dir / filename
                    import shutil

                    shutil.copy2(sarif_file, dest_file)

                    # Record relative path for sarif-files.txt
                    relative_path = f"{org}/{repo}/{filename}"
                    copied_files.append(relative_path)

            # Append to sarif-files.txt
            if copied_files:
                with open(self.sarif_list_file, "a") as f:
                    for relative_path in copied_files:
                        f.write(f"{relative_path}\n")

            pipeline.state = PipelineState.FINISHED
            pipeline.finished_at = datetime.utcnow()
            return True

        except Exception as e:
            pipeline.state = PipelineState.FAILED
            pipeline.error_message = f"Copy failed: {str(e)}"
            return False

    def process_pipeline(self, pipeline: MRVAPipeline) -> bool:
        """Process a single pipeline through all stages."""
        try:
            # Submit
            if pipeline.state == PipelineState.NOT_STARTED:
                if not self.submit_session(pipeline):
                    return False
                with self.pipelines_lock:
                    self._save_state()

            # Monitor
            if pipeline.state in [PipelineState.SUBMITTED, PipelineState.MONITORING]:
                if not self.monitor_session(pipeline):
                    return False
                with self.pipelines_lock:
                    self._save_state()

            # Download
            if pipeline.state == PipelineState.COMPLETED:
                if not self.download_session(pipeline):
                    return False
                with self.pipelines_lock:
                    self._save_state()

            # Copy results
            if pipeline.state == PipelineState.DOWNLOADED:
                if not self.copy_results(pipeline):
                    return False
                with self.pipelines_lock:
                    self._save_state()

            return pipeline.state == PipelineState.FINISHED

        except Exception as e:
            pipeline.state = PipelineState.FAILED
            pipeline.error_message = f"Pipeline error: {str(e)}"
            with self.pipelines_lock:
                self._save_state()
            return False

    def restore_existing_pipelines(self, query_paths: List[str]):
        """Restore pipelines from existing MRVA sessions."""
        print("\nChecking for existing MRVA sessions...")
        existing_sessions = self.get_existing_sessions()

        if existing_sessions:
            print(
                f"Found {len(existing_sessions)} existing sessions with prefix '{self.session_prefix}'"
            )

        restored_count = 0

        for query_path in query_paths:
            session_name = self._generate_session_name(query_path)

            # Skip if already in state
            if session_name in self.pipelines:
                continue

            # Check if session exists in MRVA
            if session_name in existing_sessions:
                session_data = existing_sessions[session_name]

                # Create pipeline
                pipeline = MRVAPipeline(
                    query_path=query_path, session_name=session_name, language=self.language
                )

                # Determine state based on session status and downloads
                session_status = self.get_session_status(session_name)
                downloads_exist, sarif_files = self.check_downloads_exist(session_name)

                if session_status:
                    status = session_status.get("status", "").lower()
                    runs = session_status.get("runs", [])

                    pipeline.run_count = len(runs)
                    pipeline.succeeded_runs = len(
                        [r for r in runs if r.get("status") == "succeeded"]
                    )
                    pipeline.failed_runs = len([r for r in runs if r.get("status") == "failed"])

                    if status in ["completed", "succeeded"]:
                        if downloads_exist:
                            # Check if results have been copied
                            # For simplicity, assume if downloaded, we need to copy
                            pipeline.state = PipelineState.DOWNLOADED
                            pipeline.submitted_at = datetime.utcnow()  # Unknown actual time
                            pipeline.completed_at = datetime.utcnow()
                            pipeline.downloaded_at = datetime.utcnow()
                        else:
                            pipeline.state = PipelineState.COMPLETED
                            pipeline.submitted_at = datetime.utcnow()
                            pipeline.completed_at = datetime.utcnow()
                    elif status == "failed":
                        pipeline.state = PipelineState.FAILED
                        pipeline.error_message = "Session previously failed"
                    else:
                        # In progress
                        pipeline.state = PipelineState.SUBMITTED
                        pipeline.submitted_at = datetime.utcnow()

                self.pipelines[session_name] = pipeline
                restored_count += 1

        if restored_count > 0:
            print(f"✓ Restored {restored_count} pipelines from existing sessions")
            self._save_state()

    def get_status_summary(self) -> Dict[str, int]:
        """Get summary of pipeline states."""
        summary = {}
        for pipeline in self.pipelines.values():
            state = pipeline.state.value
            summary[state] = summary.get(state, 0) + 1
        return summary

    def print_progress(self, total_queries: int):
        """Print detailed progress information."""
        summary = self.get_status_summary()

        not_started = total_queries - len(self.pipelines)
        submitting = summary.get(PipelineState.SUBMITTING.value, 0)
        submitted = summary.get(PipelineState.SUBMITTED.value, 0)
        monitoring = summary.get(PipelineState.MONITORING.value, 0)
        completed = summary.get(PipelineState.COMPLETED.value, 0)
        downloading = summary.get(PipelineState.DOWNLOADING.value, 0)
        downloaded = summary.get(PipelineState.DOWNLOADED.value, 0)
        copying = summary.get(PipelineState.COPYING.value, 0)
        finished = summary.get(PipelineState.FINISHED.value, 0)
        failed = summary.get(PipelineState.FAILED.value, 0)

        print("\n" + "=" * 70)
        print(f"PROGRESS REPORT - {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}")
        print("=" * 70)
        print(f"Total queries in suite:           {total_queries}")
        print(f"  Not yet started:                {not_started}")
        print(f"  Submitting:                     {submitting}")
        print(f"  Submitted (monitoring):         {submitted + monitoring}")
        print(f"  Completed (awaiting download):  {completed}")
        print(f"  Downloading:                    {downloading}")
        print(f"  Downloaded (copying results):   {downloaded + copying}")
        print(f"  Finished:                       {finished}")
        print(f"  Failed/Errored:                 {failed}")
        print("-" * 70)
        print(
            f"Completion rate:                  {(finished / total_queries * 100) if total_queries > 0 else 0:.1f}%"
        )
        print("=" * 70)
        print()

    def run_until_complete(self) -> bool:
        """Run all pipelines until complete using concurrent processing."""
        # Resolve queries
        query_paths = self.resolve_queries()
        total_queries = len(query_paths)

        print(
            f"\n{'[DRY RUN] ' if self.dry_run else ''}Planning to process {total_queries} queries..."
        )
        print(f"Session prefix: {self.session_prefix}")
        print(f"Max concurrent pipelines: {self.max_concurrent}")
        print(f"Monitor interval: {self.check_interval} seconds")
        print()

        # Restore existing pipelines
        self.restore_existing_pipelines(query_paths)

        # Create pipelines for new queries
        for query_path in query_paths:
            session_name = self._generate_session_name(query_path)
            if session_name not in self.pipelines:
                pipeline = MRVAPipeline(
                    query_path=query_path, session_name=session_name, language=self.language
                )
                self.pipelines[session_name] = pipeline

        # Get pipelines that need processing
        pipelines_to_process = [
            p for p in self.pipelines.values() if p.state != PipelineState.FINISHED
        ]

        if not pipelines_to_process:
            print("\n✓ All pipelines already finished!")
            return True

        print(f"\nProcessing {len(pipelines_to_process)} pipelines...")

        if self.dry_run:
            print("\nDRY RUN: Simulating all pipeline operations (no actual API calls)...")

        # Process pipelines concurrently
        completed = 0
        failed = 0

        with ThreadPoolExecutor(max_workers=self.max_concurrent) as executor:
            # Submit all pipelines
            future_to_pipeline = {
                executor.submit(self.process_pipeline, pipeline): pipeline
                for pipeline in pipelines_to_process
            }

            # Process completions
            for future in as_completed(future_to_pipeline):
                pipeline = future_to_pipeline[future]
                try:
                    success = future.result()
                    if success:
                        completed += 1
                        if not self.dry_run:
                            print(
                                f"✓ Finished: {pipeline.session_name} ({completed + failed}/{len(pipelines_to_process)})"
                            )
                    else:
                        failed += 1
                        error_msg = pipeline.error_message or "Unknown error"
                        print(
                            f"✗ Failed: {pipeline.session_name} - {error_msg} ({completed + failed}/{len(pipelines_to_process)})"
                        )
                except Exception as e:
                    failed += 1
                    print(
                        f"✗ Exception in {pipeline.session_name}: {e} ({completed + failed}/{len(pipelines_to_process)})"
                    )

                # Print progress every 10 completions (or every 50 in dry-run)
                progress_interval = 50 if self.dry_run else 10
                if (completed + failed) % progress_interval == 0:
                    self.print_progress(total_queries)

        # Final progress report
        self.print_progress(total_queries)

        print(f"\n{'=' * 70}")
        print(f"Processing complete!")
        print(f"  Finished: {completed}")
        print(f"  Failed: {failed}")
        print(f"{'=' * 70}")

        if not self.dry_run:
            print(f"\nResults directory: {self.results_dir}")
            print(f"SARIF file list: {self.sarif_list_file}")
            print(f"State file: {self.state_file}")

        return failed == 0


def main():
    parser = argparse.ArgumentParser(
        description="Run MRVA sessions for all queries in a CodeQL query suite (Pipeline-based v2)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage
  python run-gh-mrva-for-query-suite.py \\
    --query-suite codeql/misra-cpp-coding-standards@2.50.0 \\
    --output-base-dir ./mrva \\
    --session-prefix t1-misra-cpp-default \\
    --language cpp \\
    --repository-list cpp_top_1000

  # With local query suite file
  python run-gh-mrva-for-query-suite.py \\
    --query-suite ../../cpp/misra/src/codeql-suites/misra-cpp-default.qls \\
    --output-base-dir ./mrva \\
    --session-prefix t1-misra-cpp-default \\
    --language cpp \\
    --repository-list cpp_top_1000 \\
    --max-concurrent 10

  # Dry run
  python run-gh-mrva-for-query-suite.py \\
    --query-suite ../../cpp/autosar/src/codeql-suites/autosar-default.qls \\
    --output-base-dir ./mrva \\
    --session-prefix t1-autosar-cpp-default \\
    --language cpp \\
    --repository-list cpp_top_1000 \\
    --dry-run
        """,
    )

    parser.add_argument(
        "--query-suite",
        required=True,
        help="CodeQL query suite - either a pack reference or path to .qls file",
    )
    parser.add_argument(
        "--output-base-dir",
        required=True,
        type=Path,
        help="Base directory for output files and session state",
    )
    parser.add_argument(
        "--session-prefix",
        required=True,
        help="Prefix for MRVA session names (e.g., t1-misra-cpp-default)",
    )
    parser.add_argument(
        "--language",
        required=True,
        choices=["cpp", "c", "java", "javascript", "python", "go", "csharp"],
        help="Programming language for analysis",
    )
    parser.add_argument(
        "--repository-list", required=True, help="Repository list for MRVA (e.g., cpp_top_1000)"
    )
    parser.add_argument(
        "--max-concurrent",
        type=int,
        default=20,
        help="Maximum number of concurrent pipeline workers (default: 20)",
    )
    parser.add_argument(
        "--check-interval",
        type=int,
        default=300,
        help="Interval in seconds between status checks (default: 300)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands that would be executed without actually running them",
    )

    args = parser.parse_args()

    print("MRVA Query Suite Runner (Pipeline-based v2)")
    print("=" * 70)
    print(f"Run started: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}")
    print(f"Query suite: {args.query_suite}")
    print(f"Output directory: {args.output_base_dir}")
    print(f"Session prefix: {args.session_prefix}")
    print(f"Language: {args.language}")
    print(f"Repository list: {args.repository_list}")
    print(f"Max concurrent: {args.max_concurrent}")
    print(f"Monitor interval: {args.check_interval} seconds")
    if args.dry_run:
        print("DRY RUN MODE: No submissions or downloads will occur")
    print()

    # Validate dependencies
    if not args.dry_run:
        try:
            subprocess.run(["gh", "mrva", "--help"], capture_output=True, check=True)
            print("✓ GitHub CLI with mrva extension is available")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ Error: GitHub CLI with mrva extension not found")
            sys.exit(1)

        try:
            subprocess.run(["codeql", "--version"], capture_output=True, check=True)
            print("✓ CodeQL CLI is available")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ Error: CodeQL CLI not found")
            sys.exit(1)
    else:
        print("✓ [DRY RUN] Skipping dependency validation")

    print()

    # Create and run manager
    manager = MRVAManager(
        query_suite=args.query_suite,
        output_base_dir=args.output_base_dir,
        session_prefix=args.session_prefix,
        language=args.language,
        repository_list=args.repository_list,
        max_concurrent=args.max_concurrent,
        check_interval=args.check_interval,
        dry_run=args.dry_run,
    )

    try:
        success = manager.run_until_complete()
        sys.exit(0 if success else 1)

    except KeyboardInterrupt:
        print(f"\n\nInterrupted by user")
        print(f"Session state saved to: {manager.state_file}")
        print(f"You can resume by running the script again with the same parameters")
        sys.exit(130)


if __name__ == "__main__":
    main()
