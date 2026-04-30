"""Populate `codeql-coding-standards-help/{c,cpp}/misra/src/rules/...` from the
two MISRA PDFs that the user supplies (the PDFs are gitignored / not shipped).

For each `.ql` query under `<repo>/{c,cpp}/misra/src/rules/RULE-X-Y[-Z]/<Name>.ql`,
this writes `<help-repo>/{c,cpp}/misra/src/rules/RULE-X-Y[-Z]/<Name>.md` using
content extracted by `extract_rules.py` (deterministic, docling-based).

Behaviour:
  - existing .md files are NEVER overwritten unless --overwrite is passed
  - missing rule_ids are reported but do not abort
  - dry-run mode (--dry-run) prints what would be written

Standards covered:
  - MISRA-C-2023 (C queries)         ← extracted from MISRA-C PDF
  - MISRA-C-2012 (C queries)         ← extracted from same MISRA-C PDF (rule
                                       numbering is largely shared); consult
                                       rules.csv for the rule list
  - MISRA-C++-2023 (C++ queries)     ← extracted from MISRA-C++ PDF
"""
from __future__ import annotations
import argparse
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from extract_rules import extract_rules, render_help, Rule  # noqa: E402

DEFAULT_HELP_REPO = Path(__file__).resolve().parents[3].parent / "codeql-coding-standards-help"
DEFAULT_QUERY_REPO = Path(__file__).resolve().parents[3]
DEFAULT_CACHE_DIR = Path(__file__).resolve().parent / "cache"

# standard → (lang, relative source dir under the queries repo).
# A MISRA standard implies its language; users do not pass --lang.
STANDARD_INFO: dict[str, tuple[str, Path]] = {
    "MISRA-C-2023":   ("c",   Path("c/misra/src/rules")),
    "MISRA-C-2012":   ("c",   Path("c/misra/src/rules")),
    "MISRA-C++-2023": ("cpp", Path("cpp/misra/src/rules")),
}

SUPPORTED_STANDARDS = sorted(STANDARD_INFO)

# Each MISRA standard ships as a single licensed PDF whose filename includes a
# per-licensee suffix (e.g. "MISRA-C-2023-XXXXXX.pdf"). We do not hard-code the
# filename. The PDF location is resolved in this order:
#
#   1. --pdf CLI flag
#   2. environment variable named in PDF_ENV_VARS for the standard
#   3. a glob of PDF_FILE_GLOBS within --help-repo
#
# If none of those resolve to exactly one file, we abort with a clear message.
PDF_ENV_VARS = {
    "MISRA-C-2023":   "MISRA_C_PDF",
    "MISRA-C-2012":   "MISRA_C_PDF",
    "MISRA-C++-2023": "MISRA_CPP_PDF",
}
PDF_FILE_GLOBS = {
    "MISRA-C-2023":   ["MISRA-C-2023*.pdf", "MISRA-C-2012*.pdf"],
    "MISRA-C-2012":   ["MISRA-C-2023*.pdf", "MISRA-C-2012*.pdf"],
    "MISRA-C++-2023": ["MISRA-CPP-2023*.pdf", "MISRA-C++-2023*.pdf"],
}

RULE_DIR_RE = re.compile(r"^(?:RULE|DIR)-\d+(?:-\d+){1,2}$")
QL_NAME_RE = re.compile(r"@name\s+(?:RULE|DIR)-\d+(?:-\d+){1,2}:\s+(?P<title>.+?)\s*$")


