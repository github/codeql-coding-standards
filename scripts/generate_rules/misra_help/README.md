# MISRA help-file populator

Generates per-query Markdown help files in
`codeql-coding-standards-help/{c,cpp}/misra/src/rules/<RULE-ID>/<Name>.md`
from the licensed MISRA PDFs.

## Prerequisites

1. **Python venv with docling** (~3 GB, not in `scripts/requirements.txt`):

   ```bash
   python3 -m venv .venv && .venv/bin/pip install docling
   ```

2. **MISRA PDFs** — licensed material, excluded from version control.
   Place them in your `codeql-coding-standards-help` checkout:

   ```bash
   cp ~/Downloads/MISRA-C-2023-*.pdf   ../codeql-coding-standards-help/
   cp ~/Downloads/MISRA-CPP-2023-*.pdf ../codeql-coding-standards-help/
   ```

   The tool resolves PDFs via: `--pdf` flag > `$MISRA_C_PDF` /
   `$MISRA_CPP_PDF` env vars > glob in `--help-repo`.

## Usage

```bash
# Deterministic render (Stage 1 only):
.venv/bin/python populate_help.py --standard MISRA-C++-2023
.venv/bin/python populate_help.py --standard MISRA-C-2012

# Single rule:
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --rule RULE-8-1

# Fill in missing help only (don't overwrite existing):
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --no-overwrite

# Preview without writing:
.venv/bin/python populate_help.py --standard MISRA-C++-2023 --dry-run
```

### Two-pass mode (deterministic + LLM lint)

```bash
# 1. Build the JSON sidecar:
.venv/bin/python dump_rules_json.py --standard MISRA-C-2012

# 2. Re-render + LLM proofread:
.venv/bin/python refresh_help.py --standard MISRA-C-2012
```

## Files

| File                  | Purpose                                                 |
| --------------------- | ------------------------------------------------------- |
| `extract_rules.py`    | docling PDF → `Rule` dataclasses (deterministic core)   |
| `populate_help.py`    | Walk `.ql` queries, render and write `.md` help files   |
| `dump_rules_json.py`  | Emit JSON sidecar for the LLM rewrite pass              |
| `rewrite_help.py`     | Headless Copilot driver for LLM lint/proofread          |
| `refresh_help.py`     | Combined Stage 1 + cache patch + Stage 2 runner         |
| `harness.py`          | Determinism harness (per-section hashing across N runs) |
| `cache.py`            | Shared helpers for cache path resolution and I/O        |

