/**
 * @id cpp/autosar/continue-in-for-loop-condition
 * @name M6-6-3: The continue statement shall only be used within a well-formed for loop
 * @description The continue statement can cause unnecessary complexity.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-6-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ContinueStmt cont, ForStmt forLoop
where
  not isExcluded(cont, ConditionalsPackage::continueInForLoopConditionQuery()) and
  forLoop.getStmt().getChildStmt*() = cont and
  isInvalidLoop(forLoop)
select cont, "The $@ statement is used inside a $@ loop that is not well formed. ", cont,
  "continue", forLoop, "for"
