/**
 * @id cpp/cert/honor-exception-specifications
 * @name ERR55-CPP: Honor exception specifications
 * @description A function which throws an exception which is not permitted by the exception
 *              specification causes abrupt termination of the program, and can leave resources such
 *              as streams and temporary files in an unclosed state.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err55-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications
import ExceptionPathGraph

/**
 * A function which violates its declared dynamic exception specification.
 */
class ExceptionSpecificationContravenedFunction extends ExceptionThrowingFunction {
  ExceptionType thrownExceptionType;
  string message;

  ExceptionSpecificationContravenedFunction() {
    thrownExceptionType = getAFunctionThrownType(this, _) and
    (
      hasDynamicExceptionSpecification(this) and
      not thrownExceptionType = getAHandledExceptionType(getAThrownType()) and
      message = "has a dynamic exception specification that does not specify this type."
      or
      isNoExceptTrue(this) and
      message = "is marked noexcept(true)."
    )
  }

  /** Gets an `ExceptionType` thrown by this function which is not covered by the dynamic exception specification. */
  ExceptionType getASpecificationContraveningExceptionType() { result = thrownExceptionType }

  string getMessage() { result = message }
}

from
  ExceptionSpecificationContravenedFunction function, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode, ExceptionType exceptionType
where
  not isExcluded(function, Exceptions1Package::honorExceptionSpecificationsQuery()) and
  function.hasExceptionFlow(exceptionSource, functionNode, exceptionType) and
  exceptionType = function.getASpecificationContraveningExceptionType()
select function, exceptionSource, functionNode,
  function.getName() + " can throw an exception of type " + exceptionType.getExceptionName() +
    " but " + function.getMessage()
