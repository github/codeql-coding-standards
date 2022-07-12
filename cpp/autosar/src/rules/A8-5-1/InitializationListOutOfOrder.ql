/**
 * @id cpp/autosar/initialization-list-out-of-order
 * @name A8-5-1: Write constructor member initializers in the canonical order
 * @description In an initialization list, the order of initialization shall be following: (1)
 *              virtual base classes in depth and left to right order of the inheritance graph, (2)
 *              direct base classes in left to right order of inheritance list, (3) non-static data
 *              members in the order they were declared in the class definition.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a8-5-1
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.usecanonicalorderformemberinit.UseCanonicalOrderForMemberInit

class InitializationListOutOfOrderQuery extends UseCanonicalOrderForMemberInitSharedQuery {
  InitializationListOutOfOrderQuery() {
    this = InitializationPackage::initializationListOutOfOrderQuery()
  }
}
