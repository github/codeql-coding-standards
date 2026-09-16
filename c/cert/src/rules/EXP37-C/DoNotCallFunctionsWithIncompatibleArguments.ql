/**
 * @id c/cert/do-not-call-functions-with-incompatible-arguments
 * @name EXP37-C: Do not pass arguments with an incompatible count or type to a function
 * @description The arguments passed to a function must be compatible with the function's
 *              parameters.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp37-c
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.MistypedFunctionArguments

from FunctionCall fc, Parameter p
where
  not isExcluded(fc, ExpressionsPackage::doNotCallFunctionsWithIncompatibleArgumentsQuery()) and
  p = fc.getTarget().getAParameter() and
  (
    mistypedFunctionArguments(fc, p)
    or
    complexArgumentPassedToRealParameter(fc, p)
  )
select fc,
  "Argument $@ in " + fc.toString() + " is incompatible with parameter " + p.getTypedName() + ".",
  fc.getArgument(p.getIndex()) as arg, arg.toString()
