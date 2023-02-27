/**
 * @id c/misra/value-returned-by-a-function-not-used
 * @name RULE-17-7: Return values should be used or cast to void
 * @description The value returned by a function having non-void return type shall be used or cast
 *              to void.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-17-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.dataflow.DataFlow

from Call c
where
  not isExcluded(c, Contracts6Package::valueReturnedByAFunctionNotUsedQuery()) and
  // Calls in `ExprStmt`s indicate that the return value is ignored
  c.getParent() instanceof ExprStmt and
  // Ignore calls to void functions or where the return value is cast to `void`
  not c.getActualType() instanceof VoidType and
  // Exclude cases where the function call is generated within a macro, as the user of the macro is
  // not necessarily able to address thoes results
  not c.isAffectedByMacro()
select c, "The value returned by this call shall be used or cast to `void`."
