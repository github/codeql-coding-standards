/**
 * @id c/misra/exception-handling-features-of-fenvh-used
 * @name RULE-21-12: The exception handling features of 'fenv.h' should not be used
 * @description The use of the exception handling features of 'fenv.h' may result in undefined
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-21-12
 *       correctness
 *       external/misra/c/2012/amendment2
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

class FPExceptionHandlingFunction extends Function {
  FPExceptionHandlingFunction() {
    this.hasName([
        "feclearexcept", "fegetexceptflag", "feraiseexcept", "fesetexceptflag", "fetestexcept",
        "fesetenv", "feupdateenv", "fesetround"
      ]) and
    this.getFile().getBaseName() = "fenv.h"
  }
}

class FPExceptionHandlingMacro extends Macro {
  FPExceptionHandlingMacro() {
    this.hasName([
        "FE_INEXACT", "FE_DIVBYZERO", "FE_UNDERFLOW", "FE_OVERFLOW", "FE_INVALID", "FE_ALL_EXCEPT"
      ]) and
    this.getFile().getBaseName() = "fenv.h"
  }
}

from Locatable element, string name, string message
where
  not isExcluded(element, BannedPackage::exceptionHandlingFeaturesOfFenvhUsedQuery()) and
  (
    exists(Include include |
      include.getIncludedFile().getBaseName() = "fenv.h" and
      message = "Include of banned header" and
      name = "fenv.h" and
      element = include
    )
    or
    exists(FPExceptionHandlingFunction f |
      element = f.getACallToThisFunction() and
      name = f.getName() and
      message = "Call to banned function"
    )
    or
    exists(FPExceptionHandlingMacro m |
      element = m.getAnInvocation() and
      name = m.getName() and
      message = "Expansion of banned macro" and
      // Exclude macro invocations expanded from other macro invocations from macros in fenv.h.
      not element.(MacroInvocation).getParentInvocation().getMacro().getFile().getBaseName() =
        "fenv.h"
    )
  )
select element, message + " '" + name + "'."
