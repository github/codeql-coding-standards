/**
 * @id c/misra/size-in-realloc-call-may-be-zero
 * @name RULE-1-5: Size argument value in realloc call may equal zero
 * @description Invoking realloc with a size argument set to zero is implementation-defined behavior
 *              and declared as an obsolete feature in C18.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-1-5
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Realloc

from ReallocCall call
where
  not isExcluded(call, Language4Package::sizeInReallocCallMayBeZeroQuery()) and
  call.sizeMayBeZero() and
  not call.sizeIsExactlyZero()
select call,
  "Size argument '$@' equals zero in realloc call, resulting in obsolescent and/or implementation-defined behavior.",
  call.getSizeArgument(), call.getSizeArgument().toString()
