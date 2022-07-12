/**
 * @id cpp/autosar/non-boolean-loop-control-variable
 * @name M6-5-6: Loop-control-variable modified in a statement shall have type bool
 * @description A loop-control-variable other than the loop-counter which is modified in a statement
 *              shall have type bool.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m6-5-6
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Loops

from
  ForStmt forLoop, LoopControlVariable loopControlVariable, VariableAccess loopControlVariableAccess
where
  not isExcluded(forLoop, LoopsPackage::nonBooleanLoopControlVariableQuery()) and
  isNonBoolLoopControlVar(forLoop, loopControlVariable, loopControlVariableAccess)
select loopControlVariableAccess,
  "Loop control variable " + loopControlVariable.getName() +
    " is modified in a statement and must be of type bool."
