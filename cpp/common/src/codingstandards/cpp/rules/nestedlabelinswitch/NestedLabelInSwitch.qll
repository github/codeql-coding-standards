/**
 * Provides a library which includes a `problems` predicate for reporting nested labels in a switch statement.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NestedLabelInSwitchSharedQuery extends Query { }

Query getQuery() { result instanceof NestedLabelInSwitchSharedQuery }

query predicate problems(
  SwitchCase case, string message, SwitchCase caseLocation, string caseLabel, SwitchStmt switch,
  string switchLabel
) {
  not isExcluded(case, getQuery()) and
  switch.getASwitchCase() = caseLocation and
  not case.getParentStmt() = switch.getChildStmt() and
  case = caseLocation and
  message =
    "The case $@ does not appear at the outermost level of the compound statement forming the body of the $@ statement." and
  caseLabel = case.toString() and
  switchLabel = switch.toString()
}
