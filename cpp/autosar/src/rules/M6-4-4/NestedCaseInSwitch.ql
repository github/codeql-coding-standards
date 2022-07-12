/**
 * @id cpp/autosar/nested-case-in-switch
 * @name M6-4-4: A switch-label shall only be used when the most closely-enclosing compound statement is the body of a switch statement
 * @description By default in C++, the switch structure is weak, which may lead to switch labels
 *              being placed anywhere in the switch block. This can cause unspecified behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-4
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SwitchStatement

from SwitchCase nestedCase, SwitchStmt switch
where
  not isExcluded(nestedCase, ConditionalsPackage::nestedCaseInSwitchQuery()) and
  switch.getASwitchCase() = nestedCase and
  not nestedCase.getParentStmt() = switch.getChildStmt()
select nestedCase,
  "Weak switch structure - the parent statement of this $@ clause does not belong to its $@ statement.",
  switch, "switch", nestedCase, "case"
