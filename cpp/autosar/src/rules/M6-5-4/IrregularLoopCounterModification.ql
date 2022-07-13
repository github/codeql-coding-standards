/**
 * @id cpp/autosar/irregular-loop-counter-modification
 * @name M6-5-4: Loop-counter modified by one of --, ++, = n, or + = n, where n remains constant
 * @description The loop-counter should be modified by one of: --, ++, -=n, or +=n; where n remains
 *              constant for the duration of the loop.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m6-5-4
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from ForStmt forLoop, Variable loopCounter, VariableAccess loopCounterAccess
where
  not isExcluded(loopCounter, LoopsPackage::irregularLoopCounterModificationQuery()) and
  isIrregularLoopCounterModification(forLoop, loopCounter, loopCounterAccess)
select loopCounter, "Loop counter " + loopCounter.getName() + " when modified may not be constant."
