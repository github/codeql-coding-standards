"""MISRA PDF → structured rule data extractor (docling-based).

Pipeline:
  1. Convert each PDF with docling, getting structured JSON whose `texts[]`
     items carry labels (section_header / text / list_item / code / table).
  2. Walk the texts in document order, slicing into per-rule chunks at any
     item whose text starts with "Rule N.N[.N]" or "Dir N.N[.N]" and which
     has a `Category` line within the next ~25 items.
  3. Repair the C++ PDF's broken font CMap (`fi`/`fl`/`ff` glyphs encoded as
     `9`/`2`/`C`). Repair is deterministic and wordlist-based: at each
     suspect glyph between two letters, try fi/fl/ff/ffi/ffl substitutions
     and accept the unique substitution that yields a real word; if zero or
     multiple substitutions produce real words, leave the glyph untouched.
  4. Render each rule via a help-file template that mirrors the on-disk
     convention used in `codeql-coding-standards-help/c/misra/src/rules/`.
"""
from __future__ import annotations
import json
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path

# ----------------------------------------------------------------------------
# Wordlist-based ligature repair (deterministic)
# ----------------------------------------------------------------------------
_WORDLIST_PATHS = ["/usr/share/dict/words", "/usr/dict/words"]
_EXTRA_WORDS = {
    "dataflow", "workflow", "reflow", "overflow", "overflows", "overflowed",
    "overflowing", "underflow", "underflows", "outflow", "flow", "flows",
    "flowing", "flag", "flags", "flagged", "flagging", "float", "floats",
    "floating", "conflict", "conflicts", "conflicting", "conflicted",
    "reflect", "reflects", "reflected", "reflecting", "superfluous",
    "inflow", "offsetof", "sufficient", "efficient", "difficult", "difficulty",
    "config", "configure", "configured", "configuration", "configurations",
    "buffer", "buffers", "buffered", "buffering",
    "differ", "different", "differently", "difference", "differences",
    "differing", "differs",
    "effect", "effects", "effective", "effectively", "effort", "efforts",
    "affect", "affects", "affected", "affecting",
    "specifier", "specifiers", "specification", "specifications",
    "definition", "definitions", "define", "defined", "defines", "defining",
    "amplification", "classification", "identifier", "identifiers",
    "identified", "identifies", "identify", "identifying",
    "modifier", "modifiers", "modifies", "modify", "modified", "modification",
    "qualifier", "qualifiers", "qualified", "qualify",
    "predefined", "undefined", "unspecified", "specified", "specify",
    "prefix", "prefixed", "prefixes",
    "fixed", "fix", "fixes", "field", "fields", "file", "files",
    "first", "firstly",
    "benefit", "benefits", "benefited",
    "clarified", "confined", "filename", "filenames", "filesystem",
    "lifetime", "compile", "compiled", "compiles", "compiler", "compilers",
    "compilation", "redefine", "redefined",
    "bitfield", "bitfields", "welldefined", "illdefined",
}

_WORDS_CACHE: set[str] | None = None


def _load_words() -> set[str]:
    global _WORDS_CACHE
    if _WORDS_CACHE is not None:
        return _WORDS_CACHE
    words: set[str] = set(_EXTRA_WORDS)
    found_system = False
    for p in _WORDLIST_PATHS:
        path = Path(p)
        if path.exists():
            with path.open() as f:
                words |= {w.strip().lower() for w in f if w.strip()}
            found_system = True
            break
    if not found_system:
        import warnings
        warnings.warn(
            "No system wordlist found; ligature repair will rely on "
            "the built-in word list only. Install a words file at "
            f"{_WORDLIST_PATHS[0]} for full coverage.",
            stacklevel=2,
        )
    _WORDS_CACHE = words
    return words


_LIGS = ("fi", "fl", "ff", "ffi", "ffl")
# Suspect glyphs observed in the MISRA C++ PDF's font CMap:
#   digits 0-9, capital `C`, caret `^`, percent `%`, and capital `A`
#   all appear where a genuine ligature (fi/fl/ff/ffi/ffl) was
#   originally rendered. The wordlist check in `repair_ligatures`
#   prevents mis-substitution on legitimate CamelCase identifiers
#   containing `A` or `C`.
_SUSPECT_GLYPHS = set("0123456789CA^%")
_SUSPECT_TOKEN_RE = re.compile(r"[A-Za-z0-9\^%]+")


