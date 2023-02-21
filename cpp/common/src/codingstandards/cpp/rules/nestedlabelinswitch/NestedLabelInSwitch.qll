/**
 * Provides a library which includes a `problems` predicate for reporting nested labels in a switch statement.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NestedLabelInSwitchSharedQuery extends Query { }

Query getQuery() { result instanceof NestedLabelInSwitchSharedQuery }

query predicate problems(
  SwitchCase nestedCase, string message, SwitchCase case, string caseLabel, SwitchStmt switch,
  string switchLabel
) {
  not isExcluded(nestedCase, getQuery()) and
  switch.getASwitchCase() = case and
  not nestedCase.getParentStmt() = switch.getChildStmt() and
  nestedCase = case and
  message =
    "The switch $@ does not appear at the outermost level of the compound statement forming the body of the $@ statement." and
  caseLabel = nestedCase.toString() and
  switchLabel = switch.toString()
}
