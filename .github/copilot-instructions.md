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
- Can the query be simplified further (not golfed!)

In your review output, list only those checklist items that are not satisfied or are uncertain, but also report any other problems you find outside this checklist; do not mention checklist items that clearly pass.