def repair_ligatures(text: str) -> str:
    """Fix MISRA C++ PDF's font-CMap-induced ligature corruption.

    For each token containing a suspect glyph, try each ligature
    substitution at each suspect position; if exactly one substitution
    yields a dictionary word, apply it. Otherwise leave the token alone
    (preserves real numeric literals and identifiers like `int32_t` and
    code variables like `Class`).
    """
    words = _load_words()

    def fix(tok: str) -> str:
        # Only attempt repairs on tokens that already contain letters;
        # pure-digit tokens like "4" or "10" must be left alone even
        # though they start or end with a suspect glyph.
        if not any(c.isalpha() for c in tok):
            return tok
        # Skip tokens that contain no suspect glyphs at all.
        if not any(c in _SUSPECT_GLYPHS for c in tok):
            return tok
        low = tok.lower()
        if low.isalpha() and low in words:
            return tok
        out = tok
        for i, ch in enumerate(out):
            if ch not in _SUSPECT_GLYPHS:
                continue
            left_ok = (i == 0) or out[i - 1].isalpha()
            right_ok = (i == len(out) - 1) or out[i + 1].isalpha()
            if not (left_ok and right_ok):
                continue
            hits = []
            for lig in _LIGS:
                cand = (out[:i] + lig + out[i + 1 :]).lower()
                if cand in words:
                    hits.append(lig)
            if len(hits) == 1:
                out = out[:i] + hits[0] + out[i + 1 :]
                break  # indices shifted; one repair per token suffices
        return out

    return _SUSPECT_TOKEN_RE.sub(lambda m: fix(m.group(0)), text)


# ----------------------------------------------------------------------------
# Docling load (cached)
# ----------------------------------------------------------------------------

def load_docling_json(pdf_path: Path, cache_dir: Path) -> dict:
    cache_dir.mkdir(parents=True, exist_ok=True)
    out = cache_dir / f"{pdf_path.stem}.docling.json"
    if not out.exists():
        # Lazy import — docling is heavy and only needed on cache miss.
        from docling.document_converter import DocumentConverter
        conv = DocumentConverter()
        result = conv.convert(str(pdf_path))
        out.write_text(
            json.dumps(result.document.export_to_dict(), indent=2),
            encoding="utf-8",
        )
    return json.loads(out.read_text(encoding="utf-8"))


# ----------------------------------------------------------------------------
# Rule extraction over docling's text stream
# ----------------------------------------------------------------------------

RULE_ANCHOR_RE = re.compile(
    r"^(?P<kind>Rule|Dir)\s+(?P<num>\d+(?:\.\d+){1,2})\b\s*(?P<rest>.*)$"
)
HEADER_KEYS = ("Category", "Analysis", "Applies to")
SUB_LABELS = ("Amplification", "Rationale", "Exception", "Example", "See also")

# `page_header` items (running heads like "Section 4: Guidelines" or
# "Rule 15.0.2") must be retained for rule-anchor detection (a small number of
# real rule headers in the C PDF land in `page_header`-labelled items), but
# they MUST NOT be allowed to leak into the body of a rule's sections. We
# therefore keep them in `_items()` but filter them when accumulating section
# content in `_build_rule()`.
_BODY_SKIP_LABELS = {"page_header"}


@dataclass
class TextItem:
    label: str
    text: str
    page: int


@dataclass
class Rule:
    rule_id: str
    raw_id: str
    title: str
    standard: str
    category: str = ""
    analysis: str = ""
    applies_to: str = ""
    amplification: str = ""
    rationale: str = ""
    exceptions: list[str] = field(default_factory=list)
    example: str = ""
    see_also: list[str] = field(default_factory=list)


def _items(doc: dict) -> list[TextItem]:
    items: list[TextItem] = []
    for t in doc["texts"]:
        if t["label"] == "page_footer":
            continue
        page = t.get("prov", [{}])[0].get("page_no", 0) if t.get("prov") else 0
        # Normalize NBSP (U+00A0) — MISRA rule headers use it between
        # "Rule" and the number, which would otherwise break our anchor.
        raw = t.get("text", "").replace("\xa0", " ")
        text = repair_ligatures(raw)
        items.append(TextItem(label=t["label"], text=text, page=page))
    return items


