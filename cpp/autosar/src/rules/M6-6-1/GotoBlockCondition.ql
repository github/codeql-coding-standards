/**
 * @id cpp/autosar/goto-block-condition
 * @name M6-6-1: Any label referenced by a goto statement shall be declared in the same block, or in a block enclosing the goto statement
 * @description Unconstrained use of goto can lead to unspecified behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m6-6-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from GotoStmt goto
where
  not isExcluded(goto, ConditionalsPackage::gotoBlockConditionQuery()) and
  not goto.getEnclosingBlock+() = goto.getTarget().getEnclosingBlock()
select goto, "The goto label $@ is located inside a nested block.", goto.getTarget(), goto.getName()
