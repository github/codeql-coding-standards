/**
 * @id cpp/autosar/missing-no-except
 * @name A15-4-4: A declaration of non-throwing function shall contain noexcept specification
 * @description Adding a noexcept specifier makes it clearer that the function is not intended to
 *              throw functions.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a15-4-4
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionSpecifications
import codingstandards.cpp.exceptions.ExceptionFlow

from Function f
where
  not isExcluded(f, Exceptions1Package::missingNoExceptQuery()) and
  // No thrown exceptions
  not exists(getAFunctionThrownType(f, _)) and
  // But not marked noexcept(true)
  not isNoExceptTrue(f) and
  // Not explicitly marked noexcept(false)
  not isNoExceptExplicitlyFalse(f) and
  // Not compiler generated
  not f.isCompilerGenerated() and
  // The function is defined in this database
  f.hasDefinition() and
  // This function is not an overriden call operator of a lambda expression
  not exists(LambdaExpression lambda | lambda.getLambdaFunction() = f)
select f, "Function " + f.getName() + " could be declared noexcept(true)."
