/**
 * @id cpp/autosar/function-erroneous-return-value-not-tested
 * @name M0-3-2: If a function generates error information, then that error information shall be tested
 * @description A function (whether it is part of the standard library, a third party library or a
 *              user defined function) may provide some means of indicating the occurrence of an
 *              error. This may be via a global error flag, a parametric error flag, a special
 *              return value or some other means. Whenever such a mechanism is provided by a
 *              function the calling program shall check for the indication of an error as soon as
 *              the function returns.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m0-3-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.functionerroneousreturnvaluenottested.FunctionErroneousReturnValueNotTested

class FunctionErrorInformationUntestedQuery extends FunctionErroneousReturnValueNotTestedSharedQuery
{
  FunctionErrorInformationUntestedQuery() {
    this = ExpressionsPackage::functionErroneousReturnValueNotTestedQuery()
  }
}
