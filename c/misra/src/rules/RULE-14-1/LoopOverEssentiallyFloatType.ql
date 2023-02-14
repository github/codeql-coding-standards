/**
 * @id c/misra/loop-over-essentially-float-type
 * @name RULE-14-1: A loop counter shall not have essentially floating type
 * @description A floating point loop counter can cause confusing behavior when incremented.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-14-1
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.cpp.Loops

from ForStmt forLoop, Variable loopIterationVariable
where
  not isExcluded(loopIterationVariable, EssentialTypesPackage::loopOverEssentiallyFloatTypeQuery()) and
  getAnIterationVariable(forLoop) = loopIterationVariable and
  getEssentialTypeCategory(loopIterationVariable.getType()) = EssentiallyFloatingType()
select loopIterationVariable,
  "Loop iteration variable " + loopIterationVariable.getName() + " is essentially Floating type."
