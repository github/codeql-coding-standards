# MISRA help-file populator

A re-runnable, deterministic generator that writes per-query Markdown help
files in
`codeql-coding-standards-help/{c,cpp}/misra/src/rules/<RULE-ID>/<Name>.md`
from the licensed MISRA PDFs.

## About the source PDFs

The MISRA C and MISRA C++ PDFs are **licensed material**.
**You must obtain them yourself from MISRA.** They are
**deliberately excluded from version control** by the
`codeql-coding-standards-help/.gitignore` (`MISRA-*.pdf`) and this
populator will not run without them. Drop your locally-licensed copies
into your checkout of the help repo (or pass `--pdf` on every
invocation).

Expected local layout (the licensee suffix on each PDF filename will
vary):

```text
codeql-coding-standards-help/
├── .gitignore                       # ignores MISRA-*.pdf
├── MISRA-C-2023-<licensee>.pdf      # NOT in git; you place it here
├── MISRA-CPP-2023-<licensee>.pdf    # NOT in git; you place it here
└── {c,cpp}/misra/src/rules/...      # the .md files this tool generates
```

## Why this exists

The standard `scripts/generate_rules/generate_package_files.py` writes a
templated stub help file when a `.ql` query has none. For MISRA queries
those stubs are placeholders — actual rule prose, classification, and
examples must come from the published PDFs. This module automates that
transcription so MISRA help files can be regenerated whenever the query
set, the MISRA editions, or the parser improves.

## Approach

We use **[docling](https://github.com/docling-project/docling)** (an
open-source IBM-Research project that uses ML layout models to convert
PDFs into structured JSON) to obtain a labelled stream of text items per
page (`section_header`, `text`, `code`, `list_item`, `page_header`,
`page_footer`). On top of that JSON we run a small deterministic Python
parser that locates each MISRA rule by its `Rule N.N[.N]` heading anchor,
harvests the following items into a `Rule` dataclass (Category / Analysis
/ Applies to / Amplification / Rationale / Exception / Example / See also),
and renders the result via a Markdown template that mirrors the on-disk
format used elsewhere in the help repo.

docling itself bundles ML-based layout and reading-order models, so the
only AI in the pipeline lives inside docling. Everything downstream is
plain deterministic Python.

## What it does and does not do

### Does

- Use **docling** for PDF → structured JSON. No other PDF parsing libraries
  (pdfplumber, pymupdf, pdfminer) are used in the production pipeline.
- Render `.md` files in the help repo using the same Markdown shape as the
  hand-written entries (`# Rule X.Y: ...`, `## Classification` HTML table,
  `### Rationale`, `## Example`, `## Implementation notes`,
  `## References`).
- Cache docling's structured JSON to disk so re-runs are fast and stable.
- Regenerate every help file by default (matching renders are reported
  as `unchanged` and not touched on disk, so re-runs are idempotent).
  Pass `--no-overwrite` to leave existing files untouched.
- Skip queries whose `.ql` `@name` title cannot be reconciled with the
  PDF rule title (rule-numbering drift between MISRA editions; docling
  anchor-detection failures). Pass `--ignore-title-mismatch` to
  regenerate anyway.
- Provide a determinism harness so changes to the parser can be checked
  for byte-stability before they land.
