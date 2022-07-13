/**
 * @id cpp/autosar/switch-does-not-start-with-case
 * @name M6-4-3: A well formed switch statement must start with a case clause
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
  not isExcluded(switch, ConditionalsPackage::switchDoesNotStartWithCaseQuery()) and
  case = switch.getASwitchCase() and
  switchWithCaseNotFirst(switch)
select switch,
  "$@ statement not well formed because the first statement in a well formed switch statement must be a case clause.",
  switch, "Switch"
