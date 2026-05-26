[//]: # "Include this file in the repository to provide instructions to GitHub Copilot AUtofix. For more information, see https://docs.github.com/copilot/copilot-for-business/copilot-instructions."
# GitHub Copilot instructions

This file contains repository-wide guidance for GitHub Copilot. Each top-level
section below configures Copilot for a specific use case in this repository.
Add further top-level sections as needed (general coding conventions, review
guidance, etc.).

## Agentic autofix for CodeQL Coding Standards

This section configures GitHub Copilot (in particular, Copilot **agentic
autofix**) when it generates pull requests to remediate alerts produced by the
[CodeQL Coding Standards](https://github.com/github/codeql-coding-standards/)
project. It applies to alerts for any of the supported standards (MISRA C,
MISRA C++, AUTOSAR C++, CERT C, CERT C++).

### 1. Reference material — where to learn each rule

Before proposing a fix, consult the rule’s authoritative implementation as well as the corresponding compliant and non-compliant code patterns available as test cases in the CodeQL Coding Standards [`github/codeql-coding-standards`](https://github.com/github/codeql-coding-standards/)
repository. That repository is the single source of truth for what the query
detects and what compliant code looks like.

Project layout (per language / standard):

```
<language>/<standard>/src/rules/<rule-id>/    # query source (.ql) and rule help (.md, .qhelp)
<language>/<standard>/test/rules/<rule-id>/   # test cases, with COMPLIANT / NON_COMPLIANT markers
```

When generating a fix:

1. Locate the rule directory matching the alert’s rule id / query id.
2. Read the `.md` / `.qhelp` help file in `src/rules/<rule-id>/` to understand
   the intent and the recommended remediation.
3. Read the files in `test/rules/<rule-id>/`. Lines (or blocks) annotated with
   `// COMPLIANT` show patterns that pass the query; lines annotated with
   `// NON_COMPLIANT` show patterns that trigger the query. Use these as the
   ground truth for what the fixed code must look like.

The full list of supported rules per standard is published as
`supported_rules_list_<version>.csv` / `.md` in each
[release](https://github.com/github/codeql-coding-standards/releases).

### 2. Fix discipline — keep changes minimal and standards-compliant

- **Minimum diff.** Modify the smallest possible amount of code that
  eliminates the alert. Do not refactor surrounding code, rename symbols,
  reformat unrelated lines, or change public APIs unless strictly required to
  satisfy the rule.
- **No drive-by changes.** Do not add features, fix unrelated warnings, change
  build flags, update dependencies, or “improve” code that the alert does not
  point at.
- **New code must comply with the same standard.** Any code introduced by the
  fix must itself satisfy the coding standard being verified (e.g. MISRA C++
  2023). Cross-check the inserted code against the COMPLIANT examples in the
  corresponding `test/rules/<rule-id>/` directory and against neighbouring
  rules that are obviously relevant (e.g. don’t fix an integer-conversion rule
  by introducing a cast that violates a different MISRA rule).
- **Match the project’s existing style.** Follow the conventions visible in
  the surrounding source files (naming, headers, namespaces, C++ standard
  level, use of `enum class`, etc.).
- **Preserve behaviour.** A coding-standards fix is a refactor at the source
  level, not a functional change. The fix must not alter observable runtime
  behaviour unless the rule explicitly targets undefined or implementation-
  defined behaviour that has to change.

### 3. Do not touch build outputs, generated files, or `.gitignore`

Autofix pull requests must only change source files that are part of the
checked-in project. They must **not** include:

- Build directories or files generated during compilation.
- Editor / IDE state (`.vscode/`, `.idea/`, `.DS_Store`, etc.).
- **`.gitignore` itself.** Do not add, remove, or reorder entries in
  `.gitignore` as part of an autofix.
- The CodeQL workflow files under `.github/workflows/` (e.g. `codeql.yml`).
  Suppression or scope changes must use the deviation mechanism (see §4),
  not workflow edits.

### 4. Deviations — respect project policy and reference it in fixes

A project under analysis may declare that a rule, file, region, or specific
construct is intentionally exempt from a coding standard. Such deviations are
not always expressed through the same mechanism: a project may use the
**standard CodeQL Coding Standards deviation mechanism**, a **custom
annotation or attribute** convention, **in-source line / block comments**,
or a **separate documentation file** (for example a `DEVIATIONS.md`,
`MISRA-deviations.md`, compliance matrix, or similar).

The fix proposal must take what is found into account and treat it as an existing deviation if it clearly covers the alert location and rule.

If the alert location is covered by an existing deviation:

- **Still propose a code fix** that would make the location compliant by
  default. Authors may have left the deviation in place pragmatically and
  may prefer a real fix.
- **In the pull request description, explicitly state** that a matching
  deviation already exists in the project, citing the file path and the
  relevant `rule-id` / `query-id` / `permit-id` / `code-identifier` / scope
  (paths or markers) so reviewers can decide whether to accept the fix or
  keep the deviation.
- Do not silently delete or weaken an existing deviation, permit, or
  re-categorization entry as part of the fix.

### 5. False positives — propose a deviation, do not stay silent

Copilot autofix normally refrains from opening a pull request when it
considers an alert to be a false positive. For CodeQL Coding Standards alerts
this behaviour is **overridden**: a false-positive determination must still
result in a pull request, and that pull request must record the decision
using the project’s deviation mechanism.

The CodeQL Coding Standards project supports an explicit deviation mechanism,
fully documented in
[`docs/user_manual.md`](https://github.com/github/codeql-coding-standards/blob/main/docs/user_manual.md)
(sections “Applying deviations”, “Deviation records”, “Deviation permits”,
“Guideline re-categorization plan”).
When an alert is judged to be a false positive, the autofix PR must:

1. **Not modify the flagged code** to “work around” the alert.
2. **Add or update a deviation record** that scopes precisely to the alert.
   Prefer the narrowest scope that is appropriate:
   - a `code-identifier` deviation referenced from the exact line, statement,
     function, or block, via an attribute
     (`[[codeql::<standard>_deviation("...")]]`) or a comment marker
     (`// codeql::<standard>_deviation(...)`,
     `// codeql::<standard>_deviation_next_line(...)`, or a
     `..._deviation_begin` / `..._deviation_end` pair); or
   - a `paths:`-scoped deviation in `coding-standards.yml` when a whole file
     or directory is affected;
   - a project-wide deviation only when the rule is genuinely inapplicable to
     the project.
   Use `<standard>` ∈ {`misra`, `autosar`, `cert`} as appropriate for the
   alert.
3. **Populate the deviation record** with at least:
   - `rule-id` matching the alert’s rule identifier;
   - `query-id` matching the alert’s `@id` (when the deviation is meant to
     cover a single sub-query of the rule);
   - a clear `justification` explaining why the alert is a false positive
     (what the query missed, why the code is in fact compliant or safe);
   - `scope`, `background`, and `requirements` when they help a reviewer
     audit the decision;
   - a `raised-by` entry (and leave `approved-by` for a human reviewer).
4. **Place the deviation entry** in an existing `coding-standards.yml` if one
   exists in an appropriate directory; otherwise create one at the most
   specific directory whose subtree is affected. When using a `permit-id`,
   reference an existing permit if one matches; do not invent new permit IDs
   unless necessary.
5. **In the PR description**, explicitly state that the alert is being
   handled as a false positive via a deviation (not by code change), link to
   the
   [deviation mechanism documentation](https://github.com/github/codeql-coding-standards/blob/main/docs/user_manual.md#applying-deviations),
   and summarise the justification so a reviewer can approve or reject it.

A false-positive PR should therefore contain **only** the deviation entry
and/or the in-source deviation marker — no changes to logic, no edits to
build outputs, and no edits to `.gitignore`.