def _anchor(it: TextItem) -> tuple[str, str, str] | None:
    m = RULE_ANCHOR_RE.match(it.text.strip())
    if not m:
        return None
    return m.group("kind"), m.group("num"), m.group("rest").strip()


def _find_rule_starts(items: list[TextItem]) -> list[int]:
    starts: list[int] = []
    seen: set[str] = set()
    for i, it in enumerate(items):
        a = _anchor(it)
        if not a:
            continue
        kind, num, rest = a
        # page_header items are running heads — ignore them when they're
        # bare ids without title text (those reference a rule defined
        # elsewhere); but accept them when they include the title (real
        # rule headers in this PDF appear as page_header for some rules).
        rid = f"{kind.upper()}-{num.replace('.', '-')}"
        if rid in seen:
            continue
        # Require a `Category` line within the next 25 items to confirm
        # this is a real rule definition (not a cross-reference).
        for j in range(i + 1, min(i + 30, len(items))):
            if items[j].text.strip().startswith("Category"):
                starts.append(i)
                seen.add(rid)
                break
    return starts


def _split_label_and_value(text: str, label: str) -> tuple[bool, str]:
    s = text.strip()
    if s == label:
        return True, ""
    if s.startswith(label + " "):
        return True, s[len(label) + 1 :].strip()
    if s.startswith(label + "\n"):
        return True, s[len(label) + 1 :].strip()
    return False, ""


def _classify_section(text: str) -> str | None:
    s = text.strip()
    for lab in SUB_LABELS:
        if s == lab or s.startswith(lab + " ") or s.startswith(lab + "\n"):
            return lab
        # "Exception 1", "Exception 2" -> Exception
        if lab == "Exception" and re.match(r"^Exception(\s+\d+)?\b", s):
            return "Exception"
    return None


def _build_rule(items: list[TextItem], start: int, end: int, standard: str) -> Rule:
    head = items[start]
    kind, num, rest = _anchor(head)  # type: ignore
    rule_id = f"{kind.upper()}-{num.replace('.', '-')}"
    raw_id = f"{kind} {num}"

    # Title may continue across the next 1-2 plain text items before Category.
    title_parts: list[str] = []
    if rest:
        title_parts.append(rest)
    body_start = start + 1
    while body_start < end:
        it = items[body_start]
        s = it.text.strip()
        if not s:
            body_start += 1
            continue
        if s.startswith("Category") or _classify_section(s):
            break
        if it.label in ("text", "section_header"):
            title_parts.append(s)
            body_start += 1
        else:
            break
    title = " ".join(p for p in title_parts if p).strip()

    rule = Rule(rule_id=rule_id, raw_id=raw_id, title=title, standard=standard)

    cur: str | None = None
    # `mixed_buf` preserves prose-and-code interleaving (so the Example
    # section can present prose paragraphs between code blocks just as the
    # PDF does). Each entry is ("text", str) or ("code", str).
    mixed_buf: list[tuple[str, str]] = []

    def flush():
        nonlocal mixed_buf
        items_buf = mixed_buf
        mixed_buf = []
        prose_only = "\n\n".join(s for kind, s in items_buf if kind == "text").strip()
        if cur == "Amplification":
            rule.amplification = prose_only
        elif cur == "Rationale":
            rule.rationale = prose_only
        elif cur == "Exception":
            if prose_only:
                rule.exceptions.append(prose_only)
        elif cur == "Example":
            parts: list[str] = []
            run_text: list[str] = []
            run_code: list[str] = []

            def flush_text():
                if run_text:
                    parts.append("\n\n".join(run_text))
                    run_text.clear()

            def flush_code():
                if run_code:
                    parts.append("\n\n".join(run_code))
                    run_code.clear()

            for kind, s in items_buf:
                if kind == "code":
                    flush_text()
                    run_code.append(s)
                else:
                    flush_code()
                    run_text.append(s)
            flush_text()
            flush_code()
            rule.example = "\n\n".join(parts).strip()
            rule._example_layout = items_buf  # type: ignore[attr-defined]
        elif cur == "See also":
            rule.see_also = [s.strip() for s in re.split(r"[,\n]", prose_only) if s.strip()]

    skip_next = 0
    for k in range(body_start, end):
        if skip_next:
            skip_next -= 1
            continue
        it = items[k]
        s = it.text.strip()
        if not s:
            continue
        # Header k/v: may be on one item ("Category Required") or split
        # across two items ("Category" then "Required").
        matched_header = False
        for hkey in HEADER_KEYS:
            ok, val = _split_label_and_value(s, hkey)
            if ok:
                if not val and k + 1 < end:
                    # Look ahead: next item is the value.
                    nxt = items[k + 1].text.strip()
                    if nxt and not _classify_section(nxt) and not any(
                        nxt.startswith(h) for h in HEADER_KEYS
                    ):
                        val = nxt
                        skip_next = 1
                if hkey == "Category":
                    if not rule.category:
                        rule.category = val
                elif hkey == "Analysis":
                    if not rule.analysis:
                        rule.analysis = val
                elif hkey == "Applies to":
                    if not rule.applies_to:
                        rule.applies_to = val
                matched_header = True
                break
        if matched_header:
            continue
        # Drop running-head text from the body of any section.
        if it.label in _BODY_SKIP_LABELS:
            continue
        sec = _classify_section(s)
        if sec:
            flush()
            cur = sec
            ok, after = _split_label_and_value(s, sec if sec != "Exception" else s.split()[0])
            if after:
                kind = "code" if it.label == "code" else "text"
                mixed_buf.append((kind, after))
            continue
        if cur is None:
            continue
        if it.label == "code":
            mixed_buf.append(("code", s))
        elif it.label == "list_item":
            mixed_buf.append(("text", f"- {s}"))
        else:
            mixed_buf.append(("text", s))
    flush()
    return rule


