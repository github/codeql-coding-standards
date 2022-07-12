/**
 * @id cpp/autosar/loop-counter-modified-within-statement
 * @name M6-5-3: Loop-counter modified within condition
 * @description The loop-counter shall not be modified within a statement.
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

from ForStmt forLoop, Variable loopCounter, VariableAccess loopCounterAccess
where
  not isExcluded(forLoop, LoopsPackage::loopCounterModifiedWithinStatementQuery()) and
  isLoopCounterModifiedInStatement(forLoop, loopCounter, loopCounterAccess)
select loopCounterAccess, "Loop counters should not be modified within a statement in a for loop."
