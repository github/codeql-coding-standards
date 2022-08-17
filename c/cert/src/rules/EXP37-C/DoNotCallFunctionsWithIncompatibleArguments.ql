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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.MistypedFunctionArguments

from FunctionCall fc, Function f, Parameter p
where
  not isExcluded(fc, ExpressionsPackage::doNotCallFunctionsWithIncompatibleArgumentsQuery()) and
  (
    mistypedFunctionArguments(fc, f, p)
    or
    complexArgumentPassedToRealParameter(fc, f, p)
  )
select fc,
  "Argument $@ in call to " + f.toString() + " is incompatible with parameter " + p.getTypedName() +
    ".", fc.getArgument(p.getIndex()) as arg, arg.toString()
