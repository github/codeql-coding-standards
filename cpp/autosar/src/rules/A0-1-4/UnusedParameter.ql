/**
 * @id cpp/autosar/unused-parameter
 * @name A0-1-4: There shall be no unused named parameters in non-virtual functions
 * @description Unused parameters can indicate a mistake when implementing the function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedParameters
import codingstandards.cpp.rules.unusedparameter.UnusedParameter

class UnusedParameterQuery extends UnusedParameterSharedQuery {
  UnusedParameterQuery() { this = DeadCodePackage::unusedParameterQuery() }
}
