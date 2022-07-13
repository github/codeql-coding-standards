/**
 * @id cpp/autosar/missing-checked-exceptions
 * @name A15-4-5: Checked exceptions that could be thrown from a function should be specified
 * @description Checked exceptions that could be thrown from a function shall be specified together
 *              with the function declaration and they shall be identical in all function
 *              declarations and for all its overriders.
 * @kind path-problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a15-4-5
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.autosar.CheckedException
import codingstandards.cpp.exceptions.ExceptionFlow
import ExceptionPathGraph

/** A function which throws a `CheckedException` but is missing an `@throw`. */
class MissingCheckedExceptionThrowingFunction extends ExceptionThrowingFunction {
  CheckedException ce;

  MissingCheckedExceptionThrowingFunction() {
    ce = getAFunctionThrownType(this, _) and
    not exists(FunctionDeclarationEntry fde |
      fde = getADeclarationEntry() and
      ce = getADeclaredThrowsCheckedException(fde)
    )
  }

  CheckedException getAMissingCheckedException() { result = ce }
}

from
  MissingCheckedExceptionThrowingFunction f, CheckedException et, ExceptionFlowNode exceptionSource,
  ExceptionFlowNode functionNode
where
  not isExcluded(f, Exceptions2Package::missingCheckedExceptionsQuery()) and
  et = f.getAMissingCheckedException() and
  f.hasExceptionFlow(exceptionSource, functionNode, et)
select f, exceptionSource, functionNode,
  "Checked exception of type $@ thrown here which is not specified in any declaration for " +
    f.getName() + ".", et, et.getName()
