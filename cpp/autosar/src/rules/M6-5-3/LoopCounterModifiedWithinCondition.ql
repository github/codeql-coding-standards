/**
 * @id cpp/autosar/loop-counter-modified-within-condition
 * @name M6-5-3: Loop-counter modified within condition
 * @description The loop-counter shall not be modified within condition.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m6-5-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ForStmt forLoop, VariableAccess loopCounterAccess
where
  not isExcluded(forLoop, LoopsPackage::loopCounterModifiedWithinConditionQuery()) and
  isLoopCounterModifiedInCondition(forLoop, loopCounterAccess)
select loopCounterAccess, "Loop counter modified within the condition in a for loop."
