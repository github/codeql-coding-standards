/**
 * @id cpp/autosar/exception-safety-guarantees-not-provided
 * @name A15-0-2: Exception safety guarantees not provided
 * @description Basic guarantees for exception safety shall be provided for all operations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-0-2
 *       correctness
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.exceptionsafetyguarantees.ExceptionSafetyGuarantees

class ExceptionSafetyGuaranteesNotProvidedQuery extends ExceptionSafetyGuaranteesSharedQuery {
  ExceptionSafetyGuaranteesNotProvidedQuery() {
    this = ExceptionSafetyPackage::exceptionSafetyGuaranteesNotProvidedQuery()
  }
}
