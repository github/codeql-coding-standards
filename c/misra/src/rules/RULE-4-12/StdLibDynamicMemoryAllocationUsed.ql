/**
 * @id c/misra/std-lib-dynamic-memory-allocation-used
 * @name RULE-4-12: Dynamic memory allocation shall not be used
 * @description Using dynamic memory allocation and deallocation can result to undefined behaviour.
 *              This query is for the Standard Library Implementation. Any implementation outside it
 *              will require a seperate query under the same directive
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-4-12
 *       security
 *       correctness
 *       maintainability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import cpp
import codingstandards.c.misra
import semmle.code.cpp.models.interfaces.Allocation
import semmle.code.cpp.models.interfaces.Deallocation

from Expr e, string type
where
  not isExcluded(e, BannedPackage::memoryAllocDeallocFunctionsOfStdlibhUsedQuery()) and
  (
    e.(FunctionCall).getTarget().(AllocationFunction).requiresDealloc() and
    type = "allocation"
    or
    e instanceof DeallocationExpr and
    not e.(FunctionCall).getTarget() instanceof AllocationFunction and
    type = "deallocation"
  )
select e, "Use of banned dynamic memory " + type + "."
