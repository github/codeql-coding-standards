#!/usr/bin/env python3
"""
github/codeql-coding-standards:scripts/es-sarif/run-gh-mrva-for-query-suite.py

MRVA = Multi-Repository Vulnerability Analysis => scale one CodeQL query to many (1000s of) repos.

This script creates a MRVA session for each query in a given query suite and manages
the execution lifecycle including submission, monitoring, and downloading of results.
The script can optionally load SARIF results into an Elasticsearch index for analysis.

This script expects that the `mrva` extension has already been installed for the
`gh` CLI tool, such that `gh mrva` commands can be executed.

Usage:
    python run-gh-mrva-for-query-suite.py --query-suite <suite> --output-base-dir <dir> [options]

Requirements:
    - GitHub CLI with mrva extension installed
    - CodeQL CLI available in PATH
    - Python 3.11+
    - Optional: Elasticsearch for result indexing
"""

import sys
import json
import os
import argparse
import subprocess
import time
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime
import re


class MRVASession:
    """Represents a single MRVA session for a CodeQL query."""
    
    def __init__(self, query_path: str, session_name: str, language: str):
        self.query_path = query_path
        self.session_name = session_name
        self.language = language
        self.status = "not_started"  # not_started, submitted, in_progress, completed, download_in_progress, downloaded, failed
        self.submitted_at: Optional[datetime] = None
        self.completed_at: Optional[datetime] = None
        self.downloaded_at: Optional[datetime] = None
        self.output_dir: Optional[Path] = None
        self.error_message: Optional[str] = None
        self.run_stats: Optional[Dict] = None  # Track run-level statistics
    
    def to_dict(self) -> Dict:
        """Convert session to dictionary for JSON serialization."""
        return {
            "query_path": self.query_path,
            "session_name": self.session_name,
            "language": self.language,
            "status": self.status,
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "downloaded_at": self.downloaded_at.isoformat() if self.downloaded_at else None,
            "output_dir": str(self.output_dir) if self.output_dir else None,
            "error_message": self.error_message,
            "run_stats": self.run_stats
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'MRVASession':
        """Create session from dictionary."""
        session = cls(data["query_path"], data["session_name"], data["language"])
        session.status = data["status"]
        session.submitted_at = datetime.fromisoformat(data["submitted_at"]) if data["submitted_at"] else None
        session.completed_at = datetime.fromisoformat(data["completed_at"]) if data["completed_at"] else None
        session.downloaded_at = datetime.fromisoformat(data["downloaded_at"]) if data.get("downloaded_at") else None
        session.output_dir = Path(data["output_dir"]) if data["output_dir"] else None
        session.error_message = data.get("error_message")
        session.run_stats = data.get("run_stats")
        return session


class MRVAManager:
    """Manages multiple MRVA sessions for a query suite."""
    
    def __init__(self, query_suite: str, output_base_dir: Path, session_prefix: str, 
                 language: str, repository_list: str, max_concurrent: int = 20, dry_run: bool = False):
        self.query_suite = query_suite
        self.output_base_dir = output_base_dir
        self.session_prefix = session_prefix
        self.language = language
        self.repository_list = repository_list
        self.max_concurrent = max_concurrent
        self.dry_run = dry_run
        self.sessions: Dict[str, MRVASession] = {}
        self.state_file = output_base_dir / f"{session_prefix}_state.json"
        
        # Create output directory
        if not self.dry_run:
            self.output_base_dir.mkdir(parents=True, exist_ok=True)
        
        # Load existing state if available
        if not self.dry_run:
            self._load_state()
    
    def _load_state(self):
        """Load existing session state from file."""
        if self.state_file.exists():
            try:
                with open(self.state_file, 'r') as f:
                    state_data = json.load(f)
                    for session_data in state_data.get("sessions", []):
                        session = MRVASession.from_dict(session_data)
                        self.sessions[session.session_name] = session
                print(f"✓ Loaded {len(self.sessions)} existing sessions from state file")
            except Exception as e:
                print(f"Warning: Could not load state file: {e}")
    
    def _save_state(self):
        """Save current session state to file."""
        state_data = {
            "query_suite": self.query_suite,
            "session_prefix": self.session_prefix,
            "language": self.language,
            "repository_list": self.repository_list,
            "updated_at": datetime.utcnow().isoformat(),
            "sessions": [session.to_dict() for session in self.sessions.values()]
        }
        
        with open(self.state_file, 'w') as f:
            json.dump(state_data, f, indent=2)
    
    def resolve_queries(self) -> List[str]:
        """Resolve query files from the query suite using CodeQL CLI."""
        print(f"Resolving queries from suite: {self.query_suite}")
        
        try:
            result = subprocess.run(
                ["codeql", "resolve", "queries", "--", self.query_suite],
                capture_output=True, text=True, check=True
            )
            
            query_paths = []
            for line in result.stdout.strip().split('\n'):
                line = line.strip()
                if line and line.endswith('.ql'):
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
        # Extract query name from path
        query_name = Path(query_path).stem
        # Sanitize for session name
        sanitized = re.sub(r'[^a-zA-Z0-9\-_]', '-', query_name)
        return f"{self.session_prefix}-{sanitized}"
    
    def _get_active_sessions_count(self) -> int:
        """Count sessions that are currently running."""
        return len([s for s in self.sessions.values() 
                   if s.status in ["submitted", "in_progress"]])
    
    def _can_submit_new_session(self) -> bool:
        """Check if we can submit a new session based on concurrency limits."""
        return self._get_active_sessions_count() < self.max_concurrent
    
    def submit_session(self, query_path: str) -> bool:
        """Submit a new MRVA session for a query."""
        session_name = self._generate_session_name(query_path)
        
        if session_name in self.sessions:
            session = self.sessions[session_name]
            if session.status in ["completed", "failed"]:
                print(f"Session {session_name} already processed, skipping")
                return True
            elif session.status in ["submitted", "in_progress"]:
                print(f"Session {session_name} already active, skipping")
                return True
        
        # Create new session
        session = MRVASession(query_path, session_name, self.language)
        
        if not self.dry_run:
            print(f"  Submitting: {session_name}")
        else:
            print(f"  [DRY RUN] Would submit: {session_name}")
        
        try:
            # Submit the MRVA session - use -q/--query flag as per CLI help
            cmd = [
                "gh", "mrva", "submit",
                "--language", self.language,
                "--session", session_name,
                "--list", self.repository_list,
                "--query", query_path
            ]
            
            if self.dry_run:
                print(f"     Command: {' '.join(cmd)}")
                session.status = "submitted"
                session.submitted_at = datetime.utcnow()
                self.sessions[session_name] = session
                return True
            
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            
            session.status = "submitted"
            session.submitted_at = datetime.utcnow()
            self.sessions[session_name] = session
            
            self._save_state()
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"     ✗ Failed to submit: {e}")
            if e.stderr:
                print(f"     STDERR: {e.stderr}")
            
            session.status = "failed"
            session.error_message = str(e)
            self.sessions[session_name] = session
            if not self.dry_run:
                self._save_state()
            return False
    
    def check_session_status(self, session_name: str) -> Optional[str]:
        """Check the status of a specific session."""
        if self.dry_run:
            # In dry run mode, simulate status progression
            return "in_progress"
            
        try:
            result = subprocess.run(
                ["gh", "mrva", "status", "--json", "--session", session_name],
                capture_output=True, text=True, check=True
            )
            
            status_data = json.loads(result.stdout)
            # The status JSON is a list with one element containing session info
            if status_data and len(status_data) > 0:
                session_info = status_data[0]
                return session_info.get("status", "unknown")
            return None
            
        except subprocess.CalledProcessError:
            return None
        except json.JSONDecodeError:
            return None
    
    def get_session_details(self, session_name: str) -> Optional[Dict]:
        """Get detailed information about a session including run statuses."""
        if self.dry_run:
            # In dry run mode, simulate session details
            return {
                "name": session_name,
                "status": "in_progress",
                "runs": [
                    {"id": 12345, "status": "succeeded", "query": "sample.ql"},
                    {"id": 12346, "status": "in_progress", "query": "sample2.ql"}
                ]
            }
            
        try:
            result = subprocess.run(
                ["gh", "mrva", "status", "--json", "--session", session_name],
                capture_output=True, text=True, check=True
            )
            
            status_data = json.loads(result.stdout)
            if status_data and len(status_data) > 0:
                return status_data[0]
            return None
            
        except subprocess.CalledProcessError:
            return None
        except json.JSONDecodeError:
            return None
    
    def update_session_statuses(self):
        """Update the status of all active sessions."""
        active_sessions = [s for s in self.sessions.values() 
                          if s.status in ["submitted", "in_progress"]]
        
        if not active_sessions:
            return
        
        print(f"\nChecking status of {len(active_sessions)} active sessions...")
        
        for session in active_sessions:
            session_details = self.get_session_details(session.session_name)
            if session_details:
                old_status = session.status
                new_status = session_details.get("status", "unknown")
                
                # Update session status
                session.status = new_status
                
                # Extract and store run statistics
                runs = session_details.get("runs", [])
                if runs:
                    run_stats = {
                        "total": len(runs),
                        "succeeded": len([r for r in runs if r.get("status") == "succeeded"]),
                        "failed": len([r for r in runs if r.get("status") == "failed"]),
                        "in_progress": len([r for r in runs if r.get("status") == "in_progress"]),
                        "pending": len([r for r in runs if r.get("status") == "pending"])
                    }
                    session.run_stats = run_stats
                
                # Check if session is completed
                if new_status == "completed" and old_status != "completed":
                    session.completed_at = datetime.utcnow()
                    print(f"  ✓ Session completed: {session.session_name}")
                    if session.run_stats:
                        print(f"    Runs: {session.run_stats['succeeded']}/{session.run_stats['total']} succeeded, {session.run_stats['failed']} failed")
                elif new_status == "failed" and old_status != "failed":
                    session.error_message = "Session failed"
                    print(f"  ✗ Session failed: {session.session_name}")
                elif new_status != old_status:
                    print(f"  Status update: {session.session_name} -> {new_status}")
                
                # For in_progress sessions, show run details
                if new_status == "in_progress" and session.run_stats:
                    print(f"  {session.session_name}: {session.run_stats['succeeded']}/{session.run_stats['total']} runs completed, {session.run_stats['in_progress']} in progress")
        
        if not self.dry_run:
            self._save_state()
    
    def download_completed_sessions(self):
        """Download results for completed sessions."""
        completed_sessions = [s for s in self.sessions.values() 
                             if s.status == "completed" and not s.output_dir]
        
        if not completed_sessions:
            return
        
        print(f"\n{'[DRY RUN] ' if self.dry_run else ''}Downloading results for {len(completed_sessions)} completed sessions...")
        
        for session in completed_sessions:
            output_dir = self.output_base_dir / "sessions" / session.session_name
            
            try:
                # Mark as download in progress
                session.status = "download_in_progress"
                if not self.dry_run:
                    self._save_state()
                
                cmd = [
                    "gh", "mrva", "download",
                    "--session", session.session_name,
                    "--output-dir", str(output_dir)
                ]
                
                if self.dry_run:
                    print(f"  Command: {' '.join(cmd)}")
                    session.output_dir = output_dir
                    session.status = "downloaded"
                    session.downloaded_at = datetime.utcnow()
                    print(f"  ✓ [DRY RUN] Would download results: {session.session_name} -> {output_dir}")
                    continue
                
                print(f"  Downloading: {session.session_name}...")
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)
                
                session.output_dir = output_dir
                session.status = "downloaded"
                session.downloaded_at = datetime.utcnow()
                print(f"  ✓ Downloaded results: {session.session_name} -> {output_dir}")
                
            except subprocess.CalledProcessError as e:
                print(f"  ✗ Failed to download {session.session_name}: {e}")
                print(f"     STDERR: {e.stderr}")
                session.status = "completed"  # Revert to completed so we can retry
                session.error_message = f"Download failed: {e}"
        
        if not self.dry_run:
            self._save_state()
    
    def get_status_summary(self) -> Dict[str, int]:
        """Get a summary of session statuses."""
        summary = {}
        for session in self.sessions.values():
            summary[session.status] = summary.get(session.status, 0) + 1
        return summary
    
    def print_detailed_progress(self, remaining_queries: List[str]):
        """Print detailed progress information about all sessions."""
        summary = self.get_status_summary()
        
        # Calculate various counts
        not_started = len(remaining_queries)
        submitted = summary.get("submitted", 0)
        in_progress = summary.get("in_progress", 0)
        completed_not_downloaded = summary.get("completed", 0)
        download_in_progress = summary.get("download_in_progress", 0)
        downloaded = summary.get("downloaded", 0)
        failed = summary.get("failed", 0)
        
        total_queries = len(self.sessions) + not_started
        total_processed = submitted + in_progress + completed_not_downloaded + download_in_progress + downloaded + failed
        
        print("\n" + "=" * 70)
        print(f"PROGRESS REPORT - {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}")
        print("=" * 70)
        print(f"Total queries in suite:           {total_queries}")
        print(f"  Not yet submitted:              {not_started}")
        print(f"  Submitted (pending):            {submitted}")
        print(f"  MRVA runs in progress:          {in_progress}")
        print(f"  MRVA completed (not downloaded):{completed_not_downloaded}")
        print(f"  Download in progress:           {download_in_progress}")
        print(f"  Downloaded (complete):          {downloaded}")
        print(f"  Failed/Errored:                 {failed}")
        print("-" * 70)
        print(f"Total processed:                  {total_processed}/{total_queries}")
        print(f"Completion rate:                  {(downloaded / total_queries * 100):.1f}%")
        
        # Show detailed run statistics for in-progress sessions
        in_progress_sessions = [s for s in self.sessions.values() if s.status == "in_progress"]
        if in_progress_sessions:
            print("\nIn-Progress Sessions:")
            for session in in_progress_sessions[:10]:  # Show first 10
                if session.run_stats:
                    stats = session.run_stats
                    print(f"  {session.session_name}:")
                    print(f"    Runs: {stats['succeeded']}/{stats['total']} succeeded, "
                          f"{stats['in_progress']} in progress, {stats['failed']} failed")
            if len(in_progress_sessions) > 10:
                print(f"  ... and {len(in_progress_sessions) - 10} more in-progress sessions")
        
        # Show recently completed sessions
        completed_sessions = [s for s in self.sessions.values() 
                             if s.status == "completed" and s.completed_at]
        if completed_sessions:
            recent = sorted(completed_sessions, key=lambda s: s.completed_at, reverse=True)[:5]
            print("\nRecently Completed (awaiting download):")
            for session in recent:
                elapsed = (datetime.utcnow() - session.completed_at).total_seconds() / 60
                print(f"  {session.session_name} (completed {elapsed:.1f} minutes ago)")
        
        # Show failed sessions
        failed_sessions = [s for s in self.sessions.values() if s.status == "failed"]
        if failed_sessions:
            print("\nFailed Sessions:")
            for session in failed_sessions[:5]:  # Show first 5
                print(f"  {session.session_name}")
                if session.error_message:
                    print(f"    Error: {session.error_message}")
            if len(failed_sessions) > 5:
                print(f"  ... and {len(failed_sessions) - 5} more failed sessions")
        
        print("=" * 70)
        print()
    
    def run_until_complete(self, check_interval: int = 300) -> bool:
        """Run the MRVA manager until all sessions are complete."""
        # Resolve queries and create sessions
        query_paths = self.resolve_queries()
        
        print(f"{'[DRY RUN] ' if self.dry_run else ''}Planning to submit {len(query_paths)} MRVA sessions...")
        print(f"Session prefix: {self.session_prefix}")
        print(f"Max concurrent sessions: {self.max_concurrent}")
        print(f"Check interval: {check_interval} seconds")
        print()
        
        if self.dry_run:
            print("DRY RUN MODE: Commands will be printed but not executed")
            print()
        
        # Submit initial batch of sessions
        print(f"Submitting initial batch of up to {self.max_concurrent} sessions...")
        submitted_count = 0
        for query_path in query_paths:
            if not self._can_submit_new_session():
                break
            
            if self.submit_session(query_path):
                submitted_count += 1
                if not self.dry_run:
                    time.sleep(1)  # Brief pause between submissions
        
        print(f"\nInitial submission complete: {submitted_count} sessions submitted")
        print(f"Remaining to submit when capacity available: {len(query_paths) - submitted_count}")
        print()
        
        if self.dry_run:
            print("\nDRY RUN: Stopping here. In real execution, the script would continue monitoring sessions.")
            return True
        
        # Main monitoring loop
        remaining_queries = [q for q in query_paths 
                           if self._generate_session_name(q) not in self.sessions]
        
        iteration = 0
        while True:
            iteration += 1
            
            # Print detailed progress report
            self.print_detailed_progress(remaining_queries)
            
            # Update status of active sessions
            self.update_session_statuses()
            
            # Download completed sessions
            self.download_completed_sessions()
            
            # Submit new sessions if we have capacity
            while remaining_queries and self._can_submit_new_session():
                query_path = remaining_queries.pop(0)
                if self.submit_session(query_path):
                    time.sleep(1)
            
            # Check if we're done
            active_count = self._get_active_sessions_count()
            completed_not_downloaded = len([s for s in self.sessions.values() 
                                           if s.status == "completed"])
            download_in_progress = len([s for s in self.sessions.values() 
                                       if s.status == "download_in_progress"])
            
            if not remaining_queries and active_count == 0 and completed_not_downloaded == 0 and download_in_progress == 0:
                print("\n✓ All sessions completed and downloaded!")
                break
            
            # Wait before next check
            print(f"Iteration {iteration} complete. Waiting {check_interval} seconds before next check...")
            time.sleep(check_interval)
        
        # Final summary
        final_summary = self.get_status_summary()
        print(f"\nFinal summary: {final_summary}")
        
        return final_summary.get("completed", 0) > 0


