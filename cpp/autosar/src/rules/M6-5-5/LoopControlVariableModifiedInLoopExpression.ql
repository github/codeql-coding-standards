/**
 * @id cpp/autosar/loop-control-variable-modified-in-loop-expression
 * @name M6-5-5: Loop-control-variable modified within a expression
 * @description A loop-control-variable other than the loop-counter shall not be modified within an
 *              expression.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m6-5-5
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
  not isExcluded(forLoop, LoopsPackage::loopControlVariableModifiedInLoopExpressionQuery()) and
  isLoopControlVarModifiedInLoopExpr(forLoop, loopControlVariable, loopControlVariableAccess)
select loopControlVariableAccess,
  "Loop control variable " + loopControlVariable.getName() +
    " is modified in the loop update expression."
