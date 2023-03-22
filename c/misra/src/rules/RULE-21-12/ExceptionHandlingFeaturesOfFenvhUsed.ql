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
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

class FPExceptionHandlingFunction extends Function {
  FPExceptionHandlingFunction() {
    this.hasName([
        "feclearexcept", "fegetexceptflag", "feraiseexcept", "fesetexceptflag", "fetestexcept"
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

from Locatable call, string name, string kind
where
  not isExcluded(call, BannedPackage::exceptionHandlingFeaturesOfFenvhUsedQuery()) and
  (
    exists(FPExceptionHandlingFunction f |
      call = f.getACallToThisFunction() and
      name = f.getName() and
      kind = "function"
    )
    or
    exists(FPExceptionHandlingMacro m |
      call = m.getAnInvocation() and
      name = m.getName() and
      kind = "macro" and
      // Exclude macro invocations expanded from other macro invocations from macros in fenv.h.
      not call.(MacroInvocation).getParentInvocation().getMacro().getFile().getBaseName() = "fenv.h"
    )
  )
select call, "Call to banned " + kind + " " + name + "."
