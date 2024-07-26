/**
 * Provides a library with a `problems` predicate for the following issue:
 * The switch statement syntax is weak and may lead to unspecified behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SwitchStatement

abstract class SwitchNotWellFormedSharedQuery extends Query { }

Query getQuery() { result instanceof SwitchNotWellFormedSharedQuery }

query predicate problems(
  SwitchStmt switch, string message, SwitchStmt switchLocation, string switchMessage,
  SwitchCase case, string caseMessage
) {
  not isExcluded(switch, getQuery()) and
  case = switch.getASwitchCase() and
  switchCaseNotWellFormed(case) and
  switch = switchLocation and
  message =
    "$@ statement not well formed because this $@ block uses a statement that is not allowed." and
  switchMessage = "Switch" and
  caseMessage = "case"
}