# ----------------------------------------------------------------------------
# Hand-curated repairs for rules whose docling output is too entangled with
# adjacent code/text items for the generic anchor logic to find. These PDFs
# are static (MISRA C 2023, MISRA C++ 2023), so we splice synthetic anchor
# items at content-anchored positions; we then let the normal `_build_rule`
# pipeline harvest section content from the items that follow.
#
# Each entry: (locator -> int|None, synthetic_items: list[TextItem]).
# The locator returns the index in `items` BEFORE which to insert.
# ----------------------------------------------------------------------------
def _ti(label: str, text: str, page: int = 0) -> "TextItem":
    return TextItem(label=label, text=text, page=page)


def _find_after(items: list["TextItem"], pred, start: int = 0) -> int | None:
    for i in range(start, len(items)):
        if pred(items[i]):
            return i
    return None


def _missing_anchors_misra_cpp_2023(items: list["TextItem"]) -> list[tuple[int, list["TextItem"]]]:
    """Return [(insert_before_index, synthetic_items)] for the 4 rules whose
    headers are absent or merged with adjacent items in the docling output."""
    out: list[tuple[int, list[TextItem]]] = []

    # Rule 0.0.1 — heading entirely missing in docling output. Body begins
    # at the "Ampli2cation" section_header that immediately follows the
    # "[misra]" text item that follows the "4.0.0 Path feasibility" header.
    i_path = _find_after(items, lambda it: it.label == "section_header"
                         and it.text.strip() == "4.0.0 Path feasibility")
    if i_path is not None:
        i_misra = _find_after(items, lambda it: it.text.strip() == "[misra]", i_path + 1)
        if i_misra is not None:
            out.append((i_misra + 1, [
                _ti("section_header",
                    "Rule 0.0.1 A function shall not contain unreachable statements"),
                _ti("text", "Category Required"),
                _ti("text", "Analysis Decidable, Single Translation Unit"),
            ]))

    # Rule 5.13.6 — heading and Category/Analysis are concatenated inside a
    # single `code` item. Insert synthetic anchor immediately before that
    # code item (located by a unique substring of the rule title).
    i_5136 = _find_after(items, lambda it: it.label == "code"
                         and "Rule 5.13.6" in it.text and "long long" in it.text)
    if i_5136 is not None:
        out.append((i_5136, [
            _ti("section_header",
                "Rule 5.13.6 An integer-literal of type long long shall not "
                "use a single L or l in any suffix"),
            _ti("text", "Category Required"),
            _ti("text", "Analysis Decidable, Single Translation Unit"),
            _ti("section_header", "Example"),
        ]))

    # Rule 6.9.1 — heading concatenated into a `text` item ("...4.6.9 Types
    # [basic.types] Rule 6.9.1 ..."). Insert synthetic anchor immediately
    # before that item.
    i_691 = _find_after(items, lambda it: it.label == "text"
                        and "Rule 6.9.1" in it.text
                        and "type aliases" in it.text)
    if i_691 is not None:
        out.append((i_691, [
            _ti("section_header",
                "Rule 6.9.1 The same type aliases shall be used in all "
                "declarations of the same entity"),
            _ti("text", "Category Required"),
            _ti("text", "Analysis Decidable, Single Translation Unit"),
            _ti("section_header", "Amplification"),
        ]))

    # Rule 15.0.2 — heading inside a `code` item ("struct NonEmptyDestructor
    # ... Rule 15.0.2 User-provided copy and move ..."). Insert anchor
    # immediately before it.
    i_1502 = _find_after(items, lambda it: it.label == "code"
                         and "Rule 15.0.2" in it.text
                         and "User-provided copy and move" in it.text)
    if i_1502 is not None:
        out.append((i_1502, [
            _ti("section_header",
                "Rule 15.0.2 User-provided copy and move member functions of "
                "a class should have appropriate signatures"),
            _ti("text", "Category Advisory"),
            _ti("text", "Analysis Decidable, Single Translation Unit"),
        ]))

    return out


