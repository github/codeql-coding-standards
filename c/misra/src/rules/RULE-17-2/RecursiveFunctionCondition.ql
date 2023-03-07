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

from FunctionCall call, string msg, FunctionCall fc
where
  not isExcluded(fc, Statements3Package::recursiveFunctionConditionQuery()) and
  fc.getTarget() = call.getTarget() and
  call.getTarget().calls*(call.getEnclosingFunction()) and
  if fc.getTarget() = fc.getEnclosingFunction()
  then msg = "This call directly invokes its containing function $@."
  else
    msg =
      "The function " + fc.getEnclosingFunction() + " is indirectly recursive via this call to $@."
select fc, msg, fc.getTarget(), fc.getTarget().getName()
