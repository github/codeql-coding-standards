/**
 * @id c/misra/recursive-function-condition
 * @name RULE-17-2: Functions shall not call themselves, either directly or indirectly
 * @description Recursive function may cause memory and system failure issues.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-2
 *       maintainability
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from FunctionCall fc, Function f, string msg
where
  not isExcluded(fc, Statements3Package::recursiveFunctionConditionQuery()) and
  fc.getEnclosingFunction() = f and
  fc.getTarget().calls*(f) and
  if fc.getTarget() = f
  then msg = f + " calls itself directly."
  else msg = f + " is indirectly recursive via this call to $@."
select fc, msg, fc.getTarget(), fc.getTarget().getName()