_MISSING_ANCHOR_RESOLVERS = {
    "MISRA-C++-2023": _missing_anchors_misra_cpp_2023,
}


def _splice_missing_anchors(items: list["TextItem"], standard: str) -> list["TextItem"]:
    resolver = _MISSING_ANCHOR_RESOLVERS.get(standard)
    if resolver is None:
        return items
    insertions = resolver(items)
    if not insertions:
        return items
    # Apply from highest index to lowest so earlier indices stay valid.
    insertions.sort(key=lambda x: x[0], reverse=True)
    out = list(items)
    for idx, syn in insertions:
        out[idx:idx] = syn
    return out


def extract_rules(pdf_path: Path, standard: str, cache_dir: Path) -> list[Rule]:
    doc = load_docling_json(pdf_path, cache_dir)
    items = _items(doc)
    items = _splice_missing_anchors(items, standard)
    starts = _find_rule_starts(items)
    starts.append(len(items))
    rules: list[Rule] = []
    for a, b in zip(starts, starts[1:]):
        rules.append(_build_rule(items, a, b, standard))
    return rules


# ----------------------------------------------------------------------------
# Code-block line-break recovery
# ----------------------------------------------------------------------------
#
# docling emits each PDF code block as a single joined string: the PDF's
# line breaks are collapsed to spaces, so examples would render as one
# long line. We cannot losslessly recover the original line breaks without
# re-reading layout boxes, but for C/C++ examples we can insert
# statement-level breaks at the obvious boundaries: `;`, `{`, `}`, and
# before `//` line comments. This is a deterministic, purely textual
# transform — no parsing or formatting — and keeps the output readable.

_CODE_FORMAT_STEPS = [
    # Newline after `;` (but not inside `for( ; ; )` — the next rule catches
    # runs of `;` we should leave alone).
    (re.compile(r";\s+(?=\S)"),    ";\n"),
    # Newline after `{` (common block open) except for `${`-style literals.
    (re.compile(r"\{\s+(?=\S)"),   "{\n"),
    # Newline before a `}` that is preceded by content on the same line.
    (re.compile(r"(?<=\S)\s+\}"),  "\n}"),
]


def _indent_by_braces(text: str) -> str:
    """Add 2-space indentation based on brace nesting depth."""
    lines = text.splitlines()
    out: list[str] = []
    depth = 0
    for line in lines:
        stripped = line.strip()
        if not stripped:
            out.append("")
            continue
        # Dedent for lines that start with `}`
        if stripped.startswith("}"):
            depth = max(0, depth - 1)
        out.append("  " * depth + stripped)
        # Indent after lines that end with `{`
        if stripped.endswith("{"):
            depth += 1
    return "\n".join(out)


