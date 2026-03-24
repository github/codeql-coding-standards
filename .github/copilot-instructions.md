---
description: 'Code review guidelines for GitHub copilot in this project'
applyTo: '**'
excludeAgent: ["coding-agent"]
---

# Code Review Instructions

A change note is required for any pull request which modifies:
- The structure or layout of the release artifacts.
- The evaluation performance (memory, execution time) of an existing query.
- The results of an existing query in any circumstance.

If the pull request only adds new rule queries, a change note is not required.
Confirm that either a change note is not required or the change note is required and has been added.

For PRs that add new queries or modify existing queries, also consider the following review checklist:
- Confirm that the output format of shared queries is valid.
- Have all the relevant rule package description files been checked in?
- Have you verified that the metadata properties of each new query is set appropriately?
- Do all the unit tests contain both "COMPLIANT" and "NON_COMPLIANT" cases?
- Are all the alerts in the expected file annotated as NON_COMPLIANT in the test source file?
- Are the alert messages properly formatted and consistent with the style guide?
- Does the query have an appropriate level of in-query comments/documentation?
- Does the query not reinvent features in the standard library?
- Can the query be simplified further (not golfed!).

In your review output, list only those checklist items that are not satisfied or are uncertain, but also report any other problems you find outside this checklist; do not mention checklist items that clearly pass.

## Validating tests and .expected files

The test infrastructure for CodeQL that we use in this project involves the creation of a test directory with the following structure:
- Test root is `some/path/test/path/to/feature` (mirrors `some/path/src/path/to/query`)
- At least one test `c` or `c++` file, typically named `test.c`/`test.cpp`, with lines annotated `// COMPLIANT` or `// NON_COMPLIANT`
- A `.ql` file with test query logic, or a `.qlref` file referring to the production query logic
- A matching `FOO.expected` file to go with each `FOO.ql` or `FOO.qlref`, containing the test query results for the test `c` or `c++` files
- Note that some test directories simply have a `testref` file, to document that a certain query is tested in a different directory.

As a code reviewer, it is critical to ensure that the results in the `.expected` file match the comments in the test file.

The `.expected` file uses a columnar format:
- For example, a basic row may look like `| test.cpp:8:22:8:37 | element | message |`.
- For a query with `select x, "test"`, the columns are | x.getLocation() | x.toString() | "test" |`
- An alert with placeholders will use `$@` in the message, and have additional `element`/`string` columns for placeholder, e.g. `| test.cpp:8:22:8:37 | ... + ... | Invalid add of $@. | test.cpp:7:5:7:12 | my_var | deprecated variable my_var |`.
- Remember, there is one `.expected` file for each `.ql` or `.qlref` file.
- Each `.expected` file will contain the results for all test c/cpp files.
- The `toString()` format of QL objects is deliberately terse for performance reasons.
- For certain queries such as "path problems", the results may be grouped into categories via text lines with the category name, e.g. `nodes` and `edges` and `problems`.

Reviewing tests in this style can be tedious and error prone, but fundamental to the effectiveness of our TDD requirements in this project.

When reviewing tests, it is critical to:
- Check that each `NON_COMPLIANT` case in the test file has a row in the correct `.expected` file referring to the correct location.
- Check that each row in each `.expected` file has a `NON_COMPLIANT` case in the test file at the correct location.
- Check that there are no `.expected` rows that refer to test code cases marked as `COMPLIANT`, or with no comment
- Note that it is OK if the locations of the comment are not precisely aligned with the alert 
- Check that the alert message and placeholders are accurate and understandable.
- Check that the locations do not refer to files in the standard library, as these have issues in GitHub's Code Scanning UI and complicate our compiler compatibility tests.
- Consider the "test coverage" of the query, are each of its logical statements effectively exercised  individually, collectively? The test should neither be overly bloated nor under specified.
- Consider the edge cases of the language itself, will the analysis work in non-trivial cases, are all relevant language concepts tested here? This doesn't need to be exhaustive, but it should be thoughfully thorough.

## Validating Query style

The following list describes the required style guides for a query that **must** be validated during the code-review process.

A query **must** include:

- A use of the `isExcluded` predicate on the element reported as the primary location. This predicate ensures that we have a central mechanism for excluding results. This predicate may also be used on other elements relevant to the alert, but only if a suppression on that element should also cause alerts on the current element to be suppressed.
- A well formatted alert message:
  - The message should be a complete standalone sentence, with punctuation and a period.
  - The message should refer to this particular instance of the problem, rather than repeating the generic rule. e.g. "Call to banned function x." instead of "Do not use function x."
  - Code elements should be placed in 'single quotes', unless they are formatted as links.
  - Avoid value judgments such as "dubious" and "suspicious", and focus on factual statements about the problem.
  - If possible, avoid constant alert messages. Either add placeholders and links (using $@), or concatenate element names to the alert message. Non-constant messages make it easier to find particular results, and links to other program elements can help provide additional context to help a developer understand the results. Examples:
    - Instead of `Call to banned function.` prefer `Call to banned function foobar.`.
    - Instead of `Return value from call is unused.` prefer `Return value from call to function [x] is unused.`, where `[x]` is a link to the function itself.
  - Do not try to explain the solution in the message; instead that should be provided in the help for the query.

All public predicates, classes, modules and files should be documented with QLDoc. All QLDoc should follow the following QLDoc style guide:

### General QLDoc requirements

1. Documentation must adhere to the [QLDoc specification](https://codeql.github.com/docs/ql-language-reference/ql-language-specification/#qldoc).
1. Documentation comments should be appropriate for users of the code.
1. Documentation for maintainers of the code must use normal comments.
1. Use `/** ... */` for documentation, even for single line comments.
   - For single-line documentation, the `/**` and `*/` are written on the same line as the comment.
   - For multi-line documentation, the `/**` and `*/` are written on separate lines. There is a `*` preceding each comment line, aligned on the first `*`.
1. Use code formatting (backticks) within comments for code from the source language, and also for QL code (for example, names of classes, predicates, and variables).
1. Give explanatory examples of code in the target language, enclosed in ```` ```<target language> ````  or `` ` ``.


### Language requirements

1. Use American English.
1. Use full sentences, with capital letters and periods, except for the initial sentence of the comment, which may be fragmentary as described below.
1. Use simple sentence structures and avoid complex or academic language.
1. Avoid colloquialisms and contractions.
1. Use words that are in common usage.


### Requirements for specific items

1. Public declarations must be documented.
1. Non-public declarations should be documented.
1. Declarations in query files should be documented.
1. Library files (`.qll` files) should have a documentation comment at the top of the file.
1. Query files, except for tests, must have a QLDoc query documentation comment at the top of the file.

### QLDoc for predicates

1. Refer to all predicate parameters in the predicate documentation.
1. Reference names, such as types and parameters, using backticks `` ` ``.
1. Give examples of code in the target language, enclosed in ```` ```<target language> ````  or `` ` ``.
1. Predicates that override a single predicate don't need QLDoc, as they will inherit it.