def _normalize_title(s: str) -> str:
    """Canonicalize a rule title for equality comparison.

    Titles in the MISRA PDFs routinely carry trailing annotations that
    the `.ql` @name does not replicate — standards-body references
    (`C90 [Undefined 12, 39, 40]`), bracketed cross-reference tags
    (`[dcl.enum]`, `[class.bit] / 3, 4`), and implementation notes
    (`Implementation 1.2, 1.10`) — so we strip those before comparing.
    We also normalize whitespace, curly quotes, dashes, and typographic
    spaces.
    """
    # Normalize curly quotes / dashes / non-breaking spaces first.
    trans = str.maketrans({
        "\u2019": "'", "\u2018": "'",
        "\u201c": '"', "\u201d": '"',
        "\u2013": "-", "\u2014": "-",
        "\u00a0": " ",
    })
    s = s.translate(trans)
    # Collapse whitespace.
    s = re.sub(r"\s+", " ", s).strip()
    # Strip a leading "Rule X.Y[.Z] " or "Dir X.Y " duplicated prefix that
    # docling sometimes injects into the section-header text itself.
    s = re.sub(r"^(?:Rule|Dir)\s+\d+(?:\.\d+){1,2}\s+", "", s)
    # PDF extraction leaves spaces before commas/semicolons where the
    # layout used kerning around punctuation ("virtual , override").
    s = re.sub(r"\s+([,;])", r"\1", s)
    # Drop trailing references of the form "C90 [...]" / "C99 [...]" etc.
    s = re.sub(
        r"\s+(?:C90|C99|C11|C17|C18)\s*\[[^\]]*\]"
        r"(?:[,;\s]+(?:C90|C99|C11|C17|C18)\s*\[[^\]]*\])*\s*$",
        "",
        s,
    )
    # Iteratively strip trailing bracketed annotations and their tails.
    # Handles: `[ns.anchor]`, `[ns.anchor] / 2`, `[ns.anchor] Undefined 5`,
    # `[Koenig] 78-81`, `[C11] / 7.22.1; Undefined 1`, chains of these.
    trailing = re.compile(
        r"\s*\[[^\]]*\]"                                 # a [...] group
        r"(?:\s*/?\s*[\w.,;\s()*+-]*?)?"                  # optional tail
        r"\s*$"
    )
    impl = re.compile(
        r"\s*(?:Implementation|Undefined|Unspecified)"
        r"\s+[\w.,;\s()*+-]+$",
        re.IGNORECASE,
    )
    for _ in range(5):
        before = s
        s = trailing.sub("", s).strip()
        s = impl.sub("", s).strip()
        if s == before:
            break
    s = s.lower()
    # Strip single/double quotes entirely — MISRA quotes individual
    # tokens like "'commented out'" inconsistently between the PDF and
    # the .ql `@name`.
    s = re.sub(r"[\"']", "", s)
    return s.rstrip(" .,;:")


def _titles_match(ql_title: str, pdf_title: str) -> bool:
    """Return True if the `.ql` `@name` title and the PDF-extracted rule
    title describe the same rule.

    We accept:
      * exact normalized equality;
      * the `.ql` title being a prefix of the PDF title (the `.ql`
        `@name` line is sometimes truncated before the help generator
        wraps onto the `@description` line);
      * the `.ql` title being contained in the PDF title, when it is
        sufficiently long that an accidental substring match is
        implausible (≥ 40 normalized chars). Multiple queries per rule
        often carry query-specific titles that appear verbatim inside
        the rule's full statement.
    """
    a = _normalize_title(ql_title)
    b = _normalize_title(pdf_title)
    if not a or not b:
        return False
    if a == b:
        return True
    if b.startswith(a) or a.startswith(b):
        return True
    if len(a) >= 40 and a in b:
        return True
    return False


def _read_ql_name(ql_path: Path) -> str | None:
    """Return the human-readable rule title from a `.ql` file's `@name`
    metadata, or None if not found."""
    try:
        with ql_path.open(encoding="utf-8") as f:
            for line in f:
                m = QL_NAME_RE.search(line)
                if m:
                    return m.group("title")
                if line.strip().startswith("import "):
                    break
    except OSError:
        return None
    return None


def resolve_pdf(standard: str, cli_pdf: Path | None, help_repo: Path) -> Path:
    """Locate the licensed PDF for a standard. Raises with a helpful message."""
    if cli_pdf is not None:
        if not cli_pdf.is_file():
            raise SystemExit(f"error: --pdf {cli_pdf} does not exist")
        return cli_pdf
    env_var = PDF_ENV_VARS[standard]
    env_val = os.environ.get(env_var)
    if env_val:
        p = Path(env_val).expanduser()
        if not p.is_file():
            raise SystemExit(
                f"error: ${env_var} is set to {p} which does not exist")
        return p
    matches: list[Path] = []
    for pattern in PDF_FILE_GLOBS[standard]:
        matches.extend(sorted(help_repo.glob(pattern)))
    if len(matches) == 1:
        return matches[0]
    if not matches:
        raise SystemExit(
            f"error: cannot locate the {standard} PDF.\n"
            f"  Provide it via --pdf <path>, or set ${env_var}, or place a\n"
            f"  file matching one of {PDF_FILE_GLOBS[standard]} in {help_repo}.")
    raise SystemExit(
        f"error: multiple candidate PDFs for {standard} found in {help_repo}:\n"
        + "\n".join(f"  {m}" for m in matches)
        + f"\n  Disambiguate with --pdf <path> or ${env_var}.")


def collect_queries(query_repo: Path, standard: str) -> dict[str, list[Path]]:
    """rule_id -> list of query file paths."""
    _, src_rel = STANDARD_INFO[standard]
    src_dir = query_repo / src_rel
    out: dict[str, list[Path]] = {}
    if not src_dir.is_dir():
        return out
    for ql in src_dir.rglob("*.ql"):
        rule_dir = ql.parent.name
        if not RULE_DIR_RE.match(rule_dir):
            continue
        out.setdefault(rule_dir, []).append(ql)
    return out


