/**
 * @id cpp/autosar/switch-statement-not-well-formed
 * @name M6-4-3: A well formed switch statement should only have expression, compound, selection, iteration or try statements within its body
 * @description By default, in C++ the switch statement syntax is weak which may lead to unspecified
 *              behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SwitchStatement

from SwitchStmt switch, SwitchCase case
where
  not isExcluded(switch, ConditionalsPackage::switchStatementNotWellFormedQuery()) and
  case = switch.getASwitchCase() and
  switchCaseNotWellFormed(case)
select switch,
  "$@ statement not well formed because this $@ block uses a statement that is not allowed.",
  switch, "Switch", case, "case"
