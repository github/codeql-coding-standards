/**
 * @id cpp/misra/exception-unfriendly-function-must-be-noexcept
 * @name RULE-18-4-1: Exception-unfriendly functions shall be noexcept
 * @description Throwing exceptions in constructors, destructors, copy-constructors, move
 *              constructors, assignments, and functions named swap, may result in
 *              implementation-defined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-4-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Function
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.SpecialFunctionExceptions

from UserDeclaredFunction func, string message, Element extra, string extraString
where
  not isExcluded([func, extra], Exceptions3Package::exceptionUnfriendlyFunctionMustBeNoexceptQuery()) and
  not isNoExceptTrue(func) and
  (
    message = "a " + func.(SpecialFunction).getSpecialDescription() and
    extra = func and
    extraString = ""
    or
    exists(SpecialUseOfFunction specialUse |
      specialUse.getFunction() = func and
      message = specialUse.getSpecialDescription(extra, extraString)
    )
  )
select func, "Function '" + func.getName() + "' must be noexcept because it is " + message + ".",
  extra, extraString