- Emit a structured per-standard JSON sidecar via `dump_rules_json.py`
  so a downstream LLM rewrite pass (see
  [Two-pass mode](#two-pass-mode-deterministic-extract--llm-render))
  can produce higher-quality help files.

### Does not (deterministic populator only)

- Use any LLM service in the deterministic populator itself. The
  optional second-pass renderer in the agent extension does call a
  Copilot chat model — see [Two-pass mode](#two-pass-mode-deterministic-extract--llm-render).
- Modify any source query (`.ql`) file or any non-`.md` file.
- Invent or paraphrase content — output is rendered verbatim from the
  extracted `Rule` fields.
- Check the MISRA PDFs into git. They remain local to your machine.
- Download the PDFs for you. **You** must obtain them from MISRA.

## Architecture

```text
   ┌────────────────────────────────────────────┐
   │ MISRA-*.pdf (gitignored, supplied locally) │
   └─────────────────┬──────────────────────────┘
                     │
                     ▼
   ┌────────────────────────────────────────────┐
   │ docling.DocumentConverter                  │
   │   ML layout + reading-order model          │
   └─────────────────┬──────────────────────────┘
                     │  structured JSON
                     │  (texts[].label/text/prov)
                     ▼
   ┌────────────────────────────────────────────┐
   │ extract_rules.py                           │
   │   • cache JSON to disk                     │
   │   • repair fi/fl/ff ligatures              │
   │     (wordlist-based, deterministic)        │
   │   • splice synthetic anchors for rules     │
   │     whose headings docling merges into     │
   │     neighbouring items                     │
   │   • slice items into Rule chunks at        │
   │     "Rule N.N[.N]" anchors                 │
   │   • parse Category/Analysis/Applies to     │
   │     plus section bodies                    │
   └─────────────────┬──────────────────────────┘
                     │  Rule dataclass per rule
                     ▼
   ┌────────────────────────────────────────────┐
   │ render_help() + populate_help.py           │
   │   • walk c/misra/src/rules/RULE-X-Y/*.ql   │
   │   • render one .md per .ql with matching   │
   │     basename                               │
   │   • write into                             │
   │     codeql-coding-standards-help/{c,cpp}/  │
   │     misra/src/rules/RULE-X-Y/<Name>.md     │
   └────────────────────────────────────────────┘
```

## Files

| File                 | Purpose                                                                              |
|----------------------|--------------------------------------------------------------------------------------|
| `extract_rules.py`   | docling-based PDF → `Rule` dataclasses; the deterministic core.                      |
| `populate_help.py`   | Walk `.ql` queries, render and write help `.md` files into the help repo.            |
| `dump_rules_json.py` | Emit `<help-repo>/.misra-rule-cache/<standard>.json` for the LLM rewrite pass.       |
| `harness.py`         | Determinism harness for the extract+render pipeline (per-section hashing).           |

## Quick start

### Install

`docling` is heavy (~3 GB once torch + transformers + the layout/OCR models
are downloaded). It is intentionally **not** added to
`scripts/requirements.txt` because the standard CI flow does not need it —
only this populator does.

```bash
python3 -m venv .venv
.venv/bin/pip install docling
```

### Provide the PDFs

Drop your locally-licensed copies into the help repo (the licensee
suffix on each filename varies per purchaser):

```bash
cp ~/Downloads/MISRA-C-2023-*.pdf   ../codeql-coding-standards-help/
cp ~/Downloads/MISRA-CPP-2023-*.pdf ../codeql-coding-standards-help/
```

The populator and harness resolve each PDF in this order:

1. `--pdf <path>` CLI flag (highest precedence).
2. Environment variable `MISRA_C_PDF` (for MISRA-C-2023 / MISRA-C-2012)
   or `MISRA_CPP_PDF` (for MISRA-C++-2023).
3. A glob inside `--help-repo` (e.g. `MISRA-C-2023*.pdf`,
   `MISRA-CPP-2023*.pdf`). If exactly one file matches, it is used; if
   zero or multiple match, the tool aborts with a clear message asking
   you to disambiguate via `--pdf` or the env var.

No MISRA PDF filename is hard-coded anywhere in this module.

### Populate

By default the populator **regenerates every help file** for the given
standard from the extracted rule description, overwriting existing
content. This is deliberate: the rule description in the MISRA PDF is
treated as the single source of truth for query documentation, so any
prior hand-authored edits will be replaced. Files whose rendered output
matches the existing bytes are reported as `unchanged` and not touched
on disk, so re-runs yield `wrote-changed: 0` — that is the idempotency
signal.

Pass `--no-overwrite` to leave existing `.md` files untouched (useful
when you only want to fill in help for queries that do not yet have
any). Pass `--dry-run` to preview without writing.

```bash
# Preview what would be written.
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --dry-run
.venv/bin/python populate_help.py --standard MISRA-C-2012   --dry-run

# Regenerate every help file for the given standard.
.venv/bin/python populate_help.py --standard MISRA-C++-2023
.venv/bin/python populate_help.py --standard MISRA-C-2012

# Regenerate only a specific rule.
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --rule RULE-8-1

# Only fill in help for queries that do not yet have any; leave
# existing files (including hand-authored entries) untouched.
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --no-overwrite
```

Per-file status values printed by the populator:

| Status           | Meaning                                                                              |
|------------------|--------------------------------------------------------------------------------------|
| `wrote-new`      | File did not exist; it was written.                                                  |
| `wrote-changed`  | Existed and differed from the render; was rewritten.                                 |
| `unchanged`      | Existed and render matches byte-for-byte; not touched.                               |
| `skip-existing`  | Existed and `--no-overwrite` was passed; not touched.                                |
| `title-mismatch` | `.ql` `@name` title could not be reconciled with the PDF rule title; skipped.        |
| `missing-rule`   | `.ql` query present but no rule with that ID in the PDF.                             |
| `would-*`        | Dry-run variants of the above (`--dry-run`).                                         |

Pass `--ignore-title-mismatch` to regenerate `title-mismatch` rules
anyway (useful for the C 2012 ↔ 2023 numbering drift).

Verify idempotency on content this tool produced:

```bash
.venv/bin/python populate_help.py --standard MISRA-C++-2023
cd ../codeql-coding-standards-help && git diff --stat   # expect: empty
```

Supported standards (the source language is derived from `--standard`):

| `--standard`     | Language | Source dir under the queries repo |
|------------------|----------|-----------------------------------|
| `MISRA-C-2023`   | C        | `c/misra/src/rules`               |
| `MISRA-C-2012`   | C        | `c/misra/src/rules`               |
| `MISRA-C++-2023` | C++      | `cpp/misra/src/rules`             |

### Two-pass mode (deterministic extract + LLM render)

The deterministic populator above is reproducible and safe but cannot
recover document structure that the PDF doesn't expose: numbered
exception lists collapse to bullets, code examples lose their
original line breaks, kerning runs leave multi-space gaps inside
sentences, and footnote references like `C90 [Undefined 12]` leak
into titles. For higher-quality output, pair the populator with the
LLM second pass shipped in the
[`codeql-coding-standards-agent`](https://github.com/github/codeql-coding-standards-agent)
extension (v0.3.0+).

Step 1 — emit the structured rule cache as JSON for the LLM pass to
consume:

```bash
.venv/bin/python dump_rules_json.py --standard MISRA-C-2012
.venv/bin/python dump_rules_json.py --standard MISRA-C++-2023
```

This writes `<help-repo>/.misra-rule-cache/<standard>.json` (the
directory is gitignored locally) containing every extracted rule
plus, for each `.ql` query that targets the rule, the query's
`@name` title, the target `.md` path, and the existing `.md`
content (so the model can preserve human edits).

Step 2 — open the help repo in VS Code with the agent extension
installed, then run **CodeQL Coding Standards: Rewrite MISRA Help
Docs (LLM second pass)** from the Command Palette. It quick-picks
the standard, an optional rule filter, an overwrite policy, a
dry-run toggle, and an optional limit; then iterates every selected
query, asking the configured Copilot chat model to render an
idiomatic Markdown help file from the structured JSON + the `.ql`
`@name` + the existing `.md`. The output schema is fixed by the
system prompt so files stay diff-friendly across reruns.

The LLM pass is **not** byte-stable across runs (we measured 0/8
files byte-stable on a representative sample × 3 passes), but the
variance is purely cosmetic — punctuation, blank-line placement,
code-comment alignment, list-marker presence — with no content
drift. Picking any single pass and committing it is safe.

## Determinism

The post-docling stages are byte-deterministic by construction (no
time-of-day, no PRNG, dataclass field order preserved by
`dataclasses.fields`, dict iteration order preserved since Python 3.7).
End-to-end determinism (including docling itself) is verified with the
included harness, which runs N fresh-cache iterations and reports any
per-section hash divergence:

```bash
# Fast: re-test only the post-docling stages (uses cached JSON).
.venv/bin/python harness.py --standard MISRA-C++-2023 -n 5 --keep-cache \
    --pdf "$MISRA_CPP_PDF"

# Full e2e: clears the docling cache between iterations
# (~70 s/iter on CPP, ~155 s/iter on C).
.venv/bin/python harness.py --standard MISRA-C++-2023 -n 5 \
    --pdf "$MISRA_CPP_PDF"
```

The harness emits a per-section stability table and writes a JSON report
listing every rule's per-section sha256 hashes across all iterations. Run
it whenever `extract_rules.py` changes, or when adding support for a new
MISRA edition, to confirm output is byte-stable across runs.

## Known limitations

These are properties of docling's PDF interpretation. They are
**deterministic defects** (the same wrong output every run), not
flakiness:

- **Code blocks lose internal newlines.** The MISRA C++ PDF in particular
  emits code as a single long line per logical block. Token-level content
  is preserved (every identifier, operator and comment is still there),
  but the rendered Markdown shows long single-line code samples.
- **Font-CMap-induced ligature corruption in the MISRA C++ PDF.**
  The `fi`, `fl`, `ff`, `ffi`, `ffl` ligatures get rendered as digit or
  letter glyphs (`9`, `2`, `C`, `A`, `^`, `%`). The parser
  deterministically repairs these via wordlist lookup
  (`/usr/share/dict/words` plus a curated extras list); each suspect
  token is repaired only when exactly one ligature substitution yields
  a real English word, and pure-numeric tokens are left alone so rule
  anchors like "Rule 4.10" are preserved.
- **Some rule headings get merged into adjacent items by docling.** For
  the affected rules, the parser splices in synthetic anchors so the rule
  still appears with full Classification + best-effort
  Example/Amplification rather than being dropped.
- **Page running heads** (e.g. "Section 4: Guidelines") occasionally leak
  into `code` items. They are stripped from body section accumulation
  during extraction but may still appear inside code-block content.

## Adding a new standard

To extend the populator to another MISRA edition or another standard with
the same shape:

1. Add a `standard → (lang, source_rel_dir)` entry to `STANDARD_INFO` in
   `populate_help.py`. Add matching entries to `PDF_ENV_VARS` (the env
   var users will set) and `PDF_FILE_GLOBS` (the filename globs the
   resolver will look for inside the help repo). No filename is ever
   hard-coded.
2. Add the standard to `STD_DISPLAY` in `extract_rules.py` so the rendered
   reference line carries the correct human-readable name.
3. If the new standard's rule headings are merged into neighbouring items
   by docling (visible as missing rules in the harness output), add a
   resolver to `_MISSING_ANCHOR_RESOLVERS` that returns synthetic anchors.
4. Run the harness with `-n 5` to confirm byte-stability before publishing
   regenerated help files.
