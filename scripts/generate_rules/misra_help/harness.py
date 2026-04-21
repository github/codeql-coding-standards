"""Determinism harness for the MISRA help generator.

Runs the docling → extract → render pipeline `N` times and reports per-rule,
per-section variance. Intended workflow:

  python harness.py --pdf <pdf> --standard <std> -n 5

For each iteration:
  - clears the docling JSON cache (so docling re-runs end-to-end)
  - extracts every rule
  - hashes every section field per rule
  - hashes the full rendered .md per rule
  - records all hashes

After N iterations, emits a JSON report and a brief summary:
  - per-section: count of rules where ALL N runs agreed
  - per-rule: list of sections that diverged
  - hash table sizes per rule (1 == deterministic, >1 == flaky)

This intentionally focuses on *output variance*, not on backend variance:
the goal is "given this codebase, are the rendered help files reproducible?"
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
import sys
import time
from collections import Counter, defaultdict
from dataclasses import asdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from extract_rules import extract_rules, render_help, to_dict, STD_DISPLAY  # noqa: E402

SECTIONS = (
    "category", "analysis", "applies_to",
    "amplification", "rationale", "exceptions",
    "example", "see_also",
    "_rendered",  # the full .md output
)


def _hash(value) -> str:
    if isinstance(value, list):
        s = "\n\u241e\n".join(value)
    else:
        s = str(value)
    return hashlib.sha256(s.encode("utf-8")).hexdigest()[:16]


def run_once(pdf: Path, standard: str, cache_dir: Path, lang: str) -> dict[str, dict[str, str]]:
    """Return rule_id -> {section: hash}."""
    rules = extract_rules(pdf, standard, cache_dir)
    out: dict[str, dict[str, str]] = {}
    for r in rules:
        d = to_dict(r)
        rendered = render_help(r, lang)
        hashes = {}
        for sec in SECTIONS:
            if sec == "_rendered":
                hashes[sec] = _hash(rendered)
            else:
                hashes[sec] = _hash(d.get(sec, ""))
        out[r.rule_id] = hashes
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pdf", required=True)
    ap.add_argument("--standard", required=True, choices=list(STD_DISPLAY))
    ap.add_argument("-n", "--iterations", type=int, default=3)
    ap.add_argument("--cache-dir", default="/tmp/misra-pdf-probe/det-cache")
    ap.add_argument("--keep-cache", action="store_true",
                    help="do NOT clear docling cache between runs (tests just the post-docling stages)")
    ap.add_argument("--report", default="/tmp/misra-pdf-probe/determinism-report.json")
    args = ap.parse_args()

    cache = Path(args.cache_dir)
    cache.mkdir(parents=True, exist_ok=True)

    all_runs: list[dict[str, dict[str, str]]] = []
    timings: list[float] = []
    for i in range(args.iterations):
        if not args.keep_cache:
            for f in cache.glob("*.docling.json"):
                f.unlink()
        t0 = time.time()
        run = run_once(Path(args.pdf), args.standard, cache,
                       "cpp" if "C++" in args.standard else "c")
        timings.append(time.time() - t0)
        print(f"  iter {i+1}/{args.iterations}: {len(run)} rules, {timings[-1]:.1f}s")
        all_runs.append(run)

    # Aggregate.
    rule_ids = sorted({rid for run in all_runs for rid in run.keys()})
    rules_in_all_runs = [r for r in rule_ids if all(r in run for run in all_runs)]
    rules_missing_in_some = [r for r in rule_ids if r not in rules_in_all_runs]

    section_pass: Counter[str] = Counter()
    section_total: Counter[str] = Counter()
    rule_diverged: dict[str, list[str]] = defaultdict(list)
    rule_hashes: dict[str, dict[str, list[str]]] = {}

    for rid in rules_in_all_runs:
        per_sec: dict[str, list[str]] = {}
        for sec in SECTIONS:
            hs = [run[rid][sec] for run in all_runs]
            per_sec[sec] = hs
            section_total[sec] += 1
            if len(set(hs)) == 1:
                section_pass[sec] += 1
            else:
                rule_diverged[rid].append(sec)
        rule_hashes[rid] = per_sec

    summary = {
        "iterations": args.iterations,
        "pdf": args.pdf,
        "standard": args.standard,
        "rule_count_per_iter": [len(run) for run in all_runs],
        "rules_in_all_runs": len(rules_in_all_runs),
        "rules_missing_in_some_runs": rules_missing_in_some,
        "rule_count_stable": len(set(len(run) for run in all_runs)) == 1,
        "section_determinism": {
            sec: {
                "stable": section_pass[sec],
                "total": section_total[sec],
                "pct": (100.0 * section_pass[sec] / section_total[sec]) if section_total[sec] else 0.0,
            }
            for sec in SECTIONS
        },
        "rules_with_divergence": [
            {"rule_id": rid, "diverging_sections": secs} for rid, secs in sorted(rule_diverged.items())
        ],
        "iteration_seconds": timings,
    }

    Path(args.report).write_text(json.dumps(
        {"summary": summary, "rule_hashes": rule_hashes},
        indent=2,
    ), encoding="utf-8")

    print("\n=== Determinism summary ===")
    print(f"  iterations:            {args.iterations}")
    print(f"  pdf:                   {args.pdf}")
    print(f"  rule count/iter:       {summary['rule_count_per_iter']}")
    print(f"  rules in all runs:     {summary['rules_in_all_runs']}")
    if rules_missing_in_some:
        print(f"  rules missing in some: {rules_missing_in_some[:10]} ...")
    print(f"  per-section stability:")
    for sec, s in summary["section_determinism"].items():
        bar = "#" * int(s["pct"] / 5)
        print(f"    {sec:14s} {s['stable']:>4d}/{s['total']:<4d} {s['pct']:6.2f}% {bar}")
    print(f"  rules with any divergence: {len(rule_diverged)}")
    if rule_diverged:
        sample = list(rule_diverged.items())[:5]
        for rid, secs in sample:
            print(f"    {rid}: {secs}")
    print(f"  per-iteration time:    {[f'{t:.1f}s' for t in timings]}")
    print(f"  full report:           {args.report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
