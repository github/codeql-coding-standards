## Description

_please enter the description of your change here_

## Change request type

 - [ ] Release or process automation (GitHub workflows, internal scripts)
 - [ ] Internal documentation
 - [ ] External documentation
 - [ ] Query files (`.ql`, `.qll`, `.qls` or unit tests)
 - [ ] External scripts (analysis report or other code shipped as part of a release)

## Rules with added or modified queries

 - [ ] No rules added
 - [ ] Queries have been added for the following rules:
     - _rule number here_
 - [ ] Queries have been modified for the following rules:
     - _rule number here_

## Release change checklist

A change note ([development_handbook.md#change-notes](https://github.com/github/codeql-coding-standards/blob/main/docs/development_handbook.md#change-notes)) is required for any pull request which modifies:

 - The structure or layout of the release artifacts.
 - The evaluation performance (memory, execution time) of an existing query.
 - The results of an existing query in any circumstance.

If you are only adding new rule queries, a change note is not required.

_**Author:**_ Is a change note required? 
  - [ ] Yes
  - [ ] No

🚨🚨🚨
_**Reviewer:**_ Confirm that format of *shared* queries (not the .qll file, the
.ql file that imports it) is valid by running them within VS Code. 
  - [ ] Confirmed


_**Reviewer:**_ Confirm that either a change note is not required or the change note is required and has been added.
  - [ ] Confirmed

## Query development review checklist

For PRs that add new queries or modify existing queries, the following checklist should be completed by both the author and reviewer:

### Author

 - [ ] Have all the relevant rule package description files been checked in?
 - [ ] Have you verified that the metadata properties of each new query is set appropriately?
 - [ ] Do all the unit tests contain both "COMPLIANT" and "NON_COMPLIANT" cases?
 - [ ] Are the alert messages properly formatted and consistent with the [style guide](https://github.com/github/codeql-coding-standards/blob/main/docs/development_handbook.md#query-style-guide)?
 - [ ] Have you run the queries on OpenPilot and verified that the performance and results are acceptable?<br />_As a rule of thumb, predicates specific to the query should take no more than 1 minute, and for simple queries be under 10 seconds. If this is not the case, this should be highlighted and agreed in the code review process._
 - [ ] Does the query have an appropriate level of in-query comments/documentation?
 - [ ] Have you considered/identified possible edge cases?
 - [ ] Does the query not reinvent features in the standard library?
 - [ ] Can the query be simplified further (not golfed!)

### Reviewer 

 - [ ] Have all the relevant rule package description files been checked in?
 - [ ] Have you verified that the metadata properties of each new query is set appropriately?
 - [ ] Do all the unit tests contain both "COMPLIANT" and "NON_COMPLIANT" cases?
 - [ ] Are the alert messages properly formatted and consistent with the [style guide](https://github.com/github/codeql-coding-standards/blob/main/docs/development_handbook.md#query-style-guide)?
 - [ ] Have you run the queries on OpenPilot and verified that the performance and results are acceptable?<br />_As a rule of thumb, predicates specific to the query should take no more than 1 minute, and for simple queries be under 10 seconds. If this is not the case, this should be highlighted and agreed in the code review process._
 - [ ] Does the query have an appropriate level of in-query comments/documentation?
 - [ ] Have you considered/identified possible edge cases?
 - [ ] Does the query not reinvent features in the standard library?
 - [ ] Can the query be simplified further (not golfed!)