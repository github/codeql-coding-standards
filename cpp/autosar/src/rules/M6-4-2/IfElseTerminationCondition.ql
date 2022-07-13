/**
 * @id cpp/autosar/if-else-termination-condition
 * @name M6-4-2: All if ... else if constructs shall be terminated with an else clause
 * @description The final else statement is a defensive programming technique.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-4-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from IfStmt ifStmt, IfStmt ifElse
where
  not isExcluded(ifStmt, ConditionalsPackage::ifElseTerminationConditionQuery()) and
  ifStmt.getElse() = ifElse and
  not ifElse.hasElse()
select ifStmt, "The $@ if statement does not terminate with an else construct.", ifElse, "if...else"
