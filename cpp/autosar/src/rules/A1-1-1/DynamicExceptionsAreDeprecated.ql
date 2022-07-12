/**
 * @id cpp/autosar/dynamic-exceptions-are-deprecated
 * @name A1-1-1: Dynamic Exception Specifications are deprecated
 * @description Dynamic Exception Specifications are deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
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
  not isExcluded(f, ToolchainPackage::dynamicExceptionsAreDeprecatedQuery()) and
  hasDynamicExceptionSpecification(f) and
  // Exclude compiler generated, because the user cannot remove those
  not f.isCompilerGenerated()
select f,
  "Use of dynamic exception specification '" + getDynamicExceptionSpecification(f) +
    "' is deprecated."
