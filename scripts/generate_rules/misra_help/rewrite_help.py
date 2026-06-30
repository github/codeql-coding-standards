"""Rewrite MISRA help (.md) files using GitHub Copilot as a second pass.

The deterministic Python pipeline (`extract_rules.py` + `populate_help.py`)
extracts each rule from the licensed MISRA PDFs into Markdown plus a
structured JSON sidecar (via `dump_rules_json.py`). This script reads
that JSON and asks GitHub Copilot to render an idiomatic, well-formatted
help file for every query that targets the rule.

This is a true headless driver: it talks directly to the Copilot chat
completions endpoint (`https://api.githubcopilot.com/chat/completions`)
using the OAuth token that the official Copilot extensions store on
disk. No VS Code, no extension required.

Token discovery order:
1. Environment variable `GH_COPILOT_OAUTH_TOKEN`.
2. `~/.config/github-copilot/apps.json`  (current Copilot).
3. `~/.config/github-copilot/hosts.json` (legacy Copilot).

The OAuth token is exchanged for a short-lived Copilot API token via
`https://api.github.com/copilot_internal/v2/token` and refreshed
automatically before expiry.

Usage:
    python rewrite_help.py --standard MISRA-C-2012
    python rewrite_help.py --standard MISRA-C++-2023 --rule RULE-6-7-1
    python rewrite_help.py --standard MISRA-C-2012 --limit 5 --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

import requests

sys.path.insert(0, str(Path(__file__).resolve().parent))


SUPPORTED_STANDARDS = ("MISRA-C-2012", "MISRA-C-2023", "MISRA-C++-2023")
STD_DISPLAY = {
    "MISRA-C-2012": "MISRA C 2012",
    "MISRA-C-2023": "MISRA C 2012",
    "MISRA-C++-2023": "MISRA C++ 2023",
}

DEFAULT_HELP_REPO = (
    Path(__file__).resolve().parents[3].parent / "codeql-coding-standards-help"
)

COPILOT_TOKEN_URL = "https://api.github.com/copilot_internal/v2/token"
COPILOT_CHAT_URL = "https://api.githubcopilot.com/chat/completions"

# Headers required by the Copilot backend. The editor identification
# strings mirror what a real editor sends; the Copilot service rejects
# requests without them.
EDITOR_VERSION = "vscode/1.99.0"
EDITOR_PLUGIN = "copilot-chat/0.20.0"
COPILOT_INTEGRATION_ID = "vscode-chat"
USER_AGENT = "GitHubCopilotChat/0.20.0"

DEFAULT_MODEL = "claude-sonnet-4"
MODEL_FALLBACKS = ("claude-sonnet-4", "claude-3.7-sonnet", "gpt-4o", "gpt-4")


# ---------------------------------------------------------------------------
# Token handling
# ---------------------------------------------------------------------------


def _read_oauth_token_from_apps(path: Path) -> str | None:
    """Read OAuth token from the current `apps.json` Copilot store."""
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    # apps.json maps "github.com:<client_id>" -> {"oauth_token": "..."}.
    for entry in data.values():
        token = entry.get("oauth_token") if isinstance(entry, dict) else None
        if token:
            return token
    return None


def _read_oauth_token_from_hosts(path: Path) -> str | None:
    """Read OAuth token from the legacy `hosts.json` Copilot store."""
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    entry = data.get("github.com")
    if isinstance(entry, dict):
        token = entry.get("oauth_token")
        if token:
            return token
    return None


def discover_oauth_token() -> str:
    """Find a Copilot OAuth token on this machine."""
    env = os.environ.get("GH_COPILOT_OAUTH_TOKEN")
    if env:
        return env.strip()
    base = Path.home() / ".config" / "github-copilot"
    candidates = [
        ("apps.json", _read_oauth_token_from_apps),
        ("hosts.json", _read_oauth_token_from_hosts),
    ]
    for name, reader in candidates:
        token = reader(base / name)
        if token:
            return token
    raise RuntimeError(
        "No Copilot OAuth token found. Either set GH_COPILOT_OAUTH_TOKEN, "
        "or sign in to GitHub Copilot in VS Code / the gh CLI so that "
        f"{base}/apps.json or hosts.json exists."
    )


@dataclass
class CopilotToken:
    token: str
    expires_at: int  # unix seconds

    def near_expiry(self, slack_seconds: int = 300) -> bool:
        return time.time() + slack_seconds >= self.expires_at


def fetch_copilot_token(oauth_token: str) -> CopilotToken:
    """Exchange a GitHub OAuth token for a short-lived Copilot API token."""
    resp = requests.get(
        COPILOT_TOKEN_URL,
        headers={
            "Authorization": f"token {oauth_token}",
            "Editor-Version": EDITOR_VERSION,
            "Editor-Plugin-Version": EDITOR_PLUGIN,
            "User-Agent": USER_AGENT,
            "Accept": "application/json",
        },
        timeout=30,
    )
    if resp.status_code != 200:
        raise RuntimeError(
            f"Copilot token exchange failed: HTTP {resp.status_code} {resp.text[:200]}"
        )
    body = resp.json()
    return CopilotToken(token=body["token"], expires_at=int(body["expires_at"]))


class CopilotSession:
    """Holds the OAuth token and the current short-lived API token."""

    def __init__(self, oauth_token: str) -> None:
        self._oauth = oauth_token
        self._tok: CopilotToken | None = None

    def token(self) -> str:
        if self._tok is None or self._tok.near_expiry():
            self._tok = fetch_copilot_token(self._oauth)
        return self._tok.token

    def chat(
        self,
        messages: list[dict[str, str]],
        model: str,
        temperature: float = 0.0,
        max_tokens: int = 4096,
    ) -> str:
        """Call chat completions and return the assistant message text."""
        last_err: Exception | None = None
        for attempt in range(3):
            headers = {
                "Authorization": f"Bearer {self.token()}",
                "Editor-Version": EDITOR_VERSION,
                "Editor-Plugin-Version": EDITOR_PLUGIN,
                "Copilot-Integration-Id": COPILOT_INTEGRATION_ID,
                "User-Agent": USER_AGENT,
                "Content-Type": "application/json",
                "Accept": "application/json",
            }
            payload = {
                "model": model,
                "messages": messages,
                "temperature": temperature,
                "max_tokens": max_tokens,
                "stream": False,
                "n": 1,
            }
            try:
                resp = requests.post(
                    COPILOT_CHAT_URL,
                    headers=headers,
                    json=payload,
                    timeout=180,
                )
            except requests.RequestException as exc:
                last_err = exc
                time.sleep(2 ** attempt)
                continue
            if resp.status_code == 401:
                # Token may have expired between the near-expiry check
                # and the request. Force a refresh and retry once.
                self._tok = None
                last_err = RuntimeError(f"401: {resp.text[:200]}")
                continue
            if resp.status_code == 429 or 500 <= resp.status_code < 600:
                last_err = RuntimeError(
                    f"HTTP {resp.status_code}: {resp.text[:200]}"
                )
                time.sleep(2 ** attempt)
                continue
            if resp.status_code != 200:
                raise RuntimeError(
                    f"Copilot chat failed: HTTP {resp.status_code} {resp.text[:500]}"
                )
            data = resp.json()
            return data["choices"][0]["message"]["content"]
        raise RuntimeError(f"Copilot chat failed after retries: {last_err}")


# ---------------------------------------------------------------------------
# Prompt construction (mirrors codeql-coding-standards-agent/src/rewriteHelp.ts)
# ---------------------------------------------------------------------------


def system_prompt() -> str:
    return "\n".join([
        "You are a documentation linter, formatter, and proofreader for"
        " MISRA query help files (Markdown).",
        "",
        "You are NOT an author. Your job is to take an existing query"
        " help file and apply ONLY the transformations listed below."
        " The input document was generated deterministically from the"
        " licensed MISRA rule text and should be preserved as-is except"
        " for the specific fixes you are instructed to make.",
        "",
        "ALLOWED changes (apply all that are applicable):",
        "",
        "1. American English: convert British spellings throughout all"
        "   prose (NOT code, identifiers, or text inside `code spans`)."
        "   Common conversions: behaviour->behavior,"
        "   initialise->initialize, initialised->initialized,"
        "   initialisation->initialization, recognise->recognize,"
        "   organisation->organization, optimise->optimize,"
        "   analyse->analyze, modelling->modeling,"
        "   signalling->signaling, programme->program,"
        "   centre->center, colour->color, defence->defense,"
        "   licence (noun)->license, judgement->judgment,"
        "   fulfil->fulfill, whilst->while, amongst->among,"
        "   learnt->learned, spelt->spelled, catalogue->catalog,"
        "   dialogue->dialog, artefact->artifact.",
        "",
        "2. PDF extraction artifacts:",
        "   - Strip footnote references: \"C90 [Undefined 12]\","
        "     \"C99 [...]\", \"C11 [...]\", \"C17 [...]\".",
        "   - Strip bracketed cross-reference tags:"
        "     \"[dcl.enum]\", \"[class.bit]\".",
        "   - Collapse multi-space kerning runs"
        "     (\"If   any   element\" -> \"If any element\").",
        "   - Fix stray spaces before punctuation"
        "     (\"virtual , override\" -> \"virtual, override\").",
        "   - Replace curly quotes with straight quotes.",
        "",
        "3. Markdown formatting (fix only if broken):",
        "   - Code blocks must use the correct language tag"
        "     (```c or ```cpp).",
        "   - Numbered exceptions must use \"1.\", \"2.\", \"3.\""
        "     format, never bullets.",
        "",
        "4. Heading title: the \"# <Rule|Dir> X.Y[.Z]: <title>\""
        "   heading must use the title from the .ql @name metadata"
        "   (provided in the input as ql_name_title), which is the"
        "   authoritative short title.",
        "",
        "5. Implementation notes: if IMPLEMENTATION_SCOPE text is"
        "   provided in the input, use it verbatim in the"
        "   \"## Implementation notes\" section. Otherwise, leave"
        "   the section as \"None\". Never invent implementation"
        "   notes.",
        "",
        "6. Structure: verify the document follows this section"
        "   order. Fix ordering if wrong, but do NOT add sections"
        "   that have no content in the input:",
        "   - # <Rule|Dir> X.Y[.Z]: <title>",
        "   - \"This query implements ...\" + blockquote",
        "   - ## Classification (HTML table)",
        "   - ### Amplification (if content exists)",
        "   - ### Rationale (if content exists)",
        "   - ### Exception (if content exists)",
        "   - ## Example (if content exists)",
        "   - ## See also (if content exists)",
        "   - ## Implementation notes",
        "   - ## References",
        "",
        "FORBIDDEN (do NOT do any of these):",
        "- Do NOT paraphrase, summarize, or rewrite the rule text"
        "   in your own words.",
        "- Do NOT add explanatory text, examples, or content not"
        "   present in the input.",
        "- Do NOT remove content that is present in the input"
        "   (unless it is a PDF artifact listed above).",
        "- Do NOT change technical meaning, even subtly.",
        "- Do NOT modify code inside fenced code blocks."
        "   Preserve indentation, brace placement, comment"
        "   positions, and alignment exactly as given.",
        "- Do NOT change brace placement style (e.g. Allman to"
        "   K&R or vice versa).",
        "- Do NOT merge separate fenced code blocks into one or"
        "   convert prose paragraphs between code blocks into"
        "   code comments.",
        "- Do NOT wrap the entire output in a fenced code block.",
        "",
        "Output ONLY the corrected Markdown file content."
        " No commentary before or after."
        " End with exactly one trailing newline.",
    ])


def user_prompt(rule: dict[str, Any], query: dict[str, Any], standard: str) -> str:
    existing = query.get("existing_md")
    impl_scope = query.get("implementation_scope")

    parts: list[str] = []

    if existing:
        parts += [
            "Lint, format, and proofread the following query help file.",
            "Apply ONLY the allowed transformations from your instructions.",
            "Do NOT rewrite or paraphrase -- preserve the original text.",
            "",
            "DOCUMENT TO PROOFREAD:",
            "```markdown",
            existing.rstrip("\n"),
            "```",
            "",
        ]
    else:
        parts += [
            "Format the following rule data into a query help file.",
            "Use the literal MISRA rule text below -- do NOT paraphrase.",
            "Follow the section structure from your instructions exactly.",
            "",
        ]

    # Provide rule JSON as reference (for fact-checking or initial
    # formatting when there is no existing_md).
    payload = {
        "standard": standard,
        "standard_display": STD_DISPLAY[standard],
        "rule": rule,
        "query": {k: v for k, v in query.items() if k != "existing_md"},
    }
    parts += [
        "REFERENCE DATA (for fact-checking and metadata):",
        "```json",
        json.dumps(payload, indent=2),
        "```",
        "",
    ]

    if impl_scope:
        desc = impl_scope.get("description", "")
        items = impl_scope.get("items", [])
        parts.append("IMPLEMENTATION_SCOPE (use verbatim in"
                      " '## Implementation notes'):")
        parts.append(desc)
        for item in items:
            parts.append(f"* {item}")
        parts.append("")

    parts += [
        f"The heading MUST be \"# {rule['raw_id']}: <title>\" where"
        f" <title> comes from ql_name_title"
        f" (\"{query.get('ql_name_title', '')}\"),"
        f" NOT from the PDF rule title.",
        "",
        "Now emit the proofread .md content.",
    ]

    return "\n".join(parts)


def unwrap_fence(text: str) -> str:
    """Strip ```markdown ... ``` if the model wrapped the whole file."""
    s = text.strip()
    for tag in ("markdown", "md", ""):
        prefix = f"```{tag}\n" if tag else "```\n"
        if s.startswith(prefix) and s.endswith("\n```"):
            return s[len(prefix):-4]
        if s.startswith(prefix.rstrip("\n")) and s.endswith("```"):
            inner = s[len(prefix.rstrip("\n")):-3].lstrip("\n").rstrip()
            return inner
    return text


# ---------------------------------------------------------------------------
# Main rewrite loop
# ---------------------------------------------------------------------------

from cache import load_cache  # noqa: E402


def iter_work(
    cache: dict[str, Any],
    rule_filter: set[str] | None,
) -> Iterable[tuple[dict[str, Any], dict[str, Any]]]:
    rules = cache["rules"]
    queries = cache["queries"]
    for rule_id in sorted(queries.keys()):
        if rule_filter and rule_id not in rule_filter:
            continue
        rule = rules.get(rule_id)
        if rule is None:
            print(f"  skip {rule_id}: no PDF rule entry", file=sys.stderr)
            continue
        for q in queries[rule_id]:
            yield rule, q


def rewrite_one(
    session: CopilotSession,
    rule: dict[str, Any],
    query: dict[str, Any],
    standard: str,
    model: str,
) -> str:
    messages = [
        {"role": "system", "content": system_prompt()},
        {"role": "user", "content": user_prompt(rule, query, standard)},
    ]
    body = session.chat(messages, model=model)
    body = unwrap_fence(body).strip()
    if not body.endswith("\n"):
        body += "\n"
    return body


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n\n", 1)[0])
    p.add_argument("--standard", required=True, choices=SUPPORTED_STANDARDS)
    p.add_argument("--help-repo", type=Path, default=DEFAULT_HELP_REPO,
                   help=f"Path to codeql-coding-standards-help (default: {DEFAULT_HELP_REPO}).")
    p.add_argument("--rule", action="append", default=[],
                   help="Restrict to specific rule IDs (e.g. RULE-6-7-1). Repeatable.")
    p.add_argument("--model", default=DEFAULT_MODEL,
                   help=f"Copilot model id. Default: {DEFAULT_MODEL}. "
                        f"Known good: {', '.join(MODEL_FALLBACKS)}.")
    p.add_argument("--no-overwrite", action="store_true",
                   help="Skip queries that already have a .md file.")
    p.add_argument("--dry-run", action="store_true",
                   help="Plan and call the model but do not write files.")
    p.add_argument("--limit", type=int, default=None,
                   help="Process at most N (rule, query) pairs.")
    args = p.parse_args()

    help_repo: Path = args.help_repo.resolve()
    if not help_repo.is_dir():
        print(f"help repo not found: {help_repo}", file=sys.stderr)
        return 2

    cache = load_cache(help_repo, args.standard)
    rule_filter = {r.upper() for r in args.rule} if args.rule else None

    work = list(iter_work(cache, rule_filter))
    if args.limit is not None:
        work = work[: args.limit]
    print(f"Planned: {len(work)} (rule, query) pairs for {args.standard}")

    oauth = discover_oauth_token()
    session = CopilotSession(oauth)
    # Force an early token fetch so auth failures surface before we
    # start iterating.
    _ = session.token()
    print(f"Copilot session ready. Model: {args.model}")

    wrote = unchanged = skipped = failed = 0
    for i, (rule, query) in enumerate(work, 1):
        rel = query["md_path"]
        target = help_repo / rel
        existing = query.get("existing_md")

        if existing is not None and args.no_overwrite:
            print(f"[{i}/{len(work)}] skip-existing {rel}")
            skipped += 1
            continue

        try:
            body = rewrite_one(session, rule, query, args.standard, args.model)
        except Exception as exc:  # noqa: BLE001 - surface and keep going
            print(f"[{i}/{len(work)}] FAILED  {rel}: {exc}", file=sys.stderr)
            failed += 1
            continue

        if existing == body:
            print(f"[{i}/{len(work)}] unchanged {rel}")
            unchanged += 1
            continue

        if args.dry_run:
            print(f"[{i}/{len(work)}] would-write {rel} ({len(body)} bytes)")
            wrote += 1
            continue

        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(body, encoding="utf-8")
        verb = "wrote-new" if existing is None else "wrote-changed"
        print(f"[{i}/{len(work)}] {verb} {rel} ({len(body)} bytes)")
        wrote += 1

    print(
        f"\nDone. wrote={wrote} unchanged={unchanged} "
        f"skipped={skipped} failed={failed}"
    )
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
