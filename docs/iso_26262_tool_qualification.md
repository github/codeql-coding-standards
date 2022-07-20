# Software tool qualification under ISO 26262

## Document management

**Document ID:** codeql-coding-standards/iso-26262-tool-qualification

| Version | Date       | Author          | Changes                                                                                  |
| ------- | ---------- | --------------- | ---------------------------------------------------------------------------------------- |
| 0.1.0   | 2021-09-07 | Luke Cartey     | Initial version.                                                                         |
| 0.2.0   | 2021-09-08 | Luke Cartey     | Update CodeQL qualification methods.                                                     |
| 0.3.0   | 2021-09-08 | Luke Cartey     | Update the customer table.                                                               |
| 0.4.0   | 2021-09-19 | Luke Cartey     | Add more detail on approach to V&V. Update section around increased confidence from use. |
| 0.5.0   | 2021-11-29 | Remco Vermeulen | Add document management section.                                                         |

## Introduction

A common use case for coding standards is in the verification and certification process for safety critical or low fault tolerance systems. The "CodeQL Coding Standards" product is therefore intended to be qualified as a "software tool" under "Part 8: Supporting processes" of ISO 26262 ("Road vehicles - Functional Safety"), to support use within the automotive industry as part of an ISO 26262 certification process.

## Tool confidence level

The ISO 26262 standard assigns software tools a "tool confidence level" (TCL), based on their classification according to two categories:

 - **Tool impact** (TI) - whether a malfunction in the tool can introduce or fail to detect errors in safety-related item.
 - **Tool error detection** (TD) - whether a malfunction in the tool that introduces or fails to detect errors can be prevented or detected.

Based on ISO 26262-8 11.4.5.2 we believe that the "CodeQL Coding Standards" product should be classified as:

 - `TI2` - as a malfunction in the queries can lead to errors in the production code not being identified.
 - `TD2` - as we have medium confidence that errors missed due to a malfunction will be detected by other verification and validation activities during the development lifecycle.

Given these classifications ISO 26262-8 11.4.5.5 specifies a tool confidence level of TCL2.

## Methods for qualification

According to ISO 26262-8, there are four possible methods which can be used to qualify a software tool:

  - 1a. Increased confidence from use in accordance with 11.4.7 
  - 1b. Evaluation of the tool development process in accordance with 11.4.8
  - 1c. Validation of the software tool in accordance with 11.4.9
  - 1d. Development in accordance with a safety standard.

A combination of the TCL and the intended usage of the tool determines which qualification methods are appropriate. The intended usage of the tool is captured by the "Automotive Safety Integrity Level" (ASIL) of the components which will be analyzed by the tool. ASIL is a risk classification scheme, with levels ranging from A (lowest risk) to D (highest risk).

For our purposes, we wish to allow customers to use the queries at all risk levels, so we select TCL2 and ASIL D, which yields methods `1c.` and `1d.` as highly recommended, and methods `1a.` and `1b.` as recommended.

