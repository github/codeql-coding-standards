
# CodeQL Coding Standards : User manual

## Document management

**Document ID:** codeql-coding-standards/user-manual

| Version | Date       | Author          | Changes                                                                                                                 |
| ------- | ---------- | --------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 0.1.0   | 2021-08-24 | Luke Cartey     | Initial version.                                                                                                        |
| 0.2.0   | 2021-09-03 | Luke Cartey     | Clarify the required SARIF version.                                                                                     |
| 0.3.0   | 2021-09-07 | Luke Cartey     | Extract tool qualification into to separate document with id codeql-coding-standards/iso-26262-tool-qualification.      |
| 0.4.0   | 2021-09-10 | Luke Cartey     | Refine the use cases and failure modes.                                                                                 |
| 0.5.0   | 2021-09-19 | Luke Cartey     | Clarify requirements of build command. Clarify the certification scope. Add false positives/negatives as failure modes. |
| 0.6.0   | 2021-11-16 | Remco Vermeulen | Add description of deviation records and analysis reports.                                                              |
| 0.7.0   | 2021-11-29 | Remco Vermeulen | Add document management section. Add release section.                                                                   |
| 0.8.0   | 2022-02-06 | Remco Vermeulen | Add Hazard and Risk Analysis (HARA). Remove armclang support.                                                           |
| 0.9.0   | 2022-02-17 | Remco Vermeulen | Finalize scope deviation records                                                                                        |
| 0.10.0  | 2022-02-28 | Remco Vermeulen | Describe database correctness in the Hazard and Risk Analysis (HARA).                                                   |
| 0.11.0  | 2022-02-28 | Remco Vermeulen | Updated version to 1.1.0                                                                                                |
| 0.12.0  | 2022-10-21 | Luke Cartey     | Updated version to 2.10.0                                                                                               |
| 0.13.0  | 2022-11-03 | Remco Vermeulen | Add missing deviation analysis report tables to section 'Producing an analysis report'.                                 |
| 0.14.0  | 2022-11-03 | Remco Vermeulen | Add guideline recategorization plan.                                                                                    |
| 0.15.0  | 2023-05-24 | Mauro Baluda    | Clarify AUTOSAR C++ supported versions.                                                                                 |
| 0.16.0  | 2023-07-03 | Luke Cartey     | Remove reference to LGTM, update the name of the query pack                                                             |
| 0.17.0  | 2023-08-16 | Luke Cartey     | Update list of supported compiler configurations.                                                                       |
| 0.18.0  | 2024-01-30 | Luke Cartey     | Update product description and coverage table.                                                                          |
| 0.19.0  | 2024-02-23 | Remco Vermeulen | Clarify the required use of Python version 3.9.                                                                         |
| 0.20.0  | 2024-02-23 | Remco Vermeulen | Add table describing the permitted guideline re-categorizations.                                                        |
| 0.21.0  | 2024-05-01 | Luke Cartey     | Add MISRA C++ 2023 as under development, and clarify MISRA C 2012 coverage.                                             |
| 0.22.0  | 2024-10-02 | Luke Cartey     | Add MISRA C 2023 as under development, and clarify MISRA C 2012 coverage.                                               |
| 0.23.0  | 2024-10-21 | Luke Cartey     | Add assembly as a hazard.                                                                                               |
| 0.24.0  | 2024-10-22 | Luke Cartey     | Add CodeQL packs as a usable output, update release artifacts list.                                                     |
| 0.25.0  | 2025-01-15 | Mike Fairhurst  | Add guidance for the usage of 'strict' queries.                                                                         |
| 0.26.0  | 2025-02-12 | Luke Cartey     | Describe support for new deviation code identifier formats                                                              |
| 0.27.0  | 2025-05-15 | Luke Cartey     | Documented completed support for MISRA C 2023.                                                                          |

## Release information