def _format_code_lines(text: str) -> str:
    """Heuristically insert line breaks into a C/C++ code example that
    docling concatenated onto a single line. Deterministic.

    Preserves existing multi-space alignment and inline ``//`` comments.
    Only inserts line breaks at ``;``, ``{``, ``}`` boundaries and adds
    brace-depth indentation.
    """
    # Collapse runs of 3+ spaces (likely docling kerning artefacts) to
    # a single space, but preserve 2-space runs which may be intentional
    # alignment in column-style comments.
    s = re.sub(r"[ \t]{3,}", " ", text).strip()
    for pat, repl in _CODE_FORMAT_STEPS:
        s = pat.sub(repl, s)
    # Trim trailing whitespace on each line.
    s = "\n".join(line.rstrip() for line in s.splitlines()).strip()
    # Add indentation based on brace depth.
    return _indent_by_braces(s)


# ----------------------------------------------------------------------------
# Help-file rendering
# ----------------------------------------------------------------------------

STD_DISPLAY = {
    "MISRA-C-2023": "MISRA C 2012",
    "MISRA-C-2012": "MISRA C 2012",
    "MISRA-C++-2023": "MISRA C++ 2023",
}


def render_help(rule: Rule, lang: str = "c") -> str:
    rows = [f"<tr><td><b>Category</b></td><td>{rule.category or 'Unknown'}</td></tr>"]
    if rule.analysis:
        rows.append(f"<tr><td><b>Analysis</b></td><td>{rule.analysis}</td></tr>")
    if rule.applies_to:
        rows.append(f"<tr><td><b>Applies to</b></td><td>{rule.applies_to}</td></tr>")

    parts: list[str] = [
        f"# {rule.raw_id}: {rule.title}",
        "",
        f"This query implements the {STD_DISPLAY.get(rule.standard, rule.standard)} {rule.raw_id}:",
        "",
        f"> {rule.title}",
        "",
        "## Classification",
        "",
        "<table>",
        *rows,
        "</table>",
        "",
    ]
    if rule.amplification:
        parts += ["### Amplification", "", rule.amplification, ""]
    if rule.rationale:
        parts += ["### Rationale", "", rule.rationale, ""]
    if rule.exceptions:
        parts += ["### Exception", ""]
        for e in rule.exceptions:
            parts += [e, ""]
    layout = getattr(rule, "_example_layout", None)
    if layout:
        parts += ["## Example", ""]
        for kind, s in layout:
            if kind == "code":
                parts += [f"```{lang}", _format_code_lines(s), "```", ""]
            else:
                parts += [s, ""]
    elif rule.example:
        parts += ["## Example", "", f"```{lang}",
                  _format_code_lines(rule.example), "```", ""]
    if rule.see_also:
        parts += ["## See also", "", ", ".join(rule.see_also), ""]
    parts += [
        "## Implementation notes",
        "",
        "None",
        "",
        "## References",
        "",
        f"* {STD_DISPLAY.get(rule.standard, rule.standard)}: {rule.raw_id}: {rule.title}",
        "",
    ]
    return "\n".join(parts)


def to_dict(rule: Rule) -> dict:
    return asdict(rule)


# ----------------------------------------------------------------------------
# CLI
# ----------------------------------------------------------------------------

_REPO_ROOT = Path(__file__).resolve().parents[3]

if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("--standard", required=True, choices=list(STD_DISPLAY))
    ap.add_argument("--cache-dir",
                    default=str(_REPO_ROOT / "scripts" / "generate_rules"
                                / "misra_help" / "cache"))
    ap.add_argument("--rule", action="append", help="only emit these rule IDs")
    ap.add_argument("--json", default=None,
                    help="write extracted rules to this JSON file")
    args = ap.parse_args()
    rules = extract_rules(Path(args.pdf), args.standard, Path(args.cache_dir))
    selected = [r for r in rules if not args.rule or r.rule_id in args.rule]
    print(f"Extracted {len(rules)} rules from {args.pdf}"
          f" ({len(selected)} selected)")
    if args.json:
        out = Path(args.json)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(
            json.dumps([to_dict(r) for r in selected], indent=2),
            encoding="utf-8",
        )
        print(f"Wrote {out}")