def main():
    parser = argparse.ArgumentParser(
        description="Run MRVA sessions for all queries in a CodeQL query suite",
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

  # With custom concurrency
  python run-gh-mrva-for-query-suite.py \\
    --query-suite ../../cpp/misra/src/codeql-suites/misra-c-default.qls \\
    --output-base-dir ./mrva \\
    --session-prefix t1-misra-c-default \\
    --language c \\
    --repository-list cpp_top_1000 \\
    --max-concurrent 10

  # Dry run to validate commands
  python run-gh-mrva-for-query-suite.py \\
    --query-suite ../../cpp/misra/src/codeql-suites/misra-cpp-default.qls \\
    --output-base-dir ./mrva \\
    --session-prefix t1-misra-cpp-default \\
    --language cpp \\
    --repository-list cpp_top_1000 \\
    --dry-run
        """
    )
    
    parser.add_argument(
        "--query-suite", required=True,
        help="CodeQL query suite - either a pack reference (e.g., codeql/misra-cpp-coding-standards@2.50.0) or path to .qls file (e.g., ../../cpp/misra/src/codeql-suites/misra-cpp-default.qls)"
    )
    parser.add_argument(
        "--output-base-dir", required=True, type=Path,
        help="Base directory for output files and session state"
    )
    parser.add_argument(
        "--session-prefix", required=True,
        help="Prefix for MRVA session names (e.g., t1-misra-cpp-default)"
    )
    parser.add_argument(
        "--language", required=True, choices=["cpp", "c", "java", "javascript", "python", "go", "csharp"],
        help="Programming language for analysis"
    )
    parser.add_argument(
        "--repository-list", required=True,
        help="Repository list for MRVA (e.g., cpp_top_1000)"
    )
    parser.add_argument(
        "--max-concurrent", type=int, default=20,
        help="Maximum number of concurrent MRVA sessions (default: 20)"
    )
    parser.add_argument(
        "--check-interval", type=int, default=300,
        help="Interval in seconds between status checks (default: 300)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print commands that would be executed without actually running them"
    )
    
    args = parser.parse_args()
    
    print("MRVA Query Suite Runner")
    print("=" * 50)
    print(f"Query suite: {args.query_suite}")
    print(f"Output directory: {args.output_base_dir}")
    print(f"Session prefix: {args.session_prefix}")
    print(f"Language: {args.language}")
    print(f"Repository list: {args.repository_list}")
    print(f"Max concurrent: {args.max_concurrent}")
    if args.dry_run:
        print("DRY RUN MODE: Commands will be printed but not executed")
    print()
    
    # Validate dependencies
    if not args.dry_run:
        try:
            subprocess.run(["gh", "mrva", "--help"], capture_output=True, check=True)
            print("✓ GitHub CLI with mrva extension is available")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ GitHub CLI with mrva extension is required")
            sys.exit(1)
        
        try:
            subprocess.run(["codeql", "--version"], capture_output=True, check=True)
            print("✓ CodeQL CLI is available")
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("✗ CodeQL CLI is required")
            sys.exit(1)
    else:
        print("✓ [DRY RUN] Skipping dependency validation")
    
    print()
    
    # Create and run MRVA manager
    manager = MRVAManager(
        query_suite=args.query_suite,
        output_base_dir=args.output_base_dir,
        session_prefix=args.session_prefix,
        language=args.language,
        repository_list=args.repository_list,
        max_concurrent=args.max_concurrent,
        dry_run=args.dry_run
    )
    
    try:
        success = manager.run_until_complete(check_interval=args.check_interval)
        
        if success:
            print(f"\n✓ MRVA sessions completed successfully")
            print(f"Results available in: {args.output_base_dir}")
            print(f"State file: {manager.state_file}")
            sys.exit(0)
        else:
            print(f"\n✗ No sessions completed successfully")
            sys.exit(1)
            
    except KeyboardInterrupt:
        print(f"\n\nInterrupted by user")
        print(f"Session state saved to: {manager.state_file}")
        print(f"You can resume by running the script again with the same parameters")
        sys.exit(130)


if __name__ == "__main__":
    main()