This user manual documents release `2.55.0` of the coding standards located at [https://github.com/github/codeql-coding-standards](https://github.com/github/codeql-coding-standards).
The release page documents the release notes and contains the following artifacts part of the release:

- `coding-standards-codeql-packs-2.37.0-dev.zip`: CodeQL packs that can be used with GitHub Code Scanning or the CodeQL CLI as documented in the section _Operating manual_.
- `code-scanning-cpp-query-pack-2.55.0.zip`: Legacy packaging for the queries and scripts to be used with GitHub Code Scanning or the CodeQL CLI as documented in the section _Operating manual_.
- `supported_rules_list_2.55.0.csv`: A Comma Separated File (CSV) containing the supported rules per standard and the queries that implement the rule.
- `supported_rules_list_2.55.0.md`: A Markdown formatted file with a table containing the supported rules per standard and the queries that implement the rule.
- `user_manual_2.55.0.md`: This user manual.
- `Source Code (zip)`: A zip archive containing the contents of https://github.com/github/codeql-coding-standards
- `Source Code (tar.gz)`: A GZip compressed tar archive containing the contents of https://github.com/github/codeql-coding-standards
- `checksums.txt`: A text file containing sha256 checksums for the aforementioned artifacts.

## Introduction

### Background

[CodeQL](https://codeql.github.com/docs/codeql-overview/about-codeql/) is a static analysis tool that treats code as data. It does so by building a database of facts about a codebase under analysis. _CodeQL queries_ can then be run against this database of facts to find patterns of interest, such as bugs, security problems and maintainability issues.

A _coding standard_ is a set of rules or guidelines which restrict or prohibit the use of certain dangerous or confusing coding patterns or language features. Following a coding standard can improve the reliability of a software product. Each rule in a coding standard is typically provided with a unique identifier.

### Product description

The _CodeQL Coding Standards_ product is a set of CodeQL queries for identifying contraventions of rules in the following coding standards:

| Standard    | Version                                                                                                                                                                                                  | Rules | Supportable rules | Implemented rules | Status            |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- | ----------------- | ----------------- | ----------------- |
| AUTOSAR C++ | [^1] [R22-11](https://www.autosar.org/fileadmin/standards/R22-11/AP/AUTOSAR_RS_CPP14Guidelines.pdf), R21-11, R20-11, R19-11, R19-03                                                                      | 397   | 372               | 370[^2]           | Implemented       |
| CERT-C++    | [2016](https://resources.sei.cmu.edu/downloads/secure-coding/assets/sei-cert-cpp-coding-standard-2016-v01.pdf)                                                                                           | 83    | 82                | 82                | Implemented       |
| CERT C      | [2016](https://resources.sei.cmu.edu/downloads/secure-coding/assets/sei-cert-c-coding-standard-2016-v01.pdf)                                                                                             | 99    | 97                | 97                | Implemented       |
| MISRA C     | [2012 Third Edition, First Revision](https://www.misra.org.uk/product/misra-c2012-third-edition-first-revision/), [Amendment 2](https://misra.org.uk/app/uploads/2021/06/MISRA-C-2012-AMD2.pdf) and TC2  | 175   | 164               | 162[^3]           | Implemented       |
|             | [2012 Amendment 3](https://misra.org.uk/app/uploads/2021/06/MISRA-C-2012-AMD3.pdf)                                                                                                                       | 24    | 24                | 24                | Implemented       |
|             | [2012 Amendment 4](https://misra.org.uk/app/uploads/2021/06/MISRA-C-2012-AMD4.pdf)                                                                                                                       | 22    | 22                | 21[^4]            | Implemented       |
|             | [2023 Third Edition, Second Revision](https://misra.org.uk/product/misra-c2023/)                                                                                                                         | 221   | 210               | 207[^5]           | Implemented       |
| MISRA C++   | [2023](https://misra.org.uk/product/misra-cpp2023/)                                                                                                                                                      | 179   | 176[^6]           | -                 | Under development |

Not all rules in these standards are amenable to static analysis by CodeQL - some rules require external or domain specific knowledge to validate, or refer to properties which are not present in our representation of the codebase under analysis. In addition, some rules are natively enforced by the supported compilers. As CodeQL requires that the program under analysis compiles, we are unable to implement queries for these rules, and doing so would be redundant.

For each rule we therefore identify whether it is supportable or not. Furthermore, a rule can be supported in two ways:

- **Automated** - the queries for the rule find contraventions directly.
- **Audit only** - the queries for the rule does not find contraventions directly, but instead report a list of _candidates_ that can be used as input into a manual audit. For example, `A10-0-1` (_Public inheritance shall be used to implement 'is-a' relationship_) is not directly amenable to static analysis, but CodeQL can be used to produce a list of all the locations that use public inheritance so they can be manually reviewed.
- **Strict only** - the queries for the rule find contraventions directly, but find results which are strongly indicated to be intentional, and where adding a _deviation report_ may be extra burden on developers. For example, in `RULE-2-8` (_A project should not contain unused object definitions_), declaring objects with `__attribute__((unused))` may be preferable to a _deviation report_, which will not suppress relevant compiler warnings, and therefore would otherwise require developer double-entry.

Each supported rule is implemented as one or more CodeQL queries, with each query covering an aspect of the rule. In many coding standards, the rules cover non-trivial semantic properties of the codebase under analysis.

The datasheet _"CodeQL Coding Standards: supported rules"_, provided with each release, lists which rules are supported for that particular release, and the _scope of analysis_ for that rule.

[^1]: AUTOSAR C++ versions R22-11, R21-11, R20-11, R19-11 and R19-03 are all identical as indicated in the document change history.
[^2]: The unimplemented supportable AUTOSAR rules are `A7-1-8` and `A8-2-1`. These rules require additional support in the CodeQL CLI to ensure the required information is available in the CodeQL database to identify violations of these rules.
[^3]: The unimplemented supportable MISRA C 2012 rules are `Rule 9.5`, `Rule 17.13`. `Rule 9.5` and `Rule 17.13` require additional support in the CodeQL CLI to ensure the required information is available in the CodeQL database to identify violations of these rules. Note: `Dir 4.14` is covered by the default CodeQL queries, which identify potential security vulnerabilities caused by not validating external input.
[^4]: The unimplemented supportable MISRA C 2012 Amendment 4 rule is `Rule 9.6`. `Rule 9.6` requires additional support in the CodeQL CLI to ensure the required information is available in the CodeQL database to identify violations of this rule.
[^5]: The unimplemented supportable MISRA C 2023 rules are `Rule 9.5`, `Rule 9.6`, `Rule 17.13`. `Rule 9.5`, `Rule 9.6` and `Rule 17.13` require additional support in the CodeQL CLI to ensure the required information is available in the CodeQL database to identify violations of these rules. Note: `Dir 4.14` is covered by the default CodeQL queries, which identify potential security vulnerabilities caused by not validating external input.
[^6]: The rules `5.13.7`, `19.0.1` and `19.1.2` are not planned to be implemented by CodeQL as they are compiler checked in all supported compilers.

## Supported environment

This section describes the supported environment for the product.

### CodeQL dependencies

To run the "CodeQL Coding Standards" queries two additional components are required:

- The CodeQL CLI - this is the command line tool for creating CodeQL databases and running CodeQL queries.
- The CodeQL Standard Library for C++ - this provides the common CodeQL query libraries used in the implementation of the CodeQL Coding Standards queries.

Refer to the release notes for the selected release to determine which versions of these dependencies are supported or required.

From a functional safety perspective, the use of these two components is only validated in conjunction with the use cases supported in the user manual.

### Codebase requirements

In all scenarios, the codebase must comply with the language, platform and compiler requirements listed on the [CodeQL: Supported languages and frameworks](https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks) in order to be successfully analyzed.

In addition, the machine which performs the analysis must be able to complete a clean build of the codebase.

#### C++

For C++ the codebase under analysis must comply with C++14 and use one of the following supported compiler configurations:

| Compiler | Version | Standard library    | Target architecture   | Required flags                   |
| -------- | ------- | ------------------- | --------------------- | -------------------------------- |
| clang    | 10.0.0  | libstdc++ (default) | x86_64-linux-gnu      | -std=c++14                       |
| gcc      | 8.4.0   | libstdc++ (default) | x86_64-linux-gnu      | -std=c++14                       |
| qcc      | 8.3.0   | libc++ (default)    | gcc_ntoaarch64le_cxx  | -std=c++14 -D_QNX_SOURCE -nopipe |

Use of the queries outside these scenarios is possible, but not validated for functional safety. In particular:

- Use of the queries against codebases written with more recent versions of C++ (as supported by CodeQL) are not validated in the following circumstances:
  - When new language features are used
  - When language features are used which have a differing interpretation from C++14.
- Use of the queries against codebases which use other compilers or other compiler versions supported by CodeQL is not tested or validated for functional safety.

#### C

For C the codebase under analysis must comply with C99 or C11 and use one of the following supported compiler configurations:

| Compiler | Version | Standard library    | Target architecture   | Required Flags             |
| -------- | ------- | ------------------- | --------------------- | -------------------------- |
| clang    | 10.0.0  | glibc (default)     | x86_64-linux-gnu      | `-std=c11` or `-std=c99`   |
| gcc      | 8.4.0   | glibc (default)     | x86_64-linux-gnu      | `-std=c11` or `-std=c99`   |
| qcc      | 8.3.0   | glibc (default)     | gcc_ntoaarch64le      | `-std=c11 -nopipe` or `-std=c99 -nopipe` |

Use of the queries outside these scenarios is possible, but not validated for functional safety. In particular:

- Use of the queries against codebases written with more recent versions of C (as supported by CodeQL) are not validated in the following circumstances:
  - When new language features are used
  - When language features are used which have a differing interpretation from C11.
- Use of the queries against codebases which use other compilers or other compiler versions supported by CodeQL (e.g. gcc) is not tested or validated for functional safety.

### Analysis report requirements

The Coding Standards ships with scripts to generate reports that summarizes:

- The integrity and validity of the CodeQL database created for the project.
- The findings reported by the default queries for the selected Coding Standards, grouped by categories as specified by MISRA Compliance 2020.
- The CodeQL dependencies used for the analysis, and whether they comply with the stated requirements.

The environment used to generate these reports requires:

- A Python interpreter version 3.9
- A CodeQL CLI version documented in the release artifact `supported_codeql_configs.json`

## Operating manual

This section describes how to operate the "CodeQL Coding Standards".

### Command line

#### Pre-requisite: downloading the CodeQL CLI

You must download a compatible version of the CodeQL CLI, as specified in the release notes for the release you are using.

**Option 1:** Use the CodeQL CLI bundle, which includes both the CodeQL CLI and GitHub's default security queries:

 1. Download the CodeQL CLI bundle from the [`github/codeql-action` releases page](https://github.com/github/codeql-action/releases).
 2. Expand the compressed archive to a specified location on your machine.
 3. [Optional] Add the CodeQL CLI to your user or system path.

This approach is recommended if you wish to use the default queries provided by GitHub in addition to the Coding Standards queries.

**Option 2:** Use the CodeQL CLI binary:

 1. Download the CodeQL CLI from the [`github/codeql-cli-binaries` releases page](https://github.com/github/codeql-cli-binaries/releases)
 2. Expand the compressed archive to a specified location on your machine.
3. [Optional] Add the CodeQL CLI to your user or system path.

#### Pre-requisite: downloading the Coding Standards queries

The Coding Standards packs can be downloaded into the local CodeQL package cache using the following command:

```bash
codeql pack download codeql/<standard>-<language>-coding-standards@<version>
```

The supported standards and languages are:
 * `codeql/misra-c-coding-standards` - a CodeQL query pack for reporting violations of MISRA C.
 * `codeql/cert-c-coding-standards` - a CodeQL query pack for reporting violations of CERT C.
 * `codeql/misra-cpp-coding-standards` - a CodeQL query pack for reporting violations of MISRA C++.
 * `codeql/cert-cpp-coding-standards` - a CodeQL query pack for reporting violations of CERT C++.
 * `codeql/autosar-cpp-coding-standards` - - a CodeQL query pack for reporting violations of AUTOSAR for C++.

Ensure that the `@<version>` string matches the desired Coding Standards version.

Alternatively, the packs can be downloaded directly from a release on the `github/codeql-coding-standards` repository by choosing the `coding-standards-codeql-packs.zip`, which contains the following files:

  * `misra-c-coding-standards.tgz` - a CodeQL query pack for reporting violations of MISRA C.
  * `cert-c-coding-standards.tgz` - a CodeQL query pack for reporting violations of CERT C.
  * `cert-cpp-coding-standards.tgz`  - a CodeQL query pack for reporting violations of CERT C++.
  * `autosar-cpp-coding-standards.tgz` - a CodeQL query pack for reporting violations of AUTOSAR for C++.
  * `common-cpp-coding-standards.tgz` - a CodeQL library pack, used if you are writing your own C++ queries against Coding Standards.
  * `common-c-coding-standards.tgz` - a CodeQL library pack, used if you are writing your own C queries against Coding Standards.
  * `report-coding-standards.tgz` - a CodeQL query pack for running diagnostics on databases.

Each pack will need to be decompressed using the `tar` program, and placed in a known location.

Finally, we provide a legacy single zip containing all the artifacts from a release, named `code-scanning-cpp-query-pack.zip`. This also contains the CodeQL packs listed above.

#### Creating a CodeQL database

In order to run the Coding Standards queries you must first build a CodeQL database representing the program. You will need the following pre-requisites:

- A machine with the source code available locally.
- A clean build command for the project, which compiles all relevant source code locally on the machine without failure. Incremental and distributed builds must be disabled. The build command must be tested prior to configuring the CodeQL CLI and confirmed to compile all relevant files and return a zero exit code to indicate success.

The database can be created using the CodeQL CLI like so:

```bash
codeql database create --language cpp --command <build_command> <output_database_name>
```

This will produce a CodeQL database at the `<output_database_name>` path.

Reference: [CodeQL CLI: Creating a CodeQL database](https://codeql.github.com/docs/codeql-cli/creating-codeql-databases/)

#### Running the default analysis for one or more Coding Standards

Once you have a CodeQL database for your project you can run the default analysis for a specified Coding Standard using the `codeql database analyze` command by specifying the names of the QL packs which you want to run as arguments, along with a version specifier:

```bash
codeql database analyze --format=sarifv2.1.0 --output=<name-of-results-file>.sarif path/to/<output_database_name> codeql/<standard>-<language>-coding-standard@version
```

For example, this command would run MISRA C and CERT C with the default query sets:

```bash
codeql database analyze --format=sarifv2.1.0 --output=results.sarif path/to/<output_database_name> codeql/misra-c-coding-standard@version codeql/cert-c-coding-standard@version
```
The output of this command will be a [SARIF file](https://sarifweb.azurewebsites.net/) called `<name-of-results-file>.sarif`.

##### Locating the Coding Standards CodeQL packs

If you have downloaded a release artifact containing the packs, you will need to provide the `--search-path` parameter, pointing to each of the uncompressed query packs.
```
--search-path path/to/pack1:path/to/pack2
```

Alternatively, the packs can be made available to CodeQL without specification on the comamnd line by placing them inside the distribution under the `qlpacks/codeql/` directory, or placed inside a directory adjacent to the folder containing the distribution.

##### Alternative query sets

Each supported standard includes a variety of query suites, which enable the running of different sets of queries based on specified properties. In addition, a custom query suite can be defined as specified by the CodeQL CLI documentation, in order to select any arbitrary sets of queries in this repository. To run

```bash
codeql database analyze --format=sarifv2.1.0 --output=<name-of-results-file>.sarif path/to/<output_database_name> codeql/<standard>-<language>-coding-standard@version:codeql-suites/<alternative-suite>.qls
```

If modifying the query suite, ensure that all Rules you expect to be covered by CodeQL in your Guideline Enforcement Plan (or similar) are included in the query suite, by running:

```bash
codeql resolve queries codeql/<standard>-<language>-coding-standard@version:codeql-suites/<alternative-suite>.qls
```

##### Supported SARIF versions

The only supported SARIF version for use in a functional safety environment is version 2.1.0.
To select this SARIF version you **must** specify the flag `--format=sarifv2.1.0` when invoking the database analyze command `codeql database analyze ...` as shown in the above example.

##### Performance optimizations

Running the default analysis for one or more Coding Standards may require further performance customizations for larger codebases. The following flags may be passed to the `database analyze` command to adjust the performance:

- `--ram` - to specify the maximum amount of RAM to use during the analysis as [documented](https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/database-analyze#options-to-control-ram-usage) in the CodeQL CLI manual.
- `--thread` - to specify number of threads to use while evaluating as [documented](https://docs.github.com/en/code-security/codeql-cli/codeql-cli-manual/database-analyze#-j---threadsnum) in the CodeQL CLI manual.

##### Legacy approach

If you have downloaded the legacy release artifact `code-scanning-query-pack.zip`, you can run the default query suite using the `codeql database analyze` command as follows:

```bash
codeql database analyze --format=sarifv2.1.0 --output=<name-of-results-file>.sarif path/to/<output_database_name> path/to/codeql-coding-standards/<language>/<coding-standard>/src/codeql-suites/<coding-standard>-default.qls...
```

For each Coding Standard you want to run, add a trailing entry in the following format: `path/to/codeql-coding-standards/<language>/<coding-standard>/src/codeql-suites/<coding-standard>-default.qls`. Custom query suites can be run by specifying the appropriate paths.

All other options discussed above are valid.

#### Running the analysis for strict and/or audit level queries

Optionally, you may want to run the "strict" or "audit" level queries.

Audit queries produce lists of results that do not directly highlight contraventions of the rule. Instead, they identify locations in the code that can be manually audited to verify the absence of problems for that particular rule.

```bash
codeql database analyze --format=sarifv2.1.0 --output=<name-of-results-file>.sarif path/to/<output_database_name> path/to/codeql-coding-standards/cpp/<coding-standard>/src/codeql-suites/<coding-standard>-audit.qls...
```

Strict queries identify contraventions in the code that strongly suggest they are deliberate, and where adding an explicit _deviation report_ may be extra burden on developers.

```bash
codeql database analyze --format=sarifv2.1.0 --output=<name-of-results-file>.sarif path/to/<output_database_name> path/to/codeql-coding-standards/cpp/<coding-standard>/src/codeql-suites/<coding-standard>-strict.qls...
```

#### Producing an analysis report

In addition to producing a results file, an analysis report can be produced that summarizes:

- The integrity and validity of the CodeQL database created for the project.
- The findings reported by the default queries for the selected Coding Standards, grouped by categories as specified by MISRA Compliance 2020.
- The CodeQL dependencies used for the analysis, and whether they comply with the stated requirements.

To run this script, the CodeQL CLI part of a supported CodeQL Bundle and Python interpreter version 3.9 must be available on the system path.

```bash
python3.9 scripts/reports/analysis_report.py path/to/<output_database_name> <name-of-results-file>.sarif <output_directory>
```

This will produce a directory (`<output_directory>`) containing the following report files in markdown format:

- A **Guideline Compliance Summary** (GCS) which meets the requirements specified by the [MISRA Compliance 2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) document, and providing a summary of:
  - Whether the analysis reports that the project is "Compliance".
  - Which Coding Standards were applied.
  - The versions of the CodeQL CLI, CodeQL Standard Library for C/C++ and the CodeQL Coding Standards queries used to perform the analysis.
  - Count of violations of guidelines by guideline category ("Required", "Advisory")
  - A list of the guidelines checked, and the status of each guideline ("Compliant", "Violations", "Deviations").
    - **Note:** The `Deviations` status is **only** shown when the database has been build with a configuration to _report deviated alerts_ and analyzed with a _deviation alert suppression query_. The section on _Deviation records_ outlines how this can be achieved.
- An **Analysis Integrity Report** which summarizes any issues that were identified in the creation of the database, which can be reviewed to determine the extent to which these issues may have impacted the generated results. This includes:
  - A list of recoverable errors, where a specific piece of syntax was not handled, but the error could be recovered from. These a further sub-divided into "user code" errors and "third-party" errors.
  - A list of unrecoverable errors, which affect either entire files or entire compilations. These are also further sub-divided into "user code" errors and "third-party" errors.
  - A list of the files analyzed.
- A **Deviations Report** which reports the deviation records that where included during the creation of the database, which can be used to audit the applied deviations. The includes:
  - A table of deviation records for which we list:
    - An identifier for the coding standards rule the deviation applies to.
    - The query identifier that implements the guideline.
    - An inferred scope that shows the files or code-identifier the deviation is applied to.
    - A textual description of the scope when the deviation can be applied.
    - A textual justification of the deviation.
    - A textual description of background information.
    - A textual description of the requirements which must be satisfied to use the deviation.
  - A table of invalid deviation records for which we list:
    - The location of the invalid deviation record in the database.
    - The reason why it is considered invalid.
  - A table of deviation permits for which we list:
    - An identifier that identifies the permit.
    - An identifier for the coding standards rule the deviation applies to.
    - The query identifier that implements the guideline.
    - An inferred scope that shows the files or code-identifier the deviation is applied to.
    - A textual description of the scope when the deviation can be applied.
    - A textual justification of the deviation.
    - A textual description of background information.
    - A textual description of the requirements which must be satisfied to use the deviation.
  - A table of invalid deviation permits for which we list:
    - The location of the invalid permit in the database.
    - The reason why it is considered invalid.

#### Applying deviations

The CodeQL Coding Standards supports the following features from the [MISRA Compliance 2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) document:

- _Deviation records_ - an entry that states a particular instance, or set of instances, of a rule should be considered permitted.
- _Deviation permit_ - an entry that provides authorization to apply a deviation to a project.
- _Guideline re-categorization plan_ - an agreement on how the guidelines are applied. Whether a guideline may be violated, deviated from, or must always be applied.

##### Deviation records

The current implementation supports _deviation records_ to state that a particular instance, or set of instances, of a rule should be considered permitted.
A _deviation record_ can be specified in a `coding-standards.yml` configuration file in the repository and applies to source files in that directory and sub-directories unless explicitly scoped using a `paths` or `code-identifier` property.

The deviation mechanism, by default, works by **excluding** alerts for which there exists an associated _deviation record_, with exclusion being defined as not reporting the alert.
This default behavior can be changed by specify the top level property `report-deviated-alerts: true` in any `coding-standards.yml` that is added to the database.
This property can be combined with the query `path/to/codeql-coding-standards/cpp/common/src/codingstandards/cpp/deviations/DeviationsSuppression.ql` that can be added to a CodeQL database analyze command to generate suppression information that is added to the resulting SARIF output in the form of [suppressions](https://docs.oasis-open.org/sarif/sarif/v2.1.0/os/sarif-v2.1.0-os.html#_Toc34317661) that is part of [result](https://docs.oasis-open.org/sarif/sarif/v2.1.0/os/sarif-v2.1.0-os.html#_Toc34317638) object.
The rational for the default behavior is that GitHub Code Scanning does not support the `suppressions` property of a `result` object and displays the alert even though it is suppressed.

**Note:** It is important to create a database with the property `report-deviated-alerts: true` set and analyzed with the alert suppression query `path/to/codeql-coding-standards/cpp/common/src/codingstandards/cpp/deviations/DeviationsSuppression.ql` when the **Guideline Compliance Summary Report** **must** include deviation statuses!

The current implementation of the  `coding-standards.yml` specification supports the `deviations` section with the following keys:

- `rule-id` - An identifier for the coding standards rule the deviation applies to. This matches the rule id format specified in the documentation (e.g., `A1-0-1`)
- `query-id` - An identifier for the query (as specified by the `@id` property of the query) that can be used to specify a deviation for _sub-category_ of rule (as defined by a query). If the `query-id` is specified , the `rule-id` property should also be specified.
- `justification` - An short textual justification of the deviation.
- `scope` - An _optional_ short textual description of when this deviation can be applied. This will be combined with any automatically deduced scope for the deviation.
- `background` - Any relevant background information.
- `requirements` - One or more _requirements_ which must be satisfied to use this deviation.
- `paths` - An _optional_ set of paths, relative to the deviations file, specify either a directory or file to which this deviation should be applied.
- `code-identifier` - An _optional_ identifier which can be placed in the source code at locations where this deviation should be applied.
- `permit-id` - An _optional_ identifier which links to a deviation permit, from which some of the properties can be inherited.
- `raised-by` - A compact mapping, if specified requires the specification of `approved-by`, that includes:
  - `name` - The name, handle or other identifier of the user who raised the request
  - `date` - The date on which they raised the request.
- `approved-by` - A compact mapping, if specified requires the specification of `raised-by`, that includes:
  - `name` - The name, handle or other identifier of the user who approved the request
  - `date` - The date on which they approved the request.

The following code snippet provides an example of a `deviations` specification.

```yaml
deviations:
- rule-id: "A18-1-1"
  query-id: "cpp/autosar/c-style-arrays-used"
  justification: "C-style arrays are required for compatibility with the X third-party library."
- rule-id: "A18-5-1"
  query-id: "cpp/autosar/functions-malloc-calloc-realloc-and-free-used"
  justification: "malloc used in adopted code."
  paths:
    - "foo/bar"
- rule-id: A0-4-2
    justification: "long double is required for interaction with third-party libraries."
    code-identifier: a-0-4-2-deviation
```

The example describes three ways of scoping a deviation:

1. The deviation for `A18-1-1` applies to any source file in the same or a child directory of the directory containing the example `coding-standards.yml`.
2. The deviation for `A18-5-1` applies to any source file in the directory `foo/bar` or a child directory of `foo/bar` relative to the directory containing the `coding-standards.yml`.
3. The deviation for `A0-4-2` applies to any source element that marked by a comment containing the identifier specified in `code-identifier`. The different acceptable formats are discussed in the next section.

The activation of the deviation mechanism requires an extra step in the database creation process.
This extra step is the invocation of the Python script `path/to/codeql-coding-standards/scripts/configuration/process_coding_standards_config.py` that is part of the coding standards code scanning pack.
To run this script, a Python interpreter version 3.9 must be available on the system path.
The script should be invoked as follows:

```bash
codeql database create --language cpp --command 'python3 path/to/codeql-coding-standards/scripts/configuration/process_coding_standards_config.py' --command <build_command> <output_database_name>
```

The `process_coding_standards_config.py` has a dependency on the package `pyyaml` that can be installed using the provided PIP package manifest by running the following command:

`pip3 install -r path/to/codeql-coding-standards/scripts/configuration/requirements.txt`

##### Deviation code identifier attributes

A code identifier specified in a deviation record can be applied to certain results in the code by adding a C or C++ attribute of the following format:

```
[[codeql::<standard>_deviation("code-identifier")]]
```

For example `[[codeql::autosar_deviation("a1-2-4")]]` would apply a deviation of a rule in the AUTOSAR standard, using the code identifier `a1-2-4`. The supported standard names are `misra`, `autosar` and `cert`.

This attribute may be added to the following program elements:

 * Functions
 * Statements
 * Variables

Deviation attributes are inherited from parents in the code structure. For example, a deviation attribute applied to a function will apply the deviation to all code within the function.

Multiple code identifiers may be passed in a single attribute to apply multiple deviations, for example:

```
[[codeql::misra_deviation("code-identifier-1", "code-identifier-2")]]
```

Note - considation should be taken to ensure the use of custom attributes for deviations is compatible with your chosen language version, compiler, compiler configuration and coding standard.

**Use of attributes in C Coding Standards**: The C Standard introduces attributes in C23, however some compilers support attributes as a language extension in prior versions. You should:
 * Confirm that your compiler supports attributes for your chosen compiler configuration, if necessary as a language extension.
 * Confirm that unknown attributes are ignored by the compiler.
 * For MISRA C, add a project deviation against "Rule 1.2: Language extensions should not be used", if attribute support is a language extension in your language version. 

**Use of attributes in C++ Coding Standards**: The C++ Standard supports attributes in C++14, however the handling of unknown attributes is implementation defined. From C++17 onwards, unknown attributes are mandated to be ignored. Unknown attributes will usually raise an "unknown attribute" warning. You should:
 * If using C++14, confirm that your compiler ignores unknown attributes.
 * If using AUTOSAR and a compiler which produces warnings on unknown attributes, the compiler warning should be disabled (as per `A1-1-2: A warning level of the compilation process shall be set in compliance with project policies`),  to ensure compliance with `A1-4-3: All code should compiler free of compiler warnings`.

If you cannot satisfy these condition, please use the deviation code identifier comment format instead.

##### Deviation code identifier comments

As an alternative to attributes, a code identifier specified in a deviation record can be applied to certain results in the code by adding a comment marker consisting of a `code-identifier` with some optional annotations. The supported marker annotation formats are:

 - `<code-identifier>` - the deviation applies to results on the current line.
 - `codeql::<standard>_deviation(<code-identifier>)` - the deviation applies to results on the current line.
 - `codeql::<standard>_deviation_next_line(<code-identifier>)` - this deviation applies to results on the next line.
 - `codeql::<standard>_deviation_begin(<code-identifier>)` - marks the beginning of a range of lines where the deviation applies.
 - `codeql::<standard>_deviation_end(<code-identifier>)` - marks the end of a range of lines where the deviation applies.

Here are some examples, using the deviation record with the `a-0-4-2-deviation` code-identifier specified above:
```cpp
  long double x1; // NON_COMPLIANT

  long double x2; // a-0-4-2-deviation - COMPLIANT
  long double x3; // COMPLIANT - a-0-4-2-deviation

  long double x4; // codeql::autosar_deviation(a-0-4-2-deviation) - COMPLIANT
  long double x5; // COMPLIANT - codeql::autosar_deviation(a-0-4-2-deviation)

  // codeql::autosar_deviation_next_line(a-0-4-2-deviation)
  long double x6; // COMPLIANT

  // codeql::autosar_deviation_begin(a-0-4-2-deviation)
  long double x7; // COMPLIANT
  // codeql::autosar_deviation_end(a-0-4-2-deviation)
```

`codeql::<standard>_deviation_end` markers will pair with the closest unmatched `codeql::<standard>_deviation_begin` for the same `code-identifier`. Consider this example:
```cpp
1 | // codeql::autosar_deviation_begin(a-0-4-2-deviation)
2 |
3 | // codeql::autosar_deviation_begin(a-0-4-2-deviation)
4 |
5 | // codeql::autosar_deviation_end(a-0-4-2-deviation)
6 |
7 | // codeql::autosar_deviation_end(a-0-4-2-deviation)
```
Here, Line 1 will pair with Line 7, and Line 3 will pair with Line 5.

A `codeql::<standard>_deviation_end` without a matching `codeql::<standard>_deviation_begin`, or `codeql::<standard>_deviation_begin` without a matching `codeql::<standard>_deviation_end` is invalid and will be ignored.

`codeql::<standard>_deviation_begin` and `ccodeql::<standard>_deviation_end` markers only apply within a single file. Markers cannot be paired across files, and deviations do not apply to included files.

Note: deviation comment markers cannot be applied to the body of a macro. Please apply the deviation to macro expansion, or use the attribute deviation format.

##### Deviation permits

The current implementation supports _deviation permits_ as described in the [MISRA Compliance:2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) section _4.3 Deviation permits_.

Deviation permits are a mechanism to simplify the documentation of many deviations by allowing _deviation records_ to inherit properties from a _deviation permit_. A _deviation record_ can inherit the following properties that are documented in the section on _Deviation records_:

- `rule-id`
- `query-id`
- `justification`
- `scope`
- `background`
- `requirements`
- `code-identifier`

A _deviation permit_ **must** be specified in a `deviation-records` section part of a `coding-standards.yml` file that **must** be anywhere in the source repository. Every _deviation permit_ **must** specify a free-form `permit-id` property that **must** contain a globally unique identifier and **may** specify any of the allowed properties listed above.

The following example illustrate a possible _deviation permit_:

```yaml
deviation-permits:
  - permit-id: dp1
    rule-id: "A18-1-1"
    query-id: "cpp/autosar/c-style-arrays-used"
    justification: "C-style arrays are required for compatibility with the X third-party library."
```

A _deviation record_ can refer to a _deviation permit_ by specifying a property `permit-id` with the unique identifier of the _deviation permit_.
The following example illustrates a possible _deviation record_ that inherits the `rule-id`, `query-id`, and `justification` properties from the _deviation permit_ `dp1` and states that it applies to the path `foo/bar` through the `paths` property of the _deviation record_.

```yaml
deviations:
  - permit-id: dp1
    paths:
      - foo/bar
```

**Inheritance priority**:
Any property specified in a _deviation permit_ that is also specified in a _deviation record_ referring to that _deviation permit_ is overwritten by the property in the _deviation record_.

For example, the following _deviation record_ and _deviation permit_ both specify the `justification` property. The `justification` property of the _deviation records_ takes precedence.

```yaml
deviation-permits:
  - permit-id: dp2
    justification: "C-style arrays are required for compatibility with the X third-party library."
deviations:
  - rule-id: "A18-1-1"
    query-id: "cpp/autosar/c-style-arrays-used"
    permit-id: dp2
    justification: "C-style arrays are required."

```

**Importing permits**:
The used _deviation permits_ **must** be present in the source directory during the build of the CodeQL database.
Unlike _deviation records_ their location in the source directory does not impact their scope which is determined solemnly by the _deviation records_ referring to the _deviation permits_.

This means that _deviation permits_ can be made available at build time by any means available.
An example of importing _deviation permits_ is through a [Git Submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) that contains a repository of allowed _deviation permits_.

##### Guideline re-categorization plan

The current implementation supports a _guideline re-categorization plan_ as described in the [MISRA Compliance:2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) section _5 The guideline re-categorization plan_.

A re-categorization plan provides a mechanism to adjust the policy associated with a guideline that determines whether it may be violated or not and if it may be violated whether a deviation is required.

The implementation follows the constraints on re-categorization as described in [MISRA Compliance:2020](https://www.misra.org.uk/app/uploads/2021/06/MISRA-Compliance-2020.pdf) section _5.1 Re-categorization_.

The following tables described the re-categorizations are permitted.

| Current Category | Revised Category | Revised Category | Revised Category | Revised Category |
| --- | --- | --- | --- | --- |
| | Mandatory | Required | Advisory | Disapplied |
| Mandatory | Permitted |  | | |
| Required | Permitted | Permitted | | |
| Advisory | Permitted | Permitted | Permitted | Permitted |

Each guideline re-categorization **must** be specified in the `guideline-recategorizations` section of a `coding-standards.yml` file that **must** be anywhere in the source repository.

A guideline re-categorization specification **must** specify a `rule-id`, an identifier for the coding standards rule the re-categorization applies to, and a `category`, a category that can be any of `disapplied`, `advisory`, `required`, or `mandatory`.

An example guideline re-categorization section is:

```yaml
guideline-recategorizations:
  - rule-id: "A0-1-1"
    category: "mandatory"
  - rule-id: "A0-1-6"
    category: "disapplied"
  - rule-id: "A11-0-1"
    category: "mandatory"
```

Application of the guideline re-categorization plan to the analysis results requires an additional post-processing step.
The post-processing step is implemented by the Python script `path/to/codeql-coding-standards/scripts/guideline_recategorization/recategorize.py`.
The script will update the `external/<standard>/obligation/<category>` tag for each query implementing a recategorized guideline such that `<category>` is equal to the new category and
add the tag `external/<standard>/original-obligation/<category` to each query implementing a recategorized guideline such that `<category>` reflects the orignal category.

The script should be invoked as follows:

```bash
python3.9 path/to/codeql-coding-standards/scripts/guideline_recategorization/recategorize.py coding_standards_config_file <sarif_in> <sarif_out>
```

The `recategorize.py` scripts has a dependencies on the following Python packages that can be installed with the command `pip install -r path/to/codeql-coding-standards/scripts/guideline_recategorization/requirements.txt`:

- Jsonpath-ng==1.5.3
- Jsonschema
- Jsonpatch
- Jsonpointer
- PyYAML
- Pytest

and the schema files:

- `path/to/codeql-coding-standards/schemas/coding-standards-schema-1.0.0.json`
- `path/to/codeql-coding-standards/schemas/sarif-schema-2.1.0.json`

The schema files **must** be available in the same directory as the `recategorize.py` file or in any ancestor directory.

### GitHub Advanced Security

The only use cases that will be certified under ISO 26262 are those listed above. CodeQL Coding Standards is also compatible with, but not certified for, the following use cases:

- Creating databases and running the CodeQL Coding Standards queries with the [CodeQL Action](https://github.com/github/codeql-action) (for GitHub Actions CI/CD system).
- Uploading the SARIF results files for a CodeQL Coding Standards analysis to the GitHub [Code Scanning](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/about-code-scanning) feature.

### Hazard and risk analysis

This section describes known failure modes for "CodeQL Coding Standards" and describes the impact, how the issue can be identified and what remediation steps can be followed to address the issue.

| Use case                     | Failure mode                                                                                                                                                       | Effect                                                                                                                                                    | Protective/detective measure                                                                                                                                                                                                                                                                                                         | Remediation                                                                                                                                                                                                                                                                                                                                                                |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Installing CodeQL            | Standard library not installed in the correct location.                                                                                                            | Less output. The queries relying on the standard library cannot compile and not be executed.                                                              | Verify the availability of the required codeql/cpp-all QL pack with the command `codeql resolve qlpacks` or use a supported CodeQL bundle                                                                                                                                                                                            | Ensure a supported CodeQL bundle is used.                                                                                                                                                                                                                                                                                                                                  |
|                              | Incompatible standard library installed.                                                                                                                           | Less output. The queries relying on a certain standard library version cannot compile and not be executed.                                                | Use a supported CodeQL bundle                                                                                                                                                                                                                                                                                                        | Ensure a supported CodeQL bundle is used.                                                                                                                                                                                                                                                                                                                                  |
|                              | CodeQL installation modified (e.g., removing all extractors except for the cpp extractor)                                                                          | Less output. Functionality such as reporting or the deviation mechanism relying on the availability of extractors other than the C++ extractor will fail. | Verify the availability of the required codeql/cpp-all QL pack with the command `codeql resolve qlpacks` and the availability of the cpp & xml extractors using the codeql command `codeql resolve extractor --language=cpp` & `codeql resolve extractor --language=xml`                                                             | Ensure a supported and unmodified CodeQL bundle is used. To prevent the downloading of the CodeQL bundle to dominate the total analysis time ensure it is available on the machine used to perform the analysis.                                                                                                                                                           |
|                              | Standard library modified                                                                                                                                          | Less or more output. Results are reported that are not violations of the guidelines or guideline violations are not reported                              | Use the available CodeQL and CodeQL Coding Standards unit test to determine the queries work as expected with the provided standard library.                                                                                                                                                                                         | Ensure a supported and unmodified CodeQL bundle is used. To prevent the downloading of the CodeQL bundle to dominate the total analysis time ensure it is available on the machine used to perform the analysis.                                                                                                                                                           |
|                              | Incompatible runtime environment (e.g., `musl-c`)                                                                                                                  | Less output. Unable to observe compilation invocations preventing analysis.                                                                               | Analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                                                                                          | Ensure a supported operating system is used and that the CodeQL requirements are met as listed on https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks/                                                                                                                                                                                       |
| Generating a CodeQL database | Compiler invocations are not observed                                                                                                                              | Less output. Unable to observe compilation invocations preventing analysis.                                                                               | Analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                                                                                          | Ensure that the build system is not caching previous compilations (for example, using `ccache` or `bazel`) and that a supported compiler is being used. Issues can be reported via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                    |
|                              | Failure while processing a file or compilation                                                                                                                     | Less output. Some files may be only be partially analyzed, or not analyzed at all.                                                                        | Analysis integrity report lists the failures identified.                                                                                                                                                                                                                                                                             | Recoverable errors impact only the specified portion of the code and anything that relies on it. Unrecoverable errors impact the specified file or compilation unit, and may impact other files whose analysis relies on that information. Issues can be reported via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues). |
|                              | Build command exits non-zero                                                                                                                                       | Less output. No CodeQL database is created.                                                                                                               | Error reported on the command line.                                                                                                                                                                                                                                                                                                  | The underlying user provided build command failed. Ensure the build command succeeds outside of the CodeQL CLI.                                                                                                                                                                                                                                                            |
|                              | Incremental build                                                                                                                                                  | Less output. Some files may not be analyzed because they are not observed during the compilation process.                                                 | Analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                                                                                          | Ensure that the build system is configured to build from a clean state and disabled the use of a shared build cache.                                                                                                                                                                                                                                                       |
|                              | Distributed build                                                                                                                                                  | Less output. Some files may not be analyzed because they are not observed during the compilation process.                                                 | Analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                                                                                          | Ensure that the build system is configured to build locally. CodeQL does not support distributed builds.                                                                                                                                                                                                                                                                   |
|                              | Containerized build                                                                                                                                                | Less output or normal output. If misconfigured CodeQL will be unable to observe compilation invocations preventing analysis.                              | Error reported on the command line. CodeQL will either report the error `No source code was seen during the build` or exit with code `32` indicating that CodeQL was unable to monitor your code                                                                                                                                     | Ensure CodeQL is configured to run in the container during the build as documented at https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/running-codeql-code-scanning-in-a-container                                                                                                                   |
|                              | Out of memory                                                                                                                                                      | Less output. No analysis results are produced                                                                                                             | Error reported on the command line.                                                                                                                                                                                                                                                                                                  | Increase memory, configure the CodeQL CLI to adhere to a memory limit, or report memory consumption issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                        |
|                              | Timeout                                                                                                                                                            | Less output. No analysis results are produced                                                                                                             | Analysis fails to complete, or is killed after a given time.                                                                                                                                                                                                                                                                         | Report timeout issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                                                                                                             |
|                              | Use of unsupported compiler                                                                                                                                        | Less output. Some files may be only be partially analyzed, or not analyzed at all.                                                                        | Error reported on the command line. If no error is reported the analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                          | Ensure only compilers listed at https://codeql.github.com/docs/codeql-overview/supported-languages-and-frameworks/ are used.                                                                                                                                                                                                                                               |
|                              | Use of incorrect build command                                                                                                                                     | Less output. Some files may be only be partially analyzed, or not analyzed at all.                                                                        | Analysis integrity report lists all analyzed files, and must be crossed referenced with the list of files that are expected to be analyzed.                                                                                                                                                                                          | Ensure the build command corresponds to the build command that is used to build the release artifacts.                                                                                                                                                                                                                                                                     |
|                              | Incorrect build environment (e.g., concurrent builds writing to same file, overwriting translation unit/object file with different content)                        | Less or more output. Results are reported that are not violations of the guidelines or guideline violations are not reported                              | All reported results must be reviewed.                                                                                                                                                                                                                                                                                               | Ensure the build environment is configured to not use shared resources such as caches or artifact providers that can introduce race conditions. Report inconsistent results via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                       |
|                              | Source root misspecification                                                                                                                                       | Less output. The results cannot be correctly correlated to source files when viewing the resulting Sarif file in a Sarif viewer.                          | Verify that the reported results are display on the correct files in the Sarif viewer                                                                                                                                                                                                                                                | Ensure the CodeQL CLI configured to use the correct source root that correspond to the root of the repository under consideration.                                                                                                                                                                                                                                         |
|                              | Out of space                                                                                                                                                       | Less output. Some files may be only be partially analyzed, or not analyzed at all.                                                                        | Error reported on the command line.                                                                                                                                                                                                                                                                                                  | Increase space. If it remains an issue report space consumption issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                                                            |
|                              | False positives                                                                                                                                                    | More output. Results are reported which are not violations of the guidelines.                                                                             | All reported results must be reviewed.                                                                                                                                                                                                                                                                                               | Report false positive issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                                                                                                      |
|                              | False negatives                                                                                                                                                    | Less output. Violations of the guidelines are not reported.                                                                                               | Other validation and verification processes during software development should be used to complement the analysis performed by CodeQL Coding Standards.                                                                                                                                                                              | Report false negative issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                                                                                                      |
|                              | Modifying coding standard suite                                                                                                                                    | More or less output. If queries are added to the query set more result can be reported. If queries are removed less results might be reported.            | All queries supported by the CodeQL Coding Standards are listed in the release artifacts `supported_rules_list_2.55.0.csv` where VERSION is replaced with the used release. The rules in the resulting Sarif file must be cross-referenced with the expected rules in this list to determine the validity of the used CodeQL suite. | Ensure that the CodeQL Coding Standards are not modified in ways that are not documented as supported modifications.                                                                                                                                                                                                                                                    |
|                              | Incorrect deviation record specification                                                                                                                           | More output. Results are reported for guidelines for which a deviation is assigned.                                                                       | Analysis integrity report lists all deviations and incorrectly specified deviation records with a reason. Ensure that all deviation records are correctly specified.                                                                                                                                                                 | Ensure that the deviation record is specified according to the specification in the user manual.                                                                                                                                                                                                                                                                           |
|                              | Incorrect deviation permit specification                                                                                                                           | More output. Results are reported for guidelines for which a deviation is assigned.                                                                       | Analysis integrity report lists all deviations and incorrectly specified deviation permits with a reason. Ensure that all deviation permits are correctly specified.                                                                                                                                                                 | Ensure that the deviation record is specified according to the specification in the user manual.                                                                                                                                                                                                                                                                           |
|                              | Unapproved use of a deviation record                                                                                                                               | Less output. Results for guideline violations are not reported.                                                                                           | Validate that the deviation record use is approved by verifying the approved-by attribute of the deviation record specification.                                                                                                                                                                                                     | Ensure that each raised deviation record is approved by an independent approver through an auditable process.                                                                                                                                                                                                                                                              |
|                              | Incorrect database. The information extracted by the CodeQL extractor deviates from what the compiler extracts resulting in an incorrect model of the source-code. | More or less output. Incorrect extraction can result in false positives or false negatives.                                                               | Combinations of supported compilers and CodeQL CLIs are tested against a [provided](https://github.com/github/codeql/tree/main/cpp/ql/test/library-tests) suite of test cases and a coding standards specific test suite to determine if the extracted information deviates from the expected information.                           | Report incorrect database issues via the CodeQL Coding Standards [bug tracker](https://github.com/github/codeql-coding-standards/issues).                                                                                                                                                                                                                                  |
|                              | Use of assembly language instructions, which are not inspected by CodeQL. | More or less output. Can result in false positives or false negatives.                                                               | Avoid the use of assembly language instructions where possible. Where unavoidable, encapasulate and isolate the use of assembly language in separate functions to limit impact. Careful manual review of all functions that use assembly language. | Ensure that all functions which use assembly language instructions are manually reviewed for compliance.                                                                                                                                                                                                                                  |

## Reporting bugs

A bug tracker is provided on the [`github/codeql-coding-standards`](https://github.com/github/codeql-coding-standards) repository [issues page](https://github.com/github/codeql-coding-standards/issues). New issues can be filed on the [New Issues](https://github.com/github/codeql-coding-standards/issues/new/choose) page.
