"""Shared helpers for locating and reading the MISRA rule cache."""
from __future__ import annotations
import json
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_CACHE_DIR = SCRIPT_DIR / "cache"
DEFAULT_HELP_REPO = SCRIPT_DIR.parents[2].parent / "codeql-coding-standards-help"


def cache_path_for(help_repo: Path, standard: str) -> Path:
    """Return the path to the JSON cache file for a standard."""
    return help_repo / ".misra-rule-cache" / f"{standard}.json"


def load_cache(help_repo: Path, standard: str) -> dict[str, Any]:
    """Load and return the JSON cache for a standard."""
    path = cache_path_for(help_repo, standard)
    if not path.exists():
        raise FileNotFoundError(
            f"Cache not found: {path}. Run dump_rules_json.py first."
        )
    return json.loads(path.read_text(encoding="utf-8"))


def save_cache(help_repo: Path, standard: str, data: dict[str, Any]) -> Path:
    """Write the JSON cache for a standard and return the path."""
    path = cache_path_for(help_repo, standard)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return path
