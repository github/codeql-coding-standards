"""Emit a per-standard JSON sidecar containing every extracted MISRA
rule plus, for each `.ql` query that targets the rule, the query's
`@name` title, target `.md` path, and the existing `.md` content (if
any). This file is the input to the agent extension's LLM-driven
"rewrite help docs" pass: docling extracts the structured rule data
deterministically, then the LLM uses both the structured data AND the
.ql title to produce a polished, idiomatic help file.

Output layout:

    <help-repo>/.misra-rule-cache/<standard>.json

Schema (top-level):

    {
      "standard": "MISRA-C-2012",
      "lang": "c",
      "lang_src": "c/misra/src/rules",
      "generated_at": "2026-04-20T10:11:12Z",
      "rules": {
        "RULE-9-2": {
          "rule_id": "RULE-9-2",
          "raw_id": "Rule 9.2",
          "standard": "MISRA-C-2012",
          "title": "...",
          "category": "Required",
          "analysis": "Decidable, Single Translation Unit",
          "applies_to": "C90, C99, C11",
          "amplification": "...",
          "rationale": "...",
          "exceptions": ["...", "..."],
          "example_layout": [
            {"kind": "code", "text": "..."},
            {"kind": "text", "text": "..."}
          ],
          "see_also": [...]
        },
        ...
      },
      "queries": {
        "RULE-9-2": [
          {
            "ql_path": "c/misra/src/rules/RULE-9-2/Init...braces.ql",
            "ql_name_title": "The initializer for an aggregate ...",
            "md_path": "c/misra/src/rules/RULE-9-2/Init...braces.md",
            "existing_md": "..."  // null if the .md does not exist
          },
          ...
        ],
        ...
      }
    }

The `existing_md` content is included so the LLM pass can preserve
human-authored details (alert message wording, special examples) that
docling did not capture.
"""
from __future__ import annotations
import argparse
import datetime as _dt
import json
import sys
from dataclasses import asdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from extract_rules import extract_rules, Rule  # noqa: E402
from populate_help import (  # noqa: E402
    STANDARD_INFO,
    SUPPORTED_STANDARDS,
    DEFAULT_HELP_REPO,
    DEFAULT_QUERY_REPO,
    collect_queries,
    resolve_pdf,
    _read_ql_name,
)


def _rule_to_jsonable(rule: Rule) -> dict:
    """Serialize a Rule to JSON, including the example layout."""
    d = asdict(rule)
    layout = getattr(rule, "_example_layout", None)
    if layout:
        d["example_layout"] = [{"kind": k, "text": s} for (k, s) in layout]
    else:
        d["example_layout"] = []
    return d


def _query_entries(rule_id: str, ql_paths: list[Path],
                   query_repo: Path, help_repo: Path,
                   lang_src: Path) -> list[dict]:
    out: list[dict] = []
    for ql in sorted(ql_paths):
        rel_dir = ql.parent.relative_to(query_repo / lang_src)
        md = help_repo / lang_src / rel_dir / (ql.stem + ".md")
        try:
            existing = md.read_text(encoding="utf-8")
        except FileNotFoundError:
            existing = None
        out.append({
            "ql_path": str(ql.relative_to(query_repo)),
            "ql_name_title": _read_ql_name(ql) or "",
            "md_path": str(md.relative_to(help_repo)),
            "existing_md": existing,
        })
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--standard", required=True, choices=SUPPORTED_STANDARDS)
    ap.add_argument("--query-repo", type=Path, default=DEFAULT_QUERY_REPO)
    ap.add_argument("--help-repo", type=Path, default=DEFAULT_HELP_REPO)
    ap.add_argument("--pdf", type=Path, default=None)
    ap.add_argument("--cache-dir", type=Path,
                    default=Path("/tmp/misra-pdf-probe/repo-cache"),
                    help="docling JSON cache dir")
    ap.add_argument("--output", type=Path, default=None,
                    help="output path (default: "
                         "<help-repo>/.misra-rule-cache/<standard>.json)")
    args = ap.parse_args()

    pdf = resolve_pdf(args.standard, args.pdf, args.help_repo)
    args.cache_dir.mkdir(parents=True, exist_ok=True)
    rules = extract_rules(pdf, args.standard, args.cache_dir)

    lang, lang_src = STANDARD_INFO[args.standard]
    queries = collect_queries(args.query_repo, args.standard)

    rules_json: dict[str, dict] = {}
    for r in rules:
        rules_json[r.rule_id] = _rule_to_jsonable(r)

    queries_json: dict[str, list[dict]] = {}
    for rule_id, ql_paths in queries.items():
        queries_json[rule_id] = _query_entries(
            rule_id, ql_paths, args.query_repo, args.help_repo, lang_src)

    payload = {
        "standard": args.standard,
        "lang": lang,
        "lang_src": str(lang_src),
        "generated_at": _dt.datetime.now(_dt.timezone.utc)
            .strftime("%Y-%m-%dT%H:%M:%SZ"),
        "rules": rules_json,
        "queries": queries_json,
    }

    out_path = args.output or (args.help_repo / ".misra-rule-cache"
                               / f"{args.standard}.json")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False),
                        encoding="utf-8")
    print(f"wrote {out_path} ({len(rules_json)} rules, "
          f"{sum(len(v) for v in queries_json.values())} queries)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
