"""Re-generate query help files in two stages without needing docling.

This script reuses the existing .misra-rule-cache/<standard>.json
(produced by a prior dump_rules_json.py run) to:

  Stage 1: Deterministically re-render every .md from the cached rule
           data via render_help().
  Patch:   Update the cache JSON with current existing_md content and
           implementation_scope from rule_packages/*.json.
  Stage 2: Run rewrite_help.py (LLM lint/proofread) over the patched
           cache.

Usage:
    python refresh_help.py --standard MISRA-C-2012
    python refresh_help.py --standard MISRA-C++-2023
    python refresh_help.py --standard MISRA-C-2012 --stage1-only
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).parent))
from extract_rules import Rule, render_help, _format_code_lines  # noqa: E402

SCRIPT_DIR = Path(__file__).resolve().parent
QUERY_REPO = SCRIPT_DIR.parents[2]
DEFAULT_HELP_REPO = QUERY_REPO.parent / "codeql-coding-standards-help"

STANDARD_INFO = {
    "MISRA-C-2012": ("c", "c/misra/src/rules"),
    "MISRA-C-2023": ("c", "c/misra/src/rules"),
    "MISRA-C++-2023": ("cpp", "cpp/misra/src/rules"),
}


def _rule_from_json(d: dict[str, Any]) -> Rule:
    """Reconstruct a Rule from the cache JSON dict."""
    r = Rule(
        rule_id=d["rule_id"],
        raw_id=d["raw_id"],
        standard=d["standard"],
        title=d["title"],
        category=d.get("category", ""),
        analysis=d.get("analysis", ""),
        applies_to=d.get("applies_to", ""),
        amplification=d.get("amplification", ""),
        rationale=d.get("rationale", ""),
        exceptions=d.get("exceptions", []),
        example=d.get("example", ""),
        see_also=d.get("see_also", []),
    )
    # Restore example_layout if present.
    layout = d.get("example_layout", [])
    if layout:
        r._example_layout = [(item["kind"], item["text"]) for item in layout]
    return r


def _load_impl_scope_lookup(
    query_repo: Path, standard: str,
) -> dict[tuple[str, str], dict]:
    """Build (rule_id, short_name) -> implementation_scope from rule_packages."""
    lang, _ = STANDARD_INFO[standard]
    pkg_dir = query_repo / "rule_packages" / lang
    if not pkg_dir.is_dir():
        return {}
    lookup: dict[tuple[str, str], dict] = {}
    for pkg_file in sorted(pkg_dir.glob("*.json")):
        try:
            data = json.loads(pkg_file.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        for _std_key, rules in data.items():
            if not isinstance(rules, dict):
                continue
            for rule_id, rule_data in rules.items():
                if not isinstance(rule_data, dict):
                    continue
                for q in rule_data.get("queries", []):
                    sn = q.get("short_name")
                    impl = q.get("implementation_scope")
                    if sn and impl:
                        lookup[(rule_id, sn)] = impl
    return lookup


def stage1_render(cache: dict, help_repo: Path) -> tuple[int, int]:
    """Re-render all .md files from cached rule data. Returns (wrote, skipped)."""
    lang = cache["lang"]
    rules_json = cache["rules"]
    queries_json = cache["queries"]

    wrote = skipped = 0
    for rule_id, query_list in sorted(queries_json.items()):
        rule_data = rules_json.get(rule_id)
        if not rule_data:
            skipped += len(query_list)
            continue
        rule = _rule_from_json(rule_data)
        body = render_help(rule, lang)
        for q in query_list:
            md_path = help_repo / q["md_path"]
            md_path.parent.mkdir(parents=True, exist_ok=True)
            md_path.write_text(body, encoding="utf-8")
            wrote += 1

    return wrote, skipped


def patch_cache(
    cache: dict, help_repo: Path, query_repo: Path, standard: str,
) -> dict:
    """Update existing_md and add implementation_scope to the cache."""
    impl_lookup = _load_impl_scope_lookup(query_repo, standard)
    queries_json = cache["queries"]

    for rule_id, query_list in queries_json.items():
        for q in query_list:
            md_path = help_repo / q["md_path"]
            try:
                q["existing_md"] = md_path.read_text(encoding="utf-8")
            except FileNotFoundError:
                q["existing_md"] = None

            # Add implementation_scope from rule_packages.
            ql_stem = Path(q["ql_path"]).stem
            impl = impl_lookup.get((rule_id, ql_stem))
            if impl:
                q["implementation_scope"] = impl
            elif "implementation_scope" in q:
                del q["implementation_scope"]

    return cache


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--standard", required=True, choices=sorted(STANDARD_INFO))
    p.add_argument("--help-repo", type=Path, default=DEFAULT_HELP_REPO)
    p.add_argument("--query-repo", type=Path, default=QUERY_REPO)
    p.add_argument("--stage1-only", action="store_true",
                   help="Only run deterministic stage 1 (no LLM).")
    p.add_argument("--model", default=None,
                   help="Copilot model id for stage 2.")
    args = p.parse_args()

    help_repo = args.help_repo.resolve()
    cache_path = help_repo / ".misra-rule-cache" / f"{args.standard}.json"
    if not cache_path.exists():
        print(f"Cache not found: {cache_path}", file=sys.stderr)
        return 2

    cache = json.loads(cache_path.read_text(encoding="utf-8"))
    total_queries = sum(len(v) for v in cache["queries"].values())
    print(f"Loaded cache: {len(cache['rules'])} rules, {total_queries} queries")

    # Stage 1: deterministic render.
    print("\n=== Stage 1: deterministic render ===")
    wrote, skipped = stage1_render(cache, help_repo)
    print(f"Stage 1 done: wrote={wrote} skipped={skipped}")

    # Patch cache with fresh existing_md + implementation_scope.
    print("\n=== Patching cache ===")
    cache = patch_cache(cache, help_repo, args.query_repo, args.standard)
    cache_path.write_text(
        json.dumps(cache, indent=2, ensure_ascii=False), encoding="utf-8")
    impl_count = sum(
        1 for qs in cache["queries"].values()
        for q in qs if q.get("implementation_scope")
    )
    print(f"Cache updated: implementation_scope on {impl_count} queries")

    if args.stage1_only:
        print("\n--stage1-only: skipping LLM pass.")
        return 0

    # Stage 2: LLM lint/proofread via rewrite_help.py.
    print("\n=== Stage 2: LLM lint/proofread ===")
    cmd = [
        sys.executable,
        str(SCRIPT_DIR / "rewrite_help.py"),
        "--standard", args.standard,
        "--help-repo", str(help_repo),
    ]
    if args.model:
        cmd += ["--model", args.model]
    print(f"Running: {' '.join(cmd)}")
    return subprocess.call(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
