/**
 * @id cpp/autosar/use-of-dynamic-exception-specification
 * @name A15-4-1: Dynamic exception-specification shall not be used
 * @description Dynamic exception-specifications are deprecated in C++11 onwards.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a15-4-1
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
  not isExcluded(f, Exceptions1Package::useOfDynamicExceptionSpecificationQuery()) and
  hasDynamicExceptionSpecification(f) and
  // Exclude compiler generated, because the user cannot remove those
  not f.isCompilerGenerated()
select f,
  "The function " + f.getName() + " is declared with the dynamic exception specification " +
    getDynamicExceptionSpecification(f) + "."