As described in the [user manual](user_manual.md#codeql_dependencies) running the CodeQL Coding Standards queries requires two additional dependencies:
 
 - The CodeQL CLI - this is the command line tool used to create C++ CodeQL databases and run the CodeQL Coding Standard queries.
 - The CodeQL Standard Library for C++ - this provides a basic set of core CodeQL query libraries for analyzing CodeQL C++ databases. We use these common libraries in the implementation of the CodeQL Coding Standards queries.
 
 As these components are required in order to run the CodeQL Coding Standards queries, they are included in the qualification process for the software tool. However, we will consider qualification methods for these components separately.

### Qualification methods for CodeQL Coding Standard queries

For the CodeQL Coding Standard queries, we intend to apply the following qualification methods:

  - 1b. Evaluation of the tool development process in accordance with 11.4.8
  - 1c. Validation of the software tool in accordance with 11.4.9

#### 1b. Evaluation of the tool development process in accordance with 11.4.8

The development process is described in the [development handbook](../development_handbook.md).

The project planning and requirements processes are described in our internal repository.

#### 1c. Validation of the software tool in accordance with 11.4.9

Our verification and validation plan for the queries consists of the following steps:

  1. **Unit testing** - during query development a hand-coded synthetic test case is created for each rule which exhibits both compliant and non-compliant behaviour, and exercises the known edge cases. Unit tests are derived directly from the requirements specified in the Coding Standard, and augmented based on rule and result feedback through other validation and verification methods described below.
  4. **Rule review with customer subject matter experts** - during development, rules which are unclear, or with results that are not clearly compliant or non-compliant, are reviewed with customer experts in C++ and its use in safety critical software development.
  2. **Open source integration testing** - both during rule development, and prior to release, all queries are run against a number of open source code bases from the automotive sector. Results are reviewed, and false positives are investigated and addressed or limitations documented.
  3. **Closed source integration testing** - the CodeQL Coding Standards development team has access to a select number of closed source commercial codebases from the automotive sector. Periodically all queries are run against these code bases. Results are reviewed, and false positives are investigated and addressed or limitations documented.
  5. **Addressing result feedback from customers** - during rule development we provide incremental beta releases to our customers, and actively solicit feedback on the results on existing codebases, including those which have already been verified with another static analysis tool.

In combination, these techniques ensure that the tool complies with the requirement to find violations of the Coding Standard rules in the following ways:

 - Synthetic test cases written by the query author verify that the query implements the interpretation of the rules the query author intended.
 - Rule review with subject matter experts ensures our interpretation of the rule is appropriate in uncertain cases.
 - Real world testing and external feedback ensures the interpretation of the rule is producing appropriate and reasonable results on real world code.

The development processes related to validation and verification are described in detail the [development handbook](../development_handbook.md).

### Qualification methods for CodeQL CLI and the CodeQL Standard Library for C++

The CodeQL CLI and the CodeQL Standard Library for C++ are developed by separate teams within GitHub whose development process is not within the scope of the tool qualification process for the CodeQL Coding Standards queries. For this reason we intend to apply the following qualification methods:

 - 1a. Increased confidence from use in accordance with 11.4.7 
 - 1c. Validation of the software tool in accordance with 11.4.9

Although the development process of these components is not within the remit of tool qualification (and therefore methods 1b. and 1d. are not applicable), they are produced by professional development teams within GitHub using robust modern development practices.

#### 1a. Increased confidence from use in accordance with 11.4.7 

The CodeQL CLI and CodeQL Standard Library for C++ are extensively used by both the open source community and commercial customers of GitHub to:

 - Create CodeQL databases for C and C++ code.
 - Run default (non Coding Standard) queries that make use of functionalities in the CodeQL Standard Library for C++.
 - Write and run _custom queries_ that make use of functionalities in the CodeQL Standard Library for C++.

The versions of the CodeQL CLI and CodeQL Standard Library for C++ are identical to those shipped to both customers and open source users, and the use cases are comparable.

In terms of breadth of use, between the 4th September 2021 and 7th September 2021 11,788 open source C/C++ repositories were successfully analyzed on [LGTM.com](https://lgtm.com), a platform provided by GitHub for performing analysis of open source repositories[^1] using CodeQL. Each version of the CodeQL CLI and CodeQL Standard Library for C++ version will undergo similarly broad testing on LGTM.com before being adopted by the CodeQL Coding Standards.

In addition to testing on LGTM.com, we have also analyzed a further 748 C++ repos using CodeQL via the "Code Scanning" feature included in GitHub.com. This includes both private closed source and open source software.

In addition, the following companies have publicly described their use of CodeQL for C++:

| Company                        | Creates CodeQL databases?                         | Runs default queries? | Runs custom queries? | References                                                                                                                                                                                                               |
| ------------------------------ | ------------------------------------------------- | --------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Microsoft                      | Yes, including for Edge, Office 365, Windows etc. | Yes                   | Yes                  | https://semmle.com/case-studies/semmle-microsoft-vulnerability-hunting<br>https://msrc-blog.microsoft.com/2019/11/06/vulnerability-hunting-with-semmle-ql-dom-xss/                                                       |
| NASA                           | Yes                                               | Yes                   | Yes                  | https://semmle.com/case-studies/semmle-nasa-landing-curiosity-safely-mars                                                                                                                                                |
| Murex                          | Yes                                               | Yes                   | Yes                  | https://semmle.com/case-studies/semmle-murex-securing-and-modernizing-worlds-leading-capital-markets-platform                                                                                                            |
| Thermofisher                   | Yes                                               | Yes                   | No                   | https://resources.github.com/webcasts/community-powered-security-developer-workflow-thankyou/<br>https://github.blog/2020-07-15-how-organizations-can-tackle-securing-the-worlds-code/#make-sure-your-own-code-is-secure |
| Woven Planet (formerly TRI-AD) | Yes                                               | Yes                   | Yes                  | https://www.youtube.com/watch?v=Twdftv0Tkfo                                                                                                                                                                              |

This usage includes the analysis of a broad range and styles of C and C++ codebases, including some which are extremely large and complex. These customers continue to use the CodeQL tooling and make use of releases as and when they become available.

The CodeQL CLI can be used as part of an automated deployment within CI/CD (in which case the CodeQL CLI is provided), or it can be fetched explicitly from a public download site. In total, the CodeQL CLI has been fetched from this public download page 63852 times in the period between November 2019 and August 2021. Each individual release is downloaded thousands of times.

As required by 11.4.7.2 d), both the CodeQL CLI and CodeQL Standard Library provide public and internal bug trackers to systematically track issues that are observed during use ([CodeQL CLI bug tracker](https://github.com/github/codeql-cli-binaries/issues) and [CodeQL Standard Library for C++ bug tracker](https://github.com/github/codeql/issues)).

[^1] The projects analyzed are visible in the public LGTM search at https://lgtm.com/search?q=language%3Acpp. The default analysis was applied, which exercises both the CodeQL CLI

#### 1c. Validation of the software tool in accordance with 11.4.9

When selecting a new pair of versions of the CodeQL CLI and CodeQL Standard Library for C++ to define as "supported", we perform the following black box testing of those components:

 - Functional tests are performed to confirm that:
   - CodeQL databases can be created for a set of test projects which satisfy the [supported environment specified in the user manual](user_manual.md#supported_environment) - for example, using the supported compilers and C++ language versions.
   - The CodeQL Coding Standards queries can be run against those databases, and the reported results match expected results.
 - The CodeQL Standard Library for C++ includes a substantial suite of CodeQL unit tests that exercise both the standard library and queries which use the standard library. We run these tests with the selected supported CodeQL CLI and confirm that they all pass.
 - In addition, we run our CodeQL Coding Standards unit tests in conjunction with the specified CodeQL CLI and CodeQL Standard Library for C++, and confirm that they all pass.

In addition to this black box testing of the components, we also provide validation of CodeQL databases produced in a user environment, through the [Analysis Integrity Report](user_manual.md#producing_an_analysis_report). This report is produced by inspecting a CodeQL database for errors reported during the database construction process, and reports them to the user based on the files or compilations affected, along with details of the nature of the problem - particularly, whether the issue was "recoverable", and only affecting a limited section of the program, or whether it was unrecoverable and could affect the interpretation of a whole file or compilation process. This can aid in the detection of malfunctions that occurred when the CodeQL CLI created the CodeQL database.

## Safety manager

 - **Safety Manager**: @lcartey
 - **Deputy Safety Manager**: @rvermeulen

In the event of the Safety Manager being on leave, the Deputy Safety Manager will be responsible for all duties.
