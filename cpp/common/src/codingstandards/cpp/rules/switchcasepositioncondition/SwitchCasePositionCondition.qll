/**
 * Provides a library with a `problems` predicate for the following issue:
 * The switch statement syntax is weak and may lead to unspecified behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SwitchStatement

abstract class SwitchCasePositionConditionSharedQuery extends Query { }

Query getQuery() { result instanceof SwitchCasePositionConditionSharedQuery }

//from SwitchStmt switch, SwitchCase case
//where
//not isExcluded(switch, ConditionalsPackage::switchDoesNotStartWithCaseQuery()) and
//case = switch.getASwitchCase() and
//switchWithCaseNotFirst(switch)
//select switch,
//"$@ statement not well formed because the first statement in a well formed switch statement must be a case clause.",
//switch, "Switch"
query predicate problems(
  SwitchStmt switch, string message, SwitchStmt switchLocation, string switchMessage
) {
  not isExcluded(switch, getQuery()) and
  exists(SwitchCase case | case = switch.getASwitchCase()) and
  switchWithCaseNotFirst(switch) and
  switchLocation = switch and
  switchMessage = "Switch" and
  message =
    "$@ statement not well formed because the first statement in a well formed switch statement must be a case clause."
}
