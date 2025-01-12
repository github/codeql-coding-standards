/**
 * @id c/misra/function-error-information-untested
 * @name DIR-4-7: If a function generates error information, then that error information shall be tested
 * @description A function (whether it is part of the standard library, a third party library or a
 *              user defined function) may provide some means of indicating the occurrence of an
 *              error. This may be via a global error flag, a parametric error flag, a special
 *              return value or some other means. Whenever such a mechanism is provided by a
 *              function the calling program shall check for the indication of an error as soon as
 *              the function returns.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/dir-4-7
 *       maintainability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.functionerroneousreturnvaluenottested.FunctionErroneousReturnValueNotTested

class FunctionErrorInformationUntestedQuery extends FunctionErroneousReturnValueNotTestedSharedQuery
{
  FunctionErrorInformationUntestedQuery() {
    this = ContractsPackage::functionErrorInformationUntestedQuery()
  }
}
