/**
 * @id cpp/autosar/valid-resources-state-before-throw
 * @name A15-1-4: All resources must be in a valid state before an exception is thrown
 * @description If a function exits with an exception, then before a throw, the function shall place
 *              all objects/resources that the function constructed in valid states or it shall
 *              delete them.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-1-4
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.exceptionsafetyvalidstate.ExceptionSafetyValidState

class ValidResourcesStateBeforeThrowQuery extends ExceptionSafetyValidStateSharedQuery {
  ValidResourcesStateBeforeThrowQuery() {
    this = ExceptionSafetyPackage::validResourcesStateBeforeThrowQuery()
  }
}