#### Predicates without result

1. Use a third-person verb phrase of the form ``Holds if `arg` has <property>.``
1. Avoid:
   - `/** Whether ... */`
   - `/**" Relates ... */`
   - Question forms:
     - ``/** Is `x` a foo? */``
     - ``/** Does `x` have a bar? */``

##### Example

```ql
/**
 * Holds if the qualifier of this call has type `qualifierType`.
 * `isExactType` indicates whether the type is exact, that is, whether
 * the qualifier is guaranteed not to be a subtype of `qualifierType`.
 */
```

#### Predicates with result

1. Use a third-person verb phrase of the form `Gets (a|the) <thing>.`
1. Use "if any" if the item is usually unique but might be missing. For example
`Gets the body of this method, if any.`
1. If the predicate has more complex behaviour, for example multiple arguments are conceptually "outputs", it can be described like a predicate without a result. For example
``Holds if `result` is a child of this expression.``
1. Avoid:
   - `Get a ...`
   - `The ...`
   - `Results in ...`
   - Any use of `return`

##### Example
```ql
/**
 * Gets the expression denoting the super class of this class,
 * or nothing if this is an interface or a class without an `extends` clause.
 */
```

#### Deprecated predicates

The documentation for deprecated predicates should be updated to emphasize the deprecation and specify what predicate to use as an alternative.
Insert a sentence of the form `DEPRECATED: Use <other predicate> instead.` at the start of the QLDoc comment. 

##### Example

```ql
/** DEPRECATED: Use `getAnExpr()` instead. */
deprecated Expr getInitializer()
```

#### Internal predicates

Some predicates are internal-only declarations that cannot be made private. The documentation for internal predicates should begin with `INTERNAL: Do not use.`

##### Example

```ql
/**
 * INTERNAL: Do not use.
 */
```

#### Special predicates

Certain special predicates should be documented consistently.

- Always document `toString` as 
  
  ```ql
  /** Gets a textual representation of this element. */
  string toString() { ... } 
  ```

- Always document `hasLocationInfo` as

  ```ql
  /**
   * Holds if this element is at the specified location.
   * The location spans column `startcolumn` of line `startline` to
   * column `endcolumn` of line `endline` in file `filepath`.
   * For more information, see
   * [Locations](https://codeql.github.com/docs/writing-codeql-queries/providing-locations-in-codeql-queries/).
   */

  predicate hasLocationInfo(string filepath, int startline, int startcolumn, int endline, int endcolumn) { ... }
  ```

### QLDoc for classes

1. Document classes using a noun phrase of the form `A <domain element> that <has property>.`
1. Use "that", not "which".
1. Refer to member elements in the singular.
1. Where a class denotes a generic concept with subclasses, list those subclasses.

##### Example

```ql
/**
 * A delegate declaration, for example
 * ```
 * delegate void Logger(string text);
 * ```
 */
class Delegate extends ...
```

```ql
/**
 * An element that can be called.
 *
 * Either a method (`Method`), a constructor (`Constructor`), a destructor
 * (`Destructor`), an operator (`Operator`), an accessor (`Accessor`),
 * an anonymous function (`AnonymousFunctionExpr`), or a local function
 * (`LocalFunction`).
 */
class Callable extends ...
```

### QLDoc for modules

Modules should be documented using a third-person verb phrase of the form `Provides <classes and predicates to do something>.` 

##### Example

```ql
/** Provides logic for determining constant expressions. */
```
```ql
/** Provides classes representing the control flow graph within functions. */
```

### Special variables

When referring to `this`, you may either refer to it as `` `this` `` or `this <type>`. For example:
- ``Holds if `this` is static.``
- `Holds if this method is static.`

When referring to `result`, you may either refer to it as `` `result` `` or as `the result`. For example:
- ``Holds if `result` is a child of this expression.``
- `Holds if the result is a child of this expression.`
