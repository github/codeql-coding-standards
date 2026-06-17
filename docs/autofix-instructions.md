[//]: # "Include this file in the repository to provide instructions to GitHub Copilot Autofix. For more information, see https://docs.github.com/copilot/copilot-for-business/copilot-instructions."


# Agentic autofix instructions for CodeQL Coding Standards

This document configures **Agentic Autofix** when generating pull requests to
remediate alerts produced by [CodeQL Coding Standards](https://github.com/github/codeql-coding-standards/).
It applies to alerts for any of the supported standards (MISRA C, MISRA C++,
AUTOSAR C++, CERT C, CERT C++).

## 1. Reference material — where to learn each rule

Before proposing a fix, consult the rule’s authoritative implementation as well
as the corresponding compliant and non-compliant code patterns available as
test cases in the [`github/codeql-coding-standards` repository](https://github.com/github/codeql-coding-standards/).
That repository is the single source of truth for what the query
detects and what compliant code looks like.

Project layout (per language / standard):

```
<language>/<standard>/src/rules/<rule-id>/    # query source (.ql) and rule help (.md, .qhelp)
<language>/<standard>/test/rules/<rule-id>/   # test cases, with COMPLIANT / NON_COMPLIANT markers
```

When referring to the alerts you are addressing, include a clickable link
to the Code Scanning result (e.g. `./security/code-scanning/<id>`).

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

## 2. Fix discipline — keep changes minimal and standards-compliant

- **Minimum diff.** Modify the smallest possible amount of code that
  eliminates the alert. Do not refactor surrounding code, rename symbols,
  reformat unrelated lines, or change public APIs unless strictly required to
  satisfy the rule.
- **No drive-by changes.** Do not add features, fix unrelated warnings, change
  build flags, update dependencies, or “improve” code that the alert does not
  point at.
- **Do not attempt at fixing design issues.** A fix should not attempt to
  “improve” the design of the code or address architectural issues.
  Always verify that the code section around the alert is intended to follow
  the standard and add a comment.
  The presence of certain design issues (e.g. dynamic memory allocation) might
  indicate that the code is not intended to be compliant with the standard, and
  that a deviation should be added instead of a code fix.
- **New code must comply with the same standard.** Any code introduced by the
  fix must itself satisfy the coding standard being verified (e.g. MISRA C++
  2023). Cross-check the inserted code against the COMPLIANT examples in the
  corresponding `test/rules/<rule-id>/` directory and against neighbouring
  rules that are obviously relevant (e.g. don’t fix an integer-conversion rule
  by introducing a cast that violates a different MISRA rule).
- **Preserve safe and desired functional behavior.** ensure the resulting code
  handles all reasonable real-world scenarios as the code originally intended.
  This may involve precisely maintaining the existing code behavior, or it may
  involve fixing subtle or rare bugs, for instance dangerous overflows,
  that the existing code does not handle and the rule is designed to detect.
- **Fix dangerous bugs** If the alert is flagging unsafe or undefined behavior,
  critically examine how that safety issue in the code should be properly fixed.
  Add detections and error handling if necessary to make the code safe under
  all conditions without introducing unnecessary complexity. Follow existing
  project guidelines on how to handle rare, dangerous, or unexpected scenarios
  that occur at runtime.
- **Thoroughly explain analysis and functional changes.** If the alert does not
  introduce any unwanted behavior and the change is functionally equivalent,
  explain your thinking, and clearly show that the code before was safe, and
  that the new code is exactly equivalent in behavior.
  If there was a dangerous edge case or condition, explain exactly how that
  scenario would create problems in the code and how the fix will prevent such
  issues and improve the safety and quality of the codebase.

## 3. Do not touch build output, generated files, or `.gitignore`

Autofix pull requests must only change source files that are part of the
checked-in project. They must **not** include:

- Build directories or files generated during compilation (`.build/`, etc.).
- Editor / IDE state (`.vscode/`, `.idea/`, `.DS_Store`, etc.).
- **`.gitignore` itself.** Do not add, remove, or reorder entries in
  `.gitignore` as part of an autofix.
- The CodeQL workflow files under `.github/workflows/` (e.g. `codeql.yml`).
  Suppression or scope changes must use the deviation mechanism (see §4),
  not workflow edits.

## 4. Deviations — respect project policy and reference it in fixes

A project may declare that a rule, file, region, or specific construct is
intentionally exempt from a coding standard. Such deviations are
not always expressed through the same mechanism: a project may use the
**standard CodeQL Coding Standards deviation mechanism**, a
**custom annotation or attribute** convention,
**in-source line / block comments**,
or a **separate documentation file** (for example a `DEVIATIONS.md`,
`MISRA-deviations.md`, `coding-standards.yml`, compliance matrix, or similar).

Locate the deviations file and explicitly search for matching deviations
before proposing code changes.
The fix proposal must take what is found into account and treat it as an
existing deviation if it clearly covers the alert location and rule.

If the alert location is covered by an existing deviation:
- Look for existing deviations of that rule, and see if any should apply
- In the pull request description, explicitly state that a matching
  deviation already exists in the project, citing the file path and the
  relevant `rule-id` / `query-id` / `permit-id` / `code-identifier` / scope
  (paths or markers) so reviewers can decide whether to accept the fix or
  keep the deviation.
- Do not silently delete or weaken an existing deviation, permit, or
  re-categorization entry as part of the fix.
- Propose a code fix that would make the location compliant by
  default. Authors may have left the deviation in place pragmatically and
  may prefer a real fix.
- Consider whether an existing code identifier should be used
- Consider whether a file-wide exception should be used
- Consider whether a new code identifier should be used
- If using a code-identifier, look for examples to determine whether 
  to use [[attribute]] form
- If using an [[attribute]], look for project formatting configurations or code
  examples to determine how to format the attribute relative to its declaration
- When using deviation comments, consider project formatting, the specific
  violation in question, and other example deviation comments in the project to
  determine whether to use same-line, next-line, or begin/end comment deviations
  Project formatting configuration may be .clang-format, etc.

## 5. False positives — propose a deviation, do not stay silent

Precedence: if an alert is judged to be a false positive, the false-positive
workflow in this section overrides any guidance above about proposing a code
fix when a deviation exists.

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
