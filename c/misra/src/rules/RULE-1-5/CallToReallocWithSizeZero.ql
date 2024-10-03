/**
 * @id c/misra/call-to-realloc-with-size-zero
 * @name RULE-1-5: Disallowed size argument value equal to zero in call to realloc
 * @description Invoking realloc with a size argument set to zero is implementation-defined behavior
 *              and declared as an obsolete feature in C18.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-1-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.new.RangeAnalysis

from FunctionCall call, Expr arg
where
  not isExcluded(call, Language4Package::callToReallocWithSizeZeroQuery()) and
  call.getTarget().hasGlobalOrStdName("realloc") and
  arg = call.getArgument(1) and
  upperBound(arg) = 0
select arg, "Calling realloc with size zero results in implementation-defined behavior."
