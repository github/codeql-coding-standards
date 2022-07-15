/**
 * @id c/misra/memory-alloc-dealloc-functions-of-stdlibh-used
 * @name RULE-21-3: The memory allocation and deallocation functions of 'stdlib.h' shall not be used
 * @description The use of memory allocation and deallocation in 'stdlib.h' may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-3
 *       correctness
 *       security
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