def write_help(rule: Rule, ql_path: Path, lang: str, help_repo: Path,
               query_repo: Path, lang_src: Path,
               no_overwrite: bool, dry_run: bool,
               rule_trusted: bool) -> str:
    """Write one help .md and return a short status string."""
    rel_dir = ql_path.parent.relative_to(query_repo / lang_src)
    target_dir = help_repo / lang_src / rel_dir
    target = target_dir / (ql_path.stem + ".md")
    rel = target.relative_to(help_repo)

    if not rule_trusted:
        ql_title = _read_ql_name(ql_path) or ""
        return (f"title-mismatch {rel} "
                f"(ql={ql_title!r} pdf={rule.title!r})")

    body = render_help(rule, lang)
    if target.exists():
        if no_overwrite:
            return f"skip-existing {rel}"
        if target.read_text(encoding="utf-8") == body:
            return f"unchanged {rel}"
        action = "wrote-changed"
    else:
        action = "wrote-new"
    if dry_run:
        return f"would-{action} {rel} ({len(body)} bytes)"
    target_dir.mkdir(parents=True, exist_ok=True)
    target.write_text(body, encoding="utf-8")
    return f"{action} {rel} ({len(body)} bytes)"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--standard", required=True, choices=SUPPORTED_STANDARDS,
                    help="MISRA standard to populate (the source language is "
                         "derived from this)")
    ap.add_argument("--query-repo", type=Path, default=DEFAULT_QUERY_REPO,
                    help="path to codeql-coding-standards repo (default: this repo)")
    ap.add_argument("--help-repo", type=Path, default=DEFAULT_HELP_REPO,
                    help="path to codeql-coding-standards-help repo")
    ap.add_argument("--pdf", type=Path, default=None,
                    help="path to the licensed MISRA PDF (overrides env var "
                         "and help-repo glob)")
    ap.add_argument("--cache-dir", type=Path,
                    default=DEFAULT_CACHE_DIR,
                    help="docling JSON cache dir (deterministic across runs)")
    ap.add_argument("--rule", action="append", default=[],
                    help="restrict to specific RULE-X-Y[-Z] (repeatable)")
    ap.add_argument("--no-overwrite", action="store_true",
                    help="leave existing .md files untouched (default: "
                         "regenerate every help file from the rule "
                         "description so help content is reproducible)")
    ap.add_argument("--ignore-title-mismatch", action="store_true",
                    help="regenerate even when the .ql @name title differs "
                         "from the PDF-extracted title (by default we skip "
                         "such files to avoid overwriting correct content "
                         "with content from a renumbered rule or a broken "
                         "PDF anchor)")
    ap.add_argument("--dry-run", action="store_true",
                    help="report what would be written without writing")
    args = ap.parse_args()

    pdf = resolve_pdf(args.standard, args.pdf, args.help_repo)
    args.cache_dir.mkdir(parents=True, exist_ok=True)
    rules = extract_rules(pdf, args.standard, args.cache_dir)
    by_id = {r.rule_id: r for r in rules}

    lang, lang_src = STANDARD_INFO[args.standard]
    queries = collect_queries(args.query_repo, args.standard)
    rule_filter = set(s.upper() for s in args.rule)
    counts: dict[str, int] = {}
    for rule_id in sorted(queries):
        if rule_filter and rule_id not in rule_filter:
            continue
        rule = by_id.get(rule_id)
        if rule is None:
            print(f"missing-rule {rule_id} (no PDF entry)")
            counts["missing-rule"] = counts.get("missing-rule", 0) + 1
            continue
        # Verify the rule's identity via the `.ql` `@name` titles. The
        # rule is "trusted" for this directory if any one query's title
        # matches the PDF title; that way narrow per-query titles do
        # not block regeneration when the rule as a whole is correctly
        # identified.
        if args.ignore_title_mismatch:
            rule_trusted = True
        else:
            rule_trusted = False
            for ql in queries[rule_id]:
                ql_title = _read_ql_name(ql) or ""
                if _titles_match(ql_title, rule.title):
                    rule_trusted = True
                    break
        for ql in sorted(queries[rule_id]):
            status = write_help(rule, ql, lang, args.help_repo,
                                args.query_repo, lang_src,
                                args.no_overwrite, args.dry_run,
                                rule_trusted)
            print(status)
            kind = status.split()[0]
            counts[kind] = counts.get(kind, 0) + 1

    print("\nSummary:")
    for k in sorted(counts):
        print(f"  {k}: {counts[k]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
