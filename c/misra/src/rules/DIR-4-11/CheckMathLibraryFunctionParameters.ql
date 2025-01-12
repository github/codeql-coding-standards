/**
 * @id c/misra/check-math-library-function-parameters
 * @name DIR-4-11: The validity of values passed to `math.h` library functions shall be checked
 * @description Range, domain or pole errors in math functions may return unexpected values, trigger
 *              floating-point exceptions or set unexpected error modes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-11
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.uncheckedrangedomainpoleerrors.UncheckedRangeDomainPoleErrors

class CheckMathLibraryFunctionParametersQuery extends UncheckedRangeDomainPoleErrorsSharedQuery {
  CheckMathLibraryFunctionParametersQuery() {
    this = ContractsPackage::checkMathLibraryFunctionParametersQuery()
  }
}
